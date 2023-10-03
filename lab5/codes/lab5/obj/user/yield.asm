
obj/__user_yield.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0c8000ef          	jal	ra,8000e8 <umain>
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
  80002e:	094000ef          	jal	ra,8000c2 <sys_putc>
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
  800068:	0f8000ef          	jal	ra,800160 <vprintfmt>
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
  800094:	6522                	ld	a0,8(sp)
  800096:	75a2                	ld	a1,40(sp)
  800098:	7642                	ld	a2,48(sp)
  80009a:	76e2                	ld	a3,56(sp)
  80009c:	6706                	ld	a4,64(sp)
  80009e:	67a6                	ld	a5,72(sp)
  8000a0:	00000073          	ecall
  8000a4:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  8000a8:	4572                	lw	a0,28(sp)
  8000aa:	6149                	addi	sp,sp,144
  8000ac:	8082                	ret

00000000008000ae <sys_exit>:

int
sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
  8000ae:	85aa                	mv	a1,a0
  8000b0:	4505                	li	a0,1
  8000b2:	fc3ff06f          	j	800074 <syscall>

00000000008000b6 <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  8000b6:	4529                	li	a0,10
  8000b8:	fbdff06f          	j	800074 <syscall>

00000000008000bc <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000bc:	4549                	li	a0,18
  8000be:	fb7ff06f          	j	800074 <syscall>

00000000008000c2 <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000c2:	85aa                	mv	a1,a0
  8000c4:	4579                	li	a0,30
  8000c6:	fafff06f          	j	800074 <syscall>

00000000008000ca <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000ca:	1141                	addi	sp,sp,-16
  8000cc:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000ce:	fe1ff0ef          	jal	ra,8000ae <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000d2:	00000517          	auipc	a0,0x0
  8000d6:	4ae50513          	addi	a0,a0,1198 # 800580 <main+0x6e>
  8000da:	f67ff0ef          	jal	ra,800040 <cprintf>
    while (1);
  8000de:	a001                	j	8000de <exit+0x14>

00000000008000e0 <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  8000e0:	fd7ff06f          	j	8000b6 <sys_yield>

00000000008000e4 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000e4:	fd9ff06f          	j	8000bc <sys_getpid>

00000000008000e8 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000e8:	1141                	addi	sp,sp,-16
  8000ea:	e406                	sd	ra,8(sp)
    int ret = main();
  8000ec:	426000ef          	jal	ra,800512 <main>
    exit(ret);
  8000f0:	fdbff0ef          	jal	ra,8000ca <exit>

00000000008000f4 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000f4:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000f8:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000fa:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000fe:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800100:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800104:	f022                	sd	s0,32(sp)
  800106:	ec26                	sd	s1,24(sp)
  800108:	e84a                	sd	s2,16(sp)
  80010a:	f406                	sd	ra,40(sp)
  80010c:	e44e                	sd	s3,8(sp)
  80010e:	84aa                	mv	s1,a0
  800110:	892e                	mv	s2,a1
  800112:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800116:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800118:	03067e63          	bleu	a6,a2,800154 <printnum+0x60>
  80011c:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80011e:	00805763          	blez	s0,80012c <printnum+0x38>
  800122:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800124:	85ca                	mv	a1,s2
  800126:	854e                	mv	a0,s3
  800128:	9482                	jalr	s1
        while (-- width > 0)
  80012a:	fc65                	bnez	s0,800122 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80012c:	1a02                	slli	s4,s4,0x20
  80012e:	020a5a13          	srli	s4,s4,0x20
  800132:	00000797          	auipc	a5,0x0
  800136:	68678793          	addi	a5,a5,1670 # 8007b8 <error_string+0xc8>
  80013a:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80013c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80013e:	000a4503          	lbu	a0,0(s4)
}
  800142:	70a2                	ld	ra,40(sp)
  800144:	69a2                	ld	s3,8(sp)
  800146:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800148:	85ca                	mv	a1,s2
  80014a:	8326                	mv	t1,s1
}
  80014c:	6942                	ld	s2,16(sp)
  80014e:	64e2                	ld	s1,24(sp)
  800150:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800152:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  800154:	03065633          	divu	a2,a2,a6
  800158:	8722                	mv	a4,s0
  80015a:	f9bff0ef          	jal	ra,8000f4 <printnum>
  80015e:	b7f9                	j	80012c <printnum+0x38>

