
obj/__user_waitkill.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  800020:	14a000ef          	jal	ra,80016a <umain>
1:  j 1b
  800024:	a001                	j	800024 <_start+0x4>

0000000000800026 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800026:	715d                	addi	sp,sp,-80
  800028:	e822                	sd	s0,16(sp)
  80002a:	fc3e                	sd	a5,56(sp)
  80002c:	8432                	mv	s0,a2
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  80002e:	103c                	addi	a5,sp,40
    cprintf("user panic at %s:%d:\n    ", file, line);
  800030:	862e                	mv	a2,a1
  800032:	85aa                	mv	a1,a0
  800034:	00000517          	auipc	a0,0x0
  800038:	6a450513          	addi	a0,a0,1700 # 8006d8 <main+0xb6>
__panic(const char *file, int line, const char *fmt, ...) {
  80003c:	ec06                	sd	ra,24(sp)
  80003e:	f436                	sd	a3,40(sp)
  800040:	f83a                	sd	a4,48(sp)
  800042:	e0c2                	sd	a6,64(sp)
  800044:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800046:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800048:	058000ef          	jal	ra,8000a0 <cprintf>
    vcprintf(fmt, ap);
  80004c:	65a2                	ld	a1,8(sp)
  80004e:	8522                	mv	a0,s0
  800050:	030000ef          	jal	ra,800080 <vcprintf>
    cprintf("\n");
  800054:	00001517          	auipc	a0,0x1
  800058:	9dc50513          	addi	a0,a0,-1572 # 800a30 <error_string+0x1c8>
  80005c:	044000ef          	jal	ra,8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800060:	5559                	li	a0,-10
  800062:	0de000ef          	jal	ra,800140 <exit>

0000000000800066 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800066:	1141                	addi	sp,sp,-16
  800068:	e022                	sd	s0,0(sp)
  80006a:	e406                	sd	ra,8(sp)
  80006c:	842e                	mv	s0,a1
    sys_putc(c);
  80006e:	0ca000ef          	jal	ra,800138 <sys_putc>
    (*cnt) ++;
  800072:	401c                	lw	a5,0(s0)
}
  800074:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  800076:	2785                	addiw	a5,a5,1
  800078:	c01c                	sw	a5,0(s0)
}
  80007a:	6402                	ld	s0,0(sp)
  80007c:	0141                	addi	sp,sp,16
  80007e:	8082                	ret

0000000000800080 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  800080:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800082:	86ae                	mv	a3,a1
  800084:	862a                	mv	a2,a0
  800086:	006c                	addi	a1,sp,12
  800088:	00000517          	auipc	a0,0x0
  80008c:	fde50513          	addi	a0,a0,-34 # 800066 <cputch>
vcprintf(const char *fmt, va_list ap) {
  800090:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800092:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800094:	14e000ef          	jal	ra,8001e2 <vprintfmt>
    return cnt;
}
  800098:	60e2                	ld	ra,24(sp)
  80009a:	4532                	lw	a0,12(sp)
  80009c:	6105                	addi	sp,sp,32
  80009e:	8082                	ret

00000000008000a0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000a0:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000a2:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000a6:	f42e                	sd	a1,40(sp)
  8000a8:	f832                	sd	a2,48(sp)
  8000aa:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000ac:	862a                	mv	a2,a0
  8000ae:	004c                	addi	a1,sp,4
  8000b0:	00000517          	auipc	a0,0x0
  8000b4:	fb650513          	addi	a0,a0,-74 # 800066 <cputch>
  8000b8:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000ba:	ec06                	sd	ra,24(sp)
  8000bc:	e0ba                	sd	a4,64(sp)
  8000be:	e4be                	sd	a5,72(sp)
  8000c0:	e8c2                	sd	a6,80(sp)
  8000c2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  8000c4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  8000c6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000c8:	11a000ef          	jal	ra,8001e2 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000cc:	60e2                	ld	ra,24(sp)
  8000ce:	4512                	lw	a0,4(sp)
  8000d0:	6125                	addi	sp,sp,96
  8000d2:	8082                	ret

00000000008000d4 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  8000d4:	7175                	addi	sp,sp,-144
  8000d6:	f8ba                	sd	a4,112(sp)
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  8000d8:	e0ba                	sd	a4,64(sp)
  8000da:	0118                	addi	a4,sp,128
