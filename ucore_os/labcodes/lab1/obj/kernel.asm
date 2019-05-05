
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100000:	55                   	push   %ebp
  100001:	89 e5                	mov    %esp,%ebp
  100003:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100006:	ba 20 fd 10 00       	mov    $0x10fd20,%edx
  10000b:	b8 16 ea 10 00       	mov    $0x10ea16,%eax
  100010:	29 c2                	sub    %eax,%edx
  100012:	89 d0                	mov    %edx,%eax
  100014:	89 44 24 08          	mov    %eax,0x8(%esp)
  100018:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10001f:	00 
  100020:	c7 04 24 16 ea 10 00 	movl   $0x10ea16,(%esp)
  100027:	e8 3c 2c 00 00       	call   102c68 <memset>

    cons_init();                // init the console
  10002c:	e8 42 15 00 00       	call   101573 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100031:	c7 45 f4 80 34 10 00 	movl   $0x103480,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10003b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10003f:	c7 04 24 9c 34 10 00 	movl   $0x10349c,(%esp)
  100046:	e8 1c 02 00 00       	call   100267 <cprintf>

    print_kerninfo();
  10004b:	e8 bd 08 00 00       	call   10090d <print_kerninfo>

    grade_backtrace();
  100050:	e8 89 00 00 00       	call   1000de <grade_backtrace>

    pmm_init();                 // init physical memory management
  100055:	e8 e3 28 00 00       	call   10293d <pmm_init>

    pic_init();                 // init interrupt controller
  10005a:	e8 52 16 00 00       	call   1016b1 <pic_init>
    idt_init();                 // init interrupt descriptor table
  10005f:	e8 ab 17 00 00       	call   10180f <idt_init>

    clock_init();               // init clock interrupt
  100064:	e8 fb 0c 00 00       	call   100d64 <clock_init>
    intr_enable();              // enable irq interrupt
  100069:	e8 76 17 00 00       	call   1017e4 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  10006e:	eb fe                	jmp    10006e <kern_init+0x6e>

00100070 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  100070:	55                   	push   %ebp
  100071:	89 e5                	mov    %esp,%ebp
  100073:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  100076:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10007d:	00 
  10007e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100085:	00 
  100086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10008d:	e8 c0 0c 00 00       	call   100d52 <mon_backtrace>
}
  100092:	90                   	nop
  100093:	c9                   	leave  
  100094:	c3                   	ret    

00100095 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  100095:	55                   	push   %ebp
  100096:	89 e5                	mov    %esp,%ebp
  100098:	53                   	push   %ebx
  100099:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  10009c:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  10009f:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000a2:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1000a8:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000ac:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000b4:	89 04 24             	mov    %eax,(%esp)
  1000b7:	e8 b4 ff ff ff       	call   100070 <grade_backtrace2>
}
  1000bc:	90                   	nop
  1000bd:	83 c4 14             	add    $0x14,%esp
  1000c0:	5b                   	pop    %ebx
  1000c1:	5d                   	pop    %ebp
  1000c2:	c3                   	ret    

001000c3 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000c3:	55                   	push   %ebp
  1000c4:	89 e5                	mov    %esp,%ebp
  1000c6:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000c9:	8b 45 10             	mov    0x10(%ebp),%eax
  1000cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000d0:	8b 45 08             	mov    0x8(%ebp),%eax
  1000d3:	89 04 24             	mov    %eax,(%esp)
  1000d6:	e8 ba ff ff ff       	call   100095 <grade_backtrace1>
}
  1000db:	90                   	nop
  1000dc:	c9                   	leave  
  1000dd:	c3                   	ret    

001000de <grade_backtrace>:

void
grade_backtrace(void) {
  1000de:	55                   	push   %ebp
  1000df:	89 e5                	mov    %esp,%ebp
  1000e1:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  1000e4:	b8 00 00 10 00       	mov    $0x100000,%eax
  1000e9:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  1000f0:	ff 
  1000f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000fc:	e8 c2 ff ff ff       	call   1000c3 <grade_backtrace0>
}
  100101:	90                   	nop
  100102:	c9                   	leave  
  100103:	c3                   	ret    

00100104 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100104:	55                   	push   %ebp
  100105:	89 e5                	mov    %esp,%ebp
  100107:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  10010a:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  10010d:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100110:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100113:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100116:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10011a:	83 e0 03             	and    $0x3,%eax
  10011d:	89 c2                	mov    %eax,%edx
  10011f:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100124:	89 54 24 08          	mov    %edx,0x8(%esp)
  100128:	89 44 24 04          	mov    %eax,0x4(%esp)
  10012c:	c7 04 24 a1 34 10 00 	movl   $0x1034a1,(%esp)
  100133:	e8 2f 01 00 00       	call   100267 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100138:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10013c:	89 c2                	mov    %eax,%edx
  10013e:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100143:	89 54 24 08          	mov    %edx,0x8(%esp)
  100147:	89 44 24 04          	mov    %eax,0x4(%esp)
  10014b:	c7 04 24 af 34 10 00 	movl   $0x1034af,(%esp)
  100152:	e8 10 01 00 00       	call   100267 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100157:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  10015b:	89 c2                	mov    %eax,%edx
  10015d:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100162:	89 54 24 08          	mov    %edx,0x8(%esp)
  100166:	89 44 24 04          	mov    %eax,0x4(%esp)
  10016a:	c7 04 24 bd 34 10 00 	movl   $0x1034bd,(%esp)
  100171:	e8 f1 00 00 00       	call   100267 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  100176:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  10017a:	89 c2                	mov    %eax,%edx
  10017c:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100181:	89 54 24 08          	mov    %edx,0x8(%esp)
  100185:	89 44 24 04          	mov    %eax,0x4(%esp)
  100189:	c7 04 24 cb 34 10 00 	movl   $0x1034cb,(%esp)
  100190:	e8 d2 00 00 00       	call   100267 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  100195:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  100199:	89 c2                	mov    %eax,%edx
  10019b:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  1001a0:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a8:	c7 04 24 d9 34 10 00 	movl   $0x1034d9,(%esp)
  1001af:	e8 b3 00 00 00       	call   100267 <cprintf>
    round ++;
  1001b4:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  1001b9:	40                   	inc    %eax
  1001ba:	a3 20 ea 10 00       	mov    %eax,0x10ea20
}
  1001bf:	90                   	nop
  1001c0:	c9                   	leave  
  1001c1:	c3                   	ret    

001001c2 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001c2:	55                   	push   %ebp
  1001c3:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
   asm volatile (
  1001c5:	83 ec 08             	sub    $0x8,%esp
  1001c8:	cd 78                	int    $0x78
  1001ca:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp"
	    : 
	    : "i"(T_SWITCH_TOU)
	);
}
  1001cc:	90                   	nop
  1001cd:	5d                   	pop    %ebp
  1001ce:	c3                   	ret    

001001cf <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001cf:	55                   	push   %ebp
  1001d0:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile (
  1001d2:	cd 79                	int    $0x79
  1001d4:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp \n"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
}
  1001d6:	90                   	nop
  1001d7:	5d                   	pop    %ebp
  1001d8:	c3                   	ret    

001001d9 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  1001d9:	55                   	push   %ebp
  1001da:	89 e5                	mov    %esp,%ebp
  1001dc:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  1001df:	e8 20 ff ff ff       	call   100104 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  1001e4:	c7 04 24 e8 34 10 00 	movl   $0x1034e8,(%esp)
  1001eb:	e8 77 00 00 00       	call   100267 <cprintf>
    lab1_switch_to_user();
  1001f0:	e8 cd ff ff ff       	call   1001c2 <lab1_switch_to_user>
    lab1_print_cur_status();
  1001f5:	e8 0a ff ff ff       	call   100104 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  1001fa:	c7 04 24 08 35 10 00 	movl   $0x103508,(%esp)
  100201:	e8 61 00 00 00       	call   100267 <cprintf>
    lab1_switch_to_kernel();
  100206:	e8 c4 ff ff ff       	call   1001cf <lab1_switch_to_kernel>
    lab1_print_cur_status();
  10020b:	e8 f4 fe ff ff       	call   100104 <lab1_print_cur_status>
}
  100210:	90                   	nop
  100211:	c9                   	leave  
  100212:	c3                   	ret    

00100213 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  100213:	55                   	push   %ebp
  100214:	89 e5                	mov    %esp,%ebp
  100216:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100219:	8b 45 08             	mov    0x8(%ebp),%eax
  10021c:	89 04 24             	mov    %eax,(%esp)
  10021f:	e8 7c 13 00 00       	call   1015a0 <cons_putc>
    (*cnt) ++;
  100224:	8b 45 0c             	mov    0xc(%ebp),%eax
  100227:	8b 00                	mov    (%eax),%eax
  100229:	8d 50 01             	lea    0x1(%eax),%edx
  10022c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10022f:	89 10                	mov    %edx,(%eax)
}
  100231:	90                   	nop
  100232:	c9                   	leave  
  100233:	c3                   	ret    

00100234 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100234:	55                   	push   %ebp
  100235:	89 e5                	mov    %esp,%ebp
  100237:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10023a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100241:	8b 45 0c             	mov    0xc(%ebp),%eax
  100244:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100248:	8b 45 08             	mov    0x8(%ebp),%eax
  10024b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10024f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  100252:	89 44 24 04          	mov    %eax,0x4(%esp)
  100256:	c7 04 24 13 02 10 00 	movl   $0x100213,(%esp)
  10025d:	e8 59 2d 00 00       	call   102fbb <vprintfmt>
    return cnt;
  100262:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100265:	c9                   	leave  
  100266:	c3                   	ret    

00100267 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100267:	55                   	push   %ebp
  100268:	89 e5                	mov    %esp,%ebp
  10026a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10026d:	8d 45 0c             	lea    0xc(%ebp),%eax
  100270:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100273:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100276:	89 44 24 04          	mov    %eax,0x4(%esp)
  10027a:	8b 45 08             	mov    0x8(%ebp),%eax
  10027d:	89 04 24             	mov    %eax,(%esp)
  100280:	e8 af ff ff ff       	call   100234 <vcprintf>
  100285:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100288:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10028b:	c9                   	leave  
  10028c:	c3                   	ret    

0010028d <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  10028d:	55                   	push   %ebp
  10028e:	89 e5                	mov    %esp,%ebp
  100290:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100293:	8b 45 08             	mov    0x8(%ebp),%eax
  100296:	89 04 24             	mov    %eax,(%esp)
  100299:	e8 02 13 00 00       	call   1015a0 <cons_putc>
}
  10029e:	90                   	nop
  10029f:	c9                   	leave  
  1002a0:	c3                   	ret    

001002a1 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1002a1:	55                   	push   %ebp
  1002a2:	89 e5                	mov    %esp,%ebp
  1002a4:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002a7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1002ae:	eb 13                	jmp    1002c3 <cputs+0x22>
        cputch(c, &cnt);
  1002b0:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1002b4:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002b7:	89 54 24 04          	mov    %edx,0x4(%esp)
  1002bb:	89 04 24             	mov    %eax,(%esp)
  1002be:	e8 50 ff ff ff       	call   100213 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  1002c3:	8b 45 08             	mov    0x8(%ebp),%eax
  1002c6:	8d 50 01             	lea    0x1(%eax),%edx
  1002c9:	89 55 08             	mov    %edx,0x8(%ebp)
  1002cc:	0f b6 00             	movzbl (%eax),%eax
  1002cf:	88 45 f7             	mov    %al,-0x9(%ebp)
  1002d2:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1002d6:	75 d8                	jne    1002b0 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  1002d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1002db:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002df:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1002e6:	e8 28 ff ff ff       	call   100213 <cputch>
    return cnt;
  1002eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1002ee:	c9                   	leave  
  1002ef:	c3                   	ret    

001002f0 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1002f0:	55                   	push   %ebp
  1002f1:	89 e5                	mov    %esp,%ebp
  1002f3:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1002f6:	e8 cf 12 00 00       	call   1015ca <cons_getc>
  1002fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1002fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100302:	74 f2                	je     1002f6 <getchar+0x6>
        /* do nothing */;
    return c;
  100304:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100307:	c9                   	leave  
  100308:	c3                   	ret    

00100309 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100309:	55                   	push   %ebp
  10030a:	89 e5                	mov    %esp,%ebp
  10030c:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10030f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100313:	74 13                	je     100328 <readline+0x1f>
        cprintf("%s", prompt);
  100315:	8b 45 08             	mov    0x8(%ebp),%eax
  100318:	89 44 24 04          	mov    %eax,0x4(%esp)
  10031c:	c7 04 24 27 35 10 00 	movl   $0x103527,(%esp)
  100323:	e8 3f ff ff ff       	call   100267 <cprintf>
    }
    int i = 0, c;
  100328:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10032f:	e8 bc ff ff ff       	call   1002f0 <getchar>
  100334:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100337:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10033b:	79 07                	jns    100344 <readline+0x3b>
            return NULL;
  10033d:	b8 00 00 00 00       	mov    $0x0,%eax
  100342:	eb 78                	jmp    1003bc <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100344:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100348:	7e 28                	jle    100372 <readline+0x69>
  10034a:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100351:	7f 1f                	jg     100372 <readline+0x69>
            cputchar(c);
  100353:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100356:	89 04 24             	mov    %eax,(%esp)
  100359:	e8 2f ff ff ff       	call   10028d <cputchar>
            buf[i ++] = c;
  10035e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100361:	8d 50 01             	lea    0x1(%eax),%edx
  100364:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100367:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10036a:	88 90 40 ea 10 00    	mov    %dl,0x10ea40(%eax)
  100370:	eb 45                	jmp    1003b7 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  100372:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  100376:	75 16                	jne    10038e <readline+0x85>
  100378:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10037c:	7e 10                	jle    10038e <readline+0x85>
            cputchar(c);
  10037e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100381:	89 04 24             	mov    %eax,(%esp)
  100384:	e8 04 ff ff ff       	call   10028d <cputchar>
            i --;
  100389:	ff 4d f4             	decl   -0xc(%ebp)
  10038c:	eb 29                	jmp    1003b7 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  10038e:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  100392:	74 06                	je     10039a <readline+0x91>
  100394:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  100398:	75 95                	jne    10032f <readline+0x26>
            cputchar(c);
  10039a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10039d:	89 04 24             	mov    %eax,(%esp)
  1003a0:	e8 e8 fe ff ff       	call   10028d <cputchar>
            buf[i] = '\0';
  1003a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003a8:	05 40 ea 10 00       	add    $0x10ea40,%eax
  1003ad:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003b0:	b8 40 ea 10 00       	mov    $0x10ea40,%eax
  1003b5:	eb 05                	jmp    1003bc <readline+0xb3>
        }
    }
  1003b7:	e9 73 ff ff ff       	jmp    10032f <readline+0x26>
}
  1003bc:	c9                   	leave  
  1003bd:	c3                   	ret    

001003be <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003be:	55                   	push   %ebp
  1003bf:	89 e5                	mov    %esp,%ebp
  1003c1:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  1003c4:	a1 40 ee 10 00       	mov    0x10ee40,%eax
  1003c9:	85 c0                	test   %eax,%eax
  1003cb:	75 5b                	jne    100428 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  1003cd:	c7 05 40 ee 10 00 01 	movl   $0x1,0x10ee40
  1003d4:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  1003d7:	8d 45 14             	lea    0x14(%ebp),%eax
  1003da:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  1003dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1003e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1003e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1003e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003eb:	c7 04 24 2a 35 10 00 	movl   $0x10352a,(%esp)
  1003f2:	e8 70 fe ff ff       	call   100267 <cprintf>
    vcprintf(fmt, ap);
  1003f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003fe:	8b 45 10             	mov    0x10(%ebp),%eax
  100401:	89 04 24             	mov    %eax,(%esp)
  100404:	e8 2b fe ff ff       	call   100234 <vcprintf>
    cprintf("\n");
  100409:	c7 04 24 46 35 10 00 	movl   $0x103546,(%esp)
  100410:	e8 52 fe ff ff       	call   100267 <cprintf>
    
    cprintf("stack trackback:\n");
  100415:	c7 04 24 48 35 10 00 	movl   $0x103548,(%esp)
  10041c:	e8 46 fe ff ff       	call   100267 <cprintf>
    print_stackframe();
  100421:	e8 32 06 00 00       	call   100a58 <print_stackframe>
  100426:	eb 01                	jmp    100429 <__panic+0x6b>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
  100428:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
  100429:	e8 bd 13 00 00       	call   1017eb <intr_disable>
    while (1) {
        kmonitor(NULL);
  10042e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100435:	e8 4b 08 00 00       	call   100c85 <kmonitor>
    }
  10043a:	eb f2                	jmp    10042e <__panic+0x70>

0010043c <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  10043c:	55                   	push   %ebp
  10043d:	89 e5                	mov    %esp,%ebp
  10043f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100442:	8d 45 14             	lea    0x14(%ebp),%eax
  100445:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100448:	8b 45 0c             	mov    0xc(%ebp),%eax
  10044b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10044f:	8b 45 08             	mov    0x8(%ebp),%eax
  100452:	89 44 24 04          	mov    %eax,0x4(%esp)
  100456:	c7 04 24 5a 35 10 00 	movl   $0x10355a,(%esp)
  10045d:	e8 05 fe ff ff       	call   100267 <cprintf>
    vcprintf(fmt, ap);
  100462:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100465:	89 44 24 04          	mov    %eax,0x4(%esp)
  100469:	8b 45 10             	mov    0x10(%ebp),%eax
  10046c:	89 04 24             	mov    %eax,(%esp)
  10046f:	e8 c0 fd ff ff       	call   100234 <vcprintf>
    cprintf("\n");
  100474:	c7 04 24 46 35 10 00 	movl   $0x103546,(%esp)
  10047b:	e8 e7 fd ff ff       	call   100267 <cprintf>
    va_end(ap);
}
  100480:	90                   	nop
  100481:	c9                   	leave  
  100482:	c3                   	ret    

00100483 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100483:	55                   	push   %ebp
  100484:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100486:	a1 40 ee 10 00       	mov    0x10ee40,%eax
}
  10048b:	5d                   	pop    %ebp
  10048c:	c3                   	ret    

0010048d <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  10048d:	55                   	push   %ebp
  10048e:	89 e5                	mov    %esp,%ebp
  100490:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  100493:	8b 45 0c             	mov    0xc(%ebp),%eax
  100496:	8b 00                	mov    (%eax),%eax
  100498:	89 45 fc             	mov    %eax,-0x4(%ebp)
  10049b:	8b 45 10             	mov    0x10(%ebp),%eax
  10049e:	8b 00                	mov    (%eax),%eax
  1004a0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1004aa:	e9 ca 00 00 00       	jmp    100579 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  1004af:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1004b5:	01 d0                	add    %edx,%eax
  1004b7:	89 c2                	mov    %eax,%edx
  1004b9:	c1 ea 1f             	shr    $0x1f,%edx
  1004bc:	01 d0                	add    %edx,%eax
  1004be:	d1 f8                	sar    %eax
  1004c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004c6:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004c9:	eb 03                	jmp    1004ce <stab_binsearch+0x41>
            m --;
  1004cb:	ff 4d f0             	decl   -0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004d1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004d4:	7c 1f                	jl     1004f5 <stab_binsearch+0x68>
  1004d6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004d9:	89 d0                	mov    %edx,%eax
  1004db:	01 c0                	add    %eax,%eax
  1004dd:	01 d0                	add    %edx,%eax
  1004df:	c1 e0 02             	shl    $0x2,%eax
  1004e2:	89 c2                	mov    %eax,%edx
  1004e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1004e7:	01 d0                	add    %edx,%eax
  1004e9:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1004ed:	0f b6 c0             	movzbl %al,%eax
  1004f0:	3b 45 14             	cmp    0x14(%ebp),%eax
  1004f3:	75 d6                	jne    1004cb <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  1004f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004f8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004fb:	7d 09                	jge    100506 <stab_binsearch+0x79>
            l = true_m + 1;
  1004fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100500:	40                   	inc    %eax
  100501:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100504:	eb 73                	jmp    100579 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  100506:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  10050d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100510:	89 d0                	mov    %edx,%eax
  100512:	01 c0                	add    %eax,%eax
  100514:	01 d0                	add    %edx,%eax
  100516:	c1 e0 02             	shl    $0x2,%eax
  100519:	89 c2                	mov    %eax,%edx
  10051b:	8b 45 08             	mov    0x8(%ebp),%eax
  10051e:	01 d0                	add    %edx,%eax
  100520:	8b 40 08             	mov    0x8(%eax),%eax
  100523:	3b 45 18             	cmp    0x18(%ebp),%eax
  100526:	73 11                	jae    100539 <stab_binsearch+0xac>
            *region_left = m;
  100528:	8b 45 0c             	mov    0xc(%ebp),%eax
  10052b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10052e:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  100530:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100533:	40                   	inc    %eax
  100534:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100537:	eb 40                	jmp    100579 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  100539:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10053c:	89 d0                	mov    %edx,%eax
  10053e:	01 c0                	add    %eax,%eax
  100540:	01 d0                	add    %edx,%eax
  100542:	c1 e0 02             	shl    $0x2,%eax
  100545:	89 c2                	mov    %eax,%edx
  100547:	8b 45 08             	mov    0x8(%ebp),%eax
  10054a:	01 d0                	add    %edx,%eax
  10054c:	8b 40 08             	mov    0x8(%eax),%eax
  10054f:	3b 45 18             	cmp    0x18(%ebp),%eax
  100552:	76 14                	jbe    100568 <stab_binsearch+0xdb>
            *region_right = m - 1;
  100554:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100557:	8d 50 ff             	lea    -0x1(%eax),%edx
  10055a:	8b 45 10             	mov    0x10(%ebp),%eax
  10055d:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  10055f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100562:	48                   	dec    %eax
  100563:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100566:	eb 11                	jmp    100579 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  100568:	8b 45 0c             	mov    0xc(%ebp),%eax
  10056b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10056e:	89 10                	mov    %edx,(%eax)
            l = m;
  100570:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100573:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  100576:	ff 45 18             	incl   0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  100579:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10057c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  10057f:	0f 8e 2a ff ff ff    	jle    1004af <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  100585:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100589:	75 0f                	jne    10059a <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  10058b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10058e:	8b 00                	mov    (%eax),%eax
  100590:	8d 50 ff             	lea    -0x1(%eax),%edx
  100593:	8b 45 10             	mov    0x10(%ebp),%eax
  100596:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  100598:	eb 3e                	jmp    1005d8 <stab_binsearch+0x14b>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  10059a:	8b 45 10             	mov    0x10(%ebp),%eax
  10059d:	8b 00                	mov    (%eax),%eax
  10059f:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1005a2:	eb 03                	jmp    1005a7 <stab_binsearch+0x11a>
  1005a4:	ff 4d fc             	decl   -0x4(%ebp)
  1005a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005aa:	8b 00                	mov    (%eax),%eax
  1005ac:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1005af:	7d 1f                	jge    1005d0 <stab_binsearch+0x143>
  1005b1:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005b4:	89 d0                	mov    %edx,%eax
  1005b6:	01 c0                	add    %eax,%eax
  1005b8:	01 d0                	add    %edx,%eax
  1005ba:	c1 e0 02             	shl    $0x2,%eax
  1005bd:	89 c2                	mov    %eax,%edx
  1005bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1005c2:	01 d0                	add    %edx,%eax
  1005c4:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1005c8:	0f b6 c0             	movzbl %al,%eax
  1005cb:	3b 45 14             	cmp    0x14(%ebp),%eax
  1005ce:	75 d4                	jne    1005a4 <stab_binsearch+0x117>
            /* do nothing */;
        *region_left = l;
  1005d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005d3:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005d6:	89 10                	mov    %edx,(%eax)
    }
}
  1005d8:	90                   	nop
  1005d9:	c9                   	leave  
  1005da:	c3                   	ret    

