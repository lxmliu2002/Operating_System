
obj/__user_forktest.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  800020:	12e000ef          	jal	ra,80014e <umain>
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
  800038:	5ec50513          	addi	a0,a0,1516 # 800620 <main+0xa8>
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
  800058:	5ec50513          	addi	a0,a0,1516 # 800640 <main+0xc8>
  80005c:	044000ef          	jal	ra,8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800060:	5559                	li	a0,-10
  800062:	0ca000ef          	jal	ra,80012c <exit>

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
  80006e:	0b6000ef          	jal	ra,800124 <sys_putc>
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
  800094:	132000ef          	jal	ra,8001c6 <vprintfmt>
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
  8000c8:	0fe000ef          	jal	ra,8001c6 <vprintfmt>
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
  8000f4:	4522                	lw	a0,8(sp)
  8000f6:	55a2                	lw	a1,40(sp)
  8000f8:	5642                	lw	a2,48(sp)
  8000fa:	56e2                	lw	a3,56(sp)
  8000fc:	4706                	lw	a4,64(sp)
  8000fe:	47a6                	lw	a5,72(sp)
  800100:	00000073          	ecall
  800104:	ce2a                	sw	a0,28(sp)
          "m" (a[3]),
          "m" (a[4])
        : "memory"
      );
    return ret;
}
  800106:	4572                	lw	a0,28(sp)
  800108:	6149                	addi	sp,sp,144
  80010a:	8082                	ret

000000000080010c <sys_exit>:

int
sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
  80010c:	85aa                	mv	a1,a0
  80010e:	4505                	li	a0,1
  800110:	fc5ff06f          	j	8000d4 <syscall>

0000000000800114 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  800114:	4509                	li	a0,2
  800116:	fbfff06f          	j	8000d4 <syscall>

000000000080011a <sys_wait>:
}

int
sys_wait(int64_t pid, int *store) {
    return syscall(SYS_wait, pid, store);
  80011a:	862e                	mv	a2,a1
  80011c:	85aa                	mv	a1,a0
  80011e:	450d                	li	a0,3
  800120:	fb5ff06f          	j	8000d4 <syscall>

0000000000800124 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  800124:	85aa                	mv	a1,a0
  800126:	4579                	li	a0,30
  800128:	fadff06f          	j	8000d4 <syscall>

000000000080012c <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80012c:	1141                	addi	sp,sp,-16
  80012e:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800130:	fddff0ef          	jal	ra,80010c <sys_exit>
    cprintf("BUG: exit failed.\n");
  800134:	00000517          	auipc	a0,0x0
  800138:	51450513          	addi	a0,a0,1300 # 800648 <main+0xd0>
  80013c:	f65ff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  800140:	a001                	j	800140 <exit+0x14>

0000000000800142 <fork>:
}

int
fork(void) {
    return sys_fork();
  800142:	fd3ff06f          	j	800114 <sys_fork>

0000000000800146 <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  800146:	4581                	li	a1,0
  800148:	4501                	li	a0,0
  80014a:	fd1ff06f          	j	80011a <sys_wait>

000000000080014e <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80014e:	1141                	addi	sp,sp,-16
  800150:	e406                	sd	ra,8(sp)
    int ret = main();
  800152:	426000ef          	jal	ra,800578 <main>
    exit(ret);
  800156:	fd7ff0ef          	jal	ra,80012c <exit>

000000000080015a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80015a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80015e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800160:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800164:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800166:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80016a:	f022                	sd	s0,32(sp)
  80016c:	ec26                	sd	s1,24(sp)
  80016e:	e84a                	sd	s2,16(sp)
  800170:	f406                	sd	ra,40(sp)
  800172:	e44e                	sd	s3,8(sp)
  800174:	84aa                	mv	s1,a0
  800176:	892e                	mv	s2,a1
  800178:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80017c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  80017e:	03067e63          	bleu	a6,a2,8001ba <printnum+0x60>
  800182:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800184:	00805763          	blez	s0,800192 <printnum+0x38>
  800188:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80018a:	85ca                	mv	a1,s2
  80018c:	854e                	mv	a0,s3
  80018e:	9482                	jalr	s1
        while (-- width > 0)
  800190:	fc65                	bnez	s0,800188 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800192:	1a02                	slli	s4,s4,0x20
  800194:	020a5a13          	srli	s4,s4,0x20
  800198:	00000797          	auipc	a5,0x0
  80019c:	6e878793          	addi	a5,a5,1768 # 800880 <error_string+0xc8>
  8001a0:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001a2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a4:	000a4503          	lbu	a0,0(s4)
}
  8001a8:	70a2                	ld	ra,40(sp)
  8001aa:	69a2                	ld	s3,8(sp)
  8001ac:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ae:	85ca                	mv	a1,s2
  8001b0:	8326                	mv	t1,s1
}
  8001b2:	6942                	ld	s2,16(sp)
  8001b4:	64e2                	ld	s1,24(sp)
  8001b6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001b8:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001ba:	03065633          	divu	a2,a2,a6
  8001be:	8722                	mv	a4,s0
  8001c0:	f9bff0ef          	jal	ra,80015a <printnum>
  8001c4:	b7f9                	j	800192 <printnum+0x38>

