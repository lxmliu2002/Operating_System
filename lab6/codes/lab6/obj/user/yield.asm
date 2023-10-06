
obj/__user_yield.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  800020:	0c6000ef          	jal	ra,8000e6 <umain>
1:  j 1b
  800024:	a001                	j	800024 <_start+0x4>

0000000000800026 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800026:	1141                	addi	sp,sp,-16
  800028:	e022                	sd	s0,0(sp)
  80002a:	e406                	sd	ra,8(sp)
  80002c:	842e                	mv	s0,a1
    sys_putc(c);
  80002e:	092000ef          	jal	ra,8000c0 <sys_putc>
    (*cnt) ++;
  800032:	401c                	lw	a5,0(s0)
}
  800034:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  800036:	2785                	addiw	a5,a5,1
  800038:	c01c                	sw	a5,0(s0)
}
  80003a:	6402                	ld	s0,0(sp)
  80003c:	0141                	addi	sp,sp,16
  80003e:	8082                	ret

0000000000800040 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800040:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800042:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800046:	f42e                	sd	a1,40(sp)
  800048:	f832                	sd	a2,48(sp)
  80004a:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80004c:	862a                	mv	a2,a0
  80004e:	004c                	addi	a1,sp,4
  800050:	00000517          	auipc	a0,0x0
  800054:	fd650513          	addi	a0,a0,-42 # 800026 <cputch>
  800058:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  80005a:	ec06                	sd	ra,24(sp)
  80005c:	e0ba                	sd	a4,64(sp)
  80005e:	e4be                	sd	a5,72(sp)
  800060:	e8c2                	sd	a6,80(sp)
  800062:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800064:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800066:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800068:	0f6000ef          	jal	ra,80015e <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80006c:	60e2                	ld	ra,24(sp)
  80006e:	4512                	lw	a0,4(sp)
  800070:	6125                	addi	sp,sp,96
  800072:	8082                	ret

0000000000800074 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  800074:	7175                	addi	sp,sp,-144
  800076:	f8ba                	sd	a4,112(sp)
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  800078:	e0ba                	sd	a4,64(sp)
  80007a:	0118                	addi	a4,sp,128
syscall(int64_t num, ...) {
  80007c:	e42a                	sd	a0,8(sp)
  80007e:	ecae                	sd	a1,88(sp)
  800080:	f0b2                	sd	a2,96(sp)
  800082:	f4b6                	sd	a3,104(sp)
  800084:	fcbe                	sd	a5,120(sp)
  800086:	e142                	sd	a6,128(sp)
  800088:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  80008a:	f42e                	sd	a1,40(sp)
  80008c:	f832                	sd	a2,48(sp)
  80008e:	fc36                	sd	a3,56(sp)
  800090:	f03a                	sd	a4,32(sp)
  800092:	e4be                	sd	a5,72(sp)
    }
    va_end(ap);
    asm volatile (
  800094:	4522                	lw	a0,8(sp)
  800096:	55a2                	lw	a1,40(sp)
  800098:	5642                	lw	a2,48(sp)
  80009a:	56e2                	lw	a3,56(sp)
  80009c:	4706                	lw	a4,64(sp)
  80009e:	47a6                	lw	a5,72(sp)
  8000a0:	00000073          	ecall
  8000a4:	ce2a                	sw	a0,28(sp)
          "m" (a[3]),
          "m" (a[4])
        : "memory"
      );
    return ret;
}
  8000a6:	4572                	lw	a0,28(sp)
  8000a8:	6149                	addi	sp,sp,144
  8000aa:	8082                	ret

00000000008000ac <sys_exit>:

int
sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
  8000ac:	85aa                	mv	a1,a0
  8000ae:	4505                	li	a0,1
  8000b0:	fc5ff06f          	j	800074 <syscall>

00000000008000b4 <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  8000b4:	4529                	li	a0,10
  8000b6:	fbfff06f          	j	800074 <syscall>

00000000008000ba <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000ba:	4549                	li	a0,18
  8000bc:	fb9ff06f          	j	800074 <syscall>

