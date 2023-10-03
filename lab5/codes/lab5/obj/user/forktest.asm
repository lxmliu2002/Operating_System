
obj/__user_forktest.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	130000ef          	jal	ra,800150 <umain>
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
  800038:	5f450513          	addi	a0,a0,1524 # 800628 <main+0xae>
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
  800058:	5f450513          	addi	a0,a0,1524 # 800648 <main+0xce>
  80005c:	044000ef          	jal	ra,8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800060:	5559                	li	a0,-10
  800062:	0cc000ef          	jal	ra,80012e <exit>

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
  80006e:	0b8000ef          	jal	ra,800126 <sys_putc>
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
  800094:	134000ef          	jal	ra,8001c8 <vprintfmt>
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
  8000c8:	100000ef          	jal	ra,8001c8 <vprintfmt>
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

0000000000800126 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  800126:	85aa                	mv	a1,a0
  800128:	4579                	li	a0,30
  80012a:	fabff06f          	j	8000d4 <syscall>

000000000080012e <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80012e:	1141                	addi	sp,sp,-16
  800130:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800132:	fddff0ef          	jal	ra,80010e <sys_exit>
    cprintf("BUG: exit failed.\n");
  800136:	00000517          	auipc	a0,0x0
  80013a:	51a50513          	addi	a0,a0,1306 # 800650 <main+0xd6>
  80013e:	f63ff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  800142:	a001                	j	800142 <exit+0x14>

0000000000800144 <fork>:
}

int
fork(void) {
    return sys_fork();
  800144:	fd3ff06f          	j	800116 <sys_fork>

0000000000800148 <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  800148:	4581                	li	a1,0
  80014a:	4501                	li	a0,0
  80014c:	fd1ff06f          	j	80011c <sys_wait>

0000000000800150 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800150:	1141                	addi	sp,sp,-16
  800152:	e406                	sd	ra,8(sp)
    int ret = main();
  800154:	426000ef          	jal	ra,80057a <main>
    exit(ret);
  800158:	fd7ff0ef          	jal	ra,80012e <exit>

000000000080015c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80015c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800160:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800162:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800166:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800168:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80016c:	f022                	sd	s0,32(sp)
  80016e:	ec26                	sd	s1,24(sp)
  800170:	e84a                	sd	s2,16(sp)
  800172:	f406                	sd	ra,40(sp)
  800174:	e44e                	sd	s3,8(sp)
  800176:	84aa                	mv	s1,a0
  800178:	892e                	mv	s2,a1
  80017a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80017e:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800180:	03067e63          	bleu	a6,a2,8001bc <printnum+0x60>
  800184:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800186:	00805763          	blez	s0,800194 <printnum+0x38>
  80018a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80018c:	85ca                	mv	a1,s2
  80018e:	854e                	mv	a0,s3
  800190:	9482                	jalr	s1
        while (-- width > 0)
  800192:	fc65                	bnez	s0,80018a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800194:	1a02                	slli	s4,s4,0x20
  800196:	020a5a13          	srli	s4,s4,0x20
  80019a:	00000797          	auipc	a5,0x0
  80019e:	6ee78793          	addi	a5,a5,1774 # 800888 <error_string+0xc8>
  8001a2:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001a4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a6:	000a4503          	lbu	a0,0(s4)
}
  8001aa:	70a2                	ld	ra,40(sp)
  8001ac:	69a2                	ld	s3,8(sp)
  8001ae:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b0:	85ca                	mv	a1,s2
  8001b2:	8326                	mv	t1,s1
}
  8001b4:	6942                	ld	s2,16(sp)
  8001b6:	64e2                	ld	s1,24(sp)
  8001b8:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001ba:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001bc:	03065633          	divu	a2,a2,a6
  8001c0:	8722                	mv	a4,s0
  8001c2:	f9bff0ef          	jal	ra,80015c <printnum>
  8001c6:	b7f9                	j	800194 <printnum+0x38>

