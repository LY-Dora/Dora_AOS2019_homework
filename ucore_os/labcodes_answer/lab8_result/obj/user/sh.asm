
obj/__user_sh.out：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800020:	55                   	push   %ebp
  800021:	89 e5                	mov    %esp,%ebp
  800023:	83 ec 18             	sub    $0x18,%esp
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  800026:	8d 45 14             	lea    0x14(%ebp),%eax
  800029:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  80002c:	83 ec 04             	sub    $0x4,%esp
  80002f:	ff 75 0c             	pushl  0xc(%ebp)
  800032:	ff 75 08             	pushl  0x8(%ebp)
  800035:	68 c0 1d 80 00       	push   $0x801dc0
  80003a:	e8 96 05 00 00       	call   8005d5 <cprintf>
  80003f:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
  800042:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800045:	83 ec 08             	sub    $0x8,%esp
  800048:	50                   	push   %eax
  800049:	ff 75 10             	pushl  0x10(%ebp)
  80004c:	e8 53 05 00 00       	call   8005a4 <vcprintf>
  800051:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	68 da 1d 80 00       	push   $0x801dda
  80005c:	e8 74 05 00 00       	call   8005d5 <cprintf>
  800061:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
    exit(-E_PANIC);
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	6a f6                	push   $0xfffffff6
  800069:	e8 28 08 00 00       	call   800896 <exit>

0080006e <__warn>:
}

void
__warn(const char *file, int line, const char *fmt, ...) {
  80006e:	55                   	push   %ebp
  80006f:	89 e5                	mov    %esp,%ebp
  800071:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    va_start(ap, fmt);
  800074:	8d 45 14             	lea    0x14(%ebp),%eax
  800077:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user warning at %s:%d:\n    ", file, line);
  80007a:	83 ec 04             	sub    $0x4,%esp
  80007d:	ff 75 0c             	pushl  0xc(%ebp)
  800080:	ff 75 08             	pushl  0x8(%ebp)
  800083:	68 dc 1d 80 00       	push   $0x801ddc
  800088:	e8 48 05 00 00       	call   8005d5 <cprintf>
  80008d:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
  800090:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800093:	83 ec 08             	sub    $0x8,%esp
  800096:	50                   	push   %eax
  800097:	ff 75 10             	pushl  0x10(%ebp)
  80009a:	e8 05 05 00 00       	call   8005a4 <vcprintf>
  80009f:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
  8000a2:	83 ec 0c             	sub    $0xc,%esp
  8000a5:	68 da 1d 80 00       	push   $0x801dda
  8000aa:	e8 26 05 00 00       	call   8005d5 <cprintf>
  8000af:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
  8000b2:	90                   	nop
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <syscall>:


#define MAX_ARGS            5

static inline int
syscall(int num, ...) {
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	57                   	push   %edi
  8000b9:	56                   	push   %esi
  8000ba:	53                   	push   %ebx
  8000bb:	83 ec 20             	sub    $0x20,%esp
    va_list ap;
    va_start(ap, num);
  8000be:	8d 45 0c             	lea    0xc(%ebp),%eax
  8000c1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
  8000c4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8000cb:	eb 16                	jmp    8000e3 <syscall+0x2e>
        a[i] = va_arg(ap, uint32_t);
  8000cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8000d0:	8d 50 04             	lea    0x4(%eax),%edx
  8000d3:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8000d6:	8b 10                	mov    (%eax),%edx
  8000d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000db:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
syscall(int num, ...) {
    va_list ap;
    va_start(ap, num);
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
  8000df:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  8000e3:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
  8000e7:	7e e4                	jle    8000cd <syscall+0x18>
    asm volatile (
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL),
          "a" (num),
          "d" (a[0]),
  8000e9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
          "c" (a[1]),
  8000ec:	8b 4d d8             	mov    -0x28(%ebp),%ecx
          "b" (a[2]),
  8000ef:	8b 5d dc             	mov    -0x24(%ebp),%ebx
          "D" (a[3]),
  8000f2:	8b 7d e0             	mov    -0x20(%ebp),%edi
          "S" (a[4])
  8000f5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint32_t);
    }
    va_end(ap);

    asm volatile (
  8000f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8000fb:	cd 80                	int    $0x80
  8000fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
          "c" (a[1]),
          "b" (a[2]),
          "D" (a[3]),
          "S" (a[4])
        : "cc", "memory");
    return ret;
  800100:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  800103:	83 c4 20             	add    $0x20,%esp
  800106:	5b                   	pop    %ebx
  800107:	5e                   	pop    %esi
  800108:	5f                   	pop    %edi
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <sys_exit>:

int
sys_exit(int error_code) {
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_exit, error_code);
  80010e:	ff 75 08             	pushl  0x8(%ebp)
  800111:	6a 01                	push   $0x1
  800113:	e8 9d ff ff ff       	call   8000b5 <syscall>
  800118:	83 c4 08             	add    $0x8,%esp
}
  80011b:	c9                   	leave  
  80011c:	c3                   	ret    

0080011d <sys_fork>:

int
sys_fork(void) {
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_fork);
  800120:	6a 02                	push   $0x2
  800122:	e8 8e ff ff ff       	call   8000b5 <syscall>
  800127:	83 c4 04             	add    $0x4,%esp
}
  80012a:	c9                   	leave  
  80012b:	c3                   	ret    

0080012c <sys_wait>:

int
sys_wait(int pid, int *store) {
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_wait, pid, store);
  80012f:	ff 75 0c             	pushl  0xc(%ebp)
  800132:	ff 75 08             	pushl  0x8(%ebp)
  800135:	6a 03                	push   $0x3
  800137:	e8 79 ff ff ff       	call   8000b5 <syscall>
  80013c:	83 c4 0c             	add    $0xc,%esp
}
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <sys_yield>:

int
sys_yield(void) {
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_yield);
  800144:	6a 0a                	push   $0xa
  800146:	e8 6a ff ff ff       	call   8000b5 <syscall>
  80014b:	83 c4 04             	add    $0x4,%esp
}
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <sys_kill>:

int
sys_kill(int pid) {
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_kill, pid);
  800153:	ff 75 08             	pushl  0x8(%ebp)
  800156:	6a 0c                	push   $0xc
  800158:	e8 58 ff ff ff       	call   8000b5 <syscall>
  80015d:	83 c4 08             	add    $0x8,%esp
}
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <sys_getpid>:

int
sys_getpid(void) {
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_getpid);
  800165:	6a 12                	push   $0x12
  800167:	e8 49 ff ff ff       	call   8000b5 <syscall>
  80016c:	83 c4 04             	add    $0x4,%esp
}
  80016f:	c9                   	leave  
  800170:	c3                   	ret    

00800171 <sys_putc>:

int
sys_putc(int c) {
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_putc, c);
  800174:	ff 75 08             	pushl  0x8(%ebp)
  800177:	6a 1e                	push   $0x1e
  800179:	e8 37 ff ff ff       	call   8000b5 <syscall>
  80017e:	83 c4 08             	add    $0x8,%esp
}
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <sys_pgdir>:

int
sys_pgdir(void) {
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_pgdir);
  800186:	6a 1f                	push   $0x1f
  800188:	e8 28 ff ff ff       	call   8000b5 <syscall>
  80018d:	83 c4 04             	add    $0x4,%esp
}
  800190:	c9                   	leave  
  800191:	c3                   	ret    

00800192 <sys_lab6_set_priority>:

void
sys_lab6_set_priority(uint32_t priority)
{
  800192:	55                   	push   %ebp
  800193:	89 e5                	mov    %esp,%ebp
    syscall(SYS_lab6_set_priority, priority);
  800195:	ff 75 08             	pushl  0x8(%ebp)
  800198:	68 ff 00 00 00       	push   $0xff
  80019d:	e8 13 ff ff ff       	call   8000b5 <syscall>
  8001a2:	83 c4 08             	add    $0x8,%esp
}
  8001a5:	90                   	nop
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <sys_sleep>:

int
sys_sleep(unsigned int time) {
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_sleep, time);
  8001ab:	ff 75 08             	pushl  0x8(%ebp)
  8001ae:	6a 0b                	push   $0xb
  8001b0:	e8 00 ff ff ff       	call   8000b5 <syscall>
  8001b5:	83 c4 08             	add    $0x8,%esp
}
  8001b8:	c9                   	leave  
  8001b9:	c3                   	ret    

008001ba <sys_gettime>:

size_t
sys_gettime(void) {
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_gettime);
  8001bd:	6a 11                	push   $0x11
  8001bf:	e8 f1 fe ff ff       	call   8000b5 <syscall>
  8001c4:	83 c4 04             	add    $0x4,%esp
}
  8001c7:	c9                   	leave  
  8001c8:	c3                   	ret    

008001c9 <sys_exec>:

int
sys_exec(const char *name, int argc, const char **argv) {
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_exec, name, argc, argv);
  8001cc:	ff 75 10             	pushl  0x10(%ebp)
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	ff 75 08             	pushl  0x8(%ebp)
  8001d5:	6a 04                	push   $0x4
  8001d7:	e8 d9 fe ff ff       	call   8000b5 <syscall>
  8001dc:	83 c4 10             	add    $0x10,%esp
}
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    

008001e1 <sys_open>:

int
sys_open(const char *path, uint32_t open_flags) {
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_open, path, open_flags);
  8001e4:	ff 75 0c             	pushl  0xc(%ebp)
  8001e7:	ff 75 08             	pushl  0x8(%ebp)
  8001ea:	6a 64                	push   $0x64
  8001ec:	e8 c4 fe ff ff       	call   8000b5 <syscall>
  8001f1:	83 c4 0c             	add    $0xc,%esp
}
  8001f4:	c9                   	leave  
  8001f5:	c3                   	ret    

008001f6 <sys_close>:

int
sys_close(int fd) {
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_close, fd);
  8001f9:	ff 75 08             	pushl  0x8(%ebp)
  8001fc:	6a 65                	push   $0x65
  8001fe:	e8 b2 fe ff ff       	call   8000b5 <syscall>
  800203:	83 c4 08             	add    $0x8,%esp
}
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <sys_read>:

int
sys_read(int fd, void *base, size_t len) {
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_read, fd, base, len);
  80020b:	ff 75 10             	pushl  0x10(%ebp)
  80020e:	ff 75 0c             	pushl  0xc(%ebp)
  800211:	ff 75 08             	pushl  0x8(%ebp)
  800214:	6a 66                	push   $0x66
  800216:	e8 9a fe ff ff       	call   8000b5 <syscall>
  80021b:	83 c4 10             	add    $0x10,%esp
}
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <sys_write>:

int
sys_write(int fd, void *base, size_t len) {
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_write, fd, base, len);
  800223:	ff 75 10             	pushl  0x10(%ebp)
  800226:	ff 75 0c             	pushl  0xc(%ebp)
  800229:	ff 75 08             	pushl  0x8(%ebp)
  80022c:	6a 67                	push   $0x67
  80022e:	e8 82 fe ff ff       	call   8000b5 <syscall>
  800233:	83 c4 10             	add    $0x10,%esp
}
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <sys_seek>:

int
sys_seek(int fd, off_t pos, int whence) {
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_seek, fd, pos, whence);
  80023b:	ff 75 10             	pushl  0x10(%ebp)
  80023e:	ff 75 0c             	pushl  0xc(%ebp)
  800241:	ff 75 08             	pushl  0x8(%ebp)
  800244:	6a 68                	push   $0x68
  800246:	e8 6a fe ff ff       	call   8000b5 <syscall>
  80024b:	83 c4 10             	add    $0x10,%esp
}
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <sys_fstat>:

int
sys_fstat(int fd, struct stat *stat) {
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_fstat, fd, stat);
  800253:	ff 75 0c             	pushl  0xc(%ebp)
  800256:	ff 75 08             	pushl  0x8(%ebp)
  800259:	6a 6e                	push   $0x6e
  80025b:	e8 55 fe ff ff       	call   8000b5 <syscall>
  800260:	83 c4 0c             	add    $0xc,%esp
}
  800263:	c9                   	leave  
  800264:	c3                   	ret    

00800265 <sys_fsync>:

int
sys_fsync(int fd) {
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_fsync, fd);
  800268:	ff 75 08             	pushl  0x8(%ebp)
  80026b:	6a 6f                	push   $0x6f
  80026d:	e8 43 fe ff ff       	call   8000b5 <syscall>
  800272:	83 c4 08             	add    $0x8,%esp
}
  800275:	c9                   	leave  
  800276:	c3                   	ret    

00800277 <sys_getcwd>:

int
sys_getcwd(char *buffer, size_t len) {
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_getcwd, buffer, len);
  80027a:	ff 75 0c             	pushl  0xc(%ebp)
  80027d:	ff 75 08             	pushl  0x8(%ebp)
  800280:	6a 79                	push   $0x79
  800282:	e8 2e fe ff ff       	call   8000b5 <syscall>
  800287:	83 c4 0c             	add    $0xc,%esp
}
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <sys_getdirentry>:

int
sys_getdirentry(int fd, struct dirent *dirent) {
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_getdirentry, fd, dirent);
  80028f:	ff 75 0c             	pushl  0xc(%ebp)
  800292:	ff 75 08             	pushl  0x8(%ebp)
  800295:	68 80 00 00 00       	push   $0x80
  80029a:	e8 16 fe ff ff       	call   8000b5 <syscall>
  80029f:	83 c4 0c             	add    $0xc,%esp
}
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <sys_dup>:

int
sys_dup(int fd1, int fd2) {
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
    return syscall(SYS_dup, fd1, fd2);
  8002a7:	ff 75 0c             	pushl  0xc(%ebp)
  8002aa:	ff 75 08             	pushl  0x8(%ebp)
  8002ad:	68 82 00 00 00       	push   $0x82
  8002b2:	e8 fe fd ff ff       	call   8000b5 <syscall>
  8002b7:	83 c4 0c             	add    $0xc,%esp
}
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <opendir>:
#include <error.h>
#include <unistd.h>