00000000008000c0 <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000c0:	85aa                	mv	a1,a0
  8000c2:	4579                	li	a0,30
  8000c4:	fb1ff06f          	j	800074 <syscall>

00000000008000c8 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c8:	1141                	addi	sp,sp,-16
  8000ca:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000cc:	fe1ff0ef          	jal	ra,8000ac <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000d0:	00000517          	auipc	a0,0x0
  8000d4:	4b050513          	addi	a0,a0,1200 # 800580 <main+0x70>
  8000d8:	f69ff0ef          	jal	ra,800040 <cprintf>
    while (1);
  8000dc:	a001                	j	8000dc <exit+0x14>

00000000008000de <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  8000de:	fd7ff06f          	j	8000b4 <sys_yield>

00000000008000e2 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000e2:	fd9ff06f          	j	8000ba <sys_getpid>

00000000008000e6 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000e6:	1141                	addi	sp,sp,-16
  8000e8:	e406                	sd	ra,8(sp)
    int ret = main();
  8000ea:	426000ef          	jal	ra,800510 <main>
    exit(ret);
  8000ee:	fdbff0ef          	jal	ra,8000c8 <exit>

00000000008000f2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000f2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000f6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000f8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000fc:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000fe:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800102:	f022                	sd	s0,32(sp)
  800104:	ec26                	sd	s1,24(sp)
  800106:	e84a                	sd	s2,16(sp)
  800108:	f406                	sd	ra,40(sp)
  80010a:	e44e                	sd	s3,8(sp)
  80010c:	84aa                	mv	s1,a0
  80010e:	892e                	mv	s2,a1
  800110:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800114:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800116:	03067e63          	bleu	a6,a2,800152 <printnum+0x60>
  80011a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80011c:	00805763          	blez	s0,80012a <printnum+0x38>
  800120:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800122:	85ca                	mv	a1,s2
  800124:	854e                	mv	a0,s3
  800126:	9482                	jalr	s1
        while (-- width > 0)
  800128:	fc65                	bnez	s0,800120 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80012a:	1a02                	slli	s4,s4,0x20
  80012c:	020a5a13          	srli	s4,s4,0x20
  800130:	00000797          	auipc	a5,0x0
  800134:	68878793          	addi	a5,a5,1672 # 8007b8 <error_string+0xc8>
  800138:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80013a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80013c:	000a4503          	lbu	a0,0(s4)
}
  800140:	70a2                	ld	ra,40(sp)
  800142:	69a2                	ld	s3,8(sp)
  800144:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800146:	85ca                	mv	a1,s2
  800148:	8326                	mv	t1,s1
}
  80014a:	6942                	ld	s2,16(sp)
  80014c:	64e2                	ld	s1,24(sp)
  80014e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800150:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  800152:	03065633          	divu	a2,a2,a6
  800156:	8722                	mv	a4,s0
  800158:	f9bff0ef          	jal	ra,8000f2 <printnum>
  80015c:	b7f9                	j	80012a <printnum+0x38>

