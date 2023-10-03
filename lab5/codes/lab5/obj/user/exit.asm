
obj/__user_exit.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	13e000ef          	jal	ra,80015e <umain>
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
  800038:	66c50513          	addi	a0,a0,1644 # 8006a0 <main+0x118>
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
  800058:	9fc50513          	addi	a0,a0,-1540 # 800a50 <error_string+0x220>
  80005c:	044000ef          	jal	ra,8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800060:	5559                	li	a0,-10
  800062:	0d2000ef          	jal	ra,800134 <exit>

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
  80006e:	0be000ef          	jal	ra,80012c <sys_putc>
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
  800094:	142000ef          	jal	ra,8001d6 <vprintfmt>
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
  8000c8:	10e000ef          	jal	ra,8001d6 <vprintfmt>
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

0000000000800116 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  800116:	4509                	li	a0,2
  800118:	fbdff06f          	j	8000d4 <syscall>

000000000080011c <sys_wait>:
}

int
sys_wait(int64_t pid, int *store) {
    return syscall(SYS_wait, pid, store);
  80011c:	862e                	mv	a2,a1
  80011e:	85aa                	mv	a1,a0
  800120:	450d                	li	a0,3
  800122:	fb3ff06f          	j	8000d4 <syscall>

0000000000800126 <sys_yield>:
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  800126:	4529                	li	a0,10
  800128:	fadff06f          	j	8000d4 <syscall>

000000000080012c <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  80012c:	85aa                	mv	a1,a0
  80012e:	4579                	li	a0,30
  800130:	fa5ff06f          	j	8000d4 <syscall>

0000000000800134 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800134:	1141                	addi	sp,sp,-16
  800136:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800138:	fd7ff0ef          	jal	ra,80010e <sys_exit>
    cprintf("BUG: exit failed.\n");
  80013c:	00000517          	auipc	a0,0x0
  800140:	58450513          	addi	a0,a0,1412 # 8006c0 <main+0x138>
  800144:	f5dff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  800148:	a001                	j	800148 <exit+0x14>

000000000080014a <fork>:
}

int
fork(void) {
    return sys_fork();
  80014a:	fcdff06f          	j	800116 <sys_fork>

000000000080014e <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  80014e:	4581                	li	a1,0
  800150:	4501                	li	a0,0
  800152:	fcbff06f          	j	80011c <sys_wait>

0000000000800156 <waitpid>:
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  800156:	fc7ff06f          	j	80011c <sys_wait>

000000000080015a <yield>:
}

void
yield(void) {
    sys_yield();
  80015a:	fcdff06f          	j	800126 <sys_yield>

000000000080015e <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80015e:	1141                	addi	sp,sp,-16
  800160:	e406                	sd	ra,8(sp)
    int ret = main();
  800162:	426000ef          	jal	ra,800588 <main>
    exit(ret);
  800166:	fcfff0ef          	jal	ra,800134 <exit>

000000000080016a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80016a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80016e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800170:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800174:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800176:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80017a:	f022                	sd	s0,32(sp)
  80017c:	ec26                	sd	s1,24(sp)
  80017e:	e84a                	sd	s2,16(sp)
  800180:	f406                	sd	ra,40(sp)
  800182:	e44e                	sd	s3,8(sp)
  800184:	84aa                	mv	s1,a0
  800186:	892e                	mv	s2,a1
  800188:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80018c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  80018e:	03067e63          	bleu	a6,a2,8001ca <printnum+0x60>
  800192:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800194:	00805763          	blez	s0,8001a2 <printnum+0x38>
  800198:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80019a:	85ca                	mv	a1,s2
  80019c:	854e                	mv	a0,s3
  80019e:	9482                	jalr	s1
        while (-- width > 0)
  8001a0:	fc65                	bnez	s0,800198 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001a2:	1a02                	slli	s4,s4,0x20
  8001a4:	020a5a13          	srli	s4,s4,0x20
  8001a8:	00000797          	auipc	a5,0x0
  8001ac:	75078793          	addi	a5,a5,1872 # 8008f8 <error_string+0xc8>
  8001b0:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001b2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b4:	000a4503          	lbu	a0,0(s4)
}
  8001b8:	70a2                	ld	ra,40(sp)
  8001ba:	69a2                	ld	s3,8(sp)
  8001bc:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001be:	85ca                	mv	a1,s2
  8001c0:	8326                	mv	t1,s1
}
  8001c2:	6942                	ld	s2,16(sp)
  8001c4:	64e2                	ld	s1,24(sp)
  8001c6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001c8:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001ca:	03065633          	divu	a2,a2,a6
  8001ce:	8722                	mv	a4,s0
  8001d0:	f9bff0ef          	jal	ra,80016a <printnum>
  8001d4:	b7f9                	j	8001a2 <printnum+0x38>

