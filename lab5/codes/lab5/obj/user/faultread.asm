
obj/__user_faultread.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0b4000ef          	jal	ra,8000d4 <umain>
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
  80002e:	088000ef          	jal	ra,8000b6 <sys_putc>
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
  800068:	0e4000ef          	jal	ra,80014c <vprintfmt>
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

00000000008000b6 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000b6:	85aa                	mv	a1,a0
  8000b8:	4579                	li	a0,30
  8000ba:	fbbff06f          	j	800074 <syscall>

00000000008000be <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000be:	1141                	addi	sp,sp,-16
  8000c0:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c2:	fedff0ef          	jal	ra,8000ae <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c6:	00000517          	auipc	a0,0x0
  8000ca:	44250513          	addi	a0,a0,1090 # 800508 <main+0xa>
  8000ce:	f73ff0ef          	jal	ra,800040 <cprintf>
    while (1);
  8000d2:	a001                	j	8000d2 <exit+0x14>

00000000008000d4 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000d4:	1141                	addi	sp,sp,-16
  8000d6:	e406                	sd	ra,8(sp)
    int ret = main();
  8000d8:	426000ef          	jal	ra,8004fe <main>
    exit(ret);
  8000dc:	fe3ff0ef          	jal	ra,8000be <exit>

00000000008000e0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000e0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000e4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000e6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000ea:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000ec:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8000f0:	f022                	sd	s0,32(sp)
  8000f2:	ec26                	sd	s1,24(sp)
  8000f4:	e84a                	sd	s2,16(sp)
  8000f6:	f406                	sd	ra,40(sp)
  8000f8:	e44e                	sd	s3,8(sp)
  8000fa:	84aa                	mv	s1,a0
  8000fc:	892e                	mv	s2,a1
  8000fe:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800102:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800104:	03067e63          	bleu	a6,a2,800140 <printnum+0x60>
  800108:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80010a:	00805763          	blez	s0,800118 <printnum+0x38>
  80010e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800110:	85ca                	mv	a1,s2
  800112:	854e                	mv	a0,s3
  800114:	9482                	jalr	s1
        while (-- width > 0)
  800116:	fc65                	bnez	s0,80010e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800118:	1a02                	slli	s4,s4,0x20
  80011a:	020a5a13          	srli	s4,s4,0x20
  80011e:	00000797          	auipc	a5,0x0
  800122:	62278793          	addi	a5,a5,1570 # 800740 <error_string+0xc8>
  800126:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800128:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80012a:	000a4503          	lbu	a0,0(s4)
}
  80012e:	70a2                	ld	ra,40(sp)
  800130:	69a2                	ld	s3,8(sp)
  800132:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800134:	85ca                	mv	a1,s2
  800136:	8326                	mv	t1,s1
}
  800138:	6942                	ld	s2,16(sp)
  80013a:	64e2                	ld	s1,24(sp)
  80013c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80013e:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  800140:	03065633          	divu	a2,a2,a6
  800144:	8722                	mv	a4,s0
  800146:	f9bff0ef          	jal	ra,8000e0 <printnum>
  80014a:	b7f9                	j	800118 <printnum+0x38>

