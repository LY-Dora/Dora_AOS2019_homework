
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_init>:
void kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

void
kern_init(void){
  100000:	55                   	push   %ebp
  100001:	89 e5                	mov    %esp,%ebp
  100003:	83 ec 18             	sub    $0x18,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100006:	ba 80 fd 10 00       	mov    $0x10fd80,%edx
  10000b:	b8 16 ea 10 00       	mov    $0x10ea16,%eax
  100010:	29 c2                	sub    %eax,%edx
  100012:	89 d0                	mov    %edx,%eax
  100014:	83 ec 04             	sub    $0x4,%esp
  100017:	50                   	push   %eax
  100018:	6a 00                	push   $0x0
  10001a:	68 16 ea 10 00       	push   $0x10ea16
  10001f:	e8 95 2d 00 00       	call   102db9 <memset>
  100024:	83 c4 10             	add    $0x10,%esp

    cons_init();                // init the console
  100027:	e8 42 15 00 00       	call   10156e <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  10002c:	c7 45 f4 60 35 10 00 	movl   $0x103560,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100033:	83 ec 08             	sub    $0x8,%esp
  100036:	ff 75 f4             	pushl  -0xc(%ebp)
  100039:	68 7c 35 10 00       	push   $0x10357c
  10003e:	e8 0a 02 00 00       	call   10024d <cprintf>
  100043:	83 c4 10             	add    $0x10,%esp

    print_kerninfo();
  100046:	e8 a1 08 00 00       	call   1008ec <print_kerninfo>

    grade_backtrace();
  10004b:	e8 79 00 00 00       	call   1000c9 <grade_backtrace>

    pmm_init();                 // init physical memory management
  100050:	e8 28 2a 00 00       	call   102a7d <pmm_init>

    pic_init();                 // init interrupt controller
  100055:	e8 57 16 00 00       	call   1016b1 <pic_init>
    idt_init();                 // init interrupt descriptor table
  10005a:	e8 b8 17 00 00       	call   101817 <idt_init>

    clock_init();               // init clock interrupt
  10005f:	e8 ef 0c 00 00       	call   100d53 <clock_init>
    intr_enable();              // enable irq interrupt
  100064:	e8 85 17 00 00       	call   1017ee <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
  100069:	e8 50 01 00 00       	call   1001be <lab1_switch_test>

    /* do nothing */
    while (1);
  10006e:	eb fe                	jmp    10006e <kern_init+0x6e>

00100070 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  100070:	55                   	push   %ebp
  100071:	89 e5                	mov    %esp,%ebp
  100073:	83 ec 08             	sub    $0x8,%esp
    mon_backtrace(0, NULL, NULL);
  100076:	83 ec 04             	sub    $0x4,%esp
  100079:	6a 00                	push   $0x0
  10007b:	6a 00                	push   $0x0
  10007d:	6a 00                	push   $0x0
  10007f:	e8 bd 0c 00 00       	call   100d41 <mon_backtrace>
  100084:	83 c4 10             	add    $0x10,%esp
}
  100087:	90                   	nop
  100088:	c9                   	leave  
  100089:	c3                   	ret    

0010008a <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  10008a:	55                   	push   %ebp
  10008b:	89 e5                	mov    %esp,%ebp
  10008d:	53                   	push   %ebx
  10008e:	83 ec 04             	sub    $0x4,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  100091:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  100094:	8b 55 0c             	mov    0xc(%ebp),%edx
  100097:	8d 5d 08             	lea    0x8(%ebp),%ebx
  10009a:	8b 45 08             	mov    0x8(%ebp),%eax
  10009d:	51                   	push   %ecx
  10009e:	52                   	push   %edx
  10009f:	53                   	push   %ebx
  1000a0:	50                   	push   %eax
  1000a1:	e8 ca ff ff ff       	call   100070 <grade_backtrace2>
  1000a6:	83 c4 10             	add    $0x10,%esp
}
  1000a9:	90                   	nop
  1000aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1000ad:	c9                   	leave  
  1000ae:	c3                   	ret    

001000af <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000af:	55                   	push   %ebp
  1000b0:	89 e5                	mov    %esp,%ebp
  1000b2:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace1(arg0, arg2);
  1000b5:	83 ec 08             	sub    $0x8,%esp
  1000b8:	ff 75 10             	pushl  0x10(%ebp)
  1000bb:	ff 75 08             	pushl  0x8(%ebp)
  1000be:	e8 c7 ff ff ff       	call   10008a <grade_backtrace1>
  1000c3:	83 c4 10             	add    $0x10,%esp
}
  1000c6:	90                   	nop
  1000c7:	c9                   	leave  
  1000c8:	c3                   	ret    

001000c9 <grade_backtrace>:

void
grade_backtrace(void) {
  1000c9:	55                   	push   %ebp
  1000ca:	89 e5                	mov    %esp,%ebp
  1000cc:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  1000cf:	b8 00 00 10 00       	mov    $0x100000,%eax
  1000d4:	83 ec 04             	sub    $0x4,%esp
  1000d7:	68 00 00 ff ff       	push   $0xffff0000
  1000dc:	50                   	push   %eax
  1000dd:	6a 00                	push   $0x0
  1000df:	e8 cb ff ff ff       	call   1000af <grade_backtrace0>
  1000e4:	83 c4 10             	add    $0x10,%esp
}
  1000e7:	90                   	nop
  1000e8:	c9                   	leave  
  1000e9:	c3                   	ret    

001000ea <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  1000ea:	55                   	push   %ebp
  1000eb:	89 e5                	mov    %esp,%ebp
  1000ed:	83 ec 18             	sub    $0x18,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  1000f0:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  1000f3:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  1000f6:	8c 45 f2             	mov    %es,-0xe(%ebp)
  1000f9:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  1000fc:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100100:	0f b7 c0             	movzwl %ax,%eax
  100103:	83 e0 03             	and    $0x3,%eax
  100106:	89 c2                	mov    %eax,%edx
  100108:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  10010d:	83 ec 04             	sub    $0x4,%esp
  100110:	52                   	push   %edx
  100111:	50                   	push   %eax
  100112:	68 81 35 10 00       	push   $0x103581
  100117:	e8 31 01 00 00       	call   10024d <cprintf>
  10011c:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  cs = %x\n", round, reg1);
  10011f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100123:	0f b7 d0             	movzwl %ax,%edx
  100126:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  10012b:	83 ec 04             	sub    $0x4,%esp
  10012e:	52                   	push   %edx
  10012f:	50                   	push   %eax
  100130:	68 8f 35 10 00       	push   $0x10358f
  100135:	e8 13 01 00 00       	call   10024d <cprintf>
  10013a:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ds = %x\n", round, reg2);
  10013d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100141:	0f b7 d0             	movzwl %ax,%edx
  100144:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100149:	83 ec 04             	sub    $0x4,%esp
  10014c:	52                   	push   %edx
  10014d:	50                   	push   %eax
  10014e:	68 9d 35 10 00       	push   $0x10359d
  100153:	e8 f5 00 00 00       	call   10024d <cprintf>
  100158:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  es = %x\n", round, reg3);
  10015b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  10015f:	0f b7 d0             	movzwl %ax,%edx
  100162:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100167:	83 ec 04             	sub    $0x4,%esp
  10016a:	52                   	push   %edx
  10016b:	50                   	push   %eax
  10016c:	68 ab 35 10 00       	push   $0x1035ab
  100171:	e8 d7 00 00 00       	call   10024d <cprintf>
  100176:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ss = %x\n", round, reg4);
  100179:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  10017d:	0f b7 d0             	movzwl %ax,%edx
  100180:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100185:	83 ec 04             	sub    $0x4,%esp
  100188:	52                   	push   %edx
  100189:	50                   	push   %eax
  10018a:	68 b9 35 10 00       	push   $0x1035b9
  10018f:	e8 b9 00 00 00       	call   10024d <cprintf>
  100194:	83 c4 10             	add    $0x10,%esp
    round ++;
  100197:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  10019c:	83 c0 01             	add    $0x1,%eax
  10019f:	a3 20 ea 10 00       	mov    %eax,0x10ea20
}
  1001a4:	90                   	nop
  1001a5:	c9                   	leave  
  1001a6:	c3                   	ret    

001001a7 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001a7:	55                   	push   %ebp
  1001a8:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
	asm volatile (
  1001aa:	83 ec 08             	sub    $0x8,%esp
  1001ad:	cd 78                	int    $0x78
  1001af:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp"
	    : 
	    : "i"(T_SWITCH_TOU)
	);
}
  1001b1:	90                   	nop
  1001b2:	5d                   	pop    %ebp
  1001b3:	c3                   	ret    

001001b4 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001b4:	55                   	push   %ebp
  1001b5:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
	asm volatile (
  1001b7:	cd 79                	int    $0x79
  1001b9:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp \n"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
}
  1001bb:	90                   	nop
  1001bc:	5d                   	pop    %ebp
  1001bd:	c3                   	ret    

001001be <lab1_switch_test>:

static void
lab1_switch_test(void) {
  1001be:	55                   	push   %ebp
  1001bf:	89 e5                	mov    %esp,%ebp
  1001c1:	83 ec 08             	sub    $0x8,%esp
    lab1_print_cur_status();
  1001c4:	e8 21 ff ff ff       	call   1000ea <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  1001c9:	83 ec 0c             	sub    $0xc,%esp
  1001cc:	68 c8 35 10 00       	push   $0x1035c8
  1001d1:	e8 77 00 00 00       	call   10024d <cprintf>
  1001d6:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_user();
  1001d9:	e8 c9 ff ff ff       	call   1001a7 <lab1_switch_to_user>
    lab1_print_cur_status();
  1001de:	e8 07 ff ff ff       	call   1000ea <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  1001e3:	83 ec 0c             	sub    $0xc,%esp
  1001e6:	68 e8 35 10 00       	push   $0x1035e8
  1001eb:	e8 5d 00 00 00       	call   10024d <cprintf>
  1001f0:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_kernel();
  1001f3:	e8 bc ff ff ff       	call   1001b4 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  1001f8:	e8 ed fe ff ff       	call   1000ea <lab1_print_cur_status>
}
  1001fd:	90                   	nop
  1001fe:	c9                   	leave  
  1001ff:	c3                   	ret    

00100200 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  100200:	55                   	push   %ebp
  100201:	89 e5                	mov    %esp,%ebp
  100203:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
  100206:	83 ec 0c             	sub    $0xc,%esp
  100209:	ff 75 08             	pushl  0x8(%ebp)
  10020c:	e8 8e 13 00 00       	call   10159f <cons_putc>
  100211:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
  100214:	8b 45 0c             	mov    0xc(%ebp),%eax
  100217:	8b 00                	mov    (%eax),%eax
  100219:	8d 50 01             	lea    0x1(%eax),%edx
  10021c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10021f:	89 10                	mov    %edx,(%eax)
}
  100221:	90                   	nop
  100222:	c9                   	leave  
  100223:	c3                   	ret    

00100224 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100224:	55                   	push   %ebp
  100225:	89 e5                	mov    %esp,%ebp
  100227:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
  10022a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100231:	ff 75 0c             	pushl  0xc(%ebp)
  100234:	ff 75 08             	pushl  0x8(%ebp)
  100237:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10023a:	50                   	push   %eax
  10023b:	68 00 02 10 00       	push   $0x100200
  100240:	e8 aa 2e 00 00       	call   1030ef <vprintfmt>
  100245:	83 c4 10             	add    $0x10,%esp
    return cnt;
  100248:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10024b:	c9                   	leave  
  10024c:	c3                   	ret    

0010024d <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  10024d:	55                   	push   %ebp
  10024e:	89 e5                	mov    %esp,%ebp
  100250:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100253:	8d 45 0c             	lea    0xc(%ebp),%eax
  100256:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100259:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10025c:	83 ec 08             	sub    $0x8,%esp
  10025f:	50                   	push   %eax
  100260:	ff 75 08             	pushl  0x8(%ebp)
  100263:	e8 bc ff ff ff       	call   100224 <vcprintf>
  100268:	83 c4 10             	add    $0x10,%esp
  10026b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  10026e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100271:	c9                   	leave  
  100272:	c3                   	ret    

00100273 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  100273:	55                   	push   %ebp
  100274:	89 e5                	mov    %esp,%ebp
  100276:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
  100279:	83 ec 0c             	sub    $0xc,%esp
  10027c:	ff 75 08             	pushl  0x8(%ebp)
  10027f:	e8 1b 13 00 00       	call   10159f <cons_putc>
  100284:	83 c4 10             	add    $0x10,%esp
}
  100287:	90                   	nop
  100288:	c9                   	leave  
  100289:	c3                   	ret    

0010028a <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  10028a:	55                   	push   %ebp
  10028b:	89 e5                	mov    %esp,%ebp
  10028d:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
  100290:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  100297:	eb 14                	jmp    1002ad <cputs+0x23>
        cputch(c, &cnt);
  100299:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  10029d:	83 ec 08             	sub    $0x8,%esp
  1002a0:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002a3:	52                   	push   %edx
  1002a4:	50                   	push   %eax
  1002a5:	e8 56 ff ff ff       	call   100200 <cputch>
  1002aa:	83 c4 10             	add    $0x10,%esp
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  1002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1002b0:	8d 50 01             	lea    0x1(%eax),%edx
  1002b3:	89 55 08             	mov    %edx,0x8(%ebp)
  1002b6:	0f b6 00             	movzbl (%eax),%eax
  1002b9:	88 45 f7             	mov    %al,-0x9(%ebp)
  1002bc:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1002c0:	75 d7                	jne    100299 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  1002c2:	83 ec 08             	sub    $0x8,%esp
  1002c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1002c8:	50                   	push   %eax
  1002c9:	6a 0a                	push   $0xa
  1002cb:	e8 30 ff ff ff       	call   100200 <cputch>
  1002d0:	83 c4 10             	add    $0x10,%esp
    return cnt;
  1002d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1002d6:	c9                   	leave  
  1002d7:	c3                   	ret    

001002d8 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1002d8:	55                   	push   %ebp
  1002d9:	89 e5                	mov    %esp,%ebp
  1002db:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1002de:	e8 ec 12 00 00       	call   1015cf <cons_getc>
  1002e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1002e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002ea:	74 f2                	je     1002de <getchar+0x6>
        /* do nothing */;
    return c;
  1002ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002ef:	c9                   	leave  
  1002f0:	c3                   	ret    

001002f1 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  1002f1:	55                   	push   %ebp
  1002f2:	89 e5                	mov    %esp,%ebp
  1002f4:	83 ec 18             	sub    $0x18,%esp
    if (prompt != NULL) {
  1002f7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1002fb:	74 13                	je     100310 <readline+0x1f>
        cprintf("%s", prompt);
  1002fd:	83 ec 08             	sub    $0x8,%esp
  100300:	ff 75 08             	pushl  0x8(%ebp)
  100303:	68 07 36 10 00       	push   $0x103607
  100308:	e8 40 ff ff ff       	call   10024d <cprintf>
  10030d:	83 c4 10             	add    $0x10,%esp
    }
    int i = 0, c;
  100310:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100317:	e8 bc ff ff ff       	call   1002d8 <getchar>
  10031c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  10031f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100323:	79 0a                	jns    10032f <readline+0x3e>
            return NULL;
  100325:	b8 00 00 00 00       	mov    $0x0,%eax
  10032a:	e9 82 00 00 00       	jmp    1003b1 <readline+0xc0>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10032f:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100333:	7e 2b                	jle    100360 <readline+0x6f>
  100335:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  10033c:	7f 22                	jg     100360 <readline+0x6f>
            cputchar(c);
  10033e:	83 ec 0c             	sub    $0xc,%esp
  100341:	ff 75 f0             	pushl  -0x10(%ebp)
  100344:	e8 2a ff ff ff       	call   100273 <cputchar>
  100349:	83 c4 10             	add    $0x10,%esp
            buf[i ++] = c;
  10034c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10034f:	8d 50 01             	lea    0x1(%eax),%edx
  100352:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100355:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100358:	88 90 40 ea 10 00    	mov    %dl,0x10ea40(%eax)
  10035e:	eb 4c                	jmp    1003ac <readline+0xbb>
        }
        else if (c == '\b' && i > 0) {
  100360:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  100364:	75 1a                	jne    100380 <readline+0x8f>
  100366:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10036a:	7e 14                	jle    100380 <readline+0x8f>
            cputchar(c);
  10036c:	83 ec 0c             	sub    $0xc,%esp
  10036f:	ff 75 f0             	pushl  -0x10(%ebp)
  100372:	e8 fc fe ff ff       	call   100273 <cputchar>
  100377:	83 c4 10             	add    $0x10,%esp
            i --;
  10037a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  10037e:	eb 2c                	jmp    1003ac <readline+0xbb>
        }
        else if (c == '\n' || c == '\r') {
  100380:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  100384:	74 06                	je     10038c <readline+0x9b>
  100386:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  10038a:	75 8b                	jne    100317 <readline+0x26>
            cputchar(c);
  10038c:	83 ec 0c             	sub    $0xc,%esp
  10038f:	ff 75 f0             	pushl  -0x10(%ebp)
  100392:	e8 dc fe ff ff       	call   100273 <cputchar>
  100397:	83 c4 10             	add    $0x10,%esp
            buf[i] = '\0';
  10039a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10039d:	05 40 ea 10 00       	add    $0x10ea40,%eax
  1003a2:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003a5:	b8 40 ea 10 00       	mov    $0x10ea40,%eax
  1003aa:	eb 05                	jmp    1003b1 <readline+0xc0>
        }
    }
  1003ac:	e9 66 ff ff ff       	jmp    100317 <readline+0x26>
}
  1003b1:	c9                   	leave  
  1003b2:	c3                   	ret    

001003b3 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003b3:	55                   	push   %ebp
  1003b4:	89 e5                	mov    %esp,%ebp
  1003b6:	83 ec 18             	sub    $0x18,%esp
    if (is_panic) {
  1003b9:	a1 40 ee 10 00       	mov    0x10ee40,%eax
  1003be:	85 c0                	test   %eax,%eax
  1003c0:	75 5f                	jne    100421 <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
  1003c2:	c7 05 40 ee 10 00 01 	movl   $0x1,0x10ee40
  1003c9:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  1003cc:	8d 45 14             	lea    0x14(%ebp),%eax
  1003cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  1003d2:	83 ec 04             	sub    $0x4,%esp
  1003d5:	ff 75 0c             	pushl  0xc(%ebp)
  1003d8:	ff 75 08             	pushl  0x8(%ebp)
  1003db:	68 0a 36 10 00       	push   $0x10360a
  1003e0:	e8 68 fe ff ff       	call   10024d <cprintf>
  1003e5:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
  1003e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003eb:	83 ec 08             	sub    $0x8,%esp
  1003ee:	50                   	push   %eax
  1003ef:	ff 75 10             	pushl  0x10(%ebp)
  1003f2:	e8 2d fe ff ff       	call   100224 <vcprintf>
  1003f7:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
  1003fa:	83 ec 0c             	sub    $0xc,%esp
  1003fd:	68 26 36 10 00       	push   $0x103626
  100402:	e8 46 fe ff ff       	call   10024d <cprintf>
  100407:	83 c4 10             	add    $0x10,%esp
    
    cprintf("stack trackback:\n");
  10040a:	83 ec 0c             	sub    $0xc,%esp
  10040d:	68 28 36 10 00       	push   $0x103628
  100412:	e8 36 fe ff ff       	call   10024d <cprintf>
  100417:	83 c4 10             	add    $0x10,%esp
    print_stackframe();
  10041a:	e8 17 06 00 00       	call   100a36 <print_stackframe>
  10041f:	eb 01                	jmp    100422 <__panic+0x6f>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
  100421:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
  100422:	e8 ce 13 00 00       	call   1017f5 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100427:	83 ec 0c             	sub    $0xc,%esp
  10042a:	6a 00                	push   $0x0
  10042c:	e8 36 08 00 00       	call   100c67 <kmonitor>
  100431:	83 c4 10             	add    $0x10,%esp
    }
  100434:	eb f1                	jmp    100427 <__panic+0x74>

00100436 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100436:	55                   	push   %ebp
  100437:	89 e5                	mov    %esp,%ebp
  100439:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    va_start(ap, fmt);
  10043c:	8d 45 14             	lea    0x14(%ebp),%eax
  10043f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100442:	83 ec 04             	sub    $0x4,%esp
  100445:	ff 75 0c             	pushl  0xc(%ebp)
  100448:	ff 75 08             	pushl  0x8(%ebp)
  10044b:	68 3a 36 10 00       	push   $0x10363a
  100450:	e8 f8 fd ff ff       	call   10024d <cprintf>
  100455:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
  100458:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10045b:	83 ec 08             	sub    $0x8,%esp
  10045e:	50                   	push   %eax
  10045f:	ff 75 10             	pushl  0x10(%ebp)
  100462:	e8 bd fd ff ff       	call   100224 <vcprintf>
  100467:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
  10046a:	83 ec 0c             	sub    $0xc,%esp
  10046d:	68 26 36 10 00       	push   $0x103626
  100472:	e8 d6 fd ff ff       	call   10024d <cprintf>
  100477:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
  10047a:	90                   	nop
  10047b:	c9                   	leave  
  10047c:	c3                   	ret    

0010047d <is_kernel_panic>:

bool
is_kernel_panic(void) {
  10047d:	55                   	push   %ebp
  10047e:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100480:	a1 40 ee 10 00       	mov    0x10ee40,%eax
}
  100485:	5d                   	pop    %ebp
  100486:	c3                   	ret    

00100487 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  100487:	55                   	push   %ebp
  100488:	89 e5                	mov    %esp,%ebp
  10048a:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  10048d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100490:	8b 00                	mov    (%eax),%eax
  100492:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100495:	8b 45 10             	mov    0x10(%ebp),%eax
  100498:	8b 00                	mov    (%eax),%eax
  10049a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10049d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1004a4:	e9 d2 00 00 00       	jmp    10057b <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  1004a9:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1004af:	01 d0                	add    %edx,%eax
  1004b1:	89 c2                	mov    %eax,%edx
  1004b3:	c1 ea 1f             	shr    $0x1f,%edx
  1004b6:	01 d0                	add    %edx,%eax
  1004b8:	d1 f8                	sar    %eax
  1004ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004c0:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004c3:	eb 04                	jmp    1004c9 <stab_binsearch+0x42>
            m --;
  1004c5:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004cc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004cf:	7c 1f                	jl     1004f0 <stab_binsearch+0x69>
  1004d1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004d4:	89 d0                	mov    %edx,%eax
  1004d6:	01 c0                	add    %eax,%eax
  1004d8:	01 d0                	add    %edx,%eax
  1004da:	c1 e0 02             	shl    $0x2,%eax
  1004dd:	89 c2                	mov    %eax,%edx
  1004df:	8b 45 08             	mov    0x8(%ebp),%eax
  1004e2:	01 d0                	add    %edx,%eax
  1004e4:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1004e8:	0f b6 c0             	movzbl %al,%eax
  1004eb:	3b 45 14             	cmp    0x14(%ebp),%eax
  1004ee:	75 d5                	jne    1004c5 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  1004f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004f3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004f6:	7d 0b                	jge    100503 <stab_binsearch+0x7c>
            l = true_m + 1;
  1004f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004fb:	83 c0 01             	add    $0x1,%eax
  1004fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100501:	eb 78                	jmp    10057b <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  100503:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  10050a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10050d:	89 d0                	mov    %edx,%eax
  10050f:	01 c0                	add    %eax,%eax
  100511:	01 d0                	add    %edx,%eax
  100513:	c1 e0 02             	shl    $0x2,%eax
  100516:	89 c2                	mov    %eax,%edx
  100518:	8b 45 08             	mov    0x8(%ebp),%eax
  10051b:	01 d0                	add    %edx,%eax
  10051d:	8b 40 08             	mov    0x8(%eax),%eax
  100520:	3b 45 18             	cmp    0x18(%ebp),%eax
  100523:	73 13                	jae    100538 <stab_binsearch+0xb1>
            *region_left = m;
  100525:	8b 45 0c             	mov    0xc(%ebp),%eax
  100528:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10052b:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10052d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100530:	83 c0 01             	add    $0x1,%eax
  100533:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100536:	eb 43                	jmp    10057b <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
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
  100551:	76 16                	jbe    100569 <stab_binsearch+0xe2>
            *region_right = m - 1;
  100553:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100556:	8d 50 ff             	lea    -0x1(%eax),%edx
  100559:	8b 45 10             	mov    0x10(%ebp),%eax
  10055c:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  10055e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100561:	83 e8 01             	sub    $0x1,%eax
  100564:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100567:	eb 12                	jmp    10057b <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  100569:	8b 45 0c             	mov    0xc(%ebp),%eax
  10056c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10056f:	89 10                	mov    %edx,(%eax)
            l = m;
  100571:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100574:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  100577:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  10057b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10057e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  100581:	0f 8e 22 ff ff ff    	jle    1004a9 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  100587:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10058b:	75 0f                	jne    10059c <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  10058d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100590:	8b 00                	mov    (%eax),%eax
  100592:	8d 50 ff             	lea    -0x1(%eax),%edx
  100595:	8b 45 10             	mov    0x10(%ebp),%eax
  100598:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  10059a:	eb 3f                	jmp    1005db <stab_binsearch+0x154>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  10059c:	8b 45 10             	mov    0x10(%ebp),%eax
  10059f:	8b 00                	mov    (%eax),%eax
  1005a1:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1005a4:	eb 04                	jmp    1005aa <stab_binsearch+0x123>
  1005a6:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  1005aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005ad:	8b 00                	mov    (%eax),%eax
  1005af:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1005b2:	7d 1f                	jge    1005d3 <stab_binsearch+0x14c>
  1005b4:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005b7:	89 d0                	mov    %edx,%eax
  1005b9:	01 c0                	add    %eax,%eax
  1005bb:	01 d0                	add    %edx,%eax
  1005bd:	c1 e0 02             	shl    $0x2,%eax
  1005c0:	89 c2                	mov    %eax,%edx
  1005c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1005c5:	01 d0                	add    %edx,%eax
  1005c7:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1005cb:	0f b6 c0             	movzbl %al,%eax
  1005ce:	3b 45 14             	cmp    0x14(%ebp),%eax
  1005d1:	75 d3                	jne    1005a6 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
  1005d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005d6:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005d9:	89 10                	mov    %edx,(%eax)
    }
}
  1005db:	90                   	nop
  1005dc:	c9                   	leave  
  1005dd:	c3                   	ret    