00000000008001d6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001d6:	7119                	addi	sp,sp,-128
  8001d8:	f4a6                	sd	s1,104(sp)
  8001da:	f0ca                	sd	s2,96(sp)
  8001dc:	e8d2                	sd	s4,80(sp)
  8001de:	e4d6                	sd	s5,72(sp)
  8001e0:	e0da                	sd	s6,64(sp)
  8001e2:	fc5e                	sd	s7,56(sp)
  8001e4:	f862                	sd	s8,48(sp)
  8001e6:	f06a                	sd	s10,32(sp)
  8001e8:	fc86                	sd	ra,120(sp)
  8001ea:	f8a2                	sd	s0,112(sp)
  8001ec:	ecce                	sd	s3,88(sp)
  8001ee:	f466                	sd	s9,40(sp)
  8001f0:	ec6e                	sd	s11,24(sp)
  8001f2:	892a                	mv	s2,a0
  8001f4:	84ae                	mv	s1,a1
  8001f6:	8d32                	mv	s10,a2
  8001f8:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001fa:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001fc:	00000a17          	auipc	s4,0x0
  800200:	4d8a0a13          	addi	s4,s4,1240 # 8006d4 <main+0x14c>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800204:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800208:	00000c17          	auipc	s8,0x0
  80020c:	628c0c13          	addi	s8,s8,1576 # 800830 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800210:	000d4503          	lbu	a0,0(s10)
  800214:	02500793          	li	a5,37
  800218:	001d0413          	addi	s0,s10,1
  80021c:	00f50e63          	beq	a0,a5,800238 <vprintfmt+0x62>
            if (ch == '\0') {
  800220:	c521                	beqz	a0,800268 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800222:	02500993          	li	s3,37
  800226:	a011                	j	80022a <vprintfmt+0x54>
            if (ch == '\0') {
  800228:	c121                	beqz	a0,800268 <vprintfmt+0x92>
            putch(ch, putdat);
  80022a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80022c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80022e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800230:	fff44503          	lbu	a0,-1(s0)
  800234:	ff351ae3          	bne	a0,s3,800228 <vprintfmt+0x52>
  800238:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80023c:	02000793          	li	a5,32
        lflag = altflag = 0;
  800240:	4981                	li	s3,0
  800242:	4801                	li	a6,0
        width = precision = -1;
  800244:	5cfd                	li	s9,-1
  800246:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800248:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  80024c:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  80024e:	fdd6069b          	addiw	a3,a2,-35
  800252:	0ff6f693          	andi	a3,a3,255
  800256:	00140d13          	addi	s10,s0,1
  80025a:	20d5e563          	bltu	a1,a3,800464 <vprintfmt+0x28e>
  80025e:	068a                	slli	a3,a3,0x2
  800260:	96d2                	add	a3,a3,s4
  800262:	4294                	lw	a3,0(a3)
  800264:	96d2                	add	a3,a3,s4
  800266:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800268:	70e6                	ld	ra,120(sp)
  80026a:	7446                	ld	s0,112(sp)
  80026c:	74a6                	ld	s1,104(sp)
  80026e:	7906                	ld	s2,96(sp)
  800270:	69e6                	ld	s3,88(sp)
  800272:	6a46                	ld	s4,80(sp)
  800274:	6aa6                	ld	s5,72(sp)
  800276:	6b06                	ld	s6,64(sp)
  800278:	7be2                	ld	s7,56(sp)
  80027a:	7c42                	ld	s8,48(sp)
  80027c:	7ca2                	ld	s9,40(sp)
  80027e:	7d02                	ld	s10,32(sp)
  800280:	6de2                	ld	s11,24(sp)
  800282:	6109                	addi	sp,sp,128
  800284:	8082                	ret
    if (lflag >= 2) {
  800286:	4705                	li	a4,1
  800288:	008a8593          	addi	a1,s5,8
  80028c:	01074463          	blt	a4,a6,800294 <vprintfmt+0xbe>
    else if (lflag) {
  800290:	26080363          	beqz	a6,8004f6 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  800294:	000ab603          	ld	a2,0(s5)
  800298:	46c1                	li	a3,16
  80029a:	8aae                	mv	s5,a1
  80029c:	a06d                	j	800346 <vprintfmt+0x170>
            goto reswitch;
  80029e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002a2:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002a4:	846a                	mv	s0,s10
            goto reswitch;
  8002a6:	b765                	j	80024e <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  8002a8:	000aa503          	lw	a0,0(s5)
  8002ac:	85a6                	mv	a1,s1
  8002ae:	0aa1                	addi	s5,s5,8
  8002b0:	9902                	jalr	s2
            break;
  8002b2:	bfb9                	j	800210 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002b4:	4705                	li	a4,1
  8002b6:	008a8993          	addi	s3,s5,8
  8002ba:	01074463          	blt	a4,a6,8002c2 <vprintfmt+0xec>
    else if (lflag) {
  8002be:	22080463          	beqz	a6,8004e6 <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002c2:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002c6:	24044463          	bltz	s0,80050e <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002ca:	8622                	mv	a2,s0
  8002cc:	8ace                	mv	s5,s3
  8002ce:	46a9                	li	a3,10
  8002d0:	a89d                	j	800346 <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002d2:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002d6:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002d8:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002da:	41f7d69b          	sraiw	a3,a5,0x1f
  8002de:	8fb5                	xor	a5,a5,a3
  8002e0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002e4:	1ad74363          	blt	a4,a3,80048a <vprintfmt+0x2b4>
  8002e8:	00369793          	slli	a5,a3,0x3
  8002ec:	97e2                	add	a5,a5,s8
  8002ee:	639c                	ld	a5,0(a5)
  8002f0:	18078d63          	beqz	a5,80048a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  8002f4:	86be                	mv	a3,a5
  8002f6:	00000617          	auipc	a2,0x0
  8002fa:	6f260613          	addi	a2,a2,1778 # 8009e8 <error_string+0x1b8>
  8002fe:	85a6                	mv	a1,s1
  800300:	854a                	mv	a0,s2
  800302:	240000ef          	jal	ra,800542 <printfmt>
  800306:	b729                	j	800210 <vprintfmt+0x3a>
            lflag ++;
  800308:	00144603          	lbu	a2,1(s0)
  80030c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  80030e:	846a                	mv	s0,s10
            goto reswitch;
  800310:	bf3d                	j	80024e <vprintfmt+0x78>
    if (lflag >= 2) {
  800312:	4705                	li	a4,1
  800314:	008a8593          	addi	a1,s5,8
  800318:	01074463          	blt	a4,a6,800320 <vprintfmt+0x14a>
    else if (lflag) {
  80031c:	1e080263          	beqz	a6,800500 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  800320:	000ab603          	ld	a2,0(s5)
  800324:	46a1                	li	a3,8
  800326:	8aae                	mv	s5,a1
  800328:	a839                	j	800346 <vprintfmt+0x170>
            putch('0', putdat);
  80032a:	03000513          	li	a0,48
  80032e:	85a6                	mv	a1,s1
  800330:	e03e                	sd	a5,0(sp)
  800332:	9902                	jalr	s2
            putch('x', putdat);
  800334:	85a6                	mv	a1,s1
  800336:	07800513          	li	a0,120
  80033a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80033c:	0aa1                	addi	s5,s5,8
  80033e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800342:	6782                	ld	a5,0(sp)
  800344:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800346:	876e                	mv	a4,s11
  800348:	85a6                	mv	a1,s1
  80034a:	854a                	mv	a0,s2
  80034c:	e1fff0ef          	jal	ra,80016a <printnum>
            break;
  800350:	b5c1                	j	800210 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800352:	000ab603          	ld	a2,0(s5)
  800356:	0aa1                	addi	s5,s5,8
  800358:	1c060663          	beqz	a2,800524 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  80035c:	00160413          	addi	s0,a2,1
  800360:	17b05c63          	blez	s11,8004d8 <vprintfmt+0x302>
  800364:	02d00593          	li	a1,45
  800368:	14b79263          	bne	a5,a1,8004ac <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80036c:	00064783          	lbu	a5,0(a2)
  800370:	0007851b          	sext.w	a0,a5
  800374:	c905                	beqz	a0,8003a4 <vprintfmt+0x1ce>
  800376:	000cc563          	bltz	s9,800380 <vprintfmt+0x1aa>
  80037a:	3cfd                	addiw	s9,s9,-1
  80037c:	036c8263          	beq	s9,s6,8003a0 <vprintfmt+0x1ca>
                    putch('?', putdat);
  800380:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800382:	18098463          	beqz	s3,80050a <vprintfmt+0x334>
  800386:	3781                	addiw	a5,a5,-32
  800388:	18fbf163          	bleu	a5,s7,80050a <vprintfmt+0x334>
                    putch('?', putdat);
  80038c:	03f00513          	li	a0,63
  800390:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800392:	0405                	addi	s0,s0,1
  800394:	fff44783          	lbu	a5,-1(s0)
  800398:	3dfd                	addiw	s11,s11,-1
  80039a:	0007851b          	sext.w	a0,a5
  80039e:	fd61                	bnez	a0,800376 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  8003a0:	e7b058e3          	blez	s11,800210 <vprintfmt+0x3a>
  8003a4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003a6:	85a6                	mv	a1,s1
  8003a8:	02000513          	li	a0,32
  8003ac:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ae:	e60d81e3          	beqz	s11,800210 <vprintfmt+0x3a>
  8003b2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003b4:	85a6                	mv	a1,s1
  8003b6:	02000513          	li	a0,32
  8003ba:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003bc:	fe0d94e3          	bnez	s11,8003a4 <vprintfmt+0x1ce>
  8003c0:	bd81                	j	800210 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003c2:	4705                	li	a4,1
  8003c4:	008a8593          	addi	a1,s5,8
  8003c8:	01074463          	blt	a4,a6,8003d0 <vprintfmt+0x1fa>
    else if (lflag) {
  8003cc:	12080063          	beqz	a6,8004ec <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003d0:	000ab603          	ld	a2,0(s5)
  8003d4:	46a9                	li	a3,10
  8003d6:	8aae                	mv	s5,a1
  8003d8:	b7bd                	j	800346 <vprintfmt+0x170>
  8003da:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003de:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  8003e2:	846a                	mv	s0,s10
  8003e4:	b5ad                	j	80024e <vprintfmt+0x78>
            putch(ch, putdat);
  8003e6:	85a6                	mv	a1,s1
  8003e8:	02500513          	li	a0,37
  8003ec:	9902                	jalr	s2
            break;
  8003ee:	b50d                	j	800210 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  8003f0:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8003f4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8003f8:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8003fa:	846a                	mv	s0,s10
            if (width < 0)
  8003fc:	e40dd9e3          	bgez	s11,80024e <vprintfmt+0x78>
                width = precision, precision = -1;
  800400:	8de6                	mv	s11,s9
  800402:	5cfd                	li	s9,-1
  800404:	b5a9                	j	80024e <vprintfmt+0x78>
            goto reswitch;
  800406:	00144603          	lbu	a2,1(s0)
            padc = '0';
  80040a:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  80040e:	846a                	mv	s0,s10
            goto reswitch;
  800410:	bd3d                	j	80024e <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800412:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800416:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80041a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80041c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800420:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800424:	fcd56ce3          	bltu	a0,a3,8003fc <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  800428:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80042a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  80042e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800432:	0196873b          	addw	a4,a3,s9
  800436:	0017171b          	slliw	a4,a4,0x1
  80043a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  80043e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800442:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800446:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80044a:	fcd57fe3          	bleu	a3,a0,800428 <vprintfmt+0x252>
  80044e:	b77d                	j	8003fc <vprintfmt+0x226>
            if (width < 0)
  800450:	fffdc693          	not	a3,s11
  800454:	96fd                	srai	a3,a3,0x3f
  800456:	00ddfdb3          	and	s11,s11,a3
  80045a:	00144603          	lbu	a2,1(s0)
  80045e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800460:	846a                	mv	s0,s10
  800462:	b3f5                	j	80024e <vprintfmt+0x78>
            putch('%', putdat);
  800464:	85a6                	mv	a1,s1
  800466:	02500513          	li	a0,37
  80046a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80046c:	fff44703          	lbu	a4,-1(s0)
  800470:	02500793          	li	a5,37
  800474:	8d22                	mv	s10,s0
  800476:	d8f70de3          	beq	a4,a5,800210 <vprintfmt+0x3a>
  80047a:	02500713          	li	a4,37
  80047e:	1d7d                	addi	s10,s10,-1
  800480:	fffd4783          	lbu	a5,-1(s10)
  800484:	fee79de3          	bne	a5,a4,80047e <vprintfmt+0x2a8>
  800488:	b361                	j	800210 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80048a:	00000617          	auipc	a2,0x0
  80048e:	54e60613          	addi	a2,a2,1358 # 8009d8 <error_string+0x1a8>
  800492:	85a6                	mv	a1,s1
  800494:	854a                	mv	a0,s2
  800496:	0ac000ef          	jal	ra,800542 <printfmt>
  80049a:	bb9d                	j	800210 <vprintfmt+0x3a>
                p = "(null)";
  80049c:	00000617          	auipc	a2,0x0
  8004a0:	53460613          	addi	a2,a2,1332 # 8009d0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004a4:	00000417          	auipc	s0,0x0
  8004a8:	52d40413          	addi	s0,s0,1325 # 8009d1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ac:	8532                	mv	a0,a2
  8004ae:	85e6                	mv	a1,s9
  8004b0:	e032                	sd	a2,0(sp)
  8004b2:	e43e                	sd	a5,8(sp)
  8004b4:	0ae000ef          	jal	ra,800562 <strnlen>
  8004b8:	40ad8dbb          	subw	s11,s11,a0
  8004bc:	6602                	ld	a2,0(sp)
  8004be:	01b05d63          	blez	s11,8004d8 <vprintfmt+0x302>
  8004c2:	67a2                	ld	a5,8(sp)
  8004c4:	2781                	sext.w	a5,a5
  8004c6:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004c8:	6522                	ld	a0,8(sp)
  8004ca:	85a6                	mv	a1,s1
  8004cc:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ce:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004d0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d2:	6602                	ld	a2,0(sp)
  8004d4:	fe0d9ae3          	bnez	s11,8004c8 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004d8:	00064783          	lbu	a5,0(a2)
  8004dc:	0007851b          	sext.w	a0,a5
  8004e0:	e8051be3          	bnez	a0,800376 <vprintfmt+0x1a0>
  8004e4:	b335                	j	800210 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  8004e6:	000aa403          	lw	s0,0(s5)
  8004ea:	bbf1                	j	8002c6 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  8004ec:	000ae603          	lwu	a2,0(s5)
  8004f0:	46a9                	li	a3,10
  8004f2:	8aae                	mv	s5,a1
  8004f4:	bd89                	j	800346 <vprintfmt+0x170>
  8004f6:	000ae603          	lwu	a2,0(s5)
  8004fa:	46c1                	li	a3,16
  8004fc:	8aae                	mv	s5,a1
  8004fe:	b5a1                	j	800346 <vprintfmt+0x170>
  800500:	000ae603          	lwu	a2,0(s5)
  800504:	46a1                	li	a3,8
  800506:	8aae                	mv	s5,a1
  800508:	bd3d                	j	800346 <vprintfmt+0x170>
                    putch(ch, putdat);
  80050a:	9902                	jalr	s2
  80050c:	b559                	j	800392 <vprintfmt+0x1bc>
                putch('-', putdat);
  80050e:	85a6                	mv	a1,s1
  800510:	02d00513          	li	a0,45
  800514:	e03e                	sd	a5,0(sp)
  800516:	9902                	jalr	s2
                num = -(long long)num;
  800518:	8ace                	mv	s5,s3
  80051a:	40800633          	neg	a2,s0
  80051e:	46a9                	li	a3,10
  800520:	6782                	ld	a5,0(sp)
  800522:	b515                	j	800346 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  800524:	01b05663          	blez	s11,800530 <vprintfmt+0x35a>
  800528:	02d00693          	li	a3,45
  80052c:	f6d798e3          	bne	a5,a3,80049c <vprintfmt+0x2c6>
  800530:	00000417          	auipc	s0,0x0
  800534:	4a140413          	addi	s0,s0,1185 # 8009d1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800538:	02800513          	li	a0,40
  80053c:	02800793          	li	a5,40
  800540:	bd1d                	j	800376 <vprintfmt+0x1a0>

0000000000800542 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800542:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800544:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800548:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80054a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80054c:	ec06                	sd	ra,24(sp)
  80054e:	f83a                	sd	a4,48(sp)
  800550:	fc3e                	sd	a5,56(sp)
  800552:	e0c2                	sd	a6,64(sp)
  800554:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800556:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800558:	c7fff0ef          	jal	ra,8001d6 <vprintfmt>
}
  80055c:	60e2                	ld	ra,24(sp)
  80055e:	6161                	addi	sp,sp,80
  800560:	8082                	ret

0000000000800562 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800562:	c185                	beqz	a1,800582 <strnlen+0x20>
  800564:	00054783          	lbu	a5,0(a0)
  800568:	cf89                	beqz	a5,800582 <strnlen+0x20>
    size_t cnt = 0;
  80056a:	4781                	li	a5,0
  80056c:	a021                	j	800574 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  80056e:	00074703          	lbu	a4,0(a4)
  800572:	c711                	beqz	a4,80057e <strnlen+0x1c>
        cnt ++;
  800574:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800576:	00f50733          	add	a4,a0,a5
  80057a:	fef59ae3          	bne	a1,a5,80056e <strnlen+0xc>
    }
    return cnt;
}
  80057e:	853e                	mv	a0,a5
  800580:	8082                	ret
    size_t cnt = 0;
  800582:	4781                	li	a5,0
}
  800584:	853e                	mv	a0,a5
  800586:	8082                	ret

0000000000800588 <main>:
#include <ulib.h>

int magic = -0x10384;

int
main(void) {
  800588:	1101                	addi	sp,sp,-32
    int pid, code;
    cprintf("I am the parent. Forking the child...\n");
  80058a:	00000517          	auipc	a0,0x0
  80058e:	46650513          	addi	a0,a0,1126 # 8009f0 <error_string+0x1c0>
main(void) {
  800592:	ec06                	sd	ra,24(sp)
  800594:	e822                	sd	s0,16(sp)
    cprintf("I am the parent. Forking the child...\n");
  800596:	b0bff0ef          	jal	ra,8000a0 <cprintf>
    if ((pid = fork()) == 0) {
  80059a:	bb1ff0ef          	jal	ra,80014a <fork>
  80059e:	c571                	beqz	a0,80066a <main+0xe2>
  8005a0:	842a                	mv	s0,a0
        yield();
        yield();
        exit(magic);
    }
    else {
        cprintf("I am parent, fork a child pid %d\n",pid);
  8005a2:	85aa                	mv	a1,a0
  8005a4:	00000517          	auipc	a0,0x0
  8005a8:	48c50513          	addi	a0,a0,1164 # 800a30 <error_string+0x200>
  8005ac:	af5ff0ef          	jal	ra,8000a0 <cprintf>
    }
    assert(pid > 0);
  8005b0:	08805e63          	blez	s0,80064c <main+0xc4>
    cprintf("I am the parent, waiting now..\n");
  8005b4:	00000517          	auipc	a0,0x0
  8005b8:	4d450513          	addi	a0,a0,1236 # 800a88 <error_string+0x258>
  8005bc:	ae5ff0ef          	jal	ra,8000a0 <cprintf>
    
    assert(waitpid(pid, &code) == 0 && code == magic);
  8005c0:	006c                	addi	a1,sp,12
  8005c2:	8522                	mv	a0,s0
  8005c4:	b93ff0ef          	jal	ra,800156 <waitpid>
  8005c8:	e139                	bnez	a0,80060e <main+0x86>
  8005ca:	00001797          	auipc	a5,0x1
  8005ce:	a3678793          	addi	a5,a5,-1482 # 801000 <magic>
  8005d2:	4732                	lw	a4,12(sp)
  8005d4:	439c                	lw	a5,0(a5)
  8005d6:	02f71c63          	bne	a4,a5,80060e <main+0x86>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  8005da:	006c                	addi	a1,sp,12
  8005dc:	8522                	mv	a0,s0
  8005de:	b79ff0ef          	jal	ra,800156 <waitpid>
  8005e2:	c529                	beqz	a0,80062c <main+0xa4>
  8005e4:	b6bff0ef          	jal	ra,80014e <wait>
  8005e8:	c131                	beqz	a0,80062c <main+0xa4>
    cprintf("waitpid %d ok.\n", pid);
  8005ea:	85a2                	mv	a1,s0
  8005ec:	00000517          	auipc	a0,0x0
  8005f0:	51450513          	addi	a0,a0,1300 # 800b00 <error_string+0x2d0>
  8005f4:	aadff0ef          	jal	ra,8000a0 <cprintf>

    cprintf("exit pass.\n");
  8005f8:	00000517          	auipc	a0,0x0
  8005fc:	51850513          	addi	a0,a0,1304 # 800b10 <error_string+0x2e0>
  800600:	aa1ff0ef          	jal	ra,8000a0 <cprintf>
    return 0;
}
  800604:	60e2                	ld	ra,24(sp)
  800606:	6442                	ld	s0,16(sp)
  800608:	4501                	li	a0,0
  80060a:	6105                	addi	sp,sp,32
  80060c:	8082                	ret
    assert(waitpid(pid, &code) == 0 && code == magic);
  80060e:	00000697          	auipc	a3,0x0
  800612:	49a68693          	addi	a3,a3,1178 # 800aa8 <error_string+0x278>
  800616:	00000617          	auipc	a2,0x0
  80061a:	44a60613          	addi	a2,a2,1098 # 800a60 <error_string+0x230>
  80061e:	45fd                	li	a1,31
  800620:	00000517          	auipc	a0,0x0
  800624:	45850513          	addi	a0,a0,1112 # 800a78 <error_string+0x248>
  800628:	9ffff0ef          	jal	ra,800026 <__panic>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  80062c:	00000697          	auipc	a3,0x0
  800630:	4ac68693          	addi	a3,a3,1196 # 800ad8 <error_string+0x2a8>
  800634:	00000617          	auipc	a2,0x0
  800638:	42c60613          	addi	a2,a2,1068 # 800a60 <error_string+0x230>
  80063c:	02000593          	li	a1,32
  800640:	00000517          	auipc	a0,0x0
  800644:	43850513          	addi	a0,a0,1080 # 800a78 <error_string+0x248>
  800648:	9dfff0ef          	jal	ra,800026 <__panic>
    assert(pid > 0);
  80064c:	00000697          	auipc	a3,0x0
  800650:	40c68693          	addi	a3,a3,1036 # 800a58 <error_string+0x228>
  800654:	00000617          	auipc	a2,0x0
  800658:	40c60613          	addi	a2,a2,1036 # 800a60 <error_string+0x230>
  80065c:	45f1                	li	a1,28
  80065e:	00000517          	auipc	a0,0x0
  800662:	41a50513          	addi	a0,a0,1050 # 800a78 <error_string+0x248>
  800666:	9c1ff0ef          	jal	ra,800026 <__panic>
        cprintf("I am the child.\n");
  80066a:	00000517          	auipc	a0,0x0
  80066e:	3ae50513          	addi	a0,a0,942 # 800a18 <error_string+0x1e8>
  800672:	a2fff0ef          	jal	ra,8000a0 <cprintf>
        yield();
  800676:	ae5ff0ef          	jal	ra,80015a <yield>
        yield();
  80067a:	ae1ff0ef          	jal	ra,80015a <yield>
        yield();
  80067e:	addff0ef          	jal	ra,80015a <yield>
        yield();
  800682:	ad9ff0ef          	jal	ra,80015a <yield>
        yield();
  800686:	ad5ff0ef          	jal	ra,80015a <yield>
        yield();
  80068a:	ad1ff0ef          	jal	ra,80015a <yield>
        yield();
  80068e:	acdff0ef          	jal	ra,80015a <yield>
        exit(magic);
  800692:	00001797          	auipc	a5,0x1
  800696:	96e78793          	addi	a5,a5,-1682 # 801000 <magic>
  80069a:	4388                	lw	a0,0(a5)
  80069c:	a99ff0ef          	jal	ra,800134 <exit>
