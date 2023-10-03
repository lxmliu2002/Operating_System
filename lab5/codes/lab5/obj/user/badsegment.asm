
obj/__user_badsegment.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	114000ef          	jal	ra,800134 <umain>
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
  800038:	54450513          	addi	a0,a0,1348 # 800578 <main+0x1a>
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
  800054:	00000517          	auipc	a0,0x0
  800058:	54450513          	addi	a0,a0,1348 # 800598 <main+0x3a>
  80005c:	044000ef          	jal	ra,8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800060:	5559                	li	a0,-10
  800062:	0bc000ef          	jal	ra,80011e <exit>

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
  80006e:	0a8000ef          	jal	ra,800116 <sys_putc>
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
  800094:	118000ef          	jal	ra,8001ac <vprintfmt>
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
  8000c8:	0e4000ef          	jal	ra,8001ac <vprintfmt>
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
  8000f4:	6522                	ld	a0,8(sp)
  8000f6:	75a2                	ld	a1,40(sp)
  8000f8:	7642                	ld	a2,48(sp)
  8000fa:	76e2                	ld	a3,56(sp)
  8000fc:	6706                	ld	a4,64(sp)
  8000fe:	67a6                	ld	a5,72(sp)
  800100:	00000073          	ecall
  800104:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  800108:	4572                	lw	a0,28(sp)
  80010a:	6149                	addi	sp,sp,144
  80010c:	8082                	ret

000000000080010e <sys_exit>:

int
sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
  80010e:	85aa                	mv	a1,a0
  800110:	4505                	li	a0,1
  800112:	fc3ff06f          	j	8000d4 <syscall>

0000000000800116 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  800116:	85aa                	mv	a1,a0
  800118:	4579                	li	a0,30
  80011a:	fbbff06f          	j	8000d4 <syscall>

000000000080011e <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80011e:	1141                	addi	sp,sp,-16
  800120:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800122:	fedff0ef          	jal	ra,80010e <sys_exit>
    cprintf("BUG: exit failed.\n");
  800126:	00000517          	auipc	a0,0x0
  80012a:	47a50513          	addi	a0,a0,1146 # 8005a0 <main+0x42>
  80012e:	f73ff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  800132:	a001                	j	800132 <exit+0x14>

0000000000800134 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800134:	1141                	addi	sp,sp,-16
  800136:	e406                	sd	ra,8(sp)
    int ret = main();
  800138:	426000ef          	jal	ra,80055e <main>
    exit(ret);
  80013c:	fe3ff0ef          	jal	ra,80011e <exit>

0000000000800140 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800140:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800144:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800146:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80014a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80014c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800150:	f022                	sd	s0,32(sp)
  800152:	ec26                	sd	s1,24(sp)
  800154:	e84a                	sd	s2,16(sp)
  800156:	f406                	sd	ra,40(sp)
  800158:	e44e                	sd	s3,8(sp)
  80015a:	84aa                	mv	s1,a0
  80015c:	892e                	mv	s2,a1
  80015e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800162:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800164:	03067e63          	bleu	a6,a2,8001a0 <printnum+0x60>
  800168:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80016a:	00805763          	blez	s0,800178 <printnum+0x38>
  80016e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800170:	85ca                	mv	a1,s2
  800172:	854e                	mv	a0,s3
  800174:	9482                	jalr	s1
        while (-- width > 0)
  800176:	fc65                	bnez	s0,80016e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800178:	1a02                	slli	s4,s4,0x20
  80017a:	020a5a13          	srli	s4,s4,0x20
  80017e:	00000797          	auipc	a5,0x0
  800182:	65a78793          	addi	a5,a5,1626 # 8007d8 <error_string+0xc8>
  800186:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800188:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80018a:	000a4503          	lbu	a0,0(s4)
}
  80018e:	70a2                	ld	ra,40(sp)
  800190:	69a2                	ld	s3,8(sp)
  800192:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800194:	85ca                	mv	a1,s2
  800196:	8326                	mv	t1,s1
}
  800198:	6942                	ld	s2,16(sp)
  80019a:	64e2                	ld	s1,24(sp)
  80019c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80019e:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001a0:	03065633          	divu	a2,a2,a6
  8001a4:	8722                	mv	a4,s0
  8001a6:	f9bff0ef          	jal	ra,800140 <printnum>
  8001aa:	b7f9                	j	800178 <printnum+0x38>

