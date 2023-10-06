
obj/__user_faultread.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  800020:	0b2000ef          	jal	ra,8000d2 <umain>
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
  80002e:	086000ef          	jal	ra,8000b4 <sys_putc>
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
  800068:	0e2000ef          	jal	ra,80014a <vprintfmt>
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

00000000008000b4 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000b4:	85aa                	mv	a1,a0
  8000b6:	4579                	li	a0,30
  8000b8:	fbdff06f          	j	800074 <syscall>

00000000008000bc <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000bc:	1141                	addi	sp,sp,-16
  8000be:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c0:	fedff0ef          	jal	ra,8000ac <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c4:	00000517          	auipc	a0,0x0
  8000c8:	44450513          	addi	a0,a0,1092 # 800508 <main+0xc>
  8000cc:	f75ff0ef          	jal	ra,800040 <cprintf>
    while (1);
  8000d0:	a001                	j	8000d0 <exit+0x14>

00000000008000d2 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000d2:	1141                	addi	sp,sp,-16
  8000d4:	e406                	sd	ra,8(sp)
    int ret = main();
  8000d6:	426000ef          	jal	ra,8004fc <main>
    exit(ret);
  8000da:	fe3ff0ef          	jal	ra,8000bc <exit>

00000000008000de <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000de:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000e2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000e4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000e8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000ea:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8000ee:	f022                	sd	s0,32(sp)
  8000f0:	ec26                	sd	s1,24(sp)
  8000f2:	e84a                	sd	s2,16(sp)
  8000f4:	f406                	sd	ra,40(sp)
  8000f6:	e44e                	sd	s3,8(sp)
  8000f8:	84aa                	mv	s1,a0
  8000fa:	892e                	mv	s2,a1
  8000fc:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800100:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800102:	03067e63          	bleu	a6,a2,80013e <printnum+0x60>
  800106:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800108:	00805763          	blez	s0,800116 <printnum+0x38>
  80010c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80010e:	85ca                	mv	a1,s2
  800110:	854e                	mv	a0,s3
  800112:	9482                	jalr	s1
        while (-- width > 0)
  800114:	fc65                	bnez	s0,80010c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800116:	1a02                	slli	s4,s4,0x20
  800118:	020a5a13          	srli	s4,s4,0x20
  80011c:	00000797          	auipc	a5,0x0
  800120:	62478793          	addi	a5,a5,1572 # 800740 <error_string+0xc8>
  800124:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800126:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800128:	000a4503          	lbu	a0,0(s4)
}
  80012c:	70a2                	ld	ra,40(sp)
  80012e:	69a2                	ld	s3,8(sp)
  800130:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800132:	85ca                	mv	a1,s2
  800134:	8326                	mv	t1,s1
}
  800136:	6942                	ld	s2,16(sp)
  800138:	64e2                	ld	s1,24(sp)
  80013a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80013c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  80013e:	03065633          	divu	a2,a2,a6
  800142:	8722                	mv	a4,s0
  800144:	f9bff0ef          	jal	ra,8000de <printnum>
  800148:	b7f9                	j	800116 <printnum+0x38>