001005de <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  1005de:	55                   	push   %ebp
  1005df:	89 e5                	mov    %esp,%ebp
  1005e1:	83 ec 38             	sub    $0x38,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  1005e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005e7:	c7 00 58 36 10 00    	movl   $0x103658,(%eax)
    info->eip_line = 0;
  1005ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005f0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  1005f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005fa:	c7 40 08 58 36 10 00 	movl   $0x103658,0x8(%eax)
    info->eip_fn_namelen = 9;
  100601:	8b 45 0c             	mov    0xc(%ebp),%eax
  100604:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10060b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10060e:	8b 55 08             	mov    0x8(%ebp),%edx
  100611:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100614:	8b 45 0c             	mov    0xc(%ebp),%eax
  100617:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  10061e:	c7 45 f4 6c 3e 10 00 	movl   $0x103e6c,-0xc(%ebp)
    stab_end = __STAB_END__;
  100625:	c7 45 f0 c4 b8 10 00 	movl   $0x10b8c4,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10062c:	c7 45 ec c5 b8 10 00 	movl   $0x10b8c5,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100633:	c7 45 e8 1d d9 10 00 	movl   $0x10d91d,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  10063a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10063d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  100640:	76 0d                	jbe    10064f <debuginfo_eip+0x71>
  100642:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100645:	83 e8 01             	sub    $0x1,%eax
  100648:	0f b6 00             	movzbl (%eax),%eax
  10064b:	84 c0                	test   %al,%al
  10064d:	74 0a                	je     100659 <debuginfo_eip+0x7b>
        return -1;
  10064f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100654:	e9 91 02 00 00       	jmp    1008ea <debuginfo_eip+0x30c>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  100659:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  100660:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100663:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100666:	29 c2                	sub    %eax,%edx
  100668:	89 d0                	mov    %edx,%eax
  10066a:	c1 f8 02             	sar    $0x2,%eax
  10066d:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  100673:	83 e8 01             	sub    $0x1,%eax
  100676:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  100679:	ff 75 08             	pushl  0x8(%ebp)
  10067c:	6a 64                	push   $0x64
  10067e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  100681:	50                   	push   %eax
  100682:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  100685:	50                   	push   %eax
  100686:	ff 75 f4             	pushl  -0xc(%ebp)
  100689:	e8 f9 fd ff ff       	call   100487 <stab_binsearch>
  10068e:	83 c4 14             	add    $0x14,%esp
    if (lfile == 0)
  100691:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100694:	85 c0                	test   %eax,%eax
  100696:	75 0a                	jne    1006a2 <debuginfo_eip+0xc4>
        return -1;
  100698:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10069d:	e9 48 02 00 00       	jmp    1008ea <debuginfo_eip+0x30c>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1006a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1006ae:	ff 75 08             	pushl  0x8(%ebp)
  1006b1:	6a 24                	push   $0x24
  1006b3:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1006b6:	50                   	push   %eax
  1006b7:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1006ba:	50                   	push   %eax
  1006bb:	ff 75 f4             	pushl  -0xc(%ebp)
  1006be:	e8 c4 fd ff ff       	call   100487 <stab_binsearch>
  1006c3:	83 c4 14             	add    $0x14,%esp

    if (lfun <= rfun) {
  1006c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1006c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006cc:	39 c2                	cmp    %eax,%edx
  1006ce:	7f 7c                	jg     10074c <debuginfo_eip+0x16e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  1006d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006d3:	89 c2                	mov    %eax,%edx
  1006d5:	89 d0                	mov    %edx,%eax
  1006d7:	01 c0                	add    %eax,%eax
  1006d9:	01 d0                	add    %edx,%eax
  1006db:	c1 e0 02             	shl    $0x2,%eax
  1006de:	89 c2                	mov    %eax,%edx
  1006e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006e3:	01 d0                	add    %edx,%eax
  1006e5:	8b 00                	mov    (%eax),%eax
  1006e7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1006ea:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1006ed:	29 d1                	sub    %edx,%ecx
  1006ef:	89 ca                	mov    %ecx,%edx
  1006f1:	39 d0                	cmp    %edx,%eax
  1006f3:	73 22                	jae    100717 <debuginfo_eip+0x139>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  1006f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006f8:	89 c2                	mov    %eax,%edx
  1006fa:	89 d0                	mov    %edx,%eax
  1006fc:	01 c0                	add    %eax,%eax
  1006fe:	01 d0                	add    %edx,%eax
  100700:	c1 e0 02             	shl    $0x2,%eax
  100703:	89 c2                	mov    %eax,%edx
  100705:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100708:	01 d0                	add    %edx,%eax
  10070a:	8b 10                	mov    (%eax),%edx
  10070c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10070f:	01 c2                	add    %eax,%edx
  100711:	8b 45 0c             	mov    0xc(%ebp),%eax
  100714:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100717:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10071a:	89 c2                	mov    %eax,%edx
  10071c:	89 d0                	mov    %edx,%eax
  10071e:	01 c0                	add    %eax,%eax
  100720:	01 d0                	add    %edx,%eax
  100722:	c1 e0 02             	shl    $0x2,%eax
  100725:	89 c2                	mov    %eax,%edx
  100727:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10072a:	01 d0                	add    %edx,%eax
  10072c:	8b 50 08             	mov    0x8(%eax),%edx
  10072f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100732:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100735:	8b 45 0c             	mov    0xc(%ebp),%eax
  100738:	8b 40 10             	mov    0x10(%eax),%eax
  10073b:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  10073e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100741:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  100744:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100747:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10074a:	eb 15                	jmp    100761 <debuginfo_eip+0x183>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  10074c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10074f:	8b 55 08             	mov    0x8(%ebp),%edx
  100752:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  100755:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100758:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  10075b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10075e:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  100761:	8b 45 0c             	mov    0xc(%ebp),%eax
  100764:	8b 40 08             	mov    0x8(%eax),%eax
  100767:	83 ec 08             	sub    $0x8,%esp
  10076a:	6a 3a                	push   $0x3a
  10076c:	50                   	push   %eax
  10076d:	e8 bb 24 00 00       	call   102c2d <strfind>
  100772:	83 c4 10             	add    $0x10,%esp
  100775:	89 c2                	mov    %eax,%edx
  100777:	8b 45 0c             	mov    0xc(%ebp),%eax
  10077a:	8b 40 08             	mov    0x8(%eax),%eax
  10077d:	29 c2                	sub    %eax,%edx
  10077f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100782:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  100785:	83 ec 0c             	sub    $0xc,%esp
  100788:	ff 75 08             	pushl  0x8(%ebp)
  10078b:	6a 44                	push   $0x44
  10078d:	8d 45 d0             	lea    -0x30(%ebp),%eax
  100790:	50                   	push   %eax
  100791:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  100794:	50                   	push   %eax
  100795:	ff 75 f4             	pushl  -0xc(%ebp)
  100798:	e8 ea fc ff ff       	call   100487 <stab_binsearch>
  10079d:	83 c4 20             	add    $0x20,%esp
    if (lline <= rline) {
  1007a0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007a3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007a6:	39 c2                	cmp    %eax,%edx
  1007a8:	7f 24                	jg     1007ce <debuginfo_eip+0x1f0>
        info->eip_line = stabs[rline].n_desc;
  1007aa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007ad:	89 c2                	mov    %eax,%edx
  1007af:	89 d0                	mov    %edx,%eax
  1007b1:	01 c0                	add    %eax,%eax
  1007b3:	01 d0                	add    %edx,%eax
  1007b5:	c1 e0 02             	shl    $0x2,%eax
  1007b8:	89 c2                	mov    %eax,%edx
  1007ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007bd:	01 d0                	add    %edx,%eax
  1007bf:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  1007c3:	0f b7 d0             	movzwl %ax,%edx
  1007c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007c9:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  1007cc:	eb 13                	jmp    1007e1 <debuginfo_eip+0x203>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  1007ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1007d3:	e9 12 01 00 00       	jmp    1008ea <debuginfo_eip+0x30c>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  1007d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007db:	83 e8 01             	sub    $0x1,%eax
  1007de:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  1007e1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007e7:	39 c2                	cmp    %eax,%edx
  1007e9:	7c 56                	jl     100841 <debuginfo_eip+0x263>
           && stabs[lline].n_type != N_SOL
  1007eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007ee:	89 c2                	mov    %eax,%edx
  1007f0:	89 d0                	mov    %edx,%eax
  1007f2:	01 c0                	add    %eax,%eax
  1007f4:	01 d0                	add    %edx,%eax
  1007f6:	c1 e0 02             	shl    $0x2,%eax
  1007f9:	89 c2                	mov    %eax,%edx
  1007fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007fe:	01 d0                	add    %edx,%eax
  100800:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100804:	3c 84                	cmp    $0x84,%al
  100806:	74 39                	je     100841 <debuginfo_eip+0x263>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100808:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10080b:	89 c2                	mov    %eax,%edx
  10080d:	89 d0                	mov    %edx,%eax
  10080f:	01 c0                	add    %eax,%eax
  100811:	01 d0                	add    %edx,%eax
  100813:	c1 e0 02             	shl    $0x2,%eax
  100816:	89 c2                	mov    %eax,%edx
  100818:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10081b:	01 d0                	add    %edx,%eax
  10081d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100821:	3c 64                	cmp    $0x64,%al
  100823:	75 b3                	jne    1007d8 <debuginfo_eip+0x1fa>
  100825:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100828:	89 c2                	mov    %eax,%edx
  10082a:	89 d0                	mov    %edx,%eax
  10082c:	01 c0                	add    %eax,%eax
  10082e:	01 d0                	add    %edx,%eax
  100830:	c1 e0 02             	shl    $0x2,%eax
  100833:	89 c2                	mov    %eax,%edx
  100835:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100838:	01 d0                	add    %edx,%eax
  10083a:	8b 40 08             	mov    0x8(%eax),%eax
  10083d:	85 c0                	test   %eax,%eax
  10083f:	74 97                	je     1007d8 <debuginfo_eip+0x1fa>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  100841:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100844:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100847:	39 c2                	cmp    %eax,%edx
  100849:	7c 46                	jl     100891 <debuginfo_eip+0x2b3>
  10084b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10084e:	89 c2                	mov    %eax,%edx
  100850:	89 d0                	mov    %edx,%eax
  100852:	01 c0                	add    %eax,%eax
  100854:	01 d0                	add    %edx,%eax
  100856:	c1 e0 02             	shl    $0x2,%eax
  100859:	89 c2                	mov    %eax,%edx
  10085b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10085e:	01 d0                	add    %edx,%eax
  100860:	8b 00                	mov    (%eax),%eax
  100862:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100865:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100868:	29 d1                	sub    %edx,%ecx
  10086a:	89 ca                	mov    %ecx,%edx
  10086c:	39 d0                	cmp    %edx,%eax
  10086e:	73 21                	jae    100891 <debuginfo_eip+0x2b3>
        info->eip_file = stabstr + stabs[lline].n_strx;
  100870:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100873:	89 c2                	mov    %eax,%edx
  100875:	89 d0                	mov    %edx,%eax
  100877:	01 c0                	add    %eax,%eax
  100879:	01 d0                	add    %edx,%eax
  10087b:	c1 e0 02             	shl    $0x2,%eax
  10087e:	89 c2                	mov    %eax,%edx
  100880:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100883:	01 d0                	add    %edx,%eax
  100885:	8b 10                	mov    (%eax),%edx
  100887:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10088a:	01 c2                	add    %eax,%edx
  10088c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10088f:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  100891:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100894:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100897:	39 c2                	cmp    %eax,%edx
  100899:	7d 4a                	jge    1008e5 <debuginfo_eip+0x307>
        for (lline = lfun + 1;
  10089b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10089e:	83 c0 01             	add    $0x1,%eax
  1008a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1008a4:	eb 18                	jmp    1008be <debuginfo_eip+0x2e0>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  1008a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008a9:	8b 40 14             	mov    0x14(%eax),%eax
  1008ac:	8d 50 01             	lea    0x1(%eax),%edx
  1008af:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008b2:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  1008b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008b8:	83 c0 01             	add    $0x1,%eax
  1008bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1008c1:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  1008c4:	39 c2                	cmp    %eax,%edx
  1008c6:	7d 1d                	jge    1008e5 <debuginfo_eip+0x307>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008cb:	89 c2                	mov    %eax,%edx
  1008cd:	89 d0                	mov    %edx,%eax
  1008cf:	01 c0                	add    %eax,%eax
  1008d1:	01 d0                	add    %edx,%eax
  1008d3:	c1 e0 02             	shl    $0x2,%eax
  1008d6:	89 c2                	mov    %eax,%edx
  1008d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008db:	01 d0                	add    %edx,%eax
  1008dd:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1008e1:	3c a0                	cmp    $0xa0,%al
  1008e3:	74 c1                	je     1008a6 <debuginfo_eip+0x2c8>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  1008e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1008ea:	c9                   	leave  
  1008eb:	c3                   	ret    

001008ec <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  1008ec:	55                   	push   %ebp
  1008ed:	89 e5                	mov    %esp,%ebp
  1008ef:	83 ec 08             	sub    $0x8,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  1008f2:	83 ec 0c             	sub    $0xc,%esp
  1008f5:	68 62 36 10 00       	push   $0x103662
  1008fa:	e8 4e f9 ff ff       	call   10024d <cprintf>
  1008ff:	83 c4 10             	add    $0x10,%esp
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  100902:	83 ec 08             	sub    $0x8,%esp
  100905:	68 00 00 10 00       	push   $0x100000
  10090a:	68 7b 36 10 00       	push   $0x10367b
  10090f:	e8 39 f9 ff ff       	call   10024d <cprintf>
  100914:	83 c4 10             	add    $0x10,%esp
    cprintf("  etext  0x%08x (phys)\n", etext);
  100917:	83 ec 08             	sub    $0x8,%esp
  10091a:	68 50 35 10 00       	push   $0x103550
  10091f:	68 93 36 10 00       	push   $0x103693
  100924:	e8 24 f9 ff ff       	call   10024d <cprintf>
  100929:	83 c4 10             	add    $0x10,%esp
    cprintf("  edata  0x%08x (phys)\n", edata);
  10092c:	83 ec 08             	sub    $0x8,%esp
  10092f:	68 16 ea 10 00       	push   $0x10ea16
  100934:	68 ab 36 10 00       	push   $0x1036ab
  100939:	e8 0f f9 ff ff       	call   10024d <cprintf>
  10093e:	83 c4 10             	add    $0x10,%esp
    cprintf("  end    0x%08x (phys)\n", end);
  100941:	83 ec 08             	sub    $0x8,%esp
  100944:	68 80 fd 10 00       	push   $0x10fd80
  100949:	68 c3 36 10 00       	push   $0x1036c3
  10094e:	e8 fa f8 ff ff       	call   10024d <cprintf>
  100953:	83 c4 10             	add    $0x10,%esp
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  100956:	b8 80 fd 10 00       	mov    $0x10fd80,%eax
  10095b:	05 ff 03 00 00       	add    $0x3ff,%eax
  100960:	ba 00 00 10 00       	mov    $0x100000,%edx
  100965:	29 d0                	sub    %edx,%eax
  100967:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  10096d:	85 c0                	test   %eax,%eax
  10096f:	0f 48 c2             	cmovs  %edx,%eax
  100972:	c1 f8 0a             	sar    $0xa,%eax
  100975:	83 ec 08             	sub    $0x8,%esp
  100978:	50                   	push   %eax
  100979:	68 dc 36 10 00       	push   $0x1036dc
  10097e:	e8 ca f8 ff ff       	call   10024d <cprintf>
  100983:	83 c4 10             	add    $0x10,%esp
}
  100986:	90                   	nop
  100987:	c9                   	leave  
  100988:	c3                   	ret    

00100989 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  100989:	55                   	push   %ebp
  10098a:	89 e5                	mov    %esp,%ebp
  10098c:	81 ec 28 01 00 00    	sub    $0x128,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  100992:	83 ec 08             	sub    $0x8,%esp
  100995:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100998:	50                   	push   %eax
  100999:	ff 75 08             	pushl  0x8(%ebp)
  10099c:	e8 3d fc ff ff       	call   1005de <debuginfo_eip>
  1009a1:	83 c4 10             	add    $0x10,%esp
  1009a4:	85 c0                	test   %eax,%eax
  1009a6:	74 15                	je     1009bd <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1009a8:	83 ec 08             	sub    $0x8,%esp
  1009ab:	ff 75 08             	pushl  0x8(%ebp)
  1009ae:	68 06 37 10 00       	push   $0x103706
  1009b3:	e8 95 f8 ff ff       	call   10024d <cprintf>
  1009b8:	83 c4 10             	add    $0x10,%esp
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  1009bb:	eb 65                	jmp    100a22 <print_debuginfo+0x99>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1009c4:	eb 1c                	jmp    1009e2 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  1009c6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1009c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009cc:	01 d0                	add    %edx,%eax
  1009ce:	0f b6 00             	movzbl (%eax),%eax
  1009d1:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  1009d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1009da:	01 ca                	add    %ecx,%edx
  1009dc:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009de:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1009e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1009e5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1009e8:	7f dc                	jg     1009c6 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  1009ea:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  1009f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009f3:	01 d0                	add    %edx,%eax
  1009f5:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  1009f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  1009fb:	8b 55 08             	mov    0x8(%ebp),%edx
  1009fe:	89 d1                	mov    %edx,%ecx
  100a00:	29 c1                	sub    %eax,%ecx
  100a02:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a05:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a08:	83 ec 0c             	sub    $0xc,%esp
  100a0b:	51                   	push   %ecx
  100a0c:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a12:	51                   	push   %ecx
  100a13:	52                   	push   %edx
  100a14:	50                   	push   %eax
  100a15:	68 22 37 10 00       	push   $0x103722
  100a1a:	e8 2e f8 ff ff       	call   10024d <cprintf>
  100a1f:	83 c4 20             	add    $0x20,%esp
                fnname, eip - info.eip_fn_addr);
    }
}
  100a22:	90                   	nop
  100a23:	c9                   	leave  
  100a24:	c3                   	ret    

00100a25 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a25:	55                   	push   %ebp
  100a26:	89 e5                	mov    %esp,%ebp
  100a28:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a2b:	8b 45 04             	mov    0x4(%ebp),%eax
  100a2e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a31:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a34:	c9                   	leave  
  100a35:	c3                   	ret    

00100a36 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100a36:	55                   	push   %ebp
  100a37:	89 e5                	mov    %esp,%ebp
  100a39:	83 ec 28             	sub    $0x28,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a3c:	89 e8                	mov    %ebp,%eax
  100a3e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  100a41:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
  100a44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100a47:	e8 d9 ff ff ff       	call   100a25 <read_eip>
  100a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  100a4f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100a56:	e9 8d 00 00 00       	jmp    100ae8 <print_stackframe+0xb2>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
  100a5b:	83 ec 04             	sub    $0x4,%esp
  100a5e:	ff 75 f0             	pushl  -0x10(%ebp)
  100a61:	ff 75 f4             	pushl  -0xc(%ebp)
  100a64:	68 34 37 10 00       	push   $0x103734
  100a69:	e8 df f7 ff ff       	call   10024d <cprintf>
  100a6e:	83 c4 10             	add    $0x10,%esp
        uint32_t *args = (uint32_t *)ebp + 2;
  100a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a74:	83 c0 08             	add    $0x8,%eax
  100a77:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
  100a7a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100a81:	eb 26                	jmp    100aa9 <print_stackframe+0x73>
            cprintf("0x%08x ", args[j]);
  100a83:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a86:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100a8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100a90:	01 d0                	add    %edx,%eax
  100a92:	8b 00                	mov    (%eax),%eax
  100a94:	83 ec 08             	sub    $0x8,%esp
  100a97:	50                   	push   %eax
  100a98:	68 50 37 10 00       	push   $0x103750
  100a9d:	e8 ab f7 ff ff       	call   10024d <cprintf>
  100aa2:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
  100aa5:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
  100aa9:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100aad:	7e d4                	jle    100a83 <print_stackframe+0x4d>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
  100aaf:	83 ec 0c             	sub    $0xc,%esp
  100ab2:	68 58 37 10 00       	push   $0x103758
  100ab7:	e8 91 f7 ff ff       	call   10024d <cprintf>
  100abc:	83 c4 10             	add    $0x10,%esp
        print_debuginfo(eip - 1);
  100abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100ac2:	83 e8 01             	sub    $0x1,%eax
  100ac5:	83 ec 0c             	sub    $0xc,%esp
  100ac8:	50                   	push   %eax
  100ac9:	e8 bb fe ff ff       	call   100989 <print_debuginfo>
  100ace:	83 c4 10             	add    $0x10,%esp
        eip = ((uint32_t *)ebp)[1];
  100ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ad4:	83 c0 04             	add    $0x4,%eax
  100ad7:	8b 00                	mov    (%eax),%eax
  100ad9:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
  100adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100adf:	8b 00                	mov    (%eax),%eax
  100ae1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  100ae4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100ae8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100aec:	74 0a                	je     100af8 <print_stackframe+0xc2>
  100aee:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100af2:	0f 8e 63 ff ff ff    	jle    100a5b <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
  100af8:	90                   	nop
  100af9:	c9                   	leave  
  100afa:	c3                   	ret    

00100afb <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100afb:	55                   	push   %ebp
  100afc:	89 e5                	mov    %esp,%ebp
  100afe:	83 ec 18             	sub    $0x18,%esp
    int argc = 0;
  100b01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b08:	eb 0c                	jmp    100b16 <parse+0x1b>
            *buf ++ = '\0';
  100b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  100b0d:	8d 50 01             	lea    0x1(%eax),%edx
  100b10:	89 55 08             	mov    %edx,0x8(%ebp)
  100b13:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b16:	8b 45 08             	mov    0x8(%ebp),%eax
  100b19:	0f b6 00             	movzbl (%eax),%eax
  100b1c:	84 c0                	test   %al,%al
  100b1e:	74 1e                	je     100b3e <parse+0x43>
  100b20:	8b 45 08             	mov    0x8(%ebp),%eax
  100b23:	0f b6 00             	movzbl (%eax),%eax
  100b26:	0f be c0             	movsbl %al,%eax
  100b29:	83 ec 08             	sub    $0x8,%esp
  100b2c:	50                   	push   %eax
  100b2d:	68 dc 37 10 00       	push   $0x1037dc
  100b32:	e8 c3 20 00 00       	call   102bfa <strchr>
  100b37:	83 c4 10             	add    $0x10,%esp
  100b3a:	85 c0                	test   %eax,%eax
  100b3c:	75 cc                	jne    100b0a <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  100b41:	0f b6 00             	movzbl (%eax),%eax
  100b44:	84 c0                	test   %al,%al
  100b46:	74 69                	je     100bb1 <parse+0xb6>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100b48:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100b4c:	75 12                	jne    100b60 <parse+0x65>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100b4e:	83 ec 08             	sub    $0x8,%esp
  100b51:	6a 10                	push   $0x10
  100b53:	68 e1 37 10 00       	push   $0x1037e1
  100b58:	e8 f0 f6 ff ff       	call   10024d <cprintf>
  100b5d:	83 c4 10             	add    $0x10,%esp
        }
        argv[argc ++] = buf;
  100b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b63:	8d 50 01             	lea    0x1(%eax),%edx
  100b66:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100b69:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  100b73:	01 c2                	add    %eax,%edx
  100b75:	8b 45 08             	mov    0x8(%ebp),%eax
  100b78:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b7a:	eb 04                	jmp    100b80 <parse+0x85>
            buf ++;
  100b7c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b80:	8b 45 08             	mov    0x8(%ebp),%eax
  100b83:	0f b6 00             	movzbl (%eax),%eax
  100b86:	84 c0                	test   %al,%al
  100b88:	0f 84 7a ff ff ff    	je     100b08 <parse+0xd>
  100b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  100b91:	0f b6 00             	movzbl (%eax),%eax
  100b94:	0f be c0             	movsbl %al,%eax
  100b97:	83 ec 08             	sub    $0x8,%esp
  100b9a:	50                   	push   %eax
  100b9b:	68 dc 37 10 00       	push   $0x1037dc
  100ba0:	e8 55 20 00 00       	call   102bfa <strchr>
  100ba5:	83 c4 10             	add    $0x10,%esp
  100ba8:	85 c0                	test   %eax,%eax
  100baa:	74 d0                	je     100b7c <parse+0x81>
            buf ++;
        }
    }
  100bac:	e9 57 ff ff ff       	jmp    100b08 <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
  100bb1:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100bb5:	c9                   	leave  
  100bb6:	c3                   	ret    

00100bb7 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100bb7:	55                   	push   %ebp
  100bb8:	89 e5                	mov    %esp,%ebp
  100bba:	83 ec 58             	sub    $0x58,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100bbd:	83 ec 08             	sub    $0x8,%esp
  100bc0:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100bc3:	50                   	push   %eax
  100bc4:	ff 75 08             	pushl  0x8(%ebp)
  100bc7:	e8 2f ff ff ff       	call   100afb <parse>
  100bcc:	83 c4 10             	add    $0x10,%esp
  100bcf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100bd2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100bd6:	75 0a                	jne    100be2 <runcmd+0x2b>
        return 0;
  100bd8:	b8 00 00 00 00       	mov    $0x0,%eax
  100bdd:	e9 83 00 00 00       	jmp    100c65 <runcmd+0xae>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100be2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100be9:	eb 59                	jmp    100c44 <runcmd+0x8d>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100beb:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100bee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100bf1:	89 d0                	mov    %edx,%eax
  100bf3:	01 c0                	add    %eax,%eax
  100bf5:	01 d0                	add    %edx,%eax
  100bf7:	c1 e0 02             	shl    $0x2,%eax
  100bfa:	05 00 e0 10 00       	add    $0x10e000,%eax
  100bff:	8b 00                	mov    (%eax),%eax
  100c01:	83 ec 08             	sub    $0x8,%esp
  100c04:	51                   	push   %ecx
  100c05:	50                   	push   %eax
  100c06:	e8 4f 1f 00 00       	call   102b5a <strcmp>
  100c0b:	83 c4 10             	add    $0x10,%esp
  100c0e:	85 c0                	test   %eax,%eax
  100c10:	75 2e                	jne    100c40 <runcmd+0x89>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c12:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c15:	89 d0                	mov    %edx,%eax
  100c17:	01 c0                	add    %eax,%eax
  100c19:	01 d0                	add    %edx,%eax
  100c1b:	c1 e0 02             	shl    $0x2,%eax
  100c1e:	05 08 e0 10 00       	add    $0x10e008,%eax
  100c23:	8b 10                	mov    (%eax),%edx
  100c25:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c28:	83 c0 04             	add    $0x4,%eax
  100c2b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100c2e:	83 e9 01             	sub    $0x1,%ecx
  100c31:	83 ec 04             	sub    $0x4,%esp
  100c34:	ff 75 0c             	pushl  0xc(%ebp)
  100c37:	50                   	push   %eax
  100c38:	51                   	push   %ecx
  100c39:	ff d2                	call   *%edx
  100c3b:	83 c4 10             	add    $0x10,%esp
  100c3e:	eb 25                	jmp    100c65 <runcmd+0xae>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c40:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c47:	83 f8 02             	cmp    $0x2,%eax
  100c4a:	76 9f                	jbe    100beb <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100c4c:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100c4f:	83 ec 08             	sub    $0x8,%esp
  100c52:	50                   	push   %eax
  100c53:	68 ff 37 10 00       	push   $0x1037ff
  100c58:	e8 f0 f5 ff ff       	call   10024d <cprintf>
  100c5d:	83 c4 10             	add    $0x10,%esp
    return 0;
  100c60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c65:	c9                   	leave  
  100c66:	c3                   	ret    

00100c67 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100c67:	55                   	push   %ebp
  100c68:	89 e5                	mov    %esp,%ebp
  100c6a:	83 ec 18             	sub    $0x18,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100c6d:	83 ec 0c             	sub    $0xc,%esp
  100c70:	68 18 38 10 00       	push   $0x103818
  100c75:	e8 d3 f5 ff ff       	call   10024d <cprintf>
  100c7a:	83 c4 10             	add    $0x10,%esp
    cprintf("Type 'help' for a list of commands.\n");
  100c7d:	83 ec 0c             	sub    $0xc,%esp
  100c80:	68 40 38 10 00       	push   $0x103840
  100c85:	e8 c3 f5 ff ff       	call   10024d <cprintf>
  100c8a:	83 c4 10             	add    $0x10,%esp

    if (tf != NULL) {
  100c8d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c91:	74 0e                	je     100ca1 <kmonitor+0x3a>
        print_trapframe(tf);
  100c93:	83 ec 0c             	sub    $0xc,%esp
  100c96:	ff 75 08             	pushl  0x8(%ebp)
  100c99:	e8 32 0d 00 00       	call   1019d0 <print_trapframe>
  100c9e:	83 c4 10             	add    $0x10,%esp
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100ca1:	83 ec 0c             	sub    $0xc,%esp
  100ca4:	68 65 38 10 00       	push   $0x103865
  100ca9:	e8 43 f6 ff ff       	call   1002f1 <readline>
  100cae:	83 c4 10             	add    $0x10,%esp
  100cb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100cb4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100cb8:	74 e7                	je     100ca1 <kmonitor+0x3a>
            if (runcmd(buf, tf) < 0) {
  100cba:	83 ec 08             	sub    $0x8,%esp
  100cbd:	ff 75 08             	pushl  0x8(%ebp)
  100cc0:	ff 75 f4             	pushl  -0xc(%ebp)
  100cc3:	e8 ef fe ff ff       	call   100bb7 <runcmd>
  100cc8:	83 c4 10             	add    $0x10,%esp
  100ccb:	85 c0                	test   %eax,%eax
  100ccd:	78 02                	js     100cd1 <kmonitor+0x6a>
                break;
            }
        }
    }
  100ccf:	eb d0                	jmp    100ca1 <kmonitor+0x3a>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
  100cd1:	90                   	nop
            }
        }
    }
}
  100cd2:	90                   	nop
  100cd3:	c9                   	leave  
  100cd4:	c3                   	ret    

00100cd5 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100cd5:	55                   	push   %ebp
  100cd6:	89 e5                	mov    %esp,%ebp
  100cd8:	83 ec 18             	sub    $0x18,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100cdb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100ce2:	eb 3c                	jmp    100d20 <mon_help+0x4b>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100ce4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100ce7:	89 d0                	mov    %edx,%eax
  100ce9:	01 c0                	add    %eax,%eax
  100ceb:	01 d0                	add    %edx,%eax
  100ced:	c1 e0 02             	shl    $0x2,%eax
  100cf0:	05 04 e0 10 00       	add    $0x10e004,%eax
  100cf5:	8b 08                	mov    (%eax),%ecx
  100cf7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100cfa:	89 d0                	mov    %edx,%eax
  100cfc:	01 c0                	add    %eax,%eax
  100cfe:	01 d0                	add    %edx,%eax
  100d00:	c1 e0 02             	shl    $0x2,%eax
  100d03:	05 00 e0 10 00       	add    $0x10e000,%eax
  100d08:	8b 00                	mov    (%eax),%eax
  100d0a:	83 ec 04             	sub    $0x4,%esp
  100d0d:	51                   	push   %ecx
  100d0e:	50                   	push   %eax
  100d0f:	68 69 38 10 00       	push   $0x103869
  100d14:	e8 34 f5 ff ff       	call   10024d <cprintf>
  100d19:	83 c4 10             	add    $0x10,%esp

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d1c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d23:	83 f8 02             	cmp    $0x2,%eax
  100d26:	76 bc                	jbe    100ce4 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100d28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d2d:	c9                   	leave  
  100d2e:	c3                   	ret    

00100d2f <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d2f:	55                   	push   %ebp
  100d30:	89 e5                	mov    %esp,%ebp
  100d32:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d35:	e8 b2 fb ff ff       	call   1008ec <print_kerninfo>
    return 0;
  100d3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d3f:	c9                   	leave  
  100d40:	c3                   	ret    

00100d41 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d41:	55                   	push   %ebp
  100d42:	89 e5                	mov    %esp,%ebp
  100d44:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100d47:	e8 ea fc ff ff       	call   100a36 <print_stackframe>
    return 0;
  100d4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d51:	c9                   	leave  
  100d52:	c3                   	ret    

00100d53 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d53:	55                   	push   %ebp
  100d54:	89 e5                	mov    %esp,%ebp
  100d56:	83 ec 18             	sub    $0x18,%esp
  100d59:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100d5f:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100d63:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  100d67:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100d6b:	ee                   	out    %al,(%dx)
  100d6c:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
  100d72:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
  100d76:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
  100d7a:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
  100d7e:	ee                   	out    %al,(%dx)
  100d7f:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100d85:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
  100d89:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100d8d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100d91:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100d92:	c7 05 08 f9 10 00 00 	movl   $0x0,0x10f908
  100d99:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100d9c:	83 ec 0c             	sub    $0xc,%esp
  100d9f:	68 72 38 10 00       	push   $0x103872
  100da4:	e8 a4 f4 ff ff       	call   10024d <cprintf>
  100da9:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_TIMER);
  100dac:	83 ec 0c             	sub    $0xc,%esp
  100daf:	6a 00                	push   $0x0
  100db1:	e8 ce 08 00 00       	call   101684 <pic_enable>
  100db6:	83 c4 10             	add    $0x10,%esp
}
  100db9:	90                   	nop
  100dba:	c9                   	leave  
  100dbb:	c3                   	ret    

00100dbc <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100dbc:	55                   	push   %ebp
  100dbd:	89 e5                	mov    %esp,%ebp
  100dbf:	83 ec 10             	sub    $0x10,%esp
  100dc2:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100dc8:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100dcc:	89 c2                	mov    %eax,%edx
  100dce:	ec                   	in     (%dx),%al
  100dcf:	88 45 f4             	mov    %al,-0xc(%ebp)
  100dd2:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
  100dd8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
  100ddc:	89 c2                	mov    %eax,%edx
  100dde:	ec                   	in     (%dx),%al
  100ddf:	88 45 f5             	mov    %al,-0xb(%ebp)
  100de2:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100de8:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100dec:	89 c2                	mov    %eax,%edx
  100dee:	ec                   	in     (%dx),%al
  100def:	88 45 f6             	mov    %al,-0xa(%ebp)
  100df2:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
  100df8:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
  100dfc:	89 c2                	mov    %eax,%edx
  100dfe:	ec                   	in     (%dx),%al
  100dff:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e02:	90                   	nop
  100e03:	c9                   	leave  
  100e04:	c3                   	ret    