00000000008001ac <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001ac:	7119                	addi	sp,sp,-128
  8001ae:	f4a6                	sd	s1,104(sp)
  8001b0:	f0ca                	sd	s2,96(sp)
  8001b2:	e8d2                	sd	s4,80(sp)
  8001b4:	e4d6                	sd	s5,72(sp)
  8001b6:	e0da                	sd	s6,64(sp)
  8001b8:	fc5e                	sd	s7,56(sp)
  8001ba:	f862                	sd	s8,48(sp)
  8001bc:	f06a                	sd	s10,32(sp)
  8001be:	fc86                	sd	ra,120(sp)
  8001c0:	f8a2                	sd	s0,112(sp)
  8001c2:	ecce                	sd	s3,88(sp)
  8001c4:	f466                	sd	s9,40(sp)
  8001c6:	ec6e                	sd	s11,24(sp)
  8001c8:	892a                	mv	s2,a0
  8001ca:	84ae                	mv	s1,a1
  8001cc:	8d32                	mv	s10,a2
  8001ce:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001d0:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001d2:	00000a17          	auipc	s4,0x0
  8001d6:	3e2a0a13          	addi	s4,s4,994 # 8005b4 <main+0x56>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  8001da:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001de:	00000c17          	auipc	s8,0x0
  8001e2:	532c0c13          	addi	s8,s8,1330 # 800710 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001e6:	000d4503          	lbu	a0,0(s10)
  8001ea:	02500793          	li	a5,37
  8001ee:	001d0413          	addi	s0,s10,1
  8001f2:	00f50e63          	beq	a0,a5,80020e <vprintfmt+0x62>
            if (ch == '\0') {
  8001f6:	c521                	beqz	a0,80023e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f8:	02500993          	li	s3,37
  8001fc:	a011                	j	800200 <vprintfmt+0x54>
            if (ch == '\0') {
  8001fe:	c121                	beqz	a0,80023e <vprintfmt+0x92>
            putch(ch, putdat);
  800200:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800202:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800204:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800206:	fff44503          	lbu	a0,-1(s0)
  80020a:	ff351ae3          	bne	a0,s3,8001fe <vprintfmt+0x52>
  80020e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800212:	02000793          	li	a5,32
        lflag = altflag = 0;
  800216:	4981                	li	s3,0
  800218:	4801                	li	a6,0
        width = precision = -1;
  80021a:	5cfd                	li	s9,-1
  80021c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  80021e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800222:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800224:	fdd6069b          	addiw	a3,a2,-35
  800228:	0ff6f693          	andi	a3,a3,255
  80022c:	00140d13          	addi	s10,s0,1
  800230:	20d5e563          	bltu	a1,a3,80043a <vprintfmt+0x28e>
  800234:	068a                	slli	a3,a3,0x2
  800236:	96d2                	add	a3,a3,s4
  800238:	4294                	lw	a3,0(a3)
  80023a:	96d2                	add	a3,a3,s4
  80023c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80023e:	70e6                	ld	ra,120(sp)
  800240:	7446                	ld	s0,112(sp)
  800242:	74a6                	ld	s1,104(sp)
  800244:	7906                	ld	s2,96(sp)
  800246:	69e6                	ld	s3,88(sp)
  800248:	6a46                	ld	s4,80(sp)
  80024a:	6aa6                	ld	s5,72(sp)
  80024c:	6b06                	ld	s6,64(sp)
  80024e:	7be2                	ld	s7,56(sp)
  800250:	7c42                	ld	s8,48(sp)
  800252:	7ca2                	ld	s9,40(sp)
  800254:	7d02                	ld	s10,32(sp)
  800256:	6de2                	ld	s11,24(sp)
  800258:	6109                	addi	sp,sp,128
  80025a:	8082                	ret
    if (lflag >= 2) {
  80025c:	4705                	li	a4,1
  80025e:	008a8593          	addi	a1,s5,8
  800262:	01074463          	blt	a4,a6,80026a <vprintfmt+0xbe>
    else if (lflag) {
  800266:	26080363          	beqz	a6,8004cc <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  80026a:	000ab603          	ld	a2,0(s5)
  80026e:	46c1                	li	a3,16
  800270:	8aae                	mv	s5,a1
  800272:	a06d                	j	80031c <vprintfmt+0x170>
            goto reswitch;
  800274:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800278:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  80027a:	846a                	mv	s0,s10
            goto reswitch;
  80027c:	b765                	j	800224 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  80027e:	000aa503          	lw	a0,0(s5)
  800282:	85a6                	mv	a1,s1
  800284:	0aa1                	addi	s5,s5,8
  800286:	9902                	jalr	s2
            break;
  800288:	bfb9                	j	8001e6 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80028a:	4705                	li	a4,1
  80028c:	008a8993          	addi	s3,s5,8
  800290:	01074463          	blt	a4,a6,800298 <vprintfmt+0xec>
    else if (lflag) {
  800294:	22080463          	beqz	a6,8004bc <vprintfmt+0x310>
        return va_arg(*ap, long);
  800298:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  80029c:	24044463          	bltz	s0,8004e4 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002a0:	8622                	mv	a2,s0
  8002a2:	8ace                	mv	s5,s3
  8002a4:	46a9                	li	a3,10
  8002a6:	a89d                	j	80031c <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002a8:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002ac:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002ae:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002b0:	41f7d69b          	sraiw	a3,a5,0x1f
  8002b4:	8fb5                	xor	a5,a5,a3
  8002b6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002ba:	1ad74363          	blt	a4,a3,800460 <vprintfmt+0x2b4>
  8002be:	00369793          	slli	a5,a3,0x3
  8002c2:	97e2                	add	a5,a5,s8
  8002c4:	639c                	ld	a5,0(a5)
  8002c6:	18078d63          	beqz	a5,800460 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  8002ca:	86be                	mv	a3,a5
  8002cc:	00000617          	auipc	a2,0x0
  8002d0:	5fc60613          	addi	a2,a2,1532 # 8008c8 <error_string+0x1b8>
  8002d4:	85a6                	mv	a1,s1
  8002d6:	854a                	mv	a0,s2
  8002d8:	240000ef          	jal	ra,800518 <printfmt>
  8002dc:	b729                	j	8001e6 <vprintfmt+0x3a>
            lflag ++;
  8002de:	00144603          	lbu	a2,1(s0)
  8002e2:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002e4:	846a                	mv	s0,s10
            goto reswitch;
  8002e6:	bf3d                	j	800224 <vprintfmt+0x78>
    if (lflag >= 2) {
  8002e8:	4705                	li	a4,1
  8002ea:	008a8593          	addi	a1,s5,8
  8002ee:	01074463          	blt	a4,a6,8002f6 <vprintfmt+0x14a>
    else if (lflag) {
  8002f2:	1e080263          	beqz	a6,8004d6 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  8002f6:	000ab603          	ld	a2,0(s5)
  8002fa:	46a1                	li	a3,8
  8002fc:	8aae                	mv	s5,a1
  8002fe:	a839                	j	80031c <vprintfmt+0x170>
            putch('0', putdat);
  800300:	03000513          	li	a0,48
  800304:	85a6                	mv	a1,s1
  800306:	e03e                	sd	a5,0(sp)
  800308:	9902                	jalr	s2
            putch('x', putdat);
  80030a:	85a6                	mv	a1,s1
  80030c:	07800513          	li	a0,120
  800310:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800312:	0aa1                	addi	s5,s5,8
  800314:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800318:	6782                	ld	a5,0(sp)
  80031a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  80031c:	876e                	mv	a4,s11
  80031e:	85a6                	mv	a1,s1
  800320:	854a                	mv	a0,s2
  800322:	e1fff0ef          	jal	ra,800140 <printnum>
            break;
  800326:	b5c1                	j	8001e6 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800328:	000ab603          	ld	a2,0(s5)
  80032c:	0aa1                	addi	s5,s5,8
  80032e:	1c060663          	beqz	a2,8004fa <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  800332:	00160413          	addi	s0,a2,1
  800336:	17b05c63          	blez	s11,8004ae <vprintfmt+0x302>
  80033a:	02d00593          	li	a1,45
  80033e:	14b79263          	bne	a5,a1,800482 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800342:	00064783          	lbu	a5,0(a2)
  800346:	0007851b          	sext.w	a0,a5
  80034a:	c905                	beqz	a0,80037a <vprintfmt+0x1ce>
  80034c:	000cc563          	bltz	s9,800356 <vprintfmt+0x1aa>
  800350:	3cfd                	addiw	s9,s9,-1
  800352:	036c8263          	beq	s9,s6,800376 <vprintfmt+0x1ca>
                    putch('?', putdat);
  800356:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800358:	18098463          	beqz	s3,8004e0 <vprintfmt+0x334>
  80035c:	3781                	addiw	a5,a5,-32
  80035e:	18fbf163          	bleu	a5,s7,8004e0 <vprintfmt+0x334>
                    putch('?', putdat);
  800362:	03f00513          	li	a0,63
  800366:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800368:	0405                	addi	s0,s0,1
  80036a:	fff44783          	lbu	a5,-1(s0)
  80036e:	3dfd                	addiw	s11,s11,-1
  800370:	0007851b          	sext.w	a0,a5
  800374:	fd61                	bnez	a0,80034c <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  800376:	e7b058e3          	blez	s11,8001e6 <vprintfmt+0x3a>
  80037a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80037c:	85a6                	mv	a1,s1
  80037e:	02000513          	li	a0,32
  800382:	9902                	jalr	s2
            for (; width > 0; width --) {
  800384:	e60d81e3          	beqz	s11,8001e6 <vprintfmt+0x3a>
  800388:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80038a:	85a6                	mv	a1,s1
  80038c:	02000513          	li	a0,32
  800390:	9902                	jalr	s2
            for (; width > 0; width --) {
  800392:	fe0d94e3          	bnez	s11,80037a <vprintfmt+0x1ce>
  800396:	bd81                	j	8001e6 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800398:	4705                	li	a4,1
  80039a:	008a8593          	addi	a1,s5,8
  80039e:	01074463          	blt	a4,a6,8003a6 <vprintfmt+0x1fa>
    else if (lflag) {
  8003a2:	12080063          	beqz	a6,8004c2 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003a6:	000ab603          	ld	a2,0(s5)
  8003aa:	46a9                	li	a3,10
  8003ac:	8aae                	mv	s5,a1
  8003ae:	b7bd                	j	80031c <vprintfmt+0x170>
  8003b0:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003b4:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  8003b8:	846a                	mv	s0,s10
  8003ba:	b5ad                	j	800224 <vprintfmt+0x78>
            putch(ch, putdat);
  8003bc:	85a6                	mv	a1,s1
  8003be:	02500513          	li	a0,37
  8003c2:	9902                	jalr	s2
            break;
  8003c4:	b50d                	j	8001e6 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  8003c6:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8003ca:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8003ce:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8003d0:	846a                	mv	s0,s10
            if (width < 0)
  8003d2:	e40dd9e3          	bgez	s11,800224 <vprintfmt+0x78>
                width = precision, precision = -1;
  8003d6:	8de6                	mv	s11,s9
  8003d8:	5cfd                	li	s9,-1
  8003da:	b5a9                	j	800224 <vprintfmt+0x78>
            goto reswitch;
  8003dc:	00144603          	lbu	a2,1(s0)
            padc = '0';
  8003e0:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  8003e4:	846a                	mv	s0,s10
            goto reswitch;
  8003e6:	bd3d                	j	800224 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  8003e8:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8003ec:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8003f0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8003f2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8003f6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003fa:	fcd56ce3          	bltu	a0,a3,8003d2 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  8003fe:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800400:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800404:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800408:	0196873b          	addw	a4,a3,s9
  80040c:	0017171b          	slliw	a4,a4,0x1
  800410:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800414:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800418:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80041c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800420:	fcd57fe3          	bleu	a3,a0,8003fe <vprintfmt+0x252>
  800424:	b77d                	j	8003d2 <vprintfmt+0x226>
            if (width < 0)
  800426:	fffdc693          	not	a3,s11
  80042a:	96fd                	srai	a3,a3,0x3f
  80042c:	00ddfdb3          	and	s11,s11,a3
  800430:	00144603          	lbu	a2,1(s0)
  800434:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800436:	846a                	mv	s0,s10
  800438:	b3f5                	j	800224 <vprintfmt+0x78>
            putch('%', putdat);
  80043a:	85a6                	mv	a1,s1
  80043c:	02500513          	li	a0,37
  800440:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800442:	fff44703          	lbu	a4,-1(s0)
  800446:	02500793          	li	a5,37
  80044a:	8d22                	mv	s10,s0
  80044c:	d8f70de3          	beq	a4,a5,8001e6 <vprintfmt+0x3a>
  800450:	02500713          	li	a4,37
  800454:	1d7d                	addi	s10,s10,-1
  800456:	fffd4783          	lbu	a5,-1(s10)
  80045a:	fee79de3          	bne	a5,a4,800454 <vprintfmt+0x2a8>
  80045e:	b361                	j	8001e6 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800460:	00000617          	auipc	a2,0x0
  800464:	45860613          	addi	a2,a2,1112 # 8008b8 <error_string+0x1a8>
  800468:	85a6                	mv	a1,s1
  80046a:	854a                	mv	a0,s2
  80046c:	0ac000ef          	jal	ra,800518 <printfmt>
  800470:	bb9d                	j	8001e6 <vprintfmt+0x3a>
                p = "(null)";
  800472:	00000617          	auipc	a2,0x0
  800476:	43e60613          	addi	a2,a2,1086 # 8008b0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  80047a:	00000417          	auipc	s0,0x0
  80047e:	43740413          	addi	s0,s0,1079 # 8008b1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800482:	8532                	mv	a0,a2
  800484:	85e6                	mv	a1,s9
  800486:	e032                	sd	a2,0(sp)
  800488:	e43e                	sd	a5,8(sp)
  80048a:	0ae000ef          	jal	ra,800538 <strnlen>
  80048e:	40ad8dbb          	subw	s11,s11,a0
  800492:	6602                	ld	a2,0(sp)
  800494:	01b05d63          	blez	s11,8004ae <vprintfmt+0x302>
  800498:	67a2                	ld	a5,8(sp)
  80049a:	2781                	sext.w	a5,a5
  80049c:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  80049e:	6522                	ld	a0,8(sp)
  8004a0:	85a6                	mv	a1,s1
  8004a2:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a4:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004a6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a8:	6602                	ld	a2,0(sp)
  8004aa:	fe0d9ae3          	bnez	s11,80049e <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ae:	00064783          	lbu	a5,0(a2)
  8004b2:	0007851b          	sext.w	a0,a5
  8004b6:	e8051be3          	bnez	a0,80034c <vprintfmt+0x1a0>
  8004ba:	b335                	j	8001e6 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  8004bc:	000aa403          	lw	s0,0(s5)
  8004c0:	bbf1                	j	80029c <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  8004c2:	000ae603          	lwu	a2,0(s5)
  8004c6:	46a9                	li	a3,10
  8004c8:	8aae                	mv	s5,a1
  8004ca:	bd89                	j	80031c <vprintfmt+0x170>
  8004cc:	000ae603          	lwu	a2,0(s5)
  8004d0:	46c1                	li	a3,16
  8004d2:	8aae                	mv	s5,a1
  8004d4:	b5a1                	j	80031c <vprintfmt+0x170>
  8004d6:	000ae603          	lwu	a2,0(s5)
  8004da:	46a1                	li	a3,8
  8004dc:	8aae                	mv	s5,a1
  8004de:	bd3d                	j	80031c <vprintfmt+0x170>
                    putch(ch, putdat);
  8004e0:	9902                	jalr	s2
  8004e2:	b559                	j	800368 <vprintfmt+0x1bc>
                putch('-', putdat);
  8004e4:	85a6                	mv	a1,s1
  8004e6:	02d00513          	li	a0,45
  8004ea:	e03e                	sd	a5,0(sp)
  8004ec:	9902                	jalr	s2
                num = -(long long)num;
  8004ee:	8ace                	mv	s5,s3
  8004f0:	40800633          	neg	a2,s0
  8004f4:	46a9                	li	a3,10
  8004f6:	6782                	ld	a5,0(sp)
  8004f8:	b515                	j	80031c <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  8004fa:	01b05663          	blez	s11,800506 <vprintfmt+0x35a>
  8004fe:	02d00693          	li	a3,45
  800502:	f6d798e3          	bne	a5,a3,800472 <vprintfmt+0x2c6>
  800506:	00000417          	auipc	s0,0x0
  80050a:	3ab40413          	addi	s0,s0,939 # 8008b1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80050e:	02800513          	li	a0,40
  800512:	02800793          	li	a5,40
  800516:	bd1d                	j	80034c <vprintfmt+0x1a0>

0000000000800518 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800518:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80051a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80051e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800520:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800522:	ec06                	sd	ra,24(sp)
  800524:	f83a                	sd	a4,48(sp)
  800526:	fc3e                	sd	a5,56(sp)
  800528:	e0c2                	sd	a6,64(sp)
  80052a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80052c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80052e:	c7fff0ef          	jal	ra,8001ac <vprintfmt>
}
  800532:	60e2                	ld	ra,24(sp)
  800534:	6161                	addi	sp,sp,80
  800536:	8082                	ret

0000000000800538 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800538:	c185                	beqz	a1,800558 <strnlen+0x20>
  80053a:	00054783          	lbu	a5,0(a0)
  80053e:	cf89                	beqz	a5,800558 <strnlen+0x20>
    size_t cnt = 0;
  800540:	4781                	li	a5,0
  800542:	a021                	j	80054a <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800544:	00074703          	lbu	a4,0(a4)
  800548:	c711                	beqz	a4,800554 <strnlen+0x1c>
        cnt ++;
  80054a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80054c:	00f50733          	add	a4,a0,a5
  800550:	fef59ae3          	bne	a1,a5,800544 <strnlen+0xc>
    }
    return cnt;
}
  800554:	853e                	mv	a0,a5
  800556:	8082                	ret
    size_t cnt = 0;
  800558:	4781                	li	a5,0
}
  80055a:	853e                	mv	a0,a5
  80055c:	8082                	ret

000000000080055e <main>:
#include <ulib.h>

/* try to load the kernel's TSS selector into the DS register */

int
main(void) {
  80055e:	1141                	addi	sp,sp,-16
	// There is no such thing as TSS in RISC-V
    // asm volatile("movw $0x28,%ax; movw %ax,%ds");
    panic("FAIL: T.T\n");
  800560:	00000617          	auipc	a2,0x0
  800564:	37060613          	addi	a2,a2,880 # 8008d0 <error_string+0x1c0>
  800568:	45a9                	li	a1,10
  80056a:	00000517          	auipc	a0,0x0
  80056e:	37650513          	addi	a0,a0,886 # 8008e0 <error_string+0x1d0>
main(void) {
  800572:	e406                	sd	ra,8(sp)
    panic("FAIL: T.T\n");
  800574:	ab3ff0ef          	jal	ra,800026 <__panic>