001005db <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  1005db:	55                   	push   %ebp
  1005dc:	89 e5                	mov    %esp,%ebp
  1005de:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  1005e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005e4:	c7 00 78 35 10 00    	movl   $0x103578,(%eax)
    info->eip_line = 0;
  1005ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005ed:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  1005f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005f7:	c7 40 08 78 35 10 00 	movl   $0x103578,0x8(%eax)
    info->eip_fn_namelen = 9;
  1005fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  100601:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100608:	8b 45 0c             	mov    0xc(%ebp),%eax
  10060b:	8b 55 08             	mov    0x8(%ebp),%edx
  10060e:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100611:	8b 45 0c             	mov    0xc(%ebp),%eax
  100614:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  10061b:	c7 45 f4 8c 3d 10 00 	movl   $0x103d8c,-0xc(%ebp)
    stab_end = __STAB_END__;
  100622:	c7 45 f0 cc b7 10 00 	movl   $0x10b7cc,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100629:	c7 45 ec cd b7 10 00 	movl   $0x10b7cd,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100630:	c7 45 e8 24 d8 10 00 	movl   $0x10d824,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  100637:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10063a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10063d:	76 0b                	jbe    10064a <debuginfo_eip+0x6f>
  10063f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100642:	48                   	dec    %eax
  100643:	0f b6 00             	movzbl (%eax),%eax
  100646:	84 c0                	test   %al,%al
  100648:	74 0a                	je     100654 <debuginfo_eip+0x79>
        return -1;
  10064a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10064f:	e9 b7 02 00 00       	jmp    10090b <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  100654:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  10065b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10065e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100661:	29 c2                	sub    %eax,%edx
  100663:	89 d0                	mov    %edx,%eax
  100665:	c1 f8 02             	sar    $0x2,%eax
  100668:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  10066e:	48                   	dec    %eax
  10066f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  100672:	8b 45 08             	mov    0x8(%ebp),%eax
  100675:	89 44 24 10          	mov    %eax,0x10(%esp)
  100679:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  100680:	00 
  100681:	8d 45 e0             	lea    -0x20(%ebp),%eax
  100684:	89 44 24 08          	mov    %eax,0x8(%esp)
  100688:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  10068b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10068f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100692:	89 04 24             	mov    %eax,(%esp)
  100695:	e8 f3 fd ff ff       	call   10048d <stab_binsearch>
    if (lfile == 0)
  10069a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10069d:	85 c0                	test   %eax,%eax
  10069f:	75 0a                	jne    1006ab <debuginfo_eip+0xd0>
        return -1;
  1006a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006a6:	e9 60 02 00 00       	jmp    10090b <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006ae:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1006b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1006b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1006ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006be:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  1006c5:	00 
  1006c6:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1006c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006cd:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1006d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006d7:	89 04 24             	mov    %eax,(%esp)
  1006da:	e8 ae fd ff ff       	call   10048d <stab_binsearch>

    if (lfun <= rfun) {
  1006df:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1006e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006e5:	39 c2                	cmp    %eax,%edx
  1006e7:	7f 7c                	jg     100765 <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  1006e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006ec:	89 c2                	mov    %eax,%edx
  1006ee:	89 d0                	mov    %edx,%eax
  1006f0:	01 c0                	add    %eax,%eax
  1006f2:	01 d0                	add    %edx,%eax
  1006f4:	c1 e0 02             	shl    $0x2,%eax
  1006f7:	89 c2                	mov    %eax,%edx
  1006f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006fc:	01 d0                	add    %edx,%eax
  1006fe:	8b 00                	mov    (%eax),%eax
  100700:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100703:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100706:	29 d1                	sub    %edx,%ecx
  100708:	89 ca                	mov    %ecx,%edx
  10070a:	39 d0                	cmp    %edx,%eax
  10070c:	73 22                	jae    100730 <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  10070e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100711:	89 c2                	mov    %eax,%edx
  100713:	89 d0                	mov    %edx,%eax
  100715:	01 c0                	add    %eax,%eax
  100717:	01 d0                	add    %edx,%eax
  100719:	c1 e0 02             	shl    $0x2,%eax
  10071c:	89 c2                	mov    %eax,%edx
  10071e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100721:	01 d0                	add    %edx,%eax
  100723:	8b 10                	mov    (%eax),%edx
  100725:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100728:	01 c2                	add    %eax,%edx
  10072a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10072d:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100730:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100733:	89 c2                	mov    %eax,%edx
  100735:	89 d0                	mov    %edx,%eax
  100737:	01 c0                	add    %eax,%eax
  100739:	01 d0                	add    %edx,%eax
  10073b:	c1 e0 02             	shl    $0x2,%eax
  10073e:	89 c2                	mov    %eax,%edx
  100740:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100743:	01 d0                	add    %edx,%eax
  100745:	8b 50 08             	mov    0x8(%eax),%edx
  100748:	8b 45 0c             	mov    0xc(%ebp),%eax
  10074b:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  10074e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100751:	8b 40 10             	mov    0x10(%eax),%eax
  100754:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  100757:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10075a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  10075d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100760:	89 45 d0             	mov    %eax,-0x30(%ebp)
  100763:	eb 15                	jmp    10077a <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  100765:	8b 45 0c             	mov    0xc(%ebp),%eax
  100768:	8b 55 08             	mov    0x8(%ebp),%edx
  10076b:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  10076e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100771:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  100774:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100777:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  10077a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10077d:	8b 40 08             	mov    0x8(%eax),%eax
  100780:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  100787:	00 
  100788:	89 04 24             	mov    %eax,(%esp)
  10078b:	e8 54 23 00 00       	call   102ae4 <strfind>
  100790:	89 c2                	mov    %eax,%edx
  100792:	8b 45 0c             	mov    0xc(%ebp),%eax
  100795:	8b 40 08             	mov    0x8(%eax),%eax
  100798:	29 c2                	sub    %eax,%edx
  10079a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10079d:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1007a0:	8b 45 08             	mov    0x8(%ebp),%eax
  1007a3:	89 44 24 10          	mov    %eax,0x10(%esp)
  1007a7:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1007ae:	00 
  1007af:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1007b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1007b6:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1007b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1007bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007c0:	89 04 24             	mov    %eax,(%esp)
  1007c3:	e8 c5 fc ff ff       	call   10048d <stab_binsearch>
    if (lline <= rline) {
  1007c8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007cb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007ce:	39 c2                	cmp    %eax,%edx
  1007d0:	7f 23                	jg     1007f5 <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
  1007d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007d5:	89 c2                	mov    %eax,%edx
  1007d7:	89 d0                	mov    %edx,%eax
  1007d9:	01 c0                	add    %eax,%eax
  1007db:	01 d0                	add    %edx,%eax
  1007dd:	c1 e0 02             	shl    $0x2,%eax
  1007e0:	89 c2                	mov    %eax,%edx
  1007e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007e5:	01 d0                	add    %edx,%eax
  1007e7:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  1007eb:	89 c2                	mov    %eax,%edx
  1007ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007f0:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  1007f3:	eb 11                	jmp    100806 <debuginfo_eip+0x22b>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  1007f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1007fa:	e9 0c 01 00 00       	jmp    10090b <debuginfo_eip+0x330>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  1007ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100802:	48                   	dec    %eax
  100803:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100806:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100809:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10080c:	39 c2                	cmp    %eax,%edx
  10080e:	7c 56                	jl     100866 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
  100810:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100813:	89 c2                	mov    %eax,%edx
  100815:	89 d0                	mov    %edx,%eax
  100817:	01 c0                	add    %eax,%eax
  100819:	01 d0                	add    %edx,%eax
  10081b:	c1 e0 02             	shl    $0x2,%eax
  10081e:	89 c2                	mov    %eax,%edx
  100820:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100823:	01 d0                	add    %edx,%eax
  100825:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100829:	3c 84                	cmp    $0x84,%al
  10082b:	74 39                	je     100866 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  10082d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100830:	89 c2                	mov    %eax,%edx
  100832:	89 d0                	mov    %edx,%eax
  100834:	01 c0                	add    %eax,%eax
  100836:	01 d0                	add    %edx,%eax
  100838:	c1 e0 02             	shl    $0x2,%eax
  10083b:	89 c2                	mov    %eax,%edx
  10083d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100840:	01 d0                	add    %edx,%eax
  100842:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100846:	3c 64                	cmp    $0x64,%al
  100848:	75 b5                	jne    1007ff <debuginfo_eip+0x224>
  10084a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10084d:	89 c2                	mov    %eax,%edx
  10084f:	89 d0                	mov    %edx,%eax
  100851:	01 c0                	add    %eax,%eax
  100853:	01 d0                	add    %edx,%eax
  100855:	c1 e0 02             	shl    $0x2,%eax
  100858:	89 c2                	mov    %eax,%edx
  10085a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10085d:	01 d0                	add    %edx,%eax
  10085f:	8b 40 08             	mov    0x8(%eax),%eax
  100862:	85 c0                	test   %eax,%eax
  100864:	74 99                	je     1007ff <debuginfo_eip+0x224>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  100866:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100869:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10086c:	39 c2                	cmp    %eax,%edx
  10086e:	7c 46                	jl     1008b6 <debuginfo_eip+0x2db>
  100870:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100873:	89 c2                	mov    %eax,%edx
  100875:	89 d0                	mov    %edx,%eax
  100877:	01 c0                	add    %eax,%eax
  100879:	01 d0                	add    %edx,%eax
  10087b:	c1 e0 02             	shl    $0x2,%eax
  10087e:	89 c2                	mov    %eax,%edx
  100880:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100883:	01 d0                	add    %edx,%eax
  100885:	8b 00                	mov    (%eax),%eax
  100887:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10088a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10088d:	29 d1                	sub    %edx,%ecx
  10088f:	89 ca                	mov    %ecx,%edx
  100891:	39 d0                	cmp    %edx,%eax
  100893:	73 21                	jae    1008b6 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
  100895:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100898:	89 c2                	mov    %eax,%edx
  10089a:	89 d0                	mov    %edx,%eax
  10089c:	01 c0                	add    %eax,%eax
  10089e:	01 d0                	add    %edx,%eax
  1008a0:	c1 e0 02             	shl    $0x2,%eax
  1008a3:	89 c2                	mov    %eax,%edx
  1008a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008a8:	01 d0                	add    %edx,%eax
  1008aa:	8b 10                	mov    (%eax),%edx
  1008ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008af:	01 c2                	add    %eax,%edx
  1008b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008b4:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1008b6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1008b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1008bc:	39 c2                	cmp    %eax,%edx
  1008be:	7d 46                	jge    100906 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
  1008c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1008c3:	40                   	inc    %eax
  1008c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1008c7:	eb 16                	jmp    1008df <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  1008c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008cc:	8b 40 14             	mov    0x14(%eax),%eax
  1008cf:	8d 50 01             	lea    0x1(%eax),%edx
  1008d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008d5:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  1008d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008db:	40                   	inc    %eax
  1008dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008df:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1008e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  1008e5:	39 c2                	cmp    %eax,%edx
  1008e7:	7d 1d                	jge    100906 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008ec:	89 c2                	mov    %eax,%edx
  1008ee:	89 d0                	mov    %edx,%eax
  1008f0:	01 c0                	add    %eax,%eax
  1008f2:	01 d0                	add    %edx,%eax
  1008f4:	c1 e0 02             	shl    $0x2,%eax
  1008f7:	89 c2                	mov    %eax,%edx
  1008f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008fc:	01 d0                	add    %edx,%eax
  1008fe:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100902:	3c a0                	cmp    $0xa0,%al
  100904:	74 c3                	je     1008c9 <debuginfo_eip+0x2ee>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  100906:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10090b:	c9                   	leave  
  10090c:	c3                   	ret    

0010090d <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  10090d:	55                   	push   %ebp
  10090e:	89 e5                	mov    %esp,%ebp
  100910:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100913:	c7 04 24 82 35 10 00 	movl   $0x103582,(%esp)
  10091a:	e8 48 f9 ff ff       	call   100267 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10091f:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  100926:	00 
  100927:	c7 04 24 9b 35 10 00 	movl   $0x10359b,(%esp)
  10092e:	e8 34 f9 ff ff       	call   100267 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  100933:	c7 44 24 04 62 34 10 	movl   $0x103462,0x4(%esp)
  10093a:	00 
  10093b:	c7 04 24 b3 35 10 00 	movl   $0x1035b3,(%esp)
  100942:	e8 20 f9 ff ff       	call   100267 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100947:	c7 44 24 04 16 ea 10 	movl   $0x10ea16,0x4(%esp)
  10094e:	00 
  10094f:	c7 04 24 cb 35 10 00 	movl   $0x1035cb,(%esp)
  100956:	e8 0c f9 ff ff       	call   100267 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  10095b:	c7 44 24 04 20 fd 10 	movl   $0x10fd20,0x4(%esp)
  100962:	00 
  100963:	c7 04 24 e3 35 10 00 	movl   $0x1035e3,(%esp)
  10096a:	e8 f8 f8 ff ff       	call   100267 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  10096f:	b8 20 fd 10 00       	mov    $0x10fd20,%eax
  100974:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  10097a:	b8 00 00 10 00       	mov    $0x100000,%eax
  10097f:	29 c2                	sub    %eax,%edx
  100981:	89 d0                	mov    %edx,%eax
  100983:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  100989:	85 c0                	test   %eax,%eax
  10098b:	0f 48 c2             	cmovs  %edx,%eax
  10098e:	c1 f8 0a             	sar    $0xa,%eax
  100991:	89 44 24 04          	mov    %eax,0x4(%esp)
  100995:	c7 04 24 fc 35 10 00 	movl   $0x1035fc,(%esp)
  10099c:	e8 c6 f8 ff ff       	call   100267 <cprintf>
}
  1009a1:	90                   	nop
  1009a2:	c9                   	leave  
  1009a3:	c3                   	ret    

001009a4 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1009a4:	55                   	push   %ebp
  1009a5:	89 e5                	mov    %esp,%ebp
  1009a7:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1009ad:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1009b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  1009b7:	89 04 24             	mov    %eax,(%esp)
  1009ba:	e8 1c fc ff ff       	call   1005db <debuginfo_eip>
  1009bf:	85 c0                	test   %eax,%eax
  1009c1:	74 15                	je     1009d8 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  1009c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009ca:	c7 04 24 26 36 10 00 	movl   $0x103626,(%esp)
  1009d1:	e8 91 f8 ff ff       	call   100267 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  1009d6:	eb 6c                	jmp    100a44 <print_debuginfo+0xa0>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1009df:	eb 1b                	jmp    1009fc <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  1009e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1009e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009e7:	01 d0                	add    %edx,%eax
  1009e9:	0f b6 00             	movzbl (%eax),%eax
  1009ec:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  1009f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1009f5:	01 ca                	add    %ecx,%edx
  1009f7:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009f9:	ff 45 f4             	incl   -0xc(%ebp)
  1009fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1009ff:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  100a02:	7f dd                	jg     1009e1 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  100a04:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a0d:	01 d0                	add    %edx,%eax
  100a0f:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  100a12:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a15:	8b 55 08             	mov    0x8(%ebp),%edx
  100a18:	89 d1                	mov    %edx,%ecx
  100a1a:	29 c1                	sub    %eax,%ecx
  100a1c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a1f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a22:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100a26:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a2c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a30:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a34:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a38:	c7 04 24 42 36 10 00 	movl   $0x103642,(%esp)
  100a3f:	e8 23 f8 ff ff       	call   100267 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
  100a44:	90                   	nop
  100a45:	c9                   	leave  
  100a46:	c3                   	ret    

00100a47 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a47:	55                   	push   %ebp
  100a48:	89 e5                	mov    %esp,%ebp
  100a4a:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a4d:	8b 45 04             	mov    0x4(%ebp),%eax
  100a50:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a53:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a56:	c9                   	leave  
  100a57:	c3                   	ret    

00100a58 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100a58:	55                   	push   %ebp
  100a59:	89 e5                	mov    %esp,%ebp
  100a5b:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a5e:	89 e8                	mov    %ebp,%eax
  100a60:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  100a63:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp = read_ebp();
  100a66:	89 45 f4             	mov    %eax,-0xc(%ebp)
      uint32_t eip=read_eip();
  100a69:	e8 d9 ff ff ff       	call   100a47 <read_eip>
  100a6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      for (int i = 0; i < STACKFRAME_DEPTH; i ++) {
  100a71:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100a78:	e9 88 00 00 00       	jmp    100b05 <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
  100a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a80:	89 44 24 08          	mov    %eax,0x8(%esp)
  100a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a87:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a8b:	c7 04 24 54 36 10 00 	movl   $0x103654,(%esp)
  100a92:	e8 d0 f7 ff ff       	call   100267 <cprintf>
        uint32_t *fun_stack = (uint32_t *)ebp ;
  100a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (int j = 2; j < 6; j ++) {
  100a9d:	c7 45 e8 02 00 00 00 	movl   $0x2,-0x18(%ebp)
  100aa4:	eb 24                	jmp    100aca <print_stackframe+0x72>
            cprintf("0x%08x ", fun_stack[j]);
  100aa6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100aa9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100ab0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100ab3:	01 d0                	add    %edx,%eax
  100ab5:	8b 00                	mov    (%eax),%eax
  100ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  100abb:	c7 04 24 70 36 10 00 	movl   $0x103670,(%esp)
  100ac2:	e8 a0 f7 ff ff       	call   100267 <cprintf>
      uint32_t ebp = read_ebp();
      uint32_t eip=read_eip();
      for (int i = 0; i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *fun_stack = (uint32_t *)ebp ;
        for (int j = 2; j < 6; j ++) {
  100ac7:	ff 45 e8             	incl   -0x18(%ebp)
  100aca:	83 7d e8 05          	cmpl   $0x5,-0x18(%ebp)
  100ace:	7e d6                	jle    100aa6 <print_stackframe+0x4e>
            cprintf("0x%08x ", fun_stack[j]);
        }
        cprintf("\n");
  100ad0:	c7 04 24 78 36 10 00 	movl   $0x103678,(%esp)
  100ad7:	e8 8b f7 ff ff       	call   100267 <cprintf>
        print_debuginfo(eip - 1);
  100adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100adf:	48                   	dec    %eax
  100ae0:	89 04 24             	mov    %eax,(%esp)
  100ae3:	e8 bc fe ff ff       	call   1009a4 <print_debuginfo>
        if(fun_stack[0]==0) break;
  100ae8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100aeb:	8b 00                	mov    (%eax),%eax
  100aed:	85 c0                	test   %eax,%eax
  100aef:	74 20                	je     100b11 <print_stackframe+0xb9>
        eip = fun_stack[1];
  100af1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100af4:	8b 40 04             	mov    0x4(%eax),%eax
  100af7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = fun_stack[0];
  100afa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100afd:	8b 00                	mov    (%eax),%eax
  100aff:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
      uint32_t ebp = read_ebp();
      uint32_t eip=read_eip();
      for (int i = 0; i < STACKFRAME_DEPTH; i ++) {
  100b02:	ff 45 ec             	incl   -0x14(%ebp)
  100b05:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b09:	0f 8e 6e ff ff ff    	jle    100a7d <print_stackframe+0x25>
        print_debuginfo(eip - 1);
        if(fun_stack[0]==0) break;
        eip = fun_stack[1];
        ebp = fun_stack[0];
    }
}
  100b0f:	eb 01                	jmp    100b12 <print_stackframe+0xba>
        for (int j = 2; j < 6; j ++) {
            cprintf("0x%08x ", fun_stack[j]);
        }
        cprintf("\n");
        print_debuginfo(eip - 1);
        if(fun_stack[0]==0) break;
  100b11:	90                   	nop
        eip = fun_stack[1];
        ebp = fun_stack[0];
    }
}
  100b12:	90                   	nop
  100b13:	c9                   	leave  
  100b14:	c3                   	ret    

00100b15 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b15:	55                   	push   %ebp
  100b16:	89 e5                	mov    %esp,%ebp
  100b18:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100b1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b22:	eb 0c                	jmp    100b30 <parse+0x1b>
            *buf ++ = '\0';
  100b24:	8b 45 08             	mov    0x8(%ebp),%eax
  100b27:	8d 50 01             	lea    0x1(%eax),%edx
  100b2a:	89 55 08             	mov    %edx,0x8(%ebp)
  100b2d:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b30:	8b 45 08             	mov    0x8(%ebp),%eax
  100b33:	0f b6 00             	movzbl (%eax),%eax
  100b36:	84 c0                	test   %al,%al
  100b38:	74 1d                	je     100b57 <parse+0x42>
  100b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  100b3d:	0f b6 00             	movzbl (%eax),%eax
  100b40:	0f be c0             	movsbl %al,%eax
  100b43:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b47:	c7 04 24 fc 36 10 00 	movl   $0x1036fc,(%esp)
  100b4e:	e8 5f 1f 00 00       	call   102ab2 <strchr>
  100b53:	85 c0                	test   %eax,%eax
  100b55:	75 cd                	jne    100b24 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100b57:	8b 45 08             	mov    0x8(%ebp),%eax
  100b5a:	0f b6 00             	movzbl (%eax),%eax
  100b5d:	84 c0                	test   %al,%al
  100b5f:	74 69                	je     100bca <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100b61:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100b65:	75 14                	jne    100b7b <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100b67:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100b6e:	00 
  100b6f:	c7 04 24 01 37 10 00 	movl   $0x103701,(%esp)
  100b76:	e8 ec f6 ff ff       	call   100267 <cprintf>
        }
        argv[argc ++] = buf;
  100b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b7e:	8d 50 01             	lea    0x1(%eax),%edx
  100b81:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100b84:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  100b8e:	01 c2                	add    %eax,%edx
  100b90:	8b 45 08             	mov    0x8(%ebp),%eax
  100b93:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b95:	eb 03                	jmp    100b9a <parse+0x85>
            buf ++;
  100b97:	ff 45 08             	incl   0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  100b9d:	0f b6 00             	movzbl (%eax),%eax
  100ba0:	84 c0                	test   %al,%al
  100ba2:	0f 84 7a ff ff ff    	je     100b22 <parse+0xd>
  100ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  100bab:	0f b6 00             	movzbl (%eax),%eax
  100bae:	0f be c0             	movsbl %al,%eax
  100bb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bb5:	c7 04 24 fc 36 10 00 	movl   $0x1036fc,(%esp)
  100bbc:	e8 f1 1e 00 00       	call   102ab2 <strchr>
  100bc1:	85 c0                	test   %eax,%eax
  100bc3:	74 d2                	je     100b97 <parse+0x82>
            buf ++;
        }
    }
  100bc5:	e9 58 ff ff ff       	jmp    100b22 <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
  100bca:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100bce:	c9                   	leave  
  100bcf:	c3                   	ret    

00100bd0 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100bd0:	55                   	push   %ebp
  100bd1:	89 e5                	mov    %esp,%ebp
  100bd3:	53                   	push   %ebx
  100bd4:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100bd7:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100bda:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bde:	8b 45 08             	mov    0x8(%ebp),%eax
  100be1:	89 04 24             	mov    %eax,(%esp)
  100be4:	e8 2c ff ff ff       	call   100b15 <parse>
  100be9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100bec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100bf0:	75 0a                	jne    100bfc <runcmd+0x2c>
        return 0;
  100bf2:	b8 00 00 00 00       	mov    $0x0,%eax
  100bf7:	e9 83 00 00 00       	jmp    100c7f <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100bfc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c03:	eb 5a                	jmp    100c5f <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c05:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c08:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c0b:	89 d0                	mov    %edx,%eax
  100c0d:	01 c0                	add    %eax,%eax
  100c0f:	01 d0                	add    %edx,%eax
  100c11:	c1 e0 02             	shl    $0x2,%eax
  100c14:	05 00 e0 10 00       	add    $0x10e000,%eax
  100c19:	8b 00                	mov    (%eax),%eax
  100c1b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c1f:	89 04 24             	mov    %eax,(%esp)
  100c22:	e8 ee 1d 00 00       	call   102a15 <strcmp>
  100c27:	85 c0                	test   %eax,%eax
  100c29:	75 31                	jne    100c5c <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c2e:	89 d0                	mov    %edx,%eax
  100c30:	01 c0                	add    %eax,%eax
  100c32:	01 d0                	add    %edx,%eax
  100c34:	c1 e0 02             	shl    $0x2,%eax
  100c37:	05 08 e0 10 00       	add    $0x10e008,%eax
  100c3c:	8b 10                	mov    (%eax),%edx
  100c3e:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c41:	83 c0 04             	add    $0x4,%eax
  100c44:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100c47:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100c4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100c4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c51:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c55:	89 1c 24             	mov    %ebx,(%esp)
  100c58:	ff d2                	call   *%edx
  100c5a:	eb 23                	jmp    100c7f <runcmd+0xaf>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c5c:	ff 45 f4             	incl   -0xc(%ebp)
  100c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c62:	83 f8 02             	cmp    $0x2,%eax
  100c65:	76 9e                	jbe    100c05 <runcmd+0x35>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100c67:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100c6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c6e:	c7 04 24 1f 37 10 00 	movl   $0x10371f,(%esp)
  100c75:	e8 ed f5 ff ff       	call   100267 <cprintf>
    return 0;
  100c7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c7f:	83 c4 64             	add    $0x64,%esp
  100c82:	5b                   	pop    %ebx
  100c83:	5d                   	pop    %ebp
  100c84:	c3                   	ret    

00100c85 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100c85:	55                   	push   %ebp
  100c86:	89 e5                	mov    %esp,%ebp
  100c88:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100c8b:	c7 04 24 38 37 10 00 	movl   $0x103738,(%esp)
  100c92:	e8 d0 f5 ff ff       	call   100267 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100c97:	c7 04 24 60 37 10 00 	movl   $0x103760,(%esp)
  100c9e:	e8 c4 f5 ff ff       	call   100267 <cprintf>

    if (tf != NULL) {
  100ca3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100ca7:	74 0b                	je     100cb4 <kmonitor+0x2f>
        print_trapframe(tf);
  100ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  100cac:	89 04 24             	mov    %eax,(%esp)
  100caf:	e8 18 0d 00 00       	call   1019cc <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100cb4:	c7 04 24 85 37 10 00 	movl   $0x103785,(%esp)
  100cbb:	e8 49 f6 ff ff       	call   100309 <readline>
  100cc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100cc3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100cc7:	74 eb                	je     100cb4 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  100ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cd3:	89 04 24             	mov    %eax,(%esp)
  100cd6:	e8 f5 fe ff ff       	call   100bd0 <runcmd>
  100cdb:	85 c0                	test   %eax,%eax
  100cdd:	78 02                	js     100ce1 <kmonitor+0x5c>
                break;
            }
        }
    }
  100cdf:	eb d3                	jmp    100cb4 <kmonitor+0x2f>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
  100ce1:	90                   	nop
            }
        }
    }
}
  100ce2:	90                   	nop
  100ce3:	c9                   	leave  
  100ce4:	c3                   	ret    

00100ce5 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100ce5:	55                   	push   %ebp
  100ce6:	89 e5                	mov    %esp,%ebp
  100ce8:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100ceb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100cf2:	eb 3d                	jmp    100d31 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100cf4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100cf7:	89 d0                	mov    %edx,%eax
  100cf9:	01 c0                	add    %eax,%eax
  100cfb:	01 d0                	add    %edx,%eax
  100cfd:	c1 e0 02             	shl    $0x2,%eax
  100d00:	05 04 e0 10 00       	add    $0x10e004,%eax
  100d05:	8b 08                	mov    (%eax),%ecx
  100d07:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d0a:	89 d0                	mov    %edx,%eax
  100d0c:	01 c0                	add    %eax,%eax
  100d0e:	01 d0                	add    %edx,%eax
  100d10:	c1 e0 02             	shl    $0x2,%eax
  100d13:	05 00 e0 10 00       	add    $0x10e000,%eax
  100d18:	8b 00                	mov    (%eax),%eax
  100d1a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100d1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d22:	c7 04 24 89 37 10 00 	movl   $0x103789,(%esp)
  100d29:	e8 39 f5 ff ff       	call   100267 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d2e:	ff 45 f4             	incl   -0xc(%ebp)
  100d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d34:	83 f8 02             	cmp    $0x2,%eax
  100d37:	76 bb                	jbe    100cf4 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100d39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d3e:	c9                   	leave  
  100d3f:	c3                   	ret    

00100d40 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d40:	55                   	push   %ebp
  100d41:	89 e5                	mov    %esp,%ebp
  100d43:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d46:	e8 c2 fb ff ff       	call   10090d <print_kerninfo>
    return 0;
  100d4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d50:	c9                   	leave  
  100d51:	c3                   	ret    

00100d52 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d52:	55                   	push   %ebp
  100d53:	89 e5                	mov    %esp,%ebp
  100d55:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100d58:	e8 fb fc ff ff       	call   100a58 <print_stackframe>
    return 0;
  100d5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d62:	c9                   	leave  
  100d63:	c3                   	ret    

00100d64 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d64:	55                   	push   %ebp
  100d65:	89 e5                	mov    %esp,%ebp
  100d67:	83 ec 28             	sub    $0x28,%esp
  100d6a:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100d70:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100d74:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  100d78:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100d7c:	ee                   	out    %al,(%dx)
  100d7d:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
  100d83:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
  100d87:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
  100d8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d8e:	ee                   	out    %al,(%dx)
  100d8f:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100d95:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
  100d99:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100d9d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100da1:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100da2:	c7 05 08 f9 10 00 00 	movl   $0x0,0x10f908
  100da9:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100dac:	c7 04 24 92 37 10 00 	movl   $0x103792,(%esp)
  100db3:	e8 af f4 ff ff       	call   100267 <cprintf>
    pic_enable(IRQ_TIMER);
  100db8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100dbf:	e8 ba 08 00 00       	call   10167e <pic_enable>
}
  100dc4:	90                   	nop
  100dc5:	c9                   	leave  
  100dc6:	c3                   	ret    

00100dc7 <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100dc7:	55                   	push   %ebp
  100dc8:	89 e5                	mov    %esp,%ebp
  100dca:	83 ec 10             	sub    $0x10,%esp
  100dcd:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100dd3:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100dd7:	89 c2                	mov    %eax,%edx
  100dd9:	ec                   	in     (%dx),%al
  100dda:	88 45 f4             	mov    %al,-0xc(%ebp)
  100ddd:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
  100de3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100de6:	89 c2                	mov    %eax,%edx
  100de8:	ec                   	in     (%dx),%al
  100de9:	88 45 f5             	mov    %al,-0xb(%ebp)
  100dec:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100df2:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100df6:	89 c2                	mov    %eax,%edx
  100df8:	ec                   	in     (%dx),%al
  100df9:	88 45 f6             	mov    %al,-0xa(%ebp)
  100dfc:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
  100e02:	8b 45 f8             	mov    -0x8(%ebp),%eax
  100e05:	89 c2                	mov    %eax,%edx
  100e07:	ec                   	in     (%dx),%al
  100e08:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e0b:	90                   	nop
  100e0c:	c9                   	leave  
  100e0d:	c3                   	ret    

00100e0e <cga_init>:
//    -- 数据寄存器 映射 到 端口 0x3D5或0x3B5 
//    -- 索引寄存器 0x3D4或0x3B4,决定在数据寄存器中的数据表示什么。

/* TEXT-mode CGA/VGA display output */
static void
cga_init(void) {
  100e0e:	55                   	push   %ebp
  100e0f:	89 e5                	mov    %esp,%ebp
  100e11:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;   //CGA_BUF: 0xB8000 (彩色显示的显存物理基址)
  100e14:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;                                            //保存当前显存0xB8000处的值
  100e1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e1e:	0f b7 00             	movzwl (%eax),%eax
  100e21:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;                                   // 给这个地址随便写个值，看看能否再读出同样的值
  100e25:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e28:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {                                            // 如果读不出来，说明没有这块显存，即是单显配置
  100e2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e30:	0f b7 00             	movzwl (%eax),%eax
  100e33:	0f b7 c0             	movzwl %ax,%eax
  100e36:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100e3b:	74 12                	je     100e4f <cga_init+0x41>
        cp = (uint16_t*)MONO_BUF;                         //设置为单显的显存基址 MONO_BUF： 0xB0000
  100e3d:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;                           //设置为单显控制的IO地址，MONO_BASE: 0x3B4
  100e44:	66 c7 05 66 ee 10 00 	movw   $0x3b4,0x10ee66
  100e4b:	b4 03 
  100e4d:	eb 13                	jmp    100e62 <cga_init+0x54>
    } else {                                                                // 如果读出来了，有这块显存，即是彩显配置
        *cp = was;                                                      //还原原来显存位置的值
  100e4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e52:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100e56:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;                               // 设置为彩显控制的IO地址，CGA_BASE: 0x3D4 
  100e59:	66 c7 05 66 ee 10 00 	movw   $0x3d4,0x10ee66
  100e60:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);                                        
  100e62:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e69:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  100e6d:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100e71:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
  100e75:	8b 55 f8             	mov    -0x8(%ebp),%edx
  100e78:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;                       //读出了光标位置(高位)
  100e79:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e80:	40                   	inc    %eax
  100e81:	0f b7 c0             	movzwl %ax,%eax
  100e84:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100e88:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e8c:	89 c2                	mov    %eax,%edx
  100e8e:	ec                   	in     (%dx),%al
  100e8f:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  100e92:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  100e96:	0f b6 c0             	movzbl %al,%eax
  100e99:	c1 e0 08             	shl    $0x8,%eax
  100e9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100e9f:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100ea6:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
  100eaa:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100eae:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
  100eb2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100eb5:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);                             //读出了光标位置(低位)
  100eb6:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100ebd:	40                   	inc    %eax
  100ebe:	0f b7 c0             	movzwl %ax,%eax
  100ec1:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100ec5:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100ec9:	89 c2                	mov    %eax,%edx
  100ecb:	ec                   	in     (%dx),%al
  100ecc:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100ecf:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100ed3:	0f b6 c0             	movzbl %al,%eax
  100ed6:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;                                  //crt_buf是CGA显存起始地址
  100ed9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100edc:	a3 60 ee 10 00       	mov    %eax,0x10ee60
    crt_pos = pos;                                                  //crt_pos是CGA当前光标位置
  100ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ee4:	0f b7 c0             	movzwl %ax,%eax
  100ee7:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
}
  100eed:	90                   	nop
  100eee:	c9                   	leave  
  100eef:	c3                   	ret    