00100e05 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e05:	55                   	push   %ebp
  100e06:	89 e5                	mov    %esp,%ebp
  100e08:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;
  100e0b:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;
  100e12:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e15:	0f b7 00             	movzwl (%eax),%eax
  100e18:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100e1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e1f:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100e24:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e27:	0f b7 00             	movzwl (%eax),%eax
  100e2a:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100e2e:	74 12                	je     100e42 <cga_init+0x3d>
        cp = (uint16_t*)MONO_BUF;
  100e30:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100e37:	66 c7 05 66 ee 10 00 	movw   $0x3b4,0x10ee66
  100e3e:	b4 03 
  100e40:	eb 13                	jmp    100e55 <cga_init+0x50>
    } else {
        *cp = was;
  100e42:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e45:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100e49:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100e4c:	66 c7 05 66 ee 10 00 	movw   $0x3d4,0x10ee66
  100e53:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100e55:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e5c:	0f b7 c0             	movzwl %ax,%eax
  100e5f:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  100e63:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100e67:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
  100e6b:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
  100e6f:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100e70:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e77:	83 c0 01             	add    $0x1,%eax
  100e7a:	0f b7 c0             	movzwl %ax,%eax
  100e7d:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100e81:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e85:	89 c2                	mov    %eax,%edx
  100e87:	ec                   	in     (%dx),%al
  100e88:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  100e8b:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  100e8f:	0f b6 c0             	movzbl %al,%eax
  100e92:	c1 e0 08             	shl    $0x8,%eax
  100e95:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100e98:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e9f:	0f b7 c0             	movzwl %ax,%eax
  100ea2:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
  100ea6:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100eaa:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
  100eae:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
  100eb2:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100eb3:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100eba:	83 c0 01             	add    $0x1,%eax
  100ebd:	0f b7 c0             	movzwl %ax,%eax
  100ec0:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100ec4:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100ec8:	89 c2                	mov    %eax,%edx
  100eca:	ec                   	in     (%dx),%al
  100ecb:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100ece:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100ed2:	0f b6 c0             	movzbl %al,%eax
  100ed5:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100ed8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100edb:	a3 60 ee 10 00       	mov    %eax,0x10ee60
    crt_pos = pos;
  100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ee3:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
}
  100ee9:	90                   	nop
  100eea:	c9                   	leave  
  100eeb:	c3                   	ret    

00100eec <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100eec:	55                   	push   %ebp
  100eed:	89 e5                	mov    %esp,%ebp
  100eef:	83 ec 28             	sub    $0x28,%esp
  100ef2:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100ef8:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100efc:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
  100f00:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f04:	ee                   	out    %al,(%dx)
  100f05:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
  100f0b:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
  100f0f:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  100f13:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
  100f17:	ee                   	out    %al,(%dx)
  100f18:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
  100f1e:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
  100f22:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  100f26:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f2a:	ee                   	out    %al,(%dx)
  100f2b:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
  100f31:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
  100f35:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100f39:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
  100f3d:	ee                   	out    %al,(%dx)
  100f3e:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
  100f44:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
  100f48:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
  100f4c:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f50:	ee                   	out    %al,(%dx)
  100f51:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
  100f57:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
  100f5b:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  100f5f:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
  100f63:	ee                   	out    %al,(%dx)
  100f64:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100f6a:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
  100f6e:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  100f72:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f76:	ee                   	out    %al,(%dx)
  100f77:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f7d:	0f b7 45 e8          	movzwl -0x18(%ebp),%eax
  100f81:	89 c2                	mov    %eax,%edx
  100f83:	ec                   	in     (%dx),%al
  100f84:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
  100f87:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100f8b:	3c ff                	cmp    $0xff,%al
  100f8d:	0f 95 c0             	setne  %al
  100f90:	0f b6 c0             	movzbl %al,%eax
  100f93:	a3 68 ee 10 00       	mov    %eax,0x10ee68
  100f98:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f9e:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100fa2:	89 c2                	mov    %eax,%edx
  100fa4:	ec                   	in     (%dx),%al
  100fa5:	88 45 e2             	mov    %al,-0x1e(%ebp)
  100fa8:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
  100fae:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
  100fb2:	89 c2                	mov    %eax,%edx
  100fb4:	ec                   	in     (%dx),%al
  100fb5:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  100fb8:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  100fbd:	85 c0                	test   %eax,%eax
  100fbf:	74 0d                	je     100fce <serial_init+0xe2>
        pic_enable(IRQ_COM1);
  100fc1:	83 ec 0c             	sub    $0xc,%esp
  100fc4:	6a 04                	push   $0x4
  100fc6:	e8 b9 06 00 00       	call   101684 <pic_enable>
  100fcb:	83 c4 10             	add    $0x10,%esp
    }
}
  100fce:	90                   	nop
  100fcf:	c9                   	leave  
  100fd0:	c3                   	ret    

00100fd1 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  100fd1:	55                   	push   %ebp
  100fd2:	89 e5                	mov    %esp,%ebp
  100fd4:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100fd7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  100fde:	eb 09                	jmp    100fe9 <lpt_putc_sub+0x18>
        delay();
  100fe0:	e8 d7 fd ff ff       	call   100dbc <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100fe5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  100fe9:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
  100fef:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100ff3:	89 c2                	mov    %eax,%edx
  100ff5:	ec                   	in     (%dx),%al
  100ff6:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
  100ff9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  100ffd:	84 c0                	test   %al,%al
  100fff:	78 09                	js     10100a <lpt_putc_sub+0x39>
  101001:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101008:	7e d6                	jle    100fe0 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  10100a:	8b 45 08             	mov    0x8(%ebp),%eax
  10100d:	0f b6 c0             	movzbl %al,%eax
  101010:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
  101016:	88 45 f0             	mov    %al,-0x10(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101019:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
  10101d:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
  101021:	ee                   	out    %al,(%dx)
  101022:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  101028:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  10102c:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101030:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101034:	ee                   	out    %al,(%dx)
  101035:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
  10103b:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
  10103f:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
  101043:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101047:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  101048:	90                   	nop
  101049:	c9                   	leave  
  10104a:	c3                   	ret    

0010104b <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  10104b:	55                   	push   %ebp
  10104c:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
  10104e:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101052:	74 0d                	je     101061 <lpt_putc+0x16>
        lpt_putc_sub(c);
  101054:	ff 75 08             	pushl  0x8(%ebp)
  101057:	e8 75 ff ff ff       	call   100fd1 <lpt_putc_sub>
  10105c:	83 c4 04             	add    $0x4,%esp
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  10105f:	eb 1e                	jmp    10107f <lpt_putc+0x34>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
  101061:	6a 08                	push   $0x8
  101063:	e8 69 ff ff ff       	call   100fd1 <lpt_putc_sub>
  101068:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub(' ');
  10106b:	6a 20                	push   $0x20
  10106d:	e8 5f ff ff ff       	call   100fd1 <lpt_putc_sub>
  101072:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub('\b');
  101075:	6a 08                	push   $0x8
  101077:	e8 55 ff ff ff       	call   100fd1 <lpt_putc_sub>
  10107c:	83 c4 04             	add    $0x4,%esp
    }
}
  10107f:	90                   	nop
  101080:	c9                   	leave  
  101081:	c3                   	ret    

00101082 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101082:	55                   	push   %ebp
  101083:	89 e5                	mov    %esp,%ebp
  101085:	53                   	push   %ebx
  101086:	83 ec 14             	sub    $0x14,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  101089:	8b 45 08             	mov    0x8(%ebp),%eax
  10108c:	b0 00                	mov    $0x0,%al
  10108e:	85 c0                	test   %eax,%eax
  101090:	75 07                	jne    101099 <cga_putc+0x17>
        c |= 0x0700;
  101092:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101099:	8b 45 08             	mov    0x8(%ebp),%eax
  10109c:	0f b6 c0             	movzbl %al,%eax
  10109f:	83 f8 0a             	cmp    $0xa,%eax
  1010a2:	74 4e                	je     1010f2 <cga_putc+0x70>
  1010a4:	83 f8 0d             	cmp    $0xd,%eax
  1010a7:	74 59                	je     101102 <cga_putc+0x80>
  1010a9:	83 f8 08             	cmp    $0x8,%eax
  1010ac:	0f 85 8a 00 00 00    	jne    10113c <cga_putc+0xba>
    case '\b':
        if (crt_pos > 0) {
  1010b2:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010b9:	66 85 c0             	test   %ax,%ax
  1010bc:	0f 84 a0 00 00 00    	je     101162 <cga_putc+0xe0>
            crt_pos --;
  1010c2:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010c9:	83 e8 01             	sub    $0x1,%eax
  1010cc:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  1010d2:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1010d7:	0f b7 15 64 ee 10 00 	movzwl 0x10ee64,%edx
  1010de:	0f b7 d2             	movzwl %dx,%edx
  1010e1:	01 d2                	add    %edx,%edx
  1010e3:	01 d0                	add    %edx,%eax
  1010e5:	8b 55 08             	mov    0x8(%ebp),%edx
  1010e8:	b2 00                	mov    $0x0,%dl
  1010ea:	83 ca 20             	or     $0x20,%edx
  1010ed:	66 89 10             	mov    %dx,(%eax)
        }
        break;
  1010f0:	eb 70                	jmp    101162 <cga_putc+0xe0>
    case '\n':
        crt_pos += CRT_COLS;
  1010f2:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010f9:	83 c0 50             	add    $0x50,%eax
  1010fc:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101102:	0f b7 1d 64 ee 10 00 	movzwl 0x10ee64,%ebx
  101109:	0f b7 0d 64 ee 10 00 	movzwl 0x10ee64,%ecx
  101110:	0f b7 c1             	movzwl %cx,%eax
  101113:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  101119:	c1 e8 10             	shr    $0x10,%eax
  10111c:	89 c2                	mov    %eax,%edx
  10111e:	66 c1 ea 06          	shr    $0x6,%dx
  101122:	89 d0                	mov    %edx,%eax
  101124:	c1 e0 02             	shl    $0x2,%eax
  101127:	01 d0                	add    %edx,%eax
  101129:	c1 e0 04             	shl    $0x4,%eax
  10112c:	29 c1                	sub    %eax,%ecx
  10112e:	89 ca                	mov    %ecx,%edx
  101130:	89 d8                	mov    %ebx,%eax
  101132:	29 d0                	sub    %edx,%eax
  101134:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
        break;
  10113a:	eb 27                	jmp    101163 <cga_putc+0xe1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  10113c:	8b 0d 60 ee 10 00    	mov    0x10ee60,%ecx
  101142:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101149:	8d 50 01             	lea    0x1(%eax),%edx
  10114c:	66 89 15 64 ee 10 00 	mov    %dx,0x10ee64
  101153:	0f b7 c0             	movzwl %ax,%eax
  101156:	01 c0                	add    %eax,%eax
  101158:	01 c8                	add    %ecx,%eax
  10115a:	8b 55 08             	mov    0x8(%ebp),%edx
  10115d:	66 89 10             	mov    %dx,(%eax)
        break;
  101160:	eb 01                	jmp    101163 <cga_putc+0xe1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
  101162:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101163:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  10116a:	66 3d cf 07          	cmp    $0x7cf,%ax
  10116e:	76 59                	jbe    1011c9 <cga_putc+0x147>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101170:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  101175:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  10117b:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  101180:	83 ec 04             	sub    $0x4,%esp
  101183:	68 00 0f 00 00       	push   $0xf00
  101188:	52                   	push   %edx
  101189:	50                   	push   %eax
  10118a:	e8 6a 1c 00 00       	call   102df9 <memmove>
  10118f:	83 c4 10             	add    $0x10,%esp
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101192:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101199:	eb 15                	jmp    1011b0 <cga_putc+0x12e>
            crt_buf[i] = 0x0700 | ' ';
  10119b:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1011a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1011a3:	01 d2                	add    %edx,%edx
  1011a5:	01 d0                	add    %edx,%eax
  1011a7:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011ac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1011b0:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  1011b7:	7e e2                	jle    10119b <cga_putc+0x119>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  1011b9:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1011c0:	83 e8 50             	sub    $0x50,%eax
  1011c3:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  1011c9:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  1011d0:	0f b7 c0             	movzwl %ax,%eax
  1011d3:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  1011d7:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
  1011db:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
  1011df:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1011e3:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  1011e4:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1011eb:	66 c1 e8 08          	shr    $0x8,%ax
  1011ef:	0f b6 c0             	movzbl %al,%eax
  1011f2:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  1011f9:	83 c2 01             	add    $0x1,%edx
  1011fc:	0f b7 d2             	movzwl %dx,%edx
  1011ff:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
  101203:	88 45 e9             	mov    %al,-0x17(%ebp)
  101206:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  10120a:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
  10120e:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  10120f:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  101216:	0f b7 c0             	movzwl %ax,%eax
  101219:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  10121d:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
  101221:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
  101225:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101229:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  10122a:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101231:	0f b6 c0             	movzbl %al,%eax
  101234:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  10123b:	83 c2 01             	add    $0x1,%edx
  10123e:	0f b7 d2             	movzwl %dx,%edx
  101241:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
  101245:	88 45 eb             	mov    %al,-0x15(%ebp)
  101248:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  10124c:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
  101250:	ee                   	out    %al,(%dx)
}
  101251:	90                   	nop
  101252:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  101255:	c9                   	leave  
  101256:	c3                   	ret    

00101257 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  101257:	55                   	push   %ebp
  101258:	89 e5                	mov    %esp,%ebp
  10125a:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10125d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101264:	eb 09                	jmp    10126f <serial_putc_sub+0x18>
        delay();
  101266:	e8 51 fb ff ff       	call   100dbc <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10126b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10126f:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101275:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
  101279:	89 c2                	mov    %eax,%edx
  10127b:	ec                   	in     (%dx),%al
  10127c:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
  10127f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  101283:	0f b6 c0             	movzbl %al,%eax
  101286:	83 e0 20             	and    $0x20,%eax
  101289:	85 c0                	test   %eax,%eax
  10128b:	75 09                	jne    101296 <serial_putc_sub+0x3f>
  10128d:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101294:	7e d0                	jle    101266 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  101296:	8b 45 08             	mov    0x8(%ebp),%eax
  101299:	0f b6 c0             	movzbl %al,%eax
  10129c:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
  1012a2:	88 45 f6             	mov    %al,-0xa(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012a5:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
  1012a9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1012ad:	ee                   	out    %al,(%dx)
}
  1012ae:	90                   	nop
  1012af:	c9                   	leave  
  1012b0:	c3                   	ret    

001012b1 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  1012b1:	55                   	push   %ebp
  1012b2:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
  1012b4:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1012b8:	74 0d                	je     1012c7 <serial_putc+0x16>
        serial_putc_sub(c);
  1012ba:	ff 75 08             	pushl  0x8(%ebp)
  1012bd:	e8 95 ff ff ff       	call   101257 <serial_putc_sub>
  1012c2:	83 c4 04             	add    $0x4,%esp
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  1012c5:	eb 1e                	jmp    1012e5 <serial_putc+0x34>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
  1012c7:	6a 08                	push   $0x8
  1012c9:	e8 89 ff ff ff       	call   101257 <serial_putc_sub>
  1012ce:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub(' ');
  1012d1:	6a 20                	push   $0x20
  1012d3:	e8 7f ff ff ff       	call   101257 <serial_putc_sub>
  1012d8:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub('\b');
  1012db:	6a 08                	push   $0x8
  1012dd:	e8 75 ff ff ff       	call   101257 <serial_putc_sub>
  1012e2:	83 c4 04             	add    $0x4,%esp
    }
}
  1012e5:	90                   	nop
  1012e6:	c9                   	leave  
  1012e7:	c3                   	ret    

001012e8 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  1012e8:	55                   	push   %ebp
  1012e9:	89 e5                	mov    %esp,%ebp
  1012eb:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  1012ee:	eb 33                	jmp    101323 <cons_intr+0x3b>
        if (c != 0) {
  1012f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1012f4:	74 2d                	je     101323 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  1012f6:	a1 84 f0 10 00       	mov    0x10f084,%eax
  1012fb:	8d 50 01             	lea    0x1(%eax),%edx
  1012fe:	89 15 84 f0 10 00    	mov    %edx,0x10f084
  101304:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101307:	88 90 80 ee 10 00    	mov    %dl,0x10ee80(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  10130d:	a1 84 f0 10 00       	mov    0x10f084,%eax
  101312:	3d 00 02 00 00       	cmp    $0x200,%eax
  101317:	75 0a                	jne    101323 <cons_intr+0x3b>
                cons.wpos = 0;
  101319:	c7 05 84 f0 10 00 00 	movl   $0x0,0x10f084
  101320:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  101323:	8b 45 08             	mov    0x8(%ebp),%eax
  101326:	ff d0                	call   *%eax
  101328:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10132b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  10132f:	75 bf                	jne    1012f0 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  101331:	90                   	nop
  101332:	c9                   	leave  
  101333:	c3                   	ret    

00101334 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  101334:	55                   	push   %ebp
  101335:	89 e5                	mov    %esp,%ebp
  101337:	83 ec 10             	sub    $0x10,%esp
  10133a:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101340:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
  101344:	89 c2                	mov    %eax,%edx
  101346:	ec                   	in     (%dx),%al
  101347:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
  10134a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  10134e:	0f b6 c0             	movzbl %al,%eax
  101351:	83 e0 01             	and    $0x1,%eax
  101354:	85 c0                	test   %eax,%eax
  101356:	75 07                	jne    10135f <serial_proc_data+0x2b>
        return -1;
  101358:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10135d:	eb 2a                	jmp    101389 <serial_proc_data+0x55>
  10135f:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101365:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101369:	89 c2                	mov    %eax,%edx
  10136b:	ec                   	in     (%dx),%al
  10136c:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
  10136f:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101373:	0f b6 c0             	movzbl %al,%eax
  101376:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  101379:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  10137d:	75 07                	jne    101386 <serial_proc_data+0x52>
        c = '\b';
  10137f:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101386:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101389:	c9                   	leave  
  10138a:	c3                   	ret    

0010138b <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  10138b:	55                   	push   %ebp
  10138c:	89 e5                	mov    %esp,%ebp
  10138e:	83 ec 08             	sub    $0x8,%esp
    if (serial_exists) {
  101391:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  101396:	85 c0                	test   %eax,%eax
  101398:	74 10                	je     1013aa <serial_intr+0x1f>
        cons_intr(serial_proc_data);
  10139a:	83 ec 0c             	sub    $0xc,%esp
  10139d:	68 34 13 10 00       	push   $0x101334
  1013a2:	e8 41 ff ff ff       	call   1012e8 <cons_intr>
  1013a7:	83 c4 10             	add    $0x10,%esp
    }
}
  1013aa:	90                   	nop
  1013ab:	c9                   	leave  
  1013ac:	c3                   	ret    

001013ad <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  1013ad:	55                   	push   %ebp
  1013ae:	89 e5                	mov    %esp,%ebp
  1013b0:	83 ec 18             	sub    $0x18,%esp
  1013b3:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013b9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1013bd:	89 c2                	mov    %eax,%edx
  1013bf:	ec                   	in     (%dx),%al
  1013c0:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  1013c3:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1013c7:	0f b6 c0             	movzbl %al,%eax
  1013ca:	83 e0 01             	and    $0x1,%eax
  1013cd:	85 c0                	test   %eax,%eax
  1013cf:	75 0a                	jne    1013db <kbd_proc_data+0x2e>
        return -1;
  1013d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013d6:	e9 5d 01 00 00       	jmp    101538 <kbd_proc_data+0x18b>
  1013db:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013e1:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1013e5:	89 c2                	mov    %eax,%edx
  1013e7:	ec                   	in     (%dx),%al
  1013e8:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
  1013eb:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
  1013ef:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  1013f2:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  1013f6:	75 17                	jne    10140f <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  1013f8:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1013fd:	83 c8 40             	or     $0x40,%eax
  101400:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101405:	b8 00 00 00 00       	mov    $0x0,%eax
  10140a:	e9 29 01 00 00       	jmp    101538 <kbd_proc_data+0x18b>
    } else if (data & 0x80) {
  10140f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101413:	84 c0                	test   %al,%al
  101415:	79 47                	jns    10145e <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  101417:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10141c:	83 e0 40             	and    $0x40,%eax
  10141f:	85 c0                	test   %eax,%eax
  101421:	75 09                	jne    10142c <kbd_proc_data+0x7f>
  101423:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101427:	83 e0 7f             	and    $0x7f,%eax
  10142a:	eb 04                	jmp    101430 <kbd_proc_data+0x83>
  10142c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101430:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  101433:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101437:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  10143e:	83 c8 40             	or     $0x40,%eax
  101441:	0f b6 c0             	movzbl %al,%eax
  101444:	f7 d0                	not    %eax
  101446:	89 c2                	mov    %eax,%edx
  101448:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10144d:	21 d0                	and    %edx,%eax
  10144f:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101454:	b8 00 00 00 00       	mov    $0x0,%eax
  101459:	e9 da 00 00 00       	jmp    101538 <kbd_proc_data+0x18b>
    } else if (shift & E0ESC) {
  10145e:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101463:	83 e0 40             	and    $0x40,%eax
  101466:	85 c0                	test   %eax,%eax
  101468:	74 11                	je     10147b <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  10146a:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  10146e:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101473:	83 e0 bf             	and    $0xffffffbf,%eax
  101476:	a3 88 f0 10 00       	mov    %eax,0x10f088
    }

    shift |= shiftcode[data];
  10147b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10147f:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  101486:	0f b6 d0             	movzbl %al,%edx
  101489:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10148e:	09 d0                	or     %edx,%eax
  101490:	a3 88 f0 10 00       	mov    %eax,0x10f088
    shift ^= togglecode[data];
  101495:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101499:	0f b6 80 40 e1 10 00 	movzbl 0x10e140(%eax),%eax
  1014a0:	0f b6 d0             	movzbl %al,%edx
  1014a3:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014a8:	31 d0                	xor    %edx,%eax
  1014aa:	a3 88 f0 10 00       	mov    %eax,0x10f088

    c = charcode[shift & (CTL | SHIFT)][data];
  1014af:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014b4:	83 e0 03             	and    $0x3,%eax
  1014b7:	8b 14 85 40 e5 10 00 	mov    0x10e540(,%eax,4),%edx
  1014be:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014c2:	01 d0                	add    %edx,%eax
  1014c4:	0f b6 00             	movzbl (%eax),%eax
  1014c7:	0f b6 c0             	movzbl %al,%eax
  1014ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1014cd:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014d2:	83 e0 08             	and    $0x8,%eax
  1014d5:	85 c0                	test   %eax,%eax
  1014d7:	74 22                	je     1014fb <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  1014d9:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  1014dd:	7e 0c                	jle    1014eb <kbd_proc_data+0x13e>
  1014df:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  1014e3:	7f 06                	jg     1014eb <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  1014e5:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  1014e9:	eb 10                	jmp    1014fb <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  1014eb:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  1014ef:	7e 0a                	jle    1014fb <kbd_proc_data+0x14e>
  1014f1:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  1014f5:	7f 04                	jg     1014fb <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  1014f7:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  1014fb:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101500:	f7 d0                	not    %eax
  101502:	83 e0 06             	and    $0x6,%eax
  101505:	85 c0                	test   %eax,%eax
  101507:	75 2c                	jne    101535 <kbd_proc_data+0x188>
  101509:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101510:	75 23                	jne    101535 <kbd_proc_data+0x188>
        cprintf("Rebooting!\n");
  101512:	83 ec 0c             	sub    $0xc,%esp
  101515:	68 8d 38 10 00       	push   $0x10388d
  10151a:	e8 2e ed ff ff       	call   10024d <cprintf>
  10151f:	83 c4 10             	add    $0x10,%esp
  101522:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
  101528:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10152c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101530:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101534:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  101535:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101538:	c9                   	leave  
  101539:	c3                   	ret    

0010153a <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  10153a:	55                   	push   %ebp
  10153b:	89 e5                	mov    %esp,%ebp
  10153d:	83 ec 08             	sub    $0x8,%esp
    cons_intr(kbd_proc_data);
  101540:	83 ec 0c             	sub    $0xc,%esp
  101543:	68 ad 13 10 00       	push   $0x1013ad
  101548:	e8 9b fd ff ff       	call   1012e8 <cons_intr>
  10154d:	83 c4 10             	add    $0x10,%esp
}
  101550:	90                   	nop
  101551:	c9                   	leave  
  101552:	c3                   	ret    

00101553 <kbd_init>:

static void
kbd_init(void) {
  101553:	55                   	push   %ebp
  101554:	89 e5                	mov    %esp,%ebp
  101556:	83 ec 08             	sub    $0x8,%esp
    // drain the kbd buffer
    kbd_intr();
  101559:	e8 dc ff ff ff       	call   10153a <kbd_intr>
    pic_enable(IRQ_KBD);
  10155e:	83 ec 0c             	sub    $0xc,%esp
  101561:	6a 01                	push   $0x1
  101563:	e8 1c 01 00 00       	call   101684 <pic_enable>
  101568:	83 c4 10             	add    $0x10,%esp
}
  10156b:	90                   	nop
  10156c:	c9                   	leave  
  10156d:	c3                   	ret    

0010156e <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  10156e:	55                   	push   %ebp
  10156f:	89 e5                	mov    %esp,%ebp
  101571:	83 ec 08             	sub    $0x8,%esp
    cga_init();
  101574:	e8 8c f8 ff ff       	call   100e05 <cga_init>
    serial_init();
  101579:	e8 6e f9 ff ff       	call   100eec <serial_init>
    kbd_init();
  10157e:	e8 d0 ff ff ff       	call   101553 <kbd_init>
    if (!serial_exists) {
  101583:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  101588:	85 c0                	test   %eax,%eax
  10158a:	75 10                	jne    10159c <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
  10158c:	83 ec 0c             	sub    $0xc,%esp
  10158f:	68 99 38 10 00       	push   $0x103899
  101594:	e8 b4 ec ff ff       	call   10024d <cprintf>
  101599:	83 c4 10             	add    $0x10,%esp
    }
}
  10159c:	90                   	nop
  10159d:	c9                   	leave  
  10159e:	c3                   	ret    

0010159f <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  10159f:	55                   	push   %ebp
  1015a0:	89 e5                	mov    %esp,%ebp
  1015a2:	83 ec 08             	sub    $0x8,%esp
    lpt_putc(c);
  1015a5:	ff 75 08             	pushl  0x8(%ebp)
  1015a8:	e8 9e fa ff ff       	call   10104b <lpt_putc>
  1015ad:	83 c4 04             	add    $0x4,%esp
    cga_putc(c);
  1015b0:	83 ec 0c             	sub    $0xc,%esp
  1015b3:	ff 75 08             	pushl  0x8(%ebp)
  1015b6:	e8 c7 fa ff ff       	call   101082 <cga_putc>
  1015bb:	83 c4 10             	add    $0x10,%esp
    serial_putc(c);
  1015be:	83 ec 0c             	sub    $0xc,%esp
  1015c1:	ff 75 08             	pushl  0x8(%ebp)
  1015c4:	e8 e8 fc ff ff       	call   1012b1 <serial_putc>
  1015c9:	83 c4 10             	add    $0x10,%esp
}
  1015cc:	90                   	nop
  1015cd:	c9                   	leave  
  1015ce:	c3                   	ret    

001015cf <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1015cf:	55                   	push   %ebp
  1015d0:	89 e5                	mov    %esp,%ebp
  1015d2:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  1015d5:	e8 b1 fd ff ff       	call   10138b <serial_intr>
    kbd_intr();
  1015da:	e8 5b ff ff ff       	call   10153a <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  1015df:	8b 15 80 f0 10 00    	mov    0x10f080,%edx
  1015e5:	a1 84 f0 10 00       	mov    0x10f084,%eax
  1015ea:	39 c2                	cmp    %eax,%edx
  1015ec:	74 36                	je     101624 <cons_getc+0x55>
        c = cons.buf[cons.rpos ++];
  1015ee:	a1 80 f0 10 00       	mov    0x10f080,%eax
  1015f3:	8d 50 01             	lea    0x1(%eax),%edx
  1015f6:	89 15 80 f0 10 00    	mov    %edx,0x10f080
  1015fc:	0f b6 80 80 ee 10 00 	movzbl 0x10ee80(%eax),%eax
  101603:	0f b6 c0             	movzbl %al,%eax
  101606:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  101609:	a1 80 f0 10 00       	mov    0x10f080,%eax
  10160e:	3d 00 02 00 00       	cmp    $0x200,%eax
  101613:	75 0a                	jne    10161f <cons_getc+0x50>
            cons.rpos = 0;
  101615:	c7 05 80 f0 10 00 00 	movl   $0x0,0x10f080
  10161c:	00 00 00 
        }
        return c;
  10161f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101622:	eb 05                	jmp    101629 <cons_getc+0x5a>
    }
    return 0;
  101624:	b8 00 00 00 00       	mov    $0x0,%eax
}
  101629:	c9                   	leave  
  10162a:	c3                   	ret    

0010162b <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  10162b:	55                   	push   %ebp
  10162c:	89 e5                	mov    %esp,%ebp
  10162e:	83 ec 14             	sub    $0x14,%esp
  101631:	8b 45 08             	mov    0x8(%ebp),%eax
  101634:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  101638:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10163c:	66 a3 50 e5 10 00    	mov    %ax,0x10e550
    if (did_init) {
  101642:	a1 8c f0 10 00       	mov    0x10f08c,%eax
  101647:	85 c0                	test   %eax,%eax
  101649:	74 36                	je     101681 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  10164b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10164f:	0f b6 c0             	movzbl %al,%eax
  101652:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101658:	88 45 fa             	mov    %al,-0x6(%ebp)
  10165b:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
  10165f:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101663:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  101664:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101668:	66 c1 e8 08          	shr    $0x8,%ax
  10166c:	0f b6 c0             	movzbl %al,%eax
  10166f:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
  101675:	88 45 fb             	mov    %al,-0x5(%ebp)
  101678:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  10167c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
  101680:	ee                   	out    %al,(%dx)
    }
}
  101681:	90                   	nop
  101682:	c9                   	leave  
  101683:	c3                   	ret    

00101684 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101684:	55                   	push   %ebp
  101685:	89 e5                	mov    %esp,%ebp
    pic_setmask(irq_mask & ~(1 << irq));
  101687:	8b 45 08             	mov    0x8(%ebp),%eax
  10168a:	ba 01 00 00 00       	mov    $0x1,%edx
  10168f:	89 c1                	mov    %eax,%ecx
  101691:	d3 e2                	shl    %cl,%edx
  101693:	89 d0                	mov    %edx,%eax
  101695:	f7 d0                	not    %eax
  101697:	89 c2                	mov    %eax,%edx
  101699:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1016a0:	21 d0                	and    %edx,%eax
  1016a2:	0f b7 c0             	movzwl %ax,%eax
  1016a5:	50                   	push   %eax
  1016a6:	e8 80 ff ff ff       	call   10162b <pic_setmask>
  1016ab:	83 c4 04             	add    $0x4,%esp
}
  1016ae:	90                   	nop
  1016af:	c9                   	leave  
  1016b0:	c3                   	ret    