syscall(int64_t num, ...) {
  8000dc:	e42a                	sd	a0,8(sp)
  8000de:	ecae                	sd	a1,88(sp)
  8000e0:	f0b2                	sd	a2,96(sp)
  8000e2:	f4b6                	sd	a3,104(sp)
  8000e4:	fcbe                	sd	a5,120(sp)
  8000e6:	e142                	sd	a6,128(sp)
  8000e8:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  8000ea:	f42e                	sd	a1,40(sp)
  8000ec:	f832                	sd	a2,48(sp)
  8000ee:	fc36                	sd	a3,56(sp)
  8000f0:	f03a                	sd	a4,32(sp)
  8000f2:	e4be                	sd	a5,72(sp)
    }
    va_end(ap);
    asm volatile (
  8000f4:	4522                	lw	a0,8(sp)
  8000f6:	55a2                	lw	a1,40(sp)
  8000f8:	5642                	lw	a2,48(sp)
  8000fa:	56e2                	lw	a3,56(sp)
  8000fc:	4706                	lw	a4,64(sp)
  8000fe:	47a6                	lw	a5,72(sp)
  800100:	00000073          	ecall
  800104:	ce2a                	sw	a0,28(sp)
          "m" (a[3]),
          "m" (a[4])
        : "memory"
      );
    return ret;
}
  800106:	4572                	lw	a0,28(sp)
  800108:	6149                	addi	sp,sp,144
  80010a:	8082                	ret

000000000080010c <sys_exit>:

int
sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
  80010c:	85aa                	mv	a1,a0
  80010e:	4505                	li	a0,1
  800110:	fc5ff06f          	j	8000d4 <syscall>

0000000000800114 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  800114:	4509                	li	a0,2
  800116:	fbfff06f          	j	8000d4 <syscall>

000000000080011a <sys_wait>:
}

int
sys_wait(int64_t pid, int *store) {
    return syscall(SYS_wait, pid, store);
  80011a:	862e                	mv	a2,a1
  80011c:	85aa                	mv	a1,a0
  80011e:	450d                	li	a0,3
  800120:	fb5ff06f          	j	8000d4 <syscall>

0000000000800124 <sys_yield>:
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  800124:	4529                	li	a0,10
  800126:	fafff06f          	j	8000d4 <syscall>

000000000080012a <sys_kill>:
}

int
sys_kill(int64_t pid) {
    return syscall(SYS_kill, pid);
  80012a:	85aa                	mv	a1,a0
  80012c:	4531                	li	a0,12
  80012e:	fa7ff06f          	j	8000d4 <syscall>

0000000000800132 <sys_getpid>:
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  800132:	4549                	li	a0,18
  800134:	fa1ff06f          	j	8000d4 <syscall>

0000000000800138 <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  800138:	85aa                	mv	a1,a0
  80013a:	4579                	li	a0,30
  80013c:	f99ff06f          	j	8000d4 <syscall>

0000000000800140 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800140:	1141                	addi	sp,sp,-16
  800142:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800144:	fc9ff0ef          	jal	ra,80010c <sys_exit>
    cprintf("BUG: exit failed.\n");
  800148:	00000517          	auipc	a0,0x0
  80014c:	5b050513          	addi	a0,a0,1456 # 8006f8 <main+0xd6>
  800150:	f51ff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  800154:	a001                	j	800154 <exit+0x14>

0000000000800156 <fork>:
}

int
fork(void) {
    return sys_fork();
  800156:	fbfff06f          	j	800114 <sys_fork>

000000000080015a <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  80015a:	fc1ff06f          	j	80011a <sys_wait>

000000000080015e <yield>:
}

void
yield(void) {
    sys_yield();
  80015e:	fc7ff06f          	j	800124 <sys_yield>

0000000000800162 <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  800162:	fc9ff06f          	j	80012a <sys_kill>

0000000000800166 <getpid>:
}