00100ef0 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100ef0:	55                   	push   %ebp
  100ef1:	89 e5                	mov    %esp,%ebp
  100ef3:	83 ec 38             	sub    $0x38,%esp
  100ef6:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100efc:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f00:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
  100f04:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f08:	ee                   	out    %al,(%dx)
  100f09:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
  100f0f:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
  100f13:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  100f17:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100f1a:	ee                   	out    %al,(%dx)
  100f1b:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
  100f21:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
  100f25:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  100f29:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f2d:	ee                   	out    %al,(%dx)
  100f2e:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
  100f34:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
  100f38:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100f3c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100f3f:	ee                   	out    %al,(%dx)
  100f40:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
  100f46:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
  100f4a:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
  100f4e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f52:	ee                   	out    %al,(%dx)
  100f53:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
  100f59:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
  100f5d:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  100f61:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100f64:	ee                   	out    %al,(%dx)
  100f65:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100f6b:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
  100f6f:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  100f73:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f77:	ee                   	out    %al,(%dx)
  100f78:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
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
  100fae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100fb1:	89 c2                	mov    %eax,%edx
  100fb3:	ec                   	in     (%dx),%al
  100fb4:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  100fb7:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  100fbc:	85 c0                	test   %eax,%eax
  100fbe:	74 0c                	je     100fcc <serial_init+0xdc>
        pic_enable(IRQ_COM1);
  100fc0:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  100fc7:	e8 b2 06 00 00       	call   10167e <pic_enable>
    }
}
  100fcc:	90                   	nop
  100fcd:	c9                   	leave  
  100fce:	c3                   	ret    

00100fcf <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  100fcf:	55                   	push   %ebp
  100fd0:	89 e5                	mov    %esp,%ebp
  100fd2:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100fd5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  100fdc:	eb 08                	jmp    100fe6 <lpt_putc_sub+0x17>
        delay();
  100fde:	e8 e4 fd ff ff       	call   100dc7 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100fe3:	ff 45 fc             	incl   -0x4(%ebp)
  100fe6:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
  100fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100fef:	89 c2                	mov    %eax,%edx
  100ff1:	ec                   	in     (%dx),%al
  100ff2:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
  100ff5:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  100ff9:	84 c0                	test   %al,%al
  100ffb:	78 09                	js     101006 <lpt_putc_sub+0x37>
  100ffd:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101004:	7e d8                	jle    100fde <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  101006:	8b 45 08             	mov    0x8(%ebp),%eax
  101009:	0f b6 c0             	movzbl %al,%eax
  10100c:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
  101012:	88 45 f0             	mov    %al,-0x10(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101015:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
  101019:	8b 55 f8             	mov    -0x8(%ebp),%edx
  10101c:	ee                   	out    %al,(%dx)
  10101d:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  101023:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  101027:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10102b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10102f:	ee                   	out    %al,(%dx)
  101030:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
  101036:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
  10103a:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
  10103e:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101042:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  101043:	90                   	nop
  101044:	c9                   	leave  
  101045:	c3                   	ret    

00101046 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  101046:	55                   	push   %ebp
  101047:	89 e5                	mov    %esp,%ebp
  101049:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10104c:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101050:	74 0d                	je     10105f <lpt_putc+0x19>
        lpt_putc_sub(c);
  101052:	8b 45 08             	mov    0x8(%ebp),%eax
  101055:	89 04 24             	mov    %eax,(%esp)
  101058:	e8 72 ff ff ff       	call   100fcf <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  10105d:	eb 24                	jmp    101083 <lpt_putc+0x3d>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
  10105f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101066:	e8 64 ff ff ff       	call   100fcf <lpt_putc_sub>
        lpt_putc_sub(' ');
  10106b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101072:	e8 58 ff ff ff       	call   100fcf <lpt_putc_sub>
        lpt_putc_sub('\b');
  101077:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10107e:	e8 4c ff ff ff       	call   100fcf <lpt_putc_sub>
    }
}
  101083:	90                   	nop
  101084:	c9                   	leave  
  101085:	c3                   	ret    

00101086 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101086:	55                   	push   %ebp
  101087:	89 e5                	mov    %esp,%ebp
  101089:	53                   	push   %ebx
  10108a:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  10108d:	8b 45 08             	mov    0x8(%ebp),%eax
  101090:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101095:	85 c0                	test   %eax,%eax
  101097:	75 07                	jne    1010a0 <cga_putc+0x1a>
        c |= 0x0700;
  101099:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  1010a0:	8b 45 08             	mov    0x8(%ebp),%eax
  1010a3:	0f b6 c0             	movzbl %al,%eax
  1010a6:	83 f8 0a             	cmp    $0xa,%eax
  1010a9:	74 54                	je     1010ff <cga_putc+0x79>
  1010ab:	83 f8 0d             	cmp    $0xd,%eax
  1010ae:	74 62                	je     101112 <cga_putc+0x8c>
  1010b0:	83 f8 08             	cmp    $0x8,%eax
  1010b3:	0f 85 93 00 00 00    	jne    10114c <cga_putc+0xc6>
    case '\b':
        if (crt_pos > 0) {
  1010b9:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010c0:	85 c0                	test   %eax,%eax
  1010c2:	0f 84 ae 00 00 00    	je     101176 <cga_putc+0xf0>
            crt_pos --;
  1010c8:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010cf:	48                   	dec    %eax
  1010d0:	0f b7 c0             	movzwl %ax,%eax
  1010d3:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  1010d9:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1010de:	0f b7 15 64 ee 10 00 	movzwl 0x10ee64,%edx
  1010e5:	01 d2                	add    %edx,%edx
  1010e7:	01 c2                	add    %eax,%edx
  1010e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1010ec:	98                   	cwtl   
  1010ed:	25 00 ff ff ff       	and    $0xffffff00,%eax
  1010f2:	98                   	cwtl   
  1010f3:	83 c8 20             	or     $0x20,%eax
  1010f6:	98                   	cwtl   
  1010f7:	0f b7 c0             	movzwl %ax,%eax
  1010fa:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  1010fd:	eb 77                	jmp    101176 <cga_putc+0xf0>
    case '\n':
        crt_pos += CRT_COLS;
  1010ff:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101106:	83 c0 50             	add    $0x50,%eax
  101109:	0f b7 c0             	movzwl %ax,%eax
  10110c:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101112:	0f b7 1d 64 ee 10 00 	movzwl 0x10ee64,%ebx
  101119:	0f b7 0d 64 ee 10 00 	movzwl 0x10ee64,%ecx
  101120:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  101125:	89 c8                	mov    %ecx,%eax
  101127:	f7 e2                	mul    %edx
  101129:	c1 ea 06             	shr    $0x6,%edx
  10112c:	89 d0                	mov    %edx,%eax
  10112e:	c1 e0 02             	shl    $0x2,%eax
  101131:	01 d0                	add    %edx,%eax
  101133:	c1 e0 04             	shl    $0x4,%eax
  101136:	29 c1                	sub    %eax,%ecx
  101138:	89 c8                	mov    %ecx,%eax
  10113a:	0f b7 c0             	movzwl %ax,%eax
  10113d:	29 c3                	sub    %eax,%ebx
  10113f:	89 d8                	mov    %ebx,%eax
  101141:	0f b7 c0             	movzwl %ax,%eax
  101144:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
        break;
  10114a:	eb 2b                	jmp    101177 <cga_putc+0xf1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  10114c:	8b 0d 60 ee 10 00    	mov    0x10ee60,%ecx
  101152:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101159:	8d 50 01             	lea    0x1(%eax),%edx
  10115c:	0f b7 d2             	movzwl %dx,%edx
  10115f:	66 89 15 64 ee 10 00 	mov    %dx,0x10ee64
  101166:	01 c0                	add    %eax,%eax
  101168:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  10116b:	8b 45 08             	mov    0x8(%ebp),%eax
  10116e:	0f b7 c0             	movzwl %ax,%eax
  101171:	66 89 02             	mov    %ax,(%edx)
        break;
  101174:	eb 01                	jmp    101177 <cga_putc+0xf1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
  101176:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101177:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  10117e:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  101183:	76 5d                	jbe    1011e2 <cga_putc+0x15c>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101185:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  10118a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101190:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  101195:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  10119c:	00 
  10119d:	89 54 24 04          	mov    %edx,0x4(%esp)
  1011a1:	89 04 24             	mov    %eax,(%esp)
  1011a4:	e8 ff 1a 00 00       	call   102ca8 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011a9:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  1011b0:	eb 14                	jmp    1011c6 <cga_putc+0x140>
            crt_buf[i] = 0x0700 | ' ';
  1011b2:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1011b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1011ba:	01 d2                	add    %edx,%edx
  1011bc:	01 d0                	add    %edx,%eax
  1011be:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011c3:	ff 45 f4             	incl   -0xc(%ebp)
  1011c6:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  1011cd:	7e e3                	jle    1011b2 <cga_putc+0x12c>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  1011cf:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1011d6:	83 e8 50             	sub    $0x50,%eax
  1011d9:	0f b7 c0             	movzwl %ax,%eax
  1011dc:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  1011e2:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  1011e9:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  1011ed:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
  1011f1:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
  1011f5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1011f9:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  1011fa:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101201:	c1 e8 08             	shr    $0x8,%eax
  101204:	0f b7 c0             	movzwl %ax,%eax
  101207:	0f b6 c0             	movzbl %al,%eax
  10120a:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  101211:	42                   	inc    %edx
  101212:	0f b7 d2             	movzwl %dx,%edx
  101215:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
  101219:	88 45 e9             	mov    %al,-0x17(%ebp)
  10121c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101220:	8b 55 f0             	mov    -0x10(%ebp),%edx
  101223:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  101224:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  10122b:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  10122f:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
  101233:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
  101237:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10123b:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  10123c:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101243:	0f b6 c0             	movzbl %al,%eax
  101246:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  10124d:	42                   	inc    %edx
  10124e:	0f b7 d2             	movzwl %dx,%edx
  101251:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
  101255:	88 45 eb             	mov    %al,-0x15(%ebp)
  101258:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  10125c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10125f:	ee                   	out    %al,(%dx)
}
  101260:	90                   	nop
  101261:	83 c4 24             	add    $0x24,%esp
  101264:	5b                   	pop    %ebx
  101265:	5d                   	pop    %ebp
  101266:	c3                   	ret    

00101267 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  101267:	55                   	push   %ebp
  101268:	89 e5                	mov    %esp,%ebp
  10126a:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10126d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101274:	eb 08                	jmp    10127e <serial_putc_sub+0x17>
        delay();
  101276:	e8 4c fb ff ff       	call   100dc7 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10127b:	ff 45 fc             	incl   -0x4(%ebp)
  10127e:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101284:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101287:	89 c2                	mov    %eax,%edx
  101289:	ec                   	in     (%dx),%al
  10128a:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
  10128d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  101291:	0f b6 c0             	movzbl %al,%eax
  101294:	83 e0 20             	and    $0x20,%eax
  101297:	85 c0                	test   %eax,%eax
  101299:	75 09                	jne    1012a4 <serial_putc_sub+0x3d>
  10129b:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1012a2:	7e d2                	jle    101276 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  1012a4:	8b 45 08             	mov    0x8(%ebp),%eax
  1012a7:	0f b6 c0             	movzbl %al,%eax
  1012aa:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
  1012b0:	88 45 f6             	mov    %al,-0xa(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012b3:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
  1012b7:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1012bb:	ee                   	out    %al,(%dx)
}
  1012bc:	90                   	nop
  1012bd:	c9                   	leave  
  1012be:	c3                   	ret    

001012bf <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  1012bf:	55                   	push   %ebp
  1012c0:	89 e5                	mov    %esp,%ebp
  1012c2:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1012c5:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1012c9:	74 0d                	je     1012d8 <serial_putc+0x19>
        serial_putc_sub(c);
  1012cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1012ce:	89 04 24             	mov    %eax,(%esp)
  1012d1:	e8 91 ff ff ff       	call   101267 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  1012d6:	eb 24                	jmp    1012fc <serial_putc+0x3d>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
  1012d8:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1012df:	e8 83 ff ff ff       	call   101267 <serial_putc_sub>
        serial_putc_sub(' ');
  1012e4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1012eb:	e8 77 ff ff ff       	call   101267 <serial_putc_sub>
        serial_putc_sub('\b');
  1012f0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1012f7:	e8 6b ff ff ff       	call   101267 <serial_putc_sub>
    }
}
  1012fc:	90                   	nop
  1012fd:	c9                   	leave  
  1012fe:	c3                   	ret    

001012ff <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  1012ff:	55                   	push   %ebp
  101300:	89 e5                	mov    %esp,%ebp
  101302:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101305:	eb 33                	jmp    10133a <cons_intr+0x3b>
        if (c != 0) {
  101307:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10130b:	74 2d                	je     10133a <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  10130d:	a1 84 f0 10 00       	mov    0x10f084,%eax
  101312:	8d 50 01             	lea    0x1(%eax),%edx
  101315:	89 15 84 f0 10 00    	mov    %edx,0x10f084
  10131b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10131e:	88 90 80 ee 10 00    	mov    %dl,0x10ee80(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101324:	a1 84 f0 10 00       	mov    0x10f084,%eax
  101329:	3d 00 02 00 00       	cmp    $0x200,%eax
  10132e:	75 0a                	jne    10133a <cons_intr+0x3b>
                cons.wpos = 0;
  101330:	c7 05 84 f0 10 00 00 	movl   $0x0,0x10f084
  101337:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  10133a:	8b 45 08             	mov    0x8(%ebp),%eax
  10133d:	ff d0                	call   *%eax
  10133f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  101342:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101346:	75 bf                	jne    101307 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  101348:	90                   	nop
  101349:	c9                   	leave  
  10134a:	c3                   	ret    

0010134b <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  10134b:	55                   	push   %ebp
  10134c:	89 e5                	mov    %esp,%ebp
  10134e:	83 ec 10             	sub    $0x10,%esp
  101351:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101357:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10135a:	89 c2                	mov    %eax,%edx
  10135c:	ec                   	in     (%dx),%al
  10135d:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
  101360:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  101364:	0f b6 c0             	movzbl %al,%eax
  101367:	83 e0 01             	and    $0x1,%eax
  10136a:	85 c0                	test   %eax,%eax
  10136c:	75 07                	jne    101375 <serial_proc_data+0x2a>
        return -1;
  10136e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101373:	eb 2a                	jmp    10139f <serial_proc_data+0x54>
  101375:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  10137b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10137f:	89 c2                	mov    %eax,%edx
  101381:	ec                   	in     (%dx),%al
  101382:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
  101385:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101389:	0f b6 c0             	movzbl %al,%eax
  10138c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  10138f:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101393:	75 07                	jne    10139c <serial_proc_data+0x51>
        c = '\b';
  101395:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  10139c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10139f:	c9                   	leave  
  1013a0:	c3                   	ret    

001013a1 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  1013a1:	55                   	push   %ebp
  1013a2:	89 e5                	mov    %esp,%ebp
  1013a4:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  1013a7:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  1013ac:	85 c0                	test   %eax,%eax
  1013ae:	74 0c                	je     1013bc <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  1013b0:	c7 04 24 4b 13 10 00 	movl   $0x10134b,(%esp)
  1013b7:	e8 43 ff ff ff       	call   1012ff <cons_intr>
    }
}
  1013bc:	90                   	nop
  1013bd:	c9                   	leave  
  1013be:	c3                   	ret    

001013bf <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  1013bf:	55                   	push   %ebp
  1013c0:	89 e5                	mov    %esp,%ebp
  1013c2:	83 ec 28             	sub    $0x28,%esp
  1013c5:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1013ce:	89 c2                	mov    %eax,%edx
  1013d0:	ec                   	in     (%dx),%al
  1013d1:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  1013d4:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1013d8:	0f b6 c0             	movzbl %al,%eax
  1013db:	83 e0 01             	and    $0x1,%eax
  1013de:	85 c0                	test   %eax,%eax
  1013e0:	75 0a                	jne    1013ec <kbd_proc_data+0x2d>
        return -1;
  1013e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013e7:	e9 56 01 00 00       	jmp    101542 <kbd_proc_data+0x183>
  1013ec:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1013f5:	89 c2                	mov    %eax,%edx
  1013f7:	ec                   	in     (%dx),%al
  1013f8:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
  1013fb:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
  1013ff:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101402:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  101406:	75 17                	jne    10141f <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  101408:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10140d:	83 c8 40             	or     $0x40,%eax
  101410:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101415:	b8 00 00 00 00       	mov    $0x0,%eax
  10141a:	e9 23 01 00 00       	jmp    101542 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
  10141f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101423:	84 c0                	test   %al,%al
  101425:	79 45                	jns    10146c <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  101427:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10142c:	83 e0 40             	and    $0x40,%eax
  10142f:	85 c0                	test   %eax,%eax
  101431:	75 08                	jne    10143b <kbd_proc_data+0x7c>
  101433:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101437:	24 7f                	and    $0x7f,%al
  101439:	eb 04                	jmp    10143f <kbd_proc_data+0x80>
  10143b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10143f:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  101442:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101446:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  10144d:	0c 40                	or     $0x40,%al
  10144f:	0f b6 c0             	movzbl %al,%eax
  101452:	f7 d0                	not    %eax
  101454:	89 c2                	mov    %eax,%edx
  101456:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10145b:	21 d0                	and    %edx,%eax
  10145d:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101462:	b8 00 00 00 00       	mov    $0x0,%eax
  101467:	e9 d6 00 00 00       	jmp    101542 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
  10146c:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101471:	83 e0 40             	and    $0x40,%eax
  101474:	85 c0                	test   %eax,%eax
  101476:	74 11                	je     101489 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  101478:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  10147c:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101481:	83 e0 bf             	and    $0xffffffbf,%eax
  101484:	a3 88 f0 10 00       	mov    %eax,0x10f088
    }

    shift |= shiftcode[data];
  101489:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10148d:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  101494:	0f b6 d0             	movzbl %al,%edx
  101497:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10149c:	09 d0                	or     %edx,%eax
  10149e:	a3 88 f0 10 00       	mov    %eax,0x10f088
    shift ^= togglecode[data];
  1014a3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014a7:	0f b6 80 40 e1 10 00 	movzbl 0x10e140(%eax),%eax
  1014ae:	0f b6 d0             	movzbl %al,%edx
  1014b1:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014b6:	31 d0                	xor    %edx,%eax
  1014b8:	a3 88 f0 10 00       	mov    %eax,0x10f088

    c = charcode[shift & (CTL | SHIFT)][data];
  1014bd:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014c2:	83 e0 03             	and    $0x3,%eax
  1014c5:	8b 14 85 40 e5 10 00 	mov    0x10e540(,%eax,4),%edx
  1014cc:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014d0:	01 d0                	add    %edx,%eax
  1014d2:	0f b6 00             	movzbl (%eax),%eax
  1014d5:	0f b6 c0             	movzbl %al,%eax
  1014d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1014db:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014e0:	83 e0 08             	and    $0x8,%eax
  1014e3:	85 c0                	test   %eax,%eax
  1014e5:	74 22                	je     101509 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  1014e7:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  1014eb:	7e 0c                	jle    1014f9 <kbd_proc_data+0x13a>
  1014ed:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  1014f1:	7f 06                	jg     1014f9 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  1014f3:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  1014f7:	eb 10                	jmp    101509 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  1014f9:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  1014fd:	7e 0a                	jle    101509 <kbd_proc_data+0x14a>
  1014ff:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101503:	7f 04                	jg     101509 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  101505:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101509:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10150e:	f7 d0                	not    %eax
  101510:	83 e0 06             	and    $0x6,%eax
  101513:	85 c0                	test   %eax,%eax
  101515:	75 28                	jne    10153f <kbd_proc_data+0x180>
  101517:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  10151e:	75 1f                	jne    10153f <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
  101520:	c7 04 24 ad 37 10 00 	movl   $0x1037ad,(%esp)
  101527:	e8 3b ed ff ff       	call   100267 <cprintf>
  10152c:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
  101532:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101536:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  10153a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10153e:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  10153f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101542:	c9                   	leave  
  101543:	c3                   	ret    

00101544 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  101544:	55                   	push   %ebp
  101545:	89 e5                	mov    %esp,%ebp
  101547:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  10154a:	c7 04 24 bf 13 10 00 	movl   $0x1013bf,(%esp)
  101551:	e8 a9 fd ff ff       	call   1012ff <cons_intr>
}
  101556:	90                   	nop
  101557:	c9                   	leave  
  101558:	c3                   	ret    

00101559 <kbd_init>:

static void
kbd_init(void) {
  101559:	55                   	push   %ebp
  10155a:	89 e5                	mov    %esp,%ebp
  10155c:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  10155f:	e8 e0 ff ff ff       	call   101544 <kbd_intr>
    pic_enable(IRQ_KBD);
  101564:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10156b:	e8 0e 01 00 00       	call   10167e <pic_enable>
}
  101570:	90                   	nop
  101571:	c9                   	leave  
  101572:	c3                   	ret    

00101573 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  101573:	55                   	push   %ebp
  101574:	89 e5                	mov    %esp,%ebp
  101576:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  101579:	e8 90 f8 ff ff       	call   100e0e <cga_init>
    serial_init();
  10157e:	e8 6d f9 ff ff       	call   100ef0 <serial_init>
    kbd_init();
  101583:	e8 d1 ff ff ff       	call   101559 <kbd_init>
    if (!serial_exists) {
  101588:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  10158d:	85 c0                	test   %eax,%eax
  10158f:	75 0c                	jne    10159d <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101591:	c7 04 24 b9 37 10 00 	movl   $0x1037b9,(%esp)
  101598:	e8 ca ec ff ff       	call   100267 <cprintf>
    }
}
  10159d:	90                   	nop
  10159e:	c9                   	leave  
  10159f:	c3                   	ret    

001015a0 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  1015a0:	55                   	push   %ebp
  1015a1:	89 e5                	mov    %esp,%ebp
  1015a3:	83 ec 18             	sub    $0x18,%esp
    lpt_putc(c);
  1015a6:	8b 45 08             	mov    0x8(%ebp),%eax
  1015a9:	89 04 24             	mov    %eax,(%esp)
  1015ac:	e8 95 fa ff ff       	call   101046 <lpt_putc>
    cga_putc(c);
  1015b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1015b4:	89 04 24             	mov    %eax,(%esp)
  1015b7:	e8 ca fa ff ff       	call   101086 <cga_putc>
    serial_putc(c);
  1015bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1015bf:	89 04 24             	mov    %eax,(%esp)
  1015c2:	e8 f8 fc ff ff       	call   1012bf <serial_putc>
}
  1015c7:	90                   	nop
  1015c8:	c9                   	leave  
  1015c9:	c3                   	ret    

001015ca <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1015ca:	55                   	push   %ebp
  1015cb:	89 e5                	mov    %esp,%ebp
  1015cd:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  1015d0:	e8 cc fd ff ff       	call   1013a1 <serial_intr>
    kbd_intr();
  1015d5:	e8 6a ff ff ff       	call   101544 <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  1015da:	8b 15 80 f0 10 00    	mov    0x10f080,%edx
  1015e0:	a1 84 f0 10 00       	mov    0x10f084,%eax
  1015e5:	39 c2                	cmp    %eax,%edx
  1015e7:	74 36                	je     10161f <cons_getc+0x55>
        c = cons.buf[cons.rpos ++];
  1015e9:	a1 80 f0 10 00       	mov    0x10f080,%eax
  1015ee:	8d 50 01             	lea    0x1(%eax),%edx
  1015f1:	89 15 80 f0 10 00    	mov    %edx,0x10f080
  1015f7:	0f b6 80 80 ee 10 00 	movzbl 0x10ee80(%eax),%eax
  1015fe:	0f b6 c0             	movzbl %al,%eax
  101601:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  101604:	a1 80 f0 10 00       	mov    0x10f080,%eax
  101609:	3d 00 02 00 00       	cmp    $0x200,%eax
  10160e:	75 0a                	jne    10161a <cons_getc+0x50>
            cons.rpos = 0;
  101610:	c7 05 80 f0 10 00 00 	movl   $0x0,0x10f080
  101617:	00 00 00 
        }
        return c;
  10161a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10161d:	eb 05                	jmp    101624 <cons_getc+0x5a>
    }
    return 0;
  10161f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  101624:	c9                   	leave  
  101625:	c3                   	ret    

00101626 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  101626:	55                   	push   %ebp
  101627:	89 e5                	mov    %esp,%ebp
  101629:	83 ec 14             	sub    $0x14,%esp
  10162c:	8b 45 08             	mov    0x8(%ebp),%eax
  10162f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  101633:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101636:	66 a3 50 e5 10 00    	mov    %ax,0x10e550
    if (did_init) {
  10163c:	a1 8c f0 10 00       	mov    0x10f08c,%eax
  101641:	85 c0                	test   %eax,%eax
  101643:	74 36                	je     10167b <pic_setmask+0x55>
        outb(IO_PIC1 + 1, mask);
  101645:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101648:	0f b6 c0             	movzbl %al,%eax
  10164b:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101651:	88 45 fa             	mov    %al,-0x6(%ebp)
  101654:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
  101658:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  10165c:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  10165d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101661:	c1 e8 08             	shr    $0x8,%eax
  101664:	0f b7 c0             	movzwl %ax,%eax
  101667:	0f b6 c0             	movzbl %al,%eax
  10166a:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
  101670:	88 45 fb             	mov    %al,-0x5(%ebp)
  101673:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  101677:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10167a:	ee                   	out    %al,(%dx)
    }
}
  10167b:	90                   	nop
  10167c:	c9                   	leave  
  10167d:	c3                   	ret    

0010167e <pic_enable>:

void
pic_enable(unsigned int irq) {
  10167e:	55                   	push   %ebp
  10167f:	89 e5                	mov    %esp,%ebp
  101681:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101684:	8b 45 08             	mov    0x8(%ebp),%eax
  101687:	ba 01 00 00 00       	mov    $0x1,%edx
  10168c:	88 c1                	mov    %al,%cl
  10168e:	d3 e2                	shl    %cl,%edx
  101690:	89 d0                	mov    %edx,%eax
  101692:	98                   	cwtl   
  101693:	f7 d0                	not    %eax
  101695:	0f bf d0             	movswl %ax,%edx
  101698:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  10169f:	98                   	cwtl   
  1016a0:	21 d0                	and    %edx,%eax
  1016a2:	98                   	cwtl   
  1016a3:	0f b7 c0             	movzwl %ax,%eax
  1016a6:	89 04 24             	mov    %eax,(%esp)
  1016a9:	e8 78 ff ff ff       	call   101626 <pic_setmask>
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
  1016b4:	83 ec 34             	sub    $0x34,%esp
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
  1016e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1016e5:	ee                   	out    %al,(%dx)
  1016e6:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
  1016ec:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
  1016f0:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
  1016f4:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1016f8:	ee                   	out    %al,(%dx)
  1016f9:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
  1016ff:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
  101703:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101707:	8b 55 f8             	mov    -0x8(%ebp),%edx
  10170a:	ee                   	out    %al,(%dx)
  10170b:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
  101711:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
  101715:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
  101719:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10171d:	ee                   	out    %al,(%dx)
  10171e:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
  101724:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
  101728:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  10172c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10172f:	ee                   	out    %al,(%dx)
  101730:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
  101736:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
  10173a:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  10173e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101742:	ee                   	out    %al,(%dx)
  101743:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
  101749:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
  10174d:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101751:	8b 55 f0             	mov    -0x10(%ebp),%edx
  101754:	ee                   	out    %al,(%dx)
  101755:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  10175b:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
  10175f:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
  101763:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101767:	ee                   	out    %al,(%dx)
  101768:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
  10176e:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
  101772:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  101776:	8b 55 ec             	mov    -0x14(%ebp),%edx
  101779:	ee                   	out    %al,(%dx)
  10177a:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
  101780:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
  101784:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  101788:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10178c:	ee                   	out    %al,(%dx)
  10178d:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
  101793:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
  101797:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  10179b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  10179e:	ee                   	out    %al,(%dx)
  10179f:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  1017a5:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
  1017a9:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
  1017ad:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1017b1:	ee                   	out    %al,(%dx)
  1017b2:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
  1017b8:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
  1017bc:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  1017c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1017c3:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1017c4:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017cb:	3d ff ff 00 00       	cmp    $0xffff,%eax
  1017d0:	74 0f                	je     1017e1 <pic_init+0x130>
        pic_setmask(irq_mask);
  1017d2:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017d9:	89 04 24             	mov    %eax,(%esp)
  1017dc:	e8 45 fe ff ff       	call   101626 <pic_setmask>
    }
}
  1017e1:	90                   	nop
  1017e2:	c9                   	leave  
  1017e3:	c3                   	ret    