001016b1 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1016b1:	55                   	push   %ebp
  1016b2:	89 e5                	mov    %esp,%ebp
  1016b4:	83 ec 30             	sub    $0x30,%esp
    did_init = 1;
  1016b7:	c7 05 8c f0 10 00 01 	movl   $0x1,0x10f08c
  1016be:	00 00 00 
  1016c1:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016c7:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
  1016cb:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
  1016cf:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1016d3:	ee                   	out    %al,(%dx)
  1016d4:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
  1016da:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
  1016de:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
  1016e2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
  1016e6:	ee                   	out    %al,(%dx)
  1016e7:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
  1016ed:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
  1016f1:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
  1016f5:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1016f9:	ee                   	out    %al,(%dx)
  1016fa:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
  101700:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
  101704:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101708:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
  10170c:	ee                   	out    %al,(%dx)
  10170d:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
  101713:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
  101717:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
  10171b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10171f:	ee                   	out    %al,(%dx)
  101720:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
  101726:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
  10172a:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  10172e:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
  101732:	ee                   	out    %al,(%dx)
  101733:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
  101739:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
  10173d:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  101741:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101745:	ee                   	out    %al,(%dx)
  101746:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
  10174c:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
  101750:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101754:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
  101758:	ee                   	out    %al,(%dx)
  101759:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  10175f:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
  101763:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
  101767:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10176b:	ee                   	out    %al,(%dx)
  10176c:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
  101772:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
  101776:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  10177a:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
  10177e:	ee                   	out    %al,(%dx)
  10177f:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
  101785:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
  101789:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  10178d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101791:	ee                   	out    %al,(%dx)
  101792:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
  101798:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
  10179c:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  1017a0:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  1017a4:	ee                   	out    %al,(%dx)
  1017a5:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  1017ab:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
  1017af:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
  1017b3:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1017b7:	ee                   	out    %al,(%dx)
  1017b8:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
  1017be:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
  1017c2:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  1017c6:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
  1017ca:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1017cb:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017d2:	66 83 f8 ff          	cmp    $0xffff,%ax
  1017d6:	74 13                	je     1017eb <pic_init+0x13a>
        pic_setmask(irq_mask);
  1017d8:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017df:	0f b7 c0             	movzwl %ax,%eax
  1017e2:	50                   	push   %eax
  1017e3:	e8 43 fe ff ff       	call   10162b <pic_setmask>
  1017e8:	83 c4 04             	add    $0x4,%esp
    }
}
  1017eb:	90                   	nop
  1017ec:	c9                   	leave  
  1017ed:	c3                   	ret    

001017ee <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1017ee:	55                   	push   %ebp
  1017ef:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  1017f1:	fb                   	sti    
    sti();
}
  1017f2:	90                   	nop
  1017f3:	5d                   	pop    %ebp
  1017f4:	c3                   	ret    

001017f5 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  1017f5:	55                   	push   %ebp
  1017f6:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli");
  1017f8:	fa                   	cli    
    cli();
}
  1017f9:	90                   	nop
  1017fa:	5d                   	pop    %ebp
  1017fb:	c3                   	ret    

001017fc <print_ticks>:
#include <console.h>
#include <kdebug.h>
#include <string.h>
#define TICK_NUM 100

static void print_ticks() {
  1017fc:	55                   	push   %ebp
  1017fd:	89 e5                	mov    %esp,%ebp
  1017ff:	83 ec 08             	sub    $0x8,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101802:	83 ec 08             	sub    $0x8,%esp
  101805:	6a 64                	push   $0x64
  101807:	68 c0 38 10 00       	push   $0x1038c0
  10180c:	e8 3c ea ff ff       	call   10024d <cprintf>
  101811:	83 c4 10             	add    $0x10,%esp
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  101814:	90                   	nop
  101815:	c9                   	leave  
  101816:	c3                   	ret    

00101817 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  101817:	55                   	push   %ebp
  101818:	89 e5                	mov    %esp,%ebp
  10181a:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  10181d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101824:	e9 c3 00 00 00       	jmp    1018ec <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  101829:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10182c:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  101833:	89 c2                	mov    %eax,%edx
  101835:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101838:	66 89 14 c5 a0 f0 10 	mov    %dx,0x10f0a0(,%eax,8)
  10183f:	00 
  101840:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101843:	66 c7 04 c5 a2 f0 10 	movw   $0x8,0x10f0a2(,%eax,8)
  10184a:	00 08 00 
  10184d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101850:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  101857:	00 
  101858:	83 e2 e0             	and    $0xffffffe0,%edx
  10185b:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  101862:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101865:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  10186c:	00 
  10186d:	83 e2 1f             	and    $0x1f,%edx
  101870:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  101877:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10187a:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  101881:	00 
  101882:	83 e2 f0             	and    $0xfffffff0,%edx
  101885:	83 ca 0e             	or     $0xe,%edx
  101888:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  10188f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101892:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  101899:	00 
  10189a:	83 e2 ef             	and    $0xffffffef,%edx
  10189d:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018a7:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018ae:	00 
  1018af:	83 e2 9f             	and    $0xffffff9f,%edx
  1018b2:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018bc:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018c3:	00 
  1018c4:	83 ca 80             	or     $0xffffff80,%edx
  1018c7:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d1:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  1018d8:	c1 e8 10             	shr    $0x10,%eax
  1018db:	89 c2                	mov    %eax,%edx
  1018dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e0:	66 89 14 c5 a6 f0 10 	mov    %dx,0x10f0a6(,%eax,8)
  1018e7:	00 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  1018e8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1018ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018ef:	3d ff 00 00 00       	cmp    $0xff,%eax
  1018f4:	0f 86 2f ff ff ff    	jbe    101829 <idt_init+0x12>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
	// set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  1018fa:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  1018ff:	66 a3 68 f4 10 00    	mov    %ax,0x10f468
  101905:	66 c7 05 6a f4 10 00 	movw   $0x8,0x10f46a
  10190c:	08 00 
  10190e:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  101915:	83 e0 e0             	and    $0xffffffe0,%eax
  101918:	a2 6c f4 10 00       	mov    %al,0x10f46c
  10191d:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  101924:	83 e0 1f             	and    $0x1f,%eax
  101927:	a2 6c f4 10 00       	mov    %al,0x10f46c
  10192c:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101933:	83 e0 f0             	and    $0xfffffff0,%eax
  101936:	83 c8 0e             	or     $0xe,%eax
  101939:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10193e:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101945:	83 e0 ef             	and    $0xffffffef,%eax
  101948:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10194d:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101954:	83 c8 60             	or     $0x60,%eax
  101957:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10195c:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101963:	83 c8 80             	or     $0xffffff80,%eax
  101966:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10196b:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  101970:	c1 e8 10             	shr    $0x10,%eax
  101973:	66 a3 6e f4 10 00    	mov    %ax,0x10f46e
  101979:	c7 45 f8 60 e5 10 00 	movl   $0x10e560,-0x8(%ebp)
    return ebp;
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd));
  101980:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101983:	0f 01 18             	lidtl  (%eax)
	// load the IDT
    lidt(&idt_pd);
}
  101986:	90                   	nop
  101987:	c9                   	leave  
  101988:	c3                   	ret    

00101989 <trapname>:

static const char *
trapname(int trapno) {
  101989:	55                   	push   %ebp
  10198a:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  10198c:	8b 45 08             	mov    0x8(%ebp),%eax
  10198f:	83 f8 13             	cmp    $0x13,%eax
  101992:	77 0c                	ja     1019a0 <trapname+0x17>
        return excnames[trapno];
  101994:	8b 45 08             	mov    0x8(%ebp),%eax
  101997:	8b 04 85 20 3c 10 00 	mov    0x103c20(,%eax,4),%eax
  10199e:	eb 18                	jmp    1019b8 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  1019a0:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  1019a4:	7e 0d                	jle    1019b3 <trapname+0x2a>
  1019a6:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  1019aa:	7f 07                	jg     1019b3 <trapname+0x2a>
        return "Hardware Interrupt";
  1019ac:	b8 ca 38 10 00       	mov    $0x1038ca,%eax
  1019b1:	eb 05                	jmp    1019b8 <trapname+0x2f>
    }
    return "(unknown trap)";
  1019b3:	b8 dd 38 10 00       	mov    $0x1038dd,%eax
}
  1019b8:	5d                   	pop    %ebp
  1019b9:	c3                   	ret    

001019ba <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  1019ba:	55                   	push   %ebp
  1019bb:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  1019bd:	8b 45 08             	mov    0x8(%ebp),%eax
  1019c0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1019c4:	66 83 f8 08          	cmp    $0x8,%ax
  1019c8:	0f 94 c0             	sete   %al
  1019cb:	0f b6 c0             	movzbl %al,%eax
}
  1019ce:	5d                   	pop    %ebp
  1019cf:	c3                   	ret    

001019d0 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  1019d0:	55                   	push   %ebp
  1019d1:	89 e5                	mov    %esp,%ebp
  1019d3:	83 ec 18             	sub    $0x18,%esp
    cprintf("trapframe at %p\n", tf);
  1019d6:	83 ec 08             	sub    $0x8,%esp
  1019d9:	ff 75 08             	pushl  0x8(%ebp)
  1019dc:	68 1e 39 10 00       	push   $0x10391e
  1019e1:	e8 67 e8 ff ff       	call   10024d <cprintf>
  1019e6:	83 c4 10             	add    $0x10,%esp
    print_regs(&tf->tf_regs);
  1019e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1019ec:	83 ec 0c             	sub    $0xc,%esp
  1019ef:	50                   	push   %eax
  1019f0:	e8 b8 01 00 00       	call   101bad <print_regs>
  1019f5:	83 c4 10             	add    $0x10,%esp
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  1019f8:	8b 45 08             	mov    0x8(%ebp),%eax
  1019fb:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  1019ff:	0f b7 c0             	movzwl %ax,%eax
  101a02:	83 ec 08             	sub    $0x8,%esp
  101a05:	50                   	push   %eax
  101a06:	68 2f 39 10 00       	push   $0x10392f
  101a0b:	e8 3d e8 ff ff       	call   10024d <cprintf>
  101a10:	83 c4 10             	add    $0x10,%esp
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a13:	8b 45 08             	mov    0x8(%ebp),%eax
  101a16:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a1a:	0f b7 c0             	movzwl %ax,%eax
  101a1d:	83 ec 08             	sub    $0x8,%esp
  101a20:	50                   	push   %eax
  101a21:	68 42 39 10 00       	push   $0x103942
  101a26:	e8 22 e8 ff ff       	call   10024d <cprintf>
  101a2b:	83 c4 10             	add    $0x10,%esp
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  101a31:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101a35:	0f b7 c0             	movzwl %ax,%eax
  101a38:	83 ec 08             	sub    $0x8,%esp
  101a3b:	50                   	push   %eax
  101a3c:	68 55 39 10 00       	push   $0x103955
  101a41:	e8 07 e8 ff ff       	call   10024d <cprintf>
  101a46:	83 c4 10             	add    $0x10,%esp
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101a49:	8b 45 08             	mov    0x8(%ebp),%eax
  101a4c:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101a50:	0f b7 c0             	movzwl %ax,%eax
  101a53:	83 ec 08             	sub    $0x8,%esp
  101a56:	50                   	push   %eax
  101a57:	68 68 39 10 00       	push   $0x103968
  101a5c:	e8 ec e7 ff ff       	call   10024d <cprintf>
  101a61:	83 c4 10             	add    $0x10,%esp
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101a64:	8b 45 08             	mov    0x8(%ebp),%eax
  101a67:	8b 40 30             	mov    0x30(%eax),%eax
  101a6a:	83 ec 0c             	sub    $0xc,%esp
  101a6d:	50                   	push   %eax
  101a6e:	e8 16 ff ff ff       	call   101989 <trapname>
  101a73:	83 c4 10             	add    $0x10,%esp
  101a76:	89 c2                	mov    %eax,%edx
  101a78:	8b 45 08             	mov    0x8(%ebp),%eax
  101a7b:	8b 40 30             	mov    0x30(%eax),%eax
  101a7e:	83 ec 04             	sub    $0x4,%esp
  101a81:	52                   	push   %edx
  101a82:	50                   	push   %eax
  101a83:	68 7b 39 10 00       	push   $0x10397b
  101a88:	e8 c0 e7 ff ff       	call   10024d <cprintf>
  101a8d:	83 c4 10             	add    $0x10,%esp
    cprintf("  err  0x%08x\n", tf->tf_err);
  101a90:	8b 45 08             	mov    0x8(%ebp),%eax
  101a93:	8b 40 34             	mov    0x34(%eax),%eax
  101a96:	83 ec 08             	sub    $0x8,%esp
  101a99:	50                   	push   %eax
  101a9a:	68 8d 39 10 00       	push   $0x10398d
  101a9f:	e8 a9 e7 ff ff       	call   10024d <cprintf>
  101aa4:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  101aaa:	8b 40 38             	mov    0x38(%eax),%eax
  101aad:	83 ec 08             	sub    $0x8,%esp
  101ab0:	50                   	push   %eax
  101ab1:	68 9c 39 10 00       	push   $0x10399c
  101ab6:	e8 92 e7 ff ff       	call   10024d <cprintf>
  101abb:	83 c4 10             	add    $0x10,%esp
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101abe:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac1:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ac5:	0f b7 c0             	movzwl %ax,%eax
  101ac8:	83 ec 08             	sub    $0x8,%esp
  101acb:	50                   	push   %eax
  101acc:	68 ab 39 10 00       	push   $0x1039ab
  101ad1:	e8 77 e7 ff ff       	call   10024d <cprintf>
  101ad6:	83 c4 10             	add    $0x10,%esp
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  101adc:	8b 40 40             	mov    0x40(%eax),%eax
  101adf:	83 ec 08             	sub    $0x8,%esp
  101ae2:	50                   	push   %eax
  101ae3:	68 be 39 10 00       	push   $0x1039be
  101ae8:	e8 60 e7 ff ff       	call   10024d <cprintf>
  101aed:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101af0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101af7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101afe:	eb 3f                	jmp    101b3f <print_trapframe+0x16f>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b00:	8b 45 08             	mov    0x8(%ebp),%eax
  101b03:	8b 50 40             	mov    0x40(%eax),%edx
  101b06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b09:	21 d0                	and    %edx,%eax
  101b0b:	85 c0                	test   %eax,%eax
  101b0d:	74 29                	je     101b38 <print_trapframe+0x168>
  101b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b12:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b19:	85 c0                	test   %eax,%eax
  101b1b:	74 1b                	je     101b38 <print_trapframe+0x168>
            cprintf("%s,", IA32flags[i]);
  101b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b20:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b27:	83 ec 08             	sub    $0x8,%esp
  101b2a:	50                   	push   %eax
  101b2b:	68 cd 39 10 00       	push   $0x1039cd
  101b30:	e8 18 e7 ff ff       	call   10024d <cprintf>
  101b35:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b38:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101b3c:	d1 65 f0             	shll   -0x10(%ebp)
  101b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b42:	83 f8 17             	cmp    $0x17,%eax
  101b45:	76 b9                	jbe    101b00 <print_trapframe+0x130>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101b47:	8b 45 08             	mov    0x8(%ebp),%eax
  101b4a:	8b 40 40             	mov    0x40(%eax),%eax
  101b4d:	25 00 30 00 00       	and    $0x3000,%eax
  101b52:	c1 e8 0c             	shr    $0xc,%eax
  101b55:	83 ec 08             	sub    $0x8,%esp
  101b58:	50                   	push   %eax
  101b59:	68 d1 39 10 00       	push   $0x1039d1
  101b5e:	e8 ea e6 ff ff       	call   10024d <cprintf>
  101b63:	83 c4 10             	add    $0x10,%esp

    if (!trap_in_kernel(tf)) {
  101b66:	83 ec 0c             	sub    $0xc,%esp
  101b69:	ff 75 08             	pushl  0x8(%ebp)
  101b6c:	e8 49 fe ff ff       	call   1019ba <trap_in_kernel>
  101b71:	83 c4 10             	add    $0x10,%esp
  101b74:	85 c0                	test   %eax,%eax
  101b76:	75 32                	jne    101baa <print_trapframe+0x1da>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101b78:	8b 45 08             	mov    0x8(%ebp),%eax
  101b7b:	8b 40 44             	mov    0x44(%eax),%eax
  101b7e:	83 ec 08             	sub    $0x8,%esp
  101b81:	50                   	push   %eax
  101b82:	68 da 39 10 00       	push   $0x1039da
  101b87:	e8 c1 e6 ff ff       	call   10024d <cprintf>
  101b8c:	83 c4 10             	add    $0x10,%esp
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  101b92:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101b96:	0f b7 c0             	movzwl %ax,%eax
  101b99:	83 ec 08             	sub    $0x8,%esp
  101b9c:	50                   	push   %eax
  101b9d:	68 e9 39 10 00       	push   $0x1039e9
  101ba2:	e8 a6 e6 ff ff       	call   10024d <cprintf>
  101ba7:	83 c4 10             	add    $0x10,%esp
    }
}
  101baa:	90                   	nop
  101bab:	c9                   	leave  
  101bac:	c3                   	ret    

00101bad <print_regs>:

void
print_regs(struct pushregs *regs) {
  101bad:	55                   	push   %ebp
  101bae:	89 e5                	mov    %esp,%ebp
  101bb0:	83 ec 08             	sub    $0x8,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101bb3:	8b 45 08             	mov    0x8(%ebp),%eax
  101bb6:	8b 00                	mov    (%eax),%eax
  101bb8:	83 ec 08             	sub    $0x8,%esp
  101bbb:	50                   	push   %eax
  101bbc:	68 fc 39 10 00       	push   $0x1039fc
  101bc1:	e8 87 e6 ff ff       	call   10024d <cprintf>
  101bc6:	83 c4 10             	add    $0x10,%esp
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  101bcc:	8b 40 04             	mov    0x4(%eax),%eax
  101bcf:	83 ec 08             	sub    $0x8,%esp
  101bd2:	50                   	push   %eax
  101bd3:	68 0b 3a 10 00       	push   $0x103a0b
  101bd8:	e8 70 e6 ff ff       	call   10024d <cprintf>
  101bdd:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101be0:	8b 45 08             	mov    0x8(%ebp),%eax
  101be3:	8b 40 08             	mov    0x8(%eax),%eax
  101be6:	83 ec 08             	sub    $0x8,%esp
  101be9:	50                   	push   %eax
  101bea:	68 1a 3a 10 00       	push   $0x103a1a
  101bef:	e8 59 e6 ff ff       	call   10024d <cprintf>
  101bf4:	83 c4 10             	add    $0x10,%esp
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101bf7:	8b 45 08             	mov    0x8(%ebp),%eax
  101bfa:	8b 40 0c             	mov    0xc(%eax),%eax
  101bfd:	83 ec 08             	sub    $0x8,%esp
  101c00:	50                   	push   %eax
  101c01:	68 29 3a 10 00       	push   $0x103a29
  101c06:	e8 42 e6 ff ff       	call   10024d <cprintf>
  101c0b:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  101c11:	8b 40 10             	mov    0x10(%eax),%eax
  101c14:	83 ec 08             	sub    $0x8,%esp
  101c17:	50                   	push   %eax
  101c18:	68 38 3a 10 00       	push   $0x103a38
  101c1d:	e8 2b e6 ff ff       	call   10024d <cprintf>
  101c22:	83 c4 10             	add    $0x10,%esp
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c25:	8b 45 08             	mov    0x8(%ebp),%eax
  101c28:	8b 40 14             	mov    0x14(%eax),%eax
  101c2b:	83 ec 08             	sub    $0x8,%esp
  101c2e:	50                   	push   %eax
  101c2f:	68 47 3a 10 00       	push   $0x103a47
  101c34:	e8 14 e6 ff ff       	call   10024d <cprintf>
  101c39:	83 c4 10             	add    $0x10,%esp
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c3f:	8b 40 18             	mov    0x18(%eax),%eax
  101c42:	83 ec 08             	sub    $0x8,%esp
  101c45:	50                   	push   %eax
  101c46:	68 56 3a 10 00       	push   $0x103a56
  101c4b:	e8 fd e5 ff ff       	call   10024d <cprintf>
  101c50:	83 c4 10             	add    $0x10,%esp
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101c53:	8b 45 08             	mov    0x8(%ebp),%eax
  101c56:	8b 40 1c             	mov    0x1c(%eax),%eax
  101c59:	83 ec 08             	sub    $0x8,%esp
  101c5c:	50                   	push   %eax
  101c5d:	68 65 3a 10 00       	push   $0x103a65
  101c62:	e8 e6 e5 ff ff       	call   10024d <cprintf>
  101c67:	83 c4 10             	add    $0x10,%esp
}
  101c6a:	90                   	nop
  101c6b:	c9                   	leave  
  101c6c:	c3                   	ret    

00101c6d <trap_dispatch>:
/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101c6d:	55                   	push   %ebp
  101c6e:	89 e5                	mov    %esp,%ebp
  101c70:	57                   	push   %edi
  101c71:	56                   	push   %esi
  101c72:	53                   	push   %ebx
  101c73:	83 ec 1c             	sub    $0x1c,%esp
    char c;

    switch (tf->tf_trapno) {
  101c76:	8b 45 08             	mov    0x8(%ebp),%eax
  101c79:	8b 40 30             	mov    0x30(%eax),%eax
  101c7c:	83 f8 2f             	cmp    $0x2f,%eax
  101c7f:	77 21                	ja     101ca2 <trap_dispatch+0x35>
  101c81:	83 f8 2e             	cmp    $0x2e,%eax
  101c84:	0f 83 ff 01 00 00    	jae    101e89 <trap_dispatch+0x21c>
  101c8a:	83 f8 21             	cmp    $0x21,%eax
  101c8d:	0f 84 87 00 00 00    	je     101d1a <trap_dispatch+0xad>
  101c93:	83 f8 24             	cmp    $0x24,%eax
  101c96:	74 5b                	je     101cf3 <trap_dispatch+0x86>
  101c98:	83 f8 20             	cmp    $0x20,%eax
  101c9b:	74 1c                	je     101cb9 <trap_dispatch+0x4c>
  101c9d:	e9 b1 01 00 00       	jmp    101e53 <trap_dispatch+0x1e6>
  101ca2:	83 f8 78             	cmp    $0x78,%eax
  101ca5:	0f 84 96 00 00 00    	je     101d41 <trap_dispatch+0xd4>
  101cab:	83 f8 79             	cmp    $0x79,%eax
  101cae:	0f 84 29 01 00 00    	je     101ddd <trap_dispatch+0x170>
  101cb4:	e9 9a 01 00 00       	jmp    101e53 <trap_dispatch+0x1e6>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101cb9:	a1 08 f9 10 00       	mov    0x10f908,%eax
  101cbe:	83 c0 01             	add    $0x1,%eax
  101cc1:	a3 08 f9 10 00       	mov    %eax,0x10f908
        if (ticks % TICK_NUM == 0) {
  101cc6:	8b 0d 08 f9 10 00    	mov    0x10f908,%ecx
  101ccc:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101cd1:	89 c8                	mov    %ecx,%eax
  101cd3:	f7 e2                	mul    %edx
  101cd5:	89 d0                	mov    %edx,%eax
  101cd7:	c1 e8 05             	shr    $0x5,%eax
  101cda:	6b c0 64             	imul   $0x64,%eax,%eax
  101cdd:	29 c1                	sub    %eax,%ecx
  101cdf:	89 c8                	mov    %ecx,%eax
  101ce1:	85 c0                	test   %eax,%eax
  101ce3:	0f 85 a3 01 00 00    	jne    101e8c <trap_dispatch+0x21f>
            print_ticks();
  101ce9:	e8 0e fb ff ff       	call   1017fc <print_ticks>
        }
        break;
  101cee:	e9 99 01 00 00       	jmp    101e8c <trap_dispatch+0x21f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101cf3:	e8 d7 f8 ff ff       	call   1015cf <cons_getc>
  101cf8:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101cfb:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101cff:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101d03:	83 ec 04             	sub    $0x4,%esp
  101d06:	52                   	push   %edx
  101d07:	50                   	push   %eax
  101d08:	68 74 3a 10 00       	push   $0x103a74
  101d0d:	e8 3b e5 ff ff       	call   10024d <cprintf>
  101d12:	83 c4 10             	add    $0x10,%esp
        break;
  101d15:	e9 79 01 00 00       	jmp    101e93 <trap_dispatch+0x226>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d1a:	e8 b0 f8 ff ff       	call   1015cf <cons_getc>
  101d1f:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d22:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101d26:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101d2a:	83 ec 04             	sub    $0x4,%esp
  101d2d:	52                   	push   %edx
  101d2e:	50                   	push   %eax
  101d2f:	68 86 3a 10 00       	push   $0x103a86
  101d34:	e8 14 e5 ff ff       	call   10024d <cprintf>
  101d39:	83 c4 10             	add    $0x10,%esp
        break;
  101d3c:	e9 52 01 00 00       	jmp    101e93 <trap_dispatch+0x226>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        if (tf->tf_cs != USER_CS) {
  101d41:	8b 45 08             	mov    0x8(%ebp),%eax
  101d44:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101d48:	66 83 f8 1b          	cmp    $0x1b,%ax
  101d4c:	0f 84 3d 01 00 00    	je     101e8f <trap_dispatch+0x222>
            switchk2u = *tf;
  101d52:	8b 55 08             	mov    0x8(%ebp),%edx
  101d55:	b8 20 f9 10 00       	mov    $0x10f920,%eax
  101d5a:	89 d3                	mov    %edx,%ebx
  101d5c:	ba 4c 00 00 00       	mov    $0x4c,%edx
  101d61:	8b 0b                	mov    (%ebx),%ecx
  101d63:	89 08                	mov    %ecx,(%eax)
  101d65:	8b 4c 13 fc          	mov    -0x4(%ebx,%edx,1),%ecx
  101d69:	89 4c 10 fc          	mov    %ecx,-0x4(%eax,%edx,1)
  101d6d:	8d 78 04             	lea    0x4(%eax),%edi
  101d70:	83 e7 fc             	and    $0xfffffffc,%edi
  101d73:	29 f8                	sub    %edi,%eax
  101d75:	29 c3                	sub    %eax,%ebx
  101d77:	01 c2                	add    %eax,%edx
  101d79:	83 e2 fc             	and    $0xfffffffc,%edx
  101d7c:	89 d0                	mov    %edx,%eax
  101d7e:	c1 e8 02             	shr    $0x2,%eax
  101d81:	89 de                	mov    %ebx,%esi
  101d83:	89 c1                	mov    %eax,%ecx
  101d85:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
            switchk2u.tf_cs = USER_CS;
  101d87:	66 c7 05 5c f9 10 00 	movw   $0x1b,0x10f95c
  101d8e:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
  101d90:	66 c7 05 68 f9 10 00 	movw   $0x23,0x10f968
  101d97:	23 00 
  101d99:	0f b7 05 68 f9 10 00 	movzwl 0x10f968,%eax
  101da0:	66 a3 48 f9 10 00    	mov    %ax,0x10f948
  101da6:	0f b7 05 48 f9 10 00 	movzwl 0x10f948,%eax
  101dad:	66 a3 4c f9 10 00    	mov    %ax,0x10f94c
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
  101db3:	8b 45 08             	mov    0x8(%ebp),%eax
  101db6:	83 c0 44             	add    $0x44,%eax
  101db9:	a3 64 f9 10 00       	mov    %eax,0x10f964
		
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            switchk2u.tf_eflags |= FL_IOPL_MASK;
  101dbe:	a1 60 f9 10 00       	mov    0x10f960,%eax
  101dc3:	80 cc 30             	or     $0x30,%ah
  101dc6:	a3 60 f9 10 00       	mov    %eax,0x10f960
		
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
  101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  101dce:	83 e8 04             	sub    $0x4,%eax
  101dd1:	ba 20 f9 10 00       	mov    $0x10f920,%edx
  101dd6:	89 10                	mov    %edx,(%eax)
        }
        break;
  101dd8:	e9 b2 00 00 00       	jmp    101e8f <trap_dispatch+0x222>
    case T_SWITCH_TOK:
        if (tf->tf_cs != KERNEL_CS) {
  101ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  101de0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101de4:	66 83 f8 08          	cmp    $0x8,%ax
  101de8:	0f 84 a4 00 00 00    	je     101e92 <trap_dispatch+0x225>
            tf->tf_cs = KERNEL_CS;
  101dee:	8b 45 08             	mov    0x8(%ebp),%eax
  101df1:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
  101df7:	8b 45 08             	mov    0x8(%ebp),%eax
  101dfa:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  101e00:	8b 45 08             	mov    0x8(%ebp),%eax
  101e03:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101e07:	8b 45 08             	mov    0x8(%ebp),%eax
  101e0a:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
  101e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  101e11:	8b 40 40             	mov    0x40(%eax),%eax
  101e14:	80 e4 cf             	and    $0xcf,%ah
  101e17:	89 c2                	mov    %eax,%edx
  101e19:	8b 45 08             	mov    0x8(%ebp),%eax
  101e1c:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  101e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  101e22:	8b 40 44             	mov    0x44(%eax),%eax
  101e25:	83 e8 44             	sub    $0x44,%eax
  101e28:	a3 6c f9 10 00       	mov    %eax,0x10f96c
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
  101e2d:	a1 6c f9 10 00       	mov    0x10f96c,%eax
  101e32:	83 ec 04             	sub    $0x4,%esp
  101e35:	6a 44                	push   $0x44
  101e37:	ff 75 08             	pushl  0x8(%ebp)
  101e3a:	50                   	push   %eax
  101e3b:	e8 b9 0f 00 00       	call   102df9 <memmove>
  101e40:	83 c4 10             	add    $0x10,%esp
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
  101e43:	8b 45 08             	mov    0x8(%ebp),%eax
  101e46:	83 e8 04             	sub    $0x4,%eax
  101e49:	8b 15 6c f9 10 00    	mov    0x10f96c,%edx
  101e4f:	89 10                	mov    %edx,(%eax)
        }
        break;
  101e51:	eb 3f                	jmp    101e92 <trap_dispatch+0x225>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101e53:	8b 45 08             	mov    0x8(%ebp),%eax
  101e56:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e5a:	0f b7 c0             	movzwl %ax,%eax
  101e5d:	83 e0 03             	and    $0x3,%eax
  101e60:	85 c0                	test   %eax,%eax
  101e62:	75 2f                	jne    101e93 <trap_dispatch+0x226>
            print_trapframe(tf);
  101e64:	83 ec 0c             	sub    $0xc,%esp
  101e67:	ff 75 08             	pushl  0x8(%ebp)
  101e6a:	e8 61 fb ff ff       	call   1019d0 <print_trapframe>
  101e6f:	83 c4 10             	add    $0x10,%esp
            panic("unexpected trap in kernel.\n");
  101e72:	83 ec 04             	sub    $0x4,%esp
  101e75:	68 95 3a 10 00       	push   $0x103a95
  101e7a:	68 d2 00 00 00       	push   $0xd2
  101e7f:	68 b1 3a 10 00       	push   $0x103ab1
  101e84:	e8 2a e5 ff ff       	call   1003b3 <__panic>
        }
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101e89:	90                   	nop
  101e8a:	eb 07                	jmp    101e93 <trap_dispatch+0x226>
         */
        ticks ++;
        if (ticks % TICK_NUM == 0) {
            print_ticks();
        }
        break;
  101e8c:	90                   	nop
  101e8d:	eb 04                	jmp    101e93 <trap_dispatch+0x226>
		
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
        }
        break;
  101e8f:	90                   	nop
  101e90:	eb 01                	jmp    101e93 <trap_dispatch+0x226>
            tf->tf_eflags &= ~FL_IOPL_MASK;
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
        }
        break;
  101e92:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101e93:	90                   	nop
  101e94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  101e97:	5b                   	pop    %ebx
  101e98:	5e                   	pop    %esi
  101e99:	5f                   	pop    %edi
  101e9a:	5d                   	pop    %ebp
  101e9b:	c3                   	ret    

