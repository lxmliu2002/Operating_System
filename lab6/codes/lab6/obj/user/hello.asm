
obj/__user_hello.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  800020:	0bc000ef          	jal	ra,8000dc <umain>
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
  80002e:	08c000ef          	jal	ra,8000ba <sys_putc>
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
  800068:	0ec000ef          	jal	ra,800154 <vprintfmt>
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

00000000008000b4 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000b4:	4549                	li	a0,18
  8000b6:	fbfff06f          	j	800074 <syscall>

00000000008000ba <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000ba:	85aa                	mv	a1,a0
  8000bc:	4579                	li	a0,30
  8000be:	fb7ff06f          	j	800074 <syscall>

00000000008000c2 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c2:	1141                	addi	sp,sp,-16
  8000c4:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c6:	fe7ff0ef          	jal	ra,8000ac <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000ca:	00000517          	auipc	a0,0x0
  8000ce:	47650513          	addi	a0,a0,1142 # 800540 <main+0x3a>
  8000d2:	f6fff0ef          	jal	ra,800040 <cprintf>
    while (1);
  8000d6:	a001                	j	8000d6 <exit+0x14>

00000000008000d8 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000d8:	fddff06f          	j	8000b4 <sys_getpid>

00000000008000dc <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000dc:	1141                	addi	sp,sp,-16
  8000de:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e0:	426000ef          	jal	ra,800506 <main>
    exit(ret);
  8000e4:	fdfff0ef          	jal	ra,8000c2 <exit>

00000000008000e8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000e8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000ec:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000ee:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000f2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000f4:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8000f8:	f022                	sd	s0,32(sp)
  8000fa:	ec26                	sd	s1,24(sp)
  8000fc:	e84a                	sd	s2,16(sp)
  8000fe:	f406                	sd	ra,40(sp)
  800100:	e44e                	sd	s3,8(sp)
  800102:	84aa                	mv	s1,a0
  800104:	892e                	mv	s2,a1
  800106:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80010a:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  80010c:	03067e63          	bleu	a6,a2,800148 <printnum+0x60>
  800110:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800112:	00805763          	blez	s0,800120 <printnum+0x38>
  800116:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800118:	85ca                	mv	a1,s2
  80011a:	854e                	mv	a0,s3
  80011c:	9482                	jalr	s1
        while (-- width > 0)
  80011e:	fc65                	bnez	s0,800116 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800120:	1a02                	slli	s4,s4,0x20
  800122:	020a5a13          	srli	s4,s4,0x20
  800126:	00000797          	auipc	a5,0x0
  80012a:	65278793          	addi	a5,a5,1618 # 800778 <error_string+0xc8>
  80012e:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800130:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800132:	000a4503          	lbu	a0,0(s4)
}
  800136:	70a2                	ld	ra,40(sp)
  800138:	69a2                	ld	s3,8(sp)
  80013a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80013c:	85ca                	mv	a1,s2
  80013e:	8326                	mv	t1,s1
}
  800140:	6942                	ld	s2,16(sp)
  800142:	64e2                	ld	s1,24(sp)
  800144:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800146:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  800148:	03065633          	divu	a2,a2,a6
  80014c:	8722                	mv	a4,s0
  80014e:	f9bff0ef          	jal	ra,8000e8 <printnum>
  800152:	b7f9                	j	800120 <printnum+0x38>