001017e4 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1017e4:	55                   	push   %ebp
  1017e5:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  1017e7:	fb                   	sti    
    sti();
}
  1017e8:	90                   	nop
  1017e9:	5d                   	pop    %ebp
  1017ea:	c3                   	ret    

001017eb <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  1017eb:	55                   	push   %ebp
  1017ec:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli");
  1017ee:	fa                   	cli    
    cli();
}
  1017ef:	90                   	nop
  1017f0:	5d                   	pop    %ebp
  1017f1:	c3                   	ret    

001017f2 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  1017f2:	55                   	push   %ebp
  1017f3:	89 e5                	mov    %esp,%ebp
  1017f5:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  1017f8:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  1017ff:	00 
  101800:	c7 04 24 e0 37 10 00 	movl   $0x1037e0,(%esp)
  101807:	e8 5b ea ff ff       	call   100267 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  10180c:	90                   	nop
  10180d:	c9                   	leave  
  10180e:	c3                   	ret    

0010180f <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  10180f:	55                   	push   %ebp
  101810:	89 e5                	mov    %esp,%ebp
  101812:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
      extern uintptr_t __vectors[];
      int length=sizeof(idt) / sizeof(struct gatedesc);
  101815:	c7 45 f8 00 01 00 00 	movl   $0x100,-0x8(%ebp)
      for(int i=0;i<length;i++)
  10181c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101823:	e9 c4 00 00 00       	jmp    1018ec <idt_init+0xdd>
          SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  101828:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10182b:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  101832:	0f b7 d0             	movzwl %ax,%edx
  101835:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101838:	66 89 14 c5 a0 f0 10 	mov    %dx,0x10f0a0(,%eax,8)
  10183f:	00 
  101840:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101843:	66 c7 04 c5 a2 f0 10 	movw   $0x8,0x10f0a2(,%eax,8)
  10184a:	00 08 00 
  10184d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101850:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  101857:	00 
  101858:	80 e2 e0             	and    $0xe0,%dl
  10185b:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  101862:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101865:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  10186c:	00 
  10186d:	80 e2 1f             	and    $0x1f,%dl
  101870:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  101877:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10187a:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  101881:	00 
  101882:	80 e2 f0             	and    $0xf0,%dl
  101885:	80 ca 0e             	or     $0xe,%dl
  101888:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  10188f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101892:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  101899:	00 
  10189a:	80 e2 ef             	and    $0xef,%dl
  10189d:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018a7:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018ae:	00 
  1018af:	80 e2 9f             	and    $0x9f,%dl
  1018b2:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018bc:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018c3:	00 
  1018c4:	80 ca 80             	or     $0x80,%dl
  1018c7:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d1:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  1018d8:	c1 e8 10             	shr    $0x10,%eax
  1018db:	0f b7 d0             	movzwl %ax,%edx
  1018de:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e1:	66 89 14 c5 a6 f0 10 	mov    %dx,0x10f0a6(,%eax,8)
  1018e8:	00 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
      extern uintptr_t __vectors[];
      int length=sizeof(idt) / sizeof(struct gatedesc);
      for(int i=0;i<length;i++)
  1018e9:	ff 45 fc             	incl   -0x4(%ebp)
  1018ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018ef:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1018f2:	0f 8c 30 ff ff ff    	jl     101828 <idt_init+0x19>
          SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
      SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  1018f8:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  1018fd:	0f b7 c0             	movzwl %ax,%eax
  101900:	66 a3 68 f4 10 00    	mov    %ax,0x10f468
  101906:	66 c7 05 6a f4 10 00 	movw   $0x8,0x10f46a
  10190d:	08 00 
  10190f:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  101916:	24 e0                	and    $0xe0,%al
  101918:	a2 6c f4 10 00       	mov    %al,0x10f46c
  10191d:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  101924:	24 1f                	and    $0x1f,%al
  101926:	a2 6c f4 10 00       	mov    %al,0x10f46c
  10192b:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101932:	24 f0                	and    $0xf0,%al
  101934:	0c 0e                	or     $0xe,%al
  101936:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10193b:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101942:	24 ef                	and    $0xef,%al
  101944:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101949:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101950:	0c 60                	or     $0x60,%al
  101952:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101957:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  10195e:	0c 80                	or     $0x80,%al
  101960:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101965:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  10196a:	c1 e8 10             	shr    $0x10,%eax
  10196d:	0f b7 c0             	movzwl %ax,%eax
  101970:	66 a3 6e f4 10 00    	mov    %ax,0x10f46e
  101976:	c7 45 f4 60 e5 10 00 	movl   $0x10e560,-0xc(%ebp)
    return ebp;
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd));
  10197d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101980:	0f 01 18             	lidtl  (%eax)
      lidt(&idt_pd);
}
  101983:	90                   	nop
  101984:	c9                   	leave  
  101985:	c3                   	ret    

00101986 <trapname>:

static const char *
trapname(int trapno) {
  101986:	55                   	push   %ebp
  101987:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101989:	8b 45 08             	mov    0x8(%ebp),%eax
  10198c:	83 f8 13             	cmp    $0x13,%eax
  10198f:	77 0c                	ja     10199d <trapname+0x17>
        return excnames[trapno];
  101991:	8b 45 08             	mov    0x8(%ebp),%eax
  101994:	8b 04 85 40 3b 10 00 	mov    0x103b40(,%eax,4),%eax
  10199b:	eb 18                	jmp    1019b5 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  10199d:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  1019a1:	7e 0d                	jle    1019b0 <trapname+0x2a>
  1019a3:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  1019a7:	7f 07                	jg     1019b0 <trapname+0x2a>
        return "Hardware Interrupt";
  1019a9:	b8 ea 37 10 00       	mov    $0x1037ea,%eax
  1019ae:	eb 05                	jmp    1019b5 <trapname+0x2f>
    }
    return "(unknown trap)";
  1019b0:	b8 fd 37 10 00       	mov    $0x1037fd,%eax
}
  1019b5:	5d                   	pop    %ebp
  1019b6:	c3                   	ret    

001019b7 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  1019b7:	55                   	push   %ebp
  1019b8:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  1019ba:	8b 45 08             	mov    0x8(%ebp),%eax
  1019bd:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1019c1:	83 f8 08             	cmp    $0x8,%eax
  1019c4:	0f 94 c0             	sete   %al
  1019c7:	0f b6 c0             	movzbl %al,%eax
}
  1019ca:	5d                   	pop    %ebp
  1019cb:	c3                   	ret    

001019cc <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  1019cc:	55                   	push   %ebp
  1019cd:	89 e5                	mov    %esp,%ebp
  1019cf:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  1019d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1019d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019d9:	c7 04 24 3e 38 10 00 	movl   $0x10383e,(%esp)
  1019e0:	e8 82 e8 ff ff       	call   100267 <cprintf>
    print_regs(&tf->tf_regs);
  1019e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1019e8:	89 04 24             	mov    %eax,(%esp)
  1019eb:	e8 91 01 00 00       	call   101b81 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  1019f0:	8b 45 08             	mov    0x8(%ebp),%eax
  1019f3:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  1019f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1019fb:	c7 04 24 4f 38 10 00 	movl   $0x10384f,(%esp)
  101a02:	e8 60 e8 ff ff       	call   100267 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a07:	8b 45 08             	mov    0x8(%ebp),%eax
  101a0a:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a12:	c7 04 24 62 38 10 00 	movl   $0x103862,(%esp)
  101a19:	e8 49 e8 ff ff       	call   100267 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  101a21:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101a25:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a29:	c7 04 24 75 38 10 00 	movl   $0x103875,(%esp)
  101a30:	e8 32 e8 ff ff       	call   100267 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101a35:	8b 45 08             	mov    0x8(%ebp),%eax
  101a38:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a40:	c7 04 24 88 38 10 00 	movl   $0x103888,(%esp)
  101a47:	e8 1b e8 ff ff       	call   100267 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  101a4f:	8b 40 30             	mov    0x30(%eax),%eax
  101a52:	89 04 24             	mov    %eax,(%esp)
  101a55:	e8 2c ff ff ff       	call   101986 <trapname>
  101a5a:	89 c2                	mov    %eax,%edx
  101a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  101a5f:	8b 40 30             	mov    0x30(%eax),%eax
  101a62:	89 54 24 08          	mov    %edx,0x8(%esp)
  101a66:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a6a:	c7 04 24 9b 38 10 00 	movl   $0x10389b,(%esp)
  101a71:	e8 f1 e7 ff ff       	call   100267 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101a76:	8b 45 08             	mov    0x8(%ebp),%eax
  101a79:	8b 40 34             	mov    0x34(%eax),%eax
  101a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a80:	c7 04 24 ad 38 10 00 	movl   $0x1038ad,(%esp)
  101a87:	e8 db e7 ff ff       	call   100267 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  101a8f:	8b 40 38             	mov    0x38(%eax),%eax
  101a92:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a96:	c7 04 24 bc 38 10 00 	movl   $0x1038bc,(%esp)
  101a9d:	e8 c5 e7 ff ff       	call   100267 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  101aa5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101aa9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aad:	c7 04 24 cb 38 10 00 	movl   $0x1038cb,(%esp)
  101ab4:	e8 ae e7 ff ff       	call   100267 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  101abc:	8b 40 40             	mov    0x40(%eax),%eax
  101abf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ac3:	c7 04 24 de 38 10 00 	movl   $0x1038de,(%esp)
  101aca:	e8 98 e7 ff ff       	call   100267 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101acf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101ad6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101add:	eb 3d                	jmp    101b1c <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101adf:	8b 45 08             	mov    0x8(%ebp),%eax
  101ae2:	8b 50 40             	mov    0x40(%eax),%edx
  101ae5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101ae8:	21 d0                	and    %edx,%eax
  101aea:	85 c0                	test   %eax,%eax
  101aec:	74 28                	je     101b16 <print_trapframe+0x14a>
  101aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101af1:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101af8:	85 c0                	test   %eax,%eax
  101afa:	74 1a                	je     101b16 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
  101afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101aff:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b06:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b0a:	c7 04 24 ed 38 10 00 	movl   $0x1038ed,(%esp)
  101b11:	e8 51 e7 ff ff       	call   100267 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b16:	ff 45 f4             	incl   -0xc(%ebp)
  101b19:	d1 65 f0             	shll   -0x10(%ebp)
  101b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b1f:	83 f8 17             	cmp    $0x17,%eax
  101b22:	76 bb                	jbe    101adf <print_trapframe+0x113>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101b24:	8b 45 08             	mov    0x8(%ebp),%eax
  101b27:	8b 40 40             	mov    0x40(%eax),%eax
  101b2a:	25 00 30 00 00       	and    $0x3000,%eax
  101b2f:	c1 e8 0c             	shr    $0xc,%eax
  101b32:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b36:	c7 04 24 f1 38 10 00 	movl   $0x1038f1,(%esp)
  101b3d:	e8 25 e7 ff ff       	call   100267 <cprintf>

    if (!trap_in_kernel(tf)) {
  101b42:	8b 45 08             	mov    0x8(%ebp),%eax
  101b45:	89 04 24             	mov    %eax,(%esp)
  101b48:	e8 6a fe ff ff       	call   1019b7 <trap_in_kernel>
  101b4d:	85 c0                	test   %eax,%eax
  101b4f:	75 2d                	jne    101b7e <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101b51:	8b 45 08             	mov    0x8(%ebp),%eax
  101b54:	8b 40 44             	mov    0x44(%eax),%eax
  101b57:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b5b:	c7 04 24 fa 38 10 00 	movl   $0x1038fa,(%esp)
  101b62:	e8 00 e7 ff ff       	call   100267 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101b67:	8b 45 08             	mov    0x8(%ebp),%eax
  101b6a:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101b6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b72:	c7 04 24 09 39 10 00 	movl   $0x103909,(%esp)
  101b79:	e8 e9 e6 ff ff       	call   100267 <cprintf>
    }
}
  101b7e:	90                   	nop
  101b7f:	c9                   	leave  
  101b80:	c3                   	ret    

00101b81 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101b81:	55                   	push   %ebp
  101b82:	89 e5                	mov    %esp,%ebp
  101b84:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101b87:	8b 45 08             	mov    0x8(%ebp),%eax
  101b8a:	8b 00                	mov    (%eax),%eax
  101b8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b90:	c7 04 24 1c 39 10 00 	movl   $0x10391c,(%esp)
  101b97:	e8 cb e6 ff ff       	call   100267 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  101b9f:	8b 40 04             	mov    0x4(%eax),%eax
  101ba2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ba6:	c7 04 24 2b 39 10 00 	movl   $0x10392b,(%esp)
  101bad:	e8 b5 e6 ff ff       	call   100267 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  101bb5:	8b 40 08             	mov    0x8(%eax),%eax
  101bb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bbc:	c7 04 24 3a 39 10 00 	movl   $0x10393a,(%esp)
  101bc3:	e8 9f e6 ff ff       	call   100267 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  101bcb:	8b 40 0c             	mov    0xc(%eax),%eax
  101bce:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd2:	c7 04 24 49 39 10 00 	movl   $0x103949,(%esp)
  101bd9:	e8 89 e6 ff ff       	call   100267 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101bde:	8b 45 08             	mov    0x8(%ebp),%eax
  101be1:	8b 40 10             	mov    0x10(%eax),%eax
  101be4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be8:	c7 04 24 58 39 10 00 	movl   $0x103958,(%esp)
  101bef:	e8 73 e6 ff ff       	call   100267 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf7:	8b 40 14             	mov    0x14(%eax),%eax
  101bfa:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bfe:	c7 04 24 67 39 10 00 	movl   $0x103967,(%esp)
  101c05:	e8 5d e6 ff ff       	call   100267 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  101c0d:	8b 40 18             	mov    0x18(%eax),%eax
  101c10:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c14:	c7 04 24 76 39 10 00 	movl   $0x103976,(%esp)
  101c1b:	e8 47 e6 ff ff       	call   100267 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101c20:	8b 45 08             	mov    0x8(%ebp),%eax
  101c23:	8b 40 1c             	mov    0x1c(%eax),%eax
  101c26:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c2a:	c7 04 24 85 39 10 00 	movl   $0x103985,(%esp)
  101c31:	e8 31 e6 ff ff       	call   100267 <cprintf>
}
  101c36:	90                   	nop
  101c37:	c9                   	leave  
  101c38:	c3                   	ret    

00101c39 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101c39:	55                   	push   %ebp
  101c3a:	89 e5                	mov    %esp,%ebp
  101c3c:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101c3f:	8b 45 08             	mov    0x8(%ebp),%eax
  101c42:	8b 40 30             	mov    0x30(%eax),%eax
  101c45:	83 f8 2f             	cmp    $0x2f,%eax
  101c48:	77 21                	ja     101c6b <trap_dispatch+0x32>
  101c4a:	83 f8 2e             	cmp    $0x2e,%eax
  101c4d:	0f 83 0c 01 00 00    	jae    101d5f <trap_dispatch+0x126>
  101c53:	83 f8 21             	cmp    $0x21,%eax
  101c56:	0f 84 8c 00 00 00    	je     101ce8 <trap_dispatch+0xaf>
  101c5c:	83 f8 24             	cmp    $0x24,%eax
  101c5f:	74 61                	je     101cc2 <trap_dispatch+0x89>
  101c61:	83 f8 20             	cmp    $0x20,%eax
  101c64:	74 16                	je     101c7c <trap_dispatch+0x43>
  101c66:	e9 bf 00 00 00       	jmp    101d2a <trap_dispatch+0xf1>
  101c6b:	83 e8 78             	sub    $0x78,%eax
  101c6e:	83 f8 01             	cmp    $0x1,%eax
  101c71:	0f 87 b3 00 00 00    	ja     101d2a <trap_dispatch+0xf1>
  101c77:	e9 92 00 00 00       	jmp    101d0e <trap_dispatch+0xd5>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101c7c:	a1 08 f9 10 00       	mov    0x10f908,%eax
  101c81:	40                   	inc    %eax
  101c82:	a3 08 f9 10 00       	mov    %eax,0x10f908
        if(ticks % TICK_NUM==0)  print_ticks();
  101c87:	8b 0d 08 f9 10 00    	mov    0x10f908,%ecx
  101c8d:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101c92:	89 c8                	mov    %ecx,%eax
  101c94:	f7 e2                	mul    %edx
  101c96:	c1 ea 05             	shr    $0x5,%edx
  101c99:	89 d0                	mov    %edx,%eax
  101c9b:	c1 e0 02             	shl    $0x2,%eax
  101c9e:	01 d0                	add    %edx,%eax
  101ca0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101ca7:	01 d0                	add    %edx,%eax
  101ca9:	c1 e0 02             	shl    $0x2,%eax
  101cac:	29 c1                	sub    %eax,%ecx
  101cae:	89 ca                	mov    %ecx,%edx
  101cb0:	85 d2                	test   %edx,%edx
  101cb2:	0f 85 aa 00 00 00    	jne    101d62 <trap_dispatch+0x129>
  101cb8:	e8 35 fb ff ff       	call   1017f2 <print_ticks>
        break;
  101cbd:	e9 a0 00 00 00       	jmp    101d62 <trap_dispatch+0x129>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101cc2:	e8 03 f9 ff ff       	call   1015ca <cons_getc>
  101cc7:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101cca:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101cce:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101cd2:	89 54 24 08          	mov    %edx,0x8(%esp)
  101cd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cda:	c7 04 24 94 39 10 00 	movl   $0x103994,(%esp)
  101ce1:	e8 81 e5 ff ff       	call   100267 <cprintf>
        break;
  101ce6:	eb 7b                	jmp    101d63 <trap_dispatch+0x12a>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101ce8:	e8 dd f8 ff ff       	call   1015ca <cons_getc>
  101ced:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101cf0:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101cf4:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101cf8:	89 54 24 08          	mov    %edx,0x8(%esp)
  101cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d00:	c7 04 24 a6 39 10 00 	movl   $0x1039a6,(%esp)
  101d07:	e8 5b e5 ff ff       	call   100267 <cprintf>
        break;
  101d0c:	eb 55                	jmp    101d63 <trap_dispatch+0x12a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101d0e:	c7 44 24 08 b5 39 10 	movl   $0x1039b5,0x8(%esp)
  101d15:	00 
  101d16:	c7 44 24 04 aa 00 00 	movl   $0xaa,0x4(%esp)
  101d1d:	00 
  101d1e:	c7 04 24 c5 39 10 00 	movl   $0x1039c5,(%esp)
  101d25:	e8 94 e6 ff ff       	call   1003be <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  101d2d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101d31:	83 e0 03             	and    $0x3,%eax
  101d34:	85 c0                	test   %eax,%eax
  101d36:	75 2b                	jne    101d63 <trap_dispatch+0x12a>
            print_trapframe(tf);
  101d38:	8b 45 08             	mov    0x8(%ebp),%eax
  101d3b:	89 04 24             	mov    %eax,(%esp)
  101d3e:	e8 89 fc ff ff       	call   1019cc <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101d43:	c7 44 24 08 d6 39 10 	movl   $0x1039d6,0x8(%esp)
  101d4a:	00 
  101d4b:	c7 44 24 04 b4 00 00 	movl   $0xb4,0x4(%esp)
  101d52:	00 
  101d53:	c7 04 24 c5 39 10 00 	movl   $0x1039c5,(%esp)
  101d5a:	e8 5f e6 ff ff       	call   1003be <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101d5f:	90                   	nop
  101d60:	eb 01                	jmp    101d63 <trap_dispatch+0x12a>
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
        if(ticks % TICK_NUM==0)  print_ticks();
        break;
  101d62:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101d63:	90                   	nop
  101d64:	c9                   	leave  
  101d65:	c3                   	ret    

00101d66 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101d66:	55                   	push   %ebp
  101d67:	89 e5                	mov    %esp,%ebp
  101d69:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  101d6f:	89 04 24             	mov    %eax,(%esp)
  101d72:	e8 c2 fe ff ff       	call   101c39 <trap_dispatch>
}
  101d77:	90                   	nop
  101d78:	c9                   	leave  
  101d79:	c3                   	ret    

00101d7a <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101d7a:	6a 00                	push   $0x0
  pushl $0
  101d7c:	6a 00                	push   $0x0
  jmp __alltraps
  101d7e:	e9 69 0a 00 00       	jmp    1027ec <__alltraps>

00101d83 <vector1>:
.globl vector1
vector1:
  pushl $0
  101d83:	6a 00                	push   $0x0
  pushl $1
  101d85:	6a 01                	push   $0x1
  jmp __alltraps
  101d87:	e9 60 0a 00 00       	jmp    1027ec <__alltraps>

00101d8c <vector2>:
.globl vector2
vector2:
  pushl $0
  101d8c:	6a 00                	push   $0x0
  pushl $2
  101d8e:	6a 02                	push   $0x2
  jmp __alltraps
  101d90:	e9 57 0a 00 00       	jmp    1027ec <__alltraps>

00101d95 <vector3>:
.globl vector3
vector3:
  pushl $0
  101d95:	6a 00                	push   $0x0
  pushl $3
  101d97:	6a 03                	push   $0x3
  jmp __alltraps
  101d99:	e9 4e 0a 00 00       	jmp    1027ec <__alltraps>

00101d9e <vector4>:
.globl vector4
vector4:
  pushl $0
  101d9e:	6a 00                	push   $0x0
  pushl $4
  101da0:	6a 04                	push   $0x4
  jmp __alltraps
  101da2:	e9 45 0a 00 00       	jmp    1027ec <__alltraps>

00101da7 <vector5>:
.globl vector5
vector5:
  pushl $0
  101da7:	6a 00                	push   $0x0
  pushl $5
  101da9:	6a 05                	push   $0x5
  jmp __alltraps
  101dab:	e9 3c 0a 00 00       	jmp    1027ec <__alltraps>

00101db0 <vector6>:
.globl vector6
vector6:
  pushl $0
  101db0:	6a 00                	push   $0x0
  pushl $6
  101db2:	6a 06                	push   $0x6
  jmp __alltraps
  101db4:	e9 33 0a 00 00       	jmp    1027ec <__alltraps>

00101db9 <vector7>:
.globl vector7
vector7:
  pushl $0
  101db9:	6a 00                	push   $0x0
  pushl $7
  101dbb:	6a 07                	push   $0x7
  jmp __alltraps
  101dbd:	e9 2a 0a 00 00       	jmp    1027ec <__alltraps>

00101dc2 <vector8>:
.globl vector8
vector8:
  pushl $8
  101dc2:	6a 08                	push   $0x8
  jmp __alltraps
  101dc4:	e9 23 0a 00 00       	jmp    1027ec <__alltraps>

00101dc9 <vector9>:
.globl vector9
vector9:
  pushl $0
  101dc9:	6a 00                	push   $0x0
  pushl $9
  101dcb:	6a 09                	push   $0x9
  jmp __alltraps
  101dcd:	e9 1a 0a 00 00       	jmp    1027ec <__alltraps>

00101dd2 <vector10>:
.globl vector10
vector10:
  pushl $10
  101dd2:	6a 0a                	push   $0xa
  jmp __alltraps
  101dd4:	e9 13 0a 00 00       	jmp    1027ec <__alltraps>

00101dd9 <vector11>:
.globl vector11
vector11:
  pushl $11
  101dd9:	6a 0b                	push   $0xb
  jmp __alltraps
  101ddb:	e9 0c 0a 00 00       	jmp    1027ec <__alltraps>

00101de0 <vector12>:
.globl vector12
vector12:
  pushl $12
  101de0:	6a 0c                	push   $0xc
  jmp __alltraps
  101de2:	e9 05 0a 00 00       	jmp    1027ec <__alltraps>

00101de7 <vector13>:
.globl vector13
vector13:
  pushl $13
  101de7:	6a 0d                	push   $0xd
  jmp __alltraps
  101de9:	e9 fe 09 00 00       	jmp    1027ec <__alltraps>

00101dee <vector14>:
.globl vector14
vector14:
  pushl $14
  101dee:	6a 0e                	push   $0xe
  jmp __alltraps
  101df0:	e9 f7 09 00 00       	jmp    1027ec <__alltraps>

00101df5 <vector15>:
.globl vector15
vector15:
  pushl $0
  101df5:	6a 00                	push   $0x0
  pushl $15
  101df7:	6a 0f                	push   $0xf
  jmp __alltraps
  101df9:	e9 ee 09 00 00       	jmp    1027ec <__alltraps>

00101dfe <vector16>:
.globl vector16
vector16:
  pushl $0
  101dfe:	6a 00                	push   $0x0
  pushl $16
  101e00:	6a 10                	push   $0x10
  jmp __alltraps
  101e02:	e9 e5 09 00 00       	jmp    1027ec <__alltraps>

00101e07 <vector17>:
.globl vector17
vector17:
  pushl $17
  101e07:	6a 11                	push   $0x11
  jmp __alltraps
  101e09:	e9 de 09 00 00       	jmp    1027ec <__alltraps>

00101e0e <vector18>:
.globl vector18
vector18:
  pushl $0
  101e0e:	6a 00                	push   $0x0
  pushl $18
  101e10:	6a 12                	push   $0x12
  jmp __alltraps
  101e12:	e9 d5 09 00 00       	jmp    1027ec <__alltraps>

00101e17 <vector19>:
.globl vector19
vector19:
  pushl $0
  101e17:	6a 00                	push   $0x0
  pushl $19
  101e19:	6a 13                	push   $0x13
  jmp __alltraps
  101e1b:	e9 cc 09 00 00       	jmp    1027ec <__alltraps>

00101e20 <vector20>:
.globl vector20
vector20:
  pushl $0
  101e20:	6a 00                	push   $0x0
  pushl $20
  101e22:	6a 14                	push   $0x14
  jmp __alltraps
  101e24:	e9 c3 09 00 00       	jmp    1027ec <__alltraps>

00101e29 <vector21>:
.globl vector21
vector21:
  pushl $0
  101e29:	6a 00                	push   $0x0
  pushl $21
  101e2b:	6a 15                	push   $0x15
  jmp __alltraps
  101e2d:	e9 ba 09 00 00       	jmp    1027ec <__alltraps>

00101e32 <vector22>:
.globl vector22
vector22:
  pushl $0
  101e32:	6a 00                	push   $0x0
  pushl $22
  101e34:	6a 16                	push   $0x16
  jmp __alltraps
  101e36:	e9 b1 09 00 00       	jmp    1027ec <__alltraps>

00101e3b <vector23>:
.globl vector23
vector23:
  pushl $0
  101e3b:	6a 00                	push   $0x0
  pushl $23
  101e3d:	6a 17                	push   $0x17
  jmp __alltraps
  101e3f:	e9 a8 09 00 00       	jmp    1027ec <__alltraps>

00101e44 <vector24>:
.globl vector24
vector24:
  pushl $0
  101e44:	6a 00                	push   $0x0
  pushl $24
  101e46:	6a 18                	push   $0x18
  jmp __alltraps
  101e48:	e9 9f 09 00 00       	jmp    1027ec <__alltraps>

00101e4d <vector25>:
.globl vector25
vector25:
  pushl $0
  101e4d:	6a 00                	push   $0x0
  pushl $25
  101e4f:	6a 19                	push   $0x19
  jmp __alltraps
  101e51:	e9 96 09 00 00       	jmp    1027ec <__alltraps>