0000000000800160 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800160:	7119                	addi	sp,sp,-128
  800162:	f4a6                	sd	s1,104(sp)
  800164:	f0ca                	sd	s2,96(sp)
  800166:	e8d2                	sd	s4,80(sp)
  800168:	e4d6                	sd	s5,72(sp)
  80016a:	e0da                	sd	s6,64(sp)
  80016c:	fc5e                	sd	s7,56(sp)
  80016e:	f862                	sd	s8,48(sp)
  800170:	f06a                	sd	s10,32(sp)
  800172:	fc86                	sd	ra,120(sp)
  800174:	f8a2                	sd	s0,112(sp)
  800176:	ecce                	sd	s3,88(sp)
  800178:	f466                	sd	s9,40(sp)
  80017a:	ec6e                	sd	s11,24(sp)
  80017c:	892a                	mv	s2,a0
  80017e:	84ae                	mv	s1,a1
  800180:	8d32                	mv	s10,a2
  800182:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800184:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800186:	00000a17          	auipc	s4,0x0
  80018a:	40ea0a13          	addi	s4,s4,1038 # 800594 <main+0x82>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  80018e:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800192:	00000c17          	auipc	s8,0x0
  800196:	55ec0c13          	addi	s8,s8,1374 # 8006f0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80019a:	000d4503          	lbu	a0,0(s10)
  80019e:	02500793          	li	a5,37
  8001a2:	001d0413          	addi	s0,s10,1
  8001a6:	00f50e63          	beq	a0,a5,8001c2 <vprintfmt+0x62>
            if (ch == '\0') {
  8001aa:	c521                	beqz	a0,8001f2 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ac:	02500993          	li	s3,37
  8001b0:	a011                	j	8001b4 <vprintfmt+0x54>
            if (ch == '\0') {
  8001b2:	c121                	beqz	a0,8001f2 <vprintfmt+0x92>
            putch(ch, putdat);
  8001b4:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001b6:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001b8:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ba:	fff44503          	lbu	a0,-1(s0)
  8001be:	ff351ae3          	bne	a0,s3,8001b2 <vprintfmt+0x52>
  8001c2:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001c6:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001ca:	4981                	li	s3,0
  8001cc:	4801                	li	a6,0
        width = precision = -1;
  8001ce:	5cfd                	li	s9,-1
  8001d0:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001d2:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  8001d6:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001d8:	fdd6069b          	addiw	a3,a2,-35
  8001dc:	0ff6f693          	andi	a3,a3,255
  8001e0:	00140d13          	addi	s10,s0,1
  8001e4:	20d5e563          	bltu	a1,a3,8003ee <vprintfmt+0x28e>
  8001e8:	068a                	slli	a3,a3,0x2
  8001ea:	96d2                	add	a3,a3,s4
  8001ec:	4294                	lw	a3,0(a3)
  8001ee:	96d2                	add	a3,a3,s4
  8001f0:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001f2:	70e6                	ld	ra,120(sp)
  8001f4:	7446                	ld	s0,112(sp)
  8001f6:	74a6                	ld	s1,104(sp)
  8001f8:	7906                	ld	s2,96(sp)
  8001fa:	69e6                	ld	s3,88(sp)
  8001fc:	6a46                	ld	s4,80(sp)
  8001fe:	6aa6                	ld	s5,72(sp)
  800200:	6b06                	ld	s6,64(sp)
  800202:	7be2                	ld	s7,56(sp)
  800204:	7c42                	ld	s8,48(sp)
  800206:	7ca2                	ld	s9,40(sp)
  800208:	7d02                	ld	s10,32(sp)
  80020a:	6de2                	ld	s11,24(sp)
  80020c:	6109                	addi	sp,sp,128
  80020e:	8082                	ret
    if (lflag >= 2) {
  800210:	4705                	li	a4,1
  800212:	008a8593          	addi	a1,s5,8
  800216:	01074463          	blt	a4,a6,80021e <vprintfmt+0xbe>
    else if (lflag) {
  80021a:	26080363          	beqz	a6,800480 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  80021e:	000ab603          	ld	a2,0(s5)
  800222:	46c1                	li	a3,16
  800224:	8aae                	mv	s5,a1
  800226:	a06d                	j	8002d0 <vprintfmt+0x170>
            goto reswitch;
  800228:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  80022c:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  80022e:	846a                	mv	s0,s10
            goto reswitch;
  800230:	b765                	j	8001d8 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  800232:	000aa503          	lw	a0,0(s5)
  800236:	85a6                	mv	a1,s1
  800238:	0aa1                	addi	s5,s5,8
  80023a:	9902                	jalr	s2
            break;
  80023c:	bfb9                	j	80019a <vprintfmt+0x3a>
    if (lflag >= 2) {
  80023e:	4705                	li	a4,1
  800240:	008a8993          	addi	s3,s5,8
  800244:	01074463          	blt	a4,a6,80024c <vprintfmt+0xec>
    else if (lflag) {
  800248:	22080463          	beqz	a6,800470 <vprintfmt+0x310>
        return va_arg(*ap, long);
  80024c:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  800250:	24044463          	bltz	s0,800498 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  800254:	8622                	mv	a2,s0
  800256:	8ace                	mv	s5,s3
  800258:	46a9                	li	a3,10
  80025a:	a89d                	j	8002d0 <vprintfmt+0x170>
            err = va_arg(ap, int);
  80025c:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800260:	4761                	li	a4,24
            err = va_arg(ap, int);
  800262:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  800264:	41f7d69b          	sraiw	a3,a5,0x1f
  800268:	8fb5                	xor	a5,a5,a3
  80026a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80026e:	1ad74363          	blt	a4,a3,800414 <vprintfmt+0x2b4>
  800272:	00369793          	slli	a5,a3,0x3
  800276:	97e2                	add	a5,a5,s8
  800278:	639c                	ld	a5,0(a5)
  80027a:	18078d63          	beqz	a5,800414 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  80027e:	86be                	mv	a3,a5
  800280:	00000617          	auipc	a2,0x0
  800284:	62860613          	addi	a2,a2,1576 # 8008a8 <error_string+0x1b8>
  800288:	85a6                	mv	a1,s1
  80028a:	854a                	mv	a0,s2
  80028c:	240000ef          	jal	ra,8004cc <printfmt>
  800290:	b729                	j	80019a <vprintfmt+0x3a>
            lflag ++;
  800292:	00144603          	lbu	a2,1(s0)
  800296:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800298:	846a                	mv	s0,s10
            goto reswitch;
  80029a:	bf3d                	j	8001d8 <vprintfmt+0x78>
    if (lflag >= 2) {
  80029c:	4705                	li	a4,1
  80029e:	008a8593          	addi	a1,s5,8
  8002a2:	01074463          	blt	a4,a6,8002aa <vprintfmt+0x14a>
    else if (lflag) {
  8002a6:	1e080263          	beqz	a6,80048a <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  8002aa:	000ab603          	ld	a2,0(s5)
  8002ae:	46a1                	li	a3,8
  8002b0:	8aae                	mv	s5,a1
  8002b2:	a839                	j	8002d0 <vprintfmt+0x170>
            putch('0', putdat);
  8002b4:	03000513          	li	a0,48
  8002b8:	85a6                	mv	a1,s1
  8002ba:	e03e                	sd	a5,0(sp)
  8002bc:	9902                	jalr	s2
            putch('x', putdat);
  8002be:	85a6                	mv	a1,s1
  8002c0:	07800513          	li	a0,120
  8002c4:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002c6:	0aa1                	addi	s5,s5,8
  8002c8:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  8002cc:	6782                	ld	a5,0(sp)
  8002ce:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  8002d0:	876e                	mv	a4,s11
  8002d2:	85a6                	mv	a1,s1
  8002d4:	854a                	mv	a0,s2
  8002d6:	e1fff0ef          	jal	ra,8000f4 <printnum>
            break;
  8002da:	b5c1                	j	80019a <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  8002dc:	000ab603          	ld	a2,0(s5)
  8002e0:	0aa1                	addi	s5,s5,8
  8002e2:	1c060663          	beqz	a2,8004ae <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  8002e6:	00160413          	addi	s0,a2,1
  8002ea:	17b05c63          	blez	s11,800462 <vprintfmt+0x302>
  8002ee:	02d00593          	li	a1,45
  8002f2:	14b79263          	bne	a5,a1,800436 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8002f6:	00064783          	lbu	a5,0(a2)
  8002fa:	0007851b          	sext.w	a0,a5
  8002fe:	c905                	beqz	a0,80032e <vprintfmt+0x1ce>
  800300:	000cc563          	bltz	s9,80030a <vprintfmt+0x1aa>
  800304:	3cfd                	addiw	s9,s9,-1
  800306:	036c8263          	beq	s9,s6,80032a <vprintfmt+0x1ca>
                    putch('?', putdat);
  80030a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80030c:	18098463          	beqz	s3,800494 <vprintfmt+0x334>
  800310:	3781                	addiw	a5,a5,-32
  800312:	18fbf163          	bleu	a5,s7,800494 <vprintfmt+0x334>
                    putch('?', putdat);
  800316:	03f00513          	li	a0,63
  80031a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80031c:	0405                	addi	s0,s0,1
  80031e:	fff44783          	lbu	a5,-1(s0)
  800322:	3dfd                	addiw	s11,s11,-1
  800324:	0007851b          	sext.w	a0,a5
  800328:	fd61                	bnez	a0,800300 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  80032a:	e7b058e3          	blez	s11,80019a <vprintfmt+0x3a>
  80032e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800330:	85a6                	mv	a1,s1
  800332:	02000513          	li	a0,32
  800336:	9902                	jalr	s2
            for (; width > 0; width --) {
  800338:	e60d81e3          	beqz	s11,80019a <vprintfmt+0x3a>
  80033c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80033e:	85a6                	mv	a1,s1
  800340:	02000513          	li	a0,32
  800344:	9902                	jalr	s2
            for (; width > 0; width --) {
  800346:	fe0d94e3          	bnez	s11,80032e <vprintfmt+0x1ce>
  80034a:	bd81                	j	80019a <vprintfmt+0x3a>
    if (lflag >= 2) {
  80034c:	4705                	li	a4,1
  80034e:	008a8593          	addi	a1,s5,8
  800352:	01074463          	blt	a4,a6,80035a <vprintfmt+0x1fa>
    else if (lflag) {
  800356:	12080063          	beqz	a6,800476 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  80035a:	000ab603          	ld	a2,0(s5)
  80035e:	46a9                	li	a3,10
  800360:	8aae                	mv	s5,a1
  800362:	b7bd                	j	8002d0 <vprintfmt+0x170>
  800364:	00144603          	lbu	a2,1(s0)
            padc = '-';
  800368:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  80036c:	846a                	mv	s0,s10
  80036e:	b5ad                	j	8001d8 <vprintfmt+0x78>
            putch(ch, putdat);
  800370:	85a6                	mv	a1,s1
  800372:	02500513          	li	a0,37
  800376:	9902                	jalr	s2
            break;
  800378:	b50d                	j	80019a <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  80037a:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  80037e:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800382:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800384:	846a                	mv	s0,s10
            if (width < 0)
  800386:	e40dd9e3          	bgez	s11,8001d8 <vprintfmt+0x78>
                width = precision, precision = -1;
  80038a:	8de6                	mv	s11,s9
  80038c:	5cfd                	li	s9,-1
  80038e:	b5a9                	j	8001d8 <vprintfmt+0x78>
            goto reswitch;
  800390:	00144603          	lbu	a2,1(s0)
            padc = '0';
  800394:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  800398:	846a                	mv	s0,s10
            goto reswitch;
  80039a:	bd3d                	j	8001d8 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  80039c:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8003a0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8003a4:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8003a6:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8003aa:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003ae:	fcd56ce3          	bltu	a0,a3,800386 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  8003b2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8003b4:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8003b8:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  8003bc:	0196873b          	addw	a4,a3,s9
  8003c0:	0017171b          	slliw	a4,a4,0x1
  8003c4:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8003c8:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8003cc:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8003d0:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003d4:	fcd57fe3          	bleu	a3,a0,8003b2 <vprintfmt+0x252>
  8003d8:	b77d                	j	800386 <vprintfmt+0x226>
            if (width < 0)
  8003da:	fffdc693          	not	a3,s11
  8003de:	96fd                	srai	a3,a3,0x3f
  8003e0:	00ddfdb3          	and	s11,s11,a3
  8003e4:	00144603          	lbu	a2,1(s0)
  8003e8:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  8003ea:	846a                	mv	s0,s10
  8003ec:	b3f5                	j	8001d8 <vprintfmt+0x78>
            putch('%', putdat);
  8003ee:	85a6                	mv	a1,s1
  8003f0:	02500513          	li	a0,37
  8003f4:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8003f6:	fff44703          	lbu	a4,-1(s0)
  8003fa:	02500793          	li	a5,37
  8003fe:	8d22                	mv	s10,s0
  800400:	d8f70de3          	beq	a4,a5,80019a <vprintfmt+0x3a>
  800404:	02500713          	li	a4,37
  800408:	1d7d                	addi	s10,s10,-1
  80040a:	fffd4783          	lbu	a5,-1(s10)
  80040e:	fee79de3          	bne	a5,a4,800408 <vprintfmt+0x2a8>
  800412:	b361                	j	80019a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800414:	00000617          	auipc	a2,0x0
  800418:	48460613          	addi	a2,a2,1156 # 800898 <error_string+0x1a8>
  80041c:	85a6                	mv	a1,s1
  80041e:	854a                	mv	a0,s2
  800420:	0ac000ef          	jal	ra,8004cc <printfmt>
  800424:	bb9d                	j	80019a <vprintfmt+0x3a>
                p = "(null)";
  800426:	00000617          	auipc	a2,0x0
  80042a:	46a60613          	addi	a2,a2,1130 # 800890 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  80042e:	00000417          	auipc	s0,0x0
  800432:	46340413          	addi	s0,s0,1123 # 800891 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800436:	8532                	mv	a0,a2
  800438:	85e6                	mv	a1,s9
  80043a:	e032                	sd	a2,0(sp)
  80043c:	e43e                	sd	a5,8(sp)
  80043e:	0ae000ef          	jal	ra,8004ec <strnlen>
  800442:	40ad8dbb          	subw	s11,s11,a0
  800446:	6602                	ld	a2,0(sp)
  800448:	01b05d63          	blez	s11,800462 <vprintfmt+0x302>
  80044c:	67a2                	ld	a5,8(sp)
  80044e:	2781                	sext.w	a5,a5
  800450:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  800452:	6522                	ld	a0,8(sp)
  800454:	85a6                	mv	a1,s1
  800456:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  800458:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  80045a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80045c:	6602                	ld	a2,0(sp)
  80045e:	fe0d9ae3          	bnez	s11,800452 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800462:	00064783          	lbu	a5,0(a2)
  800466:	0007851b          	sext.w	a0,a5
  80046a:	e8051be3          	bnez	a0,800300 <vprintfmt+0x1a0>
  80046e:	b335                	j	80019a <vprintfmt+0x3a>
        return va_arg(*ap, int);
  800470:	000aa403          	lw	s0,0(s5)
  800474:	bbf1                	j	800250 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  800476:	000ae603          	lwu	a2,0(s5)
  80047a:	46a9                	li	a3,10
  80047c:	8aae                	mv	s5,a1
  80047e:	bd89                	j	8002d0 <vprintfmt+0x170>
  800480:	000ae603          	lwu	a2,0(s5)
  800484:	46c1                	li	a3,16
  800486:	8aae                	mv	s5,a1
  800488:	b5a1                	j	8002d0 <vprintfmt+0x170>
  80048a:	000ae603          	lwu	a2,0(s5)
  80048e:	46a1                	li	a3,8
  800490:	8aae                	mv	s5,a1
  800492:	bd3d                	j	8002d0 <vprintfmt+0x170>
                    putch(ch, putdat);
  800494:	9902                	jalr	s2
  800496:	b559                	j	80031c <vprintfmt+0x1bc>
                putch('-', putdat);
  800498:	85a6                	mv	a1,s1
  80049a:	02d00513          	li	a0,45
  80049e:	e03e                	sd	a5,0(sp)
  8004a0:	9902                	jalr	s2
                num = -(long long)num;
  8004a2:	8ace                	mv	s5,s3
  8004a4:	40800633          	neg	a2,s0
  8004a8:	46a9                	li	a3,10
  8004aa:	6782                	ld	a5,0(sp)
  8004ac:	b515                	j	8002d0 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  8004ae:	01b05663          	blez	s11,8004ba <vprintfmt+0x35a>
  8004b2:	02d00693          	li	a3,45
  8004b6:	f6d798e3          	bne	a5,a3,800426 <vprintfmt+0x2c6>
  8004ba:	00000417          	auipc	s0,0x0
  8004be:	3d740413          	addi	s0,s0,983 # 800891 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004c2:	02800513          	li	a0,40
  8004c6:	02800793          	li	a5,40
  8004ca:	bd1d                	j	800300 <vprintfmt+0x1a0>

00000000008004cc <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004cc:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004ce:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004d2:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004d4:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004d6:	ec06                	sd	ra,24(sp)
  8004d8:	f83a                	sd	a4,48(sp)
  8004da:	fc3e                	sd	a5,56(sp)
  8004dc:	e0c2                	sd	a6,64(sp)
  8004de:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004e0:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004e2:	c7fff0ef          	jal	ra,800160 <vprintfmt>
}
  8004e6:	60e2                	ld	ra,24(sp)
  8004e8:	6161                	addi	sp,sp,80
  8004ea:	8082                	ret

00000000008004ec <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  8004ec:	c185                	beqz	a1,80050c <strnlen+0x20>
  8004ee:	00054783          	lbu	a5,0(a0)
  8004f2:	cf89                	beqz	a5,80050c <strnlen+0x20>
    size_t cnt = 0;
  8004f4:	4781                	li	a5,0
  8004f6:	a021                	j	8004fe <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  8004f8:	00074703          	lbu	a4,0(a4)
  8004fc:	c711                	beqz	a4,800508 <strnlen+0x1c>
        cnt ++;
  8004fe:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800500:	00f50733          	add	a4,a0,a5
  800504:	fef59ae3          	bne	a1,a5,8004f8 <strnlen+0xc>
    }
    return cnt;
}
  800508:	853e                	mv	a0,a5
  80050a:	8082                	ret
    size_t cnt = 0;
  80050c:	4781                	li	a5,0
}
  80050e:	853e                	mv	a0,a5
  800510:	8082                	ret

0000000000800512 <main>:
#include <ulib.h>
#include <stdio.h>

int
main(void) {
  800512:	1101                	addi	sp,sp,-32
  800514:	ec06                	sd	ra,24(sp)
  800516:	e822                	sd	s0,16(sp)
  800518:	e426                	sd	s1,8(sp)
  80051a:	e04a                	sd	s2,0(sp)
    int i;
    cprintf("Hello, I am process %d.\n", getpid());
  80051c:	bc9ff0ef          	jal	ra,8000e4 <getpid>
  800520:	85aa                	mv	a1,a0
  800522:	00000517          	auipc	a0,0x0
  800526:	38e50513          	addi	a0,a0,910 # 8008b0 <error_string+0x1c0>
  80052a:	b17ff0ef          	jal	ra,800040 <cprintf>
    for (i = 0; i < 5; i ++) {
  80052e:	4401                	li	s0,0
        yield();
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800530:	00000917          	auipc	s2,0x0
  800534:	3a090913          	addi	s2,s2,928 # 8008d0 <error_string+0x1e0>
    for (i = 0; i < 5; i ++) {
  800538:	4495                	li	s1,5
        yield();
  80053a:	ba7ff0ef          	jal	ra,8000e0 <yield>
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  80053e:	ba7ff0ef          	jal	ra,8000e4 <getpid>
  800542:	8622                	mv	a2,s0
  800544:	85aa                	mv	a1,a0
    for (i = 0; i < 5; i ++) {
  800546:	2405                	addiw	s0,s0,1
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800548:	854a                	mv	a0,s2
  80054a:	af7ff0ef          	jal	ra,800040 <cprintf>
    for (i = 0; i < 5; i ++) {
  80054e:	fe9416e3          	bne	s0,s1,80053a <main+0x28>
    }
    cprintf("All done in process %d.\n", getpid());
  800552:	b93ff0ef          	jal	ra,8000e4 <getpid>
  800556:	85aa                	mv	a1,a0
  800558:	00000517          	auipc	a0,0x0
  80055c:	3a050513          	addi	a0,a0,928 # 8008f8 <error_string+0x208>
  800560:	ae1ff0ef          	jal	ra,800040 <cprintf>
    cprintf("yield pass.\n");
  800564:	00000517          	auipc	a0,0x0
  800568:	3b450513          	addi	a0,a0,948 # 800918 <error_string+0x228>
  80056c:	ad5ff0ef          	jal	ra,800040 <cprintf>
    return 0;
}
  800570:	60e2                	ld	ra,24(sp)
  800572:	6442                	ld	s0,16(sp)
  800574:	64a2                	ld	s1,8(sp)
  800576:	6902                	ld	s2,0(sp)
  800578:	4501                	li	a0,0
  80057a:	6105                	addi	sp,sp,32
  80057c:	8082                	ret