int
getpid(void) {
    return sys_getpid();
  800166:	fcdff06f          	j	800132 <sys_getpid>

000000000080016a <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80016a:	1141                	addi	sp,sp,-16
  80016c:	e406                	sd	ra,8(sp)
    int ret = main();
  80016e:	4b4000ef          	jal	ra,800622 <main>
    exit(ret);
  800172:	fcfff0ef          	jal	ra,800140 <exit>

0000000000800176 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800176:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80017a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80017c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800180:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800182:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800186:	f022                	sd	s0,32(sp)
  800188:	ec26                	sd	s1,24(sp)
  80018a:	e84a                	sd	s2,16(sp)
  80018c:	f406                	sd	ra,40(sp)
  80018e:	e44e                	sd	s3,8(sp)
  800190:	84aa                	mv	s1,a0
  800192:	892e                	mv	s2,a1
  800194:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800198:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  80019a:	03067e63          	bleu	a6,a2,8001d6 <printnum+0x60>
  80019e:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8001a0:	00805763          	blez	s0,8001ae <printnum+0x38>
  8001a4:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001a6:	85ca                	mv	a1,s2
  8001a8:	854e                	mv	a0,s3
  8001aa:	9482                	jalr	s1
        while (-- width > 0)
  8001ac:	fc65                	bnez	s0,8001a4 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001ae:	1a02                	slli	s4,s4,0x20
  8001b0:	020a5a13          	srli	s4,s4,0x20
  8001b4:	00000797          	auipc	a5,0x0
  8001b8:	77c78793          	addi	a5,a5,1916 # 800930 <error_string+0xc8>
  8001bc:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001be:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001c0:	000a4503          	lbu	a0,0(s4)
}
  8001c4:	70a2                	ld	ra,40(sp)
  8001c6:	69a2                	ld	s3,8(sp)
  8001c8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ca:	85ca                	mv	a1,s2
  8001cc:	8326                	mv	t1,s1
}
  8001ce:	6942                	ld	s2,16(sp)
  8001d0:	64e2                	ld	s1,24(sp)
  8001d2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001d4:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001d6:	03065633          	divu	a2,a2,a6
  8001da:	8722                	mv	a4,s0
  8001dc:	f9bff0ef          	jal	ra,800176 <printnum>
  8001e0:	b7f9                	j	8001ae <printnum+0x38>