00101e56 <vector26>:
.globl vector26
vector26:
  pushl $0
  101e56:	6a 00                	push   $0x0
  pushl $26
  101e58:	6a 1a                	push   $0x1a
  jmp __alltraps
  101e5a:	e9 8d 09 00 00       	jmp    1027ec <__alltraps>

00101e5f <vector27>:
.globl vector27
vector27:
  pushl $0
  101e5f:	6a 00                	push   $0x0
  pushl $27
  101e61:	6a 1b                	push   $0x1b
  jmp __alltraps
  101e63:	e9 84 09 00 00       	jmp    1027ec <__alltraps>

00101e68 <vector28>:
.globl vector28
vector28:
  pushl $0
  101e68:	6a 00                	push   $0x0
  pushl $28
  101e6a:	6a 1c                	push   $0x1c
  jmp __alltraps
  101e6c:	e9 7b 09 00 00       	jmp    1027ec <__alltraps>

00101e71 <vector29>:
.globl vector29
vector29:
  pushl $0
  101e71:	6a 00                	push   $0x0
  pushl $29
  101e73:	6a 1d                	push   $0x1d
  jmp __alltraps
  101e75:	e9 72 09 00 00       	jmp    1027ec <__alltraps>

00101e7a <vector30>:
.globl vector30
vector30:
  pushl $0
  101e7a:	6a 00                	push   $0x0
  pushl $30
  101e7c:	6a 1e                	push   $0x1e
  jmp __alltraps
  101e7e:	e9 69 09 00 00       	jmp    1027ec <__alltraps>

00101e83 <vector31>:
.globl vector31
vector31:
  pushl $0
  101e83:	6a 00                	push   $0x0
  pushl $31
  101e85:	6a 1f                	push   $0x1f
  jmp __alltraps
  101e87:	e9 60 09 00 00       	jmp    1027ec <__alltraps>

00101e8c <vector32>:
.globl vector32
vector32:
  pushl $0
  101e8c:	6a 00                	push   $0x0
  pushl $32
  101e8e:	6a 20                	push   $0x20
  jmp __alltraps
  101e90:	e9 57 09 00 00       	jmp    1027ec <__alltraps>

00101e95 <vector33>:
.globl vector33
vector33:
  pushl $0
  101e95:	6a 00                	push   $0x0
  pushl $33
  101e97:	6a 21                	push   $0x21
  jmp __alltraps
  101e99:	e9 4e 09 00 00       	jmp    1027ec <__alltraps>

00101e9e <vector34>:
.globl vector34
vector34:
  pushl $0
  101e9e:	6a 00                	push   $0x0
  pushl $34
  101ea0:	6a 22                	push   $0x22
  jmp __alltraps
  101ea2:	e9 45 09 00 00       	jmp    1027ec <__alltraps>

00101ea7 <vector35>:
.globl vector35
vector35:
  pushl $0
  101ea7:	6a 00                	push   $0x0
  pushl $35
  101ea9:	6a 23                	push   $0x23
  jmp __alltraps
  101eab:	e9 3c 09 00 00       	jmp    1027ec <__alltraps>

00101eb0 <vector36>:
.globl vector36
vector36:
  pushl $0
  101eb0:	6a 00                	push   $0x0
  pushl $36
  101eb2:	6a 24                	push   $0x24
  jmp __alltraps
  101eb4:	e9 33 09 00 00       	jmp    1027ec <__alltraps>

00101eb9 <vector37>:
.globl vector37
vector37:
  pushl $0
  101eb9:	6a 00                	push   $0x0
  pushl $37
  101ebb:	6a 25                	push   $0x25
  jmp __alltraps
  101ebd:	e9 2a 09 00 00       	jmp    1027ec <__alltraps>

00101ec2 <vector38>:
.globl vector38
vector38:
  pushl $0
  101ec2:	6a 00                	push   $0x0
  pushl $38
  101ec4:	6a 26                	push   $0x26
  jmp __alltraps
  101ec6:	e9 21 09 00 00       	jmp    1027ec <__alltraps>

00101ecb <vector39>:
.globl vector39
vector39:
  pushl $0
  101ecb:	6a 00                	push   $0x0
  pushl $39
  101ecd:	6a 27                	push   $0x27
  jmp __alltraps
  101ecf:	e9 18 09 00 00       	jmp    1027ec <__alltraps>

00101ed4 <vector40>:
.globl vector40
vector40:
  pushl $0
  101ed4:	6a 00                	push   $0x0
  pushl $40
  101ed6:	6a 28                	push   $0x28
  jmp __alltraps
  101ed8:	e9 0f 09 00 00       	jmp    1027ec <__alltraps>

00101edd <vector41>:
.globl vector41
vector41:
  pushl $0
  101edd:	6a 00                	push   $0x0
  pushl $41
  101edf:	6a 29                	push   $0x29
  jmp __alltraps
  101ee1:	e9 06 09 00 00       	jmp    1027ec <__alltraps>

00101ee6 <vector42>:
.globl vector42
vector42:
  pushl $0
  101ee6:	6a 00                	push   $0x0
  pushl $42
  101ee8:	6a 2a                	push   $0x2a
  jmp __alltraps
  101eea:	e9 fd 08 00 00       	jmp    1027ec <__alltraps>

00101eef <vector43>:
.globl vector43
vector43:
  pushl $0
  101eef:	6a 00                	push   $0x0
  pushl $43
  101ef1:	6a 2b                	push   $0x2b
  jmp __alltraps
  101ef3:	e9 f4 08 00 00       	jmp    1027ec <__alltraps>

00101ef8 <vector44>:
.globl vector44
vector44:
  pushl $0
  101ef8:	6a 00                	push   $0x0
  pushl $44
  101efa:	6a 2c                	push   $0x2c
  jmp __alltraps
  101efc:	e9 eb 08 00 00       	jmp    1027ec <__alltraps>

00101f01 <vector45>:
.globl vector45
vector45:
  pushl $0
  101f01:	6a 00                	push   $0x0
  pushl $45
  101f03:	6a 2d                	push   $0x2d
  jmp __alltraps
  101f05:	e9 e2 08 00 00       	jmp    1027ec <__alltraps>

00101f0a <vector46>:
.globl vector46
vector46:
  pushl $0
  101f0a:	6a 00                	push   $0x0
  pushl $46
  101f0c:	6a 2e                	push   $0x2e
  jmp __alltraps
  101f0e:	e9 d9 08 00 00       	jmp    1027ec <__alltraps>

00101f13 <vector47>:
.globl vector47
vector47:
  pushl $0
  101f13:	6a 00                	push   $0x0
  pushl $47
  101f15:	6a 2f                	push   $0x2f
  jmp __alltraps
  101f17:	e9 d0 08 00 00       	jmp    1027ec <__alltraps>

00101f1c <vector48>:
.globl vector48
vector48:
  pushl $0
  101f1c:	6a 00                	push   $0x0
  pushl $48
  101f1e:	6a 30                	push   $0x30
  jmp __alltraps
  101f20:	e9 c7 08 00 00       	jmp    1027ec <__alltraps>

00101f25 <vector49>:
.globl vector49
vector49:
  pushl $0
  101f25:	6a 00                	push   $0x0
  pushl $49
  101f27:	6a 31                	push   $0x31
  jmp __alltraps
  101f29:	e9 be 08 00 00       	jmp    1027ec <__alltraps>

00101f2e <vector50>:
.globl vector50
vector50:
  pushl $0
  101f2e:	6a 00                	push   $0x0
  pushl $50
  101f30:	6a 32                	push   $0x32
  jmp __alltraps
  101f32:	e9 b5 08 00 00       	jmp    1027ec <__alltraps>

00101f37 <vector51>:
.globl vector51
vector51:
  pushl $0
  101f37:	6a 00                	push   $0x0
  pushl $51
  101f39:	6a 33                	push   $0x33
  jmp __alltraps
  101f3b:	e9 ac 08 00 00       	jmp    1027ec <__alltraps>

00101f40 <vector52>:
.globl vector52
vector52:
  pushl $0
  101f40:	6a 00                	push   $0x0
  pushl $52
  101f42:	6a 34                	push   $0x34
  jmp __alltraps
  101f44:	e9 a3 08 00 00       	jmp    1027ec <__alltraps>

00101f49 <vector53>:
.globl vector53
vector53:
  pushl $0
  101f49:	6a 00                	push   $0x0
  pushl $53
  101f4b:	6a 35                	push   $0x35
  jmp __alltraps
  101f4d:	e9 9a 08 00 00       	jmp    1027ec <__alltraps>

00101f52 <vector54>:
.globl vector54
vector54:
  pushl $0
  101f52:	6a 00                	push   $0x0
  pushl $54
  101f54:	6a 36                	push   $0x36
  jmp __alltraps
  101f56:	e9 91 08 00 00       	jmp    1027ec <__alltraps>

00101f5b <vector55>:
.globl vector55
vector55:
  pushl $0
  101f5b:	6a 00                	push   $0x0
  pushl $55
  101f5d:	6a 37                	push   $0x37
  jmp __alltraps
  101f5f:	e9 88 08 00 00       	jmp    1027ec <__alltraps>

00101f64 <vector56>:
.globl vector56
vector56:
  pushl $0
  101f64:	6a 00                	push   $0x0
  pushl $56
  101f66:	6a 38                	push   $0x38
  jmp __alltraps
  101f68:	e9 7f 08 00 00       	jmp    1027ec <__alltraps>

00101f6d <vector57>:
.globl vector57
vector57:
  pushl $0
  101f6d:	6a 00                	push   $0x0
  pushl $57
  101f6f:	6a 39                	push   $0x39
  jmp __alltraps
  101f71:	e9 76 08 00 00       	jmp    1027ec <__alltraps>

00101f76 <vector58>:
.globl vector58
vector58:
  pushl $0
  101f76:	6a 00                	push   $0x0
  pushl $58
  101f78:	6a 3a                	push   $0x3a
  jmp __alltraps
  101f7a:	e9 6d 08 00 00       	jmp    1027ec <__alltraps>

00101f7f <vector59>:
.globl vector59
vector59:
  pushl $0
  101f7f:	6a 00                	push   $0x0
  pushl $59
  101f81:	6a 3b                	push   $0x3b
  jmp __alltraps
  101f83:	e9 64 08 00 00       	jmp    1027ec <__alltraps>

00101f88 <vector60>:
.globl vector60
vector60:
  pushl $0
  101f88:	6a 00                	push   $0x0
  pushl $60
  101f8a:	6a 3c                	push   $0x3c
  jmp __alltraps
  101f8c:	e9 5b 08 00 00       	jmp    1027ec <__alltraps>

00101f91 <vector61>:
.globl vector61
vector61:
  pushl $0
  101f91:	6a 00                	push   $0x0
  pushl $61
  101f93:	6a 3d                	push   $0x3d
  jmp __alltraps
  101f95:	e9 52 08 00 00       	jmp    1027ec <__alltraps>

00101f9a <vector62>:
.globl vector62
vector62:
  pushl $0
  101f9a:	6a 00                	push   $0x0
  pushl $62
  101f9c:	6a 3e                	push   $0x3e
  jmp __alltraps
  101f9e:	e9 49 08 00 00       	jmp    1027ec <__alltraps>

00101fa3 <vector63>:
.globl vector63
vector63:
  pushl $0
  101fa3:	6a 00                	push   $0x0
  pushl $63
  101fa5:	6a 3f                	push   $0x3f
  jmp __alltraps
  101fa7:	e9 40 08 00 00       	jmp    1027ec <__alltraps>

00101fac <vector64>:
.globl vector64
vector64:
  pushl $0
  101fac:	6a 00                	push   $0x0
  pushl $64
  101fae:	6a 40                	push   $0x40
  jmp __alltraps
  101fb0:	e9 37 08 00 00       	jmp    1027ec <__alltraps>

00101fb5 <vector65>:
.globl vector65
vector65:
  pushl $0
  101fb5:	6a 00                	push   $0x0
  pushl $65
  101fb7:	6a 41                	push   $0x41
  jmp __alltraps
  101fb9:	e9 2e 08 00 00       	jmp    1027ec <__alltraps>

00101fbe <vector66>:
.globl vector66
vector66:
  pushl $0
  101fbe:	6a 00                	push   $0x0
  pushl $66
  101fc0:	6a 42                	push   $0x42
  jmp __alltraps
  101fc2:	e9 25 08 00 00       	jmp    1027ec <__alltraps>

00101fc7 <vector67>:
.globl vector67
vector67:
  pushl $0
  101fc7:	6a 00                	push   $0x0
  pushl $67
  101fc9:	6a 43                	push   $0x43
  jmp __alltraps
  101fcb:	e9 1c 08 00 00       	jmp    1027ec <__alltraps>

00101fd0 <vector68>:
.globl vector68
vector68:
  pushl $0
  101fd0:	6a 00                	push   $0x0
  pushl $68
  101fd2:	6a 44                	push   $0x44
  jmp __alltraps
  101fd4:	e9 13 08 00 00       	jmp    1027ec <__alltraps>

00101fd9 <vector69>:
.globl vector69
vector69:
  pushl $0
  101fd9:	6a 00                	push   $0x0
  pushl $69
  101fdb:	6a 45                	push   $0x45
  jmp __alltraps
  101fdd:	e9 0a 08 00 00       	jmp    1027ec <__alltraps>

00101fe2 <vector70>:
.globl vector70
vector70:
  pushl $0
  101fe2:	6a 00                	push   $0x0
  pushl $70
  101fe4:	6a 46                	push   $0x46
  jmp __alltraps
  101fe6:	e9 01 08 00 00       	jmp    1027ec <__alltraps>

00101feb <vector71>:
.globl vector71
vector71:
  pushl $0
  101feb:	6a 00                	push   $0x0
  pushl $71
  101fed:	6a 47                	push   $0x47
  jmp __alltraps
  101fef:	e9 f8 07 00 00       	jmp    1027ec <__alltraps>

00101ff4 <vector72>:
.globl vector72
vector72:
  pushl $0
  101ff4:	6a 00                	push   $0x0
  pushl $72
  101ff6:	6a 48                	push   $0x48
  jmp __alltraps
  101ff8:	e9 ef 07 00 00       	jmp    1027ec <__alltraps>

00101ffd <vector73>:
.globl vector73
vector73:
  pushl $0
  101ffd:	6a 00                	push   $0x0
  pushl $73
  101fff:	6a 49                	push   $0x49
  jmp __alltraps
  102001:	e9 e6 07 00 00       	jmp    1027ec <__alltraps>

00102006 <vector74>:
.globl vector74
vector74:
  pushl $0
  102006:	6a 00                	push   $0x0
  pushl $74
  102008:	6a 4a                	push   $0x4a
  jmp __alltraps
  10200a:	e9 dd 07 00 00       	jmp    1027ec <__alltraps>

0010200f <vector75>:
.globl vector75
vector75:
  pushl $0
  10200f:	6a 00                	push   $0x0
  pushl $75
  102011:	6a 4b                	push   $0x4b
  jmp __alltraps
  102013:	e9 d4 07 00 00       	jmp    1027ec <__alltraps>

00102018 <vector76>:
.globl vector76
vector76:
  pushl $0
  102018:	6a 00                	push   $0x0
  pushl $76
  10201a:	6a 4c                	push   $0x4c
  jmp __alltraps
  10201c:	e9 cb 07 00 00       	jmp    1027ec <__alltraps>

00102021 <vector77>:
.globl vector77
vector77:
  pushl $0
  102021:	6a 00                	push   $0x0
  pushl $77
  102023:	6a 4d                	push   $0x4d
  jmp __alltraps
  102025:	e9 c2 07 00 00       	jmp    1027ec <__alltraps>

0010202a <vector78>:
.globl vector78
vector78:
  pushl $0
  10202a:	6a 00                	push   $0x0
  pushl $78
  10202c:	6a 4e                	push   $0x4e
  jmp __alltraps
  10202e:	e9 b9 07 00 00       	jmp    1027ec <__alltraps>

00102033 <vector79>:
.globl vector79
vector79:
  pushl $0
  102033:	6a 00                	push   $0x0
  pushl $79
  102035:	6a 4f                	push   $0x4f
  jmp __alltraps
  102037:	e9 b0 07 00 00       	jmp    1027ec <__alltraps>

0010203c <vector80>:
.globl vector80
vector80:
  pushl $0
  10203c:	6a 00                	push   $0x0
  pushl $80
  10203e:	6a 50                	push   $0x50
  jmp __alltraps
  102040:	e9 a7 07 00 00       	jmp    1027ec <__alltraps>

00102045 <vector81>:
.globl vector81
vector81:
  pushl $0
  102045:	6a 00                	push   $0x0
  pushl $81
  102047:	6a 51                	push   $0x51
  jmp __alltraps
  102049:	e9 9e 07 00 00       	jmp    1027ec <__alltraps>

0010204e <vector82>:
.globl vector82
vector82:
  pushl $0
  10204e:	6a 00                	push   $0x0
  pushl $82
  102050:	6a 52                	push   $0x52
  jmp __alltraps
  102052:	e9 95 07 00 00       	jmp    1027ec <__alltraps>

00102057 <vector83>:
.globl vector83
vector83:
  pushl $0
  102057:	6a 00                	push   $0x0
  pushl $83
  102059:	6a 53                	push   $0x53
  jmp __alltraps
  10205b:	e9 8c 07 00 00       	jmp    1027ec <__alltraps>

00102060 <vector84>:
.globl vector84
vector84:
  pushl $0
  102060:	6a 00                	push   $0x0
  pushl $84
  102062:	6a 54                	push   $0x54
  jmp __alltraps
  102064:	e9 83 07 00 00       	jmp    1027ec <__alltraps>

00102069 <vector85>:
.globl vector85
vector85:
  pushl $0
  102069:	6a 00                	push   $0x0
  pushl $85
  10206b:	6a 55                	push   $0x55
  jmp __alltraps
  10206d:	e9 7a 07 00 00       	jmp    1027ec <__alltraps>

00102072 <vector86>:
.globl vector86
vector86:
  pushl $0
  102072:	6a 00                	push   $0x0
  pushl $86
  102074:	6a 56                	push   $0x56
  jmp __alltraps
  102076:	e9 71 07 00 00       	jmp    1027ec <__alltraps>

0010207b <vector87>:
.globl vector87
vector87:
  pushl $0
  10207b:	6a 00                	push   $0x0
  pushl $87
  10207d:	6a 57                	push   $0x57
  jmp __alltraps
  10207f:	e9 68 07 00 00       	jmp    1027ec <__alltraps>

00102084 <vector88>:
.globl vector88
vector88:
  pushl $0
  102084:	6a 00                	push   $0x0
  pushl $88
  102086:	6a 58                	push   $0x58
  jmp __alltraps
  102088:	e9 5f 07 00 00       	jmp    1027ec <__alltraps>

0010208d <vector89>:
.globl vector89
vector89:
  pushl $0
  10208d:	6a 00                	push   $0x0
  pushl $89
  10208f:	6a 59                	push   $0x59
  jmp __alltraps
  102091:	e9 56 07 00 00       	jmp    1027ec <__alltraps>

00102096 <vector90>:
.globl vector90
vector90:
  pushl $0
  102096:	6a 00                	push   $0x0
  pushl $90
  102098:	6a 5a                	push   $0x5a
  jmp __alltraps
  10209a:	e9 4d 07 00 00       	jmp    1027ec <__alltraps>

0010209f <vector91>:
.globl vector91
vector91:
  pushl $0
  10209f:	6a 00                	push   $0x0
  pushl $91
  1020a1:	6a 5b                	push   $0x5b
  jmp __alltraps
  1020a3:	e9 44 07 00 00       	jmp    1027ec <__alltraps>

001020a8 <vector92>:
.globl vector92
vector92:
  pushl $0
  1020a8:	6a 00                	push   $0x0
  pushl $92
  1020aa:	6a 5c                	push   $0x5c
  jmp __alltraps
  1020ac:	e9 3b 07 00 00       	jmp    1027ec <__alltraps>

001020b1 <vector93>:
.globl vector93
vector93:
  pushl $0
  1020b1:	6a 00                	push   $0x0
  pushl $93
  1020b3:	6a 5d                	push   $0x5d
  jmp __alltraps
  1020b5:	e9 32 07 00 00       	jmp    1027ec <__alltraps>

001020ba <vector94>:
.globl vector94
vector94:
  pushl $0
  1020ba:	6a 00                	push   $0x0
  pushl $94
  1020bc:	6a 5e                	push   $0x5e
  jmp __alltraps
  1020be:	e9 29 07 00 00       	jmp    1027ec <__alltraps>

001020c3 <vector95>:
.globl vector95
vector95:
  pushl $0
  1020c3:	6a 00                	push   $0x0
  pushl $95
  1020c5:	6a 5f                	push   $0x5f
  jmp __alltraps
  1020c7:	e9 20 07 00 00       	jmp    1027ec <__alltraps>

001020cc <vector96>:
.globl vector96
vector96:
  pushl $0
  1020cc:	6a 00                	push   $0x0
  pushl $96
  1020ce:	6a 60                	push   $0x60
  jmp __alltraps
  1020d0:	e9 17 07 00 00       	jmp    1027ec <__alltraps>

001020d5 <vector97>:
.globl vector97
vector97:
  pushl $0
  1020d5:	6a 00                	push   $0x0
  pushl $97
  1020d7:	6a 61                	push   $0x61
  jmp __alltraps
  1020d9:	e9 0e 07 00 00       	jmp    1027ec <__alltraps>

001020de <vector98>:
.globl vector98
vector98:
  pushl $0
  1020de:	6a 00                	push   $0x0
  pushl $98
  1020e0:	6a 62                	push   $0x62
  jmp __alltraps
  1020e2:	e9 05 07 00 00       	jmp    1027ec <__alltraps>

001020e7 <vector99>:
.globl vector99
vector99:
  pushl $0
  1020e7:	6a 00                	push   $0x0
  pushl $99
  1020e9:	6a 63                	push   $0x63
  jmp __alltraps
  1020eb:	e9 fc 06 00 00       	jmp    1027ec <__alltraps>

001020f0 <vector100>:
.globl vector100
vector100:
  pushl $0
  1020f0:	6a 00                	push   $0x0
  pushl $100
  1020f2:	6a 64                	push   $0x64
  jmp __alltraps
  1020f4:	e9 f3 06 00 00       	jmp    1027ec <__alltraps>

001020f9 <vector101>:
.globl vector101
vector101:
  pushl $0
  1020f9:	6a 00                	push   $0x0
  pushl $101
  1020fb:	6a 65                	push   $0x65
  jmp __alltraps
  1020fd:	e9 ea 06 00 00       	jmp    1027ec <__alltraps>

00102102 <vector102>:
.globl vector102
vector102:
  pushl $0
  102102:	6a 00                	push   $0x0
  pushl $102
  102104:	6a 66                	push   $0x66
  jmp __alltraps
  102106:	e9 e1 06 00 00       	jmp    1027ec <__alltraps>

0010210b <vector103>:
.globl vector103
vector103:
  pushl $0
  10210b:	6a 00                	push   $0x0
  pushl $103
  10210d:	6a 67                	push   $0x67
  jmp __alltraps
  10210f:	e9 d8 06 00 00       	jmp    1027ec <__alltraps>

00102114 <vector104>:
.globl vector104
vector104:
  pushl $0
  102114:	6a 00                	push   $0x0
  pushl $104
  102116:	6a 68                	push   $0x68
  jmp __alltraps
  102118:	e9 cf 06 00 00       	jmp    1027ec <__alltraps>

0010211d <vector105>:
.globl vector105
vector105:
  pushl $0
  10211d:	6a 00                	push   $0x0
  pushl $105
  10211f:	6a 69                	push   $0x69
  jmp __alltraps
  102121:	e9 c6 06 00 00       	jmp    1027ec <__alltraps>

00102126 <vector106>:
.globl vector106
vector106:
  pushl $0
  102126:	6a 00                	push   $0x0
  pushl $106
  102128:	6a 6a                	push   $0x6a
  jmp __alltraps
  10212a:	e9 bd 06 00 00       	jmp    1027ec <__alltraps>

0010212f <vector107>:
.globl vector107
vector107:
  pushl $0
  10212f:	6a 00                	push   $0x0
  pushl $107
  102131:	6a 6b                	push   $0x6b
  jmp __alltraps
  102133:	e9 b4 06 00 00       	jmp    1027ec <__alltraps>

00102138 <vector108>:
.globl vector108
vector108:
  pushl $0
  102138:	6a 00                	push   $0x0
  pushl $108
  10213a:	6a 6c                	push   $0x6c
  jmp __alltraps
  10213c:	e9 ab 06 00 00       	jmp    1027ec <__alltraps>

00102141 <vector109>:
.globl vector109
vector109:
  pushl $0
  102141:	6a 00                	push   $0x0
  pushl $109
  102143:	6a 6d                	push   $0x6d
  jmp __alltraps
  102145:	e9 a2 06 00 00       	jmp    1027ec <__alltraps>

0010214a <vector110>:
.globl vector110
vector110:
  pushl $0
  10214a:	6a 00                	push   $0x0
  pushl $110
  10214c:	6a 6e                	push   $0x6e
  jmp __alltraps
  10214e:	e9 99 06 00 00       	jmp    1027ec <__alltraps>

00102153 <vector111>:
.globl vector111
vector111:
  pushl $0
  102153:	6a 00                	push   $0x0
  pushl $111
  102155:	6a 6f                	push   $0x6f
  jmp __alltraps
  102157:	e9 90 06 00 00       	jmp    1027ec <__alltraps>

0010215c <vector112>:
.globl vector112
vector112:
  pushl $0
  10215c:	6a 00                	push   $0x0
  pushl $112
  10215e:	6a 70                	push   $0x70
  jmp __alltraps
  102160:	e9 87 06 00 00       	jmp    1027ec <__alltraps>

00102165 <vector113>:
.globl vector113
vector113:
  pushl $0
  102165:	6a 00                	push   $0x0
  pushl $113
  102167:	6a 71                	push   $0x71
  jmp __alltraps
  102169:	e9 7e 06 00 00       	jmp    1027ec <__alltraps>

0010216e <vector114>:
.globl vector114
vector114:
  pushl $0
  10216e:	6a 00                	push   $0x0
  pushl $114
  102170:	6a 72                	push   $0x72
  jmp __alltraps
  102172:	e9 75 06 00 00       	jmp    1027ec <__alltraps>

00102177 <vector115>:
.globl vector115
vector115:
  pushl $0
  102177:	6a 00                	push   $0x0
  pushl $115
  102179:	6a 73                	push   $0x73
  jmp __alltraps
  10217b:	e9 6c 06 00 00       	jmp    1027ec <__alltraps>

00102180 <vector116>:
.globl vector116
vector116:
  pushl $0
  102180:	6a 00                	push   $0x0
  pushl $116
  102182:	6a 74                	push   $0x74
  jmp __alltraps
  102184:	e9 63 06 00 00       	jmp    1027ec <__alltraps>

00102189 <vector117>:
.globl vector117
vector117:
  pushl $0
  102189:	6a 00                	push   $0x0
  pushl $117
  10218b:	6a 75                	push   $0x75
  jmp __alltraps
  10218d:	e9 5a 06 00 00       	jmp    1027ec <__alltraps>

00102192 <vector118>:
.globl vector118
vector118:
  pushl $0
  102192:	6a 00                	push   $0x0
  pushl $118
  102194:	6a 76                	push   $0x76
  jmp __alltraps
  102196:	e9 51 06 00 00       	jmp    1027ec <__alltraps>

0010219b <vector119>:
.globl vector119
vector119:
  pushl $0
  10219b:	6a 00                	push   $0x0
  pushl $119
  10219d:	6a 77                	push   $0x77
  jmp __alltraps
  10219f:	e9 48 06 00 00       	jmp    1027ec <__alltraps>

001021a4 <vector120>:
.globl vector120
vector120:
  pushl $0
  1021a4:	6a 00                	push   $0x0
  pushl $120
  1021a6:	6a 78                	push   $0x78
  jmp __alltraps
  1021a8:	e9 3f 06 00 00       	jmp    1027ec <__alltraps>

001021ad <vector121>:
.globl vector121
vector121:
  pushl $0
  1021ad:	6a 00                	push   $0x0
  pushl $121
  1021af:	6a 79                	push   $0x79
  jmp __alltraps
  1021b1:	e9 36 06 00 00       	jmp    1027ec <__alltraps>