DIR dir, *dirp=&dir;
DIR *
opendir(const char *path) {
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	53                   	push   %ebx
  8002c0:	83 ec 24             	sub    $0x24,%esp

    if ((dirp->fd = open(path, O_RDONLY)) < 0) {
  8002c3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8002c9:	83 ec 08             	sub    $0x8,%esp
  8002cc:	6a 00                	push   $0x0
  8002ce:	ff 75 08             	pushl  0x8(%ebp)
  8002d1:	e8 d6 00 00 00       	call   8003ac <open>
  8002d6:	83 c4 10             	add    $0x10,%esp
  8002d9:	89 03                	mov    %eax,(%ebx)
  8002db:	8b 03                	mov    (%ebx),%eax
  8002dd:	85 c0                	test   %eax,%eax
  8002df:	78 44                	js     800325 <opendir+0x69>
        goto failed;
    }
    struct stat __stat, *stat = &__stat;
  8002e1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8002e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (fstat(dirp->fd, stat) != 0 || !S_ISDIR(stat->st_mode)) {
  8002e7:	a1 00 30 80 00       	mov    0x803000,%eax
  8002ec:	8b 00                	mov    (%eax),%eax
  8002ee:	83 ec 08             	sub    $0x8,%esp
  8002f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8002f4:	50                   	push   %eax
  8002f5:	e8 35 01 00 00       	call   80042f <fstat>
  8002fa:	83 c4 10             	add    $0x10,%esp
  8002fd:	85 c0                	test   %eax,%eax
  8002ff:	75 25                	jne    800326 <opendir+0x6a>
  800301:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800304:	8b 00                	mov    (%eax),%eax
  800306:	25 00 70 00 00       	and    $0x7000,%eax
  80030b:	3d 00 20 00 00       	cmp    $0x2000,%eax
  800310:	75 14                	jne    800326 <opendir+0x6a>
        goto failed;
    }
    dirp->dirent.offset = 0;
  800312:	a1 00 30 80 00       	mov    0x803000,%eax
  800317:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    return dirp;
  80031e:	a1 00 30 80 00       	mov    0x803000,%eax
  800323:	eb 06                	jmp    80032b <opendir+0x6f>
DIR dir, *dirp=&dir;
DIR *
opendir(const char *path) {

    if ((dirp->fd = open(path, O_RDONLY)) < 0) {
        goto failed;
  800325:	90                   	nop
    }
    dirp->dirent.offset = 0;
    return dirp;

failed:
    return NULL;
  800326:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80032b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80032e:	c9                   	leave  
  80032f:	c3                   	ret    

00800330 <readdir>:

struct dirent *
readdir(DIR *dirp) {
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	83 ec 08             	sub    $0x8,%esp
    if (sys_getdirentry(dirp->fd, &(dirp->dirent)) == 0) {
  800336:	8b 45 08             	mov    0x8(%ebp),%eax
  800339:	8d 50 04             	lea    0x4(%eax),%edx
  80033c:	8b 45 08             	mov    0x8(%ebp),%eax
  80033f:	8b 00                	mov    (%eax),%eax
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	52                   	push   %edx
  800345:	50                   	push   %eax
  800346:	e8 41 ff ff ff       	call   80028c <sys_getdirentry>
  80034b:	83 c4 10             	add    $0x10,%esp
  80034e:	85 c0                	test   %eax,%eax
  800350:	75 08                	jne    80035a <readdir+0x2a>
        return &(dirp->dirent);
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	83 c0 04             	add    $0x4,%eax
  800358:	eb 05                	jmp    80035f <readdir+0x2f>
    }
    return NULL;
  80035a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80035f:	c9                   	leave  
  800360:	c3                   	ret    

00800361 <closedir>:

void
closedir(DIR *dirp) {
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	83 ec 08             	sub    $0x8,%esp
    close(dirp->fd);
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	8b 00                	mov    (%eax),%eax
  80036c:	83 ec 0c             	sub    $0xc,%esp
  80036f:	50                   	push   %eax
  800370:	e8 50 00 00 00       	call   8003c5 <close>
  800375:	83 c4 10             	add    $0x10,%esp
}
  800378:	90                   	nop
  800379:	c9                   	leave  
  80037a:	c3                   	ret    

0080037b <getcwd>:

int
getcwd(char *buffer, size_t len) {
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	83 ec 08             	sub    $0x8,%esp
    return sys_getcwd(buffer, len);
  800381:	83 ec 08             	sub    $0x8,%esp
  800384:	ff 75 0c             	pushl  0xc(%ebp)
  800387:	ff 75 08             	pushl  0x8(%ebp)
  80038a:	e8 e8 fe ff ff       	call   800277 <sys_getcwd>
  80038f:	83 c4 10             	add    $0x10,%esp
}
  800392:	c9                   	leave  
  800393:	c3                   	ret    

00800394 <_start>:
.text
.globl _start
_start:
    # set ebp for backtrace
    movl $0x0, %ebp
  800394:	bd 00 00 00 00       	mov    $0x0,%ebp

    # load argc and argv
    movl (%esp), %ebx
  800399:	8b 1c 24             	mov    (%esp),%ebx
    lea 0x4(%esp), %ecx
  80039c:	8d 4c 24 04          	lea    0x4(%esp),%ecx


    # move down the esp register
    # since it may cause page fault in backtrace
    subl $0x20, %esp
  8003a0:	83 ec 20             	sub    $0x20,%esp

    # save argc and argv on stack
    pushl %ecx
  8003a3:	51                   	push   %ecx
    pushl %ebx
  8003a4:	53                   	push   %ebx

    # call user-program function
    call umain
  8003a5:	e8 89 03 00 00       	call   800733 <umain>
1:  jmp 1b
  8003aa:	eb fe                	jmp    8003aa <_start+0x16>

008003ac <open>:
#include <stat.h>
#include <error.h>
#include <unistd.h>

int
open(const char *path, uint32_t open_flags) {
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	83 ec 08             	sub    $0x8,%esp
    return sys_open(path, open_flags);
  8003b2:	83 ec 08             	sub    $0x8,%esp
  8003b5:	ff 75 0c             	pushl  0xc(%ebp)
  8003b8:	ff 75 08             	pushl  0x8(%ebp)
  8003bb:	e8 21 fe ff ff       	call   8001e1 <sys_open>
  8003c0:	83 c4 10             	add    $0x10,%esp
}
  8003c3:	c9                   	leave  
  8003c4:	c3                   	ret    

008003c5 <close>:

int
close(int fd) {
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	83 ec 08             	sub    $0x8,%esp
    return sys_close(fd);
  8003cb:	83 ec 0c             	sub    $0xc,%esp
  8003ce:	ff 75 08             	pushl  0x8(%ebp)
  8003d1:	e8 20 fe ff ff       	call   8001f6 <sys_close>
  8003d6:	83 c4 10             	add    $0x10,%esp
}
  8003d9:	c9                   	leave  
  8003da:	c3                   	ret    

008003db <read>:

int
read(int fd, void *base, size_t len) {
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	83 ec 08             	sub    $0x8,%esp
    return sys_read(fd, base, len);
  8003e1:	83 ec 04             	sub    $0x4,%esp
  8003e4:	ff 75 10             	pushl  0x10(%ebp)
  8003e7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ea:	ff 75 08             	pushl  0x8(%ebp)
  8003ed:	e8 16 fe ff ff       	call   800208 <sys_read>
  8003f2:	83 c4 10             	add    $0x10,%esp
}
  8003f5:	c9                   	leave  
  8003f6:	c3                   	ret    

008003f7 <write>:

int
write(int fd, void *base, size_t len) {
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
  8003fa:	83 ec 08             	sub    $0x8,%esp
    return sys_write(fd, base, len);
  8003fd:	83 ec 04             	sub    $0x4,%esp
  800400:	ff 75 10             	pushl  0x10(%ebp)
  800403:	ff 75 0c             	pushl  0xc(%ebp)
  800406:	ff 75 08             	pushl  0x8(%ebp)
  800409:	e8 12 fe ff ff       	call   800220 <sys_write>
  80040e:	83 c4 10             	add    $0x10,%esp
}
  800411:	c9                   	leave  
  800412:	c3                   	ret    

00800413 <seek>:

int
seek(int fd, off_t pos, int whence) {
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 08             	sub    $0x8,%esp
    return sys_seek(fd, pos, whence);
  800419:	83 ec 04             	sub    $0x4,%esp
  80041c:	ff 75 10             	pushl  0x10(%ebp)
  80041f:	ff 75 0c             	pushl  0xc(%ebp)
  800422:	ff 75 08             	pushl  0x8(%ebp)
  800425:	e8 0e fe ff ff       	call   800238 <sys_seek>
  80042a:	83 c4 10             	add    $0x10,%esp
}
  80042d:	c9                   	leave  
  80042e:	c3                   	ret    

0080042f <fstat>:

int
fstat(int fd, struct stat *stat) {
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	83 ec 08             	sub    $0x8,%esp
    return sys_fstat(fd, stat);
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	ff 75 0c             	pushl  0xc(%ebp)
  80043b:	ff 75 08             	pushl  0x8(%ebp)
  80043e:	e8 0d fe ff ff       	call   800250 <sys_fstat>
  800443:	83 c4 10             	add    $0x10,%esp
}
  800446:	c9                   	leave  
  800447:	c3                   	ret    

00800448 <fsync>:

int
fsync(int fd) {
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	83 ec 08             	sub    $0x8,%esp
    return sys_fsync(fd);
  80044e:	83 ec 0c             	sub    $0xc,%esp
  800451:	ff 75 08             	pushl  0x8(%ebp)
  800454:	e8 0c fe ff ff       	call   800265 <sys_fsync>
  800459:	83 c4 10             	add    $0x10,%esp
}
  80045c:	c9                   	leave  
  80045d:	c3                   	ret    

0080045e <dup2>:

int
dup2(int fd1, int fd2) {
  80045e:	55                   	push   %ebp
  80045f:	89 e5                	mov    %esp,%ebp
  800461:	83 ec 08             	sub    $0x8,%esp
    return sys_dup(fd1, fd2);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	ff 75 0c             	pushl  0xc(%ebp)
  80046a:	ff 75 08             	pushl  0x8(%ebp)
  80046d:	e8 32 fe ff ff       	call   8002a4 <sys_dup>
  800472:	83 c4 10             	add    $0x10,%esp
}
  800475:	c9                   	leave  
  800476:	c3                   	ret    

00800477 <transmode>:

static char
transmode(struct stat *stat) {
  800477:	55                   	push   %ebp
  800478:	89 e5                	mov    %esp,%ebp
  80047a:	83 ec 10             	sub    $0x10,%esp
    uint32_t mode = stat->st_mode;
  80047d:	8b 45 08             	mov    0x8(%ebp),%eax
  800480:	8b 00                	mov    (%eax),%eax
  800482:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (S_ISREG(mode)) return 'r';
  800485:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800488:	25 00 70 00 00       	and    $0x7000,%eax
  80048d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800492:	75 07                	jne    80049b <transmode+0x24>
  800494:	b8 72 00 00 00       	mov    $0x72,%eax
  800499:	eb 5d                	jmp    8004f8 <transmode+0x81>
    if (S_ISDIR(mode)) return 'd';
  80049b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80049e:	25 00 70 00 00       	and    $0x7000,%eax
  8004a3:	3d 00 20 00 00       	cmp    $0x2000,%eax
  8004a8:	75 07                	jne    8004b1 <transmode+0x3a>
  8004aa:	b8 64 00 00 00       	mov    $0x64,%eax
  8004af:	eb 47                	jmp    8004f8 <transmode+0x81>
    if (S_ISLNK(mode)) return 'l';
  8004b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8004b4:	25 00 70 00 00       	and    $0x7000,%eax
  8004b9:	3d 00 30 00 00       	cmp    $0x3000,%eax
  8004be:	75 07                	jne    8004c7 <transmode+0x50>
  8004c0:	b8 6c 00 00 00       	mov    $0x6c,%eax
  8004c5:	eb 31                	jmp    8004f8 <transmode+0x81>
    if (S_ISCHR(mode)) return 'c';
  8004c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8004ca:	25 00 70 00 00       	and    $0x7000,%eax
  8004cf:	3d 00 40 00 00       	cmp    $0x4000,%eax
  8004d4:	75 07                	jne    8004dd <transmode+0x66>
  8004d6:	b8 63 00 00 00       	mov    $0x63,%eax
  8004db:	eb 1b                	jmp    8004f8 <transmode+0x81>
    if (S_ISBLK(mode)) return 'b';
  8004dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8004e0:	25 00 70 00 00       	and    $0x7000,%eax
  8004e5:	3d 00 50 00 00       	cmp    $0x5000,%eax
  8004ea:	75 07                	jne    8004f3 <transmode+0x7c>
  8004ec:	b8 62 00 00 00       	mov    $0x62,%eax
  8004f1:	eb 05                	jmp    8004f8 <transmode+0x81>
    return '-';
  8004f3:	b8 2d 00 00 00       	mov    $0x2d,%eax
}
  8004f8:	c9                   	leave  
  8004f9:	c3                   	ret    

008004fa <print_stat>:

void
print_stat(const char *name, int fd, struct stat *stat) {
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	83 ec 08             	sub    $0x8,%esp
    cprintf("[%03d] %s\n", fd, name);
  800500:	83 ec 04             	sub    $0x4,%esp
  800503:	ff 75 08             	pushl  0x8(%ebp)
  800506:	ff 75 0c             	pushl  0xc(%ebp)
  800509:	68 f8 1d 80 00       	push   $0x801df8
  80050e:	e8 c2 00 00 00       	call   8005d5 <cprintf>
  800513:	83 c4 10             	add    $0x10,%esp
    cprintf("    mode    : %c\n", transmode(stat));
  800516:	83 ec 0c             	sub    $0xc,%esp
  800519:	ff 75 10             	pushl  0x10(%ebp)
  80051c:	e8 56 ff ff ff       	call   800477 <transmode>
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	0f be c0             	movsbl %al,%eax
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	50                   	push   %eax
  80052b:	68 03 1e 80 00       	push   $0x801e03
  800530:	e8 a0 00 00 00       	call   8005d5 <cprintf>
  800535:	83 c4 10             	add    $0x10,%esp
    cprintf("    links   : %lu\n", stat->st_nlinks);
  800538:	8b 45 10             	mov    0x10(%ebp),%eax
  80053b:	8b 40 04             	mov    0x4(%eax),%eax
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	50                   	push   %eax
  800542:	68 15 1e 80 00       	push   $0x801e15
  800547:	e8 89 00 00 00       	call   8005d5 <cprintf>
  80054c:	83 c4 10             	add    $0x10,%esp
    cprintf("    blocks  : %lu\n", stat->st_blocks);
  80054f:	8b 45 10             	mov    0x10(%ebp),%eax
  800552:	8b 40 08             	mov    0x8(%eax),%eax
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	50                   	push   %eax
  800559:	68 28 1e 80 00       	push   $0x801e28
  80055e:	e8 72 00 00 00       	call   8005d5 <cprintf>
  800563:	83 c4 10             	add    $0x10,%esp
    cprintf("    size    : %lu\n", stat->st_size);
  800566:	8b 45 10             	mov    0x10(%ebp),%eax
  800569:	8b 40 0c             	mov    0xc(%eax),%eax
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	50                   	push   %eax
  800570:	68 3b 1e 80 00       	push   $0x801e3b
  800575:	e8 5b 00 00 00       	call   8005d5 <cprintf>
  80057a:	83 c4 10             	add    $0x10,%esp
}
  80057d:	90                   	nop
  80057e:	c9                   	leave  
  80057f:	c3                   	ret    

00800580 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800580:	55                   	push   %ebp
  800581:	89 e5                	mov    %esp,%ebp
  800583:	83 ec 08             	sub    $0x8,%esp
    sys_putc(c);
  800586:	83 ec 0c             	sub    $0xc,%esp
  800589:	ff 75 08             	pushl  0x8(%ebp)
  80058c:	e8 e0 fb ff ff       	call   800171 <sys_putc>
  800591:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
  800594:	8b 45 0c             	mov    0xc(%ebp),%eax
  800597:	8b 00                	mov    (%eax),%eax
  800599:	8d 50 01             	lea    0x1(%eax),%edx
  80059c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059f:	89 10                	mov    %edx,(%eax)
}
  8005a1:	90                   	nop
  8005a2:	c9                   	leave  
  8005a3:	c3                   	ret    

008005a4 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8005a4:	55                   	push   %ebp
  8005a5:	89 e5                	mov    %esp,%ebp
  8005a7:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
  8005aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, NO_FD, &cnt, fmt, ap);
  8005b1:	83 ec 0c             	sub    $0xc,%esp
  8005b4:	ff 75 0c             	pushl  0xc(%ebp)
  8005b7:	ff 75 08             	pushl  0x8(%ebp)
  8005ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005bd:	50                   	push   %eax
  8005be:	68 d9 6a ff ff       	push   $0xffff6ad9
  8005c3:	68 80 05 80 00       	push   $0x800580
  8005c8:	e8 7f 0a 00 00       	call   80104c <vprintfmt>
  8005cd:	83 c4 20             	add    $0x20,%esp
    return cnt;
  8005d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005d3:	c9                   	leave  
  8005d4:	c3                   	ret    

008005d5 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
  8005db:	8d 45 0c             	lea    0xc(%ebp),%eax
  8005de:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int cnt = vcprintf(fmt, ap);
  8005e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	50                   	push   %eax
  8005e8:	ff 75 08             	pushl  0x8(%ebp)
  8005eb:	e8 b4 ff ff ff       	call   8005a4 <vcprintf>
  8005f0:	83 c4 10             	add    $0x10,%esp
  8005f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);

    return cnt;
  8005f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005f9:	c9                   	leave  
  8005fa:	c3                   	ret    

008005fb <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  8005fb:	55                   	push   %ebp
  8005fc:	89 e5                	mov    %esp,%ebp
  8005fe:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
  800601:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  800608:	eb 14                	jmp    80061e <cputs+0x23>
        cputch(c, &cnt);
  80060a:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	8d 55 f0             	lea    -0x10(%ebp),%edx
  800614:	52                   	push   %edx
  800615:	50                   	push   %eax
  800616:	e8 65 ff ff ff       	call   800580 <cputch>
  80061b:	83 c4 10             	add    $0x10,%esp
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  80061e:	8b 45 08             	mov    0x8(%ebp),%eax
  800621:	8d 50 01             	lea    0x1(%eax),%edx
  800624:	89 55 08             	mov    %edx,0x8(%ebp)
  800627:	0f b6 00             	movzbl (%eax),%eax
  80062a:	88 45 f7             	mov    %al,-0x9(%ebp)
  80062d:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  800631:	75 d7                	jne    80060a <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800639:	50                   	push   %eax
  80063a:	6a 0a                	push   $0xa
  80063c:	e8 3f ff ff ff       	call   800580 <cputch>
  800641:	83 c4 10             	add    $0x10,%esp
    return cnt;
  800644:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800647:	c9                   	leave  
  800648:	c3                   	ret    

00800649 <fputch>:


static void
fputch(char c, int *cnt, int fd) {
  800649:	55                   	push   %ebp
  80064a:	89 e5                	mov    %esp,%ebp
  80064c:	83 ec 18             	sub    $0x18,%esp
  80064f:	8b 45 08             	mov    0x8(%ebp),%eax
  800652:	88 45 f4             	mov    %al,-0xc(%ebp)
    write(fd, &c, sizeof(char));
  800655:	83 ec 04             	sub    $0x4,%esp
  800658:	6a 01                	push   $0x1
  80065a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065d:	50                   	push   %eax
  80065e:	ff 75 10             	pushl  0x10(%ebp)
  800661:	e8 91 fd ff ff       	call   8003f7 <write>
  800666:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
  800669:	8b 45 0c             	mov    0xc(%ebp),%eax
  80066c:	8b 00                	mov    (%eax),%eax
  80066e:	8d 50 01             	lea    0x1(%eax),%edx
  800671:	8b 45 0c             	mov    0xc(%ebp),%eax
  800674:	89 10                	mov    %edx,(%eax)
}
  800676:	90                   	nop
  800677:	c9                   	leave  
  800678:	c3                   	ret    

