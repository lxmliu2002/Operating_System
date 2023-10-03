
obj/__user_badarg.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	136000ef          	jal	ra,800156 <umain>
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
  800038:	63c50513          	addi	a0,a0,1596 # 800670 <main+0xf0>
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
  800058:	97450513          	addi	a0,a0,-1676 # 8009c8 <error_string+0x1c8>
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
  800094:	13a000ef          	jal	ra,8001ce <vprintfmt>
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
  8000c8:	106000ef          	jal	ra,8001ce <vprintfmt>
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
  800140:	55450513          	addi	a0,a0,1364 # 800690 <main+0x110>
  800144:	f5dff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  800148:	a001                	j	800148 <exit+0x14>

000000000080014a <fork>:
}

int
fork(void) {
    return sys_fork();
  80014a:	fcdff06f          	j	800116 <sys_fork>

000000000080014e <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  80014e:	fcfff06f          	j	80011c <sys_wait>

0000000000800152 <yield>:
}

void
yield(void) {
    sys_yield();
  800152:	fd5ff06f          	j	800126 <sys_yield>

0000000000800156 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800156:	1141                	addi	sp,sp,-16
  800158:	e406                	sd	ra,8(sp)
    int ret = main();
  80015a:	426000ef          	jal	ra,800580 <main>
    exit(ret);
  80015e:	fd7ff0ef          	jal	ra,800134 <exit>

0000000000800162 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800162:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800166:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800168:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80016c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80016e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800172:	f022                	sd	s0,32(sp)
  800174:	ec26                	sd	s1,24(sp)
  800176:	e84a                	sd	s2,16(sp)
  800178:	f406                	sd	ra,40(sp)
  80017a:	e44e                	sd	s3,8(sp)
  80017c:	84aa                	mv	s1,a0
  80017e:	892e                	mv	s2,a1
  800180:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800184:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800186:	03067e63          	bleu	a6,a2,8001c2 <printnum+0x60>
  80018a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80018c:	00805763          	blez	s0,80019a <printnum+0x38>
  800190:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800192:	85ca                	mv	a1,s2
  800194:	854e                	mv	a0,s3
  800196:	9482                	jalr	s1
        while (-- width > 0)
  800198:	fc65                	bnez	s0,800190 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80019a:	1a02                	slli	s4,s4,0x20
  80019c:	020a5a13          	srli	s4,s4,0x20
  8001a0:	00000797          	auipc	a5,0x0
  8001a4:	72878793          	addi	a5,a5,1832 # 8008c8 <error_string+0xc8>
  8001a8:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001aa:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ac:	000a4503          	lbu	a0,0(s4)
}
  8001b0:	70a2                	ld	ra,40(sp)
  8001b2:	69a2                	ld	s3,8(sp)
  8001b4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b6:	85ca                	mv	a1,s2
  8001b8:	8326                	mv	t1,s1
}
  8001ba:	6942                	ld	s2,16(sp)
  8001bc:	64e2                	ld	s1,24(sp)
  8001be:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001c0:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001c2:	03065633          	divu	a2,a2,a6
  8001c6:	8722                	mv	a4,s0
  8001c8:	f9bff0ef          	jal	ra,800162 <printnum>
  8001cc:	b7f9                	j	80019a <printnum+0x38>