001021b6 <vector122>:
.globl vector122
vector122:
  pushl $0
  1021b6:	6a 00                	push   $0x0
  pushl $122
  1021b8:	6a 7a                	push   $0x7a
  jmp __alltraps
  1021ba:	e9 2d 06 00 00       	jmp    1027ec <__alltraps>

001021bf <vector123>:
.globl vector123
vector123:
  pushl $0
  1021bf:	6a 00                	push   $0x0
  pushl $123
  1021c1:	6a 7b                	push   $0x7b
  jmp __alltraps
  1021c3:	e9 24 06 00 00       	jmp    1027ec <__alltraps>

001021c8 <vector124>:
.globl vector124
vector124:
  pushl $0
  1021c8:	6a 00                	push   $0x0
  pushl $124
  1021ca:	6a 7c                	push   $0x7c
  jmp __alltraps
  1021cc:	e9 1b 06 00 00       	jmp    1027ec <__alltraps>

001021d1 <vector125>:
.globl vector125
vector125:
  pushl $0
  1021d1:	6a 00                	push   $0x0
  pushl $125
  1021d3:	6a 7d                	push   $0x7d
  jmp __alltraps
  1021d5:	e9 12 06 00 00       	jmp    1027ec <__alltraps>

001021da <vector126>:
.globl vector126
vector126:
  pushl $0
  1021da:	6a 00                	push   $0x0
  pushl $126
  1021dc:	6a 7e                	push   $0x7e
  jmp __alltraps
  1021de:	e9 09 06 00 00       	jmp    1027ec <__alltraps>

001021e3 <vector127>:
.globl vector127
vector127:
  pushl $0
  1021e3:	6a 00                	push   $0x0
  pushl $127
  1021e5:	6a 7f                	push   $0x7f
  jmp __alltraps
  1021e7:	e9 00 06 00 00       	jmp    1027ec <__alltraps>

001021ec <vector128>:
.globl vector128
vector128:
  pushl $0
  1021ec:	6a 00                	push   $0x0
  pushl $128
  1021ee:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  1021f3:	e9 f4 05 00 00       	jmp    1027ec <__alltraps>

001021f8 <vector129>:
.globl vector129
vector129:
  pushl $0
  1021f8:	6a 00                	push   $0x0
  pushl $129
  1021fa:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  1021ff:	e9 e8 05 00 00       	jmp    1027ec <__alltraps>

00102204 <vector130>:
.globl vector130
vector130:
  pushl $0
  102204:	6a 00                	push   $0x0
  pushl $130
  102206:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  10220b:	e9 dc 05 00 00       	jmp    1027ec <__alltraps>

00102210 <vector131>:
.globl vector131
vector131:
  pushl $0
  102210:	6a 00                	push   $0x0
  pushl $131
  102212:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102217:	e9 d0 05 00 00       	jmp    1027ec <__alltraps>

0010221c <vector132>:
.globl vector132
vector132:
  pushl $0
  10221c:	6a 00                	push   $0x0
  pushl $132
  10221e:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102223:	e9 c4 05 00 00       	jmp    1027ec <__alltraps>

00102228 <vector133>:
.globl vector133
vector133:
  pushl $0
  102228:	6a 00                	push   $0x0
  pushl $133
  10222a:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  10222f:	e9 b8 05 00 00       	jmp    1027ec <__alltraps>

00102234 <vector134>:
.globl vector134
vector134:
  pushl $0
  102234:	6a 00                	push   $0x0
  pushl $134
  102236:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  10223b:	e9 ac 05 00 00       	jmp    1027ec <__alltraps>

00102240 <vector135>:
.globl vector135
vector135:
  pushl $0
  102240:	6a 00                	push   $0x0
  pushl $135
  102242:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102247:	e9 a0 05 00 00       	jmp    1027ec <__alltraps>

0010224c <vector136>:
.globl vector136
vector136:
  pushl $0
  10224c:	6a 00                	push   $0x0
  pushl $136
  10224e:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102253:	e9 94 05 00 00       	jmp    1027ec <__alltraps>

00102258 <vector137>:
.globl vector137
vector137:
  pushl $0
  102258:	6a 00                	push   $0x0
  pushl $137
  10225a:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  10225f:	e9 88 05 00 00       	jmp    1027ec <__alltraps>

00102264 <vector138>:
.globl vector138
vector138:
  pushl $0
  102264:	6a 00                	push   $0x0
  pushl $138
  102266:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  10226b:	e9 7c 05 00 00       	jmp    1027ec <__alltraps>

00102270 <vector139>:
.globl vector139
vector139:
  pushl $0
  102270:	6a 00                	push   $0x0
  pushl $139
  102272:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102277:	e9 70 05 00 00       	jmp    1027ec <__alltraps>

0010227c <vector140>:
.globl vector140
vector140:
  pushl $0
  10227c:	6a 00                	push   $0x0
  pushl $140
  10227e:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102283:	e9 64 05 00 00       	jmp    1027ec <__alltraps>

00102288 <vector141>:
.globl vector141
vector141:
  pushl $0
  102288:	6a 00                	push   $0x0
  pushl $141
  10228a:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  10228f:	e9 58 05 00 00       	jmp    1027ec <__alltraps>

00102294 <vector142>:
.globl vector142
vector142:
  pushl $0
  102294:	6a 00                	push   $0x0
  pushl $142
  102296:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  10229b:	e9 4c 05 00 00       	jmp    1027ec <__alltraps>

001022a0 <vector143>:
.globl vector143
vector143:
  pushl $0
  1022a0:	6a 00                	push   $0x0
  pushl $143
  1022a2:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1022a7:	e9 40 05 00 00       	jmp    1027ec <__alltraps>

001022ac <vector144>:
.globl vector144
vector144:
  pushl $0
  1022ac:	6a 00                	push   $0x0
  pushl $144
  1022ae:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1022b3:	e9 34 05 00 00       	jmp    1027ec <__alltraps>

001022b8 <vector145>:
.globl vector145
vector145:
  pushl $0
  1022b8:	6a 00                	push   $0x0
  pushl $145
  1022ba:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1022bf:	e9 28 05 00 00       	jmp    1027ec <__alltraps>

001022c4 <vector146>:
.globl vector146
vector146:
  pushl $0
  1022c4:	6a 00                	push   $0x0
  pushl $146
  1022c6:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1022cb:	e9 1c 05 00 00       	jmp    1027ec <__alltraps>

001022d0 <vector147>:
.globl vector147
vector147:
  pushl $0
  1022d0:	6a 00                	push   $0x0
  pushl $147
  1022d2:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1022d7:	e9 10 05 00 00       	jmp    1027ec <__alltraps>

001022dc <vector148>:
.globl vector148
vector148:
  pushl $0
  1022dc:	6a 00                	push   $0x0
  pushl $148
  1022de:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  1022e3:	e9 04 05 00 00       	jmp    1027ec <__alltraps>

001022e8 <vector149>:
.globl vector149
vector149:
  pushl $0
  1022e8:	6a 00                	push   $0x0
  pushl $149
  1022ea:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  1022ef:	e9 f8 04 00 00       	jmp    1027ec <__alltraps>

001022f4 <vector150>:
.globl vector150
vector150:
  pushl $0
  1022f4:	6a 00                	push   $0x0
  pushl $150
  1022f6:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  1022fb:	e9 ec 04 00 00       	jmp    1027ec <__alltraps>

00102300 <vector151>:
.globl vector151
vector151:
  pushl $0
  102300:	6a 00                	push   $0x0
  pushl $151
  102302:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102307:	e9 e0 04 00 00       	jmp    1027ec <__alltraps>

0010230c <vector152>:
.globl vector152
vector152:
  pushl $0
  10230c:	6a 00                	push   $0x0
  pushl $152
  10230e:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102313:	e9 d4 04 00 00       	jmp    1027ec <__alltraps>

00102318 <vector153>:
.globl vector153
vector153:
  pushl $0
  102318:	6a 00                	push   $0x0
  pushl $153
  10231a:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  10231f:	e9 c8 04 00 00       	jmp    1027ec <__alltraps>

00102324 <vector154>:
.globl vector154
vector154:
  pushl $0
  102324:	6a 00                	push   $0x0
  pushl $154
  102326:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  10232b:	e9 bc 04 00 00       	jmp    1027ec <__alltraps>

00102330 <vector155>:
.globl vector155
vector155:
  pushl $0
  102330:	6a 00                	push   $0x0
  pushl $155
  102332:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102337:	e9 b0 04 00 00       	jmp    1027ec <__alltraps>

0010233c <vector156>:
.globl vector156
vector156:
  pushl $0
  10233c:	6a 00                	push   $0x0
  pushl $156
  10233e:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102343:	e9 a4 04 00 00       	jmp    1027ec <__alltraps>

00102348 <vector157>:
.globl vector157
vector157:
  pushl $0
  102348:	6a 00                	push   $0x0
  pushl $157
  10234a:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  10234f:	e9 98 04 00 00       	jmp    1027ec <__alltraps>

00102354 <vector158>:
.globl vector158
vector158:
  pushl $0
  102354:	6a 00                	push   $0x0
  pushl $158
  102356:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  10235b:	e9 8c 04 00 00       	jmp    1027ec <__alltraps>

00102360 <vector159>:
.globl vector159
vector159:
  pushl $0
  102360:	6a 00                	push   $0x0
  pushl $159
  102362:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102367:	e9 80 04 00 00       	jmp    1027ec <__alltraps>

0010236c <vector160>:
.globl vector160
vector160:
  pushl $0
  10236c:	6a 00                	push   $0x0
  pushl $160
  10236e:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102373:	e9 74 04 00 00       	jmp    1027ec <__alltraps>

00102378 <vector161>:
.globl vector161
vector161:
  pushl $0
  102378:	6a 00                	push   $0x0
  pushl $161
  10237a:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  10237f:	e9 68 04 00 00       	jmp    1027ec <__alltraps>

00102384 <vector162>:
.globl vector162
vector162:
  pushl $0
  102384:	6a 00                	push   $0x0
  pushl $162
  102386:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  10238b:	e9 5c 04 00 00       	jmp    1027ec <__alltraps>

00102390 <vector163>:
.globl vector163
vector163:
  pushl $0
  102390:	6a 00                	push   $0x0
  pushl $163
  102392:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  102397:	e9 50 04 00 00       	jmp    1027ec <__alltraps>

0010239c <vector164>:
.globl vector164
vector164:
  pushl $0
  10239c:	6a 00                	push   $0x0
  pushl $164
  10239e:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1023a3:	e9 44 04 00 00       	jmp    1027ec <__alltraps>

001023a8 <vector165>:
.globl vector165
vector165:
  pushl $0
  1023a8:	6a 00                	push   $0x0
  pushl $165
  1023aa:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1023af:	e9 38 04 00 00       	jmp    1027ec <__alltraps>

001023b4 <vector166>:
.globl vector166
vector166:
  pushl $0
  1023b4:	6a 00                	push   $0x0
  pushl $166
  1023b6:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1023bb:	e9 2c 04 00 00       	jmp    1027ec <__alltraps>

001023c0 <vector167>:
.globl vector167
vector167:
  pushl $0
  1023c0:	6a 00                	push   $0x0
  pushl $167
  1023c2:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1023c7:	e9 20 04 00 00       	jmp    1027ec <__alltraps>

001023cc <vector168>:
.globl vector168
vector168:
  pushl $0
  1023cc:	6a 00                	push   $0x0
  pushl $168
  1023ce:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1023d3:	e9 14 04 00 00       	jmp    1027ec <__alltraps>

001023d8 <vector169>:
.globl vector169
vector169:
  pushl $0
  1023d8:	6a 00                	push   $0x0
  pushl $169
  1023da:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1023df:	e9 08 04 00 00       	jmp    1027ec <__alltraps>

001023e4 <vector170>:
.globl vector170
vector170:
  pushl $0
  1023e4:	6a 00                	push   $0x0
  pushl $170
  1023e6:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1023eb:	e9 fc 03 00 00       	jmp    1027ec <__alltraps>

001023f0 <vector171>:
.globl vector171
vector171:
  pushl $0
  1023f0:	6a 00                	push   $0x0
  pushl $171
  1023f2:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  1023f7:	e9 f0 03 00 00       	jmp    1027ec <__alltraps>

001023fc <vector172>:
.globl vector172
vector172:
  pushl $0
  1023fc:	6a 00                	push   $0x0
  pushl $172
  1023fe:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102403:	e9 e4 03 00 00       	jmp    1027ec <__alltraps>

00102408 <vector173>:
.globl vector173
vector173:
  pushl $0
  102408:	6a 00                	push   $0x0
  pushl $173
  10240a:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  10240f:	e9 d8 03 00 00       	jmp    1027ec <__alltraps>

00102414 <vector174>:
.globl vector174
vector174:
  pushl $0
  102414:	6a 00                	push   $0x0
  pushl $174
  102416:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  10241b:	e9 cc 03 00 00       	jmp    1027ec <__alltraps>

00102420 <vector175>:
.globl vector175
vector175:
  pushl $0
  102420:	6a 00                	push   $0x0
  pushl $175
  102422:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102427:	e9 c0 03 00 00       	jmp    1027ec <__alltraps>

0010242c <vector176>:
.globl vector176
vector176:
  pushl $0
  10242c:	6a 00                	push   $0x0
  pushl $176
  10242e:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102433:	e9 b4 03 00 00       	jmp    1027ec <__alltraps>

00102438 <vector177>:
.globl vector177
vector177:
  pushl $0
  102438:	6a 00                	push   $0x0
  pushl $177
  10243a:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  10243f:	e9 a8 03 00 00       	jmp    1027ec <__alltraps>

00102444 <vector178>:
.globl vector178
vector178:
  pushl $0
  102444:	6a 00                	push   $0x0
  pushl $178
  102446:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  10244b:	e9 9c 03 00 00       	jmp    1027ec <__alltraps>

00102450 <vector179>:
.globl vector179
vector179:
  pushl $0
  102450:	6a 00                	push   $0x0
  pushl $179
  102452:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102457:	e9 90 03 00 00       	jmp    1027ec <__alltraps>

0010245c <vector180>:
.globl vector180
vector180:
  pushl $0
  10245c:	6a 00                	push   $0x0
  pushl $180
  10245e:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102463:	e9 84 03 00 00       	jmp    1027ec <__alltraps>

00102468 <vector181>:
.globl vector181
vector181:
  pushl $0
  102468:	6a 00                	push   $0x0
  pushl $181
  10246a:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  10246f:	e9 78 03 00 00       	jmp    1027ec <__alltraps>

00102474 <vector182>:
.globl vector182
vector182:
  pushl $0
  102474:	6a 00                	push   $0x0
  pushl $182
  102476:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  10247b:	e9 6c 03 00 00       	jmp    1027ec <__alltraps>

00102480 <vector183>:
.globl vector183
vector183:
  pushl $0
  102480:	6a 00                	push   $0x0
  pushl $183
  102482:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  102487:	e9 60 03 00 00       	jmp    1027ec <__alltraps>

0010248c <vector184>:
.globl vector184
vector184:
  pushl $0
  10248c:	6a 00                	push   $0x0
  pushl $184
  10248e:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102493:	e9 54 03 00 00       	jmp    1027ec <__alltraps>

00102498 <vector185>:
.globl vector185
vector185:
  pushl $0
  102498:	6a 00                	push   $0x0
  pushl $185
  10249a:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  10249f:	e9 48 03 00 00       	jmp    1027ec <__alltraps>

001024a4 <vector186>:
.globl vector186
vector186:
  pushl $0
  1024a4:	6a 00                	push   $0x0
  pushl $186
  1024a6:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1024ab:	e9 3c 03 00 00       	jmp    1027ec <__alltraps>

001024b0 <vector187>:
.globl vector187
vector187:
  pushl $0
  1024b0:	6a 00                	push   $0x0
  pushl $187
  1024b2:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1024b7:	e9 30 03 00 00       	jmp    1027ec <__alltraps>

001024bc <vector188>:
.globl vector188
vector188:
  pushl $0
  1024bc:	6a 00                	push   $0x0
  pushl $188
  1024be:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1024c3:	e9 24 03 00 00       	jmp    1027ec <__alltraps>

001024c8 <vector189>:
.globl vector189
vector189:
  pushl $0
  1024c8:	6a 00                	push   $0x0
  pushl $189
  1024ca:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1024cf:	e9 18 03 00 00       	jmp    1027ec <__alltraps>

001024d4 <vector190>:
.globl vector190
vector190:
  pushl $0
  1024d4:	6a 00                	push   $0x0
  pushl $190
  1024d6:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1024db:	e9 0c 03 00 00       	jmp    1027ec <__alltraps>

001024e0 <vector191>:
.globl vector191
vector191:
  pushl $0
  1024e0:	6a 00                	push   $0x0
  pushl $191
  1024e2:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  1024e7:	e9 00 03 00 00       	jmp    1027ec <__alltraps>

001024ec <vector192>:
.globl vector192
vector192:
  pushl $0
  1024ec:	6a 00                	push   $0x0
  pushl $192
  1024ee:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  1024f3:	e9 f4 02 00 00       	jmp    1027ec <__alltraps>

001024f8 <vector193>:
.globl vector193
vector193:
  pushl $0
  1024f8:	6a 00                	push   $0x0
  pushl $193
  1024fa:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  1024ff:	e9 e8 02 00 00       	jmp    1027ec <__alltraps>

00102504 <vector194>:
.globl vector194
vector194:
  pushl $0
  102504:	6a 00                	push   $0x0
  pushl $194
  102506:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  10250b:	e9 dc 02 00 00       	jmp    1027ec <__alltraps>

00102510 <vector195>:
.globl vector195
vector195:
  pushl $0
  102510:	6a 00                	push   $0x0
  pushl $195
  102512:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102517:	e9 d0 02 00 00       	jmp    1027ec <__alltraps>

0010251c <vector196>:
.globl vector196
vector196:
  pushl $0
  10251c:	6a 00                	push   $0x0
  pushl $196
  10251e:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102523:	e9 c4 02 00 00       	jmp    1027ec <__alltraps>

00102528 <vector197>:
.globl vector197
vector197:
  pushl $0
  102528:	6a 00                	push   $0x0
  pushl $197
  10252a:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  10252f:	e9 b8 02 00 00       	jmp    1027ec <__alltraps>

00102534 <vector198>:
.globl vector198
vector198:
  pushl $0
  102534:	6a 00                	push   $0x0
  pushl $198
  102536:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  10253b:	e9 ac 02 00 00       	jmp    1027ec <__alltraps>

00102540 <vector199>:
.globl vector199
vector199:
  pushl $0
  102540:	6a 00                	push   $0x0
  pushl $199
  102542:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102547:	e9 a0 02 00 00       	jmp    1027ec <__alltraps>

0010254c <vector200>:
.globl vector200
vector200:
  pushl $0
  10254c:	6a 00                	push   $0x0
  pushl $200
  10254e:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102553:	e9 94 02 00 00       	jmp    1027ec <__alltraps>

00102558 <vector201>:
.globl vector201
vector201:
  pushl $0
  102558:	6a 00                	push   $0x0
  pushl $201
  10255a:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  10255f:	e9 88 02 00 00       	jmp    1027ec <__alltraps>

00102564 <vector202>:
.globl vector202
vector202:
  pushl $0
  102564:	6a 00                	push   $0x0
  pushl $202
  102566:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  10256b:	e9 7c 02 00 00       	jmp    1027ec <__alltraps>

00102570 <vector203>:
.globl vector203
vector203:
  pushl $0
  102570:	6a 00                	push   $0x0
  pushl $203
  102572:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102577:	e9 70 02 00 00       	jmp    1027ec <__alltraps>

0010257c <vector204>:
.globl vector204
vector204:
  pushl $0
  10257c:	6a 00                	push   $0x0
  pushl $204
  10257e:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102583:	e9 64 02 00 00       	jmp    1027ec <__alltraps>

00102588 <vector205>:
.globl vector205
vector205:
  pushl $0
  102588:	6a 00                	push   $0x0
  pushl $205
  10258a:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  10258f:	e9 58 02 00 00       	jmp    1027ec <__alltraps>

00102594 <vector206>:
.globl vector206
vector206:
  pushl $0
  102594:	6a 00                	push   $0x0
  pushl $206
  102596:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  10259b:	e9 4c 02 00 00       	jmp    1027ec <__alltraps>

001025a0 <vector207>:
.globl vector207
vector207:
  pushl $0
  1025a0:	6a 00                	push   $0x0
  pushl $207
  1025a2:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1025a7:	e9 40 02 00 00       	jmp    1027ec <__alltraps>

001025ac <vector208>:
.globl vector208
vector208:
  pushl $0
  1025ac:	6a 00                	push   $0x0
  pushl $208
  1025ae:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1025b3:	e9 34 02 00 00       	jmp    1027ec <__alltraps>

001025b8 <vector209>:
.globl vector209
vector209:
  pushl $0
  1025b8:	6a 00                	push   $0x0
  pushl $209
  1025ba:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1025bf:	e9 28 02 00 00       	jmp    1027ec <__alltraps>

001025c4 <vector210>:
.globl vector210
vector210:
  pushl $0
  1025c4:	6a 00                	push   $0x0
  pushl $210
  1025c6:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1025cb:	e9 1c 02 00 00       	jmp    1027ec <__alltraps>

001025d0 <vector211>:
.globl vector211
vector211:
  pushl $0
  1025d0:	6a 00                	push   $0x0
  pushl $211
  1025d2:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1025d7:	e9 10 02 00 00       	jmp    1027ec <__alltraps>

001025dc <vector212>:
.globl vector212
vector212:
  pushl $0
  1025dc:	6a 00                	push   $0x0
  pushl $212
  1025de:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  1025e3:	e9 04 02 00 00       	jmp    1027ec <__alltraps>

001025e8 <vector213>:
.globl vector213
vector213:
  pushl $0
  1025e8:	6a 00                	push   $0x0
  pushl $213
  1025ea:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  1025ef:	e9 f8 01 00 00       	jmp    1027ec <__alltraps>

001025f4 <vector214>:
.globl vector214
vector214:
  pushl $0
  1025f4:	6a 00                	push   $0x0
  pushl $214
  1025f6:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  1025fb:	e9 ec 01 00 00       	jmp    1027ec <__alltraps>

00102600 <vector215>:
.globl vector215
vector215:
  pushl $0
  102600:	6a 00                	push   $0x0
  pushl $215
  102602:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102607:	e9 e0 01 00 00       	jmp    1027ec <__alltraps>

0010260c <vector216>:
.globl vector216
vector216:
  pushl $0
  10260c:	6a 00                	push   $0x0
  pushl $216
  10260e:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102613:	e9 d4 01 00 00       	jmp    1027ec <__alltraps>

00102618 <vector217>:
.globl vector217
vector217:
  pushl $0
  102618:	6a 00                	push   $0x0
  pushl $217
  10261a:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  10261f:	e9 c8 01 00 00       	jmp    1027ec <__alltraps>

00102624 <vector218>:
.globl vector218
vector218:
  pushl $0
  102624:	6a 00                	push   $0x0
  pushl $218
  102626:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  10262b:	e9 bc 01 00 00       	jmp    1027ec <__alltraps>

00102630 <vector219>:
.globl vector219
vector219:
  pushl $0
  102630:	6a 00                	push   $0x0
  pushl $219
  102632:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102637:	e9 b0 01 00 00       	jmp    1027ec <__alltraps>

0010263c <vector220>:
.globl vector220
vector220:
  pushl $0
  10263c:	6a 00                	push   $0x0
  pushl $220
  10263e:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102643:	e9 a4 01 00 00       	jmp    1027ec <__alltraps>

00102648 <vector221>:
.globl vector221
vector221:
  pushl $0
  102648:	6a 00                	push   $0x0
  pushl $221
  10264a:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  10264f:	e9 98 01 00 00       	jmp    1027ec <__alltraps>

00102654 <vector222>:
.globl vector222
vector222:
  pushl $0
  102654:	6a 00                	push   $0x0
  pushl $222
  102656:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  10265b:	e9 8c 01 00 00       	jmp    1027ec <__alltraps>

00102660 <vector223>:
.globl vector223
vector223:
  pushl $0
  102660:	6a 00                	push   $0x0
  pushl $223
  102662:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102667:	e9 80 01 00 00       	jmp    1027ec <__alltraps>

0010266c <vector224>:
.globl vector224
vector224:
  pushl $0
  10266c:	6a 00                	push   $0x0
  pushl $224
  10266e:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102673:	e9 74 01 00 00       	jmp    1027ec <__alltraps>

00102678 <vector225>:
.globl vector225
vector225:
  pushl $0
  102678:	6a 00                	push   $0x0
  pushl $225
  10267a:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  10267f:	e9 68 01 00 00       	jmp    1027ec <__alltraps>

00102684 <vector226>:
.globl vector226
vector226:
  pushl $0
  102684:	6a 00                	push   $0x0
  pushl $226
  102686:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  10268b:	e9 5c 01 00 00       	jmp    1027ec <__alltraps>

00102690 <vector227>:
.globl vector227
vector227:
  pushl $0
  102690:	6a 00                	push   $0x0
  pushl $227
  102692:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102697:	e9 50 01 00 00       	jmp    1027ec <__alltraps>

0010269c <vector228>:
.globl vector228
vector228:
  pushl $0
  10269c:	6a 00                	push   $0x0
  pushl $228
  10269e:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1026a3:	e9 44 01 00 00       	jmp    1027ec <__alltraps>

001026a8 <vector229>:
.globl vector229
vector229:
  pushl $0
  1026a8:	6a 00                	push   $0x0
  pushl $229
  1026aa:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1026af:	e9 38 01 00 00       	jmp    1027ec <__alltraps>

001026b4 <vector230>:
.globl vector230
vector230:
  pushl $0
  1026b4:	6a 00                	push   $0x0
  pushl $230
  1026b6:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1026bb:	e9 2c 01 00 00       	jmp    1027ec <__alltraps>

001026c0 <vector231>:
.globl vector231
vector231:
  pushl $0
  1026c0:	6a 00                	push   $0x0
  pushl $231
  1026c2:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1026c7:	e9 20 01 00 00       	jmp    1027ec <__alltraps>

001026cc <vector232>:
.globl vector232
vector232:
  pushl $0
  1026cc:	6a 00                	push   $0x0
  pushl $232
  1026ce:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  1026d3:	e9 14 01 00 00       	jmp    1027ec <__alltraps>

001026d8 <vector233>:
.globl vector233
vector233:
  pushl $0
  1026d8:	6a 00                	push   $0x0
  pushl $233
  1026da:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  1026df:	e9 08 01 00 00       	jmp    1027ec <__alltraps>

001026e4 <vector234>:
.globl vector234
vector234:
  pushl $0
  1026e4:	6a 00                	push   $0x0
  pushl $234
  1026e6:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  1026eb:	e9 fc 00 00 00       	jmp    1027ec <__alltraps>

001026f0 <vector235>:
.globl vector235
vector235:
  pushl $0
  1026f0:	6a 00                	push   $0x0
  pushl $235
  1026f2:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  1026f7:	e9 f0 00 00 00       	jmp    1027ec <__alltraps>

001026fc <vector236>:
.globl vector236
vector236:
  pushl $0
  1026fc:	6a 00                	push   $0x0
  pushl $236
  1026fe:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102703:	e9 e4 00 00 00       	jmp    1027ec <__alltraps>

00102708 <vector237>:
.globl vector237
vector237:
  pushl $0
  102708:	6a 00                	push   $0x0
  pushl $237
  10270a:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  10270f:	e9 d8 00 00 00       	jmp    1027ec <__alltraps>

00102714 <vector238>:
.globl vector238
vector238:
  pushl $0
  102714:	6a 00                	push   $0x0
  pushl $238
  102716:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  10271b:	e9 cc 00 00 00       	jmp    1027ec <__alltraps>

00102720 <vector239>:
.globl vector239
vector239:
  pushl $0
  102720:	6a 00                	push   $0x0
  pushl $239
  102722:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102727:	e9 c0 00 00 00       	jmp    1027ec <__alltraps>

0010272c <vector240>:
.globl vector240
vector240:
  pushl $0
  10272c:	6a 00                	push   $0x0
  pushl $240
  10272e:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102733:	e9 b4 00 00 00       	jmp    1027ec <__alltraps>

00102738 <vector241>:
.globl vector241
vector241:
  pushl $0
  102738:	6a 00                	push   $0x0
  pushl $241
  10273a:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  10273f:	e9 a8 00 00 00       	jmp    1027ec <__alltraps>