00800679 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap) {
  800679:	55                   	push   %ebp
  80067a:	89 e5                	mov    %esp,%ebp
  80067c:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
  80067f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)fputch, fd, &cnt, fmt, ap);
  800686:	83 ec 0c             	sub    $0xc,%esp
  800689:	ff 75 10             	pushl  0x10(%ebp)
  80068c:	ff 75 0c             	pushl  0xc(%ebp)
  80068f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800692:	50                   	push   %eax
  800693:	ff 75 08             	pushl  0x8(%ebp)
  800696:	68 49 06 80 00       	push   $0x800649
  80069b:	e8 ac 09 00 00       	call   80104c <vprintfmt>
  8006a0:	83 c4 20             	add    $0x20,%esp
    return cnt;
  8006a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8006a6:	c9                   	leave  
  8006a7:	c3                   	ret    

008006a8 <fprintf>:

int
fprintf(int fd, const char *fmt, ...) {
  8006a8:	55                   	push   %ebp
  8006a9:	89 e5                	mov    %esp,%ebp
  8006ab:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
  8006ae:	8d 45 10             	lea    0x10(%ebp),%eax
  8006b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int cnt = vfprintf(fd, fmt, ap);
  8006b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006b7:	83 ec 04             	sub    $0x4,%esp
  8006ba:	50                   	push   %eax
  8006bb:	ff 75 0c             	pushl  0xc(%ebp)
  8006be:	ff 75 08             	pushl  0x8(%ebp)
  8006c1:	e8 b3 ff ff ff       	call   800679 <vfprintf>
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);

    return cnt;
  8006cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8006cf:	c9                   	leave  
  8006d0:	c3                   	ret    

008006d1 <initfd>:
#include <stat.h>

int main(int argc, char *argv[]);