00000000008001e2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001e2:	7119                	addi	sp,sp,-128
  8001e4:	f4a6                	sd	s1,104(sp)
  8001e6:	f0ca                	sd	s2,96(sp)
  8001e8:	e8d2                	sd	s4,80(sp)
  8001ea:	e4d6                	sd	s5,72(sp)
  8001ec:	e0da                	sd	s6,64(sp)
  8001ee:	fc5e                	sd	s7,56(sp)
  8001f0:	f862                	sd	s8,48(sp)
  8001f2:	f06a                	sd	s10,32(sp)
  8001f4:	fc86                	sd	ra,120(sp)
  8001f6:	f8a2                	sd	s0,112(sp)
  8001f8:	ecce                	sd	s3,88(sp)
  8001fa:	f466                	sd	s9,40(sp)
  8001fc:	ec6e                	sd	s11,24(sp)
  8001fe:	892a                	mv	s2,a0
  800200:	84ae                	mv	s1,a1
  800202:	8d32                	mv	s10,a2
  800204:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800206:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800208:	00000a17          	auipc	s4,0x0
  80020c:	504a0a13          	addi	s4,s4,1284 # 80070c <main+0xea>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800210:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800214:	00000c17          	auipc	s8,0x0
  800218:	654c0c13          	addi	s8,s8,1620 # 800868 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021c:	000d4503          	lbu	a0,0(s10)
  800220:	02500793          	li	a5,37
  800224:	001d0413          	addi	s0,s10,1
  800228:	00f50e63          	beq	a0,a5,800244 <vprintfmt+0x62>
            if (ch == '\0') {
  80022c:	c521                	beqz	a0,800274 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80022e:	02500993          	li	s3,37
  800232:	a011                	j	800236 <vprintfmt+0x54>
            if (ch == '\0') {
  800234:	c121                	beqz	a0,800274 <vprintfmt+0x92>
            putch(ch, putdat);
  800236:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800238:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80023a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80023c:	fff44503          	lbu	a0,-1(s0)
  800240:	ff351ae3          	bne	a0,s3,800234 <vprintfmt+0x52>
  800244:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800248:	02000793          	li	a5,32
        lflag = altflag = 0;
  80024c:	4981                	li	s3,0
  80024e:	4801                	li	a6,0
        width = precision = -1;
  800250:	5cfd                	li	s9,-1
  800252:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800254:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800258:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  80025a:	fdd6069b          	addiw	a3,a2,-35
  80025e:	0ff6f693          	andi	a3,a3,255
  800262:	00140d13          	addi	s10,s0,1
  800266:	20d5e563          	bltu	a1,a3,800470 <vprintfmt+0x28e>
  80026a:	068a                	slli	a3,a3,0x2
  80026c:	96d2                	add	a3,a3,s4
  80026e:	4294                	lw	a3,0(a3)
  800270:	96d2                	add	a3,a3,s4
  800272:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800274:	70e6                	ld	ra,120(sp)
  800276:	7446                	ld	s0,112(sp)
  800278:	74a6                	ld	s1,104(sp)
  80027a:	7906                	ld	s2,96(sp)
  80027c:	69e6                	ld	s3,88(sp)
  80027e:	6a46                	ld	s4,80(sp)
  800280:	6aa6                	ld	s5,72(sp)
  800282:	6b06                	ld	s6,64(sp)
  800284:	7be2                	ld	s7,56(sp)
  800286:	7c42                	ld	s8,48(sp)
  800288:	7ca2                	ld	s9,40(sp)
  80028a:	7d02                	ld	s10,32(sp)
  80028c:	6de2                	ld	s11,24(sp)
  80028e:	6109                	addi	sp,sp,128
  800290:	8082                	ret
    if (lflag >= 2) {
  800292:	4705                	li	a4,1
  800294:	008a8593          	addi	a1,s5,8
  800298:	01074463          	blt	a4,a6,8002a0 <vprintfmt+0xbe>
    else if (lflag) {
  80029c:	26080363          	beqz	a6,800502 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  8002a0:	000ab603          	ld	a2,0(s5)
  8002a4:	46c1                	li	a3,16
  8002a6:	8aae                	mv	s5,a1
  8002a8:	a06d                	j	800352 <vprintfmt+0x170>
            goto reswitch;
  8002aa:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002ae:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002b0:	846a                	mv	s0,s10
            goto reswitch;
  8002b2:	b765                	j	80025a <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  8002b4:	000aa503          	lw	a0,0(s5)
  8002b8:	85a6                	mv	a1,s1
  8002ba:	0aa1                	addi	s5,s5,8
  8002bc:	9902                	jalr	s2
            break;
  8002be:	bfb9                	j	80021c <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002c0:	4705                	li	a4,1
  8002c2:	008a8993          	addi	s3,s5,8
  8002c6:	01074463          	blt	a4,a6,8002ce <vprintfmt+0xec>
    else if (lflag) {
  8002ca:	22080463          	beqz	a6,8004f2 <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002ce:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002d2:	24044463          	bltz	s0,80051a <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002d6:	8622                	mv	a2,s0
  8002d8:	8ace                	mv	s5,s3
  8002da:	46a9                	li	a3,10
  8002dc:	a89d                	j	800352 <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002de:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002e2:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002e4:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002e6:	41f7d69b          	sraiw	a3,a5,0x1f
  8002ea:	8fb5                	xor	a5,a5,a3
  8002ec:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002f0:	1ad74363          	blt	a4,a3,800496 <vprintfmt+0x2b4>
  8002f4:	00369793          	slli	a5,a3,0x3
  8002f8:	97e2                	add	a5,a5,s8
  8002fa:	639c                	ld	a5,0(a5)
  8002fc:	18078d63          	beqz	a5,800496 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  800300:	86be                	mv	a3,a5
  800302:	00000617          	auipc	a2,0x0
  800306:	71e60613          	addi	a2,a2,1822 # 800a20 <error_string+0x1b8>
  80030a:	85a6                	mv	a1,s1
  80030c:	854a                	mv	a0,s2
  80030e:	240000ef          	jal	ra,80054e <printfmt>
  800312:	b729                	j	80021c <vprintfmt+0x3a>
            lflag ++;
  800314:	00144603          	lbu	a2,1(s0)
  800318:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  80031a:	846a                	mv	s0,s10
            goto reswitch;
  80031c:	bf3d                	j	80025a <vprintfmt+0x78>
    if (lflag >= 2) {
  80031e:	4705                	li	a4,1
  800320:	008a8593          	addi	a1,s5,8
  800324:	01074463          	blt	a4,a6,80032c <vprintfmt+0x14a>
    else if (lflag) {
  800328:	1e080263          	beqz	a6,80050c <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  80032c:	000ab603          	ld	a2,0(s5)
  800330:	46a1                	li	a3,8
  800332:	8aae                	mv	s5,a1
  800334:	a839                	j	800352 <vprintfmt+0x170>
            putch('0', putdat);
  800336:	03000513          	li	a0,48
  80033a:	85a6                	mv	a1,s1
  80033c:	e03e                	sd	a5,0(sp)
  80033e:	9902                	jalr	s2
            putch('x', putdat);
  800340:	85a6                	mv	a1,s1
  800342:	07800513          	li	a0,120
  800346:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800348:	0aa1                	addi	s5,s5,8
  80034a:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  80034e:	6782                	ld	a5,0(sp)
  800350:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800352:	876e                	mv	a4,s11
  800354:	85a6                	mv	a1,s1
  800356:	854a                	mv	a0,s2
  800358:	e1fff0ef          	jal	ra,800176 <printnum>
            break;
  80035c:	b5c1                	j	80021c <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  80035e:	000ab603          	ld	a2,0(s5)
  800362:	0aa1                	addi	s5,s5,8
  800364:	1c060663          	beqz	a2,800530 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  800368:	00160413          	addi	s0,a2,1
  80036c:	17b05c63          	blez	s11,8004e4 <vprintfmt+0x302>
  800370:	02d00593          	li	a1,45
  800374:	14b79263          	bne	a5,a1,8004b8 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800378:	00064783          	lbu	a5,0(a2)
  80037c:	0007851b          	sext.w	a0,a5
  800380:	c905                	beqz	a0,8003b0 <vprintfmt+0x1ce>
  800382:	000cc563          	bltz	s9,80038c <vprintfmt+0x1aa>
  800386:	3cfd                	addiw	s9,s9,-1
  800388:	036c8263          	beq	s9,s6,8003ac <vprintfmt+0x1ca>
                    putch('?', putdat);
  80038c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80038e:	18098463          	beqz	s3,800516 <vprintfmt+0x334>
  800392:	3781                	addiw	a5,a5,-32
  800394:	18fbf163          	bleu	a5,s7,800516 <vprintfmt+0x334>
                    putch('?', putdat);
  800398:	03f00513          	li	a0,63
  80039c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80039e:	0405                	addi	s0,s0,1
  8003a0:	fff44783          	lbu	a5,-1(s0)
  8003a4:	3dfd                	addiw	s11,s11,-1
  8003a6:	0007851b          	sext.w	a0,a5
  8003aa:	fd61                	bnez	a0,800382 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  8003ac:	e7b058e3          	blez	s11,80021c <vprintfmt+0x3a>
  8003b0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003b2:	85a6                	mv	a1,s1
  8003b4:	02000513          	li	a0,32
  8003b8:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ba:	e60d81e3          	beqz	s11,80021c <vprintfmt+0x3a>
  8003be:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003c0:	85a6                	mv	a1,s1
  8003c2:	02000513          	li	a0,32
  8003c6:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003c8:	fe0d94e3          	bnez	s11,8003b0 <vprintfmt+0x1ce>
  8003cc:	bd81                	j	80021c <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003ce:	4705                	li	a4,1
  8003d0:	008a8593          	addi	a1,s5,8
  8003d4:	01074463          	blt	a4,a6,8003dc <vprintfmt+0x1fa>
    else if (lflag) {
  8003d8:	12080063          	beqz	a6,8004f8 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003dc:	000ab603          	ld	a2,0(s5)
  8003e0:	46a9                	li	a3,10
  8003e2:	8aae                	mv	s5,a1
  8003e4:	b7bd                	j	800352 <vprintfmt+0x170>
  8003e6:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003ea:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  8003ee:	846a                	mv	s0,s10
  8003f0:	b5ad                	j	80025a <vprintfmt+0x78>
            putch(ch, putdat);
  8003f2:	85a6                	mv	a1,s1
  8003f4:	02500513          	li	a0,37
  8003f8:	9902                	jalr	s2
            break;
  8003fa:	b50d                	j	80021c <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  8003fc:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  800400:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800404:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800406:	846a                	mv	s0,s10
            if (width < 0)
  800408:	e40dd9e3          	bgez	s11,80025a <vprintfmt+0x78>
                width = precision, precision = -1;
  80040c:	8de6                	mv	s11,s9
  80040e:	5cfd                	li	s9,-1
  800410:	b5a9                	j	80025a <vprintfmt+0x78>
            goto reswitch;
  800412:	00144603          	lbu	a2,1(s0)
            padc = '0';
  800416:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  80041a:	846a                	mv	s0,s10
            goto reswitch;
  80041c:	bd3d                	j	80025a <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  80041e:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800422:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800426:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800428:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  80042c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800430:	fcd56ce3          	bltu	a0,a3,800408 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  800434:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800436:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  80043a:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  80043e:	0196873b          	addw	a4,a3,s9
  800442:	0017171b          	slliw	a4,a4,0x1
  800446:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  80044a:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  80044e:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800452:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800456:	fcd57fe3          	bleu	a3,a0,800434 <vprintfmt+0x252>
  80045a:	b77d                	j	800408 <vprintfmt+0x226>
            if (width < 0)
  80045c:	fffdc693          	not	a3,s11
  800460:	96fd                	srai	a3,a3,0x3f
  800462:	00ddfdb3          	and	s11,s11,a3
  800466:	00144603          	lbu	a2,1(s0)
  80046a:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  80046c:	846a                	mv	s0,s10
  80046e:	b3f5                	j	80025a <vprintfmt+0x78>
            putch('%', putdat);
  800470:	85a6                	mv	a1,s1
  800472:	02500513          	li	a0,37
  800476:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800478:	fff44703          	lbu	a4,-1(s0)
  80047c:	02500793          	li	a5,37
  800480:	8d22                	mv	s10,s0
  800482:	d8f70de3          	beq	a4,a5,80021c <vprintfmt+0x3a>
  800486:	02500713          	li	a4,37
  80048a:	1d7d                	addi	s10,s10,-1
  80048c:	fffd4783          	lbu	a5,-1(s10)
  800490:	fee79de3          	bne	a5,a4,80048a <vprintfmt+0x2a8>
  800494:	b361                	j	80021c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800496:	00000617          	auipc	a2,0x0
  80049a:	57a60613          	addi	a2,a2,1402 # 800a10 <error_string+0x1a8>
  80049e:	85a6                	mv	a1,s1
  8004a0:	854a                	mv	a0,s2
  8004a2:	0ac000ef          	jal	ra,80054e <printfmt>
  8004a6:	bb9d                	j	80021c <vprintfmt+0x3a>
                p = "(null)";
  8004a8:	00000617          	auipc	a2,0x0
  8004ac:	56060613          	addi	a2,a2,1376 # 800a08 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004b0:	00000417          	auipc	s0,0x0
  8004b4:	55940413          	addi	s0,s0,1369 # 800a09 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b8:	8532                	mv	a0,a2
  8004ba:	85e6                	mv	a1,s9
  8004bc:	e032                	sd	a2,0(sp)
  8004be:	e43e                	sd	a5,8(sp)
  8004c0:	0ae000ef          	jal	ra,80056e <strnlen>
  8004c4:	40ad8dbb          	subw	s11,s11,a0
  8004c8:	6602                	ld	a2,0(sp)
  8004ca:	01b05d63          	blez	s11,8004e4 <vprintfmt+0x302>
  8004ce:	67a2                	ld	a5,8(sp)
  8004d0:	2781                	sext.w	a5,a5
  8004d2:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004d4:	6522                	ld	a0,8(sp)
  8004d6:	85a6                	mv	a1,s1
  8004d8:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004da:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004dc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004de:	6602                	ld	a2,0(sp)
  8004e0:	fe0d9ae3          	bnez	s11,8004d4 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e4:	00064783          	lbu	a5,0(a2)
  8004e8:	0007851b          	sext.w	a0,a5
  8004ec:	e8051be3          	bnez	a0,800382 <vprintfmt+0x1a0>
  8004f0:	b335                	j	80021c <vprintfmt+0x3a>
        return va_arg(*ap, int);
  8004f2:	000aa403          	lw	s0,0(s5)
  8004f6:	bbf1                	j	8002d2 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  8004f8:	000ae603          	lwu	a2,0(s5)
  8004fc:	46a9                	li	a3,10
  8004fe:	8aae                	mv	s5,a1
  800500:	bd89                	j	800352 <vprintfmt+0x170>
  800502:	000ae603          	lwu	a2,0(s5)
  800506:	46c1                	li	a3,16
  800508:	8aae                	mv	s5,a1
  80050a:	b5a1                	j	800352 <vprintfmt+0x170>
  80050c:	000ae603          	lwu	a2,0(s5)
  800510:	46a1                	li	a3,8
  800512:	8aae                	mv	s5,a1
  800514:	bd3d                	j	800352 <vprintfmt+0x170>
                    putch(ch, putdat);
  800516:	9902                	jalr	s2
  800518:	b559                	j	80039e <vprintfmt+0x1bc>
                putch('-', putdat);
  80051a:	85a6                	mv	a1,s1
  80051c:	02d00513          	li	a0,45
  800520:	e03e                	sd	a5,0(sp)
  800522:	9902                	jalr	s2
                num = -(long long)num;
  800524:	8ace                	mv	s5,s3
  800526:	40800633          	neg	a2,s0
  80052a:	46a9                	li	a3,10
  80052c:	6782                	ld	a5,0(sp)
  80052e:	b515                	j	800352 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  800530:	01b05663          	blez	s11,80053c <vprintfmt+0x35a>
  800534:	02d00693          	li	a3,45
  800538:	f6d798e3          	bne	a5,a3,8004a8 <vprintfmt+0x2c6>
  80053c:	00000417          	auipc	s0,0x0
  800540:	4cd40413          	addi	s0,s0,1229 # 800a09 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800544:	02800513          	li	a0,40
  800548:	02800793          	li	a5,40
  80054c:	bd1d                	j	800382 <vprintfmt+0x1a0>

000000000080054e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80054e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800550:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800554:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800556:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800558:	ec06                	sd	ra,24(sp)
  80055a:	f83a                	sd	a4,48(sp)
  80055c:	fc3e                	sd	a5,56(sp)
  80055e:	e0c2                	sd	a6,64(sp)
  800560:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800562:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800564:	c7fff0ef          	jal	ra,8001e2 <vprintfmt>
}
  800568:	60e2                	ld	ra,24(sp)
  80056a:	6161                	addi	sp,sp,80
  80056c:	8082                	ret

000000000080056e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  80056e:	c185                	beqz	a1,80058e <strnlen+0x20>
  800570:	00054783          	lbu	a5,0(a0)
  800574:	cf89                	beqz	a5,80058e <strnlen+0x20>
    size_t cnt = 0;
  800576:	4781                	li	a5,0
  800578:	a021                	j	800580 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  80057a:	00074703          	lbu	a4,0(a4)
  80057e:	c711                	beqz	a4,80058a <strnlen+0x1c>
        cnt ++;
  800580:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800582:	00f50733          	add	a4,a0,a5
  800586:	fef59ae3          	bne	a1,a5,80057a <strnlen+0xc>
    }
    return cnt;
}
  80058a:	853e                	mv	a0,a5
  80058c:	8082                	ret
    size_t cnt = 0;
  80058e:	4781                	li	a5,0
}
  800590:	853e                	mv	a0,a5
  800592:	8082                	ret

0000000000800594 <do_yield>:
#include <ulib.h>
#include <stdio.h>

void
do_yield(void) {
  800594:	1141                	addi	sp,sp,-16
  800596:	e406                	sd	ra,8(sp)
    yield();
  800598:	bc7ff0ef          	jal	ra,80015e <yield>
    yield();
  80059c:	bc3ff0ef          	jal	ra,80015e <yield>
    yield();
  8005a0:	bbfff0ef          	jal	ra,80015e <yield>
    yield();
  8005a4:	bbbff0ef          	jal	ra,80015e <yield>
    yield();
  8005a8:	bb7ff0ef          	jal	ra,80015e <yield>
    yield();
}
  8005ac:	60a2                	ld	ra,8(sp)
  8005ae:	0141                	addi	sp,sp,16
    yield();
  8005b0:	bafff06f          	j	80015e <yield>

00000000008005b4 <loop>:

int parent, pid1, pid2;

void
loop(void) {
  8005b4:	1141                	addi	sp,sp,-16
    cprintf("child 1.\n");
  8005b6:	00000517          	auipc	a0,0x0
  8005ba:	47250513          	addi	a0,a0,1138 # 800a28 <error_string+0x1c0>
loop(void) {
  8005be:	e406                	sd	ra,8(sp)
    cprintf("child 1.\n");
  8005c0:	ae1ff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  8005c4:	a001                	j	8005c4 <loop+0x10>

00000000008005c6 <work>:
}

void
work(void) {
  8005c6:	1141                	addi	sp,sp,-16
    cprintf("child 2.\n");
  8005c8:	00000517          	auipc	a0,0x0
  8005cc:	4e050513          	addi	a0,a0,1248 # 800aa8 <error_string+0x240>
work(void) {
  8005d0:	e406                	sd	ra,8(sp)
    cprintf("child 2.\n");
  8005d2:	acfff0ef          	jal	ra,8000a0 <cprintf>
    do_yield();
  8005d6:	fbfff0ef          	jal	ra,800594 <do_yield>
    if (kill(parent) == 0) {
  8005da:	00001797          	auipc	a5,0x1
  8005de:	a2678793          	addi	a5,a5,-1498 # 801000 <parent>
  8005e2:	4388                	lw	a0,0(a5)
  8005e4:	b7fff0ef          	jal	ra,800162 <kill>
  8005e8:	e10d                	bnez	a0,80060a <work+0x44>
        cprintf("kill parent ok.\n");
  8005ea:	00000517          	auipc	a0,0x0
  8005ee:	4ce50513          	addi	a0,a0,1230 # 800ab8 <error_string+0x250>
  8005f2:	aafff0ef          	jal	ra,8000a0 <cprintf>
        do_yield();
  8005f6:	f9fff0ef          	jal	ra,800594 <do_yield>
        if (kill(pid1) == 0) {
  8005fa:	00001797          	auipc	a5,0x1
  8005fe:	a0e78793          	addi	a5,a5,-1522 # 801008 <pid1>
  800602:	4388                	lw	a0,0(a5)
  800604:	b5fff0ef          	jal	ra,800162 <kill>
  800608:	c501                	beqz	a0,800610 <work+0x4a>
            cprintf("kill child1 ok.\n");
            exit(0);
        }
    }
    exit(-1);
  80060a:	557d                	li	a0,-1
  80060c:	b35ff0ef          	jal	ra,800140 <exit>
            cprintf("kill child1 ok.\n");
  800610:	00000517          	auipc	a0,0x0
  800614:	4c050513          	addi	a0,a0,1216 # 800ad0 <error_string+0x268>
  800618:	a89ff0ef          	jal	ra,8000a0 <cprintf>
            exit(0);
  80061c:	4501                	li	a0,0
  80061e:	b23ff0ef          	jal	ra,800140 <exit>

0000000000800622 <main>:
}

int
main(void) {
  800622:	1141                	addi	sp,sp,-16
  800624:	e406                	sd	ra,8(sp)
  800626:	e022                	sd	s0,0(sp)
    parent = getpid();
  800628:	b3fff0ef          	jal	ra,800166 <getpid>
  80062c:	00001797          	auipc	a5,0x1
  800630:	9ca7aa23          	sw	a0,-1580(a5) # 801000 <parent>
    if ((pid1 = fork()) == 0) {
  800634:	b23ff0ef          	jal	ra,800156 <fork>
  800638:	00001797          	auipc	a5,0x1
  80063c:	9ca7a823          	sw	a0,-1584(a5) # 801008 <pid1>
  800640:	c53d                	beqz	a0,8006ae <main+0x8c>
        loop();
    }

    assert(pid1 > 0);
  800642:	04a05663          	blez	a0,80068e <main+0x6c>

    if ((pid2 = fork()) == 0) {
  800646:	b11ff0ef          	jal	ra,800156 <fork>
  80064a:	00001797          	auipc	a5,0x1
  80064e:	9aa7ad23          	sw	a0,-1606(a5) # 801004 <pid2>
  800652:	cd3d                	beqz	a0,8006d0 <main+0xae>
  800654:	00001417          	auipc	s0,0x1
  800658:	9b440413          	addi	s0,s0,-1612 # 801008 <pid1>
        work();
    }
    if (pid2 > 0) {
  80065c:	04a05b63          	blez	a0,8006b2 <main+0x90>
        cprintf("wait child 1.\n");
  800660:	00000517          	auipc	a0,0x0
  800664:	41050513          	addi	a0,a0,1040 # 800a70 <error_string+0x208>
  800668:	a39ff0ef          	jal	ra,8000a0 <cprintf>
        waitpid(pid1, NULL);
  80066c:	4008                	lw	a0,0(s0)
  80066e:	4581                	li	a1,0
  800670:	aebff0ef          	jal	ra,80015a <waitpid>
        panic("waitpid %d returns\n", pid1);
  800674:	4014                	lw	a3,0(s0)
  800676:	00000617          	auipc	a2,0x0
  80067a:	40a60613          	addi	a2,a2,1034 # 800a80 <error_string+0x218>
  80067e:	03400593          	li	a1,52
  800682:	00000517          	auipc	a0,0x0
  800686:	3de50513          	addi	a0,a0,990 # 800a60 <error_string+0x1f8>
  80068a:	99dff0ef          	jal	ra,800026 <__panic>
    assert(pid1 > 0);
  80068e:	00000697          	auipc	a3,0x0
  800692:	3aa68693          	addi	a3,a3,938 # 800a38 <error_string+0x1d0>
  800696:	00000617          	auipc	a2,0x0
  80069a:	3b260613          	addi	a2,a2,946 # 800a48 <error_string+0x1e0>
  80069e:	02c00593          	li	a1,44
  8006a2:	00000517          	auipc	a0,0x0
  8006a6:	3be50513          	addi	a0,a0,958 # 800a60 <error_string+0x1f8>
  8006aa:	97dff0ef          	jal	ra,800026 <__panic>
        loop();
  8006ae:	f07ff0ef          	jal	ra,8005b4 <loop>
    }
    else {
        kill(pid1);
  8006b2:	4008                	lw	a0,0(s0)
  8006b4:	aafff0ef          	jal	ra,800162 <kill>
    }
    panic("FAIL: T.T\n");
  8006b8:	00000617          	auipc	a2,0x0
  8006bc:	3e060613          	addi	a2,a2,992 # 800a98 <error_string+0x230>
  8006c0:	03900593          	li	a1,57
  8006c4:	00000517          	auipc	a0,0x0
  8006c8:	39c50513          	addi	a0,a0,924 # 800a60 <error_string+0x1f8>
  8006cc:	95bff0ef          	jal	ra,800026 <__panic>
        work();
  8006d0:	ef7ff0ef          	jal	ra,8005c6 <work>