00102744 <vector242>:
.globl vector242
vector242:
  pushl $0
  102744:	6a 00                	push   $0x0
  pushl $242
  102746:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  10274b:	e9 9c 00 00 00       	jmp    1027ec <__alltraps>

00102750 <vector243>:
.globl vector243
vector243:
  pushl $0
  102750:	6a 00                	push   $0x0
  pushl $243
  102752:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102757:	e9 90 00 00 00       	jmp    1027ec <__alltraps>

0010275c <vector244>:
.globl vector244
vector244:
  pushl $0
  10275c:	6a 00                	push   $0x0
  pushl $244
  10275e:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102763:	e9 84 00 00 00       	jmp    1027ec <__alltraps>

00102768 <vector245>:
.globl vector245
vector245:
  pushl $0
  102768:	6a 00                	push   $0x0
  pushl $245
  10276a:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  10276f:	e9 78 00 00 00       	jmp    1027ec <__alltraps>

00102774 <vector246>:
.globl vector246
vector246:
  pushl $0
  102774:	6a 00                	push   $0x0
  pushl $246
  102776:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  10277b:	e9 6c 00 00 00       	jmp    1027ec <__alltraps>

00102780 <vector247>:
.globl vector247
vector247:
  pushl $0
  102780:	6a 00                	push   $0x0
  pushl $247
  102782:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102787:	e9 60 00 00 00       	jmp    1027ec <__alltraps>

0010278c <vector248>:
.globl vector248
vector248:
  pushl $0
  10278c:	6a 00                	push   $0x0
  pushl $248
  10278e:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102793:	e9 54 00 00 00       	jmp    1027ec <__alltraps>

00102798 <vector249>:
.globl vector249
vector249:
  pushl $0
  102798:	6a 00                	push   $0x0
  pushl $249
  10279a:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  10279f:	e9 48 00 00 00       	jmp    1027ec <__alltraps>

001027a4 <vector250>:
.globl vector250
vector250:
  pushl $0
  1027a4:	6a 00                	push   $0x0
  pushl $250
  1027a6:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1027ab:	e9 3c 00 00 00       	jmp    1027ec <__alltraps>

001027b0 <vector251>:
.globl vector251
vector251:
  pushl $0
  1027b0:	6a 00                	push   $0x0
  pushl $251
  1027b2:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1027b7:	e9 30 00 00 00       	jmp    1027ec <__alltraps>

001027bc <vector252>:
.globl vector252
vector252:
  pushl $0
  1027bc:	6a 00                	push   $0x0
  pushl $252
  1027be:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1027c3:	e9 24 00 00 00       	jmp    1027ec <__alltraps>

001027c8 <vector253>:
.globl vector253
vector253:
  pushl $0
  1027c8:	6a 00                	push   $0x0
  pushl $253
  1027ca:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  1027cf:	e9 18 00 00 00       	jmp    1027ec <__alltraps>

001027d4 <vector254>:
.globl vector254
vector254:
  pushl $0
  1027d4:	6a 00                	push   $0x0
  pushl $254
  1027d6:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  1027db:	e9 0c 00 00 00       	jmp    1027ec <__alltraps>

001027e0 <vector255>:
.globl vector255
vector255:
  pushl $0
  1027e0:	6a 00                	push   $0x0
  pushl $255
  1027e2:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  1027e7:	e9 00 00 00 00       	jmp    1027ec <__alltraps>

001027ec <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  1027ec:	1e                   	push   %ds
    pushl %es
  1027ed:	06                   	push   %es
    pushl %fs
  1027ee:	0f a0                	push   %fs
    pushl %gs
  1027f0:	0f a8                	push   %gs
    pushal
  1027f2:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  1027f3:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  1027f8:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  1027fa:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  1027fc:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  1027fd:	e8 64 f5 ff ff       	call   101d66 <trap>

    # pop the pushed stack pointer
    popl %esp
  102802:	5c                   	pop    %esp

00102803 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102803:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102804:	0f a9                	pop    %gs
    popl %fs
  102806:	0f a1                	pop    %fs
    popl %es
  102808:	07                   	pop    %es
    popl %ds
  102809:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  10280a:	83 c4 08             	add    $0x8,%esp
    iret
  10280d:	cf                   	iret   

0010280e <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  10280e:	55                   	push   %ebp
  10280f:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102811:	8b 45 08             	mov    0x8(%ebp),%eax
  102814:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102817:	b8 23 00 00 00       	mov    $0x23,%eax
  10281c:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  10281e:	b8 23 00 00 00       	mov    $0x23,%eax
  102823:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102825:	b8 10 00 00 00       	mov    $0x10,%eax
  10282a:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  10282c:	b8 10 00 00 00       	mov    $0x10,%eax
  102831:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102833:	b8 10 00 00 00       	mov    $0x10,%eax
  102838:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  10283a:	ea 41 28 10 00 08 00 	ljmp   $0x8,$0x102841
}
  102841:	90                   	nop
  102842:	5d                   	pop    %ebp
  102843:	c3                   	ret    

00102844 <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102844:	55                   	push   %ebp
  102845:	89 e5                	mov    %esp,%ebp
  102847:	83 ec 14             	sub    $0x14,%esp
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  10284a:	b8 20 f9 10 00       	mov    $0x10f920,%eax
  10284f:	05 00 04 00 00       	add    $0x400,%eax
  102854:	a3 a4 f8 10 00       	mov    %eax,0x10f8a4
    ts.ts_ss0 = KERNEL_DS;
  102859:	66 c7 05 a8 f8 10 00 	movw   $0x10,0x10f8a8
  102860:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  102862:	66 c7 05 08 ea 10 00 	movw   $0x68,0x10ea08
  102869:	68 00 
  10286b:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  102870:	0f b7 c0             	movzwl %ax,%eax
  102873:	66 a3 0a ea 10 00    	mov    %ax,0x10ea0a
  102879:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  10287e:	c1 e8 10             	shr    $0x10,%eax
  102881:	a2 0c ea 10 00       	mov    %al,0x10ea0c
  102886:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  10288d:	24 f0                	and    $0xf0,%al
  10288f:	0c 09                	or     $0x9,%al
  102891:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  102896:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  10289d:	0c 10                	or     $0x10,%al
  10289f:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1028a4:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1028ab:	24 9f                	and    $0x9f,%al
  1028ad:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1028b2:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1028b9:	0c 80                	or     $0x80,%al
  1028bb:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1028c0:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1028c7:	24 f0                	and    $0xf0,%al
  1028c9:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  1028ce:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1028d5:	24 ef                	and    $0xef,%al
  1028d7:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  1028dc:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1028e3:	24 df                	and    $0xdf,%al
  1028e5:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  1028ea:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1028f1:	0c 40                	or     $0x40,%al
  1028f3:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  1028f8:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1028ff:	24 7f                	and    $0x7f,%al
  102901:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102906:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  10290b:	c1 e8 18             	shr    $0x18,%eax
  10290e:	a2 0f ea 10 00       	mov    %al,0x10ea0f
    gdt[SEG_TSS].sd_s = 0;
  102913:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  10291a:	24 ef                	and    $0xef,%al
  10291c:	a2 0d ea 10 00       	mov    %al,0x10ea0d

    // reload all segment registers
    lgdt(&gdt_pd);
  102921:	c7 04 24 10 ea 10 00 	movl   $0x10ea10,(%esp)
  102928:	e8 e1 fe ff ff       	call   10280e <lgdt>
  10292d:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  102933:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102937:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  10293a:	90                   	nop
  10293b:	c9                   	leave  
  10293c:	c3                   	ret    

0010293d <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  10293d:	55                   	push   %ebp
  10293e:	89 e5                	mov    %esp,%ebp
    gdt_init();
  102940:	e8 ff fe ff ff       	call   102844 <gdt_init>
}
  102945:	90                   	nop
  102946:	5d                   	pop    %ebp
  102947:	c3                   	ret    

00102948 <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  102948:	55                   	push   %ebp
  102949:	89 e5                	mov    %esp,%ebp
  10294b:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  10294e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  102955:	eb 03                	jmp    10295a <strlen+0x12>
        cnt ++;
  102957:	ff 45 fc             	incl   -0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  10295a:	8b 45 08             	mov    0x8(%ebp),%eax
  10295d:	8d 50 01             	lea    0x1(%eax),%edx
  102960:	89 55 08             	mov    %edx,0x8(%ebp)
  102963:	0f b6 00             	movzbl (%eax),%eax
  102966:	84 c0                	test   %al,%al
  102968:	75 ed                	jne    102957 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  10296a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10296d:	c9                   	leave  
  10296e:	c3                   	ret    

0010296f <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  10296f:	55                   	push   %ebp
  102970:	89 e5                	mov    %esp,%ebp
  102972:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102975:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  10297c:	eb 03                	jmp    102981 <strnlen+0x12>
        cnt ++;
  10297e:	ff 45 fc             	incl   -0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  102981:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102984:	3b 45 0c             	cmp    0xc(%ebp),%eax
  102987:	73 10                	jae    102999 <strnlen+0x2a>
  102989:	8b 45 08             	mov    0x8(%ebp),%eax
  10298c:	8d 50 01             	lea    0x1(%eax),%edx
  10298f:	89 55 08             	mov    %edx,0x8(%ebp)
  102992:	0f b6 00             	movzbl (%eax),%eax
  102995:	84 c0                	test   %al,%al
  102997:	75 e5                	jne    10297e <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  102999:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10299c:	c9                   	leave  
  10299d:	c3                   	ret    

0010299e <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  10299e:	55                   	push   %ebp
  10299f:	89 e5                	mov    %esp,%ebp
  1029a1:	57                   	push   %edi
  1029a2:	56                   	push   %esi
  1029a3:	83 ec 20             	sub    $0x20,%esp
  1029a6:	8b 45 08             	mov    0x8(%ebp),%eax
  1029a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1029ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  1029af:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  1029b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1029b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1029b8:	89 d1                	mov    %edx,%ecx
  1029ba:	89 c2                	mov    %eax,%edx
  1029bc:	89 ce                	mov    %ecx,%esi
  1029be:	89 d7                	mov    %edx,%edi
  1029c0:	ac                   	lods   %ds:(%esi),%al
  1029c1:	aa                   	stos   %al,%es:(%edi)
  1029c2:	84 c0                	test   %al,%al
  1029c4:	75 fa                	jne    1029c0 <strcpy+0x22>
  1029c6:	89 fa                	mov    %edi,%edx
  1029c8:	89 f1                	mov    %esi,%ecx
  1029ca:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1029cd:	89 55 e8             	mov    %edx,-0x18(%ebp)
  1029d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  1029d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  1029d6:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  1029d7:	83 c4 20             	add    $0x20,%esp
  1029da:	5e                   	pop    %esi
  1029db:	5f                   	pop    %edi
  1029dc:	5d                   	pop    %ebp
  1029dd:	c3                   	ret    

001029de <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  1029de:	55                   	push   %ebp
  1029df:	89 e5                	mov    %esp,%ebp
  1029e1:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  1029e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1029e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  1029ea:	eb 1e                	jmp    102a0a <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  1029ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  1029ef:	0f b6 10             	movzbl (%eax),%edx
  1029f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1029f5:	88 10                	mov    %dl,(%eax)
  1029f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1029fa:	0f b6 00             	movzbl (%eax),%eax
  1029fd:	84 c0                	test   %al,%al
  1029ff:	74 03                	je     102a04 <strncpy+0x26>
            src ++;
  102a01:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  102a04:	ff 45 fc             	incl   -0x4(%ebp)
  102a07:	ff 4d 10             	decl   0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  102a0a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102a0e:	75 dc                	jne    1029ec <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  102a10:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102a13:	c9                   	leave  
  102a14:	c3                   	ret    

00102a15 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  102a15:	55                   	push   %ebp
  102a16:	89 e5                	mov    %esp,%ebp
  102a18:	57                   	push   %edi
  102a19:	56                   	push   %esi
  102a1a:	83 ec 20             	sub    $0x20,%esp
  102a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  102a20:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  102a26:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  102a29:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102a2f:	89 d1                	mov    %edx,%ecx
  102a31:	89 c2                	mov    %eax,%edx
  102a33:	89 ce                	mov    %ecx,%esi
  102a35:	89 d7                	mov    %edx,%edi
  102a37:	ac                   	lods   %ds:(%esi),%al
  102a38:	ae                   	scas   %es:(%edi),%al
  102a39:	75 08                	jne    102a43 <strcmp+0x2e>
  102a3b:	84 c0                	test   %al,%al
  102a3d:	75 f8                	jne    102a37 <strcmp+0x22>
  102a3f:	31 c0                	xor    %eax,%eax
  102a41:	eb 04                	jmp    102a47 <strcmp+0x32>
  102a43:	19 c0                	sbb    %eax,%eax
  102a45:	0c 01                	or     $0x1,%al
  102a47:	89 fa                	mov    %edi,%edx
  102a49:	89 f1                	mov    %esi,%ecx
  102a4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102a4e:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102a51:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            "orb $1, %%al;"
            "3:"
            : "=a" (ret), "=&S" (d0), "=&D" (d1)
            : "1" (s1), "2" (s2)
            : "memory");
    return ret;
  102a54:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  102a57:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  102a58:	83 c4 20             	add    $0x20,%esp
  102a5b:	5e                   	pop    %esi
  102a5c:	5f                   	pop    %edi
  102a5d:	5d                   	pop    %ebp
  102a5e:	c3                   	ret    

00102a5f <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  102a5f:	55                   	push   %ebp
  102a60:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102a62:	eb 09                	jmp    102a6d <strncmp+0xe>
        n --, s1 ++, s2 ++;
  102a64:	ff 4d 10             	decl   0x10(%ebp)
  102a67:	ff 45 08             	incl   0x8(%ebp)
  102a6a:	ff 45 0c             	incl   0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102a6d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102a71:	74 1a                	je     102a8d <strncmp+0x2e>
  102a73:	8b 45 08             	mov    0x8(%ebp),%eax
  102a76:	0f b6 00             	movzbl (%eax),%eax
  102a79:	84 c0                	test   %al,%al
  102a7b:	74 10                	je     102a8d <strncmp+0x2e>
  102a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  102a80:	0f b6 10             	movzbl (%eax),%edx
  102a83:	8b 45 0c             	mov    0xc(%ebp),%eax
  102a86:	0f b6 00             	movzbl (%eax),%eax
  102a89:	38 c2                	cmp    %al,%dl
  102a8b:	74 d7                	je     102a64 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  102a8d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102a91:	74 18                	je     102aab <strncmp+0x4c>
  102a93:	8b 45 08             	mov    0x8(%ebp),%eax
  102a96:	0f b6 00             	movzbl (%eax),%eax
  102a99:	0f b6 d0             	movzbl %al,%edx
  102a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  102a9f:	0f b6 00             	movzbl (%eax),%eax
  102aa2:	0f b6 c0             	movzbl %al,%eax
  102aa5:	29 c2                	sub    %eax,%edx
  102aa7:	89 d0                	mov    %edx,%eax
  102aa9:	eb 05                	jmp    102ab0 <strncmp+0x51>
  102aab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102ab0:	5d                   	pop    %ebp
  102ab1:	c3                   	ret    

00102ab2 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  102ab2:	55                   	push   %ebp
  102ab3:	89 e5                	mov    %esp,%ebp
  102ab5:	83 ec 04             	sub    $0x4,%esp
  102ab8:	8b 45 0c             	mov    0xc(%ebp),%eax
  102abb:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102abe:	eb 13                	jmp    102ad3 <strchr+0x21>
        if (*s == c) {
  102ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  102ac3:	0f b6 00             	movzbl (%eax),%eax
  102ac6:	3a 45 fc             	cmp    -0x4(%ebp),%al
  102ac9:	75 05                	jne    102ad0 <strchr+0x1e>
            return (char *)s;
  102acb:	8b 45 08             	mov    0x8(%ebp),%eax
  102ace:	eb 12                	jmp    102ae2 <strchr+0x30>
        }
        s ++;
  102ad0:	ff 45 08             	incl   0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  102ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  102ad6:	0f b6 00             	movzbl (%eax),%eax
  102ad9:	84 c0                	test   %al,%al
  102adb:	75 e3                	jne    102ac0 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  102add:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102ae2:	c9                   	leave  
  102ae3:	c3                   	ret    

00102ae4 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  102ae4:	55                   	push   %ebp
  102ae5:	89 e5                	mov    %esp,%ebp
  102ae7:	83 ec 04             	sub    $0x4,%esp
  102aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  102aed:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102af0:	eb 0e                	jmp    102b00 <strfind+0x1c>
        if (*s == c) {
  102af2:	8b 45 08             	mov    0x8(%ebp),%eax
  102af5:	0f b6 00             	movzbl (%eax),%eax
  102af8:	3a 45 fc             	cmp    -0x4(%ebp),%al
  102afb:	74 0f                	je     102b0c <strfind+0x28>
            break;
        }
        s ++;
  102afd:	ff 45 08             	incl   0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  102b00:	8b 45 08             	mov    0x8(%ebp),%eax
  102b03:	0f b6 00             	movzbl (%eax),%eax
  102b06:	84 c0                	test   %al,%al
  102b08:	75 e8                	jne    102af2 <strfind+0xe>
  102b0a:	eb 01                	jmp    102b0d <strfind+0x29>
        if (*s == c) {
            break;
  102b0c:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
  102b0d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102b10:	c9                   	leave  
  102b11:	c3                   	ret    

00102b12 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  102b12:	55                   	push   %ebp
  102b13:	89 e5                	mov    %esp,%ebp
  102b15:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  102b18:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  102b1f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  102b26:	eb 03                	jmp    102b2b <strtol+0x19>
        s ++;
  102b28:	ff 45 08             	incl   0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  102b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  102b2e:	0f b6 00             	movzbl (%eax),%eax
  102b31:	3c 20                	cmp    $0x20,%al
  102b33:	74 f3                	je     102b28 <strtol+0x16>
  102b35:	8b 45 08             	mov    0x8(%ebp),%eax
  102b38:	0f b6 00             	movzbl (%eax),%eax
  102b3b:	3c 09                	cmp    $0x9,%al
  102b3d:	74 e9                	je     102b28 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  102b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  102b42:	0f b6 00             	movzbl (%eax),%eax
  102b45:	3c 2b                	cmp    $0x2b,%al
  102b47:	75 05                	jne    102b4e <strtol+0x3c>
        s ++;
  102b49:	ff 45 08             	incl   0x8(%ebp)
  102b4c:	eb 14                	jmp    102b62 <strtol+0x50>
    }
    else if (*s == '-') {
  102b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  102b51:	0f b6 00             	movzbl (%eax),%eax
  102b54:	3c 2d                	cmp    $0x2d,%al
  102b56:	75 0a                	jne    102b62 <strtol+0x50>
        s ++, neg = 1;
  102b58:	ff 45 08             	incl   0x8(%ebp)
  102b5b:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  102b62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102b66:	74 06                	je     102b6e <strtol+0x5c>
  102b68:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  102b6c:	75 22                	jne    102b90 <strtol+0x7e>
  102b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  102b71:	0f b6 00             	movzbl (%eax),%eax
  102b74:	3c 30                	cmp    $0x30,%al
  102b76:	75 18                	jne    102b90 <strtol+0x7e>
  102b78:	8b 45 08             	mov    0x8(%ebp),%eax
  102b7b:	40                   	inc    %eax
  102b7c:	0f b6 00             	movzbl (%eax),%eax
  102b7f:	3c 78                	cmp    $0x78,%al
  102b81:	75 0d                	jne    102b90 <strtol+0x7e>
        s += 2, base = 16;
  102b83:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  102b87:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  102b8e:	eb 29                	jmp    102bb9 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  102b90:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102b94:	75 16                	jne    102bac <strtol+0x9a>
  102b96:	8b 45 08             	mov    0x8(%ebp),%eax
  102b99:	0f b6 00             	movzbl (%eax),%eax
  102b9c:	3c 30                	cmp    $0x30,%al
  102b9e:	75 0c                	jne    102bac <strtol+0x9a>
        s ++, base = 8;
  102ba0:	ff 45 08             	incl   0x8(%ebp)
  102ba3:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  102baa:	eb 0d                	jmp    102bb9 <strtol+0xa7>
    }
    else if (base == 0) {
  102bac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102bb0:	75 07                	jne    102bb9 <strtol+0xa7>
        base = 10;
  102bb2:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  102bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  102bbc:	0f b6 00             	movzbl (%eax),%eax
  102bbf:	3c 2f                	cmp    $0x2f,%al
  102bc1:	7e 1b                	jle    102bde <strtol+0xcc>
  102bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  102bc6:	0f b6 00             	movzbl (%eax),%eax
  102bc9:	3c 39                	cmp    $0x39,%al
  102bcb:	7f 11                	jg     102bde <strtol+0xcc>
            dig = *s - '0';
  102bcd:	8b 45 08             	mov    0x8(%ebp),%eax
  102bd0:	0f b6 00             	movzbl (%eax),%eax
  102bd3:	0f be c0             	movsbl %al,%eax
  102bd6:	83 e8 30             	sub    $0x30,%eax
  102bd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102bdc:	eb 48                	jmp    102c26 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  102bde:	8b 45 08             	mov    0x8(%ebp),%eax
  102be1:	0f b6 00             	movzbl (%eax),%eax
  102be4:	3c 60                	cmp    $0x60,%al
  102be6:	7e 1b                	jle    102c03 <strtol+0xf1>
  102be8:	8b 45 08             	mov    0x8(%ebp),%eax
  102beb:	0f b6 00             	movzbl (%eax),%eax
  102bee:	3c 7a                	cmp    $0x7a,%al
  102bf0:	7f 11                	jg     102c03 <strtol+0xf1>
            dig = *s - 'a' + 10;
  102bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  102bf5:	0f b6 00             	movzbl (%eax),%eax
  102bf8:	0f be c0             	movsbl %al,%eax
  102bfb:	83 e8 57             	sub    $0x57,%eax
  102bfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102c01:	eb 23                	jmp    102c26 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  102c03:	8b 45 08             	mov    0x8(%ebp),%eax
  102c06:	0f b6 00             	movzbl (%eax),%eax
  102c09:	3c 40                	cmp    $0x40,%al
  102c0b:	7e 3b                	jle    102c48 <strtol+0x136>
  102c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  102c10:	0f b6 00             	movzbl (%eax),%eax
  102c13:	3c 5a                	cmp    $0x5a,%al
  102c15:	7f 31                	jg     102c48 <strtol+0x136>
            dig = *s - 'A' + 10;
  102c17:	8b 45 08             	mov    0x8(%ebp),%eax
  102c1a:	0f b6 00             	movzbl (%eax),%eax
  102c1d:	0f be c0             	movsbl %al,%eax
  102c20:	83 e8 37             	sub    $0x37,%eax
  102c23:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  102c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c29:	3b 45 10             	cmp    0x10(%ebp),%eax
  102c2c:	7d 19                	jge    102c47 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  102c2e:	ff 45 08             	incl   0x8(%ebp)
  102c31:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102c34:	0f af 45 10          	imul   0x10(%ebp),%eax
  102c38:	89 c2                	mov    %eax,%edx
  102c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c3d:	01 d0                	add    %edx,%eax
  102c3f:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  102c42:	e9 72 ff ff ff       	jmp    102bb9 <strtol+0xa7>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
  102c47:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
  102c48:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102c4c:	74 08                	je     102c56 <strtol+0x144>
        *endptr = (char *) s;
  102c4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c51:	8b 55 08             	mov    0x8(%ebp),%edx
  102c54:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  102c56:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  102c5a:	74 07                	je     102c63 <strtol+0x151>
  102c5c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102c5f:	f7 d8                	neg    %eax
  102c61:	eb 03                	jmp    102c66 <strtol+0x154>
  102c63:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  102c66:	c9                   	leave  
  102c67:	c3                   	ret    

00102c68 <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  102c68:	55                   	push   %ebp
  102c69:	89 e5                	mov    %esp,%ebp
  102c6b:	57                   	push   %edi
  102c6c:	83 ec 24             	sub    $0x24,%esp
  102c6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c72:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  102c75:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  102c79:	8b 55 08             	mov    0x8(%ebp),%edx
  102c7c:	89 55 f8             	mov    %edx,-0x8(%ebp)
  102c7f:	88 45 f7             	mov    %al,-0x9(%ebp)
  102c82:	8b 45 10             	mov    0x10(%ebp),%eax
  102c85:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  102c88:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  102c8b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  102c8f:	8b 55 f8             	mov    -0x8(%ebp),%edx
  102c92:	89 d7                	mov    %edx,%edi
  102c94:	f3 aa                	rep stos %al,%es:(%edi)
  102c96:	89 fa                	mov    %edi,%edx
  102c98:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  102c9b:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  102c9e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102ca1:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  102ca2:	83 c4 24             	add    $0x24,%esp
  102ca5:	5f                   	pop    %edi
  102ca6:	5d                   	pop    %ebp
  102ca7:	c3                   	ret    

00102ca8 <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  102ca8:	55                   	push   %ebp
  102ca9:	89 e5                	mov    %esp,%ebp
  102cab:	57                   	push   %edi
  102cac:	56                   	push   %esi
  102cad:	53                   	push   %ebx
  102cae:	83 ec 30             	sub    $0x30,%esp
  102cb1:	8b 45 08             	mov    0x8(%ebp),%eax
  102cb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102cb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  102cba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102cbd:	8b 45 10             	mov    0x10(%ebp),%eax
  102cc0:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  102cc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102cc6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  102cc9:	73 42                	jae    102d0d <memmove+0x65>
  102ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102cce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102cd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102cd4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102cd7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102cda:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  102cdd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102ce0:	c1 e8 02             	shr    $0x2,%eax
  102ce3:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  102ce5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102ce8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102ceb:	89 d7                	mov    %edx,%edi
  102ced:	89 c6                	mov    %eax,%esi
  102cef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  102cf1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  102cf4:	83 e1 03             	and    $0x3,%ecx
  102cf7:	74 02                	je     102cfb <memmove+0x53>
  102cf9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102cfb:	89 f0                	mov    %esi,%eax
  102cfd:	89 fa                	mov    %edi,%edx
  102cff:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  102d02:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102d05:	89 45 d0             	mov    %eax,-0x30(%ebp)
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
            : "memory");
    return dst;
  102d08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  102d0b:	eb 36                	jmp    102d43 <memmove+0x9b>
    asm volatile (
            "std;"
            "rep; movsb;"
            "cld;"
            : "=&c" (d0), "=&S" (d1), "=&D" (d2)
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  102d0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d10:	8d 50 ff             	lea    -0x1(%eax),%edx
  102d13:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102d16:	01 c2                	add    %eax,%edx
  102d18:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d1b:	8d 48 ff             	lea    -0x1(%eax),%ecx
  102d1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d21:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  102d24:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d27:	89 c1                	mov    %eax,%ecx
  102d29:	89 d8                	mov    %ebx,%eax
  102d2b:	89 d6                	mov    %edx,%esi
  102d2d:	89 c7                	mov    %eax,%edi
  102d2f:	fd                   	std    
  102d30:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102d32:	fc                   	cld    
  102d33:	89 f8                	mov    %edi,%eax
  102d35:	89 f2                	mov    %esi,%edx
  102d37:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  102d3a:	89 55 c8             	mov    %edx,-0x38(%ebp)
  102d3d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
            "rep; movsb;"
            "cld;"
            : "=&c" (d0), "=&S" (d1), "=&D" (d2)
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
            : "memory");
    return dst;
  102d40:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  102d43:	83 c4 30             	add    $0x30,%esp
  102d46:	5b                   	pop    %ebx
  102d47:	5e                   	pop    %esi
  102d48:	5f                   	pop    %edi
  102d49:	5d                   	pop    %ebp
  102d4a:	c3                   	ret    

00102d4b <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  102d4b:	55                   	push   %ebp
  102d4c:	89 e5                	mov    %esp,%ebp
  102d4e:	57                   	push   %edi
  102d4f:	56                   	push   %esi
  102d50:	83 ec 20             	sub    $0x20,%esp
  102d53:	8b 45 08             	mov    0x8(%ebp),%eax
  102d56:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102d59:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102d5f:	8b 45 10             	mov    0x10(%ebp),%eax
  102d62:	89 45 ec             	mov    %eax,-0x14(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  102d65:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102d68:	c1 e8 02             	shr    $0x2,%eax
  102d6b:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  102d6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102d73:	89 d7                	mov    %edx,%edi
  102d75:	89 c6                	mov    %eax,%esi
  102d77:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  102d79:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  102d7c:	83 e1 03             	and    $0x3,%ecx
  102d7f:	74 02                	je     102d83 <memcpy+0x38>
  102d81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102d83:	89 f0                	mov    %esi,%eax
  102d85:	89 fa                	mov    %edi,%edx
  102d87:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102d8a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  102d8d:	89 45 e0             	mov    %eax,-0x20(%ebp)
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
            : "memory");
    return dst;
  102d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  102d93:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  102d94:	83 c4 20             	add    $0x20,%esp
  102d97:	5e                   	pop    %esi
  102d98:	5f                   	pop    %edi
  102d99:	5d                   	pop    %ebp
  102d9a:	c3                   	ret    