static int
initfd(int fd2, const char *path, uint32_t open_flags) {
  8006d1:	55                   	push   %ebp
  8006d2:	89 e5                	mov    %esp,%ebp
  8006d4:	83 ec 18             	sub    $0x18,%esp
    int fd1, ret;
    if ((fd1 = open(path, open_flags)) < 0) {
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	ff 75 10             	pushl  0x10(%ebp)
  8006dd:	ff 75 0c             	pushl  0xc(%ebp)
  8006e0:	e8 c7 fc ff ff       	call   8003ac <open>
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8006ef:	79 05                	jns    8006f6 <initfd+0x25>
        return fd1;
  8006f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006f4:	eb 3b                	jmp    800731 <initfd+0x60>
    }
    if (fd1 != fd2) {
  8006f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006f9:	3b 45 08             	cmp    0x8(%ebp),%eax
  8006fc:	74 30                	je     80072e <initfd+0x5d>
        close(fd2);
  8006fe:	83 ec 0c             	sub    $0xc,%esp
  800701:	ff 75 08             	pushl  0x8(%ebp)
  800704:	e8 bc fc ff ff       	call   8003c5 <close>
  800709:	83 c4 10             	add    $0x10,%esp
        ret = dup2(fd1, fd2);
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	ff 75 08             	pushl  0x8(%ebp)
  800712:	ff 75 f0             	pushl  -0x10(%ebp)
  800715:	e8 44 fd ff ff       	call   80045e <dup2>
  80071a:	83 c4 10             	add    $0x10,%esp
  80071d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        close(fd1);
  800720:	83 ec 0c             	sub    $0xc,%esp
  800723:	ff 75 f0             	pushl  -0x10(%ebp)
  800726:	e8 9a fc ff ff       	call   8003c5 <close>
  80072b:	83 c4 10             	add    $0x10,%esp
    }
    return ret;
  80072e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800731:	c9                   	leave  
  800732:	c3                   	ret    

00800733 <umain>:

void
umain(int argc, char *argv[]) {
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	83 ec 18             	sub    $0x18,%esp
    int fd;
    if ((fd = initfd(0, "stdin:", O_RDONLY)) < 0) {
  800739:	83 ec 04             	sub    $0x4,%esp
  80073c:	6a 00                	push   $0x0
  80073e:	68 4e 1e 80 00       	push   $0x801e4e
  800743:	6a 00                	push   $0x0
  800745:	e8 87 ff ff ff       	call   8006d1 <initfd>
  80074a:	83 c4 10             	add    $0x10,%esp
  80074d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800750:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800754:	79 17                	jns    80076d <umain+0x3a>
        warn("open <stdin> failed: %e.\n", fd);
  800756:	ff 75 f4             	pushl  -0xc(%ebp)
  800759:	68 55 1e 80 00       	push   $0x801e55
  80075e:	6a 1a                	push   $0x1a
  800760:	68 6f 1e 80 00       	push   $0x801e6f
  800765:	e8 04 f9 ff ff       	call   80006e <__warn>
  80076a:	83 c4 10             	add    $0x10,%esp
    }
    if ((fd = initfd(1, "stdout:", O_WRONLY)) < 0) {
  80076d:	83 ec 04             	sub    $0x4,%esp
  800770:	6a 01                	push   $0x1
  800772:	68 81 1e 80 00       	push   $0x801e81
  800777:	6a 01                	push   $0x1
  800779:	e8 53 ff ff ff       	call   8006d1 <initfd>
  80077e:	83 c4 10             	add    $0x10,%esp
  800781:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800784:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800788:	79 17                	jns    8007a1 <umain+0x6e>
        warn("open <stdout> failed: %e.\n", fd);
  80078a:	ff 75 f4             	pushl  -0xc(%ebp)
  80078d:	68 89 1e 80 00       	push   $0x801e89
  800792:	6a 1d                	push   $0x1d
  800794:	68 6f 1e 80 00       	push   $0x801e6f
  800799:	e8 d0 f8 ff ff       	call   80006e <__warn>
  80079e:	83 c4 10             	add    $0x10,%esp
    }
    int ret = main(argc, argv);
  8007a1:	83 ec 08             	sub    $0x8,%esp
  8007a4:	ff 75 0c             	pushl  0xc(%ebp)
  8007a7:	ff 75 08             	pushl  0x8(%ebp)
  8007aa:	e8 b9 14 00 00       	call   801c68 <main>
  8007af:	83 c4 10             	add    $0x10,%esp
  8007b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    exit(ret);
  8007b5:	83 ec 0c             	sub    $0xc,%esp
  8007b8:	ff 75 f0             	pushl  -0x10(%ebp)
  8007bb:	e8 d6 00 00 00       	call   800896 <exit>

008007c0 <try_lock>:
lock_init(lock_t *l) {
    *l = 0;
}

static inline bool
try_lock(lock_t *l) {
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	83 ec 10             	sub    $0x10,%esp
  8007c6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8007cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d0:	89 45 f8             	mov    %eax,-0x8(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_and_set_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btsl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
  8007d3:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8007d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d9:	0f ab 02             	bts    %eax,(%edx)
  8007dc:	19 c0                	sbb    %eax,%eax
  8007de:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return oldbit != 0;
  8007e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8007e5:	0f 95 c0             	setne  %al
  8007e8:	0f b6 c0             	movzbl %al,%eax
    return test_and_set_bit(0, l);
  8007eb:	90                   	nop
}
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <lock>:

static inline void
lock(lock_t *l) {
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	83 ec 18             	sub    $0x18,%esp
    if (try_lock(l)) {
  8007f4:	ff 75 08             	pushl  0x8(%ebp)
  8007f7:	e8 c4 ff ff ff       	call   8007c0 <try_lock>
  8007fc:	83 c4 04             	add    $0x4,%esp
  8007ff:	85 c0                	test   %eax,%eax
  800801:	74 3c                	je     80083f <lock+0x51>
        int step = 0;
  800803:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
        do {
            yield();
  80080a:	e8 ea 00 00 00       	call   8008f9 <yield>
            if (++ step == 100) {
  80080f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  800813:	83 7d f4 64          	cmpl   $0x64,-0xc(%ebp)
  800817:	75 14                	jne    80082d <lock+0x3f>
                step = 0;
  800819:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
                sleep(10);
  800820:	83 ec 0c             	sub    $0xc,%esp
  800823:	6a 0a                	push   $0xa
  800825:	e8 25 01 00 00       	call   80094f <sleep>
  80082a:	83 c4 10             	add    $0x10,%esp
            }
        } while (try_lock(l));
  80082d:	83 ec 0c             	sub    $0xc,%esp
  800830:	ff 75 08             	pushl  0x8(%ebp)
  800833:	e8 88 ff ff ff       	call   8007c0 <try_lock>
  800838:	83 c4 10             	add    $0x10,%esp
  80083b:	85 c0                	test   %eax,%eax
  80083d:	75 cb                	jne    80080a <lock+0x1c>
    }
}
  80083f:	90                   	nop
  800840:	c9                   	leave  
  800841:	c3                   	ret    

00800842 <unlock>:

static inline void
unlock(lock_t *l) {
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	83 ec 10             	sub    $0x10,%esp
  800848:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80084f:	8b 45 08             	mov    0x8(%ebp),%eax
  800852:	89 45 f8             	mov    %eax,-0x8(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_and_clear_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btrl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
  800855:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800858:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80085b:	0f b3 02             	btr    %eax,(%edx)
  80085e:	19 c0                	sbb    %eax,%eax
  800860:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return oldbit != 0;
  800863:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    test_and_clear_bit(0, l);
}
  800867:	90                   	nop
  800868:	c9                   	leave  
  800869:	c3                   	ret    

0080086a <lock_fork>:
#include <lock.h>

static lock_t fork_lock = INIT_LOCK;

void
lock_fork(void) {
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	83 ec 08             	sub    $0x8,%esp
    lock(&fork_lock);
  800870:	83 ec 0c             	sub    $0xc,%esp
  800873:	68 20 30 80 00       	push   $0x803020
  800878:	e8 71 ff ff ff       	call   8007ee <lock>
  80087d:	83 c4 10             	add    $0x10,%esp
}
  800880:	90                   	nop
  800881:	c9                   	leave  
  800882:	c3                   	ret    

00800883 <unlock_fork>:

void
unlock_fork(void) {
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
    unlock(&fork_lock);
  800886:	68 20 30 80 00       	push   $0x803020
  80088b:	e8 b2 ff ff ff       	call   800842 <unlock>
  800890:	83 c4 04             	add    $0x4,%esp
}
  800893:	90                   	nop
  800894:	c9                   	leave  
  800895:	c3                   	ret    

00800896 <exit>:

void
exit(int error_code) {
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	83 ec 08             	sub    $0x8,%esp
    sys_exit(error_code);
  80089c:	83 ec 0c             	sub    $0xc,%esp
  80089f:	ff 75 08             	pushl  0x8(%ebp)
  8008a2:	e8 64 f8 ff ff       	call   80010b <sys_exit>
  8008a7:	83 c4 10             	add    $0x10,%esp
    cprintf("BUG: exit failed.\n");
  8008aa:	83 ec 0c             	sub    $0xc,%esp
  8008ad:	68 a4 1e 80 00       	push   $0x801ea4
  8008b2:	e8 1e fd ff ff       	call   8005d5 <cprintf>
  8008b7:	83 c4 10             	add    $0x10,%esp
    while (1);
  8008ba:	eb fe                	jmp    8008ba <exit+0x24>

008008bc <fork>:
}

int
fork(void) {
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	83 ec 08             	sub    $0x8,%esp
    return sys_fork();
  8008c2:	e8 56 f8 ff ff       	call   80011d <sys_fork>
}
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    

008008c9 <wait>:

int
wait(void) {
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	83 ec 08             	sub    $0x8,%esp
    return sys_wait(0, NULL);
  8008cf:	83 ec 08             	sub    $0x8,%esp
  8008d2:	6a 00                	push   $0x0
  8008d4:	6a 00                	push   $0x0
  8008d6:	e8 51 f8 ff ff       	call   80012c <sys_wait>
  8008db:	83 c4 10             	add    $0x10,%esp
}
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <waitpid>:

int
waitpid(int pid, int *store) {
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	83 ec 08             	sub    $0x8,%esp
    return sys_wait(pid, store);
  8008e6:	83 ec 08             	sub    $0x8,%esp
  8008e9:	ff 75 0c             	pushl  0xc(%ebp)
  8008ec:	ff 75 08             	pushl  0x8(%ebp)
  8008ef:	e8 38 f8 ff ff       	call   80012c <sys_wait>
  8008f4:	83 c4 10             	add    $0x10,%esp
}
  8008f7:	c9                   	leave  
  8008f8:	c3                   	ret    

008008f9 <yield>:

void
yield(void) {
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	83 ec 08             	sub    $0x8,%esp
    sys_yield();
  8008ff:	e8 3d f8 ff ff       	call   800141 <sys_yield>
}
  800904:	90                   	nop
  800905:	c9                   	leave  
  800906:	c3                   	ret    

00800907 <kill>:

int
kill(int pid) {
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	83 ec 08             	sub    $0x8,%esp
    return sys_kill(pid);
  80090d:	83 ec 0c             	sub    $0xc,%esp
  800910:	ff 75 08             	pushl  0x8(%ebp)
  800913:	e8 38 f8 ff ff       	call   800150 <sys_kill>
  800918:	83 c4 10             	add    $0x10,%esp
}
  80091b:	c9                   	leave  
  80091c:	c3                   	ret    

0080091d <getpid>:

int
getpid(void) {
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	83 ec 08             	sub    $0x8,%esp
    return sys_getpid();
  800923:	e8 3a f8 ff ff       	call   800162 <sys_getpid>
}
  800928:	c9                   	leave  
  800929:	c3                   	ret    

0080092a <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	83 ec 08             	sub    $0x8,%esp
    sys_pgdir();
  800930:	e8 4e f8 ff ff       	call   800183 <sys_pgdir>
}
  800935:	90                   	nop
  800936:	c9                   	leave  
  800937:	c3                   	ret    

00800938 <lab6_set_priority>:

void
lab6_set_priority(uint32_t priority)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	83 ec 08             	sub    $0x8,%esp
    sys_lab6_set_priority(priority);
  80093e:	83 ec 0c             	sub    $0xc,%esp
  800941:	ff 75 08             	pushl  0x8(%ebp)
  800944:	e8 49 f8 ff ff       	call   800192 <sys_lab6_set_priority>
  800949:	83 c4 10             	add    $0x10,%esp
}
  80094c:	90                   	nop
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <sleep>:

int
sleep(unsigned int time) {
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	83 ec 08             	sub    $0x8,%esp
    return sys_sleep(time);
  800955:	83 ec 0c             	sub    $0xc,%esp
  800958:	ff 75 08             	pushl  0x8(%ebp)
  80095b:	e8 48 f8 ff ff       	call   8001a8 <sys_sleep>
  800960:	83 c4 10             	add    $0x10,%esp
}
  800963:	c9                   	leave  
  800964:	c3                   	ret    

00800965 <gettime_msec>:

unsigned int
gettime_msec(void) {
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	83 ec 08             	sub    $0x8,%esp
    return (unsigned int)sys_gettime();
  80096b:	e8 4a f8 ff ff       	call   8001ba <sys_gettime>
}
  800970:	c9                   	leave  
  800971:	c3                   	ret    

00800972 <__exec>:

int
__exec(const char *name, const char **argv) {
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	83 ec 18             	sub    $0x18,%esp
    int argc = 0;
  800978:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (argv[argc] != NULL) {
  80097f:	eb 04                	jmp    800985 <__exec+0x13>
        argc ++;
  800981:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
}

int
__exec(const char *name, const char **argv) {
    int argc = 0;
    while (argv[argc] != NULL) {
  800985:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800988:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80098f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800992:	01 d0                	add    %edx,%eax
  800994:	8b 00                	mov    (%eax),%eax
  800996:	85 c0                	test   %eax,%eax
  800998:	75 e7                	jne    800981 <__exec+0xf>
        argc ++;
    }
    return sys_exec(name, argc, argv);
  80099a:	83 ec 04             	sub    $0x4,%esp
  80099d:	ff 75 0c             	pushl  0xc(%ebp)
  8009a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8009a3:	ff 75 08             	pushl  0x8(%ebp)
  8009a6:	e8 1e f8 ff ff       	call   8001c9 <sys_exec>
  8009ab:	83 c4 10             	add    $0x10,%esp
}
  8009ae:	c9                   	leave  
  8009af:	c3                   	ret    

008009b0 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  8009b6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  8009bd:	eb 04                	jmp    8009c3 <strlen+0x13>
        cnt ++;
  8009bf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	8d 50 01             	lea    0x1(%eax),%edx
  8009c9:	89 55 08             	mov    %edx,0x8(%ebp)
  8009cc:	0f b6 00             	movzbl (%eax),%eax
  8009cf:	84 c0                	test   %al,%al
  8009d1:	75 ec                	jne    8009bf <strlen+0xf>
        cnt ++;
    }
    return cnt;
  8009d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  8009de:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  8009e5:	eb 04                	jmp    8009eb <strnlen+0x13>
        cnt ++;
  8009e7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  8009eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009ee:	3b 45 0c             	cmp    0xc(%ebp),%eax
  8009f1:	73 10                	jae    800a03 <strnlen+0x2b>
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8d 50 01             	lea    0x1(%eax),%edx
  8009f9:	89 55 08             	mov    %edx,0x8(%ebp)
  8009fc:	0f b6 00             	movzbl (%eax),%eax
  8009ff:	84 c0                	test   %al,%al
  800a01:	75 e4                	jne    8009e7 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  800a03:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800a06:	c9                   	leave  
  800a07:	c3                   	ret    

00800a08 <strcat>:
 * @dst:    pointer to the @dst array, which should be large enough to contain the concatenated
 *          resulting string.
 * @src:    string to be appended, this should not overlap @dst
 * */
char *
strcat(char *dst, const char *src) {
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	83 ec 08             	sub    $0x8,%esp
    return strcpy(dst + strlen(dst), src);
  800a0e:	ff 75 08             	pushl  0x8(%ebp)
  800a11:	e8 9a ff ff ff       	call   8009b0 <strlen>
  800a16:	83 c4 04             	add    $0x4,%esp
  800a19:	89 c2                	mov    %eax,%edx
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	01 d0                	add    %edx,%eax
  800a20:	83 ec 08             	sub    $0x8,%esp
  800a23:	ff 75 0c             	pushl  0xc(%ebp)
  800a26:	50                   	push   %eax
  800a27:	e8 05 00 00 00       	call   800a31 <strcpy>
  800a2c:	83 c4 10             	add    $0x10,%esp
}
  800a2f:	c9                   	leave  
  800a30:	c3                   	ret    

00800a31 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	57                   	push   %edi
  800a35:	56                   	push   %esi
  800a36:	83 ec 20             	sub    $0x20,%esp
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800a3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a42:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  800a45:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a4b:	89 d1                	mov    %edx,%ecx
  800a4d:	89 c2                	mov    %eax,%edx
  800a4f:	89 ce                	mov    %ecx,%esi
  800a51:	89 d7                	mov    %edx,%edi
  800a53:	ac                   	lods   %ds:(%esi),%al
  800a54:	aa                   	stos   %al,%es:(%edi)
  800a55:	84 c0                	test   %al,%al
  800a57:	75 fa                	jne    800a53 <strcpy+0x22>
  800a59:	89 fa                	mov    %edi,%edx
  800a5b:	89 f1                	mov    %esi,%ecx
  800a5d:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800a60:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800a63:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  800a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  800a69:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  800a6a:	83 c4 20             	add    $0x20,%esp
  800a6d:	5e                   	pop    %esi
  800a6e:	5f                   	pop    %edi
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  800a77:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  800a7d:	eb 21                	jmp    800aa0 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  800a7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a82:	0f b6 10             	movzbl (%eax),%edx
  800a85:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a88:	88 10                	mov    %dl,(%eax)
  800a8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a8d:	0f b6 00             	movzbl (%eax),%eax
  800a90:	84 c0                	test   %al,%al
  800a92:	74 04                	je     800a98 <strncpy+0x27>
            src ++;
  800a94:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  800a98:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800a9c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  800aa0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800aa4:	75 d9                	jne    800a7f <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800aa9:	c9                   	leave  
  800aaa:	c3                   	ret    

00800aab <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	57                   	push   %edi
  800aaf:	56                   	push   %esi
  800ab0:	83 ec 20             	sub    $0x20,%esp
  800ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abc:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  800abf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ac5:	89 d1                	mov    %edx,%ecx
  800ac7:	89 c2                	mov    %eax,%edx
  800ac9:	89 ce                	mov    %ecx,%esi
  800acb:	89 d7                	mov    %edx,%edi
  800acd:	ac                   	lods   %ds:(%esi),%al
  800ace:	ae                   	scas   %es:(%edi),%al
  800acf:	75 08                	jne    800ad9 <strcmp+0x2e>
  800ad1:	84 c0                	test   %al,%al
  800ad3:	75 f8                	jne    800acd <strcmp+0x22>
  800ad5:	31 c0                	xor    %eax,%eax
  800ad7:	eb 04                	jmp    800add <strcmp+0x32>
  800ad9:	19 c0                	sbb    %eax,%eax
  800adb:	0c 01                	or     $0x1,%al
  800add:	89 fa                	mov    %edi,%edx
  800adf:	89 f1                	mov    %esi,%ecx
  800ae1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ae4:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  800ae7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  800aea:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  800aed:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  800aee:	83 c4 20             	add    $0x20,%esp
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  800af8:	eb 0c                	jmp    800b06 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  800afa:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800afe:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800b02:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  800b06:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b0a:	74 1a                	je     800b26 <strncmp+0x31>
  800b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0f:	0f b6 00             	movzbl (%eax),%eax
  800b12:	84 c0                	test   %al,%al
  800b14:	74 10                	je     800b26 <strncmp+0x31>
  800b16:	8b 45 08             	mov    0x8(%ebp),%eax
  800b19:	0f b6 10             	movzbl (%eax),%edx
  800b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1f:	0f b6 00             	movzbl (%eax),%eax
  800b22:	38 c2                	cmp    %al,%dl
  800b24:	74 d4                	je     800afa <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  800b26:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b2a:	74 18                	je     800b44 <strncmp+0x4f>
  800b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2f:	0f b6 00             	movzbl (%eax),%eax
  800b32:	0f b6 d0             	movzbl %al,%edx
  800b35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b38:	0f b6 00             	movzbl (%eax),%eax
  800b3b:	0f b6 c0             	movzbl %al,%eax
  800b3e:	29 c2                	sub    %eax,%edx
  800b40:	89 d0                	mov    %edx,%eax
  800b42:	eb 05                	jmp    800b49 <strncmp+0x54>
  800b44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	83 ec 04             	sub    $0x4,%esp
  800b51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b54:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800b57:	eb 14                	jmp    800b6d <strchr+0x22>
        if (*s == c) {
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	0f b6 00             	movzbl (%eax),%eax
  800b5f:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b62:	75 05                	jne    800b69 <strchr+0x1e>
            return (char *)s;
  800b64:	8b 45 08             	mov    0x8(%ebp),%eax
  800b67:	eb 13                	jmp    800b7c <strchr+0x31>
        }
        s ++;
  800b69:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  800b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b70:	0f b6 00             	movzbl (%eax),%eax
  800b73:	84 c0                	test   %al,%al
  800b75:	75 e2                	jne    800b59 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b7c:	c9                   	leave  
  800b7d:	c3                   	ret    

00800b7e <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	83 ec 04             	sub    $0x4,%esp
  800b84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b87:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800b8a:	eb 0f                	jmp    800b9b <strfind+0x1d>
        if (*s == c) {
  800b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8f:	0f b6 00             	movzbl (%eax),%eax
  800b92:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b95:	74 10                	je     800ba7 <strfind+0x29>
            break;
        }
        s ++;
  800b97:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  800b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9e:	0f b6 00             	movzbl (%eax),%eax
  800ba1:	84 c0                	test   %al,%al
  800ba3:	75 e7                	jne    800b8c <strfind+0xe>
  800ba5:	eb 01                	jmp    800ba8 <strfind+0x2a>
        if (*s == c) {
            break;
  800ba7:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
  800ba8:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    

00800bad <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  800bb3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  800bba:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  800bc1:	eb 04                	jmp    800bc7 <strtol+0x1a>
        s ++;
  800bc3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  800bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bca:	0f b6 00             	movzbl (%eax),%eax
  800bcd:	3c 20                	cmp    $0x20,%al
  800bcf:	74 f2                	je     800bc3 <strtol+0x16>
  800bd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd4:	0f b6 00             	movzbl (%eax),%eax
  800bd7:	3c 09                	cmp    $0x9,%al
  800bd9:	74 e8                	je     800bc3 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  800bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bde:	0f b6 00             	movzbl (%eax),%eax
  800be1:	3c 2b                	cmp    $0x2b,%al
  800be3:	75 06                	jne    800beb <strtol+0x3e>
        s ++;
  800be5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800be9:	eb 15                	jmp    800c00 <strtol+0x53>
    }
    else if (*s == '-') {
  800beb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bee:	0f b6 00             	movzbl (%eax),%eax
  800bf1:	3c 2d                	cmp    $0x2d,%al
  800bf3:	75 0b                	jne    800c00 <strtol+0x53>
        s ++, neg = 1;
  800bf5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bf9:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  800c00:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c04:	74 06                	je     800c0c <strtol+0x5f>
  800c06:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800c0a:	75 24                	jne    800c30 <strtol+0x83>
  800c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0f:	0f b6 00             	movzbl (%eax),%eax
  800c12:	3c 30                	cmp    $0x30,%al
  800c14:	75 1a                	jne    800c30 <strtol+0x83>
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	83 c0 01             	add    $0x1,%eax
  800c1c:	0f b6 00             	movzbl (%eax),%eax
  800c1f:	3c 78                	cmp    $0x78,%al
  800c21:	75 0d                	jne    800c30 <strtol+0x83>
        s += 2, base = 16;
  800c23:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800c27:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800c2e:	eb 2a                	jmp    800c5a <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  800c30:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c34:	75 17                	jne    800c4d <strtol+0xa0>
  800c36:	8b 45 08             	mov    0x8(%ebp),%eax
  800c39:	0f b6 00             	movzbl (%eax),%eax
  800c3c:	3c 30                	cmp    $0x30,%al
  800c3e:	75 0d                	jne    800c4d <strtol+0xa0>
        s ++, base = 8;
  800c40:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c44:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800c4b:	eb 0d                	jmp    800c5a <strtol+0xad>
    }
    else if (base == 0) {
  800c4d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c51:	75 07                	jne    800c5a <strtol+0xad>
        base = 10;
  800c53:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  800c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5d:	0f b6 00             	movzbl (%eax),%eax
  800c60:	3c 2f                	cmp    $0x2f,%al
  800c62:	7e 1b                	jle    800c7f <strtol+0xd2>
  800c64:	8b 45 08             	mov    0x8(%ebp),%eax
  800c67:	0f b6 00             	movzbl (%eax),%eax
  800c6a:	3c 39                	cmp    $0x39,%al
  800c6c:	7f 11                	jg     800c7f <strtol+0xd2>
            dig = *s - '0';
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	0f b6 00             	movzbl (%eax),%eax
  800c74:	0f be c0             	movsbl %al,%eax
  800c77:	83 e8 30             	sub    $0x30,%eax
  800c7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800c7d:	eb 48                	jmp    800cc7 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  800c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c82:	0f b6 00             	movzbl (%eax),%eax
  800c85:	3c 60                	cmp    $0x60,%al
  800c87:	7e 1b                	jle    800ca4 <strtol+0xf7>
  800c89:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8c:	0f b6 00             	movzbl (%eax),%eax
  800c8f:	3c 7a                	cmp    $0x7a,%al
  800c91:	7f 11                	jg     800ca4 <strtol+0xf7>
            dig = *s - 'a' + 10;
  800c93:	8b 45 08             	mov    0x8(%ebp),%eax
  800c96:	0f b6 00             	movzbl (%eax),%eax
  800c99:	0f be c0             	movsbl %al,%eax
  800c9c:	83 e8 57             	sub    $0x57,%eax
  800c9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800ca2:	eb 23                	jmp    800cc7 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  800ca4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca7:	0f b6 00             	movzbl (%eax),%eax
  800caa:	3c 40                	cmp    $0x40,%al
  800cac:	7e 3c                	jle    800cea <strtol+0x13d>
  800cae:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb1:	0f b6 00             	movzbl (%eax),%eax
  800cb4:	3c 5a                	cmp    $0x5a,%al
  800cb6:	7f 32                	jg     800cea <strtol+0x13d>
            dig = *s - 'A' + 10;
  800cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbb:	0f b6 00             	movzbl (%eax),%eax
  800cbe:	0f be c0             	movsbl %al,%eax
  800cc1:	83 e8 37             	sub    $0x37,%eax
  800cc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  800cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cca:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ccd:	7d 1a                	jge    800ce9 <strtol+0x13c>
            break;
        }
        s ++, val = (val * base) + dig;
  800ccf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cd3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800cd6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cda:	89 c2                	mov    %eax,%edx
  800cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cdf:	01 d0                	add    %edx,%eax
  800ce1:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  800ce4:	e9 71 ff ff ff       	jmp    800c5a <strtol+0xad>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
  800ce9:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
  800cea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cee:	74 08                	je     800cf8 <strtol+0x14b>
        *endptr = (char *) s;
  800cf0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  800cf8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800cfc:	74 07                	je     800d05 <strtol+0x158>
  800cfe:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d01:	f7 d8                	neg    %eax
  800d03:	eb 03                	jmp    800d08 <strtol+0x15b>
  800d05:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d08:	c9                   	leave  
  800d09:	c3                   	ret    

00800d0a <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	83 ec 24             	sub    $0x24,%esp
  800d11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d14:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  800d17:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800d21:	88 45 f7             	mov    %al,-0x9(%ebp)
  800d24:	8b 45 10             	mov    0x10(%ebp),%eax
  800d27:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  800d2a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800d2d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800d31:	8b 55 f8             	mov    -0x8(%ebp),%edx
  800d34:	89 d7                	mov    %edx,%edi
  800d36:	f3 aa                	rep stos %al,%es:(%edi)
  800d38:	89 fa                	mov    %edi,%edx
  800d3a:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800d3d:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  800d40:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d43:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  800d44:	83 c4 24             	add    $0x24,%esp
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 30             	sub    $0x30,%esp
  800d53:	8b 45 08             	mov    0x8(%ebp),%eax
  800d56:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d5f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d62:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  800d65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d68:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800d6b:	73 42                	jae    800daf <memmove+0x65>
  800d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d70:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800d73:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d76:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d79:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800d7c:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  800d7f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800d82:	c1 e8 02             	shr    $0x2,%eax
  800d85:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  800d87:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d8d:	89 d7                	mov    %edx,%edi
  800d8f:	89 c6                	mov    %eax,%esi
  800d91:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d93:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800d96:	83 e1 03             	and    $0x3,%ecx
  800d99:	74 02                	je     800d9d <memmove+0x53>
  800d9b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800d9d:	89 f0                	mov    %esi,%eax
  800d9f:	89 fa                	mov    %edi,%edx
  800da1:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800da4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800da7:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  800daa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  800dad:	eb 36                	jmp    800de5 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  800daf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800db2:	8d 50 ff             	lea    -0x1(%eax),%edx
  800db5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800db8:	01 c2                	add    %eax,%edx
  800dba:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800dbd:	8d 48 ff             	lea    -0x1(%eax),%ecx
  800dc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dc3:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  800dc6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800dc9:	89 c1                	mov    %eax,%ecx
  800dcb:	89 d8                	mov    %ebx,%eax
  800dcd:	89 d6                	mov    %edx,%esi
  800dcf:	89 c7                	mov    %eax,%edi
  800dd1:	fd                   	std    
  800dd2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800dd4:	fc                   	cld    
  800dd5:	89 f8                	mov    %edi,%eax
  800dd7:	89 f2                	mov    %esi,%edx
  800dd9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800ddc:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800ddf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  800de2:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  800de5:	83 c4 30             	add    $0x30,%esp
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	83 ec 20             	sub    $0x20,%esp
  800df5:	8b 45 08             	mov    0x8(%ebp),%eax
  800df8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e01:	8b 45 10             	mov    0x10(%ebp),%eax
  800e04:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  800e07:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e0a:	c1 e8 02             	shr    $0x2,%eax
  800e0d:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  800e0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e15:	89 d7                	mov    %edx,%edi
  800e17:	89 c6                	mov    %eax,%esi
  800e19:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e1b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  800e1e:	83 e1 03             	and    $0x3,%ecx
  800e21:	74 02                	je     800e25 <memcpy+0x38>
  800e23:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800e25:	89 f0                	mov    %esi,%eax
  800e27:	89 fa                	mov    %edi,%edx
  800e29:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  800e2c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800e2f:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  800e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  800e35:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  800e36:	83 c4 20             	add    $0x20,%esp
  800e39:	5e                   	pop    %esi
  800e3a:	5f                   	pop    %edi
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    

00800e3d <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  800e43:	8b 45 08             	mov    0x8(%ebp),%eax
  800e46:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  800e49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4c:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  800e4f:	eb 30                	jmp    800e81 <memcmp+0x44>
        if (*s1 != *s2) {
  800e51:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800e54:	0f b6 10             	movzbl (%eax),%edx
  800e57:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e5a:	0f b6 00             	movzbl (%eax),%eax
  800e5d:	38 c2                	cmp    %al,%dl
  800e5f:	74 18                	je     800e79 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  800e61:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800e64:	0f b6 00             	movzbl (%eax),%eax
  800e67:	0f b6 d0             	movzbl %al,%edx
  800e6a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800e6d:	0f b6 00             	movzbl (%eax),%eax
  800e70:	0f b6 c0             	movzbl %al,%eax
  800e73:	29 c2                	sub    %eax,%edx
  800e75:	89 d0                	mov    %edx,%eax
  800e77:	eb 1a                	jmp    800e93 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  800e79:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800e7d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  800e81:	8b 45 10             	mov    0x10(%ebp),%eax
  800e84:	8d 50 ff             	lea    -0x1(%eax),%edx
  800e87:	89 55 10             	mov    %edx,0x10(%ebp)
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	75 c3                	jne    800e51 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  800e8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e93:	c9                   	leave  
  800e94:	c3                   	ret    

00800e95 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*, int), int fd, void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	83 ec 38             	sub    $0x38,%esp
  800e9b:	8b 45 14             	mov    0x14(%ebp),%eax
  800e9e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800ea1:	8b 45 18             	mov    0x18(%ebp),%eax
  800ea4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  800ea7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800eaa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800ead:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800eb0:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  800eb3:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800eb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800eb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ebc:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800ebf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ec2:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800ecb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800ecf:	74 1c                	je     800eed <printnum+0x58>
  800ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed9:	f7 75 e4             	divl   -0x1c(%ebp)
  800edc:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800edf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee7:	f7 75 e4             	divl   -0x1c(%ebp)
  800eea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800eed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ef0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ef3:	f7 75 e4             	divl   -0x1c(%ebp)
  800ef6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ef9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800efc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800eff:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f02:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800f05:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800f08:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f0b:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800f0e:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800f11:	ba 00 00 00 00       	mov    $0x0,%edx
  800f16:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  800f19:	77 44                	ja     800f5f <printnum+0xca>
  800f1b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  800f1e:	72 05                	jb     800f25 <printnum+0x90>
  800f20:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  800f23:	77 3a                	ja     800f5f <printnum+0xca>
        printnum(putch, fd, putdat, result, base, width - 1, padc);
  800f25:	8b 45 20             	mov    0x20(%ebp),%eax
  800f28:	83 e8 01             	sub    $0x1,%eax
  800f2b:	ff 75 24             	pushl  0x24(%ebp)
  800f2e:	50                   	push   %eax
  800f2f:	ff 75 1c             	pushl  0x1c(%ebp)
  800f32:	ff 75 ec             	pushl  -0x14(%ebp)
  800f35:	ff 75 e8             	pushl  -0x18(%ebp)
  800f38:	ff 75 10             	pushl  0x10(%ebp)
  800f3b:	ff 75 0c             	pushl  0xc(%ebp)
  800f3e:	ff 75 08             	pushl  0x8(%ebp)
  800f41:	e8 4f ff ff ff       	call   800e95 <printnum>
  800f46:	83 c4 20             	add    $0x20,%esp
  800f49:	eb 1e                	jmp    800f69 <printnum+0xd4>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat, fd);
  800f4b:	83 ec 04             	sub    $0x4,%esp
  800f4e:	ff 75 0c             	pushl  0xc(%ebp)
  800f51:	ff 75 10             	pushl  0x10(%ebp)
  800f54:	ff 75 24             	pushl  0x24(%ebp)
  800f57:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5a:	ff d0                	call   *%eax
  800f5c:	83 c4 10             	add    $0x10,%esp
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, fd, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800f5f:	83 6d 20 01          	subl   $0x1,0x20(%ebp)
  800f63:	83 7d 20 00          	cmpl   $0x0,0x20(%ebp)
  800f67:	7f e2                	jg     800f4b <printnum+0xb6>
            putch(padc, putdat, fd);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat, fd);
  800f69:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f6c:	05 c4 20 80 00       	add    $0x8020c4,%eax
  800f71:	0f b6 00             	movzbl (%eax),%eax
  800f74:	0f be c0             	movsbl %al,%eax
  800f77:	83 ec 04             	sub    $0x4,%esp
  800f7a:	ff 75 0c             	pushl  0xc(%ebp)
  800f7d:	ff 75 10             	pushl  0x10(%ebp)
  800f80:	50                   	push   %eax
  800f81:	8b 45 08             	mov    0x8(%ebp),%eax
  800f84:	ff d0                	call   *%eax
  800f86:	83 c4 10             	add    $0x10,%esp
}
  800f89:	90                   	nop
  800f8a:	c9                   	leave  
  800f8b:	c3                   	ret    