00000000008001ce <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001ce:	7119                	addi	sp,sp,-128
  8001d0:	f4a6                	sd	s1,104(sp)
  8001d2:	f0ca                	sd	s2,96(sp)
  8001d4:	e8d2                	sd	s4,80(sp)
  8001d6:	e4d6                	sd	s5,72(sp)
  8001d8:	e0da                	sd	s6,64(sp)
  8001da:	fc5e                	sd	s7,56(sp)
  8001dc:	f862                	sd	s8,48(sp)
  8001de:	f06a                	sd	s10,32(sp)
  8001e0:	fc86                	sd	ra,120(sp)
  8001e2:	f8a2                	sd	s0,112(sp)
  8001e4:	ecce                	sd	s3,88(sp)
  8001e6:	f466                	sd	s9,40(sp)
  8001e8:	ec6e                	sd	s11,24(sp)
  8001ea:	892a                	mv	s2,a0
  8001ec:	84ae                	mv	s1,a1
  8001ee:	8d32                	mv	s10,a2
  8001f0:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001f2:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001f4:	00000a17          	auipc	s4,0x0
  8001f8:	4b0a0a13          	addi	s4,s4,1200 # 8006a4 <main+0x124>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  8001fc:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800200:	00000c17          	auipc	s8,0x0
  800204:	600c0c13          	addi	s8,s8,1536 # 800800 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800208:	000d4503          	lbu	a0,0(s10)
  80020c:	02500793          	li	a5,37
  800210:	001d0413          	addi	s0,s10,1
  800214:	00f50e63          	beq	a0,a5,800230 <vprintfmt+0x62>
            if (ch == '\0') {
  800218:	c521                	beqz	a0,800260 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021a:	02500993          	li	s3,37
  80021e:	a011                	j	800222 <vprintfmt+0x54>
            if (ch == '\0') {
  800220:	c121                	beqz	a0,800260 <vprintfmt+0x92>
            putch(ch, putdat);
  800222:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800224:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800226:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800228:	fff44503          	lbu	a0,-1(s0)
  80022c:	ff351ae3          	bne	a0,s3,800220 <vprintfmt+0x52>
  800230:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800234:	02000793          	li	a5,32
        lflag = altflag = 0;
  800238:	4981                	li	s3,0
  80023a:	4801                	li	a6,0
        width = precision = -1;
  80023c:	5cfd                	li	s9,-1
  80023e:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800240:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800244:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800246:	fdd6069b          	addiw	a3,a2,-35
  80024a:	0ff6f693          	andi	a3,a3,255
  80024e:	00140d13          	addi	s10,s0,1
  800252:	20d5e563          	bltu	a1,a3,80045c <vprintfmt+0x28e>
  800256:	068a                	slli	a3,a3,0x2
  800258:	96d2                	add	a3,a3,s4
  80025a:	4294                	lw	a3,0(a3)
  80025c:	96d2                	add	a3,a3,s4
  80025e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800260:	70e6                	ld	ra,120(sp)
  800262:	7446                	ld	s0,112(sp)
  800264:	74a6                	ld	s1,104(sp)
  800266:	7906                	ld	s2,96(sp)
  800268:	69e6                	ld	s3,88(sp)
  80026a:	6a46                	ld	s4,80(sp)
  80026c:	6aa6                	ld	s5,72(sp)
  80026e:	6b06                	ld	s6,64(sp)
  800270:	7be2                	ld	s7,56(sp)
  800272:	7c42                	ld	s8,48(sp)
  800274:	7ca2                	ld	s9,40(sp)
  800276:	7d02                	ld	s10,32(sp)
  800278:	6de2                	ld	s11,24(sp)
  80027a:	6109                	addi	sp,sp,128
  80027c:	8082                	ret
    if (lflag >= 2) {
  80027e:	4705                	li	a4,1
  800280:	008a8593          	addi	a1,s5,8
  800284:	01074463          	blt	a4,a6,80028c <vprintfmt+0xbe>
    else if (lflag) {
  800288:	26080363          	beqz	a6,8004ee <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  80028c:	000ab603          	ld	a2,0(s5)
  800290:	46c1                	li	a3,16
  800292:	8aae                	mv	s5,a1
  800294:	a06d                	j	80033e <vprintfmt+0x170>
            goto reswitch;
  800296:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  80029a:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  80029c:	846a                	mv	s0,s10
            goto reswitch;
  80029e:	b765                	j	800246 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  8002a0:	000aa503          	lw	a0,0(s5)
  8002a4:	85a6                	mv	a1,s1
  8002a6:	0aa1                	addi	s5,s5,8
  8002a8:	9902                	jalr	s2
            break;
  8002aa:	bfb9                	j	800208 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002ac:	4705                	li	a4,1
  8002ae:	008a8993          	addi	s3,s5,8
  8002b2:	01074463          	blt	a4,a6,8002ba <vprintfmt+0xec>
    else if (lflag) {
  8002b6:	22080463          	beqz	a6,8004de <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002ba:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002be:	24044463          	bltz	s0,800506 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002c2:	8622                	mv	a2,s0
  8002c4:	8ace                	mv	s5,s3
  8002c6:	46a9                	li	a3,10
  8002c8:	a89d                	j	80033e <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002ca:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002ce:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002d0:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002d2:	41f7d69b          	sraiw	a3,a5,0x1f
  8002d6:	8fb5                	xor	a5,a5,a3
  8002d8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002dc:	1ad74363          	blt	a4,a3,800482 <vprintfmt+0x2b4>
  8002e0:	00369793          	slli	a5,a3,0x3
  8002e4:	97e2                	add	a5,a5,s8
  8002e6:	639c                	ld	a5,0(a5)
  8002e8:	18078d63          	beqz	a5,800482 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  8002ec:	86be                	mv	a3,a5
  8002ee:	00000617          	auipc	a2,0x0
  8002f2:	6ca60613          	addi	a2,a2,1738 # 8009b8 <error_string+0x1b8>
  8002f6:	85a6                	mv	a1,s1
  8002f8:	854a                	mv	a0,s2
  8002fa:	240000ef          	jal	ra,80053a <printfmt>
  8002fe:	b729                	j	800208 <vprintfmt+0x3a>
            lflag ++;
  800300:	00144603          	lbu	a2,1(s0)
  800304:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800306:	846a                	mv	s0,s10
            goto reswitch;
  800308:	bf3d                	j	800246 <vprintfmt+0x78>
    if (lflag >= 2) {
  80030a:	4705                	li	a4,1
  80030c:	008a8593          	addi	a1,s5,8
  800310:	01074463          	blt	a4,a6,800318 <vprintfmt+0x14a>
    else if (lflag) {
  800314:	1e080263          	beqz	a6,8004f8 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  800318:	000ab603          	ld	a2,0(s5)
  80031c:	46a1                	li	a3,8
  80031e:	8aae                	mv	s5,a1
  800320:	a839                	j	80033e <vprintfmt+0x170>
            putch('0', putdat);
  800322:	03000513          	li	a0,48
  800326:	85a6                	mv	a1,s1
  800328:	e03e                	sd	a5,0(sp)
  80032a:	9902                	jalr	s2
            putch('x', putdat);
  80032c:	85a6                	mv	a1,s1
  80032e:	07800513          	li	a0,120
  800332:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800334:	0aa1                	addi	s5,s5,8
  800336:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  80033a:	6782                	ld	a5,0(sp)
  80033c:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  80033e:	876e                	mv	a4,s11
  800340:	85a6                	mv	a1,s1
  800342:	854a                	mv	a0,s2
  800344:	e1fff0ef          	jal	ra,800162 <printnum>
            break;
  800348:	b5c1                	j	800208 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  80034a:	000ab603          	ld	a2,0(s5)
  80034e:	0aa1                	addi	s5,s5,8
  800350:	1c060663          	beqz	a2,80051c <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  800354:	00160413          	addi	s0,a2,1
  800358:	17b05c63          	blez	s11,8004d0 <vprintfmt+0x302>
  80035c:	02d00593          	li	a1,45
  800360:	14b79263          	bne	a5,a1,8004a4 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800364:	00064783          	lbu	a5,0(a2)
  800368:	0007851b          	sext.w	a0,a5
  80036c:	c905                	beqz	a0,80039c <vprintfmt+0x1ce>
  80036e:	000cc563          	bltz	s9,800378 <vprintfmt+0x1aa>
  800372:	3cfd                	addiw	s9,s9,-1
  800374:	036c8263          	beq	s9,s6,800398 <vprintfmt+0x1ca>
                    putch('?', putdat);
  800378:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80037a:	18098463          	beqz	s3,800502 <vprintfmt+0x334>
  80037e:	3781                	addiw	a5,a5,-32
  800380:	18fbf163          	bleu	a5,s7,800502 <vprintfmt+0x334>
                    putch('?', putdat);
  800384:	03f00513          	li	a0,63
  800388:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80038a:	0405                	addi	s0,s0,1
  80038c:	fff44783          	lbu	a5,-1(s0)
  800390:	3dfd                	addiw	s11,s11,-1
  800392:	0007851b          	sext.w	a0,a5
  800396:	fd61                	bnez	a0,80036e <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  800398:	e7b058e3          	blez	s11,800208 <vprintfmt+0x3a>
  80039c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80039e:	85a6                	mv	a1,s1
  8003a0:	02000513          	li	a0,32
  8003a4:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003a6:	e60d81e3          	beqz	s11,800208 <vprintfmt+0x3a>
  8003aa:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003ac:	85a6                	mv	a1,s1
  8003ae:	02000513          	li	a0,32
  8003b2:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003b4:	fe0d94e3          	bnez	s11,80039c <vprintfmt+0x1ce>
  8003b8:	bd81                	j	800208 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003ba:	4705                	li	a4,1
  8003bc:	008a8593          	addi	a1,s5,8
  8003c0:	01074463          	blt	a4,a6,8003c8 <vprintfmt+0x1fa>
    else if (lflag) {
  8003c4:	12080063          	beqz	a6,8004e4 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003c8:	000ab603          	ld	a2,0(s5)
  8003cc:	46a9                	li	a3,10
  8003ce:	8aae                	mv	s5,a1
  8003d0:	b7bd                	j	80033e <vprintfmt+0x170>
  8003d2:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003d6:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  8003da:	846a                	mv	s0,s10
  8003dc:	b5ad                	j	800246 <vprintfmt+0x78>
            putch(ch, putdat);
  8003de:	85a6                	mv	a1,s1
  8003e0:	02500513          	li	a0,37
  8003e4:	9902                	jalr	s2
            break;
  8003e6:	b50d                	j	800208 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  8003e8:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8003ec:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8003f0:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8003f2:	846a                	mv	s0,s10
            if (width < 0)
  8003f4:	e40dd9e3          	bgez	s11,800246 <vprintfmt+0x78>
                width = precision, precision = -1;
  8003f8:	8de6                	mv	s11,s9
  8003fa:	5cfd                	li	s9,-1
  8003fc:	b5a9                	j	800246 <vprintfmt+0x78>
            goto reswitch;
  8003fe:	00144603          	lbu	a2,1(s0)
            padc = '0';
  800402:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  800406:	846a                	mv	s0,s10
            goto reswitch;
  800408:	bd3d                	j	800246 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  80040a:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  80040e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800412:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800414:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800418:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80041c:	fcd56ce3          	bltu	a0,a3,8003f4 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  800420:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800422:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800426:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  80042a:	0196873b          	addw	a4,a3,s9
  80042e:	0017171b          	slliw	a4,a4,0x1
  800432:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800436:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  80043a:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80043e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800442:	fcd57fe3          	bleu	a3,a0,800420 <vprintfmt+0x252>
  800446:	b77d                	j	8003f4 <vprintfmt+0x226>
            if (width < 0)
  800448:	fffdc693          	not	a3,s11
  80044c:	96fd                	srai	a3,a3,0x3f
  80044e:	00ddfdb3          	and	s11,s11,a3
  800452:	00144603          	lbu	a2,1(s0)
  800456:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800458:	846a                	mv	s0,s10
  80045a:	b3f5                	j	800246 <vprintfmt+0x78>
            putch('%', putdat);
  80045c:	85a6                	mv	a1,s1
  80045e:	02500513          	li	a0,37
  800462:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800464:	fff44703          	lbu	a4,-1(s0)
  800468:	02500793          	li	a5,37
  80046c:	8d22                	mv	s10,s0
  80046e:	d8f70de3          	beq	a4,a5,800208 <vprintfmt+0x3a>
  800472:	02500713          	li	a4,37
  800476:	1d7d                	addi	s10,s10,-1
  800478:	fffd4783          	lbu	a5,-1(s10)
  80047c:	fee79de3          	bne	a5,a4,800476 <vprintfmt+0x2a8>
  800480:	b361                	j	800208 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800482:	00000617          	auipc	a2,0x0
  800486:	52660613          	addi	a2,a2,1318 # 8009a8 <error_string+0x1a8>
  80048a:	85a6                	mv	a1,s1
  80048c:	854a                	mv	a0,s2
  80048e:	0ac000ef          	jal	ra,80053a <printfmt>
  800492:	bb9d                	j	800208 <vprintfmt+0x3a>
                p = "(null)";
  800494:	00000617          	auipc	a2,0x0
  800498:	50c60613          	addi	a2,a2,1292 # 8009a0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  80049c:	00000417          	auipc	s0,0x0
  8004a0:	50540413          	addi	s0,s0,1285 # 8009a1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a4:	8532                	mv	a0,a2
  8004a6:	85e6                	mv	a1,s9
  8004a8:	e032                	sd	a2,0(sp)
  8004aa:	e43e                	sd	a5,8(sp)
  8004ac:	0ae000ef          	jal	ra,80055a <strnlen>
  8004b0:	40ad8dbb          	subw	s11,s11,a0
  8004b4:	6602                	ld	a2,0(sp)
  8004b6:	01b05d63          	blez	s11,8004d0 <vprintfmt+0x302>
  8004ba:	67a2                	ld	a5,8(sp)
  8004bc:	2781                	sext.w	a5,a5
  8004be:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004c0:	6522                	ld	a0,8(sp)
  8004c2:	85a6                	mv	a1,s1
  8004c4:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004c8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ca:	6602                	ld	a2,0(sp)
  8004cc:	fe0d9ae3          	bnez	s11,8004c0 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004d0:	00064783          	lbu	a5,0(a2)
  8004d4:	0007851b          	sext.w	a0,a5
  8004d8:	e8051be3          	bnez	a0,80036e <vprintfmt+0x1a0>
  8004dc:	b335                	j	800208 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  8004de:	000aa403          	lw	s0,0(s5)
  8004e2:	bbf1                	j	8002be <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  8004e4:	000ae603          	lwu	a2,0(s5)
  8004e8:	46a9                	li	a3,10
  8004ea:	8aae                	mv	s5,a1
  8004ec:	bd89                	j	80033e <vprintfmt+0x170>
  8004ee:	000ae603          	lwu	a2,0(s5)
  8004f2:	46c1                	li	a3,16
  8004f4:	8aae                	mv	s5,a1
  8004f6:	b5a1                	j	80033e <vprintfmt+0x170>
  8004f8:	000ae603          	lwu	a2,0(s5)
  8004fc:	46a1                	li	a3,8
  8004fe:	8aae                	mv	s5,a1
  800500:	bd3d                	j	80033e <vprintfmt+0x170>
                    putch(ch, putdat);
  800502:	9902                	jalr	s2
  800504:	b559                	j	80038a <vprintfmt+0x1bc>
                putch('-', putdat);
  800506:	85a6                	mv	a1,s1
  800508:	02d00513          	li	a0,45
  80050c:	e03e                	sd	a5,0(sp)
  80050e:	9902                	jalr	s2
                num = -(long long)num;
  800510:	8ace                	mv	s5,s3
  800512:	40800633          	neg	a2,s0
  800516:	46a9                	li	a3,10
  800518:	6782                	ld	a5,0(sp)
  80051a:	b515                	j	80033e <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  80051c:	01b05663          	blez	s11,800528 <vprintfmt+0x35a>
  800520:	02d00693          	li	a3,45
  800524:	f6d798e3          	bne	a5,a3,800494 <vprintfmt+0x2c6>
  800528:	00000417          	auipc	s0,0x0
  80052c:	47940413          	addi	s0,s0,1145 # 8009a1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800530:	02800513          	li	a0,40
  800534:	02800793          	li	a5,40
  800538:	bd1d                	j	80036e <vprintfmt+0x1a0>

000000000080053a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80053a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80053c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800540:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800542:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800544:	ec06                	sd	ra,24(sp)
  800546:	f83a                	sd	a4,48(sp)
  800548:	fc3e                	sd	a5,56(sp)
  80054a:	e0c2                	sd	a6,64(sp)
  80054c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80054e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800550:	c7fff0ef          	jal	ra,8001ce <vprintfmt>
}
  800554:	60e2                	ld	ra,24(sp)
  800556:	6161                	addi	sp,sp,80
  800558:	8082                	ret

000000000080055a <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  80055a:	c185                	beqz	a1,80057a <strnlen+0x20>
  80055c:	00054783          	lbu	a5,0(a0)
  800560:	cf89                	beqz	a5,80057a <strnlen+0x20>
    size_t cnt = 0;
  800562:	4781                	li	a5,0
  800564:	a021                	j	80056c <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800566:	00074703          	lbu	a4,0(a4)
  80056a:	c711                	beqz	a4,800576 <strnlen+0x1c>
        cnt ++;
  80056c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80056e:	00f50733          	add	a4,a0,a5
  800572:	fef59ae3          	bne	a1,a5,800566 <strnlen+0xc>
    }
    return cnt;
}
  800576:	853e                	mv	a0,a5
  800578:	8082                	ret
    size_t cnt = 0;
  80057a:	4781                	li	a5,0
}
  80057c:	853e                	mv	a0,a5
  80057e:	8082                	ret

0000000000800580 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  800580:	1101                	addi	sp,sp,-32
  800582:	ec06                	sd	ra,24(sp)
  800584:	e822                	sd	s0,16(sp)
    int pid, exit_code;
    if ((pid = fork()) == 0) {
  800586:	bc5ff0ef          	jal	ra,80014a <fork>
  80058a:	c169                	beqz	a0,80064c <main+0xcc>
  80058c:	842a                	mv	s0,a0
        for (i = 0; i < 10; i ++) {
            yield();
        }
        exit(0xbeaf);
    }
    assert(pid > 0);
  80058e:	0aa05063          	blez	a0,80062e <main+0xae>
    assert(waitpid(-1, NULL) != 0);
  800592:	4581                	li	a1,0
  800594:	557d                	li	a0,-1
  800596:	bb9ff0ef          	jal	ra,80014e <waitpid>
  80059a:	c93d                	beqz	a0,800610 <main+0x90>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  80059c:	458d                	li	a1,3
  80059e:	05fa                	slli	a1,a1,0x1e
  8005a0:	8522                	mv	a0,s0
  8005a2:	badff0ef          	jal	ra,80014e <waitpid>
  8005a6:	c531                	beqz	a0,8005f2 <main+0x72>
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  8005a8:	006c                	addi	a1,sp,12
  8005aa:	8522                	mv	a0,s0
  8005ac:	ba3ff0ef          	jal	ra,80014e <waitpid>
  8005b0:	e115                	bnez	a0,8005d4 <main+0x54>
  8005b2:	4732                	lw	a4,12(sp)
  8005b4:	67b1                	lui	a5,0xc
  8005b6:	eaf78793          	addi	a5,a5,-337 # beaf <_start-0x7f4171>
  8005ba:	00f71d63          	bne	a4,a5,8005d4 <main+0x54>
    cprintf("badarg pass.\n");
  8005be:	00000517          	auipc	a0,0x0
  8005c2:	4ba50513          	addi	a0,a0,1210 # 800a78 <error_string+0x278>
  8005c6:	adbff0ef          	jal	ra,8000a0 <cprintf>
    return 0;
}
  8005ca:	60e2                	ld	ra,24(sp)
  8005cc:	6442                	ld	s0,16(sp)
  8005ce:	4501                	li	a0,0
  8005d0:	6105                	addi	sp,sp,32
  8005d2:	8082                	ret
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  8005d4:	00000697          	auipc	a3,0x0
  8005d8:	46c68693          	addi	a3,a3,1132 # 800a40 <error_string+0x240>
  8005dc:	00000617          	auipc	a2,0x0
  8005e0:	3fc60613          	addi	a2,a2,1020 # 8009d8 <error_string+0x1d8>
  8005e4:	45c9                	li	a1,18
  8005e6:	00000517          	auipc	a0,0x0
  8005ea:	40a50513          	addi	a0,a0,1034 # 8009f0 <error_string+0x1f0>
  8005ee:	a39ff0ef          	jal	ra,800026 <__panic>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  8005f2:	00000697          	auipc	a3,0x0
  8005f6:	42668693          	addi	a3,a3,1062 # 800a18 <error_string+0x218>
  8005fa:	00000617          	auipc	a2,0x0
  8005fe:	3de60613          	addi	a2,a2,990 # 8009d8 <error_string+0x1d8>
  800602:	45c5                	li	a1,17
  800604:	00000517          	auipc	a0,0x0
  800608:	3ec50513          	addi	a0,a0,1004 # 8009f0 <error_string+0x1f0>
  80060c:	a1bff0ef          	jal	ra,800026 <__panic>
    assert(waitpid(-1, NULL) != 0);
  800610:	00000697          	auipc	a3,0x0
  800614:	3f068693          	addi	a3,a3,1008 # 800a00 <error_string+0x200>
  800618:	00000617          	auipc	a2,0x0
  80061c:	3c060613          	addi	a2,a2,960 # 8009d8 <error_string+0x1d8>
  800620:	45c1                	li	a1,16
  800622:	00000517          	auipc	a0,0x0
  800626:	3ce50513          	addi	a0,a0,974 # 8009f0 <error_string+0x1f0>
  80062a:	9fdff0ef          	jal	ra,800026 <__panic>
    assert(pid > 0);
  80062e:	00000697          	auipc	a3,0x0
  800632:	3a268693          	addi	a3,a3,930 # 8009d0 <error_string+0x1d0>
  800636:	00000617          	auipc	a2,0x0
  80063a:	3a260613          	addi	a2,a2,930 # 8009d8 <error_string+0x1d8>
  80063e:	45bd                	li	a1,15
  800640:	00000517          	auipc	a0,0x0
  800644:	3b050513          	addi	a0,a0,944 # 8009f0 <error_string+0x1f0>
  800648:	9dfff0ef          	jal	ra,800026 <__panic>
        cprintf("fork ok.\n");
  80064c:	00000517          	auipc	a0,0x0
  800650:	37450513          	addi	a0,a0,884 # 8009c0 <error_string+0x1c0>
  800654:	a4dff0ef          	jal	ra,8000a0 <cprintf>
  800658:	4429                	li	s0,10
            yield();
  80065a:	347d                	addiw	s0,s0,-1
  80065c:	af7ff0ef          	jal	ra,800152 <yield>
        for (i = 0; i < 10; i ++) {
  800660:	fc6d                	bnez	s0,80065a <main+0xda>
        exit(0xbeaf);
  800662:	6531                	lui	a0,0xc
  800664:	eaf50513          	addi	a0,a0,-337 # beaf <_start-0x7f4171>
  800668:	acdff0ef          	jal	ra,800134 <exit>