0000000000800154 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800154:	7119                	addi	sp,sp,-128
  800156:	f4a6                	sd	s1,104(sp)
  800158:	f0ca                	sd	s2,96(sp)
  80015a:	e8d2                	sd	s4,80(sp)
  80015c:	e4d6                	sd	s5,72(sp)
  80015e:	e0da                	sd	s6,64(sp)
  800160:	fc5e                	sd	s7,56(sp)
  800162:	f862                	sd	s8,48(sp)
  800164:	f06a                	sd	s10,32(sp)
  800166:	fc86                	sd	ra,120(sp)
  800168:	f8a2                	sd	s0,112(sp)
  80016a:	ecce                	sd	s3,88(sp)
  80016c:	f466                	sd	s9,40(sp)
  80016e:	ec6e                	sd	s11,24(sp)
  800170:	892a                	mv	s2,a0
  800172:	84ae                	mv	s1,a1
  800174:	8d32                	mv	s10,a2
  800176:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800178:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  80017a:	00000a17          	auipc	s4,0x0
  80017e:	3daa0a13          	addi	s4,s4,986 # 800554 <main+0x4e>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800182:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800186:	00000c17          	auipc	s8,0x0
  80018a:	52ac0c13          	addi	s8,s8,1322 # 8006b0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80018e:	000d4503          	lbu	a0,0(s10)
  800192:	02500793          	li	a5,37
  800196:	001d0413          	addi	s0,s10,1
  80019a:	00f50e63          	beq	a0,a5,8001b6 <vprintfmt+0x62>
            if (ch == '\0') {
  80019e:	c521                	beqz	a0,8001e6 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a0:	02500993          	li	s3,37
  8001a4:	a011                	j	8001a8 <vprintfmt+0x54>
            if (ch == '\0') {
  8001a6:	c121                	beqz	a0,8001e6 <vprintfmt+0x92>
            putch(ch, putdat);
  8001a8:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001aa:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001ac:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ae:	fff44503          	lbu	a0,-1(s0)
  8001b2:	ff351ae3          	bne	a0,s3,8001a6 <vprintfmt+0x52>
  8001b6:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001ba:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001be:	4981                	li	s3,0
  8001c0:	4801                	li	a6,0
        width = precision = -1;
  8001c2:	5cfd                	li	s9,-1
  8001c4:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001c6:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  8001ca:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001cc:	fdd6069b          	addiw	a3,a2,-35
  8001d0:	0ff6f693          	andi	a3,a3,255
  8001d4:	00140d13          	addi	s10,s0,1
  8001d8:	20d5e563          	bltu	a1,a3,8003e2 <vprintfmt+0x28e>
  8001dc:	068a                	slli	a3,a3,0x2
  8001de:	96d2                	add	a3,a3,s4
  8001e0:	4294                	lw	a3,0(a3)
  8001e2:	96d2                	add	a3,a3,s4
  8001e4:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001e6:	70e6                	ld	ra,120(sp)
  8001e8:	7446                	ld	s0,112(sp)
  8001ea:	74a6                	ld	s1,104(sp)
  8001ec:	7906                	ld	s2,96(sp)
  8001ee:	69e6                	ld	s3,88(sp)
  8001f0:	6a46                	ld	s4,80(sp)
  8001f2:	6aa6                	ld	s5,72(sp)
  8001f4:	6b06                	ld	s6,64(sp)
  8001f6:	7be2                	ld	s7,56(sp)
  8001f8:	7c42                	ld	s8,48(sp)
  8001fa:	7ca2                	ld	s9,40(sp)
  8001fc:	7d02                	ld	s10,32(sp)
  8001fe:	6de2                	ld	s11,24(sp)
  800200:	6109                	addi	sp,sp,128
  800202:	8082                	ret
    if (lflag >= 2) {
  800204:	4705                	li	a4,1
  800206:	008a8593          	addi	a1,s5,8
  80020a:	01074463          	blt	a4,a6,800212 <vprintfmt+0xbe>
    else if (lflag) {
  80020e:	26080363          	beqz	a6,800474 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  800212:	000ab603          	ld	a2,0(s5)
  800216:	46c1                	li	a3,16
  800218:	8aae                	mv	s5,a1
  80021a:	a06d                	j	8002c4 <vprintfmt+0x170>
            goto reswitch;
  80021c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800220:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800222:	846a                	mv	s0,s10
            goto reswitch;
  800224:	b765                	j	8001cc <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  800226:	000aa503          	lw	a0,0(s5)
  80022a:	85a6                	mv	a1,s1
  80022c:	0aa1                	addi	s5,s5,8
  80022e:	9902                	jalr	s2
            break;
  800230:	bfb9                	j	80018e <vprintfmt+0x3a>
    if (lflag >= 2) {
  800232:	4705                	li	a4,1
  800234:	008a8993          	addi	s3,s5,8
  800238:	01074463          	blt	a4,a6,800240 <vprintfmt+0xec>
    else if (lflag) {
  80023c:	22080463          	beqz	a6,800464 <vprintfmt+0x310>
        return va_arg(*ap, long);
  800240:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  800244:	24044463          	bltz	s0,80048c <vprintfmt+0x338>
            num = getint(&ap, lflag);
  800248:	8622                	mv	a2,s0
  80024a:	8ace                	mv	s5,s3
  80024c:	46a9                	li	a3,10
  80024e:	a89d                	j	8002c4 <vprintfmt+0x170>
            err = va_arg(ap, int);
  800250:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800254:	4761                	li	a4,24
            err = va_arg(ap, int);
  800256:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  800258:	41f7d69b          	sraiw	a3,a5,0x1f
  80025c:	8fb5                	xor	a5,a5,a3
  80025e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800262:	1ad74363          	blt	a4,a3,800408 <vprintfmt+0x2b4>
  800266:	00369793          	slli	a5,a3,0x3
  80026a:	97e2                	add	a5,a5,s8
  80026c:	639c                	ld	a5,0(a5)
  80026e:	18078d63          	beqz	a5,800408 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  800272:	86be                	mv	a3,a5
  800274:	00000617          	auipc	a2,0x0
  800278:	5f460613          	addi	a2,a2,1524 # 800868 <error_string+0x1b8>
  80027c:	85a6                	mv	a1,s1
  80027e:	854a                	mv	a0,s2
  800280:	240000ef          	jal	ra,8004c0 <printfmt>
  800284:	b729                	j	80018e <vprintfmt+0x3a>
            lflag ++;
  800286:	00144603          	lbu	a2,1(s0)
  80028a:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  80028c:	846a                	mv	s0,s10
            goto reswitch;
  80028e:	bf3d                	j	8001cc <vprintfmt+0x78>
    if (lflag >= 2) {
  800290:	4705                	li	a4,1
  800292:	008a8593          	addi	a1,s5,8
  800296:	01074463          	blt	a4,a6,80029e <vprintfmt+0x14a>
    else if (lflag) {
  80029a:	1e080263          	beqz	a6,80047e <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  80029e:	000ab603          	ld	a2,0(s5)
  8002a2:	46a1                	li	a3,8
  8002a4:	8aae                	mv	s5,a1
  8002a6:	a839                	j	8002c4 <vprintfmt+0x170>
            putch('0', putdat);
  8002a8:	03000513          	li	a0,48
  8002ac:	85a6                	mv	a1,s1
  8002ae:	e03e                	sd	a5,0(sp)
  8002b0:	9902                	jalr	s2
            putch('x', putdat);
  8002b2:	85a6                	mv	a1,s1
  8002b4:	07800513          	li	a0,120
  8002b8:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002ba:	0aa1                	addi	s5,s5,8
  8002bc:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  8002c0:	6782                	ld	a5,0(sp)
  8002c2:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  8002c4:	876e                	mv	a4,s11
  8002c6:	85a6                	mv	a1,s1
  8002c8:	854a                	mv	a0,s2
  8002ca:	e1fff0ef          	jal	ra,8000e8 <printnum>
            break;
  8002ce:	b5c1                	j	80018e <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  8002d0:	000ab603          	ld	a2,0(s5)
  8002d4:	0aa1                	addi	s5,s5,8
  8002d6:	1c060663          	beqz	a2,8004a2 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  8002da:	00160413          	addi	s0,a2,1
  8002de:	17b05c63          	blez	s11,800456 <vprintfmt+0x302>
  8002e2:	02d00593          	li	a1,45
  8002e6:	14b79263          	bne	a5,a1,80042a <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8002ea:	00064783          	lbu	a5,0(a2)
  8002ee:	0007851b          	sext.w	a0,a5
  8002f2:	c905                	beqz	a0,800322 <vprintfmt+0x1ce>
  8002f4:	000cc563          	bltz	s9,8002fe <vprintfmt+0x1aa>
  8002f8:	3cfd                	addiw	s9,s9,-1
  8002fa:	036c8263          	beq	s9,s6,80031e <vprintfmt+0x1ca>
                    putch('?', putdat);
  8002fe:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800300:	18098463          	beqz	s3,800488 <vprintfmt+0x334>
  800304:	3781                	addiw	a5,a5,-32
  800306:	18fbf163          	bleu	a5,s7,800488 <vprintfmt+0x334>
                    putch('?', putdat);
  80030a:	03f00513          	li	a0,63
  80030e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800310:	0405                	addi	s0,s0,1
  800312:	fff44783          	lbu	a5,-1(s0)
  800316:	3dfd                	addiw	s11,s11,-1
  800318:	0007851b          	sext.w	a0,a5
  80031c:	fd61                	bnez	a0,8002f4 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  80031e:	e7b058e3          	blez	s11,80018e <vprintfmt+0x3a>
  800322:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800324:	85a6                	mv	a1,s1
  800326:	02000513          	li	a0,32
  80032a:	9902                	jalr	s2
            for (; width > 0; width --) {
  80032c:	e60d81e3          	beqz	s11,80018e <vprintfmt+0x3a>
  800330:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800332:	85a6                	mv	a1,s1
  800334:	02000513          	li	a0,32
  800338:	9902                	jalr	s2
            for (; width > 0; width --) {
  80033a:	fe0d94e3          	bnez	s11,800322 <vprintfmt+0x1ce>
  80033e:	bd81                	j	80018e <vprintfmt+0x3a>
    if (lflag >= 2) {
  800340:	4705                	li	a4,1
  800342:	008a8593          	addi	a1,s5,8
  800346:	01074463          	blt	a4,a6,80034e <vprintfmt+0x1fa>
    else if (lflag) {
  80034a:	12080063          	beqz	a6,80046a <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  80034e:	000ab603          	ld	a2,0(s5)
  800352:	46a9                	li	a3,10
  800354:	8aae                	mv	s5,a1
  800356:	b7bd                	j	8002c4 <vprintfmt+0x170>
  800358:	00144603          	lbu	a2,1(s0)
            padc = '-';
  80035c:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  800360:	846a                	mv	s0,s10
  800362:	b5ad                	j	8001cc <vprintfmt+0x78>
            putch(ch, putdat);
  800364:	85a6                	mv	a1,s1
  800366:	02500513          	li	a0,37
  80036a:	9902                	jalr	s2
            break;
  80036c:	b50d                	j	80018e <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  80036e:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  800372:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800376:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800378:	846a                	mv	s0,s10
            if (width < 0)
  80037a:	e40dd9e3          	bgez	s11,8001cc <vprintfmt+0x78>
                width = precision, precision = -1;
  80037e:	8de6                	mv	s11,s9
  800380:	5cfd                	li	s9,-1
  800382:	b5a9                	j	8001cc <vprintfmt+0x78>
            goto reswitch;
  800384:	00144603          	lbu	a2,1(s0)
            padc = '0';
  800388:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  80038c:	846a                	mv	s0,s10
            goto reswitch;
  80038e:	bd3d                	j	8001cc <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800390:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800394:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800398:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80039a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  80039e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003a2:	fcd56ce3          	bltu	a0,a3,80037a <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  8003a6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8003a8:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8003ac:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  8003b0:	0196873b          	addw	a4,a3,s9
  8003b4:	0017171b          	slliw	a4,a4,0x1
  8003b8:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8003bc:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8003c0:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8003c4:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003c8:	fcd57fe3          	bleu	a3,a0,8003a6 <vprintfmt+0x252>
  8003cc:	b77d                	j	80037a <vprintfmt+0x226>
            if (width < 0)
  8003ce:	fffdc693          	not	a3,s11
  8003d2:	96fd                	srai	a3,a3,0x3f
  8003d4:	00ddfdb3          	and	s11,s11,a3
  8003d8:	00144603          	lbu	a2,1(s0)
  8003dc:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  8003de:	846a                	mv	s0,s10
  8003e0:	b3f5                	j	8001cc <vprintfmt+0x78>
            putch('%', putdat);
  8003e2:	85a6                	mv	a1,s1
  8003e4:	02500513          	li	a0,37
  8003e8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8003ea:	fff44703          	lbu	a4,-1(s0)
  8003ee:	02500793          	li	a5,37
  8003f2:	8d22                	mv	s10,s0
  8003f4:	d8f70de3          	beq	a4,a5,80018e <vprintfmt+0x3a>
  8003f8:	02500713          	li	a4,37
  8003fc:	1d7d                	addi	s10,s10,-1
  8003fe:	fffd4783          	lbu	a5,-1(s10)
  800402:	fee79de3          	bne	a5,a4,8003fc <vprintfmt+0x2a8>
  800406:	b361                	j	80018e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800408:	00000617          	auipc	a2,0x0
  80040c:	45060613          	addi	a2,a2,1104 # 800858 <error_string+0x1a8>
  800410:	85a6                	mv	a1,s1
  800412:	854a                	mv	a0,s2
  800414:	0ac000ef          	jal	ra,8004c0 <printfmt>
  800418:	bb9d                	j	80018e <vprintfmt+0x3a>
                p = "(null)";
  80041a:	00000617          	auipc	a2,0x0
  80041e:	43660613          	addi	a2,a2,1078 # 800850 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800422:	00000417          	auipc	s0,0x0
  800426:	42f40413          	addi	s0,s0,1071 # 800851 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80042a:	8532                	mv	a0,a2
  80042c:	85e6                	mv	a1,s9
  80042e:	e032                	sd	a2,0(sp)
  800430:	e43e                	sd	a5,8(sp)
  800432:	0ae000ef          	jal	ra,8004e0 <strnlen>
  800436:	40ad8dbb          	subw	s11,s11,a0
  80043a:	6602                	ld	a2,0(sp)
  80043c:	01b05d63          	blez	s11,800456 <vprintfmt+0x302>
  800440:	67a2                	ld	a5,8(sp)
  800442:	2781                	sext.w	a5,a5
  800444:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  800446:	6522                	ld	a0,8(sp)
  800448:	85a6                	mv	a1,s1
  80044a:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  80044c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  80044e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800450:	6602                	ld	a2,0(sp)
  800452:	fe0d9ae3          	bnez	s11,800446 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800456:	00064783          	lbu	a5,0(a2)
  80045a:	0007851b          	sext.w	a0,a5
  80045e:	e8051be3          	bnez	a0,8002f4 <vprintfmt+0x1a0>
  800462:	b335                	j	80018e <vprintfmt+0x3a>
        return va_arg(*ap, int);
  800464:	000aa403          	lw	s0,0(s5)
  800468:	bbf1                	j	800244 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  80046a:	000ae603          	lwu	a2,0(s5)
  80046e:	46a9                	li	a3,10
  800470:	8aae                	mv	s5,a1
  800472:	bd89                	j	8002c4 <vprintfmt+0x170>
  800474:	000ae603          	lwu	a2,0(s5)
  800478:	46c1                	li	a3,16
  80047a:	8aae                	mv	s5,a1
  80047c:	b5a1                	j	8002c4 <vprintfmt+0x170>
  80047e:	000ae603          	lwu	a2,0(s5)
  800482:	46a1                	li	a3,8
  800484:	8aae                	mv	s5,a1
  800486:	bd3d                	j	8002c4 <vprintfmt+0x170>
                    putch(ch, putdat);
  800488:	9902                	jalr	s2
  80048a:	b559                	j	800310 <vprintfmt+0x1bc>
                putch('-', putdat);
  80048c:	85a6                	mv	a1,s1
  80048e:	02d00513          	li	a0,45
  800492:	e03e                	sd	a5,0(sp)
  800494:	9902                	jalr	s2
                num = -(long long)num;
  800496:	8ace                	mv	s5,s3
  800498:	40800633          	neg	a2,s0
  80049c:	46a9                	li	a3,10
  80049e:	6782                	ld	a5,0(sp)
  8004a0:	b515                	j	8002c4 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  8004a2:	01b05663          	blez	s11,8004ae <vprintfmt+0x35a>
  8004a6:	02d00693          	li	a3,45
  8004aa:	f6d798e3          	bne	a5,a3,80041a <vprintfmt+0x2c6>
  8004ae:	00000417          	auipc	s0,0x0
  8004b2:	3a340413          	addi	s0,s0,931 # 800851 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004b6:	02800513          	li	a0,40
  8004ba:	02800793          	li	a5,40
  8004be:	bd1d                	j	8002f4 <vprintfmt+0x1a0>

00000000008004c0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004c0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004c2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004c6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004c8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ca:	ec06                	sd	ra,24(sp)
  8004cc:	f83a                	sd	a4,48(sp)
  8004ce:	fc3e                	sd	a5,56(sp)
  8004d0:	e0c2                	sd	a6,64(sp)
  8004d2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004d4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004d6:	c7fff0ef          	jal	ra,800154 <vprintfmt>
}
  8004da:	60e2                	ld	ra,24(sp)
  8004dc:	6161                	addi	sp,sp,80
  8004de:	8082                	ret

00000000008004e0 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  8004e0:	c185                	beqz	a1,800500 <strnlen+0x20>
  8004e2:	00054783          	lbu	a5,0(a0)
  8004e6:	cf89                	beqz	a5,800500 <strnlen+0x20>
    size_t cnt = 0;
  8004e8:	4781                	li	a5,0
  8004ea:	a021                	j	8004f2 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  8004ec:	00074703          	lbu	a4,0(a4)
  8004f0:	c711                	beqz	a4,8004fc <strnlen+0x1c>
        cnt ++;
  8004f2:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004f4:	00f50733          	add	a4,a0,a5
  8004f8:	fef59ae3          	bne	a1,a5,8004ec <strnlen+0xc>
    }
    return cnt;
}
  8004fc:	853e                	mv	a0,a5
  8004fe:	8082                	ret
    size_t cnt = 0;
  800500:	4781                	li	a5,0
}
  800502:	853e                	mv	a0,a5
  800504:	8082                	ret

0000000000800506 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  800506:	1141                	addi	sp,sp,-16
    cprintf("Hello world!!.\n");
  800508:	00000517          	auipc	a0,0x0
  80050c:	36850513          	addi	a0,a0,872 # 800870 <error_string+0x1c0>
main(void) {
  800510:	e406                	sd	ra,8(sp)
    cprintf("Hello world!!.\n");
  800512:	b2fff0ef          	jal	ra,800040 <cprintf>
    cprintf("I am process %d.\n", getpid());
  800516:	bc3ff0ef          	jal	ra,8000d8 <getpid>
  80051a:	85aa                	mv	a1,a0
  80051c:	00000517          	auipc	a0,0x0
  800520:	36450513          	addi	a0,a0,868 # 800880 <error_string+0x1d0>
  800524:	b1dff0ef          	jal	ra,800040 <cprintf>
    cprintf("hello pass.\n");
  800528:	00000517          	auipc	a0,0x0
  80052c:	37050513          	addi	a0,a0,880 # 800898 <error_string+0x1e8>
  800530:	b11ff0ef          	jal	ra,800040 <cprintf>
    return 0;
}
  800534:	60a2                	ld	ra,8(sp)
  800536:	4501                	li	a0,0
  800538:	0141                	addi	sp,sp,16
  80053a:	8082                	ret