000000000080014c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80014c:	7119                	addi	sp,sp,-128
  80014e:	f4a6                	sd	s1,104(sp)
  800150:	f0ca                	sd	s2,96(sp)
  800152:	e8d2                	sd	s4,80(sp)
  800154:	e4d6                	sd	s5,72(sp)
  800156:	e0da                	sd	s6,64(sp)
  800158:	fc5e                	sd	s7,56(sp)
  80015a:	f862                	sd	s8,48(sp)
  80015c:	f06a                	sd	s10,32(sp)
  80015e:	fc86                	sd	ra,120(sp)
  800160:	f8a2                	sd	s0,112(sp)
  800162:	ecce                	sd	s3,88(sp)
  800164:	f466                	sd	s9,40(sp)
  800166:	ec6e                	sd	s11,24(sp)
  800168:	892a                	mv	s2,a0
  80016a:	84ae                	mv	s1,a1
  80016c:	8d32                	mv	s10,a2
  80016e:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800170:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800172:	00000a17          	auipc	s4,0x0
  800176:	3aaa0a13          	addi	s4,s4,938 # 80051c <main+0x1e>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  80017a:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80017e:	00000c17          	auipc	s8,0x0
  800182:	4fac0c13          	addi	s8,s8,1274 # 800678 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800186:	000d4503          	lbu	a0,0(s10)
  80018a:	02500793          	li	a5,37
  80018e:	001d0413          	addi	s0,s10,1
  800192:	00f50e63          	beq	a0,a5,8001ae <vprintfmt+0x62>
            if (ch == '\0') {
  800196:	c521                	beqz	a0,8001de <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800198:	02500993          	li	s3,37
  80019c:	a011                	j	8001a0 <vprintfmt+0x54>
            if (ch == '\0') {
  80019e:	c121                	beqz	a0,8001de <vprintfmt+0x92>
            putch(ch, putdat);
  8001a0:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a2:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001a4:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a6:	fff44503          	lbu	a0,-1(s0)
  8001aa:	ff351ae3          	bne	a0,s3,80019e <vprintfmt+0x52>
  8001ae:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001b2:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001b6:	4981                	li	s3,0
  8001b8:	4801                	li	a6,0
        width = precision = -1;
  8001ba:	5cfd                	li	s9,-1
  8001bc:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001be:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  8001c2:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001c4:	fdd6069b          	addiw	a3,a2,-35
  8001c8:	0ff6f693          	andi	a3,a3,255
  8001cc:	00140d13          	addi	s10,s0,1
  8001d0:	20d5e563          	bltu	a1,a3,8003da <vprintfmt+0x28e>
  8001d4:	068a                	slli	a3,a3,0x2
  8001d6:	96d2                	add	a3,a3,s4
  8001d8:	4294                	lw	a3,0(a3)
  8001da:	96d2                	add	a3,a3,s4
  8001dc:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001de:	70e6                	ld	ra,120(sp)
  8001e0:	7446                	ld	s0,112(sp)
  8001e2:	74a6                	ld	s1,104(sp)
  8001e4:	7906                	ld	s2,96(sp)
  8001e6:	69e6                	ld	s3,88(sp)
  8001e8:	6a46                	ld	s4,80(sp)
  8001ea:	6aa6                	ld	s5,72(sp)
  8001ec:	6b06                	ld	s6,64(sp)
  8001ee:	7be2                	ld	s7,56(sp)
  8001f0:	7c42                	ld	s8,48(sp)
  8001f2:	7ca2                	ld	s9,40(sp)
  8001f4:	7d02                	ld	s10,32(sp)
  8001f6:	6de2                	ld	s11,24(sp)
  8001f8:	6109                	addi	sp,sp,128
  8001fa:	8082                	ret
    if (lflag >= 2) {
  8001fc:	4705                	li	a4,1
  8001fe:	008a8593          	addi	a1,s5,8
  800202:	01074463          	blt	a4,a6,80020a <vprintfmt+0xbe>
    else if (lflag) {
  800206:	26080363          	beqz	a6,80046c <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  80020a:	000ab603          	ld	a2,0(s5)
  80020e:	46c1                	li	a3,16
  800210:	8aae                	mv	s5,a1
  800212:	a06d                	j	8002bc <vprintfmt+0x170>
            goto reswitch;
  800214:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800218:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  80021a:	846a                	mv	s0,s10
            goto reswitch;
  80021c:	b765                	j	8001c4 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  80021e:	000aa503          	lw	a0,0(s5)
  800222:	85a6                	mv	a1,s1
  800224:	0aa1                	addi	s5,s5,8
  800226:	9902                	jalr	s2
            break;
  800228:	bfb9                	j	800186 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80022a:	4705                	li	a4,1
  80022c:	008a8993          	addi	s3,s5,8
  800230:	01074463          	blt	a4,a6,800238 <vprintfmt+0xec>
    else if (lflag) {
  800234:	22080463          	beqz	a6,80045c <vprintfmt+0x310>
        return va_arg(*ap, long);
  800238:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  80023c:	24044463          	bltz	s0,800484 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  800240:	8622                	mv	a2,s0
  800242:	8ace                	mv	s5,s3
  800244:	46a9                	li	a3,10
  800246:	a89d                	j	8002bc <vprintfmt+0x170>
            err = va_arg(ap, int);
  800248:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80024c:	4761                	li	a4,24
            err = va_arg(ap, int);
  80024e:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  800250:	41f7d69b          	sraiw	a3,a5,0x1f
  800254:	8fb5                	xor	a5,a5,a3
  800256:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80025a:	1ad74363          	blt	a4,a3,800400 <vprintfmt+0x2b4>
  80025e:	00369793          	slli	a5,a3,0x3
  800262:	97e2                	add	a5,a5,s8
  800264:	639c                	ld	a5,0(a5)
  800266:	18078d63          	beqz	a5,800400 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  80026a:	86be                	mv	a3,a5
  80026c:	00000617          	auipc	a2,0x0
  800270:	5c460613          	addi	a2,a2,1476 # 800830 <error_string+0x1b8>
  800274:	85a6                	mv	a1,s1
  800276:	854a                	mv	a0,s2
  800278:	240000ef          	jal	ra,8004b8 <printfmt>
  80027c:	b729                	j	800186 <vprintfmt+0x3a>
            lflag ++;
  80027e:	00144603          	lbu	a2,1(s0)
  800282:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800284:	846a                	mv	s0,s10
            goto reswitch;
  800286:	bf3d                	j	8001c4 <vprintfmt+0x78>
    if (lflag >= 2) {
  800288:	4705                	li	a4,1
  80028a:	008a8593          	addi	a1,s5,8
  80028e:	01074463          	blt	a4,a6,800296 <vprintfmt+0x14a>
    else if (lflag) {
  800292:	1e080263          	beqz	a6,800476 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  800296:	000ab603          	ld	a2,0(s5)
  80029a:	46a1                	li	a3,8
  80029c:	8aae                	mv	s5,a1
  80029e:	a839                	j	8002bc <vprintfmt+0x170>
            putch('0', putdat);
  8002a0:	03000513          	li	a0,48
  8002a4:	85a6                	mv	a1,s1
  8002a6:	e03e                	sd	a5,0(sp)
  8002a8:	9902                	jalr	s2
            putch('x', putdat);
  8002aa:	85a6                	mv	a1,s1
  8002ac:	07800513          	li	a0,120
  8002b0:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002b2:	0aa1                	addi	s5,s5,8
  8002b4:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  8002b8:	6782                	ld	a5,0(sp)
  8002ba:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  8002bc:	876e                	mv	a4,s11
  8002be:	85a6                	mv	a1,s1
  8002c0:	854a                	mv	a0,s2
  8002c2:	e1fff0ef          	jal	ra,8000e0 <printnum>
            break;
  8002c6:	b5c1                	j	800186 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  8002c8:	000ab603          	ld	a2,0(s5)
  8002cc:	0aa1                	addi	s5,s5,8
  8002ce:	1c060663          	beqz	a2,80049a <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  8002d2:	00160413          	addi	s0,a2,1
  8002d6:	17b05c63          	blez	s11,80044e <vprintfmt+0x302>
  8002da:	02d00593          	li	a1,45
  8002de:	14b79263          	bne	a5,a1,800422 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8002e2:	00064783          	lbu	a5,0(a2)
  8002e6:	0007851b          	sext.w	a0,a5
  8002ea:	c905                	beqz	a0,80031a <vprintfmt+0x1ce>
  8002ec:	000cc563          	bltz	s9,8002f6 <vprintfmt+0x1aa>
  8002f0:	3cfd                	addiw	s9,s9,-1
  8002f2:	036c8263          	beq	s9,s6,800316 <vprintfmt+0x1ca>
                    putch('?', putdat);
  8002f6:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8002f8:	18098463          	beqz	s3,800480 <vprintfmt+0x334>
  8002fc:	3781                	addiw	a5,a5,-32
  8002fe:	18fbf163          	bleu	a5,s7,800480 <vprintfmt+0x334>
                    putch('?', putdat);
  800302:	03f00513          	li	a0,63
  800306:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800308:	0405                	addi	s0,s0,1
  80030a:	fff44783          	lbu	a5,-1(s0)
  80030e:	3dfd                	addiw	s11,s11,-1
  800310:	0007851b          	sext.w	a0,a5
  800314:	fd61                	bnez	a0,8002ec <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  800316:	e7b058e3          	blez	s11,800186 <vprintfmt+0x3a>
  80031a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80031c:	85a6                	mv	a1,s1
  80031e:	02000513          	li	a0,32
  800322:	9902                	jalr	s2
            for (; width > 0; width --) {
  800324:	e60d81e3          	beqz	s11,800186 <vprintfmt+0x3a>
  800328:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80032a:	85a6                	mv	a1,s1
  80032c:	02000513          	li	a0,32
  800330:	9902                	jalr	s2
            for (; width > 0; width --) {
  800332:	fe0d94e3          	bnez	s11,80031a <vprintfmt+0x1ce>
  800336:	bd81                	j	800186 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800338:	4705                	li	a4,1
  80033a:	008a8593          	addi	a1,s5,8
  80033e:	01074463          	blt	a4,a6,800346 <vprintfmt+0x1fa>
    else if (lflag) {
  800342:	12080063          	beqz	a6,800462 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  800346:	000ab603          	ld	a2,0(s5)
  80034a:	46a9                	li	a3,10
  80034c:	8aae                	mv	s5,a1
  80034e:	b7bd                	j	8002bc <vprintfmt+0x170>
  800350:	00144603          	lbu	a2,1(s0)
            padc = '-';
  800354:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  800358:	846a                	mv	s0,s10
  80035a:	b5ad                	j	8001c4 <vprintfmt+0x78>
            putch(ch, putdat);
  80035c:	85a6                	mv	a1,s1
  80035e:	02500513          	li	a0,37
  800362:	9902                	jalr	s2
            break;
  800364:	b50d                	j	800186 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  800366:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  80036a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  80036e:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800370:	846a                	mv	s0,s10
            if (width < 0)
  800372:	e40dd9e3          	bgez	s11,8001c4 <vprintfmt+0x78>
                width = precision, precision = -1;
  800376:	8de6                	mv	s11,s9
  800378:	5cfd                	li	s9,-1
  80037a:	b5a9                	j	8001c4 <vprintfmt+0x78>
            goto reswitch;
  80037c:	00144603          	lbu	a2,1(s0)
            padc = '0';
  800380:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  800384:	846a                	mv	s0,s10
            goto reswitch;
  800386:	bd3d                	j	8001c4 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800388:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  80038c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800390:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800392:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800396:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80039a:	fcd56ce3          	bltu	a0,a3,800372 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  80039e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8003a0:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8003a4:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  8003a8:	0196873b          	addw	a4,a3,s9
  8003ac:	0017171b          	slliw	a4,a4,0x1
  8003b0:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8003b4:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8003b8:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8003bc:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003c0:	fcd57fe3          	bleu	a3,a0,80039e <vprintfmt+0x252>
  8003c4:	b77d                	j	800372 <vprintfmt+0x226>
            if (width < 0)
  8003c6:	fffdc693          	not	a3,s11
  8003ca:	96fd                	srai	a3,a3,0x3f
  8003cc:	00ddfdb3          	and	s11,s11,a3
  8003d0:	00144603          	lbu	a2,1(s0)
  8003d4:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  8003d6:	846a                	mv	s0,s10
  8003d8:	b3f5                	j	8001c4 <vprintfmt+0x78>
            putch('%', putdat);
  8003da:	85a6                	mv	a1,s1
  8003dc:	02500513          	li	a0,37
  8003e0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8003e2:	fff44703          	lbu	a4,-1(s0)
  8003e6:	02500793          	li	a5,37
  8003ea:	8d22                	mv	s10,s0
  8003ec:	d8f70de3          	beq	a4,a5,800186 <vprintfmt+0x3a>
  8003f0:	02500713          	li	a4,37
  8003f4:	1d7d                	addi	s10,s10,-1
  8003f6:	fffd4783          	lbu	a5,-1(s10)
  8003fa:	fee79de3          	bne	a5,a4,8003f4 <vprintfmt+0x2a8>
  8003fe:	b361                	j	800186 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800400:	00000617          	auipc	a2,0x0
  800404:	42060613          	addi	a2,a2,1056 # 800820 <error_string+0x1a8>
  800408:	85a6                	mv	a1,s1
  80040a:	854a                	mv	a0,s2
  80040c:	0ac000ef          	jal	ra,8004b8 <printfmt>
  800410:	bb9d                	j	800186 <vprintfmt+0x3a>
                p = "(null)";
  800412:	00000617          	auipc	a2,0x0
  800416:	40660613          	addi	a2,a2,1030 # 800818 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  80041a:	00000417          	auipc	s0,0x0
  80041e:	3ff40413          	addi	s0,s0,1023 # 800819 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800422:	8532                	mv	a0,a2
  800424:	85e6                	mv	a1,s9
  800426:	e032                	sd	a2,0(sp)
  800428:	e43e                	sd	a5,8(sp)
  80042a:	0ae000ef          	jal	ra,8004d8 <strnlen>
  80042e:	40ad8dbb          	subw	s11,s11,a0
  800432:	6602                	ld	a2,0(sp)
  800434:	01b05d63          	blez	s11,80044e <vprintfmt+0x302>
  800438:	67a2                	ld	a5,8(sp)
  80043a:	2781                	sext.w	a5,a5
  80043c:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  80043e:	6522                	ld	a0,8(sp)
  800440:	85a6                	mv	a1,s1
  800442:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  800444:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800446:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800448:	6602                	ld	a2,0(sp)
  80044a:	fe0d9ae3          	bnez	s11,80043e <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80044e:	00064783          	lbu	a5,0(a2)
  800452:	0007851b          	sext.w	a0,a5
  800456:	e8051be3          	bnez	a0,8002ec <vprintfmt+0x1a0>
  80045a:	b335                	j	800186 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  80045c:	000aa403          	lw	s0,0(s5)
  800460:	bbf1                	j	80023c <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  800462:	000ae603          	lwu	a2,0(s5)
  800466:	46a9                	li	a3,10
  800468:	8aae                	mv	s5,a1
  80046a:	bd89                	j	8002bc <vprintfmt+0x170>
  80046c:	000ae603          	lwu	a2,0(s5)
  800470:	46c1                	li	a3,16
  800472:	8aae                	mv	s5,a1
  800474:	b5a1                	j	8002bc <vprintfmt+0x170>
  800476:	000ae603          	lwu	a2,0(s5)
  80047a:	46a1                	li	a3,8
  80047c:	8aae                	mv	s5,a1
  80047e:	bd3d                	j	8002bc <vprintfmt+0x170>
                    putch(ch, putdat);
  800480:	9902                	jalr	s2
  800482:	b559                	j	800308 <vprintfmt+0x1bc>
                putch('-', putdat);
  800484:	85a6                	mv	a1,s1
  800486:	02d00513          	li	a0,45
  80048a:	e03e                	sd	a5,0(sp)
  80048c:	9902                	jalr	s2
                num = -(long long)num;
  80048e:	8ace                	mv	s5,s3
  800490:	40800633          	neg	a2,s0
  800494:	46a9                	li	a3,10
  800496:	6782                	ld	a5,0(sp)
  800498:	b515                	j	8002bc <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  80049a:	01b05663          	blez	s11,8004a6 <vprintfmt+0x35a>
  80049e:	02d00693          	li	a3,45
  8004a2:	f6d798e3          	bne	a5,a3,800412 <vprintfmt+0x2c6>
  8004a6:	00000417          	auipc	s0,0x0
  8004aa:	37340413          	addi	s0,s0,883 # 800819 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ae:	02800513          	li	a0,40
  8004b2:	02800793          	li	a5,40
  8004b6:	bd1d                	j	8002ec <vprintfmt+0x1a0>

00000000008004b8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004ba:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004be:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004c0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004c2:	ec06                	sd	ra,24(sp)
  8004c4:	f83a                	sd	a4,48(sp)
  8004c6:	fc3e                	sd	a5,56(sp)
  8004c8:	e0c2                	sd	a6,64(sp)
  8004ca:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004cc:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004ce:	c7fff0ef          	jal	ra,80014c <vprintfmt>
}
  8004d2:	60e2                	ld	ra,24(sp)
  8004d4:	6161                	addi	sp,sp,80
  8004d6:	8082                	ret

00000000008004d8 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  8004d8:	c185                	beqz	a1,8004f8 <strnlen+0x20>
  8004da:	00054783          	lbu	a5,0(a0)
  8004de:	cf89                	beqz	a5,8004f8 <strnlen+0x20>
    size_t cnt = 0;
  8004e0:	4781                	li	a5,0
  8004e2:	a021                	j	8004ea <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  8004e4:	00074703          	lbu	a4,0(a4)
  8004e8:	c711                	beqz	a4,8004f4 <strnlen+0x1c>
        cnt ++;
  8004ea:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004ec:	00f50733          	add	a4,a0,a5
  8004f0:	fef59ae3          	bne	a1,a5,8004e4 <strnlen+0xc>
    }
    return cnt;
}
  8004f4:	853e                	mv	a0,a5
  8004f6:	8082                	ret
    size_t cnt = 0;
  8004f8:	4781                	li	a5,0
}
  8004fa:	853e                	mv	a0,a5
  8004fc:	8082                	ret

00000000008004fe <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
    cprintf("I read %8x from 0.\n", *(unsigned int *)0);
  8004fe:	00002783          	lw	a5,0(zero) # 0 <_start-0x800020>
  800502:	9002                	ebreak