00800f8c <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  800f8f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800f93:	7e 14                	jle    800fa9 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  800f95:	8b 45 08             	mov    0x8(%ebp),%eax
  800f98:	8b 00                	mov    (%eax),%eax
  800f9a:	8d 48 08             	lea    0x8(%eax),%ecx
  800f9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa0:	89 0a                	mov    %ecx,(%edx)
  800fa2:	8b 50 04             	mov    0x4(%eax),%edx
  800fa5:	8b 00                	mov    (%eax),%eax
  800fa7:	eb 30                	jmp    800fd9 <getuint+0x4d>
    }
    else if (lflag) {
  800fa9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fad:	74 16                	je     800fc5 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  800faf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb2:	8b 00                	mov    (%eax),%eax
  800fb4:	8d 48 04             	lea    0x4(%eax),%ecx
  800fb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fba:	89 0a                	mov    %ecx,(%edx)
  800fbc:	8b 00                	mov    (%eax),%eax
  800fbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc3:	eb 14                	jmp    800fd9 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  800fc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc8:	8b 00                	mov    (%eax),%eax
  800fca:	8d 48 04             	lea    0x4(%eax),%ecx
  800fcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd0:	89 0a                	mov    %ecx,(%edx)
  800fd2:	8b 00                	mov    (%eax),%eax
  800fd4:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    

00800fdb <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  800fde:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800fe2:	7e 14                	jle    800ff8 <getint+0x1d>
        return va_arg(*ap, long long);
  800fe4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe7:	8b 00                	mov    (%eax),%eax
  800fe9:	8d 48 08             	lea    0x8(%eax),%ecx
  800fec:	8b 55 08             	mov    0x8(%ebp),%edx
  800fef:	89 0a                	mov    %ecx,(%edx)
  800ff1:	8b 50 04             	mov    0x4(%eax),%edx
  800ff4:	8b 00                	mov    (%eax),%eax
  800ff6:	eb 28                	jmp    801020 <getint+0x45>
    }
    else if (lflag) {
  800ff8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ffc:	74 12                	je     801010 <getint+0x35>
        return va_arg(*ap, long);
  800ffe:	8b 45 08             	mov    0x8(%ebp),%eax
  801001:	8b 00                	mov    (%eax),%eax
  801003:	8d 48 04             	lea    0x4(%eax),%ecx
  801006:	8b 55 08             	mov    0x8(%ebp),%edx
  801009:	89 0a                	mov    %ecx,(%edx)
  80100b:	8b 00                	mov    (%eax),%eax
  80100d:	99                   	cltd   
  80100e:	eb 10                	jmp    801020 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  801010:	8b 45 08             	mov    0x8(%ebp),%eax
  801013:	8b 00                	mov    (%eax),%eax
  801015:	8d 48 04             	lea    0x4(%eax),%ecx
  801018:	8b 55 08             	mov    0x8(%ebp),%edx
  80101b:	89 0a                	mov    %ecx,(%edx)
  80101d:	8b 00                	mov    (%eax),%eax
  80101f:	99                   	cltd   
    }
}
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <printfmt>:
 * @fd:         file descriptor
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*, int), int fd, void *putdat, const char *fmt, ...) {
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
  801028:	8d 45 18             	lea    0x18(%ebp),%eax
  80102b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, fd, putdat, fmt, ap);
  80102e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801031:	83 ec 0c             	sub    $0xc,%esp
  801034:	50                   	push   %eax
  801035:	ff 75 14             	pushl  0x14(%ebp)
  801038:	ff 75 10             	pushl  0x10(%ebp)
  80103b:	ff 75 0c             	pushl  0xc(%ebp)
  80103e:	ff 75 08             	pushl  0x8(%ebp)
  801041:	e8 06 00 00 00       	call   80104c <vprintfmt>
  801046:	83 c4 20             	add    $0x20,%esp
    va_end(ap);
}
  801049:	90                   	nop
  80104a:	c9                   	leave  
  80104b:	c3                   	ret    

0080104c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*, int), int fd, void *putdat, const char *fmt, va_list ap) {
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
  801051:	83 ec 20             	sub    $0x20,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  801054:	eb 1a                	jmp    801070 <vprintfmt+0x24>
            if (ch == '\0') {
  801056:	85 db                	test   %ebx,%ebx
  801058:	0f 84 be 03 00 00    	je     80141c <vprintfmt+0x3d0>
                return;
            }
            putch(ch, putdat, fd);
  80105e:	83 ec 04             	sub    $0x4,%esp
  801061:	ff 75 0c             	pushl  0xc(%ebp)
  801064:	ff 75 10             	pushl  0x10(%ebp)
  801067:	53                   	push   %ebx
  801068:	8b 45 08             	mov    0x8(%ebp),%eax
  80106b:	ff d0                	call   *%eax
  80106d:	83 c4 10             	add    $0x10,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  801070:	8b 45 14             	mov    0x14(%ebp),%eax
  801073:	8d 50 01             	lea    0x1(%eax),%edx
  801076:	89 55 14             	mov    %edx,0x14(%ebp)
  801079:	0f b6 00             	movzbl (%eax),%eax
  80107c:	0f b6 d8             	movzbl %al,%ebx
  80107f:	83 fb 25             	cmp    $0x25,%ebx
  801082:	75 d2                	jne    801056 <vprintfmt+0xa>
            }
            putch(ch, putdat, fd);
        }

        // Process a %-escape sequence
        char padc = ' ';
  801084:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  801088:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80108f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801092:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  801095:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80109c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80109f:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8010a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8010a5:	8d 50 01             	lea    0x1(%eax),%edx
  8010a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8010ab:	0f b6 00             	movzbl (%eax),%eax
  8010ae:	0f b6 d8             	movzbl %al,%ebx
  8010b1:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8010b4:	83 f8 55             	cmp    $0x55,%eax
  8010b7:	0f 87 2f 03 00 00    	ja     8013ec <vprintfmt+0x3a0>
  8010bd:	8b 04 85 e8 20 80 00 	mov    0x8020e8(,%eax,4),%eax
  8010c4:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  8010c6:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  8010ca:	eb d6                	jmp    8010a2 <vprintfmt+0x56>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  8010cc:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  8010d0:	eb d0                	jmp    8010a2 <vprintfmt+0x56>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  8010d2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  8010d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010dc:	89 d0                	mov    %edx,%eax
  8010de:	c1 e0 02             	shl    $0x2,%eax
  8010e1:	01 d0                	add    %edx,%eax
  8010e3:	01 c0                	add    %eax,%eax
  8010e5:	01 d8                	add    %ebx,%eax
  8010e7:	83 e8 30             	sub    $0x30,%eax
  8010ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  8010ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8010f0:	0f b6 00             	movzbl (%eax),%eax
  8010f3:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  8010f6:	83 fb 2f             	cmp    $0x2f,%ebx
  8010f9:	7e 39                	jle    801134 <vprintfmt+0xe8>
  8010fb:	83 fb 39             	cmp    $0x39,%ebx
  8010fe:	7f 34                	jg     801134 <vprintfmt+0xe8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  801100:	83 45 14 01          	addl   $0x1,0x14(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  801104:	eb d3                	jmp    8010d9 <vprintfmt+0x8d>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  801106:	8b 45 18             	mov    0x18(%ebp),%eax
  801109:	8d 50 04             	lea    0x4(%eax),%edx
  80110c:	89 55 18             	mov    %edx,0x18(%ebp)
  80110f:	8b 00                	mov    (%eax),%eax
  801111:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  801114:	eb 1f                	jmp    801135 <vprintfmt+0xe9>

        case '.':
            if (width < 0)
  801116:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80111a:	79 86                	jns    8010a2 <vprintfmt+0x56>
                width = 0;
  80111c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  801123:	e9 7a ff ff ff       	jmp    8010a2 <vprintfmt+0x56>

        case '#':
            altflag = 1;
  801128:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  80112f:	e9 6e ff ff ff       	jmp    8010a2 <vprintfmt+0x56>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
  801134:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
  801135:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801139:	0f 89 63 ff ff ff    	jns    8010a2 <vprintfmt+0x56>
                width = precision, precision = -1;
  80113f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801142:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801145:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  80114c:	e9 51 ff ff ff       	jmp    8010a2 <vprintfmt+0x56>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  801151:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  801155:	e9 48 ff ff ff       	jmp    8010a2 <vprintfmt+0x56>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat, fd);
  80115a:	8b 45 18             	mov    0x18(%ebp),%eax
  80115d:	8d 50 04             	lea    0x4(%eax),%edx
  801160:	89 55 18             	mov    %edx,0x18(%ebp)
  801163:	8b 00                	mov    (%eax),%eax
  801165:	83 ec 04             	sub    $0x4,%esp
  801168:	ff 75 0c             	pushl  0xc(%ebp)
  80116b:	ff 75 10             	pushl  0x10(%ebp)
  80116e:	50                   	push   %eax
  80116f:	8b 45 08             	mov    0x8(%ebp),%eax
  801172:	ff d0                	call   *%eax
  801174:	83 c4 10             	add    $0x10,%esp
            break;
  801177:	e9 9b 02 00 00       	jmp    801417 <vprintfmt+0x3cb>

        // error message
        case 'e':
            err = va_arg(ap, int);
  80117c:	8b 45 18             	mov    0x18(%ebp),%eax
  80117f:	8d 50 04             	lea    0x4(%eax),%edx
  801182:	89 55 18             	mov    %edx,0x18(%ebp)
  801185:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  801187:	85 db                	test   %ebx,%ebx
  801189:	79 02                	jns    80118d <vprintfmt+0x141>
                err = -err;
  80118b:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80118d:	83 fb 18             	cmp    $0x18,%ebx
  801190:	7f 0b                	jg     80119d <vprintfmt+0x151>
  801192:	8b 34 9d 60 20 80 00 	mov    0x802060(,%ebx,4),%esi
  801199:	85 f6                	test   %esi,%esi
  80119b:	75 1f                	jne    8011bc <vprintfmt+0x170>
                printfmt(putch, fd, putdat, "error %d", err);
  80119d:	83 ec 0c             	sub    $0xc,%esp
  8011a0:	53                   	push   %ebx
  8011a1:	68 d5 20 80 00       	push   $0x8020d5
  8011a6:	ff 75 10             	pushl  0x10(%ebp)
  8011a9:	ff 75 0c             	pushl  0xc(%ebp)
  8011ac:	ff 75 08             	pushl  0x8(%ebp)
  8011af:	e8 6e fe ff ff       	call   801022 <printfmt>
  8011b4:	83 c4 20             	add    $0x20,%esp
            }
            else {
                printfmt(putch, fd, putdat, "%s", p);
            }
            break;
  8011b7:	e9 5b 02 00 00       	jmp    801417 <vprintfmt+0x3cb>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, fd, putdat, "error %d", err);
            }
            else {
                printfmt(putch, fd, putdat, "%s", p);
  8011bc:	83 ec 0c             	sub    $0xc,%esp
  8011bf:	56                   	push   %esi
  8011c0:	68 de 20 80 00       	push   $0x8020de
  8011c5:	ff 75 10             	pushl  0x10(%ebp)
  8011c8:	ff 75 0c             	pushl  0xc(%ebp)
  8011cb:	ff 75 08             	pushl  0x8(%ebp)
  8011ce:	e8 4f fe ff ff       	call   801022 <printfmt>
  8011d3:	83 c4 20             	add    $0x20,%esp
            }
            break;
  8011d6:	e9 3c 02 00 00       	jmp    801417 <vprintfmt+0x3cb>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  8011db:	8b 45 18             	mov    0x18(%ebp),%eax
  8011de:	8d 50 04             	lea    0x4(%eax),%edx
  8011e1:	89 55 18             	mov    %edx,0x18(%ebp)
  8011e4:	8b 30                	mov    (%eax),%esi
  8011e6:	85 f6                	test   %esi,%esi
  8011e8:	75 05                	jne    8011ef <vprintfmt+0x1a3>
                p = "(null)";
  8011ea:	be e1 20 80 00       	mov    $0x8020e1,%esi
            }
            if (width > 0 && padc != '-') {
  8011ef:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8011f3:	7e 7f                	jle    801274 <vprintfmt+0x228>
  8011f5:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8011f9:	74 79                	je     801274 <vprintfmt+0x228>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8011fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011fe:	83 ec 08             	sub    $0x8,%esp
  801201:	50                   	push   %eax
  801202:	56                   	push   %esi
  801203:	e8 d0 f7 ff ff       	call   8009d8 <strnlen>
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	89 c2                	mov    %eax,%edx
  80120d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801210:	29 d0                	sub    %edx,%eax
  801212:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801215:	eb 1a                	jmp    801231 <vprintfmt+0x1e5>
                    putch(padc, putdat, fd);
  801217:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80121b:	83 ec 04             	sub    $0x4,%esp
  80121e:	ff 75 0c             	pushl  0xc(%ebp)
  801221:	ff 75 10             	pushl  0x10(%ebp)
  801224:	50                   	push   %eax
  801225:	8b 45 08             	mov    0x8(%ebp),%eax
  801228:	ff d0                	call   *%eax
  80122a:	83 c4 10             	add    $0x10,%esp
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  80122d:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  801231:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801235:	7f e0                	jg     801217 <vprintfmt+0x1cb>
                    putch(padc, putdat, fd);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  801237:	eb 3b                	jmp    801274 <vprintfmt+0x228>
                if (altflag && (ch < ' ' || ch > '~')) {
  801239:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80123d:	74 1f                	je     80125e <vprintfmt+0x212>
  80123f:	83 fb 1f             	cmp    $0x1f,%ebx
  801242:	7e 05                	jle    801249 <vprintfmt+0x1fd>
  801244:	83 fb 7e             	cmp    $0x7e,%ebx
  801247:	7e 15                	jle    80125e <vprintfmt+0x212>
                    putch('?', putdat, fd);
  801249:	83 ec 04             	sub    $0x4,%esp
  80124c:	ff 75 0c             	pushl  0xc(%ebp)
  80124f:	ff 75 10             	pushl  0x10(%ebp)
  801252:	6a 3f                	push   $0x3f
  801254:	8b 45 08             	mov    0x8(%ebp),%eax
  801257:	ff d0                	call   *%eax
  801259:	83 c4 10             	add    $0x10,%esp
  80125c:	eb 12                	jmp    801270 <vprintfmt+0x224>
                }
                else {
                    putch(ch, putdat, fd);
  80125e:	83 ec 04             	sub    $0x4,%esp
  801261:	ff 75 0c             	pushl  0xc(%ebp)
  801264:	ff 75 10             	pushl  0x10(%ebp)
  801267:	53                   	push   %ebx
  801268:	8b 45 08             	mov    0x8(%ebp),%eax
  80126b:	ff d0                	call   *%eax
  80126d:	83 c4 10             	add    $0x10,%esp
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat, fd);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  801270:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  801274:	89 f0                	mov    %esi,%eax
  801276:	8d 70 01             	lea    0x1(%eax),%esi
  801279:	0f b6 00             	movzbl (%eax),%eax
  80127c:	0f be d8             	movsbl %al,%ebx
  80127f:	85 db                	test   %ebx,%ebx
  801281:	74 29                	je     8012ac <vprintfmt+0x260>
  801283:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801287:	78 b0                	js     801239 <vprintfmt+0x1ed>
  801289:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80128d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801291:	79 a6                	jns    801239 <vprintfmt+0x1ed>
                }
                else {
                    putch(ch, putdat, fd);
                }
            }
            for (; width > 0; width --) {
  801293:	eb 17                	jmp    8012ac <vprintfmt+0x260>
                putch(' ', putdat, fd);
  801295:	83 ec 04             	sub    $0x4,%esp
  801298:	ff 75 0c             	pushl  0xc(%ebp)
  80129b:	ff 75 10             	pushl  0x10(%ebp)
  80129e:	6a 20                	push   $0x20
  8012a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a3:	ff d0                	call   *%eax
  8012a5:	83 c4 10             	add    $0x10,%esp
                }
                else {
                    putch(ch, putdat, fd);
                }
            }
            for (; width > 0; width --) {
  8012a8:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  8012ac:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8012b0:	7f e3                	jg     801295 <vprintfmt+0x249>
                putch(' ', putdat, fd);
            }
            break;
  8012b2:	e9 60 01 00 00       	jmp    801417 <vprintfmt+0x3cb>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  8012b7:	83 ec 08             	sub    $0x8,%esp
  8012ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8012bd:	8d 45 18             	lea    0x18(%ebp),%eax
  8012c0:	50                   	push   %eax
  8012c1:	e8 15 fd ff ff       	call   800fdb <getint>
  8012c6:	83 c4 10             	add    $0x10,%esp
  8012c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8012cc:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  8012cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d5:	85 d2                	test   %edx,%edx
  8012d7:	79 26                	jns    8012ff <vprintfmt+0x2b3>
                putch('-', putdat, fd);
  8012d9:	83 ec 04             	sub    $0x4,%esp
  8012dc:	ff 75 0c             	pushl  0xc(%ebp)
  8012df:	ff 75 10             	pushl  0x10(%ebp)
  8012e2:	6a 2d                	push   $0x2d
  8012e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e7:	ff d0                	call   *%eax
  8012e9:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
  8012ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012f2:	f7 d8                	neg    %eax
  8012f4:	83 d2 00             	adc    $0x0,%edx
  8012f7:	f7 da                	neg    %edx
  8012f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8012fc:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  8012ff:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  801306:	e9 a8 00 00 00       	jmp    8013b3 <vprintfmt+0x367>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  80130b:	83 ec 08             	sub    $0x8,%esp
  80130e:	ff 75 e0             	pushl  -0x20(%ebp)
  801311:	8d 45 18             	lea    0x18(%ebp),%eax
  801314:	50                   	push   %eax
  801315:	e8 72 fc ff ff       	call   800f8c <getuint>
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801320:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  801323:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  80132a:	e9 84 00 00 00       	jmp    8013b3 <vprintfmt+0x367>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  80132f:	83 ec 08             	sub    $0x8,%esp
  801332:	ff 75 e0             	pushl  -0x20(%ebp)
  801335:	8d 45 18             	lea    0x18(%ebp),%eax
  801338:	50                   	push   %eax
  801339:	e8 4e fc ff ff       	call   800f8c <getuint>
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801344:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  801347:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  80134e:	eb 63                	jmp    8013b3 <vprintfmt+0x367>

        // pointer
        case 'p':
            putch('0', putdat, fd);
  801350:	83 ec 04             	sub    $0x4,%esp
  801353:	ff 75 0c             	pushl  0xc(%ebp)
  801356:	ff 75 10             	pushl  0x10(%ebp)
  801359:	6a 30                	push   $0x30
  80135b:	8b 45 08             	mov    0x8(%ebp),%eax
  80135e:	ff d0                	call   *%eax
  801360:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat, fd);
  801363:	83 ec 04             	sub    $0x4,%esp
  801366:	ff 75 0c             	pushl  0xc(%ebp)
  801369:	ff 75 10             	pushl  0x10(%ebp)
  80136c:	6a 78                	push   $0x78
  80136e:	8b 45 08             	mov    0x8(%ebp),%eax
  801371:	ff d0                	call   *%eax
  801373:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  801376:	8b 45 18             	mov    0x18(%ebp),%eax
  801379:	8d 50 04             	lea    0x4(%eax),%edx
  80137c:	89 55 18             	mov    %edx,0x18(%ebp)
  80137f:	8b 00                	mov    (%eax),%eax
  801381:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801384:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  80138b:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  801392:	eb 1f                	jmp    8013b3 <vprintfmt+0x367>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  801394:	83 ec 08             	sub    $0x8,%esp
  801397:	ff 75 e0             	pushl  -0x20(%ebp)
  80139a:	8d 45 18             	lea    0x18(%ebp),%eax
  80139d:	50                   	push   %eax
  80139e:	e8 e9 fb ff ff       	call   800f8c <getuint>
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8013a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  8013ac:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, fd, putdat, num, base, width, padc);
  8013b3:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8013b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8013ba:	52                   	push   %edx
  8013bb:	ff 75 e8             	pushl  -0x18(%ebp)
  8013be:	50                   	push   %eax
  8013bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8013c2:	ff 75 f0             	pushl  -0x10(%ebp)
  8013c5:	ff 75 10             	pushl  0x10(%ebp)
  8013c8:	ff 75 0c             	pushl  0xc(%ebp)
  8013cb:	ff 75 08             	pushl  0x8(%ebp)
  8013ce:	e8 c2 fa ff ff       	call   800e95 <printnum>
  8013d3:	83 c4 20             	add    $0x20,%esp
            break;
  8013d6:	eb 3f                	jmp    801417 <vprintfmt+0x3cb>

        // escaped '%' character
        case '%':
            putch(ch, putdat, fd);
  8013d8:	83 ec 04             	sub    $0x4,%esp
  8013db:	ff 75 0c             	pushl  0xc(%ebp)
  8013de:	ff 75 10             	pushl  0x10(%ebp)
  8013e1:	53                   	push   %ebx
  8013e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e5:	ff d0                	call   *%eax
  8013e7:	83 c4 10             	add    $0x10,%esp
            break;
  8013ea:	eb 2b                	jmp    801417 <vprintfmt+0x3cb>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat, fd);
  8013ec:	83 ec 04             	sub    $0x4,%esp
  8013ef:	ff 75 0c             	pushl  0xc(%ebp)
  8013f2:	ff 75 10             	pushl  0x10(%ebp)
  8013f5:	6a 25                	push   $0x25
  8013f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fa:	ff d0                	call   *%eax
  8013fc:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
  8013ff:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
  801403:	eb 04                	jmp    801409 <vprintfmt+0x3bd>
  801405:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
  801409:	8b 45 14             	mov    0x14(%ebp),%eax
  80140c:	83 e8 01             	sub    $0x1,%eax
  80140f:	0f b6 00             	movzbl (%eax),%eax
  801412:	3c 25                	cmp    $0x25,%al
  801414:	75 ef                	jne    801405 <vprintfmt+0x3b9>
                /* do nothing */;
            break;
  801416:	90                   	nop
        }
    }
  801417:	e9 38 fc ff ff       	jmp    801054 <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
  80141c:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80141d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801420:	5b                   	pop    %ebx
  801421:	5e                   	pop    %esi
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    