00101e9c <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101e9c:	55                   	push   %ebp
  101e9d:	89 e5                	mov    %esp,%ebp
  101e9f:	83 ec 08             	sub    $0x8,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101ea2:	83 ec 0c             	sub    $0xc,%esp
  101ea5:	ff 75 08             	pushl  0x8(%ebp)
  101ea8:	e8 c0 fd ff ff       	call   101c6d <trap_dispatch>
  101ead:	83 c4 10             	add    $0x10,%esp
}
  101eb0:	90                   	nop
  101eb1:	c9                   	leave  
  101eb2:	c3                   	ret    

00101eb3 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101eb3:	6a 00                	push   $0x0
  pushl $0
  101eb5:	6a 00                	push   $0x0
  jmp __alltraps
  101eb7:	e9 67 0a 00 00       	jmp    102923 <__alltraps>

00101ebc <vector1>:
.globl vector1
vector1:
  pushl $0
  101ebc:	6a 00                	push   $0x0
  pushl $1
  101ebe:	6a 01                	push   $0x1
  jmp __alltraps
  101ec0:	e9 5e 0a 00 00       	jmp    102923 <__alltraps>

00101ec5 <vector2>:
.globl vector2
vector2:
  pushl $0
  101ec5:	6a 00                	push   $0x0
  pushl $2
  101ec7:	6a 02                	push   $0x2
  jmp __alltraps
  101ec9:	e9 55 0a 00 00       	jmp    102923 <__alltraps>

00101ece <vector3>:
.globl vector3
vector3:
  pushl $0
  101ece:	6a 00                	push   $0x0
  pushl $3
  101ed0:	6a 03                	push   $0x3
  jmp __alltraps
  101ed2:	e9 4c 0a 00 00       	jmp    102923 <__alltraps>

00101ed7 <vector4>:
.globl vector4
vector4:
  pushl $0
  101ed7:	6a 00                	push   $0x0
  pushl $4
  101ed9:	6a 04                	push   $0x4
  jmp __alltraps
  101edb:	e9 43 0a 00 00       	jmp    102923 <__alltraps>

00101ee0 <vector5>:
.globl vector5
vector5:
  pushl $0
  101ee0:	6a 00                	push   $0x0
  pushl $5
  101ee2:	6a 05                	push   $0x5
  jmp __alltraps
  101ee4:	e9 3a 0a 00 00       	jmp    102923 <__alltraps>

00101ee9 <vector6>:
.globl vector6
vector6:
  pushl $0
  101ee9:	6a 00                	push   $0x0
  pushl $6
  101eeb:	6a 06                	push   $0x6
  jmp __alltraps
  101eed:	e9 31 0a 00 00       	jmp    102923 <__alltraps>

00101ef2 <vector7>:
.globl vector7
vector7:
  pushl $0
  101ef2:	6a 00                	push   $0x0
  pushl $7
  101ef4:	6a 07                	push   $0x7
  jmp __alltraps
  101ef6:	e9 28 0a 00 00       	jmp    102923 <__alltraps>

00101efb <vector8>:
.globl vector8
vector8:
  pushl $8
  101efb:	6a 08                	push   $0x8
  jmp __alltraps
  101efd:	e9 21 0a 00 00       	jmp    102923 <__alltraps>

00101f02 <vector9>:
.globl vector9
vector9:
  pushl $9
  101f02:	6a 09                	push   $0x9
  jmp __alltraps
  101f04:	e9 1a 0a 00 00       	jmp    102923 <__alltraps>

00101f09 <vector10>:
.globl vector10
vector10:
  pushl $10
  101f09:	6a 0a                	push   $0xa
  jmp __alltraps
  101f0b:	e9 13 0a 00 00       	jmp    102923 <__alltraps>

00101f10 <vector11>:
.globl vector11
vector11:
  pushl $11
  101f10:	6a 0b                	push   $0xb
  jmp __alltraps
  101f12:	e9 0c 0a 00 00       	jmp    102923 <__alltraps>

00101f17 <vector12>:
.globl vector12
vector12:
  pushl $12
  101f17:	6a 0c                	push   $0xc
  jmp __alltraps
  101f19:	e9 05 0a 00 00       	jmp    102923 <__alltraps>

00101f1e <vector13>:
.globl vector13
vector13:
  pushl $13
  101f1e:	6a 0d                	push   $0xd
  jmp __alltraps
  101f20:	e9 fe 09 00 00       	jmp    102923 <__alltraps>

00101f25 <vector14>:
.globl vector14
vector14:
  pushl $14
  101f25:	6a 0e                	push   $0xe
  jmp __alltraps
  101f27:	e9 f7 09 00 00       	jmp    102923 <__alltraps>

00101f2c <vector15>:
.globl vector15
vector15:
  pushl $0
  101f2c:	6a 00                	push   $0x0
  pushl $15
  101f2e:	6a 0f                	push   $0xf
  jmp __alltraps
  101f30:	e9 ee 09 00 00       	jmp    102923 <__alltraps>

00101f35 <vector16>:
.globl vector16
vector16:
  pushl $0
  101f35:	6a 00                	push   $0x0
  pushl $16
  101f37:	6a 10                	push   $0x10
  jmp __alltraps
  101f39:	e9 e5 09 00 00       	jmp    102923 <__alltraps>

00101f3e <vector17>:
.globl vector17
vector17:
  pushl $17
  101f3e:	6a 11                	push   $0x11
  jmp __alltraps
  101f40:	e9 de 09 00 00       	jmp    102923 <__alltraps>

00101f45 <vector18>:
.globl vector18
vector18:
  pushl $0
  101f45:	6a 00                	push   $0x0
  pushl $18
  101f47:	6a 12                	push   $0x12
  jmp __alltraps
  101f49:	e9 d5 09 00 00       	jmp    102923 <__alltraps>

00101f4e <vector19>:
.globl vector19
vector19:
  pushl $0
  101f4e:	6a 00                	push   $0x0
  pushl $19
  101f50:	6a 13                	push   $0x13
  jmp __alltraps
  101f52:	e9 cc 09 00 00       	jmp    102923 <__alltraps>

00101f57 <vector20>:
.globl vector20
vector20:
  pushl $0
  101f57:	6a 00                	push   $0x0
  pushl $20
  101f59:	6a 14                	push   $0x14
  jmp __alltraps
  101f5b:	e9 c3 09 00 00       	jmp    102923 <__alltraps>

00101f60 <vector21>:
.globl vector21
vector21:
  pushl $0
  101f60:	6a 00                	push   $0x0
  pushl $21
  101f62:	6a 15                	push   $0x15
  jmp __alltraps
  101f64:	e9 ba 09 00 00       	jmp    102923 <__alltraps>

00101f69 <vector22>:
.globl vector22
vector22:
  pushl $0
  101f69:	6a 00                	push   $0x0
  pushl $22
  101f6b:	6a 16                	push   $0x16
  jmp __alltraps
  101f6d:	e9 b1 09 00 00       	jmp    102923 <__alltraps>

00101f72 <vector23>:
.globl vector23
vector23:
  pushl $0
  101f72:	6a 00                	push   $0x0
  pushl $23
  101f74:	6a 17                	push   $0x17
  jmp __alltraps
  101f76:	e9 a8 09 00 00       	jmp    102923 <__alltraps>

00101f7b <vector24>:
.globl vector24
vector24:
  pushl $0
  101f7b:	6a 00                	push   $0x0
  pushl $24
  101f7d:	6a 18                	push   $0x18
  jmp __alltraps
  101f7f:	e9 9f 09 00 00       	jmp    102923 <__alltraps>

00101f84 <vector25>:
.globl vector25
vector25:
  pushl $0
  101f84:	6a 00                	push   $0x0
  pushl $25
  101f86:	6a 19                	push   $0x19
  jmp __alltraps
  101f88:	e9 96 09 00 00       	jmp    102923 <__alltraps>

00101f8d <vector26>:
.globl vector26
vector26:
  pushl $0
  101f8d:	6a 00                	push   $0x0
  pushl $26
  101f8f:	6a 1a                	push   $0x1a
  jmp __alltraps
  101f91:	e9 8d 09 00 00       	jmp    102923 <__alltraps>

00101f96 <vector27>:
.globl vector27
vector27:
  pushl $0
  101f96:	6a 00                	push   $0x0
  pushl $27
  101f98:	6a 1b                	push   $0x1b
  jmp __alltraps
  101f9a:	e9 84 09 00 00       	jmp    102923 <__alltraps>

00101f9f <vector28>:
.globl vector28
vector28:
  pushl $0
  101f9f:	6a 00                	push   $0x0
  pushl $28
  101fa1:	6a 1c                	push   $0x1c
  jmp __alltraps
  101fa3:	e9 7b 09 00 00       	jmp    102923 <__alltraps>

00101fa8 <vector29>:
.globl vector29
vector29:
  pushl $0
  101fa8:	6a 00                	push   $0x0
  pushl $29
  101faa:	6a 1d                	push   $0x1d
  jmp __alltraps
  101fac:	e9 72 09 00 00       	jmp    102923 <__alltraps>

00101fb1 <vector30>:
.globl vector30
vector30:
  pushl $0
  101fb1:	6a 00                	push   $0x0
  pushl $30
  101fb3:	6a 1e                	push   $0x1e
  jmp __alltraps
  101fb5:	e9 69 09 00 00       	jmp    102923 <__alltraps>

00101fba <vector31>:
.globl vector31
vector31:
  pushl $0
  101fba:	6a 00                	push   $0x0
  pushl $31
  101fbc:	6a 1f                	push   $0x1f
  jmp __alltraps
  101fbe:	e9 60 09 00 00       	jmp    102923 <__alltraps>

00101fc3 <vector32>:
.globl vector32
vector32:
  pushl $0
  101fc3:	6a 00                	push   $0x0
  pushl $32
  101fc5:	6a 20                	push   $0x20
  jmp __alltraps
  101fc7:	e9 57 09 00 00       	jmp    102923 <__alltraps>

00101fcc <vector33>:
.globl vector33
vector33:
  pushl $0
  101fcc:	6a 00                	push   $0x0
  pushl $33
  101fce:	6a 21                	push   $0x21
  jmp __alltraps
  101fd0:	e9 4e 09 00 00       	jmp    102923 <__alltraps>

00101fd5 <vector34>:
.globl vector34
vector34:
  pushl $0
  101fd5:	6a 00                	push   $0x0
  pushl $34
  101fd7:	6a 22                	push   $0x22
  jmp __alltraps
  101fd9:	e9 45 09 00 00       	jmp    102923 <__alltraps>

00101fde <vector35>:
.globl vector35
vector35:
  pushl $0
  101fde:	6a 00                	push   $0x0
  pushl $35
  101fe0:	6a 23                	push   $0x23
  jmp __alltraps
  101fe2:	e9 3c 09 00 00       	jmp    102923 <__alltraps>

00101fe7 <vector36>:
.globl vector36
vector36:
  pushl $0
  101fe7:	6a 00                	push   $0x0
  pushl $36
  101fe9:	6a 24                	push   $0x24
  jmp __alltraps
  101feb:	e9 33 09 00 00       	jmp    102923 <__alltraps>

00101ff0 <vector37>:
.globl vector37
vector37:
  pushl $0
  101ff0:	6a 00                	push   $0x0
  pushl $37
  101ff2:	6a 25                	push   $0x25
  jmp __alltraps
  101ff4:	e9 2a 09 00 00       	jmp    102923 <__alltraps>

00101ff9 <vector38>:
.globl vector38
vector38:
  pushl $0
  101ff9:	6a 00                	push   $0x0
  pushl $38
  101ffb:	6a 26                	push   $0x26
  jmp __alltraps
  101ffd:	e9 21 09 00 00       	jmp    102923 <__alltraps>

00102002 <vector39>:
.globl vector39
vector39:
  pushl $0
  102002:	6a 00                	push   $0x0
  pushl $39
  102004:	6a 27                	push   $0x27
  jmp __alltraps
  102006:	e9 18 09 00 00       	jmp    102923 <__alltraps>

0010200b <vector40>:
.globl vector40
vector40:
  pushl $0
  10200b:	6a 00                	push   $0x0
  pushl $40
  10200d:	6a 28                	push   $0x28
  jmp __alltraps
  10200f:	e9 0f 09 00 00       	jmp    102923 <__alltraps>

00102014 <vector41>:
.globl vector41
vector41:
  pushl $0
  102014:	6a 00                	push   $0x0
  pushl $41
  102016:	6a 29                	push   $0x29
  jmp __alltraps
  102018:	e9 06 09 00 00       	jmp    102923 <__alltraps>

0010201d <vector42>:
.globl vector42
vector42:
  pushl $0
  10201d:	6a 00                	push   $0x0
  pushl $42
  10201f:	6a 2a                	push   $0x2a
  jmp __alltraps
  102021:	e9 fd 08 00 00       	jmp    102923 <__alltraps>

00102026 <vector43>:
.globl vector43
vector43:
  pushl $0
  102026:	6a 00                	push   $0x0
  pushl $43
  102028:	6a 2b                	push   $0x2b
  jmp __alltraps
  10202a:	e9 f4 08 00 00       	jmp    102923 <__alltraps>

0010202f <vector44>:
.globl vector44
vector44:
  pushl $0
  10202f:	6a 00                	push   $0x0
  pushl $44
  102031:	6a 2c                	push   $0x2c
  jmp __alltraps
  102033:	e9 eb 08 00 00       	jmp    102923 <__alltraps>

00102038 <vector45>:
.globl vector45
vector45:
  pushl $0
  102038:	6a 00                	push   $0x0
  pushl $45
  10203a:	6a 2d                	push   $0x2d
  jmp __alltraps
  10203c:	e9 e2 08 00 00       	jmp    102923 <__alltraps>

00102041 <vector46>:
.globl vector46
vector46:
  pushl $0
  102041:	6a 00                	push   $0x0
  pushl $46
  102043:	6a 2e                	push   $0x2e
  jmp __alltraps
  102045:	e9 d9 08 00 00       	jmp    102923 <__alltraps>

0010204a <vector47>:
.globl vector47
vector47:
  pushl $0
  10204a:	6a 00                	push   $0x0
  pushl $47
  10204c:	6a 2f                	push   $0x2f
  jmp __alltraps
  10204e:	e9 d0 08 00 00       	jmp    102923 <__alltraps>

00102053 <vector48>:
.globl vector48
vector48:
  pushl $0
  102053:	6a 00                	push   $0x0
  pushl $48
  102055:	6a 30                	push   $0x30
  jmp __alltraps
  102057:	e9 c7 08 00 00       	jmp    102923 <__alltraps>

0010205c <vector49>:
.globl vector49
vector49:
  pushl $0
  10205c:	6a 00                	push   $0x0
  pushl $49
  10205e:	6a 31                	push   $0x31
  jmp __alltraps
  102060:	e9 be 08 00 00       	jmp    102923 <__alltraps>

00102065 <vector50>:
.globl vector50
vector50:
  pushl $0
  102065:	6a 00                	push   $0x0
  pushl $50
  102067:	6a 32                	push   $0x32
  jmp __alltraps
  102069:	e9 b5 08 00 00       	jmp    102923 <__alltraps>

0010206e <vector51>:
.globl vector51
vector51:
  pushl $0
  10206e:	6a 00                	push   $0x0
  pushl $51
  102070:	6a 33                	push   $0x33
  jmp __alltraps
  102072:	e9 ac 08 00 00       	jmp    102923 <__alltraps>

00102077 <vector52>:
.globl vector52
vector52:
  pushl $0
  102077:	6a 00                	push   $0x0
  pushl $52
  102079:	6a 34                	push   $0x34
  jmp __alltraps
  10207b:	e9 a3 08 00 00       	jmp    102923 <__alltraps>

00102080 <vector53>:
.globl vector53
vector53:
  pushl $0
  102080:	6a 00                	push   $0x0
  pushl $53
  102082:	6a 35                	push   $0x35
  jmp __alltraps
  102084:	e9 9a 08 00 00       	jmp    102923 <__alltraps>

00102089 <vector54>:
.globl vector54
vector54:
  pushl $0
  102089:	6a 00                	push   $0x0
  pushl $54
  10208b:	6a 36                	push   $0x36
  jmp __alltraps
  10208d:	e9 91 08 00 00       	jmp    102923 <__alltraps>

00102092 <vector55>:
.globl vector55
vector55:
  pushl $0
  102092:	6a 00                	push   $0x0
  pushl $55
  102094:	6a 37                	push   $0x37
  jmp __alltraps
  102096:	e9 88 08 00 00       	jmp    102923 <__alltraps>

0010209b <vector56>:
.globl vector56
vector56:
  pushl $0
  10209b:	6a 00                	push   $0x0
  pushl $56
  10209d:	6a 38                	push   $0x38
  jmp __alltraps
  10209f:	e9 7f 08 00 00       	jmp    102923 <__alltraps>

001020a4 <vector57>:
.globl vector57
vector57:
  pushl $0
  1020a4:	6a 00                	push   $0x0
  pushl $57
  1020a6:	6a 39                	push   $0x39
  jmp __alltraps
  1020a8:	e9 76 08 00 00       	jmp    102923 <__alltraps>

001020ad <vector58>:
.globl vector58
vector58:
  pushl $0
  1020ad:	6a 00                	push   $0x0
  pushl $58
  1020af:	6a 3a                	push   $0x3a
  jmp __alltraps
  1020b1:	e9 6d 08 00 00       	jmp    102923 <__alltraps>

001020b6 <vector59>:
.globl vector59
vector59:
  pushl $0
  1020b6:	6a 00                	push   $0x0
  pushl $59
  1020b8:	6a 3b                	push   $0x3b
  jmp __alltraps
  1020ba:	e9 64 08 00 00       	jmp    102923 <__alltraps>

001020bf <vector60>:
.globl vector60
vector60:
  pushl $0
  1020bf:	6a 00                	push   $0x0
  pushl $60
  1020c1:	6a 3c                	push   $0x3c
  jmp __alltraps
  1020c3:	e9 5b 08 00 00       	jmp    102923 <__alltraps>

001020c8 <vector61>:
.globl vector61
vector61:
  pushl $0
  1020c8:	6a 00                	push   $0x0
  pushl $61
  1020ca:	6a 3d                	push   $0x3d
  jmp __alltraps
  1020cc:	e9 52 08 00 00       	jmp    102923 <__alltraps>

001020d1 <vector62>:
.globl vector62
vector62:
  pushl $0
  1020d1:	6a 00                	push   $0x0
  pushl $62
  1020d3:	6a 3e                	push   $0x3e
  jmp __alltraps
  1020d5:	e9 49 08 00 00       	jmp    102923 <__alltraps>

001020da <vector63>:
.globl vector63
vector63:
  pushl $0
  1020da:	6a 00                	push   $0x0
  pushl $63
  1020dc:	6a 3f                	push   $0x3f
  jmp __alltraps
  1020de:	e9 40 08 00 00       	jmp    102923 <__alltraps>

001020e3 <vector64>:
.globl vector64
vector64:
  pushl $0
  1020e3:	6a 00                	push   $0x0
  pushl $64
  1020e5:	6a 40                	push   $0x40
  jmp __alltraps
  1020e7:	e9 37 08 00 00       	jmp    102923 <__alltraps>

001020ec <vector65>:
.globl vector65
vector65:
  pushl $0
  1020ec:	6a 00                	push   $0x0
  pushl $65
  1020ee:	6a 41                	push   $0x41
  jmp __alltraps
  1020f0:	e9 2e 08 00 00       	jmp    102923 <__alltraps>

001020f5 <vector66>:
.globl vector66
vector66:
  pushl $0
  1020f5:	6a 00                	push   $0x0
  pushl $66
  1020f7:	6a 42                	push   $0x42
  jmp __alltraps
  1020f9:	e9 25 08 00 00       	jmp    102923 <__alltraps>

001020fe <vector67>:
.globl vector67
vector67:
  pushl $0
  1020fe:	6a 00                	push   $0x0
  pushl $67
  102100:	6a 43                	push   $0x43
  jmp __alltraps
  102102:	e9 1c 08 00 00       	jmp    102923 <__alltraps>

00102107 <vector68>:
.globl vector68
vector68:
  pushl $0
  102107:	6a 00                	push   $0x0
  pushl $68
  102109:	6a 44                	push   $0x44
  jmp __alltraps
  10210b:	e9 13 08 00 00       	jmp    102923 <__alltraps>

00102110 <vector69>:
.globl vector69
vector69:
  pushl $0
  102110:	6a 00                	push   $0x0
  pushl $69
  102112:	6a 45                	push   $0x45
  jmp __alltraps
  102114:	e9 0a 08 00 00       	jmp    102923 <__alltraps>

00102119 <vector70>:
.globl vector70
vector70:
  pushl $0
  102119:	6a 00                	push   $0x0
  pushl $70
  10211b:	6a 46                	push   $0x46
  jmp __alltraps
  10211d:	e9 01 08 00 00       	jmp    102923 <__alltraps>

00102122 <vector71>:
.globl vector71
vector71:
  pushl $0
  102122:	6a 00                	push   $0x0
  pushl $71
  102124:	6a 47                	push   $0x47
  jmp __alltraps
  102126:	e9 f8 07 00 00       	jmp    102923 <__alltraps>

0010212b <vector72>:
.globl vector72
vector72:
  pushl $0
  10212b:	6a 00                	push   $0x0
  pushl $72
  10212d:	6a 48                	push   $0x48
  jmp __alltraps
  10212f:	e9 ef 07 00 00       	jmp    102923 <__alltraps>

00102134 <vector73>:
.globl vector73
vector73:
  pushl $0
  102134:	6a 00                	push   $0x0
  pushl $73
  102136:	6a 49                	push   $0x49
  jmp __alltraps
  102138:	e9 e6 07 00 00       	jmp    102923 <__alltraps>

0010213d <vector74>:
.globl vector74
vector74:
  pushl $0
  10213d:	6a 00                	push   $0x0
  pushl $74
  10213f:	6a 4a                	push   $0x4a
  jmp __alltraps
  102141:	e9 dd 07 00 00       	jmp    102923 <__alltraps>

00102146 <vector75>:
.globl vector75
vector75:
  pushl $0
  102146:	6a 00                	push   $0x0
  pushl $75
  102148:	6a 4b                	push   $0x4b
  jmp __alltraps
  10214a:	e9 d4 07 00 00       	jmp    102923 <__alltraps>

0010214f <vector76>:
.globl vector76
vector76:
  pushl $0
  10214f:	6a 00                	push   $0x0
  pushl $76
  102151:	6a 4c                	push   $0x4c
  jmp __alltraps
  102153:	e9 cb 07 00 00       	jmp    102923 <__alltraps>

00102158 <vector77>:
.globl vector77
vector77:
  pushl $0
  102158:	6a 00                	push   $0x0
  pushl $77
  10215a:	6a 4d                	push   $0x4d
  jmp __alltraps
  10215c:	e9 c2 07 00 00       	jmp    102923 <__alltraps>

00102161 <vector78>:
.globl vector78
vector78:
  pushl $0
  102161:	6a 00                	push   $0x0
  pushl $78
  102163:	6a 4e                	push   $0x4e
  jmp __alltraps
  102165:	e9 b9 07 00 00       	jmp    102923 <__alltraps>

0010216a <vector79>:
.globl vector79
vector79:
  pushl $0
  10216a:	6a 00                	push   $0x0
  pushl $79
  10216c:	6a 4f                	push   $0x4f
  jmp __alltraps
  10216e:	e9 b0 07 00 00       	jmp    102923 <__alltraps>

00102173 <vector80>:
.globl vector80
vector80:
  pushl $0
  102173:	6a 00                	push   $0x0
  pushl $80
  102175:	6a 50                	push   $0x50
  jmp __alltraps
  102177:	e9 a7 07 00 00       	jmp    102923 <__alltraps>

0010217c <vector81>:
.globl vector81
vector81:
  pushl $0
  10217c:	6a 00                	push   $0x0
  pushl $81
  10217e:	6a 51                	push   $0x51
  jmp __alltraps
  102180:	e9 9e 07 00 00       	jmp    102923 <__alltraps>

00102185 <vector82>:
.globl vector82
vector82:
  pushl $0
  102185:	6a 00                	push   $0x0
  pushl $82
  102187:	6a 52                	push   $0x52
  jmp __alltraps
  102189:	e9 95 07 00 00       	jmp    102923 <__alltraps>

0010218e <vector83>:
.globl vector83
vector83:
  pushl $0
  10218e:	6a 00                	push   $0x0
  pushl $83
  102190:	6a 53                	push   $0x53
  jmp __alltraps
  102192:	e9 8c 07 00 00       	jmp    102923 <__alltraps>

00102197 <vector84>:
.globl vector84
vector84:
  pushl $0
  102197:	6a 00                	push   $0x0
  pushl $84
  102199:	6a 54                	push   $0x54
  jmp __alltraps
  10219b:	e9 83 07 00 00       	jmp    102923 <__alltraps>

001021a0 <vector85>:
.globl vector85
vector85:
  pushl $0
  1021a0:	6a 00                	push   $0x0
  pushl $85
  1021a2:	6a 55                	push   $0x55
  jmp __alltraps
  1021a4:	e9 7a 07 00 00       	jmp    102923 <__alltraps>

001021a9 <vector86>:
.globl vector86
vector86:
  pushl $0
  1021a9:	6a 00                	push   $0x0
  pushl $86
  1021ab:	6a 56                	push   $0x56
  jmp __alltraps
  1021ad:	e9 71 07 00 00       	jmp    102923 <__alltraps>

001021b2 <vector87>:
.globl vector87
vector87:
  pushl $0
  1021b2:	6a 00                	push   $0x0
  pushl $87
  1021b4:	6a 57                	push   $0x57
  jmp __alltraps
  1021b6:	e9 68 07 00 00       	jmp    102923 <__alltraps>

001021bb <vector88>:
.globl vector88
vector88:
  pushl $0
  1021bb:	6a 00                	push   $0x0
  pushl $88
  1021bd:	6a 58                	push   $0x58
  jmp __alltraps
  1021bf:	e9 5f 07 00 00       	jmp    102923 <__alltraps>

001021c4 <vector89>:
.globl vector89
vector89:
  pushl $0
  1021c4:	6a 00                	push   $0x0
  pushl $89
  1021c6:	6a 59                	push   $0x59
  jmp __alltraps
  1021c8:	e9 56 07 00 00       	jmp    102923 <__alltraps>

001021cd <vector90>:
.globl vector90
vector90:
  pushl $0
  1021cd:	6a 00                	push   $0x0
  pushl $90
  1021cf:	6a 5a                	push   $0x5a
  jmp __alltraps
  1021d1:	e9 4d 07 00 00       	jmp    102923 <__alltraps>

001021d6 <vector91>:
.globl vector91
vector91:
  pushl $0
  1021d6:	6a 00                	push   $0x0
  pushl $91
  1021d8:	6a 5b                	push   $0x5b
  jmp __alltraps
  1021da:	e9 44 07 00 00       	jmp    102923 <__alltraps>

001021df <vector92>:
.globl vector92
vector92:
  pushl $0
  1021df:	6a 00                	push   $0x0
  pushl $92
  1021e1:	6a 5c                	push   $0x5c
  jmp __alltraps
  1021e3:	e9 3b 07 00 00       	jmp    102923 <__alltraps>

001021e8 <vector93>:
.globl vector93
vector93:
  pushl $0
  1021e8:	6a 00                	push   $0x0
  pushl $93
  1021ea:	6a 5d                	push   $0x5d
  jmp __alltraps
  1021ec:	e9 32 07 00 00       	jmp    102923 <__alltraps>

001021f1 <vector94>:
.globl vector94
vector94:
  pushl $0
  1021f1:	6a 00                	push   $0x0
  pushl $94
  1021f3:	6a 5e                	push   $0x5e
  jmp __alltraps
  1021f5:	e9 29 07 00 00       	jmp    102923 <__alltraps>

001021fa <vector95>:
.globl vector95
vector95:
  pushl $0
  1021fa:	6a 00                	push   $0x0
  pushl $95
  1021fc:	6a 5f                	push   $0x5f
  jmp __alltraps
  1021fe:	e9 20 07 00 00       	jmp    102923 <__alltraps>

00102203 <vector96>:
.globl vector96
vector96:
  pushl $0
  102203:	6a 00                	push   $0x0
  pushl $96
  102205:	6a 60                	push   $0x60
  jmp __alltraps
  102207:	e9 17 07 00 00       	jmp    102923 <__alltraps>

0010220c <vector97>:
.globl vector97
vector97:
  pushl $0
  10220c:	6a 00                	push   $0x0
  pushl $97
  10220e:	6a 61                	push   $0x61
  jmp __alltraps
  102210:	e9 0e 07 00 00       	jmp    102923 <__alltraps>

00102215 <vector98>:
.globl vector98
vector98:
  pushl $0
  102215:	6a 00                	push   $0x0
  pushl $98
  102217:	6a 62                	push   $0x62
  jmp __alltraps
  102219:	e9 05 07 00 00       	jmp    102923 <__alltraps>

0010221e <vector99>:
.globl vector99
vector99:
  pushl $0
  10221e:	6a 00                	push   $0x0
  pushl $99
  102220:	6a 63                	push   $0x63
  jmp __alltraps
  102222:	e9 fc 06 00 00       	jmp    102923 <__alltraps>

00102227 <vector100>:
.globl vector100
vector100:
  pushl $0
  102227:	6a 00                	push   $0x0
  pushl $100
  102229:	6a 64                	push   $0x64
  jmp __alltraps
  10222b:	e9 f3 06 00 00       	jmp    102923 <__alltraps>

00102230 <vector101>:
.globl vector101
vector101:
  pushl $0
  102230:	6a 00                	push   $0x0
  pushl $101
  102232:	6a 65                	push   $0x65
  jmp __alltraps
  102234:	e9 ea 06 00 00       	jmp    102923 <__alltraps>

00102239 <vector102>:
.globl vector102
vector102:
  pushl $0
  102239:	6a 00                	push   $0x0
  pushl $102
  10223b:	6a 66                	push   $0x66
  jmp __alltraps
  10223d:	e9 e1 06 00 00       	jmp    102923 <__alltraps>