00102d9b <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  102d9b:	55                   	push   %ebp
  102d9c:	89 e5                	mov    %esp,%ebp
  102d9e:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  102da1:	8b 45 08             	mov    0x8(%ebp),%eax
  102da4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  102da7:	8b 45 0c             	mov    0xc(%ebp),%eax
  102daa:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  102dad:	eb 2e                	jmp    102ddd <memcmp+0x42>
        if (*s1 != *s2) {
  102daf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102db2:	0f b6 10             	movzbl (%eax),%edx
  102db5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102db8:	0f b6 00             	movzbl (%eax),%eax
  102dbb:	38 c2                	cmp    %al,%dl
  102dbd:	74 18                	je     102dd7 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  102dbf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102dc2:	0f b6 00             	movzbl (%eax),%eax
  102dc5:	0f b6 d0             	movzbl %al,%edx
  102dc8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102dcb:	0f b6 00             	movzbl (%eax),%eax
  102dce:	0f b6 c0             	movzbl %al,%eax
  102dd1:	29 c2                	sub    %eax,%edx
  102dd3:	89 d0                	mov    %edx,%eax
  102dd5:	eb 18                	jmp    102def <memcmp+0x54>
        }
        s1 ++, s2 ++;
  102dd7:	ff 45 fc             	incl   -0x4(%ebp)
  102dda:	ff 45 f8             	incl   -0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  102ddd:	8b 45 10             	mov    0x10(%ebp),%eax
  102de0:	8d 50 ff             	lea    -0x1(%eax),%edx
  102de3:	89 55 10             	mov    %edx,0x10(%ebp)
  102de6:	85 c0                	test   %eax,%eax
  102de8:	75 c5                	jne    102daf <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  102dea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102def:	c9                   	leave  
  102df0:	c3                   	ret    

00102df1 <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  102df1:	55                   	push   %ebp
  102df2:	89 e5                	mov    %esp,%ebp
  102df4:	83 ec 58             	sub    $0x58,%esp
  102df7:	8b 45 10             	mov    0x10(%ebp),%eax
  102dfa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102dfd:	8b 45 14             	mov    0x14(%ebp),%eax
  102e00:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  102e03:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102e06:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102e09:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102e0c:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  102e0f:	8b 45 18             	mov    0x18(%ebp),%eax
  102e12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102e15:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102e18:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102e1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102e1e:	89 55 f0             	mov    %edx,-0x10(%ebp)
  102e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102e27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102e2b:	74 1c                	je     102e49 <printnum+0x58>
  102e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e30:	ba 00 00 00 00       	mov    $0x0,%edx
  102e35:	f7 75 e4             	divl   -0x1c(%ebp)
  102e38:	89 55 f4             	mov    %edx,-0xc(%ebp)
  102e3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e3e:	ba 00 00 00 00       	mov    $0x0,%edx
  102e43:	f7 75 e4             	divl   -0x1c(%ebp)
  102e46:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102e49:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102e4f:	f7 75 e4             	divl   -0x1c(%ebp)
  102e52:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102e55:	89 55 dc             	mov    %edx,-0x24(%ebp)
  102e58:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102e5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102e5e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102e61:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102e64:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102e67:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  102e6a:	8b 45 18             	mov    0x18(%ebp),%eax
  102e6d:	ba 00 00 00 00       	mov    $0x0,%edx
  102e72:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102e75:	77 56                	ja     102ecd <printnum+0xdc>
  102e77:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102e7a:	72 05                	jb     102e81 <printnum+0x90>
  102e7c:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102e7f:	77 4c                	ja     102ecd <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  102e81:	8b 45 1c             	mov    0x1c(%ebp),%eax
  102e84:	8d 50 ff             	lea    -0x1(%eax),%edx
  102e87:	8b 45 20             	mov    0x20(%ebp),%eax
  102e8a:	89 44 24 18          	mov    %eax,0x18(%esp)
  102e8e:	89 54 24 14          	mov    %edx,0x14(%esp)
  102e92:	8b 45 18             	mov    0x18(%ebp),%eax
  102e95:	89 44 24 10          	mov    %eax,0x10(%esp)
  102e99:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102e9c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102e9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  102ea3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
  102eaa:	89 44 24 04          	mov    %eax,0x4(%esp)
  102eae:	8b 45 08             	mov    0x8(%ebp),%eax
  102eb1:	89 04 24             	mov    %eax,(%esp)
  102eb4:	e8 38 ff ff ff       	call   102df1 <printnum>
  102eb9:	eb 1b                	jmp    102ed6 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  102ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ebe:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ec2:	8b 45 20             	mov    0x20(%ebp),%eax
  102ec5:	89 04 24             	mov    %eax,(%esp)
  102ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  102ecb:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  102ecd:	ff 4d 1c             	decl   0x1c(%ebp)
  102ed0:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  102ed4:	7f e5                	jg     102ebb <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  102ed6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102ed9:	05 10 3c 10 00       	add    $0x103c10,%eax
  102ede:	0f b6 00             	movzbl (%eax),%eax
  102ee1:	0f be c0             	movsbl %al,%eax
  102ee4:	8b 55 0c             	mov    0xc(%ebp),%edx
  102ee7:	89 54 24 04          	mov    %edx,0x4(%esp)
  102eeb:	89 04 24             	mov    %eax,(%esp)
  102eee:	8b 45 08             	mov    0x8(%ebp),%eax
  102ef1:	ff d0                	call   *%eax
}
  102ef3:	90                   	nop
  102ef4:	c9                   	leave  
  102ef5:	c3                   	ret    

00102ef6 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  102ef6:	55                   	push   %ebp
  102ef7:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102ef9:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102efd:	7e 14                	jle    102f13 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  102eff:	8b 45 08             	mov    0x8(%ebp),%eax
  102f02:	8b 00                	mov    (%eax),%eax
  102f04:	8d 48 08             	lea    0x8(%eax),%ecx
  102f07:	8b 55 08             	mov    0x8(%ebp),%edx
  102f0a:	89 0a                	mov    %ecx,(%edx)
  102f0c:	8b 50 04             	mov    0x4(%eax),%edx
  102f0f:	8b 00                	mov    (%eax),%eax
  102f11:	eb 30                	jmp    102f43 <getuint+0x4d>
    }
    else if (lflag) {
  102f13:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102f17:	74 16                	je     102f2f <getuint+0x39>
        return va_arg(*ap, unsigned long);
  102f19:	8b 45 08             	mov    0x8(%ebp),%eax
  102f1c:	8b 00                	mov    (%eax),%eax
  102f1e:	8d 48 04             	lea    0x4(%eax),%ecx
  102f21:	8b 55 08             	mov    0x8(%ebp),%edx
  102f24:	89 0a                	mov    %ecx,(%edx)
  102f26:	8b 00                	mov    (%eax),%eax
  102f28:	ba 00 00 00 00       	mov    $0x0,%edx
  102f2d:	eb 14                	jmp    102f43 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  102f2f:	8b 45 08             	mov    0x8(%ebp),%eax
  102f32:	8b 00                	mov    (%eax),%eax
  102f34:	8d 48 04             	lea    0x4(%eax),%ecx
  102f37:	8b 55 08             	mov    0x8(%ebp),%edx
  102f3a:	89 0a                	mov    %ecx,(%edx)
  102f3c:	8b 00                	mov    (%eax),%eax
  102f3e:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  102f43:	5d                   	pop    %ebp
  102f44:	c3                   	ret    

00102f45 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  102f45:	55                   	push   %ebp
  102f46:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102f48:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102f4c:	7e 14                	jle    102f62 <getint+0x1d>
        return va_arg(*ap, long long);
  102f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  102f51:	8b 00                	mov    (%eax),%eax
  102f53:	8d 48 08             	lea    0x8(%eax),%ecx
  102f56:	8b 55 08             	mov    0x8(%ebp),%edx
  102f59:	89 0a                	mov    %ecx,(%edx)
  102f5b:	8b 50 04             	mov    0x4(%eax),%edx
  102f5e:	8b 00                	mov    (%eax),%eax
  102f60:	eb 28                	jmp    102f8a <getint+0x45>
    }
    else if (lflag) {
  102f62:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102f66:	74 12                	je     102f7a <getint+0x35>
        return va_arg(*ap, long);
  102f68:	8b 45 08             	mov    0x8(%ebp),%eax
  102f6b:	8b 00                	mov    (%eax),%eax
  102f6d:	8d 48 04             	lea    0x4(%eax),%ecx
  102f70:	8b 55 08             	mov    0x8(%ebp),%edx
  102f73:	89 0a                	mov    %ecx,(%edx)
  102f75:	8b 00                	mov    (%eax),%eax
  102f77:	99                   	cltd   
  102f78:	eb 10                	jmp    102f8a <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  102f7a:	8b 45 08             	mov    0x8(%ebp),%eax
  102f7d:	8b 00                	mov    (%eax),%eax
  102f7f:	8d 48 04             	lea    0x4(%eax),%ecx
  102f82:	8b 55 08             	mov    0x8(%ebp),%edx
  102f85:	89 0a                	mov    %ecx,(%edx)
  102f87:	8b 00                	mov    (%eax),%eax
  102f89:	99                   	cltd   
    }
}
  102f8a:	5d                   	pop    %ebp
  102f8b:	c3                   	ret    

00102f8c <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  102f8c:	55                   	push   %ebp
  102f8d:	89 e5                	mov    %esp,%ebp
  102f8f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  102f92:	8d 45 14             	lea    0x14(%ebp),%eax
  102f95:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  102f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102f9f:	8b 45 10             	mov    0x10(%ebp),%eax
  102fa2:	89 44 24 08          	mov    %eax,0x8(%esp)
  102fa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fa9:	89 44 24 04          	mov    %eax,0x4(%esp)
  102fad:	8b 45 08             	mov    0x8(%ebp),%eax
  102fb0:	89 04 24             	mov    %eax,(%esp)
  102fb3:	e8 03 00 00 00       	call   102fbb <vprintfmt>
    va_end(ap);
}
  102fb8:	90                   	nop
  102fb9:	c9                   	leave  
  102fba:	c3                   	ret    

00102fbb <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  102fbb:	55                   	push   %ebp
  102fbc:	89 e5                	mov    %esp,%ebp
  102fbe:	56                   	push   %esi
  102fbf:	53                   	push   %ebx
  102fc0:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102fc3:	eb 17                	jmp    102fdc <vprintfmt+0x21>
            if (ch == '\0') {
  102fc5:	85 db                	test   %ebx,%ebx
  102fc7:	0f 84 bf 03 00 00    	je     10338c <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  102fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  102fd4:	89 1c 24             	mov    %ebx,(%esp)
  102fd7:	8b 45 08             	mov    0x8(%ebp),%eax
  102fda:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102fdc:	8b 45 10             	mov    0x10(%ebp),%eax
  102fdf:	8d 50 01             	lea    0x1(%eax),%edx
  102fe2:	89 55 10             	mov    %edx,0x10(%ebp)
  102fe5:	0f b6 00             	movzbl (%eax),%eax
  102fe8:	0f b6 d8             	movzbl %al,%ebx
  102feb:	83 fb 25             	cmp    $0x25,%ebx
  102fee:	75 d5                	jne    102fc5 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  102ff0:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  102ff4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  102ffb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102ffe:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  103001:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103008:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10300b:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  10300e:	8b 45 10             	mov    0x10(%ebp),%eax
  103011:	8d 50 01             	lea    0x1(%eax),%edx
  103014:	89 55 10             	mov    %edx,0x10(%ebp)
  103017:	0f b6 00             	movzbl (%eax),%eax
  10301a:	0f b6 d8             	movzbl %al,%ebx
  10301d:	8d 43 dd             	lea    -0x23(%ebx),%eax
  103020:	83 f8 55             	cmp    $0x55,%eax
  103023:	0f 87 37 03 00 00    	ja     103360 <vprintfmt+0x3a5>
  103029:	8b 04 85 34 3c 10 00 	mov    0x103c34(,%eax,4),%eax
  103030:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  103032:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  103036:	eb d6                	jmp    10300e <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  103038:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  10303c:	eb d0                	jmp    10300e <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  10303e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  103045:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103048:	89 d0                	mov    %edx,%eax
  10304a:	c1 e0 02             	shl    $0x2,%eax
  10304d:	01 d0                	add    %edx,%eax
  10304f:	01 c0                	add    %eax,%eax
  103051:	01 d8                	add    %ebx,%eax
  103053:	83 e8 30             	sub    $0x30,%eax
  103056:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  103059:	8b 45 10             	mov    0x10(%ebp),%eax
  10305c:	0f b6 00             	movzbl (%eax),%eax
  10305f:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  103062:	83 fb 2f             	cmp    $0x2f,%ebx
  103065:	7e 38                	jle    10309f <vprintfmt+0xe4>
  103067:	83 fb 39             	cmp    $0x39,%ebx
  10306a:	7f 33                	jg     10309f <vprintfmt+0xe4>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  10306c:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  10306f:	eb d4                	jmp    103045 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  103071:	8b 45 14             	mov    0x14(%ebp),%eax
  103074:	8d 50 04             	lea    0x4(%eax),%edx
  103077:	89 55 14             	mov    %edx,0x14(%ebp)
  10307a:	8b 00                	mov    (%eax),%eax
  10307c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  10307f:	eb 1f                	jmp    1030a0 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  103081:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103085:	79 87                	jns    10300e <vprintfmt+0x53>
                width = 0;
  103087:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  10308e:	e9 7b ff ff ff       	jmp    10300e <vprintfmt+0x53>

        case '#':
            altflag = 1;
  103093:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  10309a:	e9 6f ff ff ff       	jmp    10300e <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
  10309f:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
  1030a0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1030a4:	0f 89 64 ff ff ff    	jns    10300e <vprintfmt+0x53>
                width = precision, precision = -1;
  1030aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1030ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1030b0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  1030b7:	e9 52 ff ff ff       	jmp    10300e <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  1030bc:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  1030bf:	e9 4a ff ff ff       	jmp    10300e <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  1030c4:	8b 45 14             	mov    0x14(%ebp),%eax
  1030c7:	8d 50 04             	lea    0x4(%eax),%edx
  1030ca:	89 55 14             	mov    %edx,0x14(%ebp)
  1030cd:	8b 00                	mov    (%eax),%eax
  1030cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  1030d2:	89 54 24 04          	mov    %edx,0x4(%esp)
  1030d6:	89 04 24             	mov    %eax,(%esp)
  1030d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1030dc:	ff d0                	call   *%eax
            break;
  1030de:	e9 a4 02 00 00       	jmp    103387 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  1030e3:	8b 45 14             	mov    0x14(%ebp),%eax
  1030e6:	8d 50 04             	lea    0x4(%eax),%edx
  1030e9:	89 55 14             	mov    %edx,0x14(%ebp)
  1030ec:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  1030ee:	85 db                	test   %ebx,%ebx
  1030f0:	79 02                	jns    1030f4 <vprintfmt+0x139>
                err = -err;
  1030f2:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  1030f4:	83 fb 06             	cmp    $0x6,%ebx
  1030f7:	7f 0b                	jg     103104 <vprintfmt+0x149>
  1030f9:	8b 34 9d f4 3b 10 00 	mov    0x103bf4(,%ebx,4),%esi
  103100:	85 f6                	test   %esi,%esi
  103102:	75 23                	jne    103127 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  103104:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  103108:	c7 44 24 08 21 3c 10 	movl   $0x103c21,0x8(%esp)
  10310f:	00 
  103110:	8b 45 0c             	mov    0xc(%ebp),%eax
  103113:	89 44 24 04          	mov    %eax,0x4(%esp)
  103117:	8b 45 08             	mov    0x8(%ebp),%eax
  10311a:	89 04 24             	mov    %eax,(%esp)
  10311d:	e8 6a fe ff ff       	call   102f8c <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  103122:	e9 60 02 00 00       	jmp    103387 <vprintfmt+0x3cc>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  103127:	89 74 24 0c          	mov    %esi,0xc(%esp)
  10312b:	c7 44 24 08 2a 3c 10 	movl   $0x103c2a,0x8(%esp)
  103132:	00 
  103133:	8b 45 0c             	mov    0xc(%ebp),%eax
  103136:	89 44 24 04          	mov    %eax,0x4(%esp)
  10313a:	8b 45 08             	mov    0x8(%ebp),%eax
  10313d:	89 04 24             	mov    %eax,(%esp)
  103140:	e8 47 fe ff ff       	call   102f8c <printfmt>
            }
            break;
  103145:	e9 3d 02 00 00       	jmp    103387 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  10314a:	8b 45 14             	mov    0x14(%ebp),%eax
  10314d:	8d 50 04             	lea    0x4(%eax),%edx
  103150:	89 55 14             	mov    %edx,0x14(%ebp)
  103153:	8b 30                	mov    (%eax),%esi
  103155:	85 f6                	test   %esi,%esi
  103157:	75 05                	jne    10315e <vprintfmt+0x1a3>
                p = "(null)";
  103159:	be 2d 3c 10 00       	mov    $0x103c2d,%esi
            }
            if (width > 0 && padc != '-') {
  10315e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103162:	7e 76                	jle    1031da <vprintfmt+0x21f>
  103164:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  103168:	74 70                	je     1031da <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  10316a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10316d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103171:	89 34 24             	mov    %esi,(%esp)
  103174:	e8 f6 f7 ff ff       	call   10296f <strnlen>
  103179:	8b 55 e8             	mov    -0x18(%ebp),%edx
  10317c:	29 c2                	sub    %eax,%edx
  10317e:	89 d0                	mov    %edx,%eax
  103180:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103183:	eb 16                	jmp    10319b <vprintfmt+0x1e0>
                    putch(padc, putdat);
  103185:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  103189:	8b 55 0c             	mov    0xc(%ebp),%edx
  10318c:	89 54 24 04          	mov    %edx,0x4(%esp)
  103190:	89 04 24             	mov    %eax,(%esp)
  103193:	8b 45 08             	mov    0x8(%ebp),%eax
  103196:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  103198:	ff 4d e8             	decl   -0x18(%ebp)
  10319b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10319f:	7f e4                	jg     103185 <vprintfmt+0x1ca>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1031a1:	eb 37                	jmp    1031da <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  1031a3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1031a7:	74 1f                	je     1031c8 <vprintfmt+0x20d>
  1031a9:	83 fb 1f             	cmp    $0x1f,%ebx
  1031ac:	7e 05                	jle    1031b3 <vprintfmt+0x1f8>
  1031ae:	83 fb 7e             	cmp    $0x7e,%ebx
  1031b1:	7e 15                	jle    1031c8 <vprintfmt+0x20d>
                    putch('?', putdat);
  1031b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1031ba:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  1031c1:	8b 45 08             	mov    0x8(%ebp),%eax
  1031c4:	ff d0                	call   *%eax
  1031c6:	eb 0f                	jmp    1031d7 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  1031c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1031cf:	89 1c 24             	mov    %ebx,(%esp)
  1031d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1031d5:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1031d7:	ff 4d e8             	decl   -0x18(%ebp)
  1031da:	89 f0                	mov    %esi,%eax
  1031dc:	8d 70 01             	lea    0x1(%eax),%esi
  1031df:	0f b6 00             	movzbl (%eax),%eax
  1031e2:	0f be d8             	movsbl %al,%ebx
  1031e5:	85 db                	test   %ebx,%ebx
  1031e7:	74 27                	je     103210 <vprintfmt+0x255>
  1031e9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1031ed:	78 b4                	js     1031a3 <vprintfmt+0x1e8>
  1031ef:	ff 4d e4             	decl   -0x1c(%ebp)
  1031f2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1031f6:	79 ab                	jns    1031a3 <vprintfmt+0x1e8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  1031f8:	eb 16                	jmp    103210 <vprintfmt+0x255>
                putch(' ', putdat);
  1031fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  103201:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  103208:	8b 45 08             	mov    0x8(%ebp),%eax
  10320b:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  10320d:	ff 4d e8             	decl   -0x18(%ebp)
  103210:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103214:	7f e4                	jg     1031fa <vprintfmt+0x23f>
                putch(' ', putdat);
            }
            break;
  103216:	e9 6c 01 00 00       	jmp    103387 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  10321b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10321e:	89 44 24 04          	mov    %eax,0x4(%esp)
  103222:	8d 45 14             	lea    0x14(%ebp),%eax
  103225:	89 04 24             	mov    %eax,(%esp)
  103228:	e8 18 fd ff ff       	call   102f45 <getint>
  10322d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103230:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  103233:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103236:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103239:	85 d2                	test   %edx,%edx
  10323b:	79 26                	jns    103263 <vprintfmt+0x2a8>
                putch('-', putdat);
  10323d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103240:	89 44 24 04          	mov    %eax,0x4(%esp)
  103244:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  10324b:	8b 45 08             	mov    0x8(%ebp),%eax
  10324e:	ff d0                	call   *%eax
                num = -(long long)num;
  103250:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103253:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103256:	f7 d8                	neg    %eax
  103258:	83 d2 00             	adc    $0x0,%edx
  10325b:	f7 da                	neg    %edx
  10325d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103260:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  103263:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  10326a:	e9 a8 00 00 00       	jmp    103317 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  10326f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103272:	89 44 24 04          	mov    %eax,0x4(%esp)
  103276:	8d 45 14             	lea    0x14(%ebp),%eax
  103279:	89 04 24             	mov    %eax,(%esp)
  10327c:	e8 75 fc ff ff       	call   102ef6 <getuint>
  103281:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103284:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  103287:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  10328e:	e9 84 00 00 00       	jmp    103317 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  103293:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103296:	89 44 24 04          	mov    %eax,0x4(%esp)
  10329a:	8d 45 14             	lea    0x14(%ebp),%eax
  10329d:	89 04 24             	mov    %eax,(%esp)
  1032a0:	e8 51 fc ff ff       	call   102ef6 <getuint>
  1032a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1032a8:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  1032ab:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  1032b2:	eb 63                	jmp    103317 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  1032b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1032bb:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  1032c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1032c5:	ff d0                	call   *%eax
            putch('x', putdat);
  1032c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  1032ce:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  1032d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1032d8:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  1032da:	8b 45 14             	mov    0x14(%ebp),%eax
  1032dd:	8d 50 04             	lea    0x4(%eax),%edx
  1032e0:	89 55 14             	mov    %edx,0x14(%ebp)
  1032e3:	8b 00                	mov    (%eax),%eax
  1032e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1032e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  1032ef:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  1032f6:	eb 1f                	jmp    103317 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  1032f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1032fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1032ff:	8d 45 14             	lea    0x14(%ebp),%eax
  103302:	89 04 24             	mov    %eax,(%esp)
  103305:	e8 ec fb ff ff       	call   102ef6 <getuint>
  10330a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10330d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  103310:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  103317:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  10331b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10331e:	89 54 24 18          	mov    %edx,0x18(%esp)
  103322:	8b 55 e8             	mov    -0x18(%ebp),%edx
  103325:	89 54 24 14          	mov    %edx,0x14(%esp)
  103329:	89 44 24 10          	mov    %eax,0x10(%esp)
  10332d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103330:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103333:	89 44 24 08          	mov    %eax,0x8(%esp)
  103337:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10333b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10333e:	89 44 24 04          	mov    %eax,0x4(%esp)
  103342:	8b 45 08             	mov    0x8(%ebp),%eax
  103345:	89 04 24             	mov    %eax,(%esp)
  103348:	e8 a4 fa ff ff       	call   102df1 <printnum>
            break;
  10334d:	eb 38                	jmp    103387 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  10334f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103352:	89 44 24 04          	mov    %eax,0x4(%esp)
  103356:	89 1c 24             	mov    %ebx,(%esp)
  103359:	8b 45 08             	mov    0x8(%ebp),%eax
  10335c:	ff d0                	call   *%eax
            break;
  10335e:	eb 27                	jmp    103387 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  103360:	8b 45 0c             	mov    0xc(%ebp),%eax
  103363:	89 44 24 04          	mov    %eax,0x4(%esp)
  103367:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  10336e:	8b 45 08             	mov    0x8(%ebp),%eax
  103371:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  103373:	ff 4d 10             	decl   0x10(%ebp)
  103376:	eb 03                	jmp    10337b <vprintfmt+0x3c0>
  103378:	ff 4d 10             	decl   0x10(%ebp)
  10337b:	8b 45 10             	mov    0x10(%ebp),%eax
  10337e:	48                   	dec    %eax
  10337f:	0f b6 00             	movzbl (%eax),%eax
  103382:	3c 25                	cmp    $0x25,%al
  103384:	75 f2                	jne    103378 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  103386:	90                   	nop
        }
    }
  103387:	e9 37 fc ff ff       	jmp    102fc3 <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
  10338c:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  10338d:	83 c4 40             	add    $0x40,%esp
  103390:	5b                   	pop    %ebx
  103391:	5e                   	pop    %esi
  103392:	5d                   	pop    %ebp
  103393:	c3                   	ret    

00103394 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  103394:	55                   	push   %ebp
  103395:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  103397:	8b 45 0c             	mov    0xc(%ebp),%eax
  10339a:	8b 40 08             	mov    0x8(%eax),%eax
  10339d:	8d 50 01             	lea    0x1(%eax),%edx
  1033a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033a3:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  1033a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033a9:	8b 10                	mov    (%eax),%edx
  1033ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033ae:	8b 40 04             	mov    0x4(%eax),%eax
  1033b1:	39 c2                	cmp    %eax,%edx
  1033b3:	73 12                	jae    1033c7 <sprintputch+0x33>
        *b->buf ++ = ch;
  1033b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033b8:	8b 00                	mov    (%eax),%eax
  1033ba:	8d 48 01             	lea    0x1(%eax),%ecx
  1033bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  1033c0:	89 0a                	mov    %ecx,(%edx)
  1033c2:	8b 55 08             	mov    0x8(%ebp),%edx
  1033c5:	88 10                	mov    %dl,(%eax)
    }
}
  1033c7:	90                   	nop
  1033c8:	5d                   	pop    %ebp
  1033c9:	c3                   	ret    

001033ca <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  1033ca:	55                   	push   %ebp
  1033cb:	89 e5                	mov    %esp,%ebp
  1033cd:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  1033d0:	8d 45 14             	lea    0x14(%ebp),%eax
  1033d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  1033d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1033d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1033dd:	8b 45 10             	mov    0x10(%ebp),%eax
  1033e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1033e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033eb:	8b 45 08             	mov    0x8(%ebp),%eax
  1033ee:	89 04 24             	mov    %eax,(%esp)
  1033f1:	e8 08 00 00 00       	call   1033fe <vsnprintf>
  1033f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1033f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1033fc:	c9                   	leave  
  1033fd:	c3                   	ret    

001033fe <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  1033fe:	55                   	push   %ebp
  1033ff:	89 e5                	mov    %esp,%ebp
  103401:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  103404:	8b 45 08             	mov    0x8(%ebp),%eax
  103407:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10340a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10340d:	8d 50 ff             	lea    -0x1(%eax),%edx
  103410:	8b 45 08             	mov    0x8(%ebp),%eax
  103413:	01 d0                	add    %edx,%eax
  103415:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103418:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  10341f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103423:	74 0a                	je     10342f <vsnprintf+0x31>
  103425:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103428:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10342b:	39 c2                	cmp    %eax,%edx
  10342d:	76 07                	jbe    103436 <vsnprintf+0x38>
        return -E_INVAL;
  10342f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  103434:	eb 2a                	jmp    103460 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  103436:	8b 45 14             	mov    0x14(%ebp),%eax
  103439:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10343d:	8b 45 10             	mov    0x10(%ebp),%eax
  103440:	89 44 24 08          	mov    %eax,0x8(%esp)
  103444:	8d 45 ec             	lea    -0x14(%ebp),%eax
  103447:	89 44 24 04          	mov    %eax,0x4(%esp)
  10344b:	c7 04 24 94 33 10 00 	movl   $0x103394,(%esp)
  103452:	e8 64 fb ff ff       	call   102fbb <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  103457:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10345a:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  10345d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103460:	c9                   	leave  
  103461:	c3                   	ret    