000000000080015e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80015e:	7119                	addi	sp,sp,-128
  800160:	f4a6                	sd	s1,104(sp)
  800162:	f0ca                	sd	s2,96(sp)
  800164:	e8d2                	sd	s4,80(sp)
  800166:	e4d6                	sd	s5,72(sp)
  800168:	e0da                	sd	s6,64(sp)
  80016a:	fc5e                	sd	s7,56(sp)
  80016c:	f862                	sd	s8,48(sp)
  80016e:	f06a                	sd	s10,32(sp)
  800170:	fc86                	sd	ra,120(sp)
  800172:	f8a2                	sd	s0,112(sp)
  800174:	ecce                	sd	s3,88(sp)
  800176:	f466                	sd	s9,40(sp)
  800178:	ec6e                	sd	s11,24(sp)
  80017a:	892a                	mv	s2,a0
  80017c:	84ae                	mv	s1,a1
  80017e:	8d32                	mv	s10,a2
  800180:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800182:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800184:	00000a17          	auipc	s4,0x0
  800188:	410a0a13          	addi	s4,s4,1040 # 800594 <main+0x84>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  80018c:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800190:	00000c17          	auipc	s8,0x0
  800194:	560c0c13          	addi	s8,s8,1376 # 8006f0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800198:	000d4503          	lbu	a0,0(s10)
  80019c:	02500793          	li	a5,37
  8001a0:	001d0413          	addi	s0,s10,1
  8001a4:	00f50e63          	beq	a0,a5,8001c0 <vprintfmt+0x62>
            if (ch == '\0') {
  8001a8:	c521                	beqz	a0,8001f0 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001aa:	02500993          	li	s3,37
  8001ae:	a011                	j	8001b2 <vprintfmt+0x54>
            if (ch == '\0') {
  8001b0:	c121                	beqz	a0,8001f0 <vprintfmt+0x92>
            putch(ch, putdat);
  8001b2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001b4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001b6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001b8:	fff44503          	lbu	a0,-1(s0)
  8001bc:	ff351ae3          	bne	a0,s3,8001b0 <vprintfmt+0x52>
  8001c0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001c4:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001c8:	4981                	li	s3,0
  8001ca:	4801                	li	a6,0
        width = precision = -1;
  8001cc:	5cfd                	li	s9,-1
  8001ce:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001d0:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  8001d4:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001d6:	fdd6069b          	addiw	a3,a2,-35
  8001da:	0ff6f693          	andi	a3,a3,255
  8001de:	00140d13          	addi	s10,s0,1
  8001e2:	20d5e563          	bltu	a1,a3,8003ec <vprintfmt+0x28e>
  8001e6:	068a                	slli	a3,a3,0x2
  8001e8:	96d2                	add	a3,a3,s4
  8001ea:	4294                	lw	a3,0(a3)
  8001ec:	96d2                	add	a3,a3,s4
  8001ee:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001f0:	70e6                	ld	ra,120(sp)
  8001f2:	7446                	ld	s0,112(sp)
  8001f4:	74a6                	ld	s1,104(sp)
  8001f6:	7906                	ld	s2,96(sp)
  8001f8:	69e6                	ld	s3,88(sp)
  8001fa:	6a46                	ld	s4,80(sp)
  8001fc:	6aa6                	ld	s5,72(sp)
  8001fe:	6b06                	ld	s6,64(sp)
  800200:	7be2                	ld	s7,56(sp)
  800202:	7c42                	ld	s8,48(sp)
  800204:	7ca2                	ld	s9,40(sp)
  800206:	7d02                	ld	s10,32(sp)
  800208:	6de2                	ld	s11,24(sp)
  80020a:	6109                	addi	sp,sp,128
  80020c:	8082                	ret
    if (lflag >= 2) {
  80020e:	4705                	li	a4,1
  800210:	008a8593          	addi	a1,s5,8
  800214:	01074463          	blt	a4,a6,80021c <vprintfmt+0xbe>
    else if (lflag) {
  800218:	26080363          	beqz	a6,80047e <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  80021c:	000ab603          	ld	a2,0(s5)
  800220:	46c1                	li	a3,16
  800222:	8aae                	mv	s5,a1
  800224:	a06d                	j	8002ce <vprintfmt+0x170>
            goto reswitch;
  800226:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  80022a:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  80022c:	846a                	mv	s0,s10
            goto reswitch;
  80022e:	b765                	j	8001d6 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  800230:	000aa503          	lw	a0,0(s5)
  800234:	85a6                	mv	a1,s1
  800236:	0aa1                	addi	s5,s5,8
  800238:	9902                	jalr	s2
            break;
  80023a:	bfb9                	j	800198 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80023c:	4705                	li	a4,1
  80023e:	008a8993          	addi	s3,s5,8
  800242:	01074463          	blt	a4,a6,80024a <vprintfmt+0xec>
    else if (lflag) {
  800246:	22080463          	beqz	a6,80046e <vprintfmt+0x310>
        return va_arg(*ap, long);
  80024a:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  80024e:	24044463          	bltz	s0,800496 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  800252:	8622                	mv	a2,s0
  800254:	8ace                	mv	s5,s3
  800256:	46a9                	li	a3,10
  800258:	a89d                	j	8002ce <vprintfmt+0x170>
            err = va_arg(ap, int);
  80025a:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80025e:	4761                	li	a4,24
            err = va_arg(ap, int);
  800260:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  800262:	41f7d69b          	sraiw	a3,a5,0x1f
  800266:	8fb5                	xor	a5,a5,a3
  800268:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80026c:	1ad74363          	blt	a4,a3,800412 <vprintfmt+0x2b4>
  800270:	00369793          	slli	a5,a3,0x3
  800274:	97e2                	add	a5,a5,s8
  800276:	639c                	ld	a5,0(a5)
  800278:	18078d63          	beqz	a5,800412 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  80027c:	86be                	mv	a3,a5
  80027e:	00000617          	auipc	a2,0x0
  800282:	62a60613          	addi	a2,a2,1578 # 8008a8 <error_string+0x1b8>
  800286:	85a6                	mv	a1,s1
  800288:	854a                	mv	a0,s2
  80028a:	240000ef          	jal	ra,8004ca <printfmt>
  80028e:	b729                	j	800198 <vprintfmt+0x3a>
            lflag ++;
  800290:	00144603          	lbu	a2,1(s0)
  800294:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800296:	846a                	mv	s0,s10
            goto reswitch;
  800298:	bf3d                	j	8001d6 <vprintfmt+0x78>
    if (lflag >= 2) {
  80029a:	4705                	li	a4,1
  80029c:	008a8593          	addi	a1,s5,8
  8002a0:	01074463          	blt	a4,a6,8002a8 <vprintfmt+0x14a>
    else if (lflag) {
  8002a4:	1e080263          	beqz	a6,800488 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  8002a8:	000ab603          	ld	a2,0(s5)
  8002ac:	46a1                	li	a3,8
  8002ae:	8aae                	mv	s5,a1
  8002b0:	a839                	j	8002ce <vprintfmt+0x170>
            putch('0', putdat);
  8002b2:	03000513          	li	a0,48
  8002b6:	85a6                	mv	a1,s1
  8002b8:	e03e                	sd	a5,0(sp)
  8002ba:	9902                	jalr	s2
            putch('x', putdat);
  8002bc:	85a6                	mv	a1,s1
  8002be:	07800513          	li	a0,120
  8002c2:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002c4:	0aa1                	addi	s5,s5,8
  8002c6:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  8002ca:	6782                	ld	a5,0(sp)
  8002cc:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  8002ce:	876e                	mv	a4,s11
  8002d0:	85a6                	mv	a1,s1
  8002d2:	854a                	mv	a0,s2
  8002d4:	e1fff0ef          	jal	ra,8000f2 <printnum>
            break;
  8002d8:	b5c1                	j	800198 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  8002da:	000ab603          	ld	a2,0(s5)
  8002de:	0aa1                	addi	s5,s5,8
  8002e0:	1c060663          	beqz	a2,8004ac <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  8002e4:	00160413          	addi	s0,a2,1
  8002e8:	17b05c63          	blez	s11,800460 <vprintfmt+0x302>
  8002ec:	02d00593          	li	a1,45
  8002f0:	14b79263          	bne	a5,a1,800434 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8002f4:	00064783          	lbu	a5,0(a2)
  8002f8:	0007851b          	sext.w	a0,a5
  8002fc:	c905                	beqz	a0,80032c <vprintfmt+0x1ce>
  8002fe:	000cc563          	bltz	s9,800308 <vprintfmt+0x1aa>
  800302:	3cfd                	addiw	s9,s9,-1
  800304:	036c8263          	beq	s9,s6,800328 <vprintfmt+0x1ca>
                    putch('?', putdat);
  800308:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80030a:	18098463          	beqz	s3,800492 <vprintfmt+0x334>
  80030e:	3781                	addiw	a5,a5,-32
  800310:	18fbf163          	bleu	a5,s7,800492 <vprintfmt+0x334>
                    putch('?', putdat);
  800314:	03f00513          	li	a0,63
  800318:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80031a:	0405                	addi	s0,s0,1
  80031c:	fff44783          	lbu	a5,-1(s0)
  800320:	3dfd                	addiw	s11,s11,-1
  800322:	0007851b          	sext.w	a0,a5
  800326:	fd61                	bnez	a0,8002fe <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  800328:	e7b058e3          	blez	s11,800198 <vprintfmt+0x3a>
  80032c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80032e:	85a6                	mv	a1,s1
  800330:	02000513          	li	a0,32
  800334:	9902                	jalr	s2
            for (; width > 0; width --) {
  800336:	e60d81e3          	beqz	s11,800198 <vprintfmt+0x3a>
  80033a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80033c:	85a6                	mv	a1,s1
  80033e:	02000513          	li	a0,32
  800342:	9902                	jalr	s2
            for (; width > 0; width --) {
  800344:	fe0d94e3          	bnez	s11,80032c <vprintfmt+0x1ce>
  800348:	bd81                	j	800198 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80034a:	4705                	li	a4,1
  80034c:	008a8593          	addi	a1,s5,8
  800350:	01074463          	blt	a4,a6,800358 <vprintfmt+0x1fa>
    else if (lflag) {
  800354:	12080063          	beqz	a6,800474 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  800358:	000ab603          	ld	a2,0(s5)
  80035c:	46a9                	li	a3,10
  80035e:	8aae                	mv	s5,a1
  800360:	b7bd                	j	8002ce <vprintfmt+0x170>
  800362:	00144603          	lbu	a2,1(s0)
            padc = '-';
  800366:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  80036a:	846a                	mv	s0,s10
  80036c:	b5ad                	j	8001d6 <vprintfmt+0x78>
            putch(ch, putdat);
  80036e:	85a6                	mv	a1,s1
  800370:	02500513          	li	a0,37
  800374:	9902                	jalr	s2
            break;
  800376:	b50d                	j	800198 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  800378:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  80037c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800380:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800382:	846a                	mv	s0,s10
            if (width < 0)
  800384:	e40dd9e3          	bgez	s11,8001d6 <vprintfmt+0x78>
                width = precision, precision = -1;
  800388:	8de6                	mv	s11,s9
  80038a:	5cfd                	li	s9,-1
  80038c:	b5a9                	j	8001d6 <vprintfmt+0x78>
            goto reswitch;
  80038e:	00144603          	lbu	a2,1(s0)
            padc = '0';
  800392:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  800396:	846a                	mv	s0,s10
            goto reswitch;
  800398:	bd3d                	j	8001d6 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  80039a:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  80039e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8003a2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8003a4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8003a8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003ac:	fcd56ce3          	bltu	a0,a3,800384 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  8003b0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8003b2:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8003b6:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  8003ba:	0196873b          	addw	a4,a3,s9
  8003be:	0017171b          	slliw	a4,a4,0x1
  8003c2:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8003c6:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8003ca:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8003ce:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003d2:	fcd57fe3          	bleu	a3,a0,8003b0 <vprintfmt+0x252>
  8003d6:	b77d                	j	800384 <vprintfmt+0x226>
            if (width < 0)
  8003d8:	fffdc693          	not	a3,s11
  8003dc:	96fd                	srai	a3,a3,0x3f
  8003de:	00ddfdb3          	and	s11,s11,a3
  8003e2:	00144603          	lbu	a2,1(s0)
  8003e6:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  8003e8:	846a                	mv	s0,s10
  8003ea:	b3f5                	j	8001d6 <vprintfmt+0x78>
            putch('%', putdat);
  8003ec:	85a6                	mv	a1,s1
  8003ee:	02500513          	li	a0,37
  8003f2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8003f4:	fff44703          	lbu	a4,-1(s0)
  8003f8:	02500793          	li	a5,37
  8003fc:	8d22                	mv	s10,s0
  8003fe:	d8f70de3          	beq	a4,a5,800198 <vprintfmt+0x3a>
  800402:	02500713          	li	a4,37
  800406:	1d7d                	addi	s10,s10,-1
  800408:	fffd4783          	lbu	a5,-1(s10)
  80040c:	fee79de3          	bne	a5,a4,800406 <vprintfmt+0x2a8>
  800410:	b361                	j	800198 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800412:	00000617          	auipc	a2,0x0
  800416:	48660613          	addi	a2,a2,1158 # 800898 <error_string+0x1a8>
  80041a:	85a6                	mv	a1,s1
  80041c:	854a                	mv	a0,s2
  80041e:	0ac000ef          	jal	ra,8004ca <printfmt>
  800422:	bb9d                	j	800198 <vprintfmt+0x3a>
                p = "(null)";
  800424:	00000617          	auipc	a2,0x0
  800428:	46c60613          	addi	a2,a2,1132 # 800890 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  80042c:	00000417          	auipc	s0,0x0
  800430:	46540413          	addi	s0,s0,1125 # 800891 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800434:	8532                	mv	a0,a2
  800436:	85e6                	mv	a1,s9
  800438:	e032                	sd	a2,0(sp)
  80043a:	e43e                	sd	a5,8(sp)
  80043c:	0ae000ef          	jal	ra,8004ea <strnlen>
  800440:	40ad8dbb          	subw	s11,s11,a0
  800444:	6602                	ld	a2,0(sp)
  800446:	01b05d63          	blez	s11,800460 <vprintfmt+0x302>
  80044a:	67a2                	ld	a5,8(sp)
  80044c:	2781                	sext.w	a5,a5
  80044e:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  800450:	6522                	ld	a0,8(sp)
  800452:	85a6                	mv	a1,s1
  800454:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  800456:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800458:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80045a:	6602                	ld	a2,0(sp)
  80045c:	fe0d9ae3          	bnez	s11,800450 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800460:	00064783          	lbu	a5,0(a2)
  800464:	0007851b          	sext.w	a0,a5
  800468:	e8051be3          	bnez	a0,8002fe <vprintfmt+0x1a0>
  80046c:	b335                	j	800198 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  80046e:	000aa403          	lw	s0,0(s5)
  800472:	bbf1                	j	80024e <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  800474:	000ae603          	lwu	a2,0(s5)
  800478:	46a9                	li	a3,10
  80047a:	8aae                	mv	s5,a1
  80047c:	bd89                	j	8002ce <vprintfmt+0x170>
  80047e:	000ae603          	lwu	a2,0(s5)
  800482:	46c1                	li	a3,16
  800484:	8aae                	mv	s5,a1
  800486:	b5a1                	j	8002ce <vprintfmt+0x170>
  800488:	000ae603          	lwu	a2,0(s5)
  80048c:	46a1                	li	a3,8
  80048e:	8aae                	mv	s5,a1
  800490:	bd3d                	j	8002ce <vprintfmt+0x170>
                    putch(ch, putdat);
  800492:	9902                	jalr	s2
  800494:	b559                	j	80031a <vprintfmt+0x1bc>
                putch('-', putdat);
  800496:	85a6                	mv	a1,s1
  800498:	02d00513          	li	a0,45
  80049c:	e03e                	sd	a5,0(sp)
  80049e:	9902                	jalr	s2
                num = -(long long)num;
  8004a0:	8ace                	mv	s5,s3
  8004a2:	40800633          	neg	a2,s0
  8004a6:	46a9                	li	a3,10
  8004a8:	6782                	ld	a5,0(sp)
  8004aa:	b515                	j	8002ce <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  8004ac:	01b05663          	blez	s11,8004b8 <vprintfmt+0x35a>
  8004b0:	02d00693          	li	a3,45
  8004b4:	f6d798e3          	bne	a5,a3,800424 <vprintfmt+0x2c6>
  8004b8:	00000417          	auipc	s0,0x0
  8004bc:	3d940413          	addi	s0,s0,985 # 800891 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004c0:	02800513          	li	a0,40
  8004c4:	02800793          	li	a5,40
  8004c8:	bd1d                	j	8002fe <vprintfmt+0x1a0>

00000000008004ca <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ca:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004cc:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004d0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004d2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004d4:	ec06                	sd	ra,24(sp)
  8004d6:	f83a                	sd	a4,48(sp)
  8004d8:	fc3e                	sd	a5,56(sp)
  8004da:	e0c2                	sd	a6,64(sp)
  8004dc:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004de:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004e0:	c7fff0ef          	jal	ra,80015e <vprintfmt>
}
  8004e4:	60e2                	ld	ra,24(sp)
  8004e6:	6161                	addi	sp,sp,80
  8004e8:	8082                	ret

00000000008004ea <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  8004ea:	c185                	beqz	a1,80050a <strnlen+0x20>
  8004ec:	00054783          	lbu	a5,0(a0)
  8004f0:	cf89                	beqz	a5,80050a <strnlen+0x20>
    size_t cnt = 0;
  8004f2:	4781                	li	a5,0
  8004f4:	a021                	j	8004fc <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  8004f6:	00074703          	lbu	a4,0(a4)
  8004fa:	c711                	beqz	a4,800506 <strnlen+0x1c>
        cnt ++;
  8004fc:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004fe:	00f50733          	add	a4,a0,a5
  800502:	fef59ae3          	bne	a1,a5,8004f6 <strnlen+0xc>
    }
    return cnt;
}
  800506:	853e                	mv	a0,a5
  800508:	8082                	ret
    size_t cnt = 0;
  80050a:	4781                	li	a5,0
}
  80050c:	853e                	mv	a0,a5
  80050e:	8082                	ret

0000000000800510 <main>:
#include <ulib.h>
#include <stdio.h>

int
main(void) {
  800510:	1101                	addi	sp,sp,-32
  800512:	ec06                	sd	ra,24(sp)
  800514:	e822                	sd	s0,16(sp)
  800516:	e426                	sd	s1,8(sp)
  800518:	e04a                	sd	s2,0(sp)
    int i;
    cprintf("Hello, I am process %d.\n", getpid());
  80051a:	bc9ff0ef          	jal	ra,8000e2 <getpid>
  80051e:	85aa                	mv	a1,a0
  800520:	00000517          	auipc	a0,0x0
  800524:	39050513          	addi	a0,a0,912 # 8008b0 <error_string+0x1c0>
  800528:	b19ff0ef          	jal	ra,800040 <cprintf>
    for (i = 0; i < 5; i ++) {
  80052c:	4401                	li	s0,0
        yield();
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  80052e:	00000917          	auipc	s2,0x0
  800532:	3a290913          	addi	s2,s2,930 # 8008d0 <error_string+0x1e0>
    for (i = 0; i < 5; i ++) {
  800536:	4495                	li	s1,5
        yield();
  800538:	ba7ff0ef          	jal	ra,8000de <yield>
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  80053c:	ba7ff0ef          	jal	ra,8000e2 <getpid>
  800540:	8622                	mv	a2,s0
  800542:	85aa                	mv	a1,a0
    for (i = 0; i < 5; i ++) {
  800544:	2405                	addiw	s0,s0,1
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800546:	854a                	mv	a0,s2
  800548:	af9ff0ef          	jal	ra,800040 <cprintf>
    for (i = 0; i < 5; i ++) {
  80054c:	fe9416e3          	bne	s0,s1,800538 <main+0x28>
    }
    cprintf("All done in process %d.\n", getpid());
  800550:	b93ff0ef          	jal	ra,8000e2 <getpid>
  800554:	85aa                	mv	a1,a0
  800556:	00000517          	auipc	a0,0x0
  80055a:	3a250513          	addi	a0,a0,930 # 8008f8 <error_string+0x208>
  80055e:	ae3ff0ef          	jal	ra,800040 <cprintf>
    cprintf("yield pass.\n");
  800562:	00000517          	auipc	a0,0x0
  800566:	3b650513          	addi	a0,a0,950 # 800918 <error_string+0x228>
  80056a:	ad7ff0ef          	jal	ra,800040 <cprintf>
    return 0;
}
  80056e:	60e2                	ld	ra,24(sp)
  800570:	6442                	ld	s0,16(sp)
  800572:	64a2                	ld	s1,8(sp)
  800574:	6902                	ld	s2,0(sp)
  800576:	4501                	li	a0,0
  800578:	6105                	addi	sp,sp,32
  80057a:	8082                	ret