00801424 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  801427:	8b 45 0c             	mov    0xc(%ebp),%eax
  80142a:	8b 40 08             	mov    0x8(%eax),%eax
  80142d:	8d 50 01             	lea    0x1(%eax),%edx
  801430:	8b 45 0c             	mov    0xc(%ebp),%eax
  801433:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  801436:	8b 45 0c             	mov    0xc(%ebp),%eax
  801439:	8b 10                	mov    (%eax),%edx
  80143b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143e:	8b 40 04             	mov    0x4(%eax),%eax
  801441:	39 c2                	cmp    %eax,%edx
  801443:	73 12                	jae    801457 <sprintputch+0x33>
        *b->buf ++ = ch;
  801445:	8b 45 0c             	mov    0xc(%ebp),%eax
  801448:	8b 00                	mov    (%eax),%eax
  80144a:	8d 48 01             	lea    0x1(%eax),%ecx
  80144d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801450:	89 0a                	mov    %ecx,(%edx)
  801452:	8b 55 08             	mov    0x8(%ebp),%edx
  801455:	88 10                	mov    %dl,(%eax)
    }
}
  801457:	90                   	nop
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  801460:	8d 45 14             	lea    0x14(%ebp),%eax
  801463:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  801466:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801469:	50                   	push   %eax
  80146a:	ff 75 10             	pushl  0x10(%ebp)
  80146d:	ff 75 0c             	pushl  0xc(%ebp)
  801470:	ff 75 08             	pushl  0x8(%ebp)
  801473:	e8 0b 00 00 00       	call   801483 <vsnprintf>
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  80147e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801481:	c9                   	leave  
  801482:	c3                   	ret    

00801483 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	83 ec 18             	sub    $0x18,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  801489:	8b 45 08             	mov    0x8(%ebp),%eax
  80148c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80148f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801492:	8d 50 ff             	lea    -0x1(%eax),%edx
  801495:	8b 45 08             	mov    0x8(%ebp),%eax
  801498:	01 d0                	add    %edx,%eax
  80149a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80149d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  8014a4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8014a8:	74 0a                	je     8014b4 <vsnprintf+0x31>
  8014aa:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8014ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b0:	39 c2                	cmp    %eax,%edx
  8014b2:	76 07                	jbe    8014bb <vsnprintf+0x38>
        return -E_INVAL;
  8014b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014b9:	eb 28                	jmp    8014e3 <vsnprintf+0x60>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, NO_FD, &b, fmt, ap);
  8014bb:	83 ec 0c             	sub    $0xc,%esp
  8014be:	ff 75 14             	pushl  0x14(%ebp)
  8014c1:	ff 75 10             	pushl  0x10(%ebp)
  8014c4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8014c7:	50                   	push   %eax
  8014c8:	68 d9 6a ff ff       	push   $0xffff6ad9
  8014cd:	68 24 14 80 00       	push   $0x801424
  8014d2:	e8 75 fb ff ff       	call   80104c <vprintfmt>
  8014d7:	83 c4 20             	add    $0x20,%esp
    // null terminate the buffer
    *b.buf = '\0';
  8014da:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8014dd:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  8014e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8014e3:	c9                   	leave  
  8014e4:	c3                   	ret    

008014e5 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
  8014eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ee:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
  8014f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
  8014f7:	b8 20 00 00 00       	mov    $0x20,%eax
  8014fc:	2b 45 0c             	sub    0xc(%ebp),%eax
  8014ff:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801502:	89 c1                	mov    %eax,%ecx
  801504:	d3 ea                	shr    %cl,%edx
  801506:	89 d0                	mov    %edx,%eax
}
  801508:	c9                   	leave  
  801509:	c3                   	ret    

0080150a <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	57                   	push   %edi
  80150e:	56                   	push   %esi
  80150f:	53                   	push   %ebx
  801510:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  801513:	a1 08 30 80 00       	mov    0x803008,%eax
  801518:	8b 15 0c 30 80 00    	mov    0x80300c,%edx
  80151e:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
  801524:	6b f0 05             	imul   $0x5,%eax,%esi
  801527:	01 fe                	add    %edi,%esi
  801529:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
  80152e:	f7 e7                	mul    %edi
  801530:	01 d6                	add    %edx,%esi
  801532:	89 f2                	mov    %esi,%edx
  801534:	83 c0 0b             	add    $0xb,%eax
  801537:	83 d2 00             	adc    $0x0,%edx
  80153a:	89 c7                	mov    %eax,%edi
  80153c:	83 e7 ff             	and    $0xffffffff,%edi
  80153f:	89 f9                	mov    %edi,%ecx
  801541:	0f b7 da             	movzwl %dx,%ebx
  801544:	89 0d 08 30 80 00    	mov    %ecx,0x803008
  80154a:	89 1d 0c 30 80 00    	mov    %ebx,0x80300c
    unsigned long long result = (next >> 12);
  801550:	a1 08 30 80 00       	mov    0x803008,%eax
  801555:	8b 15 0c 30 80 00    	mov    0x80300c,%edx
  80155b:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  80155f:	c1 ea 0c             	shr    $0xc,%edx
  801562:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801565:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
  801568:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
  80156f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801572:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801575:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801578:	89 55 e8             	mov    %edx,-0x18(%ebp)
  80157b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80157e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801581:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801585:	74 1c                	je     8015a3 <rand+0x99>
  801587:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80158a:	ba 00 00 00 00       	mov    $0x0,%edx
  80158f:	f7 75 dc             	divl   -0x24(%ebp)
  801592:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801595:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801598:	ba 00 00 00 00       	mov    $0x0,%edx
  80159d:	f7 75 dc             	divl   -0x24(%ebp)
  8015a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8015a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8015a6:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8015a9:	f7 75 dc             	divl   -0x24(%ebp)
  8015ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015af:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8015b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8015b5:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8015b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015bb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8015be:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  8015c1:	83 c4 24             	add    $0x24,%esp
  8015c4:	5b                   	pop    %ebx
  8015c5:	5e                   	pop    %esi
  8015c6:	5f                   	pop    %edi
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    

008015c9 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
    next = seed;
  8015cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d4:	a3 08 30 80 00       	mov    %eax,0x803008
  8015d9:	89 15 0c 30 80 00    	mov    %edx,0x80300c
}
  8015df:	90                   	nop
  8015e0:	5d                   	pop    %ebp
  8015e1:	c3                   	ret    

008015e2 <gettoken>:
#define SYMBOLS                         "<|>&;"

char shcwd[BUFSIZE];