00000000008001c8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001c8:	7119                	addi	sp,sp,-128
  8001ca:	f4a6                	sd	s1,104(sp)
  8001cc:	f0ca                	sd	s2,96(sp)
  8001ce:	e8d2                	sd	s4,80(sp)
  8001d0:	e4d6                	sd	s5,72(sp)
  8001d2:	e0da                	sd	s6,64(sp)
  8001d4:	fc5e                	sd	s7,56(sp)
  8001d6:	f862                	sd	s8,48(sp)
  8001d8:	f06a                	sd	s10,32(sp)
  8001da:	fc86                	sd	ra,120(sp)
  8001dc:	f8a2                	sd	s0,112(sp)
  8001de:	ecce                	sd	s3,88(sp)
  8001e0:	f466                	sd	s9,40(sp)
  8001e2:	ec6e                	sd	s11,24(sp)
  8001e4:	892a                	mv	s2,a0
  8001e6:	84ae                	mv	s1,a1
  8001e8:	8d32                	mv	s10,a2
  8001ea:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001ec:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001ee:	00000a17          	auipc	s4,0x0
  8001f2:	476a0a13          	addi	s4,s4,1142 # 800664 <main+0xea>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  8001f6:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001fa:	00000c17          	auipc	s8,0x0
  8001fe:	5c6c0c13          	addi	s8,s8,1478 # 8007c0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800202:	000d4503          	lbu	a0,0(s10)
  800206:	02500793          	li	a5,37
  80020a:	001d0413          	addi	s0,s10,1
  80020e:	00f50e63          	beq	a0,a5,80022a <vprintfmt+0x62>
            if (ch == '\0') {
  800212:	c521                	beqz	a0,80025a <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800214:	02500993          	li	s3,37
  800218:	a011                	j	80021c <vprintfmt+0x54>
            if (ch == '\0') {
  80021a:	c121                	beqz	a0,80025a <vprintfmt+0x92>
            putch(ch, putdat);
  80021c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800220:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800222:	fff44503          	lbu	a0,-1(s0)
  800226:	ff351ae3          	bne	a0,s3,80021a <vprintfmt+0x52>
  80022a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80022e:	02000793          	li	a5,32
        lflag = altflag = 0;
  800232:	4981                	li	s3,0
  800234:	4801                	li	a6,0
        width = precision = -1;
  800236:	5cfd                	li	s9,-1
  800238:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  80023a:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  80023e:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800240:	fdd6069b          	addiw	a3,a2,-35
  800244:	0ff6f693          	andi	a3,a3,255
  800248:	00140d13          	addi	s10,s0,1
  80024c:	20d5e563          	bltu	a1,a3,800456 <vprintfmt+0x28e>
  800250:	068a                	slli	a3,a3,0x2
  800252:	96d2                	add	a3,a3,s4
  800254:	4294                	lw	a3,0(a3)
  800256:	96d2                	add	a3,a3,s4
  800258:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80025a:	70e6                	ld	ra,120(sp)
  80025c:	7446                	ld	s0,112(sp)
  80025e:	74a6                	ld	s1,104(sp)
  800260:	7906                	ld	s2,96(sp)
  800262:	69e6                	ld	s3,88(sp)
  800264:	6a46                	ld	s4,80(sp)
  800266:	6aa6                	ld	s5,72(sp)
  800268:	6b06                	ld	s6,64(sp)
  80026a:	7be2                	ld	s7,56(sp)
  80026c:	7c42                	ld	s8,48(sp)
  80026e:	7ca2                	ld	s9,40(sp)
  800270:	7d02                	ld	s10,32(sp)
  800272:	6de2                	ld	s11,24(sp)
  800274:	6109                	addi	sp,sp,128
  800276:	8082                	ret
    if (lflag >= 2) {
  800278:	4705                	li	a4,1
  80027a:	008a8593          	addi	a1,s5,8
  80027e:	01074463          	blt	a4,a6,800286 <vprintfmt+0xbe>
    else if (lflag) {
  800282:	26080363          	beqz	a6,8004e8 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  800286:	000ab603          	ld	a2,0(s5)
  80028a:	46c1                	li	a3,16
  80028c:	8aae                	mv	s5,a1
  80028e:	a06d                	j	800338 <vprintfmt+0x170>
            goto reswitch;
  800290:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800294:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800296:	846a                	mv	s0,s10
            goto reswitch;
  800298:	b765                	j	800240 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  80029a:	000aa503          	lw	a0,0(s5)
  80029e:	85a6                	mv	a1,s1
  8002a0:	0aa1                	addi	s5,s5,8
  8002a2:	9902                	jalr	s2
            break;
  8002a4:	bfb9                	j	800202 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002a6:	4705                	li	a4,1
  8002a8:	008a8993          	addi	s3,s5,8
  8002ac:	01074463          	blt	a4,a6,8002b4 <vprintfmt+0xec>
    else if (lflag) {
  8002b0:	22080463          	beqz	a6,8004d8 <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002b4:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002b8:	24044463          	bltz	s0,800500 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002bc:	8622                	mv	a2,s0
  8002be:	8ace                	mv	s5,s3
  8002c0:	46a9                	li	a3,10
  8002c2:	a89d                	j	800338 <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002c4:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002c8:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002ca:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002cc:	41f7d69b          	sraiw	a3,a5,0x1f
  8002d0:	8fb5                	xor	a5,a5,a3
  8002d2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002d6:	1ad74363          	blt	a4,a3,80047c <vprintfmt+0x2b4>
  8002da:	00369793          	slli	a5,a3,0x3
  8002de:	97e2                	add	a5,a5,s8
  8002e0:	639c                	ld	a5,0(a5)
  8002e2:	18078d63          	beqz	a5,80047c <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  8002e6:	86be                	mv	a3,a5
  8002e8:	00000617          	auipc	a2,0x0
  8002ec:	69060613          	addi	a2,a2,1680 # 800978 <error_string+0x1b8>
  8002f0:	85a6                	mv	a1,s1
  8002f2:	854a                	mv	a0,s2
  8002f4:	240000ef          	jal	ra,800534 <printfmt>
  8002f8:	b729                	j	800202 <vprintfmt+0x3a>
            lflag ++;
  8002fa:	00144603          	lbu	a2,1(s0)
  8002fe:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800300:	846a                	mv	s0,s10
            goto reswitch;
  800302:	bf3d                	j	800240 <vprintfmt+0x78>
    if (lflag >= 2) {
  800304:	4705                	li	a4,1
  800306:	008a8593          	addi	a1,s5,8
  80030a:	01074463          	blt	a4,a6,800312 <vprintfmt+0x14a>
    else if (lflag) {
  80030e:	1e080263          	beqz	a6,8004f2 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  800312:	000ab603          	ld	a2,0(s5)
  800316:	46a1                	li	a3,8
  800318:	8aae                	mv	s5,a1
  80031a:	a839                	j	800338 <vprintfmt+0x170>
            putch('0', putdat);
  80031c:	03000513          	li	a0,48
  800320:	85a6                	mv	a1,s1
  800322:	e03e                	sd	a5,0(sp)
  800324:	9902                	jalr	s2
            putch('x', putdat);
  800326:	85a6                	mv	a1,s1
  800328:	07800513          	li	a0,120
  80032c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80032e:	0aa1                	addi	s5,s5,8
  800330:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800334:	6782                	ld	a5,0(sp)
  800336:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800338:	876e                	mv	a4,s11
  80033a:	85a6                	mv	a1,s1
  80033c:	854a                	mv	a0,s2
  80033e:	e1fff0ef          	jal	ra,80015c <printnum>
            break;
  800342:	b5c1                	j	800202 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800344:	000ab603          	ld	a2,0(s5)
  800348:	0aa1                	addi	s5,s5,8
  80034a:	1c060663          	beqz	a2,800516 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  80034e:	00160413          	addi	s0,a2,1
  800352:	17b05c63          	blez	s11,8004ca <vprintfmt+0x302>
  800356:	02d00593          	li	a1,45
  80035a:	14b79263          	bne	a5,a1,80049e <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80035e:	00064783          	lbu	a5,0(a2)
  800362:	0007851b          	sext.w	a0,a5
  800366:	c905                	beqz	a0,800396 <vprintfmt+0x1ce>
  800368:	000cc563          	bltz	s9,800372 <vprintfmt+0x1aa>
  80036c:	3cfd                	addiw	s9,s9,-1
  80036e:	036c8263          	beq	s9,s6,800392 <vprintfmt+0x1ca>
                    putch('?', putdat);
  800372:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800374:	18098463          	beqz	s3,8004fc <vprintfmt+0x334>
  800378:	3781                	addiw	a5,a5,-32
  80037a:	18fbf163          	bleu	a5,s7,8004fc <vprintfmt+0x334>
                    putch('?', putdat);
  80037e:	03f00513          	li	a0,63
  800382:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800384:	0405                	addi	s0,s0,1
  800386:	fff44783          	lbu	a5,-1(s0)
  80038a:	3dfd                	addiw	s11,s11,-1
  80038c:	0007851b          	sext.w	a0,a5
  800390:	fd61                	bnez	a0,800368 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  800392:	e7b058e3          	blez	s11,800202 <vprintfmt+0x3a>
  800396:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800398:	85a6                	mv	a1,s1
  80039a:	02000513          	li	a0,32
  80039e:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003a0:	e60d81e3          	beqz	s11,800202 <vprintfmt+0x3a>
  8003a4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003a6:	85a6                	mv	a1,s1
  8003a8:	02000513          	li	a0,32
  8003ac:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ae:	fe0d94e3          	bnez	s11,800396 <vprintfmt+0x1ce>
  8003b2:	bd81                	j	800202 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003b4:	4705                	li	a4,1
  8003b6:	008a8593          	addi	a1,s5,8
  8003ba:	01074463          	blt	a4,a6,8003c2 <vprintfmt+0x1fa>
    else if (lflag) {
  8003be:	12080063          	beqz	a6,8004de <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003c2:	000ab603          	ld	a2,0(s5)
  8003c6:	46a9                	li	a3,10
  8003c8:	8aae                	mv	s5,a1
  8003ca:	b7bd                	j	800338 <vprintfmt+0x170>
  8003cc:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003d0:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  8003d4:	846a                	mv	s0,s10
  8003d6:	b5ad                	j	800240 <vprintfmt+0x78>
            putch(ch, putdat);
  8003d8:	85a6                	mv	a1,s1
  8003da:	02500513          	li	a0,37
  8003de:	9902                	jalr	s2
            break;
  8003e0:	b50d                	j	800202 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  8003e2:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8003e6:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8003ea:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8003ec:	846a                	mv	s0,s10
            if (width < 0)
  8003ee:	e40dd9e3          	bgez	s11,800240 <vprintfmt+0x78>
                width = precision, precision = -1;
  8003f2:	8de6                	mv	s11,s9
  8003f4:	5cfd                	li	s9,-1
  8003f6:	b5a9                	j	800240 <vprintfmt+0x78>
            goto reswitch;
  8003f8:	00144603          	lbu	a2,1(s0)
            padc = '0';
  8003fc:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  800400:	846a                	mv	s0,s10
            goto reswitch;
  800402:	bd3d                	j	800240 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800404:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800408:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80040c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80040e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800412:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800416:	fcd56ce3          	bltu	a0,a3,8003ee <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  80041a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80041c:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800420:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800424:	0196873b          	addw	a4,a3,s9
  800428:	0017171b          	slliw	a4,a4,0x1
  80042c:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800430:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800434:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800438:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80043c:	fcd57fe3          	bleu	a3,a0,80041a <vprintfmt+0x252>
  800440:	b77d                	j	8003ee <vprintfmt+0x226>
            if (width < 0)
  800442:	fffdc693          	not	a3,s11
  800446:	96fd                	srai	a3,a3,0x3f
  800448:	00ddfdb3          	and	s11,s11,a3
  80044c:	00144603          	lbu	a2,1(s0)
  800450:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800452:	846a                	mv	s0,s10
  800454:	b3f5                	j	800240 <vprintfmt+0x78>
            putch('%', putdat);
  800456:	85a6                	mv	a1,s1
  800458:	02500513          	li	a0,37
  80045c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80045e:	fff44703          	lbu	a4,-1(s0)
  800462:	02500793          	li	a5,37
  800466:	8d22                	mv	s10,s0
  800468:	d8f70de3          	beq	a4,a5,800202 <vprintfmt+0x3a>
  80046c:	02500713          	li	a4,37
  800470:	1d7d                	addi	s10,s10,-1
  800472:	fffd4783          	lbu	a5,-1(s10)
  800476:	fee79de3          	bne	a5,a4,800470 <vprintfmt+0x2a8>
  80047a:	b361                	j	800202 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80047c:	00000617          	auipc	a2,0x0
  800480:	4ec60613          	addi	a2,a2,1260 # 800968 <error_string+0x1a8>
  800484:	85a6                	mv	a1,s1
  800486:	854a                	mv	a0,s2
  800488:	0ac000ef          	jal	ra,800534 <printfmt>
  80048c:	bb9d                	j	800202 <vprintfmt+0x3a>
                p = "(null)";
  80048e:	00000617          	auipc	a2,0x0
  800492:	4d260613          	addi	a2,a2,1234 # 800960 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800496:	00000417          	auipc	s0,0x0
  80049a:	4cb40413          	addi	s0,s0,1227 # 800961 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80049e:	8532                	mv	a0,a2
  8004a0:	85e6                	mv	a1,s9
  8004a2:	e032                	sd	a2,0(sp)
  8004a4:	e43e                	sd	a5,8(sp)
  8004a6:	0ae000ef          	jal	ra,800554 <strnlen>
  8004aa:	40ad8dbb          	subw	s11,s11,a0
  8004ae:	6602                	ld	a2,0(sp)
  8004b0:	01b05d63          	blez	s11,8004ca <vprintfmt+0x302>
  8004b4:	67a2                	ld	a5,8(sp)
  8004b6:	2781                	sext.w	a5,a5
  8004b8:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004ba:	6522                	ld	a0,8(sp)
  8004bc:	85a6                	mv	a1,s1
  8004be:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c0:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004c2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c4:	6602                	ld	a2,0(sp)
  8004c6:	fe0d9ae3          	bnez	s11,8004ba <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ca:	00064783          	lbu	a5,0(a2)
  8004ce:	0007851b          	sext.w	a0,a5
  8004d2:	e8051be3          	bnez	a0,800368 <vprintfmt+0x1a0>
  8004d6:	b335                	j	800202 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  8004d8:	000aa403          	lw	s0,0(s5)
  8004dc:	bbf1                	j	8002b8 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  8004de:	000ae603          	lwu	a2,0(s5)
  8004e2:	46a9                	li	a3,10
  8004e4:	8aae                	mv	s5,a1
  8004e6:	bd89                	j	800338 <vprintfmt+0x170>
  8004e8:	000ae603          	lwu	a2,0(s5)
  8004ec:	46c1                	li	a3,16
  8004ee:	8aae                	mv	s5,a1
  8004f0:	b5a1                	j	800338 <vprintfmt+0x170>
  8004f2:	000ae603          	lwu	a2,0(s5)
  8004f6:	46a1                	li	a3,8
  8004f8:	8aae                	mv	s5,a1
  8004fa:	bd3d                	j	800338 <vprintfmt+0x170>
                    putch(ch, putdat);
  8004fc:	9902                	jalr	s2
  8004fe:	b559                	j	800384 <vprintfmt+0x1bc>
                putch('-', putdat);
  800500:	85a6                	mv	a1,s1
  800502:	02d00513          	li	a0,45
  800506:	e03e                	sd	a5,0(sp)
  800508:	9902                	jalr	s2
                num = -(long long)num;
  80050a:	8ace                	mv	s5,s3
  80050c:	40800633          	neg	a2,s0
  800510:	46a9                	li	a3,10
  800512:	6782                	ld	a5,0(sp)
  800514:	b515                	j	800338 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  800516:	01b05663          	blez	s11,800522 <vprintfmt+0x35a>
  80051a:	02d00693          	li	a3,45
  80051e:	f6d798e3          	bne	a5,a3,80048e <vprintfmt+0x2c6>
  800522:	00000417          	auipc	s0,0x0
  800526:	43f40413          	addi	s0,s0,1087 # 800961 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80052a:	02800513          	li	a0,40
  80052e:	02800793          	li	a5,40
  800532:	bd1d                	j	800368 <vprintfmt+0x1a0>

0000000000800534 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800534:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800536:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80053a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80053c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80053e:	ec06                	sd	ra,24(sp)
  800540:	f83a                	sd	a4,48(sp)
  800542:	fc3e                	sd	a5,56(sp)
  800544:	e0c2                	sd	a6,64(sp)
  800546:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800548:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80054a:	c7fff0ef          	jal	ra,8001c8 <vprintfmt>
}
  80054e:	60e2                	ld	ra,24(sp)
  800550:	6161                	addi	sp,sp,80
  800552:	8082                	ret

0000000000800554 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800554:	c185                	beqz	a1,800574 <strnlen+0x20>
  800556:	00054783          	lbu	a5,0(a0)
  80055a:	cf89                	beqz	a5,800574 <strnlen+0x20>
    size_t cnt = 0;
  80055c:	4781                	li	a5,0
  80055e:	a021                	j	800566 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800560:	00074703          	lbu	a4,0(a4)
  800564:	c711                	beqz	a4,800570 <strnlen+0x1c>
        cnt ++;
  800566:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800568:	00f50733          	add	a4,a0,a5
  80056c:	fef59ae3          	bne	a1,a5,800560 <strnlen+0xc>
    }
    return cnt;
}
  800570:	853e                	mv	a0,a5
  800572:	8082                	ret
    size_t cnt = 0;
  800574:	4781                	li	a5,0
}
  800576:	853e                	mv	a0,a5
  800578:	8082                	ret

000000000080057a <main>:
#include <stdio.h>

const int max_child = 32;

int
main(void) {
  80057a:	1101                	addi	sp,sp,-32
  80057c:	e822                	sd	s0,16(sp)
  80057e:	e426                	sd	s1,8(sp)
  800580:	ec06                	sd	ra,24(sp)
    int n, pid;
    for (n = 0; n < max_child; n ++) {
  800582:	4401                	li	s0,0
  800584:	02000493          	li	s1,32
        if ((pid = fork()) == 0) {
  800588:	bbdff0ef          	jal	ra,800144 <fork>
  80058c:	cd05                	beqz	a0,8005c4 <main+0x4a>
            cprintf("I am child %d\n", n);
            exit(0);
        }
        assert(pid > 0);
  80058e:	06a05063          	blez	a0,8005ee <main+0x74>
    for (n = 0; n < max_child; n ++) {
  800592:	2405                	addiw	s0,s0,1
  800594:	fe941ae3          	bne	s0,s1,800588 <main+0xe>
  800598:	02000413          	li	s0,32
    if (n > max_child) {
        panic("fork claimed to work %d times!\n", n);
    }

    for (; n > 0; n --) {
        if (wait() != 0) {
  80059c:	badff0ef          	jal	ra,800148 <wait>
  8005a0:	ed05                	bnez	a0,8005d8 <main+0x5e>
  8005a2:	347d                	addiw	s0,s0,-1
    for (; n > 0; n --) {
  8005a4:	fc65                	bnez	s0,80059c <main+0x22>
            panic("wait stopped early\n");
        }
    }

    if (wait() == 0) {
  8005a6:	ba3ff0ef          	jal	ra,800148 <wait>
  8005aa:	c12d                	beqz	a0,80060c <main+0x92>
        panic("wait got too many\n");
    }

    cprintf("forktest pass.\n");
  8005ac:	00000517          	auipc	a0,0x0
  8005b0:	44450513          	addi	a0,a0,1092 # 8009f0 <error_string+0x230>
  8005b4:	aedff0ef          	jal	ra,8000a0 <cprintf>
    return 0;
}
  8005b8:	60e2                	ld	ra,24(sp)
  8005ba:	6442                	ld	s0,16(sp)
  8005bc:	64a2                	ld	s1,8(sp)
  8005be:	4501                	li	a0,0
  8005c0:	6105                	addi	sp,sp,32
  8005c2:	8082                	ret
            cprintf("I am child %d\n", n);
  8005c4:	85a2                	mv	a1,s0
  8005c6:	00000517          	auipc	a0,0x0
  8005ca:	3ba50513          	addi	a0,a0,954 # 800980 <error_string+0x1c0>
  8005ce:	ad3ff0ef          	jal	ra,8000a0 <cprintf>
            exit(0);
  8005d2:	4501                	li	a0,0
  8005d4:	b5bff0ef          	jal	ra,80012e <exit>
            panic("wait stopped early\n");
  8005d8:	00000617          	auipc	a2,0x0
  8005dc:	3e860613          	addi	a2,a2,1000 # 8009c0 <error_string+0x200>
  8005e0:	45dd                	li	a1,23
  8005e2:	00000517          	auipc	a0,0x0
  8005e6:	3ce50513          	addi	a0,a0,974 # 8009b0 <error_string+0x1f0>
  8005ea:	a3dff0ef          	jal	ra,800026 <__panic>
        assert(pid > 0);
  8005ee:	00000697          	auipc	a3,0x0
  8005f2:	3a268693          	addi	a3,a3,930 # 800990 <error_string+0x1d0>
  8005f6:	00000617          	auipc	a2,0x0
  8005fa:	3a260613          	addi	a2,a2,930 # 800998 <error_string+0x1d8>
  8005fe:	45b9                	li	a1,14
  800600:	00000517          	auipc	a0,0x0
  800604:	3b050513          	addi	a0,a0,944 # 8009b0 <error_string+0x1f0>
  800608:	a1fff0ef          	jal	ra,800026 <__panic>
        panic("wait got too many\n");
  80060c:	00000617          	auipc	a2,0x0
  800610:	3cc60613          	addi	a2,a2,972 # 8009d8 <error_string+0x218>
  800614:	45f1                	li	a1,28
  800616:	00000517          	auipc	a0,0x0
  80061a:	39a50513          	addi	a0,a0,922 # 8009b0 <error_string+0x1f0>
  80061e:	a09ff0ef          	jal	ra,800026 <__panic>