00102242 <vector103>:
.globl vector103
vector103:
  pushl $0
  102242:	6a 00                	push   $0x0
  pushl $103
  102244:	6a 67                	push   $0x67
  jmp __alltraps
  102246:	e9 d8 06 00 00       	jmp    102923 <__alltraps>

0010224b <vector104>:
.globl vector104
vector104:
  pushl $0
  10224b:	6a 00                	push   $0x0
  pushl $104
  10224d:	6a 68                	push   $0x68
  jmp __alltraps
  10224f:	e9 cf 06 00 00       	jmp    102923 <__alltraps>

00102254 <vector105>:
.globl vector105
vector105:
  pushl $0
  102254:	6a 00                	push   $0x0
  pushl $105
  102256:	6a 69                	push   $0x69
  jmp __alltraps
  102258:	e9 c6 06 00 00       	jmp    102923 <__alltraps>

0010225d <vector106>:
.globl vector106
vector106:
  pushl $0
  10225d:	6a 00                	push   $0x0
  pushl $106
  10225f:	6a 6a                	push   $0x6a
  jmp __alltraps
  102261:	e9 bd 06 00 00       	jmp    102923 <__alltraps>

00102266 <vector107>:
.globl vector107
vector107:
  pushl $0
  102266:	6a 00                	push   $0x0
  pushl $107
  102268:	6a 6b                	push   $0x6b
  jmp __alltraps
  10226a:	e9 b4 06 00 00       	jmp    102923 <__alltraps>

0010226f <vector108>:
.globl vector108
vector108:
  pushl $0
  10226f:	6a 00                	push   $0x0
  pushl $108
  102271:	6a 6c                	push   $0x6c
  jmp __alltraps
  102273:	e9 ab 06 00 00       	jmp    102923 <__alltraps>

00102278 <vector109>:
.globl vector109
vector109:
  pushl $0
  102278:	6a 00                	push   $0x0
  pushl $109
  10227a:	6a 6d                	push   $0x6d
  jmp __alltraps
  10227c:	e9 a2 06 00 00       	jmp    102923 <__alltraps>

00102281 <vector110>:
.globl vector110
vector110:
  pushl $0
  102281:	6a 00                	push   $0x0
  pushl $110
  102283:	6a 6e                	push   $0x6e
  jmp __alltraps
  102285:	e9 99 06 00 00       	jmp    102923 <__alltraps>

0010228a <vector111>:
.globl vector111
vector111:
  pushl $0
  10228a:	6a 00                	push   $0x0
  pushl $111
  10228c:	6a 6f                	push   $0x6f
  jmp __alltraps
  10228e:	e9 90 06 00 00       	jmp    102923 <__alltraps>

00102293 <vector112>:
.globl vector112
vector112:
  pushl $0
  102293:	6a 00                	push   $0x0
  pushl $112
  102295:	6a 70                	push   $0x70
  jmp __alltraps
  102297:	e9 87 06 00 00       	jmp    102923 <__alltraps>

0010229c <vector113>:
.globl vector113
vector113:
  pushl $0
  10229c:	6a 00                	push   $0x0
  pushl $113
  10229e:	6a 71                	push   $0x71
  jmp __alltraps
  1022a0:	e9 7e 06 00 00       	jmp    102923 <__alltraps>

001022a5 <vector114>:
.globl vector114
vector114:
  pushl $0
  1022a5:	6a 00                	push   $0x0
  pushl $114
  1022a7:	6a 72                	push   $0x72
  jmp __alltraps
  1022a9:	e9 75 06 00 00       	jmp    102923 <__alltraps>

001022ae <vector115>:
.globl vector115
vector115:
  pushl $0
  1022ae:	6a 00                	push   $0x0
  pushl $115
  1022b0:	6a 73                	push   $0x73
  jmp __alltraps
  1022b2:	e9 6c 06 00 00       	jmp    102923 <__alltraps>

001022b7 <vector116>:
.globl vector116
vector116:
  pushl $0
  1022b7:	6a 00                	push   $0x0
  pushl $116
  1022b9:	6a 74                	push   $0x74
  jmp __alltraps
  1022bb:	e9 63 06 00 00       	jmp    102923 <__alltraps>

001022c0 <vector117>:
.globl vector117
vector117:
  pushl $0
  1022c0:	6a 00                	push   $0x0
  pushl $117
  1022c2:	6a 75                	push   $0x75
  jmp __alltraps
  1022c4:	e9 5a 06 00 00       	jmp    102923 <__alltraps>

001022c9 <vector118>:
.globl vector118
vector118:
  pushl $0
  1022c9:	6a 00                	push   $0x0
  pushl $118
  1022cb:	6a 76                	push   $0x76
  jmp __alltraps
  1022cd:	e9 51 06 00 00       	jmp    102923 <__alltraps>

001022d2 <vector119>:
.globl vector119
vector119:
  pushl $0
  1022d2:	6a 00                	push   $0x0
  pushl $119
  1022d4:	6a 77                	push   $0x77
  jmp __alltraps
  1022d6:	e9 48 06 00 00       	jmp    102923 <__alltraps>

001022db <vector120>:
.globl vector120
vector120:
  pushl $0
  1022db:	6a 00                	push   $0x0
  pushl $120
  1022dd:	6a 78                	push   $0x78
  jmp __alltraps
  1022df:	e9 3f 06 00 00       	jmp    102923 <__alltraps>

001022e4 <vector121>:
.globl vector121
vector121:
  pushl $0
  1022e4:	6a 00                	push   $0x0
  pushl $121
  1022e6:	6a 79                	push   $0x79
  jmp __alltraps
  1022e8:	e9 36 06 00 00       	jmp    102923 <__alltraps>

001022ed <vector122>:
.globl vector122
vector122:
  pushl $0
  1022ed:	6a 00                	push   $0x0
  pushl $122
  1022ef:	6a 7a                	push   $0x7a
  jmp __alltraps
  1022f1:	e9 2d 06 00 00       	jmp    102923 <__alltraps>

001022f6 <vector123>:
.globl vector123
vector123:
  pushl $0
  1022f6:	6a 00                	push   $0x0
  pushl $123
  1022f8:	6a 7b                	push   $0x7b
  jmp __alltraps
  1022fa:	e9 24 06 00 00       	jmp    102923 <__alltraps>

001022ff <vector124>:
.globl vector124
vector124:
  pushl $0
  1022ff:	6a 00                	push   $0x0
  pushl $124
  102301:	6a 7c                	push   $0x7c
  jmp __alltraps
  102303:	e9 1b 06 00 00       	jmp    102923 <__alltraps>

00102308 <vector125>:
.globl vector125
vector125:
  pushl $0
  102308:	6a 00                	push   $0x0
  pushl $125
  10230a:	6a 7d                	push   $0x7d
  jmp __alltraps
  10230c:	e9 12 06 00 00       	jmp    102923 <__alltraps>

00102311 <vector126>:
.globl vector126
vector126:
  pushl $0
  102311:	6a 00                	push   $0x0
  pushl $126
  102313:	6a 7e                	push   $0x7e
  jmp __alltraps
  102315:	e9 09 06 00 00       	jmp    102923 <__alltraps>

0010231a <vector127>:
.globl vector127
vector127:
  pushl $0
  10231a:	6a 00                	push   $0x0
  pushl $127
  10231c:	6a 7f                	push   $0x7f
  jmp __alltraps
  10231e:	e9 00 06 00 00       	jmp    102923 <__alltraps>

00102323 <vector128>:
.globl vector128
vector128:
  pushl $0
  102323:	6a 00                	push   $0x0
  pushl $128
  102325:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  10232a:	e9 f4 05 00 00       	jmp    102923 <__alltraps>

0010232f <vector129>:
.globl vector129
vector129:
  pushl $0
  10232f:	6a 00                	push   $0x0
  pushl $129
  102331:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102336:	e9 e8 05 00 00       	jmp    102923 <__alltraps>

0010233b <vector130>:
.globl vector130
vector130:
  pushl $0
  10233b:	6a 00                	push   $0x0
  pushl $130
  10233d:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102342:	e9 dc 05 00 00       	jmp    102923 <__alltraps>

00102347 <vector131>:
.globl vector131
vector131:
  pushl $0
  102347:	6a 00                	push   $0x0
  pushl $131
  102349:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  10234e:	e9 d0 05 00 00       	jmp    102923 <__alltraps>

00102353 <vector132>:
.globl vector132
vector132:
  pushl $0
  102353:	6a 00                	push   $0x0
  pushl $132
  102355:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  10235a:	e9 c4 05 00 00       	jmp    102923 <__alltraps>

0010235f <vector133>:
.globl vector133
vector133:
  pushl $0
  10235f:	6a 00                	push   $0x0
  pushl $133
  102361:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102366:	e9 b8 05 00 00       	jmp    102923 <__alltraps>

0010236b <vector134>:
.globl vector134
vector134:
  pushl $0
  10236b:	6a 00                	push   $0x0
  pushl $134
  10236d:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102372:	e9 ac 05 00 00       	jmp    102923 <__alltraps>

00102377 <vector135>:
.globl vector135
vector135:
  pushl $0
  102377:	6a 00                	push   $0x0
  pushl $135
  102379:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  10237e:	e9 a0 05 00 00       	jmp    102923 <__alltraps>

00102383 <vector136>:
.globl vector136
vector136:
  pushl $0
  102383:	6a 00                	push   $0x0
  pushl $136
  102385:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  10238a:	e9 94 05 00 00       	jmp    102923 <__alltraps>

0010238f <vector137>:
.globl vector137
vector137:
  pushl $0
  10238f:	6a 00                	push   $0x0
  pushl $137
  102391:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102396:	e9 88 05 00 00       	jmp    102923 <__alltraps>

0010239b <vector138>:
.globl vector138
vector138:
  pushl $0
  10239b:	6a 00                	push   $0x0
  pushl $138
  10239d:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1023a2:	e9 7c 05 00 00       	jmp    102923 <__alltraps>

001023a7 <vector139>:
.globl vector139
vector139:
  pushl $0
  1023a7:	6a 00                	push   $0x0
  pushl $139
  1023a9:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1023ae:	e9 70 05 00 00       	jmp    102923 <__alltraps>

001023b3 <vector140>:
.globl vector140
vector140:
  pushl $0
  1023b3:	6a 00                	push   $0x0
  pushl $140
  1023b5:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1023ba:	e9 64 05 00 00       	jmp    102923 <__alltraps>

001023bf <vector141>:
.globl vector141
vector141:
  pushl $0
  1023bf:	6a 00                	push   $0x0
  pushl $141
  1023c1:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1023c6:	e9 58 05 00 00       	jmp    102923 <__alltraps>

001023cb <vector142>:
.globl vector142
vector142:
  pushl $0
  1023cb:	6a 00                	push   $0x0
  pushl $142
  1023cd:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1023d2:	e9 4c 05 00 00       	jmp    102923 <__alltraps>

001023d7 <vector143>:
.globl vector143
vector143:
  pushl $0
  1023d7:	6a 00                	push   $0x0
  pushl $143
  1023d9:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1023de:	e9 40 05 00 00       	jmp    102923 <__alltraps>

001023e3 <vector144>:
.globl vector144
vector144:
  pushl $0
  1023e3:	6a 00                	push   $0x0
  pushl $144
  1023e5:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1023ea:	e9 34 05 00 00       	jmp    102923 <__alltraps>

001023ef <vector145>:
.globl vector145
vector145:
  pushl $0
  1023ef:	6a 00                	push   $0x0
  pushl $145
  1023f1:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1023f6:	e9 28 05 00 00       	jmp    102923 <__alltraps>

001023fb <vector146>:
.globl vector146
vector146:
  pushl $0
  1023fb:	6a 00                	push   $0x0
  pushl $146
  1023fd:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102402:	e9 1c 05 00 00       	jmp    102923 <__alltraps>

00102407 <vector147>:
.globl vector147
vector147:
  pushl $0
  102407:	6a 00                	push   $0x0
  pushl $147
  102409:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  10240e:	e9 10 05 00 00       	jmp    102923 <__alltraps>

00102413 <vector148>:
.globl vector148
vector148:
  pushl $0
  102413:	6a 00                	push   $0x0
  pushl $148
  102415:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  10241a:	e9 04 05 00 00       	jmp    102923 <__alltraps>

0010241f <vector149>:
.globl vector149
vector149:
  pushl $0
  10241f:	6a 00                	push   $0x0
  pushl $149
  102421:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102426:	e9 f8 04 00 00       	jmp    102923 <__alltraps>

0010242b <vector150>:
.globl vector150
vector150:
  pushl $0
  10242b:	6a 00                	push   $0x0
  pushl $150
  10242d:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102432:	e9 ec 04 00 00       	jmp    102923 <__alltraps>

00102437 <vector151>:
.globl vector151
vector151:
  pushl $0
  102437:	6a 00                	push   $0x0
  pushl $151
  102439:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  10243e:	e9 e0 04 00 00       	jmp    102923 <__alltraps>

00102443 <vector152>:
.globl vector152
vector152:
  pushl $0
  102443:	6a 00                	push   $0x0
  pushl $152
  102445:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  10244a:	e9 d4 04 00 00       	jmp    102923 <__alltraps>

0010244f <vector153>:
.globl vector153
vector153:
  pushl $0
  10244f:	6a 00                	push   $0x0
  pushl $153
  102451:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102456:	e9 c8 04 00 00       	jmp    102923 <__alltraps>

0010245b <vector154>:
.globl vector154
vector154:
  pushl $0
  10245b:	6a 00                	push   $0x0
  pushl $154
  10245d:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102462:	e9 bc 04 00 00       	jmp    102923 <__alltraps>

00102467 <vector155>:
.globl vector155
vector155:
  pushl $0
  102467:	6a 00                	push   $0x0
  pushl $155
  102469:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  10246e:	e9 b0 04 00 00       	jmp    102923 <__alltraps>

00102473 <vector156>:
.globl vector156
vector156:
  pushl $0
  102473:	6a 00                	push   $0x0
  pushl $156
  102475:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  10247a:	e9 a4 04 00 00       	jmp    102923 <__alltraps>

0010247f <vector157>:
.globl vector157
vector157:
  pushl $0
  10247f:	6a 00                	push   $0x0
  pushl $157
  102481:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  102486:	e9 98 04 00 00       	jmp    102923 <__alltraps>

0010248b <vector158>:
.globl vector158
vector158:
  pushl $0
  10248b:	6a 00                	push   $0x0
  pushl $158
  10248d:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102492:	e9 8c 04 00 00       	jmp    102923 <__alltraps>

00102497 <vector159>:
.globl vector159
vector159:
  pushl $0
  102497:	6a 00                	push   $0x0
  pushl $159
  102499:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  10249e:	e9 80 04 00 00       	jmp    102923 <__alltraps>

001024a3 <vector160>:
.globl vector160
vector160:
  pushl $0
  1024a3:	6a 00                	push   $0x0
  pushl $160
  1024a5:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1024aa:	e9 74 04 00 00       	jmp    102923 <__alltraps>

001024af <vector161>:
.globl vector161
vector161:
  pushl $0
  1024af:	6a 00                	push   $0x0
  pushl $161
  1024b1:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  1024b6:	e9 68 04 00 00       	jmp    102923 <__alltraps>

001024bb <vector162>:
.globl vector162
vector162:
  pushl $0
  1024bb:	6a 00                	push   $0x0
  pushl $162
  1024bd:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1024c2:	e9 5c 04 00 00       	jmp    102923 <__alltraps>

001024c7 <vector163>:
.globl vector163
vector163:
  pushl $0
  1024c7:	6a 00                	push   $0x0
  pushl $163
  1024c9:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1024ce:	e9 50 04 00 00       	jmp    102923 <__alltraps>

001024d3 <vector164>:
.globl vector164
vector164:
  pushl $0
  1024d3:	6a 00                	push   $0x0
  pushl $164
  1024d5:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1024da:	e9 44 04 00 00       	jmp    102923 <__alltraps>

001024df <vector165>:
.globl vector165
vector165:
  pushl $0
  1024df:	6a 00                	push   $0x0
  pushl $165
  1024e1:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1024e6:	e9 38 04 00 00       	jmp    102923 <__alltraps>

001024eb <vector166>:
.globl vector166
vector166:
  pushl $0
  1024eb:	6a 00                	push   $0x0
  pushl $166
  1024ed:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1024f2:	e9 2c 04 00 00       	jmp    102923 <__alltraps>

001024f7 <vector167>:
.globl vector167
vector167:
  pushl $0
  1024f7:	6a 00                	push   $0x0
  pushl $167
  1024f9:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1024fe:	e9 20 04 00 00       	jmp    102923 <__alltraps>

00102503 <vector168>:
.globl vector168
vector168:
  pushl $0
  102503:	6a 00                	push   $0x0
  pushl $168
  102505:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  10250a:	e9 14 04 00 00       	jmp    102923 <__alltraps>

0010250f <vector169>:
.globl vector169
vector169:
  pushl $0
  10250f:	6a 00                	push   $0x0
  pushl $169
  102511:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102516:	e9 08 04 00 00       	jmp    102923 <__alltraps>

0010251b <vector170>:
.globl vector170
vector170:
  pushl $0
  10251b:	6a 00                	push   $0x0
  pushl $170
  10251d:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102522:	e9 fc 03 00 00       	jmp    102923 <__alltraps>

00102527 <vector171>:
.globl vector171
vector171:
  pushl $0
  102527:	6a 00                	push   $0x0
  pushl $171
  102529:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  10252e:	e9 f0 03 00 00       	jmp    102923 <__alltraps>

00102533 <vector172>:
.globl vector172
vector172:
  pushl $0
  102533:	6a 00                	push   $0x0
  pushl $172
  102535:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  10253a:	e9 e4 03 00 00       	jmp    102923 <__alltraps>

0010253f <vector173>:
.globl vector173
vector173:
  pushl $0
  10253f:	6a 00                	push   $0x0
  pushl $173
  102541:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102546:	e9 d8 03 00 00       	jmp    102923 <__alltraps>

0010254b <vector174>:
.globl vector174
vector174:
  pushl $0
  10254b:	6a 00                	push   $0x0
  pushl $174
  10254d:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102552:	e9 cc 03 00 00       	jmp    102923 <__alltraps>

00102557 <vector175>:
.globl vector175
vector175:
  pushl $0
  102557:	6a 00                	push   $0x0
  pushl $175
  102559:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  10255e:	e9 c0 03 00 00       	jmp    102923 <__alltraps>

00102563 <vector176>:
.globl vector176
vector176:
  pushl $0
  102563:	6a 00                	push   $0x0
  pushl $176
  102565:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  10256a:	e9 b4 03 00 00       	jmp    102923 <__alltraps>

0010256f <vector177>:
.globl vector177
vector177:
  pushl $0
  10256f:	6a 00                	push   $0x0
  pushl $177
  102571:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  102576:	e9 a8 03 00 00       	jmp    102923 <__alltraps>

0010257b <vector178>:
.globl vector178
vector178:
  pushl $0
  10257b:	6a 00                	push   $0x0
  pushl $178
  10257d:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102582:	e9 9c 03 00 00       	jmp    102923 <__alltraps>

00102587 <vector179>:
.globl vector179
vector179:
  pushl $0
  102587:	6a 00                	push   $0x0
  pushl $179
  102589:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  10258e:	e9 90 03 00 00       	jmp    102923 <__alltraps>

00102593 <vector180>:
.globl vector180
vector180:
  pushl $0
  102593:	6a 00                	push   $0x0
  pushl $180
  102595:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  10259a:	e9 84 03 00 00       	jmp    102923 <__alltraps>

0010259f <vector181>:
.globl vector181
vector181:
  pushl $0
  10259f:	6a 00                	push   $0x0
  pushl $181
  1025a1:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1025a6:	e9 78 03 00 00       	jmp    102923 <__alltraps>

001025ab <vector182>:
.globl vector182
vector182:
  pushl $0
  1025ab:	6a 00                	push   $0x0
  pushl $182
  1025ad:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1025b2:	e9 6c 03 00 00       	jmp    102923 <__alltraps>

001025b7 <vector183>:
.globl vector183
vector183:
  pushl $0
  1025b7:	6a 00                	push   $0x0
  pushl $183
  1025b9:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1025be:	e9 60 03 00 00       	jmp    102923 <__alltraps>

001025c3 <vector184>:
.globl vector184
vector184:
  pushl $0
  1025c3:	6a 00                	push   $0x0
  pushl $184
  1025c5:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1025ca:	e9 54 03 00 00       	jmp    102923 <__alltraps>

001025cf <vector185>:
.globl vector185
vector185:
  pushl $0
  1025cf:	6a 00                	push   $0x0
  pushl $185
  1025d1:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1025d6:	e9 48 03 00 00       	jmp    102923 <__alltraps>

001025db <vector186>:
.globl vector186
vector186:
  pushl $0
  1025db:	6a 00                	push   $0x0
  pushl $186
  1025dd:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1025e2:	e9 3c 03 00 00       	jmp    102923 <__alltraps>

001025e7 <vector187>:
.globl vector187
vector187:
  pushl $0
  1025e7:	6a 00                	push   $0x0
  pushl $187
  1025e9:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1025ee:	e9 30 03 00 00       	jmp    102923 <__alltraps>

001025f3 <vector188>:
.globl vector188
vector188:
  pushl $0
  1025f3:	6a 00                	push   $0x0
  pushl $188
  1025f5:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1025fa:	e9 24 03 00 00       	jmp    102923 <__alltraps>

001025ff <vector189>:
.globl vector189
vector189:
  pushl $0
  1025ff:	6a 00                	push   $0x0
  pushl $189
  102601:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102606:	e9 18 03 00 00       	jmp    102923 <__alltraps>

0010260b <vector190>:
.globl vector190
vector190:
  pushl $0
  10260b:	6a 00                	push   $0x0
  pushl $190
  10260d:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102612:	e9 0c 03 00 00       	jmp    102923 <__alltraps>

00102617 <vector191>:
.globl vector191
vector191:
  pushl $0
  102617:	6a 00                	push   $0x0
  pushl $191
  102619:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  10261e:	e9 00 03 00 00       	jmp    102923 <__alltraps>

00102623 <vector192>:
.globl vector192
vector192:
  pushl $0
  102623:	6a 00                	push   $0x0
  pushl $192
  102625:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  10262a:	e9 f4 02 00 00       	jmp    102923 <__alltraps>

0010262f <vector193>:
.globl vector193
vector193:
  pushl $0
  10262f:	6a 00                	push   $0x0
  pushl $193
  102631:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102636:	e9 e8 02 00 00       	jmp    102923 <__alltraps>

0010263b <vector194>:
.globl vector194
vector194:
  pushl $0
  10263b:	6a 00                	push   $0x0
  pushl $194
  10263d:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102642:	e9 dc 02 00 00       	jmp    102923 <__alltraps>

00102647 <vector195>:
.globl vector195
vector195:
  pushl $0
  102647:	6a 00                	push   $0x0
  pushl $195
  102649:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  10264e:	e9 d0 02 00 00       	jmp    102923 <__alltraps>

00102653 <vector196>:
.globl vector196
vector196:
  pushl $0
  102653:	6a 00                	push   $0x0
  pushl $196
  102655:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  10265a:	e9 c4 02 00 00       	jmp    102923 <__alltraps>

0010265f <vector197>:
.globl vector197
vector197:
  pushl $0
  10265f:	6a 00                	push   $0x0
  pushl $197
  102661:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102666:	e9 b8 02 00 00       	jmp    102923 <__alltraps>

0010266b <vector198>:
.globl vector198
vector198:
  pushl $0
  10266b:	6a 00                	push   $0x0
  pushl $198
  10266d:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102672:	e9 ac 02 00 00       	jmp    102923 <__alltraps>

00102677 <vector199>:
.globl vector199
vector199:
  pushl $0
  102677:	6a 00                	push   $0x0
  pushl $199
  102679:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  10267e:	e9 a0 02 00 00       	jmp    102923 <__alltraps>

00102683 <vector200>:
.globl vector200
vector200:
  pushl $0
  102683:	6a 00                	push   $0x0
  pushl $200
  102685:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  10268a:	e9 94 02 00 00       	jmp    102923 <__alltraps>

0010268f <vector201>:
.globl vector201
vector201:
  pushl $0
  10268f:	6a 00                	push   $0x0
  pushl $201
  102691:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102696:	e9 88 02 00 00       	jmp    102923 <__alltraps>

0010269b <vector202>:
.globl vector202
vector202:
  pushl $0
  10269b:	6a 00                	push   $0x0
  pushl $202
  10269d:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1026a2:	e9 7c 02 00 00       	jmp    102923 <__alltraps>

001026a7 <vector203>:
.globl vector203
vector203:
  pushl $0
  1026a7:	6a 00                	push   $0x0
  pushl $203
  1026a9:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1026ae:	e9 70 02 00 00       	jmp    102923 <__alltraps>

001026b3 <vector204>:
.globl vector204
vector204:
  pushl $0
  1026b3:	6a 00                	push   $0x0
  pushl $204
  1026b5:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1026ba:	e9 64 02 00 00       	jmp    102923 <__alltraps>

001026bf <vector205>:
.globl vector205
vector205:
  pushl $0
  1026bf:	6a 00                	push   $0x0
  pushl $205
  1026c1:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1026c6:	e9 58 02 00 00       	jmp    102923 <__alltraps>

001026cb <vector206>:
.globl vector206
vector206:
  pushl $0
  1026cb:	6a 00                	push   $0x0
  pushl $206
  1026cd:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1026d2:	e9 4c 02 00 00       	jmp    102923 <__alltraps>

001026d7 <vector207>:
.globl vector207
vector207:
  pushl $0
  1026d7:	6a 00                	push   $0x0
  pushl $207
  1026d9:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1026de:	e9 40 02 00 00       	jmp    102923 <__alltraps>

001026e3 <vector208>:
.globl vector208
vector208:
  pushl $0
  1026e3:	6a 00                	push   $0x0
  pushl $208
  1026e5:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1026ea:	e9 34 02 00 00       	jmp    102923 <__alltraps>

001026ef <vector209>:
.globl vector209
vector209:
  pushl $0
  1026ef:	6a 00                	push   $0x0
  pushl $209
  1026f1:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1026f6:	e9 28 02 00 00       	jmp    102923 <__alltraps>

001026fb <vector210>:
.globl vector210
vector210:
  pushl $0
  1026fb:	6a 00                	push   $0x0
  pushl $210
  1026fd:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102702:	e9 1c 02 00 00       	jmp    102923 <__alltraps>

00102707 <vector211>:
.globl vector211
vector211:
  pushl $0
  102707:	6a 00                	push   $0x0
  pushl $211
  102709:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  10270e:	e9 10 02 00 00       	jmp    102923 <__alltraps>

00102713 <vector212>:
.globl vector212
vector212:
  pushl $0
  102713:	6a 00                	push   $0x0
  pushl $212
  102715:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  10271a:	e9 04 02 00 00       	jmp    102923 <__alltraps>

0010271f <vector213>:
.globl vector213
vector213:
  pushl $0
  10271f:	6a 00                	push   $0x0
  pushl $213
  102721:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102726:	e9 f8 01 00 00       	jmp    102923 <__alltraps>

0010272b <vector214>:
.globl vector214
vector214:
  pushl $0
  10272b:	6a 00                	push   $0x0
  pushl $214
  10272d:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102732:	e9 ec 01 00 00       	jmp    102923 <__alltraps>

00102737 <vector215>:
.globl vector215
vector215:
  pushl $0
  102737:	6a 00                	push   $0x0
  pushl $215
  102739:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  10273e:	e9 e0 01 00 00       	jmp    102923 <__alltraps>

00102743 <vector216>:
.globl vector216
vector216:
  pushl $0
  102743:	6a 00                	push   $0x0
  pushl $216
  102745:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  10274a:	e9 d4 01 00 00       	jmp    102923 <__alltraps>

0010274f <vector217>:
.globl vector217
vector217:
  pushl $0
  10274f:	6a 00                	push   $0x0
  pushl $217
  102751:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102756:	e9 c8 01 00 00       	jmp    102923 <__alltraps>

0010275b <vector218>:
.globl vector218
vector218:
  pushl $0
  10275b:	6a 00                	push   $0x0
  pushl $218
  10275d:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102762:	e9 bc 01 00 00       	jmp    102923 <__alltraps>

00102767 <vector219>:
.globl vector219
vector219:
  pushl $0
  102767:	6a 00                	push   $0x0
  pushl $219
  102769:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  10276e:	e9 b0 01 00 00       	jmp    102923 <__alltraps>

00102773 <vector220>:
.globl vector220
vector220:
  pushl $0
  102773:	6a 00                	push   $0x0
  pushl $220
  102775:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  10277a:	e9 a4 01 00 00       	jmp    102923 <__alltraps>

0010277f <vector221>:
.globl vector221
vector221:
  pushl $0
  10277f:	6a 00                	push   $0x0
  pushl $221
  102781:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102786:	e9 98 01 00 00       	jmp    102923 <__alltraps>

0010278b <vector222>:
.globl vector222
vector222:
  pushl $0
  10278b:	6a 00                	push   $0x0
  pushl $222
  10278d:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102792:	e9 8c 01 00 00       	jmp    102923 <__alltraps>

00102797 <vector223>:
.globl vector223
vector223:
  pushl $0
  102797:	6a 00                	push   $0x0
  pushl $223
  102799:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  10279e:	e9 80 01 00 00       	jmp    102923 <__alltraps>

001027a3 <vector224>:
.globl vector224
vector224:
  pushl $0
  1027a3:	6a 00                	push   $0x0
  pushl $224
  1027a5:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  1027aa:	e9 74 01 00 00       	jmp    102923 <__alltraps>

001027af <vector225>:
.globl vector225
vector225:
  pushl $0
  1027af:	6a 00                	push   $0x0
  pushl $225
  1027b1:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  1027b6:	e9 68 01 00 00       	jmp    102923 <__alltraps>

001027bb <vector226>:
.globl vector226
vector226:
  pushl $0
  1027bb:	6a 00                	push   $0x0
  pushl $226
  1027bd:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1027c2:	e9 5c 01 00 00       	jmp    102923 <__alltraps>

001027c7 <vector227>:
.globl vector227
vector227:
  pushl $0
  1027c7:	6a 00                	push   $0x0
  pushl $227
  1027c9:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  1027ce:	e9 50 01 00 00       	jmp    102923 <__alltraps>

001027d3 <vector228>:
.globl vector228
vector228:
  pushl $0
  1027d3:	6a 00                	push   $0x0
  pushl $228
  1027d5:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1027da:	e9 44 01 00 00       	jmp    102923 <__alltraps>

001027df <vector229>:
.globl vector229
vector229:
  pushl $0
  1027df:	6a 00                	push   $0x0
  pushl $229
  1027e1:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1027e6:	e9 38 01 00 00       	jmp    102923 <__alltraps>