int
gettoken(char **p1, char **p2) {
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	83 ec 18             	sub    $0x18,%esp
    char *s;
    if ((s = *p1) == NULL) {
  8015e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015eb:	8b 00                	mov    (%eax),%eax
  8015ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8015f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8015f4:	75 16                	jne    80160c <gettoken+0x2a>
        return 0;
  8015f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8015fb:	e9 f9 00 00 00       	jmp    8016f9 <gettoken+0x117>
    }
    while (strchr(WHITESPACE, *s) != NULL) {
        *s ++ = '\0';
  801600:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801603:	8d 50 01             	lea    0x1(%eax),%edx
  801606:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801609:	c6 00 00             	movb   $0x0,(%eax)
gettoken(char **p1, char **p2) {
    char *s;
    if ((s = *p1) == NULL) {
        return 0;
    }
    while (strchr(WHITESPACE, *s) != NULL) {
  80160c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80160f:	0f b6 00             	movzbl (%eax),%eax
  801612:	0f be c0             	movsbl %al,%eax
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	50                   	push   %eax
  801619:	68 40 22 80 00       	push   $0x802240
  80161e:	e8 28 f5 ff ff       	call   800b4b <strchr>
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	85 c0                	test   %eax,%eax
  801628:	75 d6                	jne    801600 <gettoken+0x1e>
        *s ++ = '\0';
    }
    if (*s == '\0') {
  80162a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162d:	0f b6 00             	movzbl (%eax),%eax
  801630:	84 c0                	test   %al,%al
  801632:	75 0a                	jne    80163e <gettoken+0x5c>
        return 0;
  801634:	b8 00 00 00 00       	mov    $0x0,%eax
  801639:	e9 bb 00 00 00       	jmp    8016f9 <gettoken+0x117>
    }

    *p2 = s;
  80163e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801641:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801644:	89 10                	mov    %edx,(%eax)
    int token = 'w';
  801646:	c7 45 f0 77 00 00 00 	movl   $0x77,-0x10(%ebp)
    if (strchr(SYMBOLS, *s) != NULL) {
  80164d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801650:	0f b6 00             	movzbl (%eax),%eax
  801653:	0f be c0             	movsbl %al,%eax
  801656:	83 ec 08             	sub    $0x8,%esp
  801659:	50                   	push   %eax
  80165a:	68 45 22 80 00       	push   $0x802245
  80165f:	e8 e7 f4 ff ff       	call   800b4b <strchr>
  801664:	83 c4 10             	add    $0x10,%esp
  801667:	85 c0                	test   %eax,%eax
  801669:	74 1a                	je     801685 <gettoken+0xa3>
        token = *s, *s ++ = '\0';
  80166b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166e:	0f b6 00             	movzbl (%eax),%eax
  801671:	0f be c0             	movsbl %al,%eax
  801674:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801677:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167a:	8d 50 01             	lea    0x1(%eax),%edx
  80167d:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801680:	c6 00 00             	movb   $0x0,(%eax)
  801683:	eb 58                	jmp    8016dd <gettoken+0xfb>
    }
    else {
        bool flag = 0;
  801685:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
        while (*s != '\0' && (flag || strchr(WHITESPACE SYMBOLS, *s) == NULL)) {
  80168c:	eb 21                	jmp    8016af <gettoken+0xcd>
            if (*s == '"') {
  80168e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801691:	0f b6 00             	movzbl (%eax),%eax
  801694:	3c 22                	cmp    $0x22,%al
  801696:	75 13                	jne    8016ab <gettoken+0xc9>
                *s = ' ', flag = !flag;
  801698:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169b:	c6 00 20             	movb   $0x20,(%eax)
  80169e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8016a2:	0f 94 c0             	sete   %al
  8016a5:	0f b6 c0             	movzbl %al,%eax
  8016a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
            }
            s ++;
  8016ab:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if (strchr(SYMBOLS, *s) != NULL) {
        token = *s, *s ++ = '\0';
    }
    else {
        bool flag = 0;
        while (*s != '\0' && (flag || strchr(WHITESPACE SYMBOLS, *s) == NULL)) {
  8016af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b2:	0f b6 00             	movzbl (%eax),%eax
  8016b5:	84 c0                	test   %al,%al
  8016b7:	74 24                	je     8016dd <gettoken+0xfb>
  8016b9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8016bd:	75 cf                	jne    80168e <gettoken+0xac>
  8016bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c2:	0f b6 00             	movzbl (%eax),%eax
  8016c5:	0f be c0             	movsbl %al,%eax
  8016c8:	83 ec 08             	sub    $0x8,%esp
  8016cb:	50                   	push   %eax
  8016cc:	68 4b 22 80 00       	push   $0x80224b
  8016d1:	e8 75 f4 ff ff       	call   800b4b <strchr>
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	74 b1                	je     80168e <gettoken+0xac>
                *s = ' ', flag = !flag;
            }
            s ++;
        }
    }
    *p1 = (*s != '\0' ? s : NULL);
  8016dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e0:	0f b6 00             	movzbl (%eax),%eax
  8016e3:	84 c0                	test   %al,%al
  8016e5:	74 05                	je     8016ec <gettoken+0x10a>
  8016e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ea:	eb 05                	jmp    8016f1 <gettoken+0x10f>
  8016ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8016f4:	89 02                	mov    %eax,(%edx)
    return token;
  8016f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8016f9:	c9                   	leave  
  8016fa:	c3                   	ret    

008016fb <readline>:

char *
readline(const char *prompt) {
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	83 ec 18             	sub    $0x18,%esp
    static char buffer[BUFSIZE];
    if (prompt != NULL) {
  801701:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801705:	74 15                	je     80171c <readline+0x21>
        printf("%s", prompt);
  801707:	83 ec 04             	sub    $0x4,%esp
  80170a:	ff 75 08             	pushl  0x8(%ebp)
  80170d:	68 55 22 80 00       	push   $0x802255
  801712:	6a 01                	push   $0x1
  801714:	e8 8f ef ff ff       	call   8006a8 <fprintf>
  801719:	83 c4 10             	add    $0x10,%esp
    }
    int ret, i = 0;
  80171c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        char c;
        if ((ret = read(0, &c, sizeof(char))) < 0) {
  801723:	83 ec 04             	sub    $0x4,%esp
  801726:	6a 01                	push   $0x1
  801728:	8d 45 ef             	lea    -0x11(%ebp),%eax
  80172b:	50                   	push   %eax
  80172c:	6a 00                	push   $0x0
  80172e:	e8 a8 ec ff ff       	call   8003db <read>
  801733:	83 c4 10             	add    $0x10,%esp
  801736:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801739:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80173d:	79 0a                	jns    801749 <readline+0x4e>
            return NULL;
  80173f:	b8 00 00 00 00       	mov    $0x0,%eax
  801744:	e9 eb 00 00 00       	jmp    801834 <readline+0x139>
        }
        else if (ret == 0) {
  801749:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80174d:	75 20                	jne    80176f <readline+0x74>
            if (i > 0) {
  80174f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801753:	7e 10                	jle    801765 <readline+0x6a>
                buffer[i] = '\0';
  801755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801758:	05 40 30 80 00       	add    $0x803040,%eax
  80175d:	c6 00 00             	movb   $0x0,(%eax)
                break;
  801760:	e9 ca 00 00 00       	jmp    80182f <readline+0x134>
            }
            return NULL;
  801765:	b8 00 00 00 00       	mov    $0x0,%eax
  80176a:	e9 c5 00 00 00       	jmp    801834 <readline+0x139>
        }

        if (c == 3) {
  80176f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  801773:	3c 03                	cmp    $0x3,%al
  801775:	75 0a                	jne    801781 <readline+0x86>
            return NULL;
  801777:	b8 00 00 00 00       	mov    $0x0,%eax
  80177c:	e9 b3 00 00 00       	jmp    801834 <readline+0x139>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  801781:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  801785:	3c 1f                	cmp    $0x1f,%al
  801787:	7e 38                	jle    8017c1 <readline+0xc6>
  801789:	81 7d f4 fe 0f 00 00 	cmpl   $0xffe,-0xc(%ebp)
  801790:	7f 2f                	jg     8017c1 <readline+0xc6>
            putc(c);
  801792:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  801796:	0f be c0             	movsbl %al,%eax
  801799:	83 ec 04             	sub    $0x4,%esp
  80179c:	50                   	push   %eax
  80179d:	68 58 22 80 00       	push   $0x802258
  8017a2:	6a 01                	push   $0x1
  8017a4:	e8 ff ee ff ff       	call   8006a8 <fprintf>
  8017a9:	83 c4 10             	add    $0x10,%esp
            buffer[i ++] = c;
  8017ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017af:	8d 50 01             	lea    0x1(%eax),%edx
  8017b2:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8017b5:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
  8017b9:	88 90 40 30 80 00    	mov    %dl,0x803040(%eax)
  8017bf:	eb 69                	jmp    80182a <readline+0x12f>
        }
        else if (c == '\b' && i > 0) {
  8017c1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  8017c5:	3c 08                	cmp    $0x8,%al
  8017c7:	75 26                	jne    8017ef <readline+0xf4>
  8017c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8017cd:	7e 20                	jle    8017ef <readline+0xf4>
            putc(c);
  8017cf:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  8017d3:	0f be c0             	movsbl %al,%eax
  8017d6:	83 ec 04             	sub    $0x4,%esp
  8017d9:	50                   	push   %eax
  8017da:	68 58 22 80 00       	push   $0x802258
  8017df:	6a 01                	push   $0x1
  8017e1:	e8 c2 ee ff ff       	call   8006a8 <fprintf>
  8017e6:	83 c4 10             	add    $0x10,%esp
            i --;
  8017e9:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  8017ed:	eb 3b                	jmp    80182a <readline+0x12f>
        }
        else if (c == '\n' || c == '\r') {
  8017ef:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  8017f3:	3c 0a                	cmp    $0xa,%al
  8017f5:	74 0c                	je     801803 <readline+0x108>
  8017f7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  8017fb:	3c 0d                	cmp    $0xd,%al
  8017fd:	0f 85 20 ff ff ff    	jne    801723 <readline+0x28>
            putc(c);
  801803:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  801807:	0f be c0             	movsbl %al,%eax
  80180a:	83 ec 04             	sub    $0x4,%esp
  80180d:	50                   	push   %eax
  80180e:	68 58 22 80 00       	push   $0x802258
  801813:	6a 01                	push   $0x1
  801815:	e8 8e ee ff ff       	call   8006a8 <fprintf>
  80181a:	83 c4 10             	add    $0x10,%esp
            buffer[i] = '\0';
  80181d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801820:	05 40 30 80 00       	add    $0x803040,%eax
  801825:	c6 00 00             	movb   $0x0,(%eax)
            break;
  801828:	eb 05                	jmp    80182f <readline+0x134>
        }
    }
  80182a:	e9 f4 fe ff ff       	jmp    801723 <readline+0x28>
    return buffer;
  80182f:	b8 40 30 80 00       	mov    $0x803040,%eax
}
  801834:	c9                   	leave  
  801835:	c3                   	ret    

00801836 <usage>:

void
usage(void) {
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	83 ec 08             	sub    $0x8,%esp
    printf("usage: sh [command-file]\n");
  80183c:	83 ec 08             	sub    $0x8,%esp
  80183f:	68 5b 22 80 00       	push   $0x80225b
  801844:	6a 01                	push   $0x1
  801846:	e8 5d ee ff ff       	call   8006a8 <fprintf>
  80184b:	83 c4 10             	add    $0x10,%esp
}
  80184e:	90                   	nop
  80184f:	c9                   	leave  
  801850:	c3                   	ret    

00801851 <reopen>:

int
reopen(int fd2, const char *filename, uint32_t open_flags) {
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	83 ec 18             	sub    $0x18,%esp
    int ret, fd1;
    close(fd2);
  801857:	83 ec 0c             	sub    $0xc,%esp
  80185a:	ff 75 08             	pushl  0x8(%ebp)
  80185d:	e8 63 eb ff ff       	call   8003c5 <close>
  801862:	83 c4 10             	add    $0x10,%esp
    if ((ret = open(filename, open_flags)) >= 0 && ret != fd2) {
  801865:	83 ec 08             	sub    $0x8,%esp
  801868:	ff 75 10             	pushl  0x10(%ebp)
  80186b:	ff 75 0c             	pushl  0xc(%ebp)
  80186e:	e8 39 eb ff ff       	call   8003ac <open>
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801879:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80187d:	78 3e                	js     8018bd <reopen+0x6c>
  80187f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801882:	3b 45 08             	cmp    0x8(%ebp),%eax
  801885:	74 36                	je     8018bd <reopen+0x6c>
        close(fd2);
  801887:	83 ec 0c             	sub    $0xc,%esp
  80188a:	ff 75 08             	pushl  0x8(%ebp)
  80188d:	e8 33 eb ff ff       	call   8003c5 <close>
  801892:	83 c4 10             	add    $0x10,%esp
        fd1 = ret, ret = dup2(fd1, fd2);
  801895:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801898:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80189b:	83 ec 08             	sub    $0x8,%esp
  80189e:	ff 75 08             	pushl  0x8(%ebp)
  8018a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8018a4:	e8 b5 eb ff ff       	call   80045e <dup2>
  8018a9:	83 c4 10             	add    $0x10,%esp
  8018ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
        close(fd1);
  8018af:	83 ec 0c             	sub    $0xc,%esp
  8018b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8018b5:	e8 0b eb ff ff       	call   8003c5 <close>
  8018ba:	83 c4 10             	add    $0x10,%esp
    }
    return ret < 0 ? ret : 0;
  8018bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8018c6:	0f 4e 45 f4          	cmovle -0xc(%ebp),%eax
}
  8018ca:	c9                   	leave  
  8018cb:	c3                   	ret    

008018cc <testfile>:

int
testfile(const char *name) {
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	83 ec 18             	sub    $0x18,%esp
    int ret;
    if ((ret = open(name, O_RDONLY)) < 0) {
  8018d2:	83 ec 08             	sub    $0x8,%esp
  8018d5:	6a 00                	push   $0x0
  8018d7:	ff 75 08             	pushl  0x8(%ebp)
  8018da:	e8 cd ea ff ff       	call   8003ac <open>
  8018df:	83 c4 10             	add    $0x10,%esp
  8018e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8018e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8018e9:	79 05                	jns    8018f0 <testfile+0x24>
        return ret;
  8018eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ee:	eb 13                	jmp    801903 <testfile+0x37>
    }
    close(ret);
  8018f0:	83 ec 0c             	sub    $0xc,%esp
  8018f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f6:	e8 ca ea ff ff       	call   8003c5 <close>
  8018fb:	83 c4 10             	add    $0x10,%esp
    return 0;
  8018fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801903:	c9                   	leave  
  801904:	c3                   	ret    

00801905 <runcmd>:

int
runcmd(char *cmd) {
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	81 ec a8 00 00 00    	sub    $0xa8,%esp
    static char argv0[BUFSIZE];
    const char *argv[EXEC_MAX_ARG_NUM + 1];
    char *t;
    int argc, token, ret, p[2];
again:
    argc = 0;
  80190e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        switch (token = gettoken(&cmd, &t)) {
  801915:	83 ec 08             	sub    $0x8,%esp
  801918:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  80191e:	50                   	push   %eax
  80191f:	8d 45 08             	lea    0x8(%ebp),%eax
  801922:	50                   	push   %eax
  801923:	e8 ba fc ff ff       	call   8015e2 <gettoken>
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80192e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801931:	83 f8 3c             	cmp    $0x3c,%eax
  801934:	74 74                	je     8019aa <runcmd+0xa5>
  801936:	83 f8 3c             	cmp    $0x3c,%eax
  801939:	7f 16                	jg     801951 <runcmd+0x4c>
  80193b:	85 c0                	test   %eax,%eax
  80193d:	0f 84 56 02 00 00    	je     801b99 <runcmd+0x294>
  801943:	83 f8 3b             	cmp    $0x3b,%eax
  801946:	0f 84 f1 01 00 00    	je     801b3d <runcmd+0x238>
  80194c:	e9 1d 02 00 00       	jmp    801b6e <runcmd+0x269>
  801951:	83 f8 77             	cmp    $0x77,%eax
  801954:	74 17                	je     80196d <runcmd+0x68>
  801956:	83 f8 7c             	cmp    $0x7c,%eax
  801959:	0f 84 0f 01 00 00    	je     801a6e <runcmd+0x169>
  80195f:	83 f8 3e             	cmp    $0x3e,%eax
  801962:	0f 84 a4 00 00 00    	je     801a0c <runcmd+0x107>
  801968:	e9 01 02 00 00       	jmp    801b6e <runcmd+0x269>
        case 'w':
            if (argc == EXEC_MAX_ARG_NUM) {
  80196d:	83 7d f4 20          	cmpl   $0x20,-0xc(%ebp)
  801971:	75 1c                	jne    80198f <runcmd+0x8a>
                printf("sh error: too many arguments\n");
  801973:	83 ec 08             	sub    $0x8,%esp
  801976:	68 75 22 80 00       	push   $0x802275
  80197b:	6a 01                	push   $0x1
  80197d:	e8 26 ed ff ff       	call   8006a8 <fprintf>
  801982:	83 c4 10             	add    $0x10,%esp
                return -1;
  801985:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80198a:	e9 d7 02 00 00       	jmp    801c66 <runcmd+0x361>
            }
            argv[argc ++] = t;
  80198f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801992:	8d 50 01             	lea    0x1(%eax),%edx
  801995:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801998:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
  80199e:	89 94 85 68 ff ff ff 	mov    %edx,-0x98(%ebp,%eax,4)
            break;
  8019a5:	e9 ea 01 00 00       	jmp    801b94 <runcmd+0x28f>
        case '<':
            if (gettoken(&cmd, &t) != 'w') {
  8019aa:	83 ec 08             	sub    $0x8,%esp
  8019ad:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  8019b3:	50                   	push   %eax
  8019b4:	8d 45 08             	lea    0x8(%ebp),%eax
  8019b7:	50                   	push   %eax
  8019b8:	e8 25 fc ff ff       	call   8015e2 <gettoken>
  8019bd:	83 c4 10             	add    $0x10,%esp
  8019c0:	83 f8 77             	cmp    $0x77,%eax
  8019c3:	74 1c                	je     8019e1 <runcmd+0xdc>
                printf("sh error: syntax error: < not followed by word\n");
  8019c5:	83 ec 08             	sub    $0x8,%esp
  8019c8:	68 94 22 80 00       	push   $0x802294
  8019cd:	6a 01                	push   $0x1
  8019cf:	e8 d4 ec ff ff       	call   8006a8 <fprintf>
  8019d4:	83 c4 10             	add    $0x10,%esp
                return -1;
  8019d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8019dc:	e9 85 02 00 00       	jmp    801c66 <runcmd+0x361>
            }
            if ((ret = reopen(0, t, O_RDONLY)) != 0) {
  8019e1:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  8019e7:	83 ec 04             	sub    $0x4,%esp
  8019ea:	6a 00                	push   $0x0
  8019ec:	50                   	push   %eax
  8019ed:	6a 00                	push   $0x0
  8019ef:	e8 5d fe ff ff       	call   801851 <reopen>
  8019f4:	83 c4 10             	add    $0x10,%esp
  8019f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8019fa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8019fe:	0f 84 89 01 00 00    	je     801b8d <runcmd+0x288>
                return ret;
  801a04:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a07:	e9 5a 02 00 00       	jmp    801c66 <runcmd+0x361>
            }
            break;
        case '>':
            if (gettoken(&cmd, &t) != 'w') {
  801a0c:	83 ec 08             	sub    $0x8,%esp
  801a0f:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  801a15:	50                   	push   %eax
  801a16:	8d 45 08             	lea    0x8(%ebp),%eax
  801a19:	50                   	push   %eax
  801a1a:	e8 c3 fb ff ff       	call   8015e2 <gettoken>
  801a1f:	83 c4 10             	add    $0x10,%esp
  801a22:	83 f8 77             	cmp    $0x77,%eax
  801a25:	74 1c                	je     801a43 <runcmd+0x13e>
                printf("sh error: syntax error: > not followed by word\n");
  801a27:	83 ec 08             	sub    $0x8,%esp
  801a2a:	68 c4 22 80 00       	push   $0x8022c4
  801a2f:	6a 01                	push   $0x1
  801a31:	e8 72 ec ff ff       	call   8006a8 <fprintf>
  801a36:	83 c4 10             	add    $0x10,%esp
                return -1;
  801a39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801a3e:	e9 23 02 00 00       	jmp    801c66 <runcmd+0x361>
            }
            if ((ret = reopen(1, t, O_RDWR | O_TRUNC | O_CREAT)) != 0) {
  801a43:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  801a49:	83 ec 04             	sub    $0x4,%esp
  801a4c:	6a 16                	push   $0x16
  801a4e:	50                   	push   %eax
  801a4f:	6a 01                	push   $0x1
  801a51:	e8 fb fd ff ff       	call   801851 <reopen>
  801a56:	83 c4 10             	add    $0x10,%esp
  801a59:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a5c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801a60:	0f 84 2d 01 00 00    	je     801b93 <runcmd+0x28e>
                return ret;
  801a66:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a69:	e9 f8 01 00 00       	jmp    801c66 <runcmd+0x361>
            break;
        case '|':
          //  if ((ret = pipe(p)) != 0) {
          //      return ret;
          //  }
            if ((ret = fork()) == 0) {
  801a6e:	e8 49 ee ff ff       	call   8008bc <fork>
  801a73:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a76:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801a7a:	75 5b                	jne    801ad7 <runcmd+0x1d2>
                close(0);
  801a7c:	83 ec 0c             	sub    $0xc,%esp
  801a7f:	6a 00                	push   $0x0
  801a81:	e8 3f e9 ff ff       	call   8003c5 <close>
  801a86:	83 c4 10             	add    $0x10,%esp
                if ((ret = dup2(p[0], 0)) < 0) {
  801a89:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801a8f:	83 ec 08             	sub    $0x8,%esp
  801a92:	6a 00                	push   $0x0
  801a94:	50                   	push   %eax
  801a95:	e8 c4 e9 ff ff       	call   80045e <dup2>
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801aa0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801aa4:	79 08                	jns    801aae <runcmd+0x1a9>
                    return ret;
  801aa6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801aa9:	e9 b8 01 00 00       	jmp    801c66 <runcmd+0x361>
                }
                close(p[0]), close(p[1]);
  801aae:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801ab4:	83 ec 0c             	sub    $0xc,%esp
  801ab7:	50                   	push   %eax
  801ab8:	e8 08 e9 ff ff       	call   8003c5 <close>
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  801ac6:	83 ec 0c             	sub    $0xc,%esp
  801ac9:	50                   	push   %eax
  801aca:	e8 f6 e8 ff ff       	call   8003c5 <close>
  801acf:	83 c4 10             	add    $0x10,%esp
                goto again;
  801ad2:	e9 37 fe ff ff       	jmp    80190e <runcmd+0x9>
            }
            else {
                if (ret < 0) {
  801ad7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801adb:	79 08                	jns    801ae5 <runcmd+0x1e0>
                    return ret;
  801add:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ae0:	e9 81 01 00 00       	jmp    801c66 <runcmd+0x361>
                }
                close(1);
  801ae5:	83 ec 0c             	sub    $0xc,%esp
  801ae8:	6a 01                	push   $0x1
  801aea:	e8 d6 e8 ff ff       	call   8003c5 <close>
  801aef:	83 c4 10             	add    $0x10,%esp
                if ((ret = dup2(p[1], 1)) < 0) {
  801af2:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  801af8:	83 ec 08             	sub    $0x8,%esp
  801afb:	6a 01                	push   $0x1
  801afd:	50                   	push   %eax
  801afe:	e8 5b e9 ff ff       	call   80045e <dup2>
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b09:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801b0d:	79 08                	jns    801b17 <runcmd+0x212>
                    return ret;
  801b0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b12:	e9 4f 01 00 00       	jmp    801c66 <runcmd+0x361>
                }
                close(p[0]), close(p[1]);
  801b17:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801b1d:	83 ec 0c             	sub    $0xc,%esp
  801b20:	50                   	push   %eax
  801b21:	e8 9f e8 ff ff       	call   8003c5 <close>
  801b26:	83 c4 10             	add    $0x10,%esp
  801b29:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  801b2f:	83 ec 0c             	sub    $0xc,%esp
  801b32:	50                   	push   %eax
  801b33:	e8 8d e8 ff ff       	call   8003c5 <close>
  801b38:	83 c4 10             	add    $0x10,%esp
                goto runit;
  801b3b:	eb 60                	jmp    801b9d <runcmd+0x298>
            }
            break;
        case 0:
            goto runit;
        case ';':
            if ((ret = fork()) == 0) {
  801b3d:	e8 7a ed ff ff       	call   8008bc <fork>
  801b42:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b45:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801b49:	74 51                	je     801b9c <runcmd+0x297>
                goto runit;
            }
            else {
                if (ret < 0) {
  801b4b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801b4f:	79 08                	jns    801b59 <runcmd+0x254>
                    return ret;
  801b51:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b54:	e9 0d 01 00 00       	jmp    801c66 <runcmd+0x361>
                }
                waitpid(ret, NULL);
  801b59:	83 ec 08             	sub    $0x8,%esp
  801b5c:	6a 00                	push   $0x0
  801b5e:	ff 75 ec             	pushl  -0x14(%ebp)
  801b61:	e8 7a ed ff ff       	call   8008e0 <waitpid>
  801b66:	83 c4 10             	add    $0x10,%esp
                goto again;
  801b69:	e9 a0 fd ff ff       	jmp    80190e <runcmd+0x9>
            }
            break;
        default:
            printf("sh error: bad return %d from gettoken\n", token);
  801b6e:	83 ec 04             	sub    $0x4,%esp
  801b71:	ff 75 f0             	pushl  -0x10(%ebp)
  801b74:	68 f4 22 80 00       	push   $0x8022f4
  801b79:	6a 01                	push   $0x1
  801b7b:	e8 28 eb ff ff       	call   8006a8 <fprintf>
  801b80:	83 c4 10             	add    $0x10,%esp
            return -1;
  801b83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b88:	e9 d9 00 00 00       	jmp    801c66 <runcmd+0x361>
                return -1;
            }
            if ((ret = reopen(0, t, O_RDONLY)) != 0) {
                return ret;
            }
            break;
  801b8d:	90                   	nop
  801b8e:	e9 82 fd ff ff       	jmp    801915 <runcmd+0x10>
                return -1;
            }
            if ((ret = reopen(1, t, O_RDWR | O_TRUNC | O_CREAT)) != 0) {
                return ret;
            }
            break;
  801b93:	90                   	nop
            break;
        default:
            printf("sh error: bad return %d from gettoken\n", token);
            return -1;
        }
    }
  801b94:	e9 7c fd ff ff       	jmp    801915 <runcmd+0x10>
                close(p[0]), close(p[1]);
                goto runit;
            }
            break;
        case 0:
            goto runit;
  801b99:	90                   	nop
  801b9a:	eb 01                	jmp    801b9d <runcmd+0x298>
        case ';':
            if ((ret = fork()) == 0) {
                goto runit;
  801b9c:	90                   	nop
            return -1;
        }
    }

runit:
    if (argc == 0) {
  801b9d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801ba1:	75 0a                	jne    801bad <runcmd+0x2a8>
        return 0;
  801ba3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba8:	e9 b9 00 00 00       	jmp    801c66 <runcmd+0x361>
    }
    else if (strcmp(argv[0], "cd") == 0) {
  801bad:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  801bb3:	83 ec 08             	sub    $0x8,%esp
  801bb6:	68 1b 23 80 00       	push   $0x80231b
  801bbb:	50                   	push   %eax
  801bbc:	e8 ea ee ff ff       	call   800aab <strcmp>
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	75 2e                	jne    801bf6 <runcmd+0x2f1>
        if (argc != 2) {
  801bc8:	83 7d f4 02          	cmpl   $0x2,-0xc(%ebp)
  801bcc:	74 0a                	je     801bd8 <runcmd+0x2d3>
            return -1;
  801bce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801bd3:	e9 8e 00 00 00       	jmp    801c66 <runcmd+0x361>
        }
        strcpy(shcwd, argv[1]);
  801bd8:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
  801bde:	83 ec 08             	sub    $0x8,%esp
  801be1:	50                   	push   %eax
  801be2:	68 60 51 80 00       	push   $0x805160
  801be7:	e8 45 ee ff ff       	call   800a31 <strcpy>
  801bec:	83 c4 10             	add    $0x10,%esp
        return 0;
  801bef:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf4:	eb 70                	jmp    801c66 <runcmd+0x361>
    }
    if ((ret = testfile(argv[0])) != 0) {
  801bf6:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  801bfc:	83 ec 0c             	sub    $0xc,%esp
  801bff:	50                   	push   %eax
  801c00:	e8 c7 fc ff ff       	call   8018cc <testfile>
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c0b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801c0f:	74 33                	je     801c44 <runcmd+0x33f>
        if (ret != -E_NOENT) {
  801c11:	83 7d ec f0          	cmpl   $0xfffffff0,-0x14(%ebp)
  801c15:	74 05                	je     801c1c <runcmd+0x317>
            return ret;
  801c17:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c1a:	eb 4a                	jmp    801c66 <runcmd+0x361>
        }
        snprintf(argv0, sizeof(argv0), "/%s", argv[0]);
  801c1c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  801c22:	50                   	push   %eax
  801c23:	68 1e 23 80 00       	push   $0x80231e
  801c28:	68 00 10 00 00       	push   $0x1000
  801c2d:	68 40 40 80 00       	push   $0x804040
  801c32:	e8 23 f8 ff ff       	call   80145a <snprintf>
  801c37:	83 c4 10             	add    $0x10,%esp
        argv[0] = argv0;
  801c3a:	c7 85 68 ff ff ff 40 	movl   $0x804040,-0x98(%ebp)
  801c41:	40 80 00 
    }
    argv[argc] = NULL;
  801c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c47:	c7 84 85 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%eax,4)
  801c4e:	00 00 00 00 
    return __exec(NULL, argv);
  801c52:	83 ec 08             	sub    $0x8,%esp
  801c55:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801c5b:	50                   	push   %eax
  801c5c:	6a 00                	push   $0x0
  801c5e:	e8 0f ed ff ff       	call   800972 <__exec>
  801c63:	83 c4 10             	add    $0x10,%esp
}
  801c66:	c9                   	leave  
  801c67:	c3                   	ret    