000000000080014a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80014a:	7119                	addi	sp,sp,-128
  80014c:	f4a6                	sd	s1,104(sp)
  80014e:	f0ca                	sd	s2,96(sp)
  800150:	e8d2                	sd	s4,80(sp)
  800152:	e4d6                	sd	s5,72(sp)
  800154:	e0da                	sd	s6,64(sp)
  800156:	fc5e                	sd	s7,56(sp)
  800158:	f862                	sd	s8,48(sp)
  80015a:	f06a                	sd	s10,32(sp)
  80015c:	fc86                	sd	ra,120(sp)
  80015e:	f8a2                	sd	s0,112(sp)
  800160:	ecce                	sd	s3,88(sp)
  800162:	f466                	sd	s9,40(sp)
  800164:	ec6e                	sd	s11,24(sp)
  800166:	892a                	mv	s2,a0
  800168:	84ae                	mv	s1,a1
  80016a:	8d32                	mv	s10,a2
  80016c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  80016e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800170:	00000a17          	auipc	s4,0x0
  800174:	3aca0a13          	addi	s4,s4,940 # 80051c <main+0x20>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800178:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80017c:	00000c17          	auipc	s8,0x0
  800180:	4fcc0c13          	addi	s8,s8,1276 # 800678 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800184:	000d4503          	lbu	a0,0(s10)
  800188:	02500793          	li	a5,37
  80018c:	001d0413          	addi	s0,s10,1
  800190:	00f50e63          	beq	a0,a5,8001ac <vprintfmt+0x62>
            if (ch == '\0') {
  800194:	c521                	beqz	a0,8001dc <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800196:	02500993          	li	s3,37
  80019a:	a011                	j	80019e <vprintfmt+0x54>
            if (ch == '\0') {
  80019c:	c121                	beqz	a0,8001dc <vprintfmt+0x92>
            putch(ch, putdat);
  80019e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001a2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a4:	fff44503          	lbu	a0,-1(s0)
  8001a8:	ff351ae3          	bne	a0,s3,80019c <vprintfmt+0x52>
  8001ac:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001b0:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001b4:	4981                	li	s3,0
  8001b6:	4801                	li	a6,0
        width = precision = -1;
  8001b8:	5cfd                	li	s9,-1
  8001ba:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001bc:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  8001c0:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001c2:	fdd6069b          	addiw	a3,a2,-35
  8001c6:	0ff6f693          	andi	a3,a3,255
  8001ca:	00140d13          	addi	s10,s0,1
  8001ce:	20d5e563          	bltu	a1,a3,8003d8 <vprintfmt+0x28e>
  8001d2:	068a                	slli	a3,a3,0x2
  8001d4:	96d2                	add	a3,a3,s4
  8001d6:	4294                	lw	a3,0(a3)
  8001d8:	96d2                	add	a3,a3,s4
  8001da:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001dc:	70e6                	ld	ra,120(sp)
  8001de:	7446                	ld	s0,112(sp)
  8001e0:	74a6                	ld	s1,104(sp)
  8001e2:	7906                	ld	s2,96(sp)
  8001e4:	69e6                	ld	s3,88(sp)
  8001e6:	6a46                	ld	s4,80(sp)
  8001e8:	6aa6                	ld	s5,72(sp)
  8001ea:	6b06                	ld	s6,64(sp)
  8001ec:	7be2                	ld	s7,56(sp)
  8001ee:	7c42                	ld	s8,48(sp)
  8001f0:	7ca2                	ld	s9,40(sp)
  8001f2:	7d02                	ld	s10,32(sp)
  8001f4:	6de2                	ld	s11,24(sp)
  8001f6:	6109                	addi	sp,sp,128
  8001f8:	8082                	ret
    if (lflag >= 2) {
  8001fa:	4705                	li	a4,1
  8001fc:	008a8593          	addi	a1,s5,8
  800200:	01074463          	blt	a4,a6,800208 <vprintfmt+0xbe>
    else if (lflag) {
  800204:	26080363          	beqz	a6,80046a <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  800208:	000ab603          	ld	a2,0(s5)
  80020c:	46c1                	li	a3,16
  80020e:	8aae                	mv	s5,a1
  800210:	a06d                	j	8002ba <vprintfmt+0x170>
            goto reswitch;
  800212:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800216:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800218:	846a                	mv	s0,s10
            goto reswitch;
  80021a:	b765                	j	8001c2 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  80021c:	000aa503          	lw	a0,0(s5)
  800220:	85a6                	mv	a1,s1
  800222:	0aa1                	addi	s5,s5,8
  800224:	9902                	jalr	s2
            break;
  800226:	bfb9                	j	800184 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800228:	4705                	li	a4,1
  80022a:	008a8993          	addi	s3,s5,8
  80022e:	01074463          	blt	a4,a6,800236 <vprintfmt+0xec>
    else if (lflag) {
  800232:	22080463          	beqz	a6,80045a <vprintfmt+0x310>
        return va_arg(*ap, long);
  800236:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  80023a:	24044463          	bltz	s0,800482 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  80023e:	8622                	mv	a2,s0
  800240:	8ace                	mv	s5,s3
  800242:	46a9                	li	a3,10
  800244:	a89d                	j	8002ba <vprintfmt+0x170>
            err = va_arg(ap, int);
  800246:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80024a:	4761                	li	a4,24
            err = va_arg(ap, int);
  80024c:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  80024e:	41f7d69b          	sraiw	a3,a5,0x1f
  800252:	8fb5                	xor	a5,a5,a3
  800254:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800258:	1ad74363          	blt	a4,a3,8003fe <vprintfmt+0x2b4>
  80025c:	00369793          	slli	a5,a3,0x3
  800260:	97e2                	add	a5,a5,s8
  800262:	639c                	ld	a5,0(a5)
  800264:	18078d63          	beqz	a5,8003fe <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  800268:	86be                	mv	a3,a5
  80026a:	00000617          	auipc	a2,0x0
  80026e:	5c660613          	addi	a2,a2,1478 # 800830 <error_string+0x1b8>
  800272:	85a6                	mv	a1,s1
  800274:	854a                	mv	a0,s2
  800276:	240000ef          	jal	ra,8004b6 <printfmt>
  80027a:	b729                	j	800184 <vprintfmt+0x3a>
            lflag ++;
  80027c:	00144603          	lbu	a2,1(s0)
  800280:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800282:	846a                	mv	s0,s10
            goto reswitch;
  800284:	bf3d                	j	8001c2 <vprintfmt+0x78>
    if (lflag >= 2) {
  800286:	4705                	li	a4,1
  800288:	008a8593          	addi	a1,s5,8
  80028c:	01074463          	blt	a4,a6,800294 <vprintfmt+0x14a>
    else if (lflag) {
  800290:	1e080263          	beqz	a6,800474 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  800294:	000ab603          	ld	a2,0(s5)
  800298:	46a1                	li	a3,8
  80029a:	8aae                	mv	s5,a1
  80029c:	a839                	j	8002ba <vprintfmt+0x170>
            putch('0', putdat);
  80029e:	03000513          	li	a0,48
  8002a2:	85a6                	mv	a1,s1
  8002a4:	e03e                	sd	a5,0(sp)
  8002a6:	9902                	jalr	s2
            putch('x', putdat);
  8002a8:	85a6                	mv	a1,s1
  8002aa:	07800513          	li	a0,120
  8002ae:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002b0:	0aa1                	addi	s5,s5,8
  8002b2:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  8002b6:	6782                	ld	a5,0(sp)
  8002b8:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  8002ba:	876e                	mv	a4,s11
  8002bc:	85a6                	mv	a1,s1
  8002be:	854a                	mv	a0,s2
  8002c0:	e1fff0ef          	jal	ra,8000de <printnum>
            break;
  8002c4:	b5c1                	j	800184 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  8002c6:	000ab603          	ld	a2,0(s5)
  8002ca:	0aa1                	addi	s5,s5,8
  8002cc:	1c060663          	beqz	a2,800498 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  8002d0:	00160413          	addi	s0,a2,1
  8002d4:	17b05c63          	blez	s11,80044c <vprintfmt+0x302>
  8002d8:	02d00593          	li	a1,45
  8002dc:	14b79263          	bne	a5,a1,800420 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8002e0:	00064783          	lbu	a5,0(a2)
  8002e4:	0007851b          	sext.w	a0,a5
  8002e8:	c905                	beqz	a0,800318 <vprintfmt+0x1ce>
  8002ea:	000cc563          	bltz	s9,8002f4 <vprintfmt+0x1aa>
  8002ee:	3cfd                	addiw	s9,s9,-1
  8002f0:	036c8263          	beq	s9,s6,800314 <vprintfmt+0x1ca>
                    putch('?', putdat);
  8002f4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8002f6:	18098463          	beqz	s3,80047e <vprintfmt+0x334>
  8002fa:	3781                	addiw	a5,a5,-32
  8002fc:	18fbf163          	bleu	a5,s7,80047e <vprintfmt+0x334>
                    putch('?', putdat);
  800300:	03f00513          	li	a0,63
  800304:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800306:	0405                	addi	s0,s0,1
  800308:	fff44783          	lbu	a5,-1(s0)
  80030c:	3dfd                	addiw	s11,s11,-1
  80030e:	0007851b          	sext.w	a0,a5
  800312:	fd61                	bnez	a0,8002ea <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  800314:	e7b058e3          	blez	s11,800184 <vprintfmt+0x3a>
  800318:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80031a:	85a6                	mv	a1,s1
  80031c:	02000513          	li	a0,32
  800320:	9902                	jalr	s2
            for (; width > 0; width --) {
  800322:	e60d81e3          	beqz	s11,800184 <vprintfmt+0x3a>
  800326:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800328:	85a6                	mv	a1,s1
  80032a:	02000513          	li	a0,32
  80032e:	9902                	jalr	s2
            for (; width > 0; width --) {
  800330:	fe0d94e3          	bnez	s11,800318 <vprintfmt+0x1ce>
  800334:	bd81                	j	800184 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800336:	4705                	li	a4,1
  800338:	008a8593          	addi	a1,s5,8
  80033c:	01074463          	blt	a4,a6,800344 <vprintfmt+0x1fa>
    else if (lflag) {
  800340:	12080063          	beqz	a6,800460 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  800344:	000ab603          	ld	a2,0(s5)
  800348:	46a9                	li	a3,10
  80034a:	8aae                	mv	s5,a1
  80034c:	b7bd                	j	8002ba <vprintfmt+0x170>
  80034e:	00144603          	lbu	a2,1(s0)
            padc = '-';
  800352:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  800356:	846a                	mv	s0,s10
  800358:	b5ad                	j	8001c2 <vprintfmt+0x78>
            putch(ch, putdat);
  80035a:	85a6                	mv	a1,s1
  80035c:	02500513          	li	a0,37
  800360:	9902                	jalr	s2
            break;
  800362:	b50d                	j	800184 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  800364:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  800368:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  80036c:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  80036e:	846a                	mv	s0,s10
            if (width < 0)
  800370:	e40dd9e3          	bgez	s11,8001c2 <vprintfmt+0x78>
                width = precision, precision = -1;
  800374:	8de6                	mv	s11,s9
  800376:	5cfd                	li	s9,-1
  800378:	b5a9                	j	8001c2 <vprintfmt+0x78>
            goto reswitch;
  80037a:	00144603          	lbu	a2,1(s0)
            padc = '0';
  80037e:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  800382:	846a                	mv	s0,s10
            goto reswitch;
  800384:	bd3d                	j	8001c2 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800386:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  80038a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80038e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800390:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800394:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800398:	fcd56ce3          	bltu	a0,a3,800370 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  80039c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80039e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8003a2:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  8003a6:	0196873b          	addw	a4,a3,s9
  8003aa:	0017171b          	slliw	a4,a4,0x1
  8003ae:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8003b2:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8003b6:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8003ba:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003be:	fcd57fe3          	bleu	a3,a0,80039c <vprintfmt+0x252>
  8003c2:	b77d                	j	800370 <vprintfmt+0x226>
            if (width < 0)
  8003c4:	fffdc693          	not	a3,s11
  8003c8:	96fd                	srai	a3,a3,0x3f
  8003ca:	00ddfdb3          	and	s11,s11,a3
  8003ce:	00144603          	lbu	a2,1(s0)
  8003d2:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  8003d4:	846a                	mv	s0,s10
  8003d6:	b3f5                	j	8001c2 <vprintfmt+0x78>
            putch('%', putdat);
  8003d8:	85a6                	mv	a1,s1
  8003da:	02500513          	li	a0,37
  8003de:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8003e0:	fff44703          	lbu	a4,-1(s0)
  8003e4:	02500793          	li	a5,37
  8003e8:	8d22                	mv	s10,s0
  8003ea:	d8f70de3          	beq	a4,a5,800184 <vprintfmt+0x3a>
  8003ee:	02500713          	li	a4,37
  8003f2:	1d7d                	addi	s10,s10,-1
  8003f4:	fffd4783          	lbu	a5,-1(s10)
  8003f8:	fee79de3          	bne	a5,a4,8003f2 <vprintfmt+0x2a8>
  8003fc:	b361                	j	800184 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  8003fe:	00000617          	auipc	a2,0x0
  800402:	42260613          	addi	a2,a2,1058 # 800820 <error_string+0x1a8>
  800406:	85a6                	mv	a1,s1
  800408:	854a                	mv	a0,s2
  80040a:	0ac000ef          	jal	ra,8004b6 <printfmt>
  80040e:	bb9d                	j	800184 <vprintfmt+0x3a>
                p = "(null)";
  800410:	00000617          	auipc	a2,0x0
  800414:	40860613          	addi	a2,a2,1032 # 800818 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800418:	00000417          	auipc	s0,0x0
  80041c:	40140413          	addi	s0,s0,1025 # 800819 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800420:	8532                	mv	a0,a2
  800422:	85e6                	mv	a1,s9
  800424:	e032                	sd	a2,0(sp)
  800426:	e43e                	sd	a5,8(sp)
  800428:	0ae000ef          	jal	ra,8004d6 <strnlen>
  80042c:	40ad8dbb          	subw	s11,s11,a0
  800430:	6602                	ld	a2,0(sp)
  800432:	01b05d63          	blez	s11,80044c <vprintfmt+0x302>
  800436:	67a2                	ld	a5,8(sp)
  800438:	2781                	sext.w	a5,a5
  80043a:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  80043c:	6522                	ld	a0,8(sp)
  80043e:	85a6                	mv	a1,s1
  800440:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  800442:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800444:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800446:	6602                	ld	a2,0(sp)
  800448:	fe0d9ae3          	bnez	s11,80043c <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80044c:	00064783          	lbu	a5,0(a2)
  800450:	0007851b          	sext.w	a0,a5
  800454:	e8051be3          	bnez	a0,8002ea <vprintfmt+0x1a0>
  800458:	b335                	j	800184 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  80045a:	000aa403          	lw	s0,0(s5)
  80045e:	bbf1                	j	80023a <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  800460:	000ae603          	lwu	a2,0(s5)
  800464:	46a9                	li	a3,10
  800466:	8aae                	mv	s5,a1
  800468:	bd89                	j	8002ba <vprintfmt+0x170>
  80046a:	000ae603          	lwu	a2,0(s5)
  80046e:	46c1                	li	a3,16
  800470:	8aae                	mv	s5,a1
  800472:	b5a1                	j	8002ba <vprintfmt+0x170>
  800474:	000ae603          	lwu	a2,0(s5)
  800478:	46a1                	li	a3,8
  80047a:	8aae                	mv	s5,a1
  80047c:	bd3d                	j	8002ba <vprintfmt+0x170>
                    putch(ch, putdat);
  80047e:	9902                	jalr	s2
  800480:	b559                	j	800306 <vprintfmt+0x1bc>
                putch('-', putdat);
  800482:	85a6                	mv	a1,s1
  800484:	02d00513          	li	a0,45
  800488:	e03e                	sd	a5,0(sp)
  80048a:	9902                	jalr	s2
                num = -(long long)num;
  80048c:	8ace                	mv	s5,s3
  80048e:	40800633          	neg	a2,s0
  800492:	46a9                	li	a3,10
  800494:	6782                	ld	a5,0(sp)
  800496:	b515                	j	8002ba <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  800498:	01b05663          	blez	s11,8004a4 <vprintfmt+0x35a>
  80049c:	02d00693          	li	a3,45
  8004a0:	f6d798e3          	bne	a5,a3,800410 <vprintfmt+0x2c6>
  8004a4:	00000417          	auipc	s0,0x0
  8004a8:	37540413          	addi	s0,s0,885 # 800819 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ac:	02800513          	li	a0,40
  8004b0:	02800793          	li	a5,40
  8004b4:	bd1d                	j	8002ea <vprintfmt+0x1a0>

00000000008004b6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004b8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004bc:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004be:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004c0:	ec06                	sd	ra,24(sp)
  8004c2:	f83a                	sd	a4,48(sp)
  8004c4:	fc3e                	sd	a5,56(sp)
  8004c6:	e0c2                	sd	a6,64(sp)
  8004c8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004ca:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004cc:	c7fff0ef          	jal	ra,80014a <vprintfmt>
}
  8004d0:	60e2                	ld	ra,24(sp)
  8004d2:	6161                	addi	sp,sp,80
  8004d4:	8082                	ret

00000000008004d6 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  8004d6:	c185                	beqz	a1,8004f6 <strnlen+0x20>
  8004d8:	00054783          	lbu	a5,0(a0)
  8004dc:	cf89                	beqz	a5,8004f6 <strnlen+0x20>
    size_t cnt = 0;
  8004de:	4781                	li	a5,0
  8004e0:	a021                	j	8004e8 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  8004e2:	00074703          	lbu	a4,0(a4)
  8004e6:	c711                	beqz	a4,8004f2 <strnlen+0x1c>
        cnt ++;
  8004e8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004ea:	00f50733          	add	a4,a0,a5
  8004ee:	fef59ae3          	bne	a1,a5,8004e2 <strnlen+0xc>
    }
    return cnt;
}
  8004f2:	853e                	mv	a0,a5
  8004f4:	8082                	ret
    size_t cnt = 0;
  8004f6:	4781                	li	a5,0
}
  8004f8:	853e                	mv	a0,a5
  8004fa:	8082                	ret

00000000008004fc <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
    cprintf("I read %8x from 0.\n", *(unsigned int *)0);
  8004fc:	00002783          	lw	a5,0(zero) # 0 <_start-0x800020>
  800500:	9002                	ebreak
