
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 80 12 00       	mov    $0x128000,%eax
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
c0100020:	a3 00 80 12 c0       	mov    %eax,0xc0128000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 70 12 c0       	mov    $0xc0127000,%esp
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
c010003c:	ba 4c d1 12 c0       	mov    $0xc012d14c,%edx
c0100041:	b8 00 a0 12 c0       	mov    $0xc012a000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	83 ec 04             	sub    $0x4,%esp
c010004d:	50                   	push   %eax
c010004e:	6a 00                	push   $0x0
c0100050:	68 00 a0 12 c0       	push   $0xc012a000
c0100055:	e8 ef 9f 00 00       	call   c010a049 <memset>
c010005a:	83 c4 10             	add    $0x10,%esp

    cons_init();                // init the console
c010005d:	e8 31 31 00 00       	call   c0103193 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100062:	c7 45 f4 e0 a8 10 c0 	movl   $0xc010a8e0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c0100069:	83 ec 08             	sub    $0x8,%esp
c010006c:	ff 75 f4             	pushl  -0xc(%ebp)
c010006f:	68 fc a8 10 c0       	push   $0xc010a8fc
c0100074:	e8 11 02 00 00       	call   c010028a <cprintf>
c0100079:	83 c4 10             	add    $0x10,%esp

    print_kerninfo();
c010007c:	e8 20 1c 00 00       	call   c0101ca1 <print_kerninfo>

    grade_backtrace();
c0100081:	e8 8b 00 00 00       	call   c0100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100086:	e8 41 80 00 00       	call   c01080cc <pmm_init>

    pic_init();                 // init interrupt controller
c010008b:	e8 75 32 00 00       	call   c0103305 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100090:	e8 d6 33 00 00       	call   c010346b <idt_init>

    vmm_init();                 // init virtual memory management
c0100095:	e8 76 48 00 00       	call   c0104910 <vmm_init>
    proc_init();                // init process table
c010009a:	e8 78 99 00 00       	call   c0109a17 <proc_init>
    
    ide_init();                 // init ide devices
c010009f:	e8 be 20 00 00       	call   c0102162 <ide_init>
    swap_init();                // init swap
c01000a4:	e8 26 51 00 00       	call   c01051cf <swap_init>

    clock_init();               // init clock interrupt
c01000a9:	e8 8c 28 00 00       	call   c010293a <clock_init>
    intr_enable();              // enable irq interrupt
c01000ae:	e8 8f 33 00 00       	call   c0103442 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000b3:	e8 ff 9a 00 00       	call   c0109bb7 <cpu_idle>

c01000b8 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b8:	55                   	push   %ebp
c01000b9:	89 e5                	mov    %esp,%ebp
c01000bb:	83 ec 08             	sub    $0x8,%esp
    mon_backtrace(0, NULL, NULL);
c01000be:	83 ec 04             	sub    $0x4,%esp
c01000c1:	6a 00                	push   $0x0
c01000c3:	6a 00                	push   $0x0
c01000c5:	6a 00                	push   $0x0
c01000c7:	e8 2a 20 00 00       	call   c01020f6 <mon_backtrace>
c01000cc:	83 c4 10             	add    $0x10,%esp
}
c01000cf:	90                   	nop
c01000d0:	c9                   	leave  
c01000d1:	c3                   	ret    

c01000d2 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000d2:	55                   	push   %ebp
c01000d3:	89 e5                	mov    %esp,%ebp
c01000d5:	53                   	push   %ebx
c01000d6:	83 ec 04             	sub    $0x4,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d9:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000dc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000df:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01000e5:	51                   	push   %ecx
c01000e6:	52                   	push   %edx
c01000e7:	53                   	push   %ebx
c01000e8:	50                   	push   %eax
c01000e9:	e8 ca ff ff ff       	call   c01000b8 <grade_backtrace2>
c01000ee:	83 c4 10             	add    $0x10,%esp
}
c01000f1:	90                   	nop
c01000f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01000f5:	c9                   	leave  
c01000f6:	c3                   	ret    

c01000f7 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000f7:	55                   	push   %ebp
c01000f8:	89 e5                	mov    %esp,%ebp
c01000fa:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace1(arg0, arg2);
c01000fd:	83 ec 08             	sub    $0x8,%esp
c0100100:	ff 75 10             	pushl  0x10(%ebp)
c0100103:	ff 75 08             	pushl  0x8(%ebp)
c0100106:	e8 c7 ff ff ff       	call   c01000d2 <grade_backtrace1>
c010010b:	83 c4 10             	add    $0x10,%esp
}
c010010e:	90                   	nop
c010010f:	c9                   	leave  
c0100110:	c3                   	ret    

c0100111 <grade_backtrace>:

void
grade_backtrace(void) {
c0100111:	55                   	push   %ebp
c0100112:	89 e5                	mov    %esp,%ebp
c0100114:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100117:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010011c:	83 ec 04             	sub    $0x4,%esp
c010011f:	68 00 00 ff ff       	push   $0xffff0000
c0100124:	50                   	push   %eax
c0100125:	6a 00                	push   $0x0
c0100127:	e8 cb ff ff ff       	call   c01000f7 <grade_backtrace0>
c010012c:	83 c4 10             	add    $0x10,%esp
}
c010012f:	90                   	nop
c0100130:	c9                   	leave  
c0100131:	c3                   	ret    

c0100132 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100132:	55                   	push   %ebp
c0100133:	89 e5                	mov    %esp,%ebp
c0100135:	83 ec 18             	sub    $0x18,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100138:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010013b:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010013e:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100141:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100144:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100148:	0f b7 c0             	movzwl %ax,%eax
c010014b:	83 e0 03             	and    $0x3,%eax
c010014e:	89 c2                	mov    %eax,%edx
c0100150:	a1 00 a0 12 c0       	mov    0xc012a000,%eax
c0100155:	83 ec 04             	sub    $0x4,%esp
c0100158:	52                   	push   %edx
c0100159:	50                   	push   %eax
c010015a:	68 01 a9 10 c0       	push   $0xc010a901
c010015f:	e8 26 01 00 00       	call   c010028a <cprintf>
c0100164:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  cs = %x\n", round, reg1);
c0100167:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010016b:	0f b7 d0             	movzwl %ax,%edx
c010016e:	a1 00 a0 12 c0       	mov    0xc012a000,%eax
c0100173:	83 ec 04             	sub    $0x4,%esp
c0100176:	52                   	push   %edx
c0100177:	50                   	push   %eax
c0100178:	68 0f a9 10 c0       	push   $0xc010a90f
c010017d:	e8 08 01 00 00       	call   c010028a <cprintf>
c0100182:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ds = %x\n", round, reg2);
c0100185:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100189:	0f b7 d0             	movzwl %ax,%edx
c010018c:	a1 00 a0 12 c0       	mov    0xc012a000,%eax
c0100191:	83 ec 04             	sub    $0x4,%esp
c0100194:	52                   	push   %edx
c0100195:	50                   	push   %eax
c0100196:	68 1d a9 10 c0       	push   $0xc010a91d
c010019b:	e8 ea 00 00 00       	call   c010028a <cprintf>
c01001a0:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  es = %x\n", round, reg3);
c01001a3:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001a7:	0f b7 d0             	movzwl %ax,%edx
c01001aa:	a1 00 a0 12 c0       	mov    0xc012a000,%eax
c01001af:	83 ec 04             	sub    $0x4,%esp
c01001b2:	52                   	push   %edx
c01001b3:	50                   	push   %eax
c01001b4:	68 2b a9 10 c0       	push   $0xc010a92b
c01001b9:	e8 cc 00 00 00       	call   c010028a <cprintf>
c01001be:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ss = %x\n", round, reg4);
c01001c1:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001c5:	0f b7 d0             	movzwl %ax,%edx
c01001c8:	a1 00 a0 12 c0       	mov    0xc012a000,%eax
c01001cd:	83 ec 04             	sub    $0x4,%esp
c01001d0:	52                   	push   %edx
c01001d1:	50                   	push   %eax
c01001d2:	68 39 a9 10 c0       	push   $0xc010a939
c01001d7:	e8 ae 00 00 00       	call   c010028a <cprintf>
c01001dc:	83 c4 10             	add    $0x10,%esp
    round ++;
c01001df:	a1 00 a0 12 c0       	mov    0xc012a000,%eax
c01001e4:	83 c0 01             	add    $0x1,%eax
c01001e7:	a3 00 a0 12 c0       	mov    %eax,0xc012a000
}
c01001ec:	90                   	nop
c01001ed:	c9                   	leave  
c01001ee:	c3                   	ret    

c01001ef <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001ef:	55                   	push   %ebp
c01001f0:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001f2:	90                   	nop
c01001f3:	5d                   	pop    %ebp
c01001f4:	c3                   	ret    

c01001f5 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c01001f5:	55                   	push   %ebp
c01001f6:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c01001f8:	90                   	nop
c01001f9:	5d                   	pop    %ebp
c01001fa:	c3                   	ret    

c01001fb <lab1_switch_test>:

static void
lab1_switch_test(void) {
c01001fb:	55                   	push   %ebp
c01001fc:	89 e5                	mov    %esp,%ebp
c01001fe:	83 ec 08             	sub    $0x8,%esp
    lab1_print_cur_status();
c0100201:	e8 2c ff ff ff       	call   c0100132 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100206:	83 ec 0c             	sub    $0xc,%esp
c0100209:	68 48 a9 10 c0       	push   $0xc010a948
c010020e:	e8 77 00 00 00       	call   c010028a <cprintf>
c0100213:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_user();
c0100216:	e8 d4 ff ff ff       	call   c01001ef <lab1_switch_to_user>
    lab1_print_cur_status();
c010021b:	e8 12 ff ff ff       	call   c0100132 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100220:	83 ec 0c             	sub    $0xc,%esp
c0100223:	68 68 a9 10 c0       	push   $0xc010a968
c0100228:	e8 5d 00 00 00       	call   c010028a <cprintf>
c010022d:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_kernel();
c0100230:	e8 c0 ff ff ff       	call   c01001f5 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100235:	e8 f8 fe ff ff       	call   c0100132 <lab1_print_cur_status>
}
c010023a:	90                   	nop
c010023b:	c9                   	leave  
c010023c:	c3                   	ret    

c010023d <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010023d:	55                   	push   %ebp
c010023e:	89 e5                	mov    %esp,%ebp
c0100240:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c0100243:	83 ec 0c             	sub    $0xc,%esp
c0100246:	ff 75 08             	pushl  0x8(%ebp)
c0100249:	e8 76 2f 00 00       	call   c01031c4 <cons_putc>
c010024e:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
c0100251:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100254:	8b 00                	mov    (%eax),%eax
c0100256:	8d 50 01             	lea    0x1(%eax),%edx
c0100259:	8b 45 0c             	mov    0xc(%ebp),%eax
c010025c:	89 10                	mov    %edx,(%eax)
}
c010025e:	90                   	nop
c010025f:	c9                   	leave  
c0100260:	c3                   	ret    

c0100261 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100261:	55                   	push   %ebp
c0100262:	89 e5                	mov    %esp,%ebp
c0100264:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c0100267:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010026e:	ff 75 0c             	pushl  0xc(%ebp)
c0100271:	ff 75 08             	pushl  0x8(%ebp)
c0100274:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100277:	50                   	push   %eax
c0100278:	68 3d 02 10 c0       	push   $0xc010023d
c010027d:	e8 fd a0 00 00       	call   c010a37f <vprintfmt>
c0100282:	83 c4 10             	add    $0x10,%esp
    return cnt;
c0100285:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100288:	c9                   	leave  
c0100289:	c3                   	ret    

c010028a <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c010028a:	55                   	push   %ebp
c010028b:	89 e5                	mov    %esp,%ebp
c010028d:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100290:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100293:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100296:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100299:	83 ec 08             	sub    $0x8,%esp
c010029c:	50                   	push   %eax
c010029d:	ff 75 08             	pushl  0x8(%ebp)
c01002a0:	e8 bc ff ff ff       	call   c0100261 <vcprintf>
c01002a5:	83 c4 10             	add    $0x10,%esp
c01002a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002ae:	c9                   	leave  
c01002af:	c3                   	ret    

c01002b0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002b0:	55                   	push   %ebp
c01002b1:	89 e5                	mov    %esp,%ebp
c01002b3:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c01002b6:	83 ec 0c             	sub    $0xc,%esp
c01002b9:	ff 75 08             	pushl  0x8(%ebp)
c01002bc:	e8 03 2f 00 00       	call   c01031c4 <cons_putc>
c01002c1:	83 c4 10             	add    $0x10,%esp
}
c01002c4:	90                   	nop
c01002c5:	c9                   	leave  
c01002c6:	c3                   	ret    

c01002c7 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002c7:	55                   	push   %ebp
c01002c8:	89 e5                	mov    %esp,%ebp
c01002ca:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c01002cd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002d4:	eb 14                	jmp    c01002ea <cputs+0x23>
        cputch(c, &cnt);
c01002d6:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002da:	83 ec 08             	sub    $0x8,%esp
c01002dd:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002e0:	52                   	push   %edx
c01002e1:	50                   	push   %eax
c01002e2:	e8 56 ff ff ff       	call   c010023d <cputch>
c01002e7:	83 c4 10             	add    $0x10,%esp
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01002ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01002ed:	8d 50 01             	lea    0x1(%eax),%edx
c01002f0:	89 55 08             	mov    %edx,0x8(%ebp)
c01002f3:	0f b6 00             	movzbl (%eax),%eax
c01002f6:	88 45 f7             	mov    %al,-0x9(%ebp)
c01002f9:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01002fd:	75 d7                	jne    c01002d6 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01002ff:	83 ec 08             	sub    $0x8,%esp
c0100302:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100305:	50                   	push   %eax
c0100306:	6a 0a                	push   $0xa
c0100308:	e8 30 ff ff ff       	call   c010023d <cputch>
c010030d:	83 c4 10             	add    $0x10,%esp
    return cnt;
c0100310:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100313:	c9                   	leave  
c0100314:	c3                   	ret    

c0100315 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c0100315:	55                   	push   %ebp
c0100316:	89 e5                	mov    %esp,%ebp
c0100318:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c010031b:	e8 ed 2e 00 00       	call   c010320d <cons_getc>
c0100320:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100323:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100327:	74 f2                	je     c010031b <getchar+0x6>
        /* do nothing */;
    return c;
c0100329:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010032c:	c9                   	leave  
c010032d:	c3                   	ret    

c010032e <rb_node_create>:
#include <rb_tree.h>
#include <assert.h>

/* rb_node_create - create a new rb_node */
static inline rb_node *
rb_node_create(void) {
c010032e:	55                   	push   %ebp
c010032f:	89 e5                	mov    %esp,%ebp
c0100331:	83 ec 08             	sub    $0x8,%esp
    return kmalloc(sizeof(rb_node));
c0100334:	83 ec 0c             	sub    $0xc,%esp
c0100337:	6a 10                	push   $0x10
c0100339:	e8 d0 5e 00 00       	call   c010620e <kmalloc>
c010033e:	83 c4 10             	add    $0x10,%esp
}
c0100341:	c9                   	leave  
c0100342:	c3                   	ret    

c0100343 <rb_tree_empty>:

/* rb_tree_empty - tests if tree is empty */
static inline bool
rb_tree_empty(rb_tree *tree) {
c0100343:	55                   	push   %ebp
c0100344:	89 e5                	mov    %esp,%ebp
c0100346:	83 ec 10             	sub    $0x10,%esp
    rb_node *nil = tree->nil, *root = tree->root;
c0100349:	8b 45 08             	mov    0x8(%ebp),%eax
c010034c:	8b 40 04             	mov    0x4(%eax),%eax
c010034f:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100352:	8b 45 08             	mov    0x8(%ebp),%eax
c0100355:	8b 40 08             	mov    0x8(%eax),%eax
c0100358:	89 45 f8             	mov    %eax,-0x8(%ebp)
    return root->left == nil;
c010035b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010035e:	8b 40 08             	mov    0x8(%eax),%eax
c0100361:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100364:	0f 94 c0             	sete   %al
c0100367:	0f b6 c0             	movzbl %al,%eax
}
c010036a:	c9                   	leave  
c010036b:	c3                   	ret    

c010036c <rb_tree_create>:
 * Note that, root->left should always point to the node that is the root
 * of the tree. And nil points to a 'NULL' node which should always be
 * black and may have arbitrary children and parent node.
 * */
rb_tree *
rb_tree_create(int (*compare)(rb_node *node1, rb_node *node2)) {
c010036c:	55                   	push   %ebp
c010036d:	89 e5                	mov    %esp,%ebp
c010036f:	83 ec 18             	sub    $0x18,%esp
    assert(compare != NULL);
c0100372:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100376:	75 16                	jne    c010038e <rb_tree_create+0x22>
c0100378:	68 88 a9 10 c0       	push   $0xc010a988
c010037d:	68 98 a9 10 c0       	push   $0xc010a998
c0100382:	6a 1f                	push   $0x1f
c0100384:	68 ad a9 10 c0       	push   $0xc010a9ad
c0100389:	e8 da 13 00 00       	call   c0101768 <__panic>

    rb_tree *tree;
    rb_node *nil, *root;

    if ((tree = kmalloc(sizeof(rb_tree))) == NULL) {
c010038e:	83 ec 0c             	sub    $0xc,%esp
c0100391:	6a 0c                	push   $0xc
c0100393:	e8 76 5e 00 00       	call   c010620e <kmalloc>
c0100398:	83 c4 10             	add    $0x10,%esp
c010039b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010039e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003a2:	0f 84 b5 00 00 00    	je     c010045d <rb_tree_create+0xf1>
        goto bad_tree;
    }

    tree->compare = compare;
c01003a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003ab:	8b 55 08             	mov    0x8(%ebp),%edx
c01003ae:	89 10                	mov    %edx,(%eax)

    if ((nil = rb_node_create()) == NULL) {
c01003b0:	e8 79 ff ff ff       	call   c010032e <rb_node_create>
c01003b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01003b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01003bc:	0f 84 8a 00 00 00    	je     c010044c <rb_tree_create+0xe0>
        goto bad_node_cleanup_tree;
    }

    nil->parent = nil->left = nil->right = nil;
c01003c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003c8:	89 50 0c             	mov    %edx,0xc(%eax)
c01003cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003ce:	8b 50 0c             	mov    0xc(%eax),%edx
c01003d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003d4:	89 50 08             	mov    %edx,0x8(%eax)
c01003d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003da:	8b 50 08             	mov    0x8(%eax),%edx
c01003dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003e0:	89 50 04             	mov    %edx,0x4(%eax)
    nil->red = 0;
c01003e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003e6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tree->nil = nil;
c01003ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003f2:	89 50 04             	mov    %edx,0x4(%eax)

    if ((root = rb_node_create()) == NULL) {
c01003f5:	e8 34 ff ff ff       	call   c010032e <rb_node_create>
c01003fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01003fd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0100401:	74 38                	je     c010043b <rb_tree_create+0xcf>
        goto bad_node_cleanup_nil;
    }

    root->parent = root->left = root->right = nil;
c0100403:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100406:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100409:	89 50 0c             	mov    %edx,0xc(%eax)
c010040c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010040f:	8b 50 0c             	mov    0xc(%eax),%edx
c0100412:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100415:	89 50 08             	mov    %edx,0x8(%eax)
c0100418:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010041b:	8b 50 08             	mov    0x8(%eax),%edx
c010041e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100421:	89 50 04             	mov    %edx,0x4(%eax)
    root->red = 0;
c0100424:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100427:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tree->root = root;
c010042d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100430:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100433:	89 50 08             	mov    %edx,0x8(%eax)
    return tree;
c0100436:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100439:	eb 28                	jmp    c0100463 <rb_tree_create+0xf7>
    nil->parent = nil->left = nil->right = nil;
    nil->red = 0;
    tree->nil = nil;

    if ((root = rb_node_create()) == NULL) {
        goto bad_node_cleanup_nil;
c010043b:	90                   	nop
    root->red = 0;
    tree->root = root;
    return tree;

bad_node_cleanup_nil:
    kfree(nil);
c010043c:	83 ec 0c             	sub    $0xc,%esp
c010043f:	ff 75 f0             	pushl  -0x10(%ebp)
c0100442:	e8 df 5d 00 00       	call   c0106226 <kfree>
c0100447:	83 c4 10             	add    $0x10,%esp
c010044a:	eb 01                	jmp    c010044d <rb_tree_create+0xe1>
    }

    tree->compare = compare;

    if ((nil = rb_node_create()) == NULL) {
        goto bad_node_cleanup_tree;
c010044c:	90                   	nop
    return tree;

bad_node_cleanup_nil:
    kfree(nil);
bad_node_cleanup_tree:
    kfree(tree);
c010044d:	83 ec 0c             	sub    $0xc,%esp
c0100450:	ff 75 f4             	pushl  -0xc(%ebp)
c0100453:	e8 ce 5d 00 00       	call   c0106226 <kfree>
c0100458:	83 c4 10             	add    $0x10,%esp
c010045b:	eb 01                	jmp    c010045e <rb_tree_create+0xf2>

    rb_tree *tree;
    rb_node *nil, *root;

    if ((tree = kmalloc(sizeof(rb_tree))) == NULL) {
        goto bad_tree;
c010045d:	90                   	nop
bad_node_cleanup_nil:
    kfree(nil);
bad_node_cleanup_tree:
    kfree(tree);
bad_tree:
    return NULL;
c010045e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100463:	c9                   	leave  
c0100464:	c3                   	ret    

c0100465 <rb_left_rotate>:
    y->_left = x;                                               \
    x->parent = y;                                              \
    assert(!(nil->red));                                        \
}

FUNC_ROTATE(rb_left_rotate, left, right);
c0100465:	55                   	push   %ebp
c0100466:	89 e5                	mov    %esp,%ebp
c0100468:	83 ec 18             	sub    $0x18,%esp
c010046b:	8b 45 08             	mov    0x8(%ebp),%eax
c010046e:	8b 40 04             	mov    0x4(%eax),%eax
c0100471:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100474:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100477:	8b 40 0c             	mov    0xc(%eax),%eax
c010047a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010047d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100480:	8b 40 08             	mov    0x8(%eax),%eax
c0100483:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0100486:	74 10                	je     c0100498 <rb_left_rotate+0x33>
c0100488:	8b 45 0c             	mov    0xc(%ebp),%eax
c010048b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010048e:	74 08                	je     c0100498 <rb_left_rotate+0x33>
c0100490:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100493:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100496:	75 16                	jne    c01004ae <rb_left_rotate+0x49>
c0100498:	68 c4 a9 10 c0       	push   $0xc010a9c4
c010049d:	68 98 a9 10 c0       	push   $0xc010a998
c01004a2:	6a 64                	push   $0x64
c01004a4:	68 ad a9 10 c0       	push   $0xc010a9ad
c01004a9:	e8 ba 12 00 00       	call   c0101768 <__panic>
c01004ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004b1:	8b 50 08             	mov    0x8(%eax),%edx
c01004b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004b7:	89 50 0c             	mov    %edx,0xc(%eax)
c01004ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004bd:	8b 40 08             	mov    0x8(%eax),%eax
c01004c0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01004c3:	74 0c                	je     c01004d1 <rb_left_rotate+0x6c>
c01004c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004c8:	8b 40 08             	mov    0x8(%eax),%eax
c01004cb:	8b 55 0c             	mov    0xc(%ebp),%edx
c01004ce:	89 50 04             	mov    %edx,0x4(%eax)
c01004d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004d4:	8b 50 04             	mov    0x4(%eax),%edx
c01004d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004da:	89 50 04             	mov    %edx,0x4(%eax)
c01004dd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004e0:	8b 40 04             	mov    0x4(%eax),%eax
c01004e3:	8b 40 08             	mov    0x8(%eax),%eax
c01004e6:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01004e9:	75 0e                	jne    c01004f9 <rb_left_rotate+0x94>
c01004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004ee:	8b 40 04             	mov    0x4(%eax),%eax
c01004f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004f4:	89 50 08             	mov    %edx,0x8(%eax)
c01004f7:	eb 0c                	jmp    c0100505 <rb_left_rotate+0xa0>
c01004f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004fc:	8b 40 04             	mov    0x4(%eax),%eax
c01004ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100502:	89 50 0c             	mov    %edx,0xc(%eax)
c0100505:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100508:	8b 55 0c             	mov    0xc(%ebp),%edx
c010050b:	89 50 08             	mov    %edx,0x8(%eax)
c010050e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100511:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100514:	89 50 04             	mov    %edx,0x4(%eax)
c0100517:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010051a:	8b 00                	mov    (%eax),%eax
c010051c:	85 c0                	test   %eax,%eax
c010051e:	74 16                	je     c0100536 <rb_left_rotate+0xd1>
c0100520:	68 ec a9 10 c0       	push   $0xc010a9ec
c0100525:	68 98 a9 10 c0       	push   $0xc010a998
c010052a:	6a 64                	push   $0x64
c010052c:	68 ad a9 10 c0       	push   $0xc010a9ad
c0100531:	e8 32 12 00 00       	call   c0101768 <__panic>
c0100536:	90                   	nop
c0100537:	c9                   	leave  
c0100538:	c3                   	ret    

c0100539 <rb_right_rotate>:
FUNC_ROTATE(rb_right_rotate, right, left);
c0100539:	55                   	push   %ebp
c010053a:	89 e5                	mov    %esp,%ebp
c010053c:	83 ec 18             	sub    $0x18,%esp
c010053f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100542:	8b 40 04             	mov    0x4(%eax),%eax
c0100545:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100548:	8b 45 0c             	mov    0xc(%ebp),%eax
c010054b:	8b 40 08             	mov    0x8(%eax),%eax
c010054e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100551:	8b 45 08             	mov    0x8(%ebp),%eax
c0100554:	8b 40 08             	mov    0x8(%eax),%eax
c0100557:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010055a:	74 10                	je     c010056c <rb_right_rotate+0x33>
c010055c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100562:	74 08                	je     c010056c <rb_right_rotate+0x33>
c0100564:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100567:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010056a:	75 16                	jne    c0100582 <rb_right_rotate+0x49>
c010056c:	68 c4 a9 10 c0       	push   $0xc010a9c4
c0100571:	68 98 a9 10 c0       	push   $0xc010a998
c0100576:	6a 65                	push   $0x65
c0100578:	68 ad a9 10 c0       	push   $0xc010a9ad
c010057d:	e8 e6 11 00 00       	call   c0101768 <__panic>
c0100582:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100585:	8b 50 0c             	mov    0xc(%eax),%edx
c0100588:	8b 45 0c             	mov    0xc(%ebp),%eax
c010058b:	89 50 08             	mov    %edx,0x8(%eax)
c010058e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100591:	8b 40 0c             	mov    0xc(%eax),%eax
c0100594:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100597:	74 0c                	je     c01005a5 <rb_right_rotate+0x6c>
c0100599:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010059c:	8b 40 0c             	mov    0xc(%eax),%eax
c010059f:	8b 55 0c             	mov    0xc(%ebp),%edx
c01005a2:	89 50 04             	mov    %edx,0x4(%eax)
c01005a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005a8:	8b 50 04             	mov    0x4(%eax),%edx
c01005ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005ae:	89 50 04             	mov    %edx,0x4(%eax)
c01005b1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005b4:	8b 40 04             	mov    0x4(%eax),%eax
c01005b7:	8b 40 0c             	mov    0xc(%eax),%eax
c01005ba:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01005bd:	75 0e                	jne    c01005cd <rb_right_rotate+0x94>
c01005bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005c2:	8b 40 04             	mov    0x4(%eax),%eax
c01005c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005c8:	89 50 0c             	mov    %edx,0xc(%eax)
c01005cb:	eb 0c                	jmp    c01005d9 <rb_right_rotate+0xa0>
c01005cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005d0:	8b 40 04             	mov    0x4(%eax),%eax
c01005d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005d6:	89 50 08             	mov    %edx,0x8(%eax)
c01005d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005dc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01005df:	89 50 0c             	mov    %edx,0xc(%eax)
c01005e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005e8:	89 50 04             	mov    %edx,0x4(%eax)
c01005eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005ee:	8b 00                	mov    (%eax),%eax
c01005f0:	85 c0                	test   %eax,%eax
c01005f2:	74 16                	je     c010060a <rb_right_rotate+0xd1>
c01005f4:	68 ec a9 10 c0       	push   $0xc010a9ec
c01005f9:	68 98 a9 10 c0       	push   $0xc010a998
c01005fe:	6a 65                	push   $0x65
c0100600:	68 ad a9 10 c0       	push   $0xc010a9ad
c0100605:	e8 5e 11 00 00       	call   c0101768 <__panic>
c010060a:	90                   	nop
c010060b:	c9                   	leave  
c010060c:	c3                   	ret    

c010060d <rb_insert_binary>:
 * rb_insert_binary - insert @node to red-black @tree as if it were
 * a regular binary tree. This function is only intended to be called
 * by function rb_insert.
 * */
static inline void
rb_insert_binary(rb_tree *tree, rb_node *node) {
c010060d:	55                   	push   %ebp
c010060e:	89 e5                	mov    %esp,%ebp
c0100610:	83 ec 28             	sub    $0x28,%esp
    rb_node *x, *y, *z = node, *nil = tree->nil, *root = tree->root;
c0100613:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100616:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100619:	8b 45 08             	mov    0x8(%ebp),%eax
c010061c:	8b 40 04             	mov    0x4(%eax),%eax
c010061f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0100622:	8b 45 08             	mov    0x8(%ebp),%eax
c0100625:	8b 40 08             	mov    0x8(%eax),%eax
c0100628:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    z->left = z->right = nil;
c010062b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010062e:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100631:	89 50 0c             	mov    %edx,0xc(%eax)
c0100634:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100637:	8b 50 0c             	mov    0xc(%eax),%edx
c010063a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010063d:	89 50 08             	mov    %edx,0x8(%eax)
    y = root, x = y->left;
c0100640:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100643:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100646:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100649:	8b 40 08             	mov    0x8(%eax),%eax
c010064c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (x != nil) {
c010064f:	eb 2e                	jmp    c010067f <rb_insert_binary+0x72>
        y = x;
c0100651:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100654:	89 45 f0             	mov    %eax,-0x10(%ebp)
        x = (COMPARE(tree, x, node) > 0) ? x->left : x->right;
c0100657:	8b 45 08             	mov    0x8(%ebp),%eax
c010065a:	8b 00                	mov    (%eax),%eax
c010065c:	83 ec 08             	sub    $0x8,%esp
c010065f:	ff 75 0c             	pushl  0xc(%ebp)
c0100662:	ff 75 f4             	pushl  -0xc(%ebp)
c0100665:	ff d0                	call   *%eax
c0100667:	83 c4 10             	add    $0x10,%esp
c010066a:	85 c0                	test   %eax,%eax
c010066c:	7e 08                	jle    c0100676 <rb_insert_binary+0x69>
c010066e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100671:	8b 40 08             	mov    0x8(%eax),%eax
c0100674:	eb 06                	jmp    c010067c <rb_insert_binary+0x6f>
c0100676:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100679:	8b 40 0c             	mov    0xc(%eax),%eax
c010067c:	89 45 f4             	mov    %eax,-0xc(%ebp)
rb_insert_binary(rb_tree *tree, rb_node *node) {
    rb_node *x, *y, *z = node, *nil = tree->nil, *root = tree->root;

    z->left = z->right = nil;
    y = root, x = y->left;
    while (x != nil) {
c010067f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100682:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0100685:	75 ca                	jne    c0100651 <rb_insert_binary+0x44>
        y = x;
        x = (COMPARE(tree, x, node) > 0) ? x->left : x->right;
    }
    z->parent = y;
c0100687:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010068a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010068d:	89 50 04             	mov    %edx,0x4(%eax)
    if (y == root || COMPARE(tree, y, z) > 0) {
c0100690:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100693:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
c0100696:	74 17                	je     c01006af <rb_insert_binary+0xa2>
c0100698:	8b 45 08             	mov    0x8(%ebp),%eax
c010069b:	8b 00                	mov    (%eax),%eax
c010069d:	83 ec 08             	sub    $0x8,%esp
c01006a0:	ff 75 ec             	pushl  -0x14(%ebp)
c01006a3:	ff 75 f0             	pushl  -0x10(%ebp)
c01006a6:	ff d0                	call   *%eax
c01006a8:	83 c4 10             	add    $0x10,%esp
c01006ab:	85 c0                	test   %eax,%eax
c01006ad:	7e 0b                	jle    c01006ba <rb_insert_binary+0xad>
        y->left = z;
c01006af:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01006b2:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01006b5:	89 50 08             	mov    %edx,0x8(%eax)
c01006b8:	eb 09                	jmp    c01006c3 <rb_insert_binary+0xb6>
    }
    else {
        y->right = z;
c01006ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01006bd:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01006c0:	89 50 0c             	mov    %edx,0xc(%eax)
    }
}
c01006c3:	90                   	nop
c01006c4:	c9                   	leave  
c01006c5:	c3                   	ret    

c01006c6 <rb_insert>:

/* rb_insert - insert a node to red-black tree */
void
rb_insert(rb_tree *tree, rb_node *node) {
c01006c6:	55                   	push   %ebp
c01006c7:	89 e5                	mov    %esp,%ebp
c01006c9:	83 ec 18             	sub    $0x18,%esp
    rb_insert_binary(tree, node);
c01006cc:	83 ec 08             	sub    $0x8,%esp
c01006cf:	ff 75 0c             	pushl  0xc(%ebp)
c01006d2:	ff 75 08             	pushl  0x8(%ebp)
c01006d5:	e8 33 ff ff ff       	call   c010060d <rb_insert_binary>
c01006da:	83 c4 10             	add    $0x10,%esp
    node->red = 1;
c01006dd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006e0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)

    rb_node *x = node, *y;
c01006e6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
            x->parent->parent->red = 1;                         \
            rb_##_right##_rotate(tree, x->parent->parent);      \
        }                                                       \
    } while (0)

    while (x->parent->red) {
c01006ec:	e9 6c 01 00 00       	jmp    c010085d <rb_insert+0x197>
        if (x->parent == x->parent->parent->left) {
c01006f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006f4:	8b 50 04             	mov    0x4(%eax),%edx
c01006f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006fa:	8b 40 04             	mov    0x4(%eax),%eax
c01006fd:	8b 40 04             	mov    0x4(%eax),%eax
c0100700:	8b 40 08             	mov    0x8(%eax),%eax
c0100703:	39 c2                	cmp    %eax,%edx
c0100705:	0f 85 ad 00 00 00    	jne    c01007b8 <rb_insert+0xf2>
            RB_INSERT_SUB(left, right);
c010070b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010070e:	8b 40 04             	mov    0x4(%eax),%eax
c0100711:	8b 40 04             	mov    0x4(%eax),%eax
c0100714:	8b 40 0c             	mov    0xc(%eax),%eax
c0100717:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010071a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010071d:	8b 00                	mov    (%eax),%eax
c010071f:	85 c0                	test   %eax,%eax
c0100721:	74 35                	je     c0100758 <rb_insert+0x92>
c0100723:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100726:	8b 40 04             	mov    0x4(%eax),%eax
c0100729:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c010072f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100732:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100738:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010073b:	8b 40 04             	mov    0x4(%eax),%eax
c010073e:	8b 40 04             	mov    0x4(%eax),%eax
c0100741:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100747:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010074a:	8b 40 04             	mov    0x4(%eax),%eax
c010074d:	8b 40 04             	mov    0x4(%eax),%eax
c0100750:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100753:	e9 05 01 00 00       	jmp    c010085d <rb_insert+0x197>
c0100758:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075b:	8b 40 04             	mov    0x4(%eax),%eax
c010075e:	8b 40 0c             	mov    0xc(%eax),%eax
c0100761:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100764:	75 1a                	jne    c0100780 <rb_insert+0xba>
c0100766:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100769:	8b 40 04             	mov    0x4(%eax),%eax
c010076c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010076f:	83 ec 08             	sub    $0x8,%esp
c0100772:	ff 75 f4             	pushl  -0xc(%ebp)
c0100775:	ff 75 08             	pushl  0x8(%ebp)
c0100778:	e8 e8 fc ff ff       	call   c0100465 <rb_left_rotate>
c010077d:	83 c4 10             	add    $0x10,%esp
c0100780:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100783:	8b 40 04             	mov    0x4(%eax),%eax
c0100786:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c010078c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010078f:	8b 40 04             	mov    0x4(%eax),%eax
c0100792:	8b 40 04             	mov    0x4(%eax),%eax
c0100795:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c010079b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010079e:	8b 40 04             	mov    0x4(%eax),%eax
c01007a1:	8b 40 04             	mov    0x4(%eax),%eax
c01007a4:	83 ec 08             	sub    $0x8,%esp
c01007a7:	50                   	push   %eax
c01007a8:	ff 75 08             	pushl  0x8(%ebp)
c01007ab:	e8 89 fd ff ff       	call   c0100539 <rb_right_rotate>
c01007b0:	83 c4 10             	add    $0x10,%esp
c01007b3:	e9 a5 00 00 00       	jmp    c010085d <rb_insert+0x197>
        }
        else {
            RB_INSERT_SUB(right, left);
c01007b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007bb:	8b 40 04             	mov    0x4(%eax),%eax
c01007be:	8b 40 04             	mov    0x4(%eax),%eax
c01007c1:	8b 40 08             	mov    0x8(%eax),%eax
c01007c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01007c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01007ca:	8b 00                	mov    (%eax),%eax
c01007cc:	85 c0                	test   %eax,%eax
c01007ce:	74 32                	je     c0100802 <rb_insert+0x13c>
c01007d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007d3:	8b 40 04             	mov    0x4(%eax),%eax
c01007d6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c01007dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01007df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c01007e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007e8:	8b 40 04             	mov    0x4(%eax),%eax
c01007eb:	8b 40 04             	mov    0x4(%eax),%eax
c01007ee:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c01007f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007f7:	8b 40 04             	mov    0x4(%eax),%eax
c01007fa:	8b 40 04             	mov    0x4(%eax),%eax
c01007fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100800:	eb 5b                	jmp    c010085d <rb_insert+0x197>
c0100802:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100805:	8b 40 04             	mov    0x4(%eax),%eax
c0100808:	8b 40 08             	mov    0x8(%eax),%eax
c010080b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010080e:	75 1a                	jne    c010082a <rb_insert+0x164>
c0100810:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100813:	8b 40 04             	mov    0x4(%eax),%eax
c0100816:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100819:	83 ec 08             	sub    $0x8,%esp
c010081c:	ff 75 f4             	pushl  -0xc(%ebp)
c010081f:	ff 75 08             	pushl  0x8(%ebp)
c0100822:	e8 12 fd ff ff       	call   c0100539 <rb_right_rotate>
c0100827:	83 c4 10             	add    $0x10,%esp
c010082a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010082d:	8b 40 04             	mov    0x4(%eax),%eax
c0100830:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100836:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100839:	8b 40 04             	mov    0x4(%eax),%eax
c010083c:	8b 40 04             	mov    0x4(%eax),%eax
c010083f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100845:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100848:	8b 40 04             	mov    0x4(%eax),%eax
c010084b:	8b 40 04             	mov    0x4(%eax),%eax
c010084e:	83 ec 08             	sub    $0x8,%esp
c0100851:	50                   	push   %eax
c0100852:	ff 75 08             	pushl  0x8(%ebp)
c0100855:	e8 0b fc ff ff       	call   c0100465 <rb_left_rotate>
c010085a:	83 c4 10             	add    $0x10,%esp
            x->parent->parent->red = 1;                         \
            rb_##_right##_rotate(tree, x->parent->parent);      \
        }                                                       \
    } while (0)

    while (x->parent->red) {
c010085d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100860:	8b 40 04             	mov    0x4(%eax),%eax
c0100863:	8b 00                	mov    (%eax),%eax
c0100865:	85 c0                	test   %eax,%eax
c0100867:	0f 85 84 fe ff ff    	jne    c01006f1 <rb_insert+0x2b>
        }
        else {
            RB_INSERT_SUB(right, left);
        }
    }
    tree->root->left->red = 0;
c010086d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100870:	8b 40 08             	mov    0x8(%eax),%eax
c0100873:	8b 40 08             	mov    0x8(%eax),%eax
c0100876:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    assert(!(tree->nil->red) && !(tree->root->red));
c010087c:	8b 45 08             	mov    0x8(%ebp),%eax
c010087f:	8b 40 04             	mov    0x4(%eax),%eax
c0100882:	8b 00                	mov    (%eax),%eax
c0100884:	85 c0                	test   %eax,%eax
c0100886:	75 0c                	jne    c0100894 <rb_insert+0x1ce>
c0100888:	8b 45 08             	mov    0x8(%ebp),%eax
c010088b:	8b 40 08             	mov    0x8(%eax),%eax
c010088e:	8b 00                	mov    (%eax),%eax
c0100890:	85 c0                	test   %eax,%eax
c0100892:	74 19                	je     c01008ad <rb_insert+0x1e7>
c0100894:	68 f8 a9 10 c0       	push   $0xc010a9f8
c0100899:	68 98 a9 10 c0       	push   $0xc010a998
c010089e:	68 a9 00 00 00       	push   $0xa9
c01008a3:	68 ad a9 10 c0       	push   $0xc010a9ad
c01008a8:	e8 bb 0e 00 00       	call   c0101768 <__panic>

#undef RB_INSERT_SUB
}
c01008ad:	90                   	nop
c01008ae:	c9                   	leave  
c01008af:	c3                   	ret    

c01008b0 <rb_tree_successor>:
 * rb_tree_successor - returns the successor of @node, or nil
 * if no successor exists. Make sure that @node must belong to @tree,
 * and this function should only be called by rb_node_prev.
 * */
static inline rb_node *
rb_tree_successor(rb_tree *tree, rb_node *node) {
c01008b0:	55                   	push   %ebp
c01008b1:	89 e5                	mov    %esp,%ebp
c01008b3:	83 ec 10             	sub    $0x10,%esp
    rb_node *x = node, *y, *nil = tree->nil;
c01008b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01008bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01008bf:	8b 40 04             	mov    0x4(%eax),%eax
c01008c2:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if ((y = x->right) != nil) {
c01008c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01008c8:	8b 40 0c             	mov    0xc(%eax),%eax
c01008cb:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01008ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008d1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01008d4:	74 1b                	je     c01008f1 <rb_tree_successor+0x41>
        while (y->left != nil) {
c01008d6:	eb 09                	jmp    c01008e1 <rb_tree_successor+0x31>
            y = y->left;
c01008d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008db:	8b 40 08             	mov    0x8(%eax),%eax
c01008de:	89 45 f8             	mov    %eax,-0x8(%ebp)
static inline rb_node *
rb_tree_successor(rb_tree *tree, rb_node *node) {
    rb_node *x = node, *y, *nil = tree->nil;

    if ((y = x->right) != nil) {
        while (y->left != nil) {
c01008e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008e4:	8b 40 08             	mov    0x8(%eax),%eax
c01008e7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01008ea:	75 ec                	jne    c01008d8 <rb_tree_successor+0x28>
            y = y->left;
        }
        return y;
c01008ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008ef:	eb 38                	jmp    c0100929 <rb_tree_successor+0x79>
    }
    else {
        y = x->parent;
c01008f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01008f4:	8b 40 04             	mov    0x4(%eax),%eax
c01008f7:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (x == y->right) {
c01008fa:	eb 0f                	jmp    c010090b <rb_tree_successor+0x5b>
            x = y, y = y->parent;
c01008fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100902:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100905:	8b 40 04             	mov    0x4(%eax),%eax
c0100908:	89 45 f8             	mov    %eax,-0x8(%ebp)
        }
        return y;
    }
    else {
        y = x->parent;
        while (x == y->right) {
c010090b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010090e:	8b 40 0c             	mov    0xc(%eax),%eax
c0100911:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100914:	74 e6                	je     c01008fc <rb_tree_successor+0x4c>
            x = y, y = y->parent;
        }
        if (y == tree->root) {
c0100916:	8b 45 08             	mov    0x8(%ebp),%eax
c0100919:	8b 40 08             	mov    0x8(%eax),%eax
c010091c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c010091f:	75 05                	jne    c0100926 <rb_tree_successor+0x76>
            return nil;
c0100921:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100924:	eb 03                	jmp    c0100929 <rb_tree_successor+0x79>
        }
        return y;
c0100926:	8b 45 f8             	mov    -0x8(%ebp),%eax
    }
}
c0100929:	c9                   	leave  
c010092a:	c3                   	ret    

c010092b <rb_tree_predecessor>:
/* *
 * rb_tree_predecessor - returns the predecessor of @node, or nil
 * if no predecessor exists, likes rb_tree_successor.
 * */
static inline rb_node *
rb_tree_predecessor(rb_tree *tree, rb_node *node) {
c010092b:	55                   	push   %ebp
c010092c:	89 e5                	mov    %esp,%ebp
c010092e:	83 ec 10             	sub    $0x10,%esp
    rb_node *x = node, *y, *nil = tree->nil;
c0100931:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100934:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100937:	8b 45 08             	mov    0x8(%ebp),%eax
c010093a:	8b 40 04             	mov    0x4(%eax),%eax
c010093d:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if ((y = x->left) != nil) {
c0100940:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100943:	8b 40 08             	mov    0x8(%eax),%eax
c0100946:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100949:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010094c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010094f:	74 1b                	je     c010096c <rb_tree_predecessor+0x41>
        while (y->right != nil) {
c0100951:	eb 09                	jmp    c010095c <rb_tree_predecessor+0x31>
            y = y->right;
c0100953:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100956:	8b 40 0c             	mov    0xc(%eax),%eax
c0100959:	89 45 f8             	mov    %eax,-0x8(%ebp)
static inline rb_node *
rb_tree_predecessor(rb_tree *tree, rb_node *node) {
    rb_node *x = node, *y, *nil = tree->nil;

    if ((y = x->left) != nil) {
        while (y->right != nil) {
c010095c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010095f:	8b 40 0c             	mov    0xc(%eax),%eax
c0100962:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100965:	75 ec                	jne    c0100953 <rb_tree_predecessor+0x28>
            y = y->right;
        }
        return y;
c0100967:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010096a:	eb 38                	jmp    c01009a4 <rb_tree_predecessor+0x79>
    }
    else {
        y = x->parent;
c010096c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010096f:	8b 40 04             	mov    0x4(%eax),%eax
c0100972:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (x == y->left) {
c0100975:	eb 1f                	jmp    c0100996 <rb_tree_predecessor+0x6b>
            if (y == tree->root) {
c0100977:	8b 45 08             	mov    0x8(%ebp),%eax
c010097a:	8b 40 08             	mov    0x8(%eax),%eax
c010097d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0100980:	75 05                	jne    c0100987 <rb_tree_predecessor+0x5c>
                return nil;
c0100982:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100985:	eb 1d                	jmp    c01009a4 <rb_tree_predecessor+0x79>
            }
            x = y, y = y->parent;
c0100987:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010098a:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010098d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100990:	8b 40 04             	mov    0x4(%eax),%eax
c0100993:	89 45 f8             	mov    %eax,-0x8(%ebp)
        }
        return y;
    }
    else {
        y = x->parent;
        while (x == y->left) {
c0100996:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100999:	8b 40 08             	mov    0x8(%eax),%eax
c010099c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010099f:	74 d6                	je     c0100977 <rb_tree_predecessor+0x4c>
            if (y == tree->root) {
                return nil;
            }
            x = y, y = y->parent;
        }
        return y;
c01009a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
    }
}
c01009a4:	c9                   	leave  
c01009a5:	c3                   	ret    

c01009a6 <rb_search>:
 * rb_search - returns a node with value 'equal' to @key (according to
 * function @compare). If there're multiple nodes with value 'equal' to @key,
 * the functions returns the one highest in the tree.
 * */
rb_node *
rb_search(rb_tree *tree, int (*compare)(rb_node *node, void *key), void *key) {
c01009a6:	55                   	push   %ebp
c01009a7:	89 e5                	mov    %esp,%ebp
c01009a9:	83 ec 18             	sub    $0x18,%esp
    rb_node *nil = tree->nil, *node = tree->root->left;
c01009ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01009af:	8b 40 04             	mov    0x4(%eax),%eax
c01009b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01009b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01009b8:	8b 40 08             	mov    0x8(%eax),%eax
c01009bb:	8b 40 08             	mov    0x8(%eax),%eax
c01009be:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int r;
    while (node != nil && (r = compare(node, key)) != 0) {
c01009c1:	eb 17                	jmp    c01009da <rb_search+0x34>
        node = (r > 0) ? node->left : node->right;
c01009c3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01009c7:	7e 08                	jle    c01009d1 <rb_search+0x2b>
c01009c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009cc:	8b 40 08             	mov    0x8(%eax),%eax
c01009cf:	eb 06                	jmp    c01009d7 <rb_search+0x31>
c01009d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009d4:	8b 40 0c             	mov    0xc(%eax),%eax
c01009d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 * */
rb_node *
rb_search(rb_tree *tree, int (*compare)(rb_node *node, void *key), void *key) {
    rb_node *nil = tree->nil, *node = tree->root->left;
    int r;
    while (node != nil && (r = compare(node, key)) != 0) {
c01009da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009dd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01009e0:	74 1a                	je     c01009fc <rb_search+0x56>
c01009e2:	83 ec 08             	sub    $0x8,%esp
c01009e5:	ff 75 10             	pushl  0x10(%ebp)
c01009e8:	ff 75 f4             	pushl  -0xc(%ebp)
c01009eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01009ee:	ff d0                	call   *%eax
c01009f0:	83 c4 10             	add    $0x10,%esp
c01009f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01009f6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01009fa:	75 c7                	jne    c01009c3 <rb_search+0x1d>
        node = (r > 0) ? node->left : node->right;
    }
    return (node != nil) ? node : NULL;
c01009fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009ff:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100a02:	74 05                	je     c0100a09 <rb_search+0x63>
c0100a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a07:	eb 05                	jmp    c0100a0e <rb_search+0x68>
c0100a09:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100a0e:	c9                   	leave  
c0100a0f:	c3                   	ret    

c0100a10 <rb_delete_fixup>:
/* *
 * rb_delete_fixup - performs rotations and changes colors to restore
 * red-black properties after a node is deleted.
 * */
static void
rb_delete_fixup(rb_tree *tree, rb_node *node) {
c0100a10:	55                   	push   %ebp
c0100a11:	89 e5                	mov    %esp,%ebp
c0100a13:	83 ec 18             	sub    $0x18,%esp
    rb_node *x = node, *w, *root = tree->root->left;
c0100a16:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a19:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100a1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a1f:	8b 40 08             	mov    0x8(%eax),%eax
c0100a22:	8b 40 08             	mov    0x8(%eax),%eax
c0100a25:	89 45 ec             	mov    %eax,-0x14(%ebp)
            rb_##_left##_rotate(tree, x->parent);               \
            x = root;                                           \
        }                                                       \
    } while (0)

    while (x != root && !x->red) {
c0100a28:	e9 04 02 00 00       	jmp    c0100c31 <rb_delete_fixup+0x221>
        if (x == x->parent->left) {
c0100a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a30:	8b 40 04             	mov    0x4(%eax),%eax
c0100a33:	8b 40 08             	mov    0x8(%eax),%eax
c0100a36:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a39:	0f 85 fd 00 00 00    	jne    c0100b3c <rb_delete_fixup+0x12c>
            RB_DELETE_FIXUP_SUB(left, right);
c0100a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a42:	8b 40 04             	mov    0x4(%eax),%eax
c0100a45:	8b 40 0c             	mov    0xc(%eax),%eax
c0100a48:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a4e:	8b 00                	mov    (%eax),%eax
c0100a50:	85 c0                	test   %eax,%eax
c0100a52:	74 36                	je     c0100a8a <rb_delete_fixup+0x7a>
c0100a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a57:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a60:	8b 40 04             	mov    0x4(%eax),%eax
c0100a63:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a6c:	8b 40 04             	mov    0x4(%eax),%eax
c0100a6f:	83 ec 08             	sub    $0x8,%esp
c0100a72:	50                   	push   %eax
c0100a73:	ff 75 08             	pushl  0x8(%ebp)
c0100a76:	e8 ea f9 ff ff       	call   c0100465 <rb_left_rotate>
c0100a7b:	83 c4 10             	add    $0x10,%esp
c0100a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a81:	8b 40 04             	mov    0x4(%eax),%eax
c0100a84:	8b 40 0c             	mov    0xc(%eax),%eax
c0100a87:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a8d:	8b 40 08             	mov    0x8(%eax),%eax
c0100a90:	8b 00                	mov    (%eax),%eax
c0100a92:	85 c0                	test   %eax,%eax
c0100a94:	75 23                	jne    c0100ab9 <rb_delete_fixup+0xa9>
c0100a96:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a99:	8b 40 0c             	mov    0xc(%eax),%eax
c0100a9c:	8b 00                	mov    (%eax),%eax
c0100a9e:	85 c0                	test   %eax,%eax
c0100aa0:	75 17                	jne    c0100ab9 <rb_delete_fixup+0xa9>
c0100aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100aa5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aae:	8b 40 04             	mov    0x4(%eax),%eax
c0100ab1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100ab4:	e9 78 01 00 00       	jmp    c0100c31 <rb_delete_fixup+0x221>
c0100ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100abc:	8b 40 0c             	mov    0xc(%eax),%eax
c0100abf:	8b 00                	mov    (%eax),%eax
c0100ac1:	85 c0                	test   %eax,%eax
c0100ac3:	75 32                	jne    c0100af7 <rb_delete_fixup+0xe7>
c0100ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ac8:	8b 40 08             	mov    0x8(%eax),%eax
c0100acb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ad4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100ada:	83 ec 08             	sub    $0x8,%esp
c0100add:	ff 75 f0             	pushl  -0x10(%ebp)
c0100ae0:	ff 75 08             	pushl  0x8(%ebp)
c0100ae3:	e8 51 fa ff ff       	call   c0100539 <rb_right_rotate>
c0100ae8:	83 c4 10             	add    $0x10,%esp
c0100aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aee:	8b 40 04             	mov    0x4(%eax),%eax
c0100af1:	8b 40 0c             	mov    0xc(%eax),%eax
c0100af4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100afa:	8b 40 04             	mov    0x4(%eax),%eax
c0100afd:	8b 10                	mov    (%eax),%edx
c0100aff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b02:	89 10                	mov    %edx,(%eax)
c0100b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b07:	8b 40 04             	mov    0x4(%eax),%eax
c0100b0a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b13:	8b 40 0c             	mov    0xc(%eax),%eax
c0100b16:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b1f:	8b 40 04             	mov    0x4(%eax),%eax
c0100b22:	83 ec 08             	sub    $0x8,%esp
c0100b25:	50                   	push   %eax
c0100b26:	ff 75 08             	pushl  0x8(%ebp)
c0100b29:	e8 37 f9 ff ff       	call   c0100465 <rb_left_rotate>
c0100b2e:	83 c4 10             	add    $0x10,%esp
c0100b31:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100b34:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100b37:	e9 f5 00 00 00       	jmp    c0100c31 <rb_delete_fixup+0x221>
        }
        else {
            RB_DELETE_FIXUP_SUB(right, left);
c0100b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b3f:	8b 40 04             	mov    0x4(%eax),%eax
c0100b42:	8b 40 08             	mov    0x8(%eax),%eax
c0100b45:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100b48:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b4b:	8b 00                	mov    (%eax),%eax
c0100b4d:	85 c0                	test   %eax,%eax
c0100b4f:	74 36                	je     c0100b87 <rb_delete_fixup+0x177>
c0100b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b54:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b5d:	8b 40 04             	mov    0x4(%eax),%eax
c0100b60:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b69:	8b 40 04             	mov    0x4(%eax),%eax
c0100b6c:	83 ec 08             	sub    $0x8,%esp
c0100b6f:	50                   	push   %eax
c0100b70:	ff 75 08             	pushl  0x8(%ebp)
c0100b73:	e8 c1 f9 ff ff       	call   c0100539 <rb_right_rotate>
c0100b78:	83 c4 10             	add    $0x10,%esp
c0100b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b7e:	8b 40 04             	mov    0x4(%eax),%eax
c0100b81:	8b 40 08             	mov    0x8(%eax),%eax
c0100b84:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b8a:	8b 40 0c             	mov    0xc(%eax),%eax
c0100b8d:	8b 00                	mov    (%eax),%eax
c0100b8f:	85 c0                	test   %eax,%eax
c0100b91:	75 20                	jne    c0100bb3 <rb_delete_fixup+0x1a3>
c0100b93:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b96:	8b 40 08             	mov    0x8(%eax),%eax
c0100b99:	8b 00                	mov    (%eax),%eax
c0100b9b:	85 c0                	test   %eax,%eax
c0100b9d:	75 14                	jne    c0100bb3 <rb_delete_fixup+0x1a3>
c0100b9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ba2:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bab:	8b 40 04             	mov    0x4(%eax),%eax
c0100bae:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100bb1:	eb 7e                	jmp    c0100c31 <rb_delete_fixup+0x221>
c0100bb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100bb6:	8b 40 08             	mov    0x8(%eax),%eax
c0100bb9:	8b 00                	mov    (%eax),%eax
c0100bbb:	85 c0                	test   %eax,%eax
c0100bbd:	75 32                	jne    c0100bf1 <rb_delete_fixup+0x1e1>
c0100bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100bc2:	8b 40 0c             	mov    0xc(%eax),%eax
c0100bc5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100bce:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100bd4:	83 ec 08             	sub    $0x8,%esp
c0100bd7:	ff 75 f0             	pushl  -0x10(%ebp)
c0100bda:	ff 75 08             	pushl  0x8(%ebp)
c0100bdd:	e8 83 f8 ff ff       	call   c0100465 <rb_left_rotate>
c0100be2:	83 c4 10             	add    $0x10,%esp
c0100be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100be8:	8b 40 04             	mov    0x4(%eax),%eax
c0100beb:	8b 40 08             	mov    0x8(%eax),%eax
c0100bee:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bf4:	8b 40 04             	mov    0x4(%eax),%eax
c0100bf7:	8b 10                	mov    (%eax),%edx
c0100bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100bfc:	89 10                	mov    %edx,(%eax)
c0100bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c01:	8b 40 04             	mov    0x4(%eax),%eax
c0100c04:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100c0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c0d:	8b 40 08             	mov    0x8(%eax),%eax
c0100c10:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c19:	8b 40 04             	mov    0x4(%eax),%eax
c0100c1c:	83 ec 08             	sub    $0x8,%esp
c0100c1f:	50                   	push   %eax
c0100c20:	ff 75 08             	pushl  0x8(%ebp)
c0100c23:	e8 11 f9 ff ff       	call   c0100539 <rb_right_rotate>
c0100c28:	83 c4 10             	add    $0x10,%esp
c0100c2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100c2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
            rb_##_left##_rotate(tree, x->parent);               \
            x = root;                                           \
        }                                                       \
    } while (0)

    while (x != root && !x->red) {
c0100c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c34:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100c37:	74 0d                	je     c0100c46 <rb_delete_fixup+0x236>
c0100c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c3c:	8b 00                	mov    (%eax),%eax
c0100c3e:	85 c0                	test   %eax,%eax
c0100c40:	0f 84 e7 fd ff ff    	je     c0100a2d <rb_delete_fixup+0x1d>
        }
        else {
            RB_DELETE_FIXUP_SUB(right, left);
        }
    }
    x->red = 0;
c0100c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c49:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

#undef RB_DELETE_FIXUP_SUB
}
c0100c4f:	90                   	nop
c0100c50:	c9                   	leave  
c0100c51:	c3                   	ret    

c0100c52 <rb_delete>:
/* *
 * rb_delete - deletes @node from @tree, and calls rb_delete_fixup to
 * restore red-black properties.
 * */
void
rb_delete(rb_tree *tree, rb_node *node) {
c0100c52:	55                   	push   %ebp
c0100c53:	89 e5                	mov    %esp,%ebp
c0100c55:	83 ec 28             	sub    $0x28,%esp
    rb_node *x, *y, *z = node;
c0100c58:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100c5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    rb_node *nil = tree->nil, *root = tree->root;
c0100c5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c61:	8b 40 04             	mov    0x4(%eax),%eax
c0100c64:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100c67:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c6a:	8b 40 08             	mov    0x8(%eax),%eax
c0100c6d:	89 45 ec             	mov    %eax,-0x14(%ebp)

    y = (z->left == nil || z->right == nil) ? z : rb_tree_successor(tree, z);
c0100c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c73:	8b 40 08             	mov    0x8(%eax),%eax
c0100c76:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100c79:	74 1b                	je     c0100c96 <rb_delete+0x44>
c0100c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c7e:	8b 40 0c             	mov    0xc(%eax),%eax
c0100c81:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100c84:	74 10                	je     c0100c96 <rb_delete+0x44>
c0100c86:	ff 75 f4             	pushl  -0xc(%ebp)
c0100c89:	ff 75 08             	pushl  0x8(%ebp)
c0100c8c:	e8 1f fc ff ff       	call   c01008b0 <rb_tree_successor>
c0100c91:	83 c4 08             	add    $0x8,%esp
c0100c94:	eb 03                	jmp    c0100c99 <rb_delete+0x47>
c0100c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c99:	89 45 e8             	mov    %eax,-0x18(%ebp)
    x = (y->left != nil) ? y->left : y->right;
c0100c9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c9f:	8b 40 08             	mov    0x8(%eax),%eax
c0100ca2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100ca5:	74 08                	je     c0100caf <rb_delete+0x5d>
c0100ca7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100caa:	8b 40 08             	mov    0x8(%eax),%eax
c0100cad:	eb 06                	jmp    c0100cb5 <rb_delete+0x63>
c0100caf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100cb2:	8b 40 0c             	mov    0xc(%eax),%eax
c0100cb5:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    assert(y != root && y != nil);
c0100cb8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100cbb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100cbe:	74 08                	je     c0100cc8 <rb_delete+0x76>
c0100cc0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100cc3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100cc6:	75 19                	jne    c0100ce1 <rb_delete+0x8f>
c0100cc8:	68 20 aa 10 c0       	push   $0xc010aa20
c0100ccd:	68 98 a9 10 c0       	push   $0xc010a998
c0100cd2:	68 2f 01 00 00       	push   $0x12f
c0100cd7:	68 ad a9 10 c0       	push   $0xc010a9ad
c0100cdc:	e8 87 0a 00 00       	call   c0101768 <__panic>

    x->parent = y->parent;
c0100ce1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100ce4:	8b 50 04             	mov    0x4(%eax),%edx
c0100ce7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100cea:	89 50 04             	mov    %edx,0x4(%eax)
    if (y == y->parent->left) {
c0100ced:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100cf0:	8b 40 04             	mov    0x4(%eax),%eax
c0100cf3:	8b 40 08             	mov    0x8(%eax),%eax
c0100cf6:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0100cf9:	75 0e                	jne    c0100d09 <rb_delete+0xb7>
        y->parent->left = x;
c0100cfb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100cfe:	8b 40 04             	mov    0x4(%eax),%eax
c0100d01:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100d04:	89 50 08             	mov    %edx,0x8(%eax)
c0100d07:	eb 0c                	jmp    c0100d15 <rb_delete+0xc3>
    }
    else {
        y->parent->right = x;
c0100d09:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100d0c:	8b 40 04             	mov    0x4(%eax),%eax
c0100d0f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100d12:	89 50 0c             	mov    %edx,0xc(%eax)
    }

    bool need_fixup = !(y->red);
c0100d15:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100d18:	8b 00                	mov    (%eax),%eax
c0100d1a:	85 c0                	test   %eax,%eax
c0100d1c:	0f 94 c0             	sete   %al
c0100d1f:	0f b6 c0             	movzbl %al,%eax
c0100d22:	89 45 e0             	mov    %eax,-0x20(%ebp)

    if (y != z) {
c0100d25:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100d28:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100d2b:	74 5c                	je     c0100d89 <rb_delete+0x137>
        if (z == z->parent->left) {
c0100d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d30:	8b 40 04             	mov    0x4(%eax),%eax
c0100d33:	8b 40 08             	mov    0x8(%eax),%eax
c0100d36:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100d39:	75 0e                	jne    c0100d49 <rb_delete+0xf7>
            z->parent->left = y;
c0100d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d3e:	8b 40 04             	mov    0x4(%eax),%eax
c0100d41:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100d44:	89 50 08             	mov    %edx,0x8(%eax)
c0100d47:	eb 0c                	jmp    c0100d55 <rb_delete+0x103>
        }
        else {
            z->parent->right = y;
c0100d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d4c:	8b 40 04             	mov    0x4(%eax),%eax
c0100d4f:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100d52:	89 50 0c             	mov    %edx,0xc(%eax)
        }
        z->left->parent = z->right->parent = y;
c0100d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d58:	8b 50 08             	mov    0x8(%eax),%edx
c0100d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d5e:	8b 40 0c             	mov    0xc(%eax),%eax
c0100d61:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100d64:	89 48 04             	mov    %ecx,0x4(%eax)
c0100d67:	8b 40 04             	mov    0x4(%eax),%eax
c0100d6a:	89 42 04             	mov    %eax,0x4(%edx)
        *y = *z;
c0100d6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100d70:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d73:	8b 0a                	mov    (%edx),%ecx
c0100d75:	89 08                	mov    %ecx,(%eax)
c0100d77:	8b 4a 04             	mov    0x4(%edx),%ecx
c0100d7a:	89 48 04             	mov    %ecx,0x4(%eax)
c0100d7d:	8b 4a 08             	mov    0x8(%edx),%ecx
c0100d80:	89 48 08             	mov    %ecx,0x8(%eax)
c0100d83:	8b 52 0c             	mov    0xc(%edx),%edx
c0100d86:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    if (need_fixup) {
c0100d89:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0100d8d:	74 11                	je     c0100da0 <rb_delete+0x14e>
        rb_delete_fixup(tree, x);
c0100d8f:	83 ec 08             	sub    $0x8,%esp
c0100d92:	ff 75 e4             	pushl  -0x1c(%ebp)
c0100d95:	ff 75 08             	pushl  0x8(%ebp)
c0100d98:	e8 73 fc ff ff       	call   c0100a10 <rb_delete_fixup>
c0100d9d:	83 c4 10             	add    $0x10,%esp
    }
}
c0100da0:	90                   	nop
c0100da1:	c9                   	leave  
c0100da2:	c3                   	ret    

c0100da3 <rb_tree_destroy>:

/* rb_tree_destroy - destroy a tree and free memory */
void
rb_tree_destroy(rb_tree *tree) {
c0100da3:	55                   	push   %ebp
c0100da4:	89 e5                	mov    %esp,%ebp
c0100da6:	83 ec 08             	sub    $0x8,%esp
    kfree(tree->root);
c0100da9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100dac:	8b 40 08             	mov    0x8(%eax),%eax
c0100daf:	83 ec 0c             	sub    $0xc,%esp
c0100db2:	50                   	push   %eax
c0100db3:	e8 6e 54 00 00       	call   c0106226 <kfree>
c0100db8:	83 c4 10             	add    $0x10,%esp
    kfree(tree->nil);
c0100dbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0100dbe:	8b 40 04             	mov    0x4(%eax),%eax
c0100dc1:	83 ec 0c             	sub    $0xc,%esp
c0100dc4:	50                   	push   %eax
c0100dc5:	e8 5c 54 00 00       	call   c0106226 <kfree>
c0100dca:	83 c4 10             	add    $0x10,%esp
    kfree(tree);
c0100dcd:	83 ec 0c             	sub    $0xc,%esp
c0100dd0:	ff 75 08             	pushl  0x8(%ebp)
c0100dd3:	e8 4e 54 00 00       	call   c0106226 <kfree>
c0100dd8:	83 c4 10             	add    $0x10,%esp
}
c0100ddb:	90                   	nop
c0100ddc:	c9                   	leave  
c0100ddd:	c3                   	ret    

c0100dde <rb_node_prev>:
/* *
 * rb_node_prev - returns the predecessor node of @node in @tree,
 * or 'NULL' if no predecessor exists.
 * */
rb_node *
rb_node_prev(rb_tree *tree, rb_node *node) {
c0100dde:	55                   	push   %ebp
c0100ddf:	89 e5                	mov    %esp,%ebp
c0100de1:	83 ec 10             	sub    $0x10,%esp
    rb_node *prev = rb_tree_predecessor(tree, node);
c0100de4:	ff 75 0c             	pushl  0xc(%ebp)
c0100de7:	ff 75 08             	pushl  0x8(%ebp)
c0100dea:	e8 3c fb ff ff       	call   c010092b <rb_tree_predecessor>
c0100def:	83 c4 08             	add    $0x8,%esp
c0100df2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (prev != tree->nil) ? prev : NULL;
c0100df5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100df8:	8b 40 04             	mov    0x4(%eax),%eax
c0100dfb:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100dfe:	74 05                	je     c0100e05 <rb_node_prev+0x27>
c0100e00:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e03:	eb 05                	jmp    c0100e0a <rb_node_prev+0x2c>
c0100e05:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e0a:	c9                   	leave  
c0100e0b:	c3                   	ret    

c0100e0c <rb_node_next>:
/* *
 * rb_node_next - returns the successor node of @node in @tree,
 * or 'NULL' if no successor exists.
 * */
rb_node *
rb_node_next(rb_tree *tree, rb_node *node) {
c0100e0c:	55                   	push   %ebp
c0100e0d:	89 e5                	mov    %esp,%ebp
c0100e0f:	83 ec 10             	sub    $0x10,%esp
    rb_node *next = rb_tree_successor(tree, node);
c0100e12:	ff 75 0c             	pushl  0xc(%ebp)
c0100e15:	ff 75 08             	pushl  0x8(%ebp)
c0100e18:	e8 93 fa ff ff       	call   c01008b0 <rb_tree_successor>
c0100e1d:	83 c4 08             	add    $0x8,%esp
c0100e20:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (next != tree->nil) ? next : NULL;
c0100e23:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e26:	8b 40 04             	mov    0x4(%eax),%eax
c0100e29:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100e2c:	74 05                	je     c0100e33 <rb_node_next+0x27>
c0100e2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e31:	eb 05                	jmp    c0100e38 <rb_node_next+0x2c>
c0100e33:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e38:	c9                   	leave  
c0100e39:	c3                   	ret    

c0100e3a <rb_node_root>:

/* rb_node_root - returns the root node of a @tree, or 'NULL' if tree is empty */
rb_node *
rb_node_root(rb_tree *tree) {
c0100e3a:	55                   	push   %ebp
c0100e3b:	89 e5                	mov    %esp,%ebp
c0100e3d:	83 ec 10             	sub    $0x10,%esp
    rb_node *node = tree->root->left;
c0100e40:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e43:	8b 40 08             	mov    0x8(%eax),%eax
c0100e46:	8b 40 08             	mov    0x8(%eax),%eax
c0100e49:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (node != tree->nil) ? node : NULL;
c0100e4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e4f:	8b 40 04             	mov    0x4(%eax),%eax
c0100e52:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100e55:	74 05                	je     c0100e5c <rb_node_root+0x22>
c0100e57:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e5a:	eb 05                	jmp    c0100e61 <rb_node_root+0x27>
c0100e5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e61:	c9                   	leave  
c0100e62:	c3                   	ret    

c0100e63 <rb_node_left>:

/* rb_node_left - gets the left child of @node, or 'NULL' if no such node */
rb_node *
rb_node_left(rb_tree *tree, rb_node *node) {
c0100e63:	55                   	push   %ebp
c0100e64:	89 e5                	mov    %esp,%ebp
c0100e66:	83 ec 10             	sub    $0x10,%esp
    rb_node *left = node->left;
c0100e69:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e6c:	8b 40 08             	mov    0x8(%eax),%eax
c0100e6f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (left != tree->nil) ? left : NULL;
c0100e72:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e75:	8b 40 04             	mov    0x4(%eax),%eax
c0100e78:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100e7b:	74 05                	je     c0100e82 <rb_node_left+0x1f>
c0100e7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e80:	eb 05                	jmp    c0100e87 <rb_node_left+0x24>
c0100e82:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e87:	c9                   	leave  
c0100e88:	c3                   	ret    

c0100e89 <rb_node_right>:

/* rb_node_right - gets the right child of @node, or 'NULL' if no such node */
rb_node *
rb_node_right(rb_tree *tree, rb_node *node) {
c0100e89:	55                   	push   %ebp
c0100e8a:	89 e5                	mov    %esp,%ebp
c0100e8c:	83 ec 10             	sub    $0x10,%esp
    rb_node *right = node->right;
c0100e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e92:	8b 40 0c             	mov    0xc(%eax),%eax
c0100e95:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (right != tree->nil) ? right : NULL;
c0100e98:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e9b:	8b 40 04             	mov    0x4(%eax),%eax
c0100e9e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100ea1:	74 05                	je     c0100ea8 <rb_node_right+0x1f>
c0100ea3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea6:	eb 05                	jmp    c0100ead <rb_node_right+0x24>
c0100ea8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ead:	c9                   	leave  
c0100eae:	c3                   	ret    

c0100eaf <check_tree>:

int
check_tree(rb_tree *tree, rb_node *node) {
c0100eaf:	55                   	push   %ebp
c0100eb0:	89 e5                	mov    %esp,%ebp
c0100eb2:	83 ec 18             	sub    $0x18,%esp
    rb_node *nil = tree->nil;
c0100eb5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100eb8:	8b 40 04             	mov    0x4(%eax),%eax
c0100ebb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (node == nil) {
c0100ebe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ec1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100ec4:	75 2c                	jne    c0100ef2 <check_tree+0x43>
        assert(!node->red);
c0100ec6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ec9:	8b 00                	mov    (%eax),%eax
c0100ecb:	85 c0                	test   %eax,%eax
c0100ecd:	74 19                	je     c0100ee8 <check_tree+0x39>
c0100ecf:	68 36 aa 10 c0       	push   $0xc010aa36
c0100ed4:	68 98 a9 10 c0       	push   $0xc010a998
c0100ed9:	68 7f 01 00 00       	push   $0x17f
c0100ede:	68 ad a9 10 c0       	push   $0xc010a9ad
c0100ee3:	e8 80 08 00 00       	call   c0101768 <__panic>
        return 1;
c0100ee8:	b8 01 00 00 00       	mov    $0x1,%eax
c0100eed:	e9 6d 01 00 00       	jmp    c010105f <check_tree+0x1b0>
    }
    if (node->left != nil) {
c0100ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ef5:	8b 40 08             	mov    0x8(%eax),%eax
c0100ef8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100efb:	74 5b                	je     c0100f58 <check_tree+0xa9>
        assert(COMPARE(tree, node, node->left) >= 0);
c0100efd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100f00:	8b 00                	mov    (%eax),%eax
c0100f02:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100f05:	8b 52 08             	mov    0x8(%edx),%edx
c0100f08:	83 ec 08             	sub    $0x8,%esp
c0100f0b:	52                   	push   %edx
c0100f0c:	ff 75 0c             	pushl  0xc(%ebp)
c0100f0f:	ff d0                	call   *%eax
c0100f11:	83 c4 10             	add    $0x10,%esp
c0100f14:	85 c0                	test   %eax,%eax
c0100f16:	79 19                	jns    c0100f31 <check_tree+0x82>
c0100f18:	68 44 aa 10 c0       	push   $0xc010aa44
c0100f1d:	68 98 a9 10 c0       	push   $0xc010a998
c0100f22:	68 83 01 00 00       	push   $0x183
c0100f27:	68 ad a9 10 c0       	push   $0xc010a9ad
c0100f2c:	e8 37 08 00 00       	call   c0101768 <__panic>
        assert(node->left->parent == node);
c0100f31:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100f34:	8b 40 08             	mov    0x8(%eax),%eax
c0100f37:	8b 40 04             	mov    0x4(%eax),%eax
c0100f3a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0100f3d:	74 19                	je     c0100f58 <check_tree+0xa9>
c0100f3f:	68 69 aa 10 c0       	push   $0xc010aa69
c0100f44:	68 98 a9 10 c0       	push   $0xc010a998
c0100f49:	68 84 01 00 00       	push   $0x184
c0100f4e:	68 ad a9 10 c0       	push   $0xc010a9ad
c0100f53:	e8 10 08 00 00       	call   c0101768 <__panic>
    }
    if (node->right != nil) {
c0100f58:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100f5b:	8b 40 0c             	mov    0xc(%eax),%eax
c0100f5e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100f61:	74 5b                	je     c0100fbe <check_tree+0x10f>
        assert(COMPARE(tree, node, node->right) <= 0);
c0100f63:	8b 45 08             	mov    0x8(%ebp),%eax
c0100f66:	8b 00                	mov    (%eax),%eax
c0100f68:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100f6b:	8b 52 0c             	mov    0xc(%edx),%edx
c0100f6e:	83 ec 08             	sub    $0x8,%esp
c0100f71:	52                   	push   %edx
c0100f72:	ff 75 0c             	pushl  0xc(%ebp)
c0100f75:	ff d0                	call   *%eax
c0100f77:	83 c4 10             	add    $0x10,%esp
c0100f7a:	85 c0                	test   %eax,%eax
c0100f7c:	7e 19                	jle    c0100f97 <check_tree+0xe8>
c0100f7e:	68 84 aa 10 c0       	push   $0xc010aa84
c0100f83:	68 98 a9 10 c0       	push   $0xc010a998
c0100f88:	68 87 01 00 00       	push   $0x187
c0100f8d:	68 ad a9 10 c0       	push   $0xc010a9ad
c0100f92:	e8 d1 07 00 00       	call   c0101768 <__panic>
        assert(node->right->parent == node);
c0100f97:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100f9a:	8b 40 0c             	mov    0xc(%eax),%eax
c0100f9d:	8b 40 04             	mov    0x4(%eax),%eax
c0100fa0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0100fa3:	74 19                	je     c0100fbe <check_tree+0x10f>
c0100fa5:	68 aa aa 10 c0       	push   $0xc010aaaa
c0100faa:	68 98 a9 10 c0       	push   $0xc010a998
c0100faf:	68 88 01 00 00       	push   $0x188
c0100fb4:	68 ad a9 10 c0       	push   $0xc010a9ad
c0100fb9:	e8 aa 07 00 00       	call   c0101768 <__panic>
    }
    if (node->red) {
c0100fbe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100fc1:	8b 00                	mov    (%eax),%eax
c0100fc3:	85 c0                	test   %eax,%eax
c0100fc5:	74 31                	je     c0100ff8 <check_tree+0x149>
        assert(!node->left->red && !node->right->red);
c0100fc7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100fca:	8b 40 08             	mov    0x8(%eax),%eax
c0100fcd:	8b 00                	mov    (%eax),%eax
c0100fcf:	85 c0                	test   %eax,%eax
c0100fd1:	75 0c                	jne    c0100fdf <check_tree+0x130>
c0100fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100fd6:	8b 40 0c             	mov    0xc(%eax),%eax
c0100fd9:	8b 00                	mov    (%eax),%eax
c0100fdb:	85 c0                	test   %eax,%eax
c0100fdd:	74 19                	je     c0100ff8 <check_tree+0x149>
c0100fdf:	68 c8 aa 10 c0       	push   $0xc010aac8
c0100fe4:	68 98 a9 10 c0       	push   $0xc010a998
c0100fe9:	68 8b 01 00 00       	push   $0x18b
c0100fee:	68 ad a9 10 c0       	push   $0xc010a9ad
c0100ff3:	e8 70 07 00 00       	call   c0101768 <__panic>
    }
    int hb_left = check_tree(tree, node->left);
c0100ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ffb:	8b 40 08             	mov    0x8(%eax),%eax
c0100ffe:	83 ec 08             	sub    $0x8,%esp
c0101001:	50                   	push   %eax
c0101002:	ff 75 08             	pushl  0x8(%ebp)
c0101005:	e8 a5 fe ff ff       	call   c0100eaf <check_tree>
c010100a:	83 c4 10             	add    $0x10,%esp
c010100d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    int hb_right = check_tree(tree, node->right);
c0101010:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101013:	8b 40 0c             	mov    0xc(%eax),%eax
c0101016:	83 ec 08             	sub    $0x8,%esp
c0101019:	50                   	push   %eax
c010101a:	ff 75 08             	pushl  0x8(%ebp)
c010101d:	e8 8d fe ff ff       	call   c0100eaf <check_tree>
c0101022:	83 c4 10             	add    $0x10,%esp
c0101025:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(hb_left == hb_right);
c0101028:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010102b:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c010102e:	74 19                	je     c0101049 <check_tree+0x19a>
c0101030:	68 ee aa 10 c0       	push   $0xc010aaee
c0101035:	68 98 a9 10 c0       	push   $0xc010a998
c010103a:	68 8f 01 00 00       	push   $0x18f
c010103f:	68 ad a9 10 c0       	push   $0xc010a9ad
c0101044:	e8 1f 07 00 00       	call   c0101768 <__panic>
    int hb = hb_left;
c0101049:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010104c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!node->red) {
c010104f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101052:	8b 00                	mov    (%eax),%eax
c0101054:	85 c0                	test   %eax,%eax
c0101056:	75 04                	jne    c010105c <check_tree+0x1ad>
        hb ++;
c0101058:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    return hb;
c010105c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010105f:	c9                   	leave  
c0101060:	c3                   	ret    

c0101061 <check_safe_kmalloc>:

static void *
check_safe_kmalloc(size_t size) {
c0101061:	55                   	push   %ebp
c0101062:	89 e5                	mov    %esp,%ebp
c0101064:	83 ec 18             	sub    $0x18,%esp
    void *ret = kmalloc(size);
c0101067:	83 ec 0c             	sub    $0xc,%esp
c010106a:	ff 75 08             	pushl  0x8(%ebp)
c010106d:	e8 9c 51 00 00       	call   c010620e <kmalloc>
c0101072:	83 c4 10             	add    $0x10,%esp
c0101075:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(ret != NULL);
c0101078:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010107c:	75 19                	jne    c0101097 <check_safe_kmalloc+0x36>
c010107e:	68 02 ab 10 c0       	push   $0xc010ab02
c0101083:	68 98 a9 10 c0       	push   $0xc010a998
c0101088:	68 9a 01 00 00       	push   $0x19a
c010108d:	68 ad a9 10 c0       	push   $0xc010a9ad
c0101092:	e8 d1 06 00 00       	call   c0101768 <__panic>
    return ret;
c0101097:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010109a:	c9                   	leave  
c010109b:	c3                   	ret    

c010109c <check_compare1>:

#define rbn2data(node)              \
    (to_struct(node, struct check_data, rb_link))

static inline int
check_compare1(rb_node *node1, rb_node *node2) {
c010109c:	55                   	push   %ebp
c010109d:	89 e5                	mov    %esp,%ebp
    return rbn2data(node1)->data - rbn2data(node2)->data;
c010109f:	8b 45 08             	mov    0x8(%ebp),%eax
c01010a2:	83 e8 04             	sub    $0x4,%eax
c01010a5:	8b 10                	mov    (%eax),%edx
c01010a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01010aa:	83 e8 04             	sub    $0x4,%eax
c01010ad:	8b 00                	mov    (%eax),%eax
c01010af:	29 c2                	sub    %eax,%edx
c01010b1:	89 d0                	mov    %edx,%eax
}
c01010b3:	5d                   	pop    %ebp
c01010b4:	c3                   	ret    

c01010b5 <check_compare2>:

static inline int
check_compare2(rb_node *node, void *key) {
c01010b5:	55                   	push   %ebp
c01010b6:	89 e5                	mov    %esp,%ebp
    return rbn2data(node)->data - (long)key;
c01010b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01010bb:	83 e8 04             	sub    $0x4,%eax
c01010be:	8b 10                	mov    (%eax),%edx
c01010c0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01010c3:	29 c2                	sub    %eax,%edx
c01010c5:	89 d0                	mov    %edx,%eax
}
c01010c7:	5d                   	pop    %ebp
c01010c8:	c3                   	ret    

c01010c9 <check_rb_tree>:

void
check_rb_tree(void) {
c01010c9:	55                   	push   %ebp
c01010ca:	89 e5                	mov    %esp,%ebp
c01010cc:	53                   	push   %ebx
c01010cd:	83 ec 34             	sub    $0x34,%esp
    rb_tree *tree = rb_tree_create(check_compare1);
c01010d0:	83 ec 0c             	sub    $0xc,%esp
c01010d3:	68 9c 10 10 c0       	push   $0xc010109c
c01010d8:	e8 8f f2 ff ff       	call   c010036c <rb_tree_create>
c01010dd:	83 c4 10             	add    $0x10,%esp
c01010e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(tree != NULL);
c01010e3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01010e7:	75 19                	jne    c0101102 <check_rb_tree+0x39>
c01010e9:	68 0e ab 10 c0       	push   $0xc010ab0e
c01010ee:	68 98 a9 10 c0       	push   $0xc010a998
c01010f3:	68 b3 01 00 00       	push   $0x1b3
c01010f8:	68 ad a9 10 c0       	push   $0xc010a9ad
c01010fd:	e8 66 06 00 00       	call   c0101768 <__panic>

    rb_node *nil = tree->nil, *root = tree->root;
c0101102:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101105:	8b 40 04             	mov    0x4(%eax),%eax
c0101108:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010110b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010110e:	8b 40 08             	mov    0x8(%eax),%eax
c0101111:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(!nil->red && root->left == nil);
c0101114:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101117:	8b 00                	mov    (%eax),%eax
c0101119:	85 c0                	test   %eax,%eax
c010111b:	75 0b                	jne    c0101128 <check_rb_tree+0x5f>
c010111d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101120:	8b 40 08             	mov    0x8(%eax),%eax
c0101123:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0101126:	74 19                	je     c0101141 <check_rb_tree+0x78>
c0101128:	68 1c ab 10 c0       	push   $0xc010ab1c
c010112d:	68 98 a9 10 c0       	push   $0xc010a998
c0101132:	68 b6 01 00 00       	push   $0x1b6
c0101137:	68 ad a9 10 c0       	push   $0xc010a9ad
c010113c:	e8 27 06 00 00       	call   c0101768 <__panic>

    int total = 1000;
c0101141:	c7 45 e0 e8 03 00 00 	movl   $0x3e8,-0x20(%ebp)
    struct check_data **all = check_safe_kmalloc(sizeof(struct check_data *) * total);
c0101148:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010114b:	c1 e0 02             	shl    $0x2,%eax
c010114e:	83 ec 0c             	sub    $0xc,%esp
c0101151:	50                   	push   %eax
c0101152:	e8 0a ff ff ff       	call   c0101061 <check_safe_kmalloc>
c0101157:	83 c4 10             	add    $0x10,%esp
c010115a:	89 45 dc             	mov    %eax,-0x24(%ebp)

    long i;
    for (i = 0; i < total; i ++) {
c010115d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101164:	eb 39                	jmp    c010119f <check_rb_tree+0xd6>
        all[i] = check_safe_kmalloc(sizeof(struct check_data));
c0101166:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101169:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101170:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101173:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
c0101176:	83 ec 0c             	sub    $0xc,%esp
c0101179:	6a 14                	push   $0x14
c010117b:	e8 e1 fe ff ff       	call   c0101061 <check_safe_kmalloc>
c0101180:	83 c4 10             	add    $0x10,%esp
c0101183:	89 03                	mov    %eax,(%ebx)
        all[i]->data = i;
c0101185:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101188:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010118f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101192:	01 d0                	add    %edx,%eax
c0101194:	8b 00                	mov    (%eax),%eax
c0101196:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101199:	89 10                	mov    %edx,(%eax)

    int total = 1000;
    struct check_data **all = check_safe_kmalloc(sizeof(struct check_data *) * total);

    long i;
    for (i = 0; i < total; i ++) {
c010119b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010119f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01011a2:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01011a5:	7c bf                	jl     c0101166 <check_rb_tree+0x9d>
        all[i] = check_safe_kmalloc(sizeof(struct check_data));
        all[i]->data = i;
    }

    int *mark = check_safe_kmalloc(sizeof(int) * total);
c01011a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01011aa:	c1 e0 02             	shl    $0x2,%eax
c01011ad:	83 ec 0c             	sub    $0xc,%esp
c01011b0:	50                   	push   %eax
c01011b1:	e8 ab fe ff ff       	call   c0101061 <check_safe_kmalloc>
c01011b6:	83 c4 10             	add    $0x10,%esp
c01011b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    memset(mark, 0, sizeof(int) * total);
c01011bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01011bf:	c1 e0 02             	shl    $0x2,%eax
c01011c2:	83 ec 04             	sub    $0x4,%esp
c01011c5:	50                   	push   %eax
c01011c6:	6a 00                	push   $0x0
c01011c8:	ff 75 d8             	pushl  -0x28(%ebp)
c01011cb:	e8 79 8e 00 00       	call   c010a049 <memset>
c01011d0:	83 c4 10             	add    $0x10,%esp

    for (i = 0; i < total; i ++) {
c01011d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01011da:	eb 29                	jmp    c0101205 <check_rb_tree+0x13c>
        mark[all[i]->data] = 1;
c01011dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01011df:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01011e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01011e9:	01 d0                	add    %edx,%eax
c01011eb:	8b 00                	mov    (%eax),%eax
c01011ed:	8b 00                	mov    (%eax),%eax
c01011ef:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01011f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01011f9:	01 d0                	add    %edx,%eax
c01011fb:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
    }

    int *mark = check_safe_kmalloc(sizeof(int) * total);
    memset(mark, 0, sizeof(int) * total);

    for (i = 0; i < total; i ++) {
c0101201:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101205:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101208:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010120b:	7c cf                	jl     c01011dc <check_rb_tree+0x113>
        mark[all[i]->data] = 1;
    }
    for (i = 0; i < total; i ++) {
c010120d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101214:	eb 33                	jmp    c0101249 <check_rb_tree+0x180>
        assert(mark[i] == 1);
c0101216:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101219:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101220:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101223:	01 d0                	add    %edx,%eax
c0101225:	8b 00                	mov    (%eax),%eax
c0101227:	83 f8 01             	cmp    $0x1,%eax
c010122a:	74 19                	je     c0101245 <check_rb_tree+0x17c>
c010122c:	68 3b ab 10 c0       	push   $0xc010ab3b
c0101231:	68 98 a9 10 c0       	push   $0xc010a998
c0101236:	68 c8 01 00 00       	push   $0x1c8
c010123b:	68 ad a9 10 c0       	push   $0xc010a9ad
c0101240:	e8 23 05 00 00       	call   c0101768 <__panic>
    memset(mark, 0, sizeof(int) * total);

    for (i = 0; i < total; i ++) {
        mark[all[i]->data] = 1;
    }
    for (i = 0; i < total; i ++) {
c0101245:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101249:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010124c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010124f:	7c c5                	jl     c0101216 <check_rb_tree+0x14d>
        assert(mark[i] == 1);
    }

    for (i = 0; i < total; i ++) {
c0101251:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101258:	eb 6a                	jmp    c01012c4 <check_rb_tree+0x1fb>
        int j = (rand() % (total - i)) + i;
c010125a:	e8 a6 95 00 00       	call   c010a805 <rand>
c010125f:	89 c2                	mov    %eax,%edx
c0101261:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101264:	2b 45 f4             	sub    -0xc(%ebp),%eax
c0101267:	89 c1                	mov    %eax,%ecx
c0101269:	89 d0                	mov    %edx,%eax
c010126b:	99                   	cltd   
c010126c:	f7 f9                	idiv   %ecx
c010126e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101271:	01 d0                	add    %edx,%eax
c0101273:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        struct check_data *z = all[i];
c0101276:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101279:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101280:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101283:	01 d0                	add    %edx,%eax
c0101285:	8b 00                	mov    (%eax),%eax
c0101287:	89 45 d0             	mov    %eax,-0x30(%ebp)
        all[i] = all[j];
c010128a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010128d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101294:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101297:	01 c2                	add    %eax,%edx
c0101299:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010129c:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
c01012a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01012a6:	01 c8                	add    %ecx,%eax
c01012a8:	8b 00                	mov    (%eax),%eax
c01012aa:	89 02                	mov    %eax,(%edx)
        all[j] = z;
c01012ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01012af:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01012b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01012b9:	01 c2                	add    %eax,%edx
c01012bb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01012be:	89 02                	mov    %eax,(%edx)
    }
    for (i = 0; i < total; i ++) {
        assert(mark[i] == 1);
    }

    for (i = 0; i < total; i ++) {
c01012c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01012c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01012c7:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01012ca:	7c 8e                	jl     c010125a <check_rb_tree+0x191>
        struct check_data *z = all[i];
        all[i] = all[j];
        all[j] = z;
    }

    memset(mark, 0, sizeof(int) * total);
c01012cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01012cf:	c1 e0 02             	shl    $0x2,%eax
c01012d2:	83 ec 04             	sub    $0x4,%esp
c01012d5:	50                   	push   %eax
c01012d6:	6a 00                	push   $0x0
c01012d8:	ff 75 d8             	pushl  -0x28(%ebp)
c01012db:	e8 69 8d 00 00       	call   c010a049 <memset>
c01012e0:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < total; i ++) {
c01012e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01012ea:	eb 29                	jmp    c0101315 <check_rb_tree+0x24c>
        mark[all[i]->data] = 1;
c01012ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01012ef:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01012f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01012f9:	01 d0                	add    %edx,%eax
c01012fb:	8b 00                	mov    (%eax),%eax
c01012fd:	8b 00                	mov    (%eax),%eax
c01012ff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101306:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101309:	01 d0                	add    %edx,%eax
c010130b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        all[i] = all[j];
        all[j] = z;
    }

    memset(mark, 0, sizeof(int) * total);
    for (i = 0; i < total; i ++) {
c0101311:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101315:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101318:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010131b:	7c cf                	jl     c01012ec <check_rb_tree+0x223>
        mark[all[i]->data] = 1;
    }
    for (i = 0; i < total; i ++) {
c010131d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101324:	eb 33                	jmp    c0101359 <check_rb_tree+0x290>
        assert(mark[i] == 1);
c0101326:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101329:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101330:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101333:	01 d0                	add    %edx,%eax
c0101335:	8b 00                	mov    (%eax),%eax
c0101337:	83 f8 01             	cmp    $0x1,%eax
c010133a:	74 19                	je     c0101355 <check_rb_tree+0x28c>
c010133c:	68 3b ab 10 c0       	push   $0xc010ab3b
c0101341:	68 98 a9 10 c0       	push   $0xc010a998
c0101346:	68 d7 01 00 00       	push   $0x1d7
c010134b:	68 ad a9 10 c0       	push   $0xc010a9ad
c0101350:	e8 13 04 00 00       	call   c0101768 <__panic>

    memset(mark, 0, sizeof(int) * total);
    for (i = 0; i < total; i ++) {
        mark[all[i]->data] = 1;
    }
    for (i = 0; i < total; i ++) {
c0101355:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101359:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010135c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010135f:	7c c5                	jl     c0101326 <check_rb_tree+0x25d>
        assert(mark[i] == 1);
    }

    for (i = 0; i < total; i ++) {
c0101361:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101368:	eb 3c                	jmp    c01013a6 <check_rb_tree+0x2dd>
        rb_insert(tree, &(all[i]->rb_link));
c010136a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010136d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101374:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101377:	01 d0                	add    %edx,%eax
c0101379:	8b 00                	mov    (%eax),%eax
c010137b:	83 c0 04             	add    $0x4,%eax
c010137e:	83 ec 08             	sub    $0x8,%esp
c0101381:	50                   	push   %eax
c0101382:	ff 75 ec             	pushl  -0x14(%ebp)
c0101385:	e8 3c f3 ff ff       	call   c01006c6 <rb_insert>
c010138a:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c010138d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101390:	8b 40 08             	mov    0x8(%eax),%eax
c0101393:	83 ec 08             	sub    $0x8,%esp
c0101396:	50                   	push   %eax
c0101397:	ff 75 ec             	pushl  -0x14(%ebp)
c010139a:	e8 10 fb ff ff       	call   c0100eaf <check_tree>
c010139f:	83 c4 10             	add    $0x10,%esp
    }
    for (i = 0; i < total; i ++) {
        assert(mark[i] == 1);
    }

    for (i = 0; i < total; i ++) {
c01013a2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01013a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01013a9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01013ac:	7c bc                	jl     c010136a <check_rb_tree+0x2a1>
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    rb_node *node;
    for (i = 0; i < total; i ++) {
c01013ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01013b5:	eb 66                	jmp    c010141d <check_rb_tree+0x354>
        node = rb_search(tree, check_compare2, (void *)(all[i]->data));
c01013b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01013ba:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01013c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01013c4:	01 d0                	add    %edx,%eax
c01013c6:	8b 00                	mov    (%eax),%eax
c01013c8:	8b 00                	mov    (%eax),%eax
c01013ca:	83 ec 04             	sub    $0x4,%esp
c01013cd:	50                   	push   %eax
c01013ce:	68 b5 10 10 c0       	push   $0xc01010b5
c01013d3:	ff 75 ec             	pushl  -0x14(%ebp)
c01013d6:	e8 cb f5 ff ff       	call   c01009a6 <rb_search>
c01013db:	83 c4 10             	add    $0x10,%esp
c01013de:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(node != NULL && node == &(all[i]->rb_link));
c01013e1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01013e5:	74 19                	je     c0101400 <check_rb_tree+0x337>
c01013e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01013ea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01013f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01013f4:	01 d0                	add    %edx,%eax
c01013f6:	8b 00                	mov    (%eax),%eax
c01013f8:	83 c0 04             	add    $0x4,%eax
c01013fb:	3b 45 cc             	cmp    -0x34(%ebp),%eax
c01013fe:	74 19                	je     c0101419 <check_rb_tree+0x350>
c0101400:	68 48 ab 10 c0       	push   $0xc010ab48
c0101405:	68 98 a9 10 c0       	push   $0xc010a998
c010140a:	68 e2 01 00 00       	push   $0x1e2
c010140f:	68 ad a9 10 c0       	push   $0xc010a9ad
c0101414:	e8 4f 03 00 00       	call   c0101768 <__panic>
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    rb_node *node;
    for (i = 0; i < total; i ++) {
c0101419:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010141d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101420:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101423:	7c 92                	jl     c01013b7 <check_rb_tree+0x2ee>
        node = rb_search(tree, check_compare2, (void *)(all[i]->data));
        assert(node != NULL && node == &(all[i]->rb_link));
    }

    for (i = 0; i < total; i ++) {
c0101425:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010142c:	eb 70                	jmp    c010149e <check_rb_tree+0x3d5>
        node = rb_search(tree, check_compare2, (void *)i);
c010142e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101431:	83 ec 04             	sub    $0x4,%esp
c0101434:	50                   	push   %eax
c0101435:	68 b5 10 10 c0       	push   $0xc01010b5
c010143a:	ff 75 ec             	pushl  -0x14(%ebp)
c010143d:	e8 64 f5 ff ff       	call   c01009a6 <rb_search>
c0101442:	83 c4 10             	add    $0x10,%esp
c0101445:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(node != NULL && rbn2data(node)->data == i);
c0101448:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010144c:	74 0d                	je     c010145b <check_rb_tree+0x392>
c010144e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0101451:	83 e8 04             	sub    $0x4,%eax
c0101454:	8b 00                	mov    (%eax),%eax
c0101456:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0101459:	74 19                	je     c0101474 <check_rb_tree+0x3ab>
c010145b:	68 74 ab 10 c0       	push   $0xc010ab74
c0101460:	68 98 a9 10 c0       	push   $0xc010a998
c0101465:	68 e7 01 00 00       	push   $0x1e7
c010146a:	68 ad a9 10 c0       	push   $0xc010a9ad
c010146f:	e8 f4 02 00 00       	call   c0101768 <__panic>
        rb_delete(tree, node);
c0101474:	83 ec 08             	sub    $0x8,%esp
c0101477:	ff 75 cc             	pushl  -0x34(%ebp)
c010147a:	ff 75 ec             	pushl  -0x14(%ebp)
c010147d:	e8 d0 f7 ff ff       	call   c0100c52 <rb_delete>
c0101482:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c0101485:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101488:	8b 40 08             	mov    0x8(%eax),%eax
c010148b:	83 ec 08             	sub    $0x8,%esp
c010148e:	50                   	push   %eax
c010148f:	ff 75 ec             	pushl  -0x14(%ebp)
c0101492:	e8 18 fa ff ff       	call   c0100eaf <check_tree>
c0101497:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < total; i ++) {
        node = rb_search(tree, check_compare2, (void *)(all[i]->data));
        assert(node != NULL && node == &(all[i]->rb_link));
    }

    for (i = 0; i < total; i ++) {
c010149a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010149e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01014a1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01014a4:	7c 88                	jl     c010142e <check_rb_tree+0x365>
        assert(node != NULL && rbn2data(node)->data == i);
        rb_delete(tree, node);
        check_tree(tree, root->left);
    }

    assert(!nil->red && root->left == nil);
c01014a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01014a9:	8b 00                	mov    (%eax),%eax
c01014ab:	85 c0                	test   %eax,%eax
c01014ad:	75 0b                	jne    c01014ba <check_rb_tree+0x3f1>
c01014af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01014b2:	8b 40 08             	mov    0x8(%eax),%eax
c01014b5:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c01014b8:	74 19                	je     c01014d3 <check_rb_tree+0x40a>
c01014ba:	68 1c ab 10 c0       	push   $0xc010ab1c
c01014bf:	68 98 a9 10 c0       	push   $0xc010a998
c01014c4:	68 ec 01 00 00       	push   $0x1ec
c01014c9:	68 ad a9 10 c0       	push   $0xc010a9ad
c01014ce:	e8 95 02 00 00       	call   c0101768 <__panic>

    long max = 32;
c01014d3:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
    if (max > total) {
c01014da:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01014dd:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01014e0:	7e 06                	jle    c01014e8 <check_rb_tree+0x41f>
        max = total;
c01014e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01014e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }

    for (i = 0; i < max; i ++) {
c01014e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01014ef:	eb 52                	jmp    c0101543 <check_rb_tree+0x47a>
        all[i]->data = max;
c01014f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01014f4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01014fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01014fe:	01 d0                	add    %edx,%eax
c0101500:	8b 00                	mov    (%eax),%eax
c0101502:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101505:	89 10                	mov    %edx,(%eax)
        rb_insert(tree, &(all[i]->rb_link));
c0101507:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010150a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101511:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101514:	01 d0                	add    %edx,%eax
c0101516:	8b 00                	mov    (%eax),%eax
c0101518:	83 c0 04             	add    $0x4,%eax
c010151b:	83 ec 08             	sub    $0x8,%esp
c010151e:	50                   	push   %eax
c010151f:	ff 75 ec             	pushl  -0x14(%ebp)
c0101522:	e8 9f f1 ff ff       	call   c01006c6 <rb_insert>
c0101527:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c010152a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010152d:	8b 40 08             	mov    0x8(%eax),%eax
c0101530:	83 ec 08             	sub    $0x8,%esp
c0101533:	50                   	push   %eax
c0101534:	ff 75 ec             	pushl  -0x14(%ebp)
c0101537:	e8 73 f9 ff ff       	call   c0100eaf <check_tree>
c010153c:	83 c4 10             	add    $0x10,%esp
    long max = 32;
    if (max > total) {
        max = total;
    }

    for (i = 0; i < max; i ++) {
c010153f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101543:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101546:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0101549:	7c a6                	jl     c01014f1 <check_rb_tree+0x428>
        all[i]->data = max;
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    for (i = 0; i < max; i ++) {
c010154b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101552:	eb 70                	jmp    c01015c4 <check_rb_tree+0x4fb>
        node = rb_search(tree, check_compare2, (void *)max);
c0101554:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101557:	83 ec 04             	sub    $0x4,%esp
c010155a:	50                   	push   %eax
c010155b:	68 b5 10 10 c0       	push   $0xc01010b5
c0101560:	ff 75 ec             	pushl  -0x14(%ebp)
c0101563:	e8 3e f4 ff ff       	call   c01009a6 <rb_search>
c0101568:	83 c4 10             	add    $0x10,%esp
c010156b:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(node != NULL && rbn2data(node)->data == max);
c010156e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0101572:	74 0d                	je     c0101581 <check_rb_tree+0x4b8>
c0101574:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0101577:	83 e8 04             	sub    $0x4,%eax
c010157a:	8b 00                	mov    (%eax),%eax
c010157c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010157f:	74 19                	je     c010159a <check_rb_tree+0x4d1>
c0101581:	68 a0 ab 10 c0       	push   $0xc010aba0
c0101586:	68 98 a9 10 c0       	push   $0xc010a998
c010158b:	68 fb 01 00 00       	push   $0x1fb
c0101590:	68 ad a9 10 c0       	push   $0xc010a9ad
c0101595:	e8 ce 01 00 00       	call   c0101768 <__panic>
        rb_delete(tree, node);
c010159a:	83 ec 08             	sub    $0x8,%esp
c010159d:	ff 75 cc             	pushl  -0x34(%ebp)
c01015a0:	ff 75 ec             	pushl  -0x14(%ebp)
c01015a3:	e8 aa f6 ff ff       	call   c0100c52 <rb_delete>
c01015a8:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c01015ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01015ae:	8b 40 08             	mov    0x8(%eax),%eax
c01015b1:	83 ec 08             	sub    $0x8,%esp
c01015b4:	50                   	push   %eax
c01015b5:	ff 75 ec             	pushl  -0x14(%ebp)
c01015b8:	e8 f2 f8 ff ff       	call   c0100eaf <check_tree>
c01015bd:	83 c4 10             	add    $0x10,%esp
        all[i]->data = max;
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    for (i = 0; i < max; i ++) {
c01015c0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01015c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01015c7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01015ca:	7c 88                	jl     c0101554 <check_rb_tree+0x48b>
        assert(node != NULL && rbn2data(node)->data == max);
        rb_delete(tree, node);
        check_tree(tree, root->left);
    }

    assert(rb_tree_empty(tree));
c01015cc:	83 ec 0c             	sub    $0xc,%esp
c01015cf:	ff 75 ec             	pushl  -0x14(%ebp)
c01015d2:	e8 6c ed ff ff       	call   c0100343 <rb_tree_empty>
c01015d7:	83 c4 10             	add    $0x10,%esp
c01015da:	85 c0                	test   %eax,%eax
c01015dc:	75 19                	jne    c01015f7 <check_rb_tree+0x52e>
c01015de:	68 cc ab 10 c0       	push   $0xc010abcc
c01015e3:	68 98 a9 10 c0       	push   $0xc010a998
c01015e8:	68 00 02 00 00       	push   $0x200
c01015ed:	68 ad a9 10 c0       	push   $0xc010a9ad
c01015f2:	e8 71 01 00 00       	call   c0101768 <__panic>

    for (i = 0; i < total; i ++) {
c01015f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01015fe:	eb 3c                	jmp    c010163c <check_rb_tree+0x573>
        rb_insert(tree, &(all[i]->rb_link));
c0101600:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101603:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010160a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010160d:	01 d0                	add    %edx,%eax
c010160f:	8b 00                	mov    (%eax),%eax
c0101611:	83 c0 04             	add    $0x4,%eax
c0101614:	83 ec 08             	sub    $0x8,%esp
c0101617:	50                   	push   %eax
c0101618:	ff 75 ec             	pushl  -0x14(%ebp)
c010161b:	e8 a6 f0 ff ff       	call   c01006c6 <rb_insert>
c0101620:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c0101623:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101626:	8b 40 08             	mov    0x8(%eax),%eax
c0101629:	83 ec 08             	sub    $0x8,%esp
c010162c:	50                   	push   %eax
c010162d:	ff 75 ec             	pushl  -0x14(%ebp)
c0101630:	e8 7a f8 ff ff       	call   c0100eaf <check_tree>
c0101635:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
    }

    assert(rb_tree_empty(tree));

    for (i = 0; i < total; i ++) {
c0101638:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010163c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010163f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101642:	7c bc                	jl     c0101600 <check_rb_tree+0x537>
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    rb_tree_destroy(tree);
c0101644:	83 ec 0c             	sub    $0xc,%esp
c0101647:	ff 75 ec             	pushl  -0x14(%ebp)
c010164a:	e8 54 f7 ff ff       	call   c0100da3 <rb_tree_destroy>
c010164f:	83 c4 10             	add    $0x10,%esp

    for (i = 0; i < total; i ++) {
c0101652:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101659:	eb 21                	jmp    c010167c <check_rb_tree+0x5b3>
        kfree(all[i]);
c010165b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010165e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101665:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101668:	01 d0                	add    %edx,%eax
c010166a:	8b 00                	mov    (%eax),%eax
c010166c:	83 ec 0c             	sub    $0xc,%esp
c010166f:	50                   	push   %eax
c0101670:	e8 b1 4b 00 00       	call   c0106226 <kfree>
c0101675:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
    }

    rb_tree_destroy(tree);

    for (i = 0; i < total; i ++) {
c0101678:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010167c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010167f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101682:	7c d7                	jl     c010165b <check_rb_tree+0x592>
        kfree(all[i]);
    }

    kfree(mark);
c0101684:	83 ec 0c             	sub    $0xc,%esp
c0101687:	ff 75 d8             	pushl  -0x28(%ebp)
c010168a:	e8 97 4b 00 00       	call   c0106226 <kfree>
c010168f:	83 c4 10             	add    $0x10,%esp
    kfree(all);
c0101692:	83 ec 0c             	sub    $0xc,%esp
c0101695:	ff 75 dc             	pushl  -0x24(%ebp)
c0101698:	e8 89 4b 00 00       	call   c0106226 <kfree>
c010169d:	83 c4 10             	add    $0x10,%esp
}
c01016a0:	90                   	nop
c01016a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01016a4:	c9                   	leave  
c01016a5:	c3                   	ret    

c01016a6 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c01016a6:	55                   	push   %ebp
c01016a7:	89 e5                	mov    %esp,%ebp
c01016a9:	83 ec 18             	sub    $0x18,%esp
    if (prompt != NULL) {
c01016ac:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01016b0:	74 13                	je     c01016c5 <readline+0x1f>
        cprintf("%s", prompt);
c01016b2:	83 ec 08             	sub    $0x8,%esp
c01016b5:	ff 75 08             	pushl  0x8(%ebp)
c01016b8:	68 e0 ab 10 c0       	push   $0xc010abe0
c01016bd:	e8 c8 eb ff ff       	call   c010028a <cprintf>
c01016c2:	83 c4 10             	add    $0x10,%esp
    }
    int i = 0, c;
c01016c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c01016cc:	e8 44 ec ff ff       	call   c0100315 <getchar>
c01016d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c01016d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01016d8:	79 0a                	jns    c01016e4 <readline+0x3e>
            return NULL;
c01016da:	b8 00 00 00 00       	mov    $0x0,%eax
c01016df:	e9 82 00 00 00       	jmp    c0101766 <readline+0xc0>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c01016e4:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c01016e8:	7e 2b                	jle    c0101715 <readline+0x6f>
c01016ea:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c01016f1:	7f 22                	jg     c0101715 <readline+0x6f>
            cputchar(c);
c01016f3:	83 ec 0c             	sub    $0xc,%esp
c01016f6:	ff 75 f0             	pushl  -0x10(%ebp)
c01016f9:	e8 b2 eb ff ff       	call   c01002b0 <cputchar>
c01016fe:	83 c4 10             	add    $0x10,%esp
            buf[i ++] = c;
c0101701:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101704:	8d 50 01             	lea    0x1(%eax),%edx
c0101707:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010170a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010170d:	88 90 20 a0 12 c0    	mov    %dl,-0x3fed5fe0(%eax)
c0101713:	eb 4c                	jmp    c0101761 <readline+0xbb>
        }
        else if (c == '\b' && i > 0) {
c0101715:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c0101719:	75 1a                	jne    c0101735 <readline+0x8f>
c010171b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010171f:	7e 14                	jle    c0101735 <readline+0x8f>
            cputchar(c);
c0101721:	83 ec 0c             	sub    $0xc,%esp
c0101724:	ff 75 f0             	pushl  -0x10(%ebp)
c0101727:	e8 84 eb ff ff       	call   c01002b0 <cputchar>
c010172c:	83 c4 10             	add    $0x10,%esp
            i --;
c010172f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0101733:	eb 2c                	jmp    c0101761 <readline+0xbb>
        }
        else if (c == '\n' || c == '\r') {
c0101735:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c0101739:	74 06                	je     c0101741 <readline+0x9b>
c010173b:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c010173f:	75 8b                	jne    c01016cc <readline+0x26>
            cputchar(c);
c0101741:	83 ec 0c             	sub    $0xc,%esp
c0101744:	ff 75 f0             	pushl  -0x10(%ebp)
c0101747:	e8 64 eb ff ff       	call   c01002b0 <cputchar>
c010174c:	83 c4 10             	add    $0x10,%esp
            buf[i] = '\0';
c010174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101752:	05 20 a0 12 c0       	add    $0xc012a020,%eax
c0101757:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c010175a:	b8 20 a0 12 c0       	mov    $0xc012a020,%eax
c010175f:	eb 05                	jmp    c0101766 <readline+0xc0>
        }
    }
c0101761:	e9 66 ff ff ff       	jmp    c01016cc <readline+0x26>
}
c0101766:	c9                   	leave  
c0101767:	c3                   	ret    

c0101768 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0101768:	55                   	push   %ebp
c0101769:	89 e5                	mov    %esp,%ebp
c010176b:	83 ec 18             	sub    $0x18,%esp
    if (is_panic) {
c010176e:	a1 20 a4 12 c0       	mov    0xc012a420,%eax
c0101773:	85 c0                	test   %eax,%eax
c0101775:	75 5f                	jne    c01017d6 <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
c0101777:	c7 05 20 a4 12 c0 01 	movl   $0x1,0xc012a420
c010177e:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0101781:	8d 45 14             	lea    0x14(%ebp),%eax
c0101784:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0101787:	83 ec 04             	sub    $0x4,%esp
c010178a:	ff 75 0c             	pushl  0xc(%ebp)
c010178d:	ff 75 08             	pushl  0x8(%ebp)
c0101790:	68 e3 ab 10 c0       	push   $0xc010abe3
c0101795:	e8 f0 ea ff ff       	call   c010028a <cprintf>
c010179a:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c010179d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01017a0:	83 ec 08             	sub    $0x8,%esp
c01017a3:	50                   	push   %eax
c01017a4:	ff 75 10             	pushl  0x10(%ebp)
c01017a7:	e8 b5 ea ff ff       	call   c0100261 <vcprintf>
c01017ac:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c01017af:	83 ec 0c             	sub    $0xc,%esp
c01017b2:	68 ff ab 10 c0       	push   $0xc010abff
c01017b7:	e8 ce ea ff ff       	call   c010028a <cprintf>
c01017bc:	83 c4 10             	add    $0x10,%esp
    
    cprintf("stack trackback:\n");
c01017bf:	83 ec 0c             	sub    $0xc,%esp
c01017c2:	68 01 ac 10 c0       	push   $0xc010ac01
c01017c7:	e8 be ea ff ff       	call   c010028a <cprintf>
c01017cc:	83 c4 10             	add    $0x10,%esp
    print_stackframe();
c01017cf:	e8 17 06 00 00       	call   c0101deb <print_stackframe>
c01017d4:	eb 01                	jmp    c01017d7 <__panic+0x6f>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
c01017d6:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
c01017d7:	e8 6d 1c 00 00       	call   c0103449 <intr_disable>
    while (1) {
        kmonitor(NULL);
c01017dc:	83 ec 0c             	sub    $0xc,%esp
c01017df:	6a 00                	push   $0x0
c01017e1:	e8 36 08 00 00       	call   c010201c <kmonitor>
c01017e6:	83 c4 10             	add    $0x10,%esp
    }
c01017e9:	eb f1                	jmp    c01017dc <__panic+0x74>

c01017eb <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c01017eb:	55                   	push   %ebp
c01017ec:	89 e5                	mov    %esp,%ebp
c01017ee:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    va_start(ap, fmt);
c01017f1:	8d 45 14             	lea    0x14(%ebp),%eax
c01017f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c01017f7:	83 ec 04             	sub    $0x4,%esp
c01017fa:	ff 75 0c             	pushl  0xc(%ebp)
c01017fd:	ff 75 08             	pushl  0x8(%ebp)
c0101800:	68 13 ac 10 c0       	push   $0xc010ac13
c0101805:	e8 80 ea ff ff       	call   c010028a <cprintf>
c010180a:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c010180d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101810:	83 ec 08             	sub    $0x8,%esp
c0101813:	50                   	push   %eax
c0101814:	ff 75 10             	pushl  0x10(%ebp)
c0101817:	e8 45 ea ff ff       	call   c0100261 <vcprintf>
c010181c:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c010181f:	83 ec 0c             	sub    $0xc,%esp
c0101822:	68 ff ab 10 c0       	push   $0xc010abff
c0101827:	e8 5e ea ff ff       	call   c010028a <cprintf>
c010182c:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c010182f:	90                   	nop
c0101830:	c9                   	leave  
c0101831:	c3                   	ret    

c0101832 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0101832:	55                   	push   %ebp
c0101833:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0101835:	a1 20 a4 12 c0       	mov    0xc012a420,%eax
}
c010183a:	5d                   	pop    %ebp
c010183b:	c3                   	ret    

c010183c <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c010183c:	55                   	push   %ebp
c010183d:	89 e5                	mov    %esp,%ebp
c010183f:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c0101842:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101845:	8b 00                	mov    (%eax),%eax
c0101847:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010184a:	8b 45 10             	mov    0x10(%ebp),%eax
c010184d:	8b 00                	mov    (%eax),%eax
c010184f:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0101852:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0101859:	e9 d2 00 00 00       	jmp    c0101930 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c010185e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101861:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101864:	01 d0                	add    %edx,%eax
c0101866:	89 c2                	mov    %eax,%edx
c0101868:	c1 ea 1f             	shr    $0x1f,%edx
c010186b:	01 d0                	add    %edx,%eax
c010186d:	d1 f8                	sar    %eax
c010186f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0101872:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101875:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0101878:	eb 04                	jmp    c010187e <stab_binsearch+0x42>
            m --;
c010187a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010187e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101881:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0101884:	7c 1f                	jl     c01018a5 <stab_binsearch+0x69>
c0101886:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101889:	89 d0                	mov    %edx,%eax
c010188b:	01 c0                	add    %eax,%eax
c010188d:	01 d0                	add    %edx,%eax
c010188f:	c1 e0 02             	shl    $0x2,%eax
c0101892:	89 c2                	mov    %eax,%edx
c0101894:	8b 45 08             	mov    0x8(%ebp),%eax
c0101897:	01 d0                	add    %edx,%eax
c0101899:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010189d:	0f b6 c0             	movzbl %al,%eax
c01018a0:	3b 45 14             	cmp    0x14(%ebp),%eax
c01018a3:	75 d5                	jne    c010187a <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c01018a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01018a8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01018ab:	7d 0b                	jge    c01018b8 <stab_binsearch+0x7c>
            l = true_m + 1;
c01018ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01018b0:	83 c0 01             	add    $0x1,%eax
c01018b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c01018b6:	eb 78                	jmp    c0101930 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c01018b8:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c01018bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01018c2:	89 d0                	mov    %edx,%eax
c01018c4:	01 c0                	add    %eax,%eax
c01018c6:	01 d0                	add    %edx,%eax
c01018c8:	c1 e0 02             	shl    $0x2,%eax
c01018cb:	89 c2                	mov    %eax,%edx
c01018cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01018d0:	01 d0                	add    %edx,%eax
c01018d2:	8b 40 08             	mov    0x8(%eax),%eax
c01018d5:	3b 45 18             	cmp    0x18(%ebp),%eax
c01018d8:	73 13                	jae    c01018ed <stab_binsearch+0xb1>
            *region_left = m;
c01018da:	8b 45 0c             	mov    0xc(%ebp),%eax
c01018dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01018e0:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01018e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01018e5:	83 c0 01             	add    $0x1,%eax
c01018e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01018eb:	eb 43                	jmp    c0101930 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c01018ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01018f0:	89 d0                	mov    %edx,%eax
c01018f2:	01 c0                	add    %eax,%eax
c01018f4:	01 d0                	add    %edx,%eax
c01018f6:	c1 e0 02             	shl    $0x2,%eax
c01018f9:	89 c2                	mov    %eax,%edx
c01018fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01018fe:	01 d0                	add    %edx,%eax
c0101900:	8b 40 08             	mov    0x8(%eax),%eax
c0101903:	3b 45 18             	cmp    0x18(%ebp),%eax
c0101906:	76 16                	jbe    c010191e <stab_binsearch+0xe2>
            *region_right = m - 1;
c0101908:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010190b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010190e:	8b 45 10             	mov    0x10(%ebp),%eax
c0101911:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c0101913:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101916:	83 e8 01             	sub    $0x1,%eax
c0101919:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010191c:	eb 12                	jmp    c0101930 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c010191e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101921:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101924:	89 10                	mov    %edx,(%eax)
            l = m;
c0101926:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101929:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c010192c:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c0101930:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101933:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0101936:	0f 8e 22 ff ff ff    	jle    c010185e <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c010193c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101940:	75 0f                	jne    c0101951 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c0101942:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101945:	8b 00                	mov    (%eax),%eax
c0101947:	8d 50 ff             	lea    -0x1(%eax),%edx
c010194a:	8b 45 10             	mov    0x10(%ebp),%eax
c010194d:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c010194f:	eb 3f                	jmp    c0101990 <stab_binsearch+0x154>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c0101951:	8b 45 10             	mov    0x10(%ebp),%eax
c0101954:	8b 00                	mov    (%eax),%eax
c0101956:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0101959:	eb 04                	jmp    c010195f <stab_binsearch+0x123>
c010195b:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c010195f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101962:	8b 00                	mov    (%eax),%eax
c0101964:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0101967:	7d 1f                	jge    c0101988 <stab_binsearch+0x14c>
c0101969:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010196c:	89 d0                	mov    %edx,%eax
c010196e:	01 c0                	add    %eax,%eax
c0101970:	01 d0                	add    %edx,%eax
c0101972:	c1 e0 02             	shl    $0x2,%eax
c0101975:	89 c2                	mov    %eax,%edx
c0101977:	8b 45 08             	mov    0x8(%ebp),%eax
c010197a:	01 d0                	add    %edx,%eax
c010197c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101980:	0f b6 c0             	movzbl %al,%eax
c0101983:	3b 45 14             	cmp    0x14(%ebp),%eax
c0101986:	75 d3                	jne    c010195b <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0101988:	8b 45 0c             	mov    0xc(%ebp),%eax
c010198b:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010198e:	89 10                	mov    %edx,(%eax)
    }
}
c0101990:	90                   	nop
c0101991:	c9                   	leave  
c0101992:	c3                   	ret    

c0101993 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0101993:	55                   	push   %ebp
c0101994:	89 e5                	mov    %esp,%ebp
c0101996:	83 ec 38             	sub    $0x38,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0101999:	8b 45 0c             	mov    0xc(%ebp),%eax
c010199c:	c7 00 34 ac 10 c0    	movl   $0xc010ac34,(%eax)
    info->eip_line = 0;
c01019a2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019a5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c01019ac:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019af:	c7 40 08 34 ac 10 c0 	movl   $0xc010ac34,0x8(%eax)
    info->eip_fn_namelen = 9;
c01019b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019b9:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c01019c0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019c3:	8b 55 08             	mov    0x8(%ebp),%edx
c01019c6:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c01019c9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019cc:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c01019d3:	c7 45 f4 2c ce 10 c0 	movl   $0xc010ce2c,-0xc(%ebp)
    stab_end = __STAB_END__;
c01019da:	c7 45 f0 b4 ff 11 c0 	movl   $0xc011ffb4,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c01019e1:	c7 45 ec b5 ff 11 c0 	movl   $0xc011ffb5,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01019e8:	c7 45 e8 08 4d 12 c0 	movl   $0xc0124d08,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01019ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01019f2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01019f5:	76 0d                	jbe    c0101a04 <debuginfo_eip+0x71>
c01019f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01019fa:	83 e8 01             	sub    $0x1,%eax
c01019fd:	0f b6 00             	movzbl (%eax),%eax
c0101a00:	84 c0                	test   %al,%al
c0101a02:	74 0a                	je     c0101a0e <debuginfo_eip+0x7b>
        return -1;
c0101a04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101a09:	e9 91 02 00 00       	jmp    c0101c9f <debuginfo_eip+0x30c>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c0101a0e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0101a15:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101a1b:	29 c2                	sub    %eax,%edx
c0101a1d:	89 d0                	mov    %edx,%eax
c0101a1f:	c1 f8 02             	sar    $0x2,%eax
c0101a22:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c0101a28:	83 e8 01             	sub    $0x1,%eax
c0101a2b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c0101a2e:	ff 75 08             	pushl  0x8(%ebp)
c0101a31:	6a 64                	push   $0x64
c0101a33:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0101a36:	50                   	push   %eax
c0101a37:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c0101a3a:	50                   	push   %eax
c0101a3b:	ff 75 f4             	pushl  -0xc(%ebp)
c0101a3e:	e8 f9 fd ff ff       	call   c010183c <stab_binsearch>
c0101a43:	83 c4 14             	add    $0x14,%esp
    if (lfile == 0)
c0101a46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a49:	85 c0                	test   %eax,%eax
c0101a4b:	75 0a                	jne    c0101a57 <debuginfo_eip+0xc4>
        return -1;
c0101a4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101a52:	e9 48 02 00 00       	jmp    c0101c9f <debuginfo_eip+0x30c>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0101a57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a5a:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101a5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101a60:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0101a63:	ff 75 08             	pushl  0x8(%ebp)
c0101a66:	6a 24                	push   $0x24
c0101a68:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0101a6b:	50                   	push   %eax
c0101a6c:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0101a6f:	50                   	push   %eax
c0101a70:	ff 75 f4             	pushl  -0xc(%ebp)
c0101a73:	e8 c4 fd ff ff       	call   c010183c <stab_binsearch>
c0101a78:	83 c4 14             	add    $0x14,%esp

    if (lfun <= rfun) {
c0101a7b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a7e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101a81:	39 c2                	cmp    %eax,%edx
c0101a83:	7f 7c                	jg     c0101b01 <debuginfo_eip+0x16e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0101a85:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101a88:	89 c2                	mov    %eax,%edx
c0101a8a:	89 d0                	mov    %edx,%eax
c0101a8c:	01 c0                	add    %eax,%eax
c0101a8e:	01 d0                	add    %edx,%eax
c0101a90:	c1 e0 02             	shl    $0x2,%eax
c0101a93:	89 c2                	mov    %eax,%edx
c0101a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101a98:	01 d0                	add    %edx,%eax
c0101a9a:	8b 00                	mov    (%eax),%eax
c0101a9c:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0101a9f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101aa2:	29 d1                	sub    %edx,%ecx
c0101aa4:	89 ca                	mov    %ecx,%edx
c0101aa6:	39 d0                	cmp    %edx,%eax
c0101aa8:	73 22                	jae    c0101acc <debuginfo_eip+0x139>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0101aaa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101aad:	89 c2                	mov    %eax,%edx
c0101aaf:	89 d0                	mov    %edx,%eax
c0101ab1:	01 c0                	add    %eax,%eax
c0101ab3:	01 d0                	add    %edx,%eax
c0101ab5:	c1 e0 02             	shl    $0x2,%eax
c0101ab8:	89 c2                	mov    %eax,%edx
c0101aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101abd:	01 d0                	add    %edx,%eax
c0101abf:	8b 10                	mov    (%eax),%edx
c0101ac1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101ac4:	01 c2                	add    %eax,%edx
c0101ac6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ac9:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0101acc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101acf:	89 c2                	mov    %eax,%edx
c0101ad1:	89 d0                	mov    %edx,%eax
c0101ad3:	01 c0                	add    %eax,%eax
c0101ad5:	01 d0                	add    %edx,%eax
c0101ad7:	c1 e0 02             	shl    $0x2,%eax
c0101ada:	89 c2                	mov    %eax,%edx
c0101adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101adf:	01 d0                	add    %edx,%eax
c0101ae1:	8b 50 08             	mov    0x8(%eax),%edx
c0101ae4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ae7:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0101aea:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101aed:	8b 40 10             	mov    0x10(%eax),%eax
c0101af0:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0101af3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101af6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0101af9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101afc:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101aff:	eb 15                	jmp    c0101b16 <debuginfo_eip+0x183>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0101b01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b04:	8b 55 08             	mov    0x8(%ebp),%edx
c0101b07:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c0101b0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101b0d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c0101b10:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101b13:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c0101b16:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b19:	8b 40 08             	mov    0x8(%eax),%eax
c0101b1c:	83 ec 08             	sub    $0x8,%esp
c0101b1f:	6a 3a                	push   $0x3a
c0101b21:	50                   	push   %eax
c0101b22:	e8 96 83 00 00       	call   c0109ebd <strfind>
c0101b27:	83 c4 10             	add    $0x10,%esp
c0101b2a:	89 c2                	mov    %eax,%edx
c0101b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b2f:	8b 40 08             	mov    0x8(%eax),%eax
c0101b32:	29 c2                	sub    %eax,%edx
c0101b34:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b37:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0101b3a:	83 ec 0c             	sub    $0xc,%esp
c0101b3d:	ff 75 08             	pushl  0x8(%ebp)
c0101b40:	6a 44                	push   $0x44
c0101b42:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0101b45:	50                   	push   %eax
c0101b46:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0101b49:	50                   	push   %eax
c0101b4a:	ff 75 f4             	pushl  -0xc(%ebp)
c0101b4d:	e8 ea fc ff ff       	call   c010183c <stab_binsearch>
c0101b52:	83 c4 20             	add    $0x20,%esp
    if (lline <= rline) {
c0101b55:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101b58:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0101b5b:	39 c2                	cmp    %eax,%edx
c0101b5d:	7f 24                	jg     c0101b83 <debuginfo_eip+0x1f0>
        info->eip_line = stabs[rline].n_desc;
c0101b5f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0101b62:	89 c2                	mov    %eax,%edx
c0101b64:	89 d0                	mov    %edx,%eax
c0101b66:	01 c0                	add    %eax,%eax
c0101b68:	01 d0                	add    %edx,%eax
c0101b6a:	c1 e0 02             	shl    $0x2,%eax
c0101b6d:	89 c2                	mov    %eax,%edx
c0101b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b72:	01 d0                	add    %edx,%eax
c0101b74:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0101b78:	0f b7 d0             	movzwl %ax,%edx
c0101b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b7e:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0101b81:	eb 13                	jmp    c0101b96 <debuginfo_eip+0x203>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c0101b83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101b88:	e9 12 01 00 00       	jmp    c0101c9f <debuginfo_eip+0x30c>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0101b8d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101b90:	83 e8 01             	sub    $0x1,%eax
c0101b93:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0101b96:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101b99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101b9c:	39 c2                	cmp    %eax,%edx
c0101b9e:	7c 56                	jl     c0101bf6 <debuginfo_eip+0x263>
           && stabs[lline].n_type != N_SOL
c0101ba0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101ba3:	89 c2                	mov    %eax,%edx
c0101ba5:	89 d0                	mov    %edx,%eax
c0101ba7:	01 c0                	add    %eax,%eax
c0101ba9:	01 d0                	add    %edx,%eax
c0101bab:	c1 e0 02             	shl    $0x2,%eax
c0101bae:	89 c2                	mov    %eax,%edx
c0101bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bb3:	01 d0                	add    %edx,%eax
c0101bb5:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101bb9:	3c 84                	cmp    $0x84,%al
c0101bbb:	74 39                	je     c0101bf6 <debuginfo_eip+0x263>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0101bbd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101bc0:	89 c2                	mov    %eax,%edx
c0101bc2:	89 d0                	mov    %edx,%eax
c0101bc4:	01 c0                	add    %eax,%eax
c0101bc6:	01 d0                	add    %edx,%eax
c0101bc8:	c1 e0 02             	shl    $0x2,%eax
c0101bcb:	89 c2                	mov    %eax,%edx
c0101bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bd0:	01 d0                	add    %edx,%eax
c0101bd2:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101bd6:	3c 64                	cmp    $0x64,%al
c0101bd8:	75 b3                	jne    c0101b8d <debuginfo_eip+0x1fa>
c0101bda:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101bdd:	89 c2                	mov    %eax,%edx
c0101bdf:	89 d0                	mov    %edx,%eax
c0101be1:	01 c0                	add    %eax,%eax
c0101be3:	01 d0                	add    %edx,%eax
c0101be5:	c1 e0 02             	shl    $0x2,%eax
c0101be8:	89 c2                	mov    %eax,%edx
c0101bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bed:	01 d0                	add    %edx,%eax
c0101bef:	8b 40 08             	mov    0x8(%eax),%eax
c0101bf2:	85 c0                	test   %eax,%eax
c0101bf4:	74 97                	je     c0101b8d <debuginfo_eip+0x1fa>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0101bf6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101bf9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101bfc:	39 c2                	cmp    %eax,%edx
c0101bfe:	7c 46                	jl     c0101c46 <debuginfo_eip+0x2b3>
c0101c00:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c03:	89 c2                	mov    %eax,%edx
c0101c05:	89 d0                	mov    %edx,%eax
c0101c07:	01 c0                	add    %eax,%eax
c0101c09:	01 d0                	add    %edx,%eax
c0101c0b:	c1 e0 02             	shl    $0x2,%eax
c0101c0e:	89 c2                	mov    %eax,%edx
c0101c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c13:	01 d0                	add    %edx,%eax
c0101c15:	8b 00                	mov    (%eax),%eax
c0101c17:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0101c1a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101c1d:	29 d1                	sub    %edx,%ecx
c0101c1f:	89 ca                	mov    %ecx,%edx
c0101c21:	39 d0                	cmp    %edx,%eax
c0101c23:	73 21                	jae    c0101c46 <debuginfo_eip+0x2b3>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0101c25:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c28:	89 c2                	mov    %eax,%edx
c0101c2a:	89 d0                	mov    %edx,%eax
c0101c2c:	01 c0                	add    %eax,%eax
c0101c2e:	01 d0                	add    %edx,%eax
c0101c30:	c1 e0 02             	shl    $0x2,%eax
c0101c33:	89 c2                	mov    %eax,%edx
c0101c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c38:	01 d0                	add    %edx,%eax
c0101c3a:	8b 10                	mov    (%eax),%edx
c0101c3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101c3f:	01 c2                	add    %eax,%edx
c0101c41:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c44:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0101c46:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101c49:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101c4c:	39 c2                	cmp    %eax,%edx
c0101c4e:	7d 4a                	jge    c0101c9a <debuginfo_eip+0x307>
        for (lline = lfun + 1;
c0101c50:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101c53:	83 c0 01             	add    $0x1,%eax
c0101c56:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0101c59:	eb 18                	jmp    c0101c73 <debuginfo_eip+0x2e0>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0101c5b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c5e:	8b 40 14             	mov    0x14(%eax),%eax
c0101c61:	8d 50 01             	lea    0x1(%eax),%edx
c0101c64:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c67:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0101c6a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c6d:	83 c0 01             	add    $0x1,%eax
c0101c70:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0101c73:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101c76:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0101c79:	39 c2                	cmp    %eax,%edx
c0101c7b:	7d 1d                	jge    c0101c9a <debuginfo_eip+0x307>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0101c7d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c80:	89 c2                	mov    %eax,%edx
c0101c82:	89 d0                	mov    %edx,%eax
c0101c84:	01 c0                	add    %eax,%eax
c0101c86:	01 d0                	add    %edx,%eax
c0101c88:	c1 e0 02             	shl    $0x2,%eax
c0101c8b:	89 c2                	mov    %eax,%edx
c0101c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c90:	01 d0                	add    %edx,%eax
c0101c92:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101c96:	3c a0                	cmp    $0xa0,%al
c0101c98:	74 c1                	je     c0101c5b <debuginfo_eip+0x2c8>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0101c9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101c9f:	c9                   	leave  
c0101ca0:	c3                   	ret    

c0101ca1 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0101ca1:	55                   	push   %ebp
c0101ca2:	89 e5                	mov    %esp,%ebp
c0101ca4:	83 ec 08             	sub    $0x8,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0101ca7:	83 ec 0c             	sub    $0xc,%esp
c0101caa:	68 3e ac 10 c0       	push   $0xc010ac3e
c0101caf:	e8 d6 e5 ff ff       	call   c010028a <cprintf>
c0101cb4:	83 c4 10             	add    $0x10,%esp
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0101cb7:	83 ec 08             	sub    $0x8,%esp
c0101cba:	68 36 00 10 c0       	push   $0xc0100036
c0101cbf:	68 57 ac 10 c0       	push   $0xc010ac57
c0101cc4:	e8 c1 e5 ff ff       	call   c010028a <cprintf>
c0101cc9:	83 c4 10             	add    $0x10,%esp
    cprintf("  etext  0x%08x (phys)\n", etext);
c0101ccc:	83 ec 08             	sub    $0x8,%esp
c0101ccf:	68 dd a8 10 c0       	push   $0xc010a8dd
c0101cd4:	68 6f ac 10 c0       	push   $0xc010ac6f
c0101cd9:	e8 ac e5 ff ff       	call   c010028a <cprintf>
c0101cde:	83 c4 10             	add    $0x10,%esp
    cprintf("  edata  0x%08x (phys)\n", edata);
c0101ce1:	83 ec 08             	sub    $0x8,%esp
c0101ce4:	68 00 a0 12 c0       	push   $0xc012a000
c0101ce9:	68 87 ac 10 c0       	push   $0xc010ac87
c0101cee:	e8 97 e5 ff ff       	call   c010028a <cprintf>
c0101cf3:	83 c4 10             	add    $0x10,%esp
    cprintf("  end    0x%08x (phys)\n", end);
c0101cf6:	83 ec 08             	sub    $0x8,%esp
c0101cf9:	68 4c d1 12 c0       	push   $0xc012d14c
c0101cfe:	68 9f ac 10 c0       	push   $0xc010ac9f
c0101d03:	e8 82 e5 ff ff       	call   c010028a <cprintf>
c0101d08:	83 c4 10             	add    $0x10,%esp
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c0101d0b:	b8 4c d1 12 c0       	mov    $0xc012d14c,%eax
c0101d10:	05 ff 03 00 00       	add    $0x3ff,%eax
c0101d15:	ba 36 00 10 c0       	mov    $0xc0100036,%edx
c0101d1a:	29 d0                	sub    %edx,%eax
c0101d1c:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0101d22:	85 c0                	test   %eax,%eax
c0101d24:	0f 48 c2             	cmovs  %edx,%eax
c0101d27:	c1 f8 0a             	sar    $0xa,%eax
c0101d2a:	83 ec 08             	sub    $0x8,%esp
c0101d2d:	50                   	push   %eax
c0101d2e:	68 b8 ac 10 c0       	push   $0xc010acb8
c0101d33:	e8 52 e5 ff ff       	call   c010028a <cprintf>
c0101d38:	83 c4 10             	add    $0x10,%esp
}
c0101d3b:	90                   	nop
c0101d3c:	c9                   	leave  
c0101d3d:	c3                   	ret    

c0101d3e <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0101d3e:	55                   	push   %ebp
c0101d3f:	89 e5                	mov    %esp,%ebp
c0101d41:	81 ec 28 01 00 00    	sub    $0x128,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0101d47:	83 ec 08             	sub    $0x8,%esp
c0101d4a:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0101d4d:	50                   	push   %eax
c0101d4e:	ff 75 08             	pushl  0x8(%ebp)
c0101d51:	e8 3d fc ff ff       	call   c0101993 <debuginfo_eip>
c0101d56:	83 c4 10             	add    $0x10,%esp
c0101d59:	85 c0                	test   %eax,%eax
c0101d5b:	74 15                	je     c0101d72 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0101d5d:	83 ec 08             	sub    $0x8,%esp
c0101d60:	ff 75 08             	pushl  0x8(%ebp)
c0101d63:	68 e2 ac 10 c0       	push   $0xc010ace2
c0101d68:	e8 1d e5 ff ff       	call   c010028a <cprintf>
c0101d6d:	83 c4 10             	add    $0x10,%esp
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0101d70:	eb 65                	jmp    c0101dd7 <print_debuginfo+0x99>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0101d72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101d79:	eb 1c                	jmp    c0101d97 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c0101d7b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0101d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101d81:	01 d0                	add    %edx,%eax
c0101d83:	0f b6 00             	movzbl (%eax),%eax
c0101d86:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0101d8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101d8f:	01 ca                	add    %ecx,%edx
c0101d91:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0101d93:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101d97:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101d9a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0101d9d:	7f dc                	jg     c0101d7b <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0101d9f:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0101da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101da8:	01 d0                	add    %edx,%eax
c0101daa:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0101dad:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0101db0:	8b 55 08             	mov    0x8(%ebp),%edx
c0101db3:	89 d1                	mov    %edx,%ecx
c0101db5:	29 c1                	sub    %eax,%ecx
c0101db7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0101dba:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101dbd:	83 ec 0c             	sub    $0xc,%esp
c0101dc0:	51                   	push   %ecx
c0101dc1:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0101dc7:	51                   	push   %ecx
c0101dc8:	52                   	push   %edx
c0101dc9:	50                   	push   %eax
c0101dca:	68 fe ac 10 c0       	push   $0xc010acfe
c0101dcf:	e8 b6 e4 ff ff       	call   c010028a <cprintf>
c0101dd4:	83 c4 20             	add    $0x20,%esp
                fnname, eip - info.eip_fn_addr);
    }
}
c0101dd7:	90                   	nop
c0101dd8:	c9                   	leave  
c0101dd9:	c3                   	ret    

c0101dda <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0101dda:	55                   	push   %ebp
c0101ddb:	89 e5                	mov    %esp,%ebp
c0101ddd:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0101de0:	8b 45 04             	mov    0x4(%ebp),%eax
c0101de3:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0101de6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101de9:	c9                   	leave  
c0101dea:	c3                   	ret    

c0101deb <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0101deb:	55                   	push   %ebp
c0101dec:	89 e5                	mov    %esp,%ebp
c0101dee:	83 ec 28             	sub    $0x28,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0101df1:	89 e8                	mov    %ebp,%eax
c0101df3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0101df6:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c0101df9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101dfc:	e8 d9 ff ff ff       	call   c0101dda <read_eip>
c0101e01:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0101e04:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101e0b:	e9 8d 00 00 00       	jmp    c0101e9d <print_stackframe+0xb2>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0101e10:	83 ec 04             	sub    $0x4,%esp
c0101e13:	ff 75 f0             	pushl  -0x10(%ebp)
c0101e16:	ff 75 f4             	pushl  -0xc(%ebp)
c0101e19:	68 10 ad 10 c0       	push   $0xc010ad10
c0101e1e:	e8 67 e4 ff ff       	call   c010028a <cprintf>
c0101e23:	83 c4 10             	add    $0x10,%esp
        uint32_t *args = (uint32_t *)ebp + 2;
c0101e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101e29:	83 c0 08             	add    $0x8,%eax
c0101e2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0101e2f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0101e36:	eb 26                	jmp    c0101e5e <print_stackframe+0x73>
            cprintf("0x%08x ", args[j]);
c0101e38:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101e3b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101e42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101e45:	01 d0                	add    %edx,%eax
c0101e47:	8b 00                	mov    (%eax),%eax
c0101e49:	83 ec 08             	sub    $0x8,%esp
c0101e4c:	50                   	push   %eax
c0101e4d:	68 2c ad 10 c0       	push   $0xc010ad2c
c0101e52:	e8 33 e4 ff ff       	call   c010028a <cprintf>
c0101e57:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
c0101e5a:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0101e5e:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0101e62:	7e d4                	jle    c0101e38 <print_stackframe+0x4d>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
c0101e64:	83 ec 0c             	sub    $0xc,%esp
c0101e67:	68 34 ad 10 c0       	push   $0xc010ad34
c0101e6c:	e8 19 e4 ff ff       	call   c010028a <cprintf>
c0101e71:	83 c4 10             	add    $0x10,%esp
        print_debuginfo(eip - 1);
c0101e74:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101e77:	83 e8 01             	sub    $0x1,%eax
c0101e7a:	83 ec 0c             	sub    $0xc,%esp
c0101e7d:	50                   	push   %eax
c0101e7e:	e8 bb fe ff ff       	call   c0101d3e <print_debuginfo>
c0101e83:	83 c4 10             	add    $0x10,%esp
        eip = ((uint32_t *)ebp)[1];
c0101e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101e89:	83 c0 04             	add    $0x4,%eax
c0101e8c:	8b 00                	mov    (%eax),%eax
c0101e8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0101e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101e94:	8b 00                	mov    (%eax),%eax
c0101e96:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0101e99:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0101e9d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101ea1:	74 0a                	je     c0101ead <print_stackframe+0xc2>
c0101ea3:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0101ea7:	0f 8e 63 ff ff ff    	jle    c0101e10 <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
c0101ead:	90                   	nop
c0101eae:	c9                   	leave  
c0101eaf:	c3                   	ret    

c0101eb0 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0101eb0:	55                   	push   %ebp
c0101eb1:	89 e5                	mov    %esp,%ebp
c0101eb3:	83 ec 18             	sub    $0x18,%esp
    int argc = 0;
c0101eb6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0101ebd:	eb 0c                	jmp    c0101ecb <parse+0x1b>
            *buf ++ = '\0';
c0101ebf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ec2:	8d 50 01             	lea    0x1(%eax),%edx
c0101ec5:	89 55 08             	mov    %edx,0x8(%ebp)
c0101ec8:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0101ecb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ece:	0f b6 00             	movzbl (%eax),%eax
c0101ed1:	84 c0                	test   %al,%al
c0101ed3:	74 1e                	je     c0101ef3 <parse+0x43>
c0101ed5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ed8:	0f b6 00             	movzbl (%eax),%eax
c0101edb:	0f be c0             	movsbl %al,%eax
c0101ede:	83 ec 08             	sub    $0x8,%esp
c0101ee1:	50                   	push   %eax
c0101ee2:	68 b8 ad 10 c0       	push   $0xc010adb8
c0101ee7:	e8 9e 7f 00 00       	call   c0109e8a <strchr>
c0101eec:	83 c4 10             	add    $0x10,%esp
c0101eef:	85 c0                	test   %eax,%eax
c0101ef1:	75 cc                	jne    c0101ebf <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0101ef3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ef6:	0f b6 00             	movzbl (%eax),%eax
c0101ef9:	84 c0                	test   %al,%al
c0101efb:	74 69                	je     c0101f66 <parse+0xb6>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0101efd:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0101f01:	75 12                	jne    c0101f15 <parse+0x65>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0101f03:	83 ec 08             	sub    $0x8,%esp
c0101f06:	6a 10                	push   $0x10
c0101f08:	68 bd ad 10 c0       	push   $0xc010adbd
c0101f0d:	e8 78 e3 ff ff       	call   c010028a <cprintf>
c0101f12:	83 c4 10             	add    $0x10,%esp
        }
        argv[argc ++] = buf;
c0101f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101f18:	8d 50 01             	lea    0x1(%eax),%edx
c0101f1b:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0101f1e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101f25:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f28:	01 c2                	add    %eax,%edx
c0101f2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f2d:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0101f2f:	eb 04                	jmp    c0101f35 <parse+0x85>
            buf ++;
c0101f31:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0101f35:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f38:	0f b6 00             	movzbl (%eax),%eax
c0101f3b:	84 c0                	test   %al,%al
c0101f3d:	0f 84 7a ff ff ff    	je     c0101ebd <parse+0xd>
c0101f43:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f46:	0f b6 00             	movzbl (%eax),%eax
c0101f49:	0f be c0             	movsbl %al,%eax
c0101f4c:	83 ec 08             	sub    $0x8,%esp
c0101f4f:	50                   	push   %eax
c0101f50:	68 b8 ad 10 c0       	push   $0xc010adb8
c0101f55:	e8 30 7f 00 00       	call   c0109e8a <strchr>
c0101f5a:	83 c4 10             	add    $0x10,%esp
c0101f5d:	85 c0                	test   %eax,%eax
c0101f5f:	74 d0                	je     c0101f31 <parse+0x81>
            buf ++;
        }
    }
c0101f61:	e9 57 ff ff ff       	jmp    c0101ebd <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
c0101f66:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0101f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f6a:	c9                   	leave  
c0101f6b:	c3                   	ret    

c0101f6c <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0101f6c:	55                   	push   %ebp
c0101f6d:	89 e5                	mov    %esp,%ebp
c0101f6f:	83 ec 58             	sub    $0x58,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0101f72:	83 ec 08             	sub    $0x8,%esp
c0101f75:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0101f78:	50                   	push   %eax
c0101f79:	ff 75 08             	pushl  0x8(%ebp)
c0101f7c:	e8 2f ff ff ff       	call   c0101eb0 <parse>
c0101f81:	83 c4 10             	add    $0x10,%esp
c0101f84:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0101f87:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0101f8b:	75 0a                	jne    c0101f97 <runcmd+0x2b>
        return 0;
c0101f8d:	b8 00 00 00 00       	mov    $0x0,%eax
c0101f92:	e9 83 00 00 00       	jmp    c010201a <runcmd+0xae>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0101f97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101f9e:	eb 59                	jmp    c0101ff9 <runcmd+0x8d>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0101fa0:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0101fa3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101fa6:	89 d0                	mov    %edx,%eax
c0101fa8:	01 c0                	add    %eax,%eax
c0101faa:	01 d0                	add    %edx,%eax
c0101fac:	c1 e0 02             	shl    $0x2,%eax
c0101faf:	05 00 70 12 c0       	add    $0xc0127000,%eax
c0101fb4:	8b 00                	mov    (%eax),%eax
c0101fb6:	83 ec 08             	sub    $0x8,%esp
c0101fb9:	51                   	push   %ecx
c0101fba:	50                   	push   %eax
c0101fbb:	e8 2a 7e 00 00       	call   c0109dea <strcmp>
c0101fc0:	83 c4 10             	add    $0x10,%esp
c0101fc3:	85 c0                	test   %eax,%eax
c0101fc5:	75 2e                	jne    c0101ff5 <runcmd+0x89>
            return commands[i].func(argc - 1, argv + 1, tf);
c0101fc7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101fca:	89 d0                	mov    %edx,%eax
c0101fcc:	01 c0                	add    %eax,%eax
c0101fce:	01 d0                	add    %edx,%eax
c0101fd0:	c1 e0 02             	shl    $0x2,%eax
c0101fd3:	05 08 70 12 c0       	add    $0xc0127008,%eax
c0101fd8:	8b 10                	mov    (%eax),%edx
c0101fda:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0101fdd:	83 c0 04             	add    $0x4,%eax
c0101fe0:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0101fe3:	83 e9 01             	sub    $0x1,%ecx
c0101fe6:	83 ec 04             	sub    $0x4,%esp
c0101fe9:	ff 75 0c             	pushl  0xc(%ebp)
c0101fec:	50                   	push   %eax
c0101fed:	51                   	push   %ecx
c0101fee:	ff d2                	call   *%edx
c0101ff0:	83 c4 10             	add    $0x10,%esp
c0101ff3:	eb 25                	jmp    c010201a <runcmd+0xae>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0101ff5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ffc:	83 f8 02             	cmp    $0x2,%eax
c0101fff:	76 9f                	jbe    c0101fa0 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0102001:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102004:	83 ec 08             	sub    $0x8,%esp
c0102007:	50                   	push   %eax
c0102008:	68 db ad 10 c0       	push   $0xc010addb
c010200d:	e8 78 e2 ff ff       	call   c010028a <cprintf>
c0102012:	83 c4 10             	add    $0x10,%esp
    return 0;
c0102015:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010201a:	c9                   	leave  
c010201b:	c3                   	ret    

c010201c <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c010201c:	55                   	push   %ebp
c010201d:	89 e5                	mov    %esp,%ebp
c010201f:	83 ec 18             	sub    $0x18,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0102022:	83 ec 0c             	sub    $0xc,%esp
c0102025:	68 f4 ad 10 c0       	push   $0xc010adf4
c010202a:	e8 5b e2 ff ff       	call   c010028a <cprintf>
c010202f:	83 c4 10             	add    $0x10,%esp
    cprintf("Type 'help' for a list of commands.\n");
c0102032:	83 ec 0c             	sub    $0xc,%esp
c0102035:	68 1c ae 10 c0       	push   $0xc010ae1c
c010203a:	e8 4b e2 ff ff       	call   c010028a <cprintf>
c010203f:	83 c4 10             	add    $0x10,%esp

    if (tf != NULL) {
c0102042:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102046:	74 0e                	je     c0102056 <kmonitor+0x3a>
        print_trapframe(tf);
c0102048:	83 ec 0c             	sub    $0xc,%esp
c010204b:	ff 75 08             	pushl  0x8(%ebp)
c010204e:	e8 52 15 00 00       	call   c01035a5 <print_trapframe>
c0102053:	83 c4 10             	add    $0x10,%esp
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0102056:	83 ec 0c             	sub    $0xc,%esp
c0102059:	68 41 ae 10 c0       	push   $0xc010ae41
c010205e:	e8 43 f6 ff ff       	call   c01016a6 <readline>
c0102063:	83 c4 10             	add    $0x10,%esp
c0102066:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102069:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010206d:	74 e7                	je     c0102056 <kmonitor+0x3a>
            if (runcmd(buf, tf) < 0) {
c010206f:	83 ec 08             	sub    $0x8,%esp
c0102072:	ff 75 08             	pushl  0x8(%ebp)
c0102075:	ff 75 f4             	pushl  -0xc(%ebp)
c0102078:	e8 ef fe ff ff       	call   c0101f6c <runcmd>
c010207d:	83 c4 10             	add    $0x10,%esp
c0102080:	85 c0                	test   %eax,%eax
c0102082:	78 02                	js     c0102086 <kmonitor+0x6a>
                break;
            }
        }
    }
c0102084:	eb d0                	jmp    c0102056 <kmonitor+0x3a>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
c0102086:	90                   	nop
            }
        }
    }
}
c0102087:	90                   	nop
c0102088:	c9                   	leave  
c0102089:	c3                   	ret    

c010208a <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c010208a:	55                   	push   %ebp
c010208b:	89 e5                	mov    %esp,%ebp
c010208d:	83 ec 18             	sub    $0x18,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0102090:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102097:	eb 3c                	jmp    c01020d5 <mon_help+0x4b>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0102099:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010209c:	89 d0                	mov    %edx,%eax
c010209e:	01 c0                	add    %eax,%eax
c01020a0:	01 d0                	add    %edx,%eax
c01020a2:	c1 e0 02             	shl    $0x2,%eax
c01020a5:	05 04 70 12 c0       	add    $0xc0127004,%eax
c01020aa:	8b 08                	mov    (%eax),%ecx
c01020ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01020af:	89 d0                	mov    %edx,%eax
c01020b1:	01 c0                	add    %eax,%eax
c01020b3:	01 d0                	add    %edx,%eax
c01020b5:	c1 e0 02             	shl    $0x2,%eax
c01020b8:	05 00 70 12 c0       	add    $0xc0127000,%eax
c01020bd:	8b 00                	mov    (%eax),%eax
c01020bf:	83 ec 04             	sub    $0x4,%esp
c01020c2:	51                   	push   %ecx
c01020c3:	50                   	push   %eax
c01020c4:	68 45 ae 10 c0       	push   $0xc010ae45
c01020c9:	e8 bc e1 ff ff       	call   c010028a <cprintf>
c01020ce:	83 c4 10             	add    $0x10,%esp

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c01020d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01020d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01020d8:	83 f8 02             	cmp    $0x2,%eax
c01020db:	76 bc                	jbe    c0102099 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c01020dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01020e2:	c9                   	leave  
c01020e3:	c3                   	ret    

c01020e4 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c01020e4:	55                   	push   %ebp
c01020e5:	89 e5                	mov    %esp,%ebp
c01020e7:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c01020ea:	e8 b2 fb ff ff       	call   c0101ca1 <print_kerninfo>
    return 0;
c01020ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01020f4:	c9                   	leave  
c01020f5:	c3                   	ret    

c01020f6 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c01020f6:	55                   	push   %ebp
c01020f7:	89 e5                	mov    %esp,%ebp
c01020f9:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c01020fc:	e8 ea fc ff ff       	call   c0101deb <print_stackframe>
    return 0;
c0102101:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102106:	c9                   	leave  
c0102107:	c3                   	ret    

c0102108 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0102108:	55                   	push   %ebp
c0102109:	89 e5                	mov    %esp,%ebp
c010210b:	83 ec 14             	sub    $0x14,%esp
c010210e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102111:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0102115:	90                   	nop
c0102116:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010211a:	83 c0 07             	add    $0x7,%eax
c010211d:	0f b7 c0             	movzwl %ax,%eax
c0102120:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102124:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0102128:	89 c2                	mov    %eax,%edx
c010212a:	ec                   	in     (%dx),%al
c010212b:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010212e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102132:	0f b6 c0             	movzbl %al,%eax
c0102135:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0102138:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010213b:	25 80 00 00 00       	and    $0x80,%eax
c0102140:	85 c0                	test   %eax,%eax
c0102142:	75 d2                	jne    c0102116 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0102144:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102148:	74 11                	je     c010215b <ide_wait_ready+0x53>
c010214a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010214d:	83 e0 21             	and    $0x21,%eax
c0102150:	85 c0                	test   %eax,%eax
c0102152:	74 07                	je     c010215b <ide_wait_ready+0x53>
        return -1;
c0102154:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0102159:	eb 05                	jmp    c0102160 <ide_wait_ready+0x58>
    }
    return 0;
c010215b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102160:	c9                   	leave  
c0102161:	c3                   	ret    

c0102162 <ide_init>:

void
ide_init(void) {
c0102162:	55                   	push   %ebp
c0102163:	89 e5                	mov    %esp,%ebp
c0102165:	57                   	push   %edi
c0102166:	53                   	push   %ebx
c0102167:	81 ec 40 02 00 00    	sub    $0x240,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c010216d:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0102173:	e9 c1 02 00 00       	jmp    c0102439 <ide_init+0x2d7>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0102178:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010217c:	c1 e0 03             	shl    $0x3,%eax
c010217f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102186:	29 c2                	sub    %eax,%edx
c0102188:	89 d0                	mov    %edx,%eax
c010218a:	05 40 a4 12 c0       	add    $0xc012a440,%eax
c010218f:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0102192:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102196:	66 d1 e8             	shr    %ax
c0102199:	0f b7 c0             	movzwl %ax,%eax
c010219c:	0f b7 04 85 50 ae 10 	movzwl -0x3fef51b0(,%eax,4),%eax
c01021a3:	c0 
c01021a4:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c01021a8:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01021ac:	6a 00                	push   $0x0
c01021ae:	50                   	push   %eax
c01021af:	e8 54 ff ff ff       	call   c0102108 <ide_wait_ready>
c01021b4:	83 c4 08             	add    $0x8,%esp

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c01021b7:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01021bb:	83 e0 01             	and    $0x1,%eax
c01021be:	c1 e0 04             	shl    $0x4,%eax
c01021c1:	83 c8 e0             	or     $0xffffffe0,%eax
c01021c4:	0f b6 c0             	movzbl %al,%eax
c01021c7:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01021cb:	83 c2 06             	add    $0x6,%edx
c01021ce:	0f b7 d2             	movzwl %dx,%edx
c01021d1:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01021d5:	88 45 c7             	mov    %al,-0x39(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021d8:	0f b6 45 c7          	movzbl -0x39(%ebp),%eax
c01021dc:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01021e0:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01021e1:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01021e5:	6a 00                	push   $0x0
c01021e7:	50                   	push   %eax
c01021e8:	e8 1b ff ff ff       	call   c0102108 <ide_wait_ready>
c01021ed:	83 c4 08             	add    $0x8,%esp

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c01021f0:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01021f4:	83 c0 07             	add    $0x7,%eax
c01021f7:	0f b7 c0             	movzwl %ax,%eax
c01021fa:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
c01021fe:	c6 45 c8 ec          	movb   $0xec,-0x38(%ebp)
c0102202:	0f b6 45 c8          	movzbl -0x38(%ebp),%eax
c0102206:	0f b7 55 e0          	movzwl -0x20(%ebp),%edx
c010220a:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c010220b:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010220f:	6a 00                	push   $0x0
c0102211:	50                   	push   %eax
c0102212:	e8 f1 fe ff ff       	call   c0102108 <ide_wait_ready>
c0102217:	83 c4 08             	add    $0x8,%esp

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c010221a:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010221e:	83 c0 07             	add    $0x7,%eax
c0102221:	0f b7 c0             	movzwl %ax,%eax
c0102224:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102228:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c010222c:	89 c2                	mov    %eax,%edx
c010222e:	ec                   	in     (%dx),%al
c010222f:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0102232:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0102236:	84 c0                	test   %al,%al
c0102238:	0f 84 ef 01 00 00    	je     c010242d <ide_init+0x2cb>
c010223e:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102242:	6a 01                	push   $0x1
c0102244:	50                   	push   %eax
c0102245:	e8 be fe ff ff       	call   c0102108 <ide_wait_ready>
c010224a:	83 c4 08             	add    $0x8,%esp
c010224d:	85 c0                	test   %eax,%eax
c010224f:	0f 85 d8 01 00 00    	jne    c010242d <ide_init+0x2cb>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0102255:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102259:	c1 e0 03             	shl    $0x3,%eax
c010225c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102263:	29 c2                	sub    %eax,%edx
c0102265:	89 d0                	mov    %edx,%eax
c0102267:	05 40 a4 12 c0       	add    $0xc012a440,%eax
c010226c:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c010226f:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102273:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0102276:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c010227c:	89 45 c0             	mov    %eax,-0x40(%ebp)
c010227f:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0102286:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102289:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c010228c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010228f:	89 cb                	mov    %ecx,%ebx
c0102291:	89 df                	mov    %ebx,%edi
c0102293:	89 c1                	mov    %eax,%ecx
c0102295:	fc                   	cld    
c0102296:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0102298:	89 c8                	mov    %ecx,%eax
c010229a:	89 fb                	mov    %edi,%ebx
c010229c:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c010229f:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c01022a2:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c01022a8:	89 45 dc             	mov    %eax,-0x24(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c01022ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01022ae:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c01022b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c01022b7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01022ba:	25 00 00 00 04       	and    $0x4000000,%eax
c01022bf:	85 c0                	test   %eax,%eax
c01022c1:	74 0e                	je     c01022d1 <ide_init+0x16f>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c01022c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01022c6:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c01022cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01022cf:	eb 09                	jmp    c01022da <ide_init+0x178>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c01022d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01022d4:	8b 40 78             	mov    0x78(%eax),%eax
c01022d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c01022da:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01022de:	c1 e0 03             	shl    $0x3,%eax
c01022e1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01022e8:	29 c2                	sub    %eax,%edx
c01022ea:	89 d0                	mov    %edx,%eax
c01022ec:	8d 90 44 a4 12 c0    	lea    -0x3fed5bbc(%eax),%edx
c01022f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01022f5:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c01022f7:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01022fb:	c1 e0 03             	shl    $0x3,%eax
c01022fe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102305:	29 c2                	sub    %eax,%edx
c0102307:	89 d0                	mov    %edx,%eax
c0102309:	8d 90 48 a4 12 c0    	lea    -0x3fed5bb8(%eax),%edx
c010230f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102312:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0102314:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102317:	83 c0 62             	add    $0x62,%eax
c010231a:	0f b7 00             	movzwl (%eax),%eax
c010231d:	0f b7 c0             	movzwl %ax,%eax
c0102320:	25 00 02 00 00       	and    $0x200,%eax
c0102325:	85 c0                	test   %eax,%eax
c0102327:	75 16                	jne    c010233f <ide_init+0x1dd>
c0102329:	68 58 ae 10 c0       	push   $0xc010ae58
c010232e:	68 9b ae 10 c0       	push   $0xc010ae9b
c0102333:	6a 7d                	push   $0x7d
c0102335:	68 b0 ae 10 c0       	push   $0xc010aeb0
c010233a:	e8 29 f4 ff ff       	call   c0101768 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c010233f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102343:	89 c2                	mov    %eax,%edx
c0102345:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
c010234c:	89 c2                	mov    %eax,%edx
c010234e:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
c0102355:	29 d0                	sub    %edx,%eax
c0102357:	05 40 a4 12 c0       	add    $0xc012a440,%eax
c010235c:	83 c0 0c             	add    $0xc,%eax
c010235f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0102362:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102365:	83 c0 36             	add    $0x36,%eax
c0102368:	89 45 d0             	mov    %eax,-0x30(%ebp)
        unsigned int i, length = 40;
c010236b:	c7 45 cc 28 00 00 00 	movl   $0x28,-0x34(%ebp)
        for (i = 0; i < length; i += 2) {
c0102372:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102379:	eb 34                	jmp    c01023af <ide_init+0x24d>
            model[i] = data[i + 1], model[i + 1] = data[i];
c010237b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010237e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102381:	01 c2                	add    %eax,%edx
c0102383:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102386:	8d 48 01             	lea    0x1(%eax),%ecx
c0102389:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010238c:	01 c8                	add    %ecx,%eax
c010238e:	0f b6 00             	movzbl (%eax),%eax
c0102391:	88 02                	mov    %al,(%edx)
c0102393:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102396:	8d 50 01             	lea    0x1(%eax),%edx
c0102399:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010239c:	01 c2                	add    %eax,%edx
c010239e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01023a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01023a4:	01 c8                	add    %ecx,%eax
c01023a6:	0f b6 00             	movzbl (%eax),%eax
c01023a9:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c01023ab:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c01023af:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01023b2:	3b 45 cc             	cmp    -0x34(%ebp),%eax
c01023b5:	72 c4                	jb     c010237b <ide_init+0x219>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c01023b7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01023ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01023bd:	01 d0                	add    %edx,%eax
c01023bf:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c01023c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01023c5:	8d 50 ff             	lea    -0x1(%eax),%edx
c01023c8:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01023cb:	85 c0                	test   %eax,%eax
c01023cd:	74 0f                	je     c01023de <ide_init+0x27c>
c01023cf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01023d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01023d5:	01 d0                	add    %edx,%eax
c01023d7:	0f b6 00             	movzbl (%eax),%eax
c01023da:	3c 20                	cmp    $0x20,%al
c01023dc:	74 d9                	je     c01023b7 <ide_init+0x255>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c01023de:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01023e2:	89 c2                	mov    %eax,%edx
c01023e4:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
c01023eb:	89 c2                	mov    %eax,%edx
c01023ed:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
c01023f4:	29 d0                	sub    %edx,%eax
c01023f6:	05 40 a4 12 c0       	add    $0xc012a440,%eax
c01023fb:	8d 48 0c             	lea    0xc(%eax),%ecx
c01023fe:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102402:	c1 e0 03             	shl    $0x3,%eax
c0102405:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010240c:	29 c2                	sub    %eax,%edx
c010240e:	89 d0                	mov    %edx,%eax
c0102410:	05 48 a4 12 c0       	add    $0xc012a448,%eax
c0102415:	8b 10                	mov    (%eax),%edx
c0102417:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010241b:	51                   	push   %ecx
c010241c:	52                   	push   %edx
c010241d:	50                   	push   %eax
c010241e:	68 c2 ae 10 c0       	push   $0xc010aec2
c0102423:	e8 62 de ff ff       	call   c010028a <cprintf>
c0102428:	83 c4 10             	add    $0x10,%esp
c010242b:	eb 01                	jmp    c010242e <ide_init+0x2cc>
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
        ide_wait_ready(iobase, 0);

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
            continue ;
c010242d:	90                   	nop

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c010242e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102432:	83 c0 01             	add    $0x1,%eax
c0102435:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0102439:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c010243e:	0f 86 34 fd ff ff    	jbe    c0102178 <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0102444:	83 ec 0c             	sub    $0xc,%esp
c0102447:	6a 0e                	push   $0xe
c0102449:	e8 8a 0e 00 00       	call   c01032d8 <pic_enable>
c010244e:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_IDE2);
c0102451:	83 ec 0c             	sub    $0xc,%esp
c0102454:	6a 0f                	push   $0xf
c0102456:	e8 7d 0e 00 00       	call   c01032d8 <pic_enable>
c010245b:	83 c4 10             	add    $0x10,%esp
}
c010245e:	90                   	nop
c010245f:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0102462:	5b                   	pop    %ebx
c0102463:	5f                   	pop    %edi
c0102464:	5d                   	pop    %ebp
c0102465:	c3                   	ret    

c0102466 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0102466:	55                   	push   %ebp
c0102467:	89 e5                	mov    %esp,%ebp
c0102469:	83 ec 04             	sub    $0x4,%esp
c010246c:	8b 45 08             	mov    0x8(%ebp),%eax
c010246f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0102473:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c0102478:	77 25                	ja     c010249f <ide_device_valid+0x39>
c010247a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c010247e:	c1 e0 03             	shl    $0x3,%eax
c0102481:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102488:	29 c2                	sub    %eax,%edx
c010248a:	89 d0                	mov    %edx,%eax
c010248c:	05 40 a4 12 c0       	add    $0xc012a440,%eax
c0102491:	0f b6 00             	movzbl (%eax),%eax
c0102494:	84 c0                	test   %al,%al
c0102496:	74 07                	je     c010249f <ide_device_valid+0x39>
c0102498:	b8 01 00 00 00       	mov    $0x1,%eax
c010249d:	eb 05                	jmp    c01024a4 <ide_device_valid+0x3e>
c010249f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01024a4:	c9                   	leave  
c01024a5:	c3                   	ret    

c01024a6 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c01024a6:	55                   	push   %ebp
c01024a7:	89 e5                	mov    %esp,%ebp
c01024a9:	83 ec 04             	sub    $0x4,%esp
c01024ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01024af:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c01024b3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c01024b7:	50                   	push   %eax
c01024b8:	e8 a9 ff ff ff       	call   c0102466 <ide_device_valid>
c01024bd:	83 c4 04             	add    $0x4,%esp
c01024c0:	85 c0                	test   %eax,%eax
c01024c2:	74 1b                	je     c01024df <ide_device_size+0x39>
        return ide_devices[ideno].size;
c01024c4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c01024c8:	c1 e0 03             	shl    $0x3,%eax
c01024cb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01024d2:	29 c2                	sub    %eax,%edx
c01024d4:	89 d0                	mov    %edx,%eax
c01024d6:	05 48 a4 12 c0       	add    $0xc012a448,%eax
c01024db:	8b 00                	mov    (%eax),%eax
c01024dd:	eb 05                	jmp    c01024e4 <ide_device_size+0x3e>
    }
    return 0;
c01024df:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01024e4:	c9                   	leave  
c01024e5:	c3                   	ret    

c01024e6 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c01024e6:	55                   	push   %ebp
c01024e7:	89 e5                	mov    %esp,%ebp
c01024e9:	57                   	push   %edi
c01024ea:	53                   	push   %ebx
c01024eb:	83 ec 40             	sub    $0x40,%esp
c01024ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01024f1:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01024f5:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01024fc:	77 25                	ja     c0102523 <ide_read_secs+0x3d>
c01024fe:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0102503:	77 1e                	ja     c0102523 <ide_read_secs+0x3d>
c0102505:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0102509:	c1 e0 03             	shl    $0x3,%eax
c010250c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102513:	29 c2                	sub    %eax,%edx
c0102515:	89 d0                	mov    %edx,%eax
c0102517:	05 40 a4 12 c0       	add    $0xc012a440,%eax
c010251c:	0f b6 00             	movzbl (%eax),%eax
c010251f:	84 c0                	test   %al,%al
c0102521:	75 19                	jne    c010253c <ide_read_secs+0x56>
c0102523:	68 e0 ae 10 c0       	push   $0xc010aee0
c0102528:	68 9b ae 10 c0       	push   $0xc010ae9b
c010252d:	68 9f 00 00 00       	push   $0x9f
c0102532:	68 b0 ae 10 c0       	push   $0xc010aeb0
c0102537:	e8 2c f2 ff ff       	call   c0101768 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c010253c:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0102543:	77 0f                	ja     c0102554 <ide_read_secs+0x6e>
c0102545:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102548:	8b 45 14             	mov    0x14(%ebp),%eax
c010254b:	01 d0                	add    %edx,%eax
c010254d:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0102552:	76 19                	jbe    c010256d <ide_read_secs+0x87>
c0102554:	68 08 af 10 c0       	push   $0xc010af08
c0102559:	68 9b ae 10 c0       	push   $0xc010ae9b
c010255e:	68 a0 00 00 00       	push   $0xa0
c0102563:	68 b0 ae 10 c0       	push   $0xc010aeb0
c0102568:	e8 fb f1 ff ff       	call   c0101768 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c010256d:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0102571:	66 d1 e8             	shr    %ax
c0102574:	0f b7 c0             	movzwl %ax,%eax
c0102577:	0f b7 04 85 50 ae 10 	movzwl -0x3fef51b0(,%eax,4),%eax
c010257e:	c0 
c010257f:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0102583:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0102587:	66 d1 e8             	shr    %ax
c010258a:	0f b7 c0             	movzwl %ax,%eax
c010258d:	0f b7 04 85 52 ae 10 	movzwl -0x3fef51ae(,%eax,4),%eax
c0102594:	c0 
c0102595:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0102599:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010259d:	83 ec 08             	sub    $0x8,%esp
c01025a0:	6a 00                	push   $0x0
c01025a2:	50                   	push   %eax
c01025a3:	e8 60 fb ff ff       	call   c0102108 <ide_wait_ready>
c01025a8:	83 c4 10             	add    $0x10,%esp

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c01025ab:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01025af:	83 c0 02             	add    $0x2,%eax
c01025b2:	0f b7 c0             	movzwl %ax,%eax
c01025b5:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01025b9:	c6 45 d7 00          	movb   $0x0,-0x29(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01025bd:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c01025c1:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01025c5:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01025c6:	8b 45 14             	mov    0x14(%ebp),%eax
c01025c9:	0f b6 c0             	movzbl %al,%eax
c01025cc:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01025d0:	83 c2 02             	add    $0x2,%edx
c01025d3:	0f b7 d2             	movzwl %dx,%edx
c01025d6:	66 89 55 e8          	mov    %dx,-0x18(%ebp)
c01025da:	88 45 d8             	mov    %al,-0x28(%ebp)
c01025dd:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c01025e1:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01025e5:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01025e6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01025e9:	0f b6 c0             	movzbl %al,%eax
c01025ec:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01025f0:	83 c2 03             	add    $0x3,%edx
c01025f3:	0f b7 d2             	movzwl %dx,%edx
c01025f6:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01025fa:	88 45 d9             	mov    %al,-0x27(%ebp)
c01025fd:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0102601:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0102605:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0102606:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102609:	c1 e8 08             	shr    $0x8,%eax
c010260c:	0f b6 c0             	movzbl %al,%eax
c010260f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102613:	83 c2 04             	add    $0x4,%edx
c0102616:	0f b7 d2             	movzwl %dx,%edx
c0102619:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
c010261d:	88 45 da             	mov    %al,-0x26(%ebp)
c0102620:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c0102624:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
c0102628:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0102629:	8b 45 0c             	mov    0xc(%ebp),%eax
c010262c:	c1 e8 10             	shr    $0x10,%eax
c010262f:	0f b6 c0             	movzbl %al,%eax
c0102632:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102636:	83 c2 05             	add    $0x5,%edx
c0102639:	0f b7 d2             	movzwl %dx,%edx
c010263c:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0102640:	88 45 db             	mov    %al,-0x25(%ebp)
c0102643:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0102647:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010264b:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c010264c:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0102650:	83 e0 01             	and    $0x1,%eax
c0102653:	c1 e0 04             	shl    $0x4,%eax
c0102656:	89 c2                	mov    %eax,%edx
c0102658:	8b 45 0c             	mov    0xc(%ebp),%eax
c010265b:	c1 e8 18             	shr    $0x18,%eax
c010265e:	83 e0 0f             	and    $0xf,%eax
c0102661:	09 d0                	or     %edx,%eax
c0102663:	83 c8 e0             	or     $0xffffffe0,%eax
c0102666:	0f b6 c0             	movzbl %al,%eax
c0102669:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010266d:	83 c2 06             	add    $0x6,%edx
c0102670:	0f b7 d2             	movzwl %dx,%edx
c0102673:	66 89 55 e0          	mov    %dx,-0x20(%ebp)
c0102677:	88 45 dc             	mov    %al,-0x24(%ebp)
c010267a:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c010267e:	0f b7 55 e0          	movzwl -0x20(%ebp),%edx
c0102682:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0102683:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102687:	83 c0 07             	add    $0x7,%eax
c010268a:	0f b7 c0             	movzwl %ax,%eax
c010268d:	66 89 45 de          	mov    %ax,-0x22(%ebp)
c0102691:	c6 45 dd 20          	movb   $0x20,-0x23(%ebp)
c0102695:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102699:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010269d:	ee                   	out    %al,(%dx)

    int ret = 0;
c010269e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c01026a5:	eb 56                	jmp    c01026fd <ide_read_secs+0x217>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c01026a7:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01026ab:	83 ec 08             	sub    $0x8,%esp
c01026ae:	6a 01                	push   $0x1
c01026b0:	50                   	push   %eax
c01026b1:	e8 52 fa ff ff       	call   c0102108 <ide_wait_ready>
c01026b6:	83 c4 10             	add    $0x10,%esp
c01026b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01026bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01026c0:	75 43                	jne    c0102705 <ide_read_secs+0x21f>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c01026c2:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01026c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01026c9:	8b 45 10             	mov    0x10(%ebp),%eax
c01026cc:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01026cf:	c7 45 cc 80 00 00 00 	movl   $0x80,-0x34(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c01026d6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01026d9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01026dc:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01026df:	89 cb                	mov    %ecx,%ebx
c01026e1:	89 df                	mov    %ebx,%edi
c01026e3:	89 c1                	mov    %eax,%ecx
c01026e5:	fc                   	cld    
c01026e6:	f2 6d                	repnz insl (%dx),%es:(%edi)
c01026e8:	89 c8                	mov    %ecx,%eax
c01026ea:	89 fb                	mov    %edi,%ebx
c01026ec:	89 5d d0             	mov    %ebx,-0x30(%ebp)
c01026ef:	89 45 cc             	mov    %eax,-0x34(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c01026f2:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c01026f6:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01026fd:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0102701:	75 a4                	jne    c01026a7 <ide_read_secs+0x1c1>
c0102703:	eb 01                	jmp    c0102706 <ide_read_secs+0x220>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
            goto out;
c0102705:	90                   	nop
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0102706:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102709:	8d 65 f8             	lea    -0x8(%ebp),%esp
c010270c:	5b                   	pop    %ebx
c010270d:	5f                   	pop    %edi
c010270e:	5d                   	pop    %ebp
c010270f:	c3                   	ret    

c0102710 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0102710:	55                   	push   %ebp
c0102711:	89 e5                	mov    %esp,%ebp
c0102713:	56                   	push   %esi
c0102714:	53                   	push   %ebx
c0102715:	83 ec 40             	sub    $0x40,%esp
c0102718:	8b 45 08             	mov    0x8(%ebp),%eax
c010271b:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c010271f:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0102726:	77 25                	ja     c010274d <ide_write_secs+0x3d>
c0102728:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c010272d:	77 1e                	ja     c010274d <ide_write_secs+0x3d>
c010272f:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0102733:	c1 e0 03             	shl    $0x3,%eax
c0102736:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010273d:	29 c2                	sub    %eax,%edx
c010273f:	89 d0                	mov    %edx,%eax
c0102741:	05 40 a4 12 c0       	add    $0xc012a440,%eax
c0102746:	0f b6 00             	movzbl (%eax),%eax
c0102749:	84 c0                	test   %al,%al
c010274b:	75 19                	jne    c0102766 <ide_write_secs+0x56>
c010274d:	68 e0 ae 10 c0       	push   $0xc010aee0
c0102752:	68 9b ae 10 c0       	push   $0xc010ae9b
c0102757:	68 bc 00 00 00       	push   $0xbc
c010275c:	68 b0 ae 10 c0       	push   $0xc010aeb0
c0102761:	e8 02 f0 ff ff       	call   c0101768 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0102766:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c010276d:	77 0f                	ja     c010277e <ide_write_secs+0x6e>
c010276f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102772:	8b 45 14             	mov    0x14(%ebp),%eax
c0102775:	01 d0                	add    %edx,%eax
c0102777:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c010277c:	76 19                	jbe    c0102797 <ide_write_secs+0x87>
c010277e:	68 08 af 10 c0       	push   $0xc010af08
c0102783:	68 9b ae 10 c0       	push   $0xc010ae9b
c0102788:	68 bd 00 00 00       	push   $0xbd
c010278d:	68 b0 ae 10 c0       	push   $0xc010aeb0
c0102792:	e8 d1 ef ff ff       	call   c0101768 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0102797:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010279b:	66 d1 e8             	shr    %ax
c010279e:	0f b7 c0             	movzwl %ax,%eax
c01027a1:	0f b7 04 85 50 ae 10 	movzwl -0x3fef51b0(,%eax,4),%eax
c01027a8:	c0 
c01027a9:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c01027ad:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01027b1:	66 d1 e8             	shr    %ax
c01027b4:	0f b7 c0             	movzwl %ax,%eax
c01027b7:	0f b7 04 85 52 ae 10 	movzwl -0x3fef51ae(,%eax,4),%eax
c01027be:	c0 
c01027bf:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c01027c3:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01027c7:	83 ec 08             	sub    $0x8,%esp
c01027ca:	6a 00                	push   $0x0
c01027cc:	50                   	push   %eax
c01027cd:	e8 36 f9 ff ff       	call   c0102108 <ide_wait_ready>
c01027d2:	83 c4 10             	add    $0x10,%esp

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c01027d5:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01027d9:	83 c0 02             	add    $0x2,%eax
c01027dc:	0f b7 c0             	movzwl %ax,%eax
c01027df:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01027e3:	c6 45 d7 00          	movb   $0x0,-0x29(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01027e7:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c01027eb:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01027ef:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01027f0:	8b 45 14             	mov    0x14(%ebp),%eax
c01027f3:	0f b6 c0             	movzbl %al,%eax
c01027f6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01027fa:	83 c2 02             	add    $0x2,%edx
c01027fd:	0f b7 d2             	movzwl %dx,%edx
c0102800:	66 89 55 e8          	mov    %dx,-0x18(%ebp)
c0102804:	88 45 d8             	mov    %al,-0x28(%ebp)
c0102807:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c010280b:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c010280f:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0102810:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102813:	0f b6 c0             	movzbl %al,%eax
c0102816:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010281a:	83 c2 03             	add    $0x3,%edx
c010281d:	0f b7 d2             	movzwl %dx,%edx
c0102820:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0102824:	88 45 d9             	mov    %al,-0x27(%ebp)
c0102827:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010282b:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010282f:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0102830:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102833:	c1 e8 08             	shr    $0x8,%eax
c0102836:	0f b6 c0             	movzbl %al,%eax
c0102839:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010283d:	83 c2 04             	add    $0x4,%edx
c0102840:	0f b7 d2             	movzwl %dx,%edx
c0102843:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
c0102847:	88 45 da             	mov    %al,-0x26(%ebp)
c010284a:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c010284e:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
c0102852:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0102853:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102856:	c1 e8 10             	shr    $0x10,%eax
c0102859:	0f b6 c0             	movzbl %al,%eax
c010285c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102860:	83 c2 05             	add    $0x5,%edx
c0102863:	0f b7 d2             	movzwl %dx,%edx
c0102866:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c010286a:	88 45 db             	mov    %al,-0x25(%ebp)
c010286d:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0102871:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0102875:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0102876:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010287a:	83 e0 01             	and    $0x1,%eax
c010287d:	c1 e0 04             	shl    $0x4,%eax
c0102880:	89 c2                	mov    %eax,%edx
c0102882:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102885:	c1 e8 18             	shr    $0x18,%eax
c0102888:	83 e0 0f             	and    $0xf,%eax
c010288b:	09 d0                	or     %edx,%eax
c010288d:	83 c8 e0             	or     $0xffffffe0,%eax
c0102890:	0f b6 c0             	movzbl %al,%eax
c0102893:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102897:	83 c2 06             	add    $0x6,%edx
c010289a:	0f b7 d2             	movzwl %dx,%edx
c010289d:	66 89 55 e0          	mov    %dx,-0x20(%ebp)
c01028a1:	88 45 dc             	mov    %al,-0x24(%ebp)
c01028a4:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c01028a8:	0f b7 55 e0          	movzwl -0x20(%ebp),%edx
c01028ac:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c01028ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01028b1:	83 c0 07             	add    $0x7,%eax
c01028b4:	0f b7 c0             	movzwl %ax,%eax
c01028b7:	66 89 45 de          	mov    %ax,-0x22(%ebp)
c01028bb:	c6 45 dd 30          	movb   $0x30,-0x23(%ebp)
c01028bf:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01028c3:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01028c7:	ee                   	out    %al,(%dx)

    int ret = 0;
c01028c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01028cf:	eb 56                	jmp    c0102927 <ide_write_secs+0x217>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c01028d1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01028d5:	83 ec 08             	sub    $0x8,%esp
c01028d8:	6a 01                	push   $0x1
c01028da:	50                   	push   %eax
c01028db:	e8 28 f8 ff ff       	call   c0102108 <ide_wait_ready>
c01028e0:	83 c4 10             	add    $0x10,%esp
c01028e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01028e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01028ea:	75 43                	jne    c010292f <ide_write_secs+0x21f>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c01028ec:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01028f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01028f3:	8b 45 10             	mov    0x10(%ebp),%eax
c01028f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01028f9:	c7 45 cc 80 00 00 00 	movl   $0x80,-0x34(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c0102900:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102903:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0102906:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102909:	89 cb                	mov    %ecx,%ebx
c010290b:	89 de                	mov    %ebx,%esi
c010290d:	89 c1                	mov    %eax,%ecx
c010290f:	fc                   	cld    
c0102910:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0102912:	89 c8                	mov    %ecx,%eax
c0102914:	89 f3                	mov    %esi,%ebx
c0102916:	89 5d d0             	mov    %ebx,-0x30(%ebp)
c0102919:	89 45 cc             	mov    %eax,-0x34(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c010291c:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0102920:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0102927:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c010292b:	75 a4                	jne    c01028d1 <ide_write_secs+0x1c1>
c010292d:	eb 01                	jmp    c0102930 <ide_write_secs+0x220>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
            goto out;
c010292f:	90                   	nop
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0102930:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102933:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0102936:	5b                   	pop    %ebx
c0102937:	5e                   	pop    %esi
c0102938:	5d                   	pop    %ebp
c0102939:	c3                   	ret    

c010293a <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c010293a:	55                   	push   %ebp
c010293b:	89 e5                	mov    %esp,%ebp
c010293d:	83 ec 18             	sub    $0x18,%esp
c0102940:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0102946:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010294a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
c010294e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102952:	ee                   	out    %al,(%dx)
c0102953:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
c0102959:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
c010295d:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0102961:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c0102965:	ee                   	out    %al,(%dx)
c0102966:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c010296c:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
c0102970:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102974:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102978:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0102979:	c7 05 54 d0 12 c0 00 	movl   $0x0,0xc012d054
c0102980:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0102983:	83 ec 0c             	sub    $0xc,%esp
c0102986:	68 42 af 10 c0       	push   $0xc010af42
c010298b:	e8 fa d8 ff ff       	call   c010028a <cprintf>
c0102990:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_TIMER);
c0102993:	83 ec 0c             	sub    $0xc,%esp
c0102996:	6a 00                	push   $0x0
c0102998:	e8 3b 09 00 00       	call   c01032d8 <pic_enable>
c010299d:	83 c4 10             	add    $0x10,%esp
}
c01029a0:	90                   	nop
c01029a1:	c9                   	leave  
c01029a2:	c3                   	ret    

c01029a3 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c01029a3:	55                   	push   %ebp
c01029a4:	89 e5                	mov    %esp,%ebp
c01029a6:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01029a9:	9c                   	pushf  
c01029aa:	58                   	pop    %eax
c01029ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01029ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01029b1:	25 00 02 00 00       	and    $0x200,%eax
c01029b6:	85 c0                	test   %eax,%eax
c01029b8:	74 0c                	je     c01029c6 <__intr_save+0x23>
        intr_disable();
c01029ba:	e8 8a 0a 00 00       	call   c0103449 <intr_disable>
        return 1;
c01029bf:	b8 01 00 00 00       	mov    $0x1,%eax
c01029c4:	eb 05                	jmp    c01029cb <__intr_save+0x28>
    }
    return 0;
c01029c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01029cb:	c9                   	leave  
c01029cc:	c3                   	ret    

c01029cd <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01029cd:	55                   	push   %ebp
c01029ce:	89 e5                	mov    %esp,%ebp
c01029d0:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01029d3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01029d7:	74 05                	je     c01029de <__intr_restore+0x11>
        intr_enable();
c01029d9:	e8 64 0a 00 00       	call   c0103442 <intr_enable>
    }
}
c01029de:	90                   	nop
c01029df:	c9                   	leave  
c01029e0:	c3                   	ret    

c01029e1 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c01029e1:	55                   	push   %ebp
c01029e2:	89 e5                	mov    %esp,%ebp
c01029e4:	83 ec 10             	sub    $0x10,%esp
c01029e7:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01029ed:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01029f1:	89 c2                	mov    %eax,%edx
c01029f3:	ec                   	in     (%dx),%al
c01029f4:	88 45 f4             	mov    %al,-0xc(%ebp)
c01029f7:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
c01029fd:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0102a01:	89 c2                	mov    %eax,%edx
c0102a03:	ec                   	in     (%dx),%al
c0102a04:	88 45 f5             	mov    %al,-0xb(%ebp)
c0102a07:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0102a0d:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0102a11:	89 c2                	mov    %eax,%edx
c0102a13:	ec                   	in     (%dx),%al
c0102a14:	88 45 f6             	mov    %al,-0xa(%ebp)
c0102a17:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
c0102a1d:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c0102a21:	89 c2                	mov    %eax,%edx
c0102a23:	ec                   	in     (%dx),%al
c0102a24:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0102a27:	90                   	nop
c0102a28:	c9                   	leave  
c0102a29:	c3                   	ret    

c0102a2a <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0102a2a:	55                   	push   %ebp
c0102a2b:	89 e5                	mov    %esp,%ebp
c0102a2d:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0102a30:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0102a37:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102a3a:	0f b7 00             	movzwl (%eax),%eax
c0102a3d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0102a41:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102a44:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0102a49:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102a4c:	0f b7 00             	movzwl (%eax),%eax
c0102a4f:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0102a53:	74 12                	je     c0102a67 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0102a55:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0102a5c:	66 c7 05 26 a5 12 c0 	movw   $0x3b4,0xc012a526
c0102a63:	b4 03 
c0102a65:	eb 13                	jmp    c0102a7a <cga_init+0x50>
    } else {
        *cp = was;
c0102a67:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102a6a:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102a6e:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0102a71:	66 c7 05 26 a5 12 c0 	movw   $0x3d4,0xc012a526
c0102a78:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0102a7a:	0f b7 05 26 a5 12 c0 	movzwl 0xc012a526,%eax
c0102a81:	0f b7 c0             	movzwl %ax,%eax
c0102a84:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
c0102a88:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102a8c:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0102a90:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c0102a94:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0102a95:	0f b7 05 26 a5 12 c0 	movzwl 0xc012a526,%eax
c0102a9c:	83 c0 01             	add    $0x1,%eax
c0102a9f:	0f b7 c0             	movzwl %ax,%eax
c0102aa2:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102aa6:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102aaa:	89 c2                	mov    %eax,%edx
c0102aac:	ec                   	in     (%dx),%al
c0102aad:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0102ab0:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0102ab4:	0f b6 c0             	movzbl %al,%eax
c0102ab7:	c1 e0 08             	shl    $0x8,%eax
c0102aba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0102abd:	0f b7 05 26 a5 12 c0 	movzwl 0xc012a526,%eax
c0102ac4:	0f b7 c0             	movzwl %ax,%eax
c0102ac7:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
c0102acb:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102acf:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
c0102ad3:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c0102ad7:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0102ad8:	0f b7 05 26 a5 12 c0 	movzwl 0xc012a526,%eax
c0102adf:	83 c0 01             	add    $0x1,%eax
c0102ae2:	0f b7 c0             	movzwl %ax,%eax
c0102ae5:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102ae9:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0102aed:	89 c2                	mov    %eax,%edx
c0102aef:	ec                   	in     (%dx),%al
c0102af0:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0102af3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102af7:	0f b6 c0             	movzbl %al,%eax
c0102afa:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0102afd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102b00:	a3 20 a5 12 c0       	mov    %eax,0xc012a520
    crt_pos = pos;
c0102b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b08:	66 a3 24 a5 12 c0    	mov    %ax,0xc012a524
}
c0102b0e:	90                   	nop
c0102b0f:	c9                   	leave  
c0102b10:	c3                   	ret    

c0102b11 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0102b11:	55                   	push   %ebp
c0102b12:	89 e5                	mov    %esp,%ebp
c0102b14:	83 ec 28             	sub    $0x28,%esp
c0102b17:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0102b1d:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102b21:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c0102b25:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102b29:	ee                   	out    %al,(%dx)
c0102b2a:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
c0102b30:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
c0102b34:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0102b38:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c0102b3c:	ee                   	out    %al,(%dx)
c0102b3d:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
c0102b43:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
c0102b47:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0102b4b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102b4f:	ee                   	out    %al,(%dx)
c0102b50:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
c0102b56:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0102b5a:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102b5e:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c0102b62:	ee                   	out    %al,(%dx)
c0102b63:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
c0102b69:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
c0102b6d:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c0102b71:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102b75:	ee                   	out    %al,(%dx)
c0102b76:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
c0102b7c:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
c0102b80:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0102b84:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c0102b88:	ee                   	out    %al,(%dx)
c0102b89:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0102b8f:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
c0102b93:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0102b97:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102b9b:	ee                   	out    %al,(%dx)
c0102b9c:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102ba2:	0f b7 45 e8          	movzwl -0x18(%ebp),%eax
c0102ba6:	89 c2                	mov    %eax,%edx
c0102ba8:	ec                   	in     (%dx),%al
c0102ba9:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
c0102bac:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0102bb0:	3c ff                	cmp    $0xff,%al
c0102bb2:	0f 95 c0             	setne  %al
c0102bb5:	0f b6 c0             	movzbl %al,%eax
c0102bb8:	a3 28 a5 12 c0       	mov    %eax,0xc012a528
c0102bbd:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102bc3:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0102bc7:	89 c2                	mov    %eax,%edx
c0102bc9:	ec                   	in     (%dx),%al
c0102bca:	88 45 e2             	mov    %al,-0x1e(%ebp)
c0102bcd:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
c0102bd3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
c0102bd7:	89 c2                	mov    %eax,%edx
c0102bd9:	ec                   	in     (%dx),%al
c0102bda:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0102bdd:	a1 28 a5 12 c0       	mov    0xc012a528,%eax
c0102be2:	85 c0                	test   %eax,%eax
c0102be4:	74 0d                	je     c0102bf3 <serial_init+0xe2>
        pic_enable(IRQ_COM1);
c0102be6:	83 ec 0c             	sub    $0xc,%esp
c0102be9:	6a 04                	push   $0x4
c0102beb:	e8 e8 06 00 00       	call   c01032d8 <pic_enable>
c0102bf0:	83 c4 10             	add    $0x10,%esp
    }
}
c0102bf3:	90                   	nop
c0102bf4:	c9                   	leave  
c0102bf5:	c3                   	ret    

c0102bf6 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0102bf6:	55                   	push   %ebp
c0102bf7:	89 e5                	mov    %esp,%ebp
c0102bf9:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0102bfc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102c03:	eb 09                	jmp    c0102c0e <lpt_putc_sub+0x18>
        delay();
c0102c05:	e8 d7 fd ff ff       	call   c01029e1 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0102c0a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102c0e:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
c0102c14:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0102c18:	89 c2                	mov    %eax,%edx
c0102c1a:	ec                   	in     (%dx),%al
c0102c1b:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
c0102c1e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0102c22:	84 c0                	test   %al,%al
c0102c24:	78 09                	js     c0102c2f <lpt_putc_sub+0x39>
c0102c26:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0102c2d:	7e d6                	jle    c0102c05 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0102c2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c32:	0f b6 c0             	movzbl %al,%eax
c0102c35:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
c0102c3b:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102c3e:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0102c42:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c0102c46:	ee                   	out    %al,(%dx)
c0102c47:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0102c4d:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0102c51:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102c55:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102c59:	ee                   	out    %al,(%dx)
c0102c5a:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
c0102c60:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
c0102c64:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
c0102c68:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102c6c:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0102c6d:	90                   	nop
c0102c6e:	c9                   	leave  
c0102c6f:	c3                   	ret    

c0102c70 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0102c70:	55                   	push   %ebp
c0102c71:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
c0102c73:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0102c77:	74 0d                	je     c0102c86 <lpt_putc+0x16>
        lpt_putc_sub(c);
c0102c79:	ff 75 08             	pushl  0x8(%ebp)
c0102c7c:	e8 75 ff ff ff       	call   c0102bf6 <lpt_putc_sub>
c0102c81:	83 c4 04             	add    $0x4,%esp
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c0102c84:	eb 1e                	jmp    c0102ca4 <lpt_putc+0x34>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
c0102c86:	6a 08                	push   $0x8
c0102c88:	e8 69 ff ff ff       	call   c0102bf6 <lpt_putc_sub>
c0102c8d:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub(' ');
c0102c90:	6a 20                	push   $0x20
c0102c92:	e8 5f ff ff ff       	call   c0102bf6 <lpt_putc_sub>
c0102c97:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub('\b');
c0102c9a:	6a 08                	push   $0x8
c0102c9c:	e8 55 ff ff ff       	call   c0102bf6 <lpt_putc_sub>
c0102ca1:	83 c4 04             	add    $0x4,%esp
    }
}
c0102ca4:	90                   	nop
c0102ca5:	c9                   	leave  
c0102ca6:	c3                   	ret    

c0102ca7 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0102ca7:	55                   	push   %ebp
c0102ca8:	89 e5                	mov    %esp,%ebp
c0102caa:	53                   	push   %ebx
c0102cab:	83 ec 14             	sub    $0x14,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0102cae:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cb1:	b0 00                	mov    $0x0,%al
c0102cb3:	85 c0                	test   %eax,%eax
c0102cb5:	75 07                	jne    c0102cbe <cga_putc+0x17>
        c |= 0x0700;
c0102cb7:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0102cbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cc1:	0f b6 c0             	movzbl %al,%eax
c0102cc4:	83 f8 0a             	cmp    $0xa,%eax
c0102cc7:	74 4e                	je     c0102d17 <cga_putc+0x70>
c0102cc9:	83 f8 0d             	cmp    $0xd,%eax
c0102ccc:	74 59                	je     c0102d27 <cga_putc+0x80>
c0102cce:	83 f8 08             	cmp    $0x8,%eax
c0102cd1:	0f 85 8a 00 00 00    	jne    c0102d61 <cga_putc+0xba>
    case '\b':
        if (crt_pos > 0) {
c0102cd7:	0f b7 05 24 a5 12 c0 	movzwl 0xc012a524,%eax
c0102cde:	66 85 c0             	test   %ax,%ax
c0102ce1:	0f 84 a0 00 00 00    	je     c0102d87 <cga_putc+0xe0>
            crt_pos --;
c0102ce7:	0f b7 05 24 a5 12 c0 	movzwl 0xc012a524,%eax
c0102cee:	83 e8 01             	sub    $0x1,%eax
c0102cf1:	66 a3 24 a5 12 c0    	mov    %ax,0xc012a524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0102cf7:	a1 20 a5 12 c0       	mov    0xc012a520,%eax
c0102cfc:	0f b7 15 24 a5 12 c0 	movzwl 0xc012a524,%edx
c0102d03:	0f b7 d2             	movzwl %dx,%edx
c0102d06:	01 d2                	add    %edx,%edx
c0102d08:	01 d0                	add    %edx,%eax
c0102d0a:	8b 55 08             	mov    0x8(%ebp),%edx
c0102d0d:	b2 00                	mov    $0x0,%dl
c0102d0f:	83 ca 20             	or     $0x20,%edx
c0102d12:	66 89 10             	mov    %dx,(%eax)
        }
        break;
c0102d15:	eb 70                	jmp    c0102d87 <cga_putc+0xe0>
    case '\n':
        crt_pos += CRT_COLS;
c0102d17:	0f b7 05 24 a5 12 c0 	movzwl 0xc012a524,%eax
c0102d1e:	83 c0 50             	add    $0x50,%eax
c0102d21:	66 a3 24 a5 12 c0    	mov    %ax,0xc012a524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0102d27:	0f b7 1d 24 a5 12 c0 	movzwl 0xc012a524,%ebx
c0102d2e:	0f b7 0d 24 a5 12 c0 	movzwl 0xc012a524,%ecx
c0102d35:	0f b7 c1             	movzwl %cx,%eax
c0102d38:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c0102d3e:	c1 e8 10             	shr    $0x10,%eax
c0102d41:	89 c2                	mov    %eax,%edx
c0102d43:	66 c1 ea 06          	shr    $0x6,%dx
c0102d47:	89 d0                	mov    %edx,%eax
c0102d49:	c1 e0 02             	shl    $0x2,%eax
c0102d4c:	01 d0                	add    %edx,%eax
c0102d4e:	c1 e0 04             	shl    $0x4,%eax
c0102d51:	29 c1                	sub    %eax,%ecx
c0102d53:	89 ca                	mov    %ecx,%edx
c0102d55:	89 d8                	mov    %ebx,%eax
c0102d57:	29 d0                	sub    %edx,%eax
c0102d59:	66 a3 24 a5 12 c0    	mov    %ax,0xc012a524
        break;
c0102d5f:	eb 27                	jmp    c0102d88 <cga_putc+0xe1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0102d61:	8b 0d 20 a5 12 c0    	mov    0xc012a520,%ecx
c0102d67:	0f b7 05 24 a5 12 c0 	movzwl 0xc012a524,%eax
c0102d6e:	8d 50 01             	lea    0x1(%eax),%edx
c0102d71:	66 89 15 24 a5 12 c0 	mov    %dx,0xc012a524
c0102d78:	0f b7 c0             	movzwl %ax,%eax
c0102d7b:	01 c0                	add    %eax,%eax
c0102d7d:	01 c8                	add    %ecx,%eax
c0102d7f:	8b 55 08             	mov    0x8(%ebp),%edx
c0102d82:	66 89 10             	mov    %dx,(%eax)
        break;
c0102d85:	eb 01                	jmp    c0102d88 <cga_putc+0xe1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
c0102d87:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0102d88:	0f b7 05 24 a5 12 c0 	movzwl 0xc012a524,%eax
c0102d8f:	66 3d cf 07          	cmp    $0x7cf,%ax
c0102d93:	76 59                	jbe    c0102dee <cga_putc+0x147>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0102d95:	a1 20 a5 12 c0       	mov    0xc012a520,%eax
c0102d9a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0102da0:	a1 20 a5 12 c0       	mov    0xc012a520,%eax
c0102da5:	83 ec 04             	sub    $0x4,%esp
c0102da8:	68 00 0f 00 00       	push   $0xf00
c0102dad:	52                   	push   %edx
c0102dae:	50                   	push   %eax
c0102daf:	e8 d5 72 00 00       	call   c010a089 <memmove>
c0102db4:	83 c4 10             	add    $0x10,%esp
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0102db7:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0102dbe:	eb 15                	jmp    c0102dd5 <cga_putc+0x12e>
            crt_buf[i] = 0x0700 | ' ';
c0102dc0:	a1 20 a5 12 c0       	mov    0xc012a520,%eax
c0102dc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102dc8:	01 d2                	add    %edx,%edx
c0102dca:	01 d0                	add    %edx,%eax
c0102dcc:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0102dd1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102dd5:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0102ddc:	7e e2                	jle    c0102dc0 <cga_putc+0x119>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0102dde:	0f b7 05 24 a5 12 c0 	movzwl 0xc012a524,%eax
c0102de5:	83 e8 50             	sub    $0x50,%eax
c0102de8:	66 a3 24 a5 12 c0    	mov    %ax,0xc012a524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0102dee:	0f b7 05 26 a5 12 c0 	movzwl 0xc012a526,%eax
c0102df5:	0f b7 c0             	movzwl %ax,%eax
c0102df8:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0102dfc:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
c0102e00:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
c0102e04:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102e08:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0102e09:	0f b7 05 24 a5 12 c0 	movzwl 0xc012a524,%eax
c0102e10:	66 c1 e8 08          	shr    $0x8,%ax
c0102e14:	0f b6 c0             	movzbl %al,%eax
c0102e17:	0f b7 15 26 a5 12 c0 	movzwl 0xc012a526,%edx
c0102e1e:	83 c2 01             	add    $0x1,%edx
c0102e21:	0f b7 d2             	movzwl %dx,%edx
c0102e24:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
c0102e28:	88 45 e9             	mov    %al,-0x17(%ebp)
c0102e2b:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102e2f:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c0102e33:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0102e34:	0f b7 05 26 a5 12 c0 	movzwl 0xc012a526,%eax
c0102e3b:	0f b7 c0             	movzwl %ax,%eax
c0102e3e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0102e42:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
c0102e46:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0102e4a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102e4e:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0102e4f:	0f b7 05 24 a5 12 c0 	movzwl 0xc012a524,%eax
c0102e56:	0f b6 c0             	movzbl %al,%eax
c0102e59:	0f b7 15 26 a5 12 c0 	movzwl 0xc012a526,%edx
c0102e60:	83 c2 01             	add    $0x1,%edx
c0102e63:	0f b7 d2             	movzwl %dx,%edx
c0102e66:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
c0102e6a:	88 45 eb             	mov    %al,-0x15(%ebp)
c0102e6d:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0102e71:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c0102e75:	ee                   	out    %al,(%dx)
}
c0102e76:	90                   	nop
c0102e77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0102e7a:	c9                   	leave  
c0102e7b:	c3                   	ret    

c0102e7c <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0102e7c:	55                   	push   %ebp
c0102e7d:	89 e5                	mov    %esp,%ebp
c0102e7f:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0102e82:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102e89:	eb 09                	jmp    c0102e94 <serial_putc_sub+0x18>
        delay();
c0102e8b:	e8 51 fb ff ff       	call   c01029e1 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0102e90:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102e94:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102e9a:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c0102e9e:	89 c2                	mov    %eax,%edx
c0102ea0:	ec                   	in     (%dx),%al
c0102ea1:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c0102ea4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0102ea8:	0f b6 c0             	movzbl %al,%eax
c0102eab:	83 e0 20             	and    $0x20,%eax
c0102eae:	85 c0                	test   %eax,%eax
c0102eb0:	75 09                	jne    c0102ebb <serial_putc_sub+0x3f>
c0102eb2:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0102eb9:	7e d0                	jle    c0102e8b <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0102ebb:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ebe:	0f b6 c0             	movzbl %al,%eax
c0102ec1:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
c0102ec7:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102eca:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
c0102ece:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102ed2:	ee                   	out    %al,(%dx)
}
c0102ed3:	90                   	nop
c0102ed4:	c9                   	leave  
c0102ed5:	c3                   	ret    

c0102ed6 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0102ed6:	55                   	push   %ebp
c0102ed7:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
c0102ed9:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0102edd:	74 0d                	je     c0102eec <serial_putc+0x16>
        serial_putc_sub(c);
c0102edf:	ff 75 08             	pushl  0x8(%ebp)
c0102ee2:	e8 95 ff ff ff       	call   c0102e7c <serial_putc_sub>
c0102ee7:	83 c4 04             	add    $0x4,%esp
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0102eea:	eb 1e                	jmp    c0102f0a <serial_putc+0x34>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
c0102eec:	6a 08                	push   $0x8
c0102eee:	e8 89 ff ff ff       	call   c0102e7c <serial_putc_sub>
c0102ef3:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub(' ');
c0102ef6:	6a 20                	push   $0x20
c0102ef8:	e8 7f ff ff ff       	call   c0102e7c <serial_putc_sub>
c0102efd:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub('\b');
c0102f00:	6a 08                	push   $0x8
c0102f02:	e8 75 ff ff ff       	call   c0102e7c <serial_putc_sub>
c0102f07:	83 c4 04             	add    $0x4,%esp
    }
}
c0102f0a:	90                   	nop
c0102f0b:	c9                   	leave  
c0102f0c:	c3                   	ret    

c0102f0d <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0102f0d:	55                   	push   %ebp
c0102f0e:	89 e5                	mov    %esp,%ebp
c0102f10:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0102f13:	eb 33                	jmp    c0102f48 <cons_intr+0x3b>
        if (c != 0) {
c0102f15:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102f19:	74 2d                	je     c0102f48 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0102f1b:	a1 44 a7 12 c0       	mov    0xc012a744,%eax
c0102f20:	8d 50 01             	lea    0x1(%eax),%edx
c0102f23:	89 15 44 a7 12 c0    	mov    %edx,0xc012a744
c0102f29:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102f2c:	88 90 40 a5 12 c0    	mov    %dl,-0x3fed5ac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0102f32:	a1 44 a7 12 c0       	mov    0xc012a744,%eax
c0102f37:	3d 00 02 00 00       	cmp    $0x200,%eax
c0102f3c:	75 0a                	jne    c0102f48 <cons_intr+0x3b>
                cons.wpos = 0;
c0102f3e:	c7 05 44 a7 12 c0 00 	movl   $0x0,0xc012a744
c0102f45:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c0102f48:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f4b:	ff d0                	call   *%eax
c0102f4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102f50:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0102f54:	75 bf                	jne    c0102f15 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c0102f56:	90                   	nop
c0102f57:	c9                   	leave  
c0102f58:	c3                   	ret    

c0102f59 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0102f59:	55                   	push   %ebp
c0102f5a:	89 e5                	mov    %esp,%ebp
c0102f5c:	83 ec 10             	sub    $0x10,%esp
c0102f5f:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102f65:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c0102f69:	89 c2                	mov    %eax,%edx
c0102f6b:	ec                   	in     (%dx),%al
c0102f6c:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c0102f6f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0102f73:	0f b6 c0             	movzbl %al,%eax
c0102f76:	83 e0 01             	and    $0x1,%eax
c0102f79:	85 c0                	test   %eax,%eax
c0102f7b:	75 07                	jne    c0102f84 <serial_proc_data+0x2b>
        return -1;
c0102f7d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0102f82:	eb 2a                	jmp    c0102fae <serial_proc_data+0x55>
c0102f84:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102f8a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0102f8e:	89 c2                	mov    %eax,%edx
c0102f90:	ec                   	in     (%dx),%al
c0102f91:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
c0102f94:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0102f98:	0f b6 c0             	movzbl %al,%eax
c0102f9b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0102f9e:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0102fa2:	75 07                	jne    c0102fab <serial_proc_data+0x52>
        c = '\b';
c0102fa4:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0102fab:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0102fae:	c9                   	leave  
c0102faf:	c3                   	ret    

c0102fb0 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0102fb0:	55                   	push   %ebp
c0102fb1:	89 e5                	mov    %esp,%ebp
c0102fb3:	83 ec 08             	sub    $0x8,%esp
    if (serial_exists) {
c0102fb6:	a1 28 a5 12 c0       	mov    0xc012a528,%eax
c0102fbb:	85 c0                	test   %eax,%eax
c0102fbd:	74 10                	je     c0102fcf <serial_intr+0x1f>
        cons_intr(serial_proc_data);
c0102fbf:	83 ec 0c             	sub    $0xc,%esp
c0102fc2:	68 59 2f 10 c0       	push   $0xc0102f59
c0102fc7:	e8 41 ff ff ff       	call   c0102f0d <cons_intr>
c0102fcc:	83 c4 10             	add    $0x10,%esp
    }
}
c0102fcf:	90                   	nop
c0102fd0:	c9                   	leave  
c0102fd1:	c3                   	ret    

c0102fd2 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0102fd2:	55                   	push   %ebp
c0102fd3:	89 e5                	mov    %esp,%ebp
c0102fd5:	83 ec 18             	sub    $0x18,%esp
c0102fd8:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102fde:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102fe2:	89 c2                	mov    %eax,%edx
c0102fe4:	ec                   	in     (%dx),%al
c0102fe5:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0102fe8:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0102fec:	0f b6 c0             	movzbl %al,%eax
c0102fef:	83 e0 01             	and    $0x1,%eax
c0102ff2:	85 c0                	test   %eax,%eax
c0102ff4:	75 0a                	jne    c0103000 <kbd_proc_data+0x2e>
        return -1;
c0102ff6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0102ffb:	e9 5d 01 00 00       	jmp    c010315d <kbd_proc_data+0x18b>
c0103000:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0103006:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c010300a:	89 c2                	mov    %eax,%edx
c010300c:	ec                   	in     (%dx),%al
c010300d:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
c0103010:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
c0103014:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0103017:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010301b:	75 17                	jne    c0103034 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c010301d:	a1 48 a7 12 c0       	mov    0xc012a748,%eax
c0103022:	83 c8 40             	or     $0x40,%eax
c0103025:	a3 48 a7 12 c0       	mov    %eax,0xc012a748
        return 0;
c010302a:	b8 00 00 00 00       	mov    $0x0,%eax
c010302f:	e9 29 01 00 00       	jmp    c010315d <kbd_proc_data+0x18b>
    } else if (data & 0x80) {
c0103034:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0103038:	84 c0                	test   %al,%al
c010303a:	79 47                	jns    c0103083 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010303c:	a1 48 a7 12 c0       	mov    0xc012a748,%eax
c0103041:	83 e0 40             	and    $0x40,%eax
c0103044:	85 c0                	test   %eax,%eax
c0103046:	75 09                	jne    c0103051 <kbd_proc_data+0x7f>
c0103048:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010304c:	83 e0 7f             	and    $0x7f,%eax
c010304f:	eb 04                	jmp    c0103055 <kbd_proc_data+0x83>
c0103051:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0103055:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0103058:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010305c:	0f b6 80 40 70 12 c0 	movzbl -0x3fed8fc0(%eax),%eax
c0103063:	83 c8 40             	or     $0x40,%eax
c0103066:	0f b6 c0             	movzbl %al,%eax
c0103069:	f7 d0                	not    %eax
c010306b:	89 c2                	mov    %eax,%edx
c010306d:	a1 48 a7 12 c0       	mov    0xc012a748,%eax
c0103072:	21 d0                	and    %edx,%eax
c0103074:	a3 48 a7 12 c0       	mov    %eax,0xc012a748
        return 0;
c0103079:	b8 00 00 00 00       	mov    $0x0,%eax
c010307e:	e9 da 00 00 00       	jmp    c010315d <kbd_proc_data+0x18b>
    } else if (shift & E0ESC) {
c0103083:	a1 48 a7 12 c0       	mov    0xc012a748,%eax
c0103088:	83 e0 40             	and    $0x40,%eax
c010308b:	85 c0                	test   %eax,%eax
c010308d:	74 11                	je     c01030a0 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c010308f:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0103093:	a1 48 a7 12 c0       	mov    0xc012a748,%eax
c0103098:	83 e0 bf             	and    $0xffffffbf,%eax
c010309b:	a3 48 a7 12 c0       	mov    %eax,0xc012a748
    }

    shift |= shiftcode[data];
c01030a0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01030a4:	0f b6 80 40 70 12 c0 	movzbl -0x3fed8fc0(%eax),%eax
c01030ab:	0f b6 d0             	movzbl %al,%edx
c01030ae:	a1 48 a7 12 c0       	mov    0xc012a748,%eax
c01030b3:	09 d0                	or     %edx,%eax
c01030b5:	a3 48 a7 12 c0       	mov    %eax,0xc012a748
    shift ^= togglecode[data];
c01030ba:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01030be:	0f b6 80 40 71 12 c0 	movzbl -0x3fed8ec0(%eax),%eax
c01030c5:	0f b6 d0             	movzbl %al,%edx
c01030c8:	a1 48 a7 12 c0       	mov    0xc012a748,%eax
c01030cd:	31 d0                	xor    %edx,%eax
c01030cf:	a3 48 a7 12 c0       	mov    %eax,0xc012a748

    c = charcode[shift & (CTL | SHIFT)][data];
c01030d4:	a1 48 a7 12 c0       	mov    0xc012a748,%eax
c01030d9:	83 e0 03             	and    $0x3,%eax
c01030dc:	8b 14 85 40 75 12 c0 	mov    -0x3fed8ac0(,%eax,4),%edx
c01030e3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01030e7:	01 d0                	add    %edx,%eax
c01030e9:	0f b6 00             	movzbl (%eax),%eax
c01030ec:	0f b6 c0             	movzbl %al,%eax
c01030ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01030f2:	a1 48 a7 12 c0       	mov    0xc012a748,%eax
c01030f7:	83 e0 08             	and    $0x8,%eax
c01030fa:	85 c0                	test   %eax,%eax
c01030fc:	74 22                	je     c0103120 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c01030fe:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0103102:	7e 0c                	jle    c0103110 <kbd_proc_data+0x13e>
c0103104:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0103108:	7f 06                	jg     c0103110 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c010310a:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010310e:	eb 10                	jmp    c0103120 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0103110:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0103114:	7e 0a                	jle    c0103120 <kbd_proc_data+0x14e>
c0103116:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c010311a:	7f 04                	jg     c0103120 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c010311c:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0103120:	a1 48 a7 12 c0       	mov    0xc012a748,%eax
c0103125:	f7 d0                	not    %eax
c0103127:	83 e0 06             	and    $0x6,%eax
c010312a:	85 c0                	test   %eax,%eax
c010312c:	75 2c                	jne    c010315a <kbd_proc_data+0x188>
c010312e:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0103135:	75 23                	jne    c010315a <kbd_proc_data+0x188>
        cprintf("Rebooting!\n");
c0103137:	83 ec 0c             	sub    $0xc,%esp
c010313a:	68 5d af 10 c0       	push   $0xc010af5d
c010313f:	e8 46 d1 ff ff       	call   c010028a <cprintf>
c0103144:	83 c4 10             	add    $0x10,%esp
c0103147:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
c010314d:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0103151:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0103155:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0103159:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c010315a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010315d:	c9                   	leave  
c010315e:	c3                   	ret    

c010315f <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c010315f:	55                   	push   %ebp
c0103160:	89 e5                	mov    %esp,%ebp
c0103162:	83 ec 08             	sub    $0x8,%esp
    cons_intr(kbd_proc_data);
c0103165:	83 ec 0c             	sub    $0xc,%esp
c0103168:	68 d2 2f 10 c0       	push   $0xc0102fd2
c010316d:	e8 9b fd ff ff       	call   c0102f0d <cons_intr>
c0103172:	83 c4 10             	add    $0x10,%esp
}
c0103175:	90                   	nop
c0103176:	c9                   	leave  
c0103177:	c3                   	ret    

c0103178 <kbd_init>:

static void
kbd_init(void) {
c0103178:	55                   	push   %ebp
c0103179:	89 e5                	mov    %esp,%ebp
c010317b:	83 ec 08             	sub    $0x8,%esp
    // drain the kbd buffer
    kbd_intr();
c010317e:	e8 dc ff ff ff       	call   c010315f <kbd_intr>
    pic_enable(IRQ_KBD);
c0103183:	83 ec 0c             	sub    $0xc,%esp
c0103186:	6a 01                	push   $0x1
c0103188:	e8 4b 01 00 00       	call   c01032d8 <pic_enable>
c010318d:	83 c4 10             	add    $0x10,%esp
}
c0103190:	90                   	nop
c0103191:	c9                   	leave  
c0103192:	c3                   	ret    

c0103193 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0103193:	55                   	push   %ebp
c0103194:	89 e5                	mov    %esp,%ebp
c0103196:	83 ec 08             	sub    $0x8,%esp
    cga_init();
c0103199:	e8 8c f8 ff ff       	call   c0102a2a <cga_init>
    serial_init();
c010319e:	e8 6e f9 ff ff       	call   c0102b11 <serial_init>
    kbd_init();
c01031a3:	e8 d0 ff ff ff       	call   c0103178 <kbd_init>
    if (!serial_exists) {
c01031a8:	a1 28 a5 12 c0       	mov    0xc012a528,%eax
c01031ad:	85 c0                	test   %eax,%eax
c01031af:	75 10                	jne    c01031c1 <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
c01031b1:	83 ec 0c             	sub    $0xc,%esp
c01031b4:	68 69 af 10 c0       	push   $0xc010af69
c01031b9:	e8 cc d0 ff ff       	call   c010028a <cprintf>
c01031be:	83 c4 10             	add    $0x10,%esp
    }
}
c01031c1:	90                   	nop
c01031c2:	c9                   	leave  
c01031c3:	c3                   	ret    

c01031c4 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c01031c4:	55                   	push   %ebp
c01031c5:	89 e5                	mov    %esp,%ebp
c01031c7:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01031ca:	e8 d4 f7 ff ff       	call   c01029a3 <__intr_save>
c01031cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c01031d2:	83 ec 0c             	sub    $0xc,%esp
c01031d5:	ff 75 08             	pushl  0x8(%ebp)
c01031d8:	e8 93 fa ff ff       	call   c0102c70 <lpt_putc>
c01031dd:	83 c4 10             	add    $0x10,%esp
        cga_putc(c);
c01031e0:	83 ec 0c             	sub    $0xc,%esp
c01031e3:	ff 75 08             	pushl  0x8(%ebp)
c01031e6:	e8 bc fa ff ff       	call   c0102ca7 <cga_putc>
c01031eb:	83 c4 10             	add    $0x10,%esp
        serial_putc(c);
c01031ee:	83 ec 0c             	sub    $0xc,%esp
c01031f1:	ff 75 08             	pushl  0x8(%ebp)
c01031f4:	e8 dd fc ff ff       	call   c0102ed6 <serial_putc>
c01031f9:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c01031fc:	83 ec 0c             	sub    $0xc,%esp
c01031ff:	ff 75 f4             	pushl  -0xc(%ebp)
c0103202:	e8 c6 f7 ff ff       	call   c01029cd <__intr_restore>
c0103207:	83 c4 10             	add    $0x10,%esp
}
c010320a:	90                   	nop
c010320b:	c9                   	leave  
c010320c:	c3                   	ret    

c010320d <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c010320d:	55                   	push   %ebp
c010320e:	89 e5                	mov    %esp,%ebp
c0103210:	83 ec 18             	sub    $0x18,%esp
    int c = 0;
c0103213:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010321a:	e8 84 f7 ff ff       	call   c01029a3 <__intr_save>
c010321f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0103222:	e8 89 fd ff ff       	call   c0102fb0 <serial_intr>
        kbd_intr();
c0103227:	e8 33 ff ff ff       	call   c010315f <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c010322c:	8b 15 40 a7 12 c0    	mov    0xc012a740,%edx
c0103232:	a1 44 a7 12 c0       	mov    0xc012a744,%eax
c0103237:	39 c2                	cmp    %eax,%edx
c0103239:	74 31                	je     c010326c <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010323b:	a1 40 a7 12 c0       	mov    0xc012a740,%eax
c0103240:	8d 50 01             	lea    0x1(%eax),%edx
c0103243:	89 15 40 a7 12 c0    	mov    %edx,0xc012a740
c0103249:	0f b6 80 40 a5 12 c0 	movzbl -0x3fed5ac0(%eax),%eax
c0103250:	0f b6 c0             	movzbl %al,%eax
c0103253:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0103256:	a1 40 a7 12 c0       	mov    0xc012a740,%eax
c010325b:	3d 00 02 00 00       	cmp    $0x200,%eax
c0103260:	75 0a                	jne    c010326c <cons_getc+0x5f>
                cons.rpos = 0;
c0103262:	c7 05 40 a7 12 c0 00 	movl   $0x0,0xc012a740
c0103269:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c010326c:	83 ec 0c             	sub    $0xc,%esp
c010326f:	ff 75 f0             	pushl  -0x10(%ebp)
c0103272:	e8 56 f7 ff ff       	call   c01029cd <__intr_restore>
c0103277:	83 c4 10             	add    $0x10,%esp
    return c;
c010327a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010327d:	c9                   	leave  
c010327e:	c3                   	ret    

c010327f <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c010327f:	55                   	push   %ebp
c0103280:	89 e5                	mov    %esp,%ebp
c0103282:	83 ec 14             	sub    $0x14,%esp
c0103285:	8b 45 08             	mov    0x8(%ebp),%eax
c0103288:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c010328c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0103290:	66 a3 50 75 12 c0    	mov    %ax,0xc0127550
    if (did_init) {
c0103296:	a1 4c a7 12 c0       	mov    0xc012a74c,%eax
c010329b:	85 c0                	test   %eax,%eax
c010329d:	74 36                	je     c01032d5 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c010329f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01032a3:	0f b6 c0             	movzbl %al,%eax
c01032a6:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01032ac:	88 45 fa             	mov    %al,-0x6(%ebp)
c01032af:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
c01032b3:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01032b7:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c01032b8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01032bc:	66 c1 e8 08          	shr    $0x8,%ax
c01032c0:	0f b6 c0             	movzbl %al,%eax
c01032c3:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c01032c9:	88 45 fb             	mov    %al,-0x5(%ebp)
c01032cc:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
c01032d0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c01032d4:	ee                   	out    %al,(%dx)
    }
}
c01032d5:	90                   	nop
c01032d6:	c9                   	leave  
c01032d7:	c3                   	ret    

c01032d8 <pic_enable>:

void
pic_enable(unsigned int irq) {
c01032d8:	55                   	push   %ebp
c01032d9:	89 e5                	mov    %esp,%ebp
    pic_setmask(irq_mask & ~(1 << irq));
c01032db:	8b 45 08             	mov    0x8(%ebp),%eax
c01032de:	ba 01 00 00 00       	mov    $0x1,%edx
c01032e3:	89 c1                	mov    %eax,%ecx
c01032e5:	d3 e2                	shl    %cl,%edx
c01032e7:	89 d0                	mov    %edx,%eax
c01032e9:	f7 d0                	not    %eax
c01032eb:	89 c2                	mov    %eax,%edx
c01032ed:	0f b7 05 50 75 12 c0 	movzwl 0xc0127550,%eax
c01032f4:	21 d0                	and    %edx,%eax
c01032f6:	0f b7 c0             	movzwl %ax,%eax
c01032f9:	50                   	push   %eax
c01032fa:	e8 80 ff ff ff       	call   c010327f <pic_setmask>
c01032ff:	83 c4 04             	add    $0x4,%esp
}
c0103302:	90                   	nop
c0103303:	c9                   	leave  
c0103304:	c3                   	ret    

c0103305 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0103305:	55                   	push   %ebp
c0103306:	89 e5                	mov    %esp,%ebp
c0103308:	83 ec 30             	sub    $0x30,%esp
    did_init = 1;
c010330b:	c7 05 4c a7 12 c0 01 	movl   $0x1,0xc012a74c
c0103312:	00 00 00 
c0103315:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c010331b:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
c010331f:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
c0103323:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0103327:	ee                   	out    %al,(%dx)
c0103328:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c010332e:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
c0103332:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c0103336:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c010333a:	ee                   	out    %al,(%dx)
c010333b:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
c0103341:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
c0103345:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c0103349:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010334d:	ee                   	out    %al,(%dx)
c010334e:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
c0103354:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
c0103358:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010335c:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c0103360:	ee                   	out    %al,(%dx)
c0103361:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
c0103367:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
c010336b:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c010336f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0103373:	ee                   	out    %al,(%dx)
c0103374:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
c010337a:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
c010337e:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0103382:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c0103386:	ee                   	out    %al,(%dx)
c0103387:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
c010338d:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
c0103391:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0103395:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0103399:	ee                   	out    %al,(%dx)
c010339a:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
c01033a0:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
c01033a4:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01033a8:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c01033ac:	ee                   	out    %al,(%dx)
c01033ad:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c01033b3:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
c01033b7:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c01033bb:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01033bf:	ee                   	out    %al,(%dx)
c01033c0:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
c01033c6:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
c01033ca:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c01033ce:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c01033d2:	ee                   	out    %al,(%dx)
c01033d3:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
c01033d9:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
c01033dd:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c01033e1:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01033e5:	ee                   	out    %al,(%dx)
c01033e6:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
c01033ec:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
c01033f0:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01033f4:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01033f8:	ee                   	out    %al,(%dx)
c01033f9:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01033ff:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
c0103403:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
c0103407:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010340b:	ee                   	out    %al,(%dx)
c010340c:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
c0103412:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
c0103416:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
c010341a:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
c010341e:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010341f:	0f b7 05 50 75 12 c0 	movzwl 0xc0127550,%eax
c0103426:	66 83 f8 ff          	cmp    $0xffff,%ax
c010342a:	74 13                	je     c010343f <pic_init+0x13a>
        pic_setmask(irq_mask);
c010342c:	0f b7 05 50 75 12 c0 	movzwl 0xc0127550,%eax
c0103433:	0f b7 c0             	movzwl %ax,%eax
c0103436:	50                   	push   %eax
c0103437:	e8 43 fe ff ff       	call   c010327f <pic_setmask>
c010343c:	83 c4 04             	add    $0x4,%esp
    }
}
c010343f:	90                   	nop
c0103440:	c9                   	leave  
c0103441:	c3                   	ret    

c0103442 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0103442:	55                   	push   %ebp
c0103443:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c0103445:	fb                   	sti    
    sti();
}
c0103446:	90                   	nop
c0103447:	5d                   	pop    %ebp
c0103448:	c3                   	ret    

c0103449 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0103449:	55                   	push   %ebp
c010344a:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c010344c:	fa                   	cli    
    cli();
}
c010344d:	90                   	nop
c010344e:	5d                   	pop    %ebp
c010344f:	c3                   	ret    

c0103450 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0103450:	55                   	push   %ebp
c0103451:	89 e5                	mov    %esp,%ebp
c0103453:	83 ec 08             	sub    $0x8,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0103456:	83 ec 08             	sub    $0x8,%esp
c0103459:	6a 64                	push   $0x64
c010345b:	68 a0 af 10 c0       	push   $0xc010afa0
c0103460:	e8 25 ce ff ff       	call   c010028a <cprintf>
c0103465:	83 c4 10             	add    $0x10,%esp
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c0103468:	90                   	nop
c0103469:	c9                   	leave  
c010346a:	c3                   	ret    

c010346b <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c010346b:	55                   	push   %ebp
c010346c:	89 e5                	mov    %esp,%ebp
c010346e:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0103471:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0103478:	e9 c3 00 00 00       	jmp    c0103540 <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c010347d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103480:	8b 04 85 e0 75 12 c0 	mov    -0x3fed8a20(,%eax,4),%eax
c0103487:	89 c2                	mov    %eax,%edx
c0103489:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010348c:	66 89 14 c5 60 a7 12 	mov    %dx,-0x3fed58a0(,%eax,8)
c0103493:	c0 
c0103494:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103497:	66 c7 04 c5 62 a7 12 	movw   $0x8,-0x3fed589e(,%eax,8)
c010349e:	c0 08 00 
c01034a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01034a4:	0f b6 14 c5 64 a7 12 	movzbl -0x3fed589c(,%eax,8),%edx
c01034ab:	c0 
c01034ac:	83 e2 e0             	and    $0xffffffe0,%edx
c01034af:	88 14 c5 64 a7 12 c0 	mov    %dl,-0x3fed589c(,%eax,8)
c01034b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01034b9:	0f b6 14 c5 64 a7 12 	movzbl -0x3fed589c(,%eax,8),%edx
c01034c0:	c0 
c01034c1:	83 e2 1f             	and    $0x1f,%edx
c01034c4:	88 14 c5 64 a7 12 c0 	mov    %dl,-0x3fed589c(,%eax,8)
c01034cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01034ce:	0f b6 14 c5 65 a7 12 	movzbl -0x3fed589b(,%eax,8),%edx
c01034d5:	c0 
c01034d6:	83 e2 f0             	and    $0xfffffff0,%edx
c01034d9:	83 ca 0e             	or     $0xe,%edx
c01034dc:	88 14 c5 65 a7 12 c0 	mov    %dl,-0x3fed589b(,%eax,8)
c01034e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01034e6:	0f b6 14 c5 65 a7 12 	movzbl -0x3fed589b(,%eax,8),%edx
c01034ed:	c0 
c01034ee:	83 e2 ef             	and    $0xffffffef,%edx
c01034f1:	88 14 c5 65 a7 12 c0 	mov    %dl,-0x3fed589b(,%eax,8)
c01034f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01034fb:	0f b6 14 c5 65 a7 12 	movzbl -0x3fed589b(,%eax,8),%edx
c0103502:	c0 
c0103503:	83 e2 9f             	and    $0xffffff9f,%edx
c0103506:	88 14 c5 65 a7 12 c0 	mov    %dl,-0x3fed589b(,%eax,8)
c010350d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103510:	0f b6 14 c5 65 a7 12 	movzbl -0x3fed589b(,%eax,8),%edx
c0103517:	c0 
c0103518:	83 ca 80             	or     $0xffffff80,%edx
c010351b:	88 14 c5 65 a7 12 c0 	mov    %dl,-0x3fed589b(,%eax,8)
c0103522:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103525:	8b 04 85 e0 75 12 c0 	mov    -0x3fed8a20(,%eax,4),%eax
c010352c:	c1 e8 10             	shr    $0x10,%eax
c010352f:	89 c2                	mov    %eax,%edx
c0103531:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103534:	66 89 14 c5 66 a7 12 	mov    %dx,-0x3fed589a(,%eax,8)
c010353b:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c010353c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0103540:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103543:	3d ff 00 00 00       	cmp    $0xff,%eax
c0103548:	0f 86 2f ff ff ff    	jbe    c010347d <idt_init+0x12>
c010354e:	c7 45 f8 60 75 12 c0 	movl   $0xc0127560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0103555:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0103558:	0f 01 18             	lidtl  (%eax)
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
c010355b:	90                   	nop
c010355c:	c9                   	leave  
c010355d:	c3                   	ret    

c010355e <trapname>:

static const char *
trapname(int trapno) {
c010355e:	55                   	push   %ebp
c010355f:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0103561:	8b 45 08             	mov    0x8(%ebp),%eax
c0103564:	83 f8 13             	cmp    $0x13,%eax
c0103567:	77 0c                	ja     c0103575 <trapname+0x17>
        return excnames[trapno];
c0103569:	8b 45 08             	mov    0x8(%ebp),%eax
c010356c:	8b 04 85 80 b3 10 c0 	mov    -0x3fef4c80(,%eax,4),%eax
c0103573:	eb 18                	jmp    c010358d <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0103575:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0103579:	7e 0d                	jle    c0103588 <trapname+0x2a>
c010357b:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c010357f:	7f 07                	jg     c0103588 <trapname+0x2a>
        return "Hardware Interrupt";
c0103581:	b8 aa af 10 c0       	mov    $0xc010afaa,%eax
c0103586:	eb 05                	jmp    c010358d <trapname+0x2f>
    }
    return "(unknown trap)";
c0103588:	b8 bd af 10 c0       	mov    $0xc010afbd,%eax
}
c010358d:	5d                   	pop    %ebp
c010358e:	c3                   	ret    

c010358f <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c010358f:	55                   	push   %ebp
c0103590:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0103592:	8b 45 08             	mov    0x8(%ebp),%eax
c0103595:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0103599:	66 83 f8 08          	cmp    $0x8,%ax
c010359d:	0f 94 c0             	sete   %al
c01035a0:	0f b6 c0             	movzbl %al,%eax
}
c01035a3:	5d                   	pop    %ebp
c01035a4:	c3                   	ret    

c01035a5 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01035a5:	55                   	push   %ebp
c01035a6:	89 e5                	mov    %esp,%ebp
c01035a8:	83 ec 18             	sub    $0x18,%esp
    cprintf("trapframe at %p\n", tf);
c01035ab:	83 ec 08             	sub    $0x8,%esp
c01035ae:	ff 75 08             	pushl  0x8(%ebp)
c01035b1:	68 fe af 10 c0       	push   $0xc010affe
c01035b6:	e8 cf cc ff ff       	call   c010028a <cprintf>
c01035bb:	83 c4 10             	add    $0x10,%esp
    print_regs(&tf->tf_regs);
c01035be:	8b 45 08             	mov    0x8(%ebp),%eax
c01035c1:	83 ec 0c             	sub    $0xc,%esp
c01035c4:	50                   	push   %eax
c01035c5:	e8 b8 01 00 00       	call   c0103782 <print_regs>
c01035ca:	83 c4 10             	add    $0x10,%esp
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c01035cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01035d0:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c01035d4:	0f b7 c0             	movzwl %ax,%eax
c01035d7:	83 ec 08             	sub    $0x8,%esp
c01035da:	50                   	push   %eax
c01035db:	68 0f b0 10 c0       	push   $0xc010b00f
c01035e0:	e8 a5 cc ff ff       	call   c010028a <cprintf>
c01035e5:	83 c4 10             	add    $0x10,%esp
    cprintf("  es   0x----%04x\n", tf->tf_es);
c01035e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01035eb:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c01035ef:	0f b7 c0             	movzwl %ax,%eax
c01035f2:	83 ec 08             	sub    $0x8,%esp
c01035f5:	50                   	push   %eax
c01035f6:	68 22 b0 10 c0       	push   $0xc010b022
c01035fb:	e8 8a cc ff ff       	call   c010028a <cprintf>
c0103600:	83 c4 10             	add    $0x10,%esp
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0103603:	8b 45 08             	mov    0x8(%ebp),%eax
c0103606:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c010360a:	0f b7 c0             	movzwl %ax,%eax
c010360d:	83 ec 08             	sub    $0x8,%esp
c0103610:	50                   	push   %eax
c0103611:	68 35 b0 10 c0       	push   $0xc010b035
c0103616:	e8 6f cc ff ff       	call   c010028a <cprintf>
c010361b:	83 c4 10             	add    $0x10,%esp
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c010361e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103621:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0103625:	0f b7 c0             	movzwl %ax,%eax
c0103628:	83 ec 08             	sub    $0x8,%esp
c010362b:	50                   	push   %eax
c010362c:	68 48 b0 10 c0       	push   $0xc010b048
c0103631:	e8 54 cc ff ff       	call   c010028a <cprintf>
c0103636:	83 c4 10             	add    $0x10,%esp
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0103639:	8b 45 08             	mov    0x8(%ebp),%eax
c010363c:	8b 40 30             	mov    0x30(%eax),%eax
c010363f:	83 ec 0c             	sub    $0xc,%esp
c0103642:	50                   	push   %eax
c0103643:	e8 16 ff ff ff       	call   c010355e <trapname>
c0103648:	83 c4 10             	add    $0x10,%esp
c010364b:	89 c2                	mov    %eax,%edx
c010364d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103650:	8b 40 30             	mov    0x30(%eax),%eax
c0103653:	83 ec 04             	sub    $0x4,%esp
c0103656:	52                   	push   %edx
c0103657:	50                   	push   %eax
c0103658:	68 5b b0 10 c0       	push   $0xc010b05b
c010365d:	e8 28 cc ff ff       	call   c010028a <cprintf>
c0103662:	83 c4 10             	add    $0x10,%esp
    cprintf("  err  0x%08x\n", tf->tf_err);
c0103665:	8b 45 08             	mov    0x8(%ebp),%eax
c0103668:	8b 40 34             	mov    0x34(%eax),%eax
c010366b:	83 ec 08             	sub    $0x8,%esp
c010366e:	50                   	push   %eax
c010366f:	68 6d b0 10 c0       	push   $0xc010b06d
c0103674:	e8 11 cc ff ff       	call   c010028a <cprintf>
c0103679:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c010367c:	8b 45 08             	mov    0x8(%ebp),%eax
c010367f:	8b 40 38             	mov    0x38(%eax),%eax
c0103682:	83 ec 08             	sub    $0x8,%esp
c0103685:	50                   	push   %eax
c0103686:	68 7c b0 10 c0       	push   $0xc010b07c
c010368b:	e8 fa cb ff ff       	call   c010028a <cprintf>
c0103690:	83 c4 10             	add    $0x10,%esp
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0103693:	8b 45 08             	mov    0x8(%ebp),%eax
c0103696:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010369a:	0f b7 c0             	movzwl %ax,%eax
c010369d:	83 ec 08             	sub    $0x8,%esp
c01036a0:	50                   	push   %eax
c01036a1:	68 8b b0 10 c0       	push   $0xc010b08b
c01036a6:	e8 df cb ff ff       	call   c010028a <cprintf>
c01036ab:	83 c4 10             	add    $0x10,%esp
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01036ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01036b1:	8b 40 40             	mov    0x40(%eax),%eax
c01036b4:	83 ec 08             	sub    $0x8,%esp
c01036b7:	50                   	push   %eax
c01036b8:	68 9e b0 10 c0       	push   $0xc010b09e
c01036bd:	e8 c8 cb ff ff       	call   c010028a <cprintf>
c01036c2:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01036c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01036cc:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01036d3:	eb 3f                	jmp    c0103714 <print_trapframe+0x16f>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c01036d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01036d8:	8b 50 40             	mov    0x40(%eax),%edx
c01036db:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01036de:	21 d0                	and    %edx,%eax
c01036e0:	85 c0                	test   %eax,%eax
c01036e2:	74 29                	je     c010370d <print_trapframe+0x168>
c01036e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036e7:	8b 04 85 80 75 12 c0 	mov    -0x3fed8a80(,%eax,4),%eax
c01036ee:	85 c0                	test   %eax,%eax
c01036f0:	74 1b                	je     c010370d <print_trapframe+0x168>
            cprintf("%s,", IA32flags[i]);
c01036f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036f5:	8b 04 85 80 75 12 c0 	mov    -0x3fed8a80(,%eax,4),%eax
c01036fc:	83 ec 08             	sub    $0x8,%esp
c01036ff:	50                   	push   %eax
c0103700:	68 ad b0 10 c0       	push   $0xc010b0ad
c0103705:	e8 80 cb ff ff       	call   c010028a <cprintf>
c010370a:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c010370d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103711:	d1 65 f0             	shll   -0x10(%ebp)
c0103714:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103717:	83 f8 17             	cmp    $0x17,%eax
c010371a:	76 b9                	jbe    c01036d5 <print_trapframe+0x130>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c010371c:	8b 45 08             	mov    0x8(%ebp),%eax
c010371f:	8b 40 40             	mov    0x40(%eax),%eax
c0103722:	25 00 30 00 00       	and    $0x3000,%eax
c0103727:	c1 e8 0c             	shr    $0xc,%eax
c010372a:	83 ec 08             	sub    $0x8,%esp
c010372d:	50                   	push   %eax
c010372e:	68 b1 b0 10 c0       	push   $0xc010b0b1
c0103733:	e8 52 cb ff ff       	call   c010028a <cprintf>
c0103738:	83 c4 10             	add    $0x10,%esp

    if (!trap_in_kernel(tf)) {
c010373b:	83 ec 0c             	sub    $0xc,%esp
c010373e:	ff 75 08             	pushl  0x8(%ebp)
c0103741:	e8 49 fe ff ff       	call   c010358f <trap_in_kernel>
c0103746:	83 c4 10             	add    $0x10,%esp
c0103749:	85 c0                	test   %eax,%eax
c010374b:	75 32                	jne    c010377f <print_trapframe+0x1da>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c010374d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103750:	8b 40 44             	mov    0x44(%eax),%eax
c0103753:	83 ec 08             	sub    $0x8,%esp
c0103756:	50                   	push   %eax
c0103757:	68 ba b0 10 c0       	push   $0xc010b0ba
c010375c:	e8 29 cb ff ff       	call   c010028a <cprintf>
c0103761:	83 c4 10             	add    $0x10,%esp
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0103764:	8b 45 08             	mov    0x8(%ebp),%eax
c0103767:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c010376b:	0f b7 c0             	movzwl %ax,%eax
c010376e:	83 ec 08             	sub    $0x8,%esp
c0103771:	50                   	push   %eax
c0103772:	68 c9 b0 10 c0       	push   $0xc010b0c9
c0103777:	e8 0e cb ff ff       	call   c010028a <cprintf>
c010377c:	83 c4 10             	add    $0x10,%esp
    }
}
c010377f:	90                   	nop
c0103780:	c9                   	leave  
c0103781:	c3                   	ret    

c0103782 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0103782:	55                   	push   %ebp
c0103783:	89 e5                	mov    %esp,%ebp
c0103785:	83 ec 08             	sub    $0x8,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0103788:	8b 45 08             	mov    0x8(%ebp),%eax
c010378b:	8b 00                	mov    (%eax),%eax
c010378d:	83 ec 08             	sub    $0x8,%esp
c0103790:	50                   	push   %eax
c0103791:	68 dc b0 10 c0       	push   $0xc010b0dc
c0103796:	e8 ef ca ff ff       	call   c010028a <cprintf>
c010379b:	83 c4 10             	add    $0x10,%esp
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c010379e:	8b 45 08             	mov    0x8(%ebp),%eax
c01037a1:	8b 40 04             	mov    0x4(%eax),%eax
c01037a4:	83 ec 08             	sub    $0x8,%esp
c01037a7:	50                   	push   %eax
c01037a8:	68 eb b0 10 c0       	push   $0xc010b0eb
c01037ad:	e8 d8 ca ff ff       	call   c010028a <cprintf>
c01037b2:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01037b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01037b8:	8b 40 08             	mov    0x8(%eax),%eax
c01037bb:	83 ec 08             	sub    $0x8,%esp
c01037be:	50                   	push   %eax
c01037bf:	68 fa b0 10 c0       	push   $0xc010b0fa
c01037c4:	e8 c1 ca ff ff       	call   c010028a <cprintf>
c01037c9:	83 c4 10             	add    $0x10,%esp
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01037cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01037cf:	8b 40 0c             	mov    0xc(%eax),%eax
c01037d2:	83 ec 08             	sub    $0x8,%esp
c01037d5:	50                   	push   %eax
c01037d6:	68 09 b1 10 c0       	push   $0xc010b109
c01037db:	e8 aa ca ff ff       	call   c010028a <cprintf>
c01037e0:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c01037e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01037e6:	8b 40 10             	mov    0x10(%eax),%eax
c01037e9:	83 ec 08             	sub    $0x8,%esp
c01037ec:	50                   	push   %eax
c01037ed:	68 18 b1 10 c0       	push   $0xc010b118
c01037f2:	e8 93 ca ff ff       	call   c010028a <cprintf>
c01037f7:	83 c4 10             	add    $0x10,%esp
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c01037fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01037fd:	8b 40 14             	mov    0x14(%eax),%eax
c0103800:	83 ec 08             	sub    $0x8,%esp
c0103803:	50                   	push   %eax
c0103804:	68 27 b1 10 c0       	push   $0xc010b127
c0103809:	e8 7c ca ff ff       	call   c010028a <cprintf>
c010380e:	83 c4 10             	add    $0x10,%esp
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0103811:	8b 45 08             	mov    0x8(%ebp),%eax
c0103814:	8b 40 18             	mov    0x18(%eax),%eax
c0103817:	83 ec 08             	sub    $0x8,%esp
c010381a:	50                   	push   %eax
c010381b:	68 36 b1 10 c0       	push   $0xc010b136
c0103820:	e8 65 ca ff ff       	call   c010028a <cprintf>
c0103825:	83 c4 10             	add    $0x10,%esp
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0103828:	8b 45 08             	mov    0x8(%ebp),%eax
c010382b:	8b 40 1c             	mov    0x1c(%eax),%eax
c010382e:	83 ec 08             	sub    $0x8,%esp
c0103831:	50                   	push   %eax
c0103832:	68 45 b1 10 c0       	push   $0xc010b145
c0103837:	e8 4e ca ff ff       	call   c010028a <cprintf>
c010383c:	83 c4 10             	add    $0x10,%esp
}
c010383f:	90                   	nop
c0103840:	c9                   	leave  
c0103841:	c3                   	ret    

c0103842 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0103842:	55                   	push   %ebp
c0103843:	89 e5                	mov    %esp,%ebp
c0103845:	53                   	push   %ebx
c0103846:	83 ec 14             	sub    $0x14,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0103849:	8b 45 08             	mov    0x8(%ebp),%eax
c010384c:	8b 40 34             	mov    0x34(%eax),%eax
c010384f:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0103852:	85 c0                	test   %eax,%eax
c0103854:	74 07                	je     c010385d <print_pgfault+0x1b>
c0103856:	bb 54 b1 10 c0       	mov    $0xc010b154,%ebx
c010385b:	eb 05                	jmp    c0103862 <print_pgfault+0x20>
c010385d:	bb 65 b1 10 c0       	mov    $0xc010b165,%ebx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c0103862:	8b 45 08             	mov    0x8(%ebp),%eax
c0103865:	8b 40 34             	mov    0x34(%eax),%eax
c0103868:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010386b:	85 c0                	test   %eax,%eax
c010386d:	74 07                	je     c0103876 <print_pgfault+0x34>
c010386f:	b9 57 00 00 00       	mov    $0x57,%ecx
c0103874:	eb 05                	jmp    c010387b <print_pgfault+0x39>
c0103876:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c010387b:	8b 45 08             	mov    0x8(%ebp),%eax
c010387e:	8b 40 34             	mov    0x34(%eax),%eax
c0103881:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0103884:	85 c0                	test   %eax,%eax
c0103886:	74 07                	je     c010388f <print_pgfault+0x4d>
c0103888:	ba 55 00 00 00       	mov    $0x55,%edx
c010388d:	eb 05                	jmp    c0103894 <print_pgfault+0x52>
c010388f:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0103894:	0f 20 d0             	mov    %cr2,%eax
c0103897:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c010389a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010389d:	83 ec 0c             	sub    $0xc,%esp
c01038a0:	53                   	push   %ebx
c01038a1:	51                   	push   %ecx
c01038a2:	52                   	push   %edx
c01038a3:	50                   	push   %eax
c01038a4:	68 74 b1 10 c0       	push   $0xc010b174
c01038a9:	e8 dc c9 ff ff       	call   c010028a <cprintf>
c01038ae:	83 c4 20             	add    $0x20,%esp
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c01038b1:	90                   	nop
c01038b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01038b5:	c9                   	leave  
c01038b6:	c3                   	ret    

c01038b7 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01038b7:	55                   	push   %ebp
c01038b8:	89 e5                	mov    %esp,%ebp
c01038ba:	83 ec 18             	sub    $0x18,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c01038bd:	83 ec 0c             	sub    $0xc,%esp
c01038c0:	ff 75 08             	pushl  0x8(%ebp)
c01038c3:	e8 7a ff ff ff       	call   c0103842 <print_pgfault>
c01038c8:	83 c4 10             	add    $0x10,%esp
    if (check_mm_struct != NULL) {
c01038cb:	a1 58 d0 12 c0       	mov    0xc012d058,%eax
c01038d0:	85 c0                	test   %eax,%eax
c01038d2:	74 24                	je     c01038f8 <pgfault_handler+0x41>
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01038d4:	0f 20 d0             	mov    %cr2,%eax
c01038d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01038da:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c01038dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01038e0:	8b 50 34             	mov    0x34(%eax),%edx
c01038e3:	a1 58 d0 12 c0       	mov    0xc012d058,%eax
c01038e8:	83 ec 04             	sub    $0x4,%esp
c01038eb:	51                   	push   %ecx
c01038ec:	52                   	push   %edx
c01038ed:	50                   	push   %eax
c01038ee:	e8 58 16 00 00       	call   c0104f4b <do_pgfault>
c01038f3:	83 c4 10             	add    $0x10,%esp
c01038f6:	eb 17                	jmp    c010390f <pgfault_handler+0x58>
    }
    panic("unhandled page fault.\n");
c01038f8:	83 ec 04             	sub    $0x4,%esp
c01038fb:	68 97 b1 10 c0       	push   $0xc010b197
c0103900:	68 a5 00 00 00       	push   $0xa5
c0103905:	68 ae b1 10 c0       	push   $0xc010b1ae
c010390a:	e8 59 de ff ff       	call   c0101768 <__panic>
}
c010390f:	c9                   	leave  
c0103910:	c3                   	ret    

c0103911 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c0103911:	55                   	push   %ebp
c0103912:	89 e5                	mov    %esp,%ebp
c0103914:	83 ec 18             	sub    $0x18,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c0103917:	8b 45 08             	mov    0x8(%ebp),%eax
c010391a:	8b 40 30             	mov    0x30(%eax),%eax
c010391d:	83 f8 24             	cmp    $0x24,%eax
c0103920:	0f 84 ba 00 00 00    	je     c01039e0 <trap_dispatch+0xcf>
c0103926:	83 f8 24             	cmp    $0x24,%eax
c0103929:	77 18                	ja     c0103943 <trap_dispatch+0x32>
c010392b:	83 f8 20             	cmp    $0x20,%eax
c010392e:	74 76                	je     c01039a6 <trap_dispatch+0x95>
c0103930:	83 f8 21             	cmp    $0x21,%eax
c0103933:	0f 84 cb 00 00 00    	je     c0103a04 <trap_dispatch+0xf3>
c0103939:	83 f8 0e             	cmp    $0xe,%eax
c010393c:	74 28                	je     c0103966 <trap_dispatch+0x55>
c010393e:	e9 fc 00 00 00       	jmp    c0103a3f <trap_dispatch+0x12e>
c0103943:	83 f8 2e             	cmp    $0x2e,%eax
c0103946:	0f 82 f3 00 00 00    	jb     c0103a3f <trap_dispatch+0x12e>
c010394c:	83 f8 2f             	cmp    $0x2f,%eax
c010394f:	0f 86 20 01 00 00    	jbe    c0103a75 <trap_dispatch+0x164>
c0103955:	83 e8 78             	sub    $0x78,%eax
c0103958:	83 f8 01             	cmp    $0x1,%eax
c010395b:	0f 87 de 00 00 00    	ja     c0103a3f <trap_dispatch+0x12e>
c0103961:	e9 c2 00 00 00       	jmp    c0103a28 <trap_dispatch+0x117>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c0103966:	83 ec 0c             	sub    $0xc,%esp
c0103969:	ff 75 08             	pushl  0x8(%ebp)
c010396c:	e8 46 ff ff ff       	call   c01038b7 <pgfault_handler>
c0103971:	83 c4 10             	add    $0x10,%esp
c0103974:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103977:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010397b:	0f 84 f7 00 00 00    	je     c0103a78 <trap_dispatch+0x167>
            print_trapframe(tf);
c0103981:	83 ec 0c             	sub    $0xc,%esp
c0103984:	ff 75 08             	pushl  0x8(%ebp)
c0103987:	e8 19 fc ff ff       	call   c01035a5 <print_trapframe>
c010398c:	83 c4 10             	add    $0x10,%esp
            panic("handle pgfault failed. %e\n", ret);
c010398f:	ff 75 f4             	pushl  -0xc(%ebp)
c0103992:	68 bf b1 10 c0       	push   $0xc010b1bf
c0103997:	68 b5 00 00 00       	push   $0xb5
c010399c:	68 ae b1 10 c0       	push   $0xc010b1ae
c01039a1:	e8 c2 dd ff ff       	call   c0101768 <__panic>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c01039a6:	a1 54 d0 12 c0       	mov    0xc012d054,%eax
c01039ab:	83 c0 01             	add    $0x1,%eax
c01039ae:	a3 54 d0 12 c0       	mov    %eax,0xc012d054
        if (ticks % TICK_NUM == 0) {
c01039b3:	8b 0d 54 d0 12 c0    	mov    0xc012d054,%ecx
c01039b9:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c01039be:	89 c8                	mov    %ecx,%eax
c01039c0:	f7 e2                	mul    %edx
c01039c2:	89 d0                	mov    %edx,%eax
c01039c4:	c1 e8 05             	shr    $0x5,%eax
c01039c7:	6b c0 64             	imul   $0x64,%eax,%eax
c01039ca:	29 c1                	sub    %eax,%ecx
c01039cc:	89 c8                	mov    %ecx,%eax
c01039ce:	85 c0                	test   %eax,%eax
c01039d0:	0f 85 a5 00 00 00    	jne    c0103a7b <trap_dispatch+0x16a>
            print_ticks();
c01039d6:	e8 75 fa ff ff       	call   c0103450 <print_ticks>
        }
        break;
c01039db:	e9 9b 00 00 00       	jmp    c0103a7b <trap_dispatch+0x16a>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c01039e0:	e8 28 f8 ff ff       	call   c010320d <cons_getc>
c01039e5:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c01039e8:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c01039ec:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c01039f0:	83 ec 04             	sub    $0x4,%esp
c01039f3:	52                   	push   %edx
c01039f4:	50                   	push   %eax
c01039f5:	68 da b1 10 c0       	push   $0xc010b1da
c01039fa:	e8 8b c8 ff ff       	call   c010028a <cprintf>
c01039ff:	83 c4 10             	add    $0x10,%esp
        break;
c0103a02:	eb 78                	jmp    c0103a7c <trap_dispatch+0x16b>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0103a04:	e8 04 f8 ff ff       	call   c010320d <cons_getc>
c0103a09:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0103a0c:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0103a10:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0103a14:	83 ec 04             	sub    $0x4,%esp
c0103a17:	52                   	push   %edx
c0103a18:	50                   	push   %eax
c0103a19:	68 ec b1 10 c0       	push   $0xc010b1ec
c0103a1e:	e8 67 c8 ff ff       	call   c010028a <cprintf>
c0103a23:	83 c4 10             	add    $0x10,%esp
        break;
c0103a26:	eb 54                	jmp    c0103a7c <trap_dispatch+0x16b>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0103a28:	83 ec 04             	sub    $0x4,%esp
c0103a2b:	68 fb b1 10 c0       	push   $0xc010b1fb
c0103a30:	68 d3 00 00 00       	push   $0xd3
c0103a35:	68 ae b1 10 c0       	push   $0xc010b1ae
c0103a3a:	e8 29 dd ff ff       	call   c0101768 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0103a3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a42:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0103a46:	0f b7 c0             	movzwl %ax,%eax
c0103a49:	83 e0 03             	and    $0x3,%eax
c0103a4c:	85 c0                	test   %eax,%eax
c0103a4e:	75 2c                	jne    c0103a7c <trap_dispatch+0x16b>
            print_trapframe(tf);
c0103a50:	83 ec 0c             	sub    $0xc,%esp
c0103a53:	ff 75 08             	pushl  0x8(%ebp)
c0103a56:	e8 4a fb ff ff       	call   c01035a5 <print_trapframe>
c0103a5b:	83 c4 10             	add    $0x10,%esp
            panic("unexpected trap in kernel.\n");
c0103a5e:	83 ec 04             	sub    $0x4,%esp
c0103a61:	68 0b b2 10 c0       	push   $0xc010b20b
c0103a66:	68 dd 00 00 00       	push   $0xdd
c0103a6b:	68 ae b1 10 c0       	push   $0xc010b1ae
c0103a70:	e8 f3 dc ff ff       	call   c0101768 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0103a75:	90                   	nop
c0103a76:	eb 04                	jmp    c0103a7c <trap_dispatch+0x16b>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
            print_trapframe(tf);
            panic("handle pgfault failed. %e\n", ret);
        }
        break;
c0103a78:	90                   	nop
c0103a79:	eb 01                	jmp    c0103a7c <trap_dispatch+0x16b>
         */
        ticks ++;
        if (ticks % TICK_NUM == 0) {
            print_ticks();
        }
        break;
c0103a7b:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0103a7c:	90                   	nop
c0103a7d:	c9                   	leave  
c0103a7e:	c3                   	ret    

c0103a7f <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0103a7f:	55                   	push   %ebp
c0103a80:	89 e5                	mov    %esp,%ebp
c0103a82:	83 ec 08             	sub    $0x8,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0103a85:	83 ec 0c             	sub    $0xc,%esp
c0103a88:	ff 75 08             	pushl  0x8(%ebp)
c0103a8b:	e8 81 fe ff ff       	call   c0103911 <trap_dispatch>
c0103a90:	83 c4 10             	add    $0x10,%esp
}
c0103a93:	90                   	nop
c0103a94:	c9                   	leave  
c0103a95:	c3                   	ret    

c0103a96 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0103a96:	6a 00                	push   $0x0
  pushl $0
c0103a98:	6a 00                	push   $0x0
  jmp __alltraps
c0103a9a:	e9 67 0a 00 00       	jmp    c0104506 <__alltraps>

c0103a9f <vector1>:
.globl vector1
vector1:
  pushl $0
c0103a9f:	6a 00                	push   $0x0
  pushl $1
c0103aa1:	6a 01                	push   $0x1
  jmp __alltraps
c0103aa3:	e9 5e 0a 00 00       	jmp    c0104506 <__alltraps>

c0103aa8 <vector2>:
.globl vector2
vector2:
  pushl $0
c0103aa8:	6a 00                	push   $0x0
  pushl $2
c0103aaa:	6a 02                	push   $0x2
  jmp __alltraps
c0103aac:	e9 55 0a 00 00       	jmp    c0104506 <__alltraps>

c0103ab1 <vector3>:
.globl vector3
vector3:
  pushl $0
c0103ab1:	6a 00                	push   $0x0
  pushl $3
c0103ab3:	6a 03                	push   $0x3
  jmp __alltraps
c0103ab5:	e9 4c 0a 00 00       	jmp    c0104506 <__alltraps>

c0103aba <vector4>:
.globl vector4
vector4:
  pushl $0
c0103aba:	6a 00                	push   $0x0
  pushl $4
c0103abc:	6a 04                	push   $0x4
  jmp __alltraps
c0103abe:	e9 43 0a 00 00       	jmp    c0104506 <__alltraps>

c0103ac3 <vector5>:
.globl vector5
vector5:
  pushl $0
c0103ac3:	6a 00                	push   $0x0
  pushl $5
c0103ac5:	6a 05                	push   $0x5
  jmp __alltraps
c0103ac7:	e9 3a 0a 00 00       	jmp    c0104506 <__alltraps>

c0103acc <vector6>:
.globl vector6
vector6:
  pushl $0
c0103acc:	6a 00                	push   $0x0
  pushl $6
c0103ace:	6a 06                	push   $0x6
  jmp __alltraps
c0103ad0:	e9 31 0a 00 00       	jmp    c0104506 <__alltraps>

c0103ad5 <vector7>:
.globl vector7
vector7:
  pushl $0
c0103ad5:	6a 00                	push   $0x0
  pushl $7
c0103ad7:	6a 07                	push   $0x7
  jmp __alltraps
c0103ad9:	e9 28 0a 00 00       	jmp    c0104506 <__alltraps>

c0103ade <vector8>:
.globl vector8
vector8:
  pushl $8
c0103ade:	6a 08                	push   $0x8
  jmp __alltraps
c0103ae0:	e9 21 0a 00 00       	jmp    c0104506 <__alltraps>

c0103ae5 <vector9>:
.globl vector9
vector9:
  pushl $9
c0103ae5:	6a 09                	push   $0x9
  jmp __alltraps
c0103ae7:	e9 1a 0a 00 00       	jmp    c0104506 <__alltraps>

c0103aec <vector10>:
.globl vector10
vector10:
  pushl $10
c0103aec:	6a 0a                	push   $0xa
  jmp __alltraps
c0103aee:	e9 13 0a 00 00       	jmp    c0104506 <__alltraps>

c0103af3 <vector11>:
.globl vector11
vector11:
  pushl $11
c0103af3:	6a 0b                	push   $0xb
  jmp __alltraps
c0103af5:	e9 0c 0a 00 00       	jmp    c0104506 <__alltraps>

c0103afa <vector12>:
.globl vector12
vector12:
  pushl $12
c0103afa:	6a 0c                	push   $0xc
  jmp __alltraps
c0103afc:	e9 05 0a 00 00       	jmp    c0104506 <__alltraps>

c0103b01 <vector13>:
.globl vector13
vector13:
  pushl $13
c0103b01:	6a 0d                	push   $0xd
  jmp __alltraps
c0103b03:	e9 fe 09 00 00       	jmp    c0104506 <__alltraps>

c0103b08 <vector14>:
.globl vector14
vector14:
  pushl $14
c0103b08:	6a 0e                	push   $0xe
  jmp __alltraps
c0103b0a:	e9 f7 09 00 00       	jmp    c0104506 <__alltraps>

c0103b0f <vector15>:
.globl vector15
vector15:
  pushl $0
c0103b0f:	6a 00                	push   $0x0
  pushl $15
c0103b11:	6a 0f                	push   $0xf
  jmp __alltraps
c0103b13:	e9 ee 09 00 00       	jmp    c0104506 <__alltraps>

c0103b18 <vector16>:
.globl vector16
vector16:
  pushl $0
c0103b18:	6a 00                	push   $0x0
  pushl $16
c0103b1a:	6a 10                	push   $0x10
  jmp __alltraps
c0103b1c:	e9 e5 09 00 00       	jmp    c0104506 <__alltraps>

c0103b21 <vector17>:
.globl vector17
vector17:
  pushl $17
c0103b21:	6a 11                	push   $0x11
  jmp __alltraps
c0103b23:	e9 de 09 00 00       	jmp    c0104506 <__alltraps>

c0103b28 <vector18>:
.globl vector18
vector18:
  pushl $0
c0103b28:	6a 00                	push   $0x0
  pushl $18
c0103b2a:	6a 12                	push   $0x12
  jmp __alltraps
c0103b2c:	e9 d5 09 00 00       	jmp    c0104506 <__alltraps>

c0103b31 <vector19>:
.globl vector19
vector19:
  pushl $0
c0103b31:	6a 00                	push   $0x0
  pushl $19
c0103b33:	6a 13                	push   $0x13
  jmp __alltraps
c0103b35:	e9 cc 09 00 00       	jmp    c0104506 <__alltraps>

c0103b3a <vector20>:
.globl vector20
vector20:
  pushl $0
c0103b3a:	6a 00                	push   $0x0
  pushl $20
c0103b3c:	6a 14                	push   $0x14
  jmp __alltraps
c0103b3e:	e9 c3 09 00 00       	jmp    c0104506 <__alltraps>

c0103b43 <vector21>:
.globl vector21
vector21:
  pushl $0
c0103b43:	6a 00                	push   $0x0
  pushl $21
c0103b45:	6a 15                	push   $0x15
  jmp __alltraps
c0103b47:	e9 ba 09 00 00       	jmp    c0104506 <__alltraps>

c0103b4c <vector22>:
.globl vector22
vector22:
  pushl $0
c0103b4c:	6a 00                	push   $0x0
  pushl $22
c0103b4e:	6a 16                	push   $0x16
  jmp __alltraps
c0103b50:	e9 b1 09 00 00       	jmp    c0104506 <__alltraps>

c0103b55 <vector23>:
.globl vector23
vector23:
  pushl $0
c0103b55:	6a 00                	push   $0x0
  pushl $23
c0103b57:	6a 17                	push   $0x17
  jmp __alltraps
c0103b59:	e9 a8 09 00 00       	jmp    c0104506 <__alltraps>

c0103b5e <vector24>:
.globl vector24
vector24:
  pushl $0
c0103b5e:	6a 00                	push   $0x0
  pushl $24
c0103b60:	6a 18                	push   $0x18
  jmp __alltraps
c0103b62:	e9 9f 09 00 00       	jmp    c0104506 <__alltraps>

c0103b67 <vector25>:
.globl vector25
vector25:
  pushl $0
c0103b67:	6a 00                	push   $0x0
  pushl $25
c0103b69:	6a 19                	push   $0x19
  jmp __alltraps
c0103b6b:	e9 96 09 00 00       	jmp    c0104506 <__alltraps>

c0103b70 <vector26>:
.globl vector26
vector26:
  pushl $0
c0103b70:	6a 00                	push   $0x0
  pushl $26
c0103b72:	6a 1a                	push   $0x1a
  jmp __alltraps
c0103b74:	e9 8d 09 00 00       	jmp    c0104506 <__alltraps>

c0103b79 <vector27>:
.globl vector27
vector27:
  pushl $0
c0103b79:	6a 00                	push   $0x0
  pushl $27
c0103b7b:	6a 1b                	push   $0x1b
  jmp __alltraps
c0103b7d:	e9 84 09 00 00       	jmp    c0104506 <__alltraps>

c0103b82 <vector28>:
.globl vector28
vector28:
  pushl $0
c0103b82:	6a 00                	push   $0x0
  pushl $28
c0103b84:	6a 1c                	push   $0x1c
  jmp __alltraps
c0103b86:	e9 7b 09 00 00       	jmp    c0104506 <__alltraps>

c0103b8b <vector29>:
.globl vector29
vector29:
  pushl $0
c0103b8b:	6a 00                	push   $0x0
  pushl $29
c0103b8d:	6a 1d                	push   $0x1d
  jmp __alltraps
c0103b8f:	e9 72 09 00 00       	jmp    c0104506 <__alltraps>

c0103b94 <vector30>:
.globl vector30
vector30:
  pushl $0
c0103b94:	6a 00                	push   $0x0
  pushl $30
c0103b96:	6a 1e                	push   $0x1e
  jmp __alltraps
c0103b98:	e9 69 09 00 00       	jmp    c0104506 <__alltraps>

c0103b9d <vector31>:
.globl vector31
vector31:
  pushl $0
c0103b9d:	6a 00                	push   $0x0
  pushl $31
c0103b9f:	6a 1f                	push   $0x1f
  jmp __alltraps
c0103ba1:	e9 60 09 00 00       	jmp    c0104506 <__alltraps>

c0103ba6 <vector32>:
.globl vector32
vector32:
  pushl $0
c0103ba6:	6a 00                	push   $0x0
  pushl $32
c0103ba8:	6a 20                	push   $0x20
  jmp __alltraps
c0103baa:	e9 57 09 00 00       	jmp    c0104506 <__alltraps>

c0103baf <vector33>:
.globl vector33
vector33:
  pushl $0
c0103baf:	6a 00                	push   $0x0
  pushl $33
c0103bb1:	6a 21                	push   $0x21
  jmp __alltraps
c0103bb3:	e9 4e 09 00 00       	jmp    c0104506 <__alltraps>

c0103bb8 <vector34>:
.globl vector34
vector34:
  pushl $0
c0103bb8:	6a 00                	push   $0x0
  pushl $34
c0103bba:	6a 22                	push   $0x22
  jmp __alltraps
c0103bbc:	e9 45 09 00 00       	jmp    c0104506 <__alltraps>

c0103bc1 <vector35>:
.globl vector35
vector35:
  pushl $0
c0103bc1:	6a 00                	push   $0x0
  pushl $35
c0103bc3:	6a 23                	push   $0x23
  jmp __alltraps
c0103bc5:	e9 3c 09 00 00       	jmp    c0104506 <__alltraps>

c0103bca <vector36>:
.globl vector36
vector36:
  pushl $0
c0103bca:	6a 00                	push   $0x0
  pushl $36
c0103bcc:	6a 24                	push   $0x24
  jmp __alltraps
c0103bce:	e9 33 09 00 00       	jmp    c0104506 <__alltraps>

c0103bd3 <vector37>:
.globl vector37
vector37:
  pushl $0
c0103bd3:	6a 00                	push   $0x0
  pushl $37
c0103bd5:	6a 25                	push   $0x25
  jmp __alltraps
c0103bd7:	e9 2a 09 00 00       	jmp    c0104506 <__alltraps>

c0103bdc <vector38>:
.globl vector38
vector38:
  pushl $0
c0103bdc:	6a 00                	push   $0x0
  pushl $38
c0103bde:	6a 26                	push   $0x26
  jmp __alltraps
c0103be0:	e9 21 09 00 00       	jmp    c0104506 <__alltraps>

c0103be5 <vector39>:
.globl vector39
vector39:
  pushl $0
c0103be5:	6a 00                	push   $0x0
  pushl $39
c0103be7:	6a 27                	push   $0x27
  jmp __alltraps
c0103be9:	e9 18 09 00 00       	jmp    c0104506 <__alltraps>

c0103bee <vector40>:
.globl vector40
vector40:
  pushl $0
c0103bee:	6a 00                	push   $0x0
  pushl $40
c0103bf0:	6a 28                	push   $0x28
  jmp __alltraps
c0103bf2:	e9 0f 09 00 00       	jmp    c0104506 <__alltraps>

c0103bf7 <vector41>:
.globl vector41
vector41:
  pushl $0
c0103bf7:	6a 00                	push   $0x0
  pushl $41
c0103bf9:	6a 29                	push   $0x29
  jmp __alltraps
c0103bfb:	e9 06 09 00 00       	jmp    c0104506 <__alltraps>

c0103c00 <vector42>:
.globl vector42
vector42:
  pushl $0
c0103c00:	6a 00                	push   $0x0
  pushl $42
c0103c02:	6a 2a                	push   $0x2a
  jmp __alltraps
c0103c04:	e9 fd 08 00 00       	jmp    c0104506 <__alltraps>

c0103c09 <vector43>:
.globl vector43
vector43:
  pushl $0
c0103c09:	6a 00                	push   $0x0
  pushl $43
c0103c0b:	6a 2b                	push   $0x2b
  jmp __alltraps
c0103c0d:	e9 f4 08 00 00       	jmp    c0104506 <__alltraps>

c0103c12 <vector44>:
.globl vector44
vector44:
  pushl $0
c0103c12:	6a 00                	push   $0x0
  pushl $44
c0103c14:	6a 2c                	push   $0x2c
  jmp __alltraps
c0103c16:	e9 eb 08 00 00       	jmp    c0104506 <__alltraps>

c0103c1b <vector45>:
.globl vector45
vector45:
  pushl $0
c0103c1b:	6a 00                	push   $0x0
  pushl $45
c0103c1d:	6a 2d                	push   $0x2d
  jmp __alltraps
c0103c1f:	e9 e2 08 00 00       	jmp    c0104506 <__alltraps>

c0103c24 <vector46>:
.globl vector46
vector46:
  pushl $0
c0103c24:	6a 00                	push   $0x0
  pushl $46
c0103c26:	6a 2e                	push   $0x2e
  jmp __alltraps
c0103c28:	e9 d9 08 00 00       	jmp    c0104506 <__alltraps>

c0103c2d <vector47>:
.globl vector47
vector47:
  pushl $0
c0103c2d:	6a 00                	push   $0x0
  pushl $47
c0103c2f:	6a 2f                	push   $0x2f
  jmp __alltraps
c0103c31:	e9 d0 08 00 00       	jmp    c0104506 <__alltraps>

c0103c36 <vector48>:
.globl vector48
vector48:
  pushl $0
c0103c36:	6a 00                	push   $0x0
  pushl $48
c0103c38:	6a 30                	push   $0x30
  jmp __alltraps
c0103c3a:	e9 c7 08 00 00       	jmp    c0104506 <__alltraps>

c0103c3f <vector49>:
.globl vector49
vector49:
  pushl $0
c0103c3f:	6a 00                	push   $0x0
  pushl $49
c0103c41:	6a 31                	push   $0x31
  jmp __alltraps
c0103c43:	e9 be 08 00 00       	jmp    c0104506 <__alltraps>

c0103c48 <vector50>:
.globl vector50
vector50:
  pushl $0
c0103c48:	6a 00                	push   $0x0
  pushl $50
c0103c4a:	6a 32                	push   $0x32
  jmp __alltraps
c0103c4c:	e9 b5 08 00 00       	jmp    c0104506 <__alltraps>

c0103c51 <vector51>:
.globl vector51
vector51:
  pushl $0
c0103c51:	6a 00                	push   $0x0
  pushl $51
c0103c53:	6a 33                	push   $0x33
  jmp __alltraps
c0103c55:	e9 ac 08 00 00       	jmp    c0104506 <__alltraps>

c0103c5a <vector52>:
.globl vector52
vector52:
  pushl $0
c0103c5a:	6a 00                	push   $0x0
  pushl $52
c0103c5c:	6a 34                	push   $0x34
  jmp __alltraps
c0103c5e:	e9 a3 08 00 00       	jmp    c0104506 <__alltraps>

c0103c63 <vector53>:
.globl vector53
vector53:
  pushl $0
c0103c63:	6a 00                	push   $0x0
  pushl $53
c0103c65:	6a 35                	push   $0x35
  jmp __alltraps
c0103c67:	e9 9a 08 00 00       	jmp    c0104506 <__alltraps>

c0103c6c <vector54>:
.globl vector54
vector54:
  pushl $0
c0103c6c:	6a 00                	push   $0x0
  pushl $54
c0103c6e:	6a 36                	push   $0x36
  jmp __alltraps
c0103c70:	e9 91 08 00 00       	jmp    c0104506 <__alltraps>

c0103c75 <vector55>:
.globl vector55
vector55:
  pushl $0
c0103c75:	6a 00                	push   $0x0
  pushl $55
c0103c77:	6a 37                	push   $0x37
  jmp __alltraps
c0103c79:	e9 88 08 00 00       	jmp    c0104506 <__alltraps>

c0103c7e <vector56>:
.globl vector56
vector56:
  pushl $0
c0103c7e:	6a 00                	push   $0x0
  pushl $56
c0103c80:	6a 38                	push   $0x38
  jmp __alltraps
c0103c82:	e9 7f 08 00 00       	jmp    c0104506 <__alltraps>

c0103c87 <vector57>:
.globl vector57
vector57:
  pushl $0
c0103c87:	6a 00                	push   $0x0
  pushl $57
c0103c89:	6a 39                	push   $0x39
  jmp __alltraps
c0103c8b:	e9 76 08 00 00       	jmp    c0104506 <__alltraps>

c0103c90 <vector58>:
.globl vector58
vector58:
  pushl $0
c0103c90:	6a 00                	push   $0x0
  pushl $58
c0103c92:	6a 3a                	push   $0x3a
  jmp __alltraps
c0103c94:	e9 6d 08 00 00       	jmp    c0104506 <__alltraps>

c0103c99 <vector59>:
.globl vector59
vector59:
  pushl $0
c0103c99:	6a 00                	push   $0x0
  pushl $59
c0103c9b:	6a 3b                	push   $0x3b
  jmp __alltraps
c0103c9d:	e9 64 08 00 00       	jmp    c0104506 <__alltraps>

c0103ca2 <vector60>:
.globl vector60
vector60:
  pushl $0
c0103ca2:	6a 00                	push   $0x0
  pushl $60
c0103ca4:	6a 3c                	push   $0x3c
  jmp __alltraps
c0103ca6:	e9 5b 08 00 00       	jmp    c0104506 <__alltraps>

c0103cab <vector61>:
.globl vector61
vector61:
  pushl $0
c0103cab:	6a 00                	push   $0x0
  pushl $61
c0103cad:	6a 3d                	push   $0x3d
  jmp __alltraps
c0103caf:	e9 52 08 00 00       	jmp    c0104506 <__alltraps>

c0103cb4 <vector62>:
.globl vector62
vector62:
  pushl $0
c0103cb4:	6a 00                	push   $0x0
  pushl $62
c0103cb6:	6a 3e                	push   $0x3e
  jmp __alltraps
c0103cb8:	e9 49 08 00 00       	jmp    c0104506 <__alltraps>

c0103cbd <vector63>:
.globl vector63
vector63:
  pushl $0
c0103cbd:	6a 00                	push   $0x0
  pushl $63
c0103cbf:	6a 3f                	push   $0x3f
  jmp __alltraps
c0103cc1:	e9 40 08 00 00       	jmp    c0104506 <__alltraps>

c0103cc6 <vector64>:
.globl vector64
vector64:
  pushl $0
c0103cc6:	6a 00                	push   $0x0
  pushl $64
c0103cc8:	6a 40                	push   $0x40
  jmp __alltraps
c0103cca:	e9 37 08 00 00       	jmp    c0104506 <__alltraps>

c0103ccf <vector65>:
.globl vector65
vector65:
  pushl $0
c0103ccf:	6a 00                	push   $0x0
  pushl $65
c0103cd1:	6a 41                	push   $0x41
  jmp __alltraps
c0103cd3:	e9 2e 08 00 00       	jmp    c0104506 <__alltraps>

c0103cd8 <vector66>:
.globl vector66
vector66:
  pushl $0
c0103cd8:	6a 00                	push   $0x0
  pushl $66
c0103cda:	6a 42                	push   $0x42
  jmp __alltraps
c0103cdc:	e9 25 08 00 00       	jmp    c0104506 <__alltraps>

c0103ce1 <vector67>:
.globl vector67
vector67:
  pushl $0
c0103ce1:	6a 00                	push   $0x0
  pushl $67
c0103ce3:	6a 43                	push   $0x43
  jmp __alltraps
c0103ce5:	e9 1c 08 00 00       	jmp    c0104506 <__alltraps>

c0103cea <vector68>:
.globl vector68
vector68:
  pushl $0
c0103cea:	6a 00                	push   $0x0
  pushl $68
c0103cec:	6a 44                	push   $0x44
  jmp __alltraps
c0103cee:	e9 13 08 00 00       	jmp    c0104506 <__alltraps>

c0103cf3 <vector69>:
.globl vector69
vector69:
  pushl $0
c0103cf3:	6a 00                	push   $0x0
  pushl $69
c0103cf5:	6a 45                	push   $0x45
  jmp __alltraps
c0103cf7:	e9 0a 08 00 00       	jmp    c0104506 <__alltraps>

c0103cfc <vector70>:
.globl vector70
vector70:
  pushl $0
c0103cfc:	6a 00                	push   $0x0
  pushl $70
c0103cfe:	6a 46                	push   $0x46
  jmp __alltraps
c0103d00:	e9 01 08 00 00       	jmp    c0104506 <__alltraps>

c0103d05 <vector71>:
.globl vector71
vector71:
  pushl $0
c0103d05:	6a 00                	push   $0x0
  pushl $71
c0103d07:	6a 47                	push   $0x47
  jmp __alltraps
c0103d09:	e9 f8 07 00 00       	jmp    c0104506 <__alltraps>

c0103d0e <vector72>:
.globl vector72
vector72:
  pushl $0
c0103d0e:	6a 00                	push   $0x0
  pushl $72
c0103d10:	6a 48                	push   $0x48
  jmp __alltraps
c0103d12:	e9 ef 07 00 00       	jmp    c0104506 <__alltraps>

c0103d17 <vector73>:
.globl vector73
vector73:
  pushl $0
c0103d17:	6a 00                	push   $0x0
  pushl $73
c0103d19:	6a 49                	push   $0x49
  jmp __alltraps
c0103d1b:	e9 e6 07 00 00       	jmp    c0104506 <__alltraps>

c0103d20 <vector74>:
.globl vector74
vector74:
  pushl $0
c0103d20:	6a 00                	push   $0x0
  pushl $74
c0103d22:	6a 4a                	push   $0x4a
  jmp __alltraps
c0103d24:	e9 dd 07 00 00       	jmp    c0104506 <__alltraps>

c0103d29 <vector75>:
.globl vector75
vector75:
  pushl $0
c0103d29:	6a 00                	push   $0x0
  pushl $75
c0103d2b:	6a 4b                	push   $0x4b
  jmp __alltraps
c0103d2d:	e9 d4 07 00 00       	jmp    c0104506 <__alltraps>

c0103d32 <vector76>:
.globl vector76
vector76:
  pushl $0
c0103d32:	6a 00                	push   $0x0
  pushl $76
c0103d34:	6a 4c                	push   $0x4c
  jmp __alltraps
c0103d36:	e9 cb 07 00 00       	jmp    c0104506 <__alltraps>

c0103d3b <vector77>:
.globl vector77
vector77:
  pushl $0
c0103d3b:	6a 00                	push   $0x0
  pushl $77
c0103d3d:	6a 4d                	push   $0x4d
  jmp __alltraps
c0103d3f:	e9 c2 07 00 00       	jmp    c0104506 <__alltraps>

c0103d44 <vector78>:
.globl vector78
vector78:
  pushl $0
c0103d44:	6a 00                	push   $0x0
  pushl $78
c0103d46:	6a 4e                	push   $0x4e
  jmp __alltraps
c0103d48:	e9 b9 07 00 00       	jmp    c0104506 <__alltraps>

c0103d4d <vector79>:
.globl vector79
vector79:
  pushl $0
c0103d4d:	6a 00                	push   $0x0
  pushl $79
c0103d4f:	6a 4f                	push   $0x4f
  jmp __alltraps
c0103d51:	e9 b0 07 00 00       	jmp    c0104506 <__alltraps>

c0103d56 <vector80>:
.globl vector80
vector80:
  pushl $0
c0103d56:	6a 00                	push   $0x0
  pushl $80
c0103d58:	6a 50                	push   $0x50
  jmp __alltraps
c0103d5a:	e9 a7 07 00 00       	jmp    c0104506 <__alltraps>

c0103d5f <vector81>:
.globl vector81
vector81:
  pushl $0
c0103d5f:	6a 00                	push   $0x0
  pushl $81
c0103d61:	6a 51                	push   $0x51
  jmp __alltraps
c0103d63:	e9 9e 07 00 00       	jmp    c0104506 <__alltraps>

c0103d68 <vector82>:
.globl vector82
vector82:
  pushl $0
c0103d68:	6a 00                	push   $0x0
  pushl $82
c0103d6a:	6a 52                	push   $0x52
  jmp __alltraps
c0103d6c:	e9 95 07 00 00       	jmp    c0104506 <__alltraps>

c0103d71 <vector83>:
.globl vector83
vector83:
  pushl $0
c0103d71:	6a 00                	push   $0x0
  pushl $83
c0103d73:	6a 53                	push   $0x53
  jmp __alltraps
c0103d75:	e9 8c 07 00 00       	jmp    c0104506 <__alltraps>

c0103d7a <vector84>:
.globl vector84
vector84:
  pushl $0
c0103d7a:	6a 00                	push   $0x0
  pushl $84
c0103d7c:	6a 54                	push   $0x54
  jmp __alltraps
c0103d7e:	e9 83 07 00 00       	jmp    c0104506 <__alltraps>

c0103d83 <vector85>:
.globl vector85
vector85:
  pushl $0
c0103d83:	6a 00                	push   $0x0
  pushl $85
c0103d85:	6a 55                	push   $0x55
  jmp __alltraps
c0103d87:	e9 7a 07 00 00       	jmp    c0104506 <__alltraps>

c0103d8c <vector86>:
.globl vector86
vector86:
  pushl $0
c0103d8c:	6a 00                	push   $0x0
  pushl $86
c0103d8e:	6a 56                	push   $0x56
  jmp __alltraps
c0103d90:	e9 71 07 00 00       	jmp    c0104506 <__alltraps>

c0103d95 <vector87>:
.globl vector87
vector87:
  pushl $0
c0103d95:	6a 00                	push   $0x0
  pushl $87
c0103d97:	6a 57                	push   $0x57
  jmp __alltraps
c0103d99:	e9 68 07 00 00       	jmp    c0104506 <__alltraps>

c0103d9e <vector88>:
.globl vector88
vector88:
  pushl $0
c0103d9e:	6a 00                	push   $0x0
  pushl $88
c0103da0:	6a 58                	push   $0x58
  jmp __alltraps
c0103da2:	e9 5f 07 00 00       	jmp    c0104506 <__alltraps>

c0103da7 <vector89>:
.globl vector89
vector89:
  pushl $0
c0103da7:	6a 00                	push   $0x0
  pushl $89
c0103da9:	6a 59                	push   $0x59
  jmp __alltraps
c0103dab:	e9 56 07 00 00       	jmp    c0104506 <__alltraps>

c0103db0 <vector90>:
.globl vector90
vector90:
  pushl $0
c0103db0:	6a 00                	push   $0x0
  pushl $90
c0103db2:	6a 5a                	push   $0x5a
  jmp __alltraps
c0103db4:	e9 4d 07 00 00       	jmp    c0104506 <__alltraps>

c0103db9 <vector91>:
.globl vector91
vector91:
  pushl $0
c0103db9:	6a 00                	push   $0x0
  pushl $91
c0103dbb:	6a 5b                	push   $0x5b
  jmp __alltraps
c0103dbd:	e9 44 07 00 00       	jmp    c0104506 <__alltraps>

c0103dc2 <vector92>:
.globl vector92
vector92:
  pushl $0
c0103dc2:	6a 00                	push   $0x0
  pushl $92
c0103dc4:	6a 5c                	push   $0x5c
  jmp __alltraps
c0103dc6:	e9 3b 07 00 00       	jmp    c0104506 <__alltraps>

c0103dcb <vector93>:
.globl vector93
vector93:
  pushl $0
c0103dcb:	6a 00                	push   $0x0
  pushl $93
c0103dcd:	6a 5d                	push   $0x5d
  jmp __alltraps
c0103dcf:	e9 32 07 00 00       	jmp    c0104506 <__alltraps>

c0103dd4 <vector94>:
.globl vector94
vector94:
  pushl $0
c0103dd4:	6a 00                	push   $0x0
  pushl $94
c0103dd6:	6a 5e                	push   $0x5e
  jmp __alltraps
c0103dd8:	e9 29 07 00 00       	jmp    c0104506 <__alltraps>

c0103ddd <vector95>:
.globl vector95
vector95:
  pushl $0
c0103ddd:	6a 00                	push   $0x0
  pushl $95
c0103ddf:	6a 5f                	push   $0x5f
  jmp __alltraps
c0103de1:	e9 20 07 00 00       	jmp    c0104506 <__alltraps>

c0103de6 <vector96>:
.globl vector96
vector96:
  pushl $0
c0103de6:	6a 00                	push   $0x0
  pushl $96
c0103de8:	6a 60                	push   $0x60
  jmp __alltraps
c0103dea:	e9 17 07 00 00       	jmp    c0104506 <__alltraps>

c0103def <vector97>:
.globl vector97
vector97:
  pushl $0
c0103def:	6a 00                	push   $0x0
  pushl $97
c0103df1:	6a 61                	push   $0x61
  jmp __alltraps
c0103df3:	e9 0e 07 00 00       	jmp    c0104506 <__alltraps>

c0103df8 <vector98>:
.globl vector98
vector98:
  pushl $0
c0103df8:	6a 00                	push   $0x0
  pushl $98
c0103dfa:	6a 62                	push   $0x62
  jmp __alltraps
c0103dfc:	e9 05 07 00 00       	jmp    c0104506 <__alltraps>

c0103e01 <vector99>:
.globl vector99
vector99:
  pushl $0
c0103e01:	6a 00                	push   $0x0
  pushl $99
c0103e03:	6a 63                	push   $0x63
  jmp __alltraps
c0103e05:	e9 fc 06 00 00       	jmp    c0104506 <__alltraps>

c0103e0a <vector100>:
.globl vector100
vector100:
  pushl $0
c0103e0a:	6a 00                	push   $0x0
  pushl $100
c0103e0c:	6a 64                	push   $0x64
  jmp __alltraps
c0103e0e:	e9 f3 06 00 00       	jmp    c0104506 <__alltraps>

c0103e13 <vector101>:
.globl vector101
vector101:
  pushl $0
c0103e13:	6a 00                	push   $0x0
  pushl $101
c0103e15:	6a 65                	push   $0x65
  jmp __alltraps
c0103e17:	e9 ea 06 00 00       	jmp    c0104506 <__alltraps>

c0103e1c <vector102>:
.globl vector102
vector102:
  pushl $0
c0103e1c:	6a 00                	push   $0x0
  pushl $102
c0103e1e:	6a 66                	push   $0x66
  jmp __alltraps
c0103e20:	e9 e1 06 00 00       	jmp    c0104506 <__alltraps>

c0103e25 <vector103>:
.globl vector103
vector103:
  pushl $0
c0103e25:	6a 00                	push   $0x0
  pushl $103
c0103e27:	6a 67                	push   $0x67
  jmp __alltraps
c0103e29:	e9 d8 06 00 00       	jmp    c0104506 <__alltraps>

c0103e2e <vector104>:
.globl vector104
vector104:
  pushl $0
c0103e2e:	6a 00                	push   $0x0
  pushl $104
c0103e30:	6a 68                	push   $0x68
  jmp __alltraps
c0103e32:	e9 cf 06 00 00       	jmp    c0104506 <__alltraps>

c0103e37 <vector105>:
.globl vector105
vector105:
  pushl $0
c0103e37:	6a 00                	push   $0x0
  pushl $105
c0103e39:	6a 69                	push   $0x69
  jmp __alltraps
c0103e3b:	e9 c6 06 00 00       	jmp    c0104506 <__alltraps>

c0103e40 <vector106>:
.globl vector106
vector106:
  pushl $0
c0103e40:	6a 00                	push   $0x0
  pushl $106
c0103e42:	6a 6a                	push   $0x6a
  jmp __alltraps
c0103e44:	e9 bd 06 00 00       	jmp    c0104506 <__alltraps>

c0103e49 <vector107>:
.globl vector107
vector107:
  pushl $0
c0103e49:	6a 00                	push   $0x0
  pushl $107
c0103e4b:	6a 6b                	push   $0x6b
  jmp __alltraps
c0103e4d:	e9 b4 06 00 00       	jmp    c0104506 <__alltraps>

c0103e52 <vector108>:
.globl vector108
vector108:
  pushl $0
c0103e52:	6a 00                	push   $0x0
  pushl $108
c0103e54:	6a 6c                	push   $0x6c
  jmp __alltraps
c0103e56:	e9 ab 06 00 00       	jmp    c0104506 <__alltraps>

c0103e5b <vector109>:
.globl vector109
vector109:
  pushl $0
c0103e5b:	6a 00                	push   $0x0
  pushl $109
c0103e5d:	6a 6d                	push   $0x6d
  jmp __alltraps
c0103e5f:	e9 a2 06 00 00       	jmp    c0104506 <__alltraps>

c0103e64 <vector110>:
.globl vector110
vector110:
  pushl $0
c0103e64:	6a 00                	push   $0x0
  pushl $110
c0103e66:	6a 6e                	push   $0x6e
  jmp __alltraps
c0103e68:	e9 99 06 00 00       	jmp    c0104506 <__alltraps>

c0103e6d <vector111>:
.globl vector111
vector111:
  pushl $0
c0103e6d:	6a 00                	push   $0x0
  pushl $111
c0103e6f:	6a 6f                	push   $0x6f
  jmp __alltraps
c0103e71:	e9 90 06 00 00       	jmp    c0104506 <__alltraps>

c0103e76 <vector112>:
.globl vector112
vector112:
  pushl $0
c0103e76:	6a 00                	push   $0x0
  pushl $112
c0103e78:	6a 70                	push   $0x70
  jmp __alltraps
c0103e7a:	e9 87 06 00 00       	jmp    c0104506 <__alltraps>

c0103e7f <vector113>:
.globl vector113
vector113:
  pushl $0
c0103e7f:	6a 00                	push   $0x0
  pushl $113
c0103e81:	6a 71                	push   $0x71
  jmp __alltraps
c0103e83:	e9 7e 06 00 00       	jmp    c0104506 <__alltraps>

c0103e88 <vector114>:
.globl vector114
vector114:
  pushl $0
c0103e88:	6a 00                	push   $0x0
  pushl $114
c0103e8a:	6a 72                	push   $0x72
  jmp __alltraps
c0103e8c:	e9 75 06 00 00       	jmp    c0104506 <__alltraps>

c0103e91 <vector115>:
.globl vector115
vector115:
  pushl $0
c0103e91:	6a 00                	push   $0x0
  pushl $115
c0103e93:	6a 73                	push   $0x73
  jmp __alltraps
c0103e95:	e9 6c 06 00 00       	jmp    c0104506 <__alltraps>

c0103e9a <vector116>:
.globl vector116
vector116:
  pushl $0
c0103e9a:	6a 00                	push   $0x0
  pushl $116
c0103e9c:	6a 74                	push   $0x74
  jmp __alltraps
c0103e9e:	e9 63 06 00 00       	jmp    c0104506 <__alltraps>

c0103ea3 <vector117>:
.globl vector117
vector117:
  pushl $0
c0103ea3:	6a 00                	push   $0x0
  pushl $117
c0103ea5:	6a 75                	push   $0x75
  jmp __alltraps
c0103ea7:	e9 5a 06 00 00       	jmp    c0104506 <__alltraps>

c0103eac <vector118>:
.globl vector118
vector118:
  pushl $0
c0103eac:	6a 00                	push   $0x0
  pushl $118
c0103eae:	6a 76                	push   $0x76
  jmp __alltraps
c0103eb0:	e9 51 06 00 00       	jmp    c0104506 <__alltraps>

c0103eb5 <vector119>:
.globl vector119
vector119:
  pushl $0
c0103eb5:	6a 00                	push   $0x0
  pushl $119
c0103eb7:	6a 77                	push   $0x77
  jmp __alltraps
c0103eb9:	e9 48 06 00 00       	jmp    c0104506 <__alltraps>

c0103ebe <vector120>:
.globl vector120
vector120:
  pushl $0
c0103ebe:	6a 00                	push   $0x0
  pushl $120
c0103ec0:	6a 78                	push   $0x78
  jmp __alltraps
c0103ec2:	e9 3f 06 00 00       	jmp    c0104506 <__alltraps>

c0103ec7 <vector121>:
.globl vector121
vector121:
  pushl $0
c0103ec7:	6a 00                	push   $0x0
  pushl $121
c0103ec9:	6a 79                	push   $0x79
  jmp __alltraps
c0103ecb:	e9 36 06 00 00       	jmp    c0104506 <__alltraps>

c0103ed0 <vector122>:
.globl vector122
vector122:
  pushl $0
c0103ed0:	6a 00                	push   $0x0
  pushl $122
c0103ed2:	6a 7a                	push   $0x7a
  jmp __alltraps
c0103ed4:	e9 2d 06 00 00       	jmp    c0104506 <__alltraps>

c0103ed9 <vector123>:
.globl vector123
vector123:
  pushl $0
c0103ed9:	6a 00                	push   $0x0
  pushl $123
c0103edb:	6a 7b                	push   $0x7b
  jmp __alltraps
c0103edd:	e9 24 06 00 00       	jmp    c0104506 <__alltraps>

c0103ee2 <vector124>:
.globl vector124
vector124:
  pushl $0
c0103ee2:	6a 00                	push   $0x0
  pushl $124
c0103ee4:	6a 7c                	push   $0x7c
  jmp __alltraps
c0103ee6:	e9 1b 06 00 00       	jmp    c0104506 <__alltraps>

c0103eeb <vector125>:
.globl vector125
vector125:
  pushl $0
c0103eeb:	6a 00                	push   $0x0
  pushl $125
c0103eed:	6a 7d                	push   $0x7d
  jmp __alltraps
c0103eef:	e9 12 06 00 00       	jmp    c0104506 <__alltraps>

c0103ef4 <vector126>:
.globl vector126
vector126:
  pushl $0
c0103ef4:	6a 00                	push   $0x0
  pushl $126
c0103ef6:	6a 7e                	push   $0x7e
  jmp __alltraps
c0103ef8:	e9 09 06 00 00       	jmp    c0104506 <__alltraps>

c0103efd <vector127>:
.globl vector127
vector127:
  pushl $0
c0103efd:	6a 00                	push   $0x0
  pushl $127
c0103eff:	6a 7f                	push   $0x7f
  jmp __alltraps
c0103f01:	e9 00 06 00 00       	jmp    c0104506 <__alltraps>

c0103f06 <vector128>:
.globl vector128
vector128:
  pushl $0
c0103f06:	6a 00                	push   $0x0
  pushl $128
c0103f08:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0103f0d:	e9 f4 05 00 00       	jmp    c0104506 <__alltraps>

c0103f12 <vector129>:
.globl vector129
vector129:
  pushl $0
c0103f12:	6a 00                	push   $0x0
  pushl $129
c0103f14:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0103f19:	e9 e8 05 00 00       	jmp    c0104506 <__alltraps>

c0103f1e <vector130>:
.globl vector130
vector130:
  pushl $0
c0103f1e:	6a 00                	push   $0x0
  pushl $130
c0103f20:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0103f25:	e9 dc 05 00 00       	jmp    c0104506 <__alltraps>

c0103f2a <vector131>:
.globl vector131
vector131:
  pushl $0
c0103f2a:	6a 00                	push   $0x0
  pushl $131
c0103f2c:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0103f31:	e9 d0 05 00 00       	jmp    c0104506 <__alltraps>

c0103f36 <vector132>:
.globl vector132
vector132:
  pushl $0
c0103f36:	6a 00                	push   $0x0
  pushl $132
c0103f38:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0103f3d:	e9 c4 05 00 00       	jmp    c0104506 <__alltraps>

c0103f42 <vector133>:
.globl vector133
vector133:
  pushl $0
c0103f42:	6a 00                	push   $0x0
  pushl $133
c0103f44:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0103f49:	e9 b8 05 00 00       	jmp    c0104506 <__alltraps>

c0103f4e <vector134>:
.globl vector134
vector134:
  pushl $0
c0103f4e:	6a 00                	push   $0x0
  pushl $134
c0103f50:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0103f55:	e9 ac 05 00 00       	jmp    c0104506 <__alltraps>

c0103f5a <vector135>:
.globl vector135
vector135:
  pushl $0
c0103f5a:	6a 00                	push   $0x0
  pushl $135
c0103f5c:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0103f61:	e9 a0 05 00 00       	jmp    c0104506 <__alltraps>

c0103f66 <vector136>:
.globl vector136
vector136:
  pushl $0
c0103f66:	6a 00                	push   $0x0
  pushl $136
c0103f68:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0103f6d:	e9 94 05 00 00       	jmp    c0104506 <__alltraps>

c0103f72 <vector137>:
.globl vector137
vector137:
  pushl $0
c0103f72:	6a 00                	push   $0x0
  pushl $137
c0103f74:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0103f79:	e9 88 05 00 00       	jmp    c0104506 <__alltraps>

c0103f7e <vector138>:
.globl vector138
vector138:
  pushl $0
c0103f7e:	6a 00                	push   $0x0
  pushl $138
c0103f80:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0103f85:	e9 7c 05 00 00       	jmp    c0104506 <__alltraps>

c0103f8a <vector139>:
.globl vector139
vector139:
  pushl $0
c0103f8a:	6a 00                	push   $0x0
  pushl $139
c0103f8c:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0103f91:	e9 70 05 00 00       	jmp    c0104506 <__alltraps>

c0103f96 <vector140>:
.globl vector140
vector140:
  pushl $0
c0103f96:	6a 00                	push   $0x0
  pushl $140
c0103f98:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0103f9d:	e9 64 05 00 00       	jmp    c0104506 <__alltraps>

c0103fa2 <vector141>:
.globl vector141
vector141:
  pushl $0
c0103fa2:	6a 00                	push   $0x0
  pushl $141
c0103fa4:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0103fa9:	e9 58 05 00 00       	jmp    c0104506 <__alltraps>

c0103fae <vector142>:
.globl vector142
vector142:
  pushl $0
c0103fae:	6a 00                	push   $0x0
  pushl $142
c0103fb0:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0103fb5:	e9 4c 05 00 00       	jmp    c0104506 <__alltraps>

c0103fba <vector143>:
.globl vector143
vector143:
  pushl $0
c0103fba:	6a 00                	push   $0x0
  pushl $143
c0103fbc:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0103fc1:	e9 40 05 00 00       	jmp    c0104506 <__alltraps>

c0103fc6 <vector144>:
.globl vector144
vector144:
  pushl $0
c0103fc6:	6a 00                	push   $0x0
  pushl $144
c0103fc8:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0103fcd:	e9 34 05 00 00       	jmp    c0104506 <__alltraps>

c0103fd2 <vector145>:
.globl vector145
vector145:
  pushl $0
c0103fd2:	6a 00                	push   $0x0
  pushl $145
c0103fd4:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0103fd9:	e9 28 05 00 00       	jmp    c0104506 <__alltraps>

c0103fde <vector146>:
.globl vector146
vector146:
  pushl $0
c0103fde:	6a 00                	push   $0x0
  pushl $146
c0103fe0:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0103fe5:	e9 1c 05 00 00       	jmp    c0104506 <__alltraps>

c0103fea <vector147>:
.globl vector147
vector147:
  pushl $0
c0103fea:	6a 00                	push   $0x0
  pushl $147
c0103fec:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0103ff1:	e9 10 05 00 00       	jmp    c0104506 <__alltraps>

c0103ff6 <vector148>:
.globl vector148
vector148:
  pushl $0
c0103ff6:	6a 00                	push   $0x0
  pushl $148
c0103ff8:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0103ffd:	e9 04 05 00 00       	jmp    c0104506 <__alltraps>

c0104002 <vector149>:
.globl vector149
vector149:
  pushl $0
c0104002:	6a 00                	push   $0x0
  pushl $149
c0104004:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0104009:	e9 f8 04 00 00       	jmp    c0104506 <__alltraps>

c010400e <vector150>:
.globl vector150
vector150:
  pushl $0
c010400e:	6a 00                	push   $0x0
  pushl $150
c0104010:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0104015:	e9 ec 04 00 00       	jmp    c0104506 <__alltraps>

c010401a <vector151>:
.globl vector151
vector151:
  pushl $0
c010401a:	6a 00                	push   $0x0
  pushl $151
c010401c:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0104021:	e9 e0 04 00 00       	jmp    c0104506 <__alltraps>

c0104026 <vector152>:
.globl vector152
vector152:
  pushl $0
c0104026:	6a 00                	push   $0x0
  pushl $152
c0104028:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c010402d:	e9 d4 04 00 00       	jmp    c0104506 <__alltraps>

c0104032 <vector153>:
.globl vector153
vector153:
  pushl $0
c0104032:	6a 00                	push   $0x0
  pushl $153
c0104034:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0104039:	e9 c8 04 00 00       	jmp    c0104506 <__alltraps>

c010403e <vector154>:
.globl vector154
vector154:
  pushl $0
c010403e:	6a 00                	push   $0x0
  pushl $154
c0104040:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0104045:	e9 bc 04 00 00       	jmp    c0104506 <__alltraps>

c010404a <vector155>:
.globl vector155
vector155:
  pushl $0
c010404a:	6a 00                	push   $0x0
  pushl $155
c010404c:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0104051:	e9 b0 04 00 00       	jmp    c0104506 <__alltraps>

c0104056 <vector156>:
.globl vector156
vector156:
  pushl $0
c0104056:	6a 00                	push   $0x0
  pushl $156
c0104058:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c010405d:	e9 a4 04 00 00       	jmp    c0104506 <__alltraps>

c0104062 <vector157>:
.globl vector157
vector157:
  pushl $0
c0104062:	6a 00                	push   $0x0
  pushl $157
c0104064:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0104069:	e9 98 04 00 00       	jmp    c0104506 <__alltraps>

c010406e <vector158>:
.globl vector158
vector158:
  pushl $0
c010406e:	6a 00                	push   $0x0
  pushl $158
c0104070:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0104075:	e9 8c 04 00 00       	jmp    c0104506 <__alltraps>

c010407a <vector159>:
.globl vector159
vector159:
  pushl $0
c010407a:	6a 00                	push   $0x0
  pushl $159
c010407c:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0104081:	e9 80 04 00 00       	jmp    c0104506 <__alltraps>

c0104086 <vector160>:
.globl vector160
vector160:
  pushl $0
c0104086:	6a 00                	push   $0x0
  pushl $160
c0104088:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010408d:	e9 74 04 00 00       	jmp    c0104506 <__alltraps>

c0104092 <vector161>:
.globl vector161
vector161:
  pushl $0
c0104092:	6a 00                	push   $0x0
  pushl $161
c0104094:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0104099:	e9 68 04 00 00       	jmp    c0104506 <__alltraps>

c010409e <vector162>:
.globl vector162
vector162:
  pushl $0
c010409e:	6a 00                	push   $0x0
  pushl $162
c01040a0:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01040a5:	e9 5c 04 00 00       	jmp    c0104506 <__alltraps>

c01040aa <vector163>:
.globl vector163
vector163:
  pushl $0
c01040aa:	6a 00                	push   $0x0
  pushl $163
c01040ac:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01040b1:	e9 50 04 00 00       	jmp    c0104506 <__alltraps>

c01040b6 <vector164>:
.globl vector164
vector164:
  pushl $0
c01040b6:	6a 00                	push   $0x0
  pushl $164
c01040b8:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01040bd:	e9 44 04 00 00       	jmp    c0104506 <__alltraps>

c01040c2 <vector165>:
.globl vector165
vector165:
  pushl $0
c01040c2:	6a 00                	push   $0x0
  pushl $165
c01040c4:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01040c9:	e9 38 04 00 00       	jmp    c0104506 <__alltraps>

c01040ce <vector166>:
.globl vector166
vector166:
  pushl $0
c01040ce:	6a 00                	push   $0x0
  pushl $166
c01040d0:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01040d5:	e9 2c 04 00 00       	jmp    c0104506 <__alltraps>

c01040da <vector167>:
.globl vector167
vector167:
  pushl $0
c01040da:	6a 00                	push   $0x0
  pushl $167
c01040dc:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01040e1:	e9 20 04 00 00       	jmp    c0104506 <__alltraps>

c01040e6 <vector168>:
.globl vector168
vector168:
  pushl $0
c01040e6:	6a 00                	push   $0x0
  pushl $168
c01040e8:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01040ed:	e9 14 04 00 00       	jmp    c0104506 <__alltraps>

c01040f2 <vector169>:
.globl vector169
vector169:
  pushl $0
c01040f2:	6a 00                	push   $0x0
  pushl $169
c01040f4:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01040f9:	e9 08 04 00 00       	jmp    c0104506 <__alltraps>

c01040fe <vector170>:
.globl vector170
vector170:
  pushl $0
c01040fe:	6a 00                	push   $0x0
  pushl $170
c0104100:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0104105:	e9 fc 03 00 00       	jmp    c0104506 <__alltraps>

c010410a <vector171>:
.globl vector171
vector171:
  pushl $0
c010410a:	6a 00                	push   $0x0
  pushl $171
c010410c:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0104111:	e9 f0 03 00 00       	jmp    c0104506 <__alltraps>

c0104116 <vector172>:
.globl vector172
vector172:
  pushl $0
c0104116:	6a 00                	push   $0x0
  pushl $172
c0104118:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c010411d:	e9 e4 03 00 00       	jmp    c0104506 <__alltraps>

c0104122 <vector173>:
.globl vector173
vector173:
  pushl $0
c0104122:	6a 00                	push   $0x0
  pushl $173
c0104124:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0104129:	e9 d8 03 00 00       	jmp    c0104506 <__alltraps>

c010412e <vector174>:
.globl vector174
vector174:
  pushl $0
c010412e:	6a 00                	push   $0x0
  pushl $174
c0104130:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0104135:	e9 cc 03 00 00       	jmp    c0104506 <__alltraps>

c010413a <vector175>:
.globl vector175
vector175:
  pushl $0
c010413a:	6a 00                	push   $0x0
  pushl $175
c010413c:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0104141:	e9 c0 03 00 00       	jmp    c0104506 <__alltraps>

c0104146 <vector176>:
.globl vector176
vector176:
  pushl $0
c0104146:	6a 00                	push   $0x0
  pushl $176
c0104148:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c010414d:	e9 b4 03 00 00       	jmp    c0104506 <__alltraps>

c0104152 <vector177>:
.globl vector177
vector177:
  pushl $0
c0104152:	6a 00                	push   $0x0
  pushl $177
c0104154:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0104159:	e9 a8 03 00 00       	jmp    c0104506 <__alltraps>

c010415e <vector178>:
.globl vector178
vector178:
  pushl $0
c010415e:	6a 00                	push   $0x0
  pushl $178
c0104160:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0104165:	e9 9c 03 00 00       	jmp    c0104506 <__alltraps>

c010416a <vector179>:
.globl vector179
vector179:
  pushl $0
c010416a:	6a 00                	push   $0x0
  pushl $179
c010416c:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0104171:	e9 90 03 00 00       	jmp    c0104506 <__alltraps>

c0104176 <vector180>:
.globl vector180
vector180:
  pushl $0
c0104176:	6a 00                	push   $0x0
  pushl $180
c0104178:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010417d:	e9 84 03 00 00       	jmp    c0104506 <__alltraps>

c0104182 <vector181>:
.globl vector181
vector181:
  pushl $0
c0104182:	6a 00                	push   $0x0
  pushl $181
c0104184:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0104189:	e9 78 03 00 00       	jmp    c0104506 <__alltraps>

c010418e <vector182>:
.globl vector182
vector182:
  pushl $0
c010418e:	6a 00                	push   $0x0
  pushl $182
c0104190:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0104195:	e9 6c 03 00 00       	jmp    c0104506 <__alltraps>

c010419a <vector183>:
.globl vector183
vector183:
  pushl $0
c010419a:	6a 00                	push   $0x0
  pushl $183
c010419c:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01041a1:	e9 60 03 00 00       	jmp    c0104506 <__alltraps>

c01041a6 <vector184>:
.globl vector184
vector184:
  pushl $0
c01041a6:	6a 00                	push   $0x0
  pushl $184
c01041a8:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01041ad:	e9 54 03 00 00       	jmp    c0104506 <__alltraps>

c01041b2 <vector185>:
.globl vector185
vector185:
  pushl $0
c01041b2:	6a 00                	push   $0x0
  pushl $185
c01041b4:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01041b9:	e9 48 03 00 00       	jmp    c0104506 <__alltraps>

c01041be <vector186>:
.globl vector186
vector186:
  pushl $0
c01041be:	6a 00                	push   $0x0
  pushl $186
c01041c0:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01041c5:	e9 3c 03 00 00       	jmp    c0104506 <__alltraps>

c01041ca <vector187>:
.globl vector187
vector187:
  pushl $0
c01041ca:	6a 00                	push   $0x0
  pushl $187
c01041cc:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01041d1:	e9 30 03 00 00       	jmp    c0104506 <__alltraps>

c01041d6 <vector188>:
.globl vector188
vector188:
  pushl $0
c01041d6:	6a 00                	push   $0x0
  pushl $188
c01041d8:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01041dd:	e9 24 03 00 00       	jmp    c0104506 <__alltraps>

c01041e2 <vector189>:
.globl vector189
vector189:
  pushl $0
c01041e2:	6a 00                	push   $0x0
  pushl $189
c01041e4:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01041e9:	e9 18 03 00 00       	jmp    c0104506 <__alltraps>

c01041ee <vector190>:
.globl vector190
vector190:
  pushl $0
c01041ee:	6a 00                	push   $0x0
  pushl $190
c01041f0:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01041f5:	e9 0c 03 00 00       	jmp    c0104506 <__alltraps>

c01041fa <vector191>:
.globl vector191
vector191:
  pushl $0
c01041fa:	6a 00                	push   $0x0
  pushl $191
c01041fc:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0104201:	e9 00 03 00 00       	jmp    c0104506 <__alltraps>

c0104206 <vector192>:
.globl vector192
vector192:
  pushl $0
c0104206:	6a 00                	push   $0x0
  pushl $192
c0104208:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c010420d:	e9 f4 02 00 00       	jmp    c0104506 <__alltraps>

c0104212 <vector193>:
.globl vector193
vector193:
  pushl $0
c0104212:	6a 00                	push   $0x0
  pushl $193
c0104214:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0104219:	e9 e8 02 00 00       	jmp    c0104506 <__alltraps>

c010421e <vector194>:
.globl vector194
vector194:
  pushl $0
c010421e:	6a 00                	push   $0x0
  pushl $194
c0104220:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0104225:	e9 dc 02 00 00       	jmp    c0104506 <__alltraps>

c010422a <vector195>:
.globl vector195
vector195:
  pushl $0
c010422a:	6a 00                	push   $0x0
  pushl $195
c010422c:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0104231:	e9 d0 02 00 00       	jmp    c0104506 <__alltraps>

c0104236 <vector196>:
.globl vector196
vector196:
  pushl $0
c0104236:	6a 00                	push   $0x0
  pushl $196
c0104238:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c010423d:	e9 c4 02 00 00       	jmp    c0104506 <__alltraps>

c0104242 <vector197>:
.globl vector197
vector197:
  pushl $0
c0104242:	6a 00                	push   $0x0
  pushl $197
c0104244:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0104249:	e9 b8 02 00 00       	jmp    c0104506 <__alltraps>

c010424e <vector198>:
.globl vector198
vector198:
  pushl $0
c010424e:	6a 00                	push   $0x0
  pushl $198
c0104250:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0104255:	e9 ac 02 00 00       	jmp    c0104506 <__alltraps>

c010425a <vector199>:
.globl vector199
vector199:
  pushl $0
c010425a:	6a 00                	push   $0x0
  pushl $199
c010425c:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0104261:	e9 a0 02 00 00       	jmp    c0104506 <__alltraps>

c0104266 <vector200>:
.globl vector200
vector200:
  pushl $0
c0104266:	6a 00                	push   $0x0
  pushl $200
c0104268:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010426d:	e9 94 02 00 00       	jmp    c0104506 <__alltraps>

c0104272 <vector201>:
.globl vector201
vector201:
  pushl $0
c0104272:	6a 00                	push   $0x0
  pushl $201
c0104274:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0104279:	e9 88 02 00 00       	jmp    c0104506 <__alltraps>

c010427e <vector202>:
.globl vector202
vector202:
  pushl $0
c010427e:	6a 00                	push   $0x0
  pushl $202
c0104280:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0104285:	e9 7c 02 00 00       	jmp    c0104506 <__alltraps>

c010428a <vector203>:
.globl vector203
vector203:
  pushl $0
c010428a:	6a 00                	push   $0x0
  pushl $203
c010428c:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0104291:	e9 70 02 00 00       	jmp    c0104506 <__alltraps>

c0104296 <vector204>:
.globl vector204
vector204:
  pushl $0
c0104296:	6a 00                	push   $0x0
  pushl $204
c0104298:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c010429d:	e9 64 02 00 00       	jmp    c0104506 <__alltraps>

c01042a2 <vector205>:
.globl vector205
vector205:
  pushl $0
c01042a2:	6a 00                	push   $0x0
  pushl $205
c01042a4:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01042a9:	e9 58 02 00 00       	jmp    c0104506 <__alltraps>

c01042ae <vector206>:
.globl vector206
vector206:
  pushl $0
c01042ae:	6a 00                	push   $0x0
  pushl $206
c01042b0:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01042b5:	e9 4c 02 00 00       	jmp    c0104506 <__alltraps>

c01042ba <vector207>:
.globl vector207
vector207:
  pushl $0
c01042ba:	6a 00                	push   $0x0
  pushl $207
c01042bc:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01042c1:	e9 40 02 00 00       	jmp    c0104506 <__alltraps>

c01042c6 <vector208>:
.globl vector208
vector208:
  pushl $0
c01042c6:	6a 00                	push   $0x0
  pushl $208
c01042c8:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01042cd:	e9 34 02 00 00       	jmp    c0104506 <__alltraps>

c01042d2 <vector209>:
.globl vector209
vector209:
  pushl $0
c01042d2:	6a 00                	push   $0x0
  pushl $209
c01042d4:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01042d9:	e9 28 02 00 00       	jmp    c0104506 <__alltraps>

c01042de <vector210>:
.globl vector210
vector210:
  pushl $0
c01042de:	6a 00                	push   $0x0
  pushl $210
c01042e0:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01042e5:	e9 1c 02 00 00       	jmp    c0104506 <__alltraps>

c01042ea <vector211>:
.globl vector211
vector211:
  pushl $0
c01042ea:	6a 00                	push   $0x0
  pushl $211
c01042ec:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01042f1:	e9 10 02 00 00       	jmp    c0104506 <__alltraps>

c01042f6 <vector212>:
.globl vector212
vector212:
  pushl $0
c01042f6:	6a 00                	push   $0x0
  pushl $212
c01042f8:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01042fd:	e9 04 02 00 00       	jmp    c0104506 <__alltraps>

c0104302 <vector213>:
.globl vector213
vector213:
  pushl $0
c0104302:	6a 00                	push   $0x0
  pushl $213
c0104304:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0104309:	e9 f8 01 00 00       	jmp    c0104506 <__alltraps>

c010430e <vector214>:
.globl vector214
vector214:
  pushl $0
c010430e:	6a 00                	push   $0x0
  pushl $214
c0104310:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0104315:	e9 ec 01 00 00       	jmp    c0104506 <__alltraps>

c010431a <vector215>:
.globl vector215
vector215:
  pushl $0
c010431a:	6a 00                	push   $0x0
  pushl $215
c010431c:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0104321:	e9 e0 01 00 00       	jmp    c0104506 <__alltraps>

c0104326 <vector216>:
.globl vector216
vector216:
  pushl $0
c0104326:	6a 00                	push   $0x0
  pushl $216
c0104328:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c010432d:	e9 d4 01 00 00       	jmp    c0104506 <__alltraps>

c0104332 <vector217>:
.globl vector217
vector217:
  pushl $0
c0104332:	6a 00                	push   $0x0
  pushl $217
c0104334:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0104339:	e9 c8 01 00 00       	jmp    c0104506 <__alltraps>

c010433e <vector218>:
.globl vector218
vector218:
  pushl $0
c010433e:	6a 00                	push   $0x0
  pushl $218
c0104340:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0104345:	e9 bc 01 00 00       	jmp    c0104506 <__alltraps>

c010434a <vector219>:
.globl vector219
vector219:
  pushl $0
c010434a:	6a 00                	push   $0x0
  pushl $219
c010434c:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0104351:	e9 b0 01 00 00       	jmp    c0104506 <__alltraps>

c0104356 <vector220>:
.globl vector220
vector220:
  pushl $0
c0104356:	6a 00                	push   $0x0
  pushl $220
c0104358:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010435d:	e9 a4 01 00 00       	jmp    c0104506 <__alltraps>

c0104362 <vector221>:
.globl vector221
vector221:
  pushl $0
c0104362:	6a 00                	push   $0x0
  pushl $221
c0104364:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0104369:	e9 98 01 00 00       	jmp    c0104506 <__alltraps>

c010436e <vector222>:
.globl vector222
vector222:
  pushl $0
c010436e:	6a 00                	push   $0x0
  pushl $222
c0104370:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0104375:	e9 8c 01 00 00       	jmp    c0104506 <__alltraps>

c010437a <vector223>:
.globl vector223
vector223:
  pushl $0
c010437a:	6a 00                	push   $0x0
  pushl $223
c010437c:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0104381:	e9 80 01 00 00       	jmp    c0104506 <__alltraps>

c0104386 <vector224>:
.globl vector224
vector224:
  pushl $0
c0104386:	6a 00                	push   $0x0
  pushl $224
c0104388:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010438d:	e9 74 01 00 00       	jmp    c0104506 <__alltraps>

c0104392 <vector225>:
.globl vector225
vector225:
  pushl $0
c0104392:	6a 00                	push   $0x0
  pushl $225
c0104394:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0104399:	e9 68 01 00 00       	jmp    c0104506 <__alltraps>

c010439e <vector226>:
.globl vector226
vector226:
  pushl $0
c010439e:	6a 00                	push   $0x0
  pushl $226
c01043a0:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01043a5:	e9 5c 01 00 00       	jmp    c0104506 <__alltraps>

c01043aa <vector227>:
.globl vector227
vector227:
  pushl $0
c01043aa:	6a 00                	push   $0x0
  pushl $227
c01043ac:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01043b1:	e9 50 01 00 00       	jmp    c0104506 <__alltraps>

c01043b6 <vector228>:
.globl vector228
vector228:
  pushl $0
c01043b6:	6a 00                	push   $0x0
  pushl $228
c01043b8:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01043bd:	e9 44 01 00 00       	jmp    c0104506 <__alltraps>

c01043c2 <vector229>:
.globl vector229
vector229:
  pushl $0
c01043c2:	6a 00                	push   $0x0
  pushl $229
c01043c4:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01043c9:	e9 38 01 00 00       	jmp    c0104506 <__alltraps>

c01043ce <vector230>:
.globl vector230
vector230:
  pushl $0
c01043ce:	6a 00                	push   $0x0
  pushl $230
c01043d0:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01043d5:	e9 2c 01 00 00       	jmp    c0104506 <__alltraps>

c01043da <vector231>:
.globl vector231
vector231:
  pushl $0
c01043da:	6a 00                	push   $0x0
  pushl $231
c01043dc:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01043e1:	e9 20 01 00 00       	jmp    c0104506 <__alltraps>

c01043e6 <vector232>:
.globl vector232
vector232:
  pushl $0
c01043e6:	6a 00                	push   $0x0
  pushl $232
c01043e8:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01043ed:	e9 14 01 00 00       	jmp    c0104506 <__alltraps>

c01043f2 <vector233>:
.globl vector233
vector233:
  pushl $0
c01043f2:	6a 00                	push   $0x0
  pushl $233
c01043f4:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01043f9:	e9 08 01 00 00       	jmp    c0104506 <__alltraps>

c01043fe <vector234>:
.globl vector234
vector234:
  pushl $0
c01043fe:	6a 00                	push   $0x0
  pushl $234
c0104400:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0104405:	e9 fc 00 00 00       	jmp    c0104506 <__alltraps>

c010440a <vector235>:
.globl vector235
vector235:
  pushl $0
c010440a:	6a 00                	push   $0x0
  pushl $235
c010440c:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0104411:	e9 f0 00 00 00       	jmp    c0104506 <__alltraps>

c0104416 <vector236>:
.globl vector236
vector236:
  pushl $0
c0104416:	6a 00                	push   $0x0
  pushl $236
c0104418:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c010441d:	e9 e4 00 00 00       	jmp    c0104506 <__alltraps>

c0104422 <vector237>:
.globl vector237
vector237:
  pushl $0
c0104422:	6a 00                	push   $0x0
  pushl $237
c0104424:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0104429:	e9 d8 00 00 00       	jmp    c0104506 <__alltraps>

c010442e <vector238>:
.globl vector238
vector238:
  pushl $0
c010442e:	6a 00                	push   $0x0
  pushl $238
c0104430:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0104435:	e9 cc 00 00 00       	jmp    c0104506 <__alltraps>

c010443a <vector239>:
.globl vector239
vector239:
  pushl $0
c010443a:	6a 00                	push   $0x0
  pushl $239
c010443c:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0104441:	e9 c0 00 00 00       	jmp    c0104506 <__alltraps>

c0104446 <vector240>:
.globl vector240
vector240:
  pushl $0
c0104446:	6a 00                	push   $0x0
  pushl $240
c0104448:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c010444d:	e9 b4 00 00 00       	jmp    c0104506 <__alltraps>

c0104452 <vector241>:
.globl vector241
vector241:
  pushl $0
c0104452:	6a 00                	push   $0x0
  pushl $241
c0104454:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0104459:	e9 a8 00 00 00       	jmp    c0104506 <__alltraps>

c010445e <vector242>:
.globl vector242
vector242:
  pushl $0
c010445e:	6a 00                	push   $0x0
  pushl $242
c0104460:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0104465:	e9 9c 00 00 00       	jmp    c0104506 <__alltraps>

c010446a <vector243>:
.globl vector243
vector243:
  pushl $0
c010446a:	6a 00                	push   $0x0
  pushl $243
c010446c:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0104471:	e9 90 00 00 00       	jmp    c0104506 <__alltraps>

c0104476 <vector244>:
.globl vector244
vector244:
  pushl $0
c0104476:	6a 00                	push   $0x0
  pushl $244
c0104478:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010447d:	e9 84 00 00 00       	jmp    c0104506 <__alltraps>

c0104482 <vector245>:
.globl vector245
vector245:
  pushl $0
c0104482:	6a 00                	push   $0x0
  pushl $245
c0104484:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0104489:	e9 78 00 00 00       	jmp    c0104506 <__alltraps>

c010448e <vector246>:
.globl vector246
vector246:
  pushl $0
c010448e:	6a 00                	push   $0x0
  pushl $246
c0104490:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0104495:	e9 6c 00 00 00       	jmp    c0104506 <__alltraps>

c010449a <vector247>:
.globl vector247
vector247:
  pushl $0
c010449a:	6a 00                	push   $0x0
  pushl $247
c010449c:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01044a1:	e9 60 00 00 00       	jmp    c0104506 <__alltraps>

c01044a6 <vector248>:
.globl vector248
vector248:
  pushl $0
c01044a6:	6a 00                	push   $0x0
  pushl $248
c01044a8:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01044ad:	e9 54 00 00 00       	jmp    c0104506 <__alltraps>

c01044b2 <vector249>:
.globl vector249
vector249:
  pushl $0
c01044b2:	6a 00                	push   $0x0
  pushl $249
c01044b4:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01044b9:	e9 48 00 00 00       	jmp    c0104506 <__alltraps>

c01044be <vector250>:
.globl vector250
vector250:
  pushl $0
c01044be:	6a 00                	push   $0x0
  pushl $250
c01044c0:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01044c5:	e9 3c 00 00 00       	jmp    c0104506 <__alltraps>

c01044ca <vector251>:
.globl vector251
vector251:
  pushl $0
c01044ca:	6a 00                	push   $0x0
  pushl $251
c01044cc:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01044d1:	e9 30 00 00 00       	jmp    c0104506 <__alltraps>

c01044d6 <vector252>:
.globl vector252
vector252:
  pushl $0
c01044d6:	6a 00                	push   $0x0
  pushl $252
c01044d8:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01044dd:	e9 24 00 00 00       	jmp    c0104506 <__alltraps>

c01044e2 <vector253>:
.globl vector253
vector253:
  pushl $0
c01044e2:	6a 00                	push   $0x0
  pushl $253
c01044e4:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01044e9:	e9 18 00 00 00       	jmp    c0104506 <__alltraps>

c01044ee <vector254>:
.globl vector254
vector254:
  pushl $0
c01044ee:	6a 00                	push   $0x0
  pushl $254
c01044f0:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01044f5:	e9 0c 00 00 00       	jmp    c0104506 <__alltraps>

c01044fa <vector255>:
.globl vector255
vector255:
  pushl $0
c01044fa:	6a 00                	push   $0x0
  pushl $255
c01044fc:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0104501:	e9 00 00 00 00       	jmp    c0104506 <__alltraps>

c0104506 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0104506:	1e                   	push   %ds
    pushl %es
c0104507:	06                   	push   %es
    pushl %fs
c0104508:	0f a0                	push   %fs
    pushl %gs
c010450a:	0f a8                	push   %gs
    pushal
c010450c:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c010450d:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0104512:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0104514:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0104516:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0104517:	e8 63 f5 ff ff       	call   c0103a7f <trap>

    # pop the pushed stack pointer
    popl %esp
c010451c:	5c                   	pop    %esp

c010451d <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c010451d:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c010451e:	0f a9                	pop    %gs
    popl %fs
c0104520:	0f a1                	pop    %fs
    popl %es
c0104522:	07                   	pop    %es
    popl %ds
c0104523:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0104524:	83 c4 08             	add    $0x8,%esp
    iret
c0104527:	cf                   	iret   

c0104528 <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c0104528:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c010452c:	eb ef                	jmp    c010451d <__trapret>

c010452e <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c010452e:	55                   	push   %ebp
c010452f:	89 e5                	mov    %esp,%ebp
c0104531:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0104534:	8b 45 08             	mov    0x8(%ebp),%eax
c0104537:	c1 e8 0c             	shr    $0xc,%eax
c010453a:	89 c2                	mov    %eax,%edx
c010453c:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c0104541:	39 c2                	cmp    %eax,%edx
c0104543:	72 14                	jb     c0104559 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0104545:	83 ec 04             	sub    $0x4,%esp
c0104548:	68 d0 b3 10 c0       	push   $0xc010b3d0
c010454d:	6a 5f                	push   $0x5f
c010454f:	68 ef b3 10 c0       	push   $0xc010b3ef
c0104554:	e8 0f d2 ff ff       	call   c0101768 <__panic>
    }
    return &pages[PPN(pa)];
c0104559:	8b 0d 40 d1 12 c0    	mov    0xc012d140,%ecx
c010455f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104562:	c1 e8 0c             	shr    $0xc,%eax
c0104565:	89 c2                	mov    %eax,%edx
c0104567:	89 d0                	mov    %edx,%eax
c0104569:	c1 e0 03             	shl    $0x3,%eax
c010456c:	01 d0                	add    %edx,%eax
c010456e:	c1 e0 02             	shl    $0x2,%eax
c0104571:	01 c8                	add    %ecx,%eax
}
c0104573:	c9                   	leave  
c0104574:	c3                   	ret    

c0104575 <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c0104575:	55                   	push   %ebp
c0104576:	89 e5                	mov    %esp,%ebp
c0104578:	83 ec 08             	sub    $0x8,%esp
    return pa2page(PDE_ADDR(pde));
c010457b:	8b 45 08             	mov    0x8(%ebp),%eax
c010457e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104583:	83 ec 0c             	sub    $0xc,%esp
c0104586:	50                   	push   %eax
c0104587:	e8 a2 ff ff ff       	call   c010452e <pa2page>
c010458c:	83 c4 10             	add    $0x10,%esp
}
c010458f:	c9                   	leave  
c0104590:	c3                   	ret    

c0104591 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0104591:	55                   	push   %ebp
c0104592:	89 e5                	mov    %esp,%ebp
c0104594:	83 ec 18             	sub    $0x18,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0104597:	83 ec 0c             	sub    $0xc,%esp
c010459a:	6a 18                	push   $0x18
c010459c:	e8 6d 1c 00 00       	call   c010620e <kmalloc>
c01045a1:	83 c4 10             	add    $0x10,%esp
c01045a4:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c01045a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01045ab:	74 5b                	je     c0104608 <mm_create+0x77>
        list_init(&(mm->mmap_list));
c01045ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01045b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01045b9:	89 50 04             	mov    %edx,0x4(%eax)
c01045bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045bf:	8b 50 04             	mov    0x4(%eax),%edx
c01045c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045c5:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c01045c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045ca:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c01045d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045d4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c01045db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045de:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c01045e5:	a1 68 af 12 c0       	mov    0xc012af68,%eax
c01045ea:	85 c0                	test   %eax,%eax
c01045ec:	74 10                	je     c01045fe <mm_create+0x6d>
c01045ee:	83 ec 0c             	sub    $0xc,%esp
c01045f1:	ff 75 f4             	pushl  -0xc(%ebp)
c01045f4:	e8 59 0c 00 00       	call   c0105252 <swap_init_mm>
c01045f9:	83 c4 10             	add    $0x10,%esp
c01045fc:	eb 0a                	jmp    c0104608 <mm_create+0x77>
        else mm->sm_priv = NULL;
c01045fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104601:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c0104608:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010460b:	c9                   	leave  
c010460c:	c3                   	ret    

c010460d <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c010460d:	55                   	push   %ebp
c010460e:	89 e5                	mov    %esp,%ebp
c0104610:	83 ec 18             	sub    $0x18,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0104613:	83 ec 0c             	sub    $0xc,%esp
c0104616:	6a 18                	push   $0x18
c0104618:	e8 f1 1b 00 00       	call   c010620e <kmalloc>
c010461d:	83 c4 10             	add    $0x10,%esp
c0104620:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0104623:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104627:	74 1b                	je     c0104644 <vma_create+0x37>
        vma->vm_start = vm_start;
c0104629:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010462c:	8b 55 08             	mov    0x8(%ebp),%edx
c010462f:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0104632:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104635:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104638:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c010463b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010463e:	8b 55 10             	mov    0x10(%ebp),%edx
c0104641:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0104644:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104647:	c9                   	leave  
c0104648:	c3                   	ret    

c0104649 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0104649:	55                   	push   %ebp
c010464a:	89 e5                	mov    %esp,%ebp
c010464c:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c010464f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0104656:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010465a:	0f 84 95 00 00 00    	je     c01046f5 <find_vma+0xac>
        vma = mm->mmap_cache;
c0104660:	8b 45 08             	mov    0x8(%ebp),%eax
c0104663:	8b 40 08             	mov    0x8(%eax),%eax
c0104666:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0104669:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010466d:	74 16                	je     c0104685 <find_vma+0x3c>
c010466f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104672:	8b 40 04             	mov    0x4(%eax),%eax
c0104675:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104678:	77 0b                	ja     c0104685 <find_vma+0x3c>
c010467a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010467d:	8b 40 08             	mov    0x8(%eax),%eax
c0104680:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104683:	77 61                	ja     c01046e6 <find_vma+0x9d>
                bool found = 0;
c0104685:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c010468c:	8b 45 08             	mov    0x8(%ebp),%eax
c010468f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104692:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104695:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0104698:	eb 28                	jmp    c01046c2 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c010469a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010469d:	83 e8 10             	sub    $0x10,%eax
c01046a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c01046a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01046a6:	8b 40 04             	mov    0x4(%eax),%eax
c01046a9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01046ac:	77 14                	ja     c01046c2 <find_vma+0x79>
c01046ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01046b1:	8b 40 08             	mov    0x8(%eax),%eax
c01046b4:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01046b7:	76 09                	jbe    c01046c2 <find_vma+0x79>
                        found = 1;
c01046b9:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c01046c0:	eb 17                	jmp    c01046d9 <find_vma+0x90>
c01046c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01046c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01046cb:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c01046ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01046d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046d4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01046d7:	75 c1                	jne    c010469a <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c01046d9:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c01046dd:	75 07                	jne    c01046e6 <find_vma+0x9d>
                    vma = NULL;
c01046df:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c01046e6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01046ea:	74 09                	je     c01046f5 <find_vma+0xac>
            mm->mmap_cache = vma;
c01046ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01046ef:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01046f2:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c01046f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01046f8:	c9                   	leave  
c01046f9:	c3                   	ret    

c01046fa <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c01046fa:	55                   	push   %ebp
c01046fb:	89 e5                	mov    %esp,%ebp
c01046fd:	83 ec 08             	sub    $0x8,%esp
    assert(prev->vm_start < prev->vm_end);
c0104700:	8b 45 08             	mov    0x8(%ebp),%eax
c0104703:	8b 50 04             	mov    0x4(%eax),%edx
c0104706:	8b 45 08             	mov    0x8(%ebp),%eax
c0104709:	8b 40 08             	mov    0x8(%eax),%eax
c010470c:	39 c2                	cmp    %eax,%edx
c010470e:	72 16                	jb     c0104726 <check_vma_overlap+0x2c>
c0104710:	68 fd b3 10 c0       	push   $0xc010b3fd
c0104715:	68 1b b4 10 c0       	push   $0xc010b41b
c010471a:	6a 68                	push   $0x68
c010471c:	68 30 b4 10 c0       	push   $0xc010b430
c0104721:	e8 42 d0 ff ff       	call   c0101768 <__panic>
    assert(prev->vm_end <= next->vm_start);
c0104726:	8b 45 08             	mov    0x8(%ebp),%eax
c0104729:	8b 50 08             	mov    0x8(%eax),%edx
c010472c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010472f:	8b 40 04             	mov    0x4(%eax),%eax
c0104732:	39 c2                	cmp    %eax,%edx
c0104734:	76 16                	jbe    c010474c <check_vma_overlap+0x52>
c0104736:	68 40 b4 10 c0       	push   $0xc010b440
c010473b:	68 1b b4 10 c0       	push   $0xc010b41b
c0104740:	6a 69                	push   $0x69
c0104742:	68 30 b4 10 c0       	push   $0xc010b430
c0104747:	e8 1c d0 ff ff       	call   c0101768 <__panic>
    assert(next->vm_start < next->vm_end);
c010474c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010474f:	8b 50 04             	mov    0x4(%eax),%edx
c0104752:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104755:	8b 40 08             	mov    0x8(%eax),%eax
c0104758:	39 c2                	cmp    %eax,%edx
c010475a:	72 16                	jb     c0104772 <check_vma_overlap+0x78>
c010475c:	68 5f b4 10 c0       	push   $0xc010b45f
c0104761:	68 1b b4 10 c0       	push   $0xc010b41b
c0104766:	6a 6a                	push   $0x6a
c0104768:	68 30 b4 10 c0       	push   $0xc010b430
c010476d:	e8 f6 cf ff ff       	call   c0101768 <__panic>
}
c0104772:	90                   	nop
c0104773:	c9                   	leave  
c0104774:	c3                   	ret    

c0104775 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0104775:	55                   	push   %ebp
c0104776:	89 e5                	mov    %esp,%ebp
c0104778:	83 ec 38             	sub    $0x38,%esp
    assert(vma->vm_start < vma->vm_end);
c010477b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010477e:	8b 50 04             	mov    0x4(%eax),%edx
c0104781:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104784:	8b 40 08             	mov    0x8(%eax),%eax
c0104787:	39 c2                	cmp    %eax,%edx
c0104789:	72 16                	jb     c01047a1 <insert_vma_struct+0x2c>
c010478b:	68 7d b4 10 c0       	push   $0xc010b47d
c0104790:	68 1b b4 10 c0       	push   $0xc010b41b
c0104795:	6a 71                	push   $0x71
c0104797:	68 30 b4 10 c0       	push   $0xc010b430
c010479c:	e8 c7 cf ff ff       	call   c0101768 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c01047a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01047a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c01047a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047aa:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c01047ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c01047b3:	eb 1f                	jmp    c01047d4 <insert_vma_struct+0x5f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c01047b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047b8:	83 e8 10             	sub    $0x10,%eax
c01047bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c01047be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01047c1:	8b 50 04             	mov    0x4(%eax),%edx
c01047c4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047c7:	8b 40 04             	mov    0x4(%eax),%eax
c01047ca:	39 c2                	cmp    %eax,%edx
c01047cc:	77 1f                	ja     c01047ed <insert_vma_struct+0x78>
                break;
            }
            le_prev = le;
c01047ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01047d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01047da:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01047dd:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c01047e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01047e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047e6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01047e9:	75 ca                	jne    c01047b5 <insert_vma_struct+0x40>
c01047eb:	eb 01                	jmp    c01047ee <insert_vma_struct+0x79>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
                break;
c01047ed:	90                   	nop
c01047ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01047f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01047f7:	8b 40 04             	mov    0x4(%eax),%eax
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c01047fa:	89 45 dc             	mov    %eax,-0x24(%ebp)

    /* check overlap */
    if (le_prev != list) {
c01047fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104800:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104803:	74 15                	je     c010481a <insert_vma_struct+0xa5>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0104805:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104808:	83 e8 10             	sub    $0x10,%eax
c010480b:	83 ec 08             	sub    $0x8,%esp
c010480e:	ff 75 0c             	pushl  0xc(%ebp)
c0104811:	50                   	push   %eax
c0104812:	e8 e3 fe ff ff       	call   c01046fa <check_vma_overlap>
c0104817:	83 c4 10             	add    $0x10,%esp
    }
    if (le_next != list) {
c010481a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010481d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104820:	74 15                	je     c0104837 <insert_vma_struct+0xc2>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0104822:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104825:	83 e8 10             	sub    $0x10,%eax
c0104828:	83 ec 08             	sub    $0x8,%esp
c010482b:	50                   	push   %eax
c010482c:	ff 75 0c             	pushl  0xc(%ebp)
c010482f:	e8 c6 fe ff ff       	call   c01046fa <check_vma_overlap>
c0104834:	83 c4 10             	add    $0x10,%esp
    }

    vma->vm_mm = mm;
c0104837:	8b 45 0c             	mov    0xc(%ebp),%eax
c010483a:	8b 55 08             	mov    0x8(%ebp),%edx
c010483d:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c010483f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104842:	8d 50 10             	lea    0x10(%eax),%edx
c0104845:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104848:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010484b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010484e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104851:	8b 40 04             	mov    0x4(%eax),%eax
c0104854:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104857:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010485a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010485d:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0104860:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104863:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104866:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104869:	89 10                	mov    %edx,(%eax)
c010486b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010486e:	8b 10                	mov    (%eax),%edx
c0104870:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104873:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104876:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104879:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010487c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010487f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104882:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104885:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c0104887:	8b 45 08             	mov    0x8(%ebp),%eax
c010488a:	8b 40 10             	mov    0x10(%eax),%eax
c010488d:	8d 50 01             	lea    0x1(%eax),%edx
c0104890:	8b 45 08             	mov    0x8(%ebp),%eax
c0104893:	89 50 10             	mov    %edx,0x10(%eax)
}
c0104896:	90                   	nop
c0104897:	c9                   	leave  
c0104898:	c3                   	ret    

c0104899 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0104899:	55                   	push   %ebp
c010489a:	89 e5                	mov    %esp,%ebp
c010489c:	83 ec 28             	sub    $0x28,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c010489f:	8b 45 08             	mov    0x8(%ebp),%eax
c01048a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c01048a5:	eb 3a                	jmp    c01048e1 <mm_destroy+0x48>
c01048a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048aa:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01048ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01048b0:	8b 40 04             	mov    0x4(%eax),%eax
c01048b3:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01048b6:	8b 12                	mov    (%edx),%edx
c01048b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01048bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01048be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01048c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01048c4:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01048c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01048ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01048cd:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c01048cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048d2:	83 e8 10             	sub    $0x10,%eax
c01048d5:	83 ec 0c             	sub    $0xc,%esp
c01048d8:	50                   	push   %eax
c01048d9:	e8 48 19 00 00       	call   c0106226 <kfree>
c01048de:	83 c4 10             	add    $0x10,%esp
c01048e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01048e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048ea:	8b 40 04             	mov    0x4(%eax),%eax
// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c01048ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01048f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048f3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01048f6:	75 af                	jne    c01048a7 <mm_destroy+0xe>
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
    }
    kfree(mm); //kfree mm
c01048f8:	83 ec 0c             	sub    $0xc,%esp
c01048fb:	ff 75 08             	pushl  0x8(%ebp)
c01048fe:	e8 23 19 00 00       	call   c0106226 <kfree>
c0104903:	83 c4 10             	add    $0x10,%esp
    mm=NULL;
c0104906:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c010490d:	90                   	nop
c010490e:	c9                   	leave  
c010490f:	c3                   	ret    

c0104910 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0104910:	55                   	push   %ebp
c0104911:	89 e5                	mov    %esp,%ebp
c0104913:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0104916:	e8 03 00 00 00       	call   c010491e <check_vmm>
}
c010491b:	90                   	nop
c010491c:	c9                   	leave  
c010491d:	c3                   	ret    

c010491e <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c010491e:	55                   	push   %ebp
c010491f:	89 e5                	mov    %esp,%ebp
c0104921:	83 ec 18             	sub    $0x18,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0104924:	e8 8d 32 00 00       	call   c0107bb6 <nr_free_pages>
c0104929:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c010492c:	e8 18 00 00 00       	call   c0104949 <check_vma_struct>
    check_pgfault();
c0104931:	e8 10 04 00 00       	call   c0104d46 <check_pgfault>

 //   assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vmm() succeeded.\n");
c0104936:	83 ec 0c             	sub    $0xc,%esp
c0104939:	68 99 b4 10 c0       	push   $0xc010b499
c010493e:	e8 47 b9 ff ff       	call   c010028a <cprintf>
c0104943:	83 c4 10             	add    $0x10,%esp
}
c0104946:	90                   	nop
c0104947:	c9                   	leave  
c0104948:	c3                   	ret    

c0104949 <check_vma_struct>:

static void
check_vma_struct(void) {
c0104949:	55                   	push   %ebp
c010494a:	89 e5                	mov    %esp,%ebp
c010494c:	83 ec 58             	sub    $0x58,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010494f:	e8 62 32 00 00       	call   c0107bb6 <nr_free_pages>
c0104954:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0104957:	e8 35 fc ff ff       	call   c0104591 <mm_create>
c010495c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c010495f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104963:	75 19                	jne    c010497e <check_vma_struct+0x35>
c0104965:	68 b1 b4 10 c0       	push   $0xc010b4b1
c010496a:	68 1b b4 10 c0       	push   $0xc010b41b
c010496f:	68 b4 00 00 00       	push   $0xb4
c0104974:	68 30 b4 10 c0       	push   $0xc010b430
c0104979:	e8 ea cd ff ff       	call   c0101768 <__panic>

    int step1 = 10, step2 = step1 * 10;
c010497e:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0104985:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104988:	89 d0                	mov    %edx,%eax
c010498a:	c1 e0 02             	shl    $0x2,%eax
c010498d:	01 d0                	add    %edx,%eax
c010498f:	01 c0                	add    %eax,%eax
c0104991:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0104994:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104997:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010499a:	eb 5f                	jmp    c01049fb <check_vma_struct+0xb2>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c010499c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010499f:	89 d0                	mov    %edx,%eax
c01049a1:	c1 e0 02             	shl    $0x2,%eax
c01049a4:	01 d0                	add    %edx,%eax
c01049a6:	83 c0 02             	add    $0x2,%eax
c01049a9:	89 c1                	mov    %eax,%ecx
c01049ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01049ae:	89 d0                	mov    %edx,%eax
c01049b0:	c1 e0 02             	shl    $0x2,%eax
c01049b3:	01 d0                	add    %edx,%eax
c01049b5:	83 ec 04             	sub    $0x4,%esp
c01049b8:	6a 00                	push   $0x0
c01049ba:	51                   	push   %ecx
c01049bb:	50                   	push   %eax
c01049bc:	e8 4c fc ff ff       	call   c010460d <vma_create>
c01049c1:	83 c4 10             	add    $0x10,%esp
c01049c4:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c01049c7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01049cb:	75 19                	jne    c01049e6 <check_vma_struct+0x9d>
c01049cd:	68 bc b4 10 c0       	push   $0xc010b4bc
c01049d2:	68 1b b4 10 c0       	push   $0xc010b41b
c01049d7:	68 bb 00 00 00       	push   $0xbb
c01049dc:	68 30 b4 10 c0       	push   $0xc010b430
c01049e1:	e8 82 cd ff ff       	call   c0101768 <__panic>
        insert_vma_struct(mm, vma);
c01049e6:	83 ec 08             	sub    $0x8,%esp
c01049e9:	ff 75 dc             	pushl  -0x24(%ebp)
c01049ec:	ff 75 e8             	pushl  -0x18(%ebp)
c01049ef:	e8 81 fd ff ff       	call   c0104775 <insert_vma_struct>
c01049f4:	83 c4 10             	add    $0x10,%esp
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c01049f7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01049fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01049ff:	7f 9b                	jg     c010499c <check_vma_struct+0x53>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0104a01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a04:	83 c0 01             	add    $0x1,%eax
c0104a07:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104a0a:	eb 5f                	jmp    c0104a6b <check_vma_struct+0x122>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0104a0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104a0f:	89 d0                	mov    %edx,%eax
c0104a11:	c1 e0 02             	shl    $0x2,%eax
c0104a14:	01 d0                	add    %edx,%eax
c0104a16:	83 c0 02             	add    $0x2,%eax
c0104a19:	89 c1                	mov    %eax,%ecx
c0104a1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104a1e:	89 d0                	mov    %edx,%eax
c0104a20:	c1 e0 02             	shl    $0x2,%eax
c0104a23:	01 d0                	add    %edx,%eax
c0104a25:	83 ec 04             	sub    $0x4,%esp
c0104a28:	6a 00                	push   $0x0
c0104a2a:	51                   	push   %ecx
c0104a2b:	50                   	push   %eax
c0104a2c:	e8 dc fb ff ff       	call   c010460d <vma_create>
c0104a31:	83 c4 10             	add    $0x10,%esp
c0104a34:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c0104a37:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0104a3b:	75 19                	jne    c0104a56 <check_vma_struct+0x10d>
c0104a3d:	68 bc b4 10 c0       	push   $0xc010b4bc
c0104a42:	68 1b b4 10 c0       	push   $0xc010b41b
c0104a47:	68 c1 00 00 00       	push   $0xc1
c0104a4c:	68 30 b4 10 c0       	push   $0xc010b430
c0104a51:	e8 12 cd ff ff       	call   c0101768 <__panic>
        insert_vma_struct(mm, vma);
c0104a56:	83 ec 08             	sub    $0x8,%esp
c0104a59:	ff 75 d8             	pushl  -0x28(%ebp)
c0104a5c:	ff 75 e8             	pushl  -0x18(%ebp)
c0104a5f:	e8 11 fd ff ff       	call   c0104775 <insert_vma_struct>
c0104a64:	83 c4 10             	add    $0x10,%esp
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0104a67:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a6e:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0104a71:	7e 99                	jle    c0104a0c <check_vma_struct+0xc3>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0104a73:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104a76:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0104a79:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104a7c:	8b 40 04             	mov    0x4(%eax),%eax
c0104a7f:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0104a82:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0104a89:	e9 81 00 00 00       	jmp    c0104b0f <check_vma_struct+0x1c6>
        assert(le != &(mm->mmap_list));
c0104a8e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104a91:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104a94:	75 19                	jne    c0104aaf <check_vma_struct+0x166>
c0104a96:	68 c8 b4 10 c0       	push   $0xc010b4c8
c0104a9b:	68 1b b4 10 c0       	push   $0xc010b41b
c0104aa0:	68 c8 00 00 00       	push   $0xc8
c0104aa5:	68 30 b4 10 c0       	push   $0xc010b430
c0104aaa:	e8 b9 cc ff ff       	call   c0101768 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0104aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ab2:	83 e8 10             	sub    $0x10,%eax
c0104ab5:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0104ab8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104abb:	8b 48 04             	mov    0x4(%eax),%ecx
c0104abe:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104ac1:	89 d0                	mov    %edx,%eax
c0104ac3:	c1 e0 02             	shl    $0x2,%eax
c0104ac6:	01 d0                	add    %edx,%eax
c0104ac8:	39 c1                	cmp    %eax,%ecx
c0104aca:	75 17                	jne    c0104ae3 <check_vma_struct+0x19a>
c0104acc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104acf:	8b 48 08             	mov    0x8(%eax),%ecx
c0104ad2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104ad5:	89 d0                	mov    %edx,%eax
c0104ad7:	c1 e0 02             	shl    $0x2,%eax
c0104ada:	01 d0                	add    %edx,%eax
c0104adc:	83 c0 02             	add    $0x2,%eax
c0104adf:	39 c1                	cmp    %eax,%ecx
c0104ae1:	74 19                	je     c0104afc <check_vma_struct+0x1b3>
c0104ae3:	68 e0 b4 10 c0       	push   $0xc010b4e0
c0104ae8:	68 1b b4 10 c0       	push   $0xc010b41b
c0104aed:	68 ca 00 00 00       	push   $0xca
c0104af2:	68 30 b4 10 c0       	push   $0xc010b430
c0104af7:	e8 6c cc ff ff       	call   c0101768 <__panic>
c0104afc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104aff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0104b02:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104b05:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0104b08:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c0104b0b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b12:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0104b15:	0f 8e 73 ff ff ff    	jle    c0104a8e <check_vma_struct+0x145>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0104b1b:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0104b22:	e9 80 01 00 00       	jmp    c0104ca7 <check_vma_struct+0x35e>
        struct vma_struct *vma1 = find_vma(mm, i);
c0104b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b2a:	83 ec 08             	sub    $0x8,%esp
c0104b2d:	50                   	push   %eax
c0104b2e:	ff 75 e8             	pushl  -0x18(%ebp)
c0104b31:	e8 13 fb ff ff       	call   c0104649 <find_vma>
c0104b36:	83 c4 10             	add    $0x10,%esp
c0104b39:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma1 != NULL);
c0104b3c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104b40:	75 19                	jne    c0104b5b <check_vma_struct+0x212>
c0104b42:	68 15 b5 10 c0       	push   $0xc010b515
c0104b47:	68 1b b4 10 c0       	push   $0xc010b41b
c0104b4c:	68 d0 00 00 00       	push   $0xd0
c0104b51:	68 30 b4 10 c0       	push   $0xc010b430
c0104b56:	e8 0d cc ff ff       	call   c0101768 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0104b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b5e:	83 c0 01             	add    $0x1,%eax
c0104b61:	83 ec 08             	sub    $0x8,%esp
c0104b64:	50                   	push   %eax
c0104b65:	ff 75 e8             	pushl  -0x18(%ebp)
c0104b68:	e8 dc fa ff ff       	call   c0104649 <find_vma>
c0104b6d:	83 c4 10             	add    $0x10,%esp
c0104b70:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma2 != NULL);
c0104b73:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0104b77:	75 19                	jne    c0104b92 <check_vma_struct+0x249>
c0104b79:	68 22 b5 10 c0       	push   $0xc010b522
c0104b7e:	68 1b b4 10 c0       	push   $0xc010b41b
c0104b83:	68 d2 00 00 00       	push   $0xd2
c0104b88:	68 30 b4 10 c0       	push   $0xc010b430
c0104b8d:	e8 d6 cb ff ff       	call   c0101768 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0104b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b95:	83 c0 02             	add    $0x2,%eax
c0104b98:	83 ec 08             	sub    $0x8,%esp
c0104b9b:	50                   	push   %eax
c0104b9c:	ff 75 e8             	pushl  -0x18(%ebp)
c0104b9f:	e8 a5 fa ff ff       	call   c0104649 <find_vma>
c0104ba4:	83 c4 10             	add    $0x10,%esp
c0104ba7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma3 == NULL);
c0104baa:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0104bae:	74 19                	je     c0104bc9 <check_vma_struct+0x280>
c0104bb0:	68 2f b5 10 c0       	push   $0xc010b52f
c0104bb5:	68 1b b4 10 c0       	push   $0xc010b41b
c0104bba:	68 d4 00 00 00       	push   $0xd4
c0104bbf:	68 30 b4 10 c0       	push   $0xc010b430
c0104bc4:	e8 9f cb ff ff       	call   c0101768 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0104bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bcc:	83 c0 03             	add    $0x3,%eax
c0104bcf:	83 ec 08             	sub    $0x8,%esp
c0104bd2:	50                   	push   %eax
c0104bd3:	ff 75 e8             	pushl  -0x18(%ebp)
c0104bd6:	e8 6e fa ff ff       	call   c0104649 <find_vma>
c0104bdb:	83 c4 10             	add    $0x10,%esp
c0104bde:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma4 == NULL);
c0104be1:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0104be5:	74 19                	je     c0104c00 <check_vma_struct+0x2b7>
c0104be7:	68 3c b5 10 c0       	push   $0xc010b53c
c0104bec:	68 1b b4 10 c0       	push   $0xc010b41b
c0104bf1:	68 d6 00 00 00       	push   $0xd6
c0104bf6:	68 30 b4 10 c0       	push   $0xc010b430
c0104bfb:	e8 68 cb ff ff       	call   c0101768 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0104c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c03:	83 c0 04             	add    $0x4,%eax
c0104c06:	83 ec 08             	sub    $0x8,%esp
c0104c09:	50                   	push   %eax
c0104c0a:	ff 75 e8             	pushl  -0x18(%ebp)
c0104c0d:	e8 37 fa ff ff       	call   c0104649 <find_vma>
c0104c12:	83 c4 10             	add    $0x10,%esp
c0104c15:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma5 == NULL);
c0104c18:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0104c1c:	74 19                	je     c0104c37 <check_vma_struct+0x2ee>
c0104c1e:	68 49 b5 10 c0       	push   $0xc010b549
c0104c23:	68 1b b4 10 c0       	push   $0xc010b41b
c0104c28:	68 d8 00 00 00       	push   $0xd8
c0104c2d:	68 30 b4 10 c0       	push   $0xc010b430
c0104c32:	e8 31 cb ff ff       	call   c0101768 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0104c37:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104c3a:	8b 50 04             	mov    0x4(%eax),%edx
c0104c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c40:	39 c2                	cmp    %eax,%edx
c0104c42:	75 10                	jne    c0104c54 <check_vma_struct+0x30b>
c0104c44:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104c47:	8b 40 08             	mov    0x8(%eax),%eax
c0104c4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104c4d:	83 c2 02             	add    $0x2,%edx
c0104c50:	39 d0                	cmp    %edx,%eax
c0104c52:	74 19                	je     c0104c6d <check_vma_struct+0x324>
c0104c54:	68 58 b5 10 c0       	push   $0xc010b558
c0104c59:	68 1b b4 10 c0       	push   $0xc010b41b
c0104c5e:	68 da 00 00 00       	push   $0xda
c0104c63:	68 30 b4 10 c0       	push   $0xc010b430
c0104c68:	e8 fb ca ff ff       	call   c0101768 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0104c6d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104c70:	8b 50 04             	mov    0x4(%eax),%edx
c0104c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c76:	39 c2                	cmp    %eax,%edx
c0104c78:	75 10                	jne    c0104c8a <check_vma_struct+0x341>
c0104c7a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104c7d:	8b 40 08             	mov    0x8(%eax),%eax
c0104c80:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104c83:	83 c2 02             	add    $0x2,%edx
c0104c86:	39 d0                	cmp    %edx,%eax
c0104c88:	74 19                	je     c0104ca3 <check_vma_struct+0x35a>
c0104c8a:	68 88 b5 10 c0       	push   $0xc010b588
c0104c8f:	68 1b b4 10 c0       	push   $0xc010b41b
c0104c94:	68 db 00 00 00       	push   $0xdb
c0104c99:	68 30 b4 10 c0       	push   $0xc010b430
c0104c9e:	e8 c5 ca ff ff       	call   c0101768 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0104ca3:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0104ca7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104caa:	89 d0                	mov    %edx,%eax
c0104cac:	c1 e0 02             	shl    $0x2,%eax
c0104caf:	01 d0                	add    %edx,%eax
c0104cb1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104cb4:	0f 8d 6d fe ff ff    	jge    c0104b27 <check_vma_struct+0x1de>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0104cba:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0104cc1:	eb 5c                	jmp    c0104d1f <check_vma_struct+0x3d6>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0104cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cc6:	83 ec 08             	sub    $0x8,%esp
c0104cc9:	50                   	push   %eax
c0104cca:	ff 75 e8             	pushl  -0x18(%ebp)
c0104ccd:	e8 77 f9 ff ff       	call   c0104649 <find_vma>
c0104cd2:	83 c4 10             	add    $0x10,%esp
c0104cd5:	89 45 b8             	mov    %eax,-0x48(%ebp)
        if (vma_below_5 != NULL ) {
c0104cd8:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104cdc:	74 1e                	je     c0104cfc <check_vma_struct+0x3b3>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0104cde:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104ce1:	8b 50 08             	mov    0x8(%eax),%edx
c0104ce4:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104ce7:	8b 40 04             	mov    0x4(%eax),%eax
c0104cea:	52                   	push   %edx
c0104ceb:	50                   	push   %eax
c0104cec:	ff 75 f4             	pushl  -0xc(%ebp)
c0104cef:	68 b8 b5 10 c0       	push   $0xc010b5b8
c0104cf4:	e8 91 b5 ff ff       	call   c010028a <cprintf>
c0104cf9:	83 c4 10             	add    $0x10,%esp
        }
        assert(vma_below_5 == NULL);
c0104cfc:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104d00:	74 19                	je     c0104d1b <check_vma_struct+0x3d2>
c0104d02:	68 dd b5 10 c0       	push   $0xc010b5dd
c0104d07:	68 1b b4 10 c0       	push   $0xc010b41b
c0104d0c:	68 e3 00 00 00       	push   $0xe3
c0104d11:	68 30 b4 10 c0       	push   $0xc010b430
c0104d16:	e8 4d ca ff ff       	call   c0101768 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0104d1b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104d1f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104d23:	79 9e                	jns    c0104cc3 <check_vma_struct+0x37a>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c0104d25:	83 ec 0c             	sub    $0xc,%esp
c0104d28:	ff 75 e8             	pushl  -0x18(%ebp)
c0104d2b:	e8 69 fb ff ff       	call   c0104899 <mm_destroy>
c0104d30:	83 c4 10             	add    $0x10,%esp

//    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vma_struct() succeeded!\n");
c0104d33:	83 ec 0c             	sub    $0xc,%esp
c0104d36:	68 f4 b5 10 c0       	push   $0xc010b5f4
c0104d3b:	e8 4a b5 ff ff       	call   c010028a <cprintf>
c0104d40:	83 c4 10             	add    $0x10,%esp
}
c0104d43:	90                   	nop
c0104d44:	c9                   	leave  
c0104d45:	c3                   	ret    

c0104d46 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0104d46:	55                   	push   %ebp
c0104d47:	89 e5                	mov    %esp,%ebp
c0104d49:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0104d4c:	e8 65 2e 00 00       	call   c0107bb6 <nr_free_pages>
c0104d51:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0104d54:	e8 38 f8 ff ff       	call   c0104591 <mm_create>
c0104d59:	a3 58 d0 12 c0       	mov    %eax,0xc012d058
    assert(check_mm_struct != NULL);
c0104d5e:	a1 58 d0 12 c0       	mov    0xc012d058,%eax
c0104d63:	85 c0                	test   %eax,%eax
c0104d65:	75 19                	jne    c0104d80 <check_pgfault+0x3a>
c0104d67:	68 13 b6 10 c0       	push   $0xc010b613
c0104d6c:	68 1b b4 10 c0       	push   $0xc010b41b
c0104d71:	68 f5 00 00 00       	push   $0xf5
c0104d76:	68 30 b4 10 c0       	push   $0xc010b430
c0104d7b:	e8 e8 c9 ff ff       	call   c0101768 <__panic>

    struct mm_struct *mm = check_mm_struct;
c0104d80:	a1 58 d0 12 c0       	mov    0xc012d058,%eax
c0104d85:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0104d88:	8b 15 20 7a 12 c0    	mov    0xc0127a20,%edx
c0104d8e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d91:	89 50 0c             	mov    %edx,0xc(%eax)
c0104d94:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d97:	8b 40 0c             	mov    0xc(%eax),%eax
c0104d9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0104d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104da0:	8b 00                	mov    (%eax),%eax
c0104da2:	85 c0                	test   %eax,%eax
c0104da4:	74 19                	je     c0104dbf <check_pgfault+0x79>
c0104da6:	68 2b b6 10 c0       	push   $0xc010b62b
c0104dab:	68 1b b4 10 c0       	push   $0xc010b41b
c0104db0:	68 f9 00 00 00       	push   $0xf9
c0104db5:	68 30 b4 10 c0       	push   $0xc010b430
c0104dba:	e8 a9 c9 ff ff       	call   c0101768 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0104dbf:	83 ec 04             	sub    $0x4,%esp
c0104dc2:	6a 02                	push   $0x2
c0104dc4:	68 00 00 40 00       	push   $0x400000
c0104dc9:	6a 00                	push   $0x0
c0104dcb:	e8 3d f8 ff ff       	call   c010460d <vma_create>
c0104dd0:	83 c4 10             	add    $0x10,%esp
c0104dd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0104dd6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104dda:	75 19                	jne    c0104df5 <check_pgfault+0xaf>
c0104ddc:	68 bc b4 10 c0       	push   $0xc010b4bc
c0104de1:	68 1b b4 10 c0       	push   $0xc010b41b
c0104de6:	68 fc 00 00 00       	push   $0xfc
c0104deb:	68 30 b4 10 c0       	push   $0xc010b430
c0104df0:	e8 73 c9 ff ff       	call   c0101768 <__panic>

    insert_vma_struct(mm, vma);
c0104df5:	83 ec 08             	sub    $0x8,%esp
c0104df8:	ff 75 e0             	pushl  -0x20(%ebp)
c0104dfb:	ff 75 e8             	pushl  -0x18(%ebp)
c0104dfe:	e8 72 f9 ff ff       	call   c0104775 <insert_vma_struct>
c0104e03:	83 c4 10             	add    $0x10,%esp

    uintptr_t addr = 0x100;
c0104e06:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0104e0d:	83 ec 08             	sub    $0x8,%esp
c0104e10:	ff 75 dc             	pushl  -0x24(%ebp)
c0104e13:	ff 75 e8             	pushl  -0x18(%ebp)
c0104e16:	e8 2e f8 ff ff       	call   c0104649 <find_vma>
c0104e1b:	83 c4 10             	add    $0x10,%esp
c0104e1e:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0104e21:	74 19                	je     c0104e3c <check_pgfault+0xf6>
c0104e23:	68 39 b6 10 c0       	push   $0xc010b639
c0104e28:	68 1b b4 10 c0       	push   $0xc010b41b
c0104e2d:	68 01 01 00 00       	push   $0x101
c0104e32:	68 30 b4 10 c0       	push   $0xc010b430
c0104e37:	e8 2c c9 ff ff       	call   c0101768 <__panic>

    int i, sum = 0;
c0104e3c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0104e43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104e4a:	eb 19                	jmp    c0104e65 <check_pgfault+0x11f>
        *(char *)(addr + i) = i;
c0104e4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104e4f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104e52:	01 d0                	add    %edx,%eax
c0104e54:	89 c2                	mov    %eax,%edx
c0104e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e59:	88 02                	mov    %al,(%edx)
        sum += i;
c0104e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e5e:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c0104e61:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104e65:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0104e69:	7e e1                	jle    c0104e4c <check_pgfault+0x106>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0104e6b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104e72:	eb 15                	jmp    c0104e89 <check_pgfault+0x143>
        sum -= *(char *)(addr + i);
c0104e74:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104e77:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104e7a:	01 d0                	add    %edx,%eax
c0104e7c:	0f b6 00             	movzbl (%eax),%eax
c0104e7f:	0f be c0             	movsbl %al,%eax
c0104e82:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0104e85:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104e89:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0104e8d:	7e e5                	jle    c0104e74 <check_pgfault+0x12e>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c0104e8f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104e93:	74 19                	je     c0104eae <check_pgfault+0x168>
c0104e95:	68 53 b6 10 c0       	push   $0xc010b653
c0104e9a:	68 1b b4 10 c0       	push   $0xc010b41b
c0104e9f:	68 0b 01 00 00       	push   $0x10b
c0104ea4:	68 30 b4 10 c0       	push   $0xc010b430
c0104ea9:	e8 ba c8 ff ff       	call   c0101768 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0104eae:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104eb1:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0104eb4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104eb7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104ebc:	83 ec 08             	sub    $0x8,%esp
c0104ebf:	50                   	push   %eax
c0104ec0:	ff 75 e4             	pushl  -0x1c(%ebp)
c0104ec3:	e8 a1 34 00 00       	call   c0108369 <page_remove>
c0104ec8:	83 c4 10             	add    $0x10,%esp
    free_page(pde2page(pgdir[0]));
c0104ecb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ece:	8b 00                	mov    (%eax),%eax
c0104ed0:	83 ec 0c             	sub    $0xc,%esp
c0104ed3:	50                   	push   %eax
c0104ed4:	e8 9c f6 ff ff       	call   c0104575 <pde2page>
c0104ed9:	83 c4 10             	add    $0x10,%esp
c0104edc:	83 ec 08             	sub    $0x8,%esp
c0104edf:	6a 01                	push   $0x1
c0104ee1:	50                   	push   %eax
c0104ee2:	e8 9a 2c 00 00       	call   c0107b81 <free_pages>
c0104ee7:	83 c4 10             	add    $0x10,%esp
    pgdir[0] = 0;
c0104eea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104eed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0104ef3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104ef6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0104efd:	83 ec 0c             	sub    $0xc,%esp
c0104f00:	ff 75 e8             	pushl  -0x18(%ebp)
c0104f03:	e8 91 f9 ff ff       	call   c0104899 <mm_destroy>
c0104f08:	83 c4 10             	add    $0x10,%esp
    check_mm_struct = NULL;
c0104f0b:	c7 05 58 d0 12 c0 00 	movl   $0x0,0xc012d058
c0104f12:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0104f15:	e8 9c 2c 00 00       	call   c0107bb6 <nr_free_pages>
c0104f1a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104f1d:	74 19                	je     c0104f38 <check_pgfault+0x1f2>
c0104f1f:	68 5c b6 10 c0       	push   $0xc010b65c
c0104f24:	68 1b b4 10 c0       	push   $0xc010b41b
c0104f29:	68 15 01 00 00       	push   $0x115
c0104f2e:	68 30 b4 10 c0       	push   $0xc010b430
c0104f33:	e8 30 c8 ff ff       	call   c0101768 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0104f38:	83 ec 0c             	sub    $0xc,%esp
c0104f3b:	68 83 b6 10 c0       	push   $0xc010b683
c0104f40:	e8 45 b3 ff ff       	call   c010028a <cprintf>
c0104f45:	83 c4 10             	add    $0x10,%esp
}
c0104f48:	90                   	nop
c0104f49:	c9                   	leave  
c0104f4a:	c3                   	ret    

c0104f4b <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0104f4b:	55                   	push   %ebp
c0104f4c:	89 e5                	mov    %esp,%ebp
c0104f4e:	83 ec 28             	sub    $0x28,%esp
    int ret = -E_INVAL;
c0104f51:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0104f58:	ff 75 10             	pushl  0x10(%ebp)
c0104f5b:	ff 75 08             	pushl  0x8(%ebp)
c0104f5e:	e8 e6 f6 ff ff       	call   c0104649 <find_vma>
c0104f63:	83 c4 08             	add    $0x8,%esp
c0104f66:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0104f69:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c0104f6e:	83 c0 01             	add    $0x1,%eax
c0104f71:	a3 64 af 12 c0       	mov    %eax,0xc012af64
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0104f76:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104f7a:	74 0b                	je     c0104f87 <do_pgfault+0x3c>
c0104f7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f7f:	8b 40 04             	mov    0x4(%eax),%eax
c0104f82:	3b 45 10             	cmp    0x10(%ebp),%eax
c0104f85:	76 18                	jbe    c0104f9f <do_pgfault+0x54>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0104f87:	83 ec 08             	sub    $0x8,%esp
c0104f8a:	ff 75 10             	pushl  0x10(%ebp)
c0104f8d:	68 a0 b6 10 c0       	push   $0xc010b6a0
c0104f92:	e8 f3 b2 ff ff       	call   c010028a <cprintf>
c0104f97:	83 c4 10             	add    $0x10,%esp
        goto failed;
c0104f9a:	e9 aa 01 00 00       	jmp    c0105149 <do_pgfault+0x1fe>
    }
    //check the error_code
    switch (error_code & 3) {
c0104f9f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104fa2:	83 e0 03             	and    $0x3,%eax
c0104fa5:	85 c0                	test   %eax,%eax
c0104fa7:	74 3c                	je     c0104fe5 <do_pgfault+0x9a>
c0104fa9:	83 f8 01             	cmp    $0x1,%eax
c0104fac:	74 22                	je     c0104fd0 <do_pgfault+0x85>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0104fae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104fb1:	8b 40 0c             	mov    0xc(%eax),%eax
c0104fb4:	83 e0 02             	and    $0x2,%eax
c0104fb7:	85 c0                	test   %eax,%eax
c0104fb9:	75 4c                	jne    c0105007 <do_pgfault+0xbc>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0104fbb:	83 ec 0c             	sub    $0xc,%esp
c0104fbe:	68 d0 b6 10 c0       	push   $0xc010b6d0
c0104fc3:	e8 c2 b2 ff ff       	call   c010028a <cprintf>
c0104fc8:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0104fcb:	e9 79 01 00 00       	jmp    c0105149 <do_pgfault+0x1fe>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0104fd0:	83 ec 0c             	sub    $0xc,%esp
c0104fd3:	68 30 b7 10 c0       	push   $0xc010b730
c0104fd8:	e8 ad b2 ff ff       	call   c010028a <cprintf>
c0104fdd:	83 c4 10             	add    $0x10,%esp
        goto failed;
c0104fe0:	e9 64 01 00 00       	jmp    c0105149 <do_pgfault+0x1fe>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0104fe5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104fe8:	8b 40 0c             	mov    0xc(%eax),%eax
c0104feb:	83 e0 05             	and    $0x5,%eax
c0104fee:	85 c0                	test   %eax,%eax
c0104ff0:	75 16                	jne    c0105008 <do_pgfault+0xbd>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0104ff2:	83 ec 0c             	sub    $0xc,%esp
c0104ff5:	68 68 b7 10 c0       	push   $0xc010b768
c0104ffa:	e8 8b b2 ff ff       	call   c010028a <cprintf>
c0104fff:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0105002:	e9 42 01 00 00       	jmp    c0105149 <do_pgfault+0x1fe>
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
            goto failed;
        }
        break;
c0105007:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0105008:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c010500f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105012:	8b 40 0c             	mov    0xc(%eax),%eax
c0105015:	83 e0 02             	and    $0x2,%eax
c0105018:	85 c0                	test   %eax,%eax
c010501a:	74 04                	je     c0105020 <do_pgfault+0xd5>
        perm |= PTE_W;
c010501c:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0105020:	8b 45 10             	mov    0x10(%ebp),%eax
c0105023:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105026:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105029:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010502e:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0105031:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0105038:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        }
   }
#endif
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c010503f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105042:	8b 40 0c             	mov    0xc(%eax),%eax
c0105045:	83 ec 04             	sub    $0x4,%esp
c0105048:	6a 01                	push   $0x1
c010504a:	ff 75 10             	pushl  0x10(%ebp)
c010504d:	50                   	push   %eax
c010504e:	e8 3e 31 00 00       	call   c0108191 <get_pte>
c0105053:	83 c4 10             	add    $0x10,%esp
c0105056:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105059:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010505d:	75 15                	jne    c0105074 <do_pgfault+0x129>
        cprintf("get_pte in do_pgfault failed\n");
c010505f:	83 ec 0c             	sub    $0xc,%esp
c0105062:	68 cb b7 10 c0       	push   $0xc010b7cb
c0105067:	e8 1e b2 ff ff       	call   c010028a <cprintf>
c010506c:	83 c4 10             	add    $0x10,%esp
        goto failed;
c010506f:	e9 d5 00 00 00       	jmp    c0105149 <do_pgfault+0x1fe>
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
c0105074:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105077:	8b 00                	mov    (%eax),%eax
c0105079:	85 c0                	test   %eax,%eax
c010507b:	75 35                	jne    c01050b2 <do_pgfault+0x167>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c010507d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105080:	8b 40 0c             	mov    0xc(%eax),%eax
c0105083:	83 ec 04             	sub    $0x4,%esp
c0105086:	ff 75 f0             	pushl  -0x10(%ebp)
c0105089:	ff 75 10             	pushl  0x10(%ebp)
c010508c:	50                   	push   %eax
c010508d:	e8 19 34 00 00       	call   c01084ab <pgdir_alloc_page>
c0105092:	83 c4 10             	add    $0x10,%esp
c0105095:	85 c0                	test   %eax,%eax
c0105097:	0f 85 a5 00 00 00    	jne    c0105142 <do_pgfault+0x1f7>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c010509d:	83 ec 0c             	sub    $0xc,%esp
c01050a0:	68 ec b7 10 c0       	push   $0xc010b7ec
c01050a5:	e8 e0 b1 ff ff       	call   c010028a <cprintf>
c01050aa:	83 c4 10             	add    $0x10,%esp
            goto failed;
c01050ad:	e9 97 00 00 00       	jmp    c0105149 <do_pgfault+0x1fe>
        }
    }
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        if(swap_init_ok) {
c01050b2:	a1 68 af 12 c0       	mov    0xc012af68,%eax
c01050b7:	85 c0                	test   %eax,%eax
c01050b9:	74 6f                	je     c010512a <do_pgfault+0x1df>
            struct Page *page=NULL;
c01050bb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c01050c2:	83 ec 04             	sub    $0x4,%esp
c01050c5:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01050c8:	50                   	push   %eax
c01050c9:	ff 75 10             	pushl  0x10(%ebp)
c01050cc:	ff 75 08             	pushl  0x8(%ebp)
c01050cf:	e8 44 03 00 00       	call   c0105418 <swap_in>
c01050d4:	83 c4 10             	add    $0x10,%esp
c01050d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01050da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01050de:	74 12                	je     c01050f2 <do_pgfault+0x1a7>
                cprintf("swap_in in do_pgfault failed\n");
c01050e0:	83 ec 0c             	sub    $0xc,%esp
c01050e3:	68 13 b8 10 c0       	push   $0xc010b813
c01050e8:	e8 9d b1 ff ff       	call   c010028a <cprintf>
c01050ed:	83 c4 10             	add    $0x10,%esp
c01050f0:	eb 57                	jmp    c0105149 <do_pgfault+0x1fe>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
c01050f2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01050f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01050f8:	8b 40 0c             	mov    0xc(%eax),%eax
c01050fb:	ff 75 f0             	pushl  -0x10(%ebp)
c01050fe:	ff 75 10             	pushl  0x10(%ebp)
c0105101:	52                   	push   %edx
c0105102:	50                   	push   %eax
c0105103:	e8 9a 32 00 00       	call   c01083a2 <page_insert>
c0105108:	83 c4 10             	add    $0x10,%esp
            swap_map_swappable(mm, addr, page, 1);
c010510b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010510e:	6a 01                	push   $0x1
c0105110:	50                   	push   %eax
c0105111:	ff 75 10             	pushl  0x10(%ebp)
c0105114:	ff 75 08             	pushl  0x8(%ebp)
c0105117:	e8 6c 01 00 00       	call   c0105288 <swap_map_swappable>
c010511c:	83 c4 10             	add    $0x10,%esp
            page->pra_vaddr = addr;
c010511f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105122:	8b 55 10             	mov    0x10(%ebp),%edx
c0105125:	89 50 20             	mov    %edx,0x20(%eax)
c0105128:	eb 18                	jmp    c0105142 <do_pgfault+0x1f7>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c010512a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010512d:	8b 00                	mov    (%eax),%eax
c010512f:	83 ec 08             	sub    $0x8,%esp
c0105132:	50                   	push   %eax
c0105133:	68 34 b8 10 c0       	push   $0xc010b834
c0105138:	e8 4d b1 ff ff       	call   c010028a <cprintf>
c010513d:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0105140:	eb 07                	jmp    c0105149 <do_pgfault+0x1fe>
        }
   }
   ret = 0;
c0105142:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0105149:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010514c:	c9                   	leave  
c010514d:	c3                   	ret    

c010514e <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c010514e:	55                   	push   %ebp
c010514f:	89 e5                	mov    %esp,%ebp
c0105151:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0105154:	8b 45 08             	mov    0x8(%ebp),%eax
c0105157:	c1 e8 0c             	shr    $0xc,%eax
c010515a:	89 c2                	mov    %eax,%edx
c010515c:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c0105161:	39 c2                	cmp    %eax,%edx
c0105163:	72 14                	jb     c0105179 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0105165:	83 ec 04             	sub    $0x4,%esp
c0105168:	68 5c b8 10 c0       	push   $0xc010b85c
c010516d:	6a 5f                	push   $0x5f
c010516f:	68 7b b8 10 c0       	push   $0xc010b87b
c0105174:	e8 ef c5 ff ff       	call   c0101768 <__panic>
    }
    return &pages[PPN(pa)];
c0105179:	8b 0d 40 d1 12 c0    	mov    0xc012d140,%ecx
c010517f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105182:	c1 e8 0c             	shr    $0xc,%eax
c0105185:	89 c2                	mov    %eax,%edx
c0105187:	89 d0                	mov    %edx,%eax
c0105189:	c1 e0 03             	shl    $0x3,%eax
c010518c:	01 d0                	add    %edx,%eax
c010518e:	c1 e0 02             	shl    $0x2,%eax
c0105191:	01 c8                	add    %ecx,%eax
}
c0105193:	c9                   	leave  
c0105194:	c3                   	ret    

c0105195 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0105195:	55                   	push   %ebp
c0105196:	89 e5                	mov    %esp,%ebp
c0105198:	83 ec 08             	sub    $0x8,%esp
    if (!(pte & PTE_P)) {
c010519b:	8b 45 08             	mov    0x8(%ebp),%eax
c010519e:	83 e0 01             	and    $0x1,%eax
c01051a1:	85 c0                	test   %eax,%eax
c01051a3:	75 14                	jne    c01051b9 <pte2page+0x24>
        panic("pte2page called with invalid pte");
c01051a5:	83 ec 04             	sub    $0x4,%esp
c01051a8:	68 8c b8 10 c0       	push   $0xc010b88c
c01051ad:	6a 71                	push   $0x71
c01051af:	68 7b b8 10 c0       	push   $0xc010b87b
c01051b4:	e8 af c5 ff ff       	call   c0101768 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c01051b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01051bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01051c1:	83 ec 0c             	sub    $0xc,%esp
c01051c4:	50                   	push   %eax
c01051c5:	e8 84 ff ff ff       	call   c010514e <pa2page>
c01051ca:	83 c4 10             	add    $0x10,%esp
}
c01051cd:	c9                   	leave  
c01051ce:	c3                   	ret    

c01051cf <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c01051cf:	55                   	push   %ebp
c01051d0:	89 e5                	mov    %esp,%ebp
c01051d2:	83 ec 18             	sub    $0x18,%esp
     swapfs_init();
c01051d5:	e8 c2 3e 00 00       	call   c010909c <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c01051da:	a1 fc d0 12 c0       	mov    0xc012d0fc,%eax
c01051df:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c01051e4:	76 0c                	jbe    c01051f2 <swap_init+0x23>
c01051e6:	a1 fc d0 12 c0       	mov    0xc012d0fc,%eax
c01051eb:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c01051f0:	76 17                	jbe    c0105209 <swap_init+0x3a>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c01051f2:	a1 fc d0 12 c0       	mov    0xc012d0fc,%eax
c01051f7:	50                   	push   %eax
c01051f8:	68 ad b8 10 c0       	push   $0xc010b8ad
c01051fd:	6a 25                	push   $0x25
c01051ff:	68 c8 b8 10 c0       	push   $0xc010b8c8
c0105204:	e8 5f c5 ff ff       	call   c0101768 <__panic>
     }
     

     sm = &swap_manager_fifo;
c0105209:	c7 05 70 af 12 c0 00 	movl   $0xc0127a00,0xc012af70
c0105210:	7a 12 c0 
     int r = sm->init();
c0105213:	a1 70 af 12 c0       	mov    0xc012af70,%eax
c0105218:	8b 40 04             	mov    0x4(%eax),%eax
c010521b:	ff d0                	call   *%eax
c010521d:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0105220:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105224:	75 27                	jne    c010524d <swap_init+0x7e>
     {
          swap_init_ok = 1;
c0105226:	c7 05 68 af 12 c0 01 	movl   $0x1,0xc012af68
c010522d:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0105230:	a1 70 af 12 c0       	mov    0xc012af70,%eax
c0105235:	8b 00                	mov    (%eax),%eax
c0105237:	83 ec 08             	sub    $0x8,%esp
c010523a:	50                   	push   %eax
c010523b:	68 d7 b8 10 c0       	push   $0xc010b8d7
c0105240:	e8 45 b0 ff ff       	call   c010028a <cprintf>
c0105245:	83 c4 10             	add    $0x10,%esp
          check_swap();
c0105248:	e8 f7 03 00 00       	call   c0105644 <check_swap>
     }

     return r;
c010524d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105250:	c9                   	leave  
c0105251:	c3                   	ret    

c0105252 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0105252:	55                   	push   %ebp
c0105253:	89 e5                	mov    %esp,%ebp
c0105255:	83 ec 08             	sub    $0x8,%esp
     return sm->init_mm(mm);
c0105258:	a1 70 af 12 c0       	mov    0xc012af70,%eax
c010525d:	8b 40 08             	mov    0x8(%eax),%eax
c0105260:	83 ec 0c             	sub    $0xc,%esp
c0105263:	ff 75 08             	pushl  0x8(%ebp)
c0105266:	ff d0                	call   *%eax
c0105268:	83 c4 10             	add    $0x10,%esp
}
c010526b:	c9                   	leave  
c010526c:	c3                   	ret    

c010526d <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c010526d:	55                   	push   %ebp
c010526e:	89 e5                	mov    %esp,%ebp
c0105270:	83 ec 08             	sub    $0x8,%esp
     return sm->tick_event(mm);
c0105273:	a1 70 af 12 c0       	mov    0xc012af70,%eax
c0105278:	8b 40 0c             	mov    0xc(%eax),%eax
c010527b:	83 ec 0c             	sub    $0xc,%esp
c010527e:	ff 75 08             	pushl  0x8(%ebp)
c0105281:	ff d0                	call   *%eax
c0105283:	83 c4 10             	add    $0x10,%esp
}
c0105286:	c9                   	leave  
c0105287:	c3                   	ret    

c0105288 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0105288:	55                   	push   %ebp
c0105289:	89 e5                	mov    %esp,%ebp
c010528b:	83 ec 08             	sub    $0x8,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c010528e:	a1 70 af 12 c0       	mov    0xc012af70,%eax
c0105293:	8b 40 10             	mov    0x10(%eax),%eax
c0105296:	ff 75 14             	pushl  0x14(%ebp)
c0105299:	ff 75 10             	pushl  0x10(%ebp)
c010529c:	ff 75 0c             	pushl  0xc(%ebp)
c010529f:	ff 75 08             	pushl  0x8(%ebp)
c01052a2:	ff d0                	call   *%eax
c01052a4:	83 c4 10             	add    $0x10,%esp
}
c01052a7:	c9                   	leave  
c01052a8:	c3                   	ret    

c01052a9 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01052a9:	55                   	push   %ebp
c01052aa:	89 e5                	mov    %esp,%ebp
c01052ac:	83 ec 08             	sub    $0x8,%esp
     return sm->set_unswappable(mm, addr);
c01052af:	a1 70 af 12 c0       	mov    0xc012af70,%eax
c01052b4:	8b 40 14             	mov    0x14(%eax),%eax
c01052b7:	83 ec 08             	sub    $0x8,%esp
c01052ba:	ff 75 0c             	pushl  0xc(%ebp)
c01052bd:	ff 75 08             	pushl  0x8(%ebp)
c01052c0:	ff d0                	call   *%eax
c01052c2:	83 c4 10             	add    $0x10,%esp
}
c01052c5:	c9                   	leave  
c01052c6:	c3                   	ret    

c01052c7 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c01052c7:	55                   	push   %ebp
c01052c8:	89 e5                	mov    %esp,%ebp
c01052ca:	83 ec 28             	sub    $0x28,%esp
     int i;
     for (i = 0; i != n; ++ i)
c01052cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01052d4:	e9 2e 01 00 00       	jmp    c0105407 <swap_out+0x140>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c01052d9:	a1 70 af 12 c0       	mov    0xc012af70,%eax
c01052de:	8b 40 18             	mov    0x18(%eax),%eax
c01052e1:	83 ec 04             	sub    $0x4,%esp
c01052e4:	ff 75 10             	pushl  0x10(%ebp)
c01052e7:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c01052ea:	52                   	push   %edx
c01052eb:	ff 75 08             	pushl  0x8(%ebp)
c01052ee:	ff d0                	call   *%eax
c01052f0:	83 c4 10             	add    $0x10,%esp
c01052f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c01052f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01052fa:	74 18                	je     c0105314 <swap_out+0x4d>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c01052fc:	83 ec 08             	sub    $0x8,%esp
c01052ff:	ff 75 f4             	pushl  -0xc(%ebp)
c0105302:	68 ec b8 10 c0       	push   $0xc010b8ec
c0105307:	e8 7e af ff ff       	call   c010028a <cprintf>
c010530c:	83 c4 10             	add    $0x10,%esp
c010530f:	e9 ff 00 00 00       	jmp    c0105413 <swap_out+0x14c>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0105314:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105317:	8b 40 20             	mov    0x20(%eax),%eax
c010531a:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c010531d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105320:	8b 40 0c             	mov    0xc(%eax),%eax
c0105323:	83 ec 04             	sub    $0x4,%esp
c0105326:	6a 00                	push   $0x0
c0105328:	ff 75 ec             	pushl  -0x14(%ebp)
c010532b:	50                   	push   %eax
c010532c:	e8 60 2e 00 00       	call   c0108191 <get_pte>
c0105331:	83 c4 10             	add    $0x10,%esp
c0105334:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0105337:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010533a:	8b 00                	mov    (%eax),%eax
c010533c:	83 e0 01             	and    $0x1,%eax
c010533f:	85 c0                	test   %eax,%eax
c0105341:	75 16                	jne    c0105359 <swap_out+0x92>
c0105343:	68 19 b9 10 c0       	push   $0xc010b919
c0105348:	68 2e b9 10 c0       	push   $0xc010b92e
c010534d:	6a 65                	push   $0x65
c010534f:	68 c8 b8 10 c0       	push   $0xc010b8c8
c0105354:	e8 0f c4 ff ff       	call   c0101768 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0105359:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010535c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010535f:	8b 52 20             	mov    0x20(%edx),%edx
c0105362:	c1 ea 0c             	shr    $0xc,%edx
c0105365:	83 c2 01             	add    $0x1,%edx
c0105368:	c1 e2 08             	shl    $0x8,%edx
c010536b:	83 ec 08             	sub    $0x8,%esp
c010536e:	50                   	push   %eax
c010536f:	52                   	push   %edx
c0105370:	e8 c3 3d 00 00       	call   c0109138 <swapfs_write>
c0105375:	83 c4 10             	add    $0x10,%esp
c0105378:	85 c0                	test   %eax,%eax
c010537a:	74 2b                	je     c01053a7 <swap_out+0xe0>
                    cprintf("SWAP: failed to save\n");
c010537c:	83 ec 0c             	sub    $0xc,%esp
c010537f:	68 43 b9 10 c0       	push   $0xc010b943
c0105384:	e8 01 af ff ff       	call   c010028a <cprintf>
c0105389:	83 c4 10             	add    $0x10,%esp
                    sm->map_swappable(mm, v, page, 0);
c010538c:	a1 70 af 12 c0       	mov    0xc012af70,%eax
c0105391:	8b 40 10             	mov    0x10(%eax),%eax
c0105394:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105397:	6a 00                	push   $0x0
c0105399:	52                   	push   %edx
c010539a:	ff 75 ec             	pushl  -0x14(%ebp)
c010539d:	ff 75 08             	pushl  0x8(%ebp)
c01053a0:	ff d0                	call   *%eax
c01053a2:	83 c4 10             	add    $0x10,%esp
c01053a5:	eb 5c                	jmp    c0105403 <swap_out+0x13c>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c01053a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01053aa:	8b 40 20             	mov    0x20(%eax),%eax
c01053ad:	c1 e8 0c             	shr    $0xc,%eax
c01053b0:	83 c0 01             	add    $0x1,%eax
c01053b3:	50                   	push   %eax
c01053b4:	ff 75 ec             	pushl  -0x14(%ebp)
c01053b7:	ff 75 f4             	pushl  -0xc(%ebp)
c01053ba:	68 5c b9 10 c0       	push   $0xc010b95c
c01053bf:	e8 c6 ae ff ff       	call   c010028a <cprintf>
c01053c4:	83 c4 10             	add    $0x10,%esp
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c01053c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01053ca:	8b 40 20             	mov    0x20(%eax),%eax
c01053cd:	c1 e8 0c             	shr    $0xc,%eax
c01053d0:	83 c0 01             	add    $0x1,%eax
c01053d3:	c1 e0 08             	shl    $0x8,%eax
c01053d6:	89 c2                	mov    %eax,%edx
c01053d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01053db:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c01053dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01053e0:	83 ec 08             	sub    $0x8,%esp
c01053e3:	6a 01                	push   $0x1
c01053e5:	50                   	push   %eax
c01053e6:	e8 96 27 00 00       	call   c0107b81 <free_pages>
c01053eb:	83 c4 10             	add    $0x10,%esp
          }
          
          tlb_invalidate(mm->pgdir, v);
c01053ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01053f1:	8b 40 0c             	mov    0xc(%eax),%eax
c01053f4:	83 ec 08             	sub    $0x8,%esp
c01053f7:	ff 75 ec             	pushl  -0x14(%ebp)
c01053fa:	50                   	push   %eax
c01053fb:	e8 5b 30 00 00       	call   c010845b <tlb_invalidate>
c0105400:	83 c4 10             	add    $0x10,%esp

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c0105403:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0105407:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010540a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010540d:	0f 85 c6 fe ff ff    	jne    c01052d9 <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c0105413:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105416:	c9                   	leave  
c0105417:	c3                   	ret    

c0105418 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0105418:	55                   	push   %ebp
c0105419:	89 e5                	mov    %esp,%ebp
c010541b:	83 ec 18             	sub    $0x18,%esp
     struct Page *result = alloc_page();
c010541e:	83 ec 0c             	sub    $0xc,%esp
c0105421:	6a 01                	push   $0x1
c0105423:	e8 ed 26 00 00       	call   c0107b15 <alloc_pages>
c0105428:	83 c4 10             	add    $0x10,%esp
c010542b:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c010542e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105432:	75 16                	jne    c010544a <swap_in+0x32>
c0105434:	68 9c b9 10 c0       	push   $0xc010b99c
c0105439:	68 2e b9 10 c0       	push   $0xc010b92e
c010543e:	6a 7b                	push   $0x7b
c0105440:	68 c8 b8 10 c0       	push   $0xc010b8c8
c0105445:	e8 1e c3 ff ff       	call   c0101768 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c010544a:	8b 45 08             	mov    0x8(%ebp),%eax
c010544d:	8b 40 0c             	mov    0xc(%eax),%eax
c0105450:	83 ec 04             	sub    $0x4,%esp
c0105453:	6a 00                	push   $0x0
c0105455:	ff 75 0c             	pushl  0xc(%ebp)
c0105458:	50                   	push   %eax
c0105459:	e8 33 2d 00 00       	call   c0108191 <get_pte>
c010545e:	83 c4 10             	add    $0x10,%esp
c0105461:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0105464:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105467:	8b 00                	mov    (%eax),%eax
c0105469:	83 ec 08             	sub    $0x8,%esp
c010546c:	ff 75 f4             	pushl  -0xc(%ebp)
c010546f:	50                   	push   %eax
c0105470:	e8 6a 3c 00 00       	call   c01090df <swapfs_read>
c0105475:	83 c4 10             	add    $0x10,%esp
c0105478:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010547b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010547f:	74 1f                	je     c01054a0 <swap_in+0x88>
     {
        assert(r!=0);
c0105481:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105485:	75 19                	jne    c01054a0 <swap_in+0x88>
c0105487:	68 a9 b9 10 c0       	push   $0xc010b9a9
c010548c:	68 2e b9 10 c0       	push   $0xc010b92e
c0105491:	68 83 00 00 00       	push   $0x83
c0105496:	68 c8 b8 10 c0       	push   $0xc010b8c8
c010549b:	e8 c8 c2 ff ff       	call   c0101768 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c01054a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01054a3:	8b 00                	mov    (%eax),%eax
c01054a5:	c1 e8 08             	shr    $0x8,%eax
c01054a8:	83 ec 04             	sub    $0x4,%esp
c01054ab:	ff 75 0c             	pushl  0xc(%ebp)
c01054ae:	50                   	push   %eax
c01054af:	68 b0 b9 10 c0       	push   $0xc010b9b0
c01054b4:	e8 d1 ad ff ff       	call   c010028a <cprintf>
c01054b9:	83 c4 10             	add    $0x10,%esp
     *ptr_result=result;
c01054bc:	8b 45 10             	mov    0x10(%ebp),%eax
c01054bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01054c2:	89 10                	mov    %edx,(%eax)
     return 0;
c01054c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01054c9:	c9                   	leave  
c01054ca:	c3                   	ret    

c01054cb <check_content_set>:



static inline void
check_content_set(void)
{
c01054cb:	55                   	push   %ebp
c01054cc:	89 e5                	mov    %esp,%ebp
c01054ce:	83 ec 08             	sub    $0x8,%esp
     *(unsigned char *)0x1000 = 0x0a;
c01054d1:	b8 00 10 00 00       	mov    $0x1000,%eax
c01054d6:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01054d9:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c01054de:	83 f8 01             	cmp    $0x1,%eax
c01054e1:	74 19                	je     c01054fc <check_content_set+0x31>
c01054e3:	68 ee b9 10 c0       	push   $0xc010b9ee
c01054e8:	68 2e b9 10 c0       	push   $0xc010b92e
c01054ed:	68 90 00 00 00       	push   $0x90
c01054f2:	68 c8 b8 10 c0       	push   $0xc010b8c8
c01054f7:	e8 6c c2 ff ff       	call   c0101768 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c01054fc:	b8 10 10 00 00       	mov    $0x1010,%eax
c0105501:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0105504:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c0105509:	83 f8 01             	cmp    $0x1,%eax
c010550c:	74 19                	je     c0105527 <check_content_set+0x5c>
c010550e:	68 ee b9 10 c0       	push   $0xc010b9ee
c0105513:	68 2e b9 10 c0       	push   $0xc010b92e
c0105518:	68 92 00 00 00       	push   $0x92
c010551d:	68 c8 b8 10 c0       	push   $0xc010b8c8
c0105522:	e8 41 c2 ff ff       	call   c0101768 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0105527:	b8 00 20 00 00       	mov    $0x2000,%eax
c010552c:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c010552f:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c0105534:	83 f8 02             	cmp    $0x2,%eax
c0105537:	74 19                	je     c0105552 <check_content_set+0x87>
c0105539:	68 fd b9 10 c0       	push   $0xc010b9fd
c010553e:	68 2e b9 10 c0       	push   $0xc010b92e
c0105543:	68 94 00 00 00       	push   $0x94
c0105548:	68 c8 b8 10 c0       	push   $0xc010b8c8
c010554d:	e8 16 c2 ff ff       	call   c0101768 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0105552:	b8 10 20 00 00       	mov    $0x2010,%eax
c0105557:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c010555a:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c010555f:	83 f8 02             	cmp    $0x2,%eax
c0105562:	74 19                	je     c010557d <check_content_set+0xb2>
c0105564:	68 fd b9 10 c0       	push   $0xc010b9fd
c0105569:	68 2e b9 10 c0       	push   $0xc010b92e
c010556e:	68 96 00 00 00       	push   $0x96
c0105573:	68 c8 b8 10 c0       	push   $0xc010b8c8
c0105578:	e8 eb c1 ff ff       	call   c0101768 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c010557d:	b8 00 30 00 00       	mov    $0x3000,%eax
c0105582:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0105585:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c010558a:	83 f8 03             	cmp    $0x3,%eax
c010558d:	74 19                	je     c01055a8 <check_content_set+0xdd>
c010558f:	68 0c ba 10 c0       	push   $0xc010ba0c
c0105594:	68 2e b9 10 c0       	push   $0xc010b92e
c0105599:	68 98 00 00 00       	push   $0x98
c010559e:	68 c8 b8 10 c0       	push   $0xc010b8c8
c01055a3:	e8 c0 c1 ff ff       	call   c0101768 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c01055a8:	b8 10 30 00 00       	mov    $0x3010,%eax
c01055ad:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c01055b0:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c01055b5:	83 f8 03             	cmp    $0x3,%eax
c01055b8:	74 19                	je     c01055d3 <check_content_set+0x108>
c01055ba:	68 0c ba 10 c0       	push   $0xc010ba0c
c01055bf:	68 2e b9 10 c0       	push   $0xc010b92e
c01055c4:	68 9a 00 00 00       	push   $0x9a
c01055c9:	68 c8 b8 10 c0       	push   $0xc010b8c8
c01055ce:	e8 95 c1 ff ff       	call   c0101768 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c01055d3:	b8 00 40 00 00       	mov    $0x4000,%eax
c01055d8:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01055db:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c01055e0:	83 f8 04             	cmp    $0x4,%eax
c01055e3:	74 19                	je     c01055fe <check_content_set+0x133>
c01055e5:	68 1b ba 10 c0       	push   $0xc010ba1b
c01055ea:	68 2e b9 10 c0       	push   $0xc010b92e
c01055ef:	68 9c 00 00 00       	push   $0x9c
c01055f4:	68 c8 b8 10 c0       	push   $0xc010b8c8
c01055f9:	e8 6a c1 ff ff       	call   c0101768 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c01055fe:	b8 10 40 00 00       	mov    $0x4010,%eax
c0105603:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0105606:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c010560b:	83 f8 04             	cmp    $0x4,%eax
c010560e:	74 19                	je     c0105629 <check_content_set+0x15e>
c0105610:	68 1b ba 10 c0       	push   $0xc010ba1b
c0105615:	68 2e b9 10 c0       	push   $0xc010b92e
c010561a:	68 9e 00 00 00       	push   $0x9e
c010561f:	68 c8 b8 10 c0       	push   $0xc010b8c8
c0105624:	e8 3f c1 ff ff       	call   c0101768 <__panic>
}
c0105629:	90                   	nop
c010562a:	c9                   	leave  
c010562b:	c3                   	ret    

c010562c <check_content_access>:

static inline int
check_content_access(void)
{
c010562c:	55                   	push   %ebp
c010562d:	89 e5                	mov    %esp,%ebp
c010562f:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0105632:	a1 70 af 12 c0       	mov    0xc012af70,%eax
c0105637:	8b 40 1c             	mov    0x1c(%eax),%eax
c010563a:	ff d0                	call   *%eax
c010563c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c010563f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105642:	c9                   	leave  
c0105643:	c3                   	ret    

c0105644 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0105644:	55                   	push   %ebp
c0105645:	89 e5                	mov    %esp,%ebp
c0105647:	83 ec 68             	sub    $0x68,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c010564a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105651:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0105658:	c7 45 e8 2c d1 12 c0 	movl   $0xc012d12c,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c010565f:	eb 60                	jmp    c01056c1 <check_swap+0x7d>
        struct Page *p = le2page(le, page_link);
c0105661:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105664:	83 e8 10             	sub    $0x10,%eax
c0105667:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(PageProperty(p));
c010566a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010566d:	83 c0 04             	add    $0x4,%eax
c0105670:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0105677:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010567a:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010567d:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0105680:	0f a3 10             	bt     %edx,(%eax)
c0105683:	19 c0                	sbb    %eax,%eax
c0105685:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c0105688:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c010568c:	0f 95 c0             	setne  %al
c010568f:	0f b6 c0             	movzbl %al,%eax
c0105692:	85 c0                	test   %eax,%eax
c0105694:	75 19                	jne    c01056af <check_swap+0x6b>
c0105696:	68 2a ba 10 c0       	push   $0xc010ba2a
c010569b:	68 2e b9 10 c0       	push   $0xc010b92e
c01056a0:	68 b9 00 00 00       	push   $0xb9
c01056a5:	68 c8 b8 10 c0       	push   $0xc010b8c8
c01056aa:	e8 b9 c0 ff ff       	call   c0101768 <__panic>
        count ++, total += p->property;
c01056af:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01056b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01056b6:	8b 50 08             	mov    0x8(%eax),%edx
c01056b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056bc:	01 d0                	add    %edx,%eax
c01056be:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01056c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01056c4:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01056c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01056ca:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c01056cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01056d0:	81 7d e8 2c d1 12 c0 	cmpl   $0xc012d12c,-0x18(%ebp)
c01056d7:	75 88                	jne    c0105661 <check_swap+0x1d>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c01056d9:	e8 d8 24 00 00       	call   c0107bb6 <nr_free_pages>
c01056de:	89 c2                	mov    %eax,%edx
c01056e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056e3:	39 c2                	cmp    %eax,%edx
c01056e5:	74 19                	je     c0105700 <check_swap+0xbc>
c01056e7:	68 3a ba 10 c0       	push   $0xc010ba3a
c01056ec:	68 2e b9 10 c0       	push   $0xc010b92e
c01056f1:	68 bc 00 00 00       	push   $0xbc
c01056f6:	68 c8 b8 10 c0       	push   $0xc010b8c8
c01056fb:	e8 68 c0 ff ff       	call   c0101768 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0105700:	83 ec 04             	sub    $0x4,%esp
c0105703:	ff 75 f0             	pushl  -0x10(%ebp)
c0105706:	ff 75 f4             	pushl  -0xc(%ebp)
c0105709:	68 54 ba 10 c0       	push   $0xc010ba54
c010570e:	e8 77 ab ff ff       	call   c010028a <cprintf>
c0105713:	83 c4 10             	add    $0x10,%esp
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0105716:	e8 76 ee ff ff       	call   c0104591 <mm_create>
c010571b:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(mm != NULL);
c010571e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0105722:	75 19                	jne    c010573d <check_swap+0xf9>
c0105724:	68 7a ba 10 c0       	push   $0xc010ba7a
c0105729:	68 2e b9 10 c0       	push   $0xc010b92e
c010572e:	68 c1 00 00 00       	push   $0xc1
c0105733:	68 c8 b8 10 c0       	push   $0xc010b8c8
c0105738:	e8 2b c0 ff ff       	call   c0101768 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c010573d:	a1 58 d0 12 c0       	mov    0xc012d058,%eax
c0105742:	85 c0                	test   %eax,%eax
c0105744:	74 19                	je     c010575f <check_swap+0x11b>
c0105746:	68 85 ba 10 c0       	push   $0xc010ba85
c010574b:	68 2e b9 10 c0       	push   $0xc010b92e
c0105750:	68 c4 00 00 00       	push   $0xc4
c0105755:	68 c8 b8 10 c0       	push   $0xc010b8c8
c010575a:	e8 09 c0 ff ff       	call   c0101768 <__panic>

     check_mm_struct = mm;
c010575f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105762:	a3 58 d0 12 c0       	mov    %eax,0xc012d058

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0105767:	8b 15 20 7a 12 c0    	mov    0xc0127a20,%edx
c010576d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105770:	89 50 0c             	mov    %edx,0xc(%eax)
c0105773:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105776:	8b 40 0c             	mov    0xc(%eax),%eax
c0105779:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(pgdir[0] == 0);
c010577c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010577f:	8b 00                	mov    (%eax),%eax
c0105781:	85 c0                	test   %eax,%eax
c0105783:	74 19                	je     c010579e <check_swap+0x15a>
c0105785:	68 9d ba 10 c0       	push   $0xc010ba9d
c010578a:	68 2e b9 10 c0       	push   $0xc010b92e
c010578f:	68 c9 00 00 00       	push   $0xc9
c0105794:	68 c8 b8 10 c0       	push   $0xc010b8c8
c0105799:	e8 ca bf ff ff       	call   c0101768 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c010579e:	83 ec 04             	sub    $0x4,%esp
c01057a1:	6a 03                	push   $0x3
c01057a3:	68 00 60 00 00       	push   $0x6000
c01057a8:	68 00 10 00 00       	push   $0x1000
c01057ad:	e8 5b ee ff ff       	call   c010460d <vma_create>
c01057b2:	83 c4 10             	add    $0x10,%esp
c01057b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(vma != NULL);
c01057b8:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c01057bc:	75 19                	jne    c01057d7 <check_swap+0x193>
c01057be:	68 ab ba 10 c0       	push   $0xc010baab
c01057c3:	68 2e b9 10 c0       	push   $0xc010b92e
c01057c8:	68 cc 00 00 00       	push   $0xcc
c01057cd:	68 c8 b8 10 c0       	push   $0xc010b8c8
c01057d2:	e8 91 bf ff ff       	call   c0101768 <__panic>

     insert_vma_struct(mm, vma);
c01057d7:	83 ec 08             	sub    $0x8,%esp
c01057da:	ff 75 d0             	pushl  -0x30(%ebp)
c01057dd:	ff 75 d8             	pushl  -0x28(%ebp)
c01057e0:	e8 90 ef ff ff       	call   c0104775 <insert_vma_struct>
c01057e5:	83 c4 10             	add    $0x10,%esp

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c01057e8:	83 ec 0c             	sub    $0xc,%esp
c01057eb:	68 b8 ba 10 c0       	push   $0xc010bab8
c01057f0:	e8 95 aa ff ff       	call   c010028a <cprintf>
c01057f5:	83 c4 10             	add    $0x10,%esp
     pte_t *temp_ptep=NULL;
c01057f8:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c01057ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105802:	8b 40 0c             	mov    0xc(%eax),%eax
c0105805:	83 ec 04             	sub    $0x4,%esp
c0105808:	6a 01                	push   $0x1
c010580a:	68 00 10 00 00       	push   $0x1000
c010580f:	50                   	push   %eax
c0105810:	e8 7c 29 00 00       	call   c0108191 <get_pte>
c0105815:	83 c4 10             	add    $0x10,%esp
c0105818:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(temp_ptep!= NULL);
c010581b:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010581f:	75 19                	jne    c010583a <check_swap+0x1f6>
c0105821:	68 ec ba 10 c0       	push   $0xc010baec
c0105826:	68 2e b9 10 c0       	push   $0xc010b92e
c010582b:	68 d4 00 00 00       	push   $0xd4
c0105830:	68 c8 b8 10 c0       	push   $0xc010b8c8
c0105835:	e8 2e bf ff ff       	call   c0101768 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c010583a:	83 ec 0c             	sub    $0xc,%esp
c010583d:	68 00 bb 10 c0       	push   $0xc010bb00
c0105842:	e8 43 aa ff ff       	call   c010028a <cprintf>
c0105847:	83 c4 10             	add    $0x10,%esp
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010584a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105851:	e9 90 00 00 00       	jmp    c01058e6 <check_swap+0x2a2>
          check_rp[i] = alloc_page();
c0105856:	83 ec 0c             	sub    $0xc,%esp
c0105859:	6a 01                	push   $0x1
c010585b:	e8 b5 22 00 00       	call   c0107b15 <alloc_pages>
c0105860:	83 c4 10             	add    $0x10,%esp
c0105863:	89 c2                	mov    %eax,%edx
c0105865:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105868:	89 14 85 60 d0 12 c0 	mov    %edx,-0x3fed2fa0(,%eax,4)
          assert(check_rp[i] != NULL );
c010586f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105872:	8b 04 85 60 d0 12 c0 	mov    -0x3fed2fa0(,%eax,4),%eax
c0105879:	85 c0                	test   %eax,%eax
c010587b:	75 19                	jne    c0105896 <check_swap+0x252>
c010587d:	68 24 bb 10 c0       	push   $0xc010bb24
c0105882:	68 2e b9 10 c0       	push   $0xc010b92e
c0105887:	68 d9 00 00 00       	push   $0xd9
c010588c:	68 c8 b8 10 c0       	push   $0xc010b8c8
c0105891:	e8 d2 be ff ff       	call   c0101768 <__panic>
          assert(!PageProperty(check_rp[i]));
c0105896:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105899:	8b 04 85 60 d0 12 c0 	mov    -0x3fed2fa0(,%eax,4),%eax
c01058a0:	83 c0 04             	add    $0x4,%eax
c01058a3:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01058aa:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01058ad:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01058b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01058b3:	0f a3 10             	bt     %edx,(%eax)
c01058b6:	19 c0                	sbb    %eax,%eax
c01058b8:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c01058bb:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c01058bf:	0f 95 c0             	setne  %al
c01058c2:	0f b6 c0             	movzbl %al,%eax
c01058c5:	85 c0                	test   %eax,%eax
c01058c7:	74 19                	je     c01058e2 <check_swap+0x29e>
c01058c9:	68 38 bb 10 c0       	push   $0xc010bb38
c01058ce:	68 2e b9 10 c0       	push   $0xc010b92e
c01058d3:	68 da 00 00 00       	push   $0xda
c01058d8:	68 c8 b8 10 c0       	push   $0xc010b8c8
c01058dd:	e8 86 be ff ff       	call   c0101768 <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01058e2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01058e6:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01058ea:	0f 8e 66 ff ff ff    	jle    c0105856 <check_swap+0x212>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c01058f0:	a1 2c d1 12 c0       	mov    0xc012d12c,%eax
c01058f5:	8b 15 30 d1 12 c0    	mov    0xc012d130,%edx
c01058fb:	89 45 98             	mov    %eax,-0x68(%ebp)
c01058fe:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0105901:	c7 45 c0 2c d1 12 c0 	movl   $0xc012d12c,-0x40(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0105908:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010590b:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010590e:	89 50 04             	mov    %edx,0x4(%eax)
c0105911:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105914:	8b 50 04             	mov    0x4(%eax),%edx
c0105917:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010591a:	89 10                	mov    %edx,(%eax)
c010591c:	c7 45 c8 2c d1 12 c0 	movl   $0xc012d12c,-0x38(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0105923:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105926:	8b 40 04             	mov    0x4(%eax),%eax
c0105929:	39 45 c8             	cmp    %eax,-0x38(%ebp)
c010592c:	0f 94 c0             	sete   %al
c010592f:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0105932:	85 c0                	test   %eax,%eax
c0105934:	75 19                	jne    c010594f <check_swap+0x30b>
c0105936:	68 53 bb 10 c0       	push   $0xc010bb53
c010593b:	68 2e b9 10 c0       	push   $0xc010b92e
c0105940:	68 de 00 00 00       	push   $0xde
c0105945:	68 c8 b8 10 c0       	push   $0xc010b8c8
c010594a:	e8 19 be ff ff       	call   c0101768 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c010594f:	a1 34 d1 12 c0       	mov    0xc012d134,%eax
c0105954:	89 45 bc             	mov    %eax,-0x44(%ebp)
     nr_free = 0;
c0105957:	c7 05 34 d1 12 c0 00 	movl   $0x0,0xc012d134
c010595e:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105961:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105968:	eb 1c                	jmp    c0105986 <check_swap+0x342>
        free_pages(check_rp[i],1);
c010596a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010596d:	8b 04 85 60 d0 12 c0 	mov    -0x3fed2fa0(,%eax,4),%eax
c0105974:	83 ec 08             	sub    $0x8,%esp
c0105977:	6a 01                	push   $0x1
c0105979:	50                   	push   %eax
c010597a:	e8 02 22 00 00       	call   c0107b81 <free_pages>
c010597f:	83 c4 10             	add    $0x10,%esp
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105982:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105986:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010598a:	7e de                	jle    c010596a <check_swap+0x326>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c010598c:	a1 34 d1 12 c0       	mov    0xc012d134,%eax
c0105991:	83 f8 04             	cmp    $0x4,%eax
c0105994:	74 19                	je     c01059af <check_swap+0x36b>
c0105996:	68 6c bb 10 c0       	push   $0xc010bb6c
c010599b:	68 2e b9 10 c0       	push   $0xc010b92e
c01059a0:	68 e7 00 00 00       	push   $0xe7
c01059a5:	68 c8 b8 10 c0       	push   $0xc010b8c8
c01059aa:	e8 b9 bd ff ff       	call   c0101768 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c01059af:	83 ec 0c             	sub    $0xc,%esp
c01059b2:	68 90 bb 10 c0       	push   $0xc010bb90
c01059b7:	e8 ce a8 ff ff       	call   c010028a <cprintf>
c01059bc:	83 c4 10             	add    $0x10,%esp
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c01059bf:	c7 05 64 af 12 c0 00 	movl   $0x0,0xc012af64
c01059c6:	00 00 00 
     
     check_content_set();
c01059c9:	e8 fd fa ff ff       	call   c01054cb <check_content_set>
     assert( nr_free == 0);         
c01059ce:	a1 34 d1 12 c0       	mov    0xc012d134,%eax
c01059d3:	85 c0                	test   %eax,%eax
c01059d5:	74 19                	je     c01059f0 <check_swap+0x3ac>
c01059d7:	68 b7 bb 10 c0       	push   $0xc010bbb7
c01059dc:	68 2e b9 10 c0       	push   $0xc010b92e
c01059e1:	68 f0 00 00 00       	push   $0xf0
c01059e6:	68 c8 b8 10 c0       	push   $0xc010b8c8
c01059eb:	e8 78 bd ff ff       	call   c0101768 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01059f0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01059f7:	eb 26                	jmp    c0105a1f <check_swap+0x3db>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c01059f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059fc:	c7 04 85 80 d0 12 c0 	movl   $0xffffffff,-0x3fed2f80(,%eax,4)
c0105a03:	ff ff ff ff 
c0105a07:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a0a:	8b 14 85 80 d0 12 c0 	mov    -0x3fed2f80(,%eax,4),%edx
c0105a11:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a14:	89 14 85 c0 d0 12 c0 	mov    %edx,-0x3fed2f40(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0105a1b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105a1f:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0105a23:	7e d4                	jle    c01059f9 <check_swap+0x3b5>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105a25:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105a2c:	e9 cc 00 00 00       	jmp    c0105afd <check_swap+0x4b9>
         check_ptep[i]=0;
c0105a31:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a34:	c7 04 85 14 d1 12 c0 	movl   $0x0,-0x3fed2eec(,%eax,4)
c0105a3b:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0105a3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a42:	83 c0 01             	add    $0x1,%eax
c0105a45:	c1 e0 0c             	shl    $0xc,%eax
c0105a48:	83 ec 04             	sub    $0x4,%esp
c0105a4b:	6a 00                	push   $0x0
c0105a4d:	50                   	push   %eax
c0105a4e:	ff 75 d4             	pushl  -0x2c(%ebp)
c0105a51:	e8 3b 27 00 00       	call   c0108191 <get_pte>
c0105a56:	83 c4 10             	add    $0x10,%esp
c0105a59:	89 c2                	mov    %eax,%edx
c0105a5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a5e:	89 14 85 14 d1 12 c0 	mov    %edx,-0x3fed2eec(,%eax,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0105a65:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a68:	8b 04 85 14 d1 12 c0 	mov    -0x3fed2eec(,%eax,4),%eax
c0105a6f:	85 c0                	test   %eax,%eax
c0105a71:	75 19                	jne    c0105a8c <check_swap+0x448>
c0105a73:	68 c4 bb 10 c0       	push   $0xc010bbc4
c0105a78:	68 2e b9 10 c0       	push   $0xc010b92e
c0105a7d:	68 f8 00 00 00       	push   $0xf8
c0105a82:	68 c8 b8 10 c0       	push   $0xc010b8c8
c0105a87:	e8 dc bc ff ff       	call   c0101768 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0105a8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a8f:	8b 04 85 14 d1 12 c0 	mov    -0x3fed2eec(,%eax,4),%eax
c0105a96:	8b 00                	mov    (%eax),%eax
c0105a98:	83 ec 0c             	sub    $0xc,%esp
c0105a9b:	50                   	push   %eax
c0105a9c:	e8 f4 f6 ff ff       	call   c0105195 <pte2page>
c0105aa1:	83 c4 10             	add    $0x10,%esp
c0105aa4:	89 c2                	mov    %eax,%edx
c0105aa6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105aa9:	8b 04 85 60 d0 12 c0 	mov    -0x3fed2fa0(,%eax,4),%eax
c0105ab0:	39 c2                	cmp    %eax,%edx
c0105ab2:	74 19                	je     c0105acd <check_swap+0x489>
c0105ab4:	68 dc bb 10 c0       	push   $0xc010bbdc
c0105ab9:	68 2e b9 10 c0       	push   $0xc010b92e
c0105abe:	68 f9 00 00 00       	push   $0xf9
c0105ac3:	68 c8 b8 10 c0       	push   $0xc010b8c8
c0105ac8:	e8 9b bc ff ff       	call   c0101768 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0105acd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ad0:	8b 04 85 14 d1 12 c0 	mov    -0x3fed2eec(,%eax,4),%eax
c0105ad7:	8b 00                	mov    (%eax),%eax
c0105ad9:	83 e0 01             	and    $0x1,%eax
c0105adc:	85 c0                	test   %eax,%eax
c0105ade:	75 19                	jne    c0105af9 <check_swap+0x4b5>
c0105ae0:	68 04 bc 10 c0       	push   $0xc010bc04
c0105ae5:	68 2e b9 10 c0       	push   $0xc010b92e
c0105aea:	68 fa 00 00 00       	push   $0xfa
c0105aef:	68 c8 b8 10 c0       	push   $0xc010b8c8
c0105af4:	e8 6f bc ff ff       	call   c0101768 <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105af9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105afd:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105b01:	0f 8e 2a ff ff ff    	jle    c0105a31 <check_swap+0x3ed>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c0105b07:	83 ec 0c             	sub    $0xc,%esp
c0105b0a:	68 20 bc 10 c0       	push   $0xc010bc20
c0105b0f:	e8 76 a7 ff ff       	call   c010028a <cprintf>
c0105b14:	83 c4 10             	add    $0x10,%esp
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0105b17:	e8 10 fb ff ff       	call   c010562c <check_content_access>
c0105b1c:	89 45 b8             	mov    %eax,-0x48(%ebp)
     assert(ret==0);
c0105b1f:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0105b23:	74 19                	je     c0105b3e <check_swap+0x4fa>
c0105b25:	68 46 bc 10 c0       	push   $0xc010bc46
c0105b2a:	68 2e b9 10 c0       	push   $0xc010b92e
c0105b2f:	68 ff 00 00 00       	push   $0xff
c0105b34:	68 c8 b8 10 c0       	push   $0xc010b8c8
c0105b39:	e8 2a bc ff ff       	call   c0101768 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105b3e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105b45:	eb 1c                	jmp    c0105b63 <check_swap+0x51f>
         free_pages(check_rp[i],1);
c0105b47:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b4a:	8b 04 85 60 d0 12 c0 	mov    -0x3fed2fa0(,%eax,4),%eax
c0105b51:	83 ec 08             	sub    $0x8,%esp
c0105b54:	6a 01                	push   $0x1
c0105b56:	50                   	push   %eax
c0105b57:	e8 25 20 00 00       	call   c0107b81 <free_pages>
c0105b5c:	83 c4 10             	add    $0x10,%esp
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105b5f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105b63:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105b67:	7e de                	jle    c0105b47 <check_swap+0x503>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0105b69:	83 ec 0c             	sub    $0xc,%esp
c0105b6c:	ff 75 d8             	pushl  -0x28(%ebp)
c0105b6f:	e8 25 ed ff ff       	call   c0104899 <mm_destroy>
c0105b74:	83 c4 10             	add    $0x10,%esp
         
     nr_free = nr_free_store;
c0105b77:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105b7a:	a3 34 d1 12 c0       	mov    %eax,0xc012d134
     free_list = free_list_store;
c0105b7f:	8b 45 98             	mov    -0x68(%ebp),%eax
c0105b82:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0105b85:	a3 2c d1 12 c0       	mov    %eax,0xc012d12c
c0105b8a:	89 15 30 d1 12 c0    	mov    %edx,0xc012d130

     
     le = &free_list;
c0105b90:	c7 45 e8 2c d1 12 c0 	movl   $0xc012d12c,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0105b97:	eb 1d                	jmp    c0105bb6 <check_swap+0x572>
         struct Page *p = le2page(le, page_link);
c0105b99:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b9c:	83 e8 10             	sub    $0x10,%eax
c0105b9f:	89 45 b4             	mov    %eax,-0x4c(%ebp)
         count --, total -= p->property;
c0105ba2:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0105ba6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105ba9:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105bac:	8b 40 08             	mov    0x8(%eax),%eax
c0105baf:	29 c2                	sub    %eax,%edx
c0105bb1:	89 d0                	mov    %edx,%eax
c0105bb3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105bb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105bb9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0105bbc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105bbf:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0105bc2:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105bc5:	81 7d e8 2c d1 12 c0 	cmpl   $0xc012d12c,-0x18(%ebp)
c0105bcc:	75 cb                	jne    c0105b99 <check_swap+0x555>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c0105bce:	83 ec 04             	sub    $0x4,%esp
c0105bd1:	ff 75 f0             	pushl  -0x10(%ebp)
c0105bd4:	ff 75 f4             	pushl  -0xc(%ebp)
c0105bd7:	68 4d bc 10 c0       	push   $0xc010bc4d
c0105bdc:	e8 a9 a6 ff ff       	call   c010028a <cprintf>
c0105be1:	83 c4 10             	add    $0x10,%esp
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0105be4:	83 ec 0c             	sub    $0xc,%esp
c0105be7:	68 67 bc 10 c0       	push   $0xc010bc67
c0105bec:	e8 99 a6 ff ff       	call   c010028a <cprintf>
c0105bf1:	83 c4 10             	add    $0x10,%esp
}
c0105bf4:	90                   	nop
c0105bf5:	c9                   	leave  
c0105bf6:	c3                   	ret    

c0105bf7 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0105bf7:	55                   	push   %ebp
c0105bf8:	89 e5                	mov    %esp,%ebp
c0105bfa:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0105bfd:	9c                   	pushf  
c0105bfe:	58                   	pop    %eax
c0105bff:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0105c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0105c05:	25 00 02 00 00       	and    $0x200,%eax
c0105c0a:	85 c0                	test   %eax,%eax
c0105c0c:	74 0c                	je     c0105c1a <__intr_save+0x23>
        intr_disable();
c0105c0e:	e8 36 d8 ff ff       	call   c0103449 <intr_disable>
        return 1;
c0105c13:	b8 01 00 00 00       	mov    $0x1,%eax
c0105c18:	eb 05                	jmp    c0105c1f <__intr_save+0x28>
    }
    return 0;
c0105c1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105c1f:	c9                   	leave  
c0105c20:	c3                   	ret    

c0105c21 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0105c21:	55                   	push   %ebp
c0105c22:	89 e5                	mov    %esp,%ebp
c0105c24:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0105c27:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105c2b:	74 05                	je     c0105c32 <__intr_restore+0x11>
        intr_enable();
c0105c2d:	e8 10 d8 ff ff       	call   c0103442 <intr_enable>
    }
}
c0105c32:	90                   	nop
c0105c33:	c9                   	leave  
c0105c34:	c3                   	ret    

c0105c35 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0105c35:	55                   	push   %ebp
c0105c36:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0105c38:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c3b:	8b 15 40 d1 12 c0    	mov    0xc012d140,%edx
c0105c41:	29 d0                	sub    %edx,%eax
c0105c43:	c1 f8 02             	sar    $0x2,%eax
c0105c46:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0105c4c:	5d                   	pop    %ebp
c0105c4d:	c3                   	ret    

c0105c4e <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0105c4e:	55                   	push   %ebp
c0105c4f:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0105c51:	ff 75 08             	pushl  0x8(%ebp)
c0105c54:	e8 dc ff ff ff       	call   c0105c35 <page2ppn>
c0105c59:	83 c4 04             	add    $0x4,%esp
c0105c5c:	c1 e0 0c             	shl    $0xc,%eax
}
c0105c5f:	c9                   	leave  
c0105c60:	c3                   	ret    

c0105c61 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0105c61:	55                   	push   %ebp
c0105c62:	89 e5                	mov    %esp,%ebp
c0105c64:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0105c67:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c6a:	c1 e8 0c             	shr    $0xc,%eax
c0105c6d:	89 c2                	mov    %eax,%edx
c0105c6f:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c0105c74:	39 c2                	cmp    %eax,%edx
c0105c76:	72 14                	jb     c0105c8c <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0105c78:	83 ec 04             	sub    $0x4,%esp
c0105c7b:	68 80 bc 10 c0       	push   $0xc010bc80
c0105c80:	6a 5f                	push   $0x5f
c0105c82:	68 9f bc 10 c0       	push   $0xc010bc9f
c0105c87:	e8 dc ba ff ff       	call   c0101768 <__panic>
    }
    return &pages[PPN(pa)];
c0105c8c:	8b 0d 40 d1 12 c0    	mov    0xc012d140,%ecx
c0105c92:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c95:	c1 e8 0c             	shr    $0xc,%eax
c0105c98:	89 c2                	mov    %eax,%edx
c0105c9a:	89 d0                	mov    %edx,%eax
c0105c9c:	c1 e0 03             	shl    $0x3,%eax
c0105c9f:	01 d0                	add    %edx,%eax
c0105ca1:	c1 e0 02             	shl    $0x2,%eax
c0105ca4:	01 c8                	add    %ecx,%eax
}
c0105ca6:	c9                   	leave  
c0105ca7:	c3                   	ret    

c0105ca8 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0105ca8:	55                   	push   %ebp
c0105ca9:	89 e5                	mov    %esp,%ebp
c0105cab:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c0105cae:	ff 75 08             	pushl  0x8(%ebp)
c0105cb1:	e8 98 ff ff ff       	call   c0105c4e <page2pa>
c0105cb6:	83 c4 04             	add    $0x4,%esp
c0105cb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cbf:	c1 e8 0c             	shr    $0xc,%eax
c0105cc2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105cc5:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c0105cca:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105ccd:	72 14                	jb     c0105ce3 <page2kva+0x3b>
c0105ccf:	ff 75 f4             	pushl  -0xc(%ebp)
c0105cd2:	68 b0 bc 10 c0       	push   $0xc010bcb0
c0105cd7:	6a 66                	push   $0x66
c0105cd9:	68 9f bc 10 c0       	push   $0xc010bc9f
c0105cde:	e8 85 ba ff ff       	call   c0101768 <__panic>
c0105ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ce6:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0105ceb:	c9                   	leave  
c0105cec:	c3                   	ret    

c0105ced <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c0105ced:	55                   	push   %ebp
c0105cee:	89 e5                	mov    %esp,%ebp
c0105cf0:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PADDR(kva));
c0105cf3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cf6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105cf9:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105d00:	77 14                	ja     c0105d16 <kva2page+0x29>
c0105d02:	ff 75 f4             	pushl  -0xc(%ebp)
c0105d05:	68 d4 bc 10 c0       	push   $0xc010bcd4
c0105d0a:	6a 6b                	push   $0x6b
c0105d0c:	68 9f bc 10 c0       	push   $0xc010bc9f
c0105d11:	e8 52 ba ff ff       	call   c0101768 <__panic>
c0105d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d19:	05 00 00 00 40       	add    $0x40000000,%eax
c0105d1e:	83 ec 0c             	sub    $0xc,%esp
c0105d21:	50                   	push   %eax
c0105d22:	e8 3a ff ff ff       	call   c0105c61 <pa2page>
c0105d27:	83 c4 10             	add    $0x10,%esp
}
c0105d2a:	c9                   	leave  
c0105d2b:	c3                   	ret    

c0105d2c <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0105d2c:	55                   	push   %ebp
c0105d2d:	89 e5                	mov    %esp,%ebp
c0105d2f:	83 ec 18             	sub    $0x18,%esp
  struct Page * page = alloc_pages(1 << order);
c0105d32:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d35:	ba 01 00 00 00       	mov    $0x1,%edx
c0105d3a:	89 c1                	mov    %eax,%ecx
c0105d3c:	d3 e2                	shl    %cl,%edx
c0105d3e:	89 d0                	mov    %edx,%eax
c0105d40:	83 ec 0c             	sub    $0xc,%esp
c0105d43:	50                   	push   %eax
c0105d44:	e8 cc 1d 00 00       	call   c0107b15 <alloc_pages>
c0105d49:	83 c4 10             	add    $0x10,%esp
c0105d4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c0105d4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105d53:	75 07                	jne    c0105d5c <__slob_get_free_pages+0x30>
    return NULL;
c0105d55:	b8 00 00 00 00       	mov    $0x0,%eax
c0105d5a:	eb 0e                	jmp    c0105d6a <__slob_get_free_pages+0x3e>
  return page2kva(page);
c0105d5c:	83 ec 0c             	sub    $0xc,%esp
c0105d5f:	ff 75 f4             	pushl  -0xc(%ebp)
c0105d62:	e8 41 ff ff ff       	call   c0105ca8 <page2kva>
c0105d67:	83 c4 10             	add    $0x10,%esp
}
c0105d6a:	c9                   	leave  
c0105d6b:	c3                   	ret    

c0105d6c <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c0105d6c:	55                   	push   %ebp
c0105d6d:	89 e5                	mov    %esp,%ebp
c0105d6f:	53                   	push   %ebx
c0105d70:	83 ec 04             	sub    $0x4,%esp
  free_pages(kva2page(kva), 1 << order);
c0105d73:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d76:	ba 01 00 00 00       	mov    $0x1,%edx
c0105d7b:	89 c1                	mov    %eax,%ecx
c0105d7d:	d3 e2                	shl    %cl,%edx
c0105d7f:	89 d0                	mov    %edx,%eax
c0105d81:	89 c3                	mov    %eax,%ebx
c0105d83:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d86:	83 ec 0c             	sub    $0xc,%esp
c0105d89:	50                   	push   %eax
c0105d8a:	e8 5e ff ff ff       	call   c0105ced <kva2page>
c0105d8f:	83 c4 10             	add    $0x10,%esp
c0105d92:	83 ec 08             	sub    $0x8,%esp
c0105d95:	53                   	push   %ebx
c0105d96:	50                   	push   %eax
c0105d97:	e8 e5 1d 00 00       	call   c0107b81 <free_pages>
c0105d9c:	83 c4 10             	add    $0x10,%esp
}
c0105d9f:	90                   	nop
c0105da0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0105da3:	c9                   	leave  
c0105da4:	c3                   	ret    

c0105da5 <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c0105da5:	55                   	push   %ebp
c0105da6:	89 e5                	mov    %esp,%ebp
c0105da8:	83 ec 28             	sub    $0x28,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c0105dab:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dae:	83 c0 08             	add    $0x8,%eax
c0105db1:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0105db6:	76 16                	jbe    c0105dce <slob_alloc+0x29>
c0105db8:	68 f8 bc 10 c0       	push   $0xc010bcf8
c0105dbd:	68 17 bd 10 c0       	push   $0xc010bd17
c0105dc2:	6a 64                	push   $0x64
c0105dc4:	68 2c bd 10 c0       	push   $0xc010bd2c
c0105dc9:	e8 9a b9 ff ff       	call   c0101768 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c0105dce:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c0105dd5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0105ddc:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ddf:	83 c0 07             	add    $0x7,%eax
c0105de2:	c1 e8 03             	shr    $0x3,%eax
c0105de5:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c0105de8:	e8 0a fe ff ff       	call   c0105bf7 <__intr_save>
c0105ded:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c0105df0:	a1 e8 79 12 c0       	mov    0xc01279e8,%eax
c0105df5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0105df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105dfb:	8b 40 04             	mov    0x4(%eax),%eax
c0105dfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0105e01:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105e05:	74 25                	je     c0105e2c <slob_alloc+0x87>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c0105e07:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105e0a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e0d:	01 d0                	add    %edx,%eax
c0105e0f:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105e12:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e15:	f7 d8                	neg    %eax
c0105e17:	21 d0                	and    %edx,%eax
c0105e19:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0105e1c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105e1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e22:	29 c2                	sub    %eax,%edx
c0105e24:	89 d0                	mov    %edx,%eax
c0105e26:	c1 f8 03             	sar    $0x3,%eax
c0105e29:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c0105e2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e2f:	8b 00                	mov    (%eax),%eax
c0105e31:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0105e34:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105e37:	01 ca                	add    %ecx,%edx
c0105e39:	39 d0                	cmp    %edx,%eax
c0105e3b:	0f 8c b1 00 00 00    	jl     c0105ef2 <slob_alloc+0x14d>
			if (delta) { /* need to fragment head to align? */
c0105e41:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105e45:	74 38                	je     c0105e7f <slob_alloc+0xda>
				aligned->units = cur->units - delta;
c0105e47:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e4a:	8b 00                	mov    (%eax),%eax
c0105e4c:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0105e4f:	89 c2                	mov    %eax,%edx
c0105e51:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e54:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c0105e56:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e59:	8b 50 04             	mov    0x4(%eax),%edx
c0105e5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e5f:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c0105e62:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e65:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105e68:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c0105e6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e6e:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105e71:	89 10                	mov    %edx,(%eax)
				prev = cur;
c0105e73:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e76:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c0105e79:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c0105e7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e82:	8b 00                	mov    (%eax),%eax
c0105e84:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0105e87:	75 0e                	jne    c0105e97 <slob_alloc+0xf2>
				prev->next = cur->next; /* unlink */
c0105e89:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e8c:	8b 50 04             	mov    0x4(%eax),%edx
c0105e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e92:	89 50 04             	mov    %edx,0x4(%eax)
c0105e95:	eb 3c                	jmp    c0105ed3 <slob_alloc+0x12e>
			else { /* fragment */
				prev->next = cur + units;
c0105e97:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e9a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0105ea1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ea4:	01 c2                	add    %eax,%edx
c0105ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ea9:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c0105eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105eaf:	8b 40 04             	mov    0x4(%eax),%eax
c0105eb2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105eb5:	8b 12                	mov    (%edx),%edx
c0105eb7:	2b 55 e0             	sub    -0x20(%ebp),%edx
c0105eba:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c0105ebc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ebf:	8b 40 04             	mov    0x4(%eax),%eax
c0105ec2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105ec5:	8b 52 04             	mov    0x4(%edx),%edx
c0105ec8:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0105ecb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ece:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105ed1:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0105ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ed6:	a3 e8 79 12 c0       	mov    %eax,0xc01279e8
			spin_unlock_irqrestore(&slob_lock, flags);
c0105edb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ede:	83 ec 0c             	sub    $0xc,%esp
c0105ee1:	50                   	push   %eax
c0105ee2:	e8 3a fd ff ff       	call   c0105c21 <__intr_restore>
c0105ee7:	83 c4 10             	add    $0x10,%esp
			return cur;
c0105eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105eed:	e9 80 00 00 00       	jmp    c0105f72 <slob_alloc+0x1cd>
		}
		if (cur == slobfree) {
c0105ef2:	a1 e8 79 12 c0       	mov    0xc01279e8,%eax
c0105ef7:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105efa:	75 62                	jne    c0105f5e <slob_alloc+0x1b9>
			spin_unlock_irqrestore(&slob_lock, flags);
c0105efc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105eff:	83 ec 0c             	sub    $0xc,%esp
c0105f02:	50                   	push   %eax
c0105f03:	e8 19 fd ff ff       	call   c0105c21 <__intr_restore>
c0105f08:	83 c4 10             	add    $0x10,%esp

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c0105f0b:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0105f12:	75 07                	jne    c0105f1b <slob_alloc+0x176>
				return 0;
c0105f14:	b8 00 00 00 00       	mov    $0x0,%eax
c0105f19:	eb 57                	jmp    c0105f72 <slob_alloc+0x1cd>

			cur = (slob_t *)__slob_get_free_page(gfp);
c0105f1b:	83 ec 08             	sub    $0x8,%esp
c0105f1e:	6a 00                	push   $0x0
c0105f20:	ff 75 0c             	pushl  0xc(%ebp)
c0105f23:	e8 04 fe ff ff       	call   c0105d2c <__slob_get_free_pages>
c0105f28:	83 c4 10             	add    $0x10,%esp
c0105f2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0105f2e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105f32:	75 07                	jne    c0105f3b <slob_alloc+0x196>
				return 0;
c0105f34:	b8 00 00 00 00       	mov    $0x0,%eax
c0105f39:	eb 37                	jmp    c0105f72 <slob_alloc+0x1cd>

			slob_free(cur, PAGE_SIZE);
c0105f3b:	83 ec 08             	sub    $0x8,%esp
c0105f3e:	68 00 10 00 00       	push   $0x1000
c0105f43:	ff 75 f0             	pushl  -0x10(%ebp)
c0105f46:	e8 29 00 00 00       	call   c0105f74 <slob_free>
c0105f4b:	83 c4 10             	add    $0x10,%esp
			spin_lock_irqsave(&slob_lock, flags);
c0105f4e:	e8 a4 fc ff ff       	call   c0105bf7 <__intr_save>
c0105f53:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c0105f56:	a1 e8 79 12 c0       	mov    0xc01279e8,%eax
c0105f5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0105f5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f61:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105f64:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f67:	8b 40 04             	mov    0x4(%eax),%eax
c0105f6a:	89 45 f0             	mov    %eax,-0x10(%ebp)

			slob_free(cur, PAGE_SIZE);
			spin_lock_irqsave(&slob_lock, flags);
			cur = slobfree;
		}
	}
c0105f6d:	e9 8f fe ff ff       	jmp    c0105e01 <slob_alloc+0x5c>
}
c0105f72:	c9                   	leave  
c0105f73:	c3                   	ret    

c0105f74 <slob_free>:

static void slob_free(void *block, int size)
{
c0105f74:	55                   	push   %ebp
c0105f75:	89 e5                	mov    %esp,%ebp
c0105f77:	83 ec 18             	sub    $0x18,%esp
	slob_t *cur, *b = (slob_t *)block;
c0105f7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0105f80:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105f84:	0f 84 05 01 00 00    	je     c010608f <slob_free+0x11b>
		return;

	if (size)
c0105f8a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105f8e:	74 10                	je     c0105fa0 <slob_free+0x2c>
		b->units = SLOB_UNITS(size);
c0105f90:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f93:	83 c0 07             	add    $0x7,%eax
c0105f96:	c1 e8 03             	shr    $0x3,%eax
c0105f99:	89 c2                	mov    %eax,%edx
c0105f9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f9e:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c0105fa0:	e8 52 fc ff ff       	call   c0105bf7 <__intr_save>
c0105fa5:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0105fa8:	a1 e8 79 12 c0       	mov    0xc01279e8,%eax
c0105fad:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105fb0:	eb 27                	jmp    c0105fd9 <slob_free+0x65>
		if (cur >= cur->next && (b > cur || b < cur->next))
c0105fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fb5:	8b 40 04             	mov    0x4(%eax),%eax
c0105fb8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105fbb:	77 13                	ja     c0105fd0 <slob_free+0x5c>
c0105fbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fc0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105fc3:	77 27                	ja     c0105fec <slob_free+0x78>
c0105fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fc8:	8b 40 04             	mov    0x4(%eax),%eax
c0105fcb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105fce:	77 1c                	ja     c0105fec <slob_free+0x78>
	if (size)
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0105fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fd3:	8b 40 04             	mov    0x4(%eax),%eax
c0105fd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105fd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fdc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105fdf:	76 d1                	jbe    c0105fb2 <slob_free+0x3e>
c0105fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fe4:	8b 40 04             	mov    0x4(%eax),%eax
c0105fe7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105fea:	76 c6                	jbe    c0105fb2 <slob_free+0x3e>
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	if (b + b->units == cur->next) {
c0105fec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fef:	8b 00                	mov    (%eax),%eax
c0105ff1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0105ff8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ffb:	01 c2                	add    %eax,%edx
c0105ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106000:	8b 40 04             	mov    0x4(%eax),%eax
c0106003:	39 c2                	cmp    %eax,%edx
c0106005:	75 25                	jne    c010602c <slob_free+0xb8>
		b->units += cur->next->units;
c0106007:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010600a:	8b 10                	mov    (%eax),%edx
c010600c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010600f:	8b 40 04             	mov    0x4(%eax),%eax
c0106012:	8b 00                	mov    (%eax),%eax
c0106014:	01 c2                	add    %eax,%edx
c0106016:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106019:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c010601b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010601e:	8b 40 04             	mov    0x4(%eax),%eax
c0106021:	8b 50 04             	mov    0x4(%eax),%edx
c0106024:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106027:	89 50 04             	mov    %edx,0x4(%eax)
c010602a:	eb 0c                	jmp    c0106038 <slob_free+0xc4>
	} else
		b->next = cur->next;
c010602c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010602f:	8b 50 04             	mov    0x4(%eax),%edx
c0106032:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106035:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0106038:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010603b:	8b 00                	mov    (%eax),%eax
c010603d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0106044:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106047:	01 d0                	add    %edx,%eax
c0106049:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010604c:	75 1f                	jne    c010606d <slob_free+0xf9>
		cur->units += b->units;
c010604e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106051:	8b 10                	mov    (%eax),%edx
c0106053:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106056:	8b 00                	mov    (%eax),%eax
c0106058:	01 c2                	add    %eax,%edx
c010605a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010605d:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c010605f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106062:	8b 50 04             	mov    0x4(%eax),%edx
c0106065:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106068:	89 50 04             	mov    %edx,0x4(%eax)
c010606b:	eb 09                	jmp    c0106076 <slob_free+0x102>
	} else
		cur->next = b;
c010606d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106070:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106073:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0106076:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106079:	a3 e8 79 12 c0       	mov    %eax,0xc01279e8

	spin_unlock_irqrestore(&slob_lock, flags);
c010607e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106081:	83 ec 0c             	sub    $0xc,%esp
c0106084:	50                   	push   %eax
c0106085:	e8 97 fb ff ff       	call   c0105c21 <__intr_restore>
c010608a:	83 c4 10             	add    $0x10,%esp
c010608d:	eb 01                	jmp    c0106090 <slob_free+0x11c>
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
		return;
c010608f:	90                   	nop
		cur->next = b;

	slobfree = cur;

	spin_unlock_irqrestore(&slob_lock, flags);
}
c0106090:	c9                   	leave  
c0106091:	c3                   	ret    

c0106092 <check_slab>:



void check_slab(void) {
c0106092:	55                   	push   %ebp
c0106093:	89 e5                	mov    %esp,%ebp
c0106095:	83 ec 08             	sub    $0x8,%esp
  cprintf("check_slab() success\n");
c0106098:	83 ec 0c             	sub    $0xc,%esp
c010609b:	68 3e bd 10 c0       	push   $0xc010bd3e
c01060a0:	e8 e5 a1 ff ff       	call   c010028a <cprintf>
c01060a5:	83 c4 10             	add    $0x10,%esp
}
c01060a8:	90                   	nop
c01060a9:	c9                   	leave  
c01060aa:	c3                   	ret    

c01060ab <slab_init>:

void
slab_init(void) {
c01060ab:	55                   	push   %ebp
c01060ac:	89 e5                	mov    %esp,%ebp
c01060ae:	83 ec 08             	sub    $0x8,%esp
  cprintf("use SLOB allocator\n");
c01060b1:	83 ec 0c             	sub    $0xc,%esp
c01060b4:	68 54 bd 10 c0       	push   $0xc010bd54
c01060b9:	e8 cc a1 ff ff       	call   c010028a <cprintf>
c01060be:	83 c4 10             	add    $0x10,%esp
  check_slab();
c01060c1:	e8 cc ff ff ff       	call   c0106092 <check_slab>
}
c01060c6:	90                   	nop
c01060c7:	c9                   	leave  
c01060c8:	c3                   	ret    

c01060c9 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c01060c9:	55                   	push   %ebp
c01060ca:	89 e5                	mov    %esp,%ebp
c01060cc:	83 ec 08             	sub    $0x8,%esp
    slab_init();
c01060cf:	e8 d7 ff ff ff       	call   c01060ab <slab_init>
    cprintf("kmalloc_init() succeeded!\n");
c01060d4:	83 ec 0c             	sub    $0xc,%esp
c01060d7:	68 68 bd 10 c0       	push   $0xc010bd68
c01060dc:	e8 a9 a1 ff ff       	call   c010028a <cprintf>
c01060e1:	83 c4 10             	add    $0x10,%esp
}
c01060e4:	90                   	nop
c01060e5:	c9                   	leave  
c01060e6:	c3                   	ret    

c01060e7 <slab_allocated>:

size_t
slab_allocated(void) {
c01060e7:	55                   	push   %ebp
c01060e8:	89 e5                	mov    %esp,%ebp
  return 0;
c01060ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01060ef:	5d                   	pop    %ebp
c01060f0:	c3                   	ret    

c01060f1 <kallocated>:

size_t
kallocated(void) {
c01060f1:	55                   	push   %ebp
c01060f2:	89 e5                	mov    %esp,%ebp
   return slab_allocated();
c01060f4:	e8 ee ff ff ff       	call   c01060e7 <slab_allocated>
}
c01060f9:	5d                   	pop    %ebp
c01060fa:	c3                   	ret    

c01060fb <find_order>:

static int find_order(int size)
{
c01060fb:	55                   	push   %ebp
c01060fc:	89 e5                	mov    %esp,%ebp
c01060fe:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0106101:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0106108:	eb 07                	jmp    c0106111 <find_order+0x16>
		order++;
c010610a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
}

static int find_order(int size)
{
	int order = 0;
	for ( ; size > 4096 ; size >>=1)
c010610e:	d1 7d 08             	sarl   0x8(%ebp)
c0106111:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0106118:	7f f0                	jg     c010610a <find_order+0xf>
		order++;
	return order;
c010611a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010611d:	c9                   	leave  
c010611e:	c3                   	ret    

c010611f <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c010611f:	55                   	push   %ebp
c0106120:	89 e5                	mov    %esp,%ebp
c0106122:	83 ec 18             	sub    $0x18,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0106125:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c010612c:	77 35                	ja     c0106163 <__kmalloc+0x44>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c010612e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106131:	83 c0 08             	add    $0x8,%eax
c0106134:	83 ec 04             	sub    $0x4,%esp
c0106137:	6a 00                	push   $0x0
c0106139:	ff 75 0c             	pushl  0xc(%ebp)
c010613c:	50                   	push   %eax
c010613d:	e8 63 fc ff ff       	call   c0105da5 <slob_alloc>
c0106142:	83 c4 10             	add    $0x10,%esp
c0106145:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return m ? (void *)(m + 1) : 0;
c0106148:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010614c:	74 0b                	je     c0106159 <__kmalloc+0x3a>
c010614e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106151:	83 c0 08             	add    $0x8,%eax
c0106154:	e9 b3 00 00 00       	jmp    c010620c <__kmalloc+0xed>
c0106159:	b8 00 00 00 00       	mov    $0x0,%eax
c010615e:	e9 a9 00 00 00       	jmp    c010620c <__kmalloc+0xed>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0106163:	83 ec 04             	sub    $0x4,%esp
c0106166:	6a 00                	push   $0x0
c0106168:	ff 75 0c             	pushl  0xc(%ebp)
c010616b:	6a 0c                	push   $0xc
c010616d:	e8 33 fc ff ff       	call   c0105da5 <slob_alloc>
c0106172:	83 c4 10             	add    $0x10,%esp
c0106175:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (!bb)
c0106178:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010617c:	75 0a                	jne    c0106188 <__kmalloc+0x69>
		return 0;
c010617e:	b8 00 00 00 00       	mov    $0x0,%eax
c0106183:	e9 84 00 00 00       	jmp    c010620c <__kmalloc+0xed>

	bb->order = find_order(size);
c0106188:	8b 45 08             	mov    0x8(%ebp),%eax
c010618b:	83 ec 0c             	sub    $0xc,%esp
c010618e:	50                   	push   %eax
c010618f:	e8 67 ff ff ff       	call   c01060fb <find_order>
c0106194:	83 c4 10             	add    $0x10,%esp
c0106197:	89 c2                	mov    %eax,%edx
c0106199:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010619c:	89 10                	mov    %edx,(%eax)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c010619e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061a1:	8b 00                	mov    (%eax),%eax
c01061a3:	83 ec 08             	sub    $0x8,%esp
c01061a6:	50                   	push   %eax
c01061a7:	ff 75 0c             	pushl  0xc(%ebp)
c01061aa:	e8 7d fb ff ff       	call   c0105d2c <__slob_get_free_pages>
c01061af:	83 c4 10             	add    $0x10,%esp
c01061b2:	89 c2                	mov    %eax,%edx
c01061b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061b7:	89 50 04             	mov    %edx,0x4(%eax)

	if (bb->pages) {
c01061ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061bd:	8b 40 04             	mov    0x4(%eax),%eax
c01061c0:	85 c0                	test   %eax,%eax
c01061c2:	74 33                	je     c01061f7 <__kmalloc+0xd8>
		spin_lock_irqsave(&block_lock, flags);
c01061c4:	e8 2e fa ff ff       	call   c0105bf7 <__intr_save>
c01061c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
		bb->next = bigblocks;
c01061cc:	8b 15 74 af 12 c0    	mov    0xc012af74,%edx
c01061d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061d5:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c01061d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061db:	a3 74 af 12 c0       	mov    %eax,0xc012af74
		spin_unlock_irqrestore(&block_lock, flags);
c01061e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01061e3:	83 ec 0c             	sub    $0xc,%esp
c01061e6:	50                   	push   %eax
c01061e7:	e8 35 fa ff ff       	call   c0105c21 <__intr_restore>
c01061ec:	83 c4 10             	add    $0x10,%esp
		return bb->pages;
c01061ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061f2:	8b 40 04             	mov    0x4(%eax),%eax
c01061f5:	eb 15                	jmp    c010620c <__kmalloc+0xed>
	}

	slob_free(bb, sizeof(bigblock_t));
c01061f7:	83 ec 08             	sub    $0x8,%esp
c01061fa:	6a 0c                	push   $0xc
c01061fc:	ff 75 f0             	pushl  -0x10(%ebp)
c01061ff:	e8 70 fd ff ff       	call   c0105f74 <slob_free>
c0106204:	83 c4 10             	add    $0x10,%esp
	return 0;
c0106207:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010620c:	c9                   	leave  
c010620d:	c3                   	ret    

c010620e <kmalloc>:

void *
kmalloc(size_t size)
{
c010620e:	55                   	push   %ebp
c010620f:	89 e5                	mov    %esp,%ebp
c0106211:	83 ec 08             	sub    $0x8,%esp
  return __kmalloc(size, 0);
c0106214:	83 ec 08             	sub    $0x8,%esp
c0106217:	6a 00                	push   $0x0
c0106219:	ff 75 08             	pushl  0x8(%ebp)
c010621c:	e8 fe fe ff ff       	call   c010611f <__kmalloc>
c0106221:	83 c4 10             	add    $0x10,%esp
}
c0106224:	c9                   	leave  
c0106225:	c3                   	ret    

c0106226 <kfree>:


void kfree(void *block)
{
c0106226:	55                   	push   %ebp
c0106227:	89 e5                	mov    %esp,%ebp
c0106229:	83 ec 18             	sub    $0x18,%esp
	bigblock_t *bb, **last = &bigblocks;
c010622c:	c7 45 f0 74 af 12 c0 	movl   $0xc012af74,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0106233:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106237:	0f 84 ac 00 00 00    	je     c01062e9 <kfree+0xc3>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c010623d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106240:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106245:	85 c0                	test   %eax,%eax
c0106247:	0f 85 85 00 00 00    	jne    c01062d2 <kfree+0xac>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c010624d:	e8 a5 f9 ff ff       	call   c0105bf7 <__intr_save>
c0106252:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0106255:	a1 74 af 12 c0       	mov    0xc012af74,%eax
c010625a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010625d:	eb 5e                	jmp    c01062bd <kfree+0x97>
			if (bb->pages == block) {
c010625f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106262:	8b 40 04             	mov    0x4(%eax),%eax
c0106265:	3b 45 08             	cmp    0x8(%ebp),%eax
c0106268:	75 41                	jne    c01062ab <kfree+0x85>
				*last = bb->next;
c010626a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010626d:	8b 50 08             	mov    0x8(%eax),%edx
c0106270:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106273:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0106275:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106278:	83 ec 0c             	sub    $0xc,%esp
c010627b:	50                   	push   %eax
c010627c:	e8 a0 f9 ff ff       	call   c0105c21 <__intr_restore>
c0106281:	83 c4 10             	add    $0x10,%esp
				__slob_free_pages((unsigned long)block, bb->order);
c0106284:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106287:	8b 10                	mov    (%eax),%edx
c0106289:	8b 45 08             	mov    0x8(%ebp),%eax
c010628c:	83 ec 08             	sub    $0x8,%esp
c010628f:	52                   	push   %edx
c0106290:	50                   	push   %eax
c0106291:	e8 d6 fa ff ff       	call   c0105d6c <__slob_free_pages>
c0106296:	83 c4 10             	add    $0x10,%esp
				slob_free(bb, sizeof(bigblock_t));
c0106299:	83 ec 08             	sub    $0x8,%esp
c010629c:	6a 0c                	push   $0xc
c010629e:	ff 75 f4             	pushl  -0xc(%ebp)
c01062a1:	e8 ce fc ff ff       	call   c0105f74 <slob_free>
c01062a6:	83 c4 10             	add    $0x10,%esp
				return;
c01062a9:	eb 3f                	jmp    c01062ea <kfree+0xc4>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c01062ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062ae:	83 c0 08             	add    $0x8,%eax
c01062b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01062b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062b7:	8b 40 08             	mov    0x8(%eax),%eax
c01062ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01062bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01062c1:	75 9c                	jne    c010625f <kfree+0x39>
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c01062c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01062c6:	83 ec 0c             	sub    $0xc,%esp
c01062c9:	50                   	push   %eax
c01062ca:	e8 52 f9 ff ff       	call   c0105c21 <__intr_restore>
c01062cf:	83 c4 10             	add    $0x10,%esp
	}

	slob_free((slob_t *)block - 1, 0);
c01062d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01062d5:	83 e8 08             	sub    $0x8,%eax
c01062d8:	83 ec 08             	sub    $0x8,%esp
c01062db:	6a 00                	push   $0x0
c01062dd:	50                   	push   %eax
c01062de:	e8 91 fc ff ff       	call   c0105f74 <slob_free>
c01062e3:	83 c4 10             	add    $0x10,%esp
	return;
c01062e6:	90                   	nop
c01062e7:	eb 01                	jmp    c01062ea <kfree+0xc4>
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
		return;
c01062e9:	90                   	nop
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
c01062ea:	c9                   	leave  
c01062eb:	c3                   	ret    

c01062ec <ksize>:


unsigned int ksize(const void *block)
{
c01062ec:	55                   	push   %ebp
c01062ed:	89 e5                	mov    %esp,%ebp
c01062ef:	83 ec 18             	sub    $0x18,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c01062f2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01062f6:	75 07                	jne    c01062ff <ksize+0x13>
		return 0;
c01062f8:	b8 00 00 00 00       	mov    $0x0,%eax
c01062fd:	eb 73                	jmp    c0106372 <ksize+0x86>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c01062ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0106302:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106307:	85 c0                	test   %eax,%eax
c0106309:	75 5c                	jne    c0106367 <ksize+0x7b>
		spin_lock_irqsave(&block_lock, flags);
c010630b:	e8 e7 f8 ff ff       	call   c0105bf7 <__intr_save>
c0106310:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0106313:	a1 74 af 12 c0       	mov    0xc012af74,%eax
c0106318:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010631b:	eb 35                	jmp    c0106352 <ksize+0x66>
			if (bb->pages == block) {
c010631d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106320:	8b 40 04             	mov    0x4(%eax),%eax
c0106323:	3b 45 08             	cmp    0x8(%ebp),%eax
c0106326:	75 21                	jne    c0106349 <ksize+0x5d>
				spin_unlock_irqrestore(&slob_lock, flags);
c0106328:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010632b:	83 ec 0c             	sub    $0xc,%esp
c010632e:	50                   	push   %eax
c010632f:	e8 ed f8 ff ff       	call   c0105c21 <__intr_restore>
c0106334:	83 c4 10             	add    $0x10,%esp
				return PAGE_SIZE << bb->order;
c0106337:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010633a:	8b 00                	mov    (%eax),%eax
c010633c:	ba 00 10 00 00       	mov    $0x1000,%edx
c0106341:	89 c1                	mov    %eax,%ecx
c0106343:	d3 e2                	shl    %cl,%edx
c0106345:	89 d0                	mov    %edx,%eax
c0106347:	eb 29                	jmp    c0106372 <ksize+0x86>
	if (!block)
		return 0;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; bb = bb->next)
c0106349:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010634c:	8b 40 08             	mov    0x8(%eax),%eax
c010634f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106352:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106356:	75 c5                	jne    c010631d <ksize+0x31>
			if (bb->pages == block) {
				spin_unlock_irqrestore(&slob_lock, flags);
				return PAGE_SIZE << bb->order;
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0106358:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010635b:	83 ec 0c             	sub    $0xc,%esp
c010635e:	50                   	push   %eax
c010635f:	e8 bd f8 ff ff       	call   c0105c21 <__intr_restore>
c0106364:	83 c4 10             	add    $0x10,%esp
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0106367:	8b 45 08             	mov    0x8(%ebp),%eax
c010636a:	83 e8 08             	sub    $0x8,%eax
c010636d:	8b 00                	mov    (%eax),%eax
c010636f:	c1 e0 03             	shl    $0x3,%eax
}
c0106372:	c9                   	leave  
c0106373:	c3                   	ret    

c0106374 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0106374:	55                   	push   %ebp
c0106375:	89 e5                	mov    %esp,%ebp
c0106377:	83 ec 10             	sub    $0x10,%esp
c010637a:	c7 45 fc 24 d1 12 c0 	movl   $0xc012d124,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0106381:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106384:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0106387:	89 50 04             	mov    %edx,0x4(%eax)
c010638a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010638d:	8b 50 04             	mov    0x4(%eax),%edx
c0106390:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106393:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0106395:	8b 45 08             	mov    0x8(%ebp),%eax
c0106398:	c7 40 14 24 d1 12 c0 	movl   $0xc012d124,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c010639f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01063a4:	c9                   	leave  
c01063a5:	c3                   	ret    

c01063a6 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01063a6:	55                   	push   %ebp
c01063a7:	89 e5                	mov    %esp,%ebp
c01063a9:	83 ec 38             	sub    $0x38,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c01063ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01063af:	8b 40 14             	mov    0x14(%eax),%eax
c01063b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c01063b5:	8b 45 10             	mov    0x10(%ebp),%eax
c01063b8:	83 c0 18             	add    $0x18,%eax
c01063bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c01063be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01063c2:	74 06                	je     c01063ca <_fifo_map_swappable+0x24>
c01063c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01063c8:	75 16                	jne    c01063e0 <_fifo_map_swappable+0x3a>
c01063ca:	68 84 bd 10 c0       	push   $0xc010bd84
c01063cf:	68 a2 bd 10 c0       	push   $0xc010bda2
c01063d4:	6a 32                	push   $0x32
c01063d6:	68 b7 bd 10 c0       	push   $0xc010bdb7
c01063db:	e8 88 b3 ff ff       	call   c0101768 <__panic>
c01063e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01063e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01063e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01063e9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01063ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01063ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01063f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01063f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01063f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01063fb:	8b 40 04             	mov    0x4(%eax),%eax
c01063fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106401:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0106404:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106407:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010640a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010640d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106410:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106413:	89 10                	mov    %edx,(%eax)
c0106415:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106418:	8b 10                	mov    (%eax),%edx
c010641a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010641d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106420:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106423:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106426:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106429:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010642c:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010642f:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c0106431:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106436:	c9                   	leave  
c0106437:	c3                   	ret    

c0106438 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0106438:	55                   	push   %ebp
c0106439:	89 e5                	mov    %esp,%ebp
c010643b:	83 ec 28             	sub    $0x28,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c010643e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106441:	8b 40 14             	mov    0x14(%eax),%eax
c0106444:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0106447:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010644b:	75 16                	jne    c0106463 <_fifo_swap_out_victim+0x2b>
c010644d:	68 cb bd 10 c0       	push   $0xc010bdcb
c0106452:	68 a2 bd 10 c0       	push   $0xc010bda2
c0106457:	6a 41                	push   $0x41
c0106459:	68 b7 bd 10 c0       	push   $0xc010bdb7
c010645e:	e8 05 b3 ff ff       	call   c0101768 <__panic>
     assert(in_tick==0);
c0106463:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106467:	74 16                	je     c010647f <_fifo_swap_out_victim+0x47>
c0106469:	68 d8 bd 10 c0       	push   $0xc010bdd8
c010646e:	68 a2 bd 10 c0       	push   $0xc010bda2
c0106473:	6a 42                	push   $0x42
c0106475:	68 b7 bd 10 c0       	push   $0xc010bdb7
c010647a:	e8 e9 b2 ff ff       	call   c0101768 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     /* Select the tail */
     list_entry_t *le = head->prev;
c010647f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106482:	8b 00                	mov    (%eax),%eax
c0106484:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c0106487:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010648a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010648d:	75 16                	jne    c01064a5 <_fifo_swap_out_victim+0x6d>
c010648f:	68 e3 bd 10 c0       	push   $0xc010bde3
c0106494:	68 a2 bd 10 c0       	push   $0xc010bda2
c0106499:	6a 49                	push   $0x49
c010649b:	68 b7 bd 10 c0       	push   $0xc010bdb7
c01064a0:	e8 c3 b2 ff ff       	call   c0101768 <__panic>
     struct Page *p = le2page(le, pra_page_link);
c01064a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01064a8:	83 e8 18             	sub    $0x18,%eax
c01064ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01064ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01064b1:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01064b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01064b7:	8b 40 04             	mov    0x4(%eax),%eax
c01064ba:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01064bd:	8b 12                	mov    (%edx),%edx
c01064bf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01064c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01064c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01064c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01064cb:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01064ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01064d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01064d4:	89 10                	mov    %edx,(%eax)
     list_del(le);
     assert(p !=NULL);
c01064d6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01064da:	75 16                	jne    c01064f2 <_fifo_swap_out_victim+0xba>
c01064dc:	68 ec bd 10 c0       	push   $0xc010bdec
c01064e1:	68 a2 bd 10 c0       	push   $0xc010bda2
c01064e6:	6a 4c                	push   $0x4c
c01064e8:	68 b7 bd 10 c0       	push   $0xc010bdb7
c01064ed:	e8 76 b2 ff ff       	call   c0101768 <__panic>
     *ptr_page = p;
c01064f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01064f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01064f8:	89 10                	mov    %edx,(%eax)
     return 0;
c01064fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01064ff:	c9                   	leave  
c0106500:	c3                   	ret    

c0106501 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0106501:	55                   	push   %ebp
c0106502:	89 e5                	mov    %esp,%ebp
c0106504:	83 ec 08             	sub    $0x8,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0106507:	83 ec 0c             	sub    $0xc,%esp
c010650a:	68 f8 bd 10 c0       	push   $0xc010bdf8
c010650f:	e8 76 9d ff ff       	call   c010028a <cprintf>
c0106514:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x3000 = 0x0c;
c0106517:	b8 00 30 00 00       	mov    $0x3000,%eax
c010651c:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c010651f:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c0106524:	83 f8 04             	cmp    $0x4,%eax
c0106527:	74 16                	je     c010653f <_fifo_check_swap+0x3e>
c0106529:	68 1e be 10 c0       	push   $0xc010be1e
c010652e:	68 a2 bd 10 c0       	push   $0xc010bda2
c0106533:	6a 55                	push   $0x55
c0106535:	68 b7 bd 10 c0       	push   $0xc010bdb7
c010653a:	e8 29 b2 ff ff       	call   c0101768 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c010653f:	83 ec 0c             	sub    $0xc,%esp
c0106542:	68 30 be 10 c0       	push   $0xc010be30
c0106547:	e8 3e 9d ff ff       	call   c010028a <cprintf>
c010654c:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x1000 = 0x0a;
c010654f:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106554:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0106557:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c010655c:	83 f8 04             	cmp    $0x4,%eax
c010655f:	74 16                	je     c0106577 <_fifo_check_swap+0x76>
c0106561:	68 1e be 10 c0       	push   $0xc010be1e
c0106566:	68 a2 bd 10 c0       	push   $0xc010bda2
c010656b:	6a 58                	push   $0x58
c010656d:	68 b7 bd 10 c0       	push   $0xc010bdb7
c0106572:	e8 f1 b1 ff ff       	call   c0101768 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0106577:	83 ec 0c             	sub    $0xc,%esp
c010657a:	68 58 be 10 c0       	push   $0xc010be58
c010657f:	e8 06 9d ff ff       	call   c010028a <cprintf>
c0106584:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x4000 = 0x0d;
c0106587:	b8 00 40 00 00       	mov    $0x4000,%eax
c010658c:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c010658f:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c0106594:	83 f8 04             	cmp    $0x4,%eax
c0106597:	74 16                	je     c01065af <_fifo_check_swap+0xae>
c0106599:	68 1e be 10 c0       	push   $0xc010be1e
c010659e:	68 a2 bd 10 c0       	push   $0xc010bda2
c01065a3:	6a 5b                	push   $0x5b
c01065a5:	68 b7 bd 10 c0       	push   $0xc010bdb7
c01065aa:	e8 b9 b1 ff ff       	call   c0101768 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c01065af:	83 ec 0c             	sub    $0xc,%esp
c01065b2:	68 80 be 10 c0       	push   $0xc010be80
c01065b7:	e8 ce 9c ff ff       	call   c010028a <cprintf>
c01065bc:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c01065bf:	b8 00 20 00 00       	mov    $0x2000,%eax
c01065c4:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c01065c7:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c01065cc:	83 f8 04             	cmp    $0x4,%eax
c01065cf:	74 16                	je     c01065e7 <_fifo_check_swap+0xe6>
c01065d1:	68 1e be 10 c0       	push   $0xc010be1e
c01065d6:	68 a2 bd 10 c0       	push   $0xc010bda2
c01065db:	6a 5e                	push   $0x5e
c01065dd:	68 b7 bd 10 c0       	push   $0xc010bdb7
c01065e2:	e8 81 b1 ff ff       	call   c0101768 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01065e7:	83 ec 0c             	sub    $0xc,%esp
c01065ea:	68 a8 be 10 c0       	push   $0xc010bea8
c01065ef:	e8 96 9c ff ff       	call   c010028a <cprintf>
c01065f4:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x5000 = 0x0e;
c01065f7:	b8 00 50 00 00       	mov    $0x5000,%eax
c01065fc:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c01065ff:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c0106604:	83 f8 05             	cmp    $0x5,%eax
c0106607:	74 16                	je     c010661f <_fifo_check_swap+0x11e>
c0106609:	68 ce be 10 c0       	push   $0xc010bece
c010660e:	68 a2 bd 10 c0       	push   $0xc010bda2
c0106613:	6a 61                	push   $0x61
c0106615:	68 b7 bd 10 c0       	push   $0xc010bdb7
c010661a:	e8 49 b1 ff ff       	call   c0101768 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010661f:	83 ec 0c             	sub    $0xc,%esp
c0106622:	68 80 be 10 c0       	push   $0xc010be80
c0106627:	e8 5e 9c ff ff       	call   c010028a <cprintf>
c010662c:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c010662f:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106634:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0106637:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c010663c:	83 f8 05             	cmp    $0x5,%eax
c010663f:	74 16                	je     c0106657 <_fifo_check_swap+0x156>
c0106641:	68 ce be 10 c0       	push   $0xc010bece
c0106646:	68 a2 bd 10 c0       	push   $0xc010bda2
c010664b:	6a 64                	push   $0x64
c010664d:	68 b7 bd 10 c0       	push   $0xc010bdb7
c0106652:	e8 11 b1 ff ff       	call   c0101768 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0106657:	83 ec 0c             	sub    $0xc,%esp
c010665a:	68 30 be 10 c0       	push   $0xc010be30
c010665f:	e8 26 9c ff ff       	call   c010028a <cprintf>
c0106664:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x1000 = 0x0a;
c0106667:	b8 00 10 00 00       	mov    $0x1000,%eax
c010666c:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c010666f:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c0106674:	83 f8 06             	cmp    $0x6,%eax
c0106677:	74 16                	je     c010668f <_fifo_check_swap+0x18e>
c0106679:	68 dd be 10 c0       	push   $0xc010bedd
c010667e:	68 a2 bd 10 c0       	push   $0xc010bda2
c0106683:	6a 67                	push   $0x67
c0106685:	68 b7 bd 10 c0       	push   $0xc010bdb7
c010668a:	e8 d9 b0 ff ff       	call   c0101768 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010668f:	83 ec 0c             	sub    $0xc,%esp
c0106692:	68 80 be 10 c0       	push   $0xc010be80
c0106697:	e8 ee 9b ff ff       	call   c010028a <cprintf>
c010669c:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c010669f:	b8 00 20 00 00       	mov    $0x2000,%eax
c01066a4:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c01066a7:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c01066ac:	83 f8 07             	cmp    $0x7,%eax
c01066af:	74 16                	je     c01066c7 <_fifo_check_swap+0x1c6>
c01066b1:	68 ec be 10 c0       	push   $0xc010beec
c01066b6:	68 a2 bd 10 c0       	push   $0xc010bda2
c01066bb:	6a 6a                	push   $0x6a
c01066bd:	68 b7 bd 10 c0       	push   $0xc010bdb7
c01066c2:	e8 a1 b0 ff ff       	call   c0101768 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c01066c7:	83 ec 0c             	sub    $0xc,%esp
c01066ca:	68 f8 bd 10 c0       	push   $0xc010bdf8
c01066cf:	e8 b6 9b ff ff       	call   c010028a <cprintf>
c01066d4:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x3000 = 0x0c;
c01066d7:	b8 00 30 00 00       	mov    $0x3000,%eax
c01066dc:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c01066df:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c01066e4:	83 f8 08             	cmp    $0x8,%eax
c01066e7:	74 16                	je     c01066ff <_fifo_check_swap+0x1fe>
c01066e9:	68 fb be 10 c0       	push   $0xc010befb
c01066ee:	68 a2 bd 10 c0       	push   $0xc010bda2
c01066f3:	6a 6d                	push   $0x6d
c01066f5:	68 b7 bd 10 c0       	push   $0xc010bdb7
c01066fa:	e8 69 b0 ff ff       	call   c0101768 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01066ff:	83 ec 0c             	sub    $0xc,%esp
c0106702:	68 58 be 10 c0       	push   $0xc010be58
c0106707:	e8 7e 9b ff ff       	call   c010028a <cprintf>
c010670c:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x4000 = 0x0d;
c010670f:	b8 00 40 00 00       	mov    $0x4000,%eax
c0106714:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0106717:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c010671c:	83 f8 09             	cmp    $0x9,%eax
c010671f:	74 16                	je     c0106737 <_fifo_check_swap+0x236>
c0106721:	68 0a bf 10 c0       	push   $0xc010bf0a
c0106726:	68 a2 bd 10 c0       	push   $0xc010bda2
c010672b:	6a 70                	push   $0x70
c010672d:	68 b7 bd 10 c0       	push   $0xc010bdb7
c0106732:	e8 31 b0 ff ff       	call   c0101768 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0106737:	83 ec 0c             	sub    $0xc,%esp
c010673a:	68 a8 be 10 c0       	push   $0xc010bea8
c010673f:	e8 46 9b ff ff       	call   c010028a <cprintf>
c0106744:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x5000 = 0x0e;
c0106747:	b8 00 50 00 00       	mov    $0x5000,%eax
c010674c:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c010674f:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c0106754:	83 f8 0a             	cmp    $0xa,%eax
c0106757:	74 16                	je     c010676f <_fifo_check_swap+0x26e>
c0106759:	68 19 bf 10 c0       	push   $0xc010bf19
c010675e:	68 a2 bd 10 c0       	push   $0xc010bda2
c0106763:	6a 73                	push   $0x73
c0106765:	68 b7 bd 10 c0       	push   $0xc010bdb7
c010676a:	e8 f9 af ff ff       	call   c0101768 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c010676f:	83 ec 0c             	sub    $0xc,%esp
c0106772:	68 30 be 10 c0       	push   $0xc010be30
c0106777:	e8 0e 9b ff ff       	call   c010028a <cprintf>
c010677c:	83 c4 10             	add    $0x10,%esp
    assert(*(unsigned char *)0x1000 == 0x0a);
c010677f:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106784:	0f b6 00             	movzbl (%eax),%eax
c0106787:	3c 0a                	cmp    $0xa,%al
c0106789:	74 16                	je     c01067a1 <_fifo_check_swap+0x2a0>
c010678b:	68 2c bf 10 c0       	push   $0xc010bf2c
c0106790:	68 a2 bd 10 c0       	push   $0xc010bda2
c0106795:	6a 75                	push   $0x75
c0106797:	68 b7 bd 10 c0       	push   $0xc010bdb7
c010679c:	e8 c7 af ff ff       	call   c0101768 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c01067a1:	b8 00 10 00 00       	mov    $0x1000,%eax
c01067a6:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c01067a9:	a1 64 af 12 c0       	mov    0xc012af64,%eax
c01067ae:	83 f8 0b             	cmp    $0xb,%eax
c01067b1:	74 16                	je     c01067c9 <_fifo_check_swap+0x2c8>
c01067b3:	68 4d bf 10 c0       	push   $0xc010bf4d
c01067b8:	68 a2 bd 10 c0       	push   $0xc010bda2
c01067bd:	6a 77                	push   $0x77
c01067bf:	68 b7 bd 10 c0       	push   $0xc010bdb7
c01067c4:	e8 9f af ff ff       	call   c0101768 <__panic>
    return 0;
c01067c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01067ce:	c9                   	leave  
c01067cf:	c3                   	ret    

c01067d0 <_fifo_init>:


static int
_fifo_init(void)
{
c01067d0:	55                   	push   %ebp
c01067d1:	89 e5                	mov    %esp,%ebp
    return 0;
c01067d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01067d8:	5d                   	pop    %ebp
c01067d9:	c3                   	ret    

c01067da <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01067da:	55                   	push   %ebp
c01067db:	89 e5                	mov    %esp,%ebp
    return 0;
c01067dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01067e2:	5d                   	pop    %ebp
c01067e3:	c3                   	ret    

c01067e4 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c01067e4:	55                   	push   %ebp
c01067e5:	89 e5                	mov    %esp,%ebp
c01067e7:	b8 00 00 00 00       	mov    $0x0,%eax
c01067ec:	5d                   	pop    %ebp
c01067ed:	c3                   	ret    

c01067ee <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01067ee:	55                   	push   %ebp
c01067ef:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01067f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01067f4:	8b 15 40 d1 12 c0    	mov    0xc012d140,%edx
c01067fa:	29 d0                	sub    %edx,%eax
c01067fc:	c1 f8 02             	sar    $0x2,%eax
c01067ff:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0106805:	5d                   	pop    %ebp
c0106806:	c3                   	ret    

c0106807 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0106807:	55                   	push   %ebp
c0106808:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c010680a:	ff 75 08             	pushl  0x8(%ebp)
c010680d:	e8 dc ff ff ff       	call   c01067ee <page2ppn>
c0106812:	83 c4 04             	add    $0x4,%esp
c0106815:	c1 e0 0c             	shl    $0xc,%eax
}
c0106818:	c9                   	leave  
c0106819:	c3                   	ret    

c010681a <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c010681a:	55                   	push   %ebp
c010681b:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010681d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106820:	8b 00                	mov    (%eax),%eax
}
c0106822:	5d                   	pop    %ebp
c0106823:	c3                   	ret    

c0106824 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0106824:	55                   	push   %ebp
c0106825:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0106827:	8b 45 08             	mov    0x8(%ebp),%eax
c010682a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010682d:	89 10                	mov    %edx,(%eax)
}
c010682f:	90                   	nop
c0106830:	5d                   	pop    %ebp
c0106831:	c3                   	ret    

c0106832 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0106832:	55                   	push   %ebp
c0106833:	89 e5                	mov    %esp,%ebp
c0106835:	83 ec 10             	sub    $0x10,%esp
c0106838:	c7 45 fc 2c d1 12 c0 	movl   $0xc012d12c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010683f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106842:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0106845:	89 50 04             	mov    %edx,0x4(%eax)
c0106848:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010684b:	8b 50 04             	mov    0x4(%eax),%edx
c010684e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106851:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0106853:	c7 05 34 d1 12 c0 00 	movl   $0x0,0xc012d134
c010685a:	00 00 00 
}
c010685d:	90                   	nop
c010685e:	c9                   	leave  
c010685f:	c3                   	ret    

c0106860 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0106860:	55                   	push   %ebp
c0106861:	89 e5                	mov    %esp,%ebp
c0106863:	83 ec 38             	sub    $0x38,%esp
    assert(n > 0);
c0106866:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010686a:	75 16                	jne    c0106882 <default_init_memmap+0x22>
c010686c:	68 70 bf 10 c0       	push   $0xc010bf70
c0106871:	68 76 bf 10 c0       	push   $0xc010bf76
c0106876:	6a 6d                	push   $0x6d
c0106878:	68 8b bf 10 c0       	push   $0xc010bf8b
c010687d:	e8 e6 ae ff ff       	call   c0101768 <__panic>
    struct Page *p = base;
c0106882:	8b 45 08             	mov    0x8(%ebp),%eax
c0106885:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0106888:	eb 6c                	jmp    c01068f6 <default_init_memmap+0x96>
        assert(PageReserved(p));
c010688a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010688d:	83 c0 04             	add    $0x4,%eax
c0106890:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0106897:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010689a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010689d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01068a0:	0f a3 10             	bt     %edx,(%eax)
c01068a3:	19 c0                	sbb    %eax,%eax
c01068a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c01068a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01068ac:	0f 95 c0             	setne  %al
c01068af:	0f b6 c0             	movzbl %al,%eax
c01068b2:	85 c0                	test   %eax,%eax
c01068b4:	75 16                	jne    c01068cc <default_init_memmap+0x6c>
c01068b6:	68 a1 bf 10 c0       	push   $0xc010bfa1
c01068bb:	68 76 bf 10 c0       	push   $0xc010bf76
c01068c0:	6a 70                	push   $0x70
c01068c2:	68 8b bf 10 c0       	push   $0xc010bf8b
c01068c7:	e8 9c ae ff ff       	call   c0101768 <__panic>
        p->flags = p->property = 0;
c01068cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01068cf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01068d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01068d9:	8b 50 08             	mov    0x8(%eax),%edx
c01068dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01068df:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c01068e2:	83 ec 08             	sub    $0x8,%esp
c01068e5:	6a 00                	push   $0x0
c01068e7:	ff 75 f4             	pushl  -0xc(%ebp)
c01068ea:	e8 35 ff ff ff       	call   c0106824 <set_page_ref>
c01068ef:	83 c4 10             	add    $0x10,%esp

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c01068f2:	83 45 f4 24          	addl   $0x24,-0xc(%ebp)
c01068f6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01068f9:	89 d0                	mov    %edx,%eax
c01068fb:	c1 e0 03             	shl    $0x3,%eax
c01068fe:	01 d0                	add    %edx,%eax
c0106900:	c1 e0 02             	shl    $0x2,%eax
c0106903:	89 c2                	mov    %eax,%edx
c0106905:	8b 45 08             	mov    0x8(%ebp),%eax
c0106908:	01 d0                	add    %edx,%eax
c010690a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010690d:	0f 85 77 ff ff ff    	jne    c010688a <default_init_memmap+0x2a>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0106913:	8b 45 08             	mov    0x8(%ebp),%eax
c0106916:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106919:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010691c:	8b 45 08             	mov    0x8(%ebp),%eax
c010691f:	83 c0 04             	add    $0x4,%eax
c0106922:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c0106929:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010692c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010692f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106932:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0106935:	8b 15 34 d1 12 c0    	mov    0xc012d134,%edx
c010693b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010693e:	01 d0                	add    %edx,%eax
c0106940:	a3 34 d1 12 c0       	mov    %eax,0xc012d134
    list_add_before(&free_list, &(base->page_link));
c0106945:	8b 45 08             	mov    0x8(%ebp),%eax
c0106948:	83 c0 10             	add    $0x10,%eax
c010694b:	c7 45 f0 2c d1 12 c0 	movl   $0xc012d12c,-0x10(%ebp)
c0106952:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0106955:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106958:	8b 00                	mov    (%eax),%eax
c010695a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010695d:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0106960:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0106963:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106966:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0106969:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010696c:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010696f:	89 10                	mov    %edx,(%eax)
c0106971:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106974:	8b 10                	mov    (%eax),%edx
c0106976:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106979:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010697c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010697f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0106982:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106985:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106988:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010698b:	89 10                	mov    %edx,(%eax)
}
c010698d:	90                   	nop
c010698e:	c9                   	leave  
c010698f:	c3                   	ret    

c0106990 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0106990:	55                   	push   %ebp
c0106991:	89 e5                	mov    %esp,%ebp
c0106993:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c0106996:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010699a:	75 16                	jne    c01069b2 <default_alloc_pages+0x22>
c010699c:	68 70 bf 10 c0       	push   $0xc010bf70
c01069a1:	68 76 bf 10 c0       	push   $0xc010bf76
c01069a6:	6a 7c                	push   $0x7c
c01069a8:	68 8b bf 10 c0       	push   $0xc010bf8b
c01069ad:	e8 b6 ad ff ff       	call   c0101768 <__panic>
    if (n > nr_free) {
c01069b2:	a1 34 d1 12 c0       	mov    0xc012d134,%eax
c01069b7:	3b 45 08             	cmp    0x8(%ebp),%eax
c01069ba:	73 0a                	jae    c01069c6 <default_alloc_pages+0x36>
        return NULL;
c01069bc:	b8 00 00 00 00       	mov    $0x0,%eax
c01069c1:	e9 3d 01 00 00       	jmp    c0106b03 <default_alloc_pages+0x173>
    }
    struct Page *page = NULL;
c01069c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c01069cd:	c7 45 f0 2c d1 12 c0 	movl   $0xc012d12c,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c01069d4:	eb 1c                	jmp    c01069f2 <default_alloc_pages+0x62>
        struct Page *p = le2page(le, page_link);
c01069d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069d9:	83 e8 10             	sub    $0x10,%eax
c01069dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
c01069df:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01069e2:	8b 40 08             	mov    0x8(%eax),%eax
c01069e5:	3b 45 08             	cmp    0x8(%ebp),%eax
c01069e8:	72 08                	jb     c01069f2 <default_alloc_pages+0x62>
            page = p;
c01069ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01069ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c01069f0:	eb 18                	jmp    c0106a0a <default_alloc_pages+0x7a>
c01069f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01069f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01069fb:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c01069fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106a01:	81 7d f0 2c d1 12 c0 	cmpl   $0xc012d12c,-0x10(%ebp)
c0106a08:	75 cc                	jne    c01069d6 <default_alloc_pages+0x46>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c0106a0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106a0e:	0f 84 ec 00 00 00    	je     c0106b00 <default_alloc_pages+0x170>
        if (page->property > n) {
c0106a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a17:	8b 40 08             	mov    0x8(%eax),%eax
c0106a1a:	3b 45 08             	cmp    0x8(%ebp),%eax
c0106a1d:	0f 86 8c 00 00 00    	jbe    c0106aaf <default_alloc_pages+0x11f>
            struct Page *p = page + n;
c0106a23:	8b 55 08             	mov    0x8(%ebp),%edx
c0106a26:	89 d0                	mov    %edx,%eax
c0106a28:	c1 e0 03             	shl    $0x3,%eax
c0106a2b:	01 d0                	add    %edx,%eax
c0106a2d:	c1 e0 02             	shl    $0x2,%eax
c0106a30:	89 c2                	mov    %eax,%edx
c0106a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a35:	01 d0                	add    %edx,%eax
c0106a37:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            p->property = page->property - n;
c0106a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a3d:	8b 40 08             	mov    0x8(%eax),%eax
c0106a40:	2b 45 08             	sub    0x8(%ebp),%eax
c0106a43:	89 c2                	mov    %eax,%edx
c0106a45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a48:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0106a4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a4e:	83 c0 04             	add    $0x4,%eax
c0106a51:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c0106a58:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0106a5b:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106a5e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106a61:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c0106a64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a67:	83 c0 10             	add    $0x10,%eax
c0106a6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106a6d:	83 c2 10             	add    $0x10,%edx
c0106a70:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0106a73:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0106a76:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a79:	8b 40 04             	mov    0x4(%eax),%eax
c0106a7c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0106a7f:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0106a82:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106a85:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0106a88:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0106a8b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106a8e:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106a91:	89 10                	mov    %edx,(%eax)
c0106a93:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106a96:	8b 10                	mov    (%eax),%edx
c0106a98:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106a9b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106a9e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106aa1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106aa4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106aa7:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106aaa:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0106aad:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
c0106aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ab2:	83 c0 10             	add    $0x10,%eax
c0106ab5:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0106ab8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106abb:	8b 40 04             	mov    0x4(%eax),%eax
c0106abe:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106ac1:	8b 12                	mov    (%edx),%edx
c0106ac3:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0106ac6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0106ac9:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106acc:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106acf:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106ad2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106ad5:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0106ad8:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c0106ada:	a1 34 d1 12 c0       	mov    0xc012d134,%eax
c0106adf:	2b 45 08             	sub    0x8(%ebp),%eax
c0106ae2:	a3 34 d1 12 c0       	mov    %eax,0xc012d134
        ClearPageProperty(page);
c0106ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106aea:	83 c0 04             	add    $0x4,%eax
c0106aed:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0106af4:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106af7:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106afa:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106afd:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0106b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106b03:	c9                   	leave  
c0106b04:	c3                   	ret    

c0106b05 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0106b05:	55                   	push   %ebp
c0106b06:	89 e5                	mov    %esp,%ebp
c0106b08:	81 ec 88 00 00 00    	sub    $0x88,%esp
    assert(n > 0);
c0106b0e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106b12:	75 19                	jne    c0106b2d <default_free_pages+0x28>
c0106b14:	68 70 bf 10 c0       	push   $0xc010bf70
c0106b19:	68 76 bf 10 c0       	push   $0xc010bf76
c0106b1e:	68 9a 00 00 00       	push   $0x9a
c0106b23:	68 8b bf 10 c0       	push   $0xc010bf8b
c0106b28:	e8 3b ac ff ff       	call   c0101768 <__panic>
    struct Page *p = base;
c0106b2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b30:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0106b33:	e9 8f 00 00 00       	jmp    c0106bc7 <default_free_pages+0xc2>
        assert(!PageReserved(p) && !PageProperty(p));
c0106b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b3b:	83 c0 04             	add    $0x4,%eax
c0106b3e:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
c0106b45:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106b48:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106b4b:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0106b4e:	0f a3 10             	bt     %edx,(%eax)
c0106b51:	19 c0                	sbb    %eax,%eax
c0106b53:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0106b56:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0106b5a:	0f 95 c0             	setne  %al
c0106b5d:	0f b6 c0             	movzbl %al,%eax
c0106b60:	85 c0                	test   %eax,%eax
c0106b62:	75 2c                	jne    c0106b90 <default_free_pages+0x8b>
c0106b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b67:	83 c0 04             	add    $0x4,%eax
c0106b6a:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c0106b71:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106b74:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106b77:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106b7a:	0f a3 10             	bt     %edx,(%eax)
c0106b7d:	19 c0                	sbb    %eax,%eax
c0106b7f:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return oldbit != 0;
c0106b82:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
c0106b86:	0f 95 c0             	setne  %al
c0106b89:	0f b6 c0             	movzbl %al,%eax
c0106b8c:	85 c0                	test   %eax,%eax
c0106b8e:	74 19                	je     c0106ba9 <default_free_pages+0xa4>
c0106b90:	68 b4 bf 10 c0       	push   $0xc010bfb4
c0106b95:	68 76 bf 10 c0       	push   $0xc010bf76
c0106b9a:	68 9d 00 00 00       	push   $0x9d
c0106b9f:	68 8b bf 10 c0       	push   $0xc010bf8b
c0106ba4:	e8 bf ab ff ff       	call   c0101768 <__panic>
        p->flags = 0;
c0106ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106bac:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0106bb3:	83 ec 08             	sub    $0x8,%esp
c0106bb6:	6a 00                	push   $0x0
c0106bb8:	ff 75 f4             	pushl  -0xc(%ebp)
c0106bbb:	e8 64 fc ff ff       	call   c0106824 <set_page_ref>
c0106bc0:	83 c4 10             	add    $0x10,%esp

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0106bc3:	83 45 f4 24          	addl   $0x24,-0xc(%ebp)
c0106bc7:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106bca:	89 d0                	mov    %edx,%eax
c0106bcc:	c1 e0 03             	shl    $0x3,%eax
c0106bcf:	01 d0                	add    %edx,%eax
c0106bd1:	c1 e0 02             	shl    $0x2,%eax
c0106bd4:	89 c2                	mov    %eax,%edx
c0106bd6:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bd9:	01 d0                	add    %edx,%eax
c0106bdb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106bde:	0f 85 54 ff ff ff    	jne    c0106b38 <default_free_pages+0x33>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0106be4:	8b 45 08             	mov    0x8(%ebp),%eax
c0106be7:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106bea:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0106bed:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bf0:	83 c0 04             	add    $0x4,%eax
c0106bf3:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0106bfa:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106bfd:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0106c00:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106c03:	0f ab 10             	bts    %edx,(%eax)
c0106c06:	c7 45 e8 2c d1 12 c0 	movl   $0xc012d12c,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0106c0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106c10:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0106c13:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0106c16:	e9 08 01 00 00       	jmp    c0106d23 <default_free_pages+0x21e>
        p = le2page(le, page_link);
c0106c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c1e:	83 e8 10             	sub    $0x10,%eax
c0106c21:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106c24:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c27:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106c2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106c2d:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0106c30:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c0106c33:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c36:	8b 50 08             	mov    0x8(%eax),%edx
c0106c39:	89 d0                	mov    %edx,%eax
c0106c3b:	c1 e0 03             	shl    $0x3,%eax
c0106c3e:	01 d0                	add    %edx,%eax
c0106c40:	c1 e0 02             	shl    $0x2,%eax
c0106c43:	89 c2                	mov    %eax,%edx
c0106c45:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c48:	01 d0                	add    %edx,%eax
c0106c4a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106c4d:	75 5a                	jne    c0106ca9 <default_free_pages+0x1a4>
            base->property += p->property;
c0106c4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c52:	8b 50 08             	mov    0x8(%eax),%edx
c0106c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c58:	8b 40 08             	mov    0x8(%eax),%eax
c0106c5b:	01 c2                	add    %eax,%edx
c0106c5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c60:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0106c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c66:	83 c0 04             	add    $0x4,%eax
c0106c69:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0106c70:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106c73:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106c76:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106c79:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0106c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c7f:	83 c0 10             	add    $0x10,%eax
c0106c82:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0106c85:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106c88:	8b 40 04             	mov    0x4(%eax),%eax
c0106c8b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106c8e:	8b 12                	mov    (%edx),%edx
c0106c90:	89 55 a8             	mov    %edx,-0x58(%ebp)
c0106c93:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0106c96:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106c99:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0106c9c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106c9f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106ca2:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0106ca5:	89 10                	mov    %edx,(%eax)
c0106ca7:	eb 7a                	jmp    c0106d23 <default_free_pages+0x21e>
        }
        else if (p + p->property == base) {
c0106ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cac:	8b 50 08             	mov    0x8(%eax),%edx
c0106caf:	89 d0                	mov    %edx,%eax
c0106cb1:	c1 e0 03             	shl    $0x3,%eax
c0106cb4:	01 d0                	add    %edx,%eax
c0106cb6:	c1 e0 02             	shl    $0x2,%eax
c0106cb9:	89 c2                	mov    %eax,%edx
c0106cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cbe:	01 d0                	add    %edx,%eax
c0106cc0:	3b 45 08             	cmp    0x8(%ebp),%eax
c0106cc3:	75 5e                	jne    c0106d23 <default_free_pages+0x21e>
            p->property += base->property;
c0106cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cc8:	8b 50 08             	mov    0x8(%eax),%edx
c0106ccb:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cce:	8b 40 08             	mov    0x8(%eax),%eax
c0106cd1:	01 c2                	add    %eax,%edx
c0106cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cd6:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0106cd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cdc:	83 c0 04             	add    $0x4,%eax
c0106cdf:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0106ce6:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0106ce9:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0106cec:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106cef:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0106cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cf5:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0106cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cfb:	83 c0 10             	add    $0x10,%eax
c0106cfe:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0106d01:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106d04:	8b 40 04             	mov    0x4(%eax),%eax
c0106d07:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106d0a:	8b 12                	mov    (%edx),%edx
c0106d0c:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0106d0f:	89 45 98             	mov    %eax,-0x68(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0106d12:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0106d15:	8b 55 98             	mov    -0x68(%ebp),%edx
c0106d18:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106d1b:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106d1e:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0106d21:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c0106d23:	81 7d f0 2c d1 12 c0 	cmpl   $0xc012d12c,-0x10(%ebp)
c0106d2a:	0f 85 eb fe ff ff    	jne    c0106c1b <default_free_pages+0x116>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c0106d30:	8b 15 34 d1 12 c0    	mov    0xc012d134,%edx
c0106d36:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d39:	01 d0                	add    %edx,%eax
c0106d3b:	a3 34 d1 12 c0       	mov    %eax,0xc012d134
c0106d40:	c7 45 d0 2c d1 12 c0 	movl   $0xc012d12c,-0x30(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0106d47:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106d4a:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c0106d4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0106d50:	eb 69                	jmp    c0106dbb <default_free_pages+0x2b6>
        p = le2page(le, page_link);
c0106d52:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106d55:	83 e8 10             	sub    $0x10,%eax
c0106d58:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0106d5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d5e:	8b 50 08             	mov    0x8(%eax),%edx
c0106d61:	89 d0                	mov    %edx,%eax
c0106d63:	c1 e0 03             	shl    $0x3,%eax
c0106d66:	01 d0                	add    %edx,%eax
c0106d68:	c1 e0 02             	shl    $0x2,%eax
c0106d6b:	89 c2                	mov    %eax,%edx
c0106d6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d70:	01 d0                	add    %edx,%eax
c0106d72:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106d75:	77 35                	ja     c0106dac <default_free_pages+0x2a7>
            assert(base + base->property != p);
c0106d77:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d7a:	8b 50 08             	mov    0x8(%eax),%edx
c0106d7d:	89 d0                	mov    %edx,%eax
c0106d7f:	c1 e0 03             	shl    $0x3,%eax
c0106d82:	01 d0                	add    %edx,%eax
c0106d84:	c1 e0 02             	shl    $0x2,%eax
c0106d87:	89 c2                	mov    %eax,%edx
c0106d89:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d8c:	01 d0                	add    %edx,%eax
c0106d8e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106d91:	75 33                	jne    c0106dc6 <default_free_pages+0x2c1>
c0106d93:	68 d9 bf 10 c0       	push   $0xc010bfd9
c0106d98:	68 76 bf 10 c0       	push   $0xc010bf76
c0106d9d:	68 b9 00 00 00       	push   $0xb9
c0106da2:	68 8b bf 10 c0       	push   $0xc010bf8b
c0106da7:	e8 bc a9 ff ff       	call   c0101768 <__panic>
c0106dac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106daf:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0106db2:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106db5:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c0106db8:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
c0106dbb:	81 7d f0 2c d1 12 c0 	cmpl   $0xc012d12c,-0x10(%ebp)
c0106dc2:	75 8e                	jne    c0106d52 <default_free_pages+0x24d>
c0106dc4:	eb 01                	jmp    c0106dc7 <default_free_pages+0x2c2>
        p = le2page(le, page_link);
        if (base + base->property <= p) {
            assert(base + base->property != p);
            break;
c0106dc6:	90                   	nop
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
c0106dc7:	8b 45 08             	mov    0x8(%ebp),%eax
c0106dca:	8d 50 10             	lea    0x10(%eax),%edx
c0106dcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106dd0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0106dd3:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0106dd6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106dd9:	8b 00                	mov    (%eax),%eax
c0106ddb:	8b 55 90             	mov    -0x70(%ebp),%edx
c0106dde:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0106de1:	89 45 88             	mov    %eax,-0x78(%ebp)
c0106de4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106de7:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0106dea:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0106ded:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0106df0:	89 10                	mov    %edx,(%eax)
c0106df2:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0106df5:	8b 10                	mov    (%eax),%edx
c0106df7:	8b 45 88             	mov    -0x78(%ebp),%eax
c0106dfa:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106dfd:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0106e00:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0106e03:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106e06:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0106e09:	8b 55 88             	mov    -0x78(%ebp),%edx
c0106e0c:	89 10                	mov    %edx,(%eax)
}
c0106e0e:	90                   	nop
c0106e0f:	c9                   	leave  
c0106e10:	c3                   	ret    

c0106e11 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0106e11:	55                   	push   %ebp
c0106e12:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0106e14:	a1 34 d1 12 c0       	mov    0xc012d134,%eax
}
c0106e19:	5d                   	pop    %ebp
c0106e1a:	c3                   	ret    

c0106e1b <basic_check>:

static void
basic_check(void) {
c0106e1b:	55                   	push   %ebp
c0106e1c:	89 e5                	mov    %esp,%ebp
c0106e1e:	83 ec 38             	sub    $0x38,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0106e21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106e2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e31:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0106e34:	83 ec 0c             	sub    $0xc,%esp
c0106e37:	6a 01                	push   $0x1
c0106e39:	e8 d7 0c 00 00       	call   c0107b15 <alloc_pages>
c0106e3e:	83 c4 10             	add    $0x10,%esp
c0106e41:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106e44:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106e48:	75 19                	jne    c0106e63 <basic_check+0x48>
c0106e4a:	68 f4 bf 10 c0       	push   $0xc010bff4
c0106e4f:	68 76 bf 10 c0       	push   $0xc010bf76
c0106e54:	68 ca 00 00 00       	push   $0xca
c0106e59:	68 8b bf 10 c0       	push   $0xc010bf8b
c0106e5e:	e8 05 a9 ff ff       	call   c0101768 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0106e63:	83 ec 0c             	sub    $0xc,%esp
c0106e66:	6a 01                	push   $0x1
c0106e68:	e8 a8 0c 00 00       	call   c0107b15 <alloc_pages>
c0106e6d:	83 c4 10             	add    $0x10,%esp
c0106e70:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106e73:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106e77:	75 19                	jne    c0106e92 <basic_check+0x77>
c0106e79:	68 10 c0 10 c0       	push   $0xc010c010
c0106e7e:	68 76 bf 10 c0       	push   $0xc010bf76
c0106e83:	68 cb 00 00 00       	push   $0xcb
c0106e88:	68 8b bf 10 c0       	push   $0xc010bf8b
c0106e8d:	e8 d6 a8 ff ff       	call   c0101768 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0106e92:	83 ec 0c             	sub    $0xc,%esp
c0106e95:	6a 01                	push   $0x1
c0106e97:	e8 79 0c 00 00       	call   c0107b15 <alloc_pages>
c0106e9c:	83 c4 10             	add    $0x10,%esp
c0106e9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106ea2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106ea6:	75 19                	jne    c0106ec1 <basic_check+0xa6>
c0106ea8:	68 2c c0 10 c0       	push   $0xc010c02c
c0106ead:	68 76 bf 10 c0       	push   $0xc010bf76
c0106eb2:	68 cc 00 00 00       	push   $0xcc
c0106eb7:	68 8b bf 10 c0       	push   $0xc010bf8b
c0106ebc:	e8 a7 a8 ff ff       	call   c0101768 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0106ec1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ec4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0106ec7:	74 10                	je     c0106ed9 <basic_check+0xbe>
c0106ec9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ecc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106ecf:	74 08                	je     c0106ed9 <basic_check+0xbe>
c0106ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ed4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106ed7:	75 19                	jne    c0106ef2 <basic_check+0xd7>
c0106ed9:	68 48 c0 10 c0       	push   $0xc010c048
c0106ede:	68 76 bf 10 c0       	push   $0xc010bf76
c0106ee3:	68 ce 00 00 00       	push   $0xce
c0106ee8:	68 8b bf 10 c0       	push   $0xc010bf8b
c0106eed:	e8 76 a8 ff ff       	call   c0101768 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0106ef2:	83 ec 0c             	sub    $0xc,%esp
c0106ef5:	ff 75 ec             	pushl  -0x14(%ebp)
c0106ef8:	e8 1d f9 ff ff       	call   c010681a <page_ref>
c0106efd:	83 c4 10             	add    $0x10,%esp
c0106f00:	85 c0                	test   %eax,%eax
c0106f02:	75 24                	jne    c0106f28 <basic_check+0x10d>
c0106f04:	83 ec 0c             	sub    $0xc,%esp
c0106f07:	ff 75 f0             	pushl  -0x10(%ebp)
c0106f0a:	e8 0b f9 ff ff       	call   c010681a <page_ref>
c0106f0f:	83 c4 10             	add    $0x10,%esp
c0106f12:	85 c0                	test   %eax,%eax
c0106f14:	75 12                	jne    c0106f28 <basic_check+0x10d>
c0106f16:	83 ec 0c             	sub    $0xc,%esp
c0106f19:	ff 75 f4             	pushl  -0xc(%ebp)
c0106f1c:	e8 f9 f8 ff ff       	call   c010681a <page_ref>
c0106f21:	83 c4 10             	add    $0x10,%esp
c0106f24:	85 c0                	test   %eax,%eax
c0106f26:	74 19                	je     c0106f41 <basic_check+0x126>
c0106f28:	68 6c c0 10 c0       	push   $0xc010c06c
c0106f2d:	68 76 bf 10 c0       	push   $0xc010bf76
c0106f32:	68 cf 00 00 00       	push   $0xcf
c0106f37:	68 8b bf 10 c0       	push   $0xc010bf8b
c0106f3c:	e8 27 a8 ff ff       	call   c0101768 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0106f41:	83 ec 0c             	sub    $0xc,%esp
c0106f44:	ff 75 ec             	pushl  -0x14(%ebp)
c0106f47:	e8 bb f8 ff ff       	call   c0106807 <page2pa>
c0106f4c:	83 c4 10             	add    $0x10,%esp
c0106f4f:	89 c2                	mov    %eax,%edx
c0106f51:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c0106f56:	c1 e0 0c             	shl    $0xc,%eax
c0106f59:	39 c2                	cmp    %eax,%edx
c0106f5b:	72 19                	jb     c0106f76 <basic_check+0x15b>
c0106f5d:	68 a8 c0 10 c0       	push   $0xc010c0a8
c0106f62:	68 76 bf 10 c0       	push   $0xc010bf76
c0106f67:	68 d1 00 00 00       	push   $0xd1
c0106f6c:	68 8b bf 10 c0       	push   $0xc010bf8b
c0106f71:	e8 f2 a7 ff ff       	call   c0101768 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0106f76:	83 ec 0c             	sub    $0xc,%esp
c0106f79:	ff 75 f0             	pushl  -0x10(%ebp)
c0106f7c:	e8 86 f8 ff ff       	call   c0106807 <page2pa>
c0106f81:	83 c4 10             	add    $0x10,%esp
c0106f84:	89 c2                	mov    %eax,%edx
c0106f86:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c0106f8b:	c1 e0 0c             	shl    $0xc,%eax
c0106f8e:	39 c2                	cmp    %eax,%edx
c0106f90:	72 19                	jb     c0106fab <basic_check+0x190>
c0106f92:	68 c5 c0 10 c0       	push   $0xc010c0c5
c0106f97:	68 76 bf 10 c0       	push   $0xc010bf76
c0106f9c:	68 d2 00 00 00       	push   $0xd2
c0106fa1:	68 8b bf 10 c0       	push   $0xc010bf8b
c0106fa6:	e8 bd a7 ff ff       	call   c0101768 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0106fab:	83 ec 0c             	sub    $0xc,%esp
c0106fae:	ff 75 f4             	pushl  -0xc(%ebp)
c0106fb1:	e8 51 f8 ff ff       	call   c0106807 <page2pa>
c0106fb6:	83 c4 10             	add    $0x10,%esp
c0106fb9:	89 c2                	mov    %eax,%edx
c0106fbb:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c0106fc0:	c1 e0 0c             	shl    $0xc,%eax
c0106fc3:	39 c2                	cmp    %eax,%edx
c0106fc5:	72 19                	jb     c0106fe0 <basic_check+0x1c5>
c0106fc7:	68 e2 c0 10 c0       	push   $0xc010c0e2
c0106fcc:	68 76 bf 10 c0       	push   $0xc010bf76
c0106fd1:	68 d3 00 00 00       	push   $0xd3
c0106fd6:	68 8b bf 10 c0       	push   $0xc010bf8b
c0106fdb:	e8 88 a7 ff ff       	call   c0101768 <__panic>

    list_entry_t free_list_store = free_list;
c0106fe0:	a1 2c d1 12 c0       	mov    0xc012d12c,%eax
c0106fe5:	8b 15 30 d1 12 c0    	mov    0xc012d130,%edx
c0106feb:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106fee:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106ff1:	c7 45 e4 2c d1 12 c0 	movl   $0xc012d12c,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0106ff8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106ffb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106ffe:	89 50 04             	mov    %edx,0x4(%eax)
c0107001:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107004:	8b 50 04             	mov    0x4(%eax),%edx
c0107007:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010700a:	89 10                	mov    %edx,(%eax)
c010700c:	c7 45 d8 2c d1 12 c0 	movl   $0xc012d12c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0107013:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107016:	8b 40 04             	mov    0x4(%eax),%eax
c0107019:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c010701c:	0f 94 c0             	sete   %al
c010701f:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0107022:	85 c0                	test   %eax,%eax
c0107024:	75 19                	jne    c010703f <basic_check+0x224>
c0107026:	68 ff c0 10 c0       	push   $0xc010c0ff
c010702b:	68 76 bf 10 c0       	push   $0xc010bf76
c0107030:	68 d7 00 00 00       	push   $0xd7
c0107035:	68 8b bf 10 c0       	push   $0xc010bf8b
c010703a:	e8 29 a7 ff ff       	call   c0101768 <__panic>

    unsigned int nr_free_store = nr_free;
c010703f:	a1 34 d1 12 c0       	mov    0xc012d134,%eax
c0107044:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0107047:	c7 05 34 d1 12 c0 00 	movl   $0x0,0xc012d134
c010704e:	00 00 00 

    assert(alloc_page() == NULL);
c0107051:	83 ec 0c             	sub    $0xc,%esp
c0107054:	6a 01                	push   $0x1
c0107056:	e8 ba 0a 00 00       	call   c0107b15 <alloc_pages>
c010705b:	83 c4 10             	add    $0x10,%esp
c010705e:	85 c0                	test   %eax,%eax
c0107060:	74 19                	je     c010707b <basic_check+0x260>
c0107062:	68 16 c1 10 c0       	push   $0xc010c116
c0107067:	68 76 bf 10 c0       	push   $0xc010bf76
c010706c:	68 dc 00 00 00       	push   $0xdc
c0107071:	68 8b bf 10 c0       	push   $0xc010bf8b
c0107076:	e8 ed a6 ff ff       	call   c0101768 <__panic>

    free_page(p0);
c010707b:	83 ec 08             	sub    $0x8,%esp
c010707e:	6a 01                	push   $0x1
c0107080:	ff 75 ec             	pushl  -0x14(%ebp)
c0107083:	e8 f9 0a 00 00       	call   c0107b81 <free_pages>
c0107088:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c010708b:	83 ec 08             	sub    $0x8,%esp
c010708e:	6a 01                	push   $0x1
c0107090:	ff 75 f0             	pushl  -0x10(%ebp)
c0107093:	e8 e9 0a 00 00       	call   c0107b81 <free_pages>
c0107098:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c010709b:	83 ec 08             	sub    $0x8,%esp
c010709e:	6a 01                	push   $0x1
c01070a0:	ff 75 f4             	pushl  -0xc(%ebp)
c01070a3:	e8 d9 0a 00 00       	call   c0107b81 <free_pages>
c01070a8:	83 c4 10             	add    $0x10,%esp
    assert(nr_free == 3);
c01070ab:	a1 34 d1 12 c0       	mov    0xc012d134,%eax
c01070b0:	83 f8 03             	cmp    $0x3,%eax
c01070b3:	74 19                	je     c01070ce <basic_check+0x2b3>
c01070b5:	68 2b c1 10 c0       	push   $0xc010c12b
c01070ba:	68 76 bf 10 c0       	push   $0xc010bf76
c01070bf:	68 e1 00 00 00       	push   $0xe1
c01070c4:	68 8b bf 10 c0       	push   $0xc010bf8b
c01070c9:	e8 9a a6 ff ff       	call   c0101768 <__panic>

    assert((p0 = alloc_page()) != NULL);
c01070ce:	83 ec 0c             	sub    $0xc,%esp
c01070d1:	6a 01                	push   $0x1
c01070d3:	e8 3d 0a 00 00       	call   c0107b15 <alloc_pages>
c01070d8:	83 c4 10             	add    $0x10,%esp
c01070db:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01070de:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01070e2:	75 19                	jne    c01070fd <basic_check+0x2e2>
c01070e4:	68 f4 bf 10 c0       	push   $0xc010bff4
c01070e9:	68 76 bf 10 c0       	push   $0xc010bf76
c01070ee:	68 e3 00 00 00       	push   $0xe3
c01070f3:	68 8b bf 10 c0       	push   $0xc010bf8b
c01070f8:	e8 6b a6 ff ff       	call   c0101768 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01070fd:	83 ec 0c             	sub    $0xc,%esp
c0107100:	6a 01                	push   $0x1
c0107102:	e8 0e 0a 00 00       	call   c0107b15 <alloc_pages>
c0107107:	83 c4 10             	add    $0x10,%esp
c010710a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010710d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107111:	75 19                	jne    c010712c <basic_check+0x311>
c0107113:	68 10 c0 10 c0       	push   $0xc010c010
c0107118:	68 76 bf 10 c0       	push   $0xc010bf76
c010711d:	68 e4 00 00 00       	push   $0xe4
c0107122:	68 8b bf 10 c0       	push   $0xc010bf8b
c0107127:	e8 3c a6 ff ff       	call   c0101768 <__panic>
    assert((p2 = alloc_page()) != NULL);
c010712c:	83 ec 0c             	sub    $0xc,%esp
c010712f:	6a 01                	push   $0x1
c0107131:	e8 df 09 00 00       	call   c0107b15 <alloc_pages>
c0107136:	83 c4 10             	add    $0x10,%esp
c0107139:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010713c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107140:	75 19                	jne    c010715b <basic_check+0x340>
c0107142:	68 2c c0 10 c0       	push   $0xc010c02c
c0107147:	68 76 bf 10 c0       	push   $0xc010bf76
c010714c:	68 e5 00 00 00       	push   $0xe5
c0107151:	68 8b bf 10 c0       	push   $0xc010bf8b
c0107156:	e8 0d a6 ff ff       	call   c0101768 <__panic>

    assert(alloc_page() == NULL);
c010715b:	83 ec 0c             	sub    $0xc,%esp
c010715e:	6a 01                	push   $0x1
c0107160:	e8 b0 09 00 00       	call   c0107b15 <alloc_pages>
c0107165:	83 c4 10             	add    $0x10,%esp
c0107168:	85 c0                	test   %eax,%eax
c010716a:	74 19                	je     c0107185 <basic_check+0x36a>
c010716c:	68 16 c1 10 c0       	push   $0xc010c116
c0107171:	68 76 bf 10 c0       	push   $0xc010bf76
c0107176:	68 e7 00 00 00       	push   $0xe7
c010717b:	68 8b bf 10 c0       	push   $0xc010bf8b
c0107180:	e8 e3 a5 ff ff       	call   c0101768 <__panic>

    free_page(p0);
c0107185:	83 ec 08             	sub    $0x8,%esp
c0107188:	6a 01                	push   $0x1
c010718a:	ff 75 ec             	pushl  -0x14(%ebp)
c010718d:	e8 ef 09 00 00       	call   c0107b81 <free_pages>
c0107192:	83 c4 10             	add    $0x10,%esp
c0107195:	c7 45 e8 2c d1 12 c0 	movl   $0xc012d12c,-0x18(%ebp)
c010719c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010719f:	8b 40 04             	mov    0x4(%eax),%eax
c01071a2:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01071a5:	0f 94 c0             	sete   %al
c01071a8:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c01071ab:	85 c0                	test   %eax,%eax
c01071ad:	74 19                	je     c01071c8 <basic_check+0x3ad>
c01071af:	68 38 c1 10 c0       	push   $0xc010c138
c01071b4:	68 76 bf 10 c0       	push   $0xc010bf76
c01071b9:	68 ea 00 00 00       	push   $0xea
c01071be:	68 8b bf 10 c0       	push   $0xc010bf8b
c01071c3:	e8 a0 a5 ff ff       	call   c0101768 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c01071c8:	83 ec 0c             	sub    $0xc,%esp
c01071cb:	6a 01                	push   $0x1
c01071cd:	e8 43 09 00 00       	call   c0107b15 <alloc_pages>
c01071d2:	83 c4 10             	add    $0x10,%esp
c01071d5:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01071d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01071db:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01071de:	74 19                	je     c01071f9 <basic_check+0x3de>
c01071e0:	68 50 c1 10 c0       	push   $0xc010c150
c01071e5:	68 76 bf 10 c0       	push   $0xc010bf76
c01071ea:	68 ed 00 00 00       	push   $0xed
c01071ef:	68 8b bf 10 c0       	push   $0xc010bf8b
c01071f4:	e8 6f a5 ff ff       	call   c0101768 <__panic>
    assert(alloc_page() == NULL);
c01071f9:	83 ec 0c             	sub    $0xc,%esp
c01071fc:	6a 01                	push   $0x1
c01071fe:	e8 12 09 00 00       	call   c0107b15 <alloc_pages>
c0107203:	83 c4 10             	add    $0x10,%esp
c0107206:	85 c0                	test   %eax,%eax
c0107208:	74 19                	je     c0107223 <basic_check+0x408>
c010720a:	68 16 c1 10 c0       	push   $0xc010c116
c010720f:	68 76 bf 10 c0       	push   $0xc010bf76
c0107214:	68 ee 00 00 00       	push   $0xee
c0107219:	68 8b bf 10 c0       	push   $0xc010bf8b
c010721e:	e8 45 a5 ff ff       	call   c0101768 <__panic>

    assert(nr_free == 0);
c0107223:	a1 34 d1 12 c0       	mov    0xc012d134,%eax
c0107228:	85 c0                	test   %eax,%eax
c010722a:	74 19                	je     c0107245 <basic_check+0x42a>
c010722c:	68 69 c1 10 c0       	push   $0xc010c169
c0107231:	68 76 bf 10 c0       	push   $0xc010bf76
c0107236:	68 f0 00 00 00       	push   $0xf0
c010723b:	68 8b bf 10 c0       	push   $0xc010bf8b
c0107240:	e8 23 a5 ff ff       	call   c0101768 <__panic>
    free_list = free_list_store;
c0107245:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107248:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010724b:	a3 2c d1 12 c0       	mov    %eax,0xc012d12c
c0107250:	89 15 30 d1 12 c0    	mov    %edx,0xc012d130
    nr_free = nr_free_store;
c0107256:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107259:	a3 34 d1 12 c0       	mov    %eax,0xc012d134

    free_page(p);
c010725e:	83 ec 08             	sub    $0x8,%esp
c0107261:	6a 01                	push   $0x1
c0107263:	ff 75 dc             	pushl  -0x24(%ebp)
c0107266:	e8 16 09 00 00       	call   c0107b81 <free_pages>
c010726b:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c010726e:	83 ec 08             	sub    $0x8,%esp
c0107271:	6a 01                	push   $0x1
c0107273:	ff 75 f0             	pushl  -0x10(%ebp)
c0107276:	e8 06 09 00 00       	call   c0107b81 <free_pages>
c010727b:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c010727e:	83 ec 08             	sub    $0x8,%esp
c0107281:	6a 01                	push   $0x1
c0107283:	ff 75 f4             	pushl  -0xc(%ebp)
c0107286:	e8 f6 08 00 00       	call   c0107b81 <free_pages>
c010728b:	83 c4 10             	add    $0x10,%esp
}
c010728e:	90                   	nop
c010728f:	c9                   	leave  
c0107290:	c3                   	ret    

c0107291 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0107291:	55                   	push   %ebp
c0107292:	89 e5                	mov    %esp,%ebp
c0107294:	81 ec 88 00 00 00    	sub    $0x88,%esp
    int count = 0, total = 0;
c010729a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01072a1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c01072a8:	c7 45 ec 2c d1 12 c0 	movl   $0xc012d12c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01072af:	eb 60                	jmp    c0107311 <default_check+0x80>
        struct Page *p = le2page(le, page_link);
c01072b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01072b4:	83 e8 10             	sub    $0x10,%eax
c01072b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c01072ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01072bd:	83 c0 04             	add    $0x4,%eax
c01072c0:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c01072c7:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01072ca:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01072cd:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01072d0:	0f a3 10             	bt     %edx,(%eax)
c01072d3:	19 c0                	sbb    %eax,%eax
c01072d5:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c01072d8:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c01072dc:	0f 95 c0             	setne  %al
c01072df:	0f b6 c0             	movzbl %al,%eax
c01072e2:	85 c0                	test   %eax,%eax
c01072e4:	75 19                	jne    c01072ff <default_check+0x6e>
c01072e6:	68 76 c1 10 c0       	push   $0xc010c176
c01072eb:	68 76 bf 10 c0       	push   $0xc010bf76
c01072f0:	68 01 01 00 00       	push   $0x101
c01072f5:	68 8b bf 10 c0       	push   $0xc010bf8b
c01072fa:	e8 69 a4 ff ff       	call   c0101768 <__panic>
        count ++, total += p->property;
c01072ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107303:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107306:	8b 50 08             	mov    0x8(%eax),%edx
c0107309:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010730c:	01 d0                	add    %edx,%eax
c010730e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107311:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107314:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0107317:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010731a:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c010731d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107320:	81 7d ec 2c d1 12 c0 	cmpl   $0xc012d12c,-0x14(%ebp)
c0107327:	75 88                	jne    c01072b1 <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0107329:	e8 88 08 00 00       	call   c0107bb6 <nr_free_pages>
c010732e:	89 c2                	mov    %eax,%edx
c0107330:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107333:	39 c2                	cmp    %eax,%edx
c0107335:	74 19                	je     c0107350 <default_check+0xbf>
c0107337:	68 86 c1 10 c0       	push   $0xc010c186
c010733c:	68 76 bf 10 c0       	push   $0xc010bf76
c0107341:	68 04 01 00 00       	push   $0x104
c0107346:	68 8b bf 10 c0       	push   $0xc010bf8b
c010734b:	e8 18 a4 ff ff       	call   c0101768 <__panic>

    basic_check();
c0107350:	e8 c6 fa ff ff       	call   c0106e1b <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0107355:	83 ec 0c             	sub    $0xc,%esp
c0107358:	6a 05                	push   $0x5
c010735a:	e8 b6 07 00 00       	call   c0107b15 <alloc_pages>
c010735f:	83 c4 10             	add    $0x10,%esp
c0107362:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
c0107365:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107369:	75 19                	jne    c0107384 <default_check+0xf3>
c010736b:	68 9f c1 10 c0       	push   $0xc010c19f
c0107370:	68 76 bf 10 c0       	push   $0xc010bf76
c0107375:	68 09 01 00 00       	push   $0x109
c010737a:	68 8b bf 10 c0       	push   $0xc010bf8b
c010737f:	e8 e4 a3 ff ff       	call   c0101768 <__panic>
    assert(!PageProperty(p0));
c0107384:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107387:	83 c0 04             	add    $0x4,%eax
c010738a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c0107391:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107394:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0107397:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010739a:	0f a3 10             	bt     %edx,(%eax)
c010739d:	19 c0                	sbb    %eax,%eax
c010739f:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c01073a2:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c01073a6:	0f 95 c0             	setne  %al
c01073a9:	0f b6 c0             	movzbl %al,%eax
c01073ac:	85 c0                	test   %eax,%eax
c01073ae:	74 19                	je     c01073c9 <default_check+0x138>
c01073b0:	68 aa c1 10 c0       	push   $0xc010c1aa
c01073b5:	68 76 bf 10 c0       	push   $0xc010bf76
c01073ba:	68 0a 01 00 00       	push   $0x10a
c01073bf:	68 8b bf 10 c0       	push   $0xc010bf8b
c01073c4:	e8 9f a3 ff ff       	call   c0101768 <__panic>

    list_entry_t free_list_store = free_list;
c01073c9:	a1 2c d1 12 c0       	mov    0xc012d12c,%eax
c01073ce:	8b 15 30 d1 12 c0    	mov    0xc012d130,%edx
c01073d4:	89 45 80             	mov    %eax,-0x80(%ebp)
c01073d7:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01073da:	c7 45 d0 2c d1 12 c0 	movl   $0xc012d12c,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01073e1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01073e4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01073e7:	89 50 04             	mov    %edx,0x4(%eax)
c01073ea:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01073ed:	8b 50 04             	mov    0x4(%eax),%edx
c01073f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01073f3:	89 10                	mov    %edx,(%eax)
c01073f5:	c7 45 d8 2c d1 12 c0 	movl   $0xc012d12c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01073fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01073ff:	8b 40 04             	mov    0x4(%eax),%eax
c0107402:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0107405:	0f 94 c0             	sete   %al
c0107408:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010740b:	85 c0                	test   %eax,%eax
c010740d:	75 19                	jne    c0107428 <default_check+0x197>
c010740f:	68 ff c0 10 c0       	push   $0xc010c0ff
c0107414:	68 76 bf 10 c0       	push   $0xc010bf76
c0107419:	68 0e 01 00 00       	push   $0x10e
c010741e:	68 8b bf 10 c0       	push   $0xc010bf8b
c0107423:	e8 40 a3 ff ff       	call   c0101768 <__panic>
    assert(alloc_page() == NULL);
c0107428:	83 ec 0c             	sub    $0xc,%esp
c010742b:	6a 01                	push   $0x1
c010742d:	e8 e3 06 00 00       	call   c0107b15 <alloc_pages>
c0107432:	83 c4 10             	add    $0x10,%esp
c0107435:	85 c0                	test   %eax,%eax
c0107437:	74 19                	je     c0107452 <default_check+0x1c1>
c0107439:	68 16 c1 10 c0       	push   $0xc010c116
c010743e:	68 76 bf 10 c0       	push   $0xc010bf76
c0107443:	68 0f 01 00 00       	push   $0x10f
c0107448:	68 8b bf 10 c0       	push   $0xc010bf8b
c010744d:	e8 16 a3 ff ff       	call   c0101768 <__panic>

    unsigned int nr_free_store = nr_free;
c0107452:	a1 34 d1 12 c0       	mov    0xc012d134,%eax
c0107457:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
c010745a:	c7 05 34 d1 12 c0 00 	movl   $0x0,0xc012d134
c0107461:	00 00 00 

    free_pages(p0 + 2, 3);
c0107464:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107467:	83 c0 48             	add    $0x48,%eax
c010746a:	83 ec 08             	sub    $0x8,%esp
c010746d:	6a 03                	push   $0x3
c010746f:	50                   	push   %eax
c0107470:	e8 0c 07 00 00       	call   c0107b81 <free_pages>
c0107475:	83 c4 10             	add    $0x10,%esp
    assert(alloc_pages(4) == NULL);
c0107478:	83 ec 0c             	sub    $0xc,%esp
c010747b:	6a 04                	push   $0x4
c010747d:	e8 93 06 00 00       	call   c0107b15 <alloc_pages>
c0107482:	83 c4 10             	add    $0x10,%esp
c0107485:	85 c0                	test   %eax,%eax
c0107487:	74 19                	je     c01074a2 <default_check+0x211>
c0107489:	68 bc c1 10 c0       	push   $0xc010c1bc
c010748e:	68 76 bf 10 c0       	push   $0xc010bf76
c0107493:	68 15 01 00 00       	push   $0x115
c0107498:	68 8b bf 10 c0       	push   $0xc010bf8b
c010749d:	e8 c6 a2 ff ff       	call   c0101768 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01074a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01074a5:	83 c0 48             	add    $0x48,%eax
c01074a8:	83 c0 04             	add    $0x4,%eax
c01074ab:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c01074b2:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01074b5:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01074b8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01074bb:	0f a3 10             	bt     %edx,(%eax)
c01074be:	19 c0                	sbb    %eax,%eax
c01074c0:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c01074c3:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c01074c7:	0f 95 c0             	setne  %al
c01074ca:	0f b6 c0             	movzbl %al,%eax
c01074cd:	85 c0                	test   %eax,%eax
c01074cf:	74 0e                	je     c01074df <default_check+0x24e>
c01074d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01074d4:	83 c0 48             	add    $0x48,%eax
c01074d7:	8b 40 08             	mov    0x8(%eax),%eax
c01074da:	83 f8 03             	cmp    $0x3,%eax
c01074dd:	74 19                	je     c01074f8 <default_check+0x267>
c01074df:	68 d4 c1 10 c0       	push   $0xc010c1d4
c01074e4:	68 76 bf 10 c0       	push   $0xc010bf76
c01074e9:	68 16 01 00 00       	push   $0x116
c01074ee:	68 8b bf 10 c0       	push   $0xc010bf8b
c01074f3:	e8 70 a2 ff ff       	call   c0101768 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01074f8:	83 ec 0c             	sub    $0xc,%esp
c01074fb:	6a 03                	push   $0x3
c01074fd:	e8 13 06 00 00       	call   c0107b15 <alloc_pages>
c0107502:	83 c4 10             	add    $0x10,%esp
c0107505:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0107508:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c010750c:	75 19                	jne    c0107527 <default_check+0x296>
c010750e:	68 00 c2 10 c0       	push   $0xc010c200
c0107513:	68 76 bf 10 c0       	push   $0xc010bf76
c0107518:	68 17 01 00 00       	push   $0x117
c010751d:	68 8b bf 10 c0       	push   $0xc010bf8b
c0107522:	e8 41 a2 ff ff       	call   c0101768 <__panic>
    assert(alloc_page() == NULL);
c0107527:	83 ec 0c             	sub    $0xc,%esp
c010752a:	6a 01                	push   $0x1
c010752c:	e8 e4 05 00 00       	call   c0107b15 <alloc_pages>
c0107531:	83 c4 10             	add    $0x10,%esp
c0107534:	85 c0                	test   %eax,%eax
c0107536:	74 19                	je     c0107551 <default_check+0x2c0>
c0107538:	68 16 c1 10 c0       	push   $0xc010c116
c010753d:	68 76 bf 10 c0       	push   $0xc010bf76
c0107542:	68 18 01 00 00       	push   $0x118
c0107547:	68 8b bf 10 c0       	push   $0xc010bf8b
c010754c:	e8 17 a2 ff ff       	call   c0101768 <__panic>
    assert(p0 + 2 == p1);
c0107551:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107554:	83 c0 48             	add    $0x48,%eax
c0107557:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
c010755a:	74 19                	je     c0107575 <default_check+0x2e4>
c010755c:	68 1e c2 10 c0       	push   $0xc010c21e
c0107561:	68 76 bf 10 c0       	push   $0xc010bf76
c0107566:	68 19 01 00 00       	push   $0x119
c010756b:	68 8b bf 10 c0       	push   $0xc010bf8b
c0107570:	e8 f3 a1 ff ff       	call   c0101768 <__panic>

    p2 = p0 + 1;
c0107575:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107578:	83 c0 24             	add    $0x24,%eax
c010757b:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
c010757e:	83 ec 08             	sub    $0x8,%esp
c0107581:	6a 01                	push   $0x1
c0107583:	ff 75 dc             	pushl  -0x24(%ebp)
c0107586:	e8 f6 05 00 00       	call   c0107b81 <free_pages>
c010758b:	83 c4 10             	add    $0x10,%esp
    free_pages(p1, 3);
c010758e:	83 ec 08             	sub    $0x8,%esp
c0107591:	6a 03                	push   $0x3
c0107593:	ff 75 c4             	pushl  -0x3c(%ebp)
c0107596:	e8 e6 05 00 00       	call   c0107b81 <free_pages>
c010759b:	83 c4 10             	add    $0x10,%esp
    assert(PageProperty(p0) && p0->property == 1);
c010759e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01075a1:	83 c0 04             	add    $0x4,%eax
c01075a4:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c01075ab:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01075ae:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01075b1:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01075b4:	0f a3 10             	bt     %edx,(%eax)
c01075b7:	19 c0                	sbb    %eax,%eax
c01075b9:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
c01075bc:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
c01075c0:	0f 95 c0             	setne  %al
c01075c3:	0f b6 c0             	movzbl %al,%eax
c01075c6:	85 c0                	test   %eax,%eax
c01075c8:	74 0b                	je     c01075d5 <default_check+0x344>
c01075ca:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01075cd:	8b 40 08             	mov    0x8(%eax),%eax
c01075d0:	83 f8 01             	cmp    $0x1,%eax
c01075d3:	74 19                	je     c01075ee <default_check+0x35d>
c01075d5:	68 2c c2 10 c0       	push   $0xc010c22c
c01075da:	68 76 bf 10 c0       	push   $0xc010bf76
c01075df:	68 1e 01 00 00       	push   $0x11e
c01075e4:	68 8b bf 10 c0       	push   $0xc010bf8b
c01075e9:	e8 7a a1 ff ff       	call   c0101768 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01075ee:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01075f1:	83 c0 04             	add    $0x4,%eax
c01075f4:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c01075fb:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01075fe:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0107601:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0107604:	0f a3 10             	bt     %edx,(%eax)
c0107607:	19 c0                	sbb    %eax,%eax
c0107609:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
c010760c:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
c0107610:	0f 95 c0             	setne  %al
c0107613:	0f b6 c0             	movzbl %al,%eax
c0107616:	85 c0                	test   %eax,%eax
c0107618:	74 0b                	je     c0107625 <default_check+0x394>
c010761a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010761d:	8b 40 08             	mov    0x8(%eax),%eax
c0107620:	83 f8 03             	cmp    $0x3,%eax
c0107623:	74 19                	je     c010763e <default_check+0x3ad>
c0107625:	68 54 c2 10 c0       	push   $0xc010c254
c010762a:	68 76 bf 10 c0       	push   $0xc010bf76
c010762f:	68 1f 01 00 00       	push   $0x11f
c0107634:	68 8b bf 10 c0       	push   $0xc010bf8b
c0107639:	e8 2a a1 ff ff       	call   c0101768 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c010763e:	83 ec 0c             	sub    $0xc,%esp
c0107641:	6a 01                	push   $0x1
c0107643:	e8 cd 04 00 00       	call   c0107b15 <alloc_pages>
c0107648:	83 c4 10             	add    $0x10,%esp
c010764b:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010764e:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0107651:	83 e8 24             	sub    $0x24,%eax
c0107654:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0107657:	74 19                	je     c0107672 <default_check+0x3e1>
c0107659:	68 7a c2 10 c0       	push   $0xc010c27a
c010765e:	68 76 bf 10 c0       	push   $0xc010bf76
c0107663:	68 21 01 00 00       	push   $0x121
c0107668:	68 8b bf 10 c0       	push   $0xc010bf8b
c010766d:	e8 f6 a0 ff ff       	call   c0101768 <__panic>
    free_page(p0);
c0107672:	83 ec 08             	sub    $0x8,%esp
c0107675:	6a 01                	push   $0x1
c0107677:	ff 75 dc             	pushl  -0x24(%ebp)
c010767a:	e8 02 05 00 00       	call   c0107b81 <free_pages>
c010767f:	83 c4 10             	add    $0x10,%esp
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0107682:	83 ec 0c             	sub    $0xc,%esp
c0107685:	6a 02                	push   $0x2
c0107687:	e8 89 04 00 00       	call   c0107b15 <alloc_pages>
c010768c:	83 c4 10             	add    $0x10,%esp
c010768f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107692:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0107695:	83 c0 24             	add    $0x24,%eax
c0107698:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010769b:	74 19                	je     c01076b6 <default_check+0x425>
c010769d:	68 98 c2 10 c0       	push   $0xc010c298
c01076a2:	68 76 bf 10 c0       	push   $0xc010bf76
c01076a7:	68 23 01 00 00       	push   $0x123
c01076ac:	68 8b bf 10 c0       	push   $0xc010bf8b
c01076b1:	e8 b2 a0 ff ff       	call   c0101768 <__panic>

    free_pages(p0, 2);
c01076b6:	83 ec 08             	sub    $0x8,%esp
c01076b9:	6a 02                	push   $0x2
c01076bb:	ff 75 dc             	pushl  -0x24(%ebp)
c01076be:	e8 be 04 00 00       	call   c0107b81 <free_pages>
c01076c3:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c01076c6:	83 ec 08             	sub    $0x8,%esp
c01076c9:	6a 01                	push   $0x1
c01076cb:	ff 75 c0             	pushl  -0x40(%ebp)
c01076ce:	e8 ae 04 00 00       	call   c0107b81 <free_pages>
c01076d3:	83 c4 10             	add    $0x10,%esp

    assert((p0 = alloc_pages(5)) != NULL);
c01076d6:	83 ec 0c             	sub    $0xc,%esp
c01076d9:	6a 05                	push   $0x5
c01076db:	e8 35 04 00 00       	call   c0107b15 <alloc_pages>
c01076e0:	83 c4 10             	add    $0x10,%esp
c01076e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01076e6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01076ea:	75 19                	jne    c0107705 <default_check+0x474>
c01076ec:	68 b8 c2 10 c0       	push   $0xc010c2b8
c01076f1:	68 76 bf 10 c0       	push   $0xc010bf76
c01076f6:	68 28 01 00 00       	push   $0x128
c01076fb:	68 8b bf 10 c0       	push   $0xc010bf8b
c0107700:	e8 63 a0 ff ff       	call   c0101768 <__panic>
    assert(alloc_page() == NULL);
c0107705:	83 ec 0c             	sub    $0xc,%esp
c0107708:	6a 01                	push   $0x1
c010770a:	e8 06 04 00 00       	call   c0107b15 <alloc_pages>
c010770f:	83 c4 10             	add    $0x10,%esp
c0107712:	85 c0                	test   %eax,%eax
c0107714:	74 19                	je     c010772f <default_check+0x49e>
c0107716:	68 16 c1 10 c0       	push   $0xc010c116
c010771b:	68 76 bf 10 c0       	push   $0xc010bf76
c0107720:	68 29 01 00 00       	push   $0x129
c0107725:	68 8b bf 10 c0       	push   $0xc010bf8b
c010772a:	e8 39 a0 ff ff       	call   c0101768 <__panic>

    assert(nr_free == 0);
c010772f:	a1 34 d1 12 c0       	mov    0xc012d134,%eax
c0107734:	85 c0                	test   %eax,%eax
c0107736:	74 19                	je     c0107751 <default_check+0x4c0>
c0107738:	68 69 c1 10 c0       	push   $0xc010c169
c010773d:	68 76 bf 10 c0       	push   $0xc010bf76
c0107742:	68 2b 01 00 00       	push   $0x12b
c0107747:	68 8b bf 10 c0       	push   $0xc010bf8b
c010774c:	e8 17 a0 ff ff       	call   c0101768 <__panic>
    nr_free = nr_free_store;
c0107751:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107754:	a3 34 d1 12 c0       	mov    %eax,0xc012d134

    free_list = free_list_store;
c0107759:	8b 45 80             	mov    -0x80(%ebp),%eax
c010775c:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010775f:	a3 2c d1 12 c0       	mov    %eax,0xc012d12c
c0107764:	89 15 30 d1 12 c0    	mov    %edx,0xc012d130
    free_pages(p0, 5);
c010776a:	83 ec 08             	sub    $0x8,%esp
c010776d:	6a 05                	push   $0x5
c010776f:	ff 75 dc             	pushl  -0x24(%ebp)
c0107772:	e8 0a 04 00 00       	call   c0107b81 <free_pages>
c0107777:	83 c4 10             	add    $0x10,%esp

    le = &free_list;
c010777a:	c7 45 ec 2c d1 12 c0 	movl   $0xc012d12c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0107781:	eb 1d                	jmp    c01077a0 <default_check+0x50f>
        struct Page *p = le2page(le, page_link);
c0107783:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107786:	83 e8 10             	sub    $0x10,%eax
c0107789:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
c010778c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0107790:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107793:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107796:	8b 40 08             	mov    0x8(%eax),%eax
c0107799:	29 c2                	sub    %eax,%edx
c010779b:	89 d0                	mov    %edx,%eax
c010779d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01077a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01077a3:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01077a6:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01077a9:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01077ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01077af:	81 7d ec 2c d1 12 c0 	cmpl   $0xc012d12c,-0x14(%ebp)
c01077b6:	75 cb                	jne    c0107783 <default_check+0x4f2>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c01077b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01077bc:	74 19                	je     c01077d7 <default_check+0x546>
c01077be:	68 d6 c2 10 c0       	push   $0xc010c2d6
c01077c3:	68 76 bf 10 c0       	push   $0xc010bf76
c01077c8:	68 36 01 00 00       	push   $0x136
c01077cd:	68 8b bf 10 c0       	push   $0xc010bf8b
c01077d2:	e8 91 9f ff ff       	call   c0101768 <__panic>
    assert(total == 0);
c01077d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01077db:	74 19                	je     c01077f6 <default_check+0x565>
c01077dd:	68 e1 c2 10 c0       	push   $0xc010c2e1
c01077e2:	68 76 bf 10 c0       	push   $0xc010bf76
c01077e7:	68 37 01 00 00       	push   $0x137
c01077ec:	68 8b bf 10 c0       	push   $0xc010bf8b
c01077f1:	e8 72 9f ff ff       	call   c0101768 <__panic>
}
c01077f6:	90                   	nop
c01077f7:	c9                   	leave  
c01077f8:	c3                   	ret    

c01077f9 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01077f9:	55                   	push   %ebp
c01077fa:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01077fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01077ff:	8b 15 40 d1 12 c0    	mov    0xc012d140,%edx
c0107805:	29 d0                	sub    %edx,%eax
c0107807:	c1 f8 02             	sar    $0x2,%eax
c010780a:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0107810:	5d                   	pop    %ebp
c0107811:	c3                   	ret    

c0107812 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0107812:	55                   	push   %ebp
c0107813:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0107815:	ff 75 08             	pushl  0x8(%ebp)
c0107818:	e8 dc ff ff ff       	call   c01077f9 <page2ppn>
c010781d:	83 c4 04             	add    $0x4,%esp
c0107820:	c1 e0 0c             	shl    $0xc,%eax
}
c0107823:	c9                   	leave  
c0107824:	c3                   	ret    

c0107825 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0107825:	55                   	push   %ebp
c0107826:	89 e5                	mov    %esp,%ebp
c0107828:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c010782b:	8b 45 08             	mov    0x8(%ebp),%eax
c010782e:	c1 e8 0c             	shr    $0xc,%eax
c0107831:	89 c2                	mov    %eax,%edx
c0107833:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c0107838:	39 c2                	cmp    %eax,%edx
c010783a:	72 14                	jb     c0107850 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c010783c:	83 ec 04             	sub    $0x4,%esp
c010783f:	68 1c c3 10 c0       	push   $0xc010c31c
c0107844:	6a 5f                	push   $0x5f
c0107846:	68 3b c3 10 c0       	push   $0xc010c33b
c010784b:	e8 18 9f ff ff       	call   c0101768 <__panic>
    }
    return &pages[PPN(pa)];
c0107850:	8b 0d 40 d1 12 c0    	mov    0xc012d140,%ecx
c0107856:	8b 45 08             	mov    0x8(%ebp),%eax
c0107859:	c1 e8 0c             	shr    $0xc,%eax
c010785c:	89 c2                	mov    %eax,%edx
c010785e:	89 d0                	mov    %edx,%eax
c0107860:	c1 e0 03             	shl    $0x3,%eax
c0107863:	01 d0                	add    %edx,%eax
c0107865:	c1 e0 02             	shl    $0x2,%eax
c0107868:	01 c8                	add    %ecx,%eax
}
c010786a:	c9                   	leave  
c010786b:	c3                   	ret    

c010786c <page2kva>:

static inline void *
page2kva(struct Page *page) {
c010786c:	55                   	push   %ebp
c010786d:	89 e5                	mov    %esp,%ebp
c010786f:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c0107872:	ff 75 08             	pushl  0x8(%ebp)
c0107875:	e8 98 ff ff ff       	call   c0107812 <page2pa>
c010787a:	83 c4 04             	add    $0x4,%esp
c010787d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107880:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107883:	c1 e8 0c             	shr    $0xc,%eax
c0107886:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107889:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c010788e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107891:	72 14                	jb     c01078a7 <page2kva+0x3b>
c0107893:	ff 75 f4             	pushl  -0xc(%ebp)
c0107896:	68 4c c3 10 c0       	push   $0xc010c34c
c010789b:	6a 66                	push   $0x66
c010789d:	68 3b c3 10 c0       	push   $0xc010c33b
c01078a2:	e8 c1 9e ff ff       	call   c0101768 <__panic>
c01078a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01078aa:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01078af:	c9                   	leave  
c01078b0:	c3                   	ret    

c01078b1 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c01078b1:	55                   	push   %ebp
c01078b2:	89 e5                	mov    %esp,%ebp
c01078b4:	83 ec 08             	sub    $0x8,%esp
    if (!(pte & PTE_P)) {
c01078b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01078ba:	83 e0 01             	and    $0x1,%eax
c01078bd:	85 c0                	test   %eax,%eax
c01078bf:	75 14                	jne    c01078d5 <pte2page+0x24>
        panic("pte2page called with invalid pte");
c01078c1:	83 ec 04             	sub    $0x4,%esp
c01078c4:	68 70 c3 10 c0       	push   $0xc010c370
c01078c9:	6a 71                	push   $0x71
c01078cb:	68 3b c3 10 c0       	push   $0xc010c33b
c01078d0:	e8 93 9e ff ff       	call   c0101768 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c01078d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01078d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01078dd:	83 ec 0c             	sub    $0xc,%esp
c01078e0:	50                   	push   %eax
c01078e1:	e8 3f ff ff ff       	call   c0107825 <pa2page>
c01078e6:	83 c4 10             	add    $0x10,%esp
}
c01078e9:	c9                   	leave  
c01078ea:	c3                   	ret    

c01078eb <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c01078eb:	55                   	push   %ebp
c01078ec:	89 e5                	mov    %esp,%ebp
c01078ee:	83 ec 08             	sub    $0x8,%esp
    return pa2page(PDE_ADDR(pde));
c01078f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01078f4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01078f9:	83 ec 0c             	sub    $0xc,%esp
c01078fc:	50                   	push   %eax
c01078fd:	e8 23 ff ff ff       	call   c0107825 <pa2page>
c0107902:	83 c4 10             	add    $0x10,%esp
}
c0107905:	c9                   	leave  
c0107906:	c3                   	ret    

c0107907 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0107907:	55                   	push   %ebp
c0107908:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010790a:	8b 45 08             	mov    0x8(%ebp),%eax
c010790d:	8b 00                	mov    (%eax),%eax
}
c010790f:	5d                   	pop    %ebp
c0107910:	c3                   	ret    

c0107911 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0107911:	55                   	push   %ebp
c0107912:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0107914:	8b 45 08             	mov    0x8(%ebp),%eax
c0107917:	8b 55 0c             	mov    0xc(%ebp),%edx
c010791a:	89 10                	mov    %edx,(%eax)
}
c010791c:	90                   	nop
c010791d:	5d                   	pop    %ebp
c010791e:	c3                   	ret    

c010791f <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c010791f:	55                   	push   %ebp
c0107920:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0107922:	8b 45 08             	mov    0x8(%ebp),%eax
c0107925:	8b 00                	mov    (%eax),%eax
c0107927:	8d 50 01             	lea    0x1(%eax),%edx
c010792a:	8b 45 08             	mov    0x8(%ebp),%eax
c010792d:	89 10                	mov    %edx,(%eax)
    return page->ref;
c010792f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107932:	8b 00                	mov    (%eax),%eax
}
c0107934:	5d                   	pop    %ebp
c0107935:	c3                   	ret    

c0107936 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0107936:	55                   	push   %ebp
c0107937:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0107939:	8b 45 08             	mov    0x8(%ebp),%eax
c010793c:	8b 00                	mov    (%eax),%eax
c010793e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0107941:	8b 45 08             	mov    0x8(%ebp),%eax
c0107944:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0107946:	8b 45 08             	mov    0x8(%ebp),%eax
c0107949:	8b 00                	mov    (%eax),%eax
}
c010794b:	5d                   	pop    %ebp
c010794c:	c3                   	ret    

c010794d <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c010794d:	55                   	push   %ebp
c010794e:	89 e5                	mov    %esp,%ebp
c0107950:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0107953:	9c                   	pushf  
c0107954:	58                   	pop    %eax
c0107955:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0107958:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010795b:	25 00 02 00 00       	and    $0x200,%eax
c0107960:	85 c0                	test   %eax,%eax
c0107962:	74 0c                	je     c0107970 <__intr_save+0x23>
        intr_disable();
c0107964:	e8 e0 ba ff ff       	call   c0103449 <intr_disable>
        return 1;
c0107969:	b8 01 00 00 00       	mov    $0x1,%eax
c010796e:	eb 05                	jmp    c0107975 <__intr_save+0x28>
    }
    return 0;
c0107970:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107975:	c9                   	leave  
c0107976:	c3                   	ret    

c0107977 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0107977:	55                   	push   %ebp
c0107978:	89 e5                	mov    %esp,%ebp
c010797a:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010797d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107981:	74 05                	je     c0107988 <__intr_restore+0x11>
        intr_enable();
c0107983:	e8 ba ba ff ff       	call   c0103442 <intr_enable>
    }
}
c0107988:	90                   	nop
c0107989:	c9                   	leave  
c010798a:	c3                   	ret    

c010798b <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c010798b:	55                   	push   %ebp
c010798c:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c010798e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107991:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0107994:	b8 23 00 00 00       	mov    $0x23,%eax
c0107999:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c010799b:	b8 23 00 00 00       	mov    $0x23,%eax
c01079a0:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c01079a2:	b8 10 00 00 00       	mov    $0x10,%eax
c01079a7:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c01079a9:	b8 10 00 00 00       	mov    $0x10,%eax
c01079ae:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c01079b0:	b8 10 00 00 00       	mov    $0x10,%eax
c01079b5:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c01079b7:	ea be 79 10 c0 08 00 	ljmp   $0x8,$0xc01079be
}
c01079be:	90                   	nop
c01079bf:	5d                   	pop    %ebp
c01079c0:	c3                   	ret    

c01079c1 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c01079c1:	55                   	push   %ebp
c01079c2:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c01079c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01079c7:	a3 a4 af 12 c0       	mov    %eax,0xc012afa4
}
c01079cc:	90                   	nop
c01079cd:	5d                   	pop    %ebp
c01079ce:	c3                   	ret    

c01079cf <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c01079cf:	55                   	push   %ebp
c01079d0:	89 e5                	mov    %esp,%ebp
c01079d2:	83 ec 10             	sub    $0x10,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c01079d5:	b8 00 70 12 c0       	mov    $0xc0127000,%eax
c01079da:	50                   	push   %eax
c01079db:	e8 e1 ff ff ff       	call   c01079c1 <load_esp0>
c01079e0:	83 c4 04             	add    $0x4,%esp
    ts.ts_ss0 = KERNEL_DS;
c01079e3:	66 c7 05 a8 af 12 c0 	movw   $0x10,0xc012afa8
c01079ea:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c01079ec:	66 c7 05 68 7a 12 c0 	movw   $0x68,0xc0127a68
c01079f3:	68 00 
c01079f5:	b8 a0 af 12 c0       	mov    $0xc012afa0,%eax
c01079fa:	66 a3 6a 7a 12 c0    	mov    %ax,0xc0127a6a
c0107a00:	b8 a0 af 12 c0       	mov    $0xc012afa0,%eax
c0107a05:	c1 e8 10             	shr    $0x10,%eax
c0107a08:	a2 6c 7a 12 c0       	mov    %al,0xc0127a6c
c0107a0d:	0f b6 05 6d 7a 12 c0 	movzbl 0xc0127a6d,%eax
c0107a14:	83 e0 f0             	and    $0xfffffff0,%eax
c0107a17:	83 c8 09             	or     $0x9,%eax
c0107a1a:	a2 6d 7a 12 c0       	mov    %al,0xc0127a6d
c0107a1f:	0f b6 05 6d 7a 12 c0 	movzbl 0xc0127a6d,%eax
c0107a26:	83 e0 ef             	and    $0xffffffef,%eax
c0107a29:	a2 6d 7a 12 c0       	mov    %al,0xc0127a6d
c0107a2e:	0f b6 05 6d 7a 12 c0 	movzbl 0xc0127a6d,%eax
c0107a35:	83 e0 9f             	and    $0xffffff9f,%eax
c0107a38:	a2 6d 7a 12 c0       	mov    %al,0xc0127a6d
c0107a3d:	0f b6 05 6d 7a 12 c0 	movzbl 0xc0127a6d,%eax
c0107a44:	83 c8 80             	or     $0xffffff80,%eax
c0107a47:	a2 6d 7a 12 c0       	mov    %al,0xc0127a6d
c0107a4c:	0f b6 05 6e 7a 12 c0 	movzbl 0xc0127a6e,%eax
c0107a53:	83 e0 f0             	and    $0xfffffff0,%eax
c0107a56:	a2 6e 7a 12 c0       	mov    %al,0xc0127a6e
c0107a5b:	0f b6 05 6e 7a 12 c0 	movzbl 0xc0127a6e,%eax
c0107a62:	83 e0 ef             	and    $0xffffffef,%eax
c0107a65:	a2 6e 7a 12 c0       	mov    %al,0xc0127a6e
c0107a6a:	0f b6 05 6e 7a 12 c0 	movzbl 0xc0127a6e,%eax
c0107a71:	83 e0 df             	and    $0xffffffdf,%eax
c0107a74:	a2 6e 7a 12 c0       	mov    %al,0xc0127a6e
c0107a79:	0f b6 05 6e 7a 12 c0 	movzbl 0xc0127a6e,%eax
c0107a80:	83 c8 40             	or     $0x40,%eax
c0107a83:	a2 6e 7a 12 c0       	mov    %al,0xc0127a6e
c0107a88:	0f b6 05 6e 7a 12 c0 	movzbl 0xc0127a6e,%eax
c0107a8f:	83 e0 7f             	and    $0x7f,%eax
c0107a92:	a2 6e 7a 12 c0       	mov    %al,0xc0127a6e
c0107a97:	b8 a0 af 12 c0       	mov    $0xc012afa0,%eax
c0107a9c:	c1 e8 18             	shr    $0x18,%eax
c0107a9f:	a2 6f 7a 12 c0       	mov    %al,0xc0127a6f

    // reload all segment registers
    lgdt(&gdt_pd);
c0107aa4:	68 70 7a 12 c0       	push   $0xc0127a70
c0107aa9:	e8 dd fe ff ff       	call   c010798b <lgdt>
c0107aae:	83 c4 04             	add    $0x4,%esp
c0107ab1:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0107ab7:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0107abb:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0107abe:	90                   	nop
c0107abf:	c9                   	leave  
c0107ac0:	c3                   	ret    

c0107ac1 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0107ac1:	55                   	push   %ebp
c0107ac2:	89 e5                	mov    %esp,%ebp
c0107ac4:	83 ec 08             	sub    $0x8,%esp
    pmm_manager = &default_pmm_manager;
c0107ac7:	c7 05 38 d1 12 c0 00 	movl   $0xc010c300,0xc012d138
c0107ace:	c3 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0107ad1:	a1 38 d1 12 c0       	mov    0xc012d138,%eax
c0107ad6:	8b 00                	mov    (%eax),%eax
c0107ad8:	83 ec 08             	sub    $0x8,%esp
c0107adb:	50                   	push   %eax
c0107adc:	68 9c c3 10 c0       	push   $0xc010c39c
c0107ae1:	e8 a4 87 ff ff       	call   c010028a <cprintf>
c0107ae6:	83 c4 10             	add    $0x10,%esp
    pmm_manager->init();
c0107ae9:	a1 38 d1 12 c0       	mov    0xc012d138,%eax
c0107aee:	8b 40 04             	mov    0x4(%eax),%eax
c0107af1:	ff d0                	call   *%eax
}
c0107af3:	90                   	nop
c0107af4:	c9                   	leave  
c0107af5:	c3                   	ret    

c0107af6 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0107af6:	55                   	push   %ebp
c0107af7:	89 e5                	mov    %esp,%ebp
c0107af9:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->init_memmap(base, n);
c0107afc:	a1 38 d1 12 c0       	mov    0xc012d138,%eax
c0107b01:	8b 40 08             	mov    0x8(%eax),%eax
c0107b04:	83 ec 08             	sub    $0x8,%esp
c0107b07:	ff 75 0c             	pushl  0xc(%ebp)
c0107b0a:	ff 75 08             	pushl  0x8(%ebp)
c0107b0d:	ff d0                	call   *%eax
c0107b0f:	83 c4 10             	add    $0x10,%esp
}
c0107b12:	90                   	nop
c0107b13:	c9                   	leave  
c0107b14:	c3                   	ret    

c0107b15 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0107b15:	55                   	push   %ebp
c0107b16:	89 e5                	mov    %esp,%ebp
c0107b18:	83 ec 18             	sub    $0x18,%esp
    struct Page *page=NULL;
c0107b1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0107b22:	e8 26 fe ff ff       	call   c010794d <__intr_save>
c0107b27:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0107b2a:	a1 38 d1 12 c0       	mov    0xc012d138,%eax
c0107b2f:	8b 40 0c             	mov    0xc(%eax),%eax
c0107b32:	83 ec 0c             	sub    $0xc,%esp
c0107b35:	ff 75 08             	pushl  0x8(%ebp)
c0107b38:	ff d0                	call   *%eax
c0107b3a:	83 c4 10             	add    $0x10,%esp
c0107b3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0107b40:	83 ec 0c             	sub    $0xc,%esp
c0107b43:	ff 75 f0             	pushl  -0x10(%ebp)
c0107b46:	e8 2c fe ff ff       	call   c0107977 <__intr_restore>
c0107b4b:	83 c4 10             	add    $0x10,%esp

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c0107b4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107b52:	75 28                	jne    c0107b7c <alloc_pages+0x67>
c0107b54:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c0107b58:	77 22                	ja     c0107b7c <alloc_pages+0x67>
c0107b5a:	a1 68 af 12 c0       	mov    0xc012af68,%eax
c0107b5f:	85 c0                	test   %eax,%eax
c0107b61:	74 19                	je     c0107b7c <alloc_pages+0x67>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c0107b63:	8b 55 08             	mov    0x8(%ebp),%edx
c0107b66:	a1 58 d0 12 c0       	mov    0xc012d058,%eax
c0107b6b:	83 ec 04             	sub    $0x4,%esp
c0107b6e:	6a 00                	push   $0x0
c0107b70:	52                   	push   %edx
c0107b71:	50                   	push   %eax
c0107b72:	e8 50 d7 ff ff       	call   c01052c7 <swap_out>
c0107b77:	83 c4 10             	add    $0x10,%esp
    }
c0107b7a:	eb a6                	jmp    c0107b22 <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c0107b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107b7f:	c9                   	leave  
c0107b80:	c3                   	ret    

c0107b81 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0107b81:	55                   	push   %ebp
c0107b82:	89 e5                	mov    %esp,%ebp
c0107b84:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0107b87:	e8 c1 fd ff ff       	call   c010794d <__intr_save>
c0107b8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0107b8f:	a1 38 d1 12 c0       	mov    0xc012d138,%eax
c0107b94:	8b 40 10             	mov    0x10(%eax),%eax
c0107b97:	83 ec 08             	sub    $0x8,%esp
c0107b9a:	ff 75 0c             	pushl  0xc(%ebp)
c0107b9d:	ff 75 08             	pushl  0x8(%ebp)
c0107ba0:	ff d0                	call   *%eax
c0107ba2:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c0107ba5:	83 ec 0c             	sub    $0xc,%esp
c0107ba8:	ff 75 f4             	pushl  -0xc(%ebp)
c0107bab:	e8 c7 fd ff ff       	call   c0107977 <__intr_restore>
c0107bb0:	83 c4 10             	add    $0x10,%esp
}
c0107bb3:	90                   	nop
c0107bb4:	c9                   	leave  
c0107bb5:	c3                   	ret    

c0107bb6 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0107bb6:	55                   	push   %ebp
c0107bb7:	89 e5                	mov    %esp,%ebp
c0107bb9:	83 ec 18             	sub    $0x18,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0107bbc:	e8 8c fd ff ff       	call   c010794d <__intr_save>
c0107bc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0107bc4:	a1 38 d1 12 c0       	mov    0xc012d138,%eax
c0107bc9:	8b 40 14             	mov    0x14(%eax),%eax
c0107bcc:	ff d0                	call   *%eax
c0107bce:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0107bd1:	83 ec 0c             	sub    $0xc,%esp
c0107bd4:	ff 75 f4             	pushl  -0xc(%ebp)
c0107bd7:	e8 9b fd ff ff       	call   c0107977 <__intr_restore>
c0107bdc:	83 c4 10             	add    $0x10,%esp
    return ret;
c0107bdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0107be2:	c9                   	leave  
c0107be3:	c3                   	ret    

c0107be4 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0107be4:	55                   	push   %ebp
c0107be5:	89 e5                	mov    %esp,%ebp
c0107be7:	57                   	push   %edi
c0107be8:	56                   	push   %esi
c0107be9:	53                   	push   %ebx
c0107bea:	83 ec 7c             	sub    $0x7c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0107bed:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0107bf4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0107bfb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0107c02:	83 ec 0c             	sub    $0xc,%esp
c0107c05:	68 b3 c3 10 c0       	push   $0xc010c3b3
c0107c0a:	e8 7b 86 ff ff       	call   c010028a <cprintf>
c0107c0f:	83 c4 10             	add    $0x10,%esp
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0107c12:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0107c19:	e9 fc 00 00 00       	jmp    c0107d1a <page_init+0x136>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0107c1e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107c21:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107c24:	89 d0                	mov    %edx,%eax
c0107c26:	c1 e0 02             	shl    $0x2,%eax
c0107c29:	01 d0                	add    %edx,%eax
c0107c2b:	c1 e0 02             	shl    $0x2,%eax
c0107c2e:	01 c8                	add    %ecx,%eax
c0107c30:	8b 50 08             	mov    0x8(%eax),%edx
c0107c33:	8b 40 04             	mov    0x4(%eax),%eax
c0107c36:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0107c39:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0107c3c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107c3f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107c42:	89 d0                	mov    %edx,%eax
c0107c44:	c1 e0 02             	shl    $0x2,%eax
c0107c47:	01 d0                	add    %edx,%eax
c0107c49:	c1 e0 02             	shl    $0x2,%eax
c0107c4c:	01 c8                	add    %ecx,%eax
c0107c4e:	8b 48 0c             	mov    0xc(%eax),%ecx
c0107c51:	8b 58 10             	mov    0x10(%eax),%ebx
c0107c54:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107c57:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0107c5a:	01 c8                	add    %ecx,%eax
c0107c5c:	11 da                	adc    %ebx,%edx
c0107c5e:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0107c61:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0107c64:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107c67:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107c6a:	89 d0                	mov    %edx,%eax
c0107c6c:	c1 e0 02             	shl    $0x2,%eax
c0107c6f:	01 d0                	add    %edx,%eax
c0107c71:	c1 e0 02             	shl    $0x2,%eax
c0107c74:	01 c8                	add    %ecx,%eax
c0107c76:	83 c0 14             	add    $0x14,%eax
c0107c79:	8b 00                	mov    (%eax),%eax
c0107c7b:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0107c7e:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0107c81:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0107c84:	83 c0 ff             	add    $0xffffffff,%eax
c0107c87:	83 d2 ff             	adc    $0xffffffff,%edx
c0107c8a:	89 c1                	mov    %eax,%ecx
c0107c8c:	89 d3                	mov    %edx,%ebx
c0107c8e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0107c91:	89 55 80             	mov    %edx,-0x80(%ebp)
c0107c94:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107c97:	89 d0                	mov    %edx,%eax
c0107c99:	c1 e0 02             	shl    $0x2,%eax
c0107c9c:	01 d0                	add    %edx,%eax
c0107c9e:	c1 e0 02             	shl    $0x2,%eax
c0107ca1:	03 45 80             	add    -0x80(%ebp),%eax
c0107ca4:	8b 50 10             	mov    0x10(%eax),%edx
c0107ca7:	8b 40 0c             	mov    0xc(%eax),%eax
c0107caa:	ff 75 84             	pushl  -0x7c(%ebp)
c0107cad:	53                   	push   %ebx
c0107cae:	51                   	push   %ecx
c0107caf:	ff 75 bc             	pushl  -0x44(%ebp)
c0107cb2:	ff 75 b8             	pushl  -0x48(%ebp)
c0107cb5:	52                   	push   %edx
c0107cb6:	50                   	push   %eax
c0107cb7:	68 c0 c3 10 c0       	push   $0xc010c3c0
c0107cbc:	e8 c9 85 ff ff       	call   c010028a <cprintf>
c0107cc1:	83 c4 20             	add    $0x20,%esp
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0107cc4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107cc7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107cca:	89 d0                	mov    %edx,%eax
c0107ccc:	c1 e0 02             	shl    $0x2,%eax
c0107ccf:	01 d0                	add    %edx,%eax
c0107cd1:	c1 e0 02             	shl    $0x2,%eax
c0107cd4:	01 c8                	add    %ecx,%eax
c0107cd6:	83 c0 14             	add    $0x14,%eax
c0107cd9:	8b 00                	mov    (%eax),%eax
c0107cdb:	83 f8 01             	cmp    $0x1,%eax
c0107cde:	75 36                	jne    c0107d16 <page_init+0x132>
            if (maxpa < end && begin < KMEMSIZE) {
c0107ce0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107ce3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107ce6:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0107ce9:	77 2b                	ja     c0107d16 <page_init+0x132>
c0107ceb:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0107cee:	72 05                	jb     c0107cf5 <page_init+0x111>
c0107cf0:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0107cf3:	73 21                	jae    c0107d16 <page_init+0x132>
c0107cf5:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0107cf9:	77 1b                	ja     c0107d16 <page_init+0x132>
c0107cfb:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0107cff:	72 09                	jb     c0107d0a <page_init+0x126>
c0107d01:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0107d08:	77 0c                	ja     c0107d16 <page_init+0x132>
                maxpa = end;
c0107d0a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0107d0d:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0107d10:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107d13:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0107d16:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0107d1a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107d1d:	8b 00                	mov    (%eax),%eax
c0107d1f:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0107d22:	0f 8f f6 fe ff ff    	jg     c0107c1e <page_init+0x3a>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0107d28:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107d2c:	72 1d                	jb     c0107d4b <page_init+0x167>
c0107d2e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107d32:	77 09                	ja     c0107d3d <page_init+0x159>
c0107d34:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0107d3b:	76 0e                	jbe    c0107d4b <page_init+0x167>
        maxpa = KMEMSIZE;
c0107d3d:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0107d44:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0107d4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107d4e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107d51:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0107d55:	c1 ea 0c             	shr    $0xc,%edx
c0107d58:	a3 80 af 12 c0       	mov    %eax,0xc012af80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0107d5d:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0107d64:	b8 4c d1 12 c0       	mov    $0xc012d14c,%eax
c0107d69:	8d 50 ff             	lea    -0x1(%eax),%edx
c0107d6c:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0107d6f:	01 d0                	add    %edx,%eax
c0107d71:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0107d74:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0107d77:	ba 00 00 00 00       	mov    $0x0,%edx
c0107d7c:	f7 75 ac             	divl   -0x54(%ebp)
c0107d7f:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0107d82:	29 d0                	sub    %edx,%eax
c0107d84:	a3 40 d1 12 c0       	mov    %eax,0xc012d140

    for (i = 0; i < npage; i ++) {
c0107d89:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0107d90:	eb 2f                	jmp    c0107dc1 <page_init+0x1dd>
        SetPageReserved(pages + i);
c0107d92:	8b 0d 40 d1 12 c0    	mov    0xc012d140,%ecx
c0107d98:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107d9b:	89 d0                	mov    %edx,%eax
c0107d9d:	c1 e0 03             	shl    $0x3,%eax
c0107da0:	01 d0                	add    %edx,%eax
c0107da2:	c1 e0 02             	shl    $0x2,%eax
c0107da5:	01 c8                	add    %ecx,%eax
c0107da7:	83 c0 04             	add    $0x4,%eax
c0107daa:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0107db1:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0107db4:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0107db7:	8b 55 90             	mov    -0x70(%ebp),%edx
c0107dba:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0107dbd:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0107dc1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107dc4:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c0107dc9:	39 c2                	cmp    %eax,%edx
c0107dcb:	72 c5                	jb     c0107d92 <page_init+0x1ae>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0107dcd:	8b 15 80 af 12 c0    	mov    0xc012af80,%edx
c0107dd3:	89 d0                	mov    %edx,%eax
c0107dd5:	c1 e0 03             	shl    $0x3,%eax
c0107dd8:	01 d0                	add    %edx,%eax
c0107dda:	c1 e0 02             	shl    $0x2,%eax
c0107ddd:	89 c2                	mov    %eax,%edx
c0107ddf:	a1 40 d1 12 c0       	mov    0xc012d140,%eax
c0107de4:	01 d0                	add    %edx,%eax
c0107de6:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0107de9:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0107df0:	77 17                	ja     c0107e09 <page_init+0x225>
c0107df2:	ff 75 a4             	pushl  -0x5c(%ebp)
c0107df5:	68 f0 c3 10 c0       	push   $0xc010c3f0
c0107dfa:	68 ea 00 00 00       	push   $0xea
c0107dff:	68 14 c4 10 c0       	push   $0xc010c414
c0107e04:	e8 5f 99 ff ff       	call   c0101768 <__panic>
c0107e09:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0107e0c:	05 00 00 00 40       	add    $0x40000000,%eax
c0107e11:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0107e14:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0107e1b:	e9 69 01 00 00       	jmp    c0107f89 <page_init+0x3a5>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0107e20:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107e23:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107e26:	89 d0                	mov    %edx,%eax
c0107e28:	c1 e0 02             	shl    $0x2,%eax
c0107e2b:	01 d0                	add    %edx,%eax
c0107e2d:	c1 e0 02             	shl    $0x2,%eax
c0107e30:	01 c8                	add    %ecx,%eax
c0107e32:	8b 50 08             	mov    0x8(%eax),%edx
c0107e35:	8b 40 04             	mov    0x4(%eax),%eax
c0107e38:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107e3b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0107e3e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107e41:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107e44:	89 d0                	mov    %edx,%eax
c0107e46:	c1 e0 02             	shl    $0x2,%eax
c0107e49:	01 d0                	add    %edx,%eax
c0107e4b:	c1 e0 02             	shl    $0x2,%eax
c0107e4e:	01 c8                	add    %ecx,%eax
c0107e50:	8b 48 0c             	mov    0xc(%eax),%ecx
c0107e53:	8b 58 10             	mov    0x10(%eax),%ebx
c0107e56:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107e59:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107e5c:	01 c8                	add    %ecx,%eax
c0107e5e:	11 da                	adc    %ebx,%edx
c0107e60:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0107e63:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0107e66:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107e69:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107e6c:	89 d0                	mov    %edx,%eax
c0107e6e:	c1 e0 02             	shl    $0x2,%eax
c0107e71:	01 d0                	add    %edx,%eax
c0107e73:	c1 e0 02             	shl    $0x2,%eax
c0107e76:	01 c8                	add    %ecx,%eax
c0107e78:	83 c0 14             	add    $0x14,%eax
c0107e7b:	8b 00                	mov    (%eax),%eax
c0107e7d:	83 f8 01             	cmp    $0x1,%eax
c0107e80:	0f 85 ff 00 00 00    	jne    c0107f85 <page_init+0x3a1>
            if (begin < freemem) {
c0107e86:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0107e89:	ba 00 00 00 00       	mov    $0x0,%edx
c0107e8e:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0107e91:	72 17                	jb     c0107eaa <page_init+0x2c6>
c0107e93:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0107e96:	77 05                	ja     c0107e9d <page_init+0x2b9>
c0107e98:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0107e9b:	76 0d                	jbe    c0107eaa <page_init+0x2c6>
                begin = freemem;
c0107e9d:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0107ea0:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107ea3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0107eaa:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107eae:	72 1d                	jb     c0107ecd <page_init+0x2e9>
c0107eb0:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107eb4:	77 09                	ja     c0107ebf <page_init+0x2db>
c0107eb6:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0107ebd:	76 0e                	jbe    c0107ecd <page_init+0x2e9>
                end = KMEMSIZE;
c0107ebf:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0107ec6:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0107ecd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107ed0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107ed3:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107ed6:	0f 87 a9 00 00 00    	ja     c0107f85 <page_init+0x3a1>
c0107edc:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107edf:	72 09                	jb     c0107eea <page_init+0x306>
c0107ee1:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0107ee4:	0f 83 9b 00 00 00    	jae    c0107f85 <page_init+0x3a1>
                begin = ROUNDUP(begin, PGSIZE);
c0107eea:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0107ef1:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107ef4:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0107ef7:	01 d0                	add    %edx,%eax
c0107ef9:	83 e8 01             	sub    $0x1,%eax
c0107efc:	89 45 98             	mov    %eax,-0x68(%ebp)
c0107eff:	8b 45 98             	mov    -0x68(%ebp),%eax
c0107f02:	ba 00 00 00 00       	mov    $0x0,%edx
c0107f07:	f7 75 9c             	divl   -0x64(%ebp)
c0107f0a:	8b 45 98             	mov    -0x68(%ebp),%eax
c0107f0d:	29 d0                	sub    %edx,%eax
c0107f0f:	ba 00 00 00 00       	mov    $0x0,%edx
c0107f14:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107f17:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0107f1a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107f1d:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0107f20:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0107f23:	ba 00 00 00 00       	mov    $0x0,%edx
c0107f28:	89 c3                	mov    %eax,%ebx
c0107f2a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0107f30:	89 de                	mov    %ebx,%esi
c0107f32:	89 d0                	mov    %edx,%eax
c0107f34:	83 e0 00             	and    $0x0,%eax
c0107f37:	89 c7                	mov    %eax,%edi
c0107f39:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0107f3c:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0107f3f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107f42:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107f45:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107f48:	77 3b                	ja     c0107f85 <page_init+0x3a1>
c0107f4a:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107f4d:	72 05                	jb     c0107f54 <page_init+0x370>
c0107f4f:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0107f52:	73 31                	jae    c0107f85 <page_init+0x3a1>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0107f54:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107f57:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107f5a:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0107f5d:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0107f60:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0107f64:	c1 ea 0c             	shr    $0xc,%edx
c0107f67:	89 c3                	mov    %eax,%ebx
c0107f69:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107f6c:	83 ec 0c             	sub    $0xc,%esp
c0107f6f:	50                   	push   %eax
c0107f70:	e8 b0 f8 ff ff       	call   c0107825 <pa2page>
c0107f75:	83 c4 10             	add    $0x10,%esp
c0107f78:	83 ec 08             	sub    $0x8,%esp
c0107f7b:	53                   	push   %ebx
c0107f7c:	50                   	push   %eax
c0107f7d:	e8 74 fb ff ff       	call   c0107af6 <init_memmap>
c0107f82:	83 c4 10             	add    $0x10,%esp
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c0107f85:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0107f89:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107f8c:	8b 00                	mov    (%eax),%eax
c0107f8e:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0107f91:	0f 8f 89 fe ff ff    	jg     c0107e20 <page_init+0x23c>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0107f97:	90                   	nop
c0107f98:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0107f9b:	5b                   	pop    %ebx
c0107f9c:	5e                   	pop    %esi
c0107f9d:	5f                   	pop    %edi
c0107f9e:	5d                   	pop    %ebp
c0107f9f:	c3                   	ret    

c0107fa0 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0107fa0:	55                   	push   %ebp
c0107fa1:	89 e5                	mov    %esp,%ebp
c0107fa3:	83 ec 28             	sub    $0x28,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0107fa6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107fa9:	33 45 14             	xor    0x14(%ebp),%eax
c0107fac:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107fb1:	85 c0                	test   %eax,%eax
c0107fb3:	74 19                	je     c0107fce <boot_map_segment+0x2e>
c0107fb5:	68 22 c4 10 c0       	push   $0xc010c422
c0107fba:	68 39 c4 10 c0       	push   $0xc010c439
c0107fbf:	68 08 01 00 00       	push   $0x108
c0107fc4:	68 14 c4 10 c0       	push   $0xc010c414
c0107fc9:	e8 9a 97 ff ff       	call   c0101768 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0107fce:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0107fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107fd8:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107fdd:	89 c2                	mov    %eax,%edx
c0107fdf:	8b 45 10             	mov    0x10(%ebp),%eax
c0107fe2:	01 c2                	add    %eax,%edx
c0107fe4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107fe7:	01 d0                	add    %edx,%eax
c0107fe9:	83 e8 01             	sub    $0x1,%eax
c0107fec:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107fef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107ff2:	ba 00 00 00 00       	mov    $0x0,%edx
c0107ff7:	f7 75 f0             	divl   -0x10(%ebp)
c0107ffa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107ffd:	29 d0                	sub    %edx,%eax
c0107fff:	c1 e8 0c             	shr    $0xc,%eax
c0108002:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0108005:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108008:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010800b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010800e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108013:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0108016:	8b 45 14             	mov    0x14(%ebp),%eax
c0108019:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010801c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010801f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108024:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0108027:	eb 57                	jmp    c0108080 <boot_map_segment+0xe0>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0108029:	83 ec 04             	sub    $0x4,%esp
c010802c:	6a 01                	push   $0x1
c010802e:	ff 75 0c             	pushl  0xc(%ebp)
c0108031:	ff 75 08             	pushl  0x8(%ebp)
c0108034:	e8 58 01 00 00       	call   c0108191 <get_pte>
c0108039:	83 c4 10             	add    $0x10,%esp
c010803c:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c010803f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0108043:	75 19                	jne    c010805e <boot_map_segment+0xbe>
c0108045:	68 4e c4 10 c0       	push   $0xc010c44e
c010804a:	68 39 c4 10 c0       	push   $0xc010c439
c010804f:	68 0e 01 00 00       	push   $0x10e
c0108054:	68 14 c4 10 c0       	push   $0xc010c414
c0108059:	e8 0a 97 ff ff       	call   c0101768 <__panic>
        *ptep = pa | PTE_P | perm;
c010805e:	8b 45 14             	mov    0x14(%ebp),%eax
c0108061:	0b 45 18             	or     0x18(%ebp),%eax
c0108064:	83 c8 01             	or     $0x1,%eax
c0108067:	89 c2                	mov    %eax,%edx
c0108069:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010806c:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010806e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0108072:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0108079:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0108080:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108084:	75 a3                	jne    c0108029 <boot_map_segment+0x89>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0108086:	90                   	nop
c0108087:	c9                   	leave  
c0108088:	c3                   	ret    

c0108089 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0108089:	55                   	push   %ebp
c010808a:	89 e5                	mov    %esp,%ebp
c010808c:	83 ec 18             	sub    $0x18,%esp
    struct Page *p = alloc_page();
c010808f:	83 ec 0c             	sub    $0xc,%esp
c0108092:	6a 01                	push   $0x1
c0108094:	e8 7c fa ff ff       	call   c0107b15 <alloc_pages>
c0108099:	83 c4 10             	add    $0x10,%esp
c010809c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c010809f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01080a3:	75 17                	jne    c01080bc <boot_alloc_page+0x33>
        panic("boot_alloc_page failed.\n");
c01080a5:	83 ec 04             	sub    $0x4,%esp
c01080a8:	68 5b c4 10 c0       	push   $0xc010c45b
c01080ad:	68 1a 01 00 00       	push   $0x11a
c01080b2:	68 14 c4 10 c0       	push   $0xc010c414
c01080b7:	e8 ac 96 ff ff       	call   c0101768 <__panic>
    }
    return page2kva(p);
c01080bc:	83 ec 0c             	sub    $0xc,%esp
c01080bf:	ff 75 f4             	pushl  -0xc(%ebp)
c01080c2:	e8 a5 f7 ff ff       	call   c010786c <page2kva>
c01080c7:	83 c4 10             	add    $0x10,%esp
}
c01080ca:	c9                   	leave  
c01080cb:	c3                   	ret    

c01080cc <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01080cc:	55                   	push   %ebp
c01080cd:	89 e5                	mov    %esp,%ebp
c01080cf:	83 ec 18             	sub    $0x18,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c01080d2:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c01080d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01080da:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01080e1:	77 17                	ja     c01080fa <pmm_init+0x2e>
c01080e3:	ff 75 f4             	pushl  -0xc(%ebp)
c01080e6:	68 f0 c3 10 c0       	push   $0xc010c3f0
c01080eb:	68 24 01 00 00       	push   $0x124
c01080f0:	68 14 c4 10 c0       	push   $0xc010c414
c01080f5:	e8 6e 96 ff ff       	call   c0101768 <__panic>
c01080fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080fd:	05 00 00 00 40       	add    $0x40000000,%eax
c0108102:	a3 3c d1 12 c0       	mov    %eax,0xc012d13c
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0108107:	e8 b5 f9 ff ff       	call   c0107ac1 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c010810c:	e8 d3 fa ff ff       	call   c0107be4 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0108111:	e8 3d 04 00 00       	call   c0108553 <check_alloc_page>

    check_pgdir();
c0108116:	e8 5b 04 00 00       	call   c0108576 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c010811b:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108120:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0108126:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c010812b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010812e:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0108135:	77 17                	ja     c010814e <pmm_init+0x82>
c0108137:	ff 75 f0             	pushl  -0x10(%ebp)
c010813a:	68 f0 c3 10 c0       	push   $0xc010c3f0
c010813f:	68 3a 01 00 00       	push   $0x13a
c0108144:	68 14 c4 10 c0       	push   $0xc010c414
c0108149:	e8 1a 96 ff ff       	call   c0101768 <__panic>
c010814e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108151:	05 00 00 00 40       	add    $0x40000000,%eax
c0108156:	83 c8 03             	or     $0x3,%eax
c0108159:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c010815b:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108160:	83 ec 0c             	sub    $0xc,%esp
c0108163:	6a 02                	push   $0x2
c0108165:	6a 00                	push   $0x0
c0108167:	68 00 00 00 38       	push   $0x38000000
c010816c:	68 00 00 00 c0       	push   $0xc0000000
c0108171:	50                   	push   %eax
c0108172:	e8 29 fe ff ff       	call   c0107fa0 <boot_map_segment>
c0108177:	83 c4 20             	add    $0x20,%esp

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c010817a:	e8 50 f8 ff ff       	call   c01079cf <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c010817f:	e8 58 09 00 00       	call   c0108adc <check_boot_pgdir>

    print_pgdir();
c0108184:	e8 4e 0d 00 00       	call   c0108ed7 <print_pgdir>
    
    kmalloc_init();
c0108189:	e8 3b df ff ff       	call   c01060c9 <kmalloc_init>

}
c010818e:	90                   	nop
c010818f:	c9                   	leave  
c0108190:	c3                   	ret    

c0108191 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0108191:	55                   	push   %ebp
c0108192:	89 e5                	mov    %esp,%ebp
c0108194:	83 ec 28             	sub    $0x28,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c0108197:	8b 45 0c             	mov    0xc(%ebp),%eax
c010819a:	c1 e8 16             	shr    $0x16,%eax
c010819d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01081a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01081a7:	01 d0                	add    %edx,%eax
c01081a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c01081ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081af:	8b 00                	mov    (%eax),%eax
c01081b1:	83 e0 01             	and    $0x1,%eax
c01081b4:	85 c0                	test   %eax,%eax
c01081b6:	0f 85 9f 00 00 00    	jne    c010825b <get_pte+0xca>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c01081bc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01081c0:	74 16                	je     c01081d8 <get_pte+0x47>
c01081c2:	83 ec 0c             	sub    $0xc,%esp
c01081c5:	6a 01                	push   $0x1
c01081c7:	e8 49 f9 ff ff       	call   c0107b15 <alloc_pages>
c01081cc:	83 c4 10             	add    $0x10,%esp
c01081cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01081d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01081d6:	75 0a                	jne    c01081e2 <get_pte+0x51>
            return NULL;
c01081d8:	b8 00 00 00 00       	mov    $0x0,%eax
c01081dd:	e9 ca 00 00 00       	jmp    c01082ac <get_pte+0x11b>
        }
        set_page_ref(page, 1);
c01081e2:	83 ec 08             	sub    $0x8,%esp
c01081e5:	6a 01                	push   $0x1
c01081e7:	ff 75 f0             	pushl  -0x10(%ebp)
c01081ea:	e8 22 f7 ff ff       	call   c0107911 <set_page_ref>
c01081ef:	83 c4 10             	add    $0x10,%esp
        uintptr_t pa = page2pa(page);
c01081f2:	83 ec 0c             	sub    $0xc,%esp
c01081f5:	ff 75 f0             	pushl  -0x10(%ebp)
c01081f8:	e8 15 f6 ff ff       	call   c0107812 <page2pa>
c01081fd:	83 c4 10             	add    $0x10,%esp
c0108200:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0108203:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108206:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108209:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010820c:	c1 e8 0c             	shr    $0xc,%eax
c010820f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108212:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c0108217:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010821a:	72 17                	jb     c0108233 <get_pte+0xa2>
c010821c:	ff 75 e8             	pushl  -0x18(%ebp)
c010821f:	68 4c c3 10 c0       	push   $0xc010c34c
c0108224:	68 82 01 00 00       	push   $0x182
c0108229:	68 14 c4 10 c0       	push   $0xc010c414
c010822e:	e8 35 95 ff ff       	call   c0101768 <__panic>
c0108233:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108236:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010823b:	83 ec 04             	sub    $0x4,%esp
c010823e:	68 00 10 00 00       	push   $0x1000
c0108243:	6a 00                	push   $0x0
c0108245:	50                   	push   %eax
c0108246:	e8 fe 1d 00 00       	call   c010a049 <memset>
c010824b:	83 c4 10             	add    $0x10,%esp
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c010824e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108251:	83 c8 07             	or     $0x7,%eax
c0108254:	89 c2                	mov    %eax,%edx
c0108256:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108259:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c010825b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010825e:	8b 00                	mov    (%eax),%eax
c0108260:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108265:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108268:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010826b:	c1 e8 0c             	shr    $0xc,%eax
c010826e:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0108271:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c0108276:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0108279:	72 17                	jb     c0108292 <get_pte+0x101>
c010827b:	ff 75 e0             	pushl  -0x20(%ebp)
c010827e:	68 4c c3 10 c0       	push   $0xc010c34c
c0108283:	68 85 01 00 00       	push   $0x185
c0108288:	68 14 c4 10 c0       	push   $0xc010c414
c010828d:	e8 d6 94 ff ff       	call   c0101768 <__panic>
c0108292:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108295:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010829a:	89 c2                	mov    %eax,%edx
c010829c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010829f:	c1 e8 0c             	shr    $0xc,%eax
c01082a2:	25 ff 03 00 00       	and    $0x3ff,%eax
c01082a7:	c1 e0 02             	shl    $0x2,%eax
c01082aa:	01 d0                	add    %edx,%eax
}
c01082ac:	c9                   	leave  
c01082ad:	c3                   	ret    

c01082ae <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01082ae:	55                   	push   %ebp
c01082af:	89 e5                	mov    %esp,%ebp
c01082b1:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01082b4:	83 ec 04             	sub    $0x4,%esp
c01082b7:	6a 00                	push   $0x0
c01082b9:	ff 75 0c             	pushl  0xc(%ebp)
c01082bc:	ff 75 08             	pushl  0x8(%ebp)
c01082bf:	e8 cd fe ff ff       	call   c0108191 <get_pte>
c01082c4:	83 c4 10             	add    $0x10,%esp
c01082c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01082ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01082ce:	74 08                	je     c01082d8 <get_page+0x2a>
        *ptep_store = ptep;
c01082d0:	8b 45 10             	mov    0x10(%ebp),%eax
c01082d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01082d6:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01082d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01082dc:	74 1f                	je     c01082fd <get_page+0x4f>
c01082de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082e1:	8b 00                	mov    (%eax),%eax
c01082e3:	83 e0 01             	and    $0x1,%eax
c01082e6:	85 c0                	test   %eax,%eax
c01082e8:	74 13                	je     c01082fd <get_page+0x4f>
        return pte2page(*ptep);
c01082ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082ed:	8b 00                	mov    (%eax),%eax
c01082ef:	83 ec 0c             	sub    $0xc,%esp
c01082f2:	50                   	push   %eax
c01082f3:	e8 b9 f5 ff ff       	call   c01078b1 <pte2page>
c01082f8:	83 c4 10             	add    $0x10,%esp
c01082fb:	eb 05                	jmp    c0108302 <get_page+0x54>
    }
    return NULL;
c01082fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108302:	c9                   	leave  
c0108303:	c3                   	ret    

c0108304 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0108304:	55                   	push   %ebp
c0108305:	89 e5                	mov    %esp,%ebp
c0108307:	83 ec 18             	sub    $0x18,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c010830a:	8b 45 10             	mov    0x10(%ebp),%eax
c010830d:	8b 00                	mov    (%eax),%eax
c010830f:	83 e0 01             	and    $0x1,%eax
c0108312:	85 c0                	test   %eax,%eax
c0108314:	74 50                	je     c0108366 <page_remove_pte+0x62>
        struct Page *page = pte2page(*ptep);
c0108316:	8b 45 10             	mov    0x10(%ebp),%eax
c0108319:	8b 00                	mov    (%eax),%eax
c010831b:	83 ec 0c             	sub    $0xc,%esp
c010831e:	50                   	push   %eax
c010831f:	e8 8d f5 ff ff       	call   c01078b1 <pte2page>
c0108324:	83 c4 10             	add    $0x10,%esp
c0108327:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c010832a:	83 ec 0c             	sub    $0xc,%esp
c010832d:	ff 75 f4             	pushl  -0xc(%ebp)
c0108330:	e8 01 f6 ff ff       	call   c0107936 <page_ref_dec>
c0108335:	83 c4 10             	add    $0x10,%esp
c0108338:	85 c0                	test   %eax,%eax
c010833a:	75 10                	jne    c010834c <page_remove_pte+0x48>
            free_page(page);
c010833c:	83 ec 08             	sub    $0x8,%esp
c010833f:	6a 01                	push   $0x1
c0108341:	ff 75 f4             	pushl  -0xc(%ebp)
c0108344:	e8 38 f8 ff ff       	call   c0107b81 <free_pages>
c0108349:	83 c4 10             	add    $0x10,%esp
        }
        *ptep = 0;
c010834c:	8b 45 10             	mov    0x10(%ebp),%eax
c010834f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0108355:	83 ec 08             	sub    $0x8,%esp
c0108358:	ff 75 0c             	pushl  0xc(%ebp)
c010835b:	ff 75 08             	pushl  0x8(%ebp)
c010835e:	e8 f8 00 00 00       	call   c010845b <tlb_invalidate>
c0108363:	83 c4 10             	add    $0x10,%esp
    }
}
c0108366:	90                   	nop
c0108367:	c9                   	leave  
c0108368:	c3                   	ret    

c0108369 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0108369:	55                   	push   %ebp
c010836a:	89 e5                	mov    %esp,%ebp
c010836c:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010836f:	83 ec 04             	sub    $0x4,%esp
c0108372:	6a 00                	push   $0x0
c0108374:	ff 75 0c             	pushl  0xc(%ebp)
c0108377:	ff 75 08             	pushl  0x8(%ebp)
c010837a:	e8 12 fe ff ff       	call   c0108191 <get_pte>
c010837f:	83 c4 10             	add    $0x10,%esp
c0108382:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0108385:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108389:	74 14                	je     c010839f <page_remove+0x36>
        page_remove_pte(pgdir, la, ptep);
c010838b:	83 ec 04             	sub    $0x4,%esp
c010838e:	ff 75 f4             	pushl  -0xc(%ebp)
c0108391:	ff 75 0c             	pushl  0xc(%ebp)
c0108394:	ff 75 08             	pushl  0x8(%ebp)
c0108397:	e8 68 ff ff ff       	call   c0108304 <page_remove_pte>
c010839c:	83 c4 10             	add    $0x10,%esp
    }
}
c010839f:	90                   	nop
c01083a0:	c9                   	leave  
c01083a1:	c3                   	ret    

c01083a2 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01083a2:	55                   	push   %ebp
c01083a3:	89 e5                	mov    %esp,%ebp
c01083a5:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01083a8:	83 ec 04             	sub    $0x4,%esp
c01083ab:	6a 01                	push   $0x1
c01083ad:	ff 75 10             	pushl  0x10(%ebp)
c01083b0:	ff 75 08             	pushl  0x8(%ebp)
c01083b3:	e8 d9 fd ff ff       	call   c0108191 <get_pte>
c01083b8:	83 c4 10             	add    $0x10,%esp
c01083bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01083be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01083c2:	75 0a                	jne    c01083ce <page_insert+0x2c>
        return -E_NO_MEM;
c01083c4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01083c9:	e9 8b 00 00 00       	jmp    c0108459 <page_insert+0xb7>
    }
    page_ref_inc(page);
c01083ce:	83 ec 0c             	sub    $0xc,%esp
c01083d1:	ff 75 0c             	pushl  0xc(%ebp)
c01083d4:	e8 46 f5 ff ff       	call   c010791f <page_ref_inc>
c01083d9:	83 c4 10             	add    $0x10,%esp
    if (*ptep & PTE_P) {
c01083dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083df:	8b 00                	mov    (%eax),%eax
c01083e1:	83 e0 01             	and    $0x1,%eax
c01083e4:	85 c0                	test   %eax,%eax
c01083e6:	74 40                	je     c0108428 <page_insert+0x86>
        struct Page *p = pte2page(*ptep);
c01083e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083eb:	8b 00                	mov    (%eax),%eax
c01083ed:	83 ec 0c             	sub    $0xc,%esp
c01083f0:	50                   	push   %eax
c01083f1:	e8 bb f4 ff ff       	call   c01078b1 <pte2page>
c01083f6:	83 c4 10             	add    $0x10,%esp
c01083f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c01083fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01083ff:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108402:	75 10                	jne    c0108414 <page_insert+0x72>
            page_ref_dec(page);
c0108404:	83 ec 0c             	sub    $0xc,%esp
c0108407:	ff 75 0c             	pushl  0xc(%ebp)
c010840a:	e8 27 f5 ff ff       	call   c0107936 <page_ref_dec>
c010840f:	83 c4 10             	add    $0x10,%esp
c0108412:	eb 14                	jmp    c0108428 <page_insert+0x86>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0108414:	83 ec 04             	sub    $0x4,%esp
c0108417:	ff 75 f4             	pushl  -0xc(%ebp)
c010841a:	ff 75 10             	pushl  0x10(%ebp)
c010841d:	ff 75 08             	pushl  0x8(%ebp)
c0108420:	e8 df fe ff ff       	call   c0108304 <page_remove_pte>
c0108425:	83 c4 10             	add    $0x10,%esp
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0108428:	83 ec 0c             	sub    $0xc,%esp
c010842b:	ff 75 0c             	pushl  0xc(%ebp)
c010842e:	e8 df f3 ff ff       	call   c0107812 <page2pa>
c0108433:	83 c4 10             	add    $0x10,%esp
c0108436:	0b 45 14             	or     0x14(%ebp),%eax
c0108439:	83 c8 01             	or     $0x1,%eax
c010843c:	89 c2                	mov    %eax,%edx
c010843e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108441:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0108443:	83 ec 08             	sub    $0x8,%esp
c0108446:	ff 75 10             	pushl  0x10(%ebp)
c0108449:	ff 75 08             	pushl  0x8(%ebp)
c010844c:	e8 0a 00 00 00       	call   c010845b <tlb_invalidate>
c0108451:	83 c4 10             	add    $0x10,%esp
    return 0;
c0108454:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108459:	c9                   	leave  
c010845a:	c3                   	ret    

c010845b <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c010845b:	55                   	push   %ebp
c010845c:	89 e5                	mov    %esp,%ebp
c010845e:	83 ec 18             	sub    $0x18,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0108461:	0f 20 d8             	mov    %cr3,%eax
c0108464:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
c0108467:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c010846a:	8b 45 08             	mov    0x8(%ebp),%eax
c010846d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108470:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0108477:	77 17                	ja     c0108490 <tlb_invalidate+0x35>
c0108479:	ff 75 f0             	pushl  -0x10(%ebp)
c010847c:	68 f0 c3 10 c0       	push   $0xc010c3f0
c0108481:	68 e7 01 00 00       	push   $0x1e7
c0108486:	68 14 c4 10 c0       	push   $0xc010c414
c010848b:	e8 d8 92 ff ff       	call   c0101768 <__panic>
c0108490:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108493:	05 00 00 00 40       	add    $0x40000000,%eax
c0108498:	39 c2                	cmp    %eax,%edx
c010849a:	75 0c                	jne    c01084a8 <tlb_invalidate+0x4d>
        invlpg((void *)la);
c010849c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010849f:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01084a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084a5:	0f 01 38             	invlpg (%eax)
    }
}
c01084a8:	90                   	nop
c01084a9:	c9                   	leave  
c01084aa:	c3                   	ret    

c01084ab <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c01084ab:	55                   	push   %ebp
c01084ac:	89 e5                	mov    %esp,%ebp
c01084ae:	83 ec 18             	sub    $0x18,%esp
    struct Page *page = alloc_page();
c01084b1:	83 ec 0c             	sub    $0xc,%esp
c01084b4:	6a 01                	push   $0x1
c01084b6:	e8 5a f6 ff ff       	call   c0107b15 <alloc_pages>
c01084bb:	83 c4 10             	add    $0x10,%esp
c01084be:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c01084c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01084c5:	0f 84 83 00 00 00    	je     c010854e <pgdir_alloc_page+0xa3>
        if (page_insert(pgdir, page, la, perm) != 0) {
c01084cb:	ff 75 10             	pushl  0x10(%ebp)
c01084ce:	ff 75 0c             	pushl  0xc(%ebp)
c01084d1:	ff 75 f4             	pushl  -0xc(%ebp)
c01084d4:	ff 75 08             	pushl  0x8(%ebp)
c01084d7:	e8 c6 fe ff ff       	call   c01083a2 <page_insert>
c01084dc:	83 c4 10             	add    $0x10,%esp
c01084df:	85 c0                	test   %eax,%eax
c01084e1:	74 17                	je     c01084fa <pgdir_alloc_page+0x4f>
            free_page(page);
c01084e3:	83 ec 08             	sub    $0x8,%esp
c01084e6:	6a 01                	push   $0x1
c01084e8:	ff 75 f4             	pushl  -0xc(%ebp)
c01084eb:	e8 91 f6 ff ff       	call   c0107b81 <free_pages>
c01084f0:	83 c4 10             	add    $0x10,%esp
            return NULL;
c01084f3:	b8 00 00 00 00       	mov    $0x0,%eax
c01084f8:	eb 57                	jmp    c0108551 <pgdir_alloc_page+0xa6>
        }
        if (swap_init_ok){
c01084fa:	a1 68 af 12 c0       	mov    0xc012af68,%eax
c01084ff:	85 c0                	test   %eax,%eax
c0108501:	74 4b                	je     c010854e <pgdir_alloc_page+0xa3>
            swap_map_swappable(check_mm_struct, la, page, 0);
c0108503:	a1 58 d0 12 c0       	mov    0xc012d058,%eax
c0108508:	6a 00                	push   $0x0
c010850a:	ff 75 f4             	pushl  -0xc(%ebp)
c010850d:	ff 75 0c             	pushl  0xc(%ebp)
c0108510:	50                   	push   %eax
c0108511:	e8 72 cd ff ff       	call   c0105288 <swap_map_swappable>
c0108516:	83 c4 10             	add    $0x10,%esp
            page->pra_vaddr=la;
c0108519:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010851c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010851f:	89 50 20             	mov    %edx,0x20(%eax)
            assert(page_ref(page) == 1);
c0108522:	83 ec 0c             	sub    $0xc,%esp
c0108525:	ff 75 f4             	pushl  -0xc(%ebp)
c0108528:	e8 da f3 ff ff       	call   c0107907 <page_ref>
c010852d:	83 c4 10             	add    $0x10,%esp
c0108530:	83 f8 01             	cmp    $0x1,%eax
c0108533:	74 19                	je     c010854e <pgdir_alloc_page+0xa3>
c0108535:	68 74 c4 10 c0       	push   $0xc010c474
c010853a:	68 39 c4 10 c0       	push   $0xc010c439
c010853f:	68 fa 01 00 00       	push   $0x1fa
c0108544:	68 14 c4 10 c0       	push   $0xc010c414
c0108549:	e8 1a 92 ff ff       	call   c0101768 <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c010854e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108551:	c9                   	leave  
c0108552:	c3                   	ret    

c0108553 <check_alloc_page>:

static void
check_alloc_page(void) {
c0108553:	55                   	push   %ebp
c0108554:	89 e5                	mov    %esp,%ebp
c0108556:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->check();
c0108559:	a1 38 d1 12 c0       	mov    0xc012d138,%eax
c010855e:	8b 40 18             	mov    0x18(%eax),%eax
c0108561:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0108563:	83 ec 0c             	sub    $0xc,%esp
c0108566:	68 88 c4 10 c0       	push   $0xc010c488
c010856b:	e8 1a 7d ff ff       	call   c010028a <cprintf>
c0108570:	83 c4 10             	add    $0x10,%esp
}
c0108573:	90                   	nop
c0108574:	c9                   	leave  
c0108575:	c3                   	ret    

c0108576 <check_pgdir>:

static void
check_pgdir(void) {
c0108576:	55                   	push   %ebp
c0108577:	89 e5                	mov    %esp,%ebp
c0108579:	83 ec 28             	sub    $0x28,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c010857c:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c0108581:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0108586:	76 19                	jbe    c01085a1 <check_pgdir+0x2b>
c0108588:	68 a7 c4 10 c0       	push   $0xc010c4a7
c010858d:	68 39 c4 10 c0       	push   $0xc010c439
c0108592:	68 0b 02 00 00       	push   $0x20b
c0108597:	68 14 c4 10 c0       	push   $0xc010c414
c010859c:	e8 c7 91 ff ff       	call   c0101768 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01085a1:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c01085a6:	85 c0                	test   %eax,%eax
c01085a8:	74 0e                	je     c01085b8 <check_pgdir+0x42>
c01085aa:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c01085af:	25 ff 0f 00 00       	and    $0xfff,%eax
c01085b4:	85 c0                	test   %eax,%eax
c01085b6:	74 19                	je     c01085d1 <check_pgdir+0x5b>
c01085b8:	68 c4 c4 10 c0       	push   $0xc010c4c4
c01085bd:	68 39 c4 10 c0       	push   $0xc010c439
c01085c2:	68 0c 02 00 00       	push   $0x20c
c01085c7:	68 14 c4 10 c0       	push   $0xc010c414
c01085cc:	e8 97 91 ff ff       	call   c0101768 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01085d1:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c01085d6:	83 ec 04             	sub    $0x4,%esp
c01085d9:	6a 00                	push   $0x0
c01085db:	6a 00                	push   $0x0
c01085dd:	50                   	push   %eax
c01085de:	e8 cb fc ff ff       	call   c01082ae <get_page>
c01085e3:	83 c4 10             	add    $0x10,%esp
c01085e6:	85 c0                	test   %eax,%eax
c01085e8:	74 19                	je     c0108603 <check_pgdir+0x8d>
c01085ea:	68 fc c4 10 c0       	push   $0xc010c4fc
c01085ef:	68 39 c4 10 c0       	push   $0xc010c439
c01085f4:	68 0d 02 00 00       	push   $0x20d
c01085f9:	68 14 c4 10 c0       	push   $0xc010c414
c01085fe:	e8 65 91 ff ff       	call   c0101768 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0108603:	83 ec 0c             	sub    $0xc,%esp
c0108606:	6a 01                	push   $0x1
c0108608:	e8 08 f5 ff ff       	call   c0107b15 <alloc_pages>
c010860d:	83 c4 10             	add    $0x10,%esp
c0108610:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0108613:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108618:	6a 00                	push   $0x0
c010861a:	6a 00                	push   $0x0
c010861c:	ff 75 f4             	pushl  -0xc(%ebp)
c010861f:	50                   	push   %eax
c0108620:	e8 7d fd ff ff       	call   c01083a2 <page_insert>
c0108625:	83 c4 10             	add    $0x10,%esp
c0108628:	85 c0                	test   %eax,%eax
c010862a:	74 19                	je     c0108645 <check_pgdir+0xcf>
c010862c:	68 24 c5 10 c0       	push   $0xc010c524
c0108631:	68 39 c4 10 c0       	push   $0xc010c439
c0108636:	68 11 02 00 00       	push   $0x211
c010863b:	68 14 c4 10 c0       	push   $0xc010c414
c0108640:	e8 23 91 ff ff       	call   c0101768 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0108645:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c010864a:	83 ec 04             	sub    $0x4,%esp
c010864d:	6a 00                	push   $0x0
c010864f:	6a 00                	push   $0x0
c0108651:	50                   	push   %eax
c0108652:	e8 3a fb ff ff       	call   c0108191 <get_pte>
c0108657:	83 c4 10             	add    $0x10,%esp
c010865a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010865d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108661:	75 19                	jne    c010867c <check_pgdir+0x106>
c0108663:	68 50 c5 10 c0       	push   $0xc010c550
c0108668:	68 39 c4 10 c0       	push   $0xc010c439
c010866d:	68 14 02 00 00       	push   $0x214
c0108672:	68 14 c4 10 c0       	push   $0xc010c414
c0108677:	e8 ec 90 ff ff       	call   c0101768 <__panic>
    assert(pte2page(*ptep) == p1);
c010867c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010867f:	8b 00                	mov    (%eax),%eax
c0108681:	83 ec 0c             	sub    $0xc,%esp
c0108684:	50                   	push   %eax
c0108685:	e8 27 f2 ff ff       	call   c01078b1 <pte2page>
c010868a:	83 c4 10             	add    $0x10,%esp
c010868d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0108690:	74 19                	je     c01086ab <check_pgdir+0x135>
c0108692:	68 7d c5 10 c0       	push   $0xc010c57d
c0108697:	68 39 c4 10 c0       	push   $0xc010c439
c010869c:	68 15 02 00 00       	push   $0x215
c01086a1:	68 14 c4 10 c0       	push   $0xc010c414
c01086a6:	e8 bd 90 ff ff       	call   c0101768 <__panic>
    assert(page_ref(p1) == 1);
c01086ab:	83 ec 0c             	sub    $0xc,%esp
c01086ae:	ff 75 f4             	pushl  -0xc(%ebp)
c01086b1:	e8 51 f2 ff ff       	call   c0107907 <page_ref>
c01086b6:	83 c4 10             	add    $0x10,%esp
c01086b9:	83 f8 01             	cmp    $0x1,%eax
c01086bc:	74 19                	je     c01086d7 <check_pgdir+0x161>
c01086be:	68 93 c5 10 c0       	push   $0xc010c593
c01086c3:	68 39 c4 10 c0       	push   $0xc010c439
c01086c8:	68 16 02 00 00       	push   $0x216
c01086cd:	68 14 c4 10 c0       	push   $0xc010c414
c01086d2:	e8 91 90 ff ff       	call   c0101768 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01086d7:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c01086dc:	8b 00                	mov    (%eax),%eax
c01086de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01086e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01086e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01086e9:	c1 e8 0c             	shr    $0xc,%eax
c01086ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01086ef:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c01086f4:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01086f7:	72 17                	jb     c0108710 <check_pgdir+0x19a>
c01086f9:	ff 75 ec             	pushl  -0x14(%ebp)
c01086fc:	68 4c c3 10 c0       	push   $0xc010c34c
c0108701:	68 18 02 00 00       	push   $0x218
c0108706:	68 14 c4 10 c0       	push   $0xc010c414
c010870b:	e8 58 90 ff ff       	call   c0101768 <__panic>
c0108710:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108713:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0108718:	83 c0 04             	add    $0x4,%eax
c010871b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c010871e:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108723:	83 ec 04             	sub    $0x4,%esp
c0108726:	6a 00                	push   $0x0
c0108728:	68 00 10 00 00       	push   $0x1000
c010872d:	50                   	push   %eax
c010872e:	e8 5e fa ff ff       	call   c0108191 <get_pte>
c0108733:	83 c4 10             	add    $0x10,%esp
c0108736:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108739:	74 19                	je     c0108754 <check_pgdir+0x1de>
c010873b:	68 a8 c5 10 c0       	push   $0xc010c5a8
c0108740:	68 39 c4 10 c0       	push   $0xc010c439
c0108745:	68 19 02 00 00       	push   $0x219
c010874a:	68 14 c4 10 c0       	push   $0xc010c414
c010874f:	e8 14 90 ff ff       	call   c0101768 <__panic>

    p2 = alloc_page();
c0108754:	83 ec 0c             	sub    $0xc,%esp
c0108757:	6a 01                	push   $0x1
c0108759:	e8 b7 f3 ff ff       	call   c0107b15 <alloc_pages>
c010875e:	83 c4 10             	add    $0x10,%esp
c0108761:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0108764:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108769:	6a 06                	push   $0x6
c010876b:	68 00 10 00 00       	push   $0x1000
c0108770:	ff 75 e4             	pushl  -0x1c(%ebp)
c0108773:	50                   	push   %eax
c0108774:	e8 29 fc ff ff       	call   c01083a2 <page_insert>
c0108779:	83 c4 10             	add    $0x10,%esp
c010877c:	85 c0                	test   %eax,%eax
c010877e:	74 19                	je     c0108799 <check_pgdir+0x223>
c0108780:	68 d0 c5 10 c0       	push   $0xc010c5d0
c0108785:	68 39 c4 10 c0       	push   $0xc010c439
c010878a:	68 1c 02 00 00       	push   $0x21c
c010878f:	68 14 c4 10 c0       	push   $0xc010c414
c0108794:	e8 cf 8f ff ff       	call   c0101768 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0108799:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c010879e:	83 ec 04             	sub    $0x4,%esp
c01087a1:	6a 00                	push   $0x0
c01087a3:	68 00 10 00 00       	push   $0x1000
c01087a8:	50                   	push   %eax
c01087a9:	e8 e3 f9 ff ff       	call   c0108191 <get_pte>
c01087ae:	83 c4 10             	add    $0x10,%esp
c01087b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01087b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01087b8:	75 19                	jne    c01087d3 <check_pgdir+0x25d>
c01087ba:	68 08 c6 10 c0       	push   $0xc010c608
c01087bf:	68 39 c4 10 c0       	push   $0xc010c439
c01087c4:	68 1d 02 00 00       	push   $0x21d
c01087c9:	68 14 c4 10 c0       	push   $0xc010c414
c01087ce:	e8 95 8f ff ff       	call   c0101768 <__panic>
    assert(*ptep & PTE_U);
c01087d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01087d6:	8b 00                	mov    (%eax),%eax
c01087d8:	83 e0 04             	and    $0x4,%eax
c01087db:	85 c0                	test   %eax,%eax
c01087dd:	75 19                	jne    c01087f8 <check_pgdir+0x282>
c01087df:	68 38 c6 10 c0       	push   $0xc010c638
c01087e4:	68 39 c4 10 c0       	push   $0xc010c439
c01087e9:	68 1e 02 00 00       	push   $0x21e
c01087ee:	68 14 c4 10 c0       	push   $0xc010c414
c01087f3:	e8 70 8f ff ff       	call   c0101768 <__panic>
    assert(*ptep & PTE_W);
c01087f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01087fb:	8b 00                	mov    (%eax),%eax
c01087fd:	83 e0 02             	and    $0x2,%eax
c0108800:	85 c0                	test   %eax,%eax
c0108802:	75 19                	jne    c010881d <check_pgdir+0x2a7>
c0108804:	68 46 c6 10 c0       	push   $0xc010c646
c0108809:	68 39 c4 10 c0       	push   $0xc010c439
c010880e:	68 1f 02 00 00       	push   $0x21f
c0108813:	68 14 c4 10 c0       	push   $0xc010c414
c0108818:	e8 4b 8f ff ff       	call   c0101768 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c010881d:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108822:	8b 00                	mov    (%eax),%eax
c0108824:	83 e0 04             	and    $0x4,%eax
c0108827:	85 c0                	test   %eax,%eax
c0108829:	75 19                	jne    c0108844 <check_pgdir+0x2ce>
c010882b:	68 54 c6 10 c0       	push   $0xc010c654
c0108830:	68 39 c4 10 c0       	push   $0xc010c439
c0108835:	68 20 02 00 00       	push   $0x220
c010883a:	68 14 c4 10 c0       	push   $0xc010c414
c010883f:	e8 24 8f ff ff       	call   c0101768 <__panic>
    assert(page_ref(p2) == 1);
c0108844:	83 ec 0c             	sub    $0xc,%esp
c0108847:	ff 75 e4             	pushl  -0x1c(%ebp)
c010884a:	e8 b8 f0 ff ff       	call   c0107907 <page_ref>
c010884f:	83 c4 10             	add    $0x10,%esp
c0108852:	83 f8 01             	cmp    $0x1,%eax
c0108855:	74 19                	je     c0108870 <check_pgdir+0x2fa>
c0108857:	68 6a c6 10 c0       	push   $0xc010c66a
c010885c:	68 39 c4 10 c0       	push   $0xc010c439
c0108861:	68 21 02 00 00       	push   $0x221
c0108866:	68 14 c4 10 c0       	push   $0xc010c414
c010886b:	e8 f8 8e ff ff       	call   c0101768 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0108870:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108875:	6a 00                	push   $0x0
c0108877:	68 00 10 00 00       	push   $0x1000
c010887c:	ff 75 f4             	pushl  -0xc(%ebp)
c010887f:	50                   	push   %eax
c0108880:	e8 1d fb ff ff       	call   c01083a2 <page_insert>
c0108885:	83 c4 10             	add    $0x10,%esp
c0108888:	85 c0                	test   %eax,%eax
c010888a:	74 19                	je     c01088a5 <check_pgdir+0x32f>
c010888c:	68 7c c6 10 c0       	push   $0xc010c67c
c0108891:	68 39 c4 10 c0       	push   $0xc010c439
c0108896:	68 23 02 00 00       	push   $0x223
c010889b:	68 14 c4 10 c0       	push   $0xc010c414
c01088a0:	e8 c3 8e ff ff       	call   c0101768 <__panic>
    assert(page_ref(p1) == 2);
c01088a5:	83 ec 0c             	sub    $0xc,%esp
c01088a8:	ff 75 f4             	pushl  -0xc(%ebp)
c01088ab:	e8 57 f0 ff ff       	call   c0107907 <page_ref>
c01088b0:	83 c4 10             	add    $0x10,%esp
c01088b3:	83 f8 02             	cmp    $0x2,%eax
c01088b6:	74 19                	je     c01088d1 <check_pgdir+0x35b>
c01088b8:	68 a8 c6 10 c0       	push   $0xc010c6a8
c01088bd:	68 39 c4 10 c0       	push   $0xc010c439
c01088c2:	68 24 02 00 00       	push   $0x224
c01088c7:	68 14 c4 10 c0       	push   $0xc010c414
c01088cc:	e8 97 8e ff ff       	call   c0101768 <__panic>
    assert(page_ref(p2) == 0);
c01088d1:	83 ec 0c             	sub    $0xc,%esp
c01088d4:	ff 75 e4             	pushl  -0x1c(%ebp)
c01088d7:	e8 2b f0 ff ff       	call   c0107907 <page_ref>
c01088dc:	83 c4 10             	add    $0x10,%esp
c01088df:	85 c0                	test   %eax,%eax
c01088e1:	74 19                	je     c01088fc <check_pgdir+0x386>
c01088e3:	68 ba c6 10 c0       	push   $0xc010c6ba
c01088e8:	68 39 c4 10 c0       	push   $0xc010c439
c01088ed:	68 25 02 00 00       	push   $0x225
c01088f2:	68 14 c4 10 c0       	push   $0xc010c414
c01088f7:	e8 6c 8e ff ff       	call   c0101768 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01088fc:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108901:	83 ec 04             	sub    $0x4,%esp
c0108904:	6a 00                	push   $0x0
c0108906:	68 00 10 00 00       	push   $0x1000
c010890b:	50                   	push   %eax
c010890c:	e8 80 f8 ff ff       	call   c0108191 <get_pte>
c0108911:	83 c4 10             	add    $0x10,%esp
c0108914:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108917:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010891b:	75 19                	jne    c0108936 <check_pgdir+0x3c0>
c010891d:	68 08 c6 10 c0       	push   $0xc010c608
c0108922:	68 39 c4 10 c0       	push   $0xc010c439
c0108927:	68 26 02 00 00       	push   $0x226
c010892c:	68 14 c4 10 c0       	push   $0xc010c414
c0108931:	e8 32 8e ff ff       	call   c0101768 <__panic>
    assert(pte2page(*ptep) == p1);
c0108936:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108939:	8b 00                	mov    (%eax),%eax
c010893b:	83 ec 0c             	sub    $0xc,%esp
c010893e:	50                   	push   %eax
c010893f:	e8 6d ef ff ff       	call   c01078b1 <pte2page>
c0108944:	83 c4 10             	add    $0x10,%esp
c0108947:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010894a:	74 19                	je     c0108965 <check_pgdir+0x3ef>
c010894c:	68 7d c5 10 c0       	push   $0xc010c57d
c0108951:	68 39 c4 10 c0       	push   $0xc010c439
c0108956:	68 27 02 00 00       	push   $0x227
c010895b:	68 14 c4 10 c0       	push   $0xc010c414
c0108960:	e8 03 8e ff ff       	call   c0101768 <__panic>
    assert((*ptep & PTE_U) == 0);
c0108965:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108968:	8b 00                	mov    (%eax),%eax
c010896a:	83 e0 04             	and    $0x4,%eax
c010896d:	85 c0                	test   %eax,%eax
c010896f:	74 19                	je     c010898a <check_pgdir+0x414>
c0108971:	68 cc c6 10 c0       	push   $0xc010c6cc
c0108976:	68 39 c4 10 c0       	push   $0xc010c439
c010897b:	68 28 02 00 00       	push   $0x228
c0108980:	68 14 c4 10 c0       	push   $0xc010c414
c0108985:	e8 de 8d ff ff       	call   c0101768 <__panic>

    page_remove(boot_pgdir, 0x0);
c010898a:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c010898f:	83 ec 08             	sub    $0x8,%esp
c0108992:	6a 00                	push   $0x0
c0108994:	50                   	push   %eax
c0108995:	e8 cf f9 ff ff       	call   c0108369 <page_remove>
c010899a:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 1);
c010899d:	83 ec 0c             	sub    $0xc,%esp
c01089a0:	ff 75 f4             	pushl  -0xc(%ebp)
c01089a3:	e8 5f ef ff ff       	call   c0107907 <page_ref>
c01089a8:	83 c4 10             	add    $0x10,%esp
c01089ab:	83 f8 01             	cmp    $0x1,%eax
c01089ae:	74 19                	je     c01089c9 <check_pgdir+0x453>
c01089b0:	68 93 c5 10 c0       	push   $0xc010c593
c01089b5:	68 39 c4 10 c0       	push   $0xc010c439
c01089ba:	68 2b 02 00 00       	push   $0x22b
c01089bf:	68 14 c4 10 c0       	push   $0xc010c414
c01089c4:	e8 9f 8d ff ff       	call   c0101768 <__panic>
    assert(page_ref(p2) == 0);
c01089c9:	83 ec 0c             	sub    $0xc,%esp
c01089cc:	ff 75 e4             	pushl  -0x1c(%ebp)
c01089cf:	e8 33 ef ff ff       	call   c0107907 <page_ref>
c01089d4:	83 c4 10             	add    $0x10,%esp
c01089d7:	85 c0                	test   %eax,%eax
c01089d9:	74 19                	je     c01089f4 <check_pgdir+0x47e>
c01089db:	68 ba c6 10 c0       	push   $0xc010c6ba
c01089e0:	68 39 c4 10 c0       	push   $0xc010c439
c01089e5:	68 2c 02 00 00       	push   $0x22c
c01089ea:	68 14 c4 10 c0       	push   $0xc010c414
c01089ef:	e8 74 8d ff ff       	call   c0101768 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c01089f4:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c01089f9:	83 ec 08             	sub    $0x8,%esp
c01089fc:	68 00 10 00 00       	push   $0x1000
c0108a01:	50                   	push   %eax
c0108a02:	e8 62 f9 ff ff       	call   c0108369 <page_remove>
c0108a07:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 0);
c0108a0a:	83 ec 0c             	sub    $0xc,%esp
c0108a0d:	ff 75 f4             	pushl  -0xc(%ebp)
c0108a10:	e8 f2 ee ff ff       	call   c0107907 <page_ref>
c0108a15:	83 c4 10             	add    $0x10,%esp
c0108a18:	85 c0                	test   %eax,%eax
c0108a1a:	74 19                	je     c0108a35 <check_pgdir+0x4bf>
c0108a1c:	68 e1 c6 10 c0       	push   $0xc010c6e1
c0108a21:	68 39 c4 10 c0       	push   $0xc010c439
c0108a26:	68 2f 02 00 00       	push   $0x22f
c0108a2b:	68 14 c4 10 c0       	push   $0xc010c414
c0108a30:	e8 33 8d ff ff       	call   c0101768 <__panic>
    assert(page_ref(p2) == 0);
c0108a35:	83 ec 0c             	sub    $0xc,%esp
c0108a38:	ff 75 e4             	pushl  -0x1c(%ebp)
c0108a3b:	e8 c7 ee ff ff       	call   c0107907 <page_ref>
c0108a40:	83 c4 10             	add    $0x10,%esp
c0108a43:	85 c0                	test   %eax,%eax
c0108a45:	74 19                	je     c0108a60 <check_pgdir+0x4ea>
c0108a47:	68 ba c6 10 c0       	push   $0xc010c6ba
c0108a4c:	68 39 c4 10 c0       	push   $0xc010c439
c0108a51:	68 30 02 00 00       	push   $0x230
c0108a56:	68 14 c4 10 c0       	push   $0xc010c414
c0108a5b:	e8 08 8d ff ff       	call   c0101768 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0108a60:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108a65:	8b 00                	mov    (%eax),%eax
c0108a67:	83 ec 0c             	sub    $0xc,%esp
c0108a6a:	50                   	push   %eax
c0108a6b:	e8 7b ee ff ff       	call   c01078eb <pde2page>
c0108a70:	83 c4 10             	add    $0x10,%esp
c0108a73:	83 ec 0c             	sub    $0xc,%esp
c0108a76:	50                   	push   %eax
c0108a77:	e8 8b ee ff ff       	call   c0107907 <page_ref>
c0108a7c:	83 c4 10             	add    $0x10,%esp
c0108a7f:	83 f8 01             	cmp    $0x1,%eax
c0108a82:	74 19                	je     c0108a9d <check_pgdir+0x527>
c0108a84:	68 f4 c6 10 c0       	push   $0xc010c6f4
c0108a89:	68 39 c4 10 c0       	push   $0xc010c439
c0108a8e:	68 32 02 00 00       	push   $0x232
c0108a93:	68 14 c4 10 c0       	push   $0xc010c414
c0108a98:	e8 cb 8c ff ff       	call   c0101768 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0108a9d:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108aa2:	8b 00                	mov    (%eax),%eax
c0108aa4:	83 ec 0c             	sub    $0xc,%esp
c0108aa7:	50                   	push   %eax
c0108aa8:	e8 3e ee ff ff       	call   c01078eb <pde2page>
c0108aad:	83 c4 10             	add    $0x10,%esp
c0108ab0:	83 ec 08             	sub    $0x8,%esp
c0108ab3:	6a 01                	push   $0x1
c0108ab5:	50                   	push   %eax
c0108ab6:	e8 c6 f0 ff ff       	call   c0107b81 <free_pages>
c0108abb:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c0108abe:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108ac3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0108ac9:	83 ec 0c             	sub    $0xc,%esp
c0108acc:	68 1b c7 10 c0       	push   $0xc010c71b
c0108ad1:	e8 b4 77 ff ff       	call   c010028a <cprintf>
c0108ad6:	83 c4 10             	add    $0x10,%esp
}
c0108ad9:	90                   	nop
c0108ada:	c9                   	leave  
c0108adb:	c3                   	ret    

c0108adc <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0108adc:	55                   	push   %ebp
c0108add:	89 e5                	mov    %esp,%ebp
c0108adf:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0108ae2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108ae9:	e9 a3 00 00 00       	jmp    c0108b91 <check_boot_pgdir+0xb5>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0108aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108af1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108af7:	c1 e8 0c             	shr    $0xc,%eax
c0108afa:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108afd:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c0108b02:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0108b05:	72 17                	jb     c0108b1e <check_boot_pgdir+0x42>
c0108b07:	ff 75 f0             	pushl  -0x10(%ebp)
c0108b0a:	68 4c c3 10 c0       	push   $0xc010c34c
c0108b0f:	68 3e 02 00 00       	push   $0x23e
c0108b14:	68 14 c4 10 c0       	push   $0xc010c414
c0108b19:	e8 4a 8c ff ff       	call   c0101768 <__panic>
c0108b1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b21:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0108b26:	89 c2                	mov    %eax,%edx
c0108b28:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108b2d:	83 ec 04             	sub    $0x4,%esp
c0108b30:	6a 00                	push   $0x0
c0108b32:	52                   	push   %edx
c0108b33:	50                   	push   %eax
c0108b34:	e8 58 f6 ff ff       	call   c0108191 <get_pte>
c0108b39:	83 c4 10             	add    $0x10,%esp
c0108b3c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108b3f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108b43:	75 19                	jne    c0108b5e <check_boot_pgdir+0x82>
c0108b45:	68 38 c7 10 c0       	push   $0xc010c738
c0108b4a:	68 39 c4 10 c0       	push   $0xc010c439
c0108b4f:	68 3e 02 00 00       	push   $0x23e
c0108b54:	68 14 c4 10 c0       	push   $0xc010c414
c0108b59:	e8 0a 8c ff ff       	call   c0101768 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0108b5e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b61:	8b 00                	mov    (%eax),%eax
c0108b63:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108b68:	89 c2                	mov    %eax,%edx
c0108b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b6d:	39 c2                	cmp    %eax,%edx
c0108b6f:	74 19                	je     c0108b8a <check_boot_pgdir+0xae>
c0108b71:	68 75 c7 10 c0       	push   $0xc010c775
c0108b76:	68 39 c4 10 c0       	push   $0xc010c439
c0108b7b:	68 3f 02 00 00       	push   $0x23f
c0108b80:	68 14 c4 10 c0       	push   $0xc010c414
c0108b85:	e8 de 8b ff ff       	call   c0101768 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0108b8a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0108b91:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108b94:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c0108b99:	39 c2                	cmp    %eax,%edx
c0108b9b:	0f 82 4d ff ff ff    	jb     c0108aee <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0108ba1:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108ba6:	05 ac 0f 00 00       	add    $0xfac,%eax
c0108bab:	8b 00                	mov    (%eax),%eax
c0108bad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108bb2:	89 c2                	mov    %eax,%edx
c0108bb4:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108bb9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108bbc:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0108bc3:	77 17                	ja     c0108bdc <check_boot_pgdir+0x100>
c0108bc5:	ff 75 e4             	pushl  -0x1c(%ebp)
c0108bc8:	68 f0 c3 10 c0       	push   $0xc010c3f0
c0108bcd:	68 42 02 00 00       	push   $0x242
c0108bd2:	68 14 c4 10 c0       	push   $0xc010c414
c0108bd7:	e8 8c 8b ff ff       	call   c0101768 <__panic>
c0108bdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108bdf:	05 00 00 00 40       	add    $0x40000000,%eax
c0108be4:	39 c2                	cmp    %eax,%edx
c0108be6:	74 19                	je     c0108c01 <check_boot_pgdir+0x125>
c0108be8:	68 8c c7 10 c0       	push   $0xc010c78c
c0108bed:	68 39 c4 10 c0       	push   $0xc010c439
c0108bf2:	68 42 02 00 00       	push   $0x242
c0108bf7:	68 14 c4 10 c0       	push   $0xc010c414
c0108bfc:	e8 67 8b ff ff       	call   c0101768 <__panic>

    assert(boot_pgdir[0] == 0);
c0108c01:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108c06:	8b 00                	mov    (%eax),%eax
c0108c08:	85 c0                	test   %eax,%eax
c0108c0a:	74 19                	je     c0108c25 <check_boot_pgdir+0x149>
c0108c0c:	68 c0 c7 10 c0       	push   $0xc010c7c0
c0108c11:	68 39 c4 10 c0       	push   $0xc010c439
c0108c16:	68 44 02 00 00       	push   $0x244
c0108c1b:	68 14 c4 10 c0       	push   $0xc010c414
c0108c20:	e8 43 8b ff ff       	call   c0101768 <__panic>

    struct Page *p;
    p = alloc_page();
c0108c25:	83 ec 0c             	sub    $0xc,%esp
c0108c28:	6a 01                	push   $0x1
c0108c2a:	e8 e6 ee ff ff       	call   c0107b15 <alloc_pages>
c0108c2f:	83 c4 10             	add    $0x10,%esp
c0108c32:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0108c35:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108c3a:	6a 02                	push   $0x2
c0108c3c:	68 00 01 00 00       	push   $0x100
c0108c41:	ff 75 e0             	pushl  -0x20(%ebp)
c0108c44:	50                   	push   %eax
c0108c45:	e8 58 f7 ff ff       	call   c01083a2 <page_insert>
c0108c4a:	83 c4 10             	add    $0x10,%esp
c0108c4d:	85 c0                	test   %eax,%eax
c0108c4f:	74 19                	je     c0108c6a <check_boot_pgdir+0x18e>
c0108c51:	68 d4 c7 10 c0       	push   $0xc010c7d4
c0108c56:	68 39 c4 10 c0       	push   $0xc010c439
c0108c5b:	68 48 02 00 00       	push   $0x248
c0108c60:	68 14 c4 10 c0       	push   $0xc010c414
c0108c65:	e8 fe 8a ff ff       	call   c0101768 <__panic>
    assert(page_ref(p) == 1);
c0108c6a:	83 ec 0c             	sub    $0xc,%esp
c0108c6d:	ff 75 e0             	pushl  -0x20(%ebp)
c0108c70:	e8 92 ec ff ff       	call   c0107907 <page_ref>
c0108c75:	83 c4 10             	add    $0x10,%esp
c0108c78:	83 f8 01             	cmp    $0x1,%eax
c0108c7b:	74 19                	je     c0108c96 <check_boot_pgdir+0x1ba>
c0108c7d:	68 02 c8 10 c0       	push   $0xc010c802
c0108c82:	68 39 c4 10 c0       	push   $0xc010c439
c0108c87:	68 49 02 00 00       	push   $0x249
c0108c8c:	68 14 c4 10 c0       	push   $0xc010c414
c0108c91:	e8 d2 8a ff ff       	call   c0101768 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0108c96:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108c9b:	6a 02                	push   $0x2
c0108c9d:	68 00 11 00 00       	push   $0x1100
c0108ca2:	ff 75 e0             	pushl  -0x20(%ebp)
c0108ca5:	50                   	push   %eax
c0108ca6:	e8 f7 f6 ff ff       	call   c01083a2 <page_insert>
c0108cab:	83 c4 10             	add    $0x10,%esp
c0108cae:	85 c0                	test   %eax,%eax
c0108cb0:	74 19                	je     c0108ccb <check_boot_pgdir+0x1ef>
c0108cb2:	68 14 c8 10 c0       	push   $0xc010c814
c0108cb7:	68 39 c4 10 c0       	push   $0xc010c439
c0108cbc:	68 4a 02 00 00       	push   $0x24a
c0108cc1:	68 14 c4 10 c0       	push   $0xc010c414
c0108cc6:	e8 9d 8a ff ff       	call   c0101768 <__panic>
    assert(page_ref(p) == 2);
c0108ccb:	83 ec 0c             	sub    $0xc,%esp
c0108cce:	ff 75 e0             	pushl  -0x20(%ebp)
c0108cd1:	e8 31 ec ff ff       	call   c0107907 <page_ref>
c0108cd6:	83 c4 10             	add    $0x10,%esp
c0108cd9:	83 f8 02             	cmp    $0x2,%eax
c0108cdc:	74 19                	je     c0108cf7 <check_boot_pgdir+0x21b>
c0108cde:	68 4b c8 10 c0       	push   $0xc010c84b
c0108ce3:	68 39 c4 10 c0       	push   $0xc010c439
c0108ce8:	68 4b 02 00 00       	push   $0x24b
c0108ced:	68 14 c4 10 c0       	push   $0xc010c414
c0108cf2:	e8 71 8a ff ff       	call   c0101768 <__panic>

    const char *str = "ucore: Hello world!!";
c0108cf7:	c7 45 dc 5c c8 10 c0 	movl   $0xc010c85c,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0108cfe:	83 ec 08             	sub    $0x8,%esp
c0108d01:	ff 75 dc             	pushl  -0x24(%ebp)
c0108d04:	68 00 01 00 00       	push   $0x100
c0108d09:	e8 62 10 00 00       	call   c0109d70 <strcpy>
c0108d0e:	83 c4 10             	add    $0x10,%esp
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0108d11:	83 ec 08             	sub    $0x8,%esp
c0108d14:	68 00 11 00 00       	push   $0x1100
c0108d19:	68 00 01 00 00       	push   $0x100
c0108d1e:	e8 c7 10 00 00       	call   c0109dea <strcmp>
c0108d23:	83 c4 10             	add    $0x10,%esp
c0108d26:	85 c0                	test   %eax,%eax
c0108d28:	74 19                	je     c0108d43 <check_boot_pgdir+0x267>
c0108d2a:	68 74 c8 10 c0       	push   $0xc010c874
c0108d2f:	68 39 c4 10 c0       	push   $0xc010c439
c0108d34:	68 4f 02 00 00       	push   $0x24f
c0108d39:	68 14 c4 10 c0       	push   $0xc010c414
c0108d3e:	e8 25 8a ff ff       	call   c0101768 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0108d43:	83 ec 0c             	sub    $0xc,%esp
c0108d46:	ff 75 e0             	pushl  -0x20(%ebp)
c0108d49:	e8 1e eb ff ff       	call   c010786c <page2kva>
c0108d4e:	83 c4 10             	add    $0x10,%esp
c0108d51:	05 00 01 00 00       	add    $0x100,%eax
c0108d56:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0108d59:	83 ec 0c             	sub    $0xc,%esp
c0108d5c:	68 00 01 00 00       	push   $0x100
c0108d61:	e8 b2 0f 00 00       	call   c0109d18 <strlen>
c0108d66:	83 c4 10             	add    $0x10,%esp
c0108d69:	85 c0                	test   %eax,%eax
c0108d6b:	74 19                	je     c0108d86 <check_boot_pgdir+0x2aa>
c0108d6d:	68 ac c8 10 c0       	push   $0xc010c8ac
c0108d72:	68 39 c4 10 c0       	push   $0xc010c439
c0108d77:	68 52 02 00 00       	push   $0x252
c0108d7c:	68 14 c4 10 c0       	push   $0xc010c414
c0108d81:	e8 e2 89 ff ff       	call   c0101768 <__panic>

    free_page(p);
c0108d86:	83 ec 08             	sub    $0x8,%esp
c0108d89:	6a 01                	push   $0x1
c0108d8b:	ff 75 e0             	pushl  -0x20(%ebp)
c0108d8e:	e8 ee ed ff ff       	call   c0107b81 <free_pages>
c0108d93:	83 c4 10             	add    $0x10,%esp
    free_page(pde2page(boot_pgdir[0]));
c0108d96:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108d9b:	8b 00                	mov    (%eax),%eax
c0108d9d:	83 ec 0c             	sub    $0xc,%esp
c0108da0:	50                   	push   %eax
c0108da1:	e8 45 eb ff ff       	call   c01078eb <pde2page>
c0108da6:	83 c4 10             	add    $0x10,%esp
c0108da9:	83 ec 08             	sub    $0x8,%esp
c0108dac:	6a 01                	push   $0x1
c0108dae:	50                   	push   %eax
c0108daf:	e8 cd ed ff ff       	call   c0107b81 <free_pages>
c0108db4:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c0108db7:	a1 20 7a 12 c0       	mov    0xc0127a20,%eax
c0108dbc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0108dc2:	83 ec 0c             	sub    $0xc,%esp
c0108dc5:	68 d0 c8 10 c0       	push   $0xc010c8d0
c0108dca:	e8 bb 74 ff ff       	call   c010028a <cprintf>
c0108dcf:	83 c4 10             	add    $0x10,%esp
}
c0108dd2:	90                   	nop
c0108dd3:	c9                   	leave  
c0108dd4:	c3                   	ret    

c0108dd5 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0108dd5:	55                   	push   %ebp
c0108dd6:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0108dd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ddb:	83 e0 04             	and    $0x4,%eax
c0108dde:	85 c0                	test   %eax,%eax
c0108de0:	74 07                	je     c0108de9 <perm2str+0x14>
c0108de2:	b8 75 00 00 00       	mov    $0x75,%eax
c0108de7:	eb 05                	jmp    c0108dee <perm2str+0x19>
c0108de9:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0108dee:	a2 08 b0 12 c0       	mov    %al,0xc012b008
    str[1] = 'r';
c0108df3:	c6 05 09 b0 12 c0 72 	movb   $0x72,0xc012b009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0108dfa:	8b 45 08             	mov    0x8(%ebp),%eax
c0108dfd:	83 e0 02             	and    $0x2,%eax
c0108e00:	85 c0                	test   %eax,%eax
c0108e02:	74 07                	je     c0108e0b <perm2str+0x36>
c0108e04:	b8 77 00 00 00       	mov    $0x77,%eax
c0108e09:	eb 05                	jmp    c0108e10 <perm2str+0x3b>
c0108e0b:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0108e10:	a2 0a b0 12 c0       	mov    %al,0xc012b00a
    str[3] = '\0';
c0108e15:	c6 05 0b b0 12 c0 00 	movb   $0x0,0xc012b00b
    return str;
c0108e1c:	b8 08 b0 12 c0       	mov    $0xc012b008,%eax
}
c0108e21:	5d                   	pop    %ebp
c0108e22:	c3                   	ret    

c0108e23 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0108e23:	55                   	push   %ebp
c0108e24:	89 e5                	mov    %esp,%ebp
c0108e26:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0108e29:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e2c:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108e2f:	72 0e                	jb     c0108e3f <get_pgtable_items+0x1c>
        return 0;
c0108e31:	b8 00 00 00 00       	mov    $0x0,%eax
c0108e36:	e9 9a 00 00 00       	jmp    c0108ed5 <get_pgtable_items+0xb2>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0108e3b:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0108e3f:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e42:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108e45:	73 18                	jae    c0108e5f <get_pgtable_items+0x3c>
c0108e47:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e4a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108e51:	8b 45 14             	mov    0x14(%ebp),%eax
c0108e54:	01 d0                	add    %edx,%eax
c0108e56:	8b 00                	mov    (%eax),%eax
c0108e58:	83 e0 01             	and    $0x1,%eax
c0108e5b:	85 c0                	test   %eax,%eax
c0108e5d:	74 dc                	je     c0108e3b <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
c0108e5f:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e62:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108e65:	73 69                	jae    c0108ed0 <get_pgtable_items+0xad>
        if (left_store != NULL) {
c0108e67:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0108e6b:	74 08                	je     c0108e75 <get_pgtable_items+0x52>
            *left_store = start;
c0108e6d:	8b 45 18             	mov    0x18(%ebp),%eax
c0108e70:	8b 55 10             	mov    0x10(%ebp),%edx
c0108e73:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0108e75:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e78:	8d 50 01             	lea    0x1(%eax),%edx
c0108e7b:	89 55 10             	mov    %edx,0x10(%ebp)
c0108e7e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108e85:	8b 45 14             	mov    0x14(%ebp),%eax
c0108e88:	01 d0                	add    %edx,%eax
c0108e8a:	8b 00                	mov    (%eax),%eax
c0108e8c:	83 e0 07             	and    $0x7,%eax
c0108e8f:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0108e92:	eb 04                	jmp    c0108e98 <get_pgtable_items+0x75>
            start ++;
c0108e94:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0108e98:	8b 45 10             	mov    0x10(%ebp),%eax
c0108e9b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108e9e:	73 1d                	jae    c0108ebd <get_pgtable_items+0x9a>
c0108ea0:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ea3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108eaa:	8b 45 14             	mov    0x14(%ebp),%eax
c0108ead:	01 d0                	add    %edx,%eax
c0108eaf:	8b 00                	mov    (%eax),%eax
c0108eb1:	83 e0 07             	and    $0x7,%eax
c0108eb4:	89 c2                	mov    %eax,%edx
c0108eb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108eb9:	39 c2                	cmp    %eax,%edx
c0108ebb:	74 d7                	je     c0108e94 <get_pgtable_items+0x71>
            start ++;
        }
        if (right_store != NULL) {
c0108ebd:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0108ec1:	74 08                	je     c0108ecb <get_pgtable_items+0xa8>
            *right_store = start;
c0108ec3:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0108ec6:	8b 55 10             	mov    0x10(%ebp),%edx
c0108ec9:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0108ecb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108ece:	eb 05                	jmp    c0108ed5 <get_pgtable_items+0xb2>
    }
    return 0;
c0108ed0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108ed5:	c9                   	leave  
c0108ed6:	c3                   	ret    

c0108ed7 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0108ed7:	55                   	push   %ebp
c0108ed8:	89 e5                	mov    %esp,%ebp
c0108eda:	57                   	push   %edi
c0108edb:	56                   	push   %esi
c0108edc:	53                   	push   %ebx
c0108edd:	83 ec 2c             	sub    $0x2c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0108ee0:	83 ec 0c             	sub    $0xc,%esp
c0108ee3:	68 f0 c8 10 c0       	push   $0xc010c8f0
c0108ee8:	e8 9d 73 ff ff       	call   c010028a <cprintf>
c0108eed:	83 c4 10             	add    $0x10,%esp
    size_t left, right = 0, perm;
c0108ef0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0108ef7:	e9 e5 00 00 00       	jmp    c0108fe1 <print_pgdir+0x10a>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0108efc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108eff:	83 ec 0c             	sub    $0xc,%esp
c0108f02:	50                   	push   %eax
c0108f03:	e8 cd fe ff ff       	call   c0108dd5 <perm2str>
c0108f08:	83 c4 10             	add    $0x10,%esp
c0108f0b:	89 c7                	mov    %eax,%edi
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0108f0d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108f10:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108f13:	29 c2                	sub    %eax,%edx
c0108f15:	89 d0                	mov    %edx,%eax
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0108f17:	c1 e0 16             	shl    $0x16,%eax
c0108f1a:	89 c3                	mov    %eax,%ebx
c0108f1c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108f1f:	c1 e0 16             	shl    $0x16,%eax
c0108f22:	89 c1                	mov    %eax,%ecx
c0108f24:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108f27:	c1 e0 16             	shl    $0x16,%eax
c0108f2a:	89 c2                	mov    %eax,%edx
c0108f2c:	8b 75 dc             	mov    -0x24(%ebp),%esi
c0108f2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108f32:	29 c6                	sub    %eax,%esi
c0108f34:	89 f0                	mov    %esi,%eax
c0108f36:	83 ec 08             	sub    $0x8,%esp
c0108f39:	57                   	push   %edi
c0108f3a:	53                   	push   %ebx
c0108f3b:	51                   	push   %ecx
c0108f3c:	52                   	push   %edx
c0108f3d:	50                   	push   %eax
c0108f3e:	68 21 c9 10 c0       	push   $0xc010c921
c0108f43:	e8 42 73 ff ff       	call   c010028a <cprintf>
c0108f48:	83 c4 20             	add    $0x20,%esp
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0108f4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108f4e:	c1 e0 0a             	shl    $0xa,%eax
c0108f51:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0108f54:	eb 4f                	jmp    c0108fa5 <print_pgdir+0xce>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0108f56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108f59:	83 ec 0c             	sub    $0xc,%esp
c0108f5c:	50                   	push   %eax
c0108f5d:	e8 73 fe ff ff       	call   c0108dd5 <perm2str>
c0108f62:	83 c4 10             	add    $0x10,%esp
c0108f65:	89 c7                	mov    %eax,%edi
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0108f67:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108f6a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108f6d:	29 c2                	sub    %eax,%edx
c0108f6f:	89 d0                	mov    %edx,%eax
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0108f71:	c1 e0 0c             	shl    $0xc,%eax
c0108f74:	89 c3                	mov    %eax,%ebx
c0108f76:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108f79:	c1 e0 0c             	shl    $0xc,%eax
c0108f7c:	89 c1                	mov    %eax,%ecx
c0108f7e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108f81:	c1 e0 0c             	shl    $0xc,%eax
c0108f84:	89 c2                	mov    %eax,%edx
c0108f86:	8b 75 d4             	mov    -0x2c(%ebp),%esi
c0108f89:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108f8c:	29 c6                	sub    %eax,%esi
c0108f8e:	89 f0                	mov    %esi,%eax
c0108f90:	83 ec 08             	sub    $0x8,%esp
c0108f93:	57                   	push   %edi
c0108f94:	53                   	push   %ebx
c0108f95:	51                   	push   %ecx
c0108f96:	52                   	push   %edx
c0108f97:	50                   	push   %eax
c0108f98:	68 40 c9 10 c0       	push   $0xc010c940
c0108f9d:	e8 e8 72 ff ff       	call   c010028a <cprintf>
c0108fa2:	83 c4 20             	add    $0x20,%esp
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0108fa5:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0108faa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108fad:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108fb0:	89 d3                	mov    %edx,%ebx
c0108fb2:	c1 e3 0a             	shl    $0xa,%ebx
c0108fb5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108fb8:	89 d1                	mov    %edx,%ecx
c0108fba:	c1 e1 0a             	shl    $0xa,%ecx
c0108fbd:	83 ec 08             	sub    $0x8,%esp
c0108fc0:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0108fc3:	52                   	push   %edx
c0108fc4:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0108fc7:	52                   	push   %edx
c0108fc8:	56                   	push   %esi
c0108fc9:	50                   	push   %eax
c0108fca:	53                   	push   %ebx
c0108fcb:	51                   	push   %ecx
c0108fcc:	e8 52 fe ff ff       	call   c0108e23 <get_pgtable_items>
c0108fd1:	83 c4 20             	add    $0x20,%esp
c0108fd4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108fd7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108fdb:	0f 85 75 ff ff ff    	jne    c0108f56 <print_pgdir+0x7f>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0108fe1:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0108fe6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108fe9:	83 ec 08             	sub    $0x8,%esp
c0108fec:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0108fef:	52                   	push   %edx
c0108ff0:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0108ff3:	52                   	push   %edx
c0108ff4:	51                   	push   %ecx
c0108ff5:	50                   	push   %eax
c0108ff6:	68 00 04 00 00       	push   $0x400
c0108ffb:	6a 00                	push   $0x0
c0108ffd:	e8 21 fe ff ff       	call   c0108e23 <get_pgtable_items>
c0109002:	83 c4 20             	add    $0x20,%esp
c0109005:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109008:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010900c:	0f 85 ea fe ff ff    	jne    c0108efc <print_pgdir+0x25>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0109012:	83 ec 0c             	sub    $0xc,%esp
c0109015:	68 64 c9 10 c0       	push   $0xc010c964
c010901a:	e8 6b 72 ff ff       	call   c010028a <cprintf>
c010901f:	83 c4 10             	add    $0x10,%esp
}
c0109022:	90                   	nop
c0109023:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0109026:	5b                   	pop    %ebx
c0109027:	5e                   	pop    %esi
c0109028:	5f                   	pop    %edi
c0109029:	5d                   	pop    %ebp
c010902a:	c3                   	ret    

c010902b <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010902b:	55                   	push   %ebp
c010902c:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010902e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109031:	8b 15 40 d1 12 c0    	mov    0xc012d140,%edx
c0109037:	29 d0                	sub    %edx,%eax
c0109039:	c1 f8 02             	sar    $0x2,%eax
c010903c:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0109042:	5d                   	pop    %ebp
c0109043:	c3                   	ret    

c0109044 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0109044:	55                   	push   %ebp
c0109045:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0109047:	ff 75 08             	pushl  0x8(%ebp)
c010904a:	e8 dc ff ff ff       	call   c010902b <page2ppn>
c010904f:	83 c4 04             	add    $0x4,%esp
c0109052:	c1 e0 0c             	shl    $0xc,%eax
}
c0109055:	c9                   	leave  
c0109056:	c3                   	ret    

c0109057 <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c0109057:	55                   	push   %ebp
c0109058:	89 e5                	mov    %esp,%ebp
c010905a:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c010905d:	ff 75 08             	pushl  0x8(%ebp)
c0109060:	e8 df ff ff ff       	call   c0109044 <page2pa>
c0109065:	83 c4 04             	add    $0x4,%esp
c0109068:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010906b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010906e:	c1 e8 0c             	shr    $0xc,%eax
c0109071:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109074:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c0109079:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010907c:	72 14                	jb     c0109092 <page2kva+0x3b>
c010907e:	ff 75 f4             	pushl  -0xc(%ebp)
c0109081:	68 98 c9 10 c0       	push   $0xc010c998
c0109086:	6a 66                	push   $0x66
c0109088:	68 bb c9 10 c0       	push   $0xc010c9bb
c010908d:	e8 d6 86 ff ff       	call   c0101768 <__panic>
c0109092:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109095:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010909a:	c9                   	leave  
c010909b:	c3                   	ret    

c010909c <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c010909c:	55                   	push   %ebp
c010909d:	89 e5                	mov    %esp,%ebp
c010909f:	83 ec 08             	sub    $0x8,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c01090a2:	83 ec 0c             	sub    $0xc,%esp
c01090a5:	6a 01                	push   $0x1
c01090a7:	e8 ba 93 ff ff       	call   c0102466 <ide_device_valid>
c01090ac:	83 c4 10             	add    $0x10,%esp
c01090af:	85 c0                	test   %eax,%eax
c01090b1:	75 14                	jne    c01090c7 <swapfs_init+0x2b>
        panic("swap fs isn't available.\n");
c01090b3:	83 ec 04             	sub    $0x4,%esp
c01090b6:	68 c9 c9 10 c0       	push   $0xc010c9c9
c01090bb:	6a 0d                	push   $0xd
c01090bd:	68 e3 c9 10 c0       	push   $0xc010c9e3
c01090c2:	e8 a1 86 ff ff       	call   c0101768 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c01090c7:	83 ec 0c             	sub    $0xc,%esp
c01090ca:	6a 01                	push   $0x1
c01090cc:	e8 d5 93 ff ff       	call   c01024a6 <ide_device_size>
c01090d1:	83 c4 10             	add    $0x10,%esp
c01090d4:	c1 e8 03             	shr    $0x3,%eax
c01090d7:	a3 fc d0 12 c0       	mov    %eax,0xc012d0fc
}
c01090dc:	90                   	nop
c01090dd:	c9                   	leave  
c01090de:	c3                   	ret    

c01090df <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c01090df:	55                   	push   %ebp
c01090e0:	89 e5                	mov    %esp,%ebp
c01090e2:	83 ec 18             	sub    $0x18,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01090e5:	83 ec 0c             	sub    $0xc,%esp
c01090e8:	ff 75 0c             	pushl  0xc(%ebp)
c01090eb:	e8 67 ff ff ff       	call   c0109057 <page2kva>
c01090f0:	83 c4 10             	add    $0x10,%esp
c01090f3:	89 c2                	mov    %eax,%edx
c01090f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01090f8:	c1 e8 08             	shr    $0x8,%eax
c01090fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01090fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109102:	74 0a                	je     c010910e <swapfs_read+0x2f>
c0109104:	a1 fc d0 12 c0       	mov    0xc012d0fc,%eax
c0109109:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010910c:	72 14                	jb     c0109122 <swapfs_read+0x43>
c010910e:	ff 75 08             	pushl  0x8(%ebp)
c0109111:	68 f4 c9 10 c0       	push   $0xc010c9f4
c0109116:	6a 14                	push   $0x14
c0109118:	68 e3 c9 10 c0       	push   $0xc010c9e3
c010911d:	e8 46 86 ff ff       	call   c0101768 <__panic>
c0109122:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109125:	c1 e0 03             	shl    $0x3,%eax
c0109128:	6a 08                	push   $0x8
c010912a:	52                   	push   %edx
c010912b:	50                   	push   %eax
c010912c:	6a 01                	push   $0x1
c010912e:	e8 b3 93 ff ff       	call   c01024e6 <ide_read_secs>
c0109133:	83 c4 10             	add    $0x10,%esp
}
c0109136:	c9                   	leave  
c0109137:	c3                   	ret    

c0109138 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0109138:	55                   	push   %ebp
c0109139:	89 e5                	mov    %esp,%ebp
c010913b:	83 ec 18             	sub    $0x18,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010913e:	83 ec 0c             	sub    $0xc,%esp
c0109141:	ff 75 0c             	pushl  0xc(%ebp)
c0109144:	e8 0e ff ff ff       	call   c0109057 <page2kva>
c0109149:	83 c4 10             	add    $0x10,%esp
c010914c:	89 c2                	mov    %eax,%edx
c010914e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109151:	c1 e8 08             	shr    $0x8,%eax
c0109154:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109157:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010915b:	74 0a                	je     c0109167 <swapfs_write+0x2f>
c010915d:	a1 fc d0 12 c0       	mov    0xc012d0fc,%eax
c0109162:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0109165:	72 14                	jb     c010917b <swapfs_write+0x43>
c0109167:	ff 75 08             	pushl  0x8(%ebp)
c010916a:	68 f4 c9 10 c0       	push   $0xc010c9f4
c010916f:	6a 19                	push   $0x19
c0109171:	68 e3 c9 10 c0       	push   $0xc010c9e3
c0109176:	e8 ed 85 ff ff       	call   c0101768 <__panic>
c010917b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010917e:	c1 e0 03             	shl    $0x3,%eax
c0109181:	6a 08                	push   $0x8
c0109183:	52                   	push   %edx
c0109184:	50                   	push   %eax
c0109185:	6a 01                	push   $0x1
c0109187:	e8 84 95 ff ff       	call   c0102710 <ide_write_secs>
c010918c:	83 c4 10             	add    $0x10,%esp
}
c010918f:	c9                   	leave  
c0109190:	c3                   	ret    

c0109191 <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c0109191:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c0109195:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c0109197:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c010919a:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c010919d:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c01091a0:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c01091a3:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c01091a6:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c01091a9:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c01091ac:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c01091b0:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c01091b3:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c01091b6:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c01091b9:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c01091bc:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c01091bf:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c01091c2:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c01091c5:	ff 30                	pushl  (%eax)

    ret
c01091c7:	c3                   	ret    

c01091c8 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c01091c8:	52                   	push   %edx
    call *%ebx              # call fn
c01091c9:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c01091cb:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c01091cc:	e8 cc 07 00 00       	call   c010999d <do_exit>

c01091d1 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c01091d1:	55                   	push   %ebp
c01091d2:	89 e5                	mov    %esp,%ebp
c01091d4:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01091d7:	9c                   	pushf  
c01091d8:	58                   	pop    %eax
c01091d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01091dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01091df:	25 00 02 00 00       	and    $0x200,%eax
c01091e4:	85 c0                	test   %eax,%eax
c01091e6:	74 0c                	je     c01091f4 <__intr_save+0x23>
        intr_disable();
c01091e8:	e8 5c a2 ff ff       	call   c0103449 <intr_disable>
        return 1;
c01091ed:	b8 01 00 00 00       	mov    $0x1,%eax
c01091f2:	eb 05                	jmp    c01091f9 <__intr_save+0x28>
    }
    return 0;
c01091f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01091f9:	c9                   	leave  
c01091fa:	c3                   	ret    

c01091fb <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01091fb:	55                   	push   %ebp
c01091fc:	89 e5                	mov    %esp,%ebp
c01091fe:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0109201:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109205:	74 05                	je     c010920c <__intr_restore+0x11>
        intr_enable();
c0109207:	e8 36 a2 ff ff       	call   c0103442 <intr_enable>
    }
}
c010920c:	90                   	nop
c010920d:	c9                   	leave  
c010920e:	c3                   	ret    

c010920f <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010920f:	55                   	push   %ebp
c0109210:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0109212:	8b 45 08             	mov    0x8(%ebp),%eax
c0109215:	8b 15 40 d1 12 c0    	mov    0xc012d140,%edx
c010921b:	29 d0                	sub    %edx,%eax
c010921d:	c1 f8 02             	sar    $0x2,%eax
c0109220:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0109226:	5d                   	pop    %ebp
c0109227:	c3                   	ret    

c0109228 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0109228:	55                   	push   %ebp
c0109229:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c010922b:	ff 75 08             	pushl  0x8(%ebp)
c010922e:	e8 dc ff ff ff       	call   c010920f <page2ppn>
c0109233:	83 c4 04             	add    $0x4,%esp
c0109236:	c1 e0 0c             	shl    $0xc,%eax
}
c0109239:	c9                   	leave  
c010923a:	c3                   	ret    

c010923b <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c010923b:	55                   	push   %ebp
c010923c:	89 e5                	mov    %esp,%ebp
c010923e:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0109241:	8b 45 08             	mov    0x8(%ebp),%eax
c0109244:	c1 e8 0c             	shr    $0xc,%eax
c0109247:	89 c2                	mov    %eax,%edx
c0109249:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c010924e:	39 c2                	cmp    %eax,%edx
c0109250:	72 14                	jb     c0109266 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0109252:	83 ec 04             	sub    $0x4,%esp
c0109255:	68 14 ca 10 c0       	push   $0xc010ca14
c010925a:	6a 5f                	push   $0x5f
c010925c:	68 33 ca 10 c0       	push   $0xc010ca33
c0109261:	e8 02 85 ff ff       	call   c0101768 <__panic>
    }
    return &pages[PPN(pa)];
c0109266:	8b 0d 40 d1 12 c0    	mov    0xc012d140,%ecx
c010926c:	8b 45 08             	mov    0x8(%ebp),%eax
c010926f:	c1 e8 0c             	shr    $0xc,%eax
c0109272:	89 c2                	mov    %eax,%edx
c0109274:	89 d0                	mov    %edx,%eax
c0109276:	c1 e0 03             	shl    $0x3,%eax
c0109279:	01 d0                	add    %edx,%eax
c010927b:	c1 e0 02             	shl    $0x2,%eax
c010927e:	01 c8                	add    %ecx,%eax
}
c0109280:	c9                   	leave  
c0109281:	c3                   	ret    

c0109282 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0109282:	55                   	push   %ebp
c0109283:	89 e5                	mov    %esp,%ebp
c0109285:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c0109288:	ff 75 08             	pushl  0x8(%ebp)
c010928b:	e8 98 ff ff ff       	call   c0109228 <page2pa>
c0109290:	83 c4 04             	add    $0x4,%esp
c0109293:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109296:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109299:	c1 e8 0c             	shr    $0xc,%eax
c010929c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010929f:	a1 80 af 12 c0       	mov    0xc012af80,%eax
c01092a4:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01092a7:	72 14                	jb     c01092bd <page2kva+0x3b>
c01092a9:	ff 75 f4             	pushl  -0xc(%ebp)
c01092ac:	68 44 ca 10 c0       	push   $0xc010ca44
c01092b1:	6a 66                	push   $0x66
c01092b3:	68 33 ca 10 c0       	push   $0xc010ca33
c01092b8:	e8 ab 84 ff ff       	call   c0101768 <__panic>
c01092bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01092c0:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01092c5:	c9                   	leave  
c01092c6:	c3                   	ret    

c01092c7 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c01092c7:	55                   	push   %ebp
c01092c8:	89 e5                	mov    %esp,%ebp
c01092ca:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PADDR(kva));
c01092cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01092d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01092d3:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01092da:	77 14                	ja     c01092f0 <kva2page+0x29>
c01092dc:	ff 75 f4             	pushl  -0xc(%ebp)
c01092df:	68 68 ca 10 c0       	push   $0xc010ca68
c01092e4:	6a 6b                	push   $0x6b
c01092e6:	68 33 ca 10 c0       	push   $0xc010ca33
c01092eb:	e8 78 84 ff ff       	call   c0101768 <__panic>
c01092f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01092f3:	05 00 00 00 40       	add    $0x40000000,%eax
c01092f8:	83 ec 0c             	sub    $0xc,%esp
c01092fb:	50                   	push   %eax
c01092fc:	e8 3a ff ff ff       	call   c010923b <pa2page>
c0109301:	83 c4 10             	add    $0x10,%esp
}
c0109304:	c9                   	leave  
c0109305:	c3                   	ret    

c0109306 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c0109306:	55                   	push   %ebp
c0109307:	89 e5                	mov    %esp,%ebp
c0109309:	83 ec 18             	sub    $0x18,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c010930c:	83 ec 0c             	sub    $0xc,%esp
c010930f:	6a 68                	push   $0x68
c0109311:	e8 f8 ce ff ff       	call   c010620e <kmalloc>
c0109316:	83 c4 10             	add    $0x10,%esp
c0109319:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c010931c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109320:	0f 84 91 00 00 00    	je     c01093b7 <alloc_proc+0xb1>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;
c0109326:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109329:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;
c010932f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109332:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->runs = 0;
c0109339:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010933c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        proc->kstack = 0;
c0109343:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109346:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        proc->need_resched = 0;
c010934d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109350:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        proc->parent = NULL;
c0109357:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010935a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        proc->mm = NULL;
c0109361:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109364:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        memset(&(proc->context), 0, sizeof(struct context));
c010936b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010936e:	83 c0 1c             	add    $0x1c,%eax
c0109371:	83 ec 04             	sub    $0x4,%esp
c0109374:	6a 20                	push   $0x20
c0109376:	6a 00                	push   $0x0
c0109378:	50                   	push   %eax
c0109379:	e8 cb 0c 00 00       	call   c010a049 <memset>
c010937e:	83 c4 10             	add    $0x10,%esp
        proc->tf = NULL;
c0109381:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109384:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
        proc->cr3 = boot_cr3;
c010938b:	8b 15 3c d1 12 c0    	mov    0xc012d13c,%edx
c0109391:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109394:	89 50 40             	mov    %edx,0x40(%eax)
        proc->flags = 0;
c0109397:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010939a:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
        memset(proc->name, 0, PROC_NAME_LEN);
c01093a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01093a4:	83 c0 48             	add    $0x48,%eax
c01093a7:	83 ec 04             	sub    $0x4,%esp
c01093aa:	6a 0f                	push   $0xf
c01093ac:	6a 00                	push   $0x0
c01093ae:	50                   	push   %eax
c01093af:	e8 95 0c 00 00       	call   c010a049 <memset>
c01093b4:	83 c4 10             	add    $0x10,%esp
    }
    return proc;
c01093b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01093ba:	c9                   	leave  
c01093bb:	c3                   	ret    

c01093bc <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c01093bc:	55                   	push   %ebp
c01093bd:	89 e5                	mov    %esp,%ebp
c01093bf:	83 ec 08             	sub    $0x8,%esp
    memset(proc->name, 0, sizeof(proc->name));
c01093c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01093c5:	83 c0 48             	add    $0x48,%eax
c01093c8:	83 ec 04             	sub    $0x4,%esp
c01093cb:	6a 10                	push   $0x10
c01093cd:	6a 00                	push   $0x0
c01093cf:	50                   	push   %eax
c01093d0:	e8 74 0c 00 00       	call   c010a049 <memset>
c01093d5:	83 c4 10             	add    $0x10,%esp
    return memcpy(proc->name, name, PROC_NAME_LEN);
c01093d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01093db:	83 c0 48             	add    $0x48,%eax
c01093de:	83 ec 04             	sub    $0x4,%esp
c01093e1:	6a 0f                	push   $0xf
c01093e3:	ff 75 0c             	pushl  0xc(%ebp)
c01093e6:	50                   	push   %eax
c01093e7:	e8 40 0d 00 00       	call   c010a12c <memcpy>
c01093ec:	83 c4 10             	add    $0x10,%esp
}
c01093ef:	c9                   	leave  
c01093f0:	c3                   	ret    

c01093f1 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c01093f1:	55                   	push   %ebp
c01093f2:	89 e5                	mov    %esp,%ebp
c01093f4:	83 ec 08             	sub    $0x8,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c01093f7:	83 ec 04             	sub    $0x4,%esp
c01093fa:	6a 10                	push   $0x10
c01093fc:	6a 00                	push   $0x0
c01093fe:	68 44 d0 12 c0       	push   $0xc012d044
c0109403:	e8 41 0c 00 00       	call   c010a049 <memset>
c0109408:	83 c4 10             	add    $0x10,%esp
    return memcpy(name, proc->name, PROC_NAME_LEN);
c010940b:	8b 45 08             	mov    0x8(%ebp),%eax
c010940e:	83 c0 48             	add    $0x48,%eax
c0109411:	83 ec 04             	sub    $0x4,%esp
c0109414:	6a 0f                	push   $0xf
c0109416:	50                   	push   %eax
c0109417:	68 44 d0 12 c0       	push   $0xc012d044
c010941c:	e8 0b 0d 00 00       	call   c010a12c <memcpy>
c0109421:	83 c4 10             	add    $0x10,%esp
}
c0109424:	c9                   	leave  
c0109425:	c3                   	ret    

c0109426 <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c0109426:	55                   	push   %ebp
c0109427:	89 e5                	mov    %esp,%ebp
c0109429:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c010942c:	c7 45 f8 44 d1 12 c0 	movl   $0xc012d144,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c0109433:	a1 78 7a 12 c0       	mov    0xc0127a78,%eax
c0109438:	83 c0 01             	add    $0x1,%eax
c010943b:	a3 78 7a 12 c0       	mov    %eax,0xc0127a78
c0109440:	a1 78 7a 12 c0       	mov    0xc0127a78,%eax
c0109445:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c010944a:	7e 0c                	jle    c0109458 <get_pid+0x32>
        last_pid = 1;
c010944c:	c7 05 78 7a 12 c0 01 	movl   $0x1,0xc0127a78
c0109453:	00 00 00 
        goto inside;
c0109456:	eb 13                	jmp    c010946b <get_pid+0x45>
    }
    if (last_pid >= next_safe) {
c0109458:	8b 15 78 7a 12 c0    	mov    0xc0127a78,%edx
c010945e:	a1 7c 7a 12 c0       	mov    0xc0127a7c,%eax
c0109463:	39 c2                	cmp    %eax,%edx
c0109465:	0f 8c ac 00 00 00    	jl     c0109517 <get_pid+0xf1>
    inside:
        next_safe = MAX_PID;
c010946b:	c7 05 7c 7a 12 c0 00 	movl   $0x2000,0xc0127a7c
c0109472:	20 00 00 
    repeat:
        le = list;
c0109475:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109478:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c010947b:	eb 7f                	jmp    c01094fc <get_pid+0xd6>
            proc = le2proc(le, list_link);
c010947d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109480:	83 e8 58             	sub    $0x58,%eax
c0109483:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c0109486:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109489:	8b 50 04             	mov    0x4(%eax),%edx
c010948c:	a1 78 7a 12 c0       	mov    0xc0127a78,%eax
c0109491:	39 c2                	cmp    %eax,%edx
c0109493:	75 3e                	jne    c01094d3 <get_pid+0xad>
                if (++ last_pid >= next_safe) {
c0109495:	a1 78 7a 12 c0       	mov    0xc0127a78,%eax
c010949a:	83 c0 01             	add    $0x1,%eax
c010949d:	a3 78 7a 12 c0       	mov    %eax,0xc0127a78
c01094a2:	8b 15 78 7a 12 c0    	mov    0xc0127a78,%edx
c01094a8:	a1 7c 7a 12 c0       	mov    0xc0127a7c,%eax
c01094ad:	39 c2                	cmp    %eax,%edx
c01094af:	7c 4b                	jl     c01094fc <get_pid+0xd6>
                    if (last_pid >= MAX_PID) {
c01094b1:	a1 78 7a 12 c0       	mov    0xc0127a78,%eax
c01094b6:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c01094bb:	7e 0a                	jle    c01094c7 <get_pid+0xa1>
                        last_pid = 1;
c01094bd:	c7 05 78 7a 12 c0 01 	movl   $0x1,0xc0127a78
c01094c4:	00 00 00 
                    }
                    next_safe = MAX_PID;
c01094c7:	c7 05 7c 7a 12 c0 00 	movl   $0x2000,0xc0127a7c
c01094ce:	20 00 00 
                    goto repeat;
c01094d1:	eb a2                	jmp    c0109475 <get_pid+0x4f>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c01094d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094d6:	8b 50 04             	mov    0x4(%eax),%edx
c01094d9:	a1 78 7a 12 c0       	mov    0xc0127a78,%eax
c01094de:	39 c2                	cmp    %eax,%edx
c01094e0:	7e 1a                	jle    c01094fc <get_pid+0xd6>
c01094e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094e5:	8b 50 04             	mov    0x4(%eax),%edx
c01094e8:	a1 7c 7a 12 c0       	mov    0xc0127a7c,%eax
c01094ed:	39 c2                	cmp    %eax,%edx
c01094ef:	7d 0b                	jge    c01094fc <get_pid+0xd6>
                next_safe = proc->pid;
c01094f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094f4:	8b 40 04             	mov    0x4(%eax),%eax
c01094f7:	a3 7c 7a 12 c0       	mov    %eax,0xc0127a7c
c01094fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01094ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109502:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109505:	8b 40 04             	mov    0x4(%eax),%eax
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
c0109508:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010950b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010950e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0109511:	0f 85 66 ff ff ff    	jne    c010947d <get_pid+0x57>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
c0109517:	a1 78 7a 12 c0       	mov    0xc0127a78,%eax
}
c010951c:	c9                   	leave  
c010951d:	c3                   	ret    

c010951e <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c010951e:	55                   	push   %ebp
c010951f:	89 e5                	mov    %esp,%ebp
c0109521:	83 ec 18             	sub    $0x18,%esp
    if (proc != current) {
c0109524:	a1 28 b0 12 c0       	mov    0xc012b028,%eax
c0109529:	39 45 08             	cmp    %eax,0x8(%ebp)
c010952c:	74 6b                	je     c0109599 <proc_run+0x7b>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c010952e:	a1 28 b0 12 c0       	mov    0xc012b028,%eax
c0109533:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109536:	8b 45 08             	mov    0x8(%ebp),%eax
c0109539:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c010953c:	e8 90 fc ff ff       	call   c01091d1 <__intr_save>
c0109541:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c0109544:	8b 45 08             	mov    0x8(%ebp),%eax
c0109547:	a3 28 b0 12 c0       	mov    %eax,0xc012b028
            load_esp0(next->kstack + KSTACKSIZE);
c010954c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010954f:	8b 40 0c             	mov    0xc(%eax),%eax
c0109552:	05 00 20 00 00       	add    $0x2000,%eax
c0109557:	83 ec 0c             	sub    $0xc,%esp
c010955a:	50                   	push   %eax
c010955b:	e8 61 e4 ff ff       	call   c01079c1 <load_esp0>
c0109560:	83 c4 10             	add    $0x10,%esp
            lcr3(next->cr3);
c0109563:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109566:	8b 40 40             	mov    0x40(%eax),%eax
c0109569:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c010956c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010956f:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c0109572:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109575:	8d 50 1c             	lea    0x1c(%eax),%edx
c0109578:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010957b:	83 c0 1c             	add    $0x1c,%eax
c010957e:	83 ec 08             	sub    $0x8,%esp
c0109581:	52                   	push   %edx
c0109582:	50                   	push   %eax
c0109583:	e8 09 fc ff ff       	call   c0109191 <switch_to>
c0109588:	83 c4 10             	add    $0x10,%esp
        }
        local_intr_restore(intr_flag);
c010958b:	83 ec 0c             	sub    $0xc,%esp
c010958e:	ff 75 ec             	pushl  -0x14(%ebp)
c0109591:	e8 65 fc ff ff       	call   c01091fb <__intr_restore>
c0109596:	83 c4 10             	add    $0x10,%esp
    }
}
c0109599:	90                   	nop
c010959a:	c9                   	leave  
c010959b:	c3                   	ret    

c010959c <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c010959c:	55                   	push   %ebp
c010959d:	89 e5                	mov    %esp,%ebp
c010959f:	83 ec 08             	sub    $0x8,%esp
    forkrets(current->tf);
c01095a2:	a1 28 b0 12 c0       	mov    0xc012b028,%eax
c01095a7:	8b 40 3c             	mov    0x3c(%eax),%eax
c01095aa:	83 ec 0c             	sub    $0xc,%esp
c01095ad:	50                   	push   %eax
c01095ae:	e8 75 af ff ff       	call   c0104528 <forkrets>
c01095b3:	83 c4 10             	add    $0x10,%esp
}
c01095b6:	90                   	nop
c01095b7:	c9                   	leave  
c01095b8:	c3                   	ret    

c01095b9 <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c01095b9:	55                   	push   %ebp
c01095ba:	89 e5                	mov    %esp,%ebp
c01095bc:	53                   	push   %ebx
c01095bd:	83 ec 24             	sub    $0x24,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c01095c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01095c3:	8d 58 60             	lea    0x60(%eax),%ebx
c01095c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01095c9:	8b 40 04             	mov    0x4(%eax),%eax
c01095cc:	83 ec 08             	sub    $0x8,%esp
c01095cf:	6a 0a                	push   $0xa
c01095d1:	50                   	push   %eax
c01095d2:	e8 09 12 00 00       	call   c010a7e0 <hash32>
c01095d7:	83 c4 10             	add    $0x10,%esp
c01095da:	c1 e0 03             	shl    $0x3,%eax
c01095dd:	05 40 b0 12 c0       	add    $0xc012b040,%eax
c01095e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01095e5:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c01095e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01095ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01095f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01095f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01095f7:	8b 40 04             	mov    0x4(%eax),%eax
c01095fa:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01095fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109600:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109603:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0109606:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0109609:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010960c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010960f:	89 10                	mov    %edx,(%eax)
c0109611:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109614:	8b 10                	mov    (%eax),%edx
c0109616:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109619:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010961c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010961f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109622:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109625:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109628:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010962b:	89 10                	mov    %edx,(%eax)
}
c010962d:	90                   	nop
c010962e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0109631:	c9                   	leave  
c0109632:	c3                   	ret    

c0109633 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0109633:	55                   	push   %ebp
c0109634:	89 e5                	mov    %esp,%ebp
c0109636:	83 ec 18             	sub    $0x18,%esp
    if (0 < pid && pid < MAX_PID) {
c0109639:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010963d:	7e 5d                	jle    c010969c <find_proc+0x69>
c010963f:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0109646:	7f 54                	jg     c010969c <find_proc+0x69>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0109648:	8b 45 08             	mov    0x8(%ebp),%eax
c010964b:	83 ec 08             	sub    $0x8,%esp
c010964e:	6a 0a                	push   $0xa
c0109650:	50                   	push   %eax
c0109651:	e8 8a 11 00 00       	call   c010a7e0 <hash32>
c0109656:	83 c4 10             	add    $0x10,%esp
c0109659:	c1 e0 03             	shl    $0x3,%eax
c010965c:	05 40 b0 12 c0       	add    $0xc012b040,%eax
c0109661:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109664:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109667:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c010966a:	eb 19                	jmp    c0109685 <find_proc+0x52>
            struct proc_struct *proc = le2proc(le, hash_link);
c010966c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010966f:	83 e8 60             	sub    $0x60,%eax
c0109672:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c0109675:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109678:	8b 40 04             	mov    0x4(%eax),%eax
c010967b:	3b 45 08             	cmp    0x8(%ebp),%eax
c010967e:	75 05                	jne    c0109685 <find_proc+0x52>
                return proc;
c0109680:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109683:	eb 1c                	jmp    c01096a1 <find_proc+0x6e>
c0109685:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109688:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010968b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010968e:	8b 40 04             	mov    0x4(%eax),%eax
// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
c0109691:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109694:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109697:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010969a:	75 d0                	jne    c010966c <find_proc+0x39>
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
c010969c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01096a1:	c9                   	leave  
c01096a2:	c3                   	ret    

c01096a3 <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c01096a3:	55                   	push   %ebp
c01096a4:	89 e5                	mov    %esp,%ebp
c01096a6:	83 ec 58             	sub    $0x58,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c01096a9:	83 ec 04             	sub    $0x4,%esp
c01096ac:	6a 4c                	push   $0x4c
c01096ae:	6a 00                	push   $0x0
c01096b0:	8d 45 ac             	lea    -0x54(%ebp),%eax
c01096b3:	50                   	push   %eax
c01096b4:	e8 90 09 00 00       	call   c010a049 <memset>
c01096b9:	83 c4 10             	add    $0x10,%esp
    tf.tf_cs = KERNEL_CS;
c01096bc:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c01096c2:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c01096c8:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01096cc:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c01096d0:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c01096d4:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c01096d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01096db:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c01096de:	8b 45 0c             	mov    0xc(%ebp),%eax
c01096e1:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c01096e4:	b8 c8 91 10 c0       	mov    $0xc01091c8,%eax
c01096e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c01096ec:	8b 45 10             	mov    0x10(%ebp),%eax
c01096ef:	80 cc 01             	or     $0x1,%ah
c01096f2:	89 c2                	mov    %eax,%edx
c01096f4:	83 ec 04             	sub    $0x4,%esp
c01096f7:	8d 45 ac             	lea    -0x54(%ebp),%eax
c01096fa:	50                   	push   %eax
c01096fb:	6a 00                	push   $0x0
c01096fd:	52                   	push   %edx
c01096fe:	e8 3c 01 00 00       	call   c010983f <do_fork>
c0109703:	83 c4 10             	add    $0x10,%esp
}
c0109706:	c9                   	leave  
c0109707:	c3                   	ret    

c0109708 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0109708:	55                   	push   %ebp
c0109709:	89 e5                	mov    %esp,%ebp
c010970b:	83 ec 18             	sub    $0x18,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c010970e:	83 ec 0c             	sub    $0xc,%esp
c0109711:	6a 02                	push   $0x2
c0109713:	e8 fd e3 ff ff       	call   c0107b15 <alloc_pages>
c0109718:	83 c4 10             	add    $0x10,%esp
c010971b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c010971e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109722:	74 1d                	je     c0109741 <setup_kstack+0x39>
        proc->kstack = (uintptr_t)page2kva(page);
c0109724:	83 ec 0c             	sub    $0xc,%esp
c0109727:	ff 75 f4             	pushl  -0xc(%ebp)
c010972a:	e8 53 fb ff ff       	call   c0109282 <page2kva>
c010972f:	83 c4 10             	add    $0x10,%esp
c0109732:	89 c2                	mov    %eax,%edx
c0109734:	8b 45 08             	mov    0x8(%ebp),%eax
c0109737:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c010973a:	b8 00 00 00 00       	mov    $0x0,%eax
c010973f:	eb 05                	jmp    c0109746 <setup_kstack+0x3e>
    }
    return -E_NO_MEM;
c0109741:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0109746:	c9                   	leave  
c0109747:	c3                   	ret    

c0109748 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0109748:	55                   	push   %ebp
c0109749:	89 e5                	mov    %esp,%ebp
c010974b:	83 ec 08             	sub    $0x8,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c010974e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109751:	8b 40 0c             	mov    0xc(%eax),%eax
c0109754:	83 ec 0c             	sub    $0xc,%esp
c0109757:	50                   	push   %eax
c0109758:	e8 6a fb ff ff       	call   c01092c7 <kva2page>
c010975d:	83 c4 10             	add    $0x10,%esp
c0109760:	83 ec 08             	sub    $0x8,%esp
c0109763:	6a 02                	push   $0x2
c0109765:	50                   	push   %eax
c0109766:	e8 16 e4 ff ff       	call   c0107b81 <free_pages>
c010976b:	83 c4 10             	add    $0x10,%esp
}
c010976e:	90                   	nop
c010976f:	c9                   	leave  
c0109770:	c3                   	ret    

c0109771 <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0109771:	55                   	push   %ebp
c0109772:	89 e5                	mov    %esp,%ebp
c0109774:	83 ec 08             	sub    $0x8,%esp
    assert(current->mm == NULL);
c0109777:	a1 28 b0 12 c0       	mov    0xc012b028,%eax
c010977c:	8b 40 18             	mov    0x18(%eax),%eax
c010977f:	85 c0                	test   %eax,%eax
c0109781:	74 19                	je     c010979c <copy_mm+0x2b>
c0109783:	68 8c ca 10 c0       	push   $0xc010ca8c
c0109788:	68 a0 ca 10 c0       	push   $0xc010caa0
c010978d:	68 fe 00 00 00       	push   $0xfe
c0109792:	68 b5 ca 10 c0       	push   $0xc010cab5
c0109797:	e8 cc 7f ff ff       	call   c0101768 <__panic>
    /* do nothing in this project */
    return 0;
c010979c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01097a1:	c9                   	leave  
c01097a2:	c3                   	ret    

c01097a3 <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c01097a3:	55                   	push   %ebp
c01097a4:	89 e5                	mov    %esp,%ebp
c01097a6:	57                   	push   %edi
c01097a7:	56                   	push   %esi
c01097a8:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c01097a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01097ac:	8b 40 0c             	mov    0xc(%eax),%eax
c01097af:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c01097b4:	89 c2                	mov    %eax,%edx
c01097b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01097b9:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c01097bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01097bf:	8b 40 3c             	mov    0x3c(%eax),%eax
c01097c2:	8b 55 10             	mov    0x10(%ebp),%edx
c01097c5:	89 d3                	mov    %edx,%ebx
c01097c7:	ba 4c 00 00 00       	mov    $0x4c,%edx
c01097cc:	8b 0b                	mov    (%ebx),%ecx
c01097ce:	89 08                	mov    %ecx,(%eax)
c01097d0:	8b 4c 13 fc          	mov    -0x4(%ebx,%edx,1),%ecx
c01097d4:	89 4c 10 fc          	mov    %ecx,-0x4(%eax,%edx,1)
c01097d8:	8d 78 04             	lea    0x4(%eax),%edi
c01097db:	83 e7 fc             	and    $0xfffffffc,%edi
c01097de:	29 f8                	sub    %edi,%eax
c01097e0:	29 c3                	sub    %eax,%ebx
c01097e2:	01 c2                	add    %eax,%edx
c01097e4:	83 e2 fc             	and    $0xfffffffc,%edx
c01097e7:	89 d0                	mov    %edx,%eax
c01097e9:	c1 e8 02             	shr    $0x2,%eax
c01097ec:	89 de                	mov    %ebx,%esi
c01097ee:	89 c1                	mov    %eax,%ecx
c01097f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    proc->tf->tf_regs.reg_eax = 0;
c01097f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01097f5:	8b 40 3c             	mov    0x3c(%eax),%eax
c01097f8:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c01097ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0109802:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109805:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109808:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c010980b:	8b 45 08             	mov    0x8(%ebp),%eax
c010980e:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109811:	8b 55 08             	mov    0x8(%ebp),%edx
c0109814:	8b 52 3c             	mov    0x3c(%edx),%edx
c0109817:	8b 52 40             	mov    0x40(%edx),%edx
c010981a:	80 ce 02             	or     $0x2,%dh
c010981d:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c0109820:	ba 9c 95 10 c0       	mov    $0xc010959c,%edx
c0109825:	8b 45 08             	mov    0x8(%ebp),%eax
c0109828:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c010982b:	8b 45 08             	mov    0x8(%ebp),%eax
c010982e:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109831:	89 c2                	mov    %eax,%edx
c0109833:	8b 45 08             	mov    0x8(%ebp),%eax
c0109836:	89 50 20             	mov    %edx,0x20(%eax)
}
c0109839:	90                   	nop
c010983a:	5b                   	pop    %ebx
c010983b:	5e                   	pop    %esi
c010983c:	5f                   	pop    %edi
c010983d:	5d                   	pop    %ebp
c010983e:	c3                   	ret    

c010983f <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c010983f:	55                   	push   %ebp
c0109840:	89 e5                	mov    %esp,%ebp
c0109842:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_NO_FREE_PROC;
c0109845:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c010984c:	a1 40 d0 12 c0       	mov    0xc012d040,%eax
c0109851:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0109856:	0f 8f 14 01 00 00    	jg     c0109970 <do_fork+0x131>
        goto fork_out;
    }
    ret = -E_NO_MEM;
c010985c:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    if ((proc = alloc_proc()) == NULL) {
c0109863:	e8 9e fa ff ff       	call   c0109306 <alloc_proc>
c0109868:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010986b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010986f:	0f 84 fe 00 00 00    	je     c0109973 <do_fork+0x134>
        goto fork_out;
    }

    proc->parent = current;
c0109875:	8b 15 28 b0 12 c0    	mov    0xc012b028,%edx
c010987b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010987e:	89 50 14             	mov    %edx,0x14(%eax)

    if (setup_kstack(proc) != 0) {
c0109881:	83 ec 0c             	sub    $0xc,%esp
c0109884:	ff 75 f0             	pushl  -0x10(%ebp)
c0109887:	e8 7c fe ff ff       	call   c0109708 <setup_kstack>
c010988c:	83 c4 10             	add    $0x10,%esp
c010988f:	85 c0                	test   %eax,%eax
c0109891:	0f 85 f3 00 00 00    	jne    c010998a <do_fork+0x14b>
        goto bad_fork_cleanup_proc;
    }
    if (copy_mm(clone_flags, proc) != 0) {
c0109897:	83 ec 08             	sub    $0x8,%esp
c010989a:	ff 75 f0             	pushl  -0x10(%ebp)
c010989d:	ff 75 08             	pushl  0x8(%ebp)
c01098a0:	e8 cc fe ff ff       	call   c0109771 <copy_mm>
c01098a5:	83 c4 10             	add    $0x10,%esp
c01098a8:	85 c0                	test   %eax,%eax
c01098aa:	0f 85 c9 00 00 00    	jne    c0109979 <do_fork+0x13a>
        goto bad_fork_cleanup_kstack;
    }
    copy_thread(proc, stack, tf);
c01098b0:	83 ec 04             	sub    $0x4,%esp
c01098b3:	ff 75 10             	pushl  0x10(%ebp)
c01098b6:	ff 75 0c             	pushl  0xc(%ebp)
c01098b9:	ff 75 f0             	pushl  -0x10(%ebp)
c01098bc:	e8 e2 fe ff ff       	call   c01097a3 <copy_thread>
c01098c1:	83 c4 10             	add    $0x10,%esp

    bool intr_flag;
    local_intr_save(intr_flag);
c01098c4:	e8 08 f9 ff ff       	call   c01091d1 <__intr_save>
c01098c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        proc->pid = get_pid();
c01098cc:	e8 55 fb ff ff       	call   c0109426 <get_pid>
c01098d1:	89 c2                	mov    %eax,%edx
c01098d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01098d6:	89 50 04             	mov    %edx,0x4(%eax)
        hash_proc(proc);
c01098d9:	83 ec 0c             	sub    $0xc,%esp
c01098dc:	ff 75 f0             	pushl  -0x10(%ebp)
c01098df:	e8 d5 fc ff ff       	call   c01095b9 <hash_proc>
c01098e4:	83 c4 10             	add    $0x10,%esp
        list_add(&proc_list, &(proc->list_link));
c01098e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01098ea:	83 c0 58             	add    $0x58,%eax
c01098ed:	c7 45 e8 44 d1 12 c0 	movl   $0xc012d144,-0x18(%ebp)
c01098f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01098f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01098fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01098fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109900:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0109903:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109906:	8b 40 04             	mov    0x4(%eax),%eax
c0109909:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010990c:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010990f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109912:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0109915:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0109918:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010991b:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010991e:	89 10                	mov    %edx,(%eax)
c0109920:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0109923:	8b 10                	mov    (%eax),%edx
c0109925:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0109928:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010992b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010992e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0109931:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109934:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109937:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010993a:	89 10                	mov    %edx,(%eax)
        nr_process ++;
c010993c:	a1 40 d0 12 c0       	mov    0xc012d040,%eax
c0109941:	83 c0 01             	add    $0x1,%eax
c0109944:	a3 40 d0 12 c0       	mov    %eax,0xc012d040
    }
    local_intr_restore(intr_flag);
c0109949:	83 ec 0c             	sub    $0xc,%esp
c010994c:	ff 75 ec             	pushl  -0x14(%ebp)
c010994f:	e8 a7 f8 ff ff       	call   c01091fb <__intr_restore>
c0109954:	83 c4 10             	add    $0x10,%esp

    wakeup_proc(proc);
c0109957:	83 ec 0c             	sub    $0xc,%esp
c010995a:	ff 75 f0             	pushl  -0x10(%ebp)
c010995d:	e8 ac 02 00 00       	call   c0109c0e <wakeup_proc>
c0109962:	83 c4 10             	add    $0x10,%esp

    ret = proc->pid;
c0109965:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109968:	8b 40 04             	mov    0x4(%eax),%eax
c010996b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010996e:	eb 04                	jmp    c0109974 <do_fork+0x135>
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
c0109970:	90                   	nop
c0109971:	eb 01                	jmp    c0109974 <do_fork+0x135>
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    if ((proc = alloc_proc()) == NULL) {
        goto fork_out;
c0109973:	90                   	nop

    wakeup_proc(proc);

    ret = proc->pid;
fork_out:
    return ret;
c0109974:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109977:	eb 22                	jmp    c010999b <do_fork+0x15c>

    if (setup_kstack(proc) != 0) {
        goto bad_fork_cleanup_proc;
    }
    if (copy_mm(clone_flags, proc) != 0) {
        goto bad_fork_cleanup_kstack;
c0109979:	90                   	nop
    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
c010997a:	83 ec 0c             	sub    $0xc,%esp
c010997d:	ff 75 f0             	pushl  -0x10(%ebp)
c0109980:	e8 c3 fd ff ff       	call   c0109748 <put_kstack>
c0109985:	83 c4 10             	add    $0x10,%esp
c0109988:	eb 01                	jmp    c010998b <do_fork+0x14c>
    }

    proc->parent = current;

    if (setup_kstack(proc) != 0) {
        goto bad_fork_cleanup_proc;
c010998a:	90                   	nop
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
c010998b:	83 ec 0c             	sub    $0xc,%esp
c010998e:	ff 75 f0             	pushl  -0x10(%ebp)
c0109991:	e8 90 c8 ff ff       	call   c0106226 <kfree>
c0109996:	83 c4 10             	add    $0x10,%esp
    goto fork_out;
c0109999:	eb d9                	jmp    c0109974 <do_fork+0x135>
}
c010999b:	c9                   	leave  
c010999c:	c3                   	ret    

c010999d <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c010999d:	55                   	push   %ebp
c010999e:	89 e5                	mov    %esp,%ebp
c01099a0:	83 ec 08             	sub    $0x8,%esp
    panic("process exit!!.\n");
c01099a3:	83 ec 04             	sub    $0x4,%esp
c01099a6:	68 c9 ca 10 c0       	push   $0xc010cac9
c01099ab:	68 62 01 00 00       	push   $0x162
c01099b0:	68 b5 ca 10 c0       	push   $0xc010cab5
c01099b5:	e8 ae 7d ff ff       	call   c0101768 <__panic>

c01099ba <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c01099ba:	55                   	push   %ebp
c01099bb:	89 e5                	mov    %esp,%ebp
c01099bd:	83 ec 08             	sub    $0x8,%esp
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
c01099c0:	a1 28 b0 12 c0       	mov    0xc012b028,%eax
c01099c5:	83 ec 0c             	sub    $0xc,%esp
c01099c8:	50                   	push   %eax
c01099c9:	e8 23 fa ff ff       	call   c01093f1 <get_proc_name>
c01099ce:	83 c4 10             	add    $0x10,%esp
c01099d1:	89 c2                	mov    %eax,%edx
c01099d3:	a1 28 b0 12 c0       	mov    0xc012b028,%eax
c01099d8:	8b 40 04             	mov    0x4(%eax),%eax
c01099db:	83 ec 04             	sub    $0x4,%esp
c01099de:	52                   	push   %edx
c01099df:	50                   	push   %eax
c01099e0:	68 dc ca 10 c0       	push   $0xc010cadc
c01099e5:	e8 a0 68 ff ff       	call   c010028a <cprintf>
c01099ea:	83 c4 10             	add    $0x10,%esp
    cprintf("To U: \"%s\".\n", (const char *)arg);
c01099ed:	83 ec 08             	sub    $0x8,%esp
c01099f0:	ff 75 08             	pushl  0x8(%ebp)
c01099f3:	68 02 cb 10 c0       	push   $0xc010cb02
c01099f8:	e8 8d 68 ff ff       	call   c010028a <cprintf>
c01099fd:	83 c4 10             	add    $0x10,%esp
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
c0109a00:	83 ec 0c             	sub    $0xc,%esp
c0109a03:	68 0f cb 10 c0       	push   $0xc010cb0f
c0109a08:	e8 7d 68 ff ff       	call   c010028a <cprintf>
c0109a0d:	83 c4 10             	add    $0x10,%esp
    return 0;
c0109a10:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109a15:	c9                   	leave  
c0109a16:	c3                   	ret    

c0109a17 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c0109a17:	55                   	push   %ebp
c0109a18:	89 e5                	mov    %esp,%ebp
c0109a1a:	83 ec 18             	sub    $0x18,%esp
c0109a1d:	c7 45 e8 44 d1 12 c0 	movl   $0xc012d144,-0x18(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0109a24:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109a27:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109a2a:	89 50 04             	mov    %edx,0x4(%eax)
c0109a2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109a30:	8b 50 04             	mov    0x4(%eax),%edx
c0109a33:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109a36:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c0109a38:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0109a3f:	eb 26                	jmp    c0109a67 <proc_init+0x50>
        list_init(hash_list + i);
c0109a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a44:	c1 e0 03             	shl    $0x3,%eax
c0109a47:	05 40 b0 12 c0       	add    $0xc012b040,%eax
c0109a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109a4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a52:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109a55:	89 50 04             	mov    %edx,0x4(%eax)
c0109a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a5b:	8b 50 04             	mov    0x4(%eax),%edx
c0109a5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a61:	89 10                	mov    %edx,(%eax)
void
proc_init(void) {
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c0109a63:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0109a67:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c0109a6e:	7e d1                	jle    c0109a41 <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
c0109a70:	e8 91 f8 ff ff       	call   c0109306 <alloc_proc>
c0109a75:	a3 20 b0 12 c0       	mov    %eax,0xc012b020
c0109a7a:	a1 20 b0 12 c0       	mov    0xc012b020,%eax
c0109a7f:	85 c0                	test   %eax,%eax
c0109a81:	75 17                	jne    c0109a9a <proc_init+0x83>
        panic("cannot alloc idleproc.\n");
c0109a83:	83 ec 04             	sub    $0x4,%esp
c0109a86:	68 2b cb 10 c0       	push   $0xc010cb2b
c0109a8b:	68 7a 01 00 00       	push   $0x17a
c0109a90:	68 b5 ca 10 c0       	push   $0xc010cab5
c0109a95:	e8 ce 7c ff ff       	call   c0101768 <__panic>
    }

    idleproc->pid = 0;
c0109a9a:	a1 20 b0 12 c0       	mov    0xc012b020,%eax
c0109a9f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c0109aa6:	a1 20 b0 12 c0       	mov    0xc012b020,%eax
c0109aab:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c0109ab1:	a1 20 b0 12 c0       	mov    0xc012b020,%eax
c0109ab6:	ba 00 50 12 c0       	mov    $0xc0125000,%edx
c0109abb:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c0109abe:	a1 20 b0 12 c0       	mov    0xc012b020,%eax
c0109ac3:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c0109aca:	a1 20 b0 12 c0       	mov    0xc012b020,%eax
c0109acf:	83 ec 08             	sub    $0x8,%esp
c0109ad2:	68 43 cb 10 c0       	push   $0xc010cb43
c0109ad7:	50                   	push   %eax
c0109ad8:	e8 df f8 ff ff       	call   c01093bc <set_proc_name>
c0109add:	83 c4 10             	add    $0x10,%esp
    nr_process ++;
c0109ae0:	a1 40 d0 12 c0       	mov    0xc012d040,%eax
c0109ae5:	83 c0 01             	add    $0x1,%eax
c0109ae8:	a3 40 d0 12 c0       	mov    %eax,0xc012d040

    current = idleproc;
c0109aed:	a1 20 b0 12 c0       	mov    0xc012b020,%eax
c0109af2:	a3 28 b0 12 c0       	mov    %eax,0xc012b028

    int pid = kernel_thread(init_main, "Hello world!!", 0);
c0109af7:	83 ec 04             	sub    $0x4,%esp
c0109afa:	6a 00                	push   $0x0
c0109afc:	68 48 cb 10 c0       	push   $0xc010cb48
c0109b01:	68 ba 99 10 c0       	push   $0xc01099ba
c0109b06:	e8 98 fb ff ff       	call   c01096a3 <kernel_thread>
c0109b0b:	83 c4 10             	add    $0x10,%esp
c0109b0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid <= 0) {
c0109b11:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109b15:	7f 17                	jg     c0109b2e <proc_init+0x117>
        panic("create init_main failed.\n");
c0109b17:	83 ec 04             	sub    $0x4,%esp
c0109b1a:	68 56 cb 10 c0       	push   $0xc010cb56
c0109b1f:	68 88 01 00 00       	push   $0x188
c0109b24:	68 b5 ca 10 c0       	push   $0xc010cab5
c0109b29:	e8 3a 7c ff ff       	call   c0101768 <__panic>
    }

    initproc = find_proc(pid);
c0109b2e:	83 ec 0c             	sub    $0xc,%esp
c0109b31:	ff 75 ec             	pushl  -0x14(%ebp)
c0109b34:	e8 fa fa ff ff       	call   c0109633 <find_proc>
c0109b39:	83 c4 10             	add    $0x10,%esp
c0109b3c:	a3 24 b0 12 c0       	mov    %eax,0xc012b024
    set_proc_name(initproc, "init");
c0109b41:	a1 24 b0 12 c0       	mov    0xc012b024,%eax
c0109b46:	83 ec 08             	sub    $0x8,%esp
c0109b49:	68 70 cb 10 c0       	push   $0xc010cb70
c0109b4e:	50                   	push   %eax
c0109b4f:	e8 68 f8 ff ff       	call   c01093bc <set_proc_name>
c0109b54:	83 c4 10             	add    $0x10,%esp

    assert(idleproc != NULL && idleproc->pid == 0);
c0109b57:	a1 20 b0 12 c0       	mov    0xc012b020,%eax
c0109b5c:	85 c0                	test   %eax,%eax
c0109b5e:	74 0c                	je     c0109b6c <proc_init+0x155>
c0109b60:	a1 20 b0 12 c0       	mov    0xc012b020,%eax
c0109b65:	8b 40 04             	mov    0x4(%eax),%eax
c0109b68:	85 c0                	test   %eax,%eax
c0109b6a:	74 19                	je     c0109b85 <proc_init+0x16e>
c0109b6c:	68 78 cb 10 c0       	push   $0xc010cb78
c0109b71:	68 a0 ca 10 c0       	push   $0xc010caa0
c0109b76:	68 8e 01 00 00       	push   $0x18e
c0109b7b:	68 b5 ca 10 c0       	push   $0xc010cab5
c0109b80:	e8 e3 7b ff ff       	call   c0101768 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c0109b85:	a1 24 b0 12 c0       	mov    0xc012b024,%eax
c0109b8a:	85 c0                	test   %eax,%eax
c0109b8c:	74 0d                	je     c0109b9b <proc_init+0x184>
c0109b8e:	a1 24 b0 12 c0       	mov    0xc012b024,%eax
c0109b93:	8b 40 04             	mov    0x4(%eax),%eax
c0109b96:	83 f8 01             	cmp    $0x1,%eax
c0109b99:	74 19                	je     c0109bb4 <proc_init+0x19d>
c0109b9b:	68 a0 cb 10 c0       	push   $0xc010cba0
c0109ba0:	68 a0 ca 10 c0       	push   $0xc010caa0
c0109ba5:	68 8f 01 00 00       	push   $0x18f
c0109baa:	68 b5 ca 10 c0       	push   $0xc010cab5
c0109baf:	e8 b4 7b ff ff       	call   c0101768 <__panic>
}
c0109bb4:	90                   	nop
c0109bb5:	c9                   	leave  
c0109bb6:	c3                   	ret    

c0109bb7 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c0109bb7:	55                   	push   %ebp
c0109bb8:	89 e5                	mov    %esp,%ebp
c0109bba:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c0109bbd:	a1 28 b0 12 c0       	mov    0xc012b028,%eax
c0109bc2:	8b 40 10             	mov    0x10(%eax),%eax
c0109bc5:	85 c0                	test   %eax,%eax
c0109bc7:	74 f4                	je     c0109bbd <cpu_idle+0x6>
            schedule();
c0109bc9:	e8 7c 00 00 00       	call   c0109c4a <schedule>
        }
    }
c0109bce:	eb ed                	jmp    c0109bbd <cpu_idle+0x6>

c0109bd0 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0109bd0:	55                   	push   %ebp
c0109bd1:	89 e5                	mov    %esp,%ebp
c0109bd3:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0109bd6:	9c                   	pushf  
c0109bd7:	58                   	pop    %eax
c0109bd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0109bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0109bde:	25 00 02 00 00       	and    $0x200,%eax
c0109be3:	85 c0                	test   %eax,%eax
c0109be5:	74 0c                	je     c0109bf3 <__intr_save+0x23>
        intr_disable();
c0109be7:	e8 5d 98 ff ff       	call   c0103449 <intr_disable>
        return 1;
c0109bec:	b8 01 00 00 00       	mov    $0x1,%eax
c0109bf1:	eb 05                	jmp    c0109bf8 <__intr_save+0x28>
    }
    return 0;
c0109bf3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109bf8:	c9                   	leave  
c0109bf9:	c3                   	ret    

c0109bfa <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0109bfa:	55                   	push   %ebp
c0109bfb:	89 e5                	mov    %esp,%ebp
c0109bfd:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0109c00:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109c04:	74 05                	je     c0109c0b <__intr_restore+0x11>
        intr_enable();
c0109c06:	e8 37 98 ff ff       	call   c0103442 <intr_enable>
    }
}
c0109c0b:	90                   	nop
c0109c0c:	c9                   	leave  
c0109c0d:	c3                   	ret    

c0109c0e <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c0109c0e:	55                   	push   %ebp
c0109c0f:	89 e5                	mov    %esp,%ebp
c0109c11:	83 ec 08             	sub    $0x8,%esp
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
c0109c14:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c17:	8b 00                	mov    (%eax),%eax
c0109c19:	83 f8 03             	cmp    $0x3,%eax
c0109c1c:	74 0a                	je     c0109c28 <wakeup_proc+0x1a>
c0109c1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c21:	8b 00                	mov    (%eax),%eax
c0109c23:	83 f8 02             	cmp    $0x2,%eax
c0109c26:	75 16                	jne    c0109c3e <wakeup_proc+0x30>
c0109c28:	68 c8 cb 10 c0       	push   $0xc010cbc8
c0109c2d:	68 03 cc 10 c0       	push   $0xc010cc03
c0109c32:	6a 09                	push   $0x9
c0109c34:	68 18 cc 10 c0       	push   $0xc010cc18
c0109c39:	e8 2a 7b ff ff       	call   c0101768 <__panic>
    proc->state = PROC_RUNNABLE;
c0109c3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c41:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
}
c0109c47:	90                   	nop
c0109c48:	c9                   	leave  
c0109c49:	c3                   	ret    

c0109c4a <schedule>:

void
schedule(void) {
c0109c4a:	55                   	push   %ebp
c0109c4b:	89 e5                	mov    %esp,%ebp
c0109c4d:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c0109c50:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c0109c57:	e8 74 ff ff ff       	call   c0109bd0 <__intr_save>
c0109c5c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c0109c5f:	a1 28 b0 12 c0       	mov    0xc012b028,%eax
c0109c64:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c0109c6b:	8b 15 28 b0 12 c0    	mov    0xc012b028,%edx
c0109c71:	a1 20 b0 12 c0       	mov    0xc012b020,%eax
c0109c76:	39 c2                	cmp    %eax,%edx
c0109c78:	74 0a                	je     c0109c84 <schedule+0x3a>
c0109c7a:	a1 28 b0 12 c0       	mov    0xc012b028,%eax
c0109c7f:	83 c0 58             	add    $0x58,%eax
c0109c82:	eb 05                	jmp    c0109c89 <schedule+0x3f>
c0109c84:	b8 44 d1 12 c0       	mov    $0xc012d144,%eax
c0109c89:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c0109c8c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109c8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109c92:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0109c98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109c9b:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c0109c9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109ca1:	81 7d f4 44 d1 12 c0 	cmpl   $0xc012d144,-0xc(%ebp)
c0109ca8:	74 13                	je     c0109cbd <schedule+0x73>
                next = le2proc(le, list_link);
c0109caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cad:	83 e8 58             	sub    $0x58,%eax
c0109cb0:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c0109cb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109cb6:	8b 00                	mov    (%eax),%eax
c0109cb8:	83 f8 02             	cmp    $0x2,%eax
c0109cbb:	74 0a                	je     c0109cc7 <schedule+0x7d>
                    break;
                }
            }
        } while (le != last);
c0109cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cc0:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0109cc3:	75 cd                	jne    c0109c92 <schedule+0x48>
c0109cc5:	eb 01                	jmp    c0109cc8 <schedule+0x7e>
        le = last;
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
                    break;
c0109cc7:	90                   	nop
                }
            }
        } while (le != last);
        if (next == NULL || next->state != PROC_RUNNABLE) {
c0109cc8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109ccc:	74 0a                	je     c0109cd8 <schedule+0x8e>
c0109cce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109cd1:	8b 00                	mov    (%eax),%eax
c0109cd3:	83 f8 02             	cmp    $0x2,%eax
c0109cd6:	74 08                	je     c0109ce0 <schedule+0x96>
            next = idleproc;
c0109cd8:	a1 20 b0 12 c0       	mov    0xc012b020,%eax
c0109cdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c0109ce0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ce3:	8b 40 08             	mov    0x8(%eax),%eax
c0109ce6:	8d 50 01             	lea    0x1(%eax),%edx
c0109ce9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109cec:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c0109cef:	a1 28 b0 12 c0       	mov    0xc012b028,%eax
c0109cf4:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109cf7:	74 0e                	je     c0109d07 <schedule+0xbd>
            proc_run(next);
c0109cf9:	83 ec 0c             	sub    $0xc,%esp
c0109cfc:	ff 75 f0             	pushl  -0x10(%ebp)
c0109cff:	e8 1a f8 ff ff       	call   c010951e <proc_run>
c0109d04:	83 c4 10             	add    $0x10,%esp
        }
    }
    local_intr_restore(intr_flag);
c0109d07:	83 ec 0c             	sub    $0xc,%esp
c0109d0a:	ff 75 ec             	pushl  -0x14(%ebp)
c0109d0d:	e8 e8 fe ff ff       	call   c0109bfa <__intr_restore>
c0109d12:	83 c4 10             	add    $0x10,%esp
}
c0109d15:	90                   	nop
c0109d16:	c9                   	leave  
c0109d17:	c3                   	ret    

c0109d18 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0109d18:	55                   	push   %ebp
c0109d19:	89 e5                	mov    %esp,%ebp
c0109d1b:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0109d1e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0109d25:	eb 04                	jmp    c0109d2b <strlen+0x13>
        cnt ++;
c0109d27:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0109d2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d2e:	8d 50 01             	lea    0x1(%eax),%edx
c0109d31:	89 55 08             	mov    %edx,0x8(%ebp)
c0109d34:	0f b6 00             	movzbl (%eax),%eax
c0109d37:	84 c0                	test   %al,%al
c0109d39:	75 ec                	jne    c0109d27 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0109d3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0109d3e:	c9                   	leave  
c0109d3f:	c3                   	ret    

c0109d40 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0109d40:	55                   	push   %ebp
c0109d41:	89 e5                	mov    %esp,%ebp
c0109d43:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0109d46:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0109d4d:	eb 04                	jmp    c0109d53 <strnlen+0x13>
        cnt ++;
c0109d4f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0109d53:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109d56:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0109d59:	73 10                	jae    c0109d6b <strnlen+0x2b>
c0109d5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d5e:	8d 50 01             	lea    0x1(%eax),%edx
c0109d61:	89 55 08             	mov    %edx,0x8(%ebp)
c0109d64:	0f b6 00             	movzbl (%eax),%eax
c0109d67:	84 c0                	test   %al,%al
c0109d69:	75 e4                	jne    c0109d4f <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0109d6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0109d6e:	c9                   	leave  
c0109d6f:	c3                   	ret    

c0109d70 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0109d70:	55                   	push   %ebp
c0109d71:	89 e5                	mov    %esp,%ebp
c0109d73:	57                   	push   %edi
c0109d74:	56                   	push   %esi
c0109d75:	83 ec 20             	sub    $0x20,%esp
c0109d78:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109d7e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109d81:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0109d84:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d8a:	89 d1                	mov    %edx,%ecx
c0109d8c:	89 c2                	mov    %eax,%edx
c0109d8e:	89 ce                	mov    %ecx,%esi
c0109d90:	89 d7                	mov    %edx,%edi
c0109d92:	ac                   	lods   %ds:(%esi),%al
c0109d93:	aa                   	stos   %al,%es:(%edi)
c0109d94:	84 c0                	test   %al,%al
c0109d96:	75 fa                	jne    c0109d92 <strcpy+0x22>
c0109d98:	89 fa                	mov    %edi,%edx
c0109d9a:	89 f1                	mov    %esi,%ecx
c0109d9c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0109d9f:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109da2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0109da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c0109da8:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0109da9:	83 c4 20             	add    $0x20,%esp
c0109dac:	5e                   	pop    %esi
c0109dad:	5f                   	pop    %edi
c0109dae:	5d                   	pop    %ebp
c0109daf:	c3                   	ret    

c0109db0 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0109db0:	55                   	push   %ebp
c0109db1:	89 e5                	mov    %esp,%ebp
c0109db3:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0109db6:	8b 45 08             	mov    0x8(%ebp),%eax
c0109db9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0109dbc:	eb 21                	jmp    c0109ddf <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0109dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109dc1:	0f b6 10             	movzbl (%eax),%edx
c0109dc4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109dc7:	88 10                	mov    %dl,(%eax)
c0109dc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109dcc:	0f b6 00             	movzbl (%eax),%eax
c0109dcf:	84 c0                	test   %al,%al
c0109dd1:	74 04                	je     c0109dd7 <strncpy+0x27>
            src ++;
c0109dd3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0109dd7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0109ddb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0109ddf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109de3:	75 d9                	jne    c0109dbe <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0109de5:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0109de8:	c9                   	leave  
c0109de9:	c3                   	ret    

c0109dea <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0109dea:	55                   	push   %ebp
c0109deb:	89 e5                	mov    %esp,%ebp
c0109ded:	57                   	push   %edi
c0109dee:	56                   	push   %esi
c0109def:	83 ec 20             	sub    $0x20,%esp
c0109df2:	8b 45 08             	mov    0x8(%ebp),%eax
c0109df5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109df8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109dfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0109dfe:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109e01:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109e04:	89 d1                	mov    %edx,%ecx
c0109e06:	89 c2                	mov    %eax,%edx
c0109e08:	89 ce                	mov    %ecx,%esi
c0109e0a:	89 d7                	mov    %edx,%edi
c0109e0c:	ac                   	lods   %ds:(%esi),%al
c0109e0d:	ae                   	scas   %es:(%edi),%al
c0109e0e:	75 08                	jne    c0109e18 <strcmp+0x2e>
c0109e10:	84 c0                	test   %al,%al
c0109e12:	75 f8                	jne    c0109e0c <strcmp+0x22>
c0109e14:	31 c0                	xor    %eax,%eax
c0109e16:	eb 04                	jmp    c0109e1c <strcmp+0x32>
c0109e18:	19 c0                	sbb    %eax,%eax
c0109e1a:	0c 01                	or     $0x1,%al
c0109e1c:	89 fa                	mov    %edi,%edx
c0109e1e:	89 f1                	mov    %esi,%ecx
c0109e20:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109e23:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0109e26:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0109e29:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c0109e2c:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0109e2d:	83 c4 20             	add    $0x20,%esp
c0109e30:	5e                   	pop    %esi
c0109e31:	5f                   	pop    %edi
c0109e32:	5d                   	pop    %ebp
c0109e33:	c3                   	ret    

c0109e34 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0109e34:	55                   	push   %ebp
c0109e35:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0109e37:	eb 0c                	jmp    c0109e45 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0109e39:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0109e3d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0109e41:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0109e45:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109e49:	74 1a                	je     c0109e65 <strncmp+0x31>
c0109e4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e4e:	0f b6 00             	movzbl (%eax),%eax
c0109e51:	84 c0                	test   %al,%al
c0109e53:	74 10                	je     c0109e65 <strncmp+0x31>
c0109e55:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e58:	0f b6 10             	movzbl (%eax),%edx
c0109e5b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e5e:	0f b6 00             	movzbl (%eax),%eax
c0109e61:	38 c2                	cmp    %al,%dl
c0109e63:	74 d4                	je     c0109e39 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0109e65:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109e69:	74 18                	je     c0109e83 <strncmp+0x4f>
c0109e6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e6e:	0f b6 00             	movzbl (%eax),%eax
c0109e71:	0f b6 d0             	movzbl %al,%edx
c0109e74:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e77:	0f b6 00             	movzbl (%eax),%eax
c0109e7a:	0f b6 c0             	movzbl %al,%eax
c0109e7d:	29 c2                	sub    %eax,%edx
c0109e7f:	89 d0                	mov    %edx,%eax
c0109e81:	eb 05                	jmp    c0109e88 <strncmp+0x54>
c0109e83:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109e88:	5d                   	pop    %ebp
c0109e89:	c3                   	ret    

c0109e8a <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0109e8a:	55                   	push   %ebp
c0109e8b:	89 e5                	mov    %esp,%ebp
c0109e8d:	83 ec 04             	sub    $0x4,%esp
c0109e90:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e93:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0109e96:	eb 14                	jmp    c0109eac <strchr+0x22>
        if (*s == c) {
c0109e98:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e9b:	0f b6 00             	movzbl (%eax),%eax
c0109e9e:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0109ea1:	75 05                	jne    c0109ea8 <strchr+0x1e>
            return (char *)s;
c0109ea3:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ea6:	eb 13                	jmp    c0109ebb <strchr+0x31>
        }
        s ++;
c0109ea8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0109eac:	8b 45 08             	mov    0x8(%ebp),%eax
c0109eaf:	0f b6 00             	movzbl (%eax),%eax
c0109eb2:	84 c0                	test   %al,%al
c0109eb4:	75 e2                	jne    c0109e98 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0109eb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109ebb:	c9                   	leave  
c0109ebc:	c3                   	ret    

c0109ebd <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0109ebd:	55                   	push   %ebp
c0109ebe:	89 e5                	mov    %esp,%ebp
c0109ec0:	83 ec 04             	sub    $0x4,%esp
c0109ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ec6:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0109ec9:	eb 0f                	jmp    c0109eda <strfind+0x1d>
        if (*s == c) {
c0109ecb:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ece:	0f b6 00             	movzbl (%eax),%eax
c0109ed1:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0109ed4:	74 10                	je     c0109ee6 <strfind+0x29>
            break;
        }
        s ++;
c0109ed6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0109eda:	8b 45 08             	mov    0x8(%ebp),%eax
c0109edd:	0f b6 00             	movzbl (%eax),%eax
c0109ee0:	84 c0                	test   %al,%al
c0109ee2:	75 e7                	jne    c0109ecb <strfind+0xe>
c0109ee4:	eb 01                	jmp    c0109ee7 <strfind+0x2a>
        if (*s == c) {
            break;
c0109ee6:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
c0109ee7:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0109eea:	c9                   	leave  
c0109eeb:	c3                   	ret    

c0109eec <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0109eec:	55                   	push   %ebp
c0109eed:	89 e5                	mov    %esp,%ebp
c0109eef:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0109ef2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0109ef9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0109f00:	eb 04                	jmp    c0109f06 <strtol+0x1a>
        s ++;
c0109f02:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0109f06:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f09:	0f b6 00             	movzbl (%eax),%eax
c0109f0c:	3c 20                	cmp    $0x20,%al
c0109f0e:	74 f2                	je     c0109f02 <strtol+0x16>
c0109f10:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f13:	0f b6 00             	movzbl (%eax),%eax
c0109f16:	3c 09                	cmp    $0x9,%al
c0109f18:	74 e8                	je     c0109f02 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0109f1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f1d:	0f b6 00             	movzbl (%eax),%eax
c0109f20:	3c 2b                	cmp    $0x2b,%al
c0109f22:	75 06                	jne    c0109f2a <strtol+0x3e>
        s ++;
c0109f24:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0109f28:	eb 15                	jmp    c0109f3f <strtol+0x53>
    }
    else if (*s == '-') {
c0109f2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f2d:	0f b6 00             	movzbl (%eax),%eax
c0109f30:	3c 2d                	cmp    $0x2d,%al
c0109f32:	75 0b                	jne    c0109f3f <strtol+0x53>
        s ++, neg = 1;
c0109f34:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0109f38:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0109f3f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109f43:	74 06                	je     c0109f4b <strtol+0x5f>
c0109f45:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0109f49:	75 24                	jne    c0109f6f <strtol+0x83>
c0109f4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f4e:	0f b6 00             	movzbl (%eax),%eax
c0109f51:	3c 30                	cmp    $0x30,%al
c0109f53:	75 1a                	jne    c0109f6f <strtol+0x83>
c0109f55:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f58:	83 c0 01             	add    $0x1,%eax
c0109f5b:	0f b6 00             	movzbl (%eax),%eax
c0109f5e:	3c 78                	cmp    $0x78,%al
c0109f60:	75 0d                	jne    c0109f6f <strtol+0x83>
        s += 2, base = 16;
c0109f62:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0109f66:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0109f6d:	eb 2a                	jmp    c0109f99 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0109f6f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109f73:	75 17                	jne    c0109f8c <strtol+0xa0>
c0109f75:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f78:	0f b6 00             	movzbl (%eax),%eax
c0109f7b:	3c 30                	cmp    $0x30,%al
c0109f7d:	75 0d                	jne    c0109f8c <strtol+0xa0>
        s ++, base = 8;
c0109f7f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0109f83:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0109f8a:	eb 0d                	jmp    c0109f99 <strtol+0xad>
    }
    else if (base == 0) {
c0109f8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109f90:	75 07                	jne    c0109f99 <strtol+0xad>
        base = 10;
c0109f92:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0109f99:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f9c:	0f b6 00             	movzbl (%eax),%eax
c0109f9f:	3c 2f                	cmp    $0x2f,%al
c0109fa1:	7e 1b                	jle    c0109fbe <strtol+0xd2>
c0109fa3:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fa6:	0f b6 00             	movzbl (%eax),%eax
c0109fa9:	3c 39                	cmp    $0x39,%al
c0109fab:	7f 11                	jg     c0109fbe <strtol+0xd2>
            dig = *s - '0';
c0109fad:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fb0:	0f b6 00             	movzbl (%eax),%eax
c0109fb3:	0f be c0             	movsbl %al,%eax
c0109fb6:	83 e8 30             	sub    $0x30,%eax
c0109fb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109fbc:	eb 48                	jmp    c010a006 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0109fbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fc1:	0f b6 00             	movzbl (%eax),%eax
c0109fc4:	3c 60                	cmp    $0x60,%al
c0109fc6:	7e 1b                	jle    c0109fe3 <strtol+0xf7>
c0109fc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fcb:	0f b6 00             	movzbl (%eax),%eax
c0109fce:	3c 7a                	cmp    $0x7a,%al
c0109fd0:	7f 11                	jg     c0109fe3 <strtol+0xf7>
            dig = *s - 'a' + 10;
c0109fd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fd5:	0f b6 00             	movzbl (%eax),%eax
c0109fd8:	0f be c0             	movsbl %al,%eax
c0109fdb:	83 e8 57             	sub    $0x57,%eax
c0109fde:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109fe1:	eb 23                	jmp    c010a006 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0109fe3:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fe6:	0f b6 00             	movzbl (%eax),%eax
c0109fe9:	3c 40                	cmp    $0x40,%al
c0109feb:	7e 3c                	jle    c010a029 <strtol+0x13d>
c0109fed:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ff0:	0f b6 00             	movzbl (%eax),%eax
c0109ff3:	3c 5a                	cmp    $0x5a,%al
c0109ff5:	7f 32                	jg     c010a029 <strtol+0x13d>
            dig = *s - 'A' + 10;
c0109ff7:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ffa:	0f b6 00             	movzbl (%eax),%eax
c0109ffd:	0f be c0             	movsbl %al,%eax
c010a000:	83 e8 37             	sub    $0x37,%eax
c010a003:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010a006:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a009:	3b 45 10             	cmp    0x10(%ebp),%eax
c010a00c:	7d 1a                	jge    c010a028 <strtol+0x13c>
            break;
        }
        s ++, val = (val * base) + dig;
c010a00e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010a012:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010a015:	0f af 45 10          	imul   0x10(%ebp),%eax
c010a019:	89 c2                	mov    %eax,%edx
c010a01b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a01e:	01 d0                	add    %edx,%eax
c010a020:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c010a023:	e9 71 ff ff ff       	jmp    c0109f99 <strtol+0xad>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
c010a028:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
c010a029:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a02d:	74 08                	je     c010a037 <strtol+0x14b>
        *endptr = (char *) s;
c010a02f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a032:	8b 55 08             	mov    0x8(%ebp),%edx
c010a035:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010a037:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010a03b:	74 07                	je     c010a044 <strtol+0x158>
c010a03d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010a040:	f7 d8                	neg    %eax
c010a042:	eb 03                	jmp    c010a047 <strtol+0x15b>
c010a044:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010a047:	c9                   	leave  
c010a048:	c3                   	ret    

c010a049 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010a049:	55                   	push   %ebp
c010a04a:	89 e5                	mov    %esp,%ebp
c010a04c:	57                   	push   %edi
c010a04d:	83 ec 24             	sub    $0x24,%esp
c010a050:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a053:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010a056:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010a05a:	8b 55 08             	mov    0x8(%ebp),%edx
c010a05d:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010a060:	88 45 f7             	mov    %al,-0x9(%ebp)
c010a063:	8b 45 10             	mov    0x10(%ebp),%eax
c010a066:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010a069:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010a06c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010a070:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010a073:	89 d7                	mov    %edx,%edi
c010a075:	f3 aa                	rep stos %al,%es:(%edi)
c010a077:	89 fa                	mov    %edi,%edx
c010a079:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010a07c:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010a07f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010a082:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010a083:	83 c4 24             	add    $0x24,%esp
c010a086:	5f                   	pop    %edi
c010a087:	5d                   	pop    %ebp
c010a088:	c3                   	ret    

c010a089 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010a089:	55                   	push   %ebp
c010a08a:	89 e5                	mov    %esp,%ebp
c010a08c:	57                   	push   %edi
c010a08d:	56                   	push   %esi
c010a08e:	53                   	push   %ebx
c010a08f:	83 ec 30             	sub    $0x30,%esp
c010a092:	8b 45 08             	mov    0x8(%ebp),%eax
c010a095:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a098:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a09b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010a09e:	8b 45 10             	mov    0x10(%ebp),%eax
c010a0a1:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010a0a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a0a7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010a0aa:	73 42                	jae    c010a0ee <memmove+0x65>
c010a0ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a0af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010a0b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a0b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a0b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a0bb:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010a0be:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a0c1:	c1 e8 02             	shr    $0x2,%eax
c010a0c4:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010a0c6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a0c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a0cc:	89 d7                	mov    %edx,%edi
c010a0ce:	89 c6                	mov    %eax,%esi
c010a0d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010a0d2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010a0d5:	83 e1 03             	and    $0x3,%ecx
c010a0d8:	74 02                	je     c010a0dc <memmove+0x53>
c010a0da:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010a0dc:	89 f0                	mov    %esi,%eax
c010a0de:	89 fa                	mov    %edi,%edx
c010a0e0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010a0e3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010a0e6:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010a0e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c010a0ec:	eb 36                	jmp    c010a124 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010a0ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a0f1:	8d 50 ff             	lea    -0x1(%eax),%edx
c010a0f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a0f7:	01 c2                	add    %eax,%edx
c010a0f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a0fc:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010a0ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a102:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c010a105:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a108:	89 c1                	mov    %eax,%ecx
c010a10a:	89 d8                	mov    %ebx,%eax
c010a10c:	89 d6                	mov    %edx,%esi
c010a10e:	89 c7                	mov    %eax,%edi
c010a110:	fd                   	std    
c010a111:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010a113:	fc                   	cld    
c010a114:	89 f8                	mov    %edi,%eax
c010a116:	89 f2                	mov    %esi,%edx
c010a118:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010a11b:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010a11e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c010a121:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010a124:	83 c4 30             	add    $0x30,%esp
c010a127:	5b                   	pop    %ebx
c010a128:	5e                   	pop    %esi
c010a129:	5f                   	pop    %edi
c010a12a:	5d                   	pop    %ebp
c010a12b:	c3                   	ret    

c010a12c <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010a12c:	55                   	push   %ebp
c010a12d:	89 e5                	mov    %esp,%ebp
c010a12f:	57                   	push   %edi
c010a130:	56                   	push   %esi
c010a131:	83 ec 20             	sub    $0x20,%esp
c010a134:	8b 45 08             	mov    0x8(%ebp),%eax
c010a137:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a13a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a13d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a140:	8b 45 10             	mov    0x10(%ebp),%eax
c010a143:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010a146:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a149:	c1 e8 02             	shr    $0x2,%eax
c010a14c:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010a14e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a151:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a154:	89 d7                	mov    %edx,%edi
c010a156:	89 c6                	mov    %eax,%esi
c010a158:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010a15a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010a15d:	83 e1 03             	and    $0x3,%ecx
c010a160:	74 02                	je     c010a164 <memcpy+0x38>
c010a162:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010a164:	89 f0                	mov    %esi,%eax
c010a166:	89 fa                	mov    %edi,%edx
c010a168:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010a16b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010a16e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010a171:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c010a174:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010a175:	83 c4 20             	add    $0x20,%esp
c010a178:	5e                   	pop    %esi
c010a179:	5f                   	pop    %edi
c010a17a:	5d                   	pop    %ebp
c010a17b:	c3                   	ret    

c010a17c <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010a17c:	55                   	push   %ebp
c010a17d:	89 e5                	mov    %esp,%ebp
c010a17f:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010a182:	8b 45 08             	mov    0x8(%ebp),%eax
c010a185:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010a188:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a18b:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010a18e:	eb 30                	jmp    c010a1c0 <memcmp+0x44>
        if (*s1 != *s2) {
c010a190:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010a193:	0f b6 10             	movzbl (%eax),%edx
c010a196:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010a199:	0f b6 00             	movzbl (%eax),%eax
c010a19c:	38 c2                	cmp    %al,%dl
c010a19e:	74 18                	je     c010a1b8 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010a1a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010a1a3:	0f b6 00             	movzbl (%eax),%eax
c010a1a6:	0f b6 d0             	movzbl %al,%edx
c010a1a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010a1ac:	0f b6 00             	movzbl (%eax),%eax
c010a1af:	0f b6 c0             	movzbl %al,%eax
c010a1b2:	29 c2                	sub    %eax,%edx
c010a1b4:	89 d0                	mov    %edx,%eax
c010a1b6:	eb 1a                	jmp    c010a1d2 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c010a1b8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010a1bc:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c010a1c0:	8b 45 10             	mov    0x10(%ebp),%eax
c010a1c3:	8d 50 ff             	lea    -0x1(%eax),%edx
c010a1c6:	89 55 10             	mov    %edx,0x10(%ebp)
c010a1c9:	85 c0                	test   %eax,%eax
c010a1cb:	75 c3                	jne    c010a190 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c010a1cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a1d2:	c9                   	leave  
c010a1d3:	c3                   	ret    

c010a1d4 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010a1d4:	55                   	push   %ebp
c010a1d5:	89 e5                	mov    %esp,%ebp
c010a1d7:	83 ec 38             	sub    $0x38,%esp
c010a1da:	8b 45 10             	mov    0x10(%ebp),%eax
c010a1dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010a1e0:	8b 45 14             	mov    0x14(%ebp),%eax
c010a1e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010a1e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a1e9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a1ec:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a1ef:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010a1f2:	8b 45 18             	mov    0x18(%ebp),%eax
c010a1f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010a1f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a1fb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a1fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a201:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010a204:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a207:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a20a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a20e:	74 1c                	je     c010a22c <printnum+0x58>
c010a210:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a213:	ba 00 00 00 00       	mov    $0x0,%edx
c010a218:	f7 75 e4             	divl   -0x1c(%ebp)
c010a21b:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010a21e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a221:	ba 00 00 00 00       	mov    $0x0,%edx
c010a226:	f7 75 e4             	divl   -0x1c(%ebp)
c010a229:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a22c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a22f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a232:	f7 75 e4             	divl   -0x1c(%ebp)
c010a235:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a238:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010a23b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a23e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010a241:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a244:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010a247:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a24a:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010a24d:	8b 45 18             	mov    0x18(%ebp),%eax
c010a250:	ba 00 00 00 00       	mov    $0x0,%edx
c010a255:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010a258:	77 41                	ja     c010a29b <printnum+0xc7>
c010a25a:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010a25d:	72 05                	jb     c010a264 <printnum+0x90>
c010a25f:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010a262:	77 37                	ja     c010a29b <printnum+0xc7>
        printnum(putch, putdat, result, base, width - 1, padc);
c010a264:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010a267:	83 e8 01             	sub    $0x1,%eax
c010a26a:	83 ec 04             	sub    $0x4,%esp
c010a26d:	ff 75 20             	pushl  0x20(%ebp)
c010a270:	50                   	push   %eax
c010a271:	ff 75 18             	pushl  0x18(%ebp)
c010a274:	ff 75 ec             	pushl  -0x14(%ebp)
c010a277:	ff 75 e8             	pushl  -0x18(%ebp)
c010a27a:	ff 75 0c             	pushl  0xc(%ebp)
c010a27d:	ff 75 08             	pushl  0x8(%ebp)
c010a280:	e8 4f ff ff ff       	call   c010a1d4 <printnum>
c010a285:	83 c4 20             	add    $0x20,%esp
c010a288:	eb 1b                	jmp    c010a2a5 <printnum+0xd1>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010a28a:	83 ec 08             	sub    $0x8,%esp
c010a28d:	ff 75 0c             	pushl  0xc(%ebp)
c010a290:	ff 75 20             	pushl  0x20(%ebp)
c010a293:	8b 45 08             	mov    0x8(%ebp),%eax
c010a296:	ff d0                	call   *%eax
c010a298:	83 c4 10             	add    $0x10,%esp
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c010a29b:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010a29f:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010a2a3:	7f e5                	jg     c010a28a <printnum+0xb6>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010a2a5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a2a8:	05 b0 cc 10 c0       	add    $0xc010ccb0,%eax
c010a2ad:	0f b6 00             	movzbl (%eax),%eax
c010a2b0:	0f be c0             	movsbl %al,%eax
c010a2b3:	83 ec 08             	sub    $0x8,%esp
c010a2b6:	ff 75 0c             	pushl  0xc(%ebp)
c010a2b9:	50                   	push   %eax
c010a2ba:	8b 45 08             	mov    0x8(%ebp),%eax
c010a2bd:	ff d0                	call   *%eax
c010a2bf:	83 c4 10             	add    $0x10,%esp
}
c010a2c2:	90                   	nop
c010a2c3:	c9                   	leave  
c010a2c4:	c3                   	ret    

c010a2c5 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010a2c5:	55                   	push   %ebp
c010a2c6:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010a2c8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010a2cc:	7e 14                	jle    c010a2e2 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010a2ce:	8b 45 08             	mov    0x8(%ebp),%eax
c010a2d1:	8b 00                	mov    (%eax),%eax
c010a2d3:	8d 48 08             	lea    0x8(%eax),%ecx
c010a2d6:	8b 55 08             	mov    0x8(%ebp),%edx
c010a2d9:	89 0a                	mov    %ecx,(%edx)
c010a2db:	8b 50 04             	mov    0x4(%eax),%edx
c010a2de:	8b 00                	mov    (%eax),%eax
c010a2e0:	eb 30                	jmp    c010a312 <getuint+0x4d>
    }
    else if (lflag) {
c010a2e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a2e6:	74 16                	je     c010a2fe <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010a2e8:	8b 45 08             	mov    0x8(%ebp),%eax
c010a2eb:	8b 00                	mov    (%eax),%eax
c010a2ed:	8d 48 04             	lea    0x4(%eax),%ecx
c010a2f0:	8b 55 08             	mov    0x8(%ebp),%edx
c010a2f3:	89 0a                	mov    %ecx,(%edx)
c010a2f5:	8b 00                	mov    (%eax),%eax
c010a2f7:	ba 00 00 00 00       	mov    $0x0,%edx
c010a2fc:	eb 14                	jmp    c010a312 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010a2fe:	8b 45 08             	mov    0x8(%ebp),%eax
c010a301:	8b 00                	mov    (%eax),%eax
c010a303:	8d 48 04             	lea    0x4(%eax),%ecx
c010a306:	8b 55 08             	mov    0x8(%ebp),%edx
c010a309:	89 0a                	mov    %ecx,(%edx)
c010a30b:	8b 00                	mov    (%eax),%eax
c010a30d:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010a312:	5d                   	pop    %ebp
c010a313:	c3                   	ret    

c010a314 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010a314:	55                   	push   %ebp
c010a315:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010a317:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010a31b:	7e 14                	jle    c010a331 <getint+0x1d>
        return va_arg(*ap, long long);
c010a31d:	8b 45 08             	mov    0x8(%ebp),%eax
c010a320:	8b 00                	mov    (%eax),%eax
c010a322:	8d 48 08             	lea    0x8(%eax),%ecx
c010a325:	8b 55 08             	mov    0x8(%ebp),%edx
c010a328:	89 0a                	mov    %ecx,(%edx)
c010a32a:	8b 50 04             	mov    0x4(%eax),%edx
c010a32d:	8b 00                	mov    (%eax),%eax
c010a32f:	eb 28                	jmp    c010a359 <getint+0x45>
    }
    else if (lflag) {
c010a331:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a335:	74 12                	je     c010a349 <getint+0x35>
        return va_arg(*ap, long);
c010a337:	8b 45 08             	mov    0x8(%ebp),%eax
c010a33a:	8b 00                	mov    (%eax),%eax
c010a33c:	8d 48 04             	lea    0x4(%eax),%ecx
c010a33f:	8b 55 08             	mov    0x8(%ebp),%edx
c010a342:	89 0a                	mov    %ecx,(%edx)
c010a344:	8b 00                	mov    (%eax),%eax
c010a346:	99                   	cltd   
c010a347:	eb 10                	jmp    c010a359 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010a349:	8b 45 08             	mov    0x8(%ebp),%eax
c010a34c:	8b 00                	mov    (%eax),%eax
c010a34e:	8d 48 04             	lea    0x4(%eax),%ecx
c010a351:	8b 55 08             	mov    0x8(%ebp),%edx
c010a354:	89 0a                	mov    %ecx,(%edx)
c010a356:	8b 00                	mov    (%eax),%eax
c010a358:	99                   	cltd   
    }
}
c010a359:	5d                   	pop    %ebp
c010a35a:	c3                   	ret    

c010a35b <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010a35b:	55                   	push   %ebp
c010a35c:	89 e5                	mov    %esp,%ebp
c010a35e:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
c010a361:	8d 45 14             	lea    0x14(%ebp),%eax
c010a364:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010a367:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a36a:	50                   	push   %eax
c010a36b:	ff 75 10             	pushl  0x10(%ebp)
c010a36e:	ff 75 0c             	pushl  0xc(%ebp)
c010a371:	ff 75 08             	pushl  0x8(%ebp)
c010a374:	e8 06 00 00 00       	call   c010a37f <vprintfmt>
c010a379:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c010a37c:	90                   	nop
c010a37d:	c9                   	leave  
c010a37e:	c3                   	ret    

c010a37f <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010a37f:	55                   	push   %ebp
c010a380:	89 e5                	mov    %esp,%ebp
c010a382:	56                   	push   %esi
c010a383:	53                   	push   %ebx
c010a384:	83 ec 20             	sub    $0x20,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010a387:	eb 17                	jmp    c010a3a0 <vprintfmt+0x21>
            if (ch == '\0') {
c010a389:	85 db                	test   %ebx,%ebx
c010a38b:	0f 84 8e 03 00 00    	je     c010a71f <vprintfmt+0x3a0>
                return;
            }
            putch(ch, putdat);
c010a391:	83 ec 08             	sub    $0x8,%esp
c010a394:	ff 75 0c             	pushl  0xc(%ebp)
c010a397:	53                   	push   %ebx
c010a398:	8b 45 08             	mov    0x8(%ebp),%eax
c010a39b:	ff d0                	call   *%eax
c010a39d:	83 c4 10             	add    $0x10,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010a3a0:	8b 45 10             	mov    0x10(%ebp),%eax
c010a3a3:	8d 50 01             	lea    0x1(%eax),%edx
c010a3a6:	89 55 10             	mov    %edx,0x10(%ebp)
c010a3a9:	0f b6 00             	movzbl (%eax),%eax
c010a3ac:	0f b6 d8             	movzbl %al,%ebx
c010a3af:	83 fb 25             	cmp    $0x25,%ebx
c010a3b2:	75 d5                	jne    c010a389 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c010a3b4:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010a3b8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010a3bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a3c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010a3c5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010a3cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a3cf:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010a3d2:	8b 45 10             	mov    0x10(%ebp),%eax
c010a3d5:	8d 50 01             	lea    0x1(%eax),%edx
c010a3d8:	89 55 10             	mov    %edx,0x10(%ebp)
c010a3db:	0f b6 00             	movzbl (%eax),%eax
c010a3de:	0f b6 d8             	movzbl %al,%ebx
c010a3e1:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010a3e4:	83 f8 55             	cmp    $0x55,%eax
c010a3e7:	0f 87 05 03 00 00    	ja     c010a6f2 <vprintfmt+0x373>
c010a3ed:	8b 04 85 d4 cc 10 c0 	mov    -0x3fef332c(,%eax,4),%eax
c010a3f4:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010a3f6:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010a3fa:	eb d6                	jmp    c010a3d2 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010a3fc:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010a400:	eb d0                	jmp    c010a3d2 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010a402:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010a409:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a40c:	89 d0                	mov    %edx,%eax
c010a40e:	c1 e0 02             	shl    $0x2,%eax
c010a411:	01 d0                	add    %edx,%eax
c010a413:	01 c0                	add    %eax,%eax
c010a415:	01 d8                	add    %ebx,%eax
c010a417:	83 e8 30             	sub    $0x30,%eax
c010a41a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010a41d:	8b 45 10             	mov    0x10(%ebp),%eax
c010a420:	0f b6 00             	movzbl (%eax),%eax
c010a423:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010a426:	83 fb 2f             	cmp    $0x2f,%ebx
c010a429:	7e 39                	jle    c010a464 <vprintfmt+0xe5>
c010a42b:	83 fb 39             	cmp    $0x39,%ebx
c010a42e:	7f 34                	jg     c010a464 <vprintfmt+0xe5>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010a430:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c010a434:	eb d3                	jmp    c010a409 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c010a436:	8b 45 14             	mov    0x14(%ebp),%eax
c010a439:	8d 50 04             	lea    0x4(%eax),%edx
c010a43c:	89 55 14             	mov    %edx,0x14(%ebp)
c010a43f:	8b 00                	mov    (%eax),%eax
c010a441:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010a444:	eb 1f                	jmp    c010a465 <vprintfmt+0xe6>

        case '.':
            if (width < 0)
c010a446:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a44a:	79 86                	jns    c010a3d2 <vprintfmt+0x53>
                width = 0;
c010a44c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010a453:	e9 7a ff ff ff       	jmp    c010a3d2 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c010a458:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010a45f:	e9 6e ff ff ff       	jmp    c010a3d2 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
c010a464:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
c010a465:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a469:	0f 89 63 ff ff ff    	jns    c010a3d2 <vprintfmt+0x53>
                width = precision, precision = -1;
c010a46f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a472:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a475:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010a47c:	e9 51 ff ff ff       	jmp    c010a3d2 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010a481:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010a485:	e9 48 ff ff ff       	jmp    c010a3d2 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010a48a:	8b 45 14             	mov    0x14(%ebp),%eax
c010a48d:	8d 50 04             	lea    0x4(%eax),%edx
c010a490:	89 55 14             	mov    %edx,0x14(%ebp)
c010a493:	8b 00                	mov    (%eax),%eax
c010a495:	83 ec 08             	sub    $0x8,%esp
c010a498:	ff 75 0c             	pushl  0xc(%ebp)
c010a49b:	50                   	push   %eax
c010a49c:	8b 45 08             	mov    0x8(%ebp),%eax
c010a49f:	ff d0                	call   *%eax
c010a4a1:	83 c4 10             	add    $0x10,%esp
            break;
c010a4a4:	e9 71 02 00 00       	jmp    c010a71a <vprintfmt+0x39b>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010a4a9:	8b 45 14             	mov    0x14(%ebp),%eax
c010a4ac:	8d 50 04             	lea    0x4(%eax),%edx
c010a4af:	89 55 14             	mov    %edx,0x14(%ebp)
c010a4b2:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010a4b4:	85 db                	test   %ebx,%ebx
c010a4b6:	79 02                	jns    c010a4ba <vprintfmt+0x13b>
                err = -err;
c010a4b8:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010a4ba:	83 fb 06             	cmp    $0x6,%ebx
c010a4bd:	7f 0b                	jg     c010a4ca <vprintfmt+0x14b>
c010a4bf:	8b 34 9d 94 cc 10 c0 	mov    -0x3fef336c(,%ebx,4),%esi
c010a4c6:	85 f6                	test   %esi,%esi
c010a4c8:	75 19                	jne    c010a4e3 <vprintfmt+0x164>
                printfmt(putch, putdat, "error %d", err);
c010a4ca:	53                   	push   %ebx
c010a4cb:	68 c1 cc 10 c0       	push   $0xc010ccc1
c010a4d0:	ff 75 0c             	pushl  0xc(%ebp)
c010a4d3:	ff 75 08             	pushl  0x8(%ebp)
c010a4d6:	e8 80 fe ff ff       	call   c010a35b <printfmt>
c010a4db:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010a4de:	e9 37 02 00 00       	jmp    c010a71a <vprintfmt+0x39b>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c010a4e3:	56                   	push   %esi
c010a4e4:	68 ca cc 10 c0       	push   $0xc010ccca
c010a4e9:	ff 75 0c             	pushl  0xc(%ebp)
c010a4ec:	ff 75 08             	pushl  0x8(%ebp)
c010a4ef:	e8 67 fe ff ff       	call   c010a35b <printfmt>
c010a4f4:	83 c4 10             	add    $0x10,%esp
            }
            break;
c010a4f7:	e9 1e 02 00 00       	jmp    c010a71a <vprintfmt+0x39b>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010a4fc:	8b 45 14             	mov    0x14(%ebp),%eax
c010a4ff:	8d 50 04             	lea    0x4(%eax),%edx
c010a502:	89 55 14             	mov    %edx,0x14(%ebp)
c010a505:	8b 30                	mov    (%eax),%esi
c010a507:	85 f6                	test   %esi,%esi
c010a509:	75 05                	jne    c010a510 <vprintfmt+0x191>
                p = "(null)";
c010a50b:	be cd cc 10 c0       	mov    $0xc010cccd,%esi
            }
            if (width > 0 && padc != '-') {
c010a510:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a514:	7e 76                	jle    c010a58c <vprintfmt+0x20d>
c010a516:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010a51a:	74 70                	je     c010a58c <vprintfmt+0x20d>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010a51c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a51f:	83 ec 08             	sub    $0x8,%esp
c010a522:	50                   	push   %eax
c010a523:	56                   	push   %esi
c010a524:	e8 17 f8 ff ff       	call   c0109d40 <strnlen>
c010a529:	83 c4 10             	add    $0x10,%esp
c010a52c:	89 c2                	mov    %eax,%edx
c010a52e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a531:	29 d0                	sub    %edx,%eax
c010a533:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a536:	eb 17                	jmp    c010a54f <vprintfmt+0x1d0>
                    putch(padc, putdat);
c010a538:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010a53c:	83 ec 08             	sub    $0x8,%esp
c010a53f:	ff 75 0c             	pushl  0xc(%ebp)
c010a542:	50                   	push   %eax
c010a543:	8b 45 08             	mov    0x8(%ebp),%eax
c010a546:	ff d0                	call   *%eax
c010a548:	83 c4 10             	add    $0x10,%esp
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c010a54b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010a54f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a553:	7f e3                	jg     c010a538 <vprintfmt+0x1b9>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010a555:	eb 35                	jmp    c010a58c <vprintfmt+0x20d>
                if (altflag && (ch < ' ' || ch > '~')) {
c010a557:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010a55b:	74 1c                	je     c010a579 <vprintfmt+0x1fa>
c010a55d:	83 fb 1f             	cmp    $0x1f,%ebx
c010a560:	7e 05                	jle    c010a567 <vprintfmt+0x1e8>
c010a562:	83 fb 7e             	cmp    $0x7e,%ebx
c010a565:	7e 12                	jle    c010a579 <vprintfmt+0x1fa>
                    putch('?', putdat);
c010a567:	83 ec 08             	sub    $0x8,%esp
c010a56a:	ff 75 0c             	pushl  0xc(%ebp)
c010a56d:	6a 3f                	push   $0x3f
c010a56f:	8b 45 08             	mov    0x8(%ebp),%eax
c010a572:	ff d0                	call   *%eax
c010a574:	83 c4 10             	add    $0x10,%esp
c010a577:	eb 0f                	jmp    c010a588 <vprintfmt+0x209>
                }
                else {
                    putch(ch, putdat);
c010a579:	83 ec 08             	sub    $0x8,%esp
c010a57c:	ff 75 0c             	pushl  0xc(%ebp)
c010a57f:	53                   	push   %ebx
c010a580:	8b 45 08             	mov    0x8(%ebp),%eax
c010a583:	ff d0                	call   *%eax
c010a585:	83 c4 10             	add    $0x10,%esp
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010a588:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010a58c:	89 f0                	mov    %esi,%eax
c010a58e:	8d 70 01             	lea    0x1(%eax),%esi
c010a591:	0f b6 00             	movzbl (%eax),%eax
c010a594:	0f be d8             	movsbl %al,%ebx
c010a597:	85 db                	test   %ebx,%ebx
c010a599:	74 26                	je     c010a5c1 <vprintfmt+0x242>
c010a59b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010a59f:	78 b6                	js     c010a557 <vprintfmt+0x1d8>
c010a5a1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c010a5a5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010a5a9:	79 ac                	jns    c010a557 <vprintfmt+0x1d8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010a5ab:	eb 14                	jmp    c010a5c1 <vprintfmt+0x242>
                putch(' ', putdat);
c010a5ad:	83 ec 08             	sub    $0x8,%esp
c010a5b0:	ff 75 0c             	pushl  0xc(%ebp)
c010a5b3:	6a 20                	push   $0x20
c010a5b5:	8b 45 08             	mov    0x8(%ebp),%eax
c010a5b8:	ff d0                	call   *%eax
c010a5ba:	83 c4 10             	add    $0x10,%esp
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010a5bd:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010a5c1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a5c5:	7f e6                	jg     c010a5ad <vprintfmt+0x22e>
                putch(' ', putdat);
            }
            break;
c010a5c7:	e9 4e 01 00 00       	jmp    c010a71a <vprintfmt+0x39b>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010a5cc:	83 ec 08             	sub    $0x8,%esp
c010a5cf:	ff 75 e0             	pushl  -0x20(%ebp)
c010a5d2:	8d 45 14             	lea    0x14(%ebp),%eax
c010a5d5:	50                   	push   %eax
c010a5d6:	e8 39 fd ff ff       	call   c010a314 <getint>
c010a5db:	83 c4 10             	add    $0x10,%esp
c010a5de:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a5e1:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010a5e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a5e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a5ea:	85 d2                	test   %edx,%edx
c010a5ec:	79 23                	jns    c010a611 <vprintfmt+0x292>
                putch('-', putdat);
c010a5ee:	83 ec 08             	sub    $0x8,%esp
c010a5f1:	ff 75 0c             	pushl  0xc(%ebp)
c010a5f4:	6a 2d                	push   $0x2d
c010a5f6:	8b 45 08             	mov    0x8(%ebp),%eax
c010a5f9:	ff d0                	call   *%eax
c010a5fb:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
c010a5fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a601:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a604:	f7 d8                	neg    %eax
c010a606:	83 d2 00             	adc    $0x0,%edx
c010a609:	f7 da                	neg    %edx
c010a60b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a60e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010a611:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010a618:	e9 9f 00 00 00       	jmp    c010a6bc <vprintfmt+0x33d>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010a61d:	83 ec 08             	sub    $0x8,%esp
c010a620:	ff 75 e0             	pushl  -0x20(%ebp)
c010a623:	8d 45 14             	lea    0x14(%ebp),%eax
c010a626:	50                   	push   %eax
c010a627:	e8 99 fc ff ff       	call   c010a2c5 <getuint>
c010a62c:	83 c4 10             	add    $0x10,%esp
c010a62f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a632:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010a635:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010a63c:	eb 7e                	jmp    c010a6bc <vprintfmt+0x33d>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010a63e:	83 ec 08             	sub    $0x8,%esp
c010a641:	ff 75 e0             	pushl  -0x20(%ebp)
c010a644:	8d 45 14             	lea    0x14(%ebp),%eax
c010a647:	50                   	push   %eax
c010a648:	e8 78 fc ff ff       	call   c010a2c5 <getuint>
c010a64d:	83 c4 10             	add    $0x10,%esp
c010a650:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a653:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010a656:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010a65d:	eb 5d                	jmp    c010a6bc <vprintfmt+0x33d>

        // pointer
        case 'p':
            putch('0', putdat);
c010a65f:	83 ec 08             	sub    $0x8,%esp
c010a662:	ff 75 0c             	pushl  0xc(%ebp)
c010a665:	6a 30                	push   $0x30
c010a667:	8b 45 08             	mov    0x8(%ebp),%eax
c010a66a:	ff d0                	call   *%eax
c010a66c:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
c010a66f:	83 ec 08             	sub    $0x8,%esp
c010a672:	ff 75 0c             	pushl  0xc(%ebp)
c010a675:	6a 78                	push   $0x78
c010a677:	8b 45 08             	mov    0x8(%ebp),%eax
c010a67a:	ff d0                	call   *%eax
c010a67c:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010a67f:	8b 45 14             	mov    0x14(%ebp),%eax
c010a682:	8d 50 04             	lea    0x4(%eax),%edx
c010a685:	89 55 14             	mov    %edx,0x14(%ebp)
c010a688:	8b 00                	mov    (%eax),%eax
c010a68a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a68d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010a694:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010a69b:	eb 1f                	jmp    c010a6bc <vprintfmt+0x33d>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010a69d:	83 ec 08             	sub    $0x8,%esp
c010a6a0:	ff 75 e0             	pushl  -0x20(%ebp)
c010a6a3:	8d 45 14             	lea    0x14(%ebp),%eax
c010a6a6:	50                   	push   %eax
c010a6a7:	e8 19 fc ff ff       	call   c010a2c5 <getuint>
c010a6ac:	83 c4 10             	add    $0x10,%esp
c010a6af:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a6b2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010a6b5:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010a6bc:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010a6c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a6c3:	83 ec 04             	sub    $0x4,%esp
c010a6c6:	52                   	push   %edx
c010a6c7:	ff 75 e8             	pushl  -0x18(%ebp)
c010a6ca:	50                   	push   %eax
c010a6cb:	ff 75 f4             	pushl  -0xc(%ebp)
c010a6ce:	ff 75 f0             	pushl  -0x10(%ebp)
c010a6d1:	ff 75 0c             	pushl  0xc(%ebp)
c010a6d4:	ff 75 08             	pushl  0x8(%ebp)
c010a6d7:	e8 f8 fa ff ff       	call   c010a1d4 <printnum>
c010a6dc:	83 c4 20             	add    $0x20,%esp
            break;
c010a6df:	eb 39                	jmp    c010a71a <vprintfmt+0x39b>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010a6e1:	83 ec 08             	sub    $0x8,%esp
c010a6e4:	ff 75 0c             	pushl  0xc(%ebp)
c010a6e7:	53                   	push   %ebx
c010a6e8:	8b 45 08             	mov    0x8(%ebp),%eax
c010a6eb:	ff d0                	call   *%eax
c010a6ed:	83 c4 10             	add    $0x10,%esp
            break;
c010a6f0:	eb 28                	jmp    c010a71a <vprintfmt+0x39b>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010a6f2:	83 ec 08             	sub    $0x8,%esp
c010a6f5:	ff 75 0c             	pushl  0xc(%ebp)
c010a6f8:	6a 25                	push   $0x25
c010a6fa:	8b 45 08             	mov    0x8(%ebp),%eax
c010a6fd:	ff d0                	call   *%eax
c010a6ff:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
c010a702:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010a706:	eb 04                	jmp    c010a70c <vprintfmt+0x38d>
c010a708:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010a70c:	8b 45 10             	mov    0x10(%ebp),%eax
c010a70f:	83 e8 01             	sub    $0x1,%eax
c010a712:	0f b6 00             	movzbl (%eax),%eax
c010a715:	3c 25                	cmp    $0x25,%al
c010a717:	75 ef                	jne    c010a708 <vprintfmt+0x389>
                /* do nothing */;
            break;
c010a719:	90                   	nop
        }
    }
c010a71a:	e9 68 fc ff ff       	jmp    c010a387 <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
c010a71f:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c010a720:	8d 65 f8             	lea    -0x8(%ebp),%esp
c010a723:	5b                   	pop    %ebx
c010a724:	5e                   	pop    %esi
c010a725:	5d                   	pop    %ebp
c010a726:	c3                   	ret    

c010a727 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010a727:	55                   	push   %ebp
c010a728:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010a72a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a72d:	8b 40 08             	mov    0x8(%eax),%eax
c010a730:	8d 50 01             	lea    0x1(%eax),%edx
c010a733:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a736:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010a739:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a73c:	8b 10                	mov    (%eax),%edx
c010a73e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a741:	8b 40 04             	mov    0x4(%eax),%eax
c010a744:	39 c2                	cmp    %eax,%edx
c010a746:	73 12                	jae    c010a75a <sprintputch+0x33>
        *b->buf ++ = ch;
c010a748:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a74b:	8b 00                	mov    (%eax),%eax
c010a74d:	8d 48 01             	lea    0x1(%eax),%ecx
c010a750:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a753:	89 0a                	mov    %ecx,(%edx)
c010a755:	8b 55 08             	mov    0x8(%ebp),%edx
c010a758:	88 10                	mov    %dl,(%eax)
    }
}
c010a75a:	90                   	nop
c010a75b:	5d                   	pop    %ebp
c010a75c:	c3                   	ret    

c010a75d <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010a75d:	55                   	push   %ebp
c010a75e:	89 e5                	mov    %esp,%ebp
c010a760:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010a763:	8d 45 14             	lea    0x14(%ebp),%eax
c010a766:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010a769:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a76c:	50                   	push   %eax
c010a76d:	ff 75 10             	pushl  0x10(%ebp)
c010a770:	ff 75 0c             	pushl  0xc(%ebp)
c010a773:	ff 75 08             	pushl  0x8(%ebp)
c010a776:	e8 0b 00 00 00       	call   c010a786 <vsnprintf>
c010a77b:	83 c4 10             	add    $0x10,%esp
c010a77e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010a781:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010a784:	c9                   	leave  
c010a785:	c3                   	ret    

c010a786 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010a786:	55                   	push   %ebp
c010a787:	89 e5                	mov    %esp,%ebp
c010a789:	83 ec 18             	sub    $0x18,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010a78c:	8b 45 08             	mov    0x8(%ebp),%eax
c010a78f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010a792:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a795:	8d 50 ff             	lea    -0x1(%eax),%edx
c010a798:	8b 45 08             	mov    0x8(%ebp),%eax
c010a79b:	01 d0                	add    %edx,%eax
c010a79d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a7a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010a7a7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010a7ab:	74 0a                	je     c010a7b7 <vsnprintf+0x31>
c010a7ad:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a7b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a7b3:	39 c2                	cmp    %eax,%edx
c010a7b5:	76 07                	jbe    c010a7be <vsnprintf+0x38>
        return -E_INVAL;
c010a7b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010a7bc:	eb 20                	jmp    c010a7de <vsnprintf+0x58>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010a7be:	ff 75 14             	pushl  0x14(%ebp)
c010a7c1:	ff 75 10             	pushl  0x10(%ebp)
c010a7c4:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010a7c7:	50                   	push   %eax
c010a7c8:	68 27 a7 10 c0       	push   $0xc010a727
c010a7cd:	e8 ad fb ff ff       	call   c010a37f <vprintfmt>
c010a7d2:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
c010a7d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a7d8:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010a7db:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010a7de:	c9                   	leave  
c010a7df:	c3                   	ret    

c010a7e0 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010a7e0:	55                   	push   %ebp
c010a7e1:	89 e5                	mov    %esp,%ebp
c010a7e3:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010a7e6:	8b 45 08             	mov    0x8(%ebp),%eax
c010a7e9:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010a7ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010a7f2:	b8 20 00 00 00       	mov    $0x20,%eax
c010a7f7:	2b 45 0c             	sub    0xc(%ebp),%eax
c010a7fa:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010a7fd:	89 c1                	mov    %eax,%ecx
c010a7ff:	d3 ea                	shr    %cl,%edx
c010a801:	89 d0                	mov    %edx,%eax
}
c010a803:	c9                   	leave  
c010a804:	c3                   	ret    

c010a805 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010a805:	55                   	push   %ebp
c010a806:	89 e5                	mov    %esp,%ebp
c010a808:	57                   	push   %edi
c010a809:	56                   	push   %esi
c010a80a:	53                   	push   %ebx
c010a80b:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010a80e:	a1 80 7a 12 c0       	mov    0xc0127a80,%eax
c010a813:	8b 15 84 7a 12 c0    	mov    0xc0127a84,%edx
c010a819:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010a81f:	6b f0 05             	imul   $0x5,%eax,%esi
c010a822:	01 fe                	add    %edi,%esi
c010a824:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c010a829:	f7 e7                	mul    %edi
c010a82b:	01 d6                	add    %edx,%esi
c010a82d:	89 f2                	mov    %esi,%edx
c010a82f:	83 c0 0b             	add    $0xb,%eax
c010a832:	83 d2 00             	adc    $0x0,%edx
c010a835:	89 c7                	mov    %eax,%edi
c010a837:	83 e7 ff             	and    $0xffffffff,%edi
c010a83a:	89 f9                	mov    %edi,%ecx
c010a83c:	0f b7 da             	movzwl %dx,%ebx
c010a83f:	89 0d 80 7a 12 c0    	mov    %ecx,0xc0127a80
c010a845:	89 1d 84 7a 12 c0    	mov    %ebx,0xc0127a84
    unsigned long long result = (next >> 12);
c010a84b:	a1 80 7a 12 c0       	mov    0xc0127a80,%eax
c010a850:	8b 15 84 7a 12 c0    	mov    0xc0127a84,%edx
c010a856:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010a85a:	c1 ea 0c             	shr    $0xc,%edx
c010a85d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a860:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010a863:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010a86a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a86d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a870:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010a873:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010a876:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a879:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010a87c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a880:	74 1c                	je     c010a89e <rand+0x99>
c010a882:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a885:	ba 00 00 00 00       	mov    $0x0,%edx
c010a88a:	f7 75 dc             	divl   -0x24(%ebp)
c010a88d:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010a890:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a893:	ba 00 00 00 00       	mov    $0x0,%edx
c010a898:	f7 75 dc             	divl   -0x24(%ebp)
c010a89b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a89e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a8a1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a8a4:	f7 75 dc             	divl   -0x24(%ebp)
c010a8a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010a8aa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010a8ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a8b0:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010a8b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a8b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010a8b9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010a8bc:	83 c4 24             	add    $0x24,%esp
c010a8bf:	5b                   	pop    %ebx
c010a8c0:	5e                   	pop    %esi
c010a8c1:	5f                   	pop    %edi
c010a8c2:	5d                   	pop    %ebp
c010a8c3:	c3                   	ret    

c010a8c4 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010a8c4:	55                   	push   %ebp
c010a8c5:	89 e5                	mov    %esp,%ebp
    next = seed;
c010a8c7:	8b 45 08             	mov    0x8(%ebp),%eax
c010a8ca:	ba 00 00 00 00       	mov    $0x0,%edx
c010a8cf:	a3 80 7a 12 c0       	mov    %eax,0xc0127a80
c010a8d4:	89 15 84 7a 12 c0    	mov    %edx,0xc0127a84
}
c010a8da:	90                   	nop
c010a8db:	5d                   	pop    %ebp
c010a8dc:	c3                   	ret    