00000000008001c6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001c6:	7119                	addi	sp,sp,-128
  8001c8:	f4a6                	sd	s1,104(sp)
  8001ca:	f0ca                	sd	s2,96(sp)
  8001cc:	e8d2                	sd	s4,80(sp)
  8001ce:	e4d6                	sd	s5,72(sp)
  8001d0:	e0da                	sd	s6,64(sp)
  8001d2:	fc5e                	sd	s7,56(sp)
  8001d4:	f862                	sd	s8,48(sp)
  8001d6:	f06a                	sd	s10,32(sp)
  8001d8:	fc86                	sd	ra,120(sp)
  8001da:	f8a2                	sd	s0,112(sp)
  8001dc:	ecce                	sd	s3,88(sp)
  8001de:	f466                	sd	s9,40(sp)
  8001e0:	ec6e                	sd	s11,24(sp)
  8001e2:	892a                	mv	s2,a0
  8001e4:	84ae                	mv	s1,a1
  8001e6:	8d32                	mv	s10,a2
  8001e8:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001ea:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001ec:	00000a17          	auipc	s4,0x0
  8001f0:	470a0a13          	addi	s4,s4,1136 # 80065c <main+0xe4>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  8001f4:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001f8:	00000c17          	auipc	s8,0x0
  8001fc:	5c0c0c13          	addi	s8,s8,1472 # 8007b8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800200:	000d4503          	lbu	a0,0(s10)
  800204:	02500793          	li	a5,37
  800208:	001d0413          	addi	s0,s10,1
  80020c:	00f50e63          	beq	a0,a5,800228 <vprintfmt+0x62>
            if (ch == '\0') {
  800210:	c521                	beqz	a0,800258 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800212:	02500993          	li	s3,37
  800216:	a011                	j	80021a <vprintfmt+0x54>
            if (ch == '\0') {
  800218:	c121                	beqz	a0,800258 <vprintfmt+0x92>
            putch(ch, putdat);
  80021a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80021e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800220:	fff44503          	lbu	a0,-1(s0)
  800224:	ff351ae3          	bne	a0,s3,800218 <vprintfmt+0x52>
  800228:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80022c:	02000793          	li	a5,32
        lflag = altflag = 0;
  800230:	4981                	li	s3,0
  800232:	4801                	li	a6,0
        width = precision = -1;
  800234:	5cfd                	li	s9,-1
  800236:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800238:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  80023c:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  80023e:	fdd6069b          	addiw	a3,a2,-35
  800242:	0ff6f693          	andi	a3,a3,255
  800246:	00140d13          	addi	s10,s0,1
  80024a:	20d5e563          	bltu	a1,a3,800454 <vprintfmt+0x28e>
  80024e:	068a                	slli	a3,a3,0x2
  800250:	96d2                	add	a3,a3,s4
  800252:	4294                	lw	a3,0(a3)
  800254:	96d2                	add	a3,a3,s4
  800256:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800258:	70e6                	ld	ra,120(sp)
  80025a:	7446                	ld	s0,112(sp)
  80025c:	74a6                	ld	s1,104(sp)
  80025e:	7906                	ld	s2,96(sp)
  800260:	69e6                	ld	s3,88(sp)
  800262:	6a46                	ld	s4,80(sp)
  800264:	6aa6                	ld	s5,72(sp)
  800266:	6b06                	ld	s6,64(sp)
  800268:	7be2                	ld	s7,56(sp)
  80026a:	7c42                	ld	s8,48(sp)
  80026c:	7ca2                	ld	s9,40(sp)
  80026e:	7d02                	ld	s10,32(sp)
  800270:	6de2                	ld	s11,24(sp)
  800272:	6109                	addi	sp,sp,128
  800274:	8082                	ret
    if (lflag >= 2) {
  800276:	4705                	li	a4,1
  800278:	008a8593          	addi	a1,s5,8
  80027c:	01074463          	blt	a4,a6,800284 <vprintfmt+0xbe>
    else if (lflag) {
  800280:	26080363          	beqz	a6,8004e6 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  800284:	000ab603          	ld	a2,0(s5)
  800288:	46c1                	li	a3,16
  80028a:	8aae                	mv	s5,a1
  80028c:	a06d                	j	800336 <vprintfmt+0x170>
            goto reswitch;
  80028e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800292:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800294:	846a                	mv	s0,s10
            goto reswitch;
  800296:	b765                	j	80023e <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  800298:	000aa503          	lw	a0,0(s5)
  80029c:	85a6                	mv	a1,s1
  80029e:	0aa1                	addi	s5,s5,8
  8002a0:	9902                	jalr	s2
            break;
  8002a2:	bfb9                	j	800200 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002a4:	4705                	li	a4,1
  8002a6:	008a8993          	addi	s3,s5,8
  8002aa:	01074463          	blt	a4,a6,8002b2 <vprintfmt+0xec>
    else if (lflag) {
  8002ae:	22080463          	beqz	a6,8004d6 <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002b2:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002b6:	24044463          	bltz	s0,8004fe <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002ba:	8622                	mv	a2,s0
  8002bc:	8ace                	mv	s5,s3
  8002be:	46a9                	li	a3,10
  8002c0:	a89d                	j	800336 <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002c2:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002c6:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002c8:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002ca:	41f7d69b          	sraiw	a3,a5,0x1f
  8002ce:	8fb5                	xor	a5,a5,a3
  8002d0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002d4:	1ad74363          	blt	a4,a3,80047a <vprintfmt+0x2b4>
  8002d8:	00369793          	slli	a5,a3,0x3
  8002dc:	97e2                	add	a5,a5,s8
  8002de:	639c                	ld	a5,0(a5)
  8002e0:	18078d63          	beqz	a5,80047a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  8002e4:	86be                	mv	a3,a5
  8002e6:	00000617          	auipc	a2,0x0
  8002ea:	68a60613          	addi	a2,a2,1674 # 800970 <error_string+0x1b8>
  8002ee:	85a6                	mv	a1,s1
  8002f0:	854a                	mv	a0,s2
  8002f2:	240000ef          	jal	ra,800532 <printfmt>
  8002f6:	b729                	j	800200 <vprintfmt+0x3a>
            lflag ++;
  8002f8:	00144603          	lbu	a2,1(s0)
  8002fc:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002fe:	846a                	mv	s0,s10
            goto reswitch;
  800300:	bf3d                	j	80023e <vprintfmt+0x78>
    if (lflag >= 2) {
  800302:	4705                	li	a4,1
  800304:	008a8593          	addi	a1,s5,8
  800308:	01074463          	blt	a4,a6,800310 <vprintfmt+0x14a>
    else if (lflag) {
  80030c:	1e080263          	beqz	a6,8004f0 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  800310:	000ab603          	ld	a2,0(s5)
  800314:	46a1                	li	a3,8
  800316:	8aae                	mv	s5,a1
  800318:	a839                	j	800336 <vprintfmt+0x170>
            putch('0', putdat);
  80031a:	03000513          	li	a0,48
  80031e:	85a6                	mv	a1,s1
  800320:	e03e                	sd	a5,0(sp)
  800322:	9902                	jalr	s2
            putch('x', putdat);
  800324:	85a6                	mv	a1,s1
  800326:	07800513          	li	a0,120
  80032a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80032c:	0aa1                	addi	s5,s5,8
  80032e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800332:	6782                	ld	a5,0(sp)
  800334:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800336:	876e                	mv	a4,s11
  800338:	85a6                	mv	a1,s1
  80033a:	854a                	mv	a0,s2
  80033c:	e1fff0ef          	jal	ra,80015a <printnum>
            break;
  800340:	b5c1                	j	800200 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800342:	000ab603          	ld	a2,0(s5)
  800346:	0aa1                	addi	s5,s5,8
  800348:	1c060663          	beqz	a2,800514 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  80034c:	00160413          	addi	s0,a2,1
  800350:	17b05c63          	blez	s11,8004c8 <vprintfmt+0x302>
  800354:	02d00593          	li	a1,45
  800358:	14b79263          	bne	a5,a1,80049c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80035c:	00064783          	lbu	a5,0(a2)
  800360:	0007851b          	sext.w	a0,a5
  800364:	c905                	beqz	a0,800394 <vprintfmt+0x1ce>
  800366:	000cc563          	bltz	s9,800370 <vprintfmt+0x1aa>
  80036a:	3cfd                	addiw	s9,s9,-1
  80036c:	036c8263          	beq	s9,s6,800390 <vprintfmt+0x1ca>
                    putch('?', putdat);
  800370:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800372:	18098463          	beqz	s3,8004fa <vprintfmt+0x334>
  800376:	3781                	addiw	a5,a5,-32
  800378:	18fbf163          	bleu	a5,s7,8004fa <vprintfmt+0x334>
                    putch('?', putdat);
  80037c:	03f00513          	li	a0,63
  800380:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800382:	0405                	addi	s0,s0,1
  800384:	fff44783          	lbu	a5,-1(s0)
  800388:	3dfd                	addiw	s11,s11,-1
  80038a:	0007851b          	sext.w	a0,a5
  80038e:	fd61                	bnez	a0,800366 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  800390:	e7b058e3          	blez	s11,800200 <vprintfmt+0x3a>
  800394:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800396:	85a6                	mv	a1,s1
  800398:	02000513          	li	a0,32
  80039c:	9902                	jalr	s2
            for (; width > 0; width --) {
  80039e:	e60d81e3          	beqz	s11,800200 <vprintfmt+0x3a>
  8003a2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003a4:	85a6                	mv	a1,s1
  8003a6:	02000513          	li	a0,32
  8003aa:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ac:	fe0d94e3          	bnez	s11,800394 <vprintfmt+0x1ce>
  8003b0:	bd81                	j	800200 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003b2:	4705                	li	a4,1
  8003b4:	008a8593          	addi	a1,s5,8
  8003b8:	01074463          	blt	a4,a6,8003c0 <vprintfmt+0x1fa>
    else if (lflag) {
  8003bc:	12080063          	beqz	a6,8004dc <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003c0:	000ab603          	ld	a2,0(s5)
  8003c4:	46a9                	li	a3,10
  8003c6:	8aae                	mv	s5,a1
  8003c8:	b7bd                	j	800336 <vprintfmt+0x170>
  8003ca:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003ce:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  8003d2:	846a                	mv	s0,s10
  8003d4:	b5ad                	j	80023e <vprintfmt+0x78>
            putch(ch, putdat);
  8003d6:	85a6                	mv	a1,s1
  8003d8:	02500513          	li	a0,37
  8003dc:	9902                	jalr	s2
            break;
  8003de:	b50d                	j	800200 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  8003e0:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8003e4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8003e8:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8003ea:	846a                	mv	s0,s10
            if (width < 0)
  8003ec:	e40dd9e3          	bgez	s11,80023e <vprintfmt+0x78>
                width = precision, precision = -1;
  8003f0:	8de6                	mv	s11,s9
  8003f2:	5cfd                	li	s9,-1
  8003f4:	b5a9                	j	80023e <vprintfmt+0x78>
            goto reswitch;
  8003f6:	00144603          	lbu	a2,1(s0)
            padc = '0';
  8003fa:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  8003fe:	846a                	mv	s0,s10
            goto reswitch;
  800400:	bd3d                	j	80023e <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800402:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800406:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80040a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80040c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800410:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800414:	fcd56ce3          	bltu	a0,a3,8003ec <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  800418:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80041a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  80041e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800422:	0196873b          	addw	a4,a3,s9
  800426:	0017171b          	slliw	a4,a4,0x1
  80042a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  80042e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800432:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800436:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80043a:	fcd57fe3          	bleu	a3,a0,800418 <vprintfmt+0x252>
  80043e:	b77d                	j	8003ec <vprintfmt+0x226>
            if (width < 0)
  800440:	fffdc693          	not	a3,s11
  800444:	96fd                	srai	a3,a3,0x3f
  800446:	00ddfdb3          	and	s11,s11,a3
  80044a:	00144603          	lbu	a2,1(s0)
  80044e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800450:	846a                	mv	s0,s10
  800452:	b3f5                	j	80023e <vprintfmt+0x78>
            putch('%', putdat);
  800454:	85a6                	mv	a1,s1
  800456:	02500513          	li	a0,37
  80045a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80045c:	fff44703          	lbu	a4,-1(s0)
  800460:	02500793          	li	a5,37
  800464:	8d22                	mv	s10,s0
  800466:	d8f70de3          	beq	a4,a5,800200 <vprintfmt+0x3a>
  80046a:	02500713          	li	a4,37
  80046e:	1d7d                	addi	s10,s10,-1
  800470:	fffd4783          	lbu	a5,-1(s10)
  800474:	fee79de3          	bne	a5,a4,80046e <vprintfmt+0x2a8>
  800478:	b361                	j	800200 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80047a:	00000617          	auipc	a2,0x0
  80047e:	4e660613          	addi	a2,a2,1254 # 800960 <error_string+0x1a8>
  800482:	85a6                	mv	a1,s1
  800484:	854a                	mv	a0,s2
  800486:	0ac000ef          	jal	ra,800532 <printfmt>
  80048a:	bb9d                	j	800200 <vprintfmt+0x3a>
                p = "(null)";
  80048c:	00000617          	auipc	a2,0x0
  800490:	4cc60613          	addi	a2,a2,1228 # 800958 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800494:	00000417          	auipc	s0,0x0
  800498:	4c540413          	addi	s0,s0,1221 # 800959 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80049c:	8532                	mv	a0,a2
  80049e:	85e6                	mv	a1,s9
  8004a0:	e032                	sd	a2,0(sp)
  8004a2:	e43e                	sd	a5,8(sp)
  8004a4:	0ae000ef          	jal	ra,800552 <strnlen>
  8004a8:	40ad8dbb          	subw	s11,s11,a0
  8004ac:	6602                	ld	a2,0(sp)
  8004ae:	01b05d63          	blez	s11,8004c8 <vprintfmt+0x302>
  8004b2:	67a2                	ld	a5,8(sp)
  8004b4:	2781                	sext.w	a5,a5
  8004b6:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004b8:	6522                	ld	a0,8(sp)
  8004ba:	85a6                	mv	a1,s1
  8004bc:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004be:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004c0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c2:	6602                	ld	a2,0(sp)
  8004c4:	fe0d9ae3          	bnez	s11,8004b8 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004c8:	00064783          	lbu	a5,0(a2)
  8004cc:	0007851b          	sext.w	a0,a5
  8004d0:	e8051be3          	bnez	a0,800366 <vprintfmt+0x1a0>
  8004d4:	b335                	j	800200 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  8004d6:	000aa403          	lw	s0,0(s5)
  8004da:	bbf1                	j	8002b6 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  8004dc:	000ae603          	lwu	a2,0(s5)
  8004e0:	46a9                	li	a3,10
  8004e2:	8aae                	mv	s5,a1
  8004e4:	bd89                	j	800336 <vprintfmt+0x170>
  8004e6:	000ae603          	lwu	a2,0(s5)
  8004ea:	46c1                	li	a3,16
  8004ec:	8aae                	mv	s5,a1
  8004ee:	b5a1                	j	800336 <vprintfmt+0x170>
  8004f0:	000ae603          	lwu	a2,0(s5)
  8004f4:	46a1                	li	a3,8
  8004f6:	8aae                	mv	s5,a1
  8004f8:	bd3d                	j	800336 <vprintfmt+0x170>
                    putch(ch, putdat);
  8004fa:	9902                	jalr	s2
  8004fc:	b559                	j	800382 <vprintfmt+0x1bc>
                putch('-', putdat);
  8004fe:	85a6                	mv	a1,s1
  800500:	02d00513          	li	a0,45
  800504:	e03e                	sd	a5,0(sp)
  800506:	9902                	jalr	s2
                num = -(long long)num;
  800508:	8ace                	mv	s5,s3
  80050a:	40800633          	neg	a2,s0
  80050e:	46a9                	li	a3,10
  800510:	6782                	ld	a5,0(sp)
  800512:	b515                	j	800336 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  800514:	01b05663          	blez	s11,800520 <vprintfmt+0x35a>
  800518:	02d00693          	li	a3,45
  80051c:	f6d798e3          	bne	a5,a3,80048c <vprintfmt+0x2c6>
  800520:	00000417          	auipc	s0,0x0
  800524:	43940413          	addi	s0,s0,1081 # 800959 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800528:	02800513          	li	a0,40
  80052c:	02800793          	li	a5,40
  800530:	bd1d                	j	800366 <vprintfmt+0x1a0>

0000000000800532 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800532:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800534:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800538:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80053a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80053c:	ec06                	sd	ra,24(sp)
  80053e:	f83a                	sd	a4,48(sp)
  800540:	fc3e                	sd	a5,56(sp)
  800542:	e0c2                	sd	a6,64(sp)
  800544:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800546:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800548:	c7fff0ef          	jal	ra,8001c6 <vprintfmt>
}
  80054c:	60e2                	ld	ra,24(sp)
  80054e:	6161                	addi	sp,sp,80
  800550:	8082                	ret

0000000000800552 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800552:	c185                	beqz	a1,800572 <strnlen+0x20>
  800554:	00054783          	lbu	a5,0(a0)
  800558:	cf89                	beqz	a5,800572 <strnlen+0x20>
    size_t cnt = 0;
  80055a:	4781                	li	a5,0
  80055c:	a021                	j	800564 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  80055e:	00074703          	lbu	a4,0(a4)
  800562:	c711                	beqz	a4,80056e <strnlen+0x1c>
        cnt ++;
  800564:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800566:	00f50733          	add	a4,a0,a5
  80056a:	fef59ae3          	bne	a1,a5,80055e <strnlen+0xc>
    }
    return cnt;
}
  80056e:	853e                	mv	a0,a5
  800570:	8082                	ret
    size_t cnt = 0;
  800572:	4781                	li	a5,0
}
  800574:	853e                	mv	a0,a5
  800576:	8082                	ret

0000000000800578 <main>:
#include <stdio.h>

const int max_child = 32;

int
main(void) {
  800578:	1101                	addi	sp,sp,-32
  80057a:	e822                	sd	s0,16(sp)
  80057c:	e426                	sd	s1,8(sp)
  80057e:	ec06                	sd	ra,24(sp)
    int n, pid;
    for (n = 0; n < max_child; n ++) {
  800580:	4401                	li	s0,0
  800582:	02000493          	li	s1,32
        if ((pid = fork()) == 0) {
  800586:	bbdff0ef          	jal	ra,800142 <fork>
  80058a:	cd05                	beqz	a0,8005c2 <main+0x4a>
            cprintf("I am child %d\n", n);
            exit(0);
        }
        assert(pid > 0);
  80058c:	06a05063          	blez	a0,8005ec <main+0x74>
    for (n = 0; n < max_child; n ++) {
  800590:	2405                	addiw	s0,s0,1
  800592:	fe941ae3          	bne	s0,s1,800586 <main+0xe>
  800596:	02000413          	li	s0,32
    if (n > max_child) {
        panic("fork claimed to work %d times!\n", n);
    }

    for (; n > 0; n --) {
        if (wait() != 0) {
  80059a:	badff0ef          	jal	ra,800146 <wait>
  80059e:	ed05                	bnez	a0,8005d6 <main+0x5e>
  8005a0:	347d                	addiw	s0,s0,-1
    for (; n > 0; n --) {
  8005a2:	fc65                	bnez	s0,80059a <main+0x22>
            panic("wait stopped early\n");
        }
    }

    if (wait() == 0) {
  8005a4:	ba3ff0ef          	jal	ra,800146 <wait>
  8005a8:	c12d                	beqz	a0,80060a <main+0x92>
        panic("wait got too many\n");
    }

    cprintf("forktest pass.\n");
  8005aa:	00000517          	auipc	a0,0x0
  8005ae:	43e50513          	addi	a0,a0,1086 # 8009e8 <error_string+0x230>
  8005b2:	aefff0ef          	jal	ra,8000a0 <cprintf>
    return 0;
}
  8005b6:	60e2                	ld	ra,24(sp)
  8005b8:	6442                	ld	s0,16(sp)
  8005ba:	64a2                	ld	s1,8(sp)
  8005bc:	4501                	li	a0,0
  8005be:	6105                	addi	sp,sp,32
  8005c0:	8082                	ret
            cprintf("I am child %d\n", n);
  8005c2:	85a2                	mv	a1,s0
  8005c4:	00000517          	auipc	a0,0x0
  8005c8:	3b450513          	addi	a0,a0,948 # 800978 <error_string+0x1c0>
  8005cc:	ad5ff0ef          	jal	ra,8000a0 <cprintf>
            exit(0);
  8005d0:	4501                	li	a0,0
  8005d2:	b5bff0ef          	jal	ra,80012c <exit>
            panic("wait stopped early\n");
  8005d6:	00000617          	auipc	a2,0x0
  8005da:	3e260613          	addi	a2,a2,994 # 8009b8 <error_string+0x200>
  8005de:	45dd                	li	a1,23
  8005e0:	00000517          	auipc	a0,0x0
  8005e4:	3c850513          	addi	a0,a0,968 # 8009a8 <error_string+0x1f0>
  8005e8:	a3fff0ef          	jal	ra,800026 <__panic>
        assert(pid > 0);
  8005ec:	00000697          	auipc	a3,0x0
  8005f0:	39c68693          	addi	a3,a3,924 # 800988 <error_string+0x1d0>
  8005f4:	00000617          	auipc	a2,0x0
  8005f8:	39c60613          	addi	a2,a2,924 # 800990 <error_string+0x1d8>
  8005fc:	45b9                	li	a1,14
  8005fe:	00000517          	auipc	a0,0x0
  800602:	3aa50513          	addi	a0,a0,938 # 8009a8 <error_string+0x1f0>
  800606:	a21ff0ef          	jal	ra,800026 <__panic>
        panic("wait got too many\n");
  80060a:	00000617          	auipc	a2,0x0
  80060e:	3c660613          	addi	a2,a2,966 # 8009d0 <error_string+0x218>
  800612:	45f1                	li	a1,28
  800614:	00000517          	auipc	a0,0x0
  800618:	39450513          	addi	a0,a0,916 # 8009a8 <error_string+0x1f0>
  80061c:	a0bff0ef          	jal	ra,800026 <__panic>
