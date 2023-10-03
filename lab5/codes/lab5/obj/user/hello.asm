
obj/__user_hello.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0be000ef          	jal	ra,8000de <umain>
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
  80002e:	08e000ef          	jal	ra,8000bc <sys_putc>
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
  800068:	0ee000ef          	jal	ra,800156 <vprintfmt>
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

00000000008000b6 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000b6:	4549                	li	a0,18
  8000b8:	fbdff06f          	j	800074 <syscall>

00000000008000bc <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000bc:	85aa                	mv	a1,a0
  8000be:	4579                	li	a0,30
  8000c0:	fb5ff06f          	j	800074 <syscall>

00000000008000c4 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c4:	1141                	addi	sp,sp,-16
  8000c6:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c8:	fe7ff0ef          	jal	ra,8000ae <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000cc:	00000517          	auipc	a0,0x0
  8000d0:	47450513          	addi	a0,a0,1140 # 800540 <main+0x38>
  8000d4:	f6dff0ef          	jal	ra,800040 <cprintf>
    while (1);
  8000d8:	a001                	j	8000d8 <exit+0x14>

00000000008000da <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000da:	fddff06f          	j	8000b6 <sys_getpid>

00000000008000de <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000de:	1141                	addi	sp,sp,-16
  8000e0:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e2:	426000ef          	jal	ra,800508 <main>
    exit(ret);
  8000e6:	fdfff0ef          	jal	ra,8000c4 <exit>

00000000008000ea <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000ea:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000ee:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000f0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000f4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000f6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8000fa:	f022                	sd	s0,32(sp)
  8000fc:	ec26                	sd	s1,24(sp)
  8000fe:	e84a                	sd	s2,16(sp)
  800100:	f406                	sd	ra,40(sp)
  800102:	e44e                	sd	s3,8(sp)
  800104:	84aa                	mv	s1,a0
  800106:	892e                	mv	s2,a1
  800108:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80010c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  80010e:	03067e63          	bleu	a6,a2,80014a <printnum+0x60>
  800112:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800114:	00805763          	blez	s0,800122 <printnum+0x38>
  800118:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80011a:	85ca                	mv	a1,s2
  80011c:	854e                	mv	a0,s3
  80011e:	9482                	jalr	s1
        while (-- width > 0)
  800120:	fc65                	bnez	s0,800118 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800122:	1a02                	slli	s4,s4,0x20
  800124:	020a5a13          	srli	s4,s4,0x20
  800128:	00000797          	auipc	a5,0x0
  80012c:	65078793          	addi	a5,a5,1616 # 800778 <error_string+0xc8>
  800130:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800132:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800134:	000a4503          	lbu	a0,0(s4)
}
  800138:	70a2                	ld	ra,40(sp)
  80013a:	69a2                	ld	s3,8(sp)
  80013c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80013e:	85ca                	mv	a1,s2
  800140:	8326                	mv	t1,s1
}
  800142:	6942                	ld	s2,16(sp)
  800144:	64e2                	ld	s1,24(sp)
  800146:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800148:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  80014a:	03065633          	divu	a2,a2,a6
  80014e:	8722                	mv	a4,s0
  800150:	f9bff0ef          	jal	ra,8000ea <printnum>
  800154:	b7f9                	j	800122 <printnum+0x38>