00801c68 <main>:

int
main(int argc, char **argv) {
  801c68:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  801c6c:	83 e4 f0             	and    $0xfffffff0,%esp
  801c6f:	ff 71 fc             	pushl  -0x4(%ecx)
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	53                   	push   %ebx
  801c76:	51                   	push   %ecx
  801c77:	83 ec 10             	sub    $0x10,%esp
  801c7a:	89 cb                	mov    %ecx,%ebx
    printf("user sh is running!!!");
  801c7c:	83 ec 08             	sub    $0x8,%esp
  801c7f:	68 22 23 80 00       	push   $0x802322
  801c84:	6a 01                	push   $0x1
  801c86:	e8 1d ea ff ff       	call   8006a8 <fprintf>
  801c8b:	83 c4 10             	add    $0x10,%esp
    int ret, interactive = 1;
  801c8e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    if (argc == 2) {
  801c95:	83 3b 02             	cmpl   $0x2,(%ebx)
  801c98:	75 36                	jne    801cd0 <main+0x68>
        if ((ret = reopen(0, argv[1], O_RDONLY)) != 0) {
  801c9a:	8b 43 04             	mov    0x4(%ebx),%eax
  801c9d:	83 c0 04             	add    $0x4,%eax
  801ca0:	8b 00                	mov    (%eax),%eax
  801ca2:	83 ec 04             	sub    $0x4,%esp
  801ca5:	6a 00                	push   $0x0
  801ca7:	50                   	push   %eax
  801ca8:	6a 00                	push   $0x0
  801caa:	e8 a2 fb ff ff       	call   801851 <reopen>
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  801cb5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	74 08                	je     801cc4 <main+0x5c>
            return ret;
  801cbc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801cbf:	e9 f2 00 00 00       	jmp    801db6 <main+0x14e>
        }
        interactive = 0;
  801cc4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  801ccb:	e9 b6 00 00 00       	jmp    801d86 <main+0x11e>
    }
    else if (argc > 2) {
  801cd0:	83 3b 02             	cmpl   $0x2,(%ebx)
  801cd3:	0f 8e ad 00 00 00    	jle    801d86 <main+0x11e>
        usage();
  801cd9:	e8 58 fb ff ff       	call   801836 <usage>
        return -1;
  801cde:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ce3:	e9 ce 00 00 00       	jmp    801db6 <main+0x14e>
    //shcwd = malloc(BUFSIZE);
    assert(shcwd != NULL);

    char *buffer;
    while ((buffer = readline((interactive) ? "$ " : NULL)) != NULL) {
        shcwd[0] = '\0';
  801ce8:	c6 05 60 51 80 00 00 	movb   $0x0,0x805160
        int pid;
        if ((pid = fork()) == 0) {
  801cef:	e8 c8 eb ff ff       	call   8008bc <fork>
  801cf4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cf7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801cfb:	75 1d                	jne    801d1a <main+0xb2>
            ret = runcmd(buffer);
  801cfd:	83 ec 0c             	sub    $0xc,%esp
  801d00:	ff 75 f0             	pushl  -0x10(%ebp)
  801d03:	e8 fd fb ff ff       	call   801905 <runcmd>
  801d08:	83 c4 10             	add    $0x10,%esp
  801d0b:	89 45 e8             	mov    %eax,-0x18(%ebp)
            exit(ret);
  801d0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d11:	83 ec 0c             	sub    $0xc,%esp
  801d14:	50                   	push   %eax
  801d15:	e8 7c eb ff ff       	call   800896 <exit>
        }
        assert(pid >= 0);
  801d1a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801d1e:	79 19                	jns    801d39 <main+0xd1>
  801d20:	68 38 23 80 00       	push   $0x802338
  801d25:	68 41 23 80 00       	push   $0x802341
  801d2a:	68 f2 00 00 00       	push   $0xf2
  801d2f:	68 56 23 80 00       	push   $0x802356
  801d34:	e8 e7 e2 ff ff       	call   800020 <__panic>
        if (waitpid(pid, &ret) == 0) {
  801d39:	83 ec 08             	sub    $0x8,%esp
  801d3c:	8d 45 e8             	lea    -0x18(%ebp),%eax
  801d3f:	50                   	push   %eax
  801d40:	ff 75 ec             	pushl  -0x14(%ebp)
  801d43:	e8 98 eb ff ff       	call   8008e0 <waitpid>
  801d48:	83 c4 10             	add    $0x10,%esp
  801d4b:	85 c0                	test   %eax,%eax
  801d4d:	75 37                	jne    801d86 <main+0x11e>
            if (ret == 0 && shcwd[0] != '\0') {
  801d4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d52:	85 c0                	test   %eax,%eax
  801d54:	75 12                	jne    801d68 <main+0x100>
  801d56:	0f b6 05 60 51 80 00 	movzbl 0x805160,%eax
  801d5d:	84 c0                	test   %al,%al
  801d5f:	74 07                	je     801d68 <main+0x100>
                ret = 0;
  801d61:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            }
            if (ret != 0) {
  801d68:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	74 17                	je     801d86 <main+0x11e>
                printf("error: %d - %e\n", ret, ret);
  801d6f:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801d72:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801d75:	52                   	push   %edx
  801d76:	50                   	push   %eax
  801d77:	68 60 23 80 00       	push   $0x802360
  801d7c:	6a 01                	push   $0x1
  801d7e:	e8 25 e9 ff ff       	call   8006a8 <fprintf>
  801d83:	83 c4 10             	add    $0x10,%esp
    }
    //shcwd = malloc(BUFSIZE);
    assert(shcwd != NULL);

    char *buffer;
    while ((buffer = readline((interactive) ? "$ " : NULL)) != NULL) {
  801d86:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  801d8a:	74 07                	je     801d93 <main+0x12b>
  801d8c:	b8 70 23 80 00       	mov    $0x802370,%eax
  801d91:	eb 05                	jmp    801d98 <main+0x130>
  801d93:	b8 00 00 00 00       	mov    $0x0,%eax
  801d98:	83 ec 0c             	sub    $0xc,%esp
  801d9b:	50                   	push   %eax
  801d9c:	e8 5a f9 ff ff       	call   8016fb <readline>
  801da1:	83 c4 10             	add    $0x10,%esp
  801da4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801da7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801dab:	0f 85 37 ff ff ff    	jne    801ce8 <main+0x80>
            if (ret != 0) {
                printf("error: %d - %e\n", ret, ret);
            }
        }
    }
    return 0;
  801db1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801db6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db9:	59                   	pop    %ecx
  801dba:	5b                   	pop    %ebx
  801dbb:	5d                   	pop    %ebp
  801dbc:	8d 61 fc             	lea    -0x4(%ecx),%esp
  801dbf:	c3                   	ret    
