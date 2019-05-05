
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 60 12 00       	mov    $0x126000,%eax
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
c0100020:	a3 00 60 12 c0       	mov    %eax,0xc0126000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 50 12 c0       	mov    $0xc0125000,%esp
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
c010003c:	ba 4c b1 12 c0       	mov    $0xc012b14c,%edx
c0100041:	b8 00 80 12 c0       	mov    $0xc0128000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 80 12 c0 	movl   $0xc0128000,(%esp)
c010005d:	e8 51 94 00 00       	call   c01094b3 <memset>

    cons_init();                // init the console
c0100062:	e8 f4 1d 00 00       	call   c0101e5b <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 c0 9d 10 c0 	movl   $0xc0109dc0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 dc 9d 10 c0 	movl   $0xc0109ddc,(%esp)
c010007c:	e8 28 02 00 00       	call   c01002a9 <cprintf>

    print_kerninfo();
c0100081:	e8 c9 08 00 00       	call   c010094f <print_kerninfo>

    grade_backtrace();
c0100086:	e8 a0 00 00 00       	call   c010012b <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 7e 71 00 00       	call   c010720e <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 2a 1f 00 00       	call   c0101fbf <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 83 20 00 00       	call   c010211d <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 c2 35 00 00       	call   c0103661 <vmm_init>
    proc_init();                // init process table
c010009f:	e8 c9 8d 00 00       	call   c0108e6d <proc_init>
    
    ide_init();                 // init ide devices
c01000a4:	e8 56 0d 00 00       	call   c0100dff <ide_init>
    swap_init();                // init swap
c01000a9:	e8 56 3f 00 00       	call   c0104004 <swap_init>

    clock_init();               // init clock interrupt
c01000ae:	e8 5b 15 00 00       	call   c010160e <clock_init>
    intr_enable();              // enable irq interrupt
c01000b3:	e8 3a 20 00 00       	call   c01020f2 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000b8:	e8 6d 8f 00 00       	call   c010902a <cpu_idle>

c01000bd <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000bd:	55                   	push   %ebp
c01000be:	89 e5                	mov    %esp,%ebp
c01000c0:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000ca:	00 
c01000cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000d2:	00 
c01000d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000da:	e8 b5 0c 00 00       	call   c0100d94 <mon_backtrace>
}
c01000df:	90                   	nop
c01000e0:	c9                   	leave  
c01000e1:	c3                   	ret    

c01000e2 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000e2:	55                   	push   %ebp
c01000e3:	89 e5                	mov    %esp,%ebp
c01000e5:	53                   	push   %ebx
c01000e6:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e9:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000ec:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000ef:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01000f5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000f9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0100101:	89 04 24             	mov    %eax,(%esp)
c0100104:	e8 b4 ff ff ff       	call   c01000bd <grade_backtrace2>
}
c0100109:	90                   	nop
c010010a:	83 c4 14             	add    $0x14,%esp
c010010d:	5b                   	pop    %ebx
c010010e:	5d                   	pop    %ebp
c010010f:	c3                   	ret    

c0100110 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100110:	55                   	push   %ebp
c0100111:	89 e5                	mov    %esp,%ebp
c0100113:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100116:	8b 45 10             	mov    0x10(%ebp),%eax
c0100119:	89 44 24 04          	mov    %eax,0x4(%esp)
c010011d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100120:	89 04 24             	mov    %eax,(%esp)
c0100123:	e8 ba ff ff ff       	call   c01000e2 <grade_backtrace1>
}
c0100128:	90                   	nop
c0100129:	c9                   	leave  
c010012a:	c3                   	ret    

c010012b <grade_backtrace>:

void
grade_backtrace(void) {
c010012b:	55                   	push   %ebp
c010012c:	89 e5                	mov    %esp,%ebp
c010012e:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100131:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100136:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c010013d:	ff 
c010013e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100142:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100149:	e8 c2 ff ff ff       	call   c0100110 <grade_backtrace0>
}
c010014e:	90                   	nop
c010014f:	c9                   	leave  
c0100150:	c3                   	ret    

c0100151 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100151:	55                   	push   %ebp
c0100152:	89 e5                	mov    %esp,%ebp
c0100154:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100157:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010015a:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010015d:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100160:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100163:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100167:	83 e0 03             	and    $0x3,%eax
c010016a:	89 c2                	mov    %eax,%edx
c010016c:	a1 00 80 12 c0       	mov    0xc0128000,%eax
c0100171:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100175:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100179:	c7 04 24 e1 9d 10 c0 	movl   $0xc0109de1,(%esp)
c0100180:	e8 24 01 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100185:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100189:	89 c2                	mov    %eax,%edx
c010018b:	a1 00 80 12 c0       	mov    0xc0128000,%eax
c0100190:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100194:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100198:	c7 04 24 ef 9d 10 c0 	movl   $0xc0109def,(%esp)
c010019f:	e8 05 01 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a4:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a8:	89 c2                	mov    %eax,%edx
c01001aa:	a1 00 80 12 c0       	mov    0xc0128000,%eax
c01001af:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b7:	c7 04 24 fd 9d 10 c0 	movl   $0xc0109dfd,(%esp)
c01001be:	e8 e6 00 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c3:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c7:	89 c2                	mov    %eax,%edx
c01001c9:	a1 00 80 12 c0       	mov    0xc0128000,%eax
c01001ce:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d6:	c7 04 24 0b 9e 10 c0 	movl   $0xc0109e0b,(%esp)
c01001dd:	e8 c7 00 00 00       	call   c01002a9 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001e2:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e6:	89 c2                	mov    %eax,%edx
c01001e8:	a1 00 80 12 c0       	mov    0xc0128000,%eax
c01001ed:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f5:	c7 04 24 19 9e 10 c0 	movl   $0xc0109e19,(%esp)
c01001fc:	e8 a8 00 00 00       	call   c01002a9 <cprintf>
    round ++;
c0100201:	a1 00 80 12 c0       	mov    0xc0128000,%eax
c0100206:	40                   	inc    %eax
c0100207:	a3 00 80 12 c0       	mov    %eax,0xc0128000
}
c010020c:	90                   	nop
c010020d:	c9                   	leave  
c010020e:	c3                   	ret    

c010020f <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c010020f:	55                   	push   %ebp
c0100210:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c0100212:	90                   	nop
c0100213:	5d                   	pop    %ebp
c0100214:	c3                   	ret    

c0100215 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100215:	55                   	push   %ebp
c0100216:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100218:	90                   	nop
c0100219:	5d                   	pop    %ebp
c010021a:	c3                   	ret    

c010021b <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010021b:	55                   	push   %ebp
c010021c:	89 e5                	mov    %esp,%ebp
c010021e:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100221:	e8 2b ff ff ff       	call   c0100151 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100226:	c7 04 24 28 9e 10 c0 	movl   $0xc0109e28,(%esp)
c010022d:	e8 77 00 00 00       	call   c01002a9 <cprintf>
    lab1_switch_to_user();
c0100232:	e8 d8 ff ff ff       	call   c010020f <lab1_switch_to_user>
    lab1_print_cur_status();
c0100237:	e8 15 ff ff ff       	call   c0100151 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010023c:	c7 04 24 48 9e 10 c0 	movl   $0xc0109e48,(%esp)
c0100243:	e8 61 00 00 00       	call   c01002a9 <cprintf>
    lab1_switch_to_kernel();
c0100248:	e8 c8 ff ff ff       	call   c0100215 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010024d:	e8 ff fe ff ff       	call   c0100151 <lab1_print_cur_status>
}
c0100252:	90                   	nop
c0100253:	c9                   	leave  
c0100254:	c3                   	ret    

c0100255 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100255:	55                   	push   %ebp
c0100256:	89 e5                	mov    %esp,%ebp
c0100258:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010025b:	8b 45 08             	mov    0x8(%ebp),%eax
c010025e:	89 04 24             	mov    %eax,(%esp)
c0100261:	e8 22 1c 00 00       	call   c0101e88 <cons_putc>
    (*cnt) ++;
c0100266:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100269:	8b 00                	mov    (%eax),%eax
c010026b:	8d 50 01             	lea    0x1(%eax),%edx
c010026e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100271:	89 10                	mov    %edx,(%eax)
}
c0100273:	90                   	nop
c0100274:	c9                   	leave  
c0100275:	c3                   	ret    

c0100276 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100276:	55                   	push   %ebp
c0100277:	89 e5                	mov    %esp,%ebp
c0100279:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010027c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100283:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100286:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010028a:	8b 45 08             	mov    0x8(%ebp),%eax
c010028d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100291:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100294:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100298:	c7 04 24 55 02 10 c0 	movl   $0xc0100255,(%esp)
c010029f:	e8 62 95 00 00       	call   c0109806 <vprintfmt>
    return cnt;
c01002a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002a7:	c9                   	leave  
c01002a8:	c3                   	ret    

c01002a9 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01002a9:	55                   	push   %ebp
c01002aa:	89 e5                	mov    %esp,%ebp
c01002ac:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01002af:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002b8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01002bf:	89 04 24             	mov    %eax,(%esp)
c01002c2:	e8 af ff ff ff       	call   c0100276 <vcprintf>
c01002c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002cd:	c9                   	leave  
c01002ce:	c3                   	ret    

c01002cf <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002cf:	55                   	push   %ebp
c01002d0:	89 e5                	mov    %esp,%ebp
c01002d2:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01002d8:	89 04 24             	mov    %eax,(%esp)
c01002db:	e8 a8 1b 00 00       	call   c0101e88 <cons_putc>
}
c01002e0:	90                   	nop
c01002e1:	c9                   	leave  
c01002e2:	c3                   	ret    

c01002e3 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002e3:	55                   	push   %ebp
c01002e4:	89 e5                	mov    %esp,%ebp
c01002e6:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002e9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002f0:	eb 13                	jmp    c0100305 <cputs+0x22>
        cputch(c, &cnt);
c01002f2:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002f6:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002f9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01002fd:	89 04 24             	mov    %eax,(%esp)
c0100300:	e8 50 ff ff ff       	call   c0100255 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c0100305:	8b 45 08             	mov    0x8(%ebp),%eax
c0100308:	8d 50 01             	lea    0x1(%eax),%edx
c010030b:	89 55 08             	mov    %edx,0x8(%ebp)
c010030e:	0f b6 00             	movzbl (%eax),%eax
c0100311:	88 45 f7             	mov    %al,-0x9(%ebp)
c0100314:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100318:	75 d8                	jne    c01002f2 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c010031a:	8d 45 f0             	lea    -0x10(%ebp),%eax
c010031d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100321:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100328:	e8 28 ff ff ff       	call   c0100255 <cputch>
    return cnt;
c010032d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100330:	c9                   	leave  
c0100331:	c3                   	ret    

c0100332 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c0100332:	55                   	push   %ebp
c0100333:	89 e5                	mov    %esp,%ebp
c0100335:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100338:	e8 88 1b 00 00       	call   c0101ec5 <cons_getc>
c010033d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100340:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100344:	74 f2                	je     c0100338 <getchar+0x6>
        /* do nothing */;
    return c;
c0100346:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100349:	c9                   	leave  
c010034a:	c3                   	ret    

c010034b <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010034b:	55                   	push   %ebp
c010034c:	89 e5                	mov    %esp,%ebp
c010034e:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100351:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100355:	74 13                	je     c010036a <readline+0x1f>
        cprintf("%s", prompt);
c0100357:	8b 45 08             	mov    0x8(%ebp),%eax
c010035a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010035e:	c7 04 24 67 9e 10 c0 	movl   $0xc0109e67,(%esp)
c0100365:	e8 3f ff ff ff       	call   c01002a9 <cprintf>
    }
    int i = 0, c;
c010036a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100371:	e8 bc ff ff ff       	call   c0100332 <getchar>
c0100376:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100379:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010037d:	79 07                	jns    c0100386 <readline+0x3b>
            return NULL;
c010037f:	b8 00 00 00 00       	mov    $0x0,%eax
c0100384:	eb 78                	jmp    c01003fe <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100386:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010038a:	7e 28                	jle    c01003b4 <readline+0x69>
c010038c:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100393:	7f 1f                	jg     c01003b4 <readline+0x69>
            cputchar(c);
c0100395:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100398:	89 04 24             	mov    %eax,(%esp)
c010039b:	e8 2f ff ff ff       	call   c01002cf <cputchar>
            buf[i ++] = c;
c01003a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003a3:	8d 50 01             	lea    0x1(%eax),%edx
c01003a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01003a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003ac:	88 90 20 80 12 c0    	mov    %dl,-0x3fed7fe0(%eax)
c01003b2:	eb 45                	jmp    c01003f9 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01003b4:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003b8:	75 16                	jne    c01003d0 <readline+0x85>
c01003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003be:	7e 10                	jle    c01003d0 <readline+0x85>
            cputchar(c);
c01003c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003c3:	89 04 24             	mov    %eax,(%esp)
c01003c6:	e8 04 ff ff ff       	call   c01002cf <cputchar>
            i --;
c01003cb:	ff 4d f4             	decl   -0xc(%ebp)
c01003ce:	eb 29                	jmp    c01003f9 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01003d0:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003d4:	74 06                	je     c01003dc <readline+0x91>
c01003d6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003da:	75 95                	jne    c0100371 <readline+0x26>
            cputchar(c);
c01003dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003df:	89 04 24             	mov    %eax,(%esp)
c01003e2:	e8 e8 fe ff ff       	call   c01002cf <cputchar>
            buf[i] = '\0';
c01003e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003ea:	05 20 80 12 c0       	add    $0xc0128020,%eax
c01003ef:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003f2:	b8 20 80 12 c0       	mov    $0xc0128020,%eax
c01003f7:	eb 05                	jmp    c01003fe <readline+0xb3>
        }
    }
c01003f9:	e9 73 ff ff ff       	jmp    c0100371 <readline+0x26>
}
c01003fe:	c9                   	leave  
c01003ff:	c3                   	ret    

c0100400 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100400:	55                   	push   %ebp
c0100401:	89 e5                	mov    %esp,%ebp
c0100403:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100406:	a1 20 84 12 c0       	mov    0xc0128420,%eax
c010040b:	85 c0                	test   %eax,%eax
c010040d:	75 5b                	jne    c010046a <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c010040f:	c7 05 20 84 12 c0 01 	movl   $0x1,0xc0128420
c0100416:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100419:	8d 45 14             	lea    0x14(%ebp),%eax
c010041c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c010041f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100422:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100426:	8b 45 08             	mov    0x8(%ebp),%eax
c0100429:	89 44 24 04          	mov    %eax,0x4(%esp)
c010042d:	c7 04 24 6a 9e 10 c0 	movl   $0xc0109e6a,(%esp)
c0100434:	e8 70 fe ff ff       	call   c01002a9 <cprintf>
    vcprintf(fmt, ap);
c0100439:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010043c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100440:	8b 45 10             	mov    0x10(%ebp),%eax
c0100443:	89 04 24             	mov    %eax,(%esp)
c0100446:	e8 2b fe ff ff       	call   c0100276 <vcprintf>
    cprintf("\n");
c010044b:	c7 04 24 86 9e 10 c0 	movl   $0xc0109e86,(%esp)
c0100452:	e8 52 fe ff ff       	call   c01002a9 <cprintf>
    
    cprintf("stack trackback:\n");
c0100457:	c7 04 24 88 9e 10 c0 	movl   $0xc0109e88,(%esp)
c010045e:	e8 46 fe ff ff       	call   c01002a9 <cprintf>
    print_stackframe();
c0100463:	e8 32 06 00 00       	call   c0100a9a <print_stackframe>
c0100468:	eb 01                	jmp    c010046b <__panic+0x6b>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
c010046a:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
c010046b:	e8 89 1c 00 00       	call   c01020f9 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100470:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100477:	e8 4b 08 00 00       	call   c0100cc7 <kmonitor>
    }
c010047c:	eb f2                	jmp    c0100470 <__panic+0x70>

c010047e <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c010047e:	55                   	push   %ebp
c010047f:	89 e5                	mov    %esp,%ebp
c0100481:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100484:	8d 45 14             	lea    0x14(%ebp),%eax
c0100487:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c010048a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010048d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100491:	8b 45 08             	mov    0x8(%ebp),%eax
c0100494:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100498:	c7 04 24 9a 9e 10 c0 	movl   $0xc0109e9a,(%esp)
c010049f:	e8 05 fe ff ff       	call   c01002a9 <cprintf>
    vcprintf(fmt, ap);
c01004a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004a7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004ab:	8b 45 10             	mov    0x10(%ebp),%eax
c01004ae:	89 04 24             	mov    %eax,(%esp)
c01004b1:	e8 c0 fd ff ff       	call   c0100276 <vcprintf>
    cprintf("\n");
c01004b6:	c7 04 24 86 9e 10 c0 	movl   $0xc0109e86,(%esp)
c01004bd:	e8 e7 fd ff ff       	call   c01002a9 <cprintf>
    va_end(ap);
}
c01004c2:	90                   	nop
c01004c3:	c9                   	leave  
c01004c4:	c3                   	ret    

c01004c5 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004c5:	55                   	push   %ebp
c01004c6:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004c8:	a1 20 84 12 c0       	mov    0xc0128420,%eax
}
c01004cd:	5d                   	pop    %ebp
c01004ce:	c3                   	ret    

c01004cf <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004cf:	55                   	push   %ebp
c01004d0:	89 e5                	mov    %esp,%ebp
c01004d2:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004d8:	8b 00                	mov    (%eax),%eax
c01004da:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004dd:	8b 45 10             	mov    0x10(%ebp),%eax
c01004e0:	8b 00                	mov    (%eax),%eax
c01004e2:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004ec:	e9 ca 00 00 00       	jmp    c01005bb <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c01004f1:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004f7:	01 d0                	add    %edx,%eax
c01004f9:	89 c2                	mov    %eax,%edx
c01004fb:	c1 ea 1f             	shr    $0x1f,%edx
c01004fe:	01 d0                	add    %edx,%eax
c0100500:	d1 f8                	sar    %eax
c0100502:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100505:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100508:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010050b:	eb 03                	jmp    c0100510 <stab_binsearch+0x41>
            m --;
c010050d:	ff 4d f0             	decl   -0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100510:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100513:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100516:	7c 1f                	jl     c0100537 <stab_binsearch+0x68>
c0100518:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010051b:	89 d0                	mov    %edx,%eax
c010051d:	01 c0                	add    %eax,%eax
c010051f:	01 d0                	add    %edx,%eax
c0100521:	c1 e0 02             	shl    $0x2,%eax
c0100524:	89 c2                	mov    %eax,%edx
c0100526:	8b 45 08             	mov    0x8(%ebp),%eax
c0100529:	01 d0                	add    %edx,%eax
c010052b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010052f:	0f b6 c0             	movzbl %al,%eax
c0100532:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100535:	75 d6                	jne    c010050d <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100537:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010053a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010053d:	7d 09                	jge    c0100548 <stab_binsearch+0x79>
            l = true_m + 1;
c010053f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100542:	40                   	inc    %eax
c0100543:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100546:	eb 73                	jmp    c01005bb <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c0100548:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010054f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100552:	89 d0                	mov    %edx,%eax
c0100554:	01 c0                	add    %eax,%eax
c0100556:	01 d0                	add    %edx,%eax
c0100558:	c1 e0 02             	shl    $0x2,%eax
c010055b:	89 c2                	mov    %eax,%edx
c010055d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100560:	01 d0                	add    %edx,%eax
c0100562:	8b 40 08             	mov    0x8(%eax),%eax
c0100565:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100568:	73 11                	jae    c010057b <stab_binsearch+0xac>
            *region_left = m;
c010056a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100570:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c0100572:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100575:	40                   	inc    %eax
c0100576:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100579:	eb 40                	jmp    c01005bb <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c010057b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010057e:	89 d0                	mov    %edx,%eax
c0100580:	01 c0                	add    %eax,%eax
c0100582:	01 d0                	add    %edx,%eax
c0100584:	c1 e0 02             	shl    $0x2,%eax
c0100587:	89 c2                	mov    %eax,%edx
c0100589:	8b 45 08             	mov    0x8(%ebp),%eax
c010058c:	01 d0                	add    %edx,%eax
c010058e:	8b 40 08             	mov    0x8(%eax),%eax
c0100591:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100594:	76 14                	jbe    c01005aa <stab_binsearch+0xdb>
            *region_right = m - 1;
c0100596:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100599:	8d 50 ff             	lea    -0x1(%eax),%edx
c010059c:	8b 45 10             	mov    0x10(%ebp),%eax
c010059f:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01005a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005a4:	48                   	dec    %eax
c01005a5:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01005a8:	eb 11                	jmp    c01005bb <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01005aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005b0:	89 10                	mov    %edx,(%eax)
            l = m;
c01005b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005b5:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005b8:	ff 45 18             	incl   0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01005bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005be:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005c1:	0f 8e 2a ff ff ff    	jle    c01004f1 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01005c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005cb:	75 0f                	jne    c01005dc <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01005cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005d0:	8b 00                	mov    (%eax),%eax
c01005d2:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005d5:	8b 45 10             	mov    0x10(%ebp),%eax
c01005d8:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005da:	eb 3e                	jmp    c010061a <stab_binsearch+0x14b>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01005dc:	8b 45 10             	mov    0x10(%ebp),%eax
c01005df:	8b 00                	mov    (%eax),%eax
c01005e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005e4:	eb 03                	jmp    c01005e9 <stab_binsearch+0x11a>
c01005e6:	ff 4d fc             	decl   -0x4(%ebp)
c01005e9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005ec:	8b 00                	mov    (%eax),%eax
c01005ee:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01005f1:	7d 1f                	jge    c0100612 <stab_binsearch+0x143>
c01005f3:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005f6:	89 d0                	mov    %edx,%eax
c01005f8:	01 c0                	add    %eax,%eax
c01005fa:	01 d0                	add    %edx,%eax
c01005fc:	c1 e0 02             	shl    $0x2,%eax
c01005ff:	89 c2                	mov    %eax,%edx
c0100601:	8b 45 08             	mov    0x8(%ebp),%eax
c0100604:	01 d0                	add    %edx,%eax
c0100606:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010060a:	0f b6 c0             	movzbl %al,%eax
c010060d:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100610:	75 d4                	jne    c01005e6 <stab_binsearch+0x117>
            /* do nothing */;
        *region_left = l;
c0100612:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100615:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100618:	89 10                	mov    %edx,(%eax)
    }
}
c010061a:	90                   	nop
c010061b:	c9                   	leave  
c010061c:	c3                   	ret    

c010061d <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010061d:	55                   	push   %ebp
c010061e:	89 e5                	mov    %esp,%ebp
c0100620:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100623:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100626:	c7 00 b8 9e 10 c0    	movl   $0xc0109eb8,(%eax)
    info->eip_line = 0;
c010062c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100636:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100639:	c7 40 08 b8 9e 10 c0 	movl   $0xc0109eb8,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100640:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100643:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010064a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010064d:	8b 55 08             	mov    0x8(%ebp),%edx
c0100650:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100653:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100656:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010065d:	c7 45 f4 84 c0 10 c0 	movl   $0xc010c084,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100664:	c7 45 f0 f0 d7 11 c0 	movl   $0xc011d7f0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010066b:	c7 45 ec f1 d7 11 c0 	movl   $0xc011d7f1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100672:	c7 45 e8 85 20 12 c0 	movl   $0xc0122085,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100679:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010067c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010067f:	76 0b                	jbe    c010068c <debuginfo_eip+0x6f>
c0100681:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100684:	48                   	dec    %eax
c0100685:	0f b6 00             	movzbl (%eax),%eax
c0100688:	84 c0                	test   %al,%al
c010068a:	74 0a                	je     c0100696 <debuginfo_eip+0x79>
        return -1;
c010068c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100691:	e9 b7 02 00 00       	jmp    c010094d <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c0100696:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c010069d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01006a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006a3:	29 c2                	sub    %eax,%edx
c01006a5:	89 d0                	mov    %edx,%eax
c01006a7:	c1 f8 02             	sar    $0x2,%eax
c01006aa:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006b0:	48                   	dec    %eax
c01006b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01006b7:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006bb:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006c2:	00 
c01006c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006c6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006cd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006d4:	89 04 24             	mov    %eax,(%esp)
c01006d7:	e8 f3 fd ff ff       	call   c01004cf <stab_binsearch>
    if (lfile == 0)
c01006dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006df:	85 c0                	test   %eax,%eax
c01006e1:	75 0a                	jne    c01006ed <debuginfo_eip+0xd0>
        return -1;
c01006e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006e8:	e9 60 02 00 00       	jmp    c010094d <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01006fc:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100700:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100707:	00 
c0100708:	8d 45 d8             	lea    -0x28(%ebp),%eax
c010070b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010070f:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100712:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100716:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100719:	89 04 24             	mov    %eax,(%esp)
c010071c:	e8 ae fd ff ff       	call   c01004cf <stab_binsearch>

    if (lfun <= rfun) {
c0100721:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100724:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100727:	39 c2                	cmp    %eax,%edx
c0100729:	7f 7c                	jg     c01007a7 <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010072b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010072e:	89 c2                	mov    %eax,%edx
c0100730:	89 d0                	mov    %edx,%eax
c0100732:	01 c0                	add    %eax,%eax
c0100734:	01 d0                	add    %edx,%eax
c0100736:	c1 e0 02             	shl    $0x2,%eax
c0100739:	89 c2                	mov    %eax,%edx
c010073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010073e:	01 d0                	add    %edx,%eax
c0100740:	8b 00                	mov    (%eax),%eax
c0100742:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100745:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100748:	29 d1                	sub    %edx,%ecx
c010074a:	89 ca                	mov    %ecx,%edx
c010074c:	39 d0                	cmp    %edx,%eax
c010074e:	73 22                	jae    c0100772 <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100750:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100753:	89 c2                	mov    %eax,%edx
c0100755:	89 d0                	mov    %edx,%eax
c0100757:	01 c0                	add    %eax,%eax
c0100759:	01 d0                	add    %edx,%eax
c010075b:	c1 e0 02             	shl    $0x2,%eax
c010075e:	89 c2                	mov    %eax,%edx
c0100760:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100763:	01 d0                	add    %edx,%eax
c0100765:	8b 10                	mov    (%eax),%edx
c0100767:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010076a:	01 c2                	add    %eax,%edx
c010076c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010076f:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100772:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100775:	89 c2                	mov    %eax,%edx
c0100777:	89 d0                	mov    %edx,%eax
c0100779:	01 c0                	add    %eax,%eax
c010077b:	01 d0                	add    %edx,%eax
c010077d:	c1 e0 02             	shl    $0x2,%eax
c0100780:	89 c2                	mov    %eax,%edx
c0100782:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100785:	01 d0                	add    %edx,%eax
c0100787:	8b 50 08             	mov    0x8(%eax),%edx
c010078a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010078d:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100790:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100793:	8b 40 10             	mov    0x10(%eax),%eax
c0100796:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100799:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010079c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c010079f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01007a5:	eb 15                	jmp    c01007bc <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007aa:	8b 55 08             	mov    0x8(%ebp),%edx
c01007ad:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01007b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007bf:	8b 40 08             	mov    0x8(%eax),%eax
c01007c2:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007c9:	00 
c01007ca:	89 04 24             	mov    %eax,(%esp)
c01007cd:	e8 5d 8b 00 00       	call   c010932f <strfind>
c01007d2:	89 c2                	mov    %eax,%edx
c01007d4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d7:	8b 40 08             	mov    0x8(%eax),%eax
c01007da:	29 c2                	sub    %eax,%edx
c01007dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007df:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01007e5:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007e9:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01007f0:	00 
c01007f1:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007f4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007f8:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007fb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100802:	89 04 24             	mov    %eax,(%esp)
c0100805:	e8 c5 fc ff ff       	call   c01004cf <stab_binsearch>
    if (lline <= rline) {
c010080a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010080d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100810:	39 c2                	cmp    %eax,%edx
c0100812:	7f 23                	jg     c0100837 <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
c0100814:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100817:	89 c2                	mov    %eax,%edx
c0100819:	89 d0                	mov    %edx,%eax
c010081b:	01 c0                	add    %eax,%eax
c010081d:	01 d0                	add    %edx,%eax
c010081f:	c1 e0 02             	shl    $0x2,%eax
c0100822:	89 c2                	mov    %eax,%edx
c0100824:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100827:	01 d0                	add    %edx,%eax
c0100829:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010082d:	89 c2                	mov    %eax,%edx
c010082f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100832:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100835:	eb 11                	jmp    c0100848 <debuginfo_eip+0x22b>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c0100837:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010083c:	e9 0c 01 00 00       	jmp    c010094d <debuginfo_eip+0x330>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100841:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100844:	48                   	dec    %eax
c0100845:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100848:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010084b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010084e:	39 c2                	cmp    %eax,%edx
c0100850:	7c 56                	jl     c01008a8 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
c0100852:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100855:	89 c2                	mov    %eax,%edx
c0100857:	89 d0                	mov    %edx,%eax
c0100859:	01 c0                	add    %eax,%eax
c010085b:	01 d0                	add    %edx,%eax
c010085d:	c1 e0 02             	shl    $0x2,%eax
c0100860:	89 c2                	mov    %eax,%edx
c0100862:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100865:	01 d0                	add    %edx,%eax
c0100867:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010086b:	3c 84                	cmp    $0x84,%al
c010086d:	74 39                	je     c01008a8 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010086f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100872:	89 c2                	mov    %eax,%edx
c0100874:	89 d0                	mov    %edx,%eax
c0100876:	01 c0                	add    %eax,%eax
c0100878:	01 d0                	add    %edx,%eax
c010087a:	c1 e0 02             	shl    $0x2,%eax
c010087d:	89 c2                	mov    %eax,%edx
c010087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100882:	01 d0                	add    %edx,%eax
c0100884:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100888:	3c 64                	cmp    $0x64,%al
c010088a:	75 b5                	jne    c0100841 <debuginfo_eip+0x224>
c010088c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010088f:	89 c2                	mov    %eax,%edx
c0100891:	89 d0                	mov    %edx,%eax
c0100893:	01 c0                	add    %eax,%eax
c0100895:	01 d0                	add    %edx,%eax
c0100897:	c1 e0 02             	shl    $0x2,%eax
c010089a:	89 c2                	mov    %eax,%edx
c010089c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010089f:	01 d0                	add    %edx,%eax
c01008a1:	8b 40 08             	mov    0x8(%eax),%eax
c01008a4:	85 c0                	test   %eax,%eax
c01008a6:	74 99                	je     c0100841 <debuginfo_eip+0x224>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008a8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01008ae:	39 c2                	cmp    %eax,%edx
c01008b0:	7c 46                	jl     c01008f8 <debuginfo_eip+0x2db>
c01008b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008b5:	89 c2                	mov    %eax,%edx
c01008b7:	89 d0                	mov    %edx,%eax
c01008b9:	01 c0                	add    %eax,%eax
c01008bb:	01 d0                	add    %edx,%eax
c01008bd:	c1 e0 02             	shl    $0x2,%eax
c01008c0:	89 c2                	mov    %eax,%edx
c01008c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008c5:	01 d0                	add    %edx,%eax
c01008c7:	8b 00                	mov    (%eax),%eax
c01008c9:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008cc:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01008cf:	29 d1                	sub    %edx,%ecx
c01008d1:	89 ca                	mov    %ecx,%edx
c01008d3:	39 d0                	cmp    %edx,%eax
c01008d5:	73 21                	jae    c01008f8 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008da:	89 c2                	mov    %eax,%edx
c01008dc:	89 d0                	mov    %edx,%eax
c01008de:	01 c0                	add    %eax,%eax
c01008e0:	01 d0                	add    %edx,%eax
c01008e2:	c1 e0 02             	shl    $0x2,%eax
c01008e5:	89 c2                	mov    %eax,%edx
c01008e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ea:	01 d0                	add    %edx,%eax
c01008ec:	8b 10                	mov    (%eax),%edx
c01008ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008f1:	01 c2                	add    %eax,%edx
c01008f3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008f6:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008fe:	39 c2                	cmp    %eax,%edx
c0100900:	7d 46                	jge    c0100948 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
c0100902:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100905:	40                   	inc    %eax
c0100906:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100909:	eb 16                	jmp    c0100921 <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c010090b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010090e:	8b 40 14             	mov    0x14(%eax),%eax
c0100911:	8d 50 01             	lea    0x1(%eax),%edx
c0100914:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100917:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c010091a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010091d:	40                   	inc    %eax
c010091e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100921:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100924:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100927:	39 c2                	cmp    %eax,%edx
c0100929:	7d 1d                	jge    c0100948 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010092b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010092e:	89 c2                	mov    %eax,%edx
c0100930:	89 d0                	mov    %edx,%eax
c0100932:	01 c0                	add    %eax,%eax
c0100934:	01 d0                	add    %edx,%eax
c0100936:	c1 e0 02             	shl    $0x2,%eax
c0100939:	89 c2                	mov    %eax,%edx
c010093b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010093e:	01 d0                	add    %edx,%eax
c0100940:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100944:	3c a0                	cmp    $0xa0,%al
c0100946:	74 c3                	je     c010090b <debuginfo_eip+0x2ee>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100948:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010094d:	c9                   	leave  
c010094e:	c3                   	ret    

c010094f <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010094f:	55                   	push   %ebp
c0100950:	89 e5                	mov    %esp,%ebp
c0100952:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100955:	c7 04 24 c2 9e 10 c0 	movl   $0xc0109ec2,(%esp)
c010095c:	e8 48 f9 ff ff       	call   c01002a9 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100961:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100968:	c0 
c0100969:	c7 04 24 db 9e 10 c0 	movl   $0xc0109edb,(%esp)
c0100970:	e8 34 f9 ff ff       	call   c01002a9 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c0100975:	c7 44 24 04 aa 9d 10 	movl   $0xc0109daa,0x4(%esp)
c010097c:	c0 
c010097d:	c7 04 24 f3 9e 10 c0 	movl   $0xc0109ef3,(%esp)
c0100984:	e8 20 f9 ff ff       	call   c01002a9 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100989:	c7 44 24 04 00 80 12 	movl   $0xc0128000,0x4(%esp)
c0100990:	c0 
c0100991:	c7 04 24 0b 9f 10 c0 	movl   $0xc0109f0b,(%esp)
c0100998:	e8 0c f9 ff ff       	call   c01002a9 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c010099d:	c7 44 24 04 4c b1 12 	movl   $0xc012b14c,0x4(%esp)
c01009a4:	c0 
c01009a5:	c7 04 24 23 9f 10 c0 	movl   $0xc0109f23,(%esp)
c01009ac:	e8 f8 f8 ff ff       	call   c01002a9 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009b1:	b8 4c b1 12 c0       	mov    $0xc012b14c,%eax
c01009b6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009bc:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009c1:	29 c2                	sub    %eax,%edx
c01009c3:	89 d0                	mov    %edx,%eax
c01009c5:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009cb:	85 c0                	test   %eax,%eax
c01009cd:	0f 48 c2             	cmovs  %edx,%eax
c01009d0:	c1 f8 0a             	sar    $0xa,%eax
c01009d3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009d7:	c7 04 24 3c 9f 10 c0 	movl   $0xc0109f3c,(%esp)
c01009de:	e8 c6 f8 ff ff       	call   c01002a9 <cprintf>
}
c01009e3:	90                   	nop
c01009e4:	c9                   	leave  
c01009e5:	c3                   	ret    

c01009e6 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009e6:	55                   	push   %ebp
c01009e7:	89 e5                	mov    %esp,%ebp
c01009e9:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009ef:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009f2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01009f9:	89 04 24             	mov    %eax,(%esp)
c01009fc:	e8 1c fc ff ff       	call   c010061d <debuginfo_eip>
c0100a01:	85 c0                	test   %eax,%eax
c0100a03:	74 15                	je     c0100a1a <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100a05:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a08:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a0c:	c7 04 24 66 9f 10 c0 	movl   $0xc0109f66,(%esp)
c0100a13:	e8 91 f8 ff ff       	call   c01002a9 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a18:	eb 6c                	jmp    c0100a86 <print_debuginfo+0xa0>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a21:	eb 1b                	jmp    c0100a3e <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100a23:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a29:	01 d0                	add    %edx,%eax
c0100a2b:	0f b6 00             	movzbl (%eax),%eax
c0100a2e:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a34:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a37:	01 ca                	add    %ecx,%edx
c0100a39:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a3b:	ff 45 f4             	incl   -0xc(%ebp)
c0100a3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a41:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a44:	7f dd                	jg     c0100a23 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100a46:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a4f:	01 d0                	add    %edx,%eax
c0100a51:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a54:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a57:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a5a:	89 d1                	mov    %edx,%ecx
c0100a5c:	29 c1                	sub    %eax,%ecx
c0100a5e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a61:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a64:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a68:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a6e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a72:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a7a:	c7 04 24 82 9f 10 c0 	movl   $0xc0109f82,(%esp)
c0100a81:	e8 23 f8 ff ff       	call   c01002a9 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a86:	90                   	nop
c0100a87:	c9                   	leave  
c0100a88:	c3                   	ret    

c0100a89 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a89:	55                   	push   %ebp
c0100a8a:	89 e5                	mov    %esp,%ebp
c0100a8c:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a8f:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a92:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a95:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a98:	c9                   	leave  
c0100a99:	c3                   	ret    

c0100a9a <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a9a:	55                   	push   %ebp
c0100a9b:	89 e5                	mov    %esp,%ebp
c0100a9d:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100aa0:	89 e8                	mov    %ebp,%eax
c0100aa2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100aa5:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp();
c0100aa8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip=read_eip();
c0100aab:	e8 d9 ff ff ff       	call   c0100a89 <read_eip>
c0100ab0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (int i = 0; i < STACKFRAME_DEPTH; i ++) {
c0100ab3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100aba:	e9 88 00 00 00       	jmp    c0100b47 <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ac2:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ac9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100acd:	c7 04 24 94 9f 10 c0 	movl   $0xc0109f94,(%esp)
c0100ad4:	e8 d0 f7 ff ff       	call   c01002a9 <cprintf>
        uint32_t *fun_stack = (uint32_t *)ebp ;
c0100ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100adc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int j = 2; j < 6; j ++) {
c0100adf:	c7 45 e8 02 00 00 00 	movl   $0x2,-0x18(%ebp)
c0100ae6:	eb 24                	jmp    c0100b0c <print_stackframe+0x72>
            cprintf("0x%08x ", fun_stack[j]);
c0100ae8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100aeb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100af2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100af5:	01 d0                	add    %edx,%eax
c0100af7:	8b 00                	mov    (%eax),%eax
c0100af9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100afd:	c7 04 24 b0 9f 10 c0 	movl   $0xc0109fb0,(%esp)
c0100b04:	e8 a0 f7 ff ff       	call   c01002a9 <cprintf>
    uint32_t ebp = read_ebp();
    uint32_t eip=read_eip();
    for (int i = 0; i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *fun_stack = (uint32_t *)ebp ;
        for (int j = 2; j < 6; j ++) {
c0100b09:	ff 45 e8             	incl   -0x18(%ebp)
c0100b0c:	83 7d e8 05          	cmpl   $0x5,-0x18(%ebp)
c0100b10:	7e d6                	jle    c0100ae8 <print_stackframe+0x4e>
            cprintf("0x%08x ", fun_stack[j]);
        }
        cprintf("\n");
c0100b12:	c7 04 24 b8 9f 10 c0 	movl   $0xc0109fb8,(%esp)
c0100b19:	e8 8b f7 ff ff       	call   c01002a9 <cprintf>
        print_debuginfo(eip - 1);
c0100b1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b21:	48                   	dec    %eax
c0100b22:	89 04 24             	mov    %eax,(%esp)
c0100b25:	e8 bc fe ff ff       	call   c01009e6 <print_debuginfo>
        if(fun_stack[0]==0) break;
c0100b2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100b2d:	8b 00                	mov    (%eax),%eax
c0100b2f:	85 c0                	test   %eax,%eax
c0100b31:	74 20                	je     c0100b53 <print_stackframe+0xb9>
        eip = fun_stack[1];
c0100b33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100b36:	8b 40 04             	mov    0x4(%eax),%eax
c0100b39:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = fun_stack[0];
c0100b3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100b3f:	8b 00                	mov    (%eax),%eax
c0100b41:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp();
    uint32_t eip=read_eip();
    for (int i = 0; i < STACKFRAME_DEPTH; i ++) {
c0100b44:	ff 45 ec             	incl   -0x14(%ebp)
c0100b47:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b4b:	0f 8e 6e ff ff ff    	jle    c0100abf <print_stackframe+0x25>
        print_debuginfo(eip - 1);
        if(fun_stack[0]==0) break;
        eip = fun_stack[1];
        ebp = fun_stack[0];
    }
}
c0100b51:	eb 01                	jmp    c0100b54 <print_stackframe+0xba>
        for (int j = 2; j < 6; j ++) {
            cprintf("0x%08x ", fun_stack[j]);
        }
        cprintf("\n");
        print_debuginfo(eip - 1);
        if(fun_stack[0]==0) break;
c0100b53:	90                   	nop
        eip = fun_stack[1];
        ebp = fun_stack[0];
    }
}
c0100b54:	90                   	nop
c0100b55:	c9                   	leave  
c0100b56:	c3                   	ret    

c0100b57 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b57:	55                   	push   %ebp
c0100b58:	89 e5                	mov    %esp,%ebp
c0100b5a:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b64:	eb 0c                	jmp    c0100b72 <parse+0x1b>
            *buf ++ = '\0';
c0100b66:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b69:	8d 50 01             	lea    0x1(%eax),%edx
c0100b6c:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b6f:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b72:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b75:	0f b6 00             	movzbl (%eax),%eax
c0100b78:	84 c0                	test   %al,%al
c0100b7a:	74 1d                	je     c0100b99 <parse+0x42>
c0100b7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b7f:	0f b6 00             	movzbl (%eax),%eax
c0100b82:	0f be c0             	movsbl %al,%eax
c0100b85:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b89:	c7 04 24 3c a0 10 c0 	movl   $0xc010a03c,(%esp)
c0100b90:	e8 68 87 00 00       	call   c01092fd <strchr>
c0100b95:	85 c0                	test   %eax,%eax
c0100b97:	75 cd                	jne    c0100b66 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100b99:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b9c:	0f b6 00             	movzbl (%eax),%eax
c0100b9f:	84 c0                	test   %al,%al
c0100ba1:	74 69                	je     c0100c0c <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100ba3:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100ba7:	75 14                	jne    c0100bbd <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ba9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100bb0:	00 
c0100bb1:	c7 04 24 41 a0 10 c0 	movl   $0xc010a041,(%esp)
c0100bb8:	e8 ec f6 ff ff       	call   c01002a9 <cprintf>
        }
        argv[argc ++] = buf;
c0100bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bc0:	8d 50 01             	lea    0x1(%eax),%edx
c0100bc3:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100bc6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100bcd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bd0:	01 c2                	add    %eax,%edx
c0100bd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bd5:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bd7:	eb 03                	jmp    c0100bdc <parse+0x85>
            buf ++;
c0100bd9:	ff 45 08             	incl   0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bdc:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bdf:	0f b6 00             	movzbl (%eax),%eax
c0100be2:	84 c0                	test   %al,%al
c0100be4:	0f 84 7a ff ff ff    	je     c0100b64 <parse+0xd>
c0100bea:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bed:	0f b6 00             	movzbl (%eax),%eax
c0100bf0:	0f be c0             	movsbl %al,%eax
c0100bf3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bf7:	c7 04 24 3c a0 10 c0 	movl   $0xc010a03c,(%esp)
c0100bfe:	e8 fa 86 00 00       	call   c01092fd <strchr>
c0100c03:	85 c0                	test   %eax,%eax
c0100c05:	74 d2                	je     c0100bd9 <parse+0x82>
            buf ++;
        }
    }
c0100c07:	e9 58 ff ff ff       	jmp    c0100b64 <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
c0100c0c:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c10:	c9                   	leave  
c0100c11:	c3                   	ret    

c0100c12 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c12:	55                   	push   %ebp
c0100c13:	89 e5                	mov    %esp,%ebp
c0100c15:	53                   	push   %ebx
c0100c16:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c19:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c1c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c20:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c23:	89 04 24             	mov    %eax,(%esp)
c0100c26:	e8 2c ff ff ff       	call   c0100b57 <parse>
c0100c2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c2e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c32:	75 0a                	jne    c0100c3e <runcmd+0x2c>
        return 0;
c0100c34:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c39:	e9 83 00 00 00       	jmp    c0100cc1 <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c3e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c45:	eb 5a                	jmp    c0100ca1 <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c47:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c4d:	89 d0                	mov    %edx,%eax
c0100c4f:	01 c0                	add    %eax,%eax
c0100c51:	01 d0                	add    %edx,%eax
c0100c53:	c1 e0 02             	shl    $0x2,%eax
c0100c56:	05 00 50 12 c0       	add    $0xc0125000,%eax
c0100c5b:	8b 00                	mov    (%eax),%eax
c0100c5d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c61:	89 04 24             	mov    %eax,(%esp)
c0100c64:	e8 f7 85 00 00       	call   c0109260 <strcmp>
c0100c69:	85 c0                	test   %eax,%eax
c0100c6b:	75 31                	jne    c0100c9e <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c70:	89 d0                	mov    %edx,%eax
c0100c72:	01 c0                	add    %eax,%eax
c0100c74:	01 d0                	add    %edx,%eax
c0100c76:	c1 e0 02             	shl    $0x2,%eax
c0100c79:	05 08 50 12 c0       	add    $0xc0125008,%eax
c0100c7e:	8b 10                	mov    (%eax),%edx
c0100c80:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c83:	83 c0 04             	add    $0x4,%eax
c0100c86:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c89:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100c8f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c93:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c97:	89 1c 24             	mov    %ebx,(%esp)
c0100c9a:	ff d2                	call   *%edx
c0100c9c:	eb 23                	jmp    c0100cc1 <runcmd+0xaf>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c9e:	ff 45 f4             	incl   -0xc(%ebp)
c0100ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ca4:	83 f8 02             	cmp    $0x2,%eax
c0100ca7:	76 9e                	jbe    c0100c47 <runcmd+0x35>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100ca9:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100cac:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cb0:	c7 04 24 5f a0 10 c0 	movl   $0xc010a05f,(%esp)
c0100cb7:	e8 ed f5 ff ff       	call   c01002a9 <cprintf>
    return 0;
c0100cbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cc1:	83 c4 64             	add    $0x64,%esp
c0100cc4:	5b                   	pop    %ebx
c0100cc5:	5d                   	pop    %ebp
c0100cc6:	c3                   	ret    

c0100cc7 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100cc7:	55                   	push   %ebp
c0100cc8:	89 e5                	mov    %esp,%ebp
c0100cca:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100ccd:	c7 04 24 78 a0 10 c0 	movl   $0xc010a078,(%esp)
c0100cd4:	e8 d0 f5 ff ff       	call   c01002a9 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100cd9:	c7 04 24 a0 a0 10 c0 	movl   $0xc010a0a0,(%esp)
c0100ce0:	e8 c4 f5 ff ff       	call   c01002a9 <cprintf>

    if (tf != NULL) {
c0100ce5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100ce9:	74 0b                	je     c0100cf6 <kmonitor+0x2f>
        print_trapframe(tf);
c0100ceb:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cee:	89 04 24             	mov    %eax,(%esp)
c0100cf1:	e8 e4 15 00 00       	call   c01022da <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100cf6:	c7 04 24 c5 a0 10 c0 	movl   $0xc010a0c5,(%esp)
c0100cfd:	e8 49 f6 ff ff       	call   c010034b <readline>
c0100d02:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d09:	74 eb                	je     c0100cf6 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100d0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d0e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d12:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d15:	89 04 24             	mov    %eax,(%esp)
c0100d18:	e8 f5 fe ff ff       	call   c0100c12 <runcmd>
c0100d1d:	85 c0                	test   %eax,%eax
c0100d1f:	78 02                	js     c0100d23 <kmonitor+0x5c>
                break;
            }
        }
    }
c0100d21:	eb d3                	jmp    c0100cf6 <kmonitor+0x2f>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
c0100d23:	90                   	nop
            }
        }
    }
}
c0100d24:	90                   	nop
c0100d25:	c9                   	leave  
c0100d26:	c3                   	ret    

c0100d27 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d27:	55                   	push   %ebp
c0100d28:	89 e5                	mov    %esp,%ebp
c0100d2a:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d2d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d34:	eb 3d                	jmp    c0100d73 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d36:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d39:	89 d0                	mov    %edx,%eax
c0100d3b:	01 c0                	add    %eax,%eax
c0100d3d:	01 d0                	add    %edx,%eax
c0100d3f:	c1 e0 02             	shl    $0x2,%eax
c0100d42:	05 04 50 12 c0       	add    $0xc0125004,%eax
c0100d47:	8b 08                	mov    (%eax),%ecx
c0100d49:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d4c:	89 d0                	mov    %edx,%eax
c0100d4e:	01 c0                	add    %eax,%eax
c0100d50:	01 d0                	add    %edx,%eax
c0100d52:	c1 e0 02             	shl    $0x2,%eax
c0100d55:	05 00 50 12 c0       	add    $0xc0125000,%eax
c0100d5a:	8b 00                	mov    (%eax),%eax
c0100d5c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d60:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d64:	c7 04 24 c9 a0 10 c0 	movl   $0xc010a0c9,(%esp)
c0100d6b:	e8 39 f5 ff ff       	call   c01002a9 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d70:	ff 45 f4             	incl   -0xc(%ebp)
c0100d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d76:	83 f8 02             	cmp    $0x2,%eax
c0100d79:	76 bb                	jbe    c0100d36 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100d7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d80:	c9                   	leave  
c0100d81:	c3                   	ret    

c0100d82 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d82:	55                   	push   %ebp
c0100d83:	89 e5                	mov    %esp,%ebp
c0100d85:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d88:	e8 c2 fb ff ff       	call   c010094f <print_kerninfo>
    return 0;
c0100d8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d92:	c9                   	leave  
c0100d93:	c3                   	ret    

c0100d94 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d94:	55                   	push   %ebp
c0100d95:	89 e5                	mov    %esp,%ebp
c0100d97:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d9a:	e8 fb fc ff ff       	call   c0100a9a <print_stackframe>
    return 0;
c0100d9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100da4:	c9                   	leave  
c0100da5:	c3                   	ret    

c0100da6 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0100da6:	55                   	push   %ebp
c0100da7:	89 e5                	mov    %esp,%ebp
c0100da9:	83 ec 14             	sub    $0x14,%esp
c0100dac:	8b 45 08             	mov    0x8(%ebp),%eax
c0100daf:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0100db3:	90                   	nop
c0100db4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100db7:	83 c0 07             	add    $0x7,%eax
c0100dba:	0f b7 c0             	movzwl %ax,%eax
c0100dbd:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100dc1:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100dc5:	89 c2                	mov    %eax,%edx
c0100dc7:	ec                   	in     (%dx),%al
c0100dc8:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100dcb:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100dcf:	0f b6 c0             	movzbl %al,%eax
c0100dd2:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100dd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100dd8:	25 80 00 00 00       	and    $0x80,%eax
c0100ddd:	85 c0                	test   %eax,%eax
c0100ddf:	75 d3                	jne    c0100db4 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0100de1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0100de5:	74 11                	je     c0100df8 <ide_wait_ready+0x52>
c0100de7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100dea:	83 e0 21             	and    $0x21,%eax
c0100ded:	85 c0                	test   %eax,%eax
c0100def:	74 07                	je     c0100df8 <ide_wait_ready+0x52>
        return -1;
c0100df1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100df6:	eb 05                	jmp    c0100dfd <ide_wait_ready+0x57>
    }
    return 0;
c0100df8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dfd:	c9                   	leave  
c0100dfe:	c3                   	ret    

c0100dff <ide_init>:

void
ide_init(void) {
c0100dff:	55                   	push   %ebp
c0100e00:	89 e5                	mov    %esp,%ebp
c0100e02:	57                   	push   %edi
c0100e03:	53                   	push   %ebx
c0100e04:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0100e0a:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0100e10:	e9 d4 02 00 00       	jmp    c01010e9 <ide_init+0x2ea>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0100e15:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e19:	c1 e0 03             	shl    $0x3,%eax
c0100e1c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100e23:	29 c2                	sub    %eax,%edx
c0100e25:	89 d0                	mov    %edx,%eax
c0100e27:	05 40 84 12 c0       	add    $0xc0128440,%eax
c0100e2c:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0100e2f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e33:	d1 e8                	shr    %eax
c0100e35:	0f b7 c0             	movzwl %ax,%eax
c0100e38:	8b 04 85 d4 a0 10 c0 	mov    -0x3fef5f2c(,%eax,4),%eax
c0100e3f:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0100e43:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100e4e:	00 
c0100e4f:	89 04 24             	mov    %eax,(%esp)
c0100e52:	e8 4f ff ff ff       	call   c0100da6 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0100e57:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e5b:	83 e0 01             	and    $0x1,%eax
c0100e5e:	c1 e0 04             	shl    $0x4,%eax
c0100e61:	0c e0                	or     $0xe0,%al
c0100e63:	0f b6 c0             	movzbl %al,%eax
c0100e66:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100e6a:	83 c2 06             	add    $0x6,%edx
c0100e6d:	0f b7 d2             	movzwl %dx,%edx
c0100e70:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0100e74:	88 45 c7             	mov    %al,-0x39(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e77:	0f b6 45 c7          	movzbl -0x39(%ebp),%eax
c0100e7b:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100e7f:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100e80:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100e8b:	00 
c0100e8c:	89 04 24             	mov    %eax,(%esp)
c0100e8f:	e8 12 ff ff ff       	call   c0100da6 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0100e94:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e98:	83 c0 07             	add    $0x7,%eax
c0100e9b:	0f b7 c0             	movzwl %ax,%eax
c0100e9e:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
c0100ea2:	c6 45 c8 ec          	movb   $0xec,-0x38(%ebp)
c0100ea6:	0f b6 45 c8          	movzbl -0x38(%ebp),%eax
c0100eaa:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100ead:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100eae:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100eb2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100eb9:	00 
c0100eba:	89 04 24             	mov    %eax,(%esp)
c0100ebd:	e8 e4 fe ff ff       	call   c0100da6 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0100ec2:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ec6:	83 c0 07             	add    $0x7,%eax
c0100ec9:	0f b7 c0             	movzwl %ax,%eax
c0100ecc:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ed0:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c0100ed4:	89 c2                	mov    %eax,%edx
c0100ed6:	ec                   	in     (%dx),%al
c0100ed7:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0100eda:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0100ede:	84 c0                	test   %al,%al
c0100ee0:	0f 84 f9 01 00 00    	je     c01010df <ide_init+0x2e0>
c0100ee6:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100eea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0100ef1:	00 
c0100ef2:	89 04 24             	mov    %eax,(%esp)
c0100ef5:	e8 ac fe ff ff       	call   c0100da6 <ide_wait_ready>
c0100efa:	85 c0                	test   %eax,%eax
c0100efc:	0f 85 dd 01 00 00    	jne    c01010df <ide_init+0x2e0>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0100f02:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f06:	c1 e0 03             	shl    $0x3,%eax
c0100f09:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100f10:	29 c2                	sub    %eax,%edx
c0100f12:	89 d0                	mov    %edx,%eax
c0100f14:	05 40 84 12 c0       	add    $0xc0128440,%eax
c0100f19:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0100f1c:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f20:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0100f23:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100f29:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0100f2c:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0100f33:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100f36:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0100f39:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0100f3c:	89 cb                	mov    %ecx,%ebx
c0100f3e:	89 df                	mov    %ebx,%edi
c0100f40:	89 c1                	mov    %eax,%ecx
c0100f42:	fc                   	cld    
c0100f43:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0100f45:	89 c8                	mov    %ecx,%eax
c0100f47:	89 fb                	mov    %edi,%ebx
c0100f49:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0100f4c:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0100f4f:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100f55:	89 45 dc             	mov    %eax,-0x24(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0100f58:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100f5b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0100f61:	89 45 d8             	mov    %eax,-0x28(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0100f64:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100f67:	25 00 00 00 04       	and    $0x4000000,%eax
c0100f6c:	85 c0                	test   %eax,%eax
c0100f6e:	74 0e                	je     c0100f7e <ide_init+0x17f>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0100f70:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100f73:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0100f79:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100f7c:	eb 09                	jmp    c0100f87 <ide_init+0x188>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0100f7e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100f81:	8b 40 78             	mov    0x78(%eax),%eax
c0100f84:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0100f87:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f8b:	c1 e0 03             	shl    $0x3,%eax
c0100f8e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100f95:	29 c2                	sub    %eax,%edx
c0100f97:	89 d0                	mov    %edx,%eax
c0100f99:	8d 90 44 84 12 c0    	lea    -0x3fed7bbc(%eax),%edx
c0100f9f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100fa2:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c0100fa4:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100fa8:	c1 e0 03             	shl    $0x3,%eax
c0100fab:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100fb2:	29 c2                	sub    %eax,%edx
c0100fb4:	89 d0                	mov    %edx,%eax
c0100fb6:	8d 90 48 84 12 c0    	lea    -0x3fed7bb8(%eax),%edx
c0100fbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100fbf:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0100fc1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100fc4:	83 c0 62             	add    $0x62,%eax
c0100fc7:	0f b7 00             	movzwl (%eax),%eax
c0100fca:	25 00 02 00 00       	and    $0x200,%eax
c0100fcf:	85 c0                	test   %eax,%eax
c0100fd1:	75 24                	jne    c0100ff7 <ide_init+0x1f8>
c0100fd3:	c7 44 24 0c dc a0 10 	movl   $0xc010a0dc,0xc(%esp)
c0100fda:	c0 
c0100fdb:	c7 44 24 08 1f a1 10 	movl   $0xc010a11f,0x8(%esp)
c0100fe2:	c0 
c0100fe3:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0100fea:	00 
c0100feb:	c7 04 24 34 a1 10 c0 	movl   $0xc010a134,(%esp)
c0100ff2:	e8 09 f4 ff ff       	call   c0100400 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0100ff7:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100ffb:	c1 e0 03             	shl    $0x3,%eax
c0100ffe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101005:	29 c2                	sub    %eax,%edx
c0101007:	8d 82 40 84 12 c0    	lea    -0x3fed7bc0(%edx),%eax
c010100d:	83 c0 0c             	add    $0xc,%eax
c0101010:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0101013:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101016:	83 c0 36             	add    $0x36,%eax
c0101019:	89 45 d0             	mov    %eax,-0x30(%ebp)
        unsigned int i, length = 40;
c010101c:	c7 45 cc 28 00 00 00 	movl   $0x28,-0x34(%ebp)
        for (i = 0; i < length; i += 2) {
c0101023:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010102a:	eb 34                	jmp    c0101060 <ide_init+0x261>
            model[i] = data[i + 1], model[i + 1] = data[i];
c010102c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010102f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101032:	01 c2                	add    %eax,%edx
c0101034:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101037:	8d 48 01             	lea    0x1(%eax),%ecx
c010103a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010103d:	01 c8                	add    %ecx,%eax
c010103f:	0f b6 00             	movzbl (%eax),%eax
c0101042:	88 02                	mov    %al,(%edx)
c0101044:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101047:	8d 50 01             	lea    0x1(%eax),%edx
c010104a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010104d:	01 c2                	add    %eax,%edx
c010104f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0101052:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101055:	01 c8                	add    %ecx,%eax
c0101057:	0f b6 00             	movzbl (%eax),%eax
c010105a:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c010105c:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101060:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101063:	3b 45 cc             	cmp    -0x34(%ebp),%eax
c0101066:	72 c4                	jb     c010102c <ide_init+0x22d>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c0101068:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010106b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010106e:	01 d0                	add    %edx,%eax
c0101070:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101073:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101076:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101079:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010107c:	85 c0                	test   %eax,%eax
c010107e:	74 0f                	je     c010108f <ide_init+0x290>
c0101080:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101083:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101086:	01 d0                	add    %edx,%eax
c0101088:	0f b6 00             	movzbl (%eax),%eax
c010108b:	3c 20                	cmp    $0x20,%al
c010108d:	74 d9                	je     c0101068 <ide_init+0x269>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c010108f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101093:	c1 e0 03             	shl    $0x3,%eax
c0101096:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010109d:	29 c2                	sub    %eax,%edx
c010109f:	8d 82 40 84 12 c0    	lea    -0x3fed7bc0(%edx),%eax
c01010a5:	8d 48 0c             	lea    0xc(%eax),%ecx
c01010a8:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010ac:	c1 e0 03             	shl    $0x3,%eax
c01010af:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01010b6:	29 c2                	sub    %eax,%edx
c01010b8:	89 d0                	mov    %edx,%eax
c01010ba:	05 48 84 12 c0       	add    $0xc0128448,%eax
c01010bf:	8b 10                	mov    (%eax),%edx
c01010c1:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010c5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01010c9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01010cd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01010d1:	c7 04 24 46 a1 10 c0 	movl   $0xc010a146,(%esp)
c01010d8:	e8 cc f1 ff ff       	call   c01002a9 <cprintf>
c01010dd:	eb 01                	jmp    c01010e0 <ide_init+0x2e1>
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
        ide_wait_ready(iobase, 0);

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
            continue ;
c01010df:	90                   	nop

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01010e0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010e4:	40                   	inc    %eax
c01010e5:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c01010e9:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010ed:	83 f8 03             	cmp    $0x3,%eax
c01010f0:	0f 86 1f fd ff ff    	jbe    c0100e15 <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c01010f6:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c01010fd:	e8 8a 0e 00 00       	call   c0101f8c <pic_enable>
    pic_enable(IRQ_IDE2);
c0101102:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101109:	e8 7e 0e 00 00       	call   c0101f8c <pic_enable>
}
c010110e:	90                   	nop
c010110f:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101115:	5b                   	pop    %ebx
c0101116:	5f                   	pop    %edi
c0101117:	5d                   	pop    %ebp
c0101118:	c3                   	ret    

c0101119 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101119:	55                   	push   %ebp
c010111a:	89 e5                	mov    %esp,%ebp
c010111c:	83 ec 04             	sub    $0x4,%esp
c010111f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101122:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101126:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c010112a:	83 f8 03             	cmp    $0x3,%eax
c010112d:	77 25                	ja     c0101154 <ide_device_valid+0x3b>
c010112f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101133:	c1 e0 03             	shl    $0x3,%eax
c0101136:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010113d:	29 c2                	sub    %eax,%edx
c010113f:	89 d0                	mov    %edx,%eax
c0101141:	05 40 84 12 c0       	add    $0xc0128440,%eax
c0101146:	0f b6 00             	movzbl (%eax),%eax
c0101149:	84 c0                	test   %al,%al
c010114b:	74 07                	je     c0101154 <ide_device_valid+0x3b>
c010114d:	b8 01 00 00 00       	mov    $0x1,%eax
c0101152:	eb 05                	jmp    c0101159 <ide_device_valid+0x40>
c0101154:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101159:	c9                   	leave  
c010115a:	c3                   	ret    

c010115b <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c010115b:	55                   	push   %ebp
c010115c:	89 e5                	mov    %esp,%ebp
c010115e:	83 ec 08             	sub    $0x8,%esp
c0101161:	8b 45 08             	mov    0x8(%ebp),%eax
c0101164:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101168:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c010116c:	89 04 24             	mov    %eax,(%esp)
c010116f:	e8 a5 ff ff ff       	call   c0101119 <ide_device_valid>
c0101174:	85 c0                	test   %eax,%eax
c0101176:	74 1b                	je     c0101193 <ide_device_size+0x38>
        return ide_devices[ideno].size;
c0101178:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c010117c:	c1 e0 03             	shl    $0x3,%eax
c010117f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101186:	29 c2                	sub    %eax,%edx
c0101188:	89 d0                	mov    %edx,%eax
c010118a:	05 48 84 12 c0       	add    $0xc0128448,%eax
c010118f:	8b 00                	mov    (%eax),%eax
c0101191:	eb 05                	jmp    c0101198 <ide_device_size+0x3d>
    }
    return 0;
c0101193:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101198:	c9                   	leave  
c0101199:	c3                   	ret    

c010119a <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c010119a:	55                   	push   %ebp
c010119b:	89 e5                	mov    %esp,%ebp
c010119d:	57                   	push   %edi
c010119e:	53                   	push   %ebx
c010119f:	83 ec 50             	sub    $0x50,%esp
c01011a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01011a5:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01011a9:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01011b0:	77 27                	ja     c01011d9 <ide_read_secs+0x3f>
c01011b2:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01011b6:	83 f8 03             	cmp    $0x3,%eax
c01011b9:	77 1e                	ja     c01011d9 <ide_read_secs+0x3f>
c01011bb:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01011bf:	c1 e0 03             	shl    $0x3,%eax
c01011c2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01011c9:	29 c2                	sub    %eax,%edx
c01011cb:	89 d0                	mov    %edx,%eax
c01011cd:	05 40 84 12 c0       	add    $0xc0128440,%eax
c01011d2:	0f b6 00             	movzbl (%eax),%eax
c01011d5:	84 c0                	test   %al,%al
c01011d7:	75 24                	jne    c01011fd <ide_read_secs+0x63>
c01011d9:	c7 44 24 0c 64 a1 10 	movl   $0xc010a164,0xc(%esp)
c01011e0:	c0 
c01011e1:	c7 44 24 08 1f a1 10 	movl   $0xc010a11f,0x8(%esp)
c01011e8:	c0 
c01011e9:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c01011f0:	00 
c01011f1:	c7 04 24 34 a1 10 c0 	movl   $0xc010a134,(%esp)
c01011f8:	e8 03 f2 ff ff       	call   c0100400 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c01011fd:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101204:	77 0f                	ja     c0101215 <ide_read_secs+0x7b>
c0101206:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101209:	8b 45 14             	mov    0x14(%ebp),%eax
c010120c:	01 d0                	add    %edx,%eax
c010120e:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101213:	76 24                	jbe    c0101239 <ide_read_secs+0x9f>
c0101215:	c7 44 24 0c 8c a1 10 	movl   $0xc010a18c,0xc(%esp)
c010121c:	c0 
c010121d:	c7 44 24 08 1f a1 10 	movl   $0xc010a11f,0x8(%esp)
c0101224:	c0 
c0101225:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c010122c:	00 
c010122d:	c7 04 24 34 a1 10 c0 	movl   $0xc010a134,(%esp)
c0101234:	e8 c7 f1 ff ff       	call   c0100400 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101239:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010123d:	d1 e8                	shr    %eax
c010123f:	0f b7 c0             	movzwl %ax,%eax
c0101242:	8b 04 85 d4 a0 10 c0 	mov    -0x3fef5f2c(,%eax,4),%eax
c0101249:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010124d:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101251:	d1 e8                	shr    %eax
c0101253:	0f b7 c0             	movzwl %ax,%eax
c0101256:	0f b7 04 85 d6 a0 10 	movzwl -0x3fef5f2a(,%eax,4),%eax
c010125d:	c0 
c010125e:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101262:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101266:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010126d:	00 
c010126e:	89 04 24             	mov    %eax,(%esp)
c0101271:	e8 30 fb ff ff       	call   c0100da6 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101276:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101279:	83 c0 02             	add    $0x2,%eax
c010127c:	0f b7 c0             	movzwl %ax,%eax
c010127f:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0101283:	c6 45 d7 00          	movb   $0x0,-0x29(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101287:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c010128b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010128f:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101290:	8b 45 14             	mov    0x14(%ebp),%eax
c0101293:	0f b6 c0             	movzbl %al,%eax
c0101296:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010129a:	83 c2 02             	add    $0x2,%edx
c010129d:	0f b7 d2             	movzwl %dx,%edx
c01012a0:	66 89 55 e8          	mov    %dx,-0x18(%ebp)
c01012a4:	88 45 d8             	mov    %al,-0x28(%ebp)
c01012a7:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c01012ab:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01012ae:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01012af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012b2:	0f b6 c0             	movzbl %al,%eax
c01012b5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012b9:	83 c2 03             	add    $0x3,%edx
c01012bc:	0f b7 d2             	movzwl %dx,%edx
c01012bf:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012c3:	88 45 d9             	mov    %al,-0x27(%ebp)
c01012c6:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01012ca:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012ce:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01012cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012d2:	c1 e8 08             	shr    $0x8,%eax
c01012d5:	0f b6 c0             	movzbl %al,%eax
c01012d8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012dc:	83 c2 04             	add    $0x4,%edx
c01012df:	0f b7 d2             	movzwl %dx,%edx
c01012e2:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
c01012e6:	88 45 da             	mov    %al,-0x26(%ebp)
c01012e9:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01012ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01012f0:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c01012f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012f4:	c1 e8 10             	shr    $0x10,%eax
c01012f7:	0f b6 c0             	movzbl %al,%eax
c01012fa:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012fe:	83 c2 05             	add    $0x5,%edx
c0101301:	0f b7 d2             	movzwl %dx,%edx
c0101304:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101308:	88 45 db             	mov    %al,-0x25(%ebp)
c010130b:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c010130f:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101313:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101314:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101317:	24 01                	and    $0x1,%al
c0101319:	c0 e0 04             	shl    $0x4,%al
c010131c:	88 c2                	mov    %al,%dl
c010131e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101321:	c1 e8 18             	shr    $0x18,%eax
c0101324:	24 0f                	and    $0xf,%al
c0101326:	08 d0                	or     %dl,%al
c0101328:	0c e0                	or     $0xe0,%al
c010132a:	0f b6 c0             	movzbl %al,%eax
c010132d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101331:	83 c2 06             	add    $0x6,%edx
c0101334:	0f b7 d2             	movzwl %dx,%edx
c0101337:	66 89 55 e0          	mov    %dx,-0x20(%ebp)
c010133b:	88 45 dc             	mov    %al,-0x24(%ebp)
c010133e:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0101342:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0101345:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101346:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010134a:	83 c0 07             	add    $0x7,%eax
c010134d:	0f b7 c0             	movzwl %ax,%eax
c0101350:	66 89 45 de          	mov    %ax,-0x22(%ebp)
c0101354:	c6 45 dd 20          	movb   $0x20,-0x23(%ebp)
c0101358:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010135c:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101360:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101361:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101368:	eb 57                	jmp    c01013c1 <ide_read_secs+0x227>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c010136a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010136e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101375:	00 
c0101376:	89 04 24             	mov    %eax,(%esp)
c0101379:	e8 28 fa ff ff       	call   c0100da6 <ide_wait_ready>
c010137e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101381:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101385:	75 42                	jne    c01013c9 <ide_read_secs+0x22f>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101387:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010138b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010138e:	8b 45 10             	mov    0x10(%ebp),%eax
c0101391:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101394:	c7 45 cc 80 00 00 00 	movl   $0x80,-0x34(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c010139b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010139e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01013a1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01013a4:	89 cb                	mov    %ecx,%ebx
c01013a6:	89 df                	mov    %ebx,%edi
c01013a8:	89 c1                	mov    %eax,%ecx
c01013aa:	fc                   	cld    
c01013ab:	f2 6d                	repnz insl (%dx),%es:(%edi)
c01013ad:	89 c8                	mov    %ecx,%eax
c01013af:	89 fb                	mov    %edi,%ebx
c01013b1:	89 5d d0             	mov    %ebx,-0x30(%ebp)
c01013b4:	89 45 cc             	mov    %eax,-0x34(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c01013b7:	ff 4d 14             	decl   0x14(%ebp)
c01013ba:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01013c1:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01013c5:	75 a3                	jne    c010136a <ide_read_secs+0x1d0>
c01013c7:	eb 01                	jmp    c01013ca <ide_read_secs+0x230>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
            goto out;
c01013c9:	90                   	nop
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c01013ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01013cd:	83 c4 50             	add    $0x50,%esp
c01013d0:	5b                   	pop    %ebx
c01013d1:	5f                   	pop    %edi
c01013d2:	5d                   	pop    %ebp
c01013d3:	c3                   	ret    

c01013d4 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c01013d4:	55                   	push   %ebp
c01013d5:	89 e5                	mov    %esp,%ebp
c01013d7:	56                   	push   %esi
c01013d8:	53                   	push   %ebx
c01013d9:	83 ec 50             	sub    $0x50,%esp
c01013dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01013df:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01013e3:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01013ea:	77 27                	ja     c0101413 <ide_write_secs+0x3f>
c01013ec:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01013f0:	83 f8 03             	cmp    $0x3,%eax
c01013f3:	77 1e                	ja     c0101413 <ide_write_secs+0x3f>
c01013f5:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01013f9:	c1 e0 03             	shl    $0x3,%eax
c01013fc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101403:	29 c2                	sub    %eax,%edx
c0101405:	89 d0                	mov    %edx,%eax
c0101407:	05 40 84 12 c0       	add    $0xc0128440,%eax
c010140c:	0f b6 00             	movzbl (%eax),%eax
c010140f:	84 c0                	test   %al,%al
c0101411:	75 24                	jne    c0101437 <ide_write_secs+0x63>
c0101413:	c7 44 24 0c 64 a1 10 	movl   $0xc010a164,0xc(%esp)
c010141a:	c0 
c010141b:	c7 44 24 08 1f a1 10 	movl   $0xc010a11f,0x8(%esp)
c0101422:	c0 
c0101423:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c010142a:	00 
c010142b:	c7 04 24 34 a1 10 c0 	movl   $0xc010a134,(%esp)
c0101432:	e8 c9 ef ff ff       	call   c0100400 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101437:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c010143e:	77 0f                	ja     c010144f <ide_write_secs+0x7b>
c0101440:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101443:	8b 45 14             	mov    0x14(%ebp),%eax
c0101446:	01 d0                	add    %edx,%eax
c0101448:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c010144d:	76 24                	jbe    c0101473 <ide_write_secs+0x9f>
c010144f:	c7 44 24 0c 8c a1 10 	movl   $0xc010a18c,0xc(%esp)
c0101456:	c0 
c0101457:	c7 44 24 08 1f a1 10 	movl   $0xc010a11f,0x8(%esp)
c010145e:	c0 
c010145f:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101466:	00 
c0101467:	c7 04 24 34 a1 10 c0 	movl   $0xc010a134,(%esp)
c010146e:	e8 8d ef ff ff       	call   c0100400 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101473:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101477:	d1 e8                	shr    %eax
c0101479:	0f b7 c0             	movzwl %ax,%eax
c010147c:	8b 04 85 d4 a0 10 c0 	mov    -0x3fef5f2c(,%eax,4),%eax
c0101483:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101487:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010148b:	d1 e8                	shr    %eax
c010148d:	0f b7 c0             	movzwl %ax,%eax
c0101490:	0f b7 04 85 d6 a0 10 	movzwl -0x3fef5f2a(,%eax,4),%eax
c0101497:	c0 
c0101498:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c010149c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01014a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01014a7:	00 
c01014a8:	89 04 24             	mov    %eax,(%esp)
c01014ab:	e8 f6 f8 ff ff       	call   c0100da6 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c01014b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01014b3:	83 c0 02             	add    $0x2,%eax
c01014b6:	0f b7 c0             	movzwl %ax,%eax
c01014b9:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01014bd:	c6 45 d7 00          	movb   $0x0,-0x29(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01014c1:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c01014c5:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01014c9:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01014ca:	8b 45 14             	mov    0x14(%ebp),%eax
c01014cd:	0f b6 c0             	movzbl %al,%eax
c01014d0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01014d4:	83 c2 02             	add    $0x2,%edx
c01014d7:	0f b7 d2             	movzwl %dx,%edx
c01014da:	66 89 55 e8          	mov    %dx,-0x18(%ebp)
c01014de:	88 45 d8             	mov    %al,-0x28(%ebp)
c01014e1:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c01014e5:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01014e8:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01014e9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01014ec:	0f b6 c0             	movzbl %al,%eax
c01014ef:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01014f3:	83 c2 03             	add    $0x3,%edx
c01014f6:	0f b7 d2             	movzwl %dx,%edx
c01014f9:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01014fd:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101500:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101504:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101508:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101509:	8b 45 0c             	mov    0xc(%ebp),%eax
c010150c:	c1 e8 08             	shr    $0x8,%eax
c010150f:	0f b6 c0             	movzbl %al,%eax
c0101512:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101516:	83 c2 04             	add    $0x4,%edx
c0101519:	0f b7 d2             	movzwl %dx,%edx
c010151c:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
c0101520:	88 45 da             	mov    %al,-0x26(%ebp)
c0101523:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c0101527:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010152a:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c010152b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010152e:	c1 e8 10             	shr    $0x10,%eax
c0101531:	0f b6 c0             	movzbl %al,%eax
c0101534:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101538:	83 c2 05             	add    $0x5,%edx
c010153b:	0f b7 d2             	movzwl %dx,%edx
c010153e:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101542:	88 45 db             	mov    %al,-0x25(%ebp)
c0101545:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0101549:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010154d:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c010154e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101551:	24 01                	and    $0x1,%al
c0101553:	c0 e0 04             	shl    $0x4,%al
c0101556:	88 c2                	mov    %al,%dl
c0101558:	8b 45 0c             	mov    0xc(%ebp),%eax
c010155b:	c1 e8 18             	shr    $0x18,%eax
c010155e:	24 0f                	and    $0xf,%al
c0101560:	08 d0                	or     %dl,%al
c0101562:	0c e0                	or     $0xe0,%al
c0101564:	0f b6 c0             	movzbl %al,%eax
c0101567:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010156b:	83 c2 06             	add    $0x6,%edx
c010156e:	0f b7 d2             	movzwl %dx,%edx
c0101571:	66 89 55 e0          	mov    %dx,-0x20(%ebp)
c0101575:	88 45 dc             	mov    %al,-0x24(%ebp)
c0101578:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c010157c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010157f:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101580:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101584:	83 c0 07             	add    $0x7,%eax
c0101587:	0f b7 c0             	movzwl %ax,%eax
c010158a:	66 89 45 de          	mov    %ax,-0x22(%ebp)
c010158e:	c6 45 dd 30          	movb   $0x30,-0x23(%ebp)
c0101592:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101596:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010159a:	ee                   	out    %al,(%dx)

    int ret = 0;
c010159b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01015a2:	eb 57                	jmp    c01015fb <ide_write_secs+0x227>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c01015a4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01015a8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01015af:	00 
c01015b0:	89 04 24             	mov    %eax,(%esp)
c01015b3:	e8 ee f7 ff ff       	call   c0100da6 <ide_wait_ready>
c01015b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01015bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01015bf:	75 42                	jne    c0101603 <ide_write_secs+0x22f>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c01015c1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01015c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01015c8:	8b 45 10             	mov    0x10(%ebp),%eax
c01015cb:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01015ce:	c7 45 cc 80 00 00 00 	movl   $0x80,-0x34(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c01015d5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01015d8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01015db:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01015de:	89 cb                	mov    %ecx,%ebx
c01015e0:	89 de                	mov    %ebx,%esi
c01015e2:	89 c1                	mov    %eax,%ecx
c01015e4:	fc                   	cld    
c01015e5:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c01015e7:	89 c8                	mov    %ecx,%eax
c01015e9:	89 f3                	mov    %esi,%ebx
c01015eb:	89 5d d0             	mov    %ebx,-0x30(%ebp)
c01015ee:	89 45 cc             	mov    %eax,-0x34(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01015f1:	ff 4d 14             	decl   0x14(%ebp)
c01015f4:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01015fb:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01015ff:	75 a3                	jne    c01015a4 <ide_write_secs+0x1d0>
c0101601:	eb 01                	jmp    c0101604 <ide_write_secs+0x230>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
            goto out;
c0101603:	90                   	nop
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0101604:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101607:	83 c4 50             	add    $0x50,%esp
c010160a:	5b                   	pop    %ebx
c010160b:	5e                   	pop    %esi
c010160c:	5d                   	pop    %ebp
c010160d:	c3                   	ret    

c010160e <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c010160e:	55                   	push   %ebp
c010160f:	89 e5                	mov    %esp,%ebp
c0101611:	83 ec 28             	sub    $0x28,%esp
c0101614:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c010161a:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010161e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
c0101622:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101626:	ee                   	out    %al,(%dx)
c0101627:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
c010162d:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
c0101631:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0101635:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101638:	ee                   	out    %al,(%dx)
c0101639:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c010163f:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
c0101643:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101647:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010164b:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c010164c:	c7 05 54 b0 12 c0 00 	movl   $0x0,0xc012b054
c0101653:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0101656:	c7 04 24 c6 a1 10 c0 	movl   $0xc010a1c6,(%esp)
c010165d:	e8 47 ec ff ff       	call   c01002a9 <cprintf>
    pic_enable(IRQ_TIMER);
c0101662:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0101669:	e8 1e 09 00 00       	call   c0101f8c <pic_enable>
}
c010166e:	90                   	nop
c010166f:	c9                   	leave  
c0101670:	c3                   	ret    

c0101671 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0101671:	55                   	push   %ebp
c0101672:	89 e5                	mov    %esp,%ebp
c0101674:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0101677:	9c                   	pushf  
c0101678:	58                   	pop    %eax
c0101679:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010167c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010167f:	25 00 02 00 00       	and    $0x200,%eax
c0101684:	85 c0                	test   %eax,%eax
c0101686:	74 0c                	je     c0101694 <__intr_save+0x23>
        intr_disable();
c0101688:	e8 6c 0a 00 00       	call   c01020f9 <intr_disable>
        return 1;
c010168d:	b8 01 00 00 00       	mov    $0x1,%eax
c0101692:	eb 05                	jmp    c0101699 <__intr_save+0x28>
    }
    return 0;
c0101694:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101699:	c9                   	leave  
c010169a:	c3                   	ret    

c010169b <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010169b:	55                   	push   %ebp
c010169c:	89 e5                	mov    %esp,%ebp
c010169e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01016a1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01016a5:	74 05                	je     c01016ac <__intr_restore+0x11>
        intr_enable();
c01016a7:	e8 46 0a 00 00       	call   c01020f2 <intr_enable>
    }
}
c01016ac:	90                   	nop
c01016ad:	c9                   	leave  
c01016ae:	c3                   	ret    

c01016af <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c01016af:	55                   	push   %ebp
c01016b0:	89 e5                	mov    %esp,%ebp
c01016b2:	83 ec 10             	sub    $0x10,%esp
c01016b5:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01016bb:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01016bf:	89 c2                	mov    %eax,%edx
c01016c1:	ec                   	in     (%dx),%al
c01016c2:	88 45 f4             	mov    %al,-0xc(%ebp)
c01016c5:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
c01016cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016ce:	89 c2                	mov    %eax,%edx
c01016d0:	ec                   	in     (%dx),%al
c01016d1:	88 45 f5             	mov    %al,-0xb(%ebp)
c01016d4:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c01016da:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01016de:	89 c2                	mov    %eax,%edx
c01016e0:	ec                   	in     (%dx),%al
c01016e1:	88 45 f6             	mov    %al,-0xa(%ebp)
c01016e4:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
c01016ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01016ed:	89 c2                	mov    %eax,%edx
c01016ef:	ec                   	in     (%dx),%al
c01016f0:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c01016f3:	90                   	nop
c01016f4:	c9                   	leave  
c01016f5:	c3                   	ret    

c01016f6 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c01016f6:	55                   	push   %ebp
c01016f7:	89 e5                	mov    %esp,%ebp
c01016f9:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c01016fc:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0101703:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101706:	0f b7 00             	movzwl (%eax),%eax
c0101709:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c010170d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101710:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0101715:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101718:	0f b7 00             	movzwl (%eax),%eax
c010171b:	0f b7 c0             	movzwl %ax,%eax
c010171e:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0101723:	74 12                	je     c0101737 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0101725:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c010172c:	66 c7 05 26 85 12 c0 	movw   $0x3b4,0xc0128526
c0101733:	b4 03 
c0101735:	eb 13                	jmp    c010174a <cga_init+0x54>
    } else {
        *cp = was;
c0101737:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010173a:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010173e:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0101741:	66 c7 05 26 85 12 c0 	movw   $0x3d4,0xc0128526
c0101748:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c010174a:	0f b7 05 26 85 12 c0 	movzwl 0xc0128526,%eax
c0101751:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
c0101755:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101759:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c010175d:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0101760:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0101761:	0f b7 05 26 85 12 c0 	movzwl 0xc0128526,%eax
c0101768:	40                   	inc    %eax
c0101769:	0f b7 c0             	movzwl %ax,%eax
c010176c:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101770:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101774:	89 c2                	mov    %eax,%edx
c0101776:	ec                   	in     (%dx),%al
c0101777:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c010177a:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c010177e:	0f b6 c0             	movzbl %al,%eax
c0101781:	c1 e0 08             	shl    $0x8,%eax
c0101784:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0101787:	0f b7 05 26 85 12 c0 	movzwl 0xc0128526,%eax
c010178e:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
c0101792:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101796:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
c010179a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010179d:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c010179e:	0f b7 05 26 85 12 c0 	movzwl 0xc0128526,%eax
c01017a5:	40                   	inc    %eax
c01017a6:	0f b7 c0             	movzwl %ax,%eax
c01017a9:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01017ad:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c01017b1:	89 c2                	mov    %eax,%edx
c01017b3:	ec                   	in     (%dx),%al
c01017b4:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c01017b7:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01017bb:	0f b6 c0             	movzbl %al,%eax
c01017be:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c01017c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017c4:	a3 20 85 12 c0       	mov    %eax,0xc0128520
    crt_pos = pos;
c01017c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01017cc:	0f b7 c0             	movzwl %ax,%eax
c01017cf:	66 a3 24 85 12 c0    	mov    %ax,0xc0128524
}
c01017d5:	90                   	nop
c01017d6:	c9                   	leave  
c01017d7:	c3                   	ret    

c01017d8 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c01017d8:	55                   	push   %ebp
c01017d9:	89 e5                	mov    %esp,%ebp
c01017db:	83 ec 38             	sub    $0x38,%esp
c01017de:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c01017e4:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017e8:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01017ec:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017f0:	ee                   	out    %al,(%dx)
c01017f1:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
c01017f7:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
c01017fb:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c01017ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101802:	ee                   	out    %al,(%dx)
c0101803:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
c0101809:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
c010180d:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0101811:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101815:	ee                   	out    %al,(%dx)
c0101816:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
c010181c:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0101820:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101824:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101827:	ee                   	out    %al,(%dx)
c0101828:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
c010182e:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
c0101832:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c0101836:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010183a:	ee                   	out    %al,(%dx)
c010183b:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
c0101841:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
c0101845:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0101849:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010184c:	ee                   	out    %al,(%dx)
c010184d:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101853:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
c0101857:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c010185b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010185f:	ee                   	out    %al,(%dx)
c0101860:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101866:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101869:	89 c2                	mov    %eax,%edx
c010186b:	ec                   	in     (%dx),%al
c010186c:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
c010186f:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101873:	3c ff                	cmp    $0xff,%al
c0101875:	0f 95 c0             	setne  %al
c0101878:	0f b6 c0             	movzbl %al,%eax
c010187b:	a3 28 85 12 c0       	mov    %eax,0xc0128528
c0101880:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101886:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c010188a:	89 c2                	mov    %eax,%edx
c010188c:	ec                   	in     (%dx),%al
c010188d:	88 45 e2             	mov    %al,-0x1e(%ebp)
c0101890:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
c0101896:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101899:	89 c2                	mov    %eax,%edx
c010189b:	ec                   	in     (%dx),%al
c010189c:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c010189f:	a1 28 85 12 c0       	mov    0xc0128528,%eax
c01018a4:	85 c0                	test   %eax,%eax
c01018a6:	74 0c                	je     c01018b4 <serial_init+0xdc>
        pic_enable(IRQ_COM1);
c01018a8:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01018af:	e8 d8 06 00 00       	call   c0101f8c <pic_enable>
    }
}
c01018b4:	90                   	nop
c01018b5:	c9                   	leave  
c01018b6:	c3                   	ret    

c01018b7 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01018b7:	55                   	push   %ebp
c01018b8:	89 e5                	mov    %esp,%ebp
c01018ba:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01018bd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018c4:	eb 08                	jmp    c01018ce <lpt_putc_sub+0x17>
        delay();
c01018c6:	e8 e4 fd ff ff       	call   c01016af <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01018cb:	ff 45 fc             	incl   -0x4(%ebp)
c01018ce:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
c01018d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01018d7:	89 c2                	mov    %eax,%edx
c01018d9:	ec                   	in     (%dx),%al
c01018da:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
c01018dd:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01018e1:	84 c0                	test   %al,%al
c01018e3:	78 09                	js     c01018ee <lpt_putc_sub+0x37>
c01018e5:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01018ec:	7e d8                	jle    c01018c6 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c01018ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01018f1:	0f b6 c0             	movzbl %al,%eax
c01018f4:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
c01018fa:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018fd:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0101901:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0101904:	ee                   	out    %al,(%dx)
c0101905:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c010190b:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c010190f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101913:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101917:	ee                   	out    %al,(%dx)
c0101918:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
c010191e:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
c0101922:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
c0101926:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010192a:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c010192b:	90                   	nop
c010192c:	c9                   	leave  
c010192d:	c3                   	ret    

c010192e <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c010192e:	55                   	push   %ebp
c010192f:	89 e5                	mov    %esp,%ebp
c0101931:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101934:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101938:	74 0d                	je     c0101947 <lpt_putc+0x19>
        lpt_putc_sub(c);
c010193a:	8b 45 08             	mov    0x8(%ebp),%eax
c010193d:	89 04 24             	mov    %eax,(%esp)
c0101940:	e8 72 ff ff ff       	call   c01018b7 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c0101945:	eb 24                	jmp    c010196b <lpt_putc+0x3d>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
c0101947:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010194e:	e8 64 ff ff ff       	call   c01018b7 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101953:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010195a:	e8 58 ff ff ff       	call   c01018b7 <lpt_putc_sub>
        lpt_putc_sub('\b');
c010195f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101966:	e8 4c ff ff ff       	call   c01018b7 <lpt_putc_sub>
    }
}
c010196b:	90                   	nop
c010196c:	c9                   	leave  
c010196d:	c3                   	ret    

c010196e <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c010196e:	55                   	push   %ebp
c010196f:	89 e5                	mov    %esp,%ebp
c0101971:	53                   	push   %ebx
c0101972:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101975:	8b 45 08             	mov    0x8(%ebp),%eax
c0101978:	25 00 ff ff ff       	and    $0xffffff00,%eax
c010197d:	85 c0                	test   %eax,%eax
c010197f:	75 07                	jne    c0101988 <cga_putc+0x1a>
        c |= 0x0700;
c0101981:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101988:	8b 45 08             	mov    0x8(%ebp),%eax
c010198b:	0f b6 c0             	movzbl %al,%eax
c010198e:	83 f8 0a             	cmp    $0xa,%eax
c0101991:	74 54                	je     c01019e7 <cga_putc+0x79>
c0101993:	83 f8 0d             	cmp    $0xd,%eax
c0101996:	74 62                	je     c01019fa <cga_putc+0x8c>
c0101998:	83 f8 08             	cmp    $0x8,%eax
c010199b:	0f 85 93 00 00 00    	jne    c0101a34 <cga_putc+0xc6>
    case '\b':
        if (crt_pos > 0) {
c01019a1:	0f b7 05 24 85 12 c0 	movzwl 0xc0128524,%eax
c01019a8:	85 c0                	test   %eax,%eax
c01019aa:	0f 84 ae 00 00 00    	je     c0101a5e <cga_putc+0xf0>
            crt_pos --;
c01019b0:	0f b7 05 24 85 12 c0 	movzwl 0xc0128524,%eax
c01019b7:	48                   	dec    %eax
c01019b8:	0f b7 c0             	movzwl %ax,%eax
c01019bb:	66 a3 24 85 12 c0    	mov    %ax,0xc0128524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01019c1:	a1 20 85 12 c0       	mov    0xc0128520,%eax
c01019c6:	0f b7 15 24 85 12 c0 	movzwl 0xc0128524,%edx
c01019cd:	01 d2                	add    %edx,%edx
c01019cf:	01 c2                	add    %eax,%edx
c01019d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01019d4:	98                   	cwtl   
c01019d5:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01019da:	98                   	cwtl   
c01019db:	83 c8 20             	or     $0x20,%eax
c01019de:	98                   	cwtl   
c01019df:	0f b7 c0             	movzwl %ax,%eax
c01019e2:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01019e5:	eb 77                	jmp    c0101a5e <cga_putc+0xf0>
    case '\n':
        crt_pos += CRT_COLS;
c01019e7:	0f b7 05 24 85 12 c0 	movzwl 0xc0128524,%eax
c01019ee:	83 c0 50             	add    $0x50,%eax
c01019f1:	0f b7 c0             	movzwl %ax,%eax
c01019f4:	66 a3 24 85 12 c0    	mov    %ax,0xc0128524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01019fa:	0f b7 1d 24 85 12 c0 	movzwl 0xc0128524,%ebx
c0101a01:	0f b7 0d 24 85 12 c0 	movzwl 0xc0128524,%ecx
c0101a08:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c0101a0d:	89 c8                	mov    %ecx,%eax
c0101a0f:	f7 e2                	mul    %edx
c0101a11:	c1 ea 06             	shr    $0x6,%edx
c0101a14:	89 d0                	mov    %edx,%eax
c0101a16:	c1 e0 02             	shl    $0x2,%eax
c0101a19:	01 d0                	add    %edx,%eax
c0101a1b:	c1 e0 04             	shl    $0x4,%eax
c0101a1e:	29 c1                	sub    %eax,%ecx
c0101a20:	89 c8                	mov    %ecx,%eax
c0101a22:	0f b7 c0             	movzwl %ax,%eax
c0101a25:	29 c3                	sub    %eax,%ebx
c0101a27:	89 d8                	mov    %ebx,%eax
c0101a29:	0f b7 c0             	movzwl %ax,%eax
c0101a2c:	66 a3 24 85 12 c0    	mov    %ax,0xc0128524
        break;
c0101a32:	eb 2b                	jmp    c0101a5f <cga_putc+0xf1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101a34:	8b 0d 20 85 12 c0    	mov    0xc0128520,%ecx
c0101a3a:	0f b7 05 24 85 12 c0 	movzwl 0xc0128524,%eax
c0101a41:	8d 50 01             	lea    0x1(%eax),%edx
c0101a44:	0f b7 d2             	movzwl %dx,%edx
c0101a47:	66 89 15 24 85 12 c0 	mov    %dx,0xc0128524
c0101a4e:	01 c0                	add    %eax,%eax
c0101a50:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101a53:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a56:	0f b7 c0             	movzwl %ax,%eax
c0101a59:	66 89 02             	mov    %ax,(%edx)
        break;
c0101a5c:	eb 01                	jmp    c0101a5f <cga_putc+0xf1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
c0101a5e:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101a5f:	0f b7 05 24 85 12 c0 	movzwl 0xc0128524,%eax
c0101a66:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101a6b:	76 5d                	jbe    c0101aca <cga_putc+0x15c>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101a6d:	a1 20 85 12 c0       	mov    0xc0128520,%eax
c0101a72:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101a78:	a1 20 85 12 c0       	mov    0xc0128520,%eax
c0101a7d:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101a84:	00 
c0101a85:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101a89:	89 04 24             	mov    %eax,(%esp)
c0101a8c:	e8 62 7a 00 00       	call   c01094f3 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101a91:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101a98:	eb 14                	jmp    c0101aae <cga_putc+0x140>
            crt_buf[i] = 0x0700 | ' ';
c0101a9a:	a1 20 85 12 c0       	mov    0xc0128520,%eax
c0101a9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101aa2:	01 d2                	add    %edx,%edx
c0101aa4:	01 d0                	add    %edx,%eax
c0101aa6:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101aab:	ff 45 f4             	incl   -0xc(%ebp)
c0101aae:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101ab5:	7e e3                	jle    c0101a9a <cga_putc+0x12c>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101ab7:	0f b7 05 24 85 12 c0 	movzwl 0xc0128524,%eax
c0101abe:	83 e8 50             	sub    $0x50,%eax
c0101ac1:	0f b7 c0             	movzwl %ax,%eax
c0101ac4:	66 a3 24 85 12 c0    	mov    %ax,0xc0128524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101aca:	0f b7 05 26 85 12 c0 	movzwl 0xc0128526,%eax
c0101ad1:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101ad5:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
c0101ad9:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
c0101add:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ae1:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101ae2:	0f b7 05 24 85 12 c0 	movzwl 0xc0128524,%eax
c0101ae9:	c1 e8 08             	shr    $0x8,%eax
c0101aec:	0f b7 c0             	movzwl %ax,%eax
c0101aef:	0f b6 c0             	movzbl %al,%eax
c0101af2:	0f b7 15 26 85 12 c0 	movzwl 0xc0128526,%edx
c0101af9:	42                   	inc    %edx
c0101afa:	0f b7 d2             	movzwl %dx,%edx
c0101afd:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
c0101b01:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101b04:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101b08:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101b0b:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101b0c:	0f b7 05 26 85 12 c0 	movzwl 0xc0128526,%eax
c0101b13:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101b17:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
c0101b1b:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0101b1f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101b23:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0101b24:	0f b7 05 24 85 12 c0 	movzwl 0xc0128524,%eax
c0101b2b:	0f b6 c0             	movzbl %al,%eax
c0101b2e:	0f b7 15 26 85 12 c0 	movzwl 0xc0128526,%edx
c0101b35:	42                   	inc    %edx
c0101b36:	0f b7 d2             	movzwl %dx,%edx
c0101b39:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
c0101b3d:	88 45 eb             	mov    %al,-0x15(%ebp)
c0101b40:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0101b44:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101b47:	ee                   	out    %al,(%dx)
}
c0101b48:	90                   	nop
c0101b49:	83 c4 24             	add    $0x24,%esp
c0101b4c:	5b                   	pop    %ebx
c0101b4d:	5d                   	pop    %ebp
c0101b4e:	c3                   	ret    

c0101b4f <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101b4f:	55                   	push   %ebp
c0101b50:	89 e5                	mov    %esp,%ebp
c0101b52:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101b55:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101b5c:	eb 08                	jmp    c0101b66 <serial_putc_sub+0x17>
        delay();
c0101b5e:	e8 4c fb ff ff       	call   c01016af <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101b63:	ff 45 fc             	incl   -0x4(%ebp)
c0101b66:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101b6c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101b6f:	89 c2                	mov    %eax,%edx
c0101b71:	ec                   	in     (%dx),%al
c0101b72:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c0101b75:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0101b79:	0f b6 c0             	movzbl %al,%eax
c0101b7c:	83 e0 20             	and    $0x20,%eax
c0101b7f:	85 c0                	test   %eax,%eax
c0101b81:	75 09                	jne    c0101b8c <serial_putc_sub+0x3d>
c0101b83:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101b8a:	7e d2                	jle    c0101b5e <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101b8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b8f:	0f b6 c0             	movzbl %al,%eax
c0101b92:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
c0101b98:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101b9b:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
c0101b9f:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101ba3:	ee                   	out    %al,(%dx)
}
c0101ba4:	90                   	nop
c0101ba5:	c9                   	leave  
c0101ba6:	c3                   	ret    

c0101ba7 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101ba7:	55                   	push   %ebp
c0101ba8:	89 e5                	mov    %esp,%ebp
c0101baa:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101bad:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101bb1:	74 0d                	je     c0101bc0 <serial_putc+0x19>
        serial_putc_sub(c);
c0101bb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bb6:	89 04 24             	mov    %eax,(%esp)
c0101bb9:	e8 91 ff ff ff       	call   c0101b4f <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101bbe:	eb 24                	jmp    c0101be4 <serial_putc+0x3d>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
c0101bc0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101bc7:	e8 83 ff ff ff       	call   c0101b4f <serial_putc_sub>
        serial_putc_sub(' ');
c0101bcc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101bd3:	e8 77 ff ff ff       	call   c0101b4f <serial_putc_sub>
        serial_putc_sub('\b');
c0101bd8:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101bdf:	e8 6b ff ff ff       	call   c0101b4f <serial_putc_sub>
    }
}
c0101be4:	90                   	nop
c0101be5:	c9                   	leave  
c0101be6:	c3                   	ret    

c0101be7 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101be7:	55                   	push   %ebp
c0101be8:	89 e5                	mov    %esp,%ebp
c0101bea:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101bed:	eb 33                	jmp    c0101c22 <cons_intr+0x3b>
        if (c != 0) {
c0101bef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101bf3:	74 2d                	je     c0101c22 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101bf5:	a1 44 87 12 c0       	mov    0xc0128744,%eax
c0101bfa:	8d 50 01             	lea    0x1(%eax),%edx
c0101bfd:	89 15 44 87 12 c0    	mov    %edx,0xc0128744
c0101c03:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101c06:	88 90 40 85 12 c0    	mov    %dl,-0x3fed7ac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101c0c:	a1 44 87 12 c0       	mov    0xc0128744,%eax
c0101c11:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101c16:	75 0a                	jne    c0101c22 <cons_intr+0x3b>
                cons.wpos = 0;
c0101c18:	c7 05 44 87 12 c0 00 	movl   $0x0,0xc0128744
c0101c1f:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c0101c22:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c25:	ff d0                	call   *%eax
c0101c27:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101c2a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101c2e:	75 bf                	jne    c0101bef <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c0101c30:	90                   	nop
c0101c31:	c9                   	leave  
c0101c32:	c3                   	ret    

c0101c33 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101c33:	55                   	push   %ebp
c0101c34:	89 e5                	mov    %esp,%ebp
c0101c36:	83 ec 10             	sub    $0x10,%esp
c0101c39:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c3f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101c42:	89 c2                	mov    %eax,%edx
c0101c44:	ec                   	in     (%dx),%al
c0101c45:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c0101c48:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101c4c:	0f b6 c0             	movzbl %al,%eax
c0101c4f:	83 e0 01             	and    $0x1,%eax
c0101c52:	85 c0                	test   %eax,%eax
c0101c54:	75 07                	jne    c0101c5d <serial_proc_data+0x2a>
        return -1;
c0101c56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101c5b:	eb 2a                	jmp    c0101c87 <serial_proc_data+0x54>
c0101c5d:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c63:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101c67:	89 c2                	mov    %eax,%edx
c0101c69:	ec                   	in     (%dx),%al
c0101c6a:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
c0101c6d:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101c71:	0f b6 c0             	movzbl %al,%eax
c0101c74:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101c77:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101c7b:	75 07                	jne    c0101c84 <serial_proc_data+0x51>
        c = '\b';
c0101c7d:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101c84:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101c87:	c9                   	leave  
c0101c88:	c3                   	ret    

c0101c89 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101c89:	55                   	push   %ebp
c0101c8a:	89 e5                	mov    %esp,%ebp
c0101c8c:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101c8f:	a1 28 85 12 c0       	mov    0xc0128528,%eax
c0101c94:	85 c0                	test   %eax,%eax
c0101c96:	74 0c                	je     c0101ca4 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101c98:	c7 04 24 33 1c 10 c0 	movl   $0xc0101c33,(%esp)
c0101c9f:	e8 43 ff ff ff       	call   c0101be7 <cons_intr>
    }
}
c0101ca4:	90                   	nop
c0101ca5:	c9                   	leave  
c0101ca6:	c3                   	ret    

c0101ca7 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101ca7:	55                   	push   %ebp
c0101ca8:	89 e5                	mov    %esp,%ebp
c0101caa:	83 ec 28             	sub    $0x28,%esp
c0101cad:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101cb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101cb6:	89 c2                	mov    %eax,%edx
c0101cb8:	ec                   	in     (%dx),%al
c0101cb9:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101cbc:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101cc0:	0f b6 c0             	movzbl %al,%eax
c0101cc3:	83 e0 01             	and    $0x1,%eax
c0101cc6:	85 c0                	test   %eax,%eax
c0101cc8:	75 0a                	jne    c0101cd4 <kbd_proc_data+0x2d>
        return -1;
c0101cca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101ccf:	e9 56 01 00 00       	jmp    c0101e2a <kbd_proc_data+0x183>
c0101cd4:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101cda:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101cdd:	89 c2                	mov    %eax,%edx
c0101cdf:	ec                   	in     (%dx),%al
c0101ce0:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
c0101ce3:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101ce7:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101cea:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101cee:	75 17                	jne    c0101d07 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c0101cf0:	a1 48 87 12 c0       	mov    0xc0128748,%eax
c0101cf5:	83 c8 40             	or     $0x40,%eax
c0101cf8:	a3 48 87 12 c0       	mov    %eax,0xc0128748
        return 0;
c0101cfd:	b8 00 00 00 00       	mov    $0x0,%eax
c0101d02:	e9 23 01 00 00       	jmp    c0101e2a <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c0101d07:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d0b:	84 c0                	test   %al,%al
c0101d0d:	79 45                	jns    c0101d54 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101d0f:	a1 48 87 12 c0       	mov    0xc0128748,%eax
c0101d14:	83 e0 40             	and    $0x40,%eax
c0101d17:	85 c0                	test   %eax,%eax
c0101d19:	75 08                	jne    c0101d23 <kbd_proc_data+0x7c>
c0101d1b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d1f:	24 7f                	and    $0x7f,%al
c0101d21:	eb 04                	jmp    c0101d27 <kbd_proc_data+0x80>
c0101d23:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d27:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101d2a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d2e:	0f b6 80 40 50 12 c0 	movzbl -0x3fedafc0(%eax),%eax
c0101d35:	0c 40                	or     $0x40,%al
c0101d37:	0f b6 c0             	movzbl %al,%eax
c0101d3a:	f7 d0                	not    %eax
c0101d3c:	89 c2                	mov    %eax,%edx
c0101d3e:	a1 48 87 12 c0       	mov    0xc0128748,%eax
c0101d43:	21 d0                	and    %edx,%eax
c0101d45:	a3 48 87 12 c0       	mov    %eax,0xc0128748
        return 0;
c0101d4a:	b8 00 00 00 00       	mov    $0x0,%eax
c0101d4f:	e9 d6 00 00 00       	jmp    c0101e2a <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c0101d54:	a1 48 87 12 c0       	mov    0xc0128748,%eax
c0101d59:	83 e0 40             	and    $0x40,%eax
c0101d5c:	85 c0                	test   %eax,%eax
c0101d5e:	74 11                	je     c0101d71 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101d60:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101d64:	a1 48 87 12 c0       	mov    0xc0128748,%eax
c0101d69:	83 e0 bf             	and    $0xffffffbf,%eax
c0101d6c:	a3 48 87 12 c0       	mov    %eax,0xc0128748
    }

    shift |= shiftcode[data];
c0101d71:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d75:	0f b6 80 40 50 12 c0 	movzbl -0x3fedafc0(%eax),%eax
c0101d7c:	0f b6 d0             	movzbl %al,%edx
c0101d7f:	a1 48 87 12 c0       	mov    0xc0128748,%eax
c0101d84:	09 d0                	or     %edx,%eax
c0101d86:	a3 48 87 12 c0       	mov    %eax,0xc0128748
    shift ^= togglecode[data];
c0101d8b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d8f:	0f b6 80 40 51 12 c0 	movzbl -0x3fedaec0(%eax),%eax
c0101d96:	0f b6 d0             	movzbl %al,%edx
c0101d99:	a1 48 87 12 c0       	mov    0xc0128748,%eax
c0101d9e:	31 d0                	xor    %edx,%eax
c0101da0:	a3 48 87 12 c0       	mov    %eax,0xc0128748

    c = charcode[shift & (CTL | SHIFT)][data];
c0101da5:	a1 48 87 12 c0       	mov    0xc0128748,%eax
c0101daa:	83 e0 03             	and    $0x3,%eax
c0101dad:	8b 14 85 40 55 12 c0 	mov    -0x3fedaac0(,%eax,4),%edx
c0101db4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101db8:	01 d0                	add    %edx,%eax
c0101dba:	0f b6 00             	movzbl (%eax),%eax
c0101dbd:	0f b6 c0             	movzbl %al,%eax
c0101dc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101dc3:	a1 48 87 12 c0       	mov    0xc0128748,%eax
c0101dc8:	83 e0 08             	and    $0x8,%eax
c0101dcb:	85 c0                	test   %eax,%eax
c0101dcd:	74 22                	je     c0101df1 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c0101dcf:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101dd3:	7e 0c                	jle    c0101de1 <kbd_proc_data+0x13a>
c0101dd5:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101dd9:	7f 06                	jg     c0101de1 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c0101ddb:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101ddf:	eb 10                	jmp    c0101df1 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c0101de1:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101de5:	7e 0a                	jle    c0101df1 <kbd_proc_data+0x14a>
c0101de7:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101deb:	7f 04                	jg     c0101df1 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c0101ded:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101df1:	a1 48 87 12 c0       	mov    0xc0128748,%eax
c0101df6:	f7 d0                	not    %eax
c0101df8:	83 e0 06             	and    $0x6,%eax
c0101dfb:	85 c0                	test   %eax,%eax
c0101dfd:	75 28                	jne    c0101e27 <kbd_proc_data+0x180>
c0101dff:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101e06:	75 1f                	jne    c0101e27 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c0101e08:	c7 04 24 e1 a1 10 c0 	movl   $0xc010a1e1,(%esp)
c0101e0f:	e8 95 e4 ff ff       	call   c01002a9 <cprintf>
c0101e14:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
c0101e1a:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e1e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101e22:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101e26:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101e2a:	c9                   	leave  
c0101e2b:	c3                   	ret    

c0101e2c <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101e2c:	55                   	push   %ebp
c0101e2d:	89 e5                	mov    %esp,%ebp
c0101e2f:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101e32:	c7 04 24 a7 1c 10 c0 	movl   $0xc0101ca7,(%esp)
c0101e39:	e8 a9 fd ff ff       	call   c0101be7 <cons_intr>
}
c0101e3e:	90                   	nop
c0101e3f:	c9                   	leave  
c0101e40:	c3                   	ret    

c0101e41 <kbd_init>:

static void
kbd_init(void) {
c0101e41:	55                   	push   %ebp
c0101e42:	89 e5                	mov    %esp,%ebp
c0101e44:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101e47:	e8 e0 ff ff ff       	call   c0101e2c <kbd_intr>
    pic_enable(IRQ_KBD);
c0101e4c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101e53:	e8 34 01 00 00       	call   c0101f8c <pic_enable>
}
c0101e58:	90                   	nop
c0101e59:	c9                   	leave  
c0101e5a:	c3                   	ret    

c0101e5b <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101e5b:	55                   	push   %ebp
c0101e5c:	89 e5                	mov    %esp,%ebp
c0101e5e:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101e61:	e8 90 f8 ff ff       	call   c01016f6 <cga_init>
    serial_init();
c0101e66:	e8 6d f9 ff ff       	call   c01017d8 <serial_init>
    kbd_init();
c0101e6b:	e8 d1 ff ff ff       	call   c0101e41 <kbd_init>
    if (!serial_exists) {
c0101e70:	a1 28 85 12 c0       	mov    0xc0128528,%eax
c0101e75:	85 c0                	test   %eax,%eax
c0101e77:	75 0c                	jne    c0101e85 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101e79:	c7 04 24 ed a1 10 c0 	movl   $0xc010a1ed,(%esp)
c0101e80:	e8 24 e4 ff ff       	call   c01002a9 <cprintf>
    }
}
c0101e85:	90                   	nop
c0101e86:	c9                   	leave  
c0101e87:	c3                   	ret    

c0101e88 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101e88:	55                   	push   %ebp
c0101e89:	89 e5                	mov    %esp,%ebp
c0101e8b:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101e8e:	e8 de f7 ff ff       	call   c0101671 <__intr_save>
c0101e93:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101e96:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e99:	89 04 24             	mov    %eax,(%esp)
c0101e9c:	e8 8d fa ff ff       	call   c010192e <lpt_putc>
        cga_putc(c);
c0101ea1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ea4:	89 04 24             	mov    %eax,(%esp)
c0101ea7:	e8 c2 fa ff ff       	call   c010196e <cga_putc>
        serial_putc(c);
c0101eac:	8b 45 08             	mov    0x8(%ebp),%eax
c0101eaf:	89 04 24             	mov    %eax,(%esp)
c0101eb2:	e8 f0 fc ff ff       	call   c0101ba7 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101eba:	89 04 24             	mov    %eax,(%esp)
c0101ebd:	e8 d9 f7 ff ff       	call   c010169b <__intr_restore>
}
c0101ec2:	90                   	nop
c0101ec3:	c9                   	leave  
c0101ec4:	c3                   	ret    

c0101ec5 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101ec5:	55                   	push   %ebp
c0101ec6:	89 e5                	mov    %esp,%ebp
c0101ec8:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101ecb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101ed2:	e8 9a f7 ff ff       	call   c0101671 <__intr_save>
c0101ed7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101eda:	e8 aa fd ff ff       	call   c0101c89 <serial_intr>
        kbd_intr();
c0101edf:	e8 48 ff ff ff       	call   c0101e2c <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101ee4:	8b 15 40 87 12 c0    	mov    0xc0128740,%edx
c0101eea:	a1 44 87 12 c0       	mov    0xc0128744,%eax
c0101eef:	39 c2                	cmp    %eax,%edx
c0101ef1:	74 31                	je     c0101f24 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101ef3:	a1 40 87 12 c0       	mov    0xc0128740,%eax
c0101ef8:	8d 50 01             	lea    0x1(%eax),%edx
c0101efb:	89 15 40 87 12 c0    	mov    %edx,0xc0128740
c0101f01:	0f b6 80 40 85 12 c0 	movzbl -0x3fed7ac0(%eax),%eax
c0101f08:	0f b6 c0             	movzbl %al,%eax
c0101f0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101f0e:	a1 40 87 12 c0       	mov    0xc0128740,%eax
c0101f13:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101f18:	75 0a                	jne    c0101f24 <cons_getc+0x5f>
                cons.rpos = 0;
c0101f1a:	c7 05 40 87 12 c0 00 	movl   $0x0,0xc0128740
c0101f21:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101f24:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f27:	89 04 24             	mov    %eax,(%esp)
c0101f2a:	e8 6c f7 ff ff       	call   c010169b <__intr_restore>
    return c;
c0101f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f32:	c9                   	leave  
c0101f33:	c3                   	ret    

c0101f34 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101f34:	55                   	push   %ebp
c0101f35:	89 e5                	mov    %esp,%ebp
c0101f37:	83 ec 14             	sub    $0x14,%esp
c0101f3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f3d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101f41:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101f44:	66 a3 50 55 12 c0    	mov    %ax,0xc0125550
    if (did_init) {
c0101f4a:	a1 4c 87 12 c0       	mov    0xc012874c,%eax
c0101f4f:	85 c0                	test   %eax,%eax
c0101f51:	74 36                	je     c0101f89 <pic_setmask+0x55>
        outb(IO_PIC1 + 1, mask);
c0101f53:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101f56:	0f b6 c0             	movzbl %al,%eax
c0101f59:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101f5f:	88 45 fa             	mov    %al,-0x6(%ebp)
c0101f62:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
c0101f66:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101f6a:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101f6b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f6f:	c1 e8 08             	shr    $0x8,%eax
c0101f72:	0f b7 c0             	movzwl %ax,%eax
c0101f75:	0f b6 c0             	movzbl %al,%eax
c0101f78:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c0101f7e:	88 45 fb             	mov    %al,-0x5(%ebp)
c0101f81:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
c0101f85:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101f88:	ee                   	out    %al,(%dx)
    }
}
c0101f89:	90                   	nop
c0101f8a:	c9                   	leave  
c0101f8b:	c3                   	ret    

c0101f8c <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101f8c:	55                   	push   %ebp
c0101f8d:	89 e5                	mov    %esp,%ebp
c0101f8f:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101f92:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f95:	ba 01 00 00 00       	mov    $0x1,%edx
c0101f9a:	88 c1                	mov    %al,%cl
c0101f9c:	d3 e2                	shl    %cl,%edx
c0101f9e:	89 d0                	mov    %edx,%eax
c0101fa0:	98                   	cwtl   
c0101fa1:	f7 d0                	not    %eax
c0101fa3:	0f bf d0             	movswl %ax,%edx
c0101fa6:	0f b7 05 50 55 12 c0 	movzwl 0xc0125550,%eax
c0101fad:	98                   	cwtl   
c0101fae:	21 d0                	and    %edx,%eax
c0101fb0:	98                   	cwtl   
c0101fb1:	0f b7 c0             	movzwl %ax,%eax
c0101fb4:	89 04 24             	mov    %eax,(%esp)
c0101fb7:	e8 78 ff ff ff       	call   c0101f34 <pic_setmask>
}
c0101fbc:	90                   	nop
c0101fbd:	c9                   	leave  
c0101fbe:	c3                   	ret    

c0101fbf <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101fbf:	55                   	push   %ebp
c0101fc0:	89 e5                	mov    %esp,%ebp
c0101fc2:	83 ec 34             	sub    $0x34,%esp
    did_init = 1;
c0101fc5:	c7 05 4c 87 12 c0 01 	movl   $0x1,0xc012874c
c0101fcc:	00 00 00 
c0101fcf:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101fd5:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
c0101fd9:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
c0101fdd:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101fe1:	ee                   	out    %al,(%dx)
c0101fe2:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c0101fe8:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
c0101fec:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c0101ff0:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101ff3:	ee                   	out    %al,(%dx)
c0101ff4:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
c0101ffa:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
c0101ffe:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c0102002:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102006:	ee                   	out    %al,(%dx)
c0102007:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
c010200d:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
c0102011:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0102015:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0102018:	ee                   	out    %al,(%dx)
c0102019:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
c010201f:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
c0102023:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c0102027:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010202b:	ee                   	out    %al,(%dx)
c010202c:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
c0102032:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
c0102036:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c010203a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010203d:	ee                   	out    %al,(%dx)
c010203e:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
c0102044:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
c0102048:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c010204c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102050:	ee                   	out    %al,(%dx)
c0102051:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
c0102057:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
c010205b:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010205f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102062:	ee                   	out    %al,(%dx)
c0102063:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0102069:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
c010206d:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c0102071:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102075:	ee                   	out    %al,(%dx)
c0102076:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
c010207c:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
c0102080:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0102084:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102087:	ee                   	out    %al,(%dx)
c0102088:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
c010208e:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
c0102092:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0102096:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010209a:	ee                   	out    %al,(%dx)
c010209b:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
c01020a1:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
c01020a5:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01020a9:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01020ac:	ee                   	out    %al,(%dx)
c01020ad:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01020b3:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
c01020b7:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
c01020bb:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01020bf:	ee                   	out    %al,(%dx)
c01020c0:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
c01020c6:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
c01020ca:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
c01020ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01020d1:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01020d2:	0f b7 05 50 55 12 c0 	movzwl 0xc0125550,%eax
c01020d9:	3d ff ff 00 00       	cmp    $0xffff,%eax
c01020de:	74 0f                	je     c01020ef <pic_init+0x130>
        pic_setmask(irq_mask);
c01020e0:	0f b7 05 50 55 12 c0 	movzwl 0xc0125550,%eax
c01020e7:	89 04 24             	mov    %eax,(%esp)
c01020ea:	e8 45 fe ff ff       	call   c0101f34 <pic_setmask>
    }
}
c01020ef:	90                   	nop
c01020f0:	c9                   	leave  
c01020f1:	c3                   	ret    

c01020f2 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01020f2:	55                   	push   %ebp
c01020f3:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c01020f5:	fb                   	sti    
    sti();
}
c01020f6:	90                   	nop
c01020f7:	5d                   	pop    %ebp
c01020f8:	c3                   	ret    

c01020f9 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01020f9:	55                   	push   %ebp
c01020fa:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c01020fc:	fa                   	cli    
    cli();
}
c01020fd:	90                   	nop
c01020fe:	5d                   	pop    %ebp
c01020ff:	c3                   	ret    

c0102100 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0102100:	55                   	push   %ebp
c0102101:	89 e5                	mov    %esp,%ebp
c0102103:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0102106:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010210d:	00 
c010210e:	c7 04 24 20 a2 10 c0 	movl   $0xc010a220,(%esp)
c0102115:	e8 8f e1 ff ff       	call   c01002a9 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c010211a:	90                   	nop
c010211b:	c9                   	leave  
c010211c:	c3                   	ret    

c010211d <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c010211d:	55                   	push   %ebp
c010211e:	89 e5                	mov    %esp,%ebp
c0102120:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int length=sizeof(idt) / sizeof(struct gatedesc);
c0102123:	c7 45 f8 00 01 00 00 	movl   $0x100,-0x8(%ebp)
    for(int i=0;i<length;i++)
c010212a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102131:	e9 c4 00 00 00       	jmp    c01021fa <idt_init+0xdd>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0102136:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102139:	8b 04 85 e0 55 12 c0 	mov    -0x3fedaa20(,%eax,4),%eax
c0102140:	0f b7 d0             	movzwl %ax,%edx
c0102143:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102146:	66 89 14 c5 60 87 12 	mov    %dx,-0x3fed78a0(,%eax,8)
c010214d:	c0 
c010214e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102151:	66 c7 04 c5 62 87 12 	movw   $0x8,-0x3fed789e(,%eax,8)
c0102158:	c0 08 00 
c010215b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010215e:	0f b6 14 c5 64 87 12 	movzbl -0x3fed789c(,%eax,8),%edx
c0102165:	c0 
c0102166:	80 e2 e0             	and    $0xe0,%dl
c0102169:	88 14 c5 64 87 12 c0 	mov    %dl,-0x3fed789c(,%eax,8)
c0102170:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102173:	0f b6 14 c5 64 87 12 	movzbl -0x3fed789c(,%eax,8),%edx
c010217a:	c0 
c010217b:	80 e2 1f             	and    $0x1f,%dl
c010217e:	88 14 c5 64 87 12 c0 	mov    %dl,-0x3fed789c(,%eax,8)
c0102185:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102188:	0f b6 14 c5 65 87 12 	movzbl -0x3fed789b(,%eax,8),%edx
c010218f:	c0 
c0102190:	80 e2 f0             	and    $0xf0,%dl
c0102193:	80 ca 0e             	or     $0xe,%dl
c0102196:	88 14 c5 65 87 12 c0 	mov    %dl,-0x3fed789b(,%eax,8)
c010219d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021a0:	0f b6 14 c5 65 87 12 	movzbl -0x3fed789b(,%eax,8),%edx
c01021a7:	c0 
c01021a8:	80 e2 ef             	and    $0xef,%dl
c01021ab:	88 14 c5 65 87 12 c0 	mov    %dl,-0x3fed789b(,%eax,8)
c01021b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021b5:	0f b6 14 c5 65 87 12 	movzbl -0x3fed789b(,%eax,8),%edx
c01021bc:	c0 
c01021bd:	80 e2 9f             	and    $0x9f,%dl
c01021c0:	88 14 c5 65 87 12 c0 	mov    %dl,-0x3fed789b(,%eax,8)
c01021c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021ca:	0f b6 14 c5 65 87 12 	movzbl -0x3fed789b(,%eax,8),%edx
c01021d1:	c0 
c01021d2:	80 ca 80             	or     $0x80,%dl
c01021d5:	88 14 c5 65 87 12 c0 	mov    %dl,-0x3fed789b(,%eax,8)
c01021dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021df:	8b 04 85 e0 55 12 c0 	mov    -0x3fedaa20(,%eax,4),%eax
c01021e6:	c1 e8 10             	shr    $0x10,%eax
c01021e9:	0f b7 d0             	movzwl %ax,%edx
c01021ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021ef:	66 89 14 c5 66 87 12 	mov    %dx,-0x3fed789a(,%eax,8)
c01021f6:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int length=sizeof(idt) / sizeof(struct gatedesc);
    for(int i=0;i<length;i++)
c01021f7:	ff 45 fc             	incl   -0x4(%ebp)
c01021fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021fd:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0102200:	0f 8c 30 ff ff ff    	jl     c0102136 <idt_init+0x19>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c0102206:	a1 c4 57 12 c0       	mov    0xc01257c4,%eax
c010220b:	0f b7 c0             	movzwl %ax,%eax
c010220e:	66 a3 28 8b 12 c0    	mov    %ax,0xc0128b28
c0102214:	66 c7 05 2a 8b 12 c0 	movw   $0x8,0xc0128b2a
c010221b:	08 00 
c010221d:	0f b6 05 2c 8b 12 c0 	movzbl 0xc0128b2c,%eax
c0102224:	24 e0                	and    $0xe0,%al
c0102226:	a2 2c 8b 12 c0       	mov    %al,0xc0128b2c
c010222b:	0f b6 05 2c 8b 12 c0 	movzbl 0xc0128b2c,%eax
c0102232:	24 1f                	and    $0x1f,%al
c0102234:	a2 2c 8b 12 c0       	mov    %al,0xc0128b2c
c0102239:	0f b6 05 2d 8b 12 c0 	movzbl 0xc0128b2d,%eax
c0102240:	24 f0                	and    $0xf0,%al
c0102242:	0c 0e                	or     $0xe,%al
c0102244:	a2 2d 8b 12 c0       	mov    %al,0xc0128b2d
c0102249:	0f b6 05 2d 8b 12 c0 	movzbl 0xc0128b2d,%eax
c0102250:	24 ef                	and    $0xef,%al
c0102252:	a2 2d 8b 12 c0       	mov    %al,0xc0128b2d
c0102257:	0f b6 05 2d 8b 12 c0 	movzbl 0xc0128b2d,%eax
c010225e:	0c 60                	or     $0x60,%al
c0102260:	a2 2d 8b 12 c0       	mov    %al,0xc0128b2d
c0102265:	0f b6 05 2d 8b 12 c0 	movzbl 0xc0128b2d,%eax
c010226c:	0c 80                	or     $0x80,%al
c010226e:	a2 2d 8b 12 c0       	mov    %al,0xc0128b2d
c0102273:	a1 c4 57 12 c0       	mov    0xc01257c4,%eax
c0102278:	c1 e8 10             	shr    $0x10,%eax
c010227b:	0f b7 c0             	movzwl %ax,%eax
c010227e:	66 a3 2e 8b 12 c0    	mov    %ax,0xc0128b2e
c0102284:	c7 45 f4 60 55 12 c0 	movl   $0xc0125560,-0xc(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c010228b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010228e:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
c0102291:	90                   	nop
c0102292:	c9                   	leave  
c0102293:	c3                   	ret    

c0102294 <trapname>:

static const char *
trapname(int trapno) {
c0102294:	55                   	push   %ebp
c0102295:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0102297:	8b 45 08             	mov    0x8(%ebp),%eax
c010229a:	83 f8 13             	cmp    $0x13,%eax
c010229d:	77 0c                	ja     c01022ab <trapname+0x17>
        return excnames[trapno];
c010229f:	8b 45 08             	mov    0x8(%ebp),%eax
c01022a2:	8b 04 85 00 a6 10 c0 	mov    -0x3fef5a00(,%eax,4),%eax
c01022a9:	eb 18                	jmp    c01022c3 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01022ab:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01022af:	7e 0d                	jle    c01022be <trapname+0x2a>
c01022b1:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01022b5:	7f 07                	jg     c01022be <trapname+0x2a>
        return "Hardware Interrupt";
c01022b7:	b8 2a a2 10 c0       	mov    $0xc010a22a,%eax
c01022bc:	eb 05                	jmp    c01022c3 <trapname+0x2f>
    }
    return "(unknown trap)";
c01022be:	b8 3d a2 10 c0       	mov    $0xc010a23d,%eax
}
c01022c3:	5d                   	pop    %ebp
c01022c4:	c3                   	ret    

c01022c5 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01022c5:	55                   	push   %ebp
c01022c6:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01022c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01022cb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01022cf:	83 f8 08             	cmp    $0x8,%eax
c01022d2:	0f 94 c0             	sete   %al
c01022d5:	0f b6 c0             	movzbl %al,%eax
}
c01022d8:	5d                   	pop    %ebp
c01022d9:	c3                   	ret    

c01022da <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01022da:	55                   	push   %ebp
c01022db:	89 e5                	mov    %esp,%ebp
c01022dd:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01022e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01022e3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022e7:	c7 04 24 7e a2 10 c0 	movl   $0xc010a27e,(%esp)
c01022ee:	e8 b6 df ff ff       	call   c01002a9 <cprintf>
    print_regs(&tf->tf_regs);
c01022f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01022f6:	89 04 24             	mov    %eax,(%esp)
c01022f9:	e8 91 01 00 00       	call   c010248f <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c01022fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0102301:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0102305:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102309:	c7 04 24 8f a2 10 c0 	movl   $0xc010a28f,(%esp)
c0102310:	e8 94 df ff ff       	call   c01002a9 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0102315:	8b 45 08             	mov    0x8(%ebp),%eax
c0102318:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c010231c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102320:	c7 04 24 a2 a2 10 c0 	movl   $0xc010a2a2,(%esp)
c0102327:	e8 7d df ff ff       	call   c01002a9 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c010232c:	8b 45 08             	mov    0x8(%ebp),%eax
c010232f:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0102333:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102337:	c7 04 24 b5 a2 10 c0 	movl   $0xc010a2b5,(%esp)
c010233e:	e8 66 df ff ff       	call   c01002a9 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0102343:	8b 45 08             	mov    0x8(%ebp),%eax
c0102346:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c010234a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010234e:	c7 04 24 c8 a2 10 c0 	movl   $0xc010a2c8,(%esp)
c0102355:	e8 4f df ff ff       	call   c01002a9 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c010235a:	8b 45 08             	mov    0x8(%ebp),%eax
c010235d:	8b 40 30             	mov    0x30(%eax),%eax
c0102360:	89 04 24             	mov    %eax,(%esp)
c0102363:	e8 2c ff ff ff       	call   c0102294 <trapname>
c0102368:	89 c2                	mov    %eax,%edx
c010236a:	8b 45 08             	mov    0x8(%ebp),%eax
c010236d:	8b 40 30             	mov    0x30(%eax),%eax
c0102370:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102374:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102378:	c7 04 24 db a2 10 c0 	movl   $0xc010a2db,(%esp)
c010237f:	e8 25 df ff ff       	call   c01002a9 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0102384:	8b 45 08             	mov    0x8(%ebp),%eax
c0102387:	8b 40 34             	mov    0x34(%eax),%eax
c010238a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010238e:	c7 04 24 ed a2 10 c0 	movl   $0xc010a2ed,(%esp)
c0102395:	e8 0f df ff ff       	call   c01002a9 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c010239a:	8b 45 08             	mov    0x8(%ebp),%eax
c010239d:	8b 40 38             	mov    0x38(%eax),%eax
c01023a0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023a4:	c7 04 24 fc a2 10 c0 	movl   $0xc010a2fc,(%esp)
c01023ab:	e8 f9 de ff ff       	call   c01002a9 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01023b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01023b3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01023b7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023bb:	c7 04 24 0b a3 10 c0 	movl   $0xc010a30b,(%esp)
c01023c2:	e8 e2 de ff ff       	call   c01002a9 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01023c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01023ca:	8b 40 40             	mov    0x40(%eax),%eax
c01023cd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023d1:	c7 04 24 1e a3 10 c0 	movl   $0xc010a31e,(%esp)
c01023d8:	e8 cc de ff ff       	call   c01002a9 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01023dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01023e4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01023eb:	eb 3d                	jmp    c010242a <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c01023ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01023f0:	8b 50 40             	mov    0x40(%eax),%edx
c01023f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01023f6:	21 d0                	and    %edx,%eax
c01023f8:	85 c0                	test   %eax,%eax
c01023fa:	74 28                	je     c0102424 <print_trapframe+0x14a>
c01023fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01023ff:	8b 04 85 80 55 12 c0 	mov    -0x3fedaa80(,%eax,4),%eax
c0102406:	85 c0                	test   %eax,%eax
c0102408:	74 1a                	je     c0102424 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c010240a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010240d:	8b 04 85 80 55 12 c0 	mov    -0x3fedaa80(,%eax,4),%eax
c0102414:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102418:	c7 04 24 2d a3 10 c0 	movl   $0xc010a32d,(%esp)
c010241f:	e8 85 de ff ff       	call   c01002a9 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102424:	ff 45 f4             	incl   -0xc(%ebp)
c0102427:	d1 65 f0             	shll   -0x10(%ebp)
c010242a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010242d:	83 f8 17             	cmp    $0x17,%eax
c0102430:	76 bb                	jbe    c01023ed <print_trapframe+0x113>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102432:	8b 45 08             	mov    0x8(%ebp),%eax
c0102435:	8b 40 40             	mov    0x40(%eax),%eax
c0102438:	25 00 30 00 00       	and    $0x3000,%eax
c010243d:	c1 e8 0c             	shr    $0xc,%eax
c0102440:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102444:	c7 04 24 31 a3 10 c0 	movl   $0xc010a331,(%esp)
c010244b:	e8 59 de ff ff       	call   c01002a9 <cprintf>

    if (!trap_in_kernel(tf)) {
c0102450:	8b 45 08             	mov    0x8(%ebp),%eax
c0102453:	89 04 24             	mov    %eax,(%esp)
c0102456:	e8 6a fe ff ff       	call   c01022c5 <trap_in_kernel>
c010245b:	85 c0                	test   %eax,%eax
c010245d:	75 2d                	jne    c010248c <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c010245f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102462:	8b 40 44             	mov    0x44(%eax),%eax
c0102465:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102469:	c7 04 24 3a a3 10 c0 	movl   $0xc010a33a,(%esp)
c0102470:	e8 34 de ff ff       	call   c01002a9 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0102475:	8b 45 08             	mov    0x8(%ebp),%eax
c0102478:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c010247c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102480:	c7 04 24 49 a3 10 c0 	movl   $0xc010a349,(%esp)
c0102487:	e8 1d de ff ff       	call   c01002a9 <cprintf>
    }
}
c010248c:	90                   	nop
c010248d:	c9                   	leave  
c010248e:	c3                   	ret    

c010248f <print_regs>:

void
print_regs(struct pushregs *regs) {
c010248f:	55                   	push   %ebp
c0102490:	89 e5                	mov    %esp,%ebp
c0102492:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0102495:	8b 45 08             	mov    0x8(%ebp),%eax
c0102498:	8b 00                	mov    (%eax),%eax
c010249a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010249e:	c7 04 24 5c a3 10 c0 	movl   $0xc010a35c,(%esp)
c01024a5:	e8 ff dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01024aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01024ad:	8b 40 04             	mov    0x4(%eax),%eax
c01024b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024b4:	c7 04 24 6b a3 10 c0 	movl   $0xc010a36b,(%esp)
c01024bb:	e8 e9 dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01024c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01024c3:	8b 40 08             	mov    0x8(%eax),%eax
c01024c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024ca:	c7 04 24 7a a3 10 c0 	movl   $0xc010a37a,(%esp)
c01024d1:	e8 d3 dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01024d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01024d9:	8b 40 0c             	mov    0xc(%eax),%eax
c01024dc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024e0:	c7 04 24 89 a3 10 c0 	movl   $0xc010a389,(%esp)
c01024e7:	e8 bd dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c01024ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01024ef:	8b 40 10             	mov    0x10(%eax),%eax
c01024f2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024f6:	c7 04 24 98 a3 10 c0 	movl   $0xc010a398,(%esp)
c01024fd:	e8 a7 dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0102502:	8b 45 08             	mov    0x8(%ebp),%eax
c0102505:	8b 40 14             	mov    0x14(%eax),%eax
c0102508:	89 44 24 04          	mov    %eax,0x4(%esp)
c010250c:	c7 04 24 a7 a3 10 c0 	movl   $0xc010a3a7,(%esp)
c0102513:	e8 91 dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0102518:	8b 45 08             	mov    0x8(%ebp),%eax
c010251b:	8b 40 18             	mov    0x18(%eax),%eax
c010251e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102522:	c7 04 24 b6 a3 10 c0 	movl   $0xc010a3b6,(%esp)
c0102529:	e8 7b dd ff ff       	call   c01002a9 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c010252e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102531:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102534:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102538:	c7 04 24 c5 a3 10 c0 	movl   $0xc010a3c5,(%esp)
c010253f:	e8 65 dd ff ff       	call   c01002a9 <cprintf>
}
c0102544:	90                   	nop
c0102545:	c9                   	leave  
c0102546:	c3                   	ret    

c0102547 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0102547:	55                   	push   %ebp
c0102548:	89 e5                	mov    %esp,%ebp
c010254a:	53                   	push   %ebx
c010254b:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c010254e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102551:	8b 40 34             	mov    0x34(%eax),%eax
c0102554:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102557:	85 c0                	test   %eax,%eax
c0102559:	74 07                	je     c0102562 <print_pgfault+0x1b>
c010255b:	bb d4 a3 10 c0       	mov    $0xc010a3d4,%ebx
c0102560:	eb 05                	jmp    c0102567 <print_pgfault+0x20>
c0102562:	bb e5 a3 10 c0       	mov    $0xc010a3e5,%ebx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c0102567:	8b 45 08             	mov    0x8(%ebp),%eax
c010256a:	8b 40 34             	mov    0x34(%eax),%eax
c010256d:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102570:	85 c0                	test   %eax,%eax
c0102572:	74 07                	je     c010257b <print_pgfault+0x34>
c0102574:	b9 57 00 00 00       	mov    $0x57,%ecx
c0102579:	eb 05                	jmp    c0102580 <print_pgfault+0x39>
c010257b:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c0102580:	8b 45 08             	mov    0x8(%ebp),%eax
c0102583:	8b 40 34             	mov    0x34(%eax),%eax
c0102586:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102589:	85 c0                	test   %eax,%eax
c010258b:	74 07                	je     c0102594 <print_pgfault+0x4d>
c010258d:	ba 55 00 00 00       	mov    $0x55,%edx
c0102592:	eb 05                	jmp    c0102599 <print_pgfault+0x52>
c0102594:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102599:	0f 20 d0             	mov    %cr2,%eax
c010259c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c010259f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01025a2:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c01025a6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01025aa:	89 54 24 08          	mov    %edx,0x8(%esp)
c01025ae:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025b2:	c7 04 24 f4 a3 10 c0 	movl   $0xc010a3f4,(%esp)
c01025b9:	e8 eb dc ff ff       	call   c01002a9 <cprintf>
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c01025be:	90                   	nop
c01025bf:	83 c4 34             	add    $0x34,%esp
c01025c2:	5b                   	pop    %ebx
c01025c3:	5d                   	pop    %ebp
c01025c4:	c3                   	ret    

c01025c5 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01025c5:	55                   	push   %ebp
c01025c6:	89 e5                	mov    %esp,%ebp
c01025c8:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c01025cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01025ce:	89 04 24             	mov    %eax,(%esp)
c01025d1:	e8 71 ff ff ff       	call   c0102547 <print_pgfault>
    if (check_mm_struct != NULL) {
c01025d6:	a1 58 b0 12 c0       	mov    0xc012b058,%eax
c01025db:	85 c0                	test   %eax,%eax
c01025dd:	74 26                	je     c0102605 <pgfault_handler+0x40>
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01025df:	0f 20 d0             	mov    %cr2,%eax
c01025e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01025e5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c01025e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01025eb:	8b 50 34             	mov    0x34(%eax),%edx
c01025ee:	a1 58 b0 12 c0       	mov    0xc012b058,%eax
c01025f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01025f7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01025fb:	89 04 24             	mov    %eax,(%esp)
c01025fe:	e8 69 17 00 00       	call   c0103d6c <do_pgfault>
c0102603:	eb 1c                	jmp    c0102621 <pgfault_handler+0x5c>
    }
    panic("unhandled page fault.\n");
c0102605:	c7 44 24 08 17 a4 10 	movl   $0xc010a417,0x8(%esp)
c010260c:	c0 
c010260d:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
c0102614:	00 
c0102615:	c7 04 24 2e a4 10 c0 	movl   $0xc010a42e,(%esp)
c010261c:	e8 df dd ff ff       	call   c0100400 <__panic>
}
c0102621:	c9                   	leave  
c0102622:	c3                   	ret    

c0102623 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c0102623:	55                   	push   %ebp
c0102624:	89 e5                	mov    %esp,%ebp
c0102626:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c0102629:	8b 45 08             	mov    0x8(%ebp),%eax
c010262c:	8b 40 30             	mov    0x30(%eax),%eax
c010262f:	83 f8 24             	cmp    $0x24,%eax
c0102632:	0f 84 cc 00 00 00    	je     c0102704 <trap_dispatch+0xe1>
c0102638:	83 f8 24             	cmp    $0x24,%eax
c010263b:	77 18                	ja     c0102655 <trap_dispatch+0x32>
c010263d:	83 f8 20             	cmp    $0x20,%eax
c0102640:	74 7c                	je     c01026be <trap_dispatch+0x9b>
c0102642:	83 f8 21             	cmp    $0x21,%eax
c0102645:	0f 84 df 00 00 00    	je     c010272a <trap_dispatch+0x107>
c010264b:	83 f8 0e             	cmp    $0xe,%eax
c010264e:	74 28                	je     c0102678 <trap_dispatch+0x55>
c0102650:	e9 17 01 00 00       	jmp    c010276c <trap_dispatch+0x149>
c0102655:	83 f8 2e             	cmp    $0x2e,%eax
c0102658:	0f 82 0e 01 00 00    	jb     c010276c <trap_dispatch+0x149>
c010265e:	83 f8 2f             	cmp    $0x2f,%eax
c0102661:	0f 86 3a 01 00 00    	jbe    c01027a1 <trap_dispatch+0x17e>
c0102667:	83 e8 78             	sub    $0x78,%eax
c010266a:	83 f8 01             	cmp    $0x1,%eax
c010266d:	0f 87 f9 00 00 00    	ja     c010276c <trap_dispatch+0x149>
c0102673:	e9 d8 00 00 00       	jmp    c0102750 <trap_dispatch+0x12d>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c0102678:	8b 45 08             	mov    0x8(%ebp),%eax
c010267b:	89 04 24             	mov    %eax,(%esp)
c010267e:	e8 42 ff ff ff       	call   c01025c5 <pgfault_handler>
c0102683:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102686:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010268a:	0f 84 14 01 00 00    	je     c01027a4 <trap_dispatch+0x181>
            print_trapframe(tf);
c0102690:	8b 45 08             	mov    0x8(%ebp),%eax
c0102693:	89 04 24             	mov    %eax,(%esp)
c0102696:	e8 3f fc ff ff       	call   c01022da <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c010269b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010269e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01026a2:	c7 44 24 08 3f a4 10 	movl   $0xc010a43f,0x8(%esp)
c01026a9:	c0 
c01026aa:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c01026b1:	00 
c01026b2:	c7 04 24 2e a4 10 c0 	movl   $0xc010a42e,(%esp)
c01026b9:	e8 42 dd ff ff       	call   c0100400 <__panic>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
            ticks ++;
c01026be:	a1 54 b0 12 c0       	mov    0xc012b054,%eax
c01026c3:	40                   	inc    %eax
c01026c4:	a3 54 b0 12 c0       	mov    %eax,0xc012b054
            if(ticks % TICK_NUM==0)  print_ticks();
c01026c9:	8b 0d 54 b0 12 c0    	mov    0xc012b054,%ecx
c01026cf:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c01026d4:	89 c8                	mov    %ecx,%eax
c01026d6:	f7 e2                	mul    %edx
c01026d8:	c1 ea 05             	shr    $0x5,%edx
c01026db:	89 d0                	mov    %edx,%eax
c01026dd:	c1 e0 02             	shl    $0x2,%eax
c01026e0:	01 d0                	add    %edx,%eax
c01026e2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01026e9:	01 d0                	add    %edx,%eax
c01026eb:	c1 e0 02             	shl    $0x2,%eax
c01026ee:	29 c1                	sub    %eax,%ecx
c01026f0:	89 ca                	mov    %ecx,%edx
c01026f2:	85 d2                	test   %edx,%edx
c01026f4:	0f 85 ad 00 00 00    	jne    c01027a7 <trap_dispatch+0x184>
c01026fa:	e8 01 fa ff ff       	call   c0102100 <print_ticks>
        break;
c01026ff:	e9 a3 00 00 00       	jmp    c01027a7 <trap_dispatch+0x184>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0102704:	e8 bc f7 ff ff       	call   c0101ec5 <cons_getc>
c0102709:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c010270c:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102710:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102714:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102718:	89 44 24 04          	mov    %eax,0x4(%esp)
c010271c:	c7 04 24 5a a4 10 c0 	movl   $0xc010a45a,(%esp)
c0102723:	e8 81 db ff ff       	call   c01002a9 <cprintf>
        break;
c0102728:	eb 7e                	jmp    c01027a8 <trap_dispatch+0x185>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c010272a:	e8 96 f7 ff ff       	call   c0101ec5 <cons_getc>
c010272f:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0102732:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102736:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c010273a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010273e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102742:	c7 04 24 6c a4 10 c0 	movl   $0xc010a46c,(%esp)
c0102749:	e8 5b db ff ff       	call   c01002a9 <cprintf>
        break;
c010274e:	eb 58                	jmp    c01027a8 <trap_dispatch+0x185>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0102750:	c7 44 24 08 7b a4 10 	movl   $0xc010a47b,0x8(%esp)
c0102757:	c0 
c0102758:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c010275f:	00 
c0102760:	c7 04 24 2e a4 10 c0 	movl   $0xc010a42e,(%esp)
c0102767:	e8 94 dc ff ff       	call   c0100400 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c010276c:	8b 45 08             	mov    0x8(%ebp),%eax
c010276f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102773:	83 e0 03             	and    $0x3,%eax
c0102776:	85 c0                	test   %eax,%eax
c0102778:	75 2e                	jne    c01027a8 <trap_dispatch+0x185>
            print_trapframe(tf);
c010277a:	8b 45 08             	mov    0x8(%ebp),%eax
c010277d:	89 04 24             	mov    %eax,(%esp)
c0102780:	e8 55 fb ff ff       	call   c01022da <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0102785:	c7 44 24 08 8b a4 10 	movl   $0xc010a48b,0x8(%esp)
c010278c:	c0 
c010278d:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0102794:	00 
c0102795:	c7 04 24 2e a4 10 c0 	movl   $0xc010a42e,(%esp)
c010279c:	e8 5f dc ff ff       	call   c0100400 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c01027a1:	90                   	nop
c01027a2:	eb 04                	jmp    c01027a8 <trap_dispatch+0x185>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
            print_trapframe(tf);
            panic("handle pgfault failed. %e\n", ret);
        }
        break;
c01027a4:	90                   	nop
c01027a5:	eb 01                	jmp    c01027a8 <trap_dispatch+0x185>
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
            ticks ++;
            if(ticks % TICK_NUM==0)  print_ticks();
        break;
c01027a7:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c01027a8:	90                   	nop
c01027a9:	c9                   	leave  
c01027aa:	c3                   	ret    

c01027ab <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c01027ab:	55                   	push   %ebp
c01027ac:	89 e5                	mov    %esp,%ebp
c01027ae:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c01027b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01027b4:	89 04 24             	mov    %eax,(%esp)
c01027b7:	e8 67 fe ff ff       	call   c0102623 <trap_dispatch>
}
c01027bc:	90                   	nop
c01027bd:	c9                   	leave  
c01027be:	c3                   	ret    

c01027bf <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c01027bf:	6a 00                	push   $0x0
  pushl $0
c01027c1:	6a 00                	push   $0x0
  jmp __alltraps
c01027c3:	e9 69 0a 00 00       	jmp    c0103231 <__alltraps>

c01027c8 <vector1>:
.globl vector1
vector1:
  pushl $0
c01027c8:	6a 00                	push   $0x0
  pushl $1
c01027ca:	6a 01                	push   $0x1
  jmp __alltraps
c01027cc:	e9 60 0a 00 00       	jmp    c0103231 <__alltraps>

c01027d1 <vector2>:
.globl vector2
vector2:
  pushl $0
c01027d1:	6a 00                	push   $0x0
  pushl $2
c01027d3:	6a 02                	push   $0x2
  jmp __alltraps
c01027d5:	e9 57 0a 00 00       	jmp    c0103231 <__alltraps>

c01027da <vector3>:
.globl vector3
vector3:
  pushl $0
c01027da:	6a 00                	push   $0x0
  pushl $3
c01027dc:	6a 03                	push   $0x3
  jmp __alltraps
c01027de:	e9 4e 0a 00 00       	jmp    c0103231 <__alltraps>

c01027e3 <vector4>:
.globl vector4
vector4:
  pushl $0
c01027e3:	6a 00                	push   $0x0
  pushl $4
c01027e5:	6a 04                	push   $0x4
  jmp __alltraps
c01027e7:	e9 45 0a 00 00       	jmp    c0103231 <__alltraps>

c01027ec <vector5>:
.globl vector5
vector5:
  pushl $0
c01027ec:	6a 00                	push   $0x0
  pushl $5
c01027ee:	6a 05                	push   $0x5
  jmp __alltraps
c01027f0:	e9 3c 0a 00 00       	jmp    c0103231 <__alltraps>

c01027f5 <vector6>:
.globl vector6
vector6:
  pushl $0
c01027f5:	6a 00                	push   $0x0
  pushl $6
c01027f7:	6a 06                	push   $0x6
  jmp __alltraps
c01027f9:	e9 33 0a 00 00       	jmp    c0103231 <__alltraps>

c01027fe <vector7>:
.globl vector7
vector7:
  pushl $0
c01027fe:	6a 00                	push   $0x0
  pushl $7
c0102800:	6a 07                	push   $0x7
  jmp __alltraps
c0102802:	e9 2a 0a 00 00       	jmp    c0103231 <__alltraps>

c0102807 <vector8>:
.globl vector8
vector8:
  pushl $8
c0102807:	6a 08                	push   $0x8
  jmp __alltraps
c0102809:	e9 23 0a 00 00       	jmp    c0103231 <__alltraps>

c010280e <vector9>:
.globl vector9
vector9:
  pushl $0
c010280e:	6a 00                	push   $0x0
  pushl $9
c0102810:	6a 09                	push   $0x9
  jmp __alltraps
c0102812:	e9 1a 0a 00 00       	jmp    c0103231 <__alltraps>

c0102817 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102817:	6a 0a                	push   $0xa
  jmp __alltraps
c0102819:	e9 13 0a 00 00       	jmp    c0103231 <__alltraps>

c010281e <vector11>:
.globl vector11
vector11:
  pushl $11
c010281e:	6a 0b                	push   $0xb
  jmp __alltraps
c0102820:	e9 0c 0a 00 00       	jmp    c0103231 <__alltraps>

c0102825 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102825:	6a 0c                	push   $0xc
  jmp __alltraps
c0102827:	e9 05 0a 00 00       	jmp    c0103231 <__alltraps>

c010282c <vector13>:
.globl vector13
vector13:
  pushl $13
c010282c:	6a 0d                	push   $0xd
  jmp __alltraps
c010282e:	e9 fe 09 00 00       	jmp    c0103231 <__alltraps>

c0102833 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102833:	6a 0e                	push   $0xe
  jmp __alltraps
c0102835:	e9 f7 09 00 00       	jmp    c0103231 <__alltraps>

c010283a <vector15>:
.globl vector15
vector15:
  pushl $0
c010283a:	6a 00                	push   $0x0
  pushl $15
c010283c:	6a 0f                	push   $0xf
  jmp __alltraps
c010283e:	e9 ee 09 00 00       	jmp    c0103231 <__alltraps>

c0102843 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102843:	6a 00                	push   $0x0
  pushl $16
c0102845:	6a 10                	push   $0x10
  jmp __alltraps
c0102847:	e9 e5 09 00 00       	jmp    c0103231 <__alltraps>

c010284c <vector17>:
.globl vector17
vector17:
  pushl $17
c010284c:	6a 11                	push   $0x11
  jmp __alltraps
c010284e:	e9 de 09 00 00       	jmp    c0103231 <__alltraps>

c0102853 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102853:	6a 00                	push   $0x0
  pushl $18
c0102855:	6a 12                	push   $0x12
  jmp __alltraps
c0102857:	e9 d5 09 00 00       	jmp    c0103231 <__alltraps>

c010285c <vector19>:
.globl vector19
vector19:
  pushl $0
c010285c:	6a 00                	push   $0x0
  pushl $19
c010285e:	6a 13                	push   $0x13
  jmp __alltraps
c0102860:	e9 cc 09 00 00       	jmp    c0103231 <__alltraps>

c0102865 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102865:	6a 00                	push   $0x0
  pushl $20
c0102867:	6a 14                	push   $0x14
  jmp __alltraps
c0102869:	e9 c3 09 00 00       	jmp    c0103231 <__alltraps>

c010286e <vector21>:
.globl vector21
vector21:
  pushl $0
c010286e:	6a 00                	push   $0x0
  pushl $21
c0102870:	6a 15                	push   $0x15
  jmp __alltraps
c0102872:	e9 ba 09 00 00       	jmp    c0103231 <__alltraps>

c0102877 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102877:	6a 00                	push   $0x0
  pushl $22
c0102879:	6a 16                	push   $0x16
  jmp __alltraps
c010287b:	e9 b1 09 00 00       	jmp    c0103231 <__alltraps>

c0102880 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102880:	6a 00                	push   $0x0
  pushl $23
c0102882:	6a 17                	push   $0x17
  jmp __alltraps
c0102884:	e9 a8 09 00 00       	jmp    c0103231 <__alltraps>

c0102889 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102889:	6a 00                	push   $0x0
  pushl $24
c010288b:	6a 18                	push   $0x18
  jmp __alltraps
c010288d:	e9 9f 09 00 00       	jmp    c0103231 <__alltraps>

c0102892 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102892:	6a 00                	push   $0x0
  pushl $25
c0102894:	6a 19                	push   $0x19
  jmp __alltraps
c0102896:	e9 96 09 00 00       	jmp    c0103231 <__alltraps>

c010289b <vector26>:
.globl vector26
vector26:
  pushl $0
c010289b:	6a 00                	push   $0x0
  pushl $26
c010289d:	6a 1a                	push   $0x1a
  jmp __alltraps
c010289f:	e9 8d 09 00 00       	jmp    c0103231 <__alltraps>

c01028a4 <vector27>:
.globl vector27
vector27:
  pushl $0
c01028a4:	6a 00                	push   $0x0
  pushl $27
c01028a6:	6a 1b                	push   $0x1b
  jmp __alltraps
c01028a8:	e9 84 09 00 00       	jmp    c0103231 <__alltraps>

c01028ad <vector28>:
.globl vector28
vector28:
  pushl $0
c01028ad:	6a 00                	push   $0x0
  pushl $28
c01028af:	6a 1c                	push   $0x1c
  jmp __alltraps
c01028b1:	e9 7b 09 00 00       	jmp    c0103231 <__alltraps>

c01028b6 <vector29>:
.globl vector29
vector29:
  pushl $0
c01028b6:	6a 00                	push   $0x0
  pushl $29
c01028b8:	6a 1d                	push   $0x1d
  jmp __alltraps
c01028ba:	e9 72 09 00 00       	jmp    c0103231 <__alltraps>

c01028bf <vector30>:
.globl vector30
vector30:
  pushl $0
c01028bf:	6a 00                	push   $0x0
  pushl $30
c01028c1:	6a 1e                	push   $0x1e
  jmp __alltraps
c01028c3:	e9 69 09 00 00       	jmp    c0103231 <__alltraps>

c01028c8 <vector31>:
.globl vector31
vector31:
  pushl $0
c01028c8:	6a 00                	push   $0x0
  pushl $31
c01028ca:	6a 1f                	push   $0x1f
  jmp __alltraps
c01028cc:	e9 60 09 00 00       	jmp    c0103231 <__alltraps>

c01028d1 <vector32>:
.globl vector32
vector32:
  pushl $0
c01028d1:	6a 00                	push   $0x0
  pushl $32
c01028d3:	6a 20                	push   $0x20
  jmp __alltraps
c01028d5:	e9 57 09 00 00       	jmp    c0103231 <__alltraps>

c01028da <vector33>:
.globl vector33
vector33:
  pushl $0
c01028da:	6a 00                	push   $0x0
  pushl $33
c01028dc:	6a 21                	push   $0x21
  jmp __alltraps
c01028de:	e9 4e 09 00 00       	jmp    c0103231 <__alltraps>

c01028e3 <vector34>:
.globl vector34
vector34:
  pushl $0
c01028e3:	6a 00                	push   $0x0
  pushl $34
c01028e5:	6a 22                	push   $0x22
  jmp __alltraps
c01028e7:	e9 45 09 00 00       	jmp    c0103231 <__alltraps>

c01028ec <vector35>:
.globl vector35
vector35:
  pushl $0
c01028ec:	6a 00                	push   $0x0
  pushl $35
c01028ee:	6a 23                	push   $0x23
  jmp __alltraps
c01028f0:	e9 3c 09 00 00       	jmp    c0103231 <__alltraps>

c01028f5 <vector36>:
.globl vector36
vector36:
  pushl $0
c01028f5:	6a 00                	push   $0x0
  pushl $36
c01028f7:	6a 24                	push   $0x24
  jmp __alltraps
c01028f9:	e9 33 09 00 00       	jmp    c0103231 <__alltraps>

c01028fe <vector37>:
.globl vector37
vector37:
  pushl $0
c01028fe:	6a 00                	push   $0x0
  pushl $37
c0102900:	6a 25                	push   $0x25
  jmp __alltraps
c0102902:	e9 2a 09 00 00       	jmp    c0103231 <__alltraps>

c0102907 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102907:	6a 00                	push   $0x0
  pushl $38
c0102909:	6a 26                	push   $0x26
  jmp __alltraps
c010290b:	e9 21 09 00 00       	jmp    c0103231 <__alltraps>

c0102910 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102910:	6a 00                	push   $0x0
  pushl $39
c0102912:	6a 27                	push   $0x27
  jmp __alltraps
c0102914:	e9 18 09 00 00       	jmp    c0103231 <__alltraps>

c0102919 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102919:	6a 00                	push   $0x0
  pushl $40
c010291b:	6a 28                	push   $0x28
  jmp __alltraps
c010291d:	e9 0f 09 00 00       	jmp    c0103231 <__alltraps>

c0102922 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102922:	6a 00                	push   $0x0
  pushl $41
c0102924:	6a 29                	push   $0x29
  jmp __alltraps
c0102926:	e9 06 09 00 00       	jmp    c0103231 <__alltraps>

c010292b <vector42>:
.globl vector42
vector42:
  pushl $0
c010292b:	6a 00                	push   $0x0
  pushl $42
c010292d:	6a 2a                	push   $0x2a
  jmp __alltraps
c010292f:	e9 fd 08 00 00       	jmp    c0103231 <__alltraps>

c0102934 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102934:	6a 00                	push   $0x0
  pushl $43
c0102936:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102938:	e9 f4 08 00 00       	jmp    c0103231 <__alltraps>

c010293d <vector44>:
.globl vector44
vector44:
  pushl $0
c010293d:	6a 00                	push   $0x0
  pushl $44
c010293f:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102941:	e9 eb 08 00 00       	jmp    c0103231 <__alltraps>

c0102946 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102946:	6a 00                	push   $0x0
  pushl $45
c0102948:	6a 2d                	push   $0x2d
  jmp __alltraps
c010294a:	e9 e2 08 00 00       	jmp    c0103231 <__alltraps>

c010294f <vector46>:
.globl vector46
vector46:
  pushl $0
c010294f:	6a 00                	push   $0x0
  pushl $46
c0102951:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102953:	e9 d9 08 00 00       	jmp    c0103231 <__alltraps>

c0102958 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102958:	6a 00                	push   $0x0
  pushl $47
c010295a:	6a 2f                	push   $0x2f
  jmp __alltraps
c010295c:	e9 d0 08 00 00       	jmp    c0103231 <__alltraps>

c0102961 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102961:	6a 00                	push   $0x0
  pushl $48
c0102963:	6a 30                	push   $0x30
  jmp __alltraps
c0102965:	e9 c7 08 00 00       	jmp    c0103231 <__alltraps>

c010296a <vector49>:
.globl vector49
vector49:
  pushl $0
c010296a:	6a 00                	push   $0x0
  pushl $49
c010296c:	6a 31                	push   $0x31
  jmp __alltraps
c010296e:	e9 be 08 00 00       	jmp    c0103231 <__alltraps>

c0102973 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102973:	6a 00                	push   $0x0
  pushl $50
c0102975:	6a 32                	push   $0x32
  jmp __alltraps
c0102977:	e9 b5 08 00 00       	jmp    c0103231 <__alltraps>

c010297c <vector51>:
.globl vector51
vector51:
  pushl $0
c010297c:	6a 00                	push   $0x0
  pushl $51
c010297e:	6a 33                	push   $0x33
  jmp __alltraps
c0102980:	e9 ac 08 00 00       	jmp    c0103231 <__alltraps>

c0102985 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102985:	6a 00                	push   $0x0
  pushl $52
c0102987:	6a 34                	push   $0x34
  jmp __alltraps
c0102989:	e9 a3 08 00 00       	jmp    c0103231 <__alltraps>

c010298e <vector53>:
.globl vector53
vector53:
  pushl $0
c010298e:	6a 00                	push   $0x0
  pushl $53
c0102990:	6a 35                	push   $0x35
  jmp __alltraps
c0102992:	e9 9a 08 00 00       	jmp    c0103231 <__alltraps>

c0102997 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102997:	6a 00                	push   $0x0
  pushl $54
c0102999:	6a 36                	push   $0x36
  jmp __alltraps
c010299b:	e9 91 08 00 00       	jmp    c0103231 <__alltraps>

c01029a0 <vector55>:
.globl vector55
vector55:
  pushl $0
c01029a0:	6a 00                	push   $0x0
  pushl $55
c01029a2:	6a 37                	push   $0x37
  jmp __alltraps
c01029a4:	e9 88 08 00 00       	jmp    c0103231 <__alltraps>

c01029a9 <vector56>:
.globl vector56
vector56:
  pushl $0
c01029a9:	6a 00                	push   $0x0
  pushl $56
c01029ab:	6a 38                	push   $0x38
  jmp __alltraps
c01029ad:	e9 7f 08 00 00       	jmp    c0103231 <__alltraps>

c01029b2 <vector57>:
.globl vector57
vector57:
  pushl $0
c01029b2:	6a 00                	push   $0x0
  pushl $57
c01029b4:	6a 39                	push   $0x39
  jmp __alltraps
c01029b6:	e9 76 08 00 00       	jmp    c0103231 <__alltraps>

c01029bb <vector58>:
.globl vector58
vector58:
  pushl $0
c01029bb:	6a 00                	push   $0x0
  pushl $58
c01029bd:	6a 3a                	push   $0x3a
  jmp __alltraps
c01029bf:	e9 6d 08 00 00       	jmp    c0103231 <__alltraps>

c01029c4 <vector59>:
.globl vector59
vector59:
  pushl $0
c01029c4:	6a 00                	push   $0x0
  pushl $59
c01029c6:	6a 3b                	push   $0x3b
  jmp __alltraps
c01029c8:	e9 64 08 00 00       	jmp    c0103231 <__alltraps>

c01029cd <vector60>:
.globl vector60
vector60:
  pushl $0
c01029cd:	6a 00                	push   $0x0
  pushl $60
c01029cf:	6a 3c                	push   $0x3c
  jmp __alltraps
c01029d1:	e9 5b 08 00 00       	jmp    c0103231 <__alltraps>

c01029d6 <vector61>:
.globl vector61
vector61:
  pushl $0
c01029d6:	6a 00                	push   $0x0
  pushl $61
c01029d8:	6a 3d                	push   $0x3d
  jmp __alltraps
c01029da:	e9 52 08 00 00       	jmp    c0103231 <__alltraps>

c01029df <vector62>:
.globl vector62
vector62:
  pushl $0
c01029df:	6a 00                	push   $0x0
  pushl $62
c01029e1:	6a 3e                	push   $0x3e
  jmp __alltraps
c01029e3:	e9 49 08 00 00       	jmp    c0103231 <__alltraps>

c01029e8 <vector63>:
.globl vector63
vector63:
  pushl $0
c01029e8:	6a 00                	push   $0x0
  pushl $63
c01029ea:	6a 3f                	push   $0x3f
  jmp __alltraps
c01029ec:	e9 40 08 00 00       	jmp    c0103231 <__alltraps>

c01029f1 <vector64>:
.globl vector64
vector64:
  pushl $0
c01029f1:	6a 00                	push   $0x0
  pushl $64
c01029f3:	6a 40                	push   $0x40
  jmp __alltraps
c01029f5:	e9 37 08 00 00       	jmp    c0103231 <__alltraps>

c01029fa <vector65>:
.globl vector65
vector65:
  pushl $0
c01029fa:	6a 00                	push   $0x0
  pushl $65
c01029fc:	6a 41                	push   $0x41
  jmp __alltraps
c01029fe:	e9 2e 08 00 00       	jmp    c0103231 <__alltraps>

c0102a03 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102a03:	6a 00                	push   $0x0
  pushl $66
c0102a05:	6a 42                	push   $0x42
  jmp __alltraps
c0102a07:	e9 25 08 00 00       	jmp    c0103231 <__alltraps>

c0102a0c <vector67>:
.globl vector67
vector67:
  pushl $0
c0102a0c:	6a 00                	push   $0x0
  pushl $67
c0102a0e:	6a 43                	push   $0x43
  jmp __alltraps
c0102a10:	e9 1c 08 00 00       	jmp    c0103231 <__alltraps>

c0102a15 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102a15:	6a 00                	push   $0x0
  pushl $68
c0102a17:	6a 44                	push   $0x44
  jmp __alltraps
c0102a19:	e9 13 08 00 00       	jmp    c0103231 <__alltraps>

c0102a1e <vector69>:
.globl vector69
vector69:
  pushl $0
c0102a1e:	6a 00                	push   $0x0
  pushl $69
c0102a20:	6a 45                	push   $0x45
  jmp __alltraps
c0102a22:	e9 0a 08 00 00       	jmp    c0103231 <__alltraps>

c0102a27 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102a27:	6a 00                	push   $0x0
  pushl $70
c0102a29:	6a 46                	push   $0x46
  jmp __alltraps
c0102a2b:	e9 01 08 00 00       	jmp    c0103231 <__alltraps>

c0102a30 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102a30:	6a 00                	push   $0x0
  pushl $71
c0102a32:	6a 47                	push   $0x47
  jmp __alltraps
c0102a34:	e9 f8 07 00 00       	jmp    c0103231 <__alltraps>

c0102a39 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102a39:	6a 00                	push   $0x0
  pushl $72
c0102a3b:	6a 48                	push   $0x48
  jmp __alltraps
c0102a3d:	e9 ef 07 00 00       	jmp    c0103231 <__alltraps>

c0102a42 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102a42:	6a 00                	push   $0x0
  pushl $73
c0102a44:	6a 49                	push   $0x49
  jmp __alltraps
c0102a46:	e9 e6 07 00 00       	jmp    c0103231 <__alltraps>

c0102a4b <vector74>:
.globl vector74
vector74:
  pushl $0
c0102a4b:	6a 00                	push   $0x0
  pushl $74
c0102a4d:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102a4f:	e9 dd 07 00 00       	jmp    c0103231 <__alltraps>

c0102a54 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102a54:	6a 00                	push   $0x0
  pushl $75
c0102a56:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102a58:	e9 d4 07 00 00       	jmp    c0103231 <__alltraps>

c0102a5d <vector76>:
.globl vector76
vector76:
  pushl $0
c0102a5d:	6a 00                	push   $0x0
  pushl $76
c0102a5f:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102a61:	e9 cb 07 00 00       	jmp    c0103231 <__alltraps>

c0102a66 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102a66:	6a 00                	push   $0x0
  pushl $77
c0102a68:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102a6a:	e9 c2 07 00 00       	jmp    c0103231 <__alltraps>

c0102a6f <vector78>:
.globl vector78
vector78:
  pushl $0
c0102a6f:	6a 00                	push   $0x0
  pushl $78
c0102a71:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102a73:	e9 b9 07 00 00       	jmp    c0103231 <__alltraps>

c0102a78 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102a78:	6a 00                	push   $0x0
  pushl $79
c0102a7a:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102a7c:	e9 b0 07 00 00       	jmp    c0103231 <__alltraps>

c0102a81 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102a81:	6a 00                	push   $0x0
  pushl $80
c0102a83:	6a 50                	push   $0x50
  jmp __alltraps
c0102a85:	e9 a7 07 00 00       	jmp    c0103231 <__alltraps>

c0102a8a <vector81>:
.globl vector81
vector81:
  pushl $0
c0102a8a:	6a 00                	push   $0x0
  pushl $81
c0102a8c:	6a 51                	push   $0x51
  jmp __alltraps
c0102a8e:	e9 9e 07 00 00       	jmp    c0103231 <__alltraps>

c0102a93 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102a93:	6a 00                	push   $0x0
  pushl $82
c0102a95:	6a 52                	push   $0x52
  jmp __alltraps
c0102a97:	e9 95 07 00 00       	jmp    c0103231 <__alltraps>

c0102a9c <vector83>:
.globl vector83
vector83:
  pushl $0
c0102a9c:	6a 00                	push   $0x0
  pushl $83
c0102a9e:	6a 53                	push   $0x53
  jmp __alltraps
c0102aa0:	e9 8c 07 00 00       	jmp    c0103231 <__alltraps>

c0102aa5 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102aa5:	6a 00                	push   $0x0
  pushl $84
c0102aa7:	6a 54                	push   $0x54
  jmp __alltraps
c0102aa9:	e9 83 07 00 00       	jmp    c0103231 <__alltraps>

c0102aae <vector85>:
.globl vector85
vector85:
  pushl $0
c0102aae:	6a 00                	push   $0x0
  pushl $85
c0102ab0:	6a 55                	push   $0x55
  jmp __alltraps
c0102ab2:	e9 7a 07 00 00       	jmp    c0103231 <__alltraps>

c0102ab7 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102ab7:	6a 00                	push   $0x0
  pushl $86
c0102ab9:	6a 56                	push   $0x56
  jmp __alltraps
c0102abb:	e9 71 07 00 00       	jmp    c0103231 <__alltraps>

c0102ac0 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102ac0:	6a 00                	push   $0x0
  pushl $87
c0102ac2:	6a 57                	push   $0x57
  jmp __alltraps
c0102ac4:	e9 68 07 00 00       	jmp    c0103231 <__alltraps>

c0102ac9 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102ac9:	6a 00                	push   $0x0
  pushl $88
c0102acb:	6a 58                	push   $0x58
  jmp __alltraps
c0102acd:	e9 5f 07 00 00       	jmp    c0103231 <__alltraps>

c0102ad2 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102ad2:	6a 00                	push   $0x0
  pushl $89
c0102ad4:	6a 59                	push   $0x59
  jmp __alltraps
c0102ad6:	e9 56 07 00 00       	jmp    c0103231 <__alltraps>

c0102adb <vector90>:
.globl vector90
vector90:
  pushl $0
c0102adb:	6a 00                	push   $0x0
  pushl $90
c0102add:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102adf:	e9 4d 07 00 00       	jmp    c0103231 <__alltraps>

c0102ae4 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102ae4:	6a 00                	push   $0x0
  pushl $91
c0102ae6:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102ae8:	e9 44 07 00 00       	jmp    c0103231 <__alltraps>

c0102aed <vector92>:
.globl vector92
vector92:
  pushl $0
c0102aed:	6a 00                	push   $0x0
  pushl $92
c0102aef:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102af1:	e9 3b 07 00 00       	jmp    c0103231 <__alltraps>

c0102af6 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102af6:	6a 00                	push   $0x0
  pushl $93
c0102af8:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102afa:	e9 32 07 00 00       	jmp    c0103231 <__alltraps>

c0102aff <vector94>:
.globl vector94
vector94:
  pushl $0
c0102aff:	6a 00                	push   $0x0
  pushl $94
c0102b01:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102b03:	e9 29 07 00 00       	jmp    c0103231 <__alltraps>

c0102b08 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102b08:	6a 00                	push   $0x0
  pushl $95
c0102b0a:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102b0c:	e9 20 07 00 00       	jmp    c0103231 <__alltraps>

c0102b11 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102b11:	6a 00                	push   $0x0
  pushl $96
c0102b13:	6a 60                	push   $0x60
  jmp __alltraps
c0102b15:	e9 17 07 00 00       	jmp    c0103231 <__alltraps>

c0102b1a <vector97>:
.globl vector97
vector97:
  pushl $0
c0102b1a:	6a 00                	push   $0x0
  pushl $97
c0102b1c:	6a 61                	push   $0x61
  jmp __alltraps
c0102b1e:	e9 0e 07 00 00       	jmp    c0103231 <__alltraps>

c0102b23 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102b23:	6a 00                	push   $0x0
  pushl $98
c0102b25:	6a 62                	push   $0x62
  jmp __alltraps
c0102b27:	e9 05 07 00 00       	jmp    c0103231 <__alltraps>

c0102b2c <vector99>:
.globl vector99
vector99:
  pushl $0
c0102b2c:	6a 00                	push   $0x0
  pushl $99
c0102b2e:	6a 63                	push   $0x63
  jmp __alltraps
c0102b30:	e9 fc 06 00 00       	jmp    c0103231 <__alltraps>

c0102b35 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102b35:	6a 00                	push   $0x0
  pushl $100
c0102b37:	6a 64                	push   $0x64
  jmp __alltraps
c0102b39:	e9 f3 06 00 00       	jmp    c0103231 <__alltraps>

c0102b3e <vector101>:
.globl vector101
vector101:
  pushl $0
c0102b3e:	6a 00                	push   $0x0
  pushl $101
c0102b40:	6a 65                	push   $0x65
  jmp __alltraps
c0102b42:	e9 ea 06 00 00       	jmp    c0103231 <__alltraps>

c0102b47 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102b47:	6a 00                	push   $0x0
  pushl $102
c0102b49:	6a 66                	push   $0x66
  jmp __alltraps
c0102b4b:	e9 e1 06 00 00       	jmp    c0103231 <__alltraps>

c0102b50 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102b50:	6a 00                	push   $0x0
  pushl $103
c0102b52:	6a 67                	push   $0x67
  jmp __alltraps
c0102b54:	e9 d8 06 00 00       	jmp    c0103231 <__alltraps>

c0102b59 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102b59:	6a 00                	push   $0x0
  pushl $104
c0102b5b:	6a 68                	push   $0x68
  jmp __alltraps
c0102b5d:	e9 cf 06 00 00       	jmp    c0103231 <__alltraps>

c0102b62 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102b62:	6a 00                	push   $0x0
  pushl $105
c0102b64:	6a 69                	push   $0x69
  jmp __alltraps
c0102b66:	e9 c6 06 00 00       	jmp    c0103231 <__alltraps>

c0102b6b <vector106>:
.globl vector106
vector106:
  pushl $0
c0102b6b:	6a 00                	push   $0x0
  pushl $106
c0102b6d:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102b6f:	e9 bd 06 00 00       	jmp    c0103231 <__alltraps>

c0102b74 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102b74:	6a 00                	push   $0x0
  pushl $107
c0102b76:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102b78:	e9 b4 06 00 00       	jmp    c0103231 <__alltraps>

c0102b7d <vector108>:
.globl vector108
vector108:
  pushl $0
c0102b7d:	6a 00                	push   $0x0
  pushl $108
c0102b7f:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102b81:	e9 ab 06 00 00       	jmp    c0103231 <__alltraps>

c0102b86 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102b86:	6a 00                	push   $0x0
  pushl $109
c0102b88:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102b8a:	e9 a2 06 00 00       	jmp    c0103231 <__alltraps>

c0102b8f <vector110>:
.globl vector110
vector110:
  pushl $0
c0102b8f:	6a 00                	push   $0x0
  pushl $110
c0102b91:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102b93:	e9 99 06 00 00       	jmp    c0103231 <__alltraps>

c0102b98 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102b98:	6a 00                	push   $0x0
  pushl $111
c0102b9a:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102b9c:	e9 90 06 00 00       	jmp    c0103231 <__alltraps>

c0102ba1 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102ba1:	6a 00                	push   $0x0
  pushl $112
c0102ba3:	6a 70                	push   $0x70
  jmp __alltraps
c0102ba5:	e9 87 06 00 00       	jmp    c0103231 <__alltraps>

c0102baa <vector113>:
.globl vector113
vector113:
  pushl $0
c0102baa:	6a 00                	push   $0x0
  pushl $113
c0102bac:	6a 71                	push   $0x71
  jmp __alltraps
c0102bae:	e9 7e 06 00 00       	jmp    c0103231 <__alltraps>

c0102bb3 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102bb3:	6a 00                	push   $0x0
  pushl $114
c0102bb5:	6a 72                	push   $0x72
  jmp __alltraps
c0102bb7:	e9 75 06 00 00       	jmp    c0103231 <__alltraps>

c0102bbc <vector115>:
.globl vector115
vector115:
  pushl $0
c0102bbc:	6a 00                	push   $0x0
  pushl $115
c0102bbe:	6a 73                	push   $0x73
  jmp __alltraps
c0102bc0:	e9 6c 06 00 00       	jmp    c0103231 <__alltraps>

c0102bc5 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102bc5:	6a 00                	push   $0x0
  pushl $116
c0102bc7:	6a 74                	push   $0x74
  jmp __alltraps
c0102bc9:	e9 63 06 00 00       	jmp    c0103231 <__alltraps>

c0102bce <vector117>:
.globl vector117
vector117:
  pushl $0
c0102bce:	6a 00                	push   $0x0
  pushl $117
c0102bd0:	6a 75                	push   $0x75
  jmp __alltraps
c0102bd2:	e9 5a 06 00 00       	jmp    c0103231 <__alltraps>

c0102bd7 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102bd7:	6a 00                	push   $0x0
  pushl $118
c0102bd9:	6a 76                	push   $0x76
  jmp __alltraps
c0102bdb:	e9 51 06 00 00       	jmp    c0103231 <__alltraps>

c0102be0 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102be0:	6a 00                	push   $0x0
  pushl $119
c0102be2:	6a 77                	push   $0x77
  jmp __alltraps
c0102be4:	e9 48 06 00 00       	jmp    c0103231 <__alltraps>

c0102be9 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102be9:	6a 00                	push   $0x0
  pushl $120
c0102beb:	6a 78                	push   $0x78
  jmp __alltraps
c0102bed:	e9 3f 06 00 00       	jmp    c0103231 <__alltraps>

c0102bf2 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102bf2:	6a 00                	push   $0x0
  pushl $121
c0102bf4:	6a 79                	push   $0x79
  jmp __alltraps
c0102bf6:	e9 36 06 00 00       	jmp    c0103231 <__alltraps>

c0102bfb <vector122>:
.globl vector122
vector122:
  pushl $0
c0102bfb:	6a 00                	push   $0x0
  pushl $122
c0102bfd:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102bff:	e9 2d 06 00 00       	jmp    c0103231 <__alltraps>

c0102c04 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102c04:	6a 00                	push   $0x0
  pushl $123
c0102c06:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102c08:	e9 24 06 00 00       	jmp    c0103231 <__alltraps>

c0102c0d <vector124>:
.globl vector124
vector124:
  pushl $0
c0102c0d:	6a 00                	push   $0x0
  pushl $124
c0102c0f:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102c11:	e9 1b 06 00 00       	jmp    c0103231 <__alltraps>

c0102c16 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102c16:	6a 00                	push   $0x0
  pushl $125
c0102c18:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102c1a:	e9 12 06 00 00       	jmp    c0103231 <__alltraps>

c0102c1f <vector126>:
.globl vector126
vector126:
  pushl $0
c0102c1f:	6a 00                	push   $0x0
  pushl $126
c0102c21:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102c23:	e9 09 06 00 00       	jmp    c0103231 <__alltraps>

c0102c28 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102c28:	6a 00                	push   $0x0
  pushl $127
c0102c2a:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102c2c:	e9 00 06 00 00       	jmp    c0103231 <__alltraps>

c0102c31 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102c31:	6a 00                	push   $0x0
  pushl $128
c0102c33:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102c38:	e9 f4 05 00 00       	jmp    c0103231 <__alltraps>

c0102c3d <vector129>:
.globl vector129
vector129:
  pushl $0
c0102c3d:	6a 00                	push   $0x0
  pushl $129
c0102c3f:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102c44:	e9 e8 05 00 00       	jmp    c0103231 <__alltraps>

c0102c49 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102c49:	6a 00                	push   $0x0
  pushl $130
c0102c4b:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102c50:	e9 dc 05 00 00       	jmp    c0103231 <__alltraps>

c0102c55 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102c55:	6a 00                	push   $0x0
  pushl $131
c0102c57:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102c5c:	e9 d0 05 00 00       	jmp    c0103231 <__alltraps>

c0102c61 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102c61:	6a 00                	push   $0x0
  pushl $132
c0102c63:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102c68:	e9 c4 05 00 00       	jmp    c0103231 <__alltraps>

c0102c6d <vector133>:
.globl vector133
vector133:
  pushl $0
c0102c6d:	6a 00                	push   $0x0
  pushl $133
c0102c6f:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102c74:	e9 b8 05 00 00       	jmp    c0103231 <__alltraps>

c0102c79 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102c79:	6a 00                	push   $0x0
  pushl $134
c0102c7b:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102c80:	e9 ac 05 00 00       	jmp    c0103231 <__alltraps>

c0102c85 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102c85:	6a 00                	push   $0x0
  pushl $135
c0102c87:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102c8c:	e9 a0 05 00 00       	jmp    c0103231 <__alltraps>

c0102c91 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102c91:	6a 00                	push   $0x0
  pushl $136
c0102c93:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102c98:	e9 94 05 00 00       	jmp    c0103231 <__alltraps>

c0102c9d <vector137>:
.globl vector137
vector137:
  pushl $0
c0102c9d:	6a 00                	push   $0x0
  pushl $137
c0102c9f:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102ca4:	e9 88 05 00 00       	jmp    c0103231 <__alltraps>

c0102ca9 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102ca9:	6a 00                	push   $0x0
  pushl $138
c0102cab:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102cb0:	e9 7c 05 00 00       	jmp    c0103231 <__alltraps>

c0102cb5 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102cb5:	6a 00                	push   $0x0
  pushl $139
c0102cb7:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102cbc:	e9 70 05 00 00       	jmp    c0103231 <__alltraps>

c0102cc1 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102cc1:	6a 00                	push   $0x0
  pushl $140
c0102cc3:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102cc8:	e9 64 05 00 00       	jmp    c0103231 <__alltraps>

c0102ccd <vector141>:
.globl vector141
vector141:
  pushl $0
c0102ccd:	6a 00                	push   $0x0
  pushl $141
c0102ccf:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102cd4:	e9 58 05 00 00       	jmp    c0103231 <__alltraps>

c0102cd9 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102cd9:	6a 00                	push   $0x0
  pushl $142
c0102cdb:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102ce0:	e9 4c 05 00 00       	jmp    c0103231 <__alltraps>

c0102ce5 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102ce5:	6a 00                	push   $0x0
  pushl $143
c0102ce7:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102cec:	e9 40 05 00 00       	jmp    c0103231 <__alltraps>

c0102cf1 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102cf1:	6a 00                	push   $0x0
  pushl $144
c0102cf3:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102cf8:	e9 34 05 00 00       	jmp    c0103231 <__alltraps>

c0102cfd <vector145>:
.globl vector145
vector145:
  pushl $0
c0102cfd:	6a 00                	push   $0x0
  pushl $145
c0102cff:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102d04:	e9 28 05 00 00       	jmp    c0103231 <__alltraps>

c0102d09 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102d09:	6a 00                	push   $0x0
  pushl $146
c0102d0b:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102d10:	e9 1c 05 00 00       	jmp    c0103231 <__alltraps>

c0102d15 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102d15:	6a 00                	push   $0x0
  pushl $147
c0102d17:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102d1c:	e9 10 05 00 00       	jmp    c0103231 <__alltraps>

c0102d21 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102d21:	6a 00                	push   $0x0
  pushl $148
c0102d23:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102d28:	e9 04 05 00 00       	jmp    c0103231 <__alltraps>

c0102d2d <vector149>:
.globl vector149
vector149:
  pushl $0
c0102d2d:	6a 00                	push   $0x0
  pushl $149
c0102d2f:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102d34:	e9 f8 04 00 00       	jmp    c0103231 <__alltraps>

c0102d39 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102d39:	6a 00                	push   $0x0
  pushl $150
c0102d3b:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102d40:	e9 ec 04 00 00       	jmp    c0103231 <__alltraps>

c0102d45 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102d45:	6a 00                	push   $0x0
  pushl $151
c0102d47:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102d4c:	e9 e0 04 00 00       	jmp    c0103231 <__alltraps>

c0102d51 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102d51:	6a 00                	push   $0x0
  pushl $152
c0102d53:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102d58:	e9 d4 04 00 00       	jmp    c0103231 <__alltraps>

c0102d5d <vector153>:
.globl vector153
vector153:
  pushl $0
c0102d5d:	6a 00                	push   $0x0
  pushl $153
c0102d5f:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102d64:	e9 c8 04 00 00       	jmp    c0103231 <__alltraps>

c0102d69 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102d69:	6a 00                	push   $0x0
  pushl $154
c0102d6b:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102d70:	e9 bc 04 00 00       	jmp    c0103231 <__alltraps>

c0102d75 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102d75:	6a 00                	push   $0x0
  pushl $155
c0102d77:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102d7c:	e9 b0 04 00 00       	jmp    c0103231 <__alltraps>

c0102d81 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102d81:	6a 00                	push   $0x0
  pushl $156
c0102d83:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102d88:	e9 a4 04 00 00       	jmp    c0103231 <__alltraps>

c0102d8d <vector157>:
.globl vector157
vector157:
  pushl $0
c0102d8d:	6a 00                	push   $0x0
  pushl $157
c0102d8f:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102d94:	e9 98 04 00 00       	jmp    c0103231 <__alltraps>

c0102d99 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102d99:	6a 00                	push   $0x0
  pushl $158
c0102d9b:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102da0:	e9 8c 04 00 00       	jmp    c0103231 <__alltraps>

c0102da5 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102da5:	6a 00                	push   $0x0
  pushl $159
c0102da7:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102dac:	e9 80 04 00 00       	jmp    c0103231 <__alltraps>

c0102db1 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102db1:	6a 00                	push   $0x0
  pushl $160
c0102db3:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102db8:	e9 74 04 00 00       	jmp    c0103231 <__alltraps>

c0102dbd <vector161>:
.globl vector161
vector161:
  pushl $0
c0102dbd:	6a 00                	push   $0x0
  pushl $161
c0102dbf:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102dc4:	e9 68 04 00 00       	jmp    c0103231 <__alltraps>

c0102dc9 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102dc9:	6a 00                	push   $0x0
  pushl $162
c0102dcb:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102dd0:	e9 5c 04 00 00       	jmp    c0103231 <__alltraps>

c0102dd5 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102dd5:	6a 00                	push   $0x0
  pushl $163
c0102dd7:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102ddc:	e9 50 04 00 00       	jmp    c0103231 <__alltraps>

c0102de1 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102de1:	6a 00                	push   $0x0
  pushl $164
c0102de3:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102de8:	e9 44 04 00 00       	jmp    c0103231 <__alltraps>

c0102ded <vector165>:
.globl vector165
vector165:
  pushl $0
c0102ded:	6a 00                	push   $0x0
  pushl $165
c0102def:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102df4:	e9 38 04 00 00       	jmp    c0103231 <__alltraps>

c0102df9 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102df9:	6a 00                	push   $0x0
  pushl $166
c0102dfb:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102e00:	e9 2c 04 00 00       	jmp    c0103231 <__alltraps>

c0102e05 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102e05:	6a 00                	push   $0x0
  pushl $167
c0102e07:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102e0c:	e9 20 04 00 00       	jmp    c0103231 <__alltraps>

c0102e11 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102e11:	6a 00                	push   $0x0
  pushl $168
c0102e13:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102e18:	e9 14 04 00 00       	jmp    c0103231 <__alltraps>

c0102e1d <vector169>:
.globl vector169
vector169:
  pushl $0
c0102e1d:	6a 00                	push   $0x0
  pushl $169
c0102e1f:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102e24:	e9 08 04 00 00       	jmp    c0103231 <__alltraps>

c0102e29 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102e29:	6a 00                	push   $0x0
  pushl $170
c0102e2b:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102e30:	e9 fc 03 00 00       	jmp    c0103231 <__alltraps>

c0102e35 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102e35:	6a 00                	push   $0x0
  pushl $171
c0102e37:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102e3c:	e9 f0 03 00 00       	jmp    c0103231 <__alltraps>

c0102e41 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102e41:	6a 00                	push   $0x0
  pushl $172
c0102e43:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102e48:	e9 e4 03 00 00       	jmp    c0103231 <__alltraps>

c0102e4d <vector173>:
.globl vector173
vector173:
  pushl $0
c0102e4d:	6a 00                	push   $0x0
  pushl $173
c0102e4f:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102e54:	e9 d8 03 00 00       	jmp    c0103231 <__alltraps>

c0102e59 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102e59:	6a 00                	push   $0x0
  pushl $174
c0102e5b:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102e60:	e9 cc 03 00 00       	jmp    c0103231 <__alltraps>

c0102e65 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102e65:	6a 00                	push   $0x0
  pushl $175
c0102e67:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102e6c:	e9 c0 03 00 00       	jmp    c0103231 <__alltraps>

c0102e71 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102e71:	6a 00                	push   $0x0
  pushl $176
c0102e73:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102e78:	e9 b4 03 00 00       	jmp    c0103231 <__alltraps>

c0102e7d <vector177>:
.globl vector177
vector177:
  pushl $0
c0102e7d:	6a 00                	push   $0x0
  pushl $177
c0102e7f:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102e84:	e9 a8 03 00 00       	jmp    c0103231 <__alltraps>

c0102e89 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102e89:	6a 00                	push   $0x0
  pushl $178
c0102e8b:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102e90:	e9 9c 03 00 00       	jmp    c0103231 <__alltraps>

c0102e95 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102e95:	6a 00                	push   $0x0
  pushl $179
c0102e97:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102e9c:	e9 90 03 00 00       	jmp    c0103231 <__alltraps>

c0102ea1 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102ea1:	6a 00                	push   $0x0
  pushl $180
c0102ea3:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102ea8:	e9 84 03 00 00       	jmp    c0103231 <__alltraps>

c0102ead <vector181>:
.globl vector181
vector181:
  pushl $0
c0102ead:	6a 00                	push   $0x0
  pushl $181
c0102eaf:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102eb4:	e9 78 03 00 00       	jmp    c0103231 <__alltraps>

c0102eb9 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102eb9:	6a 00                	push   $0x0
  pushl $182
c0102ebb:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102ec0:	e9 6c 03 00 00       	jmp    c0103231 <__alltraps>

c0102ec5 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102ec5:	6a 00                	push   $0x0
  pushl $183
c0102ec7:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102ecc:	e9 60 03 00 00       	jmp    c0103231 <__alltraps>

c0102ed1 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102ed1:	6a 00                	push   $0x0
  pushl $184
c0102ed3:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102ed8:	e9 54 03 00 00       	jmp    c0103231 <__alltraps>

c0102edd <vector185>:
.globl vector185
vector185:
  pushl $0
c0102edd:	6a 00                	push   $0x0
  pushl $185
c0102edf:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102ee4:	e9 48 03 00 00       	jmp    c0103231 <__alltraps>

c0102ee9 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102ee9:	6a 00                	push   $0x0
  pushl $186
c0102eeb:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102ef0:	e9 3c 03 00 00       	jmp    c0103231 <__alltraps>

c0102ef5 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102ef5:	6a 00                	push   $0x0
  pushl $187
c0102ef7:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102efc:	e9 30 03 00 00       	jmp    c0103231 <__alltraps>

c0102f01 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102f01:	6a 00                	push   $0x0
  pushl $188
c0102f03:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102f08:	e9 24 03 00 00       	jmp    c0103231 <__alltraps>

c0102f0d <vector189>:
.globl vector189
vector189:
  pushl $0
c0102f0d:	6a 00                	push   $0x0
  pushl $189
c0102f0f:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102f14:	e9 18 03 00 00       	jmp    c0103231 <__alltraps>

c0102f19 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102f19:	6a 00                	push   $0x0
  pushl $190
c0102f1b:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102f20:	e9 0c 03 00 00       	jmp    c0103231 <__alltraps>

c0102f25 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102f25:	6a 00                	push   $0x0
  pushl $191
c0102f27:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102f2c:	e9 00 03 00 00       	jmp    c0103231 <__alltraps>

c0102f31 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102f31:	6a 00                	push   $0x0
  pushl $192
c0102f33:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102f38:	e9 f4 02 00 00       	jmp    c0103231 <__alltraps>

c0102f3d <vector193>:
.globl vector193
vector193:
  pushl $0
c0102f3d:	6a 00                	push   $0x0
  pushl $193
c0102f3f:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102f44:	e9 e8 02 00 00       	jmp    c0103231 <__alltraps>

c0102f49 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102f49:	6a 00                	push   $0x0
  pushl $194
c0102f4b:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102f50:	e9 dc 02 00 00       	jmp    c0103231 <__alltraps>

c0102f55 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102f55:	6a 00                	push   $0x0
  pushl $195
c0102f57:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102f5c:	e9 d0 02 00 00       	jmp    c0103231 <__alltraps>

c0102f61 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102f61:	6a 00                	push   $0x0
  pushl $196
c0102f63:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102f68:	e9 c4 02 00 00       	jmp    c0103231 <__alltraps>

c0102f6d <vector197>:
.globl vector197
vector197:
  pushl $0
c0102f6d:	6a 00                	push   $0x0
  pushl $197
c0102f6f:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102f74:	e9 b8 02 00 00       	jmp    c0103231 <__alltraps>

c0102f79 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102f79:	6a 00                	push   $0x0
  pushl $198
c0102f7b:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102f80:	e9 ac 02 00 00       	jmp    c0103231 <__alltraps>

c0102f85 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102f85:	6a 00                	push   $0x0
  pushl $199
c0102f87:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102f8c:	e9 a0 02 00 00       	jmp    c0103231 <__alltraps>

c0102f91 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102f91:	6a 00                	push   $0x0
  pushl $200
c0102f93:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102f98:	e9 94 02 00 00       	jmp    c0103231 <__alltraps>

c0102f9d <vector201>:
.globl vector201
vector201:
  pushl $0
c0102f9d:	6a 00                	push   $0x0
  pushl $201
c0102f9f:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102fa4:	e9 88 02 00 00       	jmp    c0103231 <__alltraps>

c0102fa9 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102fa9:	6a 00                	push   $0x0
  pushl $202
c0102fab:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102fb0:	e9 7c 02 00 00       	jmp    c0103231 <__alltraps>

c0102fb5 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102fb5:	6a 00                	push   $0x0
  pushl $203
c0102fb7:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102fbc:	e9 70 02 00 00       	jmp    c0103231 <__alltraps>

c0102fc1 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102fc1:	6a 00                	push   $0x0
  pushl $204
c0102fc3:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102fc8:	e9 64 02 00 00       	jmp    c0103231 <__alltraps>

c0102fcd <vector205>:
.globl vector205
vector205:
  pushl $0
c0102fcd:	6a 00                	push   $0x0
  pushl $205
c0102fcf:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102fd4:	e9 58 02 00 00       	jmp    c0103231 <__alltraps>

c0102fd9 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102fd9:	6a 00                	push   $0x0
  pushl $206
c0102fdb:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102fe0:	e9 4c 02 00 00       	jmp    c0103231 <__alltraps>

c0102fe5 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102fe5:	6a 00                	push   $0x0
  pushl $207
c0102fe7:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102fec:	e9 40 02 00 00       	jmp    c0103231 <__alltraps>

c0102ff1 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102ff1:	6a 00                	push   $0x0
  pushl $208
c0102ff3:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102ff8:	e9 34 02 00 00       	jmp    c0103231 <__alltraps>

c0102ffd <vector209>:
.globl vector209
vector209:
  pushl $0
c0102ffd:	6a 00                	push   $0x0
  pushl $209
c0102fff:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0103004:	e9 28 02 00 00       	jmp    c0103231 <__alltraps>

c0103009 <vector210>:
.globl vector210
vector210:
  pushl $0
c0103009:	6a 00                	push   $0x0
  pushl $210
c010300b:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0103010:	e9 1c 02 00 00       	jmp    c0103231 <__alltraps>

c0103015 <vector211>:
.globl vector211
vector211:
  pushl $0
c0103015:	6a 00                	push   $0x0
  pushl $211
c0103017:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c010301c:	e9 10 02 00 00       	jmp    c0103231 <__alltraps>

c0103021 <vector212>:
.globl vector212
vector212:
  pushl $0
c0103021:	6a 00                	push   $0x0
  pushl $212
c0103023:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0103028:	e9 04 02 00 00       	jmp    c0103231 <__alltraps>

c010302d <vector213>:
.globl vector213
vector213:
  pushl $0
c010302d:	6a 00                	push   $0x0
  pushl $213
c010302f:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0103034:	e9 f8 01 00 00       	jmp    c0103231 <__alltraps>

c0103039 <vector214>:
.globl vector214
vector214:
  pushl $0
c0103039:	6a 00                	push   $0x0
  pushl $214
c010303b:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0103040:	e9 ec 01 00 00       	jmp    c0103231 <__alltraps>

c0103045 <vector215>:
.globl vector215
vector215:
  pushl $0
c0103045:	6a 00                	push   $0x0
  pushl $215
c0103047:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c010304c:	e9 e0 01 00 00       	jmp    c0103231 <__alltraps>

c0103051 <vector216>:
.globl vector216
vector216:
  pushl $0
c0103051:	6a 00                	push   $0x0
  pushl $216
c0103053:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0103058:	e9 d4 01 00 00       	jmp    c0103231 <__alltraps>

c010305d <vector217>:
.globl vector217
vector217:
  pushl $0
c010305d:	6a 00                	push   $0x0
  pushl $217
c010305f:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0103064:	e9 c8 01 00 00       	jmp    c0103231 <__alltraps>

c0103069 <vector218>:
.globl vector218
vector218:
  pushl $0
c0103069:	6a 00                	push   $0x0
  pushl $218
c010306b:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0103070:	e9 bc 01 00 00       	jmp    c0103231 <__alltraps>

c0103075 <vector219>:
.globl vector219
vector219:
  pushl $0
c0103075:	6a 00                	push   $0x0
  pushl $219
c0103077:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c010307c:	e9 b0 01 00 00       	jmp    c0103231 <__alltraps>

c0103081 <vector220>:
.globl vector220
vector220:
  pushl $0
c0103081:	6a 00                	push   $0x0
  pushl $220
c0103083:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0103088:	e9 a4 01 00 00       	jmp    c0103231 <__alltraps>

c010308d <vector221>:
.globl vector221
vector221:
  pushl $0
c010308d:	6a 00                	push   $0x0
  pushl $221
c010308f:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0103094:	e9 98 01 00 00       	jmp    c0103231 <__alltraps>

c0103099 <vector222>:
.globl vector222
vector222:
  pushl $0
c0103099:	6a 00                	push   $0x0
  pushl $222
c010309b:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01030a0:	e9 8c 01 00 00       	jmp    c0103231 <__alltraps>

c01030a5 <vector223>:
.globl vector223
vector223:
  pushl $0
c01030a5:	6a 00                	push   $0x0
  pushl $223
c01030a7:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01030ac:	e9 80 01 00 00       	jmp    c0103231 <__alltraps>

c01030b1 <vector224>:
.globl vector224
vector224:
  pushl $0
c01030b1:	6a 00                	push   $0x0
  pushl $224
c01030b3:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01030b8:	e9 74 01 00 00       	jmp    c0103231 <__alltraps>

c01030bd <vector225>:
.globl vector225
vector225:
  pushl $0
c01030bd:	6a 00                	push   $0x0
  pushl $225
c01030bf:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01030c4:	e9 68 01 00 00       	jmp    c0103231 <__alltraps>

c01030c9 <vector226>:
.globl vector226
vector226:
  pushl $0
c01030c9:	6a 00                	push   $0x0
  pushl $226
c01030cb:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01030d0:	e9 5c 01 00 00       	jmp    c0103231 <__alltraps>

c01030d5 <vector227>:
.globl vector227
vector227:
  pushl $0
c01030d5:	6a 00                	push   $0x0
  pushl $227
c01030d7:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01030dc:	e9 50 01 00 00       	jmp    c0103231 <__alltraps>

c01030e1 <vector228>:
.globl vector228
vector228:
  pushl $0
c01030e1:	6a 00                	push   $0x0
  pushl $228
c01030e3:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01030e8:	e9 44 01 00 00       	jmp    c0103231 <__alltraps>

c01030ed <vector229>:
.globl vector229
vector229:
  pushl $0
c01030ed:	6a 00                	push   $0x0
  pushl $229
c01030ef:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01030f4:	e9 38 01 00 00       	jmp    c0103231 <__alltraps>

c01030f9 <vector230>:
.globl vector230
vector230:
  pushl $0
c01030f9:	6a 00                	push   $0x0
  pushl $230
c01030fb:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0103100:	e9 2c 01 00 00       	jmp    c0103231 <__alltraps>

c0103105 <vector231>:
.globl vector231
vector231:
  pushl $0
c0103105:	6a 00                	push   $0x0
  pushl $231
c0103107:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c010310c:	e9 20 01 00 00       	jmp    c0103231 <__alltraps>

c0103111 <vector232>:
.globl vector232
vector232:
  pushl $0
c0103111:	6a 00                	push   $0x0
  pushl $232
c0103113:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0103118:	e9 14 01 00 00       	jmp    c0103231 <__alltraps>

c010311d <vector233>:
.globl vector233
vector233:
  pushl $0
c010311d:	6a 00                	push   $0x0
  pushl $233
c010311f:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0103124:	e9 08 01 00 00       	jmp    c0103231 <__alltraps>

c0103129 <vector234>:
.globl vector234
vector234:
  pushl $0
c0103129:	6a 00                	push   $0x0
  pushl $234
c010312b:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0103130:	e9 fc 00 00 00       	jmp    c0103231 <__alltraps>

c0103135 <vector235>:
.globl vector235
vector235:
  pushl $0
c0103135:	6a 00                	push   $0x0
  pushl $235
c0103137:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c010313c:	e9 f0 00 00 00       	jmp    c0103231 <__alltraps>

c0103141 <vector236>:
.globl vector236
vector236:
  pushl $0
c0103141:	6a 00                	push   $0x0
  pushl $236
c0103143:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0103148:	e9 e4 00 00 00       	jmp    c0103231 <__alltraps>

c010314d <vector237>:
.globl vector237
vector237:
  pushl $0
c010314d:	6a 00                	push   $0x0
  pushl $237
c010314f:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0103154:	e9 d8 00 00 00       	jmp    c0103231 <__alltraps>

c0103159 <vector238>:
.globl vector238
vector238:
  pushl $0
c0103159:	6a 00                	push   $0x0
  pushl $238
c010315b:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0103160:	e9 cc 00 00 00       	jmp    c0103231 <__alltraps>

c0103165 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103165:	6a 00                	push   $0x0
  pushl $239
c0103167:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c010316c:	e9 c0 00 00 00       	jmp    c0103231 <__alltraps>

c0103171 <vector240>:
.globl vector240
vector240:
  pushl $0
c0103171:	6a 00                	push   $0x0
  pushl $240
c0103173:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0103178:	e9 b4 00 00 00       	jmp    c0103231 <__alltraps>

c010317d <vector241>:
.globl vector241
vector241:
  pushl $0
c010317d:	6a 00                	push   $0x0
  pushl $241
c010317f:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0103184:	e9 a8 00 00 00       	jmp    c0103231 <__alltraps>

c0103189 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103189:	6a 00                	push   $0x0
  pushl $242
c010318b:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0103190:	e9 9c 00 00 00       	jmp    c0103231 <__alltraps>

c0103195 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103195:	6a 00                	push   $0x0
  pushl $243
c0103197:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c010319c:	e9 90 00 00 00       	jmp    c0103231 <__alltraps>

c01031a1 <vector244>:
.globl vector244
vector244:
  pushl $0
c01031a1:	6a 00                	push   $0x0
  pushl $244
c01031a3:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01031a8:	e9 84 00 00 00       	jmp    c0103231 <__alltraps>

c01031ad <vector245>:
.globl vector245
vector245:
  pushl $0
c01031ad:	6a 00                	push   $0x0
  pushl $245
c01031af:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01031b4:	e9 78 00 00 00       	jmp    c0103231 <__alltraps>

c01031b9 <vector246>:
.globl vector246
vector246:
  pushl $0
c01031b9:	6a 00                	push   $0x0
  pushl $246
c01031bb:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01031c0:	e9 6c 00 00 00       	jmp    c0103231 <__alltraps>

c01031c5 <vector247>:
.globl vector247
vector247:
  pushl $0
c01031c5:	6a 00                	push   $0x0
  pushl $247
c01031c7:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01031cc:	e9 60 00 00 00       	jmp    c0103231 <__alltraps>

c01031d1 <vector248>:
.globl vector248
vector248:
  pushl $0
c01031d1:	6a 00                	push   $0x0
  pushl $248
c01031d3:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01031d8:	e9 54 00 00 00       	jmp    c0103231 <__alltraps>

c01031dd <vector249>:
.globl vector249
vector249:
  pushl $0
c01031dd:	6a 00                	push   $0x0
  pushl $249
c01031df:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01031e4:	e9 48 00 00 00       	jmp    c0103231 <__alltraps>

c01031e9 <vector250>:
.globl vector250
vector250:
  pushl $0
c01031e9:	6a 00                	push   $0x0
  pushl $250
c01031eb:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01031f0:	e9 3c 00 00 00       	jmp    c0103231 <__alltraps>

c01031f5 <vector251>:
.globl vector251
vector251:
  pushl $0
c01031f5:	6a 00                	push   $0x0
  pushl $251
c01031f7:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01031fc:	e9 30 00 00 00       	jmp    c0103231 <__alltraps>

c0103201 <vector252>:
.globl vector252
vector252:
  pushl $0
c0103201:	6a 00                	push   $0x0
  pushl $252
c0103203:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0103208:	e9 24 00 00 00       	jmp    c0103231 <__alltraps>

c010320d <vector253>:
.globl vector253
vector253:
  pushl $0
c010320d:	6a 00                	push   $0x0
  pushl $253
c010320f:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0103214:	e9 18 00 00 00       	jmp    c0103231 <__alltraps>

c0103219 <vector254>:
.globl vector254
vector254:
  pushl $0
c0103219:	6a 00                	push   $0x0
  pushl $254
c010321b:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0103220:	e9 0c 00 00 00       	jmp    c0103231 <__alltraps>

c0103225 <vector255>:
.globl vector255
vector255:
  pushl $0
c0103225:	6a 00                	push   $0x0
  pushl $255
c0103227:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c010322c:	e9 00 00 00 00       	jmp    c0103231 <__alltraps>

c0103231 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0103231:	1e                   	push   %ds
    pushl %es
c0103232:	06                   	push   %es
    pushl %fs
c0103233:	0f a0                	push   %fs
    pushl %gs
c0103235:	0f a8                	push   %gs
    pushal
c0103237:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0103238:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010323d:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010323f:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0103241:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0103242:	e8 64 f5 ff ff       	call   c01027ab <trap>

    # pop the pushed stack pointer
    popl %esp
c0103247:	5c                   	pop    %esp

c0103248 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0103248:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0103249:	0f a9                	pop    %gs
    popl %fs
c010324b:	0f a1                	pop    %fs
    popl %es
c010324d:	07                   	pop    %es
    popl %ds
c010324e:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c010324f:	83 c4 08             	add    $0x8,%esp
    iret
c0103252:	cf                   	iret   

c0103253 <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c0103253:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c0103257:	eb ef                	jmp    c0103248 <__trapret>

c0103259 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0103259:	55                   	push   %ebp
c010325a:	89 e5                	mov    %esp,%ebp
c010325c:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010325f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103262:	c1 e8 0c             	shr    $0xc,%eax
c0103265:	89 c2                	mov    %eax,%edx
c0103267:	a1 80 8f 12 c0       	mov    0xc0128f80,%eax
c010326c:	39 c2                	cmp    %eax,%edx
c010326e:	72 1c                	jb     c010328c <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103270:	c7 44 24 08 50 a6 10 	movl   $0xc010a650,0x8(%esp)
c0103277:	c0 
c0103278:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c010327f:	00 
c0103280:	c7 04 24 6f a6 10 c0 	movl   $0xc010a66f,(%esp)
c0103287:	e8 74 d1 ff ff       	call   c0100400 <__panic>
    }
    return &pages[PPN(pa)];
c010328c:	a1 40 b1 12 c0       	mov    0xc012b140,%eax
c0103291:	8b 55 08             	mov    0x8(%ebp),%edx
c0103294:	c1 ea 0c             	shr    $0xc,%edx
c0103297:	c1 e2 05             	shl    $0x5,%edx
c010329a:	01 d0                	add    %edx,%eax
}
c010329c:	c9                   	leave  
c010329d:	c3                   	ret    

c010329e <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c010329e:	55                   	push   %ebp
c010329f:	89 e5                	mov    %esp,%ebp
c01032a1:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01032a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01032a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01032ac:	89 04 24             	mov    %eax,(%esp)
c01032af:	e8 a5 ff ff ff       	call   c0103259 <pa2page>
}
c01032b4:	c9                   	leave  
c01032b5:	c3                   	ret    

c01032b6 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c01032b6:	55                   	push   %ebp
c01032b7:	89 e5                	mov    %esp,%ebp
c01032b9:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c01032bc:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c01032c3:	e8 c7 1e 00 00       	call   c010518f <kmalloc>
c01032c8:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c01032cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01032cf:	74 58                	je     c0103329 <mm_create+0x73>
        list_init(&(mm->mmap_list));
c01032d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01032d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01032da:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01032dd:	89 50 04             	mov    %edx,0x4(%eax)
c01032e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01032e3:	8b 50 04             	mov    0x4(%eax),%edx
c01032e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01032e9:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c01032eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032ee:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c01032f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032f8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c01032ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103302:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0103309:	a1 68 8f 12 c0       	mov    0xc0128f68,%eax
c010330e:	85 c0                	test   %eax,%eax
c0103310:	74 0d                	je     c010331f <mm_create+0x69>
c0103312:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103315:	89 04 24             	mov    %eax,(%esp)
c0103318:	e8 77 0d 00 00       	call   c0104094 <swap_init_mm>
c010331d:	eb 0a                	jmp    c0103329 <mm_create+0x73>
        else mm->sm_priv = NULL;
c010331f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103322:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c0103329:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010332c:	c9                   	leave  
c010332d:	c3                   	ret    

c010332e <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c010332e:	55                   	push   %ebp
c010332f:	89 e5                	mov    %esp,%ebp
c0103331:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0103334:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c010333b:	e8 4f 1e 00 00       	call   c010518f <kmalloc>
c0103340:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0103343:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103347:	74 1b                	je     c0103364 <vma_create+0x36>
        vma->vm_start = vm_start;
c0103349:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010334c:	8b 55 08             	mov    0x8(%ebp),%edx
c010334f:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0103352:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103355:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103358:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c010335b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010335e:	8b 55 10             	mov    0x10(%ebp),%edx
c0103361:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0103364:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103367:	c9                   	leave  
c0103368:	c3                   	ret    

c0103369 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0103369:	55                   	push   %ebp
c010336a:	89 e5                	mov    %esp,%ebp
c010336c:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c010336f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0103376:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010337a:	0f 84 95 00 00 00    	je     c0103415 <find_vma+0xac>
        vma = mm->mmap_cache;
c0103380:	8b 45 08             	mov    0x8(%ebp),%eax
c0103383:	8b 40 08             	mov    0x8(%eax),%eax
c0103386:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0103389:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010338d:	74 16                	je     c01033a5 <find_vma+0x3c>
c010338f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103392:	8b 40 04             	mov    0x4(%eax),%eax
c0103395:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103398:	77 0b                	ja     c01033a5 <find_vma+0x3c>
c010339a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010339d:	8b 40 08             	mov    0x8(%eax),%eax
c01033a0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01033a3:	77 61                	ja     c0103406 <find_vma+0x9d>
                bool found = 0;
c01033a5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c01033ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01033af:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01033b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c01033b8:	eb 28                	jmp    c01033e2 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c01033ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033bd:	83 e8 10             	sub    $0x10,%eax
c01033c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c01033c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01033c6:	8b 40 04             	mov    0x4(%eax),%eax
c01033c9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01033cc:	77 14                	ja     c01033e2 <find_vma+0x79>
c01033ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01033d1:	8b 40 08             	mov    0x8(%eax),%eax
c01033d4:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01033d7:	76 09                	jbe    c01033e2 <find_vma+0x79>
                        found = 1;
c01033d9:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c01033e0:	eb 17                	jmp    c01033f9 <find_vma+0x90>
c01033e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01033e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01033eb:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c01033ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01033f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033f4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01033f7:	75 c1                	jne    c01033ba <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c01033f9:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c01033fd:	75 07                	jne    c0103406 <find_vma+0x9d>
                    vma = NULL;
c01033ff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0103406:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010340a:	74 09                	je     c0103415 <find_vma+0xac>
            mm->mmap_cache = vma;
c010340c:	8b 45 08             	mov    0x8(%ebp),%eax
c010340f:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103412:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0103415:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0103418:	c9                   	leave  
c0103419:	c3                   	ret    

c010341a <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c010341a:	55                   	push   %ebp
c010341b:	89 e5                	mov    %esp,%ebp
c010341d:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c0103420:	8b 45 08             	mov    0x8(%ebp),%eax
c0103423:	8b 50 04             	mov    0x4(%eax),%edx
c0103426:	8b 45 08             	mov    0x8(%ebp),%eax
c0103429:	8b 40 08             	mov    0x8(%eax),%eax
c010342c:	39 c2                	cmp    %eax,%edx
c010342e:	72 24                	jb     c0103454 <check_vma_overlap+0x3a>
c0103430:	c7 44 24 0c 7d a6 10 	movl   $0xc010a67d,0xc(%esp)
c0103437:	c0 
c0103438:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c010343f:	c0 
c0103440:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c0103447:	00 
c0103448:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c010344f:	e8 ac cf ff ff       	call   c0100400 <__panic>
    assert(prev->vm_end <= next->vm_start);
c0103454:	8b 45 08             	mov    0x8(%ebp),%eax
c0103457:	8b 50 08             	mov    0x8(%eax),%edx
c010345a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010345d:	8b 40 04             	mov    0x4(%eax),%eax
c0103460:	39 c2                	cmp    %eax,%edx
c0103462:	76 24                	jbe    c0103488 <check_vma_overlap+0x6e>
c0103464:	c7 44 24 0c c0 a6 10 	movl   $0xc010a6c0,0xc(%esp)
c010346b:	c0 
c010346c:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c0103473:	c0 
c0103474:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c010347b:	00 
c010347c:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c0103483:	e8 78 cf ff ff       	call   c0100400 <__panic>
    assert(next->vm_start < next->vm_end);
c0103488:	8b 45 0c             	mov    0xc(%ebp),%eax
c010348b:	8b 50 04             	mov    0x4(%eax),%edx
c010348e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103491:	8b 40 08             	mov    0x8(%eax),%eax
c0103494:	39 c2                	cmp    %eax,%edx
c0103496:	72 24                	jb     c01034bc <check_vma_overlap+0xa2>
c0103498:	c7 44 24 0c df a6 10 	movl   $0xc010a6df,0xc(%esp)
c010349f:	c0 
c01034a0:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c01034a7:	c0 
c01034a8:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c01034af:	00 
c01034b0:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c01034b7:	e8 44 cf ff ff       	call   c0100400 <__panic>
}
c01034bc:	90                   	nop
c01034bd:	c9                   	leave  
c01034be:	c3                   	ret    

c01034bf <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c01034bf:	55                   	push   %ebp
c01034c0:	89 e5                	mov    %esp,%ebp
c01034c2:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c01034c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034c8:	8b 50 04             	mov    0x4(%eax),%edx
c01034cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034ce:	8b 40 08             	mov    0x8(%eax),%eax
c01034d1:	39 c2                	cmp    %eax,%edx
c01034d3:	72 24                	jb     c01034f9 <insert_vma_struct+0x3a>
c01034d5:	c7 44 24 0c fd a6 10 	movl   $0xc010a6fd,0xc(%esp)
c01034dc:	c0 
c01034dd:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c01034e4:	c0 
c01034e5:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c01034ec:	00 
c01034ed:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c01034f4:	e8 07 cf ff ff       	call   c0100400 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c01034f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01034fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c01034ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103502:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0103505:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103508:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c010350b:	eb 1f                	jmp    c010352c <insert_vma_struct+0x6d>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c010350d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103510:	83 e8 10             	sub    $0x10,%eax
c0103513:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0103516:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103519:	8b 50 04             	mov    0x4(%eax),%edx
c010351c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010351f:	8b 40 04             	mov    0x4(%eax),%eax
c0103522:	39 c2                	cmp    %eax,%edx
c0103524:	77 1f                	ja     c0103545 <insert_vma_struct+0x86>
                break;
            }
            le_prev = le;
c0103526:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103529:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010352c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010352f:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103532:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103535:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c0103538:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010353b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010353e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103541:	75 ca                	jne    c010350d <insert_vma_struct+0x4e>
c0103543:	eb 01                	jmp    c0103546 <insert_vma_struct+0x87>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
                break;
c0103545:	90                   	nop
c0103546:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103549:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010354c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010354f:	8b 40 04             	mov    0x4(%eax),%eax
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c0103552:	89 45 dc             	mov    %eax,-0x24(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0103555:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103558:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010355b:	74 15                	je     c0103572 <insert_vma_struct+0xb3>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c010355d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103560:	8d 50 f0             	lea    -0x10(%eax),%edx
c0103563:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103566:	89 44 24 04          	mov    %eax,0x4(%esp)
c010356a:	89 14 24             	mov    %edx,(%esp)
c010356d:	e8 a8 fe ff ff       	call   c010341a <check_vma_overlap>
    }
    if (le_next != list) {
c0103572:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103575:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103578:	74 15                	je     c010358f <insert_vma_struct+0xd0>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c010357a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010357d:	83 e8 10             	sub    $0x10,%eax
c0103580:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103584:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103587:	89 04 24             	mov    %eax,(%esp)
c010358a:	e8 8b fe ff ff       	call   c010341a <check_vma_overlap>
    }

    vma->vm_mm = mm;
c010358f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103592:	8b 55 08             	mov    0x8(%ebp),%edx
c0103595:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0103597:	8b 45 0c             	mov    0xc(%ebp),%eax
c010359a:	8d 50 10             	lea    0x10(%eax),%edx
c010359d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01035a3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01035a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01035a9:	8b 40 04             	mov    0x4(%eax),%eax
c01035ac:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01035af:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01035b2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01035b5:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01035b8:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01035bb:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01035be:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01035c1:	89 10                	mov    %edx,(%eax)
c01035c3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01035c6:	8b 10                	mov    (%eax),%edx
c01035c8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01035cb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01035ce:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01035d1:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01035d4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01035d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01035da:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01035dd:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c01035df:	8b 45 08             	mov    0x8(%ebp),%eax
c01035e2:	8b 40 10             	mov    0x10(%eax),%eax
c01035e5:	8d 50 01             	lea    0x1(%eax),%edx
c01035e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01035eb:	89 50 10             	mov    %edx,0x10(%eax)
}
c01035ee:	90                   	nop
c01035ef:	c9                   	leave  
c01035f0:	c3                   	ret    

c01035f1 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c01035f1:	55                   	push   %ebp
c01035f2:	89 e5                	mov    %esp,%ebp
c01035f4:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c01035f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01035fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c01035fd:	eb 36                	jmp    c0103635 <mm_destroy+0x44>
c01035ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103602:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103605:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103608:	8b 40 04             	mov    0x4(%eax),%eax
c010360b:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010360e:	8b 12                	mov    (%edx),%edx
c0103610:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0103613:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103616:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103619:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010361c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010361f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103622:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103625:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c0103627:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010362a:	83 e8 10             	sub    $0x10,%eax
c010362d:	89 04 24             	mov    %eax,(%esp)
c0103630:	e8 75 1b 00 00       	call   c01051aa <kfree>
c0103635:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103638:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010363b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010363e:	8b 40 04             	mov    0x4(%eax),%eax
// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c0103641:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103644:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103647:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010364a:	75 b3                	jne    c01035ff <mm_destroy+0xe>
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
    }
    kfree(mm); //kfree mm
c010364c:	8b 45 08             	mov    0x8(%ebp),%eax
c010364f:	89 04 24             	mov    %eax,(%esp)
c0103652:	e8 53 1b 00 00       	call   c01051aa <kfree>
    mm=NULL;
c0103657:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c010365e:	90                   	nop
c010365f:	c9                   	leave  
c0103660:	c3                   	ret    

c0103661 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0103661:	55                   	push   %ebp
c0103662:	89 e5                	mov    %esp,%ebp
c0103664:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0103667:	e8 03 00 00 00       	call   c010366f <check_vmm>
}
c010366c:	90                   	nop
c010366d:	c9                   	leave  
c010366e:	c3                   	ret    

c010366f <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c010366f:	55                   	push   %ebp
c0103670:	89 e5                	mov    %esp,%ebp
c0103672:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103675:	e8 4b 36 00 00       	call   c0106cc5 <nr_free_pages>
c010367a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c010367d:	e8 14 00 00 00       	call   c0103696 <check_vma_struct>
    check_pgfault();
c0103682:	e8 a1 04 00 00       	call   c0103b28 <check_pgfault>

    cprintf("check_vmm() succeeded.\n");
c0103687:	c7 04 24 19 a7 10 c0 	movl   $0xc010a719,(%esp)
c010368e:	e8 16 cc ff ff       	call   c01002a9 <cprintf>
}
c0103693:	90                   	nop
c0103694:	c9                   	leave  
c0103695:	c3                   	ret    

c0103696 <check_vma_struct>:

static void
check_vma_struct(void) {
c0103696:	55                   	push   %ebp
c0103697:	89 e5                	mov    %esp,%ebp
c0103699:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010369c:	e8 24 36 00 00       	call   c0106cc5 <nr_free_pages>
c01036a1:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c01036a4:	e8 0d fc ff ff       	call   c01032b6 <mm_create>
c01036a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c01036ac:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01036b0:	75 24                	jne    c01036d6 <check_vma_struct+0x40>
c01036b2:	c7 44 24 0c 31 a7 10 	movl   $0xc010a731,0xc(%esp)
c01036b9:	c0 
c01036ba:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c01036c1:	c0 
c01036c2:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
c01036c9:	00 
c01036ca:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c01036d1:	e8 2a cd ff ff       	call   c0100400 <__panic>

    int step1 = 10, step2 = step1 * 10;
c01036d6:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c01036dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01036e0:	89 d0                	mov    %edx,%eax
c01036e2:	c1 e0 02             	shl    $0x2,%eax
c01036e5:	01 d0                	add    %edx,%eax
c01036e7:	01 c0                	add    %eax,%eax
c01036e9:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c01036ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01036ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01036f2:	eb 6f                	jmp    c0103763 <check_vma_struct+0xcd>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01036f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01036f7:	89 d0                	mov    %edx,%eax
c01036f9:	c1 e0 02             	shl    $0x2,%eax
c01036fc:	01 d0                	add    %edx,%eax
c01036fe:	83 c0 02             	add    $0x2,%eax
c0103701:	89 c1                	mov    %eax,%ecx
c0103703:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103706:	89 d0                	mov    %edx,%eax
c0103708:	c1 e0 02             	shl    $0x2,%eax
c010370b:	01 d0                	add    %edx,%eax
c010370d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103714:	00 
c0103715:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103719:	89 04 24             	mov    %eax,(%esp)
c010371c:	e8 0d fc ff ff       	call   c010332e <vma_create>
c0103721:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c0103724:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103728:	75 24                	jne    c010374e <check_vma_struct+0xb8>
c010372a:	c7 44 24 0c 3c a7 10 	movl   $0xc010a73c,0xc(%esp)
c0103731:	c0 
c0103732:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c0103739:	c0 
c010373a:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0103741:	00 
c0103742:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c0103749:	e8 b2 cc ff ff       	call   c0100400 <__panic>
        insert_vma_struct(mm, vma);
c010374e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103751:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103755:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103758:	89 04 24             	mov    %eax,(%esp)
c010375b:	e8 5f fd ff ff       	call   c01034bf <insert_vma_struct>
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c0103760:	ff 4d f4             	decl   -0xc(%ebp)
c0103763:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103767:	7f 8b                	jg     c01036f4 <check_vma_struct+0x5e>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0103769:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010376c:	40                   	inc    %eax
c010376d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103770:	eb 6f                	jmp    c01037e1 <check_vma_struct+0x14b>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0103772:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103775:	89 d0                	mov    %edx,%eax
c0103777:	c1 e0 02             	shl    $0x2,%eax
c010377a:	01 d0                	add    %edx,%eax
c010377c:	83 c0 02             	add    $0x2,%eax
c010377f:	89 c1                	mov    %eax,%ecx
c0103781:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103784:	89 d0                	mov    %edx,%eax
c0103786:	c1 e0 02             	shl    $0x2,%eax
c0103789:	01 d0                	add    %edx,%eax
c010378b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103792:	00 
c0103793:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103797:	89 04 24             	mov    %eax,(%esp)
c010379a:	e8 8f fb ff ff       	call   c010332e <vma_create>
c010379f:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c01037a2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01037a6:	75 24                	jne    c01037cc <check_vma_struct+0x136>
c01037a8:	c7 44 24 0c 3c a7 10 	movl   $0xc010a73c,0xc(%esp)
c01037af:	c0 
c01037b0:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c01037b7:	c0 
c01037b8:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
c01037bf:	00 
c01037c0:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c01037c7:	e8 34 cc ff ff       	call   c0100400 <__panic>
        insert_vma_struct(mm, vma);
c01037cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01037cf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01037d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01037d6:	89 04 24             	mov    %eax,(%esp)
c01037d9:	e8 e1 fc ff ff       	call   c01034bf <insert_vma_struct>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c01037de:	ff 45 f4             	incl   -0xc(%ebp)
c01037e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037e4:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01037e7:	7e 89                	jle    c0103772 <check_vma_struct+0xdc>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c01037e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01037ec:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c01037ef:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01037f2:	8b 40 04             	mov    0x4(%eax),%eax
c01037f5:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c01037f8:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c01037ff:	e9 96 00 00 00       	jmp    c010389a <check_vma_struct+0x204>
        assert(le != &(mm->mmap_list));
c0103804:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103807:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010380a:	75 24                	jne    c0103830 <check_vma_struct+0x19a>
c010380c:	c7 44 24 0c 48 a7 10 	movl   $0xc010a748,0xc(%esp)
c0103813:	c0 
c0103814:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c010381b:	c0 
c010381c:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0103823:	00 
c0103824:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c010382b:	e8 d0 cb ff ff       	call   c0100400 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0103830:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103833:	83 e8 10             	sub    $0x10,%eax
c0103836:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0103839:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010383c:	8b 48 04             	mov    0x4(%eax),%ecx
c010383f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103842:	89 d0                	mov    %edx,%eax
c0103844:	c1 e0 02             	shl    $0x2,%eax
c0103847:	01 d0                	add    %edx,%eax
c0103849:	39 c1                	cmp    %eax,%ecx
c010384b:	75 17                	jne    c0103864 <check_vma_struct+0x1ce>
c010384d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103850:	8b 48 08             	mov    0x8(%eax),%ecx
c0103853:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103856:	89 d0                	mov    %edx,%eax
c0103858:	c1 e0 02             	shl    $0x2,%eax
c010385b:	01 d0                	add    %edx,%eax
c010385d:	83 c0 02             	add    $0x2,%eax
c0103860:	39 c1                	cmp    %eax,%ecx
c0103862:	74 24                	je     c0103888 <check_vma_struct+0x1f2>
c0103864:	c7 44 24 0c 60 a7 10 	movl   $0xc010a760,0xc(%esp)
c010386b:	c0 
c010386c:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c0103873:	c0 
c0103874:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c010387b:	00 
c010387c:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c0103883:	e8 78 cb ff ff       	call   c0100400 <__panic>
c0103888:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010388b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010388e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103891:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0103894:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c0103897:	ff 45 f4             	incl   -0xc(%ebp)
c010389a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010389d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01038a0:	0f 8e 5e ff ff ff    	jle    c0103804 <check_vma_struct+0x16e>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c01038a6:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c01038ad:	e9 cb 01 00 00       	jmp    c0103a7d <check_vma_struct+0x3e7>
        struct vma_struct *vma1 = find_vma(mm, i);
c01038b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038b5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01038b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01038bc:	89 04 24             	mov    %eax,(%esp)
c01038bf:	e8 a5 fa ff ff       	call   c0103369 <find_vma>
c01038c4:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma1 != NULL);
c01038c7:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01038cb:	75 24                	jne    c01038f1 <check_vma_struct+0x25b>
c01038cd:	c7 44 24 0c 95 a7 10 	movl   $0xc010a795,0xc(%esp)
c01038d4:	c0 
c01038d5:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c01038dc:	c0 
c01038dd:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c01038e4:	00 
c01038e5:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c01038ec:	e8 0f cb ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c01038f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038f4:	40                   	inc    %eax
c01038f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01038f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01038fc:	89 04 24             	mov    %eax,(%esp)
c01038ff:	e8 65 fa ff ff       	call   c0103369 <find_vma>
c0103904:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma2 != NULL);
c0103907:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010390b:	75 24                	jne    c0103931 <check_vma_struct+0x29b>
c010390d:	c7 44 24 0c a2 a7 10 	movl   $0xc010a7a2,0xc(%esp)
c0103914:	c0 
c0103915:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c010391c:	c0 
c010391d:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0103924:	00 
c0103925:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c010392c:	e8 cf ca ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0103931:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103934:	83 c0 02             	add    $0x2,%eax
c0103937:	89 44 24 04          	mov    %eax,0x4(%esp)
c010393b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010393e:	89 04 24             	mov    %eax,(%esp)
c0103941:	e8 23 fa ff ff       	call   c0103369 <find_vma>
c0103946:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma3 == NULL);
c0103949:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c010394d:	74 24                	je     c0103973 <check_vma_struct+0x2dd>
c010394f:	c7 44 24 0c af a7 10 	movl   $0xc010a7af,0xc(%esp)
c0103956:	c0 
c0103957:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c010395e:	c0 
c010395f:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0103966:	00 
c0103967:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c010396e:	e8 8d ca ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0103973:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103976:	83 c0 03             	add    $0x3,%eax
c0103979:	89 44 24 04          	mov    %eax,0x4(%esp)
c010397d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103980:	89 04 24             	mov    %eax,(%esp)
c0103983:	e8 e1 f9 ff ff       	call   c0103369 <find_vma>
c0103988:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma4 == NULL);
c010398b:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c010398f:	74 24                	je     c01039b5 <check_vma_struct+0x31f>
c0103991:	c7 44 24 0c bc a7 10 	movl   $0xc010a7bc,0xc(%esp)
c0103998:	c0 
c0103999:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c01039a0:	c0 
c01039a1:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c01039a8:	00 
c01039a9:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c01039b0:	e8 4b ca ff ff       	call   c0100400 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c01039b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039b8:	83 c0 04             	add    $0x4,%eax
c01039bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01039bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039c2:	89 04 24             	mov    %eax,(%esp)
c01039c5:	e8 9f f9 ff ff       	call   c0103369 <find_vma>
c01039ca:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma5 == NULL);
c01039cd:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01039d1:	74 24                	je     c01039f7 <check_vma_struct+0x361>
c01039d3:	c7 44 24 0c c9 a7 10 	movl   $0xc010a7c9,0xc(%esp)
c01039da:	c0 
c01039db:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c01039e2:	c0 
c01039e3:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c01039ea:	00 
c01039eb:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c01039f2:	e8 09 ca ff ff       	call   c0100400 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c01039f7:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01039fa:	8b 50 04             	mov    0x4(%eax),%edx
c01039fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a00:	39 c2                	cmp    %eax,%edx
c0103a02:	75 10                	jne    c0103a14 <check_vma_struct+0x37e>
c0103a04:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103a07:	8b 40 08             	mov    0x8(%eax),%eax
c0103a0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103a0d:	83 c2 02             	add    $0x2,%edx
c0103a10:	39 d0                	cmp    %edx,%eax
c0103a12:	74 24                	je     c0103a38 <check_vma_struct+0x3a2>
c0103a14:	c7 44 24 0c d8 a7 10 	movl   $0xc010a7d8,0xc(%esp)
c0103a1b:	c0 
c0103a1c:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c0103a23:	c0 
c0103a24:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0103a2b:	00 
c0103a2c:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c0103a33:	e8 c8 c9 ff ff       	call   c0100400 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0103a38:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103a3b:	8b 50 04             	mov    0x4(%eax),%edx
c0103a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a41:	39 c2                	cmp    %eax,%edx
c0103a43:	75 10                	jne    c0103a55 <check_vma_struct+0x3bf>
c0103a45:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103a48:	8b 40 08             	mov    0x8(%eax),%eax
c0103a4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103a4e:	83 c2 02             	add    $0x2,%edx
c0103a51:	39 d0                	cmp    %edx,%eax
c0103a53:	74 24                	je     c0103a79 <check_vma_struct+0x3e3>
c0103a55:	c7 44 24 0c 08 a8 10 	movl   $0xc010a808,0xc(%esp)
c0103a5c:	c0 
c0103a5d:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c0103a64:	c0 
c0103a65:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0103a6c:	00 
c0103a6d:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c0103a74:	e8 87 c9 ff ff       	call   c0100400 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0103a79:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0103a7d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103a80:	89 d0                	mov    %edx,%eax
c0103a82:	c1 e0 02             	shl    $0x2,%eax
c0103a85:	01 d0                	add    %edx,%eax
c0103a87:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103a8a:	0f 8d 22 fe ff ff    	jge    c01038b2 <check_vma_struct+0x21c>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0103a90:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0103a97:	eb 6f                	jmp    c0103b08 <check_vma_struct+0x472>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0103a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103aa0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103aa3:	89 04 24             	mov    %eax,(%esp)
c0103aa6:	e8 be f8 ff ff       	call   c0103369 <find_vma>
c0103aab:	89 45 b8             	mov    %eax,-0x48(%ebp)
        if (vma_below_5 != NULL ) {
c0103aae:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0103ab2:	74 27                	je     c0103adb <check_vma_struct+0x445>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0103ab4:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103ab7:	8b 50 08             	mov    0x8(%eax),%edx
c0103aba:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103abd:	8b 40 04             	mov    0x4(%eax),%eax
c0103ac0:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0103ac4:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103acb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103acf:	c7 04 24 38 a8 10 c0 	movl   $0xc010a838,(%esp)
c0103ad6:	e8 ce c7 ff ff       	call   c01002a9 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0103adb:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0103adf:	74 24                	je     c0103b05 <check_vma_struct+0x46f>
c0103ae1:	c7 44 24 0c 5d a8 10 	movl   $0xc010a85d,0xc(%esp)
c0103ae8:	c0 
c0103ae9:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c0103af0:	c0 
c0103af1:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0103af8:	00 
c0103af9:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c0103b00:	e8 fb c8 ff ff       	call   c0100400 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0103b05:	ff 4d f4             	decl   -0xc(%ebp)
c0103b08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103b0c:	79 8b                	jns    c0103a99 <check_vma_struct+0x403>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c0103b0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103b11:	89 04 24             	mov    %eax,(%esp)
c0103b14:	e8 d8 fa ff ff       	call   c01035f1 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
c0103b19:	c7 04 24 74 a8 10 c0 	movl   $0xc010a874,(%esp)
c0103b20:	e8 84 c7 ff ff       	call   c01002a9 <cprintf>
}
c0103b25:	90                   	nop
c0103b26:	c9                   	leave  
c0103b27:	c3                   	ret    

c0103b28 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0103b28:	55                   	push   %ebp
c0103b29:	89 e5                	mov    %esp,%ebp
c0103b2b:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103b2e:	e8 92 31 00 00       	call   c0106cc5 <nr_free_pages>
c0103b33:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0103b36:	e8 7b f7 ff ff       	call   c01032b6 <mm_create>
c0103b3b:	a3 58 b0 12 c0       	mov    %eax,0xc012b058
    assert(check_mm_struct != NULL);
c0103b40:	a1 58 b0 12 c0       	mov    0xc012b058,%eax
c0103b45:	85 c0                	test   %eax,%eax
c0103b47:	75 24                	jne    c0103b6d <check_pgfault+0x45>
c0103b49:	c7 44 24 0c 93 a8 10 	movl   $0xc010a893,0xc(%esp)
c0103b50:	c0 
c0103b51:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c0103b58:	c0 
c0103b59:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0103b60:	00 
c0103b61:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c0103b68:	e8 93 c8 ff ff       	call   c0100400 <__panic>

    struct mm_struct *mm = check_mm_struct;
c0103b6d:	a1 58 b0 12 c0       	mov    0xc012b058,%eax
c0103b72:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0103b75:	8b 15 20 5a 12 c0    	mov    0xc0125a20,%edx
c0103b7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103b7e:	89 50 0c             	mov    %edx,0xc(%eax)
c0103b81:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103b84:	8b 40 0c             	mov    0xc(%eax),%eax
c0103b87:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0103b8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b8d:	8b 00                	mov    (%eax),%eax
c0103b8f:	85 c0                	test   %eax,%eax
c0103b91:	74 24                	je     c0103bb7 <check_pgfault+0x8f>
c0103b93:	c7 44 24 0c ab a8 10 	movl   $0xc010a8ab,0xc(%esp)
c0103b9a:	c0 
c0103b9b:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c0103ba2:	c0 
c0103ba3:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c0103baa:	00 
c0103bab:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c0103bb2:	e8 49 c8 ff ff       	call   c0100400 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0103bb7:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0103bbe:	00 
c0103bbf:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0103bc6:	00 
c0103bc7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0103bce:	e8 5b f7 ff ff       	call   c010332e <vma_create>
c0103bd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0103bd6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103bda:	75 24                	jne    c0103c00 <check_pgfault+0xd8>
c0103bdc:	c7 44 24 0c 3c a7 10 	movl   $0xc010a73c,0xc(%esp)
c0103be3:	c0 
c0103be4:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c0103beb:	c0 
c0103bec:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0103bf3:	00 
c0103bf4:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c0103bfb:	e8 00 c8 ff ff       	call   c0100400 <__panic>

    insert_vma_struct(mm, vma);
c0103c00:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c03:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c07:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c0a:	89 04 24             	mov    %eax,(%esp)
c0103c0d:	e8 ad f8 ff ff       	call   c01034bf <insert_vma_struct>

    uintptr_t addr = 0x100;
c0103c12:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0103c19:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c1c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c20:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c23:	89 04 24             	mov    %eax,(%esp)
c0103c26:	e8 3e f7 ff ff       	call   c0103369 <find_vma>
c0103c2b:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103c2e:	74 24                	je     c0103c54 <check_pgfault+0x12c>
c0103c30:	c7 44 24 0c b9 a8 10 	movl   $0xc010a8b9,0xc(%esp)
c0103c37:	c0 
c0103c38:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c0103c3f:	c0 
c0103c40:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
c0103c47:	00 
c0103c48:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c0103c4f:	e8 ac c7 ff ff       	call   c0100400 <__panic>

    int i, sum = 0;
c0103c54:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0103c5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103c62:	eb 16                	jmp    c0103c7a <check_pgfault+0x152>
        *(char *)(addr + i) = i;
c0103c64:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103c67:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c6a:	01 d0                	add    %edx,%eax
c0103c6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103c6f:	88 10                	mov    %dl,(%eax)
        sum += i;
c0103c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c74:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c0103c77:	ff 45 f4             	incl   -0xc(%ebp)
c0103c7a:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0103c7e:	7e e4                	jle    c0103c64 <check_pgfault+0x13c>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0103c80:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103c87:	eb 14                	jmp    c0103c9d <check_pgfault+0x175>
        sum -= *(char *)(addr + i);
c0103c89:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103c8c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103c8f:	01 d0                	add    %edx,%eax
c0103c91:	0f b6 00             	movzbl (%eax),%eax
c0103c94:	0f be c0             	movsbl %al,%eax
c0103c97:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0103c9a:	ff 45 f4             	incl   -0xc(%ebp)
c0103c9d:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0103ca1:	7e e6                	jle    c0103c89 <check_pgfault+0x161>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c0103ca3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103ca7:	74 24                	je     c0103ccd <check_pgfault+0x1a5>
c0103ca9:	c7 44 24 0c d3 a8 10 	movl   $0xc010a8d3,0xc(%esp)
c0103cb0:	c0 
c0103cb1:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c0103cb8:	c0 
c0103cb9:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0103cc0:	00 
c0103cc1:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c0103cc8:	e8 33 c7 ff ff       	call   c0100400 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0103ccd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103cd0:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103cd3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103cd6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103cdf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ce2:	89 04 24             	mov    %eax,(%esp)
c0103ce5:	e8 03 38 00 00       	call   c01074ed <page_remove>
    free_page(pde2page(pgdir[0]));
c0103cea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ced:	8b 00                	mov    (%eax),%eax
c0103cef:	89 04 24             	mov    %eax,(%esp)
c0103cf2:	e8 a7 f5 ff ff       	call   c010329e <pde2page>
c0103cf7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103cfe:	00 
c0103cff:	89 04 24             	mov    %eax,(%esp)
c0103d02:	e8 8b 2f 00 00       	call   c0106c92 <free_pages>
    pgdir[0] = 0;
c0103d07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d0a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0103d10:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103d13:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0103d1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103d1d:	89 04 24             	mov    %eax,(%esp)
c0103d20:	e8 cc f8 ff ff       	call   c01035f1 <mm_destroy>
    check_mm_struct = NULL;
c0103d25:	c7 05 58 b0 12 c0 00 	movl   $0x0,0xc012b058
c0103d2c:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0103d2f:	e8 91 2f 00 00       	call   c0106cc5 <nr_free_pages>
c0103d34:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103d37:	74 24                	je     c0103d5d <check_pgfault+0x235>
c0103d39:	c7 44 24 0c dc a8 10 	movl   $0xc010a8dc,0xc(%esp)
c0103d40:	c0 
c0103d41:	c7 44 24 08 9b a6 10 	movl   $0xc010a69b,0x8(%esp)
c0103d48:	c0 
c0103d49:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c0103d50:	00 
c0103d51:	c7 04 24 b0 a6 10 c0 	movl   $0xc010a6b0,(%esp)
c0103d58:	e8 a3 c6 ff ff       	call   c0100400 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0103d5d:	c7 04 24 03 a9 10 c0 	movl   $0xc010a903,(%esp)
c0103d64:	e8 40 c5 ff ff       	call   c01002a9 <cprintf>
}
c0103d69:	90                   	nop
c0103d6a:	c9                   	leave  
c0103d6b:	c3                   	ret    

c0103d6c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0103d6c:	55                   	push   %ebp
c0103d6d:	89 e5                	mov    %esp,%ebp
c0103d6f:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0103d72:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0103d79:	8b 45 10             	mov    0x10(%ebp),%eax
c0103d7c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d80:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d83:	89 04 24             	mov    %eax,(%esp)
c0103d86:	e8 de f5 ff ff       	call   c0103369 <find_vma>
c0103d8b:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0103d8e:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c0103d93:	40                   	inc    %eax
c0103d94:	a3 64 8f 12 c0       	mov    %eax,0xc0128f64
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0103d99:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103d9d:	74 0b                	je     c0103daa <do_pgfault+0x3e>
c0103d9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103da2:	8b 40 04             	mov    0x4(%eax),%eax
c0103da5:	3b 45 10             	cmp    0x10(%ebp),%eax
c0103da8:	76 18                	jbe    c0103dc2 <do_pgfault+0x56>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0103daa:	8b 45 10             	mov    0x10(%ebp),%eax
c0103dad:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103db1:	c7 04 24 20 a9 10 c0 	movl   $0xc010a920,(%esp)
c0103db8:	e8 ec c4 ff ff       	call   c01002a9 <cprintf>
        goto failed;
c0103dbd:	e9 ba 01 00 00       	jmp    c0103f7c <do_pgfault+0x210>
    }
    //check the error_code
    switch (error_code & 3) {
c0103dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103dc5:	83 e0 03             	and    $0x3,%eax
c0103dc8:	85 c0                	test   %eax,%eax
c0103dca:	74 34                	je     c0103e00 <do_pgfault+0x94>
c0103dcc:	83 f8 01             	cmp    $0x1,%eax
c0103dcf:	74 1e                	je     c0103def <do_pgfault+0x83>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0103dd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103dd4:	8b 40 0c             	mov    0xc(%eax),%eax
c0103dd7:	83 e0 02             	and    $0x2,%eax
c0103dda:	85 c0                	test   %eax,%eax
c0103ddc:	75 40                	jne    c0103e1e <do_pgfault+0xb2>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0103dde:	c7 04 24 50 a9 10 c0 	movl   $0xc010a950,(%esp)
c0103de5:	e8 bf c4 ff ff       	call   c01002a9 <cprintf>
            goto failed;
c0103dea:	e9 8d 01 00 00       	jmp    c0103f7c <do_pgfault+0x210>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0103def:	c7 04 24 b0 a9 10 c0 	movl   $0xc010a9b0,(%esp)
c0103df6:	e8 ae c4 ff ff       	call   c01002a9 <cprintf>
        goto failed;
c0103dfb:	e9 7c 01 00 00       	jmp    c0103f7c <do_pgfault+0x210>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0103e00:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e03:	8b 40 0c             	mov    0xc(%eax),%eax
c0103e06:	83 e0 05             	and    $0x5,%eax
c0103e09:	85 c0                	test   %eax,%eax
c0103e0b:	75 12                	jne    c0103e1f <do_pgfault+0xb3>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0103e0d:	c7 04 24 e8 a9 10 c0 	movl   $0xc010a9e8,(%esp)
c0103e14:	e8 90 c4 ff ff       	call   c01002a9 <cprintf>
            goto failed;
c0103e19:	e9 5e 01 00 00       	jmp    c0103f7c <do_pgfault+0x210>
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
            goto failed;
        }
        break;
c0103e1e:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0103e1f:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0103e26:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e29:	8b 40 0c             	mov    0xc(%eax),%eax
c0103e2c:	83 e0 02             	and    $0x2,%eax
c0103e2f:	85 c0                	test   %eax,%eax
c0103e31:	74 04                	je     c0103e37 <do_pgfault+0xcb>
        perm |= PTE_W;
c0103e33:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0103e37:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e3a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103e3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e40:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103e45:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0103e48:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0103e4f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
   }
#endif
    if((ptep=get_pte(mm->pgdir,addr,1))==NULL)
c0103e56:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e59:	8b 40 0c             	mov    0xc(%eax),%eax
c0103e5c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103e63:	00 
c0103e64:	8b 55 10             	mov    0x10(%ebp),%edx
c0103e67:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103e6b:	89 04 24             	mov    %eax,(%esp)
c0103e6e:	e8 86 34 00 00       	call   c01072f9 <get_pte>
c0103e73:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103e76:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103e7a:	75 11                	jne    c0103e8d <do_pgfault+0x121>
    {
        cprintf("do_pgfault failed: get_pte return NULL");
c0103e7c:	c7 04 24 4c aa 10 c0 	movl   $0xc010aa4c,(%esp)
c0103e83:	e8 21 c4 ff ff       	call   c01002a9 <cprintf>
        goto failed;
c0103e88:	e9 ef 00 00 00       	jmp    c0103f7c <do_pgfault+0x210>
    }
    if(*ptep == 0)
c0103e8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e90:	8b 00                	mov    (%eax),%eax
c0103e92:	85 c0                	test   %eax,%eax
c0103e94:	75 35                	jne    c0103ecb <do_pgfault+0x15f>
    {
        if(pgdir_alloc_page(mm->pgdir,addr,perm)==NULL)
c0103e96:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e99:	8b 40 0c             	mov    0xc(%eax),%eax
c0103e9c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103e9f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103ea3:	8b 55 10             	mov    0x10(%ebp),%edx
c0103ea6:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103eaa:	89 04 24             	mov    %eax,(%esp)
c0103ead:	e8 95 37 00 00       	call   c0107647 <pgdir_alloc_page>
c0103eb2:	85 c0                	test   %eax,%eax
c0103eb4:	0f 85 bb 00 00 00    	jne    c0103f75 <do_pgfault+0x209>
        {
            cprintf("do_pgfault failed: pgdir_alloc_page return NULL");
c0103eba:	c7 04 24 74 aa 10 c0 	movl   $0xc010aa74,(%esp)
c0103ec1:	e8 e3 c3 ff ff       	call   c01002a9 <cprintf>
            goto failed;
c0103ec6:	e9 b1 00 00 00       	jmp    c0103f7c <do_pgfault+0x210>

        }
    }
    else
    {
        if(swap_init_ok) {
c0103ecb:	a1 68 8f 12 c0       	mov    0xc0128f68,%eax
c0103ed0:	85 c0                	test   %eax,%eax
c0103ed2:	0f 84 86 00 00 00    	je     c0103f5e <do_pgfault+0x1f2>
            struct Page *page=NULL;
c0103ed8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c0103edf:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0103ee2:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103ee6:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ee9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103eed:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ef0:	89 04 24             	mov    %eax,(%esp)
c0103ef3:	e8 8e 03 00 00       	call   c0104286 <swap_in>
c0103ef8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103efb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103eff:	74 0e                	je     c0103f0f <do_pgfault+0x1a3>
                cprintf("do_pgfault failed: swap_in returned not 0\n");
c0103f01:	c7 04 24 a4 aa 10 c0 	movl   $0xc010aaa4,(%esp)
c0103f08:	e8 9c c3 ff ff       	call   c01002a9 <cprintf>
c0103f0d:	eb 6d                	jmp    c0103f7c <do_pgfault+0x210>
                goto failed;
            }
            page_insert(mm->pgdir, page, addr, perm);
c0103f0f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103f12:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f15:	8b 40 0c             	mov    0xc(%eax),%eax
c0103f18:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0103f1b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0103f1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0103f22:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0103f26:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103f2a:	89 04 24             	mov    %eax,(%esp)
c0103f2d:	e8 00 36 00 00       	call   c0107532 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
c0103f32:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f35:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0103f3c:	00 
c0103f3d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103f41:	8b 45 10             	mov    0x10(%ebp),%eax
c0103f44:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103f48:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f4b:	89 04 24             	mov    %eax,(%esp)
c0103f4e:	e8 71 01 00 00       	call   c01040c4 <swap_map_swappable>
            page->pra_vaddr = addr;
c0103f53:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f56:	8b 55 10             	mov    0x10(%ebp),%edx
c0103f59:	89 50 1c             	mov    %edx,0x1c(%eax)
c0103f5c:	eb 17                	jmp    c0103f75 <do_pgfault+0x209>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0103f5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f61:	8b 00                	mov    (%eax),%eax
c0103f63:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103f67:	c7 04 24 d0 aa 10 c0 	movl   $0xc010aad0,(%esp)
c0103f6e:	e8 36 c3 ff ff       	call   c01002a9 <cprintf>
            goto failed;
c0103f73:	eb 07                	jmp    c0103f7c <do_pgfault+0x210>
        }
    }
    ret = 0;
c0103f75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    failed:
    return ret;
c0103f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax

}
c0103f7f:	c9                   	leave  
c0103f80:	c3                   	ret    

c0103f81 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0103f81:	55                   	push   %ebp
c0103f82:	89 e5                	mov    %esp,%ebp
c0103f84:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103f87:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f8a:	c1 e8 0c             	shr    $0xc,%eax
c0103f8d:	89 c2                	mov    %eax,%edx
c0103f8f:	a1 80 8f 12 c0       	mov    0xc0128f80,%eax
c0103f94:	39 c2                	cmp    %eax,%edx
c0103f96:	72 1c                	jb     c0103fb4 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103f98:	c7 44 24 08 f8 aa 10 	movl   $0xc010aaf8,0x8(%esp)
c0103f9f:	c0 
c0103fa0:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0103fa7:	00 
c0103fa8:	c7 04 24 17 ab 10 c0 	movl   $0xc010ab17,(%esp)
c0103faf:	e8 4c c4 ff ff       	call   c0100400 <__panic>
    }
    return &pages[PPN(pa)];
c0103fb4:	a1 40 b1 12 c0       	mov    0xc012b140,%eax
c0103fb9:	8b 55 08             	mov    0x8(%ebp),%edx
c0103fbc:	c1 ea 0c             	shr    $0xc,%edx
c0103fbf:	c1 e2 05             	shl    $0x5,%edx
c0103fc2:	01 d0                	add    %edx,%eax
}
c0103fc4:	c9                   	leave  
c0103fc5:	c3                   	ret    

c0103fc6 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0103fc6:	55                   	push   %ebp
c0103fc7:	89 e5                	mov    %esp,%ebp
c0103fc9:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0103fcc:	8b 45 08             	mov    0x8(%ebp),%eax
c0103fcf:	83 e0 01             	and    $0x1,%eax
c0103fd2:	85 c0                	test   %eax,%eax
c0103fd4:	75 1c                	jne    c0103ff2 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103fd6:	c7 44 24 08 28 ab 10 	movl   $0xc010ab28,0x8(%esp)
c0103fdd:	c0 
c0103fde:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0103fe5:	00 
c0103fe6:	c7 04 24 17 ab 10 c0 	movl   $0xc010ab17,(%esp)
c0103fed:	e8 0e c4 ff ff       	call   c0100400 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0103ff2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ff5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103ffa:	89 04 24             	mov    %eax,(%esp)
c0103ffd:	e8 7f ff ff ff       	call   c0103f81 <pa2page>
}
c0104002:	c9                   	leave  
c0104003:	c3                   	ret    

c0104004 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0104004:	55                   	push   %ebp
c0104005:	89 e5                	mov    %esp,%ebp
c0104007:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c010400a:	e8 28 44 00 00       	call   c0108437 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c010400f:	a1 fc b0 12 c0       	mov    0xc012b0fc,%eax
c0104014:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0104019:	76 0c                	jbe    c0104027 <swap_init+0x23>
c010401b:	a1 fc b0 12 c0       	mov    0xc012b0fc,%eax
c0104020:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0104025:	76 25                	jbe    c010404c <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0104027:	a1 fc b0 12 c0       	mov    0xc012b0fc,%eax
c010402c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104030:	c7 44 24 08 49 ab 10 	movl   $0xc010ab49,0x8(%esp)
c0104037:	c0 
c0104038:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
c010403f:	00 
c0104040:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c0104047:	e8 b4 c3 ff ff       	call   c0100400 <__panic>
     }
     

     sm = &swap_manager_fifo;
c010404c:	c7 05 70 8f 12 c0 00 	movl   $0xc0125a00,0xc0128f70
c0104053:	5a 12 c0 
     int r = sm->init();
c0104056:	a1 70 8f 12 c0       	mov    0xc0128f70,%eax
c010405b:	8b 40 04             	mov    0x4(%eax),%eax
c010405e:	ff d0                	call   *%eax
c0104060:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0104063:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104067:	75 26                	jne    c010408f <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0104069:	c7 05 68 8f 12 c0 01 	movl   $0x1,0xc0128f68
c0104070:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0104073:	a1 70 8f 12 c0       	mov    0xc0128f70,%eax
c0104078:	8b 00                	mov    (%eax),%eax
c010407a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010407e:	c7 04 24 73 ab 10 c0 	movl   $0xc010ab73,(%esp)
c0104085:	e8 1f c2 ff ff       	call   c01002a9 <cprintf>
          check_swap();
c010408a:	e8 9e 04 00 00       	call   c010452d <check_swap>
     }

     return r;
c010408f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104092:	c9                   	leave  
c0104093:	c3                   	ret    

c0104094 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0104094:	55                   	push   %ebp
c0104095:	89 e5                	mov    %esp,%ebp
c0104097:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c010409a:	a1 70 8f 12 c0       	mov    0xc0128f70,%eax
c010409f:	8b 40 08             	mov    0x8(%eax),%eax
c01040a2:	8b 55 08             	mov    0x8(%ebp),%edx
c01040a5:	89 14 24             	mov    %edx,(%esp)
c01040a8:	ff d0                	call   *%eax
}
c01040aa:	c9                   	leave  
c01040ab:	c3                   	ret    

c01040ac <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c01040ac:	55                   	push   %ebp
c01040ad:	89 e5                	mov    %esp,%ebp
c01040af:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c01040b2:	a1 70 8f 12 c0       	mov    0xc0128f70,%eax
c01040b7:	8b 40 0c             	mov    0xc(%eax),%eax
c01040ba:	8b 55 08             	mov    0x8(%ebp),%edx
c01040bd:	89 14 24             	mov    %edx,(%esp)
c01040c0:	ff d0                	call   *%eax
}
c01040c2:	c9                   	leave  
c01040c3:	c3                   	ret    

c01040c4 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01040c4:	55                   	push   %ebp
c01040c5:	89 e5                	mov    %esp,%ebp
c01040c7:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c01040ca:	a1 70 8f 12 c0       	mov    0xc0128f70,%eax
c01040cf:	8b 40 10             	mov    0x10(%eax),%eax
c01040d2:	8b 55 14             	mov    0x14(%ebp),%edx
c01040d5:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01040d9:	8b 55 10             	mov    0x10(%ebp),%edx
c01040dc:	89 54 24 08          	mov    %edx,0x8(%esp)
c01040e0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01040e3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01040e7:	8b 55 08             	mov    0x8(%ebp),%edx
c01040ea:	89 14 24             	mov    %edx,(%esp)
c01040ed:	ff d0                	call   *%eax
}
c01040ef:	c9                   	leave  
c01040f0:	c3                   	ret    

c01040f1 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01040f1:	55                   	push   %ebp
c01040f2:	89 e5                	mov    %esp,%ebp
c01040f4:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c01040f7:	a1 70 8f 12 c0       	mov    0xc0128f70,%eax
c01040fc:	8b 40 14             	mov    0x14(%eax),%eax
c01040ff:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104102:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104106:	8b 55 08             	mov    0x8(%ebp),%edx
c0104109:	89 14 24             	mov    %edx,(%esp)
c010410c:	ff d0                	call   *%eax
}
c010410e:	c9                   	leave  
c010410f:	c3                   	ret    

c0104110 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0104110:	55                   	push   %ebp
c0104111:	89 e5                	mov    %esp,%ebp
c0104113:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0104116:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010411d:	e9 53 01 00 00       	jmp    c0104275 <swap_out+0x165>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0104122:	a1 70 8f 12 c0       	mov    0xc0128f70,%eax
c0104127:	8b 40 18             	mov    0x18(%eax),%eax
c010412a:	8b 55 10             	mov    0x10(%ebp),%edx
c010412d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0104131:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0104134:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104138:	8b 55 08             	mov    0x8(%ebp),%edx
c010413b:	89 14 24             	mov    %edx,(%esp)
c010413e:	ff d0                	call   *%eax
c0104140:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0104143:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104147:	74 18                	je     c0104161 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0104149:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010414c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104150:	c7 04 24 88 ab 10 c0 	movl   $0xc010ab88,(%esp)
c0104157:	e8 4d c1 ff ff       	call   c01002a9 <cprintf>
c010415c:	e9 20 01 00 00       	jmp    c0104281 <swap_out+0x171>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0104161:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104164:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104167:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c010416a:	8b 45 08             	mov    0x8(%ebp),%eax
c010416d:	8b 40 0c             	mov    0xc(%eax),%eax
c0104170:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104177:	00 
c0104178:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010417b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010417f:	89 04 24             	mov    %eax,(%esp)
c0104182:	e8 72 31 00 00       	call   c01072f9 <get_pte>
c0104187:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c010418a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010418d:	8b 00                	mov    (%eax),%eax
c010418f:	83 e0 01             	and    $0x1,%eax
c0104192:	85 c0                	test   %eax,%eax
c0104194:	75 24                	jne    c01041ba <swap_out+0xaa>
c0104196:	c7 44 24 0c b5 ab 10 	movl   $0xc010abb5,0xc(%esp)
c010419d:	c0 
c010419e:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c01041a5:	c0 
c01041a6:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01041ad:	00 
c01041ae:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c01041b5:	e8 46 c2 ff ff       	call   c0100400 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c01041ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01041bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01041c0:	8b 52 1c             	mov    0x1c(%edx),%edx
c01041c3:	c1 ea 0c             	shr    $0xc,%edx
c01041c6:	42                   	inc    %edx
c01041c7:	c1 e2 08             	shl    $0x8,%edx
c01041ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01041ce:	89 14 24             	mov    %edx,(%esp)
c01041d1:	e8 1c 43 00 00       	call   c01084f2 <swapfs_write>
c01041d6:	85 c0                	test   %eax,%eax
c01041d8:	74 34                	je     c010420e <swap_out+0xfe>
                    cprintf("SWAP: failed to save\n");
c01041da:	c7 04 24 df ab 10 c0 	movl   $0xc010abdf,(%esp)
c01041e1:	e8 c3 c0 ff ff       	call   c01002a9 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c01041e6:	a1 70 8f 12 c0       	mov    0xc0128f70,%eax
c01041eb:	8b 40 10             	mov    0x10(%eax),%eax
c01041ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01041f1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01041f8:	00 
c01041f9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01041fd:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104200:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104204:	8b 55 08             	mov    0x8(%ebp),%edx
c0104207:	89 14 24             	mov    %edx,(%esp)
c010420a:	ff d0                	call   *%eax
c010420c:	eb 64                	jmp    c0104272 <swap_out+0x162>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c010420e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104211:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104214:	c1 e8 0c             	shr    $0xc,%eax
c0104217:	40                   	inc    %eax
c0104218:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010421c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010421f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104223:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104226:	89 44 24 04          	mov    %eax,0x4(%esp)
c010422a:	c7 04 24 f8 ab 10 c0 	movl   $0xc010abf8,(%esp)
c0104231:	e8 73 c0 ff ff       	call   c01002a9 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0104236:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104239:	8b 40 1c             	mov    0x1c(%eax),%eax
c010423c:	c1 e8 0c             	shr    $0xc,%eax
c010423f:	40                   	inc    %eax
c0104240:	c1 e0 08             	shl    $0x8,%eax
c0104243:	89 c2                	mov    %eax,%edx
c0104245:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104248:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c010424a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010424d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104254:	00 
c0104255:	89 04 24             	mov    %eax,(%esp)
c0104258:	e8 35 2a 00 00       	call   c0106c92 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c010425d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104260:	8b 40 0c             	mov    0xc(%eax),%eax
c0104263:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104266:	89 54 24 04          	mov    %edx,0x4(%esp)
c010426a:	89 04 24             	mov    %eax,(%esp)
c010426d:	e8 79 33 00 00       	call   c01075eb <tlb_invalidate>

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c0104272:	ff 45 f4             	incl   -0xc(%ebp)
c0104275:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104278:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010427b:	0f 85 a1 fe ff ff    	jne    c0104122 <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c0104281:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104284:	c9                   	leave  
c0104285:	c3                   	ret    

c0104286 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0104286:	55                   	push   %ebp
c0104287:	89 e5                	mov    %esp,%ebp
c0104289:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c010428c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104293:	e8 8f 29 00 00       	call   c0106c27 <alloc_pages>
c0104298:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c010429b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010429f:	75 24                	jne    c01042c5 <swap_in+0x3f>
c01042a1:	c7 44 24 0c 38 ac 10 	movl   $0xc010ac38,0xc(%esp)
c01042a8:	c0 
c01042a9:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c01042b0:	c0 
c01042b1:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
c01042b8:	00 
c01042b9:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c01042c0:	e8 3b c1 ff ff       	call   c0100400 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c01042c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01042c8:	8b 40 0c             	mov    0xc(%eax),%eax
c01042cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01042d2:	00 
c01042d3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01042d6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01042da:	89 04 24             	mov    %eax,(%esp)
c01042dd:	e8 17 30 00 00       	call   c01072f9 <get_pte>
c01042e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c01042e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01042e8:	8b 00                	mov    (%eax),%eax
c01042ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01042ed:	89 54 24 04          	mov    %edx,0x4(%esp)
c01042f1:	89 04 24             	mov    %eax,(%esp)
c01042f4:	e8 87 41 00 00       	call   c0108480 <swapfs_read>
c01042f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01042fc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104300:	74 2a                	je     c010432c <swap_in+0xa6>
     {
        assert(r!=0);
c0104302:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104306:	75 24                	jne    c010432c <swap_in+0xa6>
c0104308:	c7 44 24 0c 45 ac 10 	movl   $0xc010ac45,0xc(%esp)
c010430f:	c0 
c0104310:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c0104317:	c0 
c0104318:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c010431f:	00 
c0104320:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c0104327:	e8 d4 c0 ff ff       	call   c0100400 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c010432c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010432f:	8b 00                	mov    (%eax),%eax
c0104331:	c1 e8 08             	shr    $0x8,%eax
c0104334:	89 c2                	mov    %eax,%edx
c0104336:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104339:	89 44 24 08          	mov    %eax,0x8(%esp)
c010433d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104341:	c7 04 24 4c ac 10 c0 	movl   $0xc010ac4c,(%esp)
c0104348:	e8 5c bf ff ff       	call   c01002a9 <cprintf>
     *ptr_result=result;
c010434d:	8b 45 10             	mov    0x10(%ebp),%eax
c0104350:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104353:	89 10                	mov    %edx,(%eax)
     return 0;
c0104355:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010435a:	c9                   	leave  
c010435b:	c3                   	ret    

c010435c <check_content_set>:



static inline void
check_content_set(void)
{
c010435c:	55                   	push   %ebp
c010435d:	89 e5                	mov    %esp,%ebp
c010435f:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0104362:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104367:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c010436a:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c010436f:	83 f8 01             	cmp    $0x1,%eax
c0104372:	74 24                	je     c0104398 <check_content_set+0x3c>
c0104374:	c7 44 24 0c 8a ac 10 	movl   $0xc010ac8a,0xc(%esp)
c010437b:	c0 
c010437c:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c0104383:	c0 
c0104384:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c010438b:	00 
c010438c:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c0104393:	e8 68 c0 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0104398:	b8 10 10 00 00       	mov    $0x1010,%eax
c010439d:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01043a0:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c01043a5:	83 f8 01             	cmp    $0x1,%eax
c01043a8:	74 24                	je     c01043ce <check_content_set+0x72>
c01043aa:	c7 44 24 0c 8a ac 10 	movl   $0xc010ac8a,0xc(%esp)
c01043b1:	c0 
c01043b2:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c01043b9:	c0 
c01043ba:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c01043c1:	00 
c01043c2:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c01043c9:	e8 32 c0 ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c01043ce:	b8 00 20 00 00       	mov    $0x2000,%eax
c01043d3:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c01043d6:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c01043db:	83 f8 02             	cmp    $0x2,%eax
c01043de:	74 24                	je     c0104404 <check_content_set+0xa8>
c01043e0:	c7 44 24 0c 99 ac 10 	movl   $0xc010ac99,0xc(%esp)
c01043e7:	c0 
c01043e8:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c01043ef:	c0 
c01043f0:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c01043f7:	00 
c01043f8:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c01043ff:	e8 fc bf ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0104404:	b8 10 20 00 00       	mov    $0x2010,%eax
c0104409:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c010440c:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c0104411:	83 f8 02             	cmp    $0x2,%eax
c0104414:	74 24                	je     c010443a <check_content_set+0xde>
c0104416:	c7 44 24 0c 99 ac 10 	movl   $0xc010ac99,0xc(%esp)
c010441d:	c0 
c010441e:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c0104425:	c0 
c0104426:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c010442d:	00 
c010442e:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c0104435:	e8 c6 bf ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c010443a:	b8 00 30 00 00       	mov    $0x3000,%eax
c010443f:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0104442:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c0104447:	83 f8 03             	cmp    $0x3,%eax
c010444a:	74 24                	je     c0104470 <check_content_set+0x114>
c010444c:	c7 44 24 0c a8 ac 10 	movl   $0xc010aca8,0xc(%esp)
c0104453:	c0 
c0104454:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c010445b:	c0 
c010445c:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0104463:	00 
c0104464:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c010446b:	e8 90 bf ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0104470:	b8 10 30 00 00       	mov    $0x3010,%eax
c0104475:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0104478:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c010447d:	83 f8 03             	cmp    $0x3,%eax
c0104480:	74 24                	je     c01044a6 <check_content_set+0x14a>
c0104482:	c7 44 24 0c a8 ac 10 	movl   $0xc010aca8,0xc(%esp)
c0104489:	c0 
c010448a:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c0104491:	c0 
c0104492:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0104499:	00 
c010449a:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c01044a1:	e8 5a bf ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c01044a6:	b8 00 40 00 00       	mov    $0x4000,%eax
c01044ab:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01044ae:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c01044b3:	83 f8 04             	cmp    $0x4,%eax
c01044b6:	74 24                	je     c01044dc <check_content_set+0x180>
c01044b8:	c7 44 24 0c b7 ac 10 	movl   $0xc010acb7,0xc(%esp)
c01044bf:	c0 
c01044c0:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c01044c7:	c0 
c01044c8:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c01044cf:	00 
c01044d0:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c01044d7:	e8 24 bf ff ff       	call   c0100400 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c01044dc:	b8 10 40 00 00       	mov    $0x4010,%eax
c01044e1:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01044e4:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c01044e9:	83 f8 04             	cmp    $0x4,%eax
c01044ec:	74 24                	je     c0104512 <check_content_set+0x1b6>
c01044ee:	c7 44 24 0c b7 ac 10 	movl   $0xc010acb7,0xc(%esp)
c01044f5:	c0 
c01044f6:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c01044fd:	c0 
c01044fe:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0104505:	00 
c0104506:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c010450d:	e8 ee be ff ff       	call   c0100400 <__panic>
}
c0104512:	90                   	nop
c0104513:	c9                   	leave  
c0104514:	c3                   	ret    

c0104515 <check_content_access>:

static inline int
check_content_access(void)
{
c0104515:	55                   	push   %ebp
c0104516:	89 e5                	mov    %esp,%ebp
c0104518:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c010451b:	a1 70 8f 12 c0       	mov    0xc0128f70,%eax
c0104520:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104523:	ff d0                	call   *%eax
c0104525:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0104528:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010452b:	c9                   	leave  
c010452c:	c3                   	ret    

c010452d <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c010452d:	55                   	push   %ebp
c010452e:	89 e5                	mov    %esp,%ebp
c0104530:	83 ec 78             	sub    $0x78,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0104533:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010453a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0104541:	c7 45 e8 2c b1 12 c0 	movl   $0xc012b12c,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0104548:	eb 6a                	jmp    c01045b4 <check_swap+0x87>
        struct Page *p = le2page(le, page_link);
c010454a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010454d:	83 e8 0c             	sub    $0xc,%eax
c0104550:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(PageProperty(p));
c0104553:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104556:	83 c0 04             	add    $0x4,%eax
c0104559:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0104560:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104563:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104566:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104569:	0f a3 10             	bt     %edx,(%eax)
c010456c:	19 c0                	sbb    %eax,%eax
c010456e:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c0104571:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c0104575:	0f 95 c0             	setne  %al
c0104578:	0f b6 c0             	movzbl %al,%eax
c010457b:	85 c0                	test   %eax,%eax
c010457d:	75 24                	jne    c01045a3 <check_swap+0x76>
c010457f:	c7 44 24 0c c6 ac 10 	movl   $0xc010acc6,0xc(%esp)
c0104586:	c0 
c0104587:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c010458e:	c0 
c010458f:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0104596:	00 
c0104597:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c010459e:	e8 5d be ff ff       	call   c0100400 <__panic>
        count ++, total += p->property;
c01045a3:	ff 45 f4             	incl   -0xc(%ebp)
c01045a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01045a9:	8b 50 08             	mov    0x8(%eax),%edx
c01045ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045af:	01 d0                	add    %edx,%eax
c01045b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01045b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01045b7:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01045ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01045bd:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c01045c0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01045c3:	81 7d e8 2c b1 12 c0 	cmpl   $0xc012b12c,-0x18(%ebp)
c01045ca:	0f 85 7a ff ff ff    	jne    c010454a <check_swap+0x1d>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c01045d0:	e8 f0 26 00 00       	call   c0106cc5 <nr_free_pages>
c01045d5:	89 c2                	mov    %eax,%edx
c01045d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045da:	39 c2                	cmp    %eax,%edx
c01045dc:	74 24                	je     c0104602 <check_swap+0xd5>
c01045de:	c7 44 24 0c d6 ac 10 	movl   $0xc010acd6,0xc(%esp)
c01045e5:	c0 
c01045e6:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c01045ed:	c0 
c01045ee:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c01045f5:	00 
c01045f6:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c01045fd:	e8 fe bd ff ff       	call   c0100400 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0104602:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104605:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104609:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010460c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104610:	c7 04 24 f0 ac 10 c0 	movl   $0xc010acf0,(%esp)
c0104617:	e8 8d bc ff ff       	call   c01002a9 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c010461c:	e8 95 ec ff ff       	call   c01032b6 <mm_create>
c0104621:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(mm != NULL);
c0104624:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0104628:	75 24                	jne    c010464e <check_swap+0x121>
c010462a:	c7 44 24 0c 16 ad 10 	movl   $0xc010ad16,0xc(%esp)
c0104631:	c0 
c0104632:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c0104639:	c0 
c010463a:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c0104641:	00 
c0104642:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c0104649:	e8 b2 bd ff ff       	call   c0100400 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c010464e:	a1 58 b0 12 c0       	mov    0xc012b058,%eax
c0104653:	85 c0                	test   %eax,%eax
c0104655:	74 24                	je     c010467b <check_swap+0x14e>
c0104657:	c7 44 24 0c 21 ad 10 	movl   $0xc010ad21,0xc(%esp)
c010465e:	c0 
c010465f:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c0104666:	c0 
c0104667:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c010466e:	00 
c010466f:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c0104676:	e8 85 bd ff ff       	call   c0100400 <__panic>

     check_mm_struct = mm;
c010467b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010467e:	a3 58 b0 12 c0       	mov    %eax,0xc012b058

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0104683:	8b 15 20 5a 12 c0    	mov    0xc0125a20,%edx
c0104689:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010468c:	89 50 0c             	mov    %edx,0xc(%eax)
c010468f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104692:	8b 40 0c             	mov    0xc(%eax),%eax
c0104695:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(pgdir[0] == 0);
c0104698:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010469b:	8b 00                	mov    (%eax),%eax
c010469d:	85 c0                	test   %eax,%eax
c010469f:	74 24                	je     c01046c5 <check_swap+0x198>
c01046a1:	c7 44 24 0c 39 ad 10 	movl   $0xc010ad39,0xc(%esp)
c01046a8:	c0 
c01046a9:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c01046b0:	c0 
c01046b1:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c01046b8:	00 
c01046b9:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c01046c0:	e8 3b bd ff ff       	call   c0100400 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c01046c5:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c01046cc:	00 
c01046cd:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c01046d4:	00 
c01046d5:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c01046dc:	e8 4d ec ff ff       	call   c010332e <vma_create>
c01046e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(vma != NULL);
c01046e4:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c01046e8:	75 24                	jne    c010470e <check_swap+0x1e1>
c01046ea:	c7 44 24 0c 47 ad 10 	movl   $0xc010ad47,0xc(%esp)
c01046f1:	c0 
c01046f2:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c01046f9:	c0 
c01046fa:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0104701:	00 
c0104702:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c0104709:	e8 f2 bc ff ff       	call   c0100400 <__panic>

     insert_vma_struct(mm, vma);
c010470e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104711:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104715:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104718:	89 04 24             	mov    %eax,(%esp)
c010471b:	e8 9f ed ff ff       	call   c01034bf <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0104720:	c7 04 24 54 ad 10 c0 	movl   $0xc010ad54,(%esp)
c0104727:	e8 7d bb ff ff       	call   c01002a9 <cprintf>
     pte_t *temp_ptep=NULL;
c010472c:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0104733:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104736:	8b 40 0c             	mov    0xc(%eax),%eax
c0104739:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104740:	00 
c0104741:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104748:	00 
c0104749:	89 04 24             	mov    %eax,(%esp)
c010474c:	e8 a8 2b 00 00       	call   c01072f9 <get_pte>
c0104751:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(temp_ptep!= NULL);
c0104754:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104758:	75 24                	jne    c010477e <check_swap+0x251>
c010475a:	c7 44 24 0c 88 ad 10 	movl   $0xc010ad88,0xc(%esp)
c0104761:	c0 
c0104762:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c0104769:	c0 
c010476a:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0104771:	00 
c0104772:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c0104779:	e8 82 bc ff ff       	call   c0100400 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c010477e:	c7 04 24 9c ad 10 c0 	movl   $0xc010ad9c,(%esp)
c0104785:	e8 1f bb ff ff       	call   c01002a9 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010478a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104791:	e9 a4 00 00 00       	jmp    c010483a <check_swap+0x30d>
          check_rp[i] = alloc_page();
c0104796:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010479d:	e8 85 24 00 00       	call   c0106c27 <alloc_pages>
c01047a2:	89 c2                	mov    %eax,%edx
c01047a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047a7:	89 14 85 60 b0 12 c0 	mov    %edx,-0x3fed4fa0(,%eax,4)
          assert(check_rp[i] != NULL );
c01047ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047b1:	8b 04 85 60 b0 12 c0 	mov    -0x3fed4fa0(,%eax,4),%eax
c01047b8:	85 c0                	test   %eax,%eax
c01047ba:	75 24                	jne    c01047e0 <check_swap+0x2b3>
c01047bc:	c7 44 24 0c c0 ad 10 	movl   $0xc010adc0,0xc(%esp)
c01047c3:	c0 
c01047c4:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c01047cb:	c0 
c01047cc:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c01047d3:	00 
c01047d4:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c01047db:	e8 20 bc ff ff       	call   c0100400 <__panic>
          assert(!PageProperty(check_rp[i]));
c01047e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047e3:	8b 04 85 60 b0 12 c0 	mov    -0x3fed4fa0(,%eax,4),%eax
c01047ea:	83 c0 04             	add    $0x4,%eax
c01047ed:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01047f4:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01047f7:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01047fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01047fd:	0f a3 10             	bt     %edx,(%eax)
c0104800:	19 c0                	sbb    %eax,%eax
c0104802:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c0104805:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c0104809:	0f 95 c0             	setne  %al
c010480c:	0f b6 c0             	movzbl %al,%eax
c010480f:	85 c0                	test   %eax,%eax
c0104811:	74 24                	je     c0104837 <check_swap+0x30a>
c0104813:	c7 44 24 0c d4 ad 10 	movl   $0xc010add4,0xc(%esp)
c010481a:	c0 
c010481b:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c0104822:	c0 
c0104823:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c010482a:	00 
c010482b:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c0104832:	e8 c9 bb ff ff       	call   c0100400 <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104837:	ff 45 ec             	incl   -0x14(%ebp)
c010483a:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010483e:	0f 8e 52 ff ff ff    	jle    c0104796 <check_swap+0x269>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c0104844:	a1 2c b1 12 c0       	mov    0xc012b12c,%eax
c0104849:	8b 15 30 b1 12 c0    	mov    0xc012b130,%edx
c010484f:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104852:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0104855:	c7 45 c0 2c b1 12 c0 	movl   $0xc012b12c,-0x40(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010485c:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010485f:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104862:	89 50 04             	mov    %edx,0x4(%eax)
c0104865:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104868:	8b 50 04             	mov    0x4(%eax),%edx
c010486b:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010486e:	89 10                	mov    %edx,(%eax)
c0104870:	c7 45 c8 2c b1 12 c0 	movl   $0xc012b12c,-0x38(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0104877:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010487a:	8b 40 04             	mov    0x4(%eax),%eax
c010487d:	39 45 c8             	cmp    %eax,-0x38(%ebp)
c0104880:	0f 94 c0             	sete   %al
c0104883:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0104886:	85 c0                	test   %eax,%eax
c0104888:	75 24                	jne    c01048ae <check_swap+0x381>
c010488a:	c7 44 24 0c ef ad 10 	movl   $0xc010adef,0xc(%esp)
c0104891:	c0 
c0104892:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c0104899:	c0 
c010489a:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c01048a1:	00 
c01048a2:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c01048a9:	e8 52 bb ff ff       	call   c0100400 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c01048ae:	a1 34 b1 12 c0       	mov    0xc012b134,%eax
c01048b3:	89 45 bc             	mov    %eax,-0x44(%ebp)
     nr_free = 0;
c01048b6:	c7 05 34 b1 12 c0 00 	movl   $0x0,0xc012b134
c01048bd:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01048c0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01048c7:	eb 1d                	jmp    c01048e6 <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c01048c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048cc:	8b 04 85 60 b0 12 c0 	mov    -0x3fed4fa0(,%eax,4),%eax
c01048d3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01048da:	00 
c01048db:	89 04 24             	mov    %eax,(%esp)
c01048de:	e8 af 23 00 00       	call   c0106c92 <free_pages>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01048e3:	ff 45 ec             	incl   -0x14(%ebp)
c01048e6:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01048ea:	7e dd                	jle    c01048c9 <check_swap+0x39c>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c01048ec:	a1 34 b1 12 c0       	mov    0xc012b134,%eax
c01048f1:	83 f8 04             	cmp    $0x4,%eax
c01048f4:	74 24                	je     c010491a <check_swap+0x3ed>
c01048f6:	c7 44 24 0c 08 ae 10 	movl   $0xc010ae08,0xc(%esp)
c01048fd:	c0 
c01048fe:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c0104905:	c0 
c0104906:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c010490d:	00 
c010490e:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c0104915:	e8 e6 ba ff ff       	call   c0100400 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c010491a:	c7 04 24 2c ae 10 c0 	movl   $0xc010ae2c,(%esp)
c0104921:	e8 83 b9 ff ff       	call   c01002a9 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0104926:	c7 05 64 8f 12 c0 00 	movl   $0x0,0xc0128f64
c010492d:	00 00 00 
     
     check_content_set();
c0104930:	e8 27 fa ff ff       	call   c010435c <check_content_set>
     assert( nr_free == 0);         
c0104935:	a1 34 b1 12 c0       	mov    0xc012b134,%eax
c010493a:	85 c0                	test   %eax,%eax
c010493c:	74 24                	je     c0104962 <check_swap+0x435>
c010493e:	c7 44 24 0c 53 ae 10 	movl   $0xc010ae53,0xc(%esp)
c0104945:	c0 
c0104946:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c010494d:	c0 
c010494e:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0104955:	00 
c0104956:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c010495d:	e8 9e ba ff ff       	call   c0100400 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0104962:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104969:	eb 25                	jmp    c0104990 <check_swap+0x463>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c010496b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010496e:	c7 04 85 80 b0 12 c0 	movl   $0xffffffff,-0x3fed4f80(,%eax,4)
c0104975:	ff ff ff ff 
c0104979:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010497c:	8b 14 85 80 b0 12 c0 	mov    -0x3fed4f80(,%eax,4),%edx
c0104983:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104986:	89 14 85 c0 b0 12 c0 	mov    %edx,-0x3fed4f40(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c010498d:	ff 45 ec             	incl   -0x14(%ebp)
c0104990:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0104994:	7e d5                	jle    c010496b <check_swap+0x43e>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104996:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010499d:	e9 ec 00 00 00       	jmp    c0104a8e <check_swap+0x561>
         check_ptep[i]=0;
c01049a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049a5:	c7 04 85 14 b1 12 c0 	movl   $0x0,-0x3fed4eec(,%eax,4)
c01049ac:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c01049b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049b3:	40                   	inc    %eax
c01049b4:	c1 e0 0c             	shl    $0xc,%eax
c01049b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01049be:	00 
c01049bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01049c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01049c6:	89 04 24             	mov    %eax,(%esp)
c01049c9:	e8 2b 29 00 00       	call   c01072f9 <get_pte>
c01049ce:	89 c2                	mov    %eax,%edx
c01049d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049d3:	89 14 85 14 b1 12 c0 	mov    %edx,-0x3fed4eec(,%eax,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c01049da:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049dd:	8b 04 85 14 b1 12 c0 	mov    -0x3fed4eec(,%eax,4),%eax
c01049e4:	85 c0                	test   %eax,%eax
c01049e6:	75 24                	jne    c0104a0c <check_swap+0x4df>
c01049e8:	c7 44 24 0c 60 ae 10 	movl   $0xc010ae60,0xc(%esp)
c01049ef:	c0 
c01049f0:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c01049f7:	c0 
c01049f8:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c01049ff:	00 
c0104a00:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c0104a07:	e8 f4 b9 ff ff       	call   c0100400 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0104a0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a0f:	8b 04 85 14 b1 12 c0 	mov    -0x3fed4eec(,%eax,4),%eax
c0104a16:	8b 00                	mov    (%eax),%eax
c0104a18:	89 04 24             	mov    %eax,(%esp)
c0104a1b:	e8 a6 f5 ff ff       	call   c0103fc6 <pte2page>
c0104a20:	89 c2                	mov    %eax,%edx
c0104a22:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a25:	8b 04 85 60 b0 12 c0 	mov    -0x3fed4fa0(,%eax,4),%eax
c0104a2c:	39 c2                	cmp    %eax,%edx
c0104a2e:	74 24                	je     c0104a54 <check_swap+0x527>
c0104a30:	c7 44 24 0c 78 ae 10 	movl   $0xc010ae78,0xc(%esp)
c0104a37:	c0 
c0104a38:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c0104a3f:	c0 
c0104a40:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0104a47:	00 
c0104a48:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c0104a4f:	e8 ac b9 ff ff       	call   c0100400 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0104a54:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a57:	8b 04 85 14 b1 12 c0 	mov    -0x3fed4eec(,%eax,4),%eax
c0104a5e:	8b 00                	mov    (%eax),%eax
c0104a60:	83 e0 01             	and    $0x1,%eax
c0104a63:	85 c0                	test   %eax,%eax
c0104a65:	75 24                	jne    c0104a8b <check_swap+0x55e>
c0104a67:	c7 44 24 0c a0 ae 10 	movl   $0xc010aea0,0xc(%esp)
c0104a6e:	c0 
c0104a6f:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c0104a76:	c0 
c0104a77:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0104a7e:	00 
c0104a7f:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c0104a86:	e8 75 b9 ff ff       	call   c0100400 <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104a8b:	ff 45 ec             	incl   -0x14(%ebp)
c0104a8e:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0104a92:	0f 8e 0a ff ff ff    	jle    c01049a2 <check_swap+0x475>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c0104a98:	c7 04 24 bc ae 10 c0 	movl   $0xc010aebc,(%esp)
c0104a9f:	e8 05 b8 ff ff       	call   c01002a9 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0104aa4:	e8 6c fa ff ff       	call   c0104515 <check_content_access>
c0104aa9:	89 45 b8             	mov    %eax,-0x48(%ebp)
     assert(ret==0);
c0104aac:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104ab0:	74 24                	je     c0104ad6 <check_swap+0x5a9>
c0104ab2:	c7 44 24 0c e2 ae 10 	movl   $0xc010aee2,0xc(%esp)
c0104ab9:	c0 
c0104aba:	c7 44 24 08 ca ab 10 	movl   $0xc010abca,0x8(%esp)
c0104ac1:	c0 
c0104ac2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0104ac9:	00 
c0104aca:	c7 04 24 64 ab 10 c0 	movl   $0xc010ab64,(%esp)
c0104ad1:	e8 2a b9 ff ff       	call   c0100400 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104ad6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104add:	eb 1d                	jmp    c0104afc <check_swap+0x5cf>
         free_pages(check_rp[i],1);
c0104adf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ae2:	8b 04 85 60 b0 12 c0 	mov    -0x3fed4fa0(,%eax,4),%eax
c0104ae9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104af0:	00 
c0104af1:	89 04 24             	mov    %eax,(%esp)
c0104af4:	e8 99 21 00 00       	call   c0106c92 <free_pages>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104af9:	ff 45 ec             	incl   -0x14(%ebp)
c0104afc:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0104b00:	7e dd                	jle    c0104adf <check_swap+0x5b2>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0104b02:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104b05:	89 04 24             	mov    %eax,(%esp)
c0104b08:	e8 e4 ea ff ff       	call   c01035f1 <mm_destroy>
         
     nr_free = nr_free_store;
c0104b0d:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104b10:	a3 34 b1 12 c0       	mov    %eax,0xc012b134
     free_list = free_list_store;
c0104b15:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104b18:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104b1b:	a3 2c b1 12 c0       	mov    %eax,0xc012b12c
c0104b20:	89 15 30 b1 12 c0    	mov    %edx,0xc012b130

     
     le = &free_list;
c0104b26:	c7 45 e8 2c b1 12 c0 	movl   $0xc012b12c,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0104b2d:	eb 1c                	jmp    c0104b4b <check_swap+0x61e>
         struct Page *p = le2page(le, page_link);
c0104b2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104b32:	83 e8 0c             	sub    $0xc,%eax
c0104b35:	89 45 b4             	mov    %eax,-0x4c(%ebp)
         count --, total -= p->property;
c0104b38:	ff 4d f4             	decl   -0xc(%ebp)
c0104b3b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104b3e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104b41:	8b 40 08             	mov    0x8(%eax),%eax
c0104b44:	29 c2                	sub    %eax,%edx
c0104b46:	89 d0                	mov    %edx,%eax
c0104b48:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104b4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104b4e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104b51:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104b54:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0104b57:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104b5a:	81 7d e8 2c b1 12 c0 	cmpl   $0xc012b12c,-0x18(%ebp)
c0104b61:	75 cc                	jne    c0104b2f <check_swap+0x602>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c0104b63:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b66:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104b71:	c7 04 24 e9 ae 10 c0 	movl   $0xc010aee9,(%esp)
c0104b78:	e8 2c b7 ff ff       	call   c01002a9 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0104b7d:	c7 04 24 03 af 10 c0 	movl   $0xc010af03,(%esp)
c0104b84:	e8 20 b7 ff ff       	call   c01002a9 <cprintf>
}
c0104b89:	90                   	nop
c0104b8a:	c9                   	leave  
c0104b8b:	c3                   	ret    

c0104b8c <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0104b8c:	55                   	push   %ebp
c0104b8d:	89 e5                	mov    %esp,%ebp
c0104b8f:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0104b92:	9c                   	pushf  
c0104b93:	58                   	pop    %eax
c0104b94:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104b9a:	25 00 02 00 00       	and    $0x200,%eax
c0104b9f:	85 c0                	test   %eax,%eax
c0104ba1:	74 0c                	je     c0104baf <__intr_save+0x23>
        intr_disable();
c0104ba3:	e8 51 d5 ff ff       	call   c01020f9 <intr_disable>
        return 1;
c0104ba8:	b8 01 00 00 00       	mov    $0x1,%eax
c0104bad:	eb 05                	jmp    c0104bb4 <__intr_save+0x28>
    }
    return 0;
c0104baf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104bb4:	c9                   	leave  
c0104bb5:	c3                   	ret    

c0104bb6 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0104bb6:	55                   	push   %ebp
c0104bb7:	89 e5                	mov    %esp,%ebp
c0104bb9:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0104bbc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104bc0:	74 05                	je     c0104bc7 <__intr_restore+0x11>
        intr_enable();
c0104bc2:	e8 2b d5 ff ff       	call   c01020f2 <intr_enable>
    }
}
c0104bc7:	90                   	nop
c0104bc8:	c9                   	leave  
c0104bc9:	c3                   	ret    

c0104bca <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104bca:	55                   	push   %ebp
c0104bcb:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104bcd:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bd0:	8b 15 40 b1 12 c0    	mov    0xc012b140,%edx
c0104bd6:	29 d0                	sub    %edx,%eax
c0104bd8:	c1 f8 05             	sar    $0x5,%eax
}
c0104bdb:	5d                   	pop    %ebp
c0104bdc:	c3                   	ret    

c0104bdd <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0104bdd:	55                   	push   %ebp
c0104bde:	89 e5                	mov    %esp,%ebp
c0104be0:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104be3:	8b 45 08             	mov    0x8(%ebp),%eax
c0104be6:	89 04 24             	mov    %eax,(%esp)
c0104be9:	e8 dc ff ff ff       	call   c0104bca <page2ppn>
c0104bee:	c1 e0 0c             	shl    $0xc,%eax
}
c0104bf1:	c9                   	leave  
c0104bf2:	c3                   	ret    

c0104bf3 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0104bf3:	55                   	push   %ebp
c0104bf4:	89 e5                	mov    %esp,%ebp
c0104bf6:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104bf9:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bfc:	c1 e8 0c             	shr    $0xc,%eax
c0104bff:	89 c2                	mov    %eax,%edx
c0104c01:	a1 80 8f 12 c0       	mov    0xc0128f80,%eax
c0104c06:	39 c2                	cmp    %eax,%edx
c0104c08:	72 1c                	jb     c0104c26 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104c0a:	c7 44 24 08 1c af 10 	movl   $0xc010af1c,0x8(%esp)
c0104c11:	c0 
c0104c12:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0104c19:	00 
c0104c1a:	c7 04 24 3b af 10 c0 	movl   $0xc010af3b,(%esp)
c0104c21:	e8 da b7 ff ff       	call   c0100400 <__panic>
    }
    return &pages[PPN(pa)];
c0104c26:	a1 40 b1 12 c0       	mov    0xc012b140,%eax
c0104c2b:	8b 55 08             	mov    0x8(%ebp),%edx
c0104c2e:	c1 ea 0c             	shr    $0xc,%edx
c0104c31:	c1 e2 05             	shl    $0x5,%edx
c0104c34:	01 d0                	add    %edx,%eax
}
c0104c36:	c9                   	leave  
c0104c37:	c3                   	ret    

c0104c38 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0104c38:	55                   	push   %ebp
c0104c39:	89 e5                	mov    %esp,%ebp
c0104c3b:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104c3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c41:	89 04 24             	mov    %eax,(%esp)
c0104c44:	e8 94 ff ff ff       	call   c0104bdd <page2pa>
c0104c49:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c4f:	c1 e8 0c             	shr    $0xc,%eax
c0104c52:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104c55:	a1 80 8f 12 c0       	mov    0xc0128f80,%eax
c0104c5a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104c5d:	72 23                	jb     c0104c82 <page2kva+0x4a>
c0104c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c62:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104c66:	c7 44 24 08 4c af 10 	movl   $0xc010af4c,0x8(%esp)
c0104c6d:	c0 
c0104c6e:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0104c75:	00 
c0104c76:	c7 04 24 3b af 10 c0 	movl   $0xc010af3b,(%esp)
c0104c7d:	e8 7e b7 ff ff       	call   c0100400 <__panic>
c0104c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c85:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0104c8a:	c9                   	leave  
c0104c8b:	c3                   	ret    

c0104c8c <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c0104c8c:	55                   	push   %ebp
c0104c8d:	89 e5                	mov    %esp,%ebp
c0104c8f:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0104c92:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c95:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104c98:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104c9f:	77 23                	ja     c0104cc4 <kva2page+0x38>
c0104ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ca4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104ca8:	c7 44 24 08 70 af 10 	movl   $0xc010af70,0x8(%esp)
c0104caf:	c0 
c0104cb0:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c0104cb7:	00 
c0104cb8:	c7 04 24 3b af 10 c0 	movl   $0xc010af3b,(%esp)
c0104cbf:	e8 3c b7 ff ff       	call   c0100400 <__panic>
c0104cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cc7:	05 00 00 00 40       	add    $0x40000000,%eax
c0104ccc:	89 04 24             	mov    %eax,(%esp)
c0104ccf:	e8 1f ff ff ff       	call   c0104bf3 <pa2page>
}
c0104cd4:	c9                   	leave  
c0104cd5:	c3                   	ret    

c0104cd6 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0104cd6:	55                   	push   %ebp
c0104cd7:	89 e5                	mov    %esp,%ebp
c0104cd9:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c0104cdc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104cdf:	ba 01 00 00 00       	mov    $0x1,%edx
c0104ce4:	88 c1                	mov    %al,%cl
c0104ce6:	d3 e2                	shl    %cl,%edx
c0104ce8:	89 d0                	mov    %edx,%eax
c0104cea:	89 04 24             	mov    %eax,(%esp)
c0104ced:	e8 35 1f 00 00       	call   c0106c27 <alloc_pages>
c0104cf2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c0104cf5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104cf9:	75 07                	jne    c0104d02 <__slob_get_free_pages+0x2c>
    return NULL;
c0104cfb:	b8 00 00 00 00       	mov    $0x0,%eax
c0104d00:	eb 0b                	jmp    c0104d0d <__slob_get_free_pages+0x37>
  return page2kva(page);
c0104d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d05:	89 04 24             	mov    %eax,(%esp)
c0104d08:	e8 2b ff ff ff       	call   c0104c38 <page2kva>
}
c0104d0d:	c9                   	leave  
c0104d0e:	c3                   	ret    

c0104d0f <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c0104d0f:	55                   	push   %ebp
c0104d10:	89 e5                	mov    %esp,%ebp
c0104d12:	53                   	push   %ebx
c0104d13:	83 ec 14             	sub    $0x14,%esp
  free_pages(kva2page(kva), 1 << order);
c0104d16:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104d19:	ba 01 00 00 00       	mov    $0x1,%edx
c0104d1e:	88 c1                	mov    %al,%cl
c0104d20:	d3 e2                	shl    %cl,%edx
c0104d22:	89 d0                	mov    %edx,%eax
c0104d24:	89 c3                	mov    %eax,%ebx
c0104d26:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d29:	89 04 24             	mov    %eax,(%esp)
c0104d2c:	e8 5b ff ff ff       	call   c0104c8c <kva2page>
c0104d31:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104d35:	89 04 24             	mov    %eax,(%esp)
c0104d38:	e8 55 1f 00 00       	call   c0106c92 <free_pages>
}
c0104d3d:	90                   	nop
c0104d3e:	83 c4 14             	add    $0x14,%esp
c0104d41:	5b                   	pop    %ebx
c0104d42:	5d                   	pop    %ebp
c0104d43:	c3                   	ret    

c0104d44 <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c0104d44:	55                   	push   %ebp
c0104d45:	89 e5                	mov    %esp,%ebp
c0104d47:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c0104d4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d4d:	83 c0 08             	add    $0x8,%eax
c0104d50:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0104d55:	76 24                	jbe    c0104d7b <slob_alloc+0x37>
c0104d57:	c7 44 24 0c 94 af 10 	movl   $0xc010af94,0xc(%esp)
c0104d5e:	c0 
c0104d5f:	c7 44 24 08 b3 af 10 	movl   $0xc010afb3,0x8(%esp)
c0104d66:	c0 
c0104d67:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0104d6e:	00 
c0104d6f:	c7 04 24 c8 af 10 c0 	movl   $0xc010afc8,(%esp)
c0104d76:	e8 85 b6 ff ff       	call   c0100400 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c0104d7b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c0104d82:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0104d89:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d8c:	83 c0 07             	add    $0x7,%eax
c0104d8f:	c1 e8 03             	shr    $0x3,%eax
c0104d92:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c0104d95:	e8 f2 fd ff ff       	call   c0104b8c <__intr_save>
c0104d9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c0104d9d:	a1 e8 59 12 c0       	mov    0xc01259e8,%eax
c0104da2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0104da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104da8:	8b 40 04             	mov    0x4(%eax),%eax
c0104dab:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0104dae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104db2:	74 25                	je     c0104dd9 <slob_alloc+0x95>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c0104db4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104db7:	8b 45 10             	mov    0x10(%ebp),%eax
c0104dba:	01 d0                	add    %edx,%eax
c0104dbc:	8d 50 ff             	lea    -0x1(%eax),%edx
c0104dbf:	8b 45 10             	mov    0x10(%ebp),%eax
c0104dc2:	f7 d8                	neg    %eax
c0104dc4:	21 d0                	and    %edx,%eax
c0104dc6:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0104dc9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104dcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104dcf:	29 c2                	sub    %eax,%edx
c0104dd1:	89 d0                	mov    %edx,%eax
c0104dd3:	c1 f8 03             	sar    $0x3,%eax
c0104dd6:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c0104dd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ddc:	8b 00                	mov    (%eax),%eax
c0104dde:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0104de1:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104de4:	01 ca                	add    %ecx,%edx
c0104de6:	39 d0                	cmp    %edx,%eax
c0104de8:	0f 8c aa 00 00 00    	jl     c0104e98 <slob_alloc+0x154>
			if (delta) { /* need to fragment head to align? */
c0104dee:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104df2:	74 38                	je     c0104e2c <slob_alloc+0xe8>
				aligned->units = cur->units - delta;
c0104df4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104df7:	8b 00                	mov    (%eax),%eax
c0104df9:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0104dfc:	89 c2                	mov    %eax,%edx
c0104dfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e01:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c0104e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e06:	8b 50 04             	mov    0x4(%eax),%edx
c0104e09:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e0c:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c0104e0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e12:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104e15:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c0104e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e1b:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104e1e:	89 10                	mov    %edx,(%eax)
				prev = cur;
c0104e20:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e23:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c0104e26:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e29:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c0104e2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e2f:	8b 00                	mov    (%eax),%eax
c0104e31:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0104e34:	75 0e                	jne    c0104e44 <slob_alloc+0x100>
				prev->next = cur->next; /* unlink */
c0104e36:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e39:	8b 50 04             	mov    0x4(%eax),%edx
c0104e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e3f:	89 50 04             	mov    %edx,0x4(%eax)
c0104e42:	eb 3c                	jmp    c0104e80 <slob_alloc+0x13c>
			else { /* fragment */
				prev->next = cur + units;
c0104e44:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104e47:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104e4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e51:	01 c2                	add    %eax,%edx
c0104e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e56:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c0104e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e5c:	8b 40 04             	mov    0x4(%eax),%eax
c0104e5f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104e62:	8b 12                	mov    (%edx),%edx
c0104e64:	2b 55 e0             	sub    -0x20(%ebp),%edx
c0104e67:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c0104e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e6c:	8b 40 04             	mov    0x4(%eax),%eax
c0104e6f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104e72:	8b 52 04             	mov    0x4(%edx),%edx
c0104e75:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0104e78:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e7b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104e7e:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0104e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e83:	a3 e8 59 12 c0       	mov    %eax,0xc01259e8
			spin_unlock_irqrestore(&slob_lock, flags);
c0104e88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e8b:	89 04 24             	mov    %eax,(%esp)
c0104e8e:	e8 23 fd ff ff       	call   c0104bb6 <__intr_restore>
			return cur;
c0104e93:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e96:	eb 7f                	jmp    c0104f17 <slob_alloc+0x1d3>
		}
		if (cur == slobfree) {
c0104e98:	a1 e8 59 12 c0       	mov    0xc01259e8,%eax
c0104e9d:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104ea0:	75 61                	jne    c0104f03 <slob_alloc+0x1bf>
			spin_unlock_irqrestore(&slob_lock, flags);
c0104ea2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ea5:	89 04 24             	mov    %eax,(%esp)
c0104ea8:	e8 09 fd ff ff       	call   c0104bb6 <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c0104ead:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0104eb4:	75 07                	jne    c0104ebd <slob_alloc+0x179>
				return 0;
c0104eb6:	b8 00 00 00 00       	mov    $0x0,%eax
c0104ebb:	eb 5a                	jmp    c0104f17 <slob_alloc+0x1d3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c0104ebd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104ec4:	00 
c0104ec5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104ec8:	89 04 24             	mov    %eax,(%esp)
c0104ecb:	e8 06 fe ff ff       	call   c0104cd6 <__slob_get_free_pages>
c0104ed0:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0104ed3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104ed7:	75 07                	jne    c0104ee0 <slob_alloc+0x19c>
				return 0;
c0104ed9:	b8 00 00 00 00       	mov    $0x0,%eax
c0104ede:	eb 37                	jmp    c0104f17 <slob_alloc+0x1d3>

			slob_free(cur, PAGE_SIZE);
c0104ee0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104ee7:	00 
c0104ee8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104eeb:	89 04 24             	mov    %eax,(%esp)
c0104eee:	e8 26 00 00 00       	call   c0104f19 <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c0104ef3:	e8 94 fc ff ff       	call   c0104b8c <__intr_save>
c0104ef8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c0104efb:	a1 e8 59 12 c0       	mov    0xc01259e8,%eax
c0104f00:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0104f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f06:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f0c:	8b 40 04             	mov    0x4(%eax),%eax
c0104f0f:	89 45 f0             	mov    %eax,-0x10(%ebp)

			slob_free(cur, PAGE_SIZE);
			spin_lock_irqsave(&slob_lock, flags);
			cur = slobfree;
		}
	}
c0104f12:	e9 97 fe ff ff       	jmp    c0104dae <slob_alloc+0x6a>
}
c0104f17:	c9                   	leave  
c0104f18:	c3                   	ret    

c0104f19 <slob_free>:

static void slob_free(void *block, int size)
{
c0104f19:	55                   	push   %ebp
c0104f1a:	89 e5                	mov    %esp,%ebp
c0104f1c:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c0104f1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f22:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0104f25:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104f29:	0f 84 01 01 00 00    	je     c0105030 <slob_free+0x117>
		return;

	if (size)
c0104f2f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104f33:	74 10                	je     c0104f45 <slob_free+0x2c>
		b->units = SLOB_UNITS(size);
c0104f35:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f38:	83 c0 07             	add    $0x7,%eax
c0104f3b:	c1 e8 03             	shr    $0x3,%eax
c0104f3e:	89 c2                	mov    %eax,%edx
c0104f40:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f43:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c0104f45:	e8 42 fc ff ff       	call   c0104b8c <__intr_save>
c0104f4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0104f4d:	a1 e8 59 12 c0       	mov    0xc01259e8,%eax
c0104f52:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104f55:	eb 27                	jmp    c0104f7e <slob_free+0x65>
		if (cur >= cur->next && (b > cur || b < cur->next))
c0104f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f5a:	8b 40 04             	mov    0x4(%eax),%eax
c0104f5d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104f60:	77 13                	ja     c0104f75 <slob_free+0x5c>
c0104f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f65:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104f68:	77 27                	ja     c0104f91 <slob_free+0x78>
c0104f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f6d:	8b 40 04             	mov    0x4(%eax),%eax
c0104f70:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104f73:	77 1c                	ja     c0104f91 <slob_free+0x78>
	if (size)
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0104f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f78:	8b 40 04             	mov    0x4(%eax),%eax
c0104f7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104f7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f81:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104f84:	76 d1                	jbe    c0104f57 <slob_free+0x3e>
c0104f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f89:	8b 40 04             	mov    0x4(%eax),%eax
c0104f8c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104f8f:	76 c6                	jbe    c0104f57 <slob_free+0x3e>
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	if (b + b->units == cur->next) {
c0104f91:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f94:	8b 00                	mov    (%eax),%eax
c0104f96:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104f9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fa0:	01 c2                	add    %eax,%edx
c0104fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fa5:	8b 40 04             	mov    0x4(%eax),%eax
c0104fa8:	39 c2                	cmp    %eax,%edx
c0104faa:	75 25                	jne    c0104fd1 <slob_free+0xb8>
		b->units += cur->next->units;
c0104fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104faf:	8b 10                	mov    (%eax),%edx
c0104fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fb4:	8b 40 04             	mov    0x4(%eax),%eax
c0104fb7:	8b 00                	mov    (%eax),%eax
c0104fb9:	01 c2                	add    %eax,%edx
c0104fbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fbe:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c0104fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fc3:	8b 40 04             	mov    0x4(%eax),%eax
c0104fc6:	8b 50 04             	mov    0x4(%eax),%edx
c0104fc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fcc:	89 50 04             	mov    %edx,0x4(%eax)
c0104fcf:	eb 0c                	jmp    c0104fdd <slob_free+0xc4>
	} else
		b->next = cur->next;
c0104fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fd4:	8b 50 04             	mov    0x4(%eax),%edx
c0104fd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fda:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0104fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fe0:	8b 00                	mov    (%eax),%eax
c0104fe2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fec:	01 d0                	add    %edx,%eax
c0104fee:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104ff1:	75 1f                	jne    c0105012 <slob_free+0xf9>
		cur->units += b->units;
c0104ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ff6:	8b 10                	mov    (%eax),%edx
c0104ff8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ffb:	8b 00                	mov    (%eax),%eax
c0104ffd:	01 c2                	add    %eax,%edx
c0104fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105002:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c0105004:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105007:	8b 50 04             	mov    0x4(%eax),%edx
c010500a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010500d:	89 50 04             	mov    %edx,0x4(%eax)
c0105010:	eb 09                	jmp    c010501b <slob_free+0x102>
	} else
		cur->next = b;
c0105012:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105015:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105018:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c010501b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010501e:	a3 e8 59 12 c0       	mov    %eax,0xc01259e8

	spin_unlock_irqrestore(&slob_lock, flags);
c0105023:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105026:	89 04 24             	mov    %eax,(%esp)
c0105029:	e8 88 fb ff ff       	call   c0104bb6 <__intr_restore>
c010502e:	eb 01                	jmp    c0105031 <slob_free+0x118>
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
		return;
c0105030:	90                   	nop
		cur->next = b;

	slobfree = cur;

	spin_unlock_irqrestore(&slob_lock, flags);
}
c0105031:	c9                   	leave  
c0105032:	c3                   	ret    

c0105033 <slob_init>:



void
slob_init(void) {
c0105033:	55                   	push   %ebp
c0105034:	89 e5                	mov    %esp,%ebp
c0105036:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c0105039:	c7 04 24 da af 10 c0 	movl   $0xc010afda,(%esp)
c0105040:	e8 64 b2 ff ff       	call   c01002a9 <cprintf>
}
c0105045:	90                   	nop
c0105046:	c9                   	leave  
c0105047:	c3                   	ret    

c0105048 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0105048:	55                   	push   %ebp
c0105049:	89 e5                	mov    %esp,%ebp
c010504b:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c010504e:	e8 e0 ff ff ff       	call   c0105033 <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c0105053:	c7 04 24 ee af 10 c0 	movl   $0xc010afee,(%esp)
c010505a:	e8 4a b2 ff ff       	call   c01002a9 <cprintf>
}
c010505f:	90                   	nop
c0105060:	c9                   	leave  
c0105061:	c3                   	ret    

c0105062 <slob_allocated>:

size_t
slob_allocated(void) {
c0105062:	55                   	push   %ebp
c0105063:	89 e5                	mov    %esp,%ebp
  return 0;
c0105065:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010506a:	5d                   	pop    %ebp
c010506b:	c3                   	ret    

c010506c <kallocated>:

size_t
kallocated(void) {
c010506c:	55                   	push   %ebp
c010506d:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c010506f:	e8 ee ff ff ff       	call   c0105062 <slob_allocated>
}
c0105074:	5d                   	pop    %ebp
c0105075:	c3                   	ret    

c0105076 <find_order>:

static int find_order(int size)
{
c0105076:	55                   	push   %ebp
c0105077:	89 e5                	mov    %esp,%ebp
c0105079:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c010507c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0105083:	eb 06                	jmp    c010508b <find_order+0x15>
		order++;
c0105085:	ff 45 fc             	incl   -0x4(%ebp)
}

static int find_order(int size)
{
	int order = 0;
	for ( ; size > 4096 ; size >>=1)
c0105088:	d1 7d 08             	sarl   0x8(%ebp)
c010508b:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0105092:	7f f1                	jg     c0105085 <find_order+0xf>
		order++;
	return order;
c0105094:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105097:	c9                   	leave  
c0105098:	c3                   	ret    

c0105099 <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0105099:	55                   	push   %ebp
c010509a:	89 e5                	mov    %esp,%ebp
c010509c:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c010509f:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c01050a6:	77 3b                	ja     c01050e3 <__kmalloc+0x4a>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c01050a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01050ab:	8d 50 08             	lea    0x8(%eax),%edx
c01050ae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01050b5:	00 
c01050b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01050b9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01050bd:	89 14 24             	mov    %edx,(%esp)
c01050c0:	e8 7f fc ff ff       	call   c0104d44 <slob_alloc>
c01050c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return m ? (void *)(m + 1) : 0;
c01050c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01050cc:	74 0b                	je     c01050d9 <__kmalloc+0x40>
c01050ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050d1:	83 c0 08             	add    $0x8,%eax
c01050d4:	e9 b4 00 00 00       	jmp    c010518d <__kmalloc+0xf4>
c01050d9:	b8 00 00 00 00       	mov    $0x0,%eax
c01050de:	e9 aa 00 00 00       	jmp    c010518d <__kmalloc+0xf4>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c01050e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01050ea:	00 
c01050eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01050ee:	89 44 24 04          	mov    %eax,0x4(%esp)
c01050f2:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c01050f9:	e8 46 fc ff ff       	call   c0104d44 <slob_alloc>
c01050fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (!bb)
c0105101:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105105:	75 07                	jne    c010510e <__kmalloc+0x75>
		return 0;
c0105107:	b8 00 00 00 00       	mov    $0x0,%eax
c010510c:	eb 7f                	jmp    c010518d <__kmalloc+0xf4>

	bb->order = find_order(size);
c010510e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105111:	89 04 24             	mov    %eax,(%esp)
c0105114:	e8 5d ff ff ff       	call   c0105076 <find_order>
c0105119:	89 c2                	mov    %eax,%edx
c010511b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010511e:	89 10                	mov    %edx,(%eax)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0105120:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105123:	8b 00                	mov    (%eax),%eax
c0105125:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105129:	8b 45 0c             	mov    0xc(%ebp),%eax
c010512c:	89 04 24             	mov    %eax,(%esp)
c010512f:	e8 a2 fb ff ff       	call   c0104cd6 <__slob_get_free_pages>
c0105134:	89 c2                	mov    %eax,%edx
c0105136:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105139:	89 50 04             	mov    %edx,0x4(%eax)

	if (bb->pages) {
c010513c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010513f:	8b 40 04             	mov    0x4(%eax),%eax
c0105142:	85 c0                	test   %eax,%eax
c0105144:	74 2f                	je     c0105175 <__kmalloc+0xdc>
		spin_lock_irqsave(&block_lock, flags);
c0105146:	e8 41 fa ff ff       	call   c0104b8c <__intr_save>
c010514b:	89 45 ec             	mov    %eax,-0x14(%ebp)
		bb->next = bigblocks;
c010514e:	8b 15 74 8f 12 c0    	mov    0xc0128f74,%edx
c0105154:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105157:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c010515a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010515d:	a3 74 8f 12 c0       	mov    %eax,0xc0128f74
		spin_unlock_irqrestore(&block_lock, flags);
c0105162:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105165:	89 04 24             	mov    %eax,(%esp)
c0105168:	e8 49 fa ff ff       	call   c0104bb6 <__intr_restore>
		return bb->pages;
c010516d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105170:	8b 40 04             	mov    0x4(%eax),%eax
c0105173:	eb 18                	jmp    c010518d <__kmalloc+0xf4>
	}

	slob_free(bb, sizeof(bigblock_t));
c0105175:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c010517c:	00 
c010517d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105180:	89 04 24             	mov    %eax,(%esp)
c0105183:	e8 91 fd ff ff       	call   c0104f19 <slob_free>
	return 0;
c0105188:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010518d:	c9                   	leave  
c010518e:	c3                   	ret    

c010518f <kmalloc>:

void *
kmalloc(size_t size)
{
c010518f:	55                   	push   %ebp
c0105190:	89 e5                	mov    %esp,%ebp
c0105192:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c0105195:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010519c:	00 
c010519d:	8b 45 08             	mov    0x8(%ebp),%eax
c01051a0:	89 04 24             	mov    %eax,(%esp)
c01051a3:	e8 f1 fe ff ff       	call   c0105099 <__kmalloc>
}
c01051a8:	c9                   	leave  
c01051a9:	c3                   	ret    

c01051aa <kfree>:


void kfree(void *block)
{
c01051aa:	55                   	push   %ebp
c01051ab:	89 e5                	mov    %esp,%ebp
c01051ad:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c01051b0:	c7 45 f0 74 8f 12 c0 	movl   $0xc0128f74,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c01051b7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01051bb:	0f 84 a4 00 00 00    	je     c0105265 <kfree+0xbb>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c01051c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01051c4:	25 ff 0f 00 00       	and    $0xfff,%eax
c01051c9:	85 c0                	test   %eax,%eax
c01051cb:	75 7f                	jne    c010524c <kfree+0xa2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c01051cd:	e8 ba f9 ff ff       	call   c0104b8c <__intr_save>
c01051d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c01051d5:	a1 74 8f 12 c0       	mov    0xc0128f74,%eax
c01051da:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01051dd:	eb 5c                	jmp    c010523b <kfree+0x91>
			if (bb->pages == block) {
c01051df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051e2:	8b 40 04             	mov    0x4(%eax),%eax
c01051e5:	3b 45 08             	cmp    0x8(%ebp),%eax
c01051e8:	75 3f                	jne    c0105229 <kfree+0x7f>
				*last = bb->next;
c01051ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051ed:	8b 50 08             	mov    0x8(%eax),%edx
c01051f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01051f3:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c01051f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051f8:	89 04 24             	mov    %eax,(%esp)
c01051fb:	e8 b6 f9 ff ff       	call   c0104bb6 <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0105200:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105203:	8b 10                	mov    (%eax),%edx
c0105205:	8b 45 08             	mov    0x8(%ebp),%eax
c0105208:	89 54 24 04          	mov    %edx,0x4(%esp)
c010520c:	89 04 24             	mov    %eax,(%esp)
c010520f:	e8 fb fa ff ff       	call   c0104d0f <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0105214:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c010521b:	00 
c010521c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010521f:	89 04 24             	mov    %eax,(%esp)
c0105222:	e8 f2 fc ff ff       	call   c0104f19 <slob_free>
				return;
c0105227:	eb 3d                	jmp    c0105266 <kfree+0xbc>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0105229:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010522c:	83 c0 08             	add    $0x8,%eax
c010522f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105232:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105235:	8b 40 08             	mov    0x8(%eax),%eax
c0105238:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010523b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010523f:	75 9e                	jne    c01051df <kfree+0x35>
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0105241:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105244:	89 04 24             	mov    %eax,(%esp)
c0105247:	e8 6a f9 ff ff       	call   c0104bb6 <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c010524c:	8b 45 08             	mov    0x8(%ebp),%eax
c010524f:	83 e8 08             	sub    $0x8,%eax
c0105252:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105259:	00 
c010525a:	89 04 24             	mov    %eax,(%esp)
c010525d:	e8 b7 fc ff ff       	call   c0104f19 <slob_free>
	return;
c0105262:	90                   	nop
c0105263:	eb 01                	jmp    c0105266 <kfree+0xbc>
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
		return;
c0105265:	90                   	nop
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
c0105266:	c9                   	leave  
c0105267:	c3                   	ret    

c0105268 <ksize>:


unsigned int ksize(const void *block)
{
c0105268:	55                   	push   %ebp
c0105269:	89 e5                	mov    %esp,%ebp
c010526b:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c010526e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105272:	75 07                	jne    c010527b <ksize+0x13>
		return 0;
c0105274:	b8 00 00 00 00       	mov    $0x0,%eax
c0105279:	eb 6b                	jmp    c01052e6 <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c010527b:	8b 45 08             	mov    0x8(%ebp),%eax
c010527e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105283:	85 c0                	test   %eax,%eax
c0105285:	75 54                	jne    c01052db <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c0105287:	e8 00 f9 ff ff       	call   c0104b8c <__intr_save>
c010528c:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c010528f:	a1 74 8f 12 c0       	mov    0xc0128f74,%eax
c0105294:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105297:	eb 31                	jmp    c01052ca <ksize+0x62>
			if (bb->pages == block) {
c0105299:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010529c:	8b 40 04             	mov    0x4(%eax),%eax
c010529f:	3b 45 08             	cmp    0x8(%ebp),%eax
c01052a2:	75 1d                	jne    c01052c1 <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c01052a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052a7:	89 04 24             	mov    %eax,(%esp)
c01052aa:	e8 07 f9 ff ff       	call   c0104bb6 <__intr_restore>
				return PAGE_SIZE << bb->order;
c01052af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052b2:	8b 00                	mov    (%eax),%eax
c01052b4:	ba 00 10 00 00       	mov    $0x1000,%edx
c01052b9:	88 c1                	mov    %al,%cl
c01052bb:	d3 e2                	shl    %cl,%edx
c01052bd:	89 d0                	mov    %edx,%eax
c01052bf:	eb 25                	jmp    c01052e6 <ksize+0x7e>
	if (!block)
		return 0;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; bb = bb->next)
c01052c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052c4:	8b 40 08             	mov    0x8(%eax),%eax
c01052c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01052ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01052ce:	75 c9                	jne    c0105299 <ksize+0x31>
			if (bb->pages == block) {
				spin_unlock_irqrestore(&slob_lock, flags);
				return PAGE_SIZE << bb->order;
			}
		spin_unlock_irqrestore(&block_lock, flags);
c01052d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052d3:	89 04 24             	mov    %eax,(%esp)
c01052d6:	e8 db f8 ff ff       	call   c0104bb6 <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c01052db:	8b 45 08             	mov    0x8(%ebp),%eax
c01052de:	83 e8 08             	sub    $0x8,%eax
c01052e1:	8b 00                	mov    (%eax),%eax
c01052e3:	c1 e0 03             	shl    $0x3,%eax
}
c01052e6:	c9                   	leave  
c01052e7:	c3                   	ret    

c01052e8 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c01052e8:	55                   	push   %ebp
c01052e9:	89 e5                	mov    %esp,%ebp
c01052eb:	83 ec 10             	sub    $0x10,%esp
c01052ee:	c7 45 fc 24 b1 12 c0 	movl   $0xc012b124,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01052f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01052f8:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01052fb:	89 50 04             	mov    %edx,0x4(%eax)
c01052fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105301:	8b 50 04             	mov    0x4(%eax),%edx
c0105304:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105307:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0105309:	8b 45 08             	mov    0x8(%ebp),%eax
c010530c:	c7 40 14 24 b1 12 c0 	movl   $0xc012b124,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0105313:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105318:	c9                   	leave  
c0105319:	c3                   	ret    

c010531a <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c010531a:	55                   	push   %ebp
c010531b:	89 e5                	mov    %esp,%ebp
c010531d:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0105320:	8b 45 08             	mov    0x8(%ebp),%eax
c0105323:	8b 40 14             	mov    0x14(%eax),%eax
c0105326:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0105329:	8b 45 10             	mov    0x10(%ebp),%eax
c010532c:	83 c0 14             	add    $0x14,%eax
c010532f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0105332:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105336:	74 06                	je     c010533e <_fifo_map_swappable+0x24>
c0105338:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010533c:	75 24                	jne    c0105362 <_fifo_map_swappable+0x48>
c010533e:	c7 44 24 0c 0c b0 10 	movl   $0xc010b00c,0xc(%esp)
c0105345:	c0 
c0105346:	c7 44 24 08 2a b0 10 	movl   $0xc010b02a,0x8(%esp)
c010534d:	c0 
c010534e:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0105355:	00 
c0105356:	c7 04 24 3f b0 10 c0 	movl   $0xc010b03f,(%esp)
c010535d:	e8 9e b0 ff ff       	call   c0100400 <__panic>
c0105362:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105365:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105368:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010536b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010536e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105371:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105374:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105377:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010537a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010537d:	8b 40 04             	mov    0x4(%eax),%eax
c0105380:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105383:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0105386:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105389:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010538c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010538f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105392:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105395:	89 10                	mov    %edx,(%eax)
c0105397:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010539a:	8b 10                	mov    (%eax),%edx
c010539c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010539f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01053a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01053a5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01053a8:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01053ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01053ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01053b1:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c01053b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01053b8:	c9                   	leave  
c01053b9:	c3                   	ret    

c01053ba <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c01053ba:	55                   	push   %ebp
c01053bb:	89 e5                	mov    %esp,%ebp
c01053bd:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c01053c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01053c3:	8b 40 14             	mov    0x14(%eax),%eax
c01053c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c01053c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01053cd:	75 24                	jne    c01053f3 <_fifo_swap_out_victim+0x39>
c01053cf:	c7 44 24 0c 53 b0 10 	movl   $0xc010b053,0xc(%esp)
c01053d6:	c0 
c01053d7:	c7 44 24 08 2a b0 10 	movl   $0xc010b02a,0x8(%esp)
c01053de:	c0 
c01053df:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c01053e6:	00 
c01053e7:	c7 04 24 3f b0 10 c0 	movl   $0xc010b03f,(%esp)
c01053ee:	e8 0d b0 ff ff       	call   c0100400 <__panic>
     assert(in_tick==0);
c01053f3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01053f7:	74 24                	je     c010541d <_fifo_swap_out_victim+0x63>
c01053f9:	c7 44 24 0c 60 b0 10 	movl   $0xc010b060,0xc(%esp)
c0105400:	c0 
c0105401:	c7 44 24 08 2a b0 10 	movl   $0xc010b02a,0x8(%esp)
c0105408:	c0 
c0105409:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c0105410:	00 
c0105411:	c7 04 24 3f b0 10 c0 	movl   $0xc010b03f,(%esp)
c0105418:	e8 e3 af ff ff       	call   c0100400 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
    list_entry_t *le = head->prev;
c010541d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105420:	8b 00                	mov    (%eax),%eax
c0105422:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(head!=le);
c0105425:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105428:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010542b:	75 24                	jne    c0105451 <_fifo_swap_out_victim+0x97>
c010542d:	c7 44 24 0c 6b b0 10 	movl   $0xc010b06b,0xc(%esp)
c0105434:	c0 
c0105435:	c7 44 24 08 2a b0 10 	movl   $0xc010b02a,0x8(%esp)
c010543c:	c0 
c010543d:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
c0105444:	00 
c0105445:	c7 04 24 3f b0 10 c0 	movl   $0xc010b03f,(%esp)
c010544c:	e8 af af ff ff       	call   c0100400 <__panic>
    struct Page *p = le2page(le, pra_page_link);
c0105451:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105454:	83 e8 14             	sub    $0x14,%eax
c0105457:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010545a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010545d:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0105460:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105463:	8b 40 04             	mov    0x4(%eax),%eax
c0105466:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105469:	8b 12                	mov    (%edx),%edx
c010546b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010546e:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0105471:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105474:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105477:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010547a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010547d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105480:	89 10                	mov    %edx,(%eax)
    list_del(le);
    assert(p !=NULL);
c0105482:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105486:	75 24                	jne    c01054ac <_fifo_swap_out_victim+0xf2>
c0105488:	c7 44 24 0c 74 b0 10 	movl   $0xc010b074,0xc(%esp)
c010548f:	c0 
c0105490:	c7 44 24 08 2a b0 10 	movl   $0xc010b02a,0x8(%esp)
c0105497:	c0 
c0105498:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
c010549f:	00 
c01054a0:	c7 04 24 3f b0 10 c0 	movl   $0xc010b03f,(%esp)
c01054a7:	e8 54 af ff ff       	call   c0100400 <__panic>
    *ptr_page = p;
c01054ac:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054af:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01054b2:	89 10                	mov    %edx,(%eax)
    return 0;
c01054b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01054b9:	c9                   	leave  
c01054ba:	c3                   	ret    

c01054bb <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c01054bb:	55                   	push   %ebp
c01054bc:	89 e5                	mov    %esp,%ebp
c01054be:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c01054c1:	c7 04 24 80 b0 10 c0 	movl   $0xc010b080,(%esp)
c01054c8:	e8 dc ad ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c01054cd:	b8 00 30 00 00       	mov    $0x3000,%eax
c01054d2:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c01054d5:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c01054da:	83 f8 04             	cmp    $0x4,%eax
c01054dd:	74 24                	je     c0105503 <_fifo_check_swap+0x48>
c01054df:	c7 44 24 0c a6 b0 10 	movl   $0xc010b0a6,0xc(%esp)
c01054e6:	c0 
c01054e7:	c7 44 24 08 2a b0 10 	movl   $0xc010b02a,0x8(%esp)
c01054ee:	c0 
c01054ef:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
c01054f6:	00 
c01054f7:	c7 04 24 3f b0 10 c0 	movl   $0xc010b03f,(%esp)
c01054fe:	e8 fd ae ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0105503:	c7 04 24 b8 b0 10 c0 	movl   $0xc010b0b8,(%esp)
c010550a:	e8 9a ad ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c010550f:	b8 00 10 00 00       	mov    $0x1000,%eax
c0105514:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0105517:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c010551c:	83 f8 04             	cmp    $0x4,%eax
c010551f:	74 24                	je     c0105545 <_fifo_check_swap+0x8a>
c0105521:	c7 44 24 0c a6 b0 10 	movl   $0xc010b0a6,0xc(%esp)
c0105528:	c0 
c0105529:	c7 44 24 08 2a b0 10 	movl   $0xc010b02a,0x8(%esp)
c0105530:	c0 
c0105531:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
c0105538:	00 
c0105539:	c7 04 24 3f b0 10 c0 	movl   $0xc010b03f,(%esp)
c0105540:	e8 bb ae ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0105545:	c7 04 24 e0 b0 10 c0 	movl   $0xc010b0e0,(%esp)
c010554c:	e8 58 ad ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0105551:	b8 00 40 00 00       	mov    $0x4000,%eax
c0105556:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0105559:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c010555e:	83 f8 04             	cmp    $0x4,%eax
c0105561:	74 24                	je     c0105587 <_fifo_check_swap+0xcc>
c0105563:	c7 44 24 0c a6 b0 10 	movl   $0xc010b0a6,0xc(%esp)
c010556a:	c0 
c010556b:	c7 44 24 08 2a b0 10 	movl   $0xc010b02a,0x8(%esp)
c0105572:	c0 
c0105573:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c010557a:	00 
c010557b:	c7 04 24 3f b0 10 c0 	movl   $0xc010b03f,(%esp)
c0105582:	e8 79 ae ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0105587:	c7 04 24 08 b1 10 c0 	movl   $0xc010b108,(%esp)
c010558e:	e8 16 ad ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0105593:	b8 00 20 00 00       	mov    $0x2000,%eax
c0105598:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c010559b:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c01055a0:	83 f8 04             	cmp    $0x4,%eax
c01055a3:	74 24                	je     c01055c9 <_fifo_check_swap+0x10e>
c01055a5:	c7 44 24 0c a6 b0 10 	movl   $0xc010b0a6,0xc(%esp)
c01055ac:	c0 
c01055ad:	c7 44 24 08 2a b0 10 	movl   $0xc010b02a,0x8(%esp)
c01055b4:	c0 
c01055b5:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
c01055bc:	00 
c01055bd:	c7 04 24 3f b0 10 c0 	movl   $0xc010b03f,(%esp)
c01055c4:	e8 37 ae ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01055c9:	c7 04 24 30 b1 10 c0 	movl   $0xc010b130,(%esp)
c01055d0:	e8 d4 ac ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c01055d5:	b8 00 50 00 00       	mov    $0x5000,%eax
c01055da:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c01055dd:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c01055e2:	83 f8 05             	cmp    $0x5,%eax
c01055e5:	74 24                	je     c010560b <_fifo_check_swap+0x150>
c01055e7:	c7 44 24 0c 56 b1 10 	movl   $0xc010b156,0xc(%esp)
c01055ee:	c0 
c01055ef:	c7 44 24 08 2a b0 10 	movl   $0xc010b02a,0x8(%esp)
c01055f6:	c0 
c01055f7:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
c01055fe:	00 
c01055ff:	c7 04 24 3f b0 10 c0 	movl   $0xc010b03f,(%esp)
c0105606:	e8 f5 ad ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010560b:	c7 04 24 08 b1 10 c0 	movl   $0xc010b108,(%esp)
c0105612:	e8 92 ac ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0105617:	b8 00 20 00 00       	mov    $0x2000,%eax
c010561c:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c010561f:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c0105624:	83 f8 05             	cmp    $0x5,%eax
c0105627:	74 24                	je     c010564d <_fifo_check_swap+0x192>
c0105629:	c7 44 24 0c 56 b1 10 	movl   $0xc010b156,0xc(%esp)
c0105630:	c0 
c0105631:	c7 44 24 08 2a b0 10 	movl   $0xc010b02a,0x8(%esp)
c0105638:	c0 
c0105639:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
c0105640:	00 
c0105641:	c7 04 24 3f b0 10 c0 	movl   $0xc010b03f,(%esp)
c0105648:	e8 b3 ad ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c010564d:	c7 04 24 b8 b0 10 c0 	movl   $0xc010b0b8,(%esp)
c0105654:	e8 50 ac ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0105659:	b8 00 10 00 00       	mov    $0x1000,%eax
c010565e:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0105661:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c0105666:	83 f8 06             	cmp    $0x6,%eax
c0105669:	74 24                	je     c010568f <_fifo_check_swap+0x1d4>
c010566b:	c7 44 24 0c 65 b1 10 	movl   $0xc010b165,0xc(%esp)
c0105672:	c0 
c0105673:	c7 44 24 08 2a b0 10 	movl   $0xc010b02a,0x8(%esp)
c010567a:	c0 
c010567b:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0105682:	00 
c0105683:	c7 04 24 3f b0 10 c0 	movl   $0xc010b03f,(%esp)
c010568a:	e8 71 ad ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010568f:	c7 04 24 08 b1 10 c0 	movl   $0xc010b108,(%esp)
c0105696:	e8 0e ac ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c010569b:	b8 00 20 00 00       	mov    $0x2000,%eax
c01056a0:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c01056a3:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c01056a8:	83 f8 07             	cmp    $0x7,%eax
c01056ab:	74 24                	je     c01056d1 <_fifo_check_swap+0x216>
c01056ad:	c7 44 24 0c 74 b1 10 	movl   $0xc010b174,0xc(%esp)
c01056b4:	c0 
c01056b5:	c7 44 24 08 2a b0 10 	movl   $0xc010b02a,0x8(%esp)
c01056bc:	c0 
c01056bd:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c01056c4:	00 
c01056c5:	c7 04 24 3f b0 10 c0 	movl   $0xc010b03f,(%esp)
c01056cc:	e8 2f ad ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c01056d1:	c7 04 24 80 b0 10 c0 	movl   $0xc010b080,(%esp)
c01056d8:	e8 cc ab ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c01056dd:	b8 00 30 00 00       	mov    $0x3000,%eax
c01056e2:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c01056e5:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c01056ea:	83 f8 08             	cmp    $0x8,%eax
c01056ed:	74 24                	je     c0105713 <_fifo_check_swap+0x258>
c01056ef:	c7 44 24 0c 83 b1 10 	movl   $0xc010b183,0xc(%esp)
c01056f6:	c0 
c01056f7:	c7 44 24 08 2a b0 10 	movl   $0xc010b02a,0x8(%esp)
c01056fe:	c0 
c01056ff:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0105706:	00 
c0105707:	c7 04 24 3f b0 10 c0 	movl   $0xc010b03f,(%esp)
c010570e:	e8 ed ac ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0105713:	c7 04 24 e0 b0 10 c0 	movl   $0xc010b0e0,(%esp)
c010571a:	e8 8a ab ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c010571f:	b8 00 40 00 00       	mov    $0x4000,%eax
c0105724:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0105727:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c010572c:	83 f8 09             	cmp    $0x9,%eax
c010572f:	74 24                	je     c0105755 <_fifo_check_swap+0x29a>
c0105731:	c7 44 24 0c 92 b1 10 	movl   $0xc010b192,0xc(%esp)
c0105738:	c0 
c0105739:	c7 44 24 08 2a b0 10 	movl   $0xc010b02a,0x8(%esp)
c0105740:	c0 
c0105741:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c0105748:	00 
c0105749:	c7 04 24 3f b0 10 c0 	movl   $0xc010b03f,(%esp)
c0105750:	e8 ab ac ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0105755:	c7 04 24 30 b1 10 c0 	movl   $0xc010b130,(%esp)
c010575c:	e8 48 ab ff ff       	call   c01002a9 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0105761:	b8 00 50 00 00       	mov    $0x5000,%eax
c0105766:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c0105769:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c010576e:	83 f8 0a             	cmp    $0xa,%eax
c0105771:	74 24                	je     c0105797 <_fifo_check_swap+0x2dc>
c0105773:	c7 44 24 0c a1 b1 10 	movl   $0xc010b1a1,0xc(%esp)
c010577a:	c0 
c010577b:	c7 44 24 08 2a b0 10 	movl   $0xc010b02a,0x8(%esp)
c0105782:	c0 
c0105783:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
c010578a:	00 
c010578b:	c7 04 24 3f b0 10 c0 	movl   $0xc010b03f,(%esp)
c0105792:	e8 69 ac ff ff       	call   c0100400 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0105797:	c7 04 24 b8 b0 10 c0 	movl   $0xc010b0b8,(%esp)
c010579e:	e8 06 ab ff ff       	call   c01002a9 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c01057a3:	b8 00 10 00 00       	mov    $0x1000,%eax
c01057a8:	0f b6 00             	movzbl (%eax),%eax
c01057ab:	3c 0a                	cmp    $0xa,%al
c01057ad:	74 24                	je     c01057d3 <_fifo_check_swap+0x318>
c01057af:	c7 44 24 0c b4 b1 10 	movl   $0xc010b1b4,0xc(%esp)
c01057b6:	c0 
c01057b7:	c7 44 24 08 2a b0 10 	movl   $0xc010b02a,0x8(%esp)
c01057be:	c0 
c01057bf:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c01057c6:	00 
c01057c7:	c7 04 24 3f b0 10 c0 	movl   $0xc010b03f,(%esp)
c01057ce:	e8 2d ac ff ff       	call   c0100400 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c01057d3:	b8 00 10 00 00       	mov    $0x1000,%eax
c01057d8:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c01057db:	a1 64 8f 12 c0       	mov    0xc0128f64,%eax
c01057e0:	83 f8 0b             	cmp    $0xb,%eax
c01057e3:	74 24                	je     c0105809 <_fifo_check_swap+0x34e>
c01057e5:	c7 44 24 0c d5 b1 10 	movl   $0xc010b1d5,0xc(%esp)
c01057ec:	c0 
c01057ed:	c7 44 24 08 2a b0 10 	movl   $0xc010b02a,0x8(%esp)
c01057f4:	c0 
c01057f5:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c01057fc:	00 
c01057fd:	c7 04 24 3f b0 10 c0 	movl   $0xc010b03f,(%esp)
c0105804:	e8 f7 ab ff ff       	call   c0100400 <__panic>
    return 0;
c0105809:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010580e:	c9                   	leave  
c010580f:	c3                   	ret    

c0105810 <_fifo_init>:


static int
_fifo_init(void)
{
c0105810:	55                   	push   %ebp
c0105811:	89 e5                	mov    %esp,%ebp
    return 0;
c0105813:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105818:	5d                   	pop    %ebp
c0105819:	c3                   	ret    

c010581a <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c010581a:	55                   	push   %ebp
c010581b:	89 e5                	mov    %esp,%ebp
    return 0;
c010581d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105822:	5d                   	pop    %ebp
c0105823:	c3                   	ret    

c0105824 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0105824:	55                   	push   %ebp
c0105825:	89 e5                	mov    %esp,%ebp
c0105827:	b8 00 00 00 00       	mov    $0x0,%eax
c010582c:	5d                   	pop    %ebp
c010582d:	c3                   	ret    

c010582e <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010582e:	55                   	push   %ebp
c010582f:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0105831:	8b 45 08             	mov    0x8(%ebp),%eax
c0105834:	8b 15 40 b1 12 c0    	mov    0xc012b140,%edx
c010583a:	29 d0                	sub    %edx,%eax
c010583c:	c1 f8 05             	sar    $0x5,%eax
}
c010583f:	5d                   	pop    %ebp
c0105840:	c3                   	ret    

c0105841 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0105841:	55                   	push   %ebp
c0105842:	89 e5                	mov    %esp,%ebp
c0105844:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0105847:	8b 45 08             	mov    0x8(%ebp),%eax
c010584a:	89 04 24             	mov    %eax,(%esp)
c010584d:	e8 dc ff ff ff       	call   c010582e <page2ppn>
c0105852:	c1 e0 0c             	shl    $0xc,%eax
}
c0105855:	c9                   	leave  
c0105856:	c3                   	ret    

c0105857 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0105857:	55                   	push   %ebp
c0105858:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010585a:	8b 45 08             	mov    0x8(%ebp),%eax
c010585d:	8b 00                	mov    (%eax),%eax
}
c010585f:	5d                   	pop    %ebp
c0105860:	c3                   	ret    

c0105861 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0105861:	55                   	push   %ebp
c0105862:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0105864:	8b 45 08             	mov    0x8(%ebp),%eax
c0105867:	8b 55 0c             	mov    0xc(%ebp),%edx
c010586a:	89 10                	mov    %edx,(%eax)
}
c010586c:	90                   	nop
c010586d:	5d                   	pop    %ebp
c010586e:	c3                   	ret    

c010586f <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c010586f:	55                   	push   %ebp
c0105870:	89 e5                	mov    %esp,%ebp
c0105872:	83 ec 10             	sub    $0x10,%esp
c0105875:	c7 45 fc 2c b1 12 c0 	movl   $0xc012b12c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010587c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010587f:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0105882:	89 50 04             	mov    %edx,0x4(%eax)
c0105885:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105888:	8b 50 04             	mov    0x4(%eax),%edx
c010588b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010588e:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0105890:	c7 05 34 b1 12 c0 00 	movl   $0x0,0xc012b134
c0105897:	00 00 00 
}
c010589a:	90                   	nop
c010589b:	c9                   	leave  
c010589c:	c3                   	ret    

c010589d <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c010589d:	55                   	push   %ebp
c010589e:	89 e5                	mov    %esp,%ebp
c01058a0:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01058a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01058a7:	75 24                	jne    c01058cd <default_init_memmap+0x30>
c01058a9:	c7 44 24 0c f8 b1 10 	movl   $0xc010b1f8,0xc(%esp)
c01058b0:	c0 
c01058b1:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c01058b8:	c0 
c01058b9:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01058c0:	00 
c01058c1:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c01058c8:	e8 33 ab ff ff       	call   c0100400 <__panic>
    struct Page *p = base;
c01058cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01058d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01058d3:	e9 de 00 00 00       	jmp    c01059b6 <default_init_memmap+0x119>
        assert(PageReserved(p));
c01058d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058db:	83 c0 04             	add    $0x4,%eax
c01058de:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c01058e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01058e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01058eb:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01058ee:	0f a3 10             	bt     %edx,(%eax)
c01058f1:	19 c0                	sbb    %eax,%eax
c01058f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c01058f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01058fa:	0f 95 c0             	setne  %al
c01058fd:	0f b6 c0             	movzbl %al,%eax
c0105900:	85 c0                	test   %eax,%eax
c0105902:	75 24                	jne    c0105928 <default_init_memmap+0x8b>
c0105904:	c7 44 24 0c 29 b2 10 	movl   $0xc010b229,0xc(%esp)
c010590b:	c0 
c010590c:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0105913:	c0 
c0105914:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c010591b:	00 
c010591c:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0105923:	e8 d8 aa ff ff       	call   c0100400 <__panic>
        p->flags = p->property = 0;
c0105928:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010592b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0105932:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105935:	8b 50 08             	mov    0x8(%eax),%edx
c0105938:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010593b:	89 50 04             	mov    %edx,0x4(%eax)
        SetPageProperty(p);
c010593e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105941:	83 c0 04             	add    $0x4,%eax
c0105944:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c010594b:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010594e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105951:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105954:	0f ab 10             	bts    %edx,(%eax)
        set_page_ref(p, 0);
c0105957:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010595e:	00 
c010595f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105962:	89 04 24             	mov    %eax,(%esp)
c0105965:	e8 f7 fe ff ff       	call   c0105861 <set_page_ref>
        list_add_before(&free_list, &(p->page_link));
c010596a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010596d:	83 c0 0c             	add    $0xc,%eax
c0105970:	c7 45 f0 2c b1 12 c0 	movl   $0xc012b12c,-0x10(%ebp)
c0105977:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010597a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010597d:	8b 00                	mov    (%eax),%eax
c010597f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105982:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0105985:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0105988:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010598b:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010598e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105991:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105994:	89 10                	mov    %edx,(%eax)
c0105996:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105999:	8b 10                	mov    (%eax),%edx
c010599b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010599e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01059a1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01059a4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01059a7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01059aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01059ad:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01059b0:	89 10                	mov    %edx,(%eax)

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c01059b2:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c01059b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059b9:	c1 e0 05             	shl    $0x5,%eax
c01059bc:	89 c2                	mov    %eax,%edx
c01059be:	8b 45 08             	mov    0x8(%ebp),%eax
c01059c1:	01 d0                	add    %edx,%eax
c01059c3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01059c6:	0f 85 0c ff ff ff    	jne    c01058d8 <default_init_memmap+0x3b>
        p->flags = p->property = 0;
        SetPageProperty(p);
        set_page_ref(p, 0);
        list_add_before(&free_list, &(p->page_link));
    }
    base->property = n;
c01059cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01059cf:	8b 55 0c             	mov    0xc(%ebp),%edx
c01059d2:	89 50 08             	mov    %edx,0x8(%eax)
    // SetPageProperty(base);
    // list_add_before(&free_list, &(p->page_link));
    nr_free += n;
c01059d5:	8b 15 34 b1 12 c0    	mov    0xc012b134,%edx
c01059db:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059de:	01 d0                	add    %edx,%eax
c01059e0:	a3 34 b1 12 c0       	mov    %eax,0xc012b134
    // list_add(&free_list, &(base->page_link));
}
c01059e5:	90                   	nop
c01059e6:	c9                   	leave  
c01059e7:	c3                   	ret    

c01059e8 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01059e8:	55                   	push   %ebp
c01059e9:	89 e5                	mov    %esp,%ebp
c01059eb:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c01059ee:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01059f2:	75 24                	jne    c0105a18 <default_alloc_pages+0x30>
c01059f4:	c7 44 24 0c f8 b1 10 	movl   $0xc010b1f8,0xc(%esp)
c01059fb:	c0 
c01059fc:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0105a03:	c0 
c0105a04:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
c0105a0b:	00 
c0105a0c:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0105a13:	e8 e8 a9 ff ff       	call   c0100400 <__panic>
    if (n > nr_free)     return NULL;
c0105a18:	a1 34 b1 12 c0       	mov    0xc012b134,%eax
c0105a1d:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105a20:	73 0a                	jae    c0105a2c <default_alloc_pages+0x44>
c0105a22:	b8 00 00 00 00       	mov    $0x0,%eax
c0105a27:	e9 04 01 00 00       	jmp    c0105b30 <default_alloc_pages+0x148>
//    struct Page *page = NULL;
    list_entry_t *le = &free_list;
c0105a2c:	c7 45 f4 2c b1 12 c0 	movl   $0xc012b12c,-0xc(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105a33:	e9 d7 00 00 00       	jmp    c0105b0f <default_alloc_pages+0x127>
        struct Page *p = le2page(le, page_link);
c0105a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a3b:	83 e8 0c             	sub    $0xc,%eax
c0105a3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0105a41:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a44:	8b 40 08             	mov    0x8(%eax),%eax
c0105a47:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105a4a:	0f 82 bf 00 00 00    	jb     c0105b0f <default_alloc_pages+0x127>
            list_entry_t *next;
            for(int i=0;i<n;i++)
c0105a50:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0105a57:	eb 7b                	jmp    c0105ad4 <default_alloc_pages+0xec>
            {
                struct Page *page = le2page(le, page_link);
c0105a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a5c:	83 e8 0c             	sub    $0xc,%eax
c0105a5f:	89 45 e8             	mov    %eax,-0x18(%ebp)
                SetPageReserved(page);
c0105a62:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a65:	83 c0 04             	add    $0x4,%eax
c0105a68:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0105a6f:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0105a72:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105a75:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105a78:	0f ab 10             	bts    %edx,(%eax)
                ClearPageProperty(page);
c0105a7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a7e:	83 c0 04             	add    $0x4,%eax
c0105a81:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c0105a88:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105a8b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105a8e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105a91:	0f b3 10             	btr    %edx,(%eax)
c0105a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a97:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0105a9a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105a9d:	8b 40 04             	mov    0x4(%eax),%eax
                next=list_next(le);
c0105aa0:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0105aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105aa6:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0105aa9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105aac:	8b 40 04             	mov    0x4(%eax),%eax
c0105aaf:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105ab2:	8b 12                	mov    (%edx),%edx
c0105ab4:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0105ab7:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0105aba:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105abd:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105ac0:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105ac3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105ac6:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105ac9:	89 10                	mov    %edx,(%eax)
                list_del(le);
                le = next;
c0105acb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105ace:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            list_entry_t *next;
            for(int i=0;i<n;i++)
c0105ad1:	ff 45 f0             	incl   -0x10(%ebp)
c0105ad4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ad7:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105ada:	0f 82 79 ff ff ff    	jb     c0105a59 <default_alloc_pages+0x71>
                ClearPageProperty(page);
                next=list_next(le);
                list_del(le);
                le = next;
            }
            if(p->property > n)
c0105ae0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ae3:	8b 40 08             	mov    0x8(%eax),%eax
c0105ae6:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105ae9:	76 12                	jbe    c0105afd <default_alloc_pages+0x115>
                (le2page(le,page_link))->property = p->property - n;
c0105aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105aee:	8d 50 f4             	lea    -0xc(%eax),%edx
c0105af1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105af4:	8b 40 08             	mov    0x8(%eax),%eax
c0105af7:	2b 45 08             	sub    0x8(%ebp),%eax
c0105afa:	89 42 08             	mov    %eax,0x8(%edx)
            nr_free -= n;
c0105afd:	a1 34 b1 12 c0       	mov    0xc012b134,%eax
c0105b02:	2b 45 08             	sub    0x8(%ebp),%eax
c0105b05:	a3 34 b1 12 c0       	mov    %eax,0xc012b134
            return p;
c0105b0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b0d:	eb 21                	jmp    c0105b30 <default_alloc_pages+0x148>
c0105b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0105b15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b18:	8b 40 04             	mov    0x4(%eax),%eax
default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free)     return NULL;
//    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0105b1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105b1e:	81 7d f4 2c b1 12 c0 	cmpl   $0xc012b12c,-0xc(%ebp)
c0105b25:	0f 85 0d ff ff ff    	jne    c0105a38 <default_alloc_pages+0x50>
      }
          list_del(&(page->page_link));
          nr_free -= n;
          ClearPageProperty(page);
      } */
    return NULL;
c0105b2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105b30:	c9                   	leave  
c0105b31:	c3                   	ret    

c0105b32 <default_free_pages>:
        le = list_next(le);
    } //insert,if the freeing block is before one free block
    list_add_before(le, &(base->page_link));//insert before le
}*/
static void
default_free_pages(struct Page *base, size_t n) {
c0105b32:	55                   	push   %ebp
c0105b33:	89 e5                	mov    %esp,%ebp
c0105b35:	83 ec 78             	sub    $0x78,%esp
    assert(n > 0);
c0105b38:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105b3c:	75 24                	jne    c0105b62 <default_free_pages+0x30>
c0105b3e:	c7 44 24 0c f8 b1 10 	movl   $0xc010b1f8,0xc(%esp)
c0105b45:	c0 
c0105b46:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0105b4d:	c0 
c0105b4e:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0105b55:	00 
c0105b56:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0105b5d:	e8 9e a8 ff ff       	call   c0100400 <__panic>
    assert(PageReserved(base));
c0105b62:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b65:	83 c0 04             	add    $0x4,%eax
c0105b68:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
c0105b6f:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105b72:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105b75:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0105b78:	0f a3 10             	bt     %edx,(%eax)
c0105b7b:	19 c0                	sbb    %eax,%eax
c0105b7d:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0105b80:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0105b84:	0f 95 c0             	setne  %al
c0105b87:	0f b6 c0             	movzbl %al,%eax
c0105b8a:	85 c0                	test   %eax,%eax
c0105b8c:	75 24                	jne    c0105bb2 <default_free_pages+0x80>
c0105b8e:	c7 44 24 0c 39 b2 10 	movl   $0xc010b239,0xc(%esp)
c0105b95:	c0 
c0105b96:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0105b9d:	c0 
c0105b9e:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0105ba5:	00 
c0105ba6:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0105bad:	e8 4e a8 ff ff       	call   c0100400 <__panic>

    list_entry_t *le = &free_list;
c0105bb2:	c7 45 f4 2c b1 12 c0 	movl   $0xc012b12c,-0xc(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105bb9:	eb 0b                	jmp    c0105bc6 <default_free_pages+0x94>
        if ((le2page(le, page_link)) > base) {
c0105bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bbe:	83 e8 0c             	sub    $0xc,%eax
c0105bc1:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105bc4:	77 1a                	ja     c0105be0 <default_free_pages+0xae>
c0105bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105bcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105bcf:	8b 40 04             	mov    0x4(%eax),%eax
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    assert(PageReserved(base));

    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0105bd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105bd5:	81 7d f4 2c b1 12 c0 	cmpl   $0xc012b12c,-0xc(%ebp)
c0105bdc:	75 dd                	jne    c0105bbb <default_free_pages+0x89>
c0105bde:	eb 01                	jmp    c0105be1 <default_free_pages+0xaf>
        if ((le2page(le, page_link)) > base) {
            break;
c0105be0:	90                   	nop
        }
    }
    list_entry_t *last_head = le, *insert_prev = list_prev(le);
c0105be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105be4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bea:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c0105bed:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105bf0:	8b 00                	mov    (%eax),%eax
c0105bf2:	89 45 d8             	mov    %eax,-0x28(%ebp)
    while ((last_head = list_prev(last_head)) != &free_list) {
c0105bf5:	eb 0d                	jmp    c0105c04 <default_free_pages+0xd2>
        if ((le2page(last_head, page_link))->property > 0) {
c0105bf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bfa:	83 e8 0c             	sub    $0xc,%eax
c0105bfd:	8b 40 08             	mov    0x8(%eax),%eax
c0105c00:	85 c0                	test   %eax,%eax
c0105c02:	75 19                	jne    c0105c1d <default_free_pages+0xeb>
c0105c04:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c07:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105c0a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105c0d:	8b 00                	mov    (%eax),%eax
        if ((le2page(le, page_link)) > base) {
            break;
        }
    }
    list_entry_t *last_head = le, *insert_prev = list_prev(le);
    while ((last_head = list_prev(last_head)) != &free_list) {
c0105c0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c12:	81 7d f0 2c b1 12 c0 	cmpl   $0xc012b12c,-0x10(%ebp)
c0105c19:	75 dc                	jne    c0105bf7 <default_free_pages+0xc5>
c0105c1b:	eb 01                	jmp    c0105c1e <default_free_pages+0xec>
        if ((le2page(last_head, page_link))->property > 0) {
            break;
c0105c1d:	90                   	nop
        }
    }

    struct Page *p = base, *block_header;
c0105c1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c21:	89 45 ec             	mov    %eax,-0x14(%ebp)
    set_page_ref(base, 0);
c0105c24:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105c2b:	00 
c0105c2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c2f:	89 04 24             	mov    %eax,(%esp)
c0105c32:	e8 2a fc ff ff       	call   c0105861 <set_page_ref>
    for (; p != base + n; ++p) {
c0105c37:	e9 87 00 00 00       	jmp    c0105cc3 <default_free_pages+0x191>
        ClearPageReserved(p);
c0105c3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c3f:	83 c0 04             	add    $0x4,%eax
c0105c42:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
c0105c49:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105c4c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105c4f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105c52:	0f b3 10             	btr    %edx,(%eax)
        SetPageProperty(p);
c0105c55:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c58:	83 c0 04             	add    $0x4,%eax
c0105c5b:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0105c62:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105c65:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105c68:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105c6b:	0f ab 10             	bts    %edx,(%eax)
        p->property = 0;
c0105c6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c71:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        list_add_before(le, &(p->page_link));
c0105c78:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c7b:	8d 50 0c             	lea    0xc(%eax),%edx
c0105c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c81:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0105c84:	89 55 b8             	mov    %edx,-0x48(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0105c87:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105c8a:	8b 00                	mov    (%eax),%eax
c0105c8c:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0105c8f:	89 55 b4             	mov    %edx,-0x4c(%ebp)
c0105c92:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0105c95:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105c98:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0105c9b:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105c9e:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0105ca1:	89 10                	mov    %edx,(%eax)
c0105ca3:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105ca6:	8b 10                	mov    (%eax),%edx
c0105ca8:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105cab:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105cae:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105cb1:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0105cb4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105cb7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105cba:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0105cbd:	89 10                	mov    %edx,(%eax)
        }
    }

    struct Page *p = base, *block_header;
    set_page_ref(base, 0);
    for (; p != base + n; ++p) {
c0105cbf:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
c0105cc3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cc6:	c1 e0 05             	shl    $0x5,%eax
c0105cc9:	89 c2                	mov    %eax,%edx
c0105ccb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cce:	01 d0                	add    %edx,%eax
c0105cd0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105cd3:	0f 85 63 ff ff ff    	jne    c0105c3c <default_free_pages+0x10a>
        ClearPageReserved(p);
        SetPageProperty(p);
        p->property = 0;
        list_add_before(le, &(p->page_link));
    }
    if ((last_head == &free_list) || ((le2page(insert_prev, page_link)) != base - 1)) {
c0105cd9:	81 7d f0 2c b1 12 c0 	cmpl   $0xc012b12c,-0x10(%ebp)
c0105ce0:	74 10                	je     c0105cf2 <default_free_pages+0x1c0>
c0105ce2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105ce5:	8d 50 f4             	lea    -0xc(%eax),%edx
c0105ce8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ceb:	83 e8 20             	sub    $0x20,%eax
c0105cee:	39 c2                	cmp    %eax,%edx
c0105cf0:	74 11                	je     c0105d03 <default_free_pages+0x1d1>
        base->property = n;
c0105cf2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cf5:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105cf8:	89 50 08             	mov    %edx,0x8(%eax)
        block_header = base;
c0105cfb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cfe:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105d01:	eb 1a                	jmp    c0105d1d <default_free_pages+0x1eb>
    } else {
        block_header = le2page(last_head, page_link);
c0105d03:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d06:	83 e8 0c             	sub    $0xc,%eax
c0105d09:	89 45 e8             	mov    %eax,-0x18(%ebp)
        block_header->property += n;
c0105d0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d0f:	8b 50 08             	mov    0x8(%eax),%edx
c0105d12:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d15:	01 c2                	add    %eax,%edx
c0105d17:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d1a:	89 50 08             	mov    %edx,0x8(%eax)
    }
    struct Page *le_page = le2page(le, page_link);
c0105d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d20:	83 e8 0c             	sub    $0xc,%eax
c0105d23:	89 45 c8             	mov    %eax,-0x38(%ebp)
    if ((le != &free_list) && (le_page == base + n)) {
c0105d26:	81 7d f4 2c b1 12 c0 	cmpl   $0xc012b12c,-0xc(%ebp)
c0105d2d:	74 30                	je     c0105d5f <default_free_pages+0x22d>
c0105d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d32:	c1 e0 05             	shl    $0x5,%eax
c0105d35:	89 c2                	mov    %eax,%edx
c0105d37:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d3a:	01 d0                	add    %edx,%eax
c0105d3c:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0105d3f:	75 1e                	jne    c0105d5f <default_free_pages+0x22d>
        block_header->property += le_page->property;
c0105d41:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d44:	8b 50 08             	mov    0x8(%eax),%edx
c0105d47:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105d4a:	8b 40 08             	mov    0x8(%eax),%eax
c0105d4d:	01 c2                	add    %eax,%edx
c0105d4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d52:	89 50 08             	mov    %edx,0x8(%eax)
        le_page->property = 0;
c0105d55:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105d58:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    nr_free += n;
c0105d5f:	8b 15 34 b1 12 c0    	mov    0xc012b134,%edx
c0105d65:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d68:	01 d0                	add    %edx,%eax
c0105d6a:	a3 34 b1 12 c0       	mov    %eax,0xc012b134
}
c0105d6f:	90                   	nop
c0105d70:	c9                   	leave  
c0105d71:	c3                   	ret    

c0105d72 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0105d72:	55                   	push   %ebp
c0105d73:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0105d75:	a1 34 b1 12 c0       	mov    0xc012b134,%eax
}
c0105d7a:	5d                   	pop    %ebp
c0105d7b:	c3                   	ret    

c0105d7c <basic_check>:

static void
basic_check(void) {
c0105d7c:	55                   	push   %ebp
c0105d7d:	89 e5                	mov    %esp,%ebp
c0105d7f:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0105d82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d92:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0105d95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105d9c:	e8 86 0e 00 00       	call   c0106c27 <alloc_pages>
c0105da1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105da4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105da8:	75 24                	jne    c0105dce <basic_check+0x52>
c0105daa:	c7 44 24 0c 4c b2 10 	movl   $0xc010b24c,0xc(%esp)
c0105db1:	c0 
c0105db2:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0105db9:	c0 
c0105dba:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0105dc1:	00 
c0105dc2:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0105dc9:	e8 32 a6 ff ff       	call   c0100400 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0105dce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105dd5:	e8 4d 0e 00 00       	call   c0106c27 <alloc_pages>
c0105dda:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ddd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105de1:	75 24                	jne    c0105e07 <basic_check+0x8b>
c0105de3:	c7 44 24 0c 68 b2 10 	movl   $0xc010b268,0xc(%esp)
c0105dea:	c0 
c0105deb:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0105df2:	c0 
c0105df3:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0105dfa:	00 
c0105dfb:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0105e02:	e8 f9 a5 ff ff       	call   c0100400 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0105e07:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105e0e:	e8 14 0e 00 00       	call   c0106c27 <alloc_pages>
c0105e13:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105e16:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105e1a:	75 24                	jne    c0105e40 <basic_check+0xc4>
c0105e1c:	c7 44 24 0c 84 b2 10 	movl   $0xc010b284,0xc(%esp)
c0105e23:	c0 
c0105e24:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0105e2b:	c0 
c0105e2c:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0105e33:	00 
c0105e34:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0105e3b:	e8 c0 a5 ff ff       	call   c0100400 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0105e40:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e43:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105e46:	74 10                	je     c0105e58 <basic_check+0xdc>
c0105e48:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e4b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105e4e:	74 08                	je     c0105e58 <basic_check+0xdc>
c0105e50:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e53:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105e56:	75 24                	jne    c0105e7c <basic_check+0x100>
c0105e58:	c7 44 24 0c a0 b2 10 	movl   $0xc010b2a0,0xc(%esp)
c0105e5f:	c0 
c0105e60:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0105e67:	c0 
c0105e68:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c0105e6f:	00 
c0105e70:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0105e77:	e8 84 a5 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0105e7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e7f:	89 04 24             	mov    %eax,(%esp)
c0105e82:	e8 d0 f9 ff ff       	call   c0105857 <page_ref>
c0105e87:	85 c0                	test   %eax,%eax
c0105e89:	75 1e                	jne    c0105ea9 <basic_check+0x12d>
c0105e8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e8e:	89 04 24             	mov    %eax,(%esp)
c0105e91:	e8 c1 f9 ff ff       	call   c0105857 <page_ref>
c0105e96:	85 c0                	test   %eax,%eax
c0105e98:	75 0f                	jne    c0105ea9 <basic_check+0x12d>
c0105e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e9d:	89 04 24             	mov    %eax,(%esp)
c0105ea0:	e8 b2 f9 ff ff       	call   c0105857 <page_ref>
c0105ea5:	85 c0                	test   %eax,%eax
c0105ea7:	74 24                	je     c0105ecd <basic_check+0x151>
c0105ea9:	c7 44 24 0c c4 b2 10 	movl   $0xc010b2c4,0xc(%esp)
c0105eb0:	c0 
c0105eb1:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0105eb8:	c0 
c0105eb9:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c0105ec0:	00 
c0105ec1:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0105ec8:	e8 33 a5 ff ff       	call   c0100400 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0105ecd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ed0:	89 04 24             	mov    %eax,(%esp)
c0105ed3:	e8 69 f9 ff ff       	call   c0105841 <page2pa>
c0105ed8:	8b 15 80 8f 12 c0    	mov    0xc0128f80,%edx
c0105ede:	c1 e2 0c             	shl    $0xc,%edx
c0105ee1:	39 d0                	cmp    %edx,%eax
c0105ee3:	72 24                	jb     c0105f09 <basic_check+0x18d>
c0105ee5:	c7 44 24 0c 00 b3 10 	movl   $0xc010b300,0xc(%esp)
c0105eec:	c0 
c0105eed:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0105ef4:	c0 
c0105ef5:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0105efc:	00 
c0105efd:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0105f04:	e8 f7 a4 ff ff       	call   c0100400 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0105f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f0c:	89 04 24             	mov    %eax,(%esp)
c0105f0f:	e8 2d f9 ff ff       	call   c0105841 <page2pa>
c0105f14:	8b 15 80 8f 12 c0    	mov    0xc0128f80,%edx
c0105f1a:	c1 e2 0c             	shl    $0xc,%edx
c0105f1d:	39 d0                	cmp    %edx,%eax
c0105f1f:	72 24                	jb     c0105f45 <basic_check+0x1c9>
c0105f21:	c7 44 24 0c 1d b3 10 	movl   $0xc010b31d,0xc(%esp)
c0105f28:	c0 
c0105f29:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0105f30:	c0 
c0105f31:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
c0105f38:	00 
c0105f39:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0105f40:	e8 bb a4 ff ff       	call   c0100400 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0105f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f48:	89 04 24             	mov    %eax,(%esp)
c0105f4b:	e8 f1 f8 ff ff       	call   c0105841 <page2pa>
c0105f50:	8b 15 80 8f 12 c0    	mov    0xc0128f80,%edx
c0105f56:	c1 e2 0c             	shl    $0xc,%edx
c0105f59:	39 d0                	cmp    %edx,%eax
c0105f5b:	72 24                	jb     c0105f81 <basic_check+0x205>
c0105f5d:	c7 44 24 0c 3a b3 10 	movl   $0xc010b33a,0xc(%esp)
c0105f64:	c0 
c0105f65:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0105f6c:	c0 
c0105f6d:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c0105f74:	00 
c0105f75:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0105f7c:	e8 7f a4 ff ff       	call   c0100400 <__panic>

    list_entry_t free_list_store = free_list;
c0105f81:	a1 2c b1 12 c0       	mov    0xc012b12c,%eax
c0105f86:	8b 15 30 b1 12 c0    	mov    0xc012b130,%edx
c0105f8c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105f8f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105f92:	c7 45 e4 2c b1 12 c0 	movl   $0xc012b12c,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0105f99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105f9c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105f9f:	89 50 04             	mov    %edx,0x4(%eax)
c0105fa2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105fa5:	8b 50 04             	mov    0x4(%eax),%edx
c0105fa8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105fab:	89 10                	mov    %edx,(%eax)
c0105fad:	c7 45 d8 2c b1 12 c0 	movl   $0xc012b12c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0105fb4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105fb7:	8b 40 04             	mov    0x4(%eax),%eax
c0105fba:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0105fbd:	0f 94 c0             	sete   %al
c0105fc0:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105fc3:	85 c0                	test   %eax,%eax
c0105fc5:	75 24                	jne    c0105feb <basic_check+0x26f>
c0105fc7:	c7 44 24 0c 57 b3 10 	movl   $0xc010b357,0xc(%esp)
c0105fce:	c0 
c0105fcf:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0105fd6:	c0 
c0105fd7:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0105fde:	00 
c0105fdf:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0105fe6:	e8 15 a4 ff ff       	call   c0100400 <__panic>

    unsigned int nr_free_store = nr_free;
c0105feb:	a1 34 b1 12 c0       	mov    0xc012b134,%eax
c0105ff0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0105ff3:	c7 05 34 b1 12 c0 00 	movl   $0x0,0xc012b134
c0105ffa:	00 00 00 

    assert(alloc_page() == NULL);
c0105ffd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106004:	e8 1e 0c 00 00       	call   c0106c27 <alloc_pages>
c0106009:	85 c0                	test   %eax,%eax
c010600b:	74 24                	je     c0106031 <basic_check+0x2b5>
c010600d:	c7 44 24 0c 6e b3 10 	movl   $0xc010b36e,0xc(%esp)
c0106014:	c0 
c0106015:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c010601c:	c0 
c010601d:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
c0106024:	00 
c0106025:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c010602c:	e8 cf a3 ff ff       	call   c0100400 <__panic>

    free_page(p0);
c0106031:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106038:	00 
c0106039:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010603c:	89 04 24             	mov    %eax,(%esp)
c010603f:	e8 4e 0c 00 00       	call   c0106c92 <free_pages>
    free_page(p1);
c0106044:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010604b:	00 
c010604c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010604f:	89 04 24             	mov    %eax,(%esp)
c0106052:	e8 3b 0c 00 00       	call   c0106c92 <free_pages>
    free_page(p2);
c0106057:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010605e:	00 
c010605f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106062:	89 04 24             	mov    %eax,(%esp)
c0106065:	e8 28 0c 00 00       	call   c0106c92 <free_pages>
    assert(nr_free == 3);
c010606a:	a1 34 b1 12 c0       	mov    0xc012b134,%eax
c010606f:	83 f8 03             	cmp    $0x3,%eax
c0106072:	74 24                	je     c0106098 <basic_check+0x31c>
c0106074:	c7 44 24 0c 83 b3 10 	movl   $0xc010b383,0xc(%esp)
c010607b:	c0 
c010607c:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0106083:	c0 
c0106084:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c010608b:	00 
c010608c:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0106093:	e8 68 a3 ff ff       	call   c0100400 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0106098:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010609f:	e8 83 0b 00 00       	call   c0106c27 <alloc_pages>
c01060a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01060a7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01060ab:	75 24                	jne    c01060d1 <basic_check+0x355>
c01060ad:	c7 44 24 0c 4c b2 10 	movl   $0xc010b24c,0xc(%esp)
c01060b4:	c0 
c01060b5:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c01060bc:	c0 
c01060bd:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c01060c4:	00 
c01060c5:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c01060cc:	e8 2f a3 ff ff       	call   c0100400 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01060d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01060d8:	e8 4a 0b 00 00       	call   c0106c27 <alloc_pages>
c01060dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01060e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01060e4:	75 24                	jne    c010610a <basic_check+0x38e>
c01060e6:	c7 44 24 0c 68 b2 10 	movl   $0xc010b268,0xc(%esp)
c01060ed:	c0 
c01060ee:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c01060f5:	c0 
c01060f6:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
c01060fd:	00 
c01060fe:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0106105:	e8 f6 a2 ff ff       	call   c0100400 <__panic>
    assert((p2 = alloc_page()) != NULL);
c010610a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106111:	e8 11 0b 00 00       	call   c0106c27 <alloc_pages>
c0106116:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106119:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010611d:	75 24                	jne    c0106143 <basic_check+0x3c7>
c010611f:	c7 44 24 0c 84 b2 10 	movl   $0xc010b284,0xc(%esp)
c0106126:	c0 
c0106127:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c010612e:	c0 
c010612f:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c0106136:	00 
c0106137:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c010613e:	e8 bd a2 ff ff       	call   c0100400 <__panic>

    assert(alloc_page() == NULL);
c0106143:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010614a:	e8 d8 0a 00 00       	call   c0106c27 <alloc_pages>
c010614f:	85 c0                	test   %eax,%eax
c0106151:	74 24                	je     c0106177 <basic_check+0x3fb>
c0106153:	c7 44 24 0c 6e b3 10 	movl   $0xc010b36e,0xc(%esp)
c010615a:	c0 
c010615b:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0106162:	c0 
c0106163:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c010616a:	00 
c010616b:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0106172:	e8 89 a2 ff ff       	call   c0100400 <__panic>

    free_page(p0);
c0106177:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010617e:	00 
c010617f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106182:	89 04 24             	mov    %eax,(%esp)
c0106185:	e8 08 0b 00 00       	call   c0106c92 <free_pages>
c010618a:	c7 45 e8 2c b1 12 c0 	movl   $0xc012b12c,-0x18(%ebp)
c0106191:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106194:	8b 40 04             	mov    0x4(%eax),%eax
c0106197:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010619a:	0f 94 c0             	sete   %al
c010619d:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c01061a0:	85 c0                	test   %eax,%eax
c01061a2:	74 24                	je     c01061c8 <basic_check+0x44c>
c01061a4:	c7 44 24 0c 90 b3 10 	movl   $0xc010b390,0xc(%esp)
c01061ab:	c0 
c01061ac:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c01061b3:	c0 
c01061b4:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c01061bb:	00 
c01061bc:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c01061c3:	e8 38 a2 ff ff       	call   c0100400 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c01061c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01061cf:	e8 53 0a 00 00       	call   c0106c27 <alloc_pages>
c01061d4:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01061d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01061da:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01061dd:	74 24                	je     c0106203 <basic_check+0x487>
c01061df:	c7 44 24 0c a8 b3 10 	movl   $0xc010b3a8,0xc(%esp)
c01061e6:	c0 
c01061e7:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c01061ee:	c0 
c01061ef:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c01061f6:	00 
c01061f7:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c01061fe:	e8 fd a1 ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c0106203:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010620a:	e8 18 0a 00 00       	call   c0106c27 <alloc_pages>
c010620f:	85 c0                	test   %eax,%eax
c0106211:	74 24                	je     c0106237 <basic_check+0x4bb>
c0106213:	c7 44 24 0c 6e b3 10 	movl   $0xc010b36e,0xc(%esp)
c010621a:	c0 
c010621b:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0106222:	c0 
c0106223:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
c010622a:	00 
c010622b:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0106232:	e8 c9 a1 ff ff       	call   c0100400 <__panic>

    assert(nr_free == 0);
c0106237:	a1 34 b1 12 c0       	mov    0xc012b134,%eax
c010623c:	85 c0                	test   %eax,%eax
c010623e:	74 24                	je     c0106264 <basic_check+0x4e8>
c0106240:	c7 44 24 0c c1 b3 10 	movl   $0xc010b3c1,0xc(%esp)
c0106247:	c0 
c0106248:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c010624f:	c0 
c0106250:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c0106257:	00 
c0106258:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c010625f:	e8 9c a1 ff ff       	call   c0100400 <__panic>
    free_list = free_list_store;
c0106264:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106267:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010626a:	a3 2c b1 12 c0       	mov    %eax,0xc012b12c
c010626f:	89 15 30 b1 12 c0    	mov    %edx,0xc012b130
    nr_free = nr_free_store;
c0106275:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106278:	a3 34 b1 12 c0       	mov    %eax,0xc012b134

    free_page(p);
c010627d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106284:	00 
c0106285:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106288:	89 04 24             	mov    %eax,(%esp)
c010628b:	e8 02 0a 00 00       	call   c0106c92 <free_pages>
    free_page(p1);
c0106290:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106297:	00 
c0106298:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010629b:	89 04 24             	mov    %eax,(%esp)
c010629e:	e8 ef 09 00 00       	call   c0106c92 <free_pages>
    free_page(p2);
c01062a3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01062aa:	00 
c01062ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062ae:	89 04 24             	mov    %eax,(%esp)
c01062b1:	e8 dc 09 00 00       	call   c0106c92 <free_pages>
}
c01062b6:	90                   	nop
c01062b7:	c9                   	leave  
c01062b8:	c3                   	ret    

c01062b9 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c01062b9:	55                   	push   %ebp
c01062ba:	89 e5                	mov    %esp,%ebp
c01062bc:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c01062c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01062c9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c01062d0:	c7 45 ec 2c b1 12 c0 	movl   $0xc012b12c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01062d7:	eb 6a                	jmp    c0106343 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c01062d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01062dc:	83 e8 0c             	sub    $0xc,%eax
c01062df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c01062e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01062e5:	83 c0 04             	add    $0x4,%eax
c01062e8:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c01062ef:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01062f2:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01062f5:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01062f8:	0f a3 10             	bt     %edx,(%eax)
c01062fb:	19 c0                	sbb    %eax,%eax
c01062fd:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c0106300:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c0106304:	0f 95 c0             	setne  %al
c0106307:	0f b6 c0             	movzbl %al,%eax
c010630a:	85 c0                	test   %eax,%eax
c010630c:	75 24                	jne    c0106332 <default_check+0x79>
c010630e:	c7 44 24 0c ce b3 10 	movl   $0xc010b3ce,0xc(%esp)
c0106315:	c0 
c0106316:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c010631d:	c0 
c010631e:	c7 44 24 04 4a 01 00 	movl   $0x14a,0x4(%esp)
c0106325:	00 
c0106326:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c010632d:	e8 ce a0 ff ff       	call   c0100400 <__panic>
        count ++, total += p->property;
c0106332:	ff 45 f4             	incl   -0xc(%ebp)
c0106335:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106338:	8b 50 08             	mov    0x8(%eax),%edx
c010633b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010633e:	01 d0                	add    %edx,%eax
c0106340:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106343:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106346:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0106349:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010634c:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c010634f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106352:	81 7d ec 2c b1 12 c0 	cmpl   $0xc012b12c,-0x14(%ebp)
c0106359:	0f 85 7a ff ff ff    	jne    c01062d9 <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c010635f:	e8 61 09 00 00       	call   c0106cc5 <nr_free_pages>
c0106364:	89 c2                	mov    %eax,%edx
c0106366:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106369:	39 c2                	cmp    %eax,%edx
c010636b:	74 24                	je     c0106391 <default_check+0xd8>
c010636d:	c7 44 24 0c de b3 10 	movl   $0xc010b3de,0xc(%esp)
c0106374:	c0 
c0106375:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c010637c:	c0 
c010637d:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
c0106384:	00 
c0106385:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c010638c:	e8 6f a0 ff ff       	call   c0100400 <__panic>

    basic_check();
c0106391:	e8 e6 f9 ff ff       	call   c0105d7c <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0106396:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010639d:	e8 85 08 00 00       	call   c0106c27 <alloc_pages>
c01063a2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
c01063a5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01063a9:	75 24                	jne    c01063cf <default_check+0x116>
c01063ab:	c7 44 24 0c f7 b3 10 	movl   $0xc010b3f7,0xc(%esp)
c01063b2:	c0 
c01063b3:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c01063ba:	c0 
c01063bb:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c01063c2:	00 
c01063c3:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c01063ca:	e8 31 a0 ff ff       	call   c0100400 <__panic>
    assert(!PageProperty(p0));
c01063cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01063d2:	83 c0 04             	add    $0x4,%eax
c01063d5:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c01063dc:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01063df:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01063e2:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01063e5:	0f a3 10             	bt     %edx,(%eax)
c01063e8:	19 c0                	sbb    %eax,%eax
c01063ea:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c01063ed:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c01063f1:	0f 95 c0             	setne  %al
c01063f4:	0f b6 c0             	movzbl %al,%eax
c01063f7:	85 c0                	test   %eax,%eax
c01063f9:	74 24                	je     c010641f <default_check+0x166>
c01063fb:	c7 44 24 0c 02 b4 10 	movl   $0xc010b402,0xc(%esp)
c0106402:	c0 
c0106403:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c010640a:	c0 
c010640b:	c7 44 24 04 53 01 00 	movl   $0x153,0x4(%esp)
c0106412:	00 
c0106413:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c010641a:	e8 e1 9f ff ff       	call   c0100400 <__panic>

    list_entry_t free_list_store = free_list;
c010641f:	a1 2c b1 12 c0       	mov    0xc012b12c,%eax
c0106424:	8b 15 30 b1 12 c0    	mov    0xc012b130,%edx
c010642a:	89 45 80             	mov    %eax,-0x80(%ebp)
c010642d:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0106430:	c7 45 d0 2c b1 12 c0 	movl   $0xc012b12c,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0106437:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010643a:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010643d:	89 50 04             	mov    %edx,0x4(%eax)
c0106440:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106443:	8b 50 04             	mov    0x4(%eax),%edx
c0106446:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106449:	89 10                	mov    %edx,(%eax)
c010644b:	c7 45 d8 2c b1 12 c0 	movl   $0xc012b12c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0106452:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106455:	8b 40 04             	mov    0x4(%eax),%eax
c0106458:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c010645b:	0f 94 c0             	sete   %al
c010645e:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0106461:	85 c0                	test   %eax,%eax
c0106463:	75 24                	jne    c0106489 <default_check+0x1d0>
c0106465:	c7 44 24 0c 57 b3 10 	movl   $0xc010b357,0xc(%esp)
c010646c:	c0 
c010646d:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0106474:	c0 
c0106475:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
c010647c:	00 
c010647d:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0106484:	e8 77 9f ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c0106489:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106490:	e8 92 07 00 00       	call   c0106c27 <alloc_pages>
c0106495:	85 c0                	test   %eax,%eax
c0106497:	74 24                	je     c01064bd <default_check+0x204>
c0106499:	c7 44 24 0c 6e b3 10 	movl   $0xc010b36e,0xc(%esp)
c01064a0:	c0 
c01064a1:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c01064a8:	c0 
c01064a9:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
c01064b0:	00 
c01064b1:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c01064b8:	e8 43 9f ff ff       	call   c0100400 <__panic>

    unsigned int nr_free_store = nr_free;
c01064bd:	a1 34 b1 12 c0       	mov    0xc012b134,%eax
c01064c2:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
c01064c5:	c7 05 34 b1 12 c0 00 	movl   $0x0,0xc012b134
c01064cc:	00 00 00 

    free_pages(p0 + 2, 3);
c01064cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01064d2:	83 c0 40             	add    $0x40,%eax
c01064d5:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01064dc:	00 
c01064dd:	89 04 24             	mov    %eax,(%esp)
c01064e0:	e8 ad 07 00 00       	call   c0106c92 <free_pages>
    assert(alloc_pages(4) == NULL);
c01064e5:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01064ec:	e8 36 07 00 00       	call   c0106c27 <alloc_pages>
c01064f1:	85 c0                	test   %eax,%eax
c01064f3:	74 24                	je     c0106519 <default_check+0x260>
c01064f5:	c7 44 24 0c 14 b4 10 	movl   $0xc010b414,0xc(%esp)
c01064fc:	c0 
c01064fd:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0106504:	c0 
c0106505:	c7 44 24 04 5e 01 00 	movl   $0x15e,0x4(%esp)
c010650c:	00 
c010650d:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0106514:	e8 e7 9e ff ff       	call   c0100400 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0106519:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010651c:	83 c0 40             	add    $0x40,%eax
c010651f:	83 c0 04             	add    $0x4,%eax
c0106522:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0106529:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010652c:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010652f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106532:	0f a3 10             	bt     %edx,(%eax)
c0106535:	19 c0                	sbb    %eax,%eax
c0106537:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c010653a:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c010653e:	0f 95 c0             	setne  %al
c0106541:	0f b6 c0             	movzbl %al,%eax
c0106544:	85 c0                	test   %eax,%eax
c0106546:	74 0e                	je     c0106556 <default_check+0x29d>
c0106548:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010654b:	83 c0 40             	add    $0x40,%eax
c010654e:	8b 40 08             	mov    0x8(%eax),%eax
c0106551:	83 f8 03             	cmp    $0x3,%eax
c0106554:	74 24                	je     c010657a <default_check+0x2c1>
c0106556:	c7 44 24 0c 2c b4 10 	movl   $0xc010b42c,0xc(%esp)
c010655d:	c0 
c010655e:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0106565:	c0 
c0106566:	c7 44 24 04 5f 01 00 	movl   $0x15f,0x4(%esp)
c010656d:	00 
c010656e:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0106575:	e8 86 9e ff ff       	call   c0100400 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c010657a:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0106581:	e8 a1 06 00 00       	call   c0106c27 <alloc_pages>
c0106586:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0106589:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c010658d:	75 24                	jne    c01065b3 <default_check+0x2fa>
c010658f:	c7 44 24 0c 58 b4 10 	movl   $0xc010b458,0xc(%esp)
c0106596:	c0 
c0106597:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c010659e:	c0 
c010659f:	c7 44 24 04 60 01 00 	movl   $0x160,0x4(%esp)
c01065a6:	00 
c01065a7:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c01065ae:	e8 4d 9e ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c01065b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01065ba:	e8 68 06 00 00       	call   c0106c27 <alloc_pages>
c01065bf:	85 c0                	test   %eax,%eax
c01065c1:	74 24                	je     c01065e7 <default_check+0x32e>
c01065c3:	c7 44 24 0c 6e b3 10 	movl   $0xc010b36e,0xc(%esp)
c01065ca:	c0 
c01065cb:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c01065d2:	c0 
c01065d3:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c01065da:	00 
c01065db:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c01065e2:	e8 19 9e ff ff       	call   c0100400 <__panic>
    assert(p0 + 2 == p1);
c01065e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01065ea:	83 c0 40             	add    $0x40,%eax
c01065ed:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
c01065f0:	74 24                	je     c0106616 <default_check+0x35d>
c01065f2:	c7 44 24 0c 76 b4 10 	movl   $0xc010b476,0xc(%esp)
c01065f9:	c0 
c01065fa:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0106601:	c0 
c0106602:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
c0106609:	00 
c010660a:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0106611:	e8 ea 9d ff ff       	call   c0100400 <__panic>

    p2 = p0 + 1;
c0106616:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106619:	83 c0 20             	add    $0x20,%eax
c010661c:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
c010661f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106626:	00 
c0106627:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010662a:	89 04 24             	mov    %eax,(%esp)
c010662d:	e8 60 06 00 00       	call   c0106c92 <free_pages>
    free_pages(p1, 3);
c0106632:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0106639:	00 
c010663a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010663d:	89 04 24             	mov    %eax,(%esp)
c0106640:	e8 4d 06 00 00       	call   c0106c92 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0106645:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106648:	83 c0 04             	add    $0x4,%eax
c010664b:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0106652:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106655:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0106658:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010665b:	0f a3 10             	bt     %edx,(%eax)
c010665e:	19 c0                	sbb    %eax,%eax
c0106660:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
c0106663:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
c0106667:	0f 95 c0             	setne  %al
c010666a:	0f b6 c0             	movzbl %al,%eax
c010666d:	85 c0                	test   %eax,%eax
c010666f:	74 0b                	je     c010667c <default_check+0x3c3>
c0106671:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106674:	8b 40 08             	mov    0x8(%eax),%eax
c0106677:	83 f8 01             	cmp    $0x1,%eax
c010667a:	74 24                	je     c01066a0 <default_check+0x3e7>
c010667c:	c7 44 24 0c 84 b4 10 	movl   $0xc010b484,0xc(%esp)
c0106683:	c0 
c0106684:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c010668b:	c0 
c010668c:	c7 44 24 04 67 01 00 	movl   $0x167,0x4(%esp)
c0106693:	00 
c0106694:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c010669b:	e8 60 9d ff ff       	call   c0100400 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01066a0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01066a3:	83 c0 04             	add    $0x4,%eax
c01066a6:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c01066ad:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01066b0:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01066b3:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01066b6:	0f a3 10             	bt     %edx,(%eax)
c01066b9:	19 c0                	sbb    %eax,%eax
c01066bb:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
c01066be:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
c01066c2:	0f 95 c0             	setne  %al
c01066c5:	0f b6 c0             	movzbl %al,%eax
c01066c8:	85 c0                	test   %eax,%eax
c01066ca:	74 0b                	je     c01066d7 <default_check+0x41e>
c01066cc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01066cf:	8b 40 08             	mov    0x8(%eax),%eax
c01066d2:	83 f8 03             	cmp    $0x3,%eax
c01066d5:	74 24                	je     c01066fb <default_check+0x442>
c01066d7:	c7 44 24 0c ac b4 10 	movl   $0xc010b4ac,0xc(%esp)
c01066de:	c0 
c01066df:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c01066e6:	c0 
c01066e7:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
c01066ee:	00 
c01066ef:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c01066f6:	e8 05 9d ff ff       	call   c0100400 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01066fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106702:	e8 20 05 00 00       	call   c0106c27 <alloc_pages>
c0106707:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010670a:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010670d:	83 e8 20             	sub    $0x20,%eax
c0106710:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106713:	74 24                	je     c0106739 <default_check+0x480>
c0106715:	c7 44 24 0c d2 b4 10 	movl   $0xc010b4d2,0xc(%esp)
c010671c:	c0 
c010671d:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0106724:	c0 
c0106725:	c7 44 24 04 6a 01 00 	movl   $0x16a,0x4(%esp)
c010672c:	00 
c010672d:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0106734:	e8 c7 9c ff ff       	call   c0100400 <__panic>
    free_page(p0);
c0106739:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106740:	00 
c0106741:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106744:	89 04 24             	mov    %eax,(%esp)
c0106747:	e8 46 05 00 00       	call   c0106c92 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c010674c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0106753:	e8 cf 04 00 00       	call   c0106c27 <alloc_pages>
c0106758:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010675b:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010675e:	83 c0 20             	add    $0x20,%eax
c0106761:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106764:	74 24                	je     c010678a <default_check+0x4d1>
c0106766:	c7 44 24 0c f0 b4 10 	movl   $0xc010b4f0,0xc(%esp)
c010676d:	c0 
c010676e:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0106775:	c0 
c0106776:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
c010677d:	00 
c010677e:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0106785:	e8 76 9c ff ff       	call   c0100400 <__panic>

    free_pages(p0, 2);
c010678a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0106791:	00 
c0106792:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106795:	89 04 24             	mov    %eax,(%esp)
c0106798:	e8 f5 04 00 00       	call   c0106c92 <free_pages>
    free_page(p2);
c010679d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01067a4:	00 
c01067a5:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01067a8:	89 04 24             	mov    %eax,(%esp)
c01067ab:	e8 e2 04 00 00       	call   c0106c92 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01067b0:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01067b7:	e8 6b 04 00 00       	call   c0106c27 <alloc_pages>
c01067bc:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01067bf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01067c3:	75 24                	jne    c01067e9 <default_check+0x530>
c01067c5:	c7 44 24 0c 10 b5 10 	movl   $0xc010b510,0xc(%esp)
c01067cc:	c0 
c01067cd:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c01067d4:	c0 
c01067d5:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
c01067dc:	00 
c01067dd:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c01067e4:	e8 17 9c ff ff       	call   c0100400 <__panic>
    assert(alloc_page() == NULL);
c01067e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01067f0:	e8 32 04 00 00       	call   c0106c27 <alloc_pages>
c01067f5:	85 c0                	test   %eax,%eax
c01067f7:	74 24                	je     c010681d <default_check+0x564>
c01067f9:	c7 44 24 0c 6e b3 10 	movl   $0xc010b36e,0xc(%esp)
c0106800:	c0 
c0106801:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0106808:	c0 
c0106809:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
c0106810:	00 
c0106811:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0106818:	e8 e3 9b ff ff       	call   c0100400 <__panic>

    assert(nr_free == 0);
c010681d:	a1 34 b1 12 c0       	mov    0xc012b134,%eax
c0106822:	85 c0                	test   %eax,%eax
c0106824:	74 24                	je     c010684a <default_check+0x591>
c0106826:	c7 44 24 0c c1 b3 10 	movl   $0xc010b3c1,0xc(%esp)
c010682d:	c0 
c010682e:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c0106835:	c0 
c0106836:	c7 44 24 04 74 01 00 	movl   $0x174,0x4(%esp)
c010683d:	00 
c010683e:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0106845:	e8 b6 9b ff ff       	call   c0100400 <__panic>
    nr_free = nr_free_store;
c010684a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010684d:	a3 34 b1 12 c0       	mov    %eax,0xc012b134

    free_list = free_list_store;
c0106852:	8b 45 80             	mov    -0x80(%ebp),%eax
c0106855:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0106858:	a3 2c b1 12 c0       	mov    %eax,0xc012b12c
c010685d:	89 15 30 b1 12 c0    	mov    %edx,0xc012b130
    free_pages(p0, 5);
c0106863:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c010686a:	00 
c010686b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010686e:	89 04 24             	mov    %eax,(%esp)
c0106871:	e8 1c 04 00 00       	call   c0106c92 <free_pages>

    le = &free_list;
c0106876:	c7 45 ec 2c b1 12 c0 	movl   $0xc012b12c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010687d:	eb 1c                	jmp    c010689b <default_check+0x5e2>
        struct Page *p = le2page(le, page_link);
c010687f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106882:	83 e8 0c             	sub    $0xc,%eax
c0106885:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
c0106888:	ff 4d f4             	decl   -0xc(%ebp)
c010688b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010688e:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106891:	8b 40 08             	mov    0x8(%eax),%eax
c0106894:	29 c2                	sub    %eax,%edx
c0106896:	89 d0                	mov    %edx,%eax
c0106898:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010689b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010689e:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01068a1:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01068a4:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01068a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01068aa:	81 7d ec 2c b1 12 c0 	cmpl   $0xc012b12c,-0x14(%ebp)
c01068b1:	75 cc                	jne    c010687f <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c01068b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01068b7:	74 24                	je     c01068dd <default_check+0x624>
c01068b9:	c7 44 24 0c 2e b5 10 	movl   $0xc010b52e,0xc(%esp)
c01068c0:	c0 
c01068c1:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c01068c8:	c0 
c01068c9:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
c01068d0:	00 
c01068d1:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c01068d8:	e8 23 9b ff ff       	call   c0100400 <__panic>
    assert(total == 0);
c01068dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01068e1:	74 24                	je     c0106907 <default_check+0x64e>
c01068e3:	c7 44 24 0c 39 b5 10 	movl   $0xc010b539,0xc(%esp)
c01068ea:	c0 
c01068eb:	c7 44 24 08 fe b1 10 	movl   $0xc010b1fe,0x8(%esp)
c01068f2:	c0 
c01068f3:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
c01068fa:	00 
c01068fb:	c7 04 24 13 b2 10 c0 	movl   $0xc010b213,(%esp)
c0106902:	e8 f9 9a ff ff       	call   c0100400 <__panic>
}
c0106907:	90                   	nop
c0106908:	c9                   	leave  
c0106909:	c3                   	ret    

c010690a <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010690a:	55                   	push   %ebp
c010690b:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010690d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106910:	8b 15 40 b1 12 c0    	mov    0xc012b140,%edx
c0106916:	29 d0                	sub    %edx,%eax
c0106918:	c1 f8 05             	sar    $0x5,%eax
}
c010691b:	5d                   	pop    %ebp
c010691c:	c3                   	ret    

c010691d <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010691d:	55                   	push   %ebp
c010691e:	89 e5                	mov    %esp,%ebp
c0106920:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0106923:	8b 45 08             	mov    0x8(%ebp),%eax
c0106926:	89 04 24             	mov    %eax,(%esp)
c0106929:	e8 dc ff ff ff       	call   c010690a <page2ppn>
c010692e:	c1 e0 0c             	shl    $0xc,%eax
}
c0106931:	c9                   	leave  
c0106932:	c3                   	ret    

c0106933 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0106933:	55                   	push   %ebp
c0106934:	89 e5                	mov    %esp,%ebp
c0106936:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0106939:	8b 45 08             	mov    0x8(%ebp),%eax
c010693c:	c1 e8 0c             	shr    $0xc,%eax
c010693f:	89 c2                	mov    %eax,%edx
c0106941:	a1 80 8f 12 c0       	mov    0xc0128f80,%eax
c0106946:	39 c2                	cmp    %eax,%edx
c0106948:	72 1c                	jb     c0106966 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010694a:	c7 44 24 08 74 b5 10 	movl   $0xc010b574,0x8(%esp)
c0106951:	c0 
c0106952:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0106959:	00 
c010695a:	c7 04 24 93 b5 10 c0 	movl   $0xc010b593,(%esp)
c0106961:	e8 9a 9a ff ff       	call   c0100400 <__panic>
    }
    return &pages[PPN(pa)];
c0106966:	a1 40 b1 12 c0       	mov    0xc012b140,%eax
c010696b:	8b 55 08             	mov    0x8(%ebp),%edx
c010696e:	c1 ea 0c             	shr    $0xc,%edx
c0106971:	c1 e2 05             	shl    $0x5,%edx
c0106974:	01 d0                	add    %edx,%eax
}
c0106976:	c9                   	leave  
c0106977:	c3                   	ret    

c0106978 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0106978:	55                   	push   %ebp
c0106979:	89 e5                	mov    %esp,%ebp
c010697b:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010697e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106981:	89 04 24             	mov    %eax,(%esp)
c0106984:	e8 94 ff ff ff       	call   c010691d <page2pa>
c0106989:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010698c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010698f:	c1 e8 0c             	shr    $0xc,%eax
c0106992:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106995:	a1 80 8f 12 c0       	mov    0xc0128f80,%eax
c010699a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010699d:	72 23                	jb     c01069c2 <page2kva+0x4a>
c010699f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01069a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01069a6:	c7 44 24 08 a4 b5 10 	movl   $0xc010b5a4,0x8(%esp)
c01069ad:	c0 
c01069ae:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c01069b5:	00 
c01069b6:	c7 04 24 93 b5 10 c0 	movl   $0xc010b593,(%esp)
c01069bd:	e8 3e 9a ff ff       	call   c0100400 <__panic>
c01069c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01069c5:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01069ca:	c9                   	leave  
c01069cb:	c3                   	ret    

c01069cc <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c01069cc:	55                   	push   %ebp
c01069cd:	89 e5                	mov    %esp,%ebp
c01069cf:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01069d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01069d5:	83 e0 01             	and    $0x1,%eax
c01069d8:	85 c0                	test   %eax,%eax
c01069da:	75 1c                	jne    c01069f8 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01069dc:	c7 44 24 08 c8 b5 10 	movl   $0xc010b5c8,0x8(%esp)
c01069e3:	c0 
c01069e4:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c01069eb:	00 
c01069ec:	c7 04 24 93 b5 10 c0 	movl   $0xc010b593,(%esp)
c01069f3:	e8 08 9a ff ff       	call   c0100400 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c01069f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01069fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106a00:	89 04 24             	mov    %eax,(%esp)
c0106a03:	e8 2b ff ff ff       	call   c0106933 <pa2page>
}
c0106a08:	c9                   	leave  
c0106a09:	c3                   	ret    

c0106a0a <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0106a0a:	55                   	push   %ebp
c0106a0b:	89 e5                	mov    %esp,%ebp
c0106a0d:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0106a10:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a13:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106a18:	89 04 24             	mov    %eax,(%esp)
c0106a1b:	e8 13 ff ff ff       	call   c0106933 <pa2page>
}
c0106a20:	c9                   	leave  
c0106a21:	c3                   	ret    

c0106a22 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0106a22:	55                   	push   %ebp
c0106a23:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0106a25:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a28:	8b 00                	mov    (%eax),%eax
}
c0106a2a:	5d                   	pop    %ebp
c0106a2b:	c3                   	ret    

c0106a2c <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0106a2c:	55                   	push   %ebp
c0106a2d:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0106a2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a32:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106a35:	89 10                	mov    %edx,(%eax)
}
c0106a37:	90                   	nop
c0106a38:	5d                   	pop    %ebp
c0106a39:	c3                   	ret    

c0106a3a <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0106a3a:	55                   	push   %ebp
c0106a3b:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0106a3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a40:	8b 00                	mov    (%eax),%eax
c0106a42:	8d 50 01             	lea    0x1(%eax),%edx
c0106a45:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a48:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0106a4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a4d:	8b 00                	mov    (%eax),%eax
}
c0106a4f:	5d                   	pop    %ebp
c0106a50:	c3                   	ret    

c0106a51 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0106a51:	55                   	push   %ebp
c0106a52:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0106a54:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a57:	8b 00                	mov    (%eax),%eax
c0106a59:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106a5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a5f:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0106a61:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a64:	8b 00                	mov    (%eax),%eax
}
c0106a66:	5d                   	pop    %ebp
c0106a67:	c3                   	ret    

c0106a68 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0106a68:	55                   	push   %ebp
c0106a69:	89 e5                	mov    %esp,%ebp
c0106a6b:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0106a6e:	9c                   	pushf  
c0106a6f:	58                   	pop    %eax
c0106a70:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0106a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0106a76:	25 00 02 00 00       	and    $0x200,%eax
c0106a7b:	85 c0                	test   %eax,%eax
c0106a7d:	74 0c                	je     c0106a8b <__intr_save+0x23>
        intr_disable();
c0106a7f:	e8 75 b6 ff ff       	call   c01020f9 <intr_disable>
        return 1;
c0106a84:	b8 01 00 00 00       	mov    $0x1,%eax
c0106a89:	eb 05                	jmp    c0106a90 <__intr_save+0x28>
    }
    return 0;
c0106a8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106a90:	c9                   	leave  
c0106a91:	c3                   	ret    

c0106a92 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0106a92:	55                   	push   %ebp
c0106a93:	89 e5                	mov    %esp,%ebp
c0106a95:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0106a98:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106a9c:	74 05                	je     c0106aa3 <__intr_restore+0x11>
        intr_enable();
c0106a9e:	e8 4f b6 ff ff       	call   c01020f2 <intr_enable>
    }
}
c0106aa3:	90                   	nop
c0106aa4:	c9                   	leave  
c0106aa5:	c3                   	ret    

c0106aa6 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0106aa6:	55                   	push   %ebp
c0106aa7:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0106aa9:	8b 45 08             	mov    0x8(%ebp),%eax
c0106aac:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0106aaf:	b8 23 00 00 00       	mov    $0x23,%eax
c0106ab4:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0106ab6:	b8 23 00 00 00       	mov    $0x23,%eax
c0106abb:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0106abd:	b8 10 00 00 00       	mov    $0x10,%eax
c0106ac2:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0106ac4:	b8 10 00 00 00       	mov    $0x10,%eax
c0106ac9:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0106acb:	b8 10 00 00 00       	mov    $0x10,%eax
c0106ad0:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0106ad2:	ea d9 6a 10 c0 08 00 	ljmp   $0x8,$0xc0106ad9
}
c0106ad9:	90                   	nop
c0106ada:	5d                   	pop    %ebp
c0106adb:	c3                   	ret    

c0106adc <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0106adc:	55                   	push   %ebp
c0106add:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0106adf:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ae2:	a3 a4 8f 12 c0       	mov    %eax,0xc0128fa4
}
c0106ae7:	90                   	nop
c0106ae8:	5d                   	pop    %ebp
c0106ae9:	c3                   	ret    

c0106aea <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0106aea:	55                   	push   %ebp
c0106aeb:	89 e5                	mov    %esp,%ebp
c0106aed:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0106af0:	b8 00 50 12 c0       	mov    $0xc0125000,%eax
c0106af5:	89 04 24             	mov    %eax,(%esp)
c0106af8:	e8 df ff ff ff       	call   c0106adc <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0106afd:	66 c7 05 a8 8f 12 c0 	movw   $0x10,0xc0128fa8
c0106b04:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0106b06:	66 c7 05 68 5a 12 c0 	movw   $0x68,0xc0125a68
c0106b0d:	68 00 
c0106b0f:	b8 a0 8f 12 c0       	mov    $0xc0128fa0,%eax
c0106b14:	0f b7 c0             	movzwl %ax,%eax
c0106b17:	66 a3 6a 5a 12 c0    	mov    %ax,0xc0125a6a
c0106b1d:	b8 a0 8f 12 c0       	mov    $0xc0128fa0,%eax
c0106b22:	c1 e8 10             	shr    $0x10,%eax
c0106b25:	a2 6c 5a 12 c0       	mov    %al,0xc0125a6c
c0106b2a:	0f b6 05 6d 5a 12 c0 	movzbl 0xc0125a6d,%eax
c0106b31:	24 f0                	and    $0xf0,%al
c0106b33:	0c 09                	or     $0x9,%al
c0106b35:	a2 6d 5a 12 c0       	mov    %al,0xc0125a6d
c0106b3a:	0f b6 05 6d 5a 12 c0 	movzbl 0xc0125a6d,%eax
c0106b41:	24 ef                	and    $0xef,%al
c0106b43:	a2 6d 5a 12 c0       	mov    %al,0xc0125a6d
c0106b48:	0f b6 05 6d 5a 12 c0 	movzbl 0xc0125a6d,%eax
c0106b4f:	24 9f                	and    $0x9f,%al
c0106b51:	a2 6d 5a 12 c0       	mov    %al,0xc0125a6d
c0106b56:	0f b6 05 6d 5a 12 c0 	movzbl 0xc0125a6d,%eax
c0106b5d:	0c 80                	or     $0x80,%al
c0106b5f:	a2 6d 5a 12 c0       	mov    %al,0xc0125a6d
c0106b64:	0f b6 05 6e 5a 12 c0 	movzbl 0xc0125a6e,%eax
c0106b6b:	24 f0                	and    $0xf0,%al
c0106b6d:	a2 6e 5a 12 c0       	mov    %al,0xc0125a6e
c0106b72:	0f b6 05 6e 5a 12 c0 	movzbl 0xc0125a6e,%eax
c0106b79:	24 ef                	and    $0xef,%al
c0106b7b:	a2 6e 5a 12 c0       	mov    %al,0xc0125a6e
c0106b80:	0f b6 05 6e 5a 12 c0 	movzbl 0xc0125a6e,%eax
c0106b87:	24 df                	and    $0xdf,%al
c0106b89:	a2 6e 5a 12 c0       	mov    %al,0xc0125a6e
c0106b8e:	0f b6 05 6e 5a 12 c0 	movzbl 0xc0125a6e,%eax
c0106b95:	0c 40                	or     $0x40,%al
c0106b97:	a2 6e 5a 12 c0       	mov    %al,0xc0125a6e
c0106b9c:	0f b6 05 6e 5a 12 c0 	movzbl 0xc0125a6e,%eax
c0106ba3:	24 7f                	and    $0x7f,%al
c0106ba5:	a2 6e 5a 12 c0       	mov    %al,0xc0125a6e
c0106baa:	b8 a0 8f 12 c0       	mov    $0xc0128fa0,%eax
c0106baf:	c1 e8 18             	shr    $0x18,%eax
c0106bb2:	a2 6f 5a 12 c0       	mov    %al,0xc0125a6f

    // reload all segment registers
    lgdt(&gdt_pd);
c0106bb7:	c7 04 24 70 5a 12 c0 	movl   $0xc0125a70,(%esp)
c0106bbe:	e8 e3 fe ff ff       	call   c0106aa6 <lgdt>
c0106bc3:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0106bc9:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0106bcd:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0106bd0:	90                   	nop
c0106bd1:	c9                   	leave  
c0106bd2:	c3                   	ret    

c0106bd3 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0106bd3:	55                   	push   %ebp
c0106bd4:	89 e5                	mov    %esp,%ebp
c0106bd6:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0106bd9:	c7 05 38 b1 12 c0 58 	movl   $0xc010b558,0xc012b138
c0106be0:	b5 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0106be3:	a1 38 b1 12 c0       	mov    0xc012b138,%eax
c0106be8:	8b 00                	mov    (%eax),%eax
c0106bea:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bee:	c7 04 24 f4 b5 10 c0 	movl   $0xc010b5f4,(%esp)
c0106bf5:	e8 af 96 ff ff       	call   c01002a9 <cprintf>
    pmm_manager->init();
c0106bfa:	a1 38 b1 12 c0       	mov    0xc012b138,%eax
c0106bff:	8b 40 04             	mov    0x4(%eax),%eax
c0106c02:	ff d0                	call   *%eax
}
c0106c04:	90                   	nop
c0106c05:	c9                   	leave  
c0106c06:	c3                   	ret    

c0106c07 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0106c07:	55                   	push   %ebp
c0106c08:	89 e5                	mov    %esp,%ebp
c0106c0a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0106c0d:	a1 38 b1 12 c0       	mov    0xc012b138,%eax
c0106c12:	8b 40 08             	mov    0x8(%eax),%eax
c0106c15:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106c18:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106c1c:	8b 55 08             	mov    0x8(%ebp),%edx
c0106c1f:	89 14 24             	mov    %edx,(%esp)
c0106c22:	ff d0                	call   *%eax
}
c0106c24:	90                   	nop
c0106c25:	c9                   	leave  
c0106c26:	c3                   	ret    

c0106c27 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0106c27:	55                   	push   %ebp
c0106c28:	89 e5                	mov    %esp,%ebp
c0106c2a:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0106c2d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0106c34:	e8 2f fe ff ff       	call   c0106a68 <__intr_save>
c0106c39:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0106c3c:	a1 38 b1 12 c0       	mov    0xc012b138,%eax
c0106c41:	8b 40 0c             	mov    0xc(%eax),%eax
c0106c44:	8b 55 08             	mov    0x8(%ebp),%edx
c0106c47:	89 14 24             	mov    %edx,(%esp)
c0106c4a:	ff d0                	call   *%eax
c0106c4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0106c4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c52:	89 04 24             	mov    %eax,(%esp)
c0106c55:	e8 38 fe ff ff       	call   c0106a92 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c0106c5a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106c5e:	75 2d                	jne    c0106c8d <alloc_pages+0x66>
c0106c60:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c0106c64:	77 27                	ja     c0106c8d <alloc_pages+0x66>
c0106c66:	a1 68 8f 12 c0       	mov    0xc0128f68,%eax
c0106c6b:	85 c0                	test   %eax,%eax
c0106c6d:	74 1e                	je     c0106c8d <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c0106c6f:	8b 55 08             	mov    0x8(%ebp),%edx
c0106c72:	a1 58 b0 12 c0       	mov    0xc012b058,%eax
c0106c77:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106c7e:	00 
c0106c7f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106c83:	89 04 24             	mov    %eax,(%esp)
c0106c86:	e8 85 d4 ff ff       	call   c0104110 <swap_out>
    }
c0106c8b:	eb a7                	jmp    c0106c34 <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c0106c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106c90:	c9                   	leave  
c0106c91:	c3                   	ret    

c0106c92 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0106c92:	55                   	push   %ebp
c0106c93:	89 e5                	mov    %esp,%ebp
c0106c95:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0106c98:	e8 cb fd ff ff       	call   c0106a68 <__intr_save>
c0106c9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0106ca0:	a1 38 b1 12 c0       	mov    0xc012b138,%eax
c0106ca5:	8b 40 10             	mov    0x10(%eax),%eax
c0106ca8:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106cab:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106caf:	8b 55 08             	mov    0x8(%ebp),%edx
c0106cb2:	89 14 24             	mov    %edx,(%esp)
c0106cb5:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0106cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cba:	89 04 24             	mov    %eax,(%esp)
c0106cbd:	e8 d0 fd ff ff       	call   c0106a92 <__intr_restore>
}
c0106cc2:	90                   	nop
c0106cc3:	c9                   	leave  
c0106cc4:	c3                   	ret    

c0106cc5 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0106cc5:	55                   	push   %ebp
c0106cc6:	89 e5                	mov    %esp,%ebp
c0106cc8:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0106ccb:	e8 98 fd ff ff       	call   c0106a68 <__intr_save>
c0106cd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0106cd3:	a1 38 b1 12 c0       	mov    0xc012b138,%eax
c0106cd8:	8b 40 14             	mov    0x14(%eax),%eax
c0106cdb:	ff d0                	call   *%eax
c0106cdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0106ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ce3:	89 04 24             	mov    %eax,(%esp)
c0106ce6:	e8 a7 fd ff ff       	call   c0106a92 <__intr_restore>
    return ret;
c0106ceb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0106cee:	c9                   	leave  
c0106cef:	c3                   	ret    

c0106cf0 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0106cf0:	55                   	push   %ebp
c0106cf1:	89 e5                	mov    %esp,%ebp
c0106cf3:	57                   	push   %edi
c0106cf4:	56                   	push   %esi
c0106cf5:	53                   	push   %ebx
c0106cf6:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0106cfc:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0106d03:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0106d0a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0106d11:	c7 04 24 0b b6 10 c0 	movl   $0xc010b60b,(%esp)
c0106d18:	e8 8c 95 ff ff       	call   c01002a9 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0106d1d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106d24:	e9 22 01 00 00       	jmp    c0106e4b <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0106d29:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106d2c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106d2f:	89 d0                	mov    %edx,%eax
c0106d31:	c1 e0 02             	shl    $0x2,%eax
c0106d34:	01 d0                	add    %edx,%eax
c0106d36:	c1 e0 02             	shl    $0x2,%eax
c0106d39:	01 c8                	add    %ecx,%eax
c0106d3b:	8b 50 08             	mov    0x8(%eax),%edx
c0106d3e:	8b 40 04             	mov    0x4(%eax),%eax
c0106d41:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0106d44:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0106d47:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106d4a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106d4d:	89 d0                	mov    %edx,%eax
c0106d4f:	c1 e0 02             	shl    $0x2,%eax
c0106d52:	01 d0                	add    %edx,%eax
c0106d54:	c1 e0 02             	shl    $0x2,%eax
c0106d57:	01 c8                	add    %ecx,%eax
c0106d59:	8b 48 0c             	mov    0xc(%eax),%ecx
c0106d5c:	8b 58 10             	mov    0x10(%eax),%ebx
c0106d5f:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106d62:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0106d65:	01 c8                	add    %ecx,%eax
c0106d67:	11 da                	adc    %ebx,%edx
c0106d69:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0106d6c:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0106d6f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106d72:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106d75:	89 d0                	mov    %edx,%eax
c0106d77:	c1 e0 02             	shl    $0x2,%eax
c0106d7a:	01 d0                	add    %edx,%eax
c0106d7c:	c1 e0 02             	shl    $0x2,%eax
c0106d7f:	01 c8                	add    %ecx,%eax
c0106d81:	83 c0 14             	add    $0x14,%eax
c0106d84:	8b 00                	mov    (%eax),%eax
c0106d86:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0106d89:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106d8c:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106d8f:	83 c0 ff             	add    $0xffffffff,%eax
c0106d92:	83 d2 ff             	adc    $0xffffffff,%edx
c0106d95:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0106d9b:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0106da1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106da4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106da7:	89 d0                	mov    %edx,%eax
c0106da9:	c1 e0 02             	shl    $0x2,%eax
c0106dac:	01 d0                	add    %edx,%eax
c0106dae:	c1 e0 02             	shl    $0x2,%eax
c0106db1:	01 c8                	add    %ecx,%eax
c0106db3:	8b 48 0c             	mov    0xc(%eax),%ecx
c0106db6:	8b 58 10             	mov    0x10(%eax),%ebx
c0106db9:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0106dbc:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0106dc0:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0106dc6:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0106dcc:	89 44 24 14          	mov    %eax,0x14(%esp)
c0106dd0:	89 54 24 18          	mov    %edx,0x18(%esp)
c0106dd4:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106dd7:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0106dda:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106dde:	89 54 24 10          	mov    %edx,0x10(%esp)
c0106de2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0106de6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0106dea:	c7 04 24 18 b6 10 c0 	movl   $0xc010b618,(%esp)
c0106df1:	e8 b3 94 ff ff       	call   c01002a9 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0106df6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106df9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106dfc:	89 d0                	mov    %edx,%eax
c0106dfe:	c1 e0 02             	shl    $0x2,%eax
c0106e01:	01 d0                	add    %edx,%eax
c0106e03:	c1 e0 02             	shl    $0x2,%eax
c0106e06:	01 c8                	add    %ecx,%eax
c0106e08:	83 c0 14             	add    $0x14,%eax
c0106e0b:	8b 00                	mov    (%eax),%eax
c0106e0d:	83 f8 01             	cmp    $0x1,%eax
c0106e10:	75 36                	jne    c0106e48 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c0106e12:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106e15:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106e18:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0106e1b:	77 2b                	ja     c0106e48 <page_init+0x158>
c0106e1d:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0106e20:	72 05                	jb     c0106e27 <page_init+0x137>
c0106e22:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0106e25:	73 21                	jae    c0106e48 <page_init+0x158>
c0106e27:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106e2b:	77 1b                	ja     c0106e48 <page_init+0x158>
c0106e2d:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106e31:	72 09                	jb     c0106e3c <page_init+0x14c>
c0106e33:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0106e3a:	77 0c                	ja     c0106e48 <page_init+0x158>
                maxpa = end;
c0106e3c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106e3f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106e42:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106e45:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0106e48:	ff 45 dc             	incl   -0x24(%ebp)
c0106e4b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106e4e:	8b 00                	mov    (%eax),%eax
c0106e50:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0106e53:	0f 8f d0 fe ff ff    	jg     c0106d29 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0106e59:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106e5d:	72 1d                	jb     c0106e7c <page_init+0x18c>
c0106e5f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106e63:	77 09                	ja     c0106e6e <page_init+0x17e>
c0106e65:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0106e6c:	76 0e                	jbe    c0106e7c <page_init+0x18c>
        maxpa = KMEMSIZE;
c0106e6e:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0106e75:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0106e7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106e7f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106e82:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0106e86:	c1 ea 0c             	shr    $0xc,%edx
c0106e89:	a3 80 8f 12 c0       	mov    %eax,0xc0128f80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0106e8e:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0106e95:	b8 4c b1 12 c0       	mov    $0xc012b14c,%eax
c0106e9a:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106e9d:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0106ea0:	01 d0                	add    %edx,%eax
c0106ea2:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0106ea5:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106ea8:	ba 00 00 00 00       	mov    $0x0,%edx
c0106ead:	f7 75 ac             	divl   -0x54(%ebp)
c0106eb0:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106eb3:	29 d0                	sub    %edx,%eax
c0106eb5:	a3 40 b1 12 c0       	mov    %eax,0xc012b140

    for (i = 0; i < npage; i ++) {
c0106eba:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106ec1:	eb 26                	jmp    c0106ee9 <page_init+0x1f9>
        SetPageReserved(pages + i);
c0106ec3:	a1 40 b1 12 c0       	mov    0xc012b140,%eax
c0106ec8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106ecb:	c1 e2 05             	shl    $0x5,%edx
c0106ece:	01 d0                	add    %edx,%eax
c0106ed0:	83 c0 04             	add    $0x4,%eax
c0106ed3:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0106eda:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106edd:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0106ee0:	8b 55 90             	mov    -0x70(%ebp),%edx
c0106ee3:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0106ee6:	ff 45 dc             	incl   -0x24(%ebp)
c0106ee9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106eec:	a1 80 8f 12 c0       	mov    0xc0128f80,%eax
c0106ef1:	39 c2                	cmp    %eax,%edx
c0106ef3:	72 ce                	jb     c0106ec3 <page_init+0x1d3>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0106ef5:	a1 80 8f 12 c0       	mov    0xc0128f80,%eax
c0106efa:	c1 e0 05             	shl    $0x5,%eax
c0106efd:	89 c2                	mov    %eax,%edx
c0106eff:	a1 40 b1 12 c0       	mov    0xc012b140,%eax
c0106f04:	01 d0                	add    %edx,%eax
c0106f06:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0106f09:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0106f10:	77 23                	ja     c0106f35 <page_init+0x245>
c0106f12:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106f15:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106f19:	c7 44 24 08 48 b6 10 	movl   $0xc010b648,0x8(%esp)
c0106f20:	c0 
c0106f21:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0106f28:	00 
c0106f29:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0106f30:	e8 cb 94 ff ff       	call   c0100400 <__panic>
c0106f35:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106f38:	05 00 00 00 40       	add    $0x40000000,%eax
c0106f3d:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0106f40:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106f47:	e9 61 01 00 00       	jmp    c01070ad <page_init+0x3bd>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0106f4c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106f4f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106f52:	89 d0                	mov    %edx,%eax
c0106f54:	c1 e0 02             	shl    $0x2,%eax
c0106f57:	01 d0                	add    %edx,%eax
c0106f59:	c1 e0 02             	shl    $0x2,%eax
c0106f5c:	01 c8                	add    %ecx,%eax
c0106f5e:	8b 50 08             	mov    0x8(%eax),%edx
c0106f61:	8b 40 04             	mov    0x4(%eax),%eax
c0106f64:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106f67:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106f6a:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106f6d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106f70:	89 d0                	mov    %edx,%eax
c0106f72:	c1 e0 02             	shl    $0x2,%eax
c0106f75:	01 d0                	add    %edx,%eax
c0106f77:	c1 e0 02             	shl    $0x2,%eax
c0106f7a:	01 c8                	add    %ecx,%eax
c0106f7c:	8b 48 0c             	mov    0xc(%eax),%ecx
c0106f7f:	8b 58 10             	mov    0x10(%eax),%ebx
c0106f82:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106f85:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106f88:	01 c8                	add    %ecx,%eax
c0106f8a:	11 da                	adc    %ebx,%edx
c0106f8c:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0106f8f:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0106f92:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106f95:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106f98:	89 d0                	mov    %edx,%eax
c0106f9a:	c1 e0 02             	shl    $0x2,%eax
c0106f9d:	01 d0                	add    %edx,%eax
c0106f9f:	c1 e0 02             	shl    $0x2,%eax
c0106fa2:	01 c8                	add    %ecx,%eax
c0106fa4:	83 c0 14             	add    $0x14,%eax
c0106fa7:	8b 00                	mov    (%eax),%eax
c0106fa9:	83 f8 01             	cmp    $0x1,%eax
c0106fac:	0f 85 f8 00 00 00    	jne    c01070aa <page_init+0x3ba>
            if (begin < freemem) {
c0106fb2:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106fb5:	ba 00 00 00 00       	mov    $0x0,%edx
c0106fba:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0106fbd:	72 17                	jb     c0106fd6 <page_init+0x2e6>
c0106fbf:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0106fc2:	77 05                	ja     c0106fc9 <page_init+0x2d9>
c0106fc4:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0106fc7:	76 0d                	jbe    c0106fd6 <page_init+0x2e6>
                begin = freemem;
c0106fc9:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106fcc:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106fcf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0106fd6:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0106fda:	72 1d                	jb     c0106ff9 <page_init+0x309>
c0106fdc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0106fe0:	77 09                	ja     c0106feb <page_init+0x2fb>
c0106fe2:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0106fe9:	76 0e                	jbe    c0106ff9 <page_init+0x309>
                end = KMEMSIZE;
c0106feb:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0106ff2:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0106ff9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106ffc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106fff:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107002:	0f 87 a2 00 00 00    	ja     c01070aa <page_init+0x3ba>
c0107008:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010700b:	72 09                	jb     c0107016 <page_init+0x326>
c010700d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0107010:	0f 83 94 00 00 00    	jae    c01070aa <page_init+0x3ba>
                begin = ROUNDUP(begin, PGSIZE);
c0107016:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c010701d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107020:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0107023:	01 d0                	add    %edx,%eax
c0107025:	48                   	dec    %eax
c0107026:	89 45 98             	mov    %eax,-0x68(%ebp)
c0107029:	8b 45 98             	mov    -0x68(%ebp),%eax
c010702c:	ba 00 00 00 00       	mov    $0x0,%edx
c0107031:	f7 75 9c             	divl   -0x64(%ebp)
c0107034:	8b 45 98             	mov    -0x68(%ebp),%eax
c0107037:	29 d0                	sub    %edx,%eax
c0107039:	ba 00 00 00 00       	mov    $0x0,%edx
c010703e:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107041:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0107044:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107047:	89 45 94             	mov    %eax,-0x6c(%ebp)
c010704a:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010704d:	ba 00 00 00 00       	mov    $0x0,%edx
c0107052:	89 c3                	mov    %eax,%ebx
c0107054:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c010705a:	89 de                	mov    %ebx,%esi
c010705c:	89 d0                	mov    %edx,%eax
c010705e:	83 e0 00             	and    $0x0,%eax
c0107061:	89 c7                	mov    %eax,%edi
c0107063:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0107066:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0107069:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010706c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010706f:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107072:	77 36                	ja     c01070aa <page_init+0x3ba>
c0107074:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107077:	72 05                	jb     c010707e <page_init+0x38e>
c0107079:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010707c:	73 2c                	jae    c01070aa <page_init+0x3ba>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c010707e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107081:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107084:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0107087:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c010708a:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010708e:	c1 ea 0c             	shr    $0xc,%edx
c0107091:	89 c3                	mov    %eax,%ebx
c0107093:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107096:	89 04 24             	mov    %eax,(%esp)
c0107099:	e8 95 f8 ff ff       	call   c0106933 <pa2page>
c010709e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01070a2:	89 04 24             	mov    %eax,(%esp)
c01070a5:	e8 5d fb ff ff       	call   c0106c07 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c01070aa:	ff 45 dc             	incl   -0x24(%ebp)
c01070ad:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01070b0:	8b 00                	mov    (%eax),%eax
c01070b2:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01070b5:	0f 8f 91 fe ff ff    	jg     c0106f4c <page_init+0x25c>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c01070bb:	90                   	nop
c01070bc:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01070c2:	5b                   	pop    %ebx
c01070c3:	5e                   	pop    %esi
c01070c4:	5f                   	pop    %edi
c01070c5:	5d                   	pop    %ebp
c01070c6:	c3                   	ret    

c01070c7 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01070c7:	55                   	push   %ebp
c01070c8:	89 e5                	mov    %esp,%ebp
c01070ca:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01070cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01070d0:	33 45 14             	xor    0x14(%ebp),%eax
c01070d3:	25 ff 0f 00 00       	and    $0xfff,%eax
c01070d8:	85 c0                	test   %eax,%eax
c01070da:	74 24                	je     c0107100 <boot_map_segment+0x39>
c01070dc:	c7 44 24 0c 7a b6 10 	movl   $0xc010b67a,0xc(%esp)
c01070e3:	c0 
c01070e4:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c01070eb:	c0 
c01070ec:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c01070f3:	00 
c01070f4:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c01070fb:	e8 00 93 ff ff       	call   c0100400 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0107100:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0107107:	8b 45 0c             	mov    0xc(%ebp),%eax
c010710a:	25 ff 0f 00 00       	and    $0xfff,%eax
c010710f:	89 c2                	mov    %eax,%edx
c0107111:	8b 45 10             	mov    0x10(%ebp),%eax
c0107114:	01 c2                	add    %eax,%edx
c0107116:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107119:	01 d0                	add    %edx,%eax
c010711b:	48                   	dec    %eax
c010711c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010711f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107122:	ba 00 00 00 00       	mov    $0x0,%edx
c0107127:	f7 75 f0             	divl   -0x10(%ebp)
c010712a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010712d:	29 d0                	sub    %edx,%eax
c010712f:	c1 e8 0c             	shr    $0xc,%eax
c0107132:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0107135:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107138:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010713b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010713e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107143:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0107146:	8b 45 14             	mov    0x14(%ebp),%eax
c0107149:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010714c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010714f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107154:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0107157:	eb 68                	jmp    c01071c1 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0107159:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0107160:	00 
c0107161:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107164:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107168:	8b 45 08             	mov    0x8(%ebp),%eax
c010716b:	89 04 24             	mov    %eax,(%esp)
c010716e:	e8 86 01 00 00       	call   c01072f9 <get_pte>
c0107173:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0107176:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010717a:	75 24                	jne    c01071a0 <boot_map_segment+0xd9>
c010717c:	c7 44 24 0c a6 b6 10 	movl   $0xc010b6a6,0xc(%esp)
c0107183:	c0 
c0107184:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c010718b:	c0 
c010718c:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0107193:	00 
c0107194:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c010719b:	e8 60 92 ff ff       	call   c0100400 <__panic>
        *ptep = pa | PTE_P | perm;
c01071a0:	8b 45 14             	mov    0x14(%ebp),%eax
c01071a3:	0b 45 18             	or     0x18(%ebp),%eax
c01071a6:	83 c8 01             	or     $0x1,%eax
c01071a9:	89 c2                	mov    %eax,%edx
c01071ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01071ae:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01071b0:	ff 4d f4             	decl   -0xc(%ebp)
c01071b3:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01071ba:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01071c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01071c5:	75 92                	jne    c0107159 <boot_map_segment+0x92>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c01071c7:	90                   	nop
c01071c8:	c9                   	leave  
c01071c9:	c3                   	ret    

c01071ca <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01071ca:	55                   	push   %ebp
c01071cb:	89 e5                	mov    %esp,%ebp
c01071cd:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c01071d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01071d7:	e8 4b fa ff ff       	call   c0106c27 <alloc_pages>
c01071dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01071df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01071e3:	75 1c                	jne    c0107201 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c01071e5:	c7 44 24 08 b3 b6 10 	movl   $0xc010b6b3,0x8(%esp)
c01071ec:	c0 
c01071ed:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c01071f4:	00 
c01071f5:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c01071fc:	e8 ff 91 ff ff       	call   c0100400 <__panic>
    }
    return page2kva(p);
c0107201:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107204:	89 04 24             	mov    %eax,(%esp)
c0107207:	e8 6c f7 ff ff       	call   c0106978 <page2kva>
}
c010720c:	c9                   	leave  
c010720d:	c3                   	ret    

c010720e <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c010720e:	55                   	push   %ebp
c010720f:	89 e5                	mov    %esp,%ebp
c0107211:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0107214:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0107219:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010721c:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0107223:	77 23                	ja     c0107248 <pmm_init+0x3a>
c0107225:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107228:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010722c:	c7 44 24 08 48 b6 10 	movl   $0xc010b648,0x8(%esp)
c0107233:	c0 
c0107234:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c010723b:	00 
c010723c:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107243:	e8 b8 91 ff ff       	call   c0100400 <__panic>
c0107248:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010724b:	05 00 00 00 40       	add    $0x40000000,%eax
c0107250:	a3 3c b1 12 c0       	mov    %eax,0xc012b13c
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0107255:	e8 79 f9 ff ff       	call   c0106bd3 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c010725a:	e8 91 fa ff ff       	call   c0106cf0 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c010725f:	e8 ae 04 00 00       	call   c0107712 <check_alloc_page>

    check_pgdir();
c0107264:	e8 c8 04 00 00       	call   c0107731 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0107269:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c010726e:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0107274:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0107279:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010727c:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0107283:	77 23                	ja     c01072a8 <pmm_init+0x9a>
c0107285:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107288:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010728c:	c7 44 24 08 48 b6 10 	movl   $0xc010b648,0x8(%esp)
c0107293:	c0 
c0107294:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c010729b:	00 
c010729c:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c01072a3:	e8 58 91 ff ff       	call   c0100400 <__panic>
c01072a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01072ab:	05 00 00 00 40       	add    $0x40000000,%eax
c01072b0:	83 c8 03             	or     $0x3,%eax
c01072b3:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c01072b5:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c01072ba:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c01072c1:	00 
c01072c2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01072c9:	00 
c01072ca:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01072d1:	38 
c01072d2:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01072d9:	c0 
c01072da:	89 04 24             	mov    %eax,(%esp)
c01072dd:	e8 e5 fd ff ff       	call   c01070c7 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01072e2:	e8 03 f8 ff ff       	call   c0106aea <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01072e7:	e8 e1 0a 00 00       	call   c0107dcd <check_boot_pgdir>

    print_pgdir();
c01072ec:	e8 5a 0f 00 00       	call   c010824b <print_pgdir>
    
    kmalloc_init();
c01072f1:	e8 52 dd ff ff       	call   c0105048 <kmalloc_init>

}
c01072f6:	90                   	nop
c01072f7:	c9                   	leave  
c01072f8:	c3                   	ret    

c01072f9 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01072f9:	55                   	push   %ebp
c01072fa:	89 e5                	mov    %esp,%ebp
c01072fc:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep=&pgdir[PDX(la)];
c01072ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107302:	c1 e8 16             	shr    $0x16,%eax
c0107305:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010730c:	8b 45 08             	mov    0x8(%ebp),%eax
c010730f:	01 d0                	add    %edx,%eax
c0107311:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(!(*pdep & PTE_P))
c0107314:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107317:	8b 00                	mov    (%eax),%eax
c0107319:	83 e0 01             	and    $0x1,%eax
c010731c:	85 c0                	test   %eax,%eax
c010731e:	0f 85 af 00 00 00    	jne    c01073d3 <get_pte+0xda>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c0107324:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107328:	74 15                	je     c010733f <get_pte+0x46>
c010732a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107331:	e8 f1 f8 ff ff       	call   c0106c27 <alloc_pages>
c0107336:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107339:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010733d:	75 0a                	jne    c0107349 <get_pte+0x50>
            return NULL;
c010733f:	b8 00 00 00 00       	mov    $0x0,%eax
c0107344:	e9 e7 00 00 00       	jmp    c0107430 <get_pte+0x137>
        }
        set_page_ref(page,1);
c0107349:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107350:	00 
c0107351:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107354:	89 04 24             	mov    %eax,(%esp)
c0107357:	e8 d0 f6 ff ff       	call   c0106a2c <set_page_ref>
        uintptr_t pa=page2pa(page);
c010735c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010735f:	89 04 24             	mov    %eax,(%esp)
c0107362:	e8 b6 f5 ff ff       	call   c010691d <page2pa>
c0107367:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa),0,PGSIZE);
c010736a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010736d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107370:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107373:	c1 e8 0c             	shr    $0xc,%eax
c0107376:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107379:	a1 80 8f 12 c0       	mov    0xc0128f80,%eax
c010737e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0107381:	72 23                	jb     c01073a6 <get_pte+0xad>
c0107383:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107386:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010738a:	c7 44 24 08 a4 b5 10 	movl   $0xc010b5a4,0x8(%esp)
c0107391:	c0 
c0107392:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
c0107399:	00 
c010739a:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c01073a1:	e8 5a 90 ff ff       	call   c0100400 <__panic>
c01073a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01073a9:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01073ae:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01073b5:	00 
c01073b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01073bd:	00 
c01073be:	89 04 24             	mov    %eax,(%esp)
c01073c1:	e8 ed 20 00 00       	call   c01094b3 <memset>
        *pdep= pa|PTE_P|PTE_W|PTE_U;
c01073c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01073c9:	83 c8 07             	or     $0x7,%eax
c01073cc:	89 c2                	mov    %eax,%edx
c01073ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01073d1:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c01073d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01073d6:	8b 00                	mov    (%eax),%eax
c01073d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01073dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01073e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01073e3:	c1 e8 0c             	shr    $0xc,%eax
c01073e6:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01073e9:	a1 80 8f 12 c0       	mov    0xc0128f80,%eax
c01073ee:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01073f1:	72 23                	jb     c0107416 <get_pte+0x11d>
c01073f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01073f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01073fa:	c7 44 24 08 a4 b5 10 	movl   $0xc010b5a4,0x8(%esp)
c0107401:	c0 
c0107402:	c7 44 24 04 86 01 00 	movl   $0x186,0x4(%esp)
c0107409:	00 
c010740a:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107411:	e8 ea 8f ff ff       	call   c0100400 <__panic>
c0107416:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107419:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010741e:	89 c2                	mov    %eax,%edx
c0107420:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107423:	c1 e8 0c             	shr    $0xc,%eax
c0107426:	25 ff 03 00 00       	and    $0x3ff,%eax
c010742b:	c1 e0 02             	shl    $0x2,%eax
c010742e:	01 d0                	add    %edx,%eax
}
c0107430:	c9                   	leave  
c0107431:	c3                   	ret    

c0107432 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0107432:	55                   	push   %ebp
c0107433:	89 e5                	mov    %esp,%ebp
c0107435:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0107438:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010743f:	00 
c0107440:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107443:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107447:	8b 45 08             	mov    0x8(%ebp),%eax
c010744a:	89 04 24             	mov    %eax,(%esp)
c010744d:	e8 a7 fe ff ff       	call   c01072f9 <get_pte>
c0107452:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0107455:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107459:	74 08                	je     c0107463 <get_page+0x31>
        *ptep_store = ptep;
c010745b:	8b 45 10             	mov    0x10(%ebp),%eax
c010745e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107461:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0107463:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107467:	74 1b                	je     c0107484 <get_page+0x52>
c0107469:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010746c:	8b 00                	mov    (%eax),%eax
c010746e:	83 e0 01             	and    $0x1,%eax
c0107471:	85 c0                	test   %eax,%eax
c0107473:	74 0f                	je     c0107484 <get_page+0x52>
        return pte2page(*ptep);
c0107475:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107478:	8b 00                	mov    (%eax),%eax
c010747a:	89 04 24             	mov    %eax,(%esp)
c010747d:	e8 4a f5 ff ff       	call   c01069cc <pte2page>
c0107482:	eb 05                	jmp    c0107489 <get_page+0x57>
    }
    return NULL;
c0107484:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107489:	c9                   	leave  
c010748a:	c3                   	ret    

c010748b <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c010748b:	55                   	push   %ebp
c010748c:	89 e5                	mov    %esp,%ebp
c010748e:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if(*ptep & PTE_P)
c0107491:	8b 45 10             	mov    0x10(%ebp),%eax
c0107494:	8b 00                	mov    (%eax),%eax
c0107496:	83 e0 01             	and    $0x1,%eax
c0107499:	85 c0                	test   %eax,%eax
c010749b:	74 4d                	je     c01074ea <page_remove_pte+0x5f>
    {
        struct Page *page= pte2page(*ptep);
c010749d:	8b 45 10             	mov    0x10(%ebp),%eax
c01074a0:	8b 00                	mov    (%eax),%eax
c01074a2:	89 04 24             	mov    %eax,(%esp)
c01074a5:	e8 22 f5 ff ff       	call   c01069cc <pte2page>
c01074aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if(page_ref_dec(page)==0)
c01074ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074b0:	89 04 24             	mov    %eax,(%esp)
c01074b3:	e8 99 f5 ff ff       	call   c0106a51 <page_ref_dec>
c01074b8:	85 c0                	test   %eax,%eax
c01074ba:	75 13                	jne    c01074cf <page_remove_pte+0x44>
            // if(i==0)
        {
            free_page(page);
c01074bc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01074c3:	00 
c01074c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074c7:	89 04 24             	mov    %eax,(%esp)
c01074ca:	e8 c3 f7 ff ff       	call   c0106c92 <free_pages>
        }
        *ptep=0;
c01074cf:	8b 45 10             	mov    0x10(%ebp),%eax
c01074d2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c01074d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01074db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01074df:	8b 45 08             	mov    0x8(%ebp),%eax
c01074e2:	89 04 24             	mov    %eax,(%esp)
c01074e5:	e8 01 01 00 00       	call   c01075eb <tlb_invalidate>
    }
}
c01074ea:	90                   	nop
c01074eb:	c9                   	leave  
c01074ec:	c3                   	ret    

c01074ed <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01074ed:	55                   	push   %ebp
c01074ee:	89 e5                	mov    %esp,%ebp
c01074f0:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01074f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01074fa:	00 
c01074fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01074fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107502:	8b 45 08             	mov    0x8(%ebp),%eax
c0107505:	89 04 24             	mov    %eax,(%esp)
c0107508:	e8 ec fd ff ff       	call   c01072f9 <get_pte>
c010750d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0107510:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107514:	74 19                	je     c010752f <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0107516:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107519:	89 44 24 08          	mov    %eax,0x8(%esp)
c010751d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107520:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107524:	8b 45 08             	mov    0x8(%ebp),%eax
c0107527:	89 04 24             	mov    %eax,(%esp)
c010752a:	e8 5c ff ff ff       	call   c010748b <page_remove_pte>
    }
}
c010752f:	90                   	nop
c0107530:	c9                   	leave  
c0107531:	c3                   	ret    

c0107532 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0107532:	55                   	push   %ebp
c0107533:	89 e5                	mov    %esp,%ebp
c0107535:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0107538:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010753f:	00 
c0107540:	8b 45 10             	mov    0x10(%ebp),%eax
c0107543:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107547:	8b 45 08             	mov    0x8(%ebp),%eax
c010754a:	89 04 24             	mov    %eax,(%esp)
c010754d:	e8 a7 fd ff ff       	call   c01072f9 <get_pte>
c0107552:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0107555:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107559:	75 0a                	jne    c0107565 <page_insert+0x33>
        return -E_NO_MEM;
c010755b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0107560:	e9 84 00 00 00       	jmp    c01075e9 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0107565:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107568:	89 04 24             	mov    %eax,(%esp)
c010756b:	e8 ca f4 ff ff       	call   c0106a3a <page_ref_inc>
    if (*ptep & PTE_P) {
c0107570:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107573:	8b 00                	mov    (%eax),%eax
c0107575:	83 e0 01             	and    $0x1,%eax
c0107578:	85 c0                	test   %eax,%eax
c010757a:	74 3e                	je     c01075ba <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c010757c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010757f:	8b 00                	mov    (%eax),%eax
c0107581:	89 04 24             	mov    %eax,(%esp)
c0107584:	e8 43 f4 ff ff       	call   c01069cc <pte2page>
c0107589:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010758c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010758f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107592:	75 0d                	jne    c01075a1 <page_insert+0x6f>
            page_ref_dec(page);
c0107594:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107597:	89 04 24             	mov    %eax,(%esp)
c010759a:	e8 b2 f4 ff ff       	call   c0106a51 <page_ref_dec>
c010759f:	eb 19                	jmp    c01075ba <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c01075a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01075a4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01075a8:	8b 45 10             	mov    0x10(%ebp),%eax
c01075ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01075af:	8b 45 08             	mov    0x8(%ebp),%eax
c01075b2:	89 04 24             	mov    %eax,(%esp)
c01075b5:	e8 d1 fe ff ff       	call   c010748b <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c01075ba:	8b 45 0c             	mov    0xc(%ebp),%eax
c01075bd:	89 04 24             	mov    %eax,(%esp)
c01075c0:	e8 58 f3 ff ff       	call   c010691d <page2pa>
c01075c5:	0b 45 14             	or     0x14(%ebp),%eax
c01075c8:	83 c8 01             	or     $0x1,%eax
c01075cb:	89 c2                	mov    %eax,%edx
c01075cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01075d0:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01075d2:	8b 45 10             	mov    0x10(%ebp),%eax
c01075d5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01075d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01075dc:	89 04 24             	mov    %eax,(%esp)
c01075df:	e8 07 00 00 00       	call   c01075eb <tlb_invalidate>
    return 0;
c01075e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01075e9:	c9                   	leave  
c01075ea:	c3                   	ret    

c01075eb <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01075eb:	55                   	push   %ebp
c01075ec:	89 e5                	mov    %esp,%ebp
c01075ee:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01075f1:	0f 20 d8             	mov    %cr3,%eax
c01075f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
c01075f7:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c01075fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01075fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107600:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0107607:	77 23                	ja     c010762c <tlb_invalidate+0x41>
c0107609:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010760c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107610:	c7 44 24 08 48 b6 10 	movl   $0xc010b648,0x8(%esp)
c0107617:	c0 
c0107618:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c010761f:	00 
c0107620:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107627:	e8 d4 8d ff ff       	call   c0100400 <__panic>
c010762c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010762f:	05 00 00 00 40       	add    $0x40000000,%eax
c0107634:	39 c2                	cmp    %eax,%edx
c0107636:	75 0c                	jne    c0107644 <tlb_invalidate+0x59>
        invlpg((void *)la);
c0107638:	8b 45 0c             	mov    0xc(%ebp),%eax
c010763b:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c010763e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107641:	0f 01 38             	invlpg (%eax)
    }
}
c0107644:	90                   	nop
c0107645:	c9                   	leave  
c0107646:	c3                   	ret    

c0107647 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0107647:	55                   	push   %ebp
c0107648:	89 e5                	mov    %esp,%ebp
c010764a:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c010764d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107654:	e8 ce f5 ff ff       	call   c0106c27 <alloc_pages>
c0107659:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c010765c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107660:	0f 84 a7 00 00 00    	je     c010770d <pgdir_alloc_page+0xc6>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0107666:	8b 45 10             	mov    0x10(%ebp),%eax
c0107669:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010766d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107670:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107674:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107677:	89 44 24 04          	mov    %eax,0x4(%esp)
c010767b:	8b 45 08             	mov    0x8(%ebp),%eax
c010767e:	89 04 24             	mov    %eax,(%esp)
c0107681:	e8 ac fe ff ff       	call   c0107532 <page_insert>
c0107686:	85 c0                	test   %eax,%eax
c0107688:	74 1a                	je     c01076a4 <pgdir_alloc_page+0x5d>
            free_page(page);
c010768a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107691:	00 
c0107692:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107695:	89 04 24             	mov    %eax,(%esp)
c0107698:	e8 f5 f5 ff ff       	call   c0106c92 <free_pages>
            return NULL;
c010769d:	b8 00 00 00 00       	mov    $0x0,%eax
c01076a2:	eb 6c                	jmp    c0107710 <pgdir_alloc_page+0xc9>
        }
        if (swap_init_ok){
c01076a4:	a1 68 8f 12 c0       	mov    0xc0128f68,%eax
c01076a9:	85 c0                	test   %eax,%eax
c01076ab:	74 60                	je     c010770d <pgdir_alloc_page+0xc6>
            swap_map_swappable(check_mm_struct, la, page, 0);
c01076ad:	a1 58 b0 12 c0       	mov    0xc012b058,%eax
c01076b2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01076b9:	00 
c01076ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01076bd:	89 54 24 08          	mov    %edx,0x8(%esp)
c01076c1:	8b 55 0c             	mov    0xc(%ebp),%edx
c01076c4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01076c8:	89 04 24             	mov    %eax,(%esp)
c01076cb:	e8 f4 c9 ff ff       	call   c01040c4 <swap_map_swappable>
            page->pra_vaddr=la;
c01076d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076d3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01076d6:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c01076d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01076dc:	89 04 24             	mov    %eax,(%esp)
c01076df:	e8 3e f3 ff ff       	call   c0106a22 <page_ref>
c01076e4:	83 f8 01             	cmp    $0x1,%eax
c01076e7:	74 24                	je     c010770d <pgdir_alloc_page+0xc6>
c01076e9:	c7 44 24 0c cc b6 10 	movl   $0xc010b6cc,0xc(%esp)
c01076f0:	c0 
c01076f1:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c01076f8:	c0 
c01076f9:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0107700:	00 
c0107701:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107708:	e8 f3 8c ff ff       	call   c0100400 <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c010770d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107710:	c9                   	leave  
c0107711:	c3                   	ret    

c0107712 <check_alloc_page>:

static void
check_alloc_page(void) {
c0107712:	55                   	push   %ebp
c0107713:	89 e5                	mov    %esp,%ebp
c0107715:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0107718:	a1 38 b1 12 c0       	mov    0xc012b138,%eax
c010771d:	8b 40 18             	mov    0x18(%eax),%eax
c0107720:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0107722:	c7 04 24 e0 b6 10 c0 	movl   $0xc010b6e0,(%esp)
c0107729:	e8 7b 8b ff ff       	call   c01002a9 <cprintf>
}
c010772e:	90                   	nop
c010772f:	c9                   	leave  
c0107730:	c3                   	ret    

c0107731 <check_pgdir>:

static void
check_pgdir(void) {
c0107731:	55                   	push   %ebp
c0107732:	89 e5                	mov    %esp,%ebp
c0107734:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0107737:	a1 80 8f 12 c0       	mov    0xc0128f80,%eax
c010773c:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0107741:	76 24                	jbe    c0107767 <check_pgdir+0x36>
c0107743:	c7 44 24 0c ff b6 10 	movl   $0xc010b6ff,0xc(%esp)
c010774a:	c0 
c010774b:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107752:	c0 
c0107753:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c010775a:	00 
c010775b:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107762:	e8 99 8c ff ff       	call   c0100400 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0107767:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c010776c:	85 c0                	test   %eax,%eax
c010776e:	74 0e                	je     c010777e <check_pgdir+0x4d>
c0107770:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0107775:	25 ff 0f 00 00       	and    $0xfff,%eax
c010777a:	85 c0                	test   %eax,%eax
c010777c:	74 24                	je     c01077a2 <check_pgdir+0x71>
c010777e:	c7 44 24 0c 1c b7 10 	movl   $0xc010b71c,0xc(%esp)
c0107785:	c0 
c0107786:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c010778d:	c0 
c010778e:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0107795:	00 
c0107796:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c010779d:	e8 5e 8c ff ff       	call   c0100400 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01077a2:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c01077a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01077ae:	00 
c01077af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01077b6:	00 
c01077b7:	89 04 24             	mov    %eax,(%esp)
c01077ba:	e8 73 fc ff ff       	call   c0107432 <get_page>
c01077bf:	85 c0                	test   %eax,%eax
c01077c1:	74 24                	je     c01077e7 <check_pgdir+0xb6>
c01077c3:	c7 44 24 0c 54 b7 10 	movl   $0xc010b754,0xc(%esp)
c01077ca:	c0 
c01077cb:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c01077d2:	c0 
c01077d3:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c01077da:	00 
c01077db:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c01077e2:	e8 19 8c ff ff       	call   c0100400 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01077e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01077ee:	e8 34 f4 ff ff       	call   c0106c27 <alloc_pages>
c01077f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01077f6:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c01077fb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107802:	00 
c0107803:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010780a:	00 
c010780b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010780e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107812:	89 04 24             	mov    %eax,(%esp)
c0107815:	e8 18 fd ff ff       	call   c0107532 <page_insert>
c010781a:	85 c0                	test   %eax,%eax
c010781c:	74 24                	je     c0107842 <check_pgdir+0x111>
c010781e:	c7 44 24 0c 7c b7 10 	movl   $0xc010b77c,0xc(%esp)
c0107825:	c0 
c0107826:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c010782d:	c0 
c010782e:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c0107835:	00 
c0107836:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c010783d:	e8 be 8b ff ff       	call   c0100400 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0107842:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0107847:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010784e:	00 
c010784f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107856:	00 
c0107857:	89 04 24             	mov    %eax,(%esp)
c010785a:	e8 9a fa ff ff       	call   c01072f9 <get_pte>
c010785f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107862:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107866:	75 24                	jne    c010788c <check_pgdir+0x15b>
c0107868:	c7 44 24 0c a8 b7 10 	movl   $0xc010b7a8,0xc(%esp)
c010786f:	c0 
c0107870:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107877:	c0 
c0107878:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c010787f:	00 
c0107880:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107887:	e8 74 8b ff ff       	call   c0100400 <__panic>
    assert(pte2page(*ptep) == p1);
c010788c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010788f:	8b 00                	mov    (%eax),%eax
c0107891:	89 04 24             	mov    %eax,(%esp)
c0107894:	e8 33 f1 ff ff       	call   c01069cc <pte2page>
c0107899:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010789c:	74 24                	je     c01078c2 <check_pgdir+0x191>
c010789e:	c7 44 24 0c d5 b7 10 	movl   $0xc010b7d5,0xc(%esp)
c01078a5:	c0 
c01078a6:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c01078ad:	c0 
c01078ae:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c01078b5:	00 
c01078b6:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c01078bd:	e8 3e 8b ff ff       	call   c0100400 <__panic>
    assert(page_ref(p1) == 1);
c01078c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01078c5:	89 04 24             	mov    %eax,(%esp)
c01078c8:	e8 55 f1 ff ff       	call   c0106a22 <page_ref>
c01078cd:	83 f8 01             	cmp    $0x1,%eax
c01078d0:	74 24                	je     c01078f6 <check_pgdir+0x1c5>
c01078d2:	c7 44 24 0c eb b7 10 	movl   $0xc010b7eb,0xc(%esp)
c01078d9:	c0 
c01078da:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c01078e1:	c0 
c01078e2:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c01078e9:	00 
c01078ea:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c01078f1:	e8 0a 8b ff ff       	call   c0100400 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01078f6:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c01078fb:	8b 00                	mov    (%eax),%eax
c01078fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107902:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107905:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107908:	c1 e8 0c             	shr    $0xc,%eax
c010790b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010790e:	a1 80 8f 12 c0       	mov    0xc0128f80,%eax
c0107913:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0107916:	72 23                	jb     c010793b <check_pgdir+0x20a>
c0107918:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010791b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010791f:	c7 44 24 08 a4 b5 10 	movl   $0xc010b5a4,0x8(%esp)
c0107926:	c0 
c0107927:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c010792e:	00 
c010792f:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107936:	e8 c5 8a ff ff       	call   c0100400 <__panic>
c010793b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010793e:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0107943:	83 c0 04             	add    $0x4,%eax
c0107946:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0107949:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c010794e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107955:	00 
c0107956:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010795d:	00 
c010795e:	89 04 24             	mov    %eax,(%esp)
c0107961:	e8 93 f9 ff ff       	call   c01072f9 <get_pte>
c0107966:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107969:	74 24                	je     c010798f <check_pgdir+0x25e>
c010796b:	c7 44 24 0c 00 b8 10 	movl   $0xc010b800,0xc(%esp)
c0107972:	c0 
c0107973:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c010797a:	c0 
c010797b:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0107982:	00 
c0107983:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c010798a:	e8 71 8a ff ff       	call   c0100400 <__panic>

    p2 = alloc_page();
c010798f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107996:	e8 8c f2 ff ff       	call   c0106c27 <alloc_pages>
c010799b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c010799e:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c01079a3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01079aa:	00 
c01079ab:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01079b2:	00 
c01079b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01079b6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01079ba:	89 04 24             	mov    %eax,(%esp)
c01079bd:	e8 70 fb ff ff       	call   c0107532 <page_insert>
c01079c2:	85 c0                	test   %eax,%eax
c01079c4:	74 24                	je     c01079ea <check_pgdir+0x2b9>
c01079c6:	c7 44 24 0c 28 b8 10 	movl   $0xc010b828,0xc(%esp)
c01079cd:	c0 
c01079ce:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c01079d5:	c0 
c01079d6:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c01079dd:	00 
c01079de:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c01079e5:	e8 16 8a ff ff       	call   c0100400 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01079ea:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c01079ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01079f6:	00 
c01079f7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01079fe:	00 
c01079ff:	89 04 24             	mov    %eax,(%esp)
c0107a02:	e8 f2 f8 ff ff       	call   c01072f9 <get_pte>
c0107a07:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107a0a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107a0e:	75 24                	jne    c0107a34 <check_pgdir+0x303>
c0107a10:	c7 44 24 0c 60 b8 10 	movl   $0xc010b860,0xc(%esp)
c0107a17:	c0 
c0107a18:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107a1f:	c0 
c0107a20:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c0107a27:	00 
c0107a28:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107a2f:	e8 cc 89 ff ff       	call   c0100400 <__panic>
    assert(*ptep & PTE_U);
c0107a34:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a37:	8b 00                	mov    (%eax),%eax
c0107a39:	83 e0 04             	and    $0x4,%eax
c0107a3c:	85 c0                	test   %eax,%eax
c0107a3e:	75 24                	jne    c0107a64 <check_pgdir+0x333>
c0107a40:	c7 44 24 0c 90 b8 10 	movl   $0xc010b890,0xc(%esp)
c0107a47:	c0 
c0107a48:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107a4f:	c0 
c0107a50:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0107a57:	00 
c0107a58:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107a5f:	e8 9c 89 ff ff       	call   c0100400 <__panic>
    assert(*ptep & PTE_W);
c0107a64:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a67:	8b 00                	mov    (%eax),%eax
c0107a69:	83 e0 02             	and    $0x2,%eax
c0107a6c:	85 c0                	test   %eax,%eax
c0107a6e:	75 24                	jne    c0107a94 <check_pgdir+0x363>
c0107a70:	c7 44 24 0c 9e b8 10 	movl   $0xc010b89e,0xc(%esp)
c0107a77:	c0 
c0107a78:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107a7f:	c0 
c0107a80:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c0107a87:	00 
c0107a88:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107a8f:	e8 6c 89 ff ff       	call   c0100400 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0107a94:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0107a99:	8b 00                	mov    (%eax),%eax
c0107a9b:	83 e0 04             	and    $0x4,%eax
c0107a9e:	85 c0                	test   %eax,%eax
c0107aa0:	75 24                	jne    c0107ac6 <check_pgdir+0x395>
c0107aa2:	c7 44 24 0c ac b8 10 	movl   $0xc010b8ac,0xc(%esp)
c0107aa9:	c0 
c0107aaa:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107ab1:	c0 
c0107ab2:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c0107ab9:	00 
c0107aba:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107ac1:	e8 3a 89 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 1);
c0107ac6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107ac9:	89 04 24             	mov    %eax,(%esp)
c0107acc:	e8 51 ef ff ff       	call   c0106a22 <page_ref>
c0107ad1:	83 f8 01             	cmp    $0x1,%eax
c0107ad4:	74 24                	je     c0107afa <check_pgdir+0x3c9>
c0107ad6:	c7 44 24 0c c2 b8 10 	movl   $0xc010b8c2,0xc(%esp)
c0107add:	c0 
c0107ade:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107ae5:	c0 
c0107ae6:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0107aed:	00 
c0107aee:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107af5:	e8 06 89 ff ff       	call   c0100400 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0107afa:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0107aff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107b06:	00 
c0107b07:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0107b0e:	00 
c0107b0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107b12:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107b16:	89 04 24             	mov    %eax,(%esp)
c0107b19:	e8 14 fa ff ff       	call   c0107532 <page_insert>
c0107b1e:	85 c0                	test   %eax,%eax
c0107b20:	74 24                	je     c0107b46 <check_pgdir+0x415>
c0107b22:	c7 44 24 0c d4 b8 10 	movl   $0xc010b8d4,0xc(%esp)
c0107b29:	c0 
c0107b2a:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107b31:	c0 
c0107b32:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c0107b39:	00 
c0107b3a:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107b41:	e8 ba 88 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p1) == 2);
c0107b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b49:	89 04 24             	mov    %eax,(%esp)
c0107b4c:	e8 d1 ee ff ff       	call   c0106a22 <page_ref>
c0107b51:	83 f8 02             	cmp    $0x2,%eax
c0107b54:	74 24                	je     c0107b7a <check_pgdir+0x449>
c0107b56:	c7 44 24 0c 00 b9 10 	movl   $0xc010b900,0xc(%esp)
c0107b5d:	c0 
c0107b5e:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107b65:	c0 
c0107b66:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
c0107b6d:	00 
c0107b6e:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107b75:	e8 86 88 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 0);
c0107b7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107b7d:	89 04 24             	mov    %eax,(%esp)
c0107b80:	e8 9d ee ff ff       	call   c0106a22 <page_ref>
c0107b85:	85 c0                	test   %eax,%eax
c0107b87:	74 24                	je     c0107bad <check_pgdir+0x47c>
c0107b89:	c7 44 24 0c 12 b9 10 	movl   $0xc010b912,0xc(%esp)
c0107b90:	c0 
c0107b91:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107b98:	c0 
c0107b99:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c0107ba0:	00 
c0107ba1:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107ba8:	e8 53 88 ff ff       	call   c0100400 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0107bad:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0107bb2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107bb9:	00 
c0107bba:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0107bc1:	00 
c0107bc2:	89 04 24             	mov    %eax,(%esp)
c0107bc5:	e8 2f f7 ff ff       	call   c01072f9 <get_pte>
c0107bca:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107bcd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107bd1:	75 24                	jne    c0107bf7 <check_pgdir+0x4c6>
c0107bd3:	c7 44 24 0c 60 b8 10 	movl   $0xc010b860,0xc(%esp)
c0107bda:	c0 
c0107bdb:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107be2:	c0 
c0107be3:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
c0107bea:	00 
c0107beb:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107bf2:	e8 09 88 ff ff       	call   c0100400 <__panic>
    assert(pte2page(*ptep) == p1);
c0107bf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107bfa:	8b 00                	mov    (%eax),%eax
c0107bfc:	89 04 24             	mov    %eax,(%esp)
c0107bff:	e8 c8 ed ff ff       	call   c01069cc <pte2page>
c0107c04:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107c07:	74 24                	je     c0107c2d <check_pgdir+0x4fc>
c0107c09:	c7 44 24 0c d5 b7 10 	movl   $0xc010b7d5,0xc(%esp)
c0107c10:	c0 
c0107c11:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107c18:	c0 
c0107c19:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
c0107c20:	00 
c0107c21:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107c28:	e8 d3 87 ff ff       	call   c0100400 <__panic>
    assert((*ptep & PTE_U) == 0);
c0107c2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c30:	8b 00                	mov    (%eax),%eax
c0107c32:	83 e0 04             	and    $0x4,%eax
c0107c35:	85 c0                	test   %eax,%eax
c0107c37:	74 24                	je     c0107c5d <check_pgdir+0x52c>
c0107c39:	c7 44 24 0c 24 b9 10 	movl   $0xc010b924,0xc(%esp)
c0107c40:	c0 
c0107c41:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107c48:	c0 
c0107c49:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c0107c50:	00 
c0107c51:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107c58:	e8 a3 87 ff ff       	call   c0100400 <__panic>

    page_remove(boot_pgdir, 0x0);
c0107c5d:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0107c62:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107c69:	00 
c0107c6a:	89 04 24             	mov    %eax,(%esp)
c0107c6d:	e8 7b f8 ff ff       	call   c01074ed <page_remove>
    assert(page_ref(p1) == 1);
c0107c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c75:	89 04 24             	mov    %eax,(%esp)
c0107c78:	e8 a5 ed ff ff       	call   c0106a22 <page_ref>
c0107c7d:	83 f8 01             	cmp    $0x1,%eax
c0107c80:	74 24                	je     c0107ca6 <check_pgdir+0x575>
c0107c82:	c7 44 24 0c eb b7 10 	movl   $0xc010b7eb,0xc(%esp)
c0107c89:	c0 
c0107c8a:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107c91:	c0 
c0107c92:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
c0107c99:	00 
c0107c9a:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107ca1:	e8 5a 87 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 0);
c0107ca6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107ca9:	89 04 24             	mov    %eax,(%esp)
c0107cac:	e8 71 ed ff ff       	call   c0106a22 <page_ref>
c0107cb1:	85 c0                	test   %eax,%eax
c0107cb3:	74 24                	je     c0107cd9 <check_pgdir+0x5a8>
c0107cb5:	c7 44 24 0c 12 b9 10 	movl   $0xc010b912,0xc(%esp)
c0107cbc:	c0 
c0107cbd:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107cc4:	c0 
c0107cc5:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c0107ccc:	00 
c0107ccd:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107cd4:	e8 27 87 ff ff       	call   c0100400 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0107cd9:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0107cde:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0107ce5:	00 
c0107ce6:	89 04 24             	mov    %eax,(%esp)
c0107ce9:	e8 ff f7 ff ff       	call   c01074ed <page_remove>
    assert(page_ref(p1) == 0);
c0107cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107cf1:	89 04 24             	mov    %eax,(%esp)
c0107cf4:	e8 29 ed ff ff       	call   c0106a22 <page_ref>
c0107cf9:	85 c0                	test   %eax,%eax
c0107cfb:	74 24                	je     c0107d21 <check_pgdir+0x5f0>
c0107cfd:	c7 44 24 0c 39 b9 10 	movl   $0xc010b939,0xc(%esp)
c0107d04:	c0 
c0107d05:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107d0c:	c0 
c0107d0d:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
c0107d14:	00 
c0107d15:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107d1c:	e8 df 86 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p2) == 0);
c0107d21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107d24:	89 04 24             	mov    %eax,(%esp)
c0107d27:	e8 f6 ec ff ff       	call   c0106a22 <page_ref>
c0107d2c:	85 c0                	test   %eax,%eax
c0107d2e:	74 24                	je     c0107d54 <check_pgdir+0x623>
c0107d30:	c7 44 24 0c 12 b9 10 	movl   $0xc010b912,0xc(%esp)
c0107d37:	c0 
c0107d38:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107d3f:	c0 
c0107d40:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
c0107d47:	00 
c0107d48:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107d4f:	e8 ac 86 ff ff       	call   c0100400 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0107d54:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0107d59:	8b 00                	mov    (%eax),%eax
c0107d5b:	89 04 24             	mov    %eax,(%esp)
c0107d5e:	e8 a7 ec ff ff       	call   c0106a0a <pde2page>
c0107d63:	89 04 24             	mov    %eax,(%esp)
c0107d66:	e8 b7 ec ff ff       	call   c0106a22 <page_ref>
c0107d6b:	83 f8 01             	cmp    $0x1,%eax
c0107d6e:	74 24                	je     c0107d94 <check_pgdir+0x663>
c0107d70:	c7 44 24 0c 4c b9 10 	movl   $0xc010b94c,0xc(%esp)
c0107d77:	c0 
c0107d78:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107d7f:	c0 
c0107d80:	c7 44 24 04 36 02 00 	movl   $0x236,0x4(%esp)
c0107d87:	00 
c0107d88:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107d8f:	e8 6c 86 ff ff       	call   c0100400 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0107d94:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0107d99:	8b 00                	mov    (%eax),%eax
c0107d9b:	89 04 24             	mov    %eax,(%esp)
c0107d9e:	e8 67 ec ff ff       	call   c0106a0a <pde2page>
c0107da3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107daa:	00 
c0107dab:	89 04 24             	mov    %eax,(%esp)
c0107dae:	e8 df ee ff ff       	call   c0106c92 <free_pages>
    boot_pgdir[0] = 0;
c0107db3:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0107db8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0107dbe:	c7 04 24 73 b9 10 c0 	movl   $0xc010b973,(%esp)
c0107dc5:	e8 df 84 ff ff       	call   c01002a9 <cprintf>
}
c0107dca:	90                   	nop
c0107dcb:	c9                   	leave  
c0107dcc:	c3                   	ret    

c0107dcd <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0107dcd:	55                   	push   %ebp
c0107dce:	89 e5                	mov    %esp,%ebp
c0107dd0:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0107dd3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107dda:	e9 ca 00 00 00       	jmp    c0107ea9 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0107ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107de2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107de8:	c1 e8 0c             	shr    $0xc,%eax
c0107deb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107dee:	a1 80 8f 12 c0       	mov    0xc0128f80,%eax
c0107df3:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0107df6:	72 23                	jb     c0107e1b <check_boot_pgdir+0x4e>
c0107df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107dfb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107dff:	c7 44 24 08 a4 b5 10 	movl   $0xc010b5a4,0x8(%esp)
c0107e06:	c0 
c0107e07:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c0107e0e:	00 
c0107e0f:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107e16:	e8 e5 85 ff ff       	call   c0100400 <__panic>
c0107e1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107e1e:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0107e23:	89 c2                	mov    %eax,%edx
c0107e25:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0107e2a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107e31:	00 
c0107e32:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107e36:	89 04 24             	mov    %eax,(%esp)
c0107e39:	e8 bb f4 ff ff       	call   c01072f9 <get_pte>
c0107e3e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107e41:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107e45:	75 24                	jne    c0107e6b <check_boot_pgdir+0x9e>
c0107e47:	c7 44 24 0c 90 b9 10 	movl   $0xc010b990,0xc(%esp)
c0107e4e:	c0 
c0107e4f:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107e56:	c0 
c0107e57:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c0107e5e:	00 
c0107e5f:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107e66:	e8 95 85 ff ff       	call   c0100400 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0107e6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107e6e:	8b 00                	mov    (%eax),%eax
c0107e70:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107e75:	89 c2                	mov    %eax,%edx
c0107e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e7a:	39 c2                	cmp    %eax,%edx
c0107e7c:	74 24                	je     c0107ea2 <check_boot_pgdir+0xd5>
c0107e7e:	c7 44 24 0c cd b9 10 	movl   $0xc010b9cd,0xc(%esp)
c0107e85:	c0 
c0107e86:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107e8d:	c0 
c0107e8e:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c0107e95:	00 
c0107e96:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107e9d:	e8 5e 85 ff ff       	call   c0100400 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0107ea2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0107ea9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107eac:	a1 80 8f 12 c0       	mov    0xc0128f80,%eax
c0107eb1:	39 c2                	cmp    %eax,%edx
c0107eb3:	0f 82 26 ff ff ff    	jb     c0107ddf <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0107eb9:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0107ebe:	05 ac 0f 00 00       	add    $0xfac,%eax
c0107ec3:	8b 00                	mov    (%eax),%eax
c0107ec5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107eca:	89 c2                	mov    %eax,%edx
c0107ecc:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0107ed1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107ed4:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0107edb:	77 23                	ja     c0107f00 <check_boot_pgdir+0x133>
c0107edd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107ee0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107ee4:	c7 44 24 08 48 b6 10 	movl   $0xc010b648,0x8(%esp)
c0107eeb:	c0 
c0107eec:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
c0107ef3:	00 
c0107ef4:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107efb:	e8 00 85 ff ff       	call   c0100400 <__panic>
c0107f00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107f03:	05 00 00 00 40       	add    $0x40000000,%eax
c0107f08:	39 c2                	cmp    %eax,%edx
c0107f0a:	74 24                	je     c0107f30 <check_boot_pgdir+0x163>
c0107f0c:	c7 44 24 0c e4 b9 10 	movl   $0xc010b9e4,0xc(%esp)
c0107f13:	c0 
c0107f14:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107f1b:	c0 
c0107f1c:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
c0107f23:	00 
c0107f24:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107f2b:	e8 d0 84 ff ff       	call   c0100400 <__panic>

    assert(boot_pgdir[0] == 0);
c0107f30:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0107f35:	8b 00                	mov    (%eax),%eax
c0107f37:	85 c0                	test   %eax,%eax
c0107f39:	74 24                	je     c0107f5f <check_boot_pgdir+0x192>
c0107f3b:	c7 44 24 0c 18 ba 10 	movl   $0xc010ba18,0xc(%esp)
c0107f42:	c0 
c0107f43:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107f4a:	c0 
c0107f4b:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c0107f52:	00 
c0107f53:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107f5a:	e8 a1 84 ff ff       	call   c0100400 <__panic>

    struct Page *p;
    p = alloc_page();
c0107f5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107f66:	e8 bc ec ff ff       	call   c0106c27 <alloc_pages>
c0107f6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0107f6e:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0107f73:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0107f7a:	00 
c0107f7b:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0107f82:	00 
c0107f83:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107f86:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107f8a:	89 04 24             	mov    %eax,(%esp)
c0107f8d:	e8 a0 f5 ff ff       	call   c0107532 <page_insert>
c0107f92:	85 c0                	test   %eax,%eax
c0107f94:	74 24                	je     c0107fba <check_boot_pgdir+0x1ed>
c0107f96:	c7 44 24 0c 2c ba 10 	movl   $0xc010ba2c,0xc(%esp)
c0107f9d:	c0 
c0107f9e:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107fa5:	c0 
c0107fa6:	c7 44 24 04 4c 02 00 	movl   $0x24c,0x4(%esp)
c0107fad:	00 
c0107fae:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107fb5:	e8 46 84 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p) == 1);
c0107fba:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107fbd:	89 04 24             	mov    %eax,(%esp)
c0107fc0:	e8 5d ea ff ff       	call   c0106a22 <page_ref>
c0107fc5:	83 f8 01             	cmp    $0x1,%eax
c0107fc8:	74 24                	je     c0107fee <check_boot_pgdir+0x221>
c0107fca:	c7 44 24 0c 5a ba 10 	movl   $0xc010ba5a,0xc(%esp)
c0107fd1:	c0 
c0107fd2:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0107fd9:	c0 
c0107fda:	c7 44 24 04 4d 02 00 	movl   $0x24d,0x4(%esp)
c0107fe1:	00 
c0107fe2:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0107fe9:	e8 12 84 ff ff       	call   c0100400 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0107fee:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0107ff3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0107ffa:	00 
c0107ffb:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0108002:	00 
c0108003:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108006:	89 54 24 04          	mov    %edx,0x4(%esp)
c010800a:	89 04 24             	mov    %eax,(%esp)
c010800d:	e8 20 f5 ff ff       	call   c0107532 <page_insert>
c0108012:	85 c0                	test   %eax,%eax
c0108014:	74 24                	je     c010803a <check_boot_pgdir+0x26d>
c0108016:	c7 44 24 0c 6c ba 10 	movl   $0xc010ba6c,0xc(%esp)
c010801d:	c0 
c010801e:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0108025:	c0 
c0108026:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
c010802d:	00 
c010802e:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0108035:	e8 c6 83 ff ff       	call   c0100400 <__panic>
    assert(page_ref(p) == 2);
c010803a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010803d:	89 04 24             	mov    %eax,(%esp)
c0108040:	e8 dd e9 ff ff       	call   c0106a22 <page_ref>
c0108045:	83 f8 02             	cmp    $0x2,%eax
c0108048:	74 24                	je     c010806e <check_boot_pgdir+0x2a1>
c010804a:	c7 44 24 0c a3 ba 10 	movl   $0xc010baa3,0xc(%esp)
c0108051:	c0 
c0108052:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c0108059:	c0 
c010805a:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
c0108061:	00 
c0108062:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0108069:	e8 92 83 ff ff       	call   c0100400 <__panic>

    const char *str = "ucore: Hello world!!";
c010806e:	c7 45 dc b4 ba 10 c0 	movl   $0xc010bab4,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0108075:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108078:	89 44 24 04          	mov    %eax,0x4(%esp)
c010807c:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0108083:	e8 61 11 00 00       	call   c01091e9 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0108088:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c010808f:	00 
c0108090:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0108097:	e8 c4 11 00 00       	call   c0109260 <strcmp>
c010809c:	85 c0                	test   %eax,%eax
c010809e:	74 24                	je     c01080c4 <check_boot_pgdir+0x2f7>
c01080a0:	c7 44 24 0c cc ba 10 	movl   $0xc010bacc,0xc(%esp)
c01080a7:	c0 
c01080a8:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c01080af:	c0 
c01080b0:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
c01080b7:	00 
c01080b8:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c01080bf:	e8 3c 83 ff ff       	call   c0100400 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01080c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01080c7:	89 04 24             	mov    %eax,(%esp)
c01080ca:	e8 a9 e8 ff ff       	call   c0106978 <page2kva>
c01080cf:	05 00 01 00 00       	add    $0x100,%eax
c01080d4:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c01080d7:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01080de:	e8 b0 10 00 00       	call   c0109193 <strlen>
c01080e3:	85 c0                	test   %eax,%eax
c01080e5:	74 24                	je     c010810b <check_boot_pgdir+0x33e>
c01080e7:	c7 44 24 0c 04 bb 10 	movl   $0xc010bb04,0xc(%esp)
c01080ee:	c0 
c01080ef:	c7 44 24 08 91 b6 10 	movl   $0xc010b691,0x8(%esp)
c01080f6:	c0 
c01080f7:	c7 44 24 04 56 02 00 	movl   $0x256,0x4(%esp)
c01080fe:	00 
c01080ff:	c7 04 24 6c b6 10 c0 	movl   $0xc010b66c,(%esp)
c0108106:	e8 f5 82 ff ff       	call   c0100400 <__panic>

    free_page(p);
c010810b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108112:	00 
c0108113:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108116:	89 04 24             	mov    %eax,(%esp)
c0108119:	e8 74 eb ff ff       	call   c0106c92 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c010811e:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0108123:	8b 00                	mov    (%eax),%eax
c0108125:	89 04 24             	mov    %eax,(%esp)
c0108128:	e8 dd e8 ff ff       	call   c0106a0a <pde2page>
c010812d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108134:	00 
c0108135:	89 04 24             	mov    %eax,(%esp)
c0108138:	e8 55 eb ff ff       	call   c0106c92 <free_pages>
    boot_pgdir[0] = 0;
c010813d:	a1 20 5a 12 c0       	mov    0xc0125a20,%eax
c0108142:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0108148:	c7 04 24 28 bb 10 c0 	movl   $0xc010bb28,(%esp)
c010814f:	e8 55 81 ff ff       	call   c01002a9 <cprintf>
}
c0108154:	90                   	nop
c0108155:	c9                   	leave  
c0108156:	c3                   	ret    

c0108157 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0108157:	55                   	push   %ebp
c0108158:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c010815a:	8b 45 08             	mov    0x8(%ebp),%eax
c010815d:	83 e0 04             	and    $0x4,%eax
c0108160:	85 c0                	test   %eax,%eax
c0108162:	74 04                	je     c0108168 <perm2str+0x11>
c0108164:	b0 75                	mov    $0x75,%al
c0108166:	eb 02                	jmp    c010816a <perm2str+0x13>
c0108168:	b0 2d                	mov    $0x2d,%al
c010816a:	a2 08 90 12 c0       	mov    %al,0xc0129008
    str[1] = 'r';
c010816f:	c6 05 09 90 12 c0 72 	movb   $0x72,0xc0129009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0108176:	8b 45 08             	mov    0x8(%ebp),%eax
c0108179:	83 e0 02             	and    $0x2,%eax
c010817c:	85 c0                	test   %eax,%eax
c010817e:	74 04                	je     c0108184 <perm2str+0x2d>
c0108180:	b0 77                	mov    $0x77,%al
c0108182:	eb 02                	jmp    c0108186 <perm2str+0x2f>
c0108184:	b0 2d                	mov    $0x2d,%al
c0108186:	a2 0a 90 12 c0       	mov    %al,0xc012900a
    str[3] = '\0';
c010818b:	c6 05 0b 90 12 c0 00 	movb   $0x0,0xc012900b
    return str;
c0108192:	b8 08 90 12 c0       	mov    $0xc0129008,%eax
}
c0108197:	5d                   	pop    %ebp
c0108198:	c3                   	ret    

c0108199 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0108199:	55                   	push   %ebp
c010819a:	89 e5                	mov    %esp,%ebp
c010819c:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c010819f:	8b 45 10             	mov    0x10(%ebp),%eax
c01081a2:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01081a5:	72 0d                	jb     c01081b4 <get_pgtable_items+0x1b>
        return 0;
c01081a7:	b8 00 00 00 00       	mov    $0x0,%eax
c01081ac:	e9 98 00 00 00       	jmp    c0108249 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c01081b1:	ff 45 10             	incl   0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c01081b4:	8b 45 10             	mov    0x10(%ebp),%eax
c01081b7:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01081ba:	73 18                	jae    c01081d4 <get_pgtable_items+0x3b>
c01081bc:	8b 45 10             	mov    0x10(%ebp),%eax
c01081bf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01081c6:	8b 45 14             	mov    0x14(%ebp),%eax
c01081c9:	01 d0                	add    %edx,%eax
c01081cb:	8b 00                	mov    (%eax),%eax
c01081cd:	83 e0 01             	and    $0x1,%eax
c01081d0:	85 c0                	test   %eax,%eax
c01081d2:	74 dd                	je     c01081b1 <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
c01081d4:	8b 45 10             	mov    0x10(%ebp),%eax
c01081d7:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01081da:	73 68                	jae    c0108244 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c01081dc:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01081e0:	74 08                	je     c01081ea <get_pgtable_items+0x51>
            *left_store = start;
c01081e2:	8b 45 18             	mov    0x18(%ebp),%eax
c01081e5:	8b 55 10             	mov    0x10(%ebp),%edx
c01081e8:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c01081ea:	8b 45 10             	mov    0x10(%ebp),%eax
c01081ed:	8d 50 01             	lea    0x1(%eax),%edx
c01081f0:	89 55 10             	mov    %edx,0x10(%ebp)
c01081f3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01081fa:	8b 45 14             	mov    0x14(%ebp),%eax
c01081fd:	01 d0                	add    %edx,%eax
c01081ff:	8b 00                	mov    (%eax),%eax
c0108201:	83 e0 07             	and    $0x7,%eax
c0108204:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0108207:	eb 03                	jmp    c010820c <get_pgtable_items+0x73>
            start ++;
c0108209:	ff 45 10             	incl   0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c010820c:	8b 45 10             	mov    0x10(%ebp),%eax
c010820f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108212:	73 1d                	jae    c0108231 <get_pgtable_items+0x98>
c0108214:	8b 45 10             	mov    0x10(%ebp),%eax
c0108217:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010821e:	8b 45 14             	mov    0x14(%ebp),%eax
c0108221:	01 d0                	add    %edx,%eax
c0108223:	8b 00                	mov    (%eax),%eax
c0108225:	83 e0 07             	and    $0x7,%eax
c0108228:	89 c2                	mov    %eax,%edx
c010822a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010822d:	39 c2                	cmp    %eax,%edx
c010822f:	74 d8                	je     c0108209 <get_pgtable_items+0x70>
            start ++;
        }
        if (right_store != NULL) {
c0108231:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0108235:	74 08                	je     c010823f <get_pgtable_items+0xa6>
            *right_store = start;
c0108237:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010823a:	8b 55 10             	mov    0x10(%ebp),%edx
c010823d:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c010823f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108242:	eb 05                	jmp    c0108249 <get_pgtable_items+0xb0>
    }
    return 0;
c0108244:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108249:	c9                   	leave  
c010824a:	c3                   	ret    

c010824b <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c010824b:	55                   	push   %ebp
c010824c:	89 e5                	mov    %esp,%ebp
c010824e:	57                   	push   %edi
c010824f:	56                   	push   %esi
c0108250:	53                   	push   %ebx
c0108251:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0108254:	c7 04 24 48 bb 10 c0 	movl   $0xc010bb48,(%esp)
c010825b:	e8 49 80 ff ff       	call   c01002a9 <cprintf>
    size_t left, right = 0, perm;
c0108260:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0108267:	e9 fa 00 00 00       	jmp    c0108366 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010826c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010826f:	89 04 24             	mov    %eax,(%esp)
c0108272:	e8 e0 fe ff ff       	call   c0108157 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0108277:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010827a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010827d:	29 d1                	sub    %edx,%ecx
c010827f:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0108281:	89 d6                	mov    %edx,%esi
c0108283:	c1 e6 16             	shl    $0x16,%esi
c0108286:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108289:	89 d3                	mov    %edx,%ebx
c010828b:	c1 e3 16             	shl    $0x16,%ebx
c010828e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108291:	89 d1                	mov    %edx,%ecx
c0108293:	c1 e1 16             	shl    $0x16,%ecx
c0108296:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0108299:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010829c:	29 d7                	sub    %edx,%edi
c010829e:	89 fa                	mov    %edi,%edx
c01082a0:	89 44 24 14          	mov    %eax,0x14(%esp)
c01082a4:	89 74 24 10          	mov    %esi,0x10(%esp)
c01082a8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01082ac:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01082b0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01082b4:	c7 04 24 79 bb 10 c0 	movl   $0xc010bb79,(%esp)
c01082bb:	e8 e9 7f ff ff       	call   c01002a9 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c01082c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01082c3:	c1 e0 0a             	shl    $0xa,%eax
c01082c6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01082c9:	eb 54                	jmp    c010831f <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01082cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01082ce:	89 04 24             	mov    %eax,(%esp)
c01082d1:	e8 81 fe ff ff       	call   c0108157 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01082d6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01082d9:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01082dc:	29 d1                	sub    %edx,%ecx
c01082de:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01082e0:	89 d6                	mov    %edx,%esi
c01082e2:	c1 e6 0c             	shl    $0xc,%esi
c01082e5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01082e8:	89 d3                	mov    %edx,%ebx
c01082ea:	c1 e3 0c             	shl    $0xc,%ebx
c01082ed:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01082f0:	89 d1                	mov    %edx,%ecx
c01082f2:	c1 e1 0c             	shl    $0xc,%ecx
c01082f5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c01082f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01082fb:	29 d7                	sub    %edx,%edi
c01082fd:	89 fa                	mov    %edi,%edx
c01082ff:	89 44 24 14          	mov    %eax,0x14(%esp)
c0108303:	89 74 24 10          	mov    %esi,0x10(%esp)
c0108307:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010830b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010830f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108313:	c7 04 24 98 bb 10 c0 	movl   $0xc010bb98,(%esp)
c010831a:	e8 8a 7f ff ff       	call   c01002a9 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010831f:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0108324:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108327:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010832a:	89 d3                	mov    %edx,%ebx
c010832c:	c1 e3 0a             	shl    $0xa,%ebx
c010832f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108332:	89 d1                	mov    %edx,%ecx
c0108334:	c1 e1 0a             	shl    $0xa,%ecx
c0108337:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c010833a:	89 54 24 14          	mov    %edx,0x14(%esp)
c010833e:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0108341:	89 54 24 10          	mov    %edx,0x10(%esp)
c0108345:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0108349:	89 44 24 08          	mov    %eax,0x8(%esp)
c010834d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0108351:	89 0c 24             	mov    %ecx,(%esp)
c0108354:	e8 40 fe ff ff       	call   c0108199 <get_pgtable_items>
c0108359:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010835c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108360:	0f 85 65 ff ff ff    	jne    c01082cb <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0108366:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c010836b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010836e:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0108371:	89 54 24 14          	mov    %edx,0x14(%esp)
c0108375:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0108378:	89 54 24 10          	mov    %edx,0x10(%esp)
c010837c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0108380:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108384:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c010838b:	00 
c010838c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0108393:	e8 01 fe ff ff       	call   c0108199 <get_pgtable_items>
c0108398:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010839b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010839f:	0f 85 c7 fe ff ff    	jne    c010826c <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01083a5:	c7 04 24 bc bb 10 c0 	movl   $0xc010bbbc,(%esp)
c01083ac:	e8 f8 7e ff ff       	call   c01002a9 <cprintf>
}
c01083b1:	90                   	nop
c01083b2:	83 c4 4c             	add    $0x4c,%esp
c01083b5:	5b                   	pop    %ebx
c01083b6:	5e                   	pop    %esi
c01083b7:	5f                   	pop    %edi
c01083b8:	5d                   	pop    %ebp
c01083b9:	c3                   	ret    

c01083ba <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01083ba:	55                   	push   %ebp
c01083bb:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01083bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01083c0:	8b 15 40 b1 12 c0    	mov    0xc012b140,%edx
c01083c6:	29 d0                	sub    %edx,%eax
c01083c8:	c1 f8 05             	sar    $0x5,%eax
}
c01083cb:	5d                   	pop    %ebp
c01083cc:	c3                   	ret    

c01083cd <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01083cd:	55                   	push   %ebp
c01083ce:	89 e5                	mov    %esp,%ebp
c01083d0:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01083d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01083d6:	89 04 24             	mov    %eax,(%esp)
c01083d9:	e8 dc ff ff ff       	call   c01083ba <page2ppn>
c01083de:	c1 e0 0c             	shl    $0xc,%eax
}
c01083e1:	c9                   	leave  
c01083e2:	c3                   	ret    

c01083e3 <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c01083e3:	55                   	push   %ebp
c01083e4:	89 e5                	mov    %esp,%ebp
c01083e6:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01083e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01083ec:	89 04 24             	mov    %eax,(%esp)
c01083ef:	e8 d9 ff ff ff       	call   c01083cd <page2pa>
c01083f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01083f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083fa:	c1 e8 0c             	shr    $0xc,%eax
c01083fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108400:	a1 80 8f 12 c0       	mov    0xc0128f80,%eax
c0108405:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0108408:	72 23                	jb     c010842d <page2kva+0x4a>
c010840a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010840d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108411:	c7 44 24 08 f0 bb 10 	movl   $0xc010bbf0,0x8(%esp)
c0108418:	c0 
c0108419:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0108420:	00 
c0108421:	c7 04 24 13 bc 10 c0 	movl   $0xc010bc13,(%esp)
c0108428:	e8 d3 7f ff ff       	call   c0100400 <__panic>
c010842d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108430:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0108435:	c9                   	leave  
c0108436:	c3                   	ret    

c0108437 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0108437:	55                   	push   %ebp
c0108438:	89 e5                	mov    %esp,%ebp
c010843a:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c010843d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108444:	e8 d0 8c ff ff       	call   c0101119 <ide_device_valid>
c0108449:	85 c0                	test   %eax,%eax
c010844b:	75 1c                	jne    c0108469 <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c010844d:	c7 44 24 08 21 bc 10 	movl   $0xc010bc21,0x8(%esp)
c0108454:	c0 
c0108455:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c010845c:	00 
c010845d:	c7 04 24 3b bc 10 c0 	movl   $0xc010bc3b,(%esp)
c0108464:	e8 97 7f ff ff       	call   c0100400 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0108469:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108470:	e8 e6 8c ff ff       	call   c010115b <ide_device_size>
c0108475:	c1 e8 03             	shr    $0x3,%eax
c0108478:	a3 fc b0 12 c0       	mov    %eax,0xc012b0fc
}
c010847d:	90                   	nop
c010847e:	c9                   	leave  
c010847f:	c3                   	ret    

c0108480 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c0108480:	55                   	push   %ebp
c0108481:	89 e5                	mov    %esp,%ebp
c0108483:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0108486:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108489:	89 04 24             	mov    %eax,(%esp)
c010848c:	e8 52 ff ff ff       	call   c01083e3 <page2kva>
c0108491:	8b 55 08             	mov    0x8(%ebp),%edx
c0108494:	c1 ea 08             	shr    $0x8,%edx
c0108497:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010849a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010849e:	74 0b                	je     c01084ab <swapfs_read+0x2b>
c01084a0:	8b 15 fc b0 12 c0    	mov    0xc012b0fc,%edx
c01084a6:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c01084a9:	72 23                	jb     c01084ce <swapfs_read+0x4e>
c01084ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01084ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01084b2:	c7 44 24 08 4c bc 10 	movl   $0xc010bc4c,0x8(%esp)
c01084b9:	c0 
c01084ba:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c01084c1:	00 
c01084c2:	c7 04 24 3b bc 10 c0 	movl   $0xc010bc3b,(%esp)
c01084c9:	e8 32 7f ff ff       	call   c0100400 <__panic>
c01084ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01084d1:	c1 e2 03             	shl    $0x3,%edx
c01084d4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01084db:	00 
c01084dc:	89 44 24 08          	mov    %eax,0x8(%esp)
c01084e0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01084e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01084eb:	e8 aa 8c ff ff       	call   c010119a <ide_read_secs>
}
c01084f0:	c9                   	leave  
c01084f1:	c3                   	ret    

c01084f2 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c01084f2:	55                   	push   %ebp
c01084f3:	89 e5                	mov    %esp,%ebp
c01084f5:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01084f8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084fb:	89 04 24             	mov    %eax,(%esp)
c01084fe:	e8 e0 fe ff ff       	call   c01083e3 <page2kva>
c0108503:	8b 55 08             	mov    0x8(%ebp),%edx
c0108506:	c1 ea 08             	shr    $0x8,%edx
c0108509:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010850c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108510:	74 0b                	je     c010851d <swapfs_write+0x2b>
c0108512:	8b 15 fc b0 12 c0    	mov    0xc012b0fc,%edx
c0108518:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c010851b:	72 23                	jb     c0108540 <swapfs_write+0x4e>
c010851d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108520:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108524:	c7 44 24 08 4c bc 10 	movl   $0xc010bc4c,0x8(%esp)
c010852b:	c0 
c010852c:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c0108533:	00 
c0108534:	c7 04 24 3b bc 10 c0 	movl   $0xc010bc3b,(%esp)
c010853b:	e8 c0 7e ff ff       	call   c0100400 <__panic>
c0108540:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108543:	c1 e2 03             	shl    $0x3,%edx
c0108546:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c010854d:	00 
c010854e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108552:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108556:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010855d:	e8 72 8e ff ff       	call   c01013d4 <ide_write_secs>
}
c0108562:	c9                   	leave  
c0108563:	c3                   	ret    

c0108564 <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c0108564:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c0108568:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)          # save esp::context of from
c010856a:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)          # save ebx::context of from
c010856d:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)         # save ecx::context of from
c0108570:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)         # save edx::context of from
c0108573:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)         # save esi::context of from
c0108576:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)         # save edi::context of from
c0108579:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)         # save ebp::context of from
c010857c:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c010857f:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp         # restore ebp::context of to
c0108583:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi         # restore edi::context of to
c0108586:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi         # restore esi::context of to
c0108589:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx         # restore edx::context of to
c010858c:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx         # restore ecx::context of to
c010858f:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx          # restore ebx::context of to
c0108592:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp          # restore esp::context of to
c0108595:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c0108598:	ff 30                	pushl  (%eax)

    ret
c010859a:	c3                   	ret    

c010859b <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c010859b:	52                   	push   %edx
    call *%ebx              # call fn
c010859c:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c010859e:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c010859f:	e8 50 08 00 00       	call   c0108df4 <do_exit>

c01085a4 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c01085a4:	55                   	push   %ebp
c01085a5:	89 e5                	mov    %esp,%ebp
c01085a7:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01085aa:	9c                   	pushf  
c01085ab:	58                   	pop    %eax
c01085ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01085af:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01085b2:	25 00 02 00 00       	and    $0x200,%eax
c01085b7:	85 c0                	test   %eax,%eax
c01085b9:	74 0c                	je     c01085c7 <__intr_save+0x23>
        intr_disable();
c01085bb:	e8 39 9b ff ff       	call   c01020f9 <intr_disable>
        return 1;
c01085c0:	b8 01 00 00 00       	mov    $0x1,%eax
c01085c5:	eb 05                	jmp    c01085cc <__intr_save+0x28>
    }
    return 0;
c01085c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01085cc:	c9                   	leave  
c01085cd:	c3                   	ret    

c01085ce <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01085ce:	55                   	push   %ebp
c01085cf:	89 e5                	mov    %esp,%ebp
c01085d1:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01085d4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01085d8:	74 05                	je     c01085df <__intr_restore+0x11>
        intr_enable();
c01085da:	e8 13 9b ff ff       	call   c01020f2 <intr_enable>
    }
}
c01085df:	90                   	nop
c01085e0:	c9                   	leave  
c01085e1:	c3                   	ret    

c01085e2 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01085e2:	55                   	push   %ebp
c01085e3:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01085e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01085e8:	8b 15 40 b1 12 c0    	mov    0xc012b140,%edx
c01085ee:	29 d0                	sub    %edx,%eax
c01085f0:	c1 f8 05             	sar    $0x5,%eax
}
c01085f3:	5d                   	pop    %ebp
c01085f4:	c3                   	ret    

c01085f5 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01085f5:	55                   	push   %ebp
c01085f6:	89 e5                	mov    %esp,%ebp
c01085f8:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01085fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01085fe:	89 04 24             	mov    %eax,(%esp)
c0108601:	e8 dc ff ff ff       	call   c01085e2 <page2ppn>
c0108606:	c1 e0 0c             	shl    $0xc,%eax
}
c0108609:	c9                   	leave  
c010860a:	c3                   	ret    

c010860b <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c010860b:	55                   	push   %ebp
c010860c:	89 e5                	mov    %esp,%ebp
c010860e:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0108611:	8b 45 08             	mov    0x8(%ebp),%eax
c0108614:	c1 e8 0c             	shr    $0xc,%eax
c0108617:	89 c2                	mov    %eax,%edx
c0108619:	a1 80 8f 12 c0       	mov    0xc0128f80,%eax
c010861e:	39 c2                	cmp    %eax,%edx
c0108620:	72 1c                	jb     c010863e <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0108622:	c7 44 24 08 6c bc 10 	movl   $0xc010bc6c,0x8(%esp)
c0108629:	c0 
c010862a:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0108631:	00 
c0108632:	c7 04 24 8b bc 10 c0 	movl   $0xc010bc8b,(%esp)
c0108639:	e8 c2 7d ff ff       	call   c0100400 <__panic>
    }
    return &pages[PPN(pa)];
c010863e:	a1 40 b1 12 c0       	mov    0xc012b140,%eax
c0108643:	8b 55 08             	mov    0x8(%ebp),%edx
c0108646:	c1 ea 0c             	shr    $0xc,%edx
c0108649:	c1 e2 05             	shl    $0x5,%edx
c010864c:	01 d0                	add    %edx,%eax
}
c010864e:	c9                   	leave  
c010864f:	c3                   	ret    

c0108650 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0108650:	55                   	push   %ebp
c0108651:	89 e5                	mov    %esp,%ebp
c0108653:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0108656:	8b 45 08             	mov    0x8(%ebp),%eax
c0108659:	89 04 24             	mov    %eax,(%esp)
c010865c:	e8 94 ff ff ff       	call   c01085f5 <page2pa>
c0108661:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108664:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108667:	c1 e8 0c             	shr    $0xc,%eax
c010866a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010866d:	a1 80 8f 12 c0       	mov    0xc0128f80,%eax
c0108672:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0108675:	72 23                	jb     c010869a <page2kva+0x4a>
c0108677:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010867a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010867e:	c7 44 24 08 9c bc 10 	movl   $0xc010bc9c,0x8(%esp)
c0108685:	c0 
c0108686:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c010868d:	00 
c010868e:	c7 04 24 8b bc 10 c0 	movl   $0xc010bc8b,(%esp)
c0108695:	e8 66 7d ff ff       	call   c0100400 <__panic>
c010869a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010869d:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01086a2:	c9                   	leave  
c01086a3:	c3                   	ret    

c01086a4 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c01086a4:	55                   	push   %ebp
c01086a5:	89 e5                	mov    %esp,%ebp
c01086a7:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01086aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01086ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01086b0:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01086b7:	77 23                	ja     c01086dc <kva2page+0x38>
c01086b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01086c0:	c7 44 24 08 c0 bc 10 	movl   $0xc010bcc0,0x8(%esp)
c01086c7:	c0 
c01086c8:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c01086cf:	00 
c01086d0:	c7 04 24 8b bc 10 c0 	movl   $0xc010bc8b,(%esp)
c01086d7:	e8 24 7d ff ff       	call   c0100400 <__panic>
c01086dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01086df:	05 00 00 00 40       	add    $0x40000000,%eax
c01086e4:	89 04 24             	mov    %eax,(%esp)
c01086e7:	e8 1f ff ff ff       	call   c010860b <pa2page>
}
c01086ec:	c9                   	leave  
c01086ed:	c3                   	ret    

c01086ee <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c01086ee:	55                   	push   %ebp
c01086ef:	89 e5                	mov    %esp,%ebp
c01086f1:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c01086f4:	c7 04 24 68 00 00 00 	movl   $0x68,(%esp)
c01086fb:	e8 8f ca ff ff       	call   c010518f <kmalloc>
c0108700:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c0108703:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108707:	0f 84 a1 00 00 00    	je     c01087ae <alloc_proc+0xc0>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;
c010870d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108710:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;
c0108716:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108719:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->runs = 0;
c0108720:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108723:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        proc->kstack = 0;
c010872a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010872d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        proc->need_resched = 0;
c0108734:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108737:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        proc->parent = NULL;
c010873e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108741:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        proc->mm = NULL;
c0108748:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010874b:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        memset(&(proc->context), 0, sizeof(struct context));
c0108752:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108755:	83 c0 1c             	add    $0x1c,%eax
c0108758:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c010875f:	00 
c0108760:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108767:	00 
c0108768:	89 04 24             	mov    %eax,(%esp)
c010876b:	e8 43 0d 00 00       	call   c01094b3 <memset>
        proc->tf = NULL;
c0108770:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108773:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
        proc->cr3 = boot_cr3;
c010877a:	8b 15 3c b1 12 c0    	mov    0xc012b13c,%edx
c0108780:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108783:	89 50 40             	mov    %edx,0x40(%eax)
        proc->flags = 0;
c0108786:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108789:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
        memset(proc->name, 0, PROC_NAME_LEN);
c0108790:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108793:	83 c0 48             	add    $0x48,%eax
c0108796:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c010879d:	00 
c010879e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01087a5:	00 
c01087a6:	89 04 24             	mov    %eax,(%esp)
c01087a9:	e8 05 0d 00 00       	call   c01094b3 <memset>
    }
    return proc;
c01087ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01087b1:	c9                   	leave  
c01087b2:	c3                   	ret    

c01087b3 <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c01087b3:	55                   	push   %ebp
c01087b4:	89 e5                	mov    %esp,%ebp
c01087b6:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c01087b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01087bc:	83 c0 48             	add    $0x48,%eax
c01087bf:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01087c6:	00 
c01087c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01087ce:	00 
c01087cf:	89 04 24             	mov    %eax,(%esp)
c01087d2:	e8 dc 0c 00 00       	call   c01094b3 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c01087d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01087da:	8d 50 48             	lea    0x48(%eax),%edx
c01087dd:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c01087e4:	00 
c01087e5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01087e8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01087ec:	89 14 24             	mov    %edx,(%esp)
c01087ef:	e8 a2 0d 00 00       	call   c0109596 <memcpy>
}
c01087f4:	c9                   	leave  
c01087f5:	c3                   	ret    

c01087f6 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c01087f6:	55                   	push   %ebp
c01087f7:	89 e5                	mov    %esp,%ebp
c01087f9:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c01087fc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0108803:	00 
c0108804:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010880b:	00 
c010880c:	c7 04 24 44 b0 12 c0 	movl   $0xc012b044,(%esp)
c0108813:	e8 9b 0c 00 00       	call   c01094b3 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0108818:	8b 45 08             	mov    0x8(%ebp),%eax
c010881b:	83 c0 48             	add    $0x48,%eax
c010881e:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0108825:	00 
c0108826:	89 44 24 04          	mov    %eax,0x4(%esp)
c010882a:	c7 04 24 44 b0 12 c0 	movl   $0xc012b044,(%esp)
c0108831:	e8 60 0d 00 00       	call   c0109596 <memcpy>
}
c0108836:	c9                   	leave  
c0108837:	c3                   	ret    

c0108838 <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c0108838:	55                   	push   %ebp
c0108839:	89 e5                	mov    %esp,%ebp
c010883b:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c010883e:	c7 45 f8 44 b1 12 c0 	movl   $0xc012b144,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c0108845:	a1 78 5a 12 c0       	mov    0xc0125a78,%eax
c010884a:	40                   	inc    %eax
c010884b:	a3 78 5a 12 c0       	mov    %eax,0xc0125a78
c0108850:	a1 78 5a 12 c0       	mov    0xc0125a78,%eax
c0108855:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c010885a:	7e 0c                	jle    c0108868 <get_pid+0x30>
        last_pid = 1;
c010885c:	c7 05 78 5a 12 c0 01 	movl   $0x1,0xc0125a78
c0108863:	00 00 00 
        goto inside;
c0108866:	eb 13                	jmp    c010887b <get_pid+0x43>
    }
    if (last_pid >= next_safe) {
c0108868:	8b 15 78 5a 12 c0    	mov    0xc0125a78,%edx
c010886e:	a1 7c 5a 12 c0       	mov    0xc0125a7c,%eax
c0108873:	39 c2                	cmp    %eax,%edx
c0108875:	0f 8c aa 00 00 00    	jl     c0108925 <get_pid+0xed>
    inside:
        next_safe = MAX_PID;
c010887b:	c7 05 7c 5a 12 c0 00 	movl   $0x2000,0xc0125a7c
c0108882:	20 00 00 
    repeat:
        le = list;
c0108885:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108888:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c010888b:	eb 7d                	jmp    c010890a <get_pid+0xd2>
            proc = le2proc(le, list_link);
c010888d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108890:	83 e8 58             	sub    $0x58,%eax
c0108893:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c0108896:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108899:	8b 50 04             	mov    0x4(%eax),%edx
c010889c:	a1 78 5a 12 c0       	mov    0xc0125a78,%eax
c01088a1:	39 c2                	cmp    %eax,%edx
c01088a3:	75 3c                	jne    c01088e1 <get_pid+0xa9>
                if (++ last_pid >= next_safe) {
c01088a5:	a1 78 5a 12 c0       	mov    0xc0125a78,%eax
c01088aa:	40                   	inc    %eax
c01088ab:	a3 78 5a 12 c0       	mov    %eax,0xc0125a78
c01088b0:	8b 15 78 5a 12 c0    	mov    0xc0125a78,%edx
c01088b6:	a1 7c 5a 12 c0       	mov    0xc0125a7c,%eax
c01088bb:	39 c2                	cmp    %eax,%edx
c01088bd:	7c 4b                	jl     c010890a <get_pid+0xd2>
                    if (last_pid >= MAX_PID) {
c01088bf:	a1 78 5a 12 c0       	mov    0xc0125a78,%eax
c01088c4:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c01088c9:	7e 0a                	jle    c01088d5 <get_pid+0x9d>
                        last_pid = 1;
c01088cb:	c7 05 78 5a 12 c0 01 	movl   $0x1,0xc0125a78
c01088d2:	00 00 00 
                    }
                    next_safe = MAX_PID;
c01088d5:	c7 05 7c 5a 12 c0 00 	movl   $0x2000,0xc0125a7c
c01088dc:	20 00 00 
                    goto repeat;
c01088df:	eb a4                	jmp    c0108885 <get_pid+0x4d>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c01088e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088e4:	8b 50 04             	mov    0x4(%eax),%edx
c01088e7:	a1 78 5a 12 c0       	mov    0xc0125a78,%eax
c01088ec:	39 c2                	cmp    %eax,%edx
c01088ee:	7e 1a                	jle    c010890a <get_pid+0xd2>
c01088f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088f3:	8b 50 04             	mov    0x4(%eax),%edx
c01088f6:	a1 7c 5a 12 c0       	mov    0xc0125a7c,%eax
c01088fb:	39 c2                	cmp    %eax,%edx
c01088fd:	7d 0b                	jge    c010890a <get_pid+0xd2>
                next_safe = proc->pid;
c01088ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108902:	8b 40 04             	mov    0x4(%eax),%eax
c0108905:	a3 7c 5a 12 c0       	mov    %eax,0xc0125a7c
c010890a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010890d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108910:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108913:	8b 40 04             	mov    0x4(%eax),%eax
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
c0108916:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0108919:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010891c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c010891f:	0f 85 68 ff ff ff    	jne    c010888d <get_pid+0x55>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
c0108925:	a1 78 5a 12 c0       	mov    0xc0125a78,%eax
}
c010892a:	c9                   	leave  
c010892b:	c3                   	ret    

c010892c <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c010892c:	55                   	push   %ebp
c010892d:	89 e5                	mov    %esp,%ebp
c010892f:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c0108932:	a1 28 90 12 c0       	mov    0xc0129028,%eax
c0108937:	39 45 08             	cmp    %eax,0x8(%ebp)
c010893a:	74 63                	je     c010899f <proc_run+0x73>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c010893c:	a1 28 90 12 c0       	mov    0xc0129028,%eax
c0108941:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108944:	8b 45 08             	mov    0x8(%ebp),%eax
c0108947:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c010894a:	e8 55 fc ff ff       	call   c01085a4 <__intr_save>
c010894f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c0108952:	8b 45 08             	mov    0x8(%ebp),%eax
c0108955:	a3 28 90 12 c0       	mov    %eax,0xc0129028
            load_esp0(next->kstack + KSTACKSIZE);
c010895a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010895d:	8b 40 0c             	mov    0xc(%eax),%eax
c0108960:	05 00 20 00 00       	add    $0x2000,%eax
c0108965:	89 04 24             	mov    %eax,(%esp)
c0108968:	e8 6f e1 ff ff       	call   c0106adc <load_esp0>
            lcr3(next->cr3);
c010896d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108970:	8b 40 40             	mov    0x40(%eax),%eax
c0108973:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0108976:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108979:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c010897c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010897f:	8d 50 1c             	lea    0x1c(%eax),%edx
c0108982:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108985:	83 c0 1c             	add    $0x1c,%eax
c0108988:	89 54 24 04          	mov    %edx,0x4(%esp)
c010898c:	89 04 24             	mov    %eax,(%esp)
c010898f:	e8 d0 fb ff ff       	call   c0108564 <switch_to>
        }
        local_intr_restore(intr_flag);
c0108994:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108997:	89 04 24             	mov    %eax,(%esp)
c010899a:	e8 2f fc ff ff       	call   c01085ce <__intr_restore>
    }
}
c010899f:	90                   	nop
c01089a0:	c9                   	leave  
c01089a1:	c3                   	ret    

c01089a2 <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c01089a2:	55                   	push   %ebp
c01089a3:	89 e5                	mov    %esp,%ebp
c01089a5:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c01089a8:	a1 28 90 12 c0       	mov    0xc0129028,%eax
c01089ad:	8b 40 3c             	mov    0x3c(%eax),%eax
c01089b0:	89 04 24             	mov    %eax,(%esp)
c01089b3:	e8 9b a8 ff ff       	call   c0103253 <forkrets>
}
c01089b8:	90                   	nop
c01089b9:	c9                   	leave  
c01089ba:	c3                   	ret    

c01089bb <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c01089bb:	55                   	push   %ebp
c01089bc:	89 e5                	mov    %esp,%ebp
c01089be:	53                   	push   %ebx
c01089bf:	83 ec 34             	sub    $0x34,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c01089c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01089c5:	8d 58 60             	lea    0x60(%eax),%ebx
c01089c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01089cb:	8b 40 04             	mov    0x4(%eax),%eax
c01089ce:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c01089d5:	00 
c01089d6:	89 04 24             	mov    %eax,(%esp)
c01089d9:	e8 cf 12 00 00       	call   c0109cad <hash32>
c01089de:	c1 e0 03             	shl    $0x3,%eax
c01089e1:	05 40 90 12 c0       	add    $0xc0129040,%eax
c01089e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01089e9:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c01089ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01089f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01089f5:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01089f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01089fb:	8b 40 04             	mov    0x4(%eax),%eax
c01089fe:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108a01:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108a04:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108a07:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0108a0a:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0108a0d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108a10:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108a13:	89 10                	mov    %edx,(%eax)
c0108a15:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108a18:	8b 10                	mov    (%eax),%edx
c0108a1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108a1d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108a20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108a23:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108a26:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108a29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108a2c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108a2f:	89 10                	mov    %edx,(%eax)
}
c0108a31:	90                   	nop
c0108a32:	83 c4 34             	add    $0x34,%esp
c0108a35:	5b                   	pop    %ebx
c0108a36:	5d                   	pop    %ebp
c0108a37:	c3                   	ret    

c0108a38 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0108a38:	55                   	push   %ebp
c0108a39:	89 e5                	mov    %esp,%ebp
c0108a3b:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c0108a3e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108a42:	7e 5f                	jle    c0108aa3 <find_proc+0x6b>
c0108a44:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0108a4b:	7f 56                	jg     c0108aa3 <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0108a4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a50:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0108a57:	00 
c0108a58:	89 04 24             	mov    %eax,(%esp)
c0108a5b:	e8 4d 12 00 00       	call   c0109cad <hash32>
c0108a60:	c1 e0 03             	shl    $0x3,%eax
c0108a63:	05 40 90 12 c0       	add    $0xc0129040,%eax
c0108a68:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108a6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c0108a71:	eb 19                	jmp    c0108a8c <find_proc+0x54>
            struct proc_struct *proc = le2proc(le, hash_link);
c0108a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a76:	83 e8 60             	sub    $0x60,%eax
c0108a79:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c0108a7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108a7f:	8b 40 04             	mov    0x4(%eax),%eax
c0108a82:	3b 45 08             	cmp    0x8(%ebp),%eax
c0108a85:	75 05                	jne    c0108a8c <find_proc+0x54>
                return proc;
c0108a87:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108a8a:	eb 1c                	jmp    c0108aa8 <find_proc+0x70>
c0108a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a8f:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0108a92:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108a95:	8b 40 04             	mov    0x4(%eax),%eax
// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
c0108a98:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a9e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108aa1:	75 d0                	jne    c0108a73 <find_proc+0x3b>
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
c0108aa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108aa8:	c9                   	leave  
c0108aa9:	c3                   	ret    

c0108aaa <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c0108aaa:	55                   	push   %ebp
c0108aab:	89 e5                	mov    %esp,%ebp
c0108aad:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0108ab0:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0108ab7:	00 
c0108ab8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108abf:	00 
c0108ac0:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0108ac3:	89 04 24             	mov    %eax,(%esp)
c0108ac6:	e8 e8 09 00 00       	call   c01094b3 <memset>
    tf.tf_cs = KERNEL_CS;
c0108acb:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0108ad1:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0108ad7:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0108adb:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0108adf:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0108ae3:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0108ae7:	8b 45 08             	mov    0x8(%ebp),%eax
c0108aea:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0108aed:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108af0:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0108af3:	b8 9b 85 10 c0       	mov    $0xc010859b,%eax
c0108af8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0108afb:	8b 45 10             	mov    0x10(%ebp),%eax
c0108afe:	0d 00 01 00 00       	or     $0x100,%eax
c0108b03:	89 c2                	mov    %eax,%edx
c0108b05:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0108b08:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108b0c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108b13:	00 
c0108b14:	89 14 24             	mov    %edx,(%esp)
c0108b17:	e8 88 01 00 00       	call   c0108ca4 <do_fork>
}
c0108b1c:	c9                   	leave  
c0108b1d:	c3                   	ret    

c0108b1e <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0108b1e:	55                   	push   %ebp
c0108b1f:	89 e5                	mov    %esp,%ebp
c0108b21:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0108b24:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0108b2b:	e8 f7 e0 ff ff       	call   c0106c27 <alloc_pages>
c0108b30:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0108b33:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108b37:	74 1a                	je     c0108b53 <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c0108b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b3c:	89 04 24             	mov    %eax,(%esp)
c0108b3f:	e8 0c fb ff ff       	call   c0108650 <page2kva>
c0108b44:	89 c2                	mov    %eax,%edx
c0108b46:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b49:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0108b4c:	b8 00 00 00 00       	mov    $0x0,%eax
c0108b51:	eb 05                	jmp    c0108b58 <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c0108b53:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0108b58:	c9                   	leave  
c0108b59:	c3                   	ret    

c0108b5a <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0108b5a:	55                   	push   %ebp
c0108b5b:	89 e5                	mov    %esp,%ebp
c0108b5d:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0108b60:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b63:	8b 40 0c             	mov    0xc(%eax),%eax
c0108b66:	89 04 24             	mov    %eax,(%esp)
c0108b69:	e8 36 fb ff ff       	call   c01086a4 <kva2page>
c0108b6e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0108b75:	00 
c0108b76:	89 04 24             	mov    %eax,(%esp)
c0108b79:	e8 14 e1 ff ff       	call   c0106c92 <free_pages>
}
c0108b7e:	90                   	nop
c0108b7f:	c9                   	leave  
c0108b80:	c3                   	ret    

c0108b81 <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0108b81:	55                   	push   %ebp
c0108b82:	89 e5                	mov    %esp,%ebp
c0108b84:	83 ec 18             	sub    $0x18,%esp
    assert(current->mm == NULL);
c0108b87:	a1 28 90 12 c0       	mov    0xc0129028,%eax
c0108b8c:	8b 40 18             	mov    0x18(%eax),%eax
c0108b8f:	85 c0                	test   %eax,%eax
c0108b91:	74 24                	je     c0108bb7 <copy_mm+0x36>
c0108b93:	c7 44 24 0c e4 bc 10 	movl   $0xc010bce4,0xc(%esp)
c0108b9a:	c0 
c0108b9b:	c7 44 24 08 f8 bc 10 	movl   $0xc010bcf8,0x8(%esp)
c0108ba2:	c0 
c0108ba3:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c0108baa:	00 
c0108bab:	c7 04 24 0d bd 10 c0 	movl   $0xc010bd0d,(%esp)
c0108bb2:	e8 49 78 ff ff       	call   c0100400 <__panic>
    /* do nothing in this project */
    return 0;
c0108bb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108bbc:	c9                   	leave  
c0108bbd:	c3                   	ret    

c0108bbe <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c0108bbe:	55                   	push   %ebp
c0108bbf:	89 e5                	mov    %esp,%ebp
c0108bc1:	57                   	push   %edi
c0108bc2:	56                   	push   %esi
c0108bc3:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0108bc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bc7:	8b 40 0c             	mov    0xc(%eax),%eax
c0108bca:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0108bcf:	89 c2                	mov    %eax,%edx
c0108bd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bd4:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c0108bd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bda:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108bdd:	8b 55 10             	mov    0x10(%ebp),%edx
c0108be0:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0108be5:	89 c1                	mov    %eax,%ecx
c0108be7:	83 e1 01             	and    $0x1,%ecx
c0108bea:	85 c9                	test   %ecx,%ecx
c0108bec:	74 0c                	je     c0108bfa <copy_thread+0x3c>
c0108bee:	0f b6 0a             	movzbl (%edx),%ecx
c0108bf1:	88 08                	mov    %cl,(%eax)
c0108bf3:	8d 40 01             	lea    0x1(%eax),%eax
c0108bf6:	8d 52 01             	lea    0x1(%edx),%edx
c0108bf9:	4b                   	dec    %ebx
c0108bfa:	89 c1                	mov    %eax,%ecx
c0108bfc:	83 e1 02             	and    $0x2,%ecx
c0108bff:	85 c9                	test   %ecx,%ecx
c0108c01:	74 0f                	je     c0108c12 <copy_thread+0x54>
c0108c03:	0f b7 0a             	movzwl (%edx),%ecx
c0108c06:	66 89 08             	mov    %cx,(%eax)
c0108c09:	8d 40 02             	lea    0x2(%eax),%eax
c0108c0c:	8d 52 02             	lea    0x2(%edx),%edx
c0108c0f:	83 eb 02             	sub    $0x2,%ebx
c0108c12:	89 df                	mov    %ebx,%edi
c0108c14:	83 e7 fc             	and    $0xfffffffc,%edi
c0108c17:	b9 00 00 00 00       	mov    $0x0,%ecx
c0108c1c:	8b 34 0a             	mov    (%edx,%ecx,1),%esi
c0108c1f:	89 34 08             	mov    %esi,(%eax,%ecx,1)
c0108c22:	83 c1 04             	add    $0x4,%ecx
c0108c25:	39 f9                	cmp    %edi,%ecx
c0108c27:	72 f3                	jb     c0108c1c <copy_thread+0x5e>
c0108c29:	01 c8                	add    %ecx,%eax
c0108c2b:	01 ca                	add    %ecx,%edx
c0108c2d:	b9 00 00 00 00       	mov    $0x0,%ecx
c0108c32:	89 de                	mov    %ebx,%esi
c0108c34:	83 e6 02             	and    $0x2,%esi
c0108c37:	85 f6                	test   %esi,%esi
c0108c39:	74 0b                	je     c0108c46 <copy_thread+0x88>
c0108c3b:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0108c3f:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0108c43:	83 c1 02             	add    $0x2,%ecx
c0108c46:	83 e3 01             	and    $0x1,%ebx
c0108c49:	85 db                	test   %ebx,%ebx
c0108c4b:	74 07                	je     c0108c54 <copy_thread+0x96>
c0108c4d:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c0108c51:	88 14 08             	mov    %dl,(%eax,%ecx,1)
    proc->tf->tf_regs.reg_eax = 0;
c0108c54:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c57:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108c5a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c0108c61:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c64:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108c67:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108c6a:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c0108c6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c70:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108c73:	8b 55 08             	mov    0x8(%ebp),%edx
c0108c76:	8b 52 3c             	mov    0x3c(%edx),%edx
c0108c79:	8b 52 40             	mov    0x40(%edx),%edx
c0108c7c:	81 ca 00 02 00 00    	or     $0x200,%edx
c0108c82:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c0108c85:	ba a2 89 10 c0       	mov    $0xc01089a2,%edx
c0108c8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c8d:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c0108c90:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c93:	8b 40 3c             	mov    0x3c(%eax),%eax
c0108c96:	89 c2                	mov    %eax,%edx
c0108c98:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c9b:	89 50 20             	mov    %edx,0x20(%eax)
}
c0108c9e:	90                   	nop
c0108c9f:	5b                   	pop    %ebx
c0108ca0:	5e                   	pop    %esi
c0108ca1:	5f                   	pop    %edi
c0108ca2:	5d                   	pop    %ebp
c0108ca3:	c3                   	ret    

c0108ca4 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c0108ca4:	55                   	push   %ebp
c0108ca5:	89 e5                	mov    %esp,%ebp
c0108ca7:	83 ec 48             	sub    $0x48,%esp
    int ret = -E_NO_FREE_PROC;
c0108caa:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c0108cb1:	a1 40 b0 12 c0       	mov    0xc012b040,%eax
c0108cb6:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0108cbb:	0f 8f 0c 01 00 00    	jg     c0108dcd <do_fork+0x129>
        goto fork_out;
    }
    ret = -E_NO_MEM;
c0108cc1:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    if ((proc = alloc_proc()) == NULL)
c0108cc8:	e8 21 fa ff ff       	call   c01086ee <alloc_proc>
c0108ccd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108cd0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108cd4:	0f 84 f6 00 00 00    	je     c0108dd0 <do_fork+0x12c>
        goto fork_out;

    proc->parent = current;
c0108cda:	8b 15 28 90 12 c0    	mov    0xc0129028,%edx
c0108ce0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ce3:	89 50 14             	mov    %edx,0x14(%eax)
    if (setup_kstack(proc) != 0)
c0108ce6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ce9:	89 04 24             	mov    %eax,(%esp)
c0108cec:	e8 2d fe ff ff       	call   c0108b1e <setup_kstack>
c0108cf1:	85 c0                	test   %eax,%eax
c0108cf3:	0f 85 eb 00 00 00    	jne    c0108de4 <do_fork+0x140>
        goto bad_fork_cleanup_proc;

    if (copy_mm(clone_flags, proc) != 0)
c0108cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108d00:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d03:	89 04 24             	mov    %eax,(%esp)
c0108d06:	e8 76 fe ff ff       	call   c0108b81 <copy_mm>
c0108d0b:	85 c0                	test   %eax,%eax
c0108d0d:	0f 85 c3 00 00 00    	jne    c0108dd6 <do_fork+0x132>
        goto bad_fork_cleanup_kstack;

    copy_thread(proc, stack, tf);
c0108d13:	8b 45 10             	mov    0x10(%ebp),%eax
c0108d16:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108d1d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108d21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108d24:	89 04 24             	mov    %eax,(%esp)
c0108d27:	e8 92 fe ff ff       	call   c0108bbe <copy_thread>
    bool intr_flag;
    local_intr_save(intr_flag);
c0108d2c:	e8 73 f8 ff ff       	call   c01085a4 <__intr_save>
c0108d31:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        proc->pid = get_pid();
c0108d34:	e8 ff fa ff ff       	call   c0108838 <get_pid>
c0108d39:	89 c2                	mov    %eax,%edx
c0108d3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108d3e:	89 50 04             	mov    %edx,0x4(%eax)
        hash_proc(proc);
c0108d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108d44:	89 04 24             	mov    %eax,(%esp)
c0108d47:	e8 6f fc ff ff       	call   c01089bb <hash_proc>
        list_add(&proc_list, &(proc->list_link));
c0108d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108d4f:	83 c0 58             	add    $0x58,%eax
c0108d52:	c7 45 e8 44 b1 12 c0 	movl   $0xc012b144,-0x18(%ebp)
c0108d59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108d5c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108d5f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108d62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108d65:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0108d68:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108d6b:	8b 40 04             	mov    0x4(%eax),%eax
c0108d6e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108d71:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0108d74:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108d77:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108d7a:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0108d7d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108d80:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108d83:	89 10                	mov    %edx,(%eax)
c0108d85:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108d88:	8b 10                	mov    (%eax),%edx
c0108d8a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0108d8d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108d90:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108d93:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0108d96:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108d99:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108d9c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108d9f:	89 10                	mov    %edx,(%eax)
        ++nr_process;
c0108da1:	a1 40 b0 12 c0       	mov    0xc012b040,%eax
c0108da6:	40                   	inc    %eax
c0108da7:	a3 40 b0 12 c0       	mov    %eax,0xc012b040
    }
    local_intr_restore(intr_flag);
c0108dac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108daf:	89 04 24             	mov    %eax,(%esp)
c0108db2:	e8 17 f8 ff ff       	call   c01085ce <__intr_restore>
    wakeup_proc(proc);
c0108db7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108dba:	89 04 24             	mov    %eax,(%esp)
c0108dbd:	e8 bf 02 00 00       	call   c0109081 <wakeup_proc>
    ret = proc->pid;
c0108dc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108dc5:	8b 40 04             	mov    0x4(%eax),%eax
c0108dc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108dcb:	eb 04                	jmp    c0108dd1 <do_fork+0x12d>
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
c0108dcd:	90                   	nop
c0108dce:	eb 01                	jmp    c0108dd1 <do_fork+0x12d>
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    if ((proc = alloc_proc()) == NULL)
        goto fork_out;
c0108dd0:	90                   	nop
    }
    local_intr_restore(intr_flag);
    wakeup_proc(proc);
    ret = proc->pid;
fork_out:
    return ret;
c0108dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108dd4:	eb 1c                	jmp    c0108df2 <do_fork+0x14e>
    proc->parent = current;
    if (setup_kstack(proc) != 0)
        goto bad_fork_cleanup_proc;

    if (copy_mm(clone_flags, proc) != 0)
        goto bad_fork_cleanup_kstack;
c0108dd6:	90                   	nop
    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
c0108dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108dda:	89 04 24             	mov    %eax,(%esp)
c0108ddd:	e8 78 fd ff ff       	call   c0108b5a <put_kstack>
c0108de2:	eb 01                	jmp    c0108de5 <do_fork+0x141>
    if ((proc = alloc_proc()) == NULL)
        goto fork_out;

    proc->parent = current;
    if (setup_kstack(proc) != 0)
        goto bad_fork_cleanup_proc;
c0108de4:	90                   	nop
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
c0108de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108de8:	89 04 24             	mov    %eax,(%esp)
c0108deb:	e8 ba c3 ff ff       	call   c01051aa <kfree>
    goto fork_out;
c0108df0:	eb df                	jmp    c0108dd1 <do_fork+0x12d>
}
c0108df2:	c9                   	leave  
c0108df3:	c3                   	ret    

c0108df4 <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c0108df4:	55                   	push   %ebp
c0108df5:	89 e5                	mov    %esp,%ebp
c0108df7:	83 ec 18             	sub    $0x18,%esp
    panic("process exit!!.\n");
c0108dfa:	c7 44 24 08 21 bd 10 	movl   $0xc010bd21,0x8(%esp)
c0108e01:	c0 
c0108e02:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
c0108e09:	00 
c0108e0a:	c7 04 24 0d bd 10 c0 	movl   $0xc010bd0d,(%esp)
c0108e11:	e8 ea 75 ff ff       	call   c0100400 <__panic>

c0108e16 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c0108e16:	55                   	push   %ebp
c0108e17:	89 e5                	mov    %esp,%ebp
c0108e19:	83 ec 18             	sub    $0x18,%esp
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
c0108e1c:	a1 28 90 12 c0       	mov    0xc0129028,%eax
c0108e21:	89 04 24             	mov    %eax,(%esp)
c0108e24:	e8 cd f9 ff ff       	call   c01087f6 <get_proc_name>
c0108e29:	89 c2                	mov    %eax,%edx
c0108e2b:	a1 28 90 12 c0       	mov    0xc0129028,%eax
c0108e30:	8b 40 04             	mov    0x4(%eax),%eax
c0108e33:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108e37:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108e3b:	c7 04 24 34 bd 10 c0 	movl   $0xc010bd34,(%esp)
c0108e42:	e8 62 74 ff ff       	call   c01002a9 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
c0108e47:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e4a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108e4e:	c7 04 24 5a bd 10 c0 	movl   $0xc010bd5a,(%esp)
c0108e55:	e8 4f 74 ff ff       	call   c01002a9 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
c0108e5a:	c7 04 24 67 bd 10 c0 	movl   $0xc010bd67,(%esp)
c0108e61:	e8 43 74 ff ff       	call   c01002a9 <cprintf>
    return 0;
c0108e66:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108e6b:	c9                   	leave  
c0108e6c:	c3                   	ret    

c0108e6d <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c0108e6d:	55                   	push   %ebp
c0108e6e:	89 e5                	mov    %esp,%ebp
c0108e70:	83 ec 28             	sub    $0x28,%esp
c0108e73:	c7 45 e8 44 b1 12 c0 	movl   $0xc012b144,-0x18(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0108e7a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108e7d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108e80:	89 50 04             	mov    %edx,0x4(%eax)
c0108e83:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108e86:	8b 50 04             	mov    0x4(%eax),%edx
c0108e89:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108e8c:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c0108e8e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108e95:	eb 25                	jmp    c0108ebc <proc_init+0x4f>
        list_init(hash_list + i);
c0108e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108e9a:	c1 e0 03             	shl    $0x3,%eax
c0108e9d:	05 40 90 12 c0       	add    $0xc0129040,%eax
c0108ea2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ea8:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108eab:	89 50 04             	mov    %edx,0x4(%eax)
c0108eae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108eb1:	8b 50 04             	mov    0x4(%eax),%edx
c0108eb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108eb7:	89 10                	mov    %edx,(%eax)
void
proc_init(void) {
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c0108eb9:	ff 45 f4             	incl   -0xc(%ebp)
c0108ebc:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c0108ec3:	7e d2                	jle    c0108e97 <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
c0108ec5:	e8 24 f8 ff ff       	call   c01086ee <alloc_proc>
c0108eca:	a3 20 90 12 c0       	mov    %eax,0xc0129020
c0108ecf:	a1 20 90 12 c0       	mov    0xc0129020,%eax
c0108ed4:	85 c0                	test   %eax,%eax
c0108ed6:	75 1c                	jne    c0108ef4 <proc_init+0x87>
        panic("cannot alloc idleproc.\n");
c0108ed8:	c7 44 24 08 83 bd 10 	movl   $0xc010bd83,0x8(%esp)
c0108edf:	c0 
c0108ee0:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
c0108ee7:	00 
c0108ee8:	c7 04 24 0d bd 10 c0 	movl   $0xc010bd0d,(%esp)
c0108eef:	e8 0c 75 ff ff       	call   c0100400 <__panic>
    }

    idleproc->pid = 0;
c0108ef4:	a1 20 90 12 c0       	mov    0xc0129020,%eax
c0108ef9:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c0108f00:	a1 20 90 12 c0       	mov    0xc0129020,%eax
c0108f05:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c0108f0b:	a1 20 90 12 c0       	mov    0xc0129020,%eax
c0108f10:	ba 00 30 12 c0       	mov    $0xc0123000,%edx
c0108f15:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c0108f18:	a1 20 90 12 c0       	mov    0xc0129020,%eax
c0108f1d:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c0108f24:	a1 20 90 12 c0       	mov    0xc0129020,%eax
c0108f29:	c7 44 24 04 9b bd 10 	movl   $0xc010bd9b,0x4(%esp)
c0108f30:	c0 
c0108f31:	89 04 24             	mov    %eax,(%esp)
c0108f34:	e8 7a f8 ff ff       	call   c01087b3 <set_proc_name>
    nr_process ++;
c0108f39:	a1 40 b0 12 c0       	mov    0xc012b040,%eax
c0108f3e:	40                   	inc    %eax
c0108f3f:	a3 40 b0 12 c0       	mov    %eax,0xc012b040

    current = idleproc;
c0108f44:	a1 20 90 12 c0       	mov    0xc0129020,%eax
c0108f49:	a3 28 90 12 c0       	mov    %eax,0xc0129028

    int pid = kernel_thread(init_main, "Hello world!!", 0);
c0108f4e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108f55:	00 
c0108f56:	c7 44 24 04 a0 bd 10 	movl   $0xc010bda0,0x4(%esp)
c0108f5d:	c0 
c0108f5e:	c7 04 24 16 8e 10 c0 	movl   $0xc0108e16,(%esp)
c0108f65:	e8 40 fb ff ff       	call   c0108aaa <kernel_thread>
c0108f6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid <= 0) {
c0108f6d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0108f71:	7f 1c                	jg     c0108f8f <proc_init+0x122>
        panic("create init_main failed.\n");
c0108f73:	c7 44 24 08 ae bd 10 	movl   $0xc010bdae,0x8(%esp)
c0108f7a:	c0 
c0108f7b:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
c0108f82:	00 
c0108f83:	c7 04 24 0d bd 10 c0 	movl   $0xc010bd0d,(%esp)
c0108f8a:	e8 71 74 ff ff       	call   c0100400 <__panic>
    }

    initproc = find_proc(pid);
c0108f8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108f92:	89 04 24             	mov    %eax,(%esp)
c0108f95:	e8 9e fa ff ff       	call   c0108a38 <find_proc>
c0108f9a:	a3 24 90 12 c0       	mov    %eax,0xc0129024
    set_proc_name(initproc, "init");
c0108f9f:	a1 24 90 12 c0       	mov    0xc0129024,%eax
c0108fa4:	c7 44 24 04 c8 bd 10 	movl   $0xc010bdc8,0x4(%esp)
c0108fab:	c0 
c0108fac:	89 04 24             	mov    %eax,(%esp)
c0108faf:	e8 ff f7 ff ff       	call   c01087b3 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c0108fb4:	a1 20 90 12 c0       	mov    0xc0129020,%eax
c0108fb9:	85 c0                	test   %eax,%eax
c0108fbb:	74 0c                	je     c0108fc9 <proc_init+0x15c>
c0108fbd:	a1 20 90 12 c0       	mov    0xc0129020,%eax
c0108fc2:	8b 40 04             	mov    0x4(%eax),%eax
c0108fc5:	85 c0                	test   %eax,%eax
c0108fc7:	74 24                	je     c0108fed <proc_init+0x180>
c0108fc9:	c7 44 24 0c d0 bd 10 	movl   $0xc010bdd0,0xc(%esp)
c0108fd0:	c0 
c0108fd1:	c7 44 24 08 f8 bc 10 	movl   $0xc010bcf8,0x8(%esp)
c0108fd8:	c0 
c0108fd9:	c7 44 24 04 89 01 00 	movl   $0x189,0x4(%esp)
c0108fe0:	00 
c0108fe1:	c7 04 24 0d bd 10 c0 	movl   $0xc010bd0d,(%esp)
c0108fe8:	e8 13 74 ff ff       	call   c0100400 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c0108fed:	a1 24 90 12 c0       	mov    0xc0129024,%eax
c0108ff2:	85 c0                	test   %eax,%eax
c0108ff4:	74 0d                	je     c0109003 <proc_init+0x196>
c0108ff6:	a1 24 90 12 c0       	mov    0xc0129024,%eax
c0108ffb:	8b 40 04             	mov    0x4(%eax),%eax
c0108ffe:	83 f8 01             	cmp    $0x1,%eax
c0109001:	74 24                	je     c0109027 <proc_init+0x1ba>
c0109003:	c7 44 24 0c f8 bd 10 	movl   $0xc010bdf8,0xc(%esp)
c010900a:	c0 
c010900b:	c7 44 24 08 f8 bc 10 	movl   $0xc010bcf8,0x8(%esp)
c0109012:	c0 
c0109013:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
c010901a:	00 
c010901b:	c7 04 24 0d bd 10 c0 	movl   $0xc010bd0d,(%esp)
c0109022:	e8 d9 73 ff ff       	call   c0100400 <__panic>
}
c0109027:	90                   	nop
c0109028:	c9                   	leave  
c0109029:	c3                   	ret    

c010902a <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c010902a:	55                   	push   %ebp
c010902b:	89 e5                	mov    %esp,%ebp
c010902d:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c0109030:	a1 28 90 12 c0       	mov    0xc0129028,%eax
c0109035:	8b 40 10             	mov    0x10(%eax),%eax
c0109038:	85 c0                	test   %eax,%eax
c010903a:	74 f4                	je     c0109030 <cpu_idle+0x6>
            schedule();
c010903c:	e8 8a 00 00 00       	call   c01090cb <schedule>
        }
    }
c0109041:	eb ed                	jmp    c0109030 <cpu_idle+0x6>

c0109043 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0109043:	55                   	push   %ebp
c0109044:	89 e5                	mov    %esp,%ebp
c0109046:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0109049:	9c                   	pushf  
c010904a:	58                   	pop    %eax
c010904b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010904e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0109051:	25 00 02 00 00       	and    $0x200,%eax
c0109056:	85 c0                	test   %eax,%eax
c0109058:	74 0c                	je     c0109066 <__intr_save+0x23>
        intr_disable();
c010905a:	e8 9a 90 ff ff       	call   c01020f9 <intr_disable>
        return 1;
c010905f:	b8 01 00 00 00       	mov    $0x1,%eax
c0109064:	eb 05                	jmp    c010906b <__intr_save+0x28>
    }
    return 0;
c0109066:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010906b:	c9                   	leave  
c010906c:	c3                   	ret    

c010906d <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010906d:	55                   	push   %ebp
c010906e:	89 e5                	mov    %esp,%ebp
c0109070:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0109073:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109077:	74 05                	je     c010907e <__intr_restore+0x11>
        intr_enable();
c0109079:	e8 74 90 ff ff       	call   c01020f2 <intr_enable>
    }
}
c010907e:	90                   	nop
c010907f:	c9                   	leave  
c0109080:	c3                   	ret    

c0109081 <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c0109081:	55                   	push   %ebp
c0109082:	89 e5                	mov    %esp,%ebp
c0109084:	83 ec 18             	sub    $0x18,%esp
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
c0109087:	8b 45 08             	mov    0x8(%ebp),%eax
c010908a:	8b 00                	mov    (%eax),%eax
c010908c:	83 f8 03             	cmp    $0x3,%eax
c010908f:	74 0a                	je     c010909b <wakeup_proc+0x1a>
c0109091:	8b 45 08             	mov    0x8(%ebp),%eax
c0109094:	8b 00                	mov    (%eax),%eax
c0109096:	83 f8 02             	cmp    $0x2,%eax
c0109099:	75 24                	jne    c01090bf <wakeup_proc+0x3e>
c010909b:	c7 44 24 0c 20 be 10 	movl   $0xc010be20,0xc(%esp)
c01090a2:	c0 
c01090a3:	c7 44 24 08 5b be 10 	movl   $0xc010be5b,0x8(%esp)
c01090aa:	c0 
c01090ab:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
c01090b2:	00 
c01090b3:	c7 04 24 70 be 10 c0 	movl   $0xc010be70,(%esp)
c01090ba:	e8 41 73 ff ff       	call   c0100400 <__panic>
    proc->state = PROC_RUNNABLE;
c01090bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01090c2:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
}
c01090c8:	90                   	nop
c01090c9:	c9                   	leave  
c01090ca:	c3                   	ret    

c01090cb <schedule>:

void
schedule(void) {
c01090cb:	55                   	push   %ebp
c01090cc:	89 e5                	mov    %esp,%ebp
c01090ce:	83 ec 38             	sub    $0x38,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c01090d1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c01090d8:	e8 66 ff ff ff       	call   c0109043 <__intr_save>
c01090dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c01090e0:	a1 28 90 12 c0       	mov    0xc0129028,%eax
c01090e5:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c01090ec:	8b 15 28 90 12 c0    	mov    0xc0129028,%edx
c01090f2:	a1 20 90 12 c0       	mov    0xc0129020,%eax
c01090f7:	39 c2                	cmp    %eax,%edx
c01090f9:	74 0a                	je     c0109105 <schedule+0x3a>
c01090fb:	a1 28 90 12 c0       	mov    0xc0129028,%eax
c0109100:	83 c0 58             	add    $0x58,%eax
c0109103:	eb 05                	jmp    c010910a <schedule+0x3f>
c0109105:	b8 44 b1 12 c0       	mov    $0xc012b144,%eax
c010910a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c010910d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109110:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109113:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109116:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0109119:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010911c:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c010911f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109122:	81 7d f4 44 b1 12 c0 	cmpl   $0xc012b144,-0xc(%ebp)
c0109129:	74 13                	je     c010913e <schedule+0x73>
                next = le2proc(le, list_link);
c010912b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010912e:	83 e8 58             	sub    $0x58,%eax
c0109131:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c0109134:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109137:	8b 00                	mov    (%eax),%eax
c0109139:	83 f8 02             	cmp    $0x2,%eax
c010913c:	74 0a                	je     c0109148 <schedule+0x7d>
                    break;
                }
            }
        } while (le != last);
c010913e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109141:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0109144:	75 cd                	jne    c0109113 <schedule+0x48>
c0109146:	eb 01                	jmp    c0109149 <schedule+0x7e>
        le = last;
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
                    break;
c0109148:	90                   	nop
                }
            }
        } while (le != last);
        if (next == NULL || next->state != PROC_RUNNABLE) {
c0109149:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010914d:	74 0a                	je     c0109159 <schedule+0x8e>
c010914f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109152:	8b 00                	mov    (%eax),%eax
c0109154:	83 f8 02             	cmp    $0x2,%eax
c0109157:	74 08                	je     c0109161 <schedule+0x96>
            next = idleproc;
c0109159:	a1 20 90 12 c0       	mov    0xc0129020,%eax
c010915e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c0109161:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109164:	8b 40 08             	mov    0x8(%eax),%eax
c0109167:	8d 50 01             	lea    0x1(%eax),%edx
c010916a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010916d:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c0109170:	a1 28 90 12 c0       	mov    0xc0129028,%eax
c0109175:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109178:	74 0b                	je     c0109185 <schedule+0xba>
            proc_run(next);
c010917a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010917d:	89 04 24             	mov    %eax,(%esp)
c0109180:	e8 a7 f7 ff ff       	call   c010892c <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c0109185:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109188:	89 04 24             	mov    %eax,(%esp)
c010918b:	e8 dd fe ff ff       	call   c010906d <__intr_restore>
}
c0109190:	90                   	nop
c0109191:	c9                   	leave  
c0109192:	c3                   	ret    

c0109193 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0109193:	55                   	push   %ebp
c0109194:	89 e5                	mov    %esp,%ebp
c0109196:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0109199:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c01091a0:	eb 03                	jmp    c01091a5 <strlen+0x12>
        cnt ++;
c01091a2:	ff 45 fc             	incl   -0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c01091a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01091a8:	8d 50 01             	lea    0x1(%eax),%edx
c01091ab:	89 55 08             	mov    %edx,0x8(%ebp)
c01091ae:	0f b6 00             	movzbl (%eax),%eax
c01091b1:	84 c0                	test   %al,%al
c01091b3:	75 ed                	jne    c01091a2 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c01091b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01091b8:	c9                   	leave  
c01091b9:	c3                   	ret    

c01091ba <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c01091ba:	55                   	push   %ebp
c01091bb:	89 e5                	mov    %esp,%ebp
c01091bd:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01091c0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c01091c7:	eb 03                	jmp    c01091cc <strnlen+0x12>
        cnt ++;
c01091c9:	ff 45 fc             	incl   -0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c01091cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01091cf:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01091d2:	73 10                	jae    c01091e4 <strnlen+0x2a>
c01091d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01091d7:	8d 50 01             	lea    0x1(%eax),%edx
c01091da:	89 55 08             	mov    %edx,0x8(%ebp)
c01091dd:	0f b6 00             	movzbl (%eax),%eax
c01091e0:	84 c0                	test   %al,%al
c01091e2:	75 e5                	jne    c01091c9 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c01091e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01091e7:	c9                   	leave  
c01091e8:	c3                   	ret    

c01091e9 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c01091e9:	55                   	push   %ebp
c01091ea:	89 e5                	mov    %esp,%ebp
c01091ec:	57                   	push   %edi
c01091ed:	56                   	push   %esi
c01091ee:	83 ec 20             	sub    $0x20,%esp
c01091f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01091f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01091f7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01091fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c01091fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109200:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109203:	89 d1                	mov    %edx,%ecx
c0109205:	89 c2                	mov    %eax,%edx
c0109207:	89 ce                	mov    %ecx,%esi
c0109209:	89 d7                	mov    %edx,%edi
c010920b:	ac                   	lods   %ds:(%esi),%al
c010920c:	aa                   	stos   %al,%es:(%edi)
c010920d:	84 c0                	test   %al,%al
c010920f:	75 fa                	jne    c010920b <strcpy+0x22>
c0109211:	89 fa                	mov    %edi,%edx
c0109213:	89 f1                	mov    %esi,%ecx
c0109215:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0109218:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010921b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010921e:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c0109221:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0109222:	83 c4 20             	add    $0x20,%esp
c0109225:	5e                   	pop    %esi
c0109226:	5f                   	pop    %edi
c0109227:	5d                   	pop    %ebp
c0109228:	c3                   	ret    

c0109229 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0109229:	55                   	push   %ebp
c010922a:	89 e5                	mov    %esp,%ebp
c010922c:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010922f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109232:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0109235:	eb 1e                	jmp    c0109255 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0109237:	8b 45 0c             	mov    0xc(%ebp),%eax
c010923a:	0f b6 10             	movzbl (%eax),%edx
c010923d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109240:	88 10                	mov    %dl,(%eax)
c0109242:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109245:	0f b6 00             	movzbl (%eax),%eax
c0109248:	84 c0                	test   %al,%al
c010924a:	74 03                	je     c010924f <strncpy+0x26>
            src ++;
c010924c:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c010924f:	ff 45 fc             	incl   -0x4(%ebp)
c0109252:	ff 4d 10             	decl   0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0109255:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109259:	75 dc                	jne    c0109237 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c010925b:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010925e:	c9                   	leave  
c010925f:	c3                   	ret    

c0109260 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0109260:	55                   	push   %ebp
c0109261:	89 e5                	mov    %esp,%ebp
c0109263:	57                   	push   %edi
c0109264:	56                   	push   %esi
c0109265:	83 ec 20             	sub    $0x20,%esp
c0109268:	8b 45 08             	mov    0x8(%ebp),%eax
c010926b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010926e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109271:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0109274:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109277:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010927a:	89 d1                	mov    %edx,%ecx
c010927c:	89 c2                	mov    %eax,%edx
c010927e:	89 ce                	mov    %ecx,%esi
c0109280:	89 d7                	mov    %edx,%edi
c0109282:	ac                   	lods   %ds:(%esi),%al
c0109283:	ae                   	scas   %es:(%edi),%al
c0109284:	75 08                	jne    c010928e <strcmp+0x2e>
c0109286:	84 c0                	test   %al,%al
c0109288:	75 f8                	jne    c0109282 <strcmp+0x22>
c010928a:	31 c0                	xor    %eax,%eax
c010928c:	eb 04                	jmp    c0109292 <strcmp+0x32>
c010928e:	19 c0                	sbb    %eax,%eax
c0109290:	0c 01                	or     $0x1,%al
c0109292:	89 fa                	mov    %edi,%edx
c0109294:	89 f1                	mov    %esi,%ecx
c0109296:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109299:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010929c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c010929f:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c01092a2:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01092a3:	83 c4 20             	add    $0x20,%esp
c01092a6:	5e                   	pop    %esi
c01092a7:	5f                   	pop    %edi
c01092a8:	5d                   	pop    %ebp
c01092a9:	c3                   	ret    

c01092aa <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01092aa:	55                   	push   %ebp
c01092ab:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01092ad:	eb 09                	jmp    c01092b8 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c01092af:	ff 4d 10             	decl   0x10(%ebp)
c01092b2:	ff 45 08             	incl   0x8(%ebp)
c01092b5:	ff 45 0c             	incl   0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01092b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01092bc:	74 1a                	je     c01092d8 <strncmp+0x2e>
c01092be:	8b 45 08             	mov    0x8(%ebp),%eax
c01092c1:	0f b6 00             	movzbl (%eax),%eax
c01092c4:	84 c0                	test   %al,%al
c01092c6:	74 10                	je     c01092d8 <strncmp+0x2e>
c01092c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01092cb:	0f b6 10             	movzbl (%eax),%edx
c01092ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01092d1:	0f b6 00             	movzbl (%eax),%eax
c01092d4:	38 c2                	cmp    %al,%dl
c01092d6:	74 d7                	je     c01092af <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c01092d8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01092dc:	74 18                	je     c01092f6 <strncmp+0x4c>
c01092de:	8b 45 08             	mov    0x8(%ebp),%eax
c01092e1:	0f b6 00             	movzbl (%eax),%eax
c01092e4:	0f b6 d0             	movzbl %al,%edx
c01092e7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01092ea:	0f b6 00             	movzbl (%eax),%eax
c01092ed:	0f b6 c0             	movzbl %al,%eax
c01092f0:	29 c2                	sub    %eax,%edx
c01092f2:	89 d0                	mov    %edx,%eax
c01092f4:	eb 05                	jmp    c01092fb <strncmp+0x51>
c01092f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01092fb:	5d                   	pop    %ebp
c01092fc:	c3                   	ret    

c01092fd <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c01092fd:	55                   	push   %ebp
c01092fe:	89 e5                	mov    %esp,%ebp
c0109300:	83 ec 04             	sub    $0x4,%esp
c0109303:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109306:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0109309:	eb 13                	jmp    c010931e <strchr+0x21>
        if (*s == c) {
c010930b:	8b 45 08             	mov    0x8(%ebp),%eax
c010930e:	0f b6 00             	movzbl (%eax),%eax
c0109311:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0109314:	75 05                	jne    c010931b <strchr+0x1e>
            return (char *)s;
c0109316:	8b 45 08             	mov    0x8(%ebp),%eax
c0109319:	eb 12                	jmp    c010932d <strchr+0x30>
        }
        s ++;
c010931b:	ff 45 08             	incl   0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c010931e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109321:	0f b6 00             	movzbl (%eax),%eax
c0109324:	84 c0                	test   %al,%al
c0109326:	75 e3                	jne    c010930b <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0109328:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010932d:	c9                   	leave  
c010932e:	c3                   	ret    

c010932f <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010932f:	55                   	push   %ebp
c0109330:	89 e5                	mov    %esp,%ebp
c0109332:	83 ec 04             	sub    $0x4,%esp
c0109335:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109338:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010933b:	eb 0e                	jmp    c010934b <strfind+0x1c>
        if (*s == c) {
c010933d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109340:	0f b6 00             	movzbl (%eax),%eax
c0109343:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0109346:	74 0f                	je     c0109357 <strfind+0x28>
            break;
        }
        s ++;
c0109348:	ff 45 08             	incl   0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c010934b:	8b 45 08             	mov    0x8(%ebp),%eax
c010934e:	0f b6 00             	movzbl (%eax),%eax
c0109351:	84 c0                	test   %al,%al
c0109353:	75 e8                	jne    c010933d <strfind+0xe>
c0109355:	eb 01                	jmp    c0109358 <strfind+0x29>
        if (*s == c) {
            break;
c0109357:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
c0109358:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010935b:	c9                   	leave  
c010935c:	c3                   	ret    

c010935d <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010935d:	55                   	push   %ebp
c010935e:	89 e5                	mov    %esp,%ebp
c0109360:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0109363:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010936a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0109371:	eb 03                	jmp    c0109376 <strtol+0x19>
        s ++;
c0109373:	ff 45 08             	incl   0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0109376:	8b 45 08             	mov    0x8(%ebp),%eax
c0109379:	0f b6 00             	movzbl (%eax),%eax
c010937c:	3c 20                	cmp    $0x20,%al
c010937e:	74 f3                	je     c0109373 <strtol+0x16>
c0109380:	8b 45 08             	mov    0x8(%ebp),%eax
c0109383:	0f b6 00             	movzbl (%eax),%eax
c0109386:	3c 09                	cmp    $0x9,%al
c0109388:	74 e9                	je     c0109373 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c010938a:	8b 45 08             	mov    0x8(%ebp),%eax
c010938d:	0f b6 00             	movzbl (%eax),%eax
c0109390:	3c 2b                	cmp    $0x2b,%al
c0109392:	75 05                	jne    c0109399 <strtol+0x3c>
        s ++;
c0109394:	ff 45 08             	incl   0x8(%ebp)
c0109397:	eb 14                	jmp    c01093ad <strtol+0x50>
    }
    else if (*s == '-') {
c0109399:	8b 45 08             	mov    0x8(%ebp),%eax
c010939c:	0f b6 00             	movzbl (%eax),%eax
c010939f:	3c 2d                	cmp    $0x2d,%al
c01093a1:	75 0a                	jne    c01093ad <strtol+0x50>
        s ++, neg = 1;
c01093a3:	ff 45 08             	incl   0x8(%ebp)
c01093a6:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c01093ad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01093b1:	74 06                	je     c01093b9 <strtol+0x5c>
c01093b3:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c01093b7:	75 22                	jne    c01093db <strtol+0x7e>
c01093b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01093bc:	0f b6 00             	movzbl (%eax),%eax
c01093bf:	3c 30                	cmp    $0x30,%al
c01093c1:	75 18                	jne    c01093db <strtol+0x7e>
c01093c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01093c6:	40                   	inc    %eax
c01093c7:	0f b6 00             	movzbl (%eax),%eax
c01093ca:	3c 78                	cmp    $0x78,%al
c01093cc:	75 0d                	jne    c01093db <strtol+0x7e>
        s += 2, base = 16;
c01093ce:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c01093d2:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c01093d9:	eb 29                	jmp    c0109404 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c01093db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01093df:	75 16                	jne    c01093f7 <strtol+0x9a>
c01093e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01093e4:	0f b6 00             	movzbl (%eax),%eax
c01093e7:	3c 30                	cmp    $0x30,%al
c01093e9:	75 0c                	jne    c01093f7 <strtol+0x9a>
        s ++, base = 8;
c01093eb:	ff 45 08             	incl   0x8(%ebp)
c01093ee:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c01093f5:	eb 0d                	jmp    c0109404 <strtol+0xa7>
    }
    else if (base == 0) {
c01093f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01093fb:	75 07                	jne    c0109404 <strtol+0xa7>
        base = 10;
c01093fd:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0109404:	8b 45 08             	mov    0x8(%ebp),%eax
c0109407:	0f b6 00             	movzbl (%eax),%eax
c010940a:	3c 2f                	cmp    $0x2f,%al
c010940c:	7e 1b                	jle    c0109429 <strtol+0xcc>
c010940e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109411:	0f b6 00             	movzbl (%eax),%eax
c0109414:	3c 39                	cmp    $0x39,%al
c0109416:	7f 11                	jg     c0109429 <strtol+0xcc>
            dig = *s - '0';
c0109418:	8b 45 08             	mov    0x8(%ebp),%eax
c010941b:	0f b6 00             	movzbl (%eax),%eax
c010941e:	0f be c0             	movsbl %al,%eax
c0109421:	83 e8 30             	sub    $0x30,%eax
c0109424:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109427:	eb 48                	jmp    c0109471 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0109429:	8b 45 08             	mov    0x8(%ebp),%eax
c010942c:	0f b6 00             	movzbl (%eax),%eax
c010942f:	3c 60                	cmp    $0x60,%al
c0109431:	7e 1b                	jle    c010944e <strtol+0xf1>
c0109433:	8b 45 08             	mov    0x8(%ebp),%eax
c0109436:	0f b6 00             	movzbl (%eax),%eax
c0109439:	3c 7a                	cmp    $0x7a,%al
c010943b:	7f 11                	jg     c010944e <strtol+0xf1>
            dig = *s - 'a' + 10;
c010943d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109440:	0f b6 00             	movzbl (%eax),%eax
c0109443:	0f be c0             	movsbl %al,%eax
c0109446:	83 e8 57             	sub    $0x57,%eax
c0109449:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010944c:	eb 23                	jmp    c0109471 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010944e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109451:	0f b6 00             	movzbl (%eax),%eax
c0109454:	3c 40                	cmp    $0x40,%al
c0109456:	7e 3b                	jle    c0109493 <strtol+0x136>
c0109458:	8b 45 08             	mov    0x8(%ebp),%eax
c010945b:	0f b6 00             	movzbl (%eax),%eax
c010945e:	3c 5a                	cmp    $0x5a,%al
c0109460:	7f 31                	jg     c0109493 <strtol+0x136>
            dig = *s - 'A' + 10;
c0109462:	8b 45 08             	mov    0x8(%ebp),%eax
c0109465:	0f b6 00             	movzbl (%eax),%eax
c0109468:	0f be c0             	movsbl %al,%eax
c010946b:	83 e8 37             	sub    $0x37,%eax
c010946e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0109471:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109474:	3b 45 10             	cmp    0x10(%ebp),%eax
c0109477:	7d 19                	jge    c0109492 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0109479:	ff 45 08             	incl   0x8(%ebp)
c010947c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010947f:	0f af 45 10          	imul   0x10(%ebp),%eax
c0109483:	89 c2                	mov    %eax,%edx
c0109485:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109488:	01 d0                	add    %edx,%eax
c010948a:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c010948d:	e9 72 ff ff ff       	jmp    c0109404 <strtol+0xa7>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
c0109492:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
c0109493:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0109497:	74 08                	je     c01094a1 <strtol+0x144>
        *endptr = (char *) s;
c0109499:	8b 45 0c             	mov    0xc(%ebp),%eax
c010949c:	8b 55 08             	mov    0x8(%ebp),%edx
c010949f:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c01094a1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01094a5:	74 07                	je     c01094ae <strtol+0x151>
c01094a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01094aa:	f7 d8                	neg    %eax
c01094ac:	eb 03                	jmp    c01094b1 <strtol+0x154>
c01094ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c01094b1:	c9                   	leave  
c01094b2:	c3                   	ret    

c01094b3 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c01094b3:	55                   	push   %ebp
c01094b4:	89 e5                	mov    %esp,%ebp
c01094b6:	57                   	push   %edi
c01094b7:	83 ec 24             	sub    $0x24,%esp
c01094ba:	8b 45 0c             	mov    0xc(%ebp),%eax
c01094bd:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c01094c0:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c01094c4:	8b 55 08             	mov    0x8(%ebp),%edx
c01094c7:	89 55 f8             	mov    %edx,-0x8(%ebp)
c01094ca:	88 45 f7             	mov    %al,-0x9(%ebp)
c01094cd:	8b 45 10             	mov    0x10(%ebp),%eax
c01094d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c01094d3:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c01094d6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c01094da:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01094dd:	89 d7                	mov    %edx,%edi
c01094df:	f3 aa                	rep stos %al,%es:(%edi)
c01094e1:	89 fa                	mov    %edi,%edx
c01094e3:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01094e6:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c01094e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01094ec:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c01094ed:	83 c4 24             	add    $0x24,%esp
c01094f0:	5f                   	pop    %edi
c01094f1:	5d                   	pop    %ebp
c01094f2:	c3                   	ret    

c01094f3 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c01094f3:	55                   	push   %ebp
c01094f4:	89 e5                	mov    %esp,%ebp
c01094f6:	57                   	push   %edi
c01094f7:	56                   	push   %esi
c01094f8:	53                   	push   %ebx
c01094f9:	83 ec 30             	sub    $0x30,%esp
c01094fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01094ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109502:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109505:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109508:	8b 45 10             	mov    0x10(%ebp),%eax
c010950b:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010950e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109511:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0109514:	73 42                	jae    c0109558 <memmove+0x65>
c0109516:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010951c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010951f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109522:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109525:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0109528:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010952b:	c1 e8 02             	shr    $0x2,%eax
c010952e:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0109530:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109533:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109536:	89 d7                	mov    %edx,%edi
c0109538:	89 c6                	mov    %eax,%esi
c010953a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010953c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010953f:	83 e1 03             	and    $0x3,%ecx
c0109542:	74 02                	je     c0109546 <memmove+0x53>
c0109544:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0109546:	89 f0                	mov    %esi,%eax
c0109548:	89 fa                	mov    %edi,%edx
c010954a:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010954d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0109550:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0109553:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c0109556:	eb 36                	jmp    c010958e <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0109558:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010955b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010955e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109561:	01 c2                	add    %eax,%edx
c0109563:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109566:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0109569:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010956c:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c010956f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109572:	89 c1                	mov    %eax,%ecx
c0109574:	89 d8                	mov    %ebx,%eax
c0109576:	89 d6                	mov    %edx,%esi
c0109578:	89 c7                	mov    %eax,%edi
c010957a:	fd                   	std    
c010957b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010957d:	fc                   	cld    
c010957e:	89 f8                	mov    %edi,%eax
c0109580:	89 f2                	mov    %esi,%edx
c0109582:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0109585:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0109588:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c010958b:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010958e:	83 c4 30             	add    $0x30,%esp
c0109591:	5b                   	pop    %ebx
c0109592:	5e                   	pop    %esi
c0109593:	5f                   	pop    %edi
c0109594:	5d                   	pop    %ebp
c0109595:	c3                   	ret    

c0109596 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0109596:	55                   	push   %ebp
c0109597:	89 e5                	mov    %esp,%ebp
c0109599:	57                   	push   %edi
c010959a:	56                   	push   %esi
c010959b:	83 ec 20             	sub    $0x20,%esp
c010959e:	8b 45 08             	mov    0x8(%ebp),%eax
c01095a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01095a4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01095a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01095aa:	8b 45 10             	mov    0x10(%ebp),%eax
c01095ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01095b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01095b3:	c1 e8 02             	shr    $0x2,%eax
c01095b6:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c01095b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01095bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01095be:	89 d7                	mov    %edx,%edi
c01095c0:	89 c6                	mov    %eax,%esi
c01095c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01095c4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c01095c7:	83 e1 03             	and    $0x3,%ecx
c01095ca:	74 02                	je     c01095ce <memcpy+0x38>
c01095cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01095ce:	89 f0                	mov    %esi,%eax
c01095d0:	89 fa                	mov    %edi,%edx
c01095d2:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01095d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01095d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c01095db:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c01095de:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c01095df:	83 c4 20             	add    $0x20,%esp
c01095e2:	5e                   	pop    %esi
c01095e3:	5f                   	pop    %edi
c01095e4:	5d                   	pop    %ebp
c01095e5:	c3                   	ret    

c01095e6 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c01095e6:	55                   	push   %ebp
c01095e7:	89 e5                	mov    %esp,%ebp
c01095e9:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c01095ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01095ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c01095f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01095f5:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c01095f8:	eb 2e                	jmp    c0109628 <memcmp+0x42>
        if (*s1 != *s2) {
c01095fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01095fd:	0f b6 10             	movzbl (%eax),%edx
c0109600:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109603:	0f b6 00             	movzbl (%eax),%eax
c0109606:	38 c2                	cmp    %al,%dl
c0109608:	74 18                	je     c0109622 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010960a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010960d:	0f b6 00             	movzbl (%eax),%eax
c0109610:	0f b6 d0             	movzbl %al,%edx
c0109613:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109616:	0f b6 00             	movzbl (%eax),%eax
c0109619:	0f b6 c0             	movzbl %al,%eax
c010961c:	29 c2                	sub    %eax,%edx
c010961e:	89 d0                	mov    %edx,%eax
c0109620:	eb 18                	jmp    c010963a <memcmp+0x54>
        }
        s1 ++, s2 ++;
c0109622:	ff 45 fc             	incl   -0x4(%ebp)
c0109625:	ff 45 f8             	incl   -0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0109628:	8b 45 10             	mov    0x10(%ebp),%eax
c010962b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010962e:	89 55 10             	mov    %edx,0x10(%ebp)
c0109631:	85 c0                	test   %eax,%eax
c0109633:	75 c5                	jne    c01095fa <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0109635:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010963a:	c9                   	leave  
c010963b:	c3                   	ret    

c010963c <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010963c:	55                   	push   %ebp
c010963d:	89 e5                	mov    %esp,%ebp
c010963f:	83 ec 58             	sub    $0x58,%esp
c0109642:	8b 45 10             	mov    0x10(%ebp),%eax
c0109645:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0109648:	8b 45 14             	mov    0x14(%ebp),%eax
c010964b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010964e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0109651:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0109654:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109657:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010965a:	8b 45 18             	mov    0x18(%ebp),%eax
c010965d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109660:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109663:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109666:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109669:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010966c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010966f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109672:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109676:	74 1c                	je     c0109694 <printnum+0x58>
c0109678:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010967b:	ba 00 00 00 00       	mov    $0x0,%edx
c0109680:	f7 75 e4             	divl   -0x1c(%ebp)
c0109683:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109686:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109689:	ba 00 00 00 00       	mov    $0x0,%edx
c010968e:	f7 75 e4             	divl   -0x1c(%ebp)
c0109691:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109694:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109697:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010969a:	f7 75 e4             	divl   -0x1c(%ebp)
c010969d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01096a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01096a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01096a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01096a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01096ac:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01096af:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01096b2:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01096b5:	8b 45 18             	mov    0x18(%ebp),%eax
c01096b8:	ba 00 00 00 00       	mov    $0x0,%edx
c01096bd:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01096c0:	77 56                	ja     c0109718 <printnum+0xdc>
c01096c2:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01096c5:	72 05                	jb     c01096cc <printnum+0x90>
c01096c7:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01096ca:	77 4c                	ja     c0109718 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c01096cc:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01096cf:	8d 50 ff             	lea    -0x1(%eax),%edx
c01096d2:	8b 45 20             	mov    0x20(%ebp),%eax
c01096d5:	89 44 24 18          	mov    %eax,0x18(%esp)
c01096d9:	89 54 24 14          	mov    %edx,0x14(%esp)
c01096dd:	8b 45 18             	mov    0x18(%ebp),%eax
c01096e0:	89 44 24 10          	mov    %eax,0x10(%esp)
c01096e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01096e7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01096ea:	89 44 24 08          	mov    %eax,0x8(%esp)
c01096ee:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01096f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01096f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01096f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01096fc:	89 04 24             	mov    %eax,(%esp)
c01096ff:	e8 38 ff ff ff       	call   c010963c <printnum>
c0109704:	eb 1b                	jmp    c0109721 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0109706:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109709:	89 44 24 04          	mov    %eax,0x4(%esp)
c010970d:	8b 45 20             	mov    0x20(%ebp),%eax
c0109710:	89 04 24             	mov    %eax,(%esp)
c0109713:	8b 45 08             	mov    0x8(%ebp),%eax
c0109716:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c0109718:	ff 4d 1c             	decl   0x1c(%ebp)
c010971b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010971f:	7f e5                	jg     c0109706 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0109721:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109724:	05 08 bf 10 c0       	add    $0xc010bf08,%eax
c0109729:	0f b6 00             	movzbl (%eax),%eax
c010972c:	0f be c0             	movsbl %al,%eax
c010972f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109732:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109736:	89 04 24             	mov    %eax,(%esp)
c0109739:	8b 45 08             	mov    0x8(%ebp),%eax
c010973c:	ff d0                	call   *%eax
}
c010973e:	90                   	nop
c010973f:	c9                   	leave  
c0109740:	c3                   	ret    

c0109741 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0109741:	55                   	push   %ebp
c0109742:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0109744:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0109748:	7e 14                	jle    c010975e <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010974a:	8b 45 08             	mov    0x8(%ebp),%eax
c010974d:	8b 00                	mov    (%eax),%eax
c010974f:	8d 48 08             	lea    0x8(%eax),%ecx
c0109752:	8b 55 08             	mov    0x8(%ebp),%edx
c0109755:	89 0a                	mov    %ecx,(%edx)
c0109757:	8b 50 04             	mov    0x4(%eax),%edx
c010975a:	8b 00                	mov    (%eax),%eax
c010975c:	eb 30                	jmp    c010978e <getuint+0x4d>
    }
    else if (lflag) {
c010975e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0109762:	74 16                	je     c010977a <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0109764:	8b 45 08             	mov    0x8(%ebp),%eax
c0109767:	8b 00                	mov    (%eax),%eax
c0109769:	8d 48 04             	lea    0x4(%eax),%ecx
c010976c:	8b 55 08             	mov    0x8(%ebp),%edx
c010976f:	89 0a                	mov    %ecx,(%edx)
c0109771:	8b 00                	mov    (%eax),%eax
c0109773:	ba 00 00 00 00       	mov    $0x0,%edx
c0109778:	eb 14                	jmp    c010978e <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010977a:	8b 45 08             	mov    0x8(%ebp),%eax
c010977d:	8b 00                	mov    (%eax),%eax
c010977f:	8d 48 04             	lea    0x4(%eax),%ecx
c0109782:	8b 55 08             	mov    0x8(%ebp),%edx
c0109785:	89 0a                	mov    %ecx,(%edx)
c0109787:	8b 00                	mov    (%eax),%eax
c0109789:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010978e:	5d                   	pop    %ebp
c010978f:	c3                   	ret    

c0109790 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0109790:	55                   	push   %ebp
c0109791:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0109793:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0109797:	7e 14                	jle    c01097ad <getint+0x1d>
        return va_arg(*ap, long long);
c0109799:	8b 45 08             	mov    0x8(%ebp),%eax
c010979c:	8b 00                	mov    (%eax),%eax
c010979e:	8d 48 08             	lea    0x8(%eax),%ecx
c01097a1:	8b 55 08             	mov    0x8(%ebp),%edx
c01097a4:	89 0a                	mov    %ecx,(%edx)
c01097a6:	8b 50 04             	mov    0x4(%eax),%edx
c01097a9:	8b 00                	mov    (%eax),%eax
c01097ab:	eb 28                	jmp    c01097d5 <getint+0x45>
    }
    else if (lflag) {
c01097ad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01097b1:	74 12                	je     c01097c5 <getint+0x35>
        return va_arg(*ap, long);
c01097b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01097b6:	8b 00                	mov    (%eax),%eax
c01097b8:	8d 48 04             	lea    0x4(%eax),%ecx
c01097bb:	8b 55 08             	mov    0x8(%ebp),%edx
c01097be:	89 0a                	mov    %ecx,(%edx)
c01097c0:	8b 00                	mov    (%eax),%eax
c01097c2:	99                   	cltd   
c01097c3:	eb 10                	jmp    c01097d5 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c01097c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01097c8:	8b 00                	mov    (%eax),%eax
c01097ca:	8d 48 04             	lea    0x4(%eax),%ecx
c01097cd:	8b 55 08             	mov    0x8(%ebp),%edx
c01097d0:	89 0a                	mov    %ecx,(%edx)
c01097d2:	8b 00                	mov    (%eax),%eax
c01097d4:	99                   	cltd   
    }
}
c01097d5:	5d                   	pop    %ebp
c01097d6:	c3                   	ret    

c01097d7 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01097d7:	55                   	push   %ebp
c01097d8:	89 e5                	mov    %esp,%ebp
c01097da:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c01097dd:	8d 45 14             	lea    0x14(%ebp),%eax
c01097e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c01097e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01097e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01097ea:	8b 45 10             	mov    0x10(%ebp),%eax
c01097ed:	89 44 24 08          	mov    %eax,0x8(%esp)
c01097f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01097f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01097f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01097fb:	89 04 24             	mov    %eax,(%esp)
c01097fe:	e8 03 00 00 00       	call   c0109806 <vprintfmt>
    va_end(ap);
}
c0109803:	90                   	nop
c0109804:	c9                   	leave  
c0109805:	c3                   	ret    

c0109806 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0109806:	55                   	push   %ebp
c0109807:	89 e5                	mov    %esp,%ebp
c0109809:	56                   	push   %esi
c010980a:	53                   	push   %ebx
c010980b:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010980e:	eb 17                	jmp    c0109827 <vprintfmt+0x21>
            if (ch == '\0') {
c0109810:	85 db                	test   %ebx,%ebx
c0109812:	0f 84 bf 03 00 00    	je     c0109bd7 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c0109818:	8b 45 0c             	mov    0xc(%ebp),%eax
c010981b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010981f:	89 1c 24             	mov    %ebx,(%esp)
c0109822:	8b 45 08             	mov    0x8(%ebp),%eax
c0109825:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0109827:	8b 45 10             	mov    0x10(%ebp),%eax
c010982a:	8d 50 01             	lea    0x1(%eax),%edx
c010982d:	89 55 10             	mov    %edx,0x10(%ebp)
c0109830:	0f b6 00             	movzbl (%eax),%eax
c0109833:	0f b6 d8             	movzbl %al,%ebx
c0109836:	83 fb 25             	cmp    $0x25,%ebx
c0109839:	75 d5                	jne    c0109810 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c010983b:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010983f:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0109846:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109849:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010984c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0109853:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109856:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0109859:	8b 45 10             	mov    0x10(%ebp),%eax
c010985c:	8d 50 01             	lea    0x1(%eax),%edx
c010985f:	89 55 10             	mov    %edx,0x10(%ebp)
c0109862:	0f b6 00             	movzbl (%eax),%eax
c0109865:	0f b6 d8             	movzbl %al,%ebx
c0109868:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010986b:	83 f8 55             	cmp    $0x55,%eax
c010986e:	0f 87 37 03 00 00    	ja     c0109bab <vprintfmt+0x3a5>
c0109874:	8b 04 85 2c bf 10 c0 	mov    -0x3fef40d4(,%eax,4),%eax
c010987b:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010987d:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0109881:	eb d6                	jmp    c0109859 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0109883:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0109887:	eb d0                	jmp    c0109859 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0109889:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0109890:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109893:	89 d0                	mov    %edx,%eax
c0109895:	c1 e0 02             	shl    $0x2,%eax
c0109898:	01 d0                	add    %edx,%eax
c010989a:	01 c0                	add    %eax,%eax
c010989c:	01 d8                	add    %ebx,%eax
c010989e:	83 e8 30             	sub    $0x30,%eax
c01098a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01098a4:	8b 45 10             	mov    0x10(%ebp),%eax
c01098a7:	0f b6 00             	movzbl (%eax),%eax
c01098aa:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c01098ad:	83 fb 2f             	cmp    $0x2f,%ebx
c01098b0:	7e 38                	jle    c01098ea <vprintfmt+0xe4>
c01098b2:	83 fb 39             	cmp    $0x39,%ebx
c01098b5:	7f 33                	jg     c01098ea <vprintfmt+0xe4>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01098b7:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c01098ba:	eb d4                	jmp    c0109890 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c01098bc:	8b 45 14             	mov    0x14(%ebp),%eax
c01098bf:	8d 50 04             	lea    0x4(%eax),%edx
c01098c2:	89 55 14             	mov    %edx,0x14(%ebp)
c01098c5:	8b 00                	mov    (%eax),%eax
c01098c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01098ca:	eb 1f                	jmp    c01098eb <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c01098cc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01098d0:	79 87                	jns    c0109859 <vprintfmt+0x53>
                width = 0;
c01098d2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c01098d9:	e9 7b ff ff ff       	jmp    c0109859 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c01098de:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c01098e5:	e9 6f ff ff ff       	jmp    c0109859 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
c01098ea:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
c01098eb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01098ef:	0f 89 64 ff ff ff    	jns    c0109859 <vprintfmt+0x53>
                width = precision, precision = -1;
c01098f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01098f8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01098fb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0109902:	e9 52 ff ff ff       	jmp    c0109859 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0109907:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c010990a:	e9 4a ff ff ff       	jmp    c0109859 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010990f:	8b 45 14             	mov    0x14(%ebp),%eax
c0109912:	8d 50 04             	lea    0x4(%eax),%edx
c0109915:	89 55 14             	mov    %edx,0x14(%ebp)
c0109918:	8b 00                	mov    (%eax),%eax
c010991a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010991d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109921:	89 04 24             	mov    %eax,(%esp)
c0109924:	8b 45 08             	mov    0x8(%ebp),%eax
c0109927:	ff d0                	call   *%eax
            break;
c0109929:	e9 a4 02 00 00       	jmp    c0109bd2 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010992e:	8b 45 14             	mov    0x14(%ebp),%eax
c0109931:	8d 50 04             	lea    0x4(%eax),%edx
c0109934:	89 55 14             	mov    %edx,0x14(%ebp)
c0109937:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0109939:	85 db                	test   %ebx,%ebx
c010993b:	79 02                	jns    c010993f <vprintfmt+0x139>
                err = -err;
c010993d:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010993f:	83 fb 06             	cmp    $0x6,%ebx
c0109942:	7f 0b                	jg     c010994f <vprintfmt+0x149>
c0109944:	8b 34 9d ec be 10 c0 	mov    -0x3fef4114(,%ebx,4),%esi
c010994b:	85 f6                	test   %esi,%esi
c010994d:	75 23                	jne    c0109972 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c010994f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0109953:	c7 44 24 08 19 bf 10 	movl   $0xc010bf19,0x8(%esp)
c010995a:	c0 
c010995b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010995e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109962:	8b 45 08             	mov    0x8(%ebp),%eax
c0109965:	89 04 24             	mov    %eax,(%esp)
c0109968:	e8 6a fe ff ff       	call   c01097d7 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010996d:	e9 60 02 00 00       	jmp    c0109bd2 <vprintfmt+0x3cc>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c0109972:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0109976:	c7 44 24 08 22 bf 10 	movl   $0xc010bf22,0x8(%esp)
c010997d:	c0 
c010997e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109981:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109985:	8b 45 08             	mov    0x8(%ebp),%eax
c0109988:	89 04 24             	mov    %eax,(%esp)
c010998b:	e8 47 fe ff ff       	call   c01097d7 <printfmt>
            }
            break;
c0109990:	e9 3d 02 00 00       	jmp    c0109bd2 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0109995:	8b 45 14             	mov    0x14(%ebp),%eax
c0109998:	8d 50 04             	lea    0x4(%eax),%edx
c010999b:	89 55 14             	mov    %edx,0x14(%ebp)
c010999e:	8b 30                	mov    (%eax),%esi
c01099a0:	85 f6                	test   %esi,%esi
c01099a2:	75 05                	jne    c01099a9 <vprintfmt+0x1a3>
                p = "(null)";
c01099a4:	be 25 bf 10 c0       	mov    $0xc010bf25,%esi
            }
            if (width > 0 && padc != '-') {
c01099a9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01099ad:	7e 76                	jle    c0109a25 <vprintfmt+0x21f>
c01099af:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01099b3:	74 70                	je     c0109a25 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01099b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01099b8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01099bc:	89 34 24             	mov    %esi,(%esp)
c01099bf:	e8 f6 f7 ff ff       	call   c01091ba <strnlen>
c01099c4:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01099c7:	29 c2                	sub    %eax,%edx
c01099c9:	89 d0                	mov    %edx,%eax
c01099cb:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01099ce:	eb 16                	jmp    c01099e6 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c01099d0:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01099d4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01099d7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01099db:	89 04 24             	mov    %eax,(%esp)
c01099de:	8b 45 08             	mov    0x8(%ebp),%eax
c01099e1:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c01099e3:	ff 4d e8             	decl   -0x18(%ebp)
c01099e6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01099ea:	7f e4                	jg     c01099d0 <vprintfmt+0x1ca>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01099ec:	eb 37                	jmp    c0109a25 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c01099ee:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01099f2:	74 1f                	je     c0109a13 <vprintfmt+0x20d>
c01099f4:	83 fb 1f             	cmp    $0x1f,%ebx
c01099f7:	7e 05                	jle    c01099fe <vprintfmt+0x1f8>
c01099f9:	83 fb 7e             	cmp    $0x7e,%ebx
c01099fc:	7e 15                	jle    c0109a13 <vprintfmt+0x20d>
                    putch('?', putdat);
c01099fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a01:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a05:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0109a0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a0f:	ff d0                	call   *%eax
c0109a11:	eb 0f                	jmp    c0109a22 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0109a13:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a16:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a1a:	89 1c 24             	mov    %ebx,(%esp)
c0109a1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a20:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0109a22:	ff 4d e8             	decl   -0x18(%ebp)
c0109a25:	89 f0                	mov    %esi,%eax
c0109a27:	8d 70 01             	lea    0x1(%eax),%esi
c0109a2a:	0f b6 00             	movzbl (%eax),%eax
c0109a2d:	0f be d8             	movsbl %al,%ebx
c0109a30:	85 db                	test   %ebx,%ebx
c0109a32:	74 27                	je     c0109a5b <vprintfmt+0x255>
c0109a34:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0109a38:	78 b4                	js     c01099ee <vprintfmt+0x1e8>
c0109a3a:	ff 4d e4             	decl   -0x1c(%ebp)
c0109a3d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0109a41:	79 ab                	jns    c01099ee <vprintfmt+0x1e8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0109a43:	eb 16                	jmp    c0109a5b <vprintfmt+0x255>
                putch(' ', putdat);
c0109a45:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a4c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0109a53:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a56:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0109a58:	ff 4d e8             	decl   -0x18(%ebp)
c0109a5b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109a5f:	7f e4                	jg     c0109a45 <vprintfmt+0x23f>
                putch(' ', putdat);
            }
            break;
c0109a61:	e9 6c 01 00 00       	jmp    c0109bd2 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0109a66:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109a69:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a6d:	8d 45 14             	lea    0x14(%ebp),%eax
c0109a70:	89 04 24             	mov    %eax,(%esp)
c0109a73:	e8 18 fd ff ff       	call   c0109790 <getint>
c0109a78:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109a7b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0109a7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a81:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109a84:	85 d2                	test   %edx,%edx
c0109a86:	79 26                	jns    c0109aae <vprintfmt+0x2a8>
                putch('-', putdat);
c0109a88:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a8b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109a8f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0109a96:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a99:	ff d0                	call   *%eax
                num = -(long long)num;
c0109a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109aa1:	f7 d8                	neg    %eax
c0109aa3:	83 d2 00             	adc    $0x0,%edx
c0109aa6:	f7 da                	neg    %edx
c0109aa8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109aab:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0109aae:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0109ab5:	e9 a8 00 00 00       	jmp    c0109b62 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0109aba:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109abd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109ac1:	8d 45 14             	lea    0x14(%ebp),%eax
c0109ac4:	89 04 24             	mov    %eax,(%esp)
c0109ac7:	e8 75 fc ff ff       	call   c0109741 <getuint>
c0109acc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109acf:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0109ad2:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0109ad9:	e9 84 00 00 00       	jmp    c0109b62 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0109ade:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109ae5:	8d 45 14             	lea    0x14(%ebp),%eax
c0109ae8:	89 04 24             	mov    %eax,(%esp)
c0109aeb:	e8 51 fc ff ff       	call   c0109741 <getuint>
c0109af0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109af3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0109af6:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0109afd:	eb 63                	jmp    c0109b62 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0109aff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109b02:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109b06:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0109b0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b10:	ff d0                	call   *%eax
            putch('x', putdat);
c0109b12:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109b15:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109b19:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0109b20:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b23:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0109b25:	8b 45 14             	mov    0x14(%ebp),%eax
c0109b28:	8d 50 04             	lea    0x4(%eax),%edx
c0109b2b:	89 55 14             	mov    %edx,0x14(%ebp)
c0109b2e:	8b 00                	mov    (%eax),%eax
c0109b30:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109b33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0109b3a:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0109b41:	eb 1f                	jmp    c0109b62 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0109b43:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109b46:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109b4a:	8d 45 14             	lea    0x14(%ebp),%eax
c0109b4d:	89 04 24             	mov    %eax,(%esp)
c0109b50:	e8 ec fb ff ff       	call   c0109741 <getuint>
c0109b55:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109b58:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0109b5b:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0109b62:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0109b66:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109b69:	89 54 24 18          	mov    %edx,0x18(%esp)
c0109b6d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109b70:	89 54 24 14          	mov    %edx,0x14(%esp)
c0109b74:	89 44 24 10          	mov    %eax,0x10(%esp)
c0109b78:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109b7e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109b82:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0109b86:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109b89:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109b8d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b90:	89 04 24             	mov    %eax,(%esp)
c0109b93:	e8 a4 fa ff ff       	call   c010963c <printnum>
            break;
c0109b98:	eb 38                	jmp    c0109bd2 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0109b9a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109b9d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109ba1:	89 1c 24             	mov    %ebx,(%esp)
c0109ba4:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ba7:	ff d0                	call   *%eax
            break;
c0109ba9:	eb 27                	jmp    c0109bd2 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0109bab:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109bae:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109bb2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0109bb9:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bbc:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0109bbe:	ff 4d 10             	decl   0x10(%ebp)
c0109bc1:	eb 03                	jmp    c0109bc6 <vprintfmt+0x3c0>
c0109bc3:	ff 4d 10             	decl   0x10(%ebp)
c0109bc6:	8b 45 10             	mov    0x10(%ebp),%eax
c0109bc9:	48                   	dec    %eax
c0109bca:	0f b6 00             	movzbl (%eax),%eax
c0109bcd:	3c 25                	cmp    $0x25,%al
c0109bcf:	75 f2                	jne    c0109bc3 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0109bd1:	90                   	nop
        }
    }
c0109bd2:	e9 37 fc ff ff       	jmp    c010980e <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
c0109bd7:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c0109bd8:	83 c4 40             	add    $0x40,%esp
c0109bdb:	5b                   	pop    %ebx
c0109bdc:	5e                   	pop    %esi
c0109bdd:	5d                   	pop    %ebp
c0109bde:	c3                   	ret    

c0109bdf <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0109bdf:	55                   	push   %ebp
c0109be0:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0109be2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109be5:	8b 40 08             	mov    0x8(%eax),%eax
c0109be8:	8d 50 01             	lea    0x1(%eax),%edx
c0109beb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109bee:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0109bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109bf4:	8b 10                	mov    (%eax),%edx
c0109bf6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109bf9:	8b 40 04             	mov    0x4(%eax),%eax
c0109bfc:	39 c2                	cmp    %eax,%edx
c0109bfe:	73 12                	jae    c0109c12 <sprintputch+0x33>
        *b->buf ++ = ch;
c0109c00:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109c03:	8b 00                	mov    (%eax),%eax
c0109c05:	8d 48 01             	lea    0x1(%eax),%ecx
c0109c08:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109c0b:	89 0a                	mov    %ecx,(%edx)
c0109c0d:	8b 55 08             	mov    0x8(%ebp),%edx
c0109c10:	88 10                	mov    %dl,(%eax)
    }
}
c0109c12:	90                   	nop
c0109c13:	5d                   	pop    %ebp
c0109c14:	c3                   	ret    

c0109c15 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0109c15:	55                   	push   %ebp
c0109c16:	89 e5                	mov    %esp,%ebp
c0109c18:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0109c1b:	8d 45 14             	lea    0x14(%ebp),%eax
c0109c1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0109c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109c24:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109c28:	8b 45 10             	mov    0x10(%ebp),%eax
c0109c2b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109c32:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109c36:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c39:	89 04 24             	mov    %eax,(%esp)
c0109c3c:	e8 08 00 00 00       	call   c0109c49 <vsnprintf>
c0109c41:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0109c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109c47:	c9                   	leave  
c0109c48:	c3                   	ret    

c0109c49 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0109c49:	55                   	push   %ebp
c0109c4a:	89 e5                	mov    %esp,%ebp
c0109c4c:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0109c4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c52:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109c55:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109c58:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109c5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c5e:	01 d0                	add    %edx,%eax
c0109c60:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109c63:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0109c6a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109c6e:	74 0a                	je     c0109c7a <vsnprintf+0x31>
c0109c70:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109c73:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109c76:	39 c2                	cmp    %eax,%edx
c0109c78:	76 07                	jbe    c0109c81 <vsnprintf+0x38>
        return -E_INVAL;
c0109c7a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0109c7f:	eb 2a                	jmp    c0109cab <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0109c81:	8b 45 14             	mov    0x14(%ebp),%eax
c0109c84:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109c88:	8b 45 10             	mov    0x10(%ebp),%eax
c0109c8b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109c8f:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0109c92:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109c96:	c7 04 24 df 9b 10 c0 	movl   $0xc0109bdf,(%esp)
c0109c9d:	e8 64 fb ff ff       	call   c0109806 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0109ca2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109ca5:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0109ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109cab:	c9                   	leave  
c0109cac:	c3                   	ret    

c0109cad <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c0109cad:	55                   	push   %ebp
c0109cae:	89 e5                	mov    %esp,%ebp
c0109cb0:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c0109cb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0109cb6:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c0109cbc:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c0109cbf:	b8 20 00 00 00       	mov    $0x20,%eax
c0109cc4:	2b 45 0c             	sub    0xc(%ebp),%eax
c0109cc7:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109cca:	88 c1                	mov    %al,%cl
c0109ccc:	d3 ea                	shr    %cl,%edx
c0109cce:	89 d0                	mov    %edx,%eax
}
c0109cd0:	c9                   	leave  
c0109cd1:	c3                   	ret    

c0109cd2 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c0109cd2:	55                   	push   %ebp
c0109cd3:	89 e5                	mov    %esp,%ebp
c0109cd5:	57                   	push   %edi
c0109cd6:	56                   	push   %esi
c0109cd7:	53                   	push   %ebx
c0109cd8:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c0109cdb:	a1 80 5a 12 c0       	mov    0xc0125a80,%eax
c0109ce0:	8b 15 84 5a 12 c0    	mov    0xc0125a84,%edx
c0109ce6:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c0109cec:	6b f0 05             	imul   $0x5,%eax,%esi
c0109cef:	01 fe                	add    %edi,%esi
c0109cf1:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c0109cf6:	f7 e7                	mul    %edi
c0109cf8:	01 d6                	add    %edx,%esi
c0109cfa:	89 f2                	mov    %esi,%edx
c0109cfc:	83 c0 0b             	add    $0xb,%eax
c0109cff:	83 d2 00             	adc    $0x0,%edx
c0109d02:	89 c7                	mov    %eax,%edi
c0109d04:	83 e7 ff             	and    $0xffffffff,%edi
c0109d07:	89 f9                	mov    %edi,%ecx
c0109d09:	0f b7 da             	movzwl %dx,%ebx
c0109d0c:	89 0d 80 5a 12 c0    	mov    %ecx,0xc0125a80
c0109d12:	89 1d 84 5a 12 c0    	mov    %ebx,0xc0125a84
    unsigned long long result = (next >> 12);
c0109d18:	a1 80 5a 12 c0       	mov    0xc0125a80,%eax
c0109d1d:	8b 15 84 5a 12 c0    	mov    0xc0125a84,%edx
c0109d23:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0109d27:	c1 ea 0c             	shr    $0xc,%edx
c0109d2a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109d2d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c0109d30:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0109d37:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109d3a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109d3d:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0109d40:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109d43:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109d46:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109d49:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0109d4d:	74 1c                	je     c0109d6b <rand+0x99>
c0109d4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109d52:	ba 00 00 00 00       	mov    $0x0,%edx
c0109d57:	f7 75 dc             	divl   -0x24(%ebp)
c0109d5a:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0109d5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109d60:	ba 00 00 00 00       	mov    $0x0,%edx
c0109d65:	f7 75 dc             	divl   -0x24(%ebp)
c0109d68:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109d6b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109d6e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109d71:	f7 75 dc             	divl   -0x24(%ebp)
c0109d74:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0109d77:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0109d7a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109d7d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109d80:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109d83:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109d86:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0109d89:	83 c4 24             	add    $0x24,%esp
c0109d8c:	5b                   	pop    %ebx
c0109d8d:	5e                   	pop    %esi
c0109d8e:	5f                   	pop    %edi
c0109d8f:	5d                   	pop    %ebp
c0109d90:	c3                   	ret    

c0109d91 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c0109d91:	55                   	push   %ebp
c0109d92:	89 e5                	mov    %esp,%ebp
    next = seed;
c0109d94:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d97:	ba 00 00 00 00       	mov    $0x0,%edx
c0109d9c:	a3 80 5a 12 c0       	mov    %eax,0xc0125a80
c0109da1:	89 15 84 5a 12 c0    	mov    %edx,0xc0125a84
}
c0109da7:	90                   	nop
c0109da8:	5d                   	pop    %ebp
c0109da9:	c3                   	ret    