001027eb <vector230>:
.globl vector230
vector230:
  pushl $0
  1027eb:	6a 00                	push   $0x0
  pushl $230
  1027ed:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1027f2:	e9 2c 01 00 00       	jmp    102923 <__alltraps>

001027f7 <vector231>:
.globl vector231
vector231:
  pushl $0
  1027f7:	6a 00                	push   $0x0
  pushl $231
  1027f9:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1027fe:	e9 20 01 00 00       	jmp    102923 <__alltraps>

00102803 <vector232>:
.globl vector232
vector232:
  pushl $0
  102803:	6a 00                	push   $0x0
  pushl $232
  102805:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  10280a:	e9 14 01 00 00       	jmp    102923 <__alltraps>

0010280f <vector233>:
.globl vector233
vector233:
  pushl $0
  10280f:	6a 00                	push   $0x0
  pushl $233
  102811:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102816:	e9 08 01 00 00       	jmp    102923 <__alltraps>

0010281b <vector234>:
.globl vector234
vector234:
  pushl $0
  10281b:	6a 00                	push   $0x0
  pushl $234
  10281d:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102822:	e9 fc 00 00 00       	jmp    102923 <__alltraps>

00102827 <vector235>:
.globl vector235
vector235:
  pushl $0
  102827:	6a 00                	push   $0x0
  pushl $235
  102829:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  10282e:	e9 f0 00 00 00       	jmp    102923 <__alltraps>

00102833 <vector236>:
.globl vector236
vector236:
  pushl $0
  102833:	6a 00                	push   $0x0
  pushl $236
  102835:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  10283a:	e9 e4 00 00 00       	jmp    102923 <__alltraps>

0010283f <vector237>:
.globl vector237
vector237:
  pushl $0
  10283f:	6a 00                	push   $0x0
  pushl $237
  102841:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102846:	e9 d8 00 00 00       	jmp    102923 <__alltraps>

0010284b <vector238>:
.globl vector238
vector238:
  pushl $0
  10284b:	6a 00                	push   $0x0
  pushl $238
  10284d:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102852:	e9 cc 00 00 00       	jmp    102923 <__alltraps>

00102857 <vector239>:
.globl vector239
vector239:
  pushl $0
  102857:	6a 00                	push   $0x0
  pushl $239
  102859:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  10285e:	e9 c0 00 00 00       	jmp    102923 <__alltraps>

00102863 <vector240>:
.globl vector240
vector240:
  pushl $0
  102863:	6a 00                	push   $0x0
  pushl $240
  102865:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  10286a:	e9 b4 00 00 00       	jmp    102923 <__alltraps>

0010286f <vector241>:
.globl vector241
vector241:
  pushl $0
  10286f:	6a 00                	push   $0x0
  pushl $241
  102871:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102876:	e9 a8 00 00 00       	jmp    102923 <__alltraps>

0010287b <vector242>:
.globl vector242
vector242:
  pushl $0
  10287b:	6a 00                	push   $0x0
  pushl $242
  10287d:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102882:	e9 9c 00 00 00       	jmp    102923 <__alltraps>

00102887 <vector243>:
.globl vector243
vector243:
  pushl $0
  102887:	6a 00                	push   $0x0
  pushl $243
  102889:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  10288e:	e9 90 00 00 00       	jmp    102923 <__alltraps>

00102893 <vector244>:
.globl vector244
vector244:
  pushl $0
  102893:	6a 00                	push   $0x0
  pushl $244
  102895:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  10289a:	e9 84 00 00 00       	jmp    102923 <__alltraps>

0010289f <vector245>:
.globl vector245
vector245:
  pushl $0
  10289f:	6a 00                	push   $0x0
  pushl $245
  1028a1:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  1028a6:	e9 78 00 00 00       	jmp    102923 <__alltraps>

001028ab <vector246>:
.globl vector246
vector246:
  pushl $0
  1028ab:	6a 00                	push   $0x0
  pushl $246
  1028ad:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  1028b2:	e9 6c 00 00 00       	jmp    102923 <__alltraps>

001028b7 <vector247>:
.globl vector247
vector247:
  pushl $0
  1028b7:	6a 00                	push   $0x0
  pushl $247
  1028b9:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  1028be:	e9 60 00 00 00       	jmp    102923 <__alltraps>

001028c3 <vector248>:
.globl vector248
vector248:
  pushl $0
  1028c3:	6a 00                	push   $0x0
  pushl $248
  1028c5:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  1028ca:	e9 54 00 00 00       	jmp    102923 <__alltraps>

001028cf <vector249>:
.globl vector249
vector249:
  pushl $0
  1028cf:	6a 00                	push   $0x0
  pushl $249
  1028d1:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  1028d6:	e9 48 00 00 00       	jmp    102923 <__alltraps>

001028db <vector250>:
.globl vector250
vector250:
  pushl $0
  1028db:	6a 00                	push   $0x0
  pushl $250
  1028dd:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1028e2:	e9 3c 00 00 00       	jmp    102923 <__alltraps>

001028e7 <vector251>:
.globl vector251
vector251:
  pushl $0
  1028e7:	6a 00                	push   $0x0
  pushl $251
  1028e9:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1028ee:	e9 30 00 00 00       	jmp    102923 <__alltraps>

001028f3 <vector252>:
.globl vector252
vector252:
  pushl $0
  1028f3:	6a 00                	push   $0x0
  pushl $252
  1028f5:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1028fa:	e9 24 00 00 00       	jmp    102923 <__alltraps>

001028ff <vector253>:
.globl vector253
vector253:
  pushl $0
  1028ff:	6a 00                	push   $0x0
  pushl $253
  102901:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102906:	e9 18 00 00 00       	jmp    102923 <__alltraps>

0010290b <vector254>:
.globl vector254
vector254:
  pushl $0
  10290b:	6a 00                	push   $0x0
  pushl $254
  10290d:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102912:	e9 0c 00 00 00       	jmp    102923 <__alltraps>

00102917 <vector255>:
.globl vector255
vector255:
  pushl $0
  102917:	6a 00                	push   $0x0
  pushl $255
  102919:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  10291e:	e9 00 00 00 00       	jmp    102923 <__alltraps>

00102923 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102923:	1e                   	push   %ds
    pushl %es
  102924:	06                   	push   %es
    pushl %fs
  102925:	0f a0                	push   %fs
    pushl %gs
  102927:	0f a8                	push   %gs
    pushal
  102929:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  10292a:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  10292f:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  102931:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  102933:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  102934:	e8 63 f5 ff ff       	call   101e9c <trap>

    # pop the pushed stack pointer
    popl %esp
  102939:	5c                   	pop    %esp

0010293a <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  10293a:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  10293b:	0f a9                	pop    %gs
    popl %fs
  10293d:	0f a1                	pop    %fs
    popl %es
  10293f:	07                   	pop    %es
    popl %ds
  102940:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  102941:	83 c4 08             	add    $0x8,%esp
    iret
  102944:	cf                   	iret   

00102945 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102945:	55                   	push   %ebp
  102946:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102948:	8b 45 08             	mov    0x8(%ebp),%eax
  10294b:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  10294e:	b8 23 00 00 00       	mov    $0x23,%eax
  102953:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102955:	b8 23 00 00 00       	mov    $0x23,%eax
  10295a:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  10295c:	b8 10 00 00 00       	mov    $0x10,%eax
  102961:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102963:	b8 10 00 00 00       	mov    $0x10,%eax
  102968:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  10296a:	b8 10 00 00 00       	mov    $0x10,%eax
  10296f:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102971:	ea 78 29 10 00 08 00 	ljmp   $0x8,$0x102978
}
  102978:	90                   	nop
  102979:	5d                   	pop    %ebp
  10297a:	c3                   	ret    

0010297b <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  10297b:	55                   	push   %ebp
  10297c:	89 e5                	mov    %esp,%ebp
  10297e:	83 ec 10             	sub    $0x10,%esp
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  102981:	b8 80 f9 10 00       	mov    $0x10f980,%eax
  102986:	05 00 04 00 00       	add    $0x400,%eax
  10298b:	a3 a4 f8 10 00       	mov    %eax,0x10f8a4
    ts.ts_ss0 = KERNEL_DS;
  102990:	66 c7 05 a8 f8 10 00 	movw   $0x10,0x10f8a8
  102997:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  102999:	66 c7 05 08 ea 10 00 	movw   $0x68,0x10ea08
  1029a0:	68 00 
  1029a2:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  1029a7:	66 a3 0a ea 10 00    	mov    %ax,0x10ea0a
  1029ad:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  1029b2:	c1 e8 10             	shr    $0x10,%eax
  1029b5:	a2 0c ea 10 00       	mov    %al,0x10ea0c
  1029ba:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029c1:	83 e0 f0             	and    $0xfffffff0,%eax
  1029c4:	83 c8 09             	or     $0x9,%eax
  1029c7:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1029cc:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029d3:	83 c8 10             	or     $0x10,%eax
  1029d6:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1029db:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029e2:	83 e0 9f             	and    $0xffffff9f,%eax
  1029e5:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1029ea:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029f1:	83 c8 80             	or     $0xffffff80,%eax
  1029f4:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1029f9:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a00:	83 e0 f0             	and    $0xfffffff0,%eax
  102a03:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a08:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a0f:	83 e0 ef             	and    $0xffffffef,%eax
  102a12:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a17:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a1e:	83 e0 df             	and    $0xffffffdf,%eax
  102a21:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a26:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a2d:	83 c8 40             	or     $0x40,%eax
  102a30:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a35:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a3c:	83 e0 7f             	and    $0x7f,%eax
  102a3f:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a44:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  102a49:	c1 e8 18             	shr    $0x18,%eax
  102a4c:	a2 0f ea 10 00       	mov    %al,0x10ea0f
    gdt[SEG_TSS].sd_s = 0;
  102a51:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  102a58:	83 e0 ef             	and    $0xffffffef,%eax
  102a5b:	a2 0d ea 10 00       	mov    %al,0x10ea0d

    // reload all segment registers
    lgdt(&gdt_pd);
  102a60:	68 10 ea 10 00       	push   $0x10ea10
  102a65:	e8 db fe ff ff       	call   102945 <lgdt>
  102a6a:	83 c4 04             	add    $0x4,%esp
  102a6d:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  102a73:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102a77:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102a7a:	90                   	nop
  102a7b:	c9                   	leave  
  102a7c:	c3                   	ret    

00102a7d <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  102a7d:	55                   	push   %ebp
  102a7e:	89 e5                	mov    %esp,%ebp
    gdt_init();
  102a80:	e8 f6 fe ff ff       	call   10297b <gdt_init>
}
  102a85:	90                   	nop
  102a86:	5d                   	pop    %ebp
  102a87:	c3                   	ret    

00102a88 <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  102a88:	55                   	push   %ebp
  102a89:	89 e5                	mov    %esp,%ebp
  102a8b:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102a8e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  102a95:	eb 04                	jmp    102a9b <strlen+0x13>
        cnt ++;
  102a97:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  102a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  102a9e:	8d 50 01             	lea    0x1(%eax),%edx
  102aa1:	89 55 08             	mov    %edx,0x8(%ebp)
  102aa4:	0f b6 00             	movzbl (%eax),%eax
  102aa7:	84 c0                	test   %al,%al
  102aa9:	75 ec                	jne    102a97 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  102aab:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102aae:	c9                   	leave  
  102aaf:	c3                   	ret    

00102ab0 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  102ab0:	55                   	push   %ebp
  102ab1:	89 e5                	mov    %esp,%ebp
  102ab3:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102ab6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102abd:	eb 04                	jmp    102ac3 <strnlen+0x13>
        cnt ++;
  102abf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  102ac3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102ac6:	3b 45 0c             	cmp    0xc(%ebp),%eax
  102ac9:	73 10                	jae    102adb <strnlen+0x2b>
  102acb:	8b 45 08             	mov    0x8(%ebp),%eax
  102ace:	8d 50 01             	lea    0x1(%eax),%edx
  102ad1:	89 55 08             	mov    %edx,0x8(%ebp)
  102ad4:	0f b6 00             	movzbl (%eax),%eax
  102ad7:	84 c0                	test   %al,%al
  102ad9:	75 e4                	jne    102abf <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  102adb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102ade:	c9                   	leave  
  102adf:	c3                   	ret    

00102ae0 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  102ae0:	55                   	push   %ebp
  102ae1:	89 e5                	mov    %esp,%ebp
  102ae3:	57                   	push   %edi
  102ae4:	56                   	push   %esi
  102ae5:	83 ec 20             	sub    $0x20,%esp
  102ae8:	8b 45 08             	mov    0x8(%ebp),%eax
  102aeb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102aee:	8b 45 0c             	mov    0xc(%ebp),%eax
  102af1:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  102af4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102afa:	89 d1                	mov    %edx,%ecx
  102afc:	89 c2                	mov    %eax,%edx
  102afe:	89 ce                	mov    %ecx,%esi
  102b00:	89 d7                	mov    %edx,%edi
  102b02:	ac                   	lods   %ds:(%esi),%al
  102b03:	aa                   	stos   %al,%es:(%edi)
  102b04:	84 c0                	test   %al,%al
  102b06:	75 fa                	jne    102b02 <strcpy+0x22>
  102b08:	89 fa                	mov    %edi,%edx
  102b0a:	89 f1                	mov    %esi,%ecx
  102b0c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  102b0f:	89 55 e8             	mov    %edx,-0x18(%ebp)
  102b12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  102b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  102b18:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  102b19:	83 c4 20             	add    $0x20,%esp
  102b1c:	5e                   	pop    %esi
  102b1d:	5f                   	pop    %edi
  102b1e:	5d                   	pop    %ebp
  102b1f:	c3                   	ret    

00102b20 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  102b20:	55                   	push   %ebp
  102b21:	89 e5                	mov    %esp,%ebp
  102b23:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  102b26:	8b 45 08             	mov    0x8(%ebp),%eax
  102b29:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  102b2c:	eb 21                	jmp    102b4f <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  102b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b31:	0f b6 10             	movzbl (%eax),%edx
  102b34:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102b37:	88 10                	mov    %dl,(%eax)
  102b39:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102b3c:	0f b6 00             	movzbl (%eax),%eax
  102b3f:	84 c0                	test   %al,%al
  102b41:	74 04                	je     102b47 <strncpy+0x27>
            src ++;
  102b43:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  102b47:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  102b4b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  102b4f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102b53:	75 d9                	jne    102b2e <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  102b55:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102b58:	c9                   	leave  
  102b59:	c3                   	ret    

00102b5a <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  102b5a:	55                   	push   %ebp
  102b5b:	89 e5                	mov    %esp,%ebp
  102b5d:	57                   	push   %edi
  102b5e:	56                   	push   %esi
  102b5f:	83 ec 20             	sub    $0x20,%esp
  102b62:	8b 45 08             	mov    0x8(%ebp),%eax
  102b65:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102b68:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  102b6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102b71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b74:	89 d1                	mov    %edx,%ecx
  102b76:	89 c2                	mov    %eax,%edx
  102b78:	89 ce                	mov    %ecx,%esi
  102b7a:	89 d7                	mov    %edx,%edi
  102b7c:	ac                   	lods   %ds:(%esi),%al
  102b7d:	ae                   	scas   %es:(%edi),%al
  102b7e:	75 08                	jne    102b88 <strcmp+0x2e>
  102b80:	84 c0                	test   %al,%al
  102b82:	75 f8                	jne    102b7c <strcmp+0x22>
  102b84:	31 c0                	xor    %eax,%eax
  102b86:	eb 04                	jmp    102b8c <strcmp+0x32>
  102b88:	19 c0                	sbb    %eax,%eax
  102b8a:	0c 01                	or     $0x1,%al
  102b8c:	89 fa                	mov    %edi,%edx
  102b8e:	89 f1                	mov    %esi,%ecx
  102b90:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102b93:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102b96:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            "orb $1, %%al;"
            "3:"
            : "=a" (ret), "=&S" (d0), "=&D" (d1)
            : "1" (s1), "2" (s2)
            : "memory");
    return ret;
  102b99:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  102b9c:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  102b9d:	83 c4 20             	add    $0x20,%esp
  102ba0:	5e                   	pop    %esi
  102ba1:	5f                   	pop    %edi
  102ba2:	5d                   	pop    %ebp
  102ba3:	c3                   	ret    

00102ba4 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  102ba4:	55                   	push   %ebp
  102ba5:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102ba7:	eb 0c                	jmp    102bb5 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  102ba9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  102bad:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102bb1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102bb5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102bb9:	74 1a                	je     102bd5 <strncmp+0x31>
  102bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  102bbe:	0f b6 00             	movzbl (%eax),%eax
  102bc1:	84 c0                	test   %al,%al
  102bc3:	74 10                	je     102bd5 <strncmp+0x31>
  102bc5:	8b 45 08             	mov    0x8(%ebp),%eax
  102bc8:	0f b6 10             	movzbl (%eax),%edx
  102bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  102bce:	0f b6 00             	movzbl (%eax),%eax
  102bd1:	38 c2                	cmp    %al,%dl
  102bd3:	74 d4                	je     102ba9 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  102bd5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102bd9:	74 18                	je     102bf3 <strncmp+0x4f>
  102bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  102bde:	0f b6 00             	movzbl (%eax),%eax
  102be1:	0f b6 d0             	movzbl %al,%edx
  102be4:	8b 45 0c             	mov    0xc(%ebp),%eax
  102be7:	0f b6 00             	movzbl (%eax),%eax
  102bea:	0f b6 c0             	movzbl %al,%eax
  102bed:	29 c2                	sub    %eax,%edx
  102bef:	89 d0                	mov    %edx,%eax
  102bf1:	eb 05                	jmp    102bf8 <strncmp+0x54>
  102bf3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102bf8:	5d                   	pop    %ebp
  102bf9:	c3                   	ret    

00102bfa <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  102bfa:	55                   	push   %ebp
  102bfb:	89 e5                	mov    %esp,%ebp
  102bfd:	83 ec 04             	sub    $0x4,%esp
  102c00:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c03:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102c06:	eb 14                	jmp    102c1c <strchr+0x22>
        if (*s == c) {
  102c08:	8b 45 08             	mov    0x8(%ebp),%eax
  102c0b:	0f b6 00             	movzbl (%eax),%eax
  102c0e:	3a 45 fc             	cmp    -0x4(%ebp),%al
  102c11:	75 05                	jne    102c18 <strchr+0x1e>
            return (char *)s;
  102c13:	8b 45 08             	mov    0x8(%ebp),%eax
  102c16:	eb 13                	jmp    102c2b <strchr+0x31>
        }
        s ++;
  102c18:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  102c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  102c1f:	0f b6 00             	movzbl (%eax),%eax
  102c22:	84 c0                	test   %al,%al
  102c24:	75 e2                	jne    102c08 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  102c26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102c2b:	c9                   	leave  
  102c2c:	c3                   	ret    

00102c2d <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  102c2d:	55                   	push   %ebp
  102c2e:	89 e5                	mov    %esp,%ebp
  102c30:	83 ec 04             	sub    $0x4,%esp
  102c33:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c36:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102c39:	eb 0f                	jmp    102c4a <strfind+0x1d>
        if (*s == c) {
  102c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  102c3e:	0f b6 00             	movzbl (%eax),%eax
  102c41:	3a 45 fc             	cmp    -0x4(%ebp),%al
  102c44:	74 10                	je     102c56 <strfind+0x29>
            break;
        }
        s ++;
  102c46:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  102c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  102c4d:	0f b6 00             	movzbl (%eax),%eax
  102c50:	84 c0                	test   %al,%al
  102c52:	75 e7                	jne    102c3b <strfind+0xe>
  102c54:	eb 01                	jmp    102c57 <strfind+0x2a>
        if (*s == c) {
            break;
  102c56:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
  102c57:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102c5a:	c9                   	leave  
  102c5b:	c3                   	ret    

00102c5c <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  102c5c:	55                   	push   %ebp
  102c5d:	89 e5                	mov    %esp,%ebp
  102c5f:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  102c62:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  102c69:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  102c70:	eb 04                	jmp    102c76 <strtol+0x1a>
        s ++;
  102c72:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  102c76:	8b 45 08             	mov    0x8(%ebp),%eax
  102c79:	0f b6 00             	movzbl (%eax),%eax
  102c7c:	3c 20                	cmp    $0x20,%al
  102c7e:	74 f2                	je     102c72 <strtol+0x16>
  102c80:	8b 45 08             	mov    0x8(%ebp),%eax
  102c83:	0f b6 00             	movzbl (%eax),%eax
  102c86:	3c 09                	cmp    $0x9,%al
  102c88:	74 e8                	je     102c72 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  102c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  102c8d:	0f b6 00             	movzbl (%eax),%eax
  102c90:	3c 2b                	cmp    $0x2b,%al
  102c92:	75 06                	jne    102c9a <strtol+0x3e>
        s ++;
  102c94:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102c98:	eb 15                	jmp    102caf <strtol+0x53>
    }
    else if (*s == '-') {
  102c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  102c9d:	0f b6 00             	movzbl (%eax),%eax
  102ca0:	3c 2d                	cmp    $0x2d,%al
  102ca2:	75 0b                	jne    102caf <strtol+0x53>
        s ++, neg = 1;
  102ca4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102ca8:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  102caf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102cb3:	74 06                	je     102cbb <strtol+0x5f>
  102cb5:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  102cb9:	75 24                	jne    102cdf <strtol+0x83>
  102cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  102cbe:	0f b6 00             	movzbl (%eax),%eax
  102cc1:	3c 30                	cmp    $0x30,%al
  102cc3:	75 1a                	jne    102cdf <strtol+0x83>
  102cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  102cc8:	83 c0 01             	add    $0x1,%eax
  102ccb:	0f b6 00             	movzbl (%eax),%eax
  102cce:	3c 78                	cmp    $0x78,%al
  102cd0:	75 0d                	jne    102cdf <strtol+0x83>
        s += 2, base = 16;
  102cd2:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  102cd6:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  102cdd:	eb 2a                	jmp    102d09 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  102cdf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102ce3:	75 17                	jne    102cfc <strtol+0xa0>
  102ce5:	8b 45 08             	mov    0x8(%ebp),%eax
  102ce8:	0f b6 00             	movzbl (%eax),%eax
  102ceb:	3c 30                	cmp    $0x30,%al
  102ced:	75 0d                	jne    102cfc <strtol+0xa0>
        s ++, base = 8;
  102cef:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102cf3:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  102cfa:	eb 0d                	jmp    102d09 <strtol+0xad>
    }
    else if (base == 0) {
  102cfc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102d00:	75 07                	jne    102d09 <strtol+0xad>
        base = 10;
  102d02:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  102d09:	8b 45 08             	mov    0x8(%ebp),%eax
  102d0c:	0f b6 00             	movzbl (%eax),%eax
  102d0f:	3c 2f                	cmp    $0x2f,%al
  102d11:	7e 1b                	jle    102d2e <strtol+0xd2>
  102d13:	8b 45 08             	mov    0x8(%ebp),%eax
  102d16:	0f b6 00             	movzbl (%eax),%eax
  102d19:	3c 39                	cmp    $0x39,%al
  102d1b:	7f 11                	jg     102d2e <strtol+0xd2>
            dig = *s - '0';
  102d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  102d20:	0f b6 00             	movzbl (%eax),%eax
  102d23:	0f be c0             	movsbl %al,%eax
  102d26:	83 e8 30             	sub    $0x30,%eax
  102d29:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102d2c:	eb 48                	jmp    102d76 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  102d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  102d31:	0f b6 00             	movzbl (%eax),%eax
  102d34:	3c 60                	cmp    $0x60,%al
  102d36:	7e 1b                	jle    102d53 <strtol+0xf7>
  102d38:	8b 45 08             	mov    0x8(%ebp),%eax
  102d3b:	0f b6 00             	movzbl (%eax),%eax
  102d3e:	3c 7a                	cmp    $0x7a,%al
  102d40:	7f 11                	jg     102d53 <strtol+0xf7>
            dig = *s - 'a' + 10;
  102d42:	8b 45 08             	mov    0x8(%ebp),%eax
  102d45:	0f b6 00             	movzbl (%eax),%eax
  102d48:	0f be c0             	movsbl %al,%eax
  102d4b:	83 e8 57             	sub    $0x57,%eax
  102d4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102d51:	eb 23                	jmp    102d76 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  102d53:	8b 45 08             	mov    0x8(%ebp),%eax
  102d56:	0f b6 00             	movzbl (%eax),%eax
  102d59:	3c 40                	cmp    $0x40,%al
  102d5b:	7e 3c                	jle    102d99 <strtol+0x13d>
  102d5d:	8b 45 08             	mov    0x8(%ebp),%eax
  102d60:	0f b6 00             	movzbl (%eax),%eax
  102d63:	3c 5a                	cmp    $0x5a,%al
  102d65:	7f 32                	jg     102d99 <strtol+0x13d>
            dig = *s - 'A' + 10;
  102d67:	8b 45 08             	mov    0x8(%ebp),%eax
  102d6a:	0f b6 00             	movzbl (%eax),%eax
  102d6d:	0f be c0             	movsbl %al,%eax
  102d70:	83 e8 37             	sub    $0x37,%eax
  102d73:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  102d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d79:	3b 45 10             	cmp    0x10(%ebp),%eax
  102d7c:	7d 1a                	jge    102d98 <strtol+0x13c>
            break;
        }
        s ++, val = (val * base) + dig;
  102d7e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102d82:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102d85:	0f af 45 10          	imul   0x10(%ebp),%eax
  102d89:	89 c2                	mov    %eax,%edx
  102d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d8e:	01 d0                	add    %edx,%eax
  102d90:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  102d93:	e9 71 ff ff ff       	jmp    102d09 <strtol+0xad>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
  102d98:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
  102d99:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102d9d:	74 08                	je     102da7 <strtol+0x14b>
        *endptr = (char *) s;
  102d9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  102da2:	8b 55 08             	mov    0x8(%ebp),%edx
  102da5:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  102da7:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  102dab:	74 07                	je     102db4 <strtol+0x158>
  102dad:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102db0:	f7 d8                	neg    %eax
  102db2:	eb 03                	jmp    102db7 <strtol+0x15b>
  102db4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  102db7:	c9                   	leave  
  102db8:	c3                   	ret    

00102db9 <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  102db9:	55                   	push   %ebp
  102dba:	89 e5                	mov    %esp,%ebp
  102dbc:	57                   	push   %edi
  102dbd:	83 ec 24             	sub    $0x24,%esp
  102dc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  102dc3:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  102dc6:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  102dca:	8b 55 08             	mov    0x8(%ebp),%edx
  102dcd:	89 55 f8             	mov    %edx,-0x8(%ebp)
  102dd0:	88 45 f7             	mov    %al,-0x9(%ebp)
  102dd3:	8b 45 10             	mov    0x10(%ebp),%eax
  102dd6:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  102dd9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  102ddc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  102de0:	8b 55 f8             	mov    -0x8(%ebp),%edx
  102de3:	89 d7                	mov    %edx,%edi
  102de5:	f3 aa                	rep stos %al,%es:(%edi)
  102de7:	89 fa                	mov    %edi,%edx
  102de9:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  102dec:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  102def:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102df2:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  102df3:	83 c4 24             	add    $0x24,%esp
  102df6:	5f                   	pop    %edi
  102df7:	5d                   	pop    %ebp
  102df8:	c3                   	ret    

00102df9 <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  102df9:	55                   	push   %ebp
  102dfa:	89 e5                	mov    %esp,%ebp
  102dfc:	57                   	push   %edi
  102dfd:	56                   	push   %esi
  102dfe:	53                   	push   %ebx
  102dff:	83 ec 30             	sub    $0x30,%esp
  102e02:	8b 45 08             	mov    0x8(%ebp),%eax
  102e05:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102e08:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102e0e:	8b 45 10             	mov    0x10(%ebp),%eax
  102e11:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  102e14:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e17:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  102e1a:	73 42                	jae    102e5e <memmove+0x65>
  102e1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e1f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102e22:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102e25:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102e28:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102e2b:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  102e2e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102e31:	c1 e8 02             	shr    $0x2,%eax
  102e34:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  102e36:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102e39:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e3c:	89 d7                	mov    %edx,%edi
  102e3e:	89 c6                	mov    %eax,%esi
  102e40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  102e42:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  102e45:	83 e1 03             	and    $0x3,%ecx
  102e48:	74 02                	je     102e4c <memmove+0x53>
  102e4a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102e4c:	89 f0                	mov    %esi,%eax
  102e4e:	89 fa                	mov    %edi,%edx
  102e50:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  102e53:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102e56:	89 45 d0             	mov    %eax,-0x30(%ebp)
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
            : "memory");
    return dst;
  102e59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  102e5c:	eb 36                	jmp    102e94 <memmove+0x9b>
    asm volatile (
            "std;"
            "rep; movsb;"
            "cld;"
            : "=&c" (d0), "=&S" (d1), "=&D" (d2)
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  102e5e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102e61:	8d 50 ff             	lea    -0x1(%eax),%edx
  102e64:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102e67:	01 c2                	add    %eax,%edx
  102e69:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102e6c:	8d 48 ff             	lea    -0x1(%eax),%ecx
  102e6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e72:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  102e75:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102e78:	89 c1                	mov    %eax,%ecx
  102e7a:	89 d8                	mov    %ebx,%eax
  102e7c:	89 d6                	mov    %edx,%esi
  102e7e:	89 c7                	mov    %eax,%edi
  102e80:	fd                   	std    
  102e81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102e83:	fc                   	cld    
  102e84:	89 f8                	mov    %edi,%eax
  102e86:	89 f2                	mov    %esi,%edx
  102e88:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  102e8b:	89 55 c8             	mov    %edx,-0x38(%ebp)
  102e8e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
            "rep; movsb;"
            "cld;"
            : "=&c" (d0), "=&S" (d1), "=&D" (d2)
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
            : "memory");
    return dst;
  102e91:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  102e94:	83 c4 30             	add    $0x30,%esp
  102e97:	5b                   	pop    %ebx
  102e98:	5e                   	pop    %esi
  102e99:	5f                   	pop    %edi
  102e9a:	5d                   	pop    %ebp
  102e9b:	c3                   	ret    