0000000000800156 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800156:	7119                	addi	sp,sp,-128
  800158:	f4a6                	sd	s1,104(sp)
  80015a:	f0ca                	sd	s2,96(sp)
  80015c:	e8d2                	sd	s4,80(sp)
  80015e:	e4d6                	sd	s5,72(sp)
  800160:	e0da                	sd	s6,64(sp)
  800162:	fc5e                	sd	s7,56(sp)
  800164:	f862                	sd	s8,48(sp)
  800166:	f06a                	sd	s10,32(sp)
  800168:	fc86                	sd	ra,120(sp)
  80016a:	f8a2                	sd	s0,112(sp)
  80016c:	ecce                	sd	s3,88(sp)
  80016e:	f466                	sd	s9,40(sp)
  800170:	ec6e                	sd	s11,24(sp)
  800172:	892a                	mv	s2,a0
  800174:	84ae                	mv	s1,a1
  800176:	8d32                	mv	s10,a2
  800178:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  80017a:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  80017c:	00000a17          	auipc	s4,0x0
  800180:	3d8a0a13          	addi	s4,s4,984 # 800554 <main+0x4c>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800184:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800188:	00000c17          	auipc	s8,0x0
  80018c:	528c0c13          	addi	s8,s8,1320 # 8006b0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800190:	000d4503          	lbu	a0,0(s10)
  800194:	02500793          	li	a5,37
  800198:	001d0413          	addi	s0,s10,1
  80019c:	00f50e63          	beq	a0,a5,8001b8 <vprintfmt+0x62>
            if (ch == '\0') {
  8001a0:	c521                	beqz	a0,8001e8 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a2:	02500993          	li	s3,37
  8001a6:	a011                	j	8001aa <vprintfmt+0x54>
            if (ch == '\0') {
  8001a8:	c121                	beqz	a0,8001e8 <vprintfmt+0x92>
            putch(ch, putdat);
  8001aa:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ac:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001ae:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001b0:	fff44503          	lbu	a0,-1(s0)
  8001b4:	ff351ae3          	bne	a0,s3,8001a8 <vprintfmt+0x52>
  8001b8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001bc:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001c0:	4981                	li	s3,0
  8001c2:	4801                	li	a6,0
        width = precision = -1;
  8001c4:	5cfd                	li	s9,-1
  8001c6:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001c8:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  8001cc:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001ce:	fdd6069b          	addiw	a3,a2,-35
  8001d2:	0ff6f693          	andi	a3,a3,255
  8001d6:	00140d13          	addi	s10,s0,1
  8001da:	20d5e563          	bltu	a1,a3,8003e4 <vprintfmt+0x28e>
  8001de:	068a                	slli	a3,a3,0x2
  8001e0:	96d2                	add	a3,a3,s4
  8001e2:	4294                	lw	a3,0(a3)
  8001e4:	96d2                	add	a3,a3,s4
  8001e6:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001e8:	70e6                	ld	ra,120(sp)
  8001ea:	7446                	ld	s0,112(sp)
  8001ec:	74a6                	ld	s1,104(sp)
  8001ee:	7906                	ld	s2,96(sp)
  8001f0:	69e6                	ld	s3,88(sp)
  8001f2:	6a46                	ld	s4,80(sp)
  8001f4:	6aa6                	ld	s5,72(sp)
  8001f6:	6b06                	ld	s6,64(sp)
  8001f8:	7be2                	ld	s7,56(sp)
  8001fa:	7c42                	ld	s8,48(sp)
  8001fc:	7ca2                	ld	s9,40(sp)
  8001fe:	7d02                	ld	s10,32(sp)
  800200:	6de2                	ld	s11,24(sp)
  800202:	6109                	addi	sp,sp,128
  800204:	8082                	ret
    if (lflag >= 2) {
  800206:	4705                	li	a4,1
  800208:	008a8593          	addi	a1,s5,8
  80020c:	01074463          	blt	a4,a6,800214 <vprintfmt+0xbe>
    else if (lflag) {
  800210:	26080363          	beqz	a6,800476 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  800214:	000ab603          	ld	a2,0(s5)
  800218:	46c1                	li	a3,16
  80021a:	8aae                	mv	s5,a1
  80021c:	a06d                	j	8002c6 <vprintfmt+0x170>
            goto reswitch;
  80021e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800222:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800224:	846a                	mv	s0,s10
            goto reswitch;
  800226:	b765                	j	8001ce <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  800228:	000aa503          	lw	a0,0(s5)
  80022c:	85a6                	mv	a1,s1
  80022e:	0aa1                	addi	s5,s5,8
  800230:	9902                	jalr	s2
            break;
  800232:	bfb9                	j	800190 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800234:	4705                	li	a4,1
  800236:	008a8993          	addi	s3,s5,8
  80023a:	01074463          	blt	a4,a6,800242 <vprintfmt+0xec>
    else if (lflag) {
  80023e:	22080463          	beqz	a6,800466 <vprintfmt+0x310>
        return va_arg(*ap, long);
  800242:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  800246:	24044463          	bltz	s0,80048e <vprintfmt+0x338>
            num = getint(&ap, lflag);
  80024a:	8622                	mv	a2,s0
  80024c:	8ace                	mv	s5,s3
  80024e:	46a9                	li	a3,10
  800250:	a89d                	j	8002c6 <vprintfmt+0x170>
            err = va_arg(ap, int);
  800252:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800256:	4761                	li	a4,24
            err = va_arg(ap, int);
  800258:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  80025a:	41f7d69b          	sraiw	a3,a5,0x1f
  80025e:	8fb5                	xor	a5,a5,a3
  800260:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800264:	1ad74363          	blt	a4,a3,80040a <vprintfmt+0x2b4>
  800268:	00369793          	slli	a5,a3,0x3
  80026c:	97e2                	add	a5,a5,s8
  80026e:	639c                	ld	a5,0(a5)
  800270:	18078d63          	beqz	a5,80040a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  800274:	86be                	mv	a3,a5
  800276:	00000617          	auipc	a2,0x0
  80027a:	5f260613          	addi	a2,a2,1522 # 800868 <error_string+0x1b8>
  80027e:	85a6                	mv	a1,s1
  800280:	854a                	mv	a0,s2
  800282:	240000ef          	jal	ra,8004c2 <printfmt>
  800286:	b729                	j	800190 <vprintfmt+0x3a>
            lflag ++;
  800288:	00144603          	lbu	a2,1(s0)
  80028c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  80028e:	846a                	mv	s0,s10
            goto reswitch;
  800290:	bf3d                	j	8001ce <vprintfmt+0x78>
    if (lflag >= 2) {
  800292:	4705                	li	a4,1
  800294:	008a8593          	addi	a1,s5,8
  800298:	01074463          	blt	a4,a6,8002a0 <vprintfmt+0x14a>
    else if (lflag) {
  80029c:	1e080263          	beqz	a6,800480 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  8002a0:	000ab603          	ld	a2,0(s5)
  8002a4:	46a1                	li	a3,8
  8002a6:	8aae                	mv	s5,a1
  8002a8:	a839                	j	8002c6 <vprintfmt+0x170>
            putch('0', putdat);
  8002aa:	03000513          	li	a0,48
  8002ae:	85a6                	mv	a1,s1
  8002b0:	e03e                	sd	a5,0(sp)
  8002b2:	9902                	jalr	s2
            putch('x', putdat);
  8002b4:	85a6                	mv	a1,s1
  8002b6:	07800513          	li	a0,120
  8002ba:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002bc:	0aa1                	addi	s5,s5,8
  8002be:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  8002c2:	6782                	ld	a5,0(sp)
  8002c4:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  8002c6:	876e                	mv	a4,s11
  8002c8:	85a6                	mv	a1,s1
  8002ca:	854a                	mv	a0,s2
  8002cc:	e1fff0ef          	jal	ra,8000ea <printnum>
            break;
  8002d0:	b5c1                	j	800190 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  8002d2:	000ab603          	ld	a2,0(s5)
  8002d6:	0aa1                	addi	s5,s5,8
  8002d8:	1c060663          	beqz	a2,8004a4 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  8002dc:	00160413          	addi	s0,a2,1
  8002e0:	17b05c63          	blez	s11,800458 <vprintfmt+0x302>
  8002e4:	02d00593          	li	a1,45
  8002e8:	14b79263          	bne	a5,a1,80042c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8002ec:	00064783          	lbu	a5,0(a2)
  8002f0:	0007851b          	sext.w	a0,a5
  8002f4:	c905                	beqz	a0,800324 <vprintfmt+0x1ce>
  8002f6:	000cc563          	bltz	s9,800300 <vprintfmt+0x1aa>
  8002fa:	3cfd                	addiw	s9,s9,-1
  8002fc:	036c8263          	beq	s9,s6,800320 <vprintfmt+0x1ca>
                    putch('?', putdat);
  800300:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800302:	18098463          	beqz	s3,80048a <vprintfmt+0x334>
  800306:	3781                	addiw	a5,a5,-32
  800308:	18fbf163          	bleu	a5,s7,80048a <vprintfmt+0x334>
                    putch('?', putdat);
  80030c:	03f00513          	li	a0,63
  800310:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800312:	0405                	addi	s0,s0,1
  800314:	fff44783          	lbu	a5,-1(s0)
  800318:	3dfd                	addiw	s11,s11,-1
  80031a:	0007851b          	sext.w	a0,a5
  80031e:	fd61                	bnez	a0,8002f6 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  800320:	e7b058e3          	blez	s11,800190 <vprintfmt+0x3a>
  800324:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800326:	85a6                	mv	a1,s1
  800328:	02000513          	li	a0,32
  80032c:	9902                	jalr	s2
            for (; width > 0; width --) {
  80032e:	e60d81e3          	beqz	s11,800190 <vprintfmt+0x3a>
  800332:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800334:	85a6                	mv	a1,s1
  800336:	02000513          	li	a0,32
  80033a:	9902                	jalr	s2
            for (; width > 0; width --) {
  80033c:	fe0d94e3          	bnez	s11,800324 <vprintfmt+0x1ce>
  800340:	bd81                	j	800190 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800342:	4705                	li	a4,1
  800344:	008a8593          	addi	a1,s5,8
  800348:	01074463          	blt	a4,a6,800350 <vprintfmt+0x1fa>
    else if (lflag) {
  80034c:	12080063          	beqz	a6,80046c <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  800350:	000ab603          	ld	a2,0(s5)
  800354:	46a9                	li	a3,10
  800356:	8aae                	mv	s5,a1
  800358:	b7bd                	j	8002c6 <vprintfmt+0x170>
  80035a:	00144603          	lbu	a2,1(s0)
            padc = '-';
  80035e:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  800362:	846a                	mv	s0,s10
  800364:	b5ad                	j	8001ce <vprintfmt+0x78>
            putch(ch, putdat);
  800366:	85a6                	mv	a1,s1
  800368:	02500513          	li	a0,37
  80036c:	9902                	jalr	s2
            break;
  80036e:	b50d                	j	800190 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  800370:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  800374:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800378:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  80037a:	846a                	mv	s0,s10
            if (width < 0)
  80037c:	e40dd9e3          	bgez	s11,8001ce <vprintfmt+0x78>
                width = precision, precision = -1;
  800380:	8de6                	mv	s11,s9
  800382:	5cfd                	li	s9,-1
  800384:	b5a9                	j	8001ce <vprintfmt+0x78>
            goto reswitch;
  800386:	00144603          	lbu	a2,1(s0)
            padc = '0';
  80038a:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  80038e:	846a                	mv	s0,s10
            goto reswitch;
  800390:	bd3d                	j	8001ce <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800392:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800396:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80039a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80039c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8003a0:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003a4:	fcd56ce3          	bltu	a0,a3,80037c <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  8003a8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8003aa:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8003ae:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  8003b2:	0196873b          	addw	a4,a3,s9
  8003b6:	0017171b          	slliw	a4,a4,0x1
  8003ba:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8003be:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8003c2:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8003c6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003ca:	fcd57fe3          	bleu	a3,a0,8003a8 <vprintfmt+0x252>
  8003ce:	b77d                	j	80037c <vprintfmt+0x226>
            if (width < 0)
  8003d0:	fffdc693          	not	a3,s11
  8003d4:	96fd                	srai	a3,a3,0x3f
  8003d6:	00ddfdb3          	and	s11,s11,a3
  8003da:	00144603          	lbu	a2,1(s0)
  8003de:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  8003e0:	846a                	mv	s0,s10
  8003e2:	b3f5                	j	8001ce <vprintfmt+0x78>
            putch('%', putdat);
  8003e4:	85a6                	mv	a1,s1
  8003e6:	02500513          	li	a0,37
  8003ea:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8003ec:	fff44703          	lbu	a4,-1(s0)
  8003f0:	02500793          	li	a5,37
  8003f4:	8d22                	mv	s10,s0
  8003f6:	d8f70de3          	beq	a4,a5,800190 <vprintfmt+0x3a>
  8003fa:	02500713          	li	a4,37
  8003fe:	1d7d                	addi	s10,s10,-1
  800400:	fffd4783          	lbu	a5,-1(s10)
  800404:	fee79de3          	bne	a5,a4,8003fe <vprintfmt+0x2a8>
  800408:	b361                	j	800190 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80040a:	00000617          	auipc	a2,0x0
  80040e:	44e60613          	addi	a2,a2,1102 # 800858 <error_string+0x1a8>
  800412:	85a6                	mv	a1,s1
  800414:	854a                	mv	a0,s2
  800416:	0ac000ef          	jal	ra,8004c2 <printfmt>
  80041a:	bb9d                	j	800190 <vprintfmt+0x3a>
                p = "(null)";
  80041c:	00000617          	auipc	a2,0x0
  800420:	43460613          	addi	a2,a2,1076 # 800850 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800424:	00000417          	auipc	s0,0x0
  800428:	42d40413          	addi	s0,s0,1069 # 800851 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80042c:	8532                	mv	a0,a2
  80042e:	85e6                	mv	a1,s9
  800430:	e032                	sd	a2,0(sp)
  800432:	e43e                	sd	a5,8(sp)
  800434:	0ae000ef          	jal	ra,8004e2 <strnlen>
  800438:	40ad8dbb          	subw	s11,s11,a0
  80043c:	6602                	ld	a2,0(sp)
  80043e:	01b05d63          	blez	s11,800458 <vprintfmt+0x302>
  800442:	67a2                	ld	a5,8(sp)
  800444:	2781                	sext.w	a5,a5
  800446:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  800448:	6522                	ld	a0,8(sp)
  80044a:	85a6                	mv	a1,s1
  80044c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  80044e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800450:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800452:	6602                	ld	a2,0(sp)
  800454:	fe0d9ae3          	bnez	s11,800448 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800458:	00064783          	lbu	a5,0(a2)
  80045c:	0007851b          	sext.w	a0,a5
  800460:	e8051be3          	bnez	a0,8002f6 <vprintfmt+0x1a0>
  800464:	b335                	j	800190 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  800466:	000aa403          	lw	s0,0(s5)
  80046a:	bbf1                	j	800246 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  80046c:	000ae603          	lwu	a2,0(s5)
  800470:	46a9                	li	a3,10
  800472:	8aae                	mv	s5,a1
  800474:	bd89                	j	8002c6 <vprintfmt+0x170>
  800476:	000ae603          	lwu	a2,0(s5)
  80047a:	46c1                	li	a3,16
  80047c:	8aae                	mv	s5,a1
  80047e:	b5a1                	j	8002c6 <vprintfmt+0x170>
  800480:	000ae603          	lwu	a2,0(s5)
  800484:	46a1                	li	a3,8
  800486:	8aae                	mv	s5,a1
  800488:	bd3d                	j	8002c6 <vprintfmt+0x170>
                    putch(ch, putdat);
  80048a:	9902                	jalr	s2
  80048c:	b559                	j	800312 <vprintfmt+0x1bc>
                putch('-', putdat);
  80048e:	85a6                	mv	a1,s1
  800490:	02d00513          	li	a0,45
  800494:	e03e                	sd	a5,0(sp)
  800496:	9902                	jalr	s2
                num = -(long long)num;
  800498:	8ace                	mv	s5,s3
  80049a:	40800633          	neg	a2,s0
  80049e:	46a9                	li	a3,10
  8004a0:	6782                	ld	a5,0(sp)
  8004a2:	b515                	j	8002c6 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  8004a4:	01b05663          	blez	s11,8004b0 <vprintfmt+0x35a>
  8004a8:	02d00693          	li	a3,45
  8004ac:	f6d798e3          	bne	a5,a3,80041c <vprintfmt+0x2c6>
  8004b0:	00000417          	auipc	s0,0x0
  8004b4:	3a140413          	addi	s0,s0,929 # 800851 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004b8:	02800513          	li	a0,40
  8004bc:	02800793          	li	a5,40
  8004c0:	bd1d                	j	8002f6 <vprintfmt+0x1a0>

00000000008004c2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004c2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004c4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004c8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004ca:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004cc:	ec06                	sd	ra,24(sp)
  8004ce:	f83a                	sd	a4,48(sp)
  8004d0:	fc3e                	sd	a5,56(sp)
  8004d2:	e0c2                	sd	a6,64(sp)
  8004d4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004d6:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004d8:	c7fff0ef          	jal	ra,800156 <vprintfmt>
}
  8004dc:	60e2                	ld	ra,24(sp)
  8004de:	6161                	addi	sp,sp,80
  8004e0:	8082                	ret

00000000008004e2 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  8004e2:	c185                	beqz	a1,800502 <strnlen+0x20>
  8004e4:	00054783          	lbu	a5,0(a0)
  8004e8:	cf89                	beqz	a5,800502 <strnlen+0x20>
    size_t cnt = 0;
  8004ea:	4781                	li	a5,0
  8004ec:	a021                	j	8004f4 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  8004ee:	00074703          	lbu	a4,0(a4)
  8004f2:	c711                	beqz	a4,8004fe <strnlen+0x1c>
        cnt ++;
  8004f4:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004f6:	00f50733          	add	a4,a0,a5
  8004fa:	fef59ae3          	bne	a1,a5,8004ee <strnlen+0xc>
    }
    return cnt;
}
  8004fe:	853e                	mv	a0,a5
  800500:	8082                	ret
    size_t cnt = 0;
  800502:	4781                	li	a5,0
}
  800504:	853e                	mv	a0,a5
  800506:	8082                	ret

0000000000800508 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  800508:	1141                	addi	sp,sp,-16
    cprintf("Hello world!!.\n");
  80050a:	00000517          	auipc	a0,0x0
  80050e:	36650513          	addi	a0,a0,870 # 800870 <error_string+0x1c0>
main(void) {
  800512:	e406                	sd	ra,8(sp)
    cprintf("Hello world!!.\n");
  800514:	b2dff0ef          	jal	ra,800040 <cprintf>
    cprintf("I am process %d.\n", getpid());
  800518:	bc3ff0ef          	jal	ra,8000da <getpid>
  80051c:	85aa                	mv	a1,a0
  80051e:	00000517          	auipc	a0,0x0
  800522:	36250513          	addi	a0,a0,866 # 800880 <error_string+0x1d0>
  800526:	b1bff0ef          	jal	ra,800040 <cprintf>
    cprintf("hello pass.\n");
  80052a:	00000517          	auipc	a0,0x0
  80052e:	36e50513          	addi	a0,a0,878 # 800898 <error_string+0x1e8>
  800532:	b0fff0ef          	jal	ra,800040 <cprintf>
    return 0;
}
  800536:	60a2                	ld	ra,8(sp)
  800538:	4501                	li	a0,0
  80053a:	0141                	addi	sp,sp,16
  80053c:	8082                	ret