00102e9c <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  102e9c:	55                   	push   %ebp
  102e9d:	89 e5                	mov    %esp,%ebp
  102e9f:	57                   	push   %edi
  102ea0:	56                   	push   %esi
  102ea1:	83 ec 20             	sub    $0x20,%esp
  102ea4:	8b 45 08             	mov    0x8(%ebp),%eax
  102ea7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102eaa:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ead:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102eb0:	8b 45 10             	mov    0x10(%ebp),%eax
  102eb3:	89 45 ec             	mov    %eax,-0x14(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  102eb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102eb9:	c1 e8 02             	shr    $0x2,%eax
  102ebc:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  102ebe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102ec1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ec4:	89 d7                	mov    %edx,%edi
  102ec6:	89 c6                	mov    %eax,%esi
  102ec8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  102eca:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  102ecd:	83 e1 03             	and    $0x3,%ecx
  102ed0:	74 02                	je     102ed4 <memcpy+0x38>
  102ed2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102ed4:	89 f0                	mov    %esi,%eax
  102ed6:	89 fa                	mov    %edi,%edx
  102ed8:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102edb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  102ede:	89 45 e0             	mov    %eax,-0x20(%ebp)
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
            : "memory");
    return dst;
  102ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  102ee4:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  102ee5:	83 c4 20             	add    $0x20,%esp
  102ee8:	5e                   	pop    %esi
  102ee9:	5f                   	pop    %edi
  102eea:	5d                   	pop    %ebp
  102eeb:	c3                   	ret    

00102eec <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  102eec:	55                   	push   %ebp
  102eed:	89 e5                	mov    %esp,%ebp
  102eef:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  102ef2:	8b 45 08             	mov    0x8(%ebp),%eax
  102ef5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  102ef8:	8b 45 0c             	mov    0xc(%ebp),%eax
  102efb:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  102efe:	eb 30                	jmp    102f30 <memcmp+0x44>
        if (*s1 != *s2) {
  102f00:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102f03:	0f b6 10             	movzbl (%eax),%edx
  102f06:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102f09:	0f b6 00             	movzbl (%eax),%eax
  102f0c:	38 c2                	cmp    %al,%dl
  102f0e:	74 18                	je     102f28 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  102f10:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102f13:	0f b6 00             	movzbl (%eax),%eax
  102f16:	0f b6 d0             	movzbl %al,%edx
  102f19:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102f1c:	0f b6 00             	movzbl (%eax),%eax
  102f1f:	0f b6 c0             	movzbl %al,%eax
  102f22:	29 c2                	sub    %eax,%edx
  102f24:	89 d0                	mov    %edx,%eax
  102f26:	eb 1a                	jmp    102f42 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  102f28:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  102f2c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  102f30:	8b 45 10             	mov    0x10(%ebp),%eax
  102f33:	8d 50 ff             	lea    -0x1(%eax),%edx
  102f36:	89 55 10             	mov    %edx,0x10(%ebp)
  102f39:	85 c0                	test   %eax,%eax
  102f3b:	75 c3                	jne    102f00 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  102f3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102f42:	c9                   	leave  
  102f43:	c3                   	ret    

00102f44 <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  102f44:	55                   	push   %ebp
  102f45:	89 e5                	mov    %esp,%ebp
  102f47:	83 ec 38             	sub    $0x38,%esp
  102f4a:	8b 45 10             	mov    0x10(%ebp),%eax
  102f4d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102f50:	8b 45 14             	mov    0x14(%ebp),%eax
  102f53:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  102f56:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f59:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f5c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102f5f:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  102f62:	8b 45 18             	mov    0x18(%ebp),%eax
  102f65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102f68:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102f6b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102f6e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102f71:	89 55 f0             	mov    %edx,-0x10(%ebp)
  102f74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102f7a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102f7e:	74 1c                	je     102f9c <printnum+0x58>
  102f80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f83:	ba 00 00 00 00       	mov    $0x0,%edx
  102f88:	f7 75 e4             	divl   -0x1c(%ebp)
  102f8b:	89 55 f4             	mov    %edx,-0xc(%ebp)
  102f8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f91:	ba 00 00 00 00       	mov    $0x0,%edx
  102f96:	f7 75 e4             	divl   -0x1c(%ebp)
  102f99:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102fa2:	f7 75 e4             	divl   -0x1c(%ebp)
  102fa5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102fa8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  102fab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102fae:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102fb1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102fb4:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102fb7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102fba:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  102fbd:	8b 45 18             	mov    0x18(%ebp),%eax
  102fc0:	ba 00 00 00 00       	mov    $0x0,%edx
  102fc5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102fc8:	77 41                	ja     10300b <printnum+0xc7>
  102fca:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102fcd:	72 05                	jb     102fd4 <printnum+0x90>
  102fcf:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102fd2:	77 37                	ja     10300b <printnum+0xc7>
        printnum(putch, putdat, result, base, width - 1, padc);
  102fd4:	8b 45 1c             	mov    0x1c(%ebp),%eax
  102fd7:	83 e8 01             	sub    $0x1,%eax
  102fda:	83 ec 04             	sub    $0x4,%esp
  102fdd:	ff 75 20             	pushl  0x20(%ebp)
  102fe0:	50                   	push   %eax
  102fe1:	ff 75 18             	pushl  0x18(%ebp)
  102fe4:	ff 75 ec             	pushl  -0x14(%ebp)
  102fe7:	ff 75 e8             	pushl  -0x18(%ebp)
  102fea:	ff 75 0c             	pushl  0xc(%ebp)
  102fed:	ff 75 08             	pushl  0x8(%ebp)
  102ff0:	e8 4f ff ff ff       	call   102f44 <printnum>
  102ff5:	83 c4 20             	add    $0x20,%esp
  102ff8:	eb 1b                	jmp    103015 <printnum+0xd1>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  102ffa:	83 ec 08             	sub    $0x8,%esp
  102ffd:	ff 75 0c             	pushl  0xc(%ebp)
  103000:	ff 75 20             	pushl  0x20(%ebp)
  103003:	8b 45 08             	mov    0x8(%ebp),%eax
  103006:	ff d0                	call   *%eax
  103008:	83 c4 10             	add    $0x10,%esp
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  10300b:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  10300f:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  103013:	7f e5                	jg     102ffa <printnum+0xb6>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  103015:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103018:	05 f0 3c 10 00       	add    $0x103cf0,%eax
  10301d:	0f b6 00             	movzbl (%eax),%eax
  103020:	0f be c0             	movsbl %al,%eax
  103023:	83 ec 08             	sub    $0x8,%esp
  103026:	ff 75 0c             	pushl  0xc(%ebp)
  103029:	50                   	push   %eax
  10302a:	8b 45 08             	mov    0x8(%ebp),%eax
  10302d:	ff d0                	call   *%eax
  10302f:	83 c4 10             	add    $0x10,%esp
}
  103032:	90                   	nop
  103033:	c9                   	leave  
  103034:	c3                   	ret    

00103035 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  103035:	55                   	push   %ebp
  103036:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  103038:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  10303c:	7e 14                	jle    103052 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  10303e:	8b 45 08             	mov    0x8(%ebp),%eax
  103041:	8b 00                	mov    (%eax),%eax
  103043:	8d 48 08             	lea    0x8(%eax),%ecx
  103046:	8b 55 08             	mov    0x8(%ebp),%edx
  103049:	89 0a                	mov    %ecx,(%edx)
  10304b:	8b 50 04             	mov    0x4(%eax),%edx
  10304e:	8b 00                	mov    (%eax),%eax
  103050:	eb 30                	jmp    103082 <getuint+0x4d>
    }
    else if (lflag) {
  103052:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  103056:	74 16                	je     10306e <getuint+0x39>
        return va_arg(*ap, unsigned long);
  103058:	8b 45 08             	mov    0x8(%ebp),%eax
  10305b:	8b 00                	mov    (%eax),%eax
  10305d:	8d 48 04             	lea    0x4(%eax),%ecx
  103060:	8b 55 08             	mov    0x8(%ebp),%edx
  103063:	89 0a                	mov    %ecx,(%edx)
  103065:	8b 00                	mov    (%eax),%eax
  103067:	ba 00 00 00 00       	mov    $0x0,%edx
  10306c:	eb 14                	jmp    103082 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  10306e:	8b 45 08             	mov    0x8(%ebp),%eax
  103071:	8b 00                	mov    (%eax),%eax
  103073:	8d 48 04             	lea    0x4(%eax),%ecx
  103076:	8b 55 08             	mov    0x8(%ebp),%edx
  103079:	89 0a                	mov    %ecx,(%edx)
  10307b:	8b 00                	mov    (%eax),%eax
  10307d:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  103082:	5d                   	pop    %ebp
  103083:	c3                   	ret    

00103084 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  103084:	55                   	push   %ebp
  103085:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  103087:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  10308b:	7e 14                	jle    1030a1 <getint+0x1d>
        return va_arg(*ap, long long);
  10308d:	8b 45 08             	mov    0x8(%ebp),%eax
  103090:	8b 00                	mov    (%eax),%eax
  103092:	8d 48 08             	lea    0x8(%eax),%ecx
  103095:	8b 55 08             	mov    0x8(%ebp),%edx
  103098:	89 0a                	mov    %ecx,(%edx)
  10309a:	8b 50 04             	mov    0x4(%eax),%edx
  10309d:	8b 00                	mov    (%eax),%eax
  10309f:	eb 28                	jmp    1030c9 <getint+0x45>
    }
    else if (lflag) {
  1030a1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1030a5:	74 12                	je     1030b9 <getint+0x35>
        return va_arg(*ap, long);
  1030a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1030aa:	8b 00                	mov    (%eax),%eax
  1030ac:	8d 48 04             	lea    0x4(%eax),%ecx
  1030af:	8b 55 08             	mov    0x8(%ebp),%edx
  1030b2:	89 0a                	mov    %ecx,(%edx)
  1030b4:	8b 00                	mov    (%eax),%eax
  1030b6:	99                   	cltd   
  1030b7:	eb 10                	jmp    1030c9 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  1030b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1030bc:	8b 00                	mov    (%eax),%eax
  1030be:	8d 48 04             	lea    0x4(%eax),%ecx
  1030c1:	8b 55 08             	mov    0x8(%ebp),%edx
  1030c4:	89 0a                	mov    %ecx,(%edx)
  1030c6:	8b 00                	mov    (%eax),%eax
  1030c8:	99                   	cltd   
    }
}
  1030c9:	5d                   	pop    %ebp
  1030ca:	c3                   	ret    

001030cb <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  1030cb:	55                   	push   %ebp
  1030cc:	89 e5                	mov    %esp,%ebp
  1030ce:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
  1030d1:	8d 45 14             	lea    0x14(%ebp),%eax
  1030d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  1030d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1030da:	50                   	push   %eax
  1030db:	ff 75 10             	pushl  0x10(%ebp)
  1030de:	ff 75 0c             	pushl  0xc(%ebp)
  1030e1:	ff 75 08             	pushl  0x8(%ebp)
  1030e4:	e8 06 00 00 00       	call   1030ef <vprintfmt>
  1030e9:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
  1030ec:	90                   	nop
  1030ed:	c9                   	leave  
  1030ee:	c3                   	ret    

001030ef <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  1030ef:	55                   	push   %ebp
  1030f0:	89 e5                	mov    %esp,%ebp
  1030f2:	56                   	push   %esi
  1030f3:	53                   	push   %ebx
  1030f4:	83 ec 20             	sub    $0x20,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1030f7:	eb 17                	jmp    103110 <vprintfmt+0x21>
            if (ch == '\0') {
  1030f9:	85 db                	test   %ebx,%ebx
  1030fb:	0f 84 8e 03 00 00    	je     10348f <vprintfmt+0x3a0>
                return;
            }
            putch(ch, putdat);
  103101:	83 ec 08             	sub    $0x8,%esp
  103104:	ff 75 0c             	pushl  0xc(%ebp)
  103107:	53                   	push   %ebx
  103108:	8b 45 08             	mov    0x8(%ebp),%eax
  10310b:	ff d0                	call   *%eax
  10310d:	83 c4 10             	add    $0x10,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  103110:	8b 45 10             	mov    0x10(%ebp),%eax
  103113:	8d 50 01             	lea    0x1(%eax),%edx
  103116:	89 55 10             	mov    %edx,0x10(%ebp)
  103119:	0f b6 00             	movzbl (%eax),%eax
  10311c:	0f b6 d8             	movzbl %al,%ebx
  10311f:	83 fb 25             	cmp    $0x25,%ebx
  103122:	75 d5                	jne    1030f9 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  103124:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  103128:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  10312f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103132:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  103135:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10313c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10313f:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  103142:	8b 45 10             	mov    0x10(%ebp),%eax
  103145:	8d 50 01             	lea    0x1(%eax),%edx
  103148:	89 55 10             	mov    %edx,0x10(%ebp)
  10314b:	0f b6 00             	movzbl (%eax),%eax
  10314e:	0f b6 d8             	movzbl %al,%ebx
  103151:	8d 43 dd             	lea    -0x23(%ebx),%eax
  103154:	83 f8 55             	cmp    $0x55,%eax
  103157:	0f 87 05 03 00 00    	ja     103462 <vprintfmt+0x373>
  10315d:	8b 04 85 14 3d 10 00 	mov    0x103d14(,%eax,4),%eax
  103164:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  103166:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  10316a:	eb d6                	jmp    103142 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  10316c:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  103170:	eb d0                	jmp    103142 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  103172:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  103179:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10317c:	89 d0                	mov    %edx,%eax
  10317e:	c1 e0 02             	shl    $0x2,%eax
  103181:	01 d0                	add    %edx,%eax
  103183:	01 c0                	add    %eax,%eax
  103185:	01 d8                	add    %ebx,%eax
  103187:	83 e8 30             	sub    $0x30,%eax
  10318a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  10318d:	8b 45 10             	mov    0x10(%ebp),%eax
  103190:	0f b6 00             	movzbl (%eax),%eax
  103193:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  103196:	83 fb 2f             	cmp    $0x2f,%ebx
  103199:	7e 39                	jle    1031d4 <vprintfmt+0xe5>
  10319b:	83 fb 39             	cmp    $0x39,%ebx
  10319e:	7f 34                	jg     1031d4 <vprintfmt+0xe5>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  1031a0:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  1031a4:	eb d3                	jmp    103179 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  1031a6:	8b 45 14             	mov    0x14(%ebp),%eax
  1031a9:	8d 50 04             	lea    0x4(%eax),%edx
  1031ac:	89 55 14             	mov    %edx,0x14(%ebp)
  1031af:	8b 00                	mov    (%eax),%eax
  1031b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  1031b4:	eb 1f                	jmp    1031d5 <vprintfmt+0xe6>

        case '.':
            if (width < 0)
  1031b6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1031ba:	79 86                	jns    103142 <vprintfmt+0x53>
                width = 0;
  1031bc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  1031c3:	e9 7a ff ff ff       	jmp    103142 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  1031c8:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  1031cf:	e9 6e ff ff ff       	jmp    103142 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
  1031d4:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
  1031d5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1031d9:	0f 89 63 ff ff ff    	jns    103142 <vprintfmt+0x53>
                width = precision, precision = -1;
  1031df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1031e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1031e5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  1031ec:	e9 51 ff ff ff       	jmp    103142 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  1031f1:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  1031f5:	e9 48 ff ff ff       	jmp    103142 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  1031fa:	8b 45 14             	mov    0x14(%ebp),%eax
  1031fd:	8d 50 04             	lea    0x4(%eax),%edx
  103200:	89 55 14             	mov    %edx,0x14(%ebp)
  103203:	8b 00                	mov    (%eax),%eax
  103205:	83 ec 08             	sub    $0x8,%esp
  103208:	ff 75 0c             	pushl  0xc(%ebp)
  10320b:	50                   	push   %eax
  10320c:	8b 45 08             	mov    0x8(%ebp),%eax
  10320f:	ff d0                	call   *%eax
  103211:	83 c4 10             	add    $0x10,%esp
            break;
  103214:	e9 71 02 00 00       	jmp    10348a <vprintfmt+0x39b>

        // error message
        case 'e':
            err = va_arg(ap, int);
  103219:	8b 45 14             	mov    0x14(%ebp),%eax
  10321c:	8d 50 04             	lea    0x4(%eax),%edx
  10321f:	89 55 14             	mov    %edx,0x14(%ebp)
  103222:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  103224:	85 db                	test   %ebx,%ebx
  103226:	79 02                	jns    10322a <vprintfmt+0x13b>
                err = -err;
  103228:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  10322a:	83 fb 06             	cmp    $0x6,%ebx
  10322d:	7f 0b                	jg     10323a <vprintfmt+0x14b>
  10322f:	8b 34 9d d4 3c 10 00 	mov    0x103cd4(,%ebx,4),%esi
  103236:	85 f6                	test   %esi,%esi
  103238:	75 19                	jne    103253 <vprintfmt+0x164>
                printfmt(putch, putdat, "error %d", err);
  10323a:	53                   	push   %ebx
  10323b:	68 01 3d 10 00       	push   $0x103d01
  103240:	ff 75 0c             	pushl  0xc(%ebp)
  103243:	ff 75 08             	pushl  0x8(%ebp)
  103246:	e8 80 fe ff ff       	call   1030cb <printfmt>
  10324b:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  10324e:	e9 37 02 00 00       	jmp    10348a <vprintfmt+0x39b>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  103253:	56                   	push   %esi
  103254:	68 0a 3d 10 00       	push   $0x103d0a
  103259:	ff 75 0c             	pushl  0xc(%ebp)
  10325c:	ff 75 08             	pushl  0x8(%ebp)
  10325f:	e8 67 fe ff ff       	call   1030cb <printfmt>
  103264:	83 c4 10             	add    $0x10,%esp
            }
            break;
  103267:	e9 1e 02 00 00       	jmp    10348a <vprintfmt+0x39b>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  10326c:	8b 45 14             	mov    0x14(%ebp),%eax
  10326f:	8d 50 04             	lea    0x4(%eax),%edx
  103272:	89 55 14             	mov    %edx,0x14(%ebp)
  103275:	8b 30                	mov    (%eax),%esi
  103277:	85 f6                	test   %esi,%esi
  103279:	75 05                	jne    103280 <vprintfmt+0x191>
                p = "(null)";
  10327b:	be 0d 3d 10 00       	mov    $0x103d0d,%esi
            }
            if (width > 0 && padc != '-') {
  103280:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103284:	7e 76                	jle    1032fc <vprintfmt+0x20d>
  103286:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  10328a:	74 70                	je     1032fc <vprintfmt+0x20d>
                for (width -= strnlen(p, precision); width > 0; width --) {
  10328c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10328f:	83 ec 08             	sub    $0x8,%esp
  103292:	50                   	push   %eax
  103293:	56                   	push   %esi
  103294:	e8 17 f8 ff ff       	call   102ab0 <strnlen>
  103299:	83 c4 10             	add    $0x10,%esp
  10329c:	89 c2                	mov    %eax,%edx
  10329e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1032a1:	29 d0                	sub    %edx,%eax
  1032a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1032a6:	eb 17                	jmp    1032bf <vprintfmt+0x1d0>
                    putch(padc, putdat);
  1032a8:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  1032ac:	83 ec 08             	sub    $0x8,%esp
  1032af:	ff 75 0c             	pushl  0xc(%ebp)
  1032b2:	50                   	push   %eax
  1032b3:	8b 45 08             	mov    0x8(%ebp),%eax
  1032b6:	ff d0                	call   *%eax
  1032b8:	83 c4 10             	add    $0x10,%esp
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  1032bb:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1032bf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1032c3:	7f e3                	jg     1032a8 <vprintfmt+0x1b9>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1032c5:	eb 35                	jmp    1032fc <vprintfmt+0x20d>
                if (altflag && (ch < ' ' || ch > '~')) {
  1032c7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1032cb:	74 1c                	je     1032e9 <vprintfmt+0x1fa>
  1032cd:	83 fb 1f             	cmp    $0x1f,%ebx
  1032d0:	7e 05                	jle    1032d7 <vprintfmt+0x1e8>
  1032d2:	83 fb 7e             	cmp    $0x7e,%ebx
  1032d5:	7e 12                	jle    1032e9 <vprintfmt+0x1fa>
                    putch('?', putdat);
  1032d7:	83 ec 08             	sub    $0x8,%esp
  1032da:	ff 75 0c             	pushl  0xc(%ebp)
  1032dd:	6a 3f                	push   $0x3f
  1032df:	8b 45 08             	mov    0x8(%ebp),%eax
  1032e2:	ff d0                	call   *%eax
  1032e4:	83 c4 10             	add    $0x10,%esp
  1032e7:	eb 0f                	jmp    1032f8 <vprintfmt+0x209>
                }
                else {
                    putch(ch, putdat);
  1032e9:	83 ec 08             	sub    $0x8,%esp
  1032ec:	ff 75 0c             	pushl  0xc(%ebp)
  1032ef:	53                   	push   %ebx
  1032f0:	8b 45 08             	mov    0x8(%ebp),%eax
  1032f3:	ff d0                	call   *%eax
  1032f5:	83 c4 10             	add    $0x10,%esp
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1032f8:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1032fc:	89 f0                	mov    %esi,%eax
  1032fe:	8d 70 01             	lea    0x1(%eax),%esi
  103301:	0f b6 00             	movzbl (%eax),%eax
  103304:	0f be d8             	movsbl %al,%ebx
  103307:	85 db                	test   %ebx,%ebx
  103309:	74 26                	je     103331 <vprintfmt+0x242>
  10330b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10330f:	78 b6                	js     1032c7 <vprintfmt+0x1d8>
  103311:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  103315:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103319:	79 ac                	jns    1032c7 <vprintfmt+0x1d8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  10331b:	eb 14                	jmp    103331 <vprintfmt+0x242>
                putch(' ', putdat);
  10331d:	83 ec 08             	sub    $0x8,%esp
  103320:	ff 75 0c             	pushl  0xc(%ebp)
  103323:	6a 20                	push   $0x20
  103325:	8b 45 08             	mov    0x8(%ebp),%eax
  103328:	ff d0                	call   *%eax
  10332a:	83 c4 10             	add    $0x10,%esp
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  10332d:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  103331:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103335:	7f e6                	jg     10331d <vprintfmt+0x22e>
                putch(' ', putdat);
            }
            break;
  103337:	e9 4e 01 00 00       	jmp    10348a <vprintfmt+0x39b>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  10333c:	83 ec 08             	sub    $0x8,%esp
  10333f:	ff 75 e0             	pushl  -0x20(%ebp)
  103342:	8d 45 14             	lea    0x14(%ebp),%eax
  103345:	50                   	push   %eax
  103346:	e8 39 fd ff ff       	call   103084 <getint>
  10334b:	83 c4 10             	add    $0x10,%esp
  10334e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103351:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  103354:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103357:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10335a:	85 d2                	test   %edx,%edx
  10335c:	79 23                	jns    103381 <vprintfmt+0x292>
                putch('-', putdat);
  10335e:	83 ec 08             	sub    $0x8,%esp
  103361:	ff 75 0c             	pushl  0xc(%ebp)
  103364:	6a 2d                	push   $0x2d
  103366:	8b 45 08             	mov    0x8(%ebp),%eax
  103369:	ff d0                	call   *%eax
  10336b:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
  10336e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103371:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103374:	f7 d8                	neg    %eax
  103376:	83 d2 00             	adc    $0x0,%edx
  103379:	f7 da                	neg    %edx
  10337b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10337e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  103381:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  103388:	e9 9f 00 00 00       	jmp    10342c <vprintfmt+0x33d>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  10338d:	83 ec 08             	sub    $0x8,%esp
  103390:	ff 75 e0             	pushl  -0x20(%ebp)
  103393:	8d 45 14             	lea    0x14(%ebp),%eax
  103396:	50                   	push   %eax
  103397:	e8 99 fc ff ff       	call   103035 <getuint>
  10339c:	83 c4 10             	add    $0x10,%esp
  10339f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1033a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  1033a5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1033ac:	eb 7e                	jmp    10342c <vprintfmt+0x33d>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  1033ae:	83 ec 08             	sub    $0x8,%esp
  1033b1:	ff 75 e0             	pushl  -0x20(%ebp)
  1033b4:	8d 45 14             	lea    0x14(%ebp),%eax
  1033b7:	50                   	push   %eax
  1033b8:	e8 78 fc ff ff       	call   103035 <getuint>
  1033bd:	83 c4 10             	add    $0x10,%esp
  1033c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1033c3:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  1033c6:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  1033cd:	eb 5d                	jmp    10342c <vprintfmt+0x33d>

        // pointer
        case 'p':
            putch('0', putdat);
  1033cf:	83 ec 08             	sub    $0x8,%esp
  1033d2:	ff 75 0c             	pushl  0xc(%ebp)
  1033d5:	6a 30                	push   $0x30
  1033d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1033da:	ff d0                	call   *%eax
  1033dc:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
  1033df:	83 ec 08             	sub    $0x8,%esp
  1033e2:	ff 75 0c             	pushl  0xc(%ebp)
  1033e5:	6a 78                	push   $0x78
  1033e7:	8b 45 08             	mov    0x8(%ebp),%eax
  1033ea:	ff d0                	call   *%eax
  1033ec:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  1033ef:	8b 45 14             	mov    0x14(%ebp),%eax
  1033f2:	8d 50 04             	lea    0x4(%eax),%edx
  1033f5:	89 55 14             	mov    %edx,0x14(%ebp)
  1033f8:	8b 00                	mov    (%eax),%eax
  1033fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1033fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  103404:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  10340b:	eb 1f                	jmp    10342c <vprintfmt+0x33d>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  10340d:	83 ec 08             	sub    $0x8,%esp
  103410:	ff 75 e0             	pushl  -0x20(%ebp)
  103413:	8d 45 14             	lea    0x14(%ebp),%eax
  103416:	50                   	push   %eax
  103417:	e8 19 fc ff ff       	call   103035 <getuint>
  10341c:	83 c4 10             	add    $0x10,%esp
  10341f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103422:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  103425:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  10342c:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  103430:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103433:	83 ec 04             	sub    $0x4,%esp
  103436:	52                   	push   %edx
  103437:	ff 75 e8             	pushl  -0x18(%ebp)
  10343a:	50                   	push   %eax
  10343b:	ff 75 f4             	pushl  -0xc(%ebp)
  10343e:	ff 75 f0             	pushl  -0x10(%ebp)
  103441:	ff 75 0c             	pushl  0xc(%ebp)
  103444:	ff 75 08             	pushl  0x8(%ebp)
  103447:	e8 f8 fa ff ff       	call   102f44 <printnum>
  10344c:	83 c4 20             	add    $0x20,%esp
            break;
  10344f:	eb 39                	jmp    10348a <vprintfmt+0x39b>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  103451:	83 ec 08             	sub    $0x8,%esp
  103454:	ff 75 0c             	pushl  0xc(%ebp)
  103457:	53                   	push   %ebx
  103458:	8b 45 08             	mov    0x8(%ebp),%eax
  10345b:	ff d0                	call   *%eax
  10345d:	83 c4 10             	add    $0x10,%esp
            break;
  103460:	eb 28                	jmp    10348a <vprintfmt+0x39b>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  103462:	83 ec 08             	sub    $0x8,%esp
  103465:	ff 75 0c             	pushl  0xc(%ebp)
  103468:	6a 25                	push   $0x25
  10346a:	8b 45 08             	mov    0x8(%ebp),%eax
  10346d:	ff d0                	call   *%eax
  10346f:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
  103472:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  103476:	eb 04                	jmp    10347c <vprintfmt+0x38d>
  103478:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  10347c:	8b 45 10             	mov    0x10(%ebp),%eax
  10347f:	83 e8 01             	sub    $0x1,%eax
  103482:	0f b6 00             	movzbl (%eax),%eax
  103485:	3c 25                	cmp    $0x25,%al
  103487:	75 ef                	jne    103478 <vprintfmt+0x389>
                /* do nothing */;
            break;
  103489:	90                   	nop
        }
    }
  10348a:	e9 68 fc ff ff       	jmp    1030f7 <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
  10348f:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  103490:	8d 65 f8             	lea    -0x8(%ebp),%esp
  103493:	5b                   	pop    %ebx
  103494:	5e                   	pop    %esi
  103495:	5d                   	pop    %ebp
  103496:	c3                   	ret    

00103497 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  103497:	55                   	push   %ebp
  103498:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  10349a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10349d:	8b 40 08             	mov    0x8(%eax),%eax
  1034a0:	8d 50 01             	lea    0x1(%eax),%edx
  1034a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034a6:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  1034a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034ac:	8b 10                	mov    (%eax),%edx
  1034ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034b1:	8b 40 04             	mov    0x4(%eax),%eax
  1034b4:	39 c2                	cmp    %eax,%edx
  1034b6:	73 12                	jae    1034ca <sprintputch+0x33>
        *b->buf ++ = ch;
  1034b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034bb:	8b 00                	mov    (%eax),%eax
  1034bd:	8d 48 01             	lea    0x1(%eax),%ecx
  1034c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  1034c3:	89 0a                	mov    %ecx,(%edx)
  1034c5:	8b 55 08             	mov    0x8(%ebp),%edx
  1034c8:	88 10                	mov    %dl,(%eax)
    }
}
  1034ca:	90                   	nop
  1034cb:	5d                   	pop    %ebp
  1034cc:	c3                   	ret    

001034cd <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  1034cd:	55                   	push   %ebp
  1034ce:	89 e5                	mov    %esp,%ebp
  1034d0:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  1034d3:	8d 45 14             	lea    0x14(%ebp),%eax
  1034d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  1034d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034dc:	50                   	push   %eax
  1034dd:	ff 75 10             	pushl  0x10(%ebp)
  1034e0:	ff 75 0c             	pushl  0xc(%ebp)
  1034e3:	ff 75 08             	pushl  0x8(%ebp)
  1034e6:	e8 0b 00 00 00       	call   1034f6 <vsnprintf>
  1034eb:	83 c4 10             	add    $0x10,%esp
  1034ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1034f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1034f4:	c9                   	leave  
  1034f5:	c3                   	ret    

001034f6 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  1034f6:	55                   	push   %ebp
  1034f7:	89 e5                	mov    %esp,%ebp
  1034f9:	83 ec 18             	sub    $0x18,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  1034fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1034ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103502:	8b 45 0c             	mov    0xc(%ebp),%eax
  103505:	8d 50 ff             	lea    -0x1(%eax),%edx
  103508:	8b 45 08             	mov    0x8(%ebp),%eax
  10350b:	01 d0                	add    %edx,%eax
  10350d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103510:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  103517:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10351b:	74 0a                	je     103527 <vsnprintf+0x31>
  10351d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103520:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103523:	39 c2                	cmp    %eax,%edx
  103525:	76 07                	jbe    10352e <vsnprintf+0x38>
        return -E_INVAL;
  103527:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  10352c:	eb 20                	jmp    10354e <vsnprintf+0x58>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  10352e:	ff 75 14             	pushl  0x14(%ebp)
  103531:	ff 75 10             	pushl  0x10(%ebp)
  103534:	8d 45 ec             	lea    -0x14(%ebp),%eax
  103537:	50                   	push   %eax
  103538:	68 97 34 10 00       	push   $0x103497
  10353d:	e8 ad fb ff ff       	call   1030ef <vprintfmt>
  103542:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
  103545:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103548:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  10354b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10354e:	c9                   	leave  
  10354f:	c3                   	ret    
