
obj/__user_sleepkill.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  800020:	138000ef          	jal	ra,800158 <umain>
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
  800038:	5d450513          	addi	a0,a0,1492 # 800608 <main+0x86>
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
  800058:	5d450513          	addi	a0,a0,1492 # 800628 <main+0xa6>
  80005c:	044000ef          	jal	ra,8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800060:	5559                	li	a0,-10
  800062:	0d0000ef          	jal	ra,800132 <exit>

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
  80006e:	0b4000ef          	jal	ra,800122 <sys_putc>
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
  800094:	13c000ef          	jal	ra,8001d0 <vprintfmt>
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
  8000c8:	108000ef          	jal	ra,8001d0 <vprintfmt>
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

000000000080011a <sys_kill>:
    return syscall(SYS_yield);
}

int
sys_kill(int64_t pid) {
    return syscall(SYS_kill, pid);
  80011a:	85aa                	mv	a1,a0
  80011c:	4531                	li	a0,12
  80011e:	fb7ff06f          	j	8000d4 <syscall>

0000000000800122 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  800122:	85aa                	mv	a1,a0
  800124:	4579                	li	a0,30
  800126:	fafff06f          	j	8000d4 <syscall>

000000000080012a <sys_sleep>:
    syscall(SYS_lab6_set_priority, priority);
}

int
sys_sleep(uint64_t time) {
    return syscall(SYS_sleep, time);
  80012a:	85aa                	mv	a1,a0
  80012c:	452d                	li	a0,11
  80012e:	fa7ff06f          	j	8000d4 <syscall>

0000000000800132 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800132:	1141                	addi	sp,sp,-16
  800134:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800136:	fd7ff0ef          	jal	ra,80010c <sys_exit>
    cprintf("BUG: exit failed.\n");
  80013a:	00000517          	auipc	a0,0x0
  80013e:	4f650513          	addi	a0,a0,1270 # 800630 <main+0xae>
  800142:	f5fff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  800146:	a001                	j	800146 <exit+0x14>

0000000000800148 <fork>:
}

int
fork(void) {
    return sys_fork();
  800148:	fcdff06f          	j	800114 <sys_fork>

000000000080014c <kill>:
    sys_yield();
}

int
kill(int pid) {
    return sys_kill(pid);
  80014c:	fcfff06f          	j	80011a <sys_kill>

0000000000800150 <sleep>:
    sys_lab6_set_priority(priority);
}

int
sleep(unsigned int time) {
    return sys_sleep(time);
  800150:	1502                	slli	a0,a0,0x20
  800152:	9101                	srli	a0,a0,0x20
  800154:	fd7ff06f          	j	80012a <sys_sleep>

0000000000800158 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800158:	1141                	addi	sp,sp,-16
  80015a:	e406                	sd	ra,8(sp)
    int ret = main();
  80015c:	426000ef          	jal	ra,800582 <main>
    exit(ret);
  800160:	fd3ff0ef          	jal	ra,800132 <exit>

0000000000800164 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800164:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800168:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80016a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80016e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800170:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800174:	f022                	sd	s0,32(sp)
  800176:	ec26                	sd	s1,24(sp)
  800178:	e84a                	sd	s2,16(sp)
  80017a:	f406                	sd	ra,40(sp)
  80017c:	e44e                	sd	s3,8(sp)
  80017e:	84aa                	mv	s1,a0
  800180:	892e                	mv	s2,a1
  800182:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800186:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800188:	03067e63          	bleu	a6,a2,8001c4 <printnum+0x60>
  80018c:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80018e:	00805763          	blez	s0,80019c <printnum+0x38>
  800192:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800194:	85ca                	mv	a1,s2
  800196:	854e                	mv	a0,s3
  800198:	9482                	jalr	s1
        while (-- width > 0)
  80019a:	fc65                	bnez	s0,800192 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80019c:	1a02                	slli	s4,s4,0x20
  80019e:	020a5a13          	srli	s4,s4,0x20
  8001a2:	00000797          	auipc	a5,0x0
  8001a6:	6c678793          	addi	a5,a5,1734 # 800868 <error_string+0xc8>
  8001aa:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001ac:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ae:	000a4503          	lbu	a0,0(s4)
}
  8001b2:	70a2                	ld	ra,40(sp)
  8001b4:	69a2                	ld	s3,8(sp)
  8001b6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b8:	85ca                	mv	a1,s2
  8001ba:	8326                	mv	t1,s1
}
  8001bc:	6942                	ld	s2,16(sp)
  8001be:	64e2                	ld	s1,24(sp)
  8001c0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001c2:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001c4:	03065633          	divu	a2,a2,a6
  8001c8:	8722                	mv	a4,s0
  8001ca:	f9bff0ef          	jal	ra,800164 <printnum>
  8001ce:	b7f9                	j	80019c <printnum+0x38>

00000000008001d0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001d0:	7119                	addi	sp,sp,-128
  8001d2:	f4a6                	sd	s1,104(sp)
  8001d4:	f0ca                	sd	s2,96(sp)
  8001d6:	e8d2                	sd	s4,80(sp)
  8001d8:	e4d6                	sd	s5,72(sp)
  8001da:	e0da                	sd	s6,64(sp)
  8001dc:	fc5e                	sd	s7,56(sp)
  8001de:	f862                	sd	s8,48(sp)
  8001e0:	f06a                	sd	s10,32(sp)
  8001e2:	fc86                	sd	ra,120(sp)
  8001e4:	f8a2                	sd	s0,112(sp)
  8001e6:	ecce                	sd	s3,88(sp)
  8001e8:	f466                	sd	s9,40(sp)
  8001ea:	ec6e                	sd	s11,24(sp)
  8001ec:	892a                	mv	s2,a0
  8001ee:	84ae                	mv	s1,a1
  8001f0:	8d32                	mv	s10,a2
  8001f2:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001f4:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001f6:	00000a17          	auipc	s4,0x0
  8001fa:	44ea0a13          	addi	s4,s4,1102 # 800644 <main+0xc2>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  8001fe:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800202:	00000c17          	auipc	s8,0x0
  800206:	59ec0c13          	addi	s8,s8,1438 # 8007a0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80020a:	000d4503          	lbu	a0,0(s10)
  80020e:	02500793          	li	a5,37
  800212:	001d0413          	addi	s0,s10,1
  800216:	00f50e63          	beq	a0,a5,800232 <vprintfmt+0x62>
            if (ch == '\0') {
  80021a:	c521                	beqz	a0,800262 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021c:	02500993          	li	s3,37
  800220:	a011                	j	800224 <vprintfmt+0x54>
            if (ch == '\0') {
  800222:	c121                	beqz	a0,800262 <vprintfmt+0x92>
            putch(ch, putdat);
  800224:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800226:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800228:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80022a:	fff44503          	lbu	a0,-1(s0)
  80022e:	ff351ae3          	bne	a0,s3,800222 <vprintfmt+0x52>
  800232:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800236:	02000793          	li	a5,32
        lflag = altflag = 0;
  80023a:	4981                	li	s3,0
  80023c:	4801                	li	a6,0
        width = precision = -1;
  80023e:	5cfd                	li	s9,-1
  800240:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800242:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800246:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800248:	fdd6069b          	addiw	a3,a2,-35
  80024c:	0ff6f693          	andi	a3,a3,255
  800250:	00140d13          	addi	s10,s0,1
  800254:	20d5e563          	bltu	a1,a3,80045e <vprintfmt+0x28e>
  800258:	068a                	slli	a3,a3,0x2
  80025a:	96d2                	add	a3,a3,s4
  80025c:	4294                	lw	a3,0(a3)
  80025e:	96d2                	add	a3,a3,s4
  800260:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800262:	70e6                	ld	ra,120(sp)
  800264:	7446                	ld	s0,112(sp)
  800266:	74a6                	ld	s1,104(sp)
  800268:	7906                	ld	s2,96(sp)
  80026a:	69e6                	ld	s3,88(sp)
  80026c:	6a46                	ld	s4,80(sp)
  80026e:	6aa6                	ld	s5,72(sp)
  800270:	6b06                	ld	s6,64(sp)
  800272:	7be2                	ld	s7,56(sp)
  800274:	7c42                	ld	s8,48(sp)
  800276:	7ca2                	ld	s9,40(sp)
  800278:	7d02                	ld	s10,32(sp)
  80027a:	6de2                	ld	s11,24(sp)
  80027c:	6109                	addi	sp,sp,128
  80027e:	8082                	ret
    if (lflag >= 2) {
  800280:	4705                	li	a4,1
  800282:	008a8593          	addi	a1,s5,8
  800286:	01074463          	blt	a4,a6,80028e <vprintfmt+0xbe>
    else if (lflag) {
  80028a:	26080363          	beqz	a6,8004f0 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  80028e:	000ab603          	ld	a2,0(s5)
  800292:	46c1                	li	a3,16
  800294:	8aae                	mv	s5,a1
  800296:	a06d                	j	800340 <vprintfmt+0x170>
            goto reswitch;
  800298:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  80029c:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  80029e:	846a                	mv	s0,s10
            goto reswitch;
  8002a0:	b765                	j	800248 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  8002a2:	000aa503          	lw	a0,0(s5)
  8002a6:	85a6                	mv	a1,s1
  8002a8:	0aa1                	addi	s5,s5,8
  8002aa:	9902                	jalr	s2
            break;
  8002ac:	bfb9                	j	80020a <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002ae:	4705                	li	a4,1
  8002b0:	008a8993          	addi	s3,s5,8
  8002b4:	01074463          	blt	a4,a6,8002bc <vprintfmt+0xec>
    else if (lflag) {
  8002b8:	22080463          	beqz	a6,8004e0 <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002bc:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002c0:	24044463          	bltz	s0,800508 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002c4:	8622                	mv	a2,s0
  8002c6:	8ace                	mv	s5,s3
  8002c8:	46a9                	li	a3,10
  8002ca:	a89d                	j	800340 <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002cc:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002d0:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002d2:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002d4:	41f7d69b          	sraiw	a3,a5,0x1f
  8002d8:	8fb5                	xor	a5,a5,a3
  8002da:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002de:	1ad74363          	blt	a4,a3,800484 <vprintfmt+0x2b4>
  8002e2:	00369793          	slli	a5,a3,0x3
  8002e6:	97e2                	add	a5,a5,s8
  8002e8:	639c                	ld	a5,0(a5)
  8002ea:	18078d63          	beqz	a5,800484 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  8002ee:	86be                	mv	a3,a5
  8002f0:	00000617          	auipc	a2,0x0
  8002f4:	66860613          	addi	a2,a2,1640 # 800958 <error_string+0x1b8>
  8002f8:	85a6                	mv	a1,s1
  8002fa:	854a                	mv	a0,s2
  8002fc:	240000ef          	jal	ra,80053c <printfmt>
  800300:	b729                	j	80020a <vprintfmt+0x3a>
            lflag ++;
  800302:	00144603          	lbu	a2,1(s0)
  800306:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800308:	846a                	mv	s0,s10
            goto reswitch;
  80030a:	bf3d                	j	800248 <vprintfmt+0x78>
    if (lflag >= 2) {
  80030c:	4705                	li	a4,1
  80030e:	008a8593          	addi	a1,s5,8
  800312:	01074463          	blt	a4,a6,80031a <vprintfmt+0x14a>
    else if (lflag) {
  800316:	1e080263          	beqz	a6,8004fa <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  80031a:	000ab603          	ld	a2,0(s5)
  80031e:	46a1                	li	a3,8
  800320:	8aae                	mv	s5,a1
  800322:	a839                	j	800340 <vprintfmt+0x170>
            putch('0', putdat);
  800324:	03000513          	li	a0,48
  800328:	85a6                	mv	a1,s1
  80032a:	e03e                	sd	a5,0(sp)
  80032c:	9902                	jalr	s2
            putch('x', putdat);
  80032e:	85a6                	mv	a1,s1
  800330:	07800513          	li	a0,120
  800334:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800336:	0aa1                	addi	s5,s5,8
  800338:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  80033c:	6782                	ld	a5,0(sp)
  80033e:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800340:	876e                	mv	a4,s11
  800342:	85a6                	mv	a1,s1
  800344:	854a                	mv	a0,s2
  800346:	e1fff0ef          	jal	ra,800164 <printnum>
            break;
  80034a:	b5c1                	j	80020a <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  80034c:	000ab603          	ld	a2,0(s5)
  800350:	0aa1                	addi	s5,s5,8
  800352:	1c060663          	beqz	a2,80051e <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  800356:	00160413          	addi	s0,a2,1
  80035a:	17b05c63          	blez	s11,8004d2 <vprintfmt+0x302>
  80035e:	02d00593          	li	a1,45
  800362:	14b79263          	bne	a5,a1,8004a6 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800366:	00064783          	lbu	a5,0(a2)
  80036a:	0007851b          	sext.w	a0,a5
  80036e:	c905                	beqz	a0,80039e <vprintfmt+0x1ce>
  800370:	000cc563          	bltz	s9,80037a <vprintfmt+0x1aa>
  800374:	3cfd                	addiw	s9,s9,-1
  800376:	036c8263          	beq	s9,s6,80039a <vprintfmt+0x1ca>
                    putch('?', putdat);
  80037a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80037c:	18098463          	beqz	s3,800504 <vprintfmt+0x334>
  800380:	3781                	addiw	a5,a5,-32
  800382:	18fbf163          	bleu	a5,s7,800504 <vprintfmt+0x334>
                    putch('?', putdat);
  800386:	03f00513          	li	a0,63
  80038a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80038c:	0405                	addi	s0,s0,1
  80038e:	fff44783          	lbu	a5,-1(s0)
  800392:	3dfd                	addiw	s11,s11,-1
  800394:	0007851b          	sext.w	a0,a5
  800398:	fd61                	bnez	a0,800370 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  80039a:	e7b058e3          	blez	s11,80020a <vprintfmt+0x3a>
  80039e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003a0:	85a6                	mv	a1,s1
  8003a2:	02000513          	li	a0,32
  8003a6:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003a8:	e60d81e3          	beqz	s11,80020a <vprintfmt+0x3a>
  8003ac:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003ae:	85a6                	mv	a1,s1
  8003b0:	02000513          	li	a0,32
  8003b4:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003b6:	fe0d94e3          	bnez	s11,80039e <vprintfmt+0x1ce>
  8003ba:	bd81                	j	80020a <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003bc:	4705                	li	a4,1
  8003be:	008a8593          	addi	a1,s5,8
  8003c2:	01074463          	blt	a4,a6,8003ca <vprintfmt+0x1fa>
    else if (lflag) {
  8003c6:	12080063          	beqz	a6,8004e6 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003ca:	000ab603          	ld	a2,0(s5)
  8003ce:	46a9                	li	a3,10
  8003d0:	8aae                	mv	s5,a1
  8003d2:	b7bd                	j	800340 <vprintfmt+0x170>
  8003d4:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003d8:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  8003dc:	846a                	mv	s0,s10
  8003de:	b5ad                	j	800248 <vprintfmt+0x78>
            putch(ch, putdat);
  8003e0:	85a6                	mv	a1,s1
  8003e2:	02500513          	li	a0,37
  8003e6:	9902                	jalr	s2
            break;
  8003e8:	b50d                	j	80020a <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  8003ea:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8003ee:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8003f2:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8003f4:	846a                	mv	s0,s10
            if (width < 0)
  8003f6:	e40dd9e3          	bgez	s11,800248 <vprintfmt+0x78>
                width = precision, precision = -1;
  8003fa:	8de6                	mv	s11,s9
  8003fc:	5cfd                	li	s9,-1
  8003fe:	b5a9                	j	800248 <vprintfmt+0x78>
            goto reswitch;
  800400:	00144603          	lbu	a2,1(s0)
            padc = '0';
  800404:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  800408:	846a                	mv	s0,s10
            goto reswitch;
  80040a:	bd3d                	j	800248 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  80040c:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800410:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800414:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800416:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  80041a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80041e:	fcd56ce3          	bltu	a0,a3,8003f6 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  800422:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800424:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800428:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  80042c:	0196873b          	addw	a4,a3,s9
  800430:	0017171b          	slliw	a4,a4,0x1
  800434:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800438:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  80043c:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800440:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800444:	fcd57fe3          	bleu	a3,a0,800422 <vprintfmt+0x252>
  800448:	b77d                	j	8003f6 <vprintfmt+0x226>
            if (width < 0)
  80044a:	fffdc693          	not	a3,s11
  80044e:	96fd                	srai	a3,a3,0x3f
  800450:	00ddfdb3          	and	s11,s11,a3
  800454:	00144603          	lbu	a2,1(s0)
  800458:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  80045a:	846a                	mv	s0,s10
  80045c:	b3f5                	j	800248 <vprintfmt+0x78>
            putch('%', putdat);
  80045e:	85a6                	mv	a1,s1
  800460:	02500513          	li	a0,37
  800464:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800466:	fff44703          	lbu	a4,-1(s0)
  80046a:	02500793          	li	a5,37
  80046e:	8d22                	mv	s10,s0
  800470:	d8f70de3          	beq	a4,a5,80020a <vprintfmt+0x3a>
  800474:	02500713          	li	a4,37
  800478:	1d7d                	addi	s10,s10,-1
  80047a:	fffd4783          	lbu	a5,-1(s10)
  80047e:	fee79de3          	bne	a5,a4,800478 <vprintfmt+0x2a8>
  800482:	b361                	j	80020a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800484:	00000617          	auipc	a2,0x0
  800488:	4c460613          	addi	a2,a2,1220 # 800948 <error_string+0x1a8>
  80048c:	85a6                	mv	a1,s1
  80048e:	854a                	mv	a0,s2
  800490:	0ac000ef          	jal	ra,80053c <printfmt>
  800494:	bb9d                	j	80020a <vprintfmt+0x3a>
                p = "(null)";
  800496:	00000617          	auipc	a2,0x0
  80049a:	4aa60613          	addi	a2,a2,1194 # 800940 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  80049e:	00000417          	auipc	s0,0x0
  8004a2:	4a340413          	addi	s0,s0,1187 # 800941 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a6:	8532                	mv	a0,a2
  8004a8:	85e6                	mv	a1,s9
  8004aa:	e032                	sd	a2,0(sp)
  8004ac:	e43e                	sd	a5,8(sp)
  8004ae:	0ae000ef          	jal	ra,80055c <strnlen>
  8004b2:	40ad8dbb          	subw	s11,s11,a0
  8004b6:	6602                	ld	a2,0(sp)
  8004b8:	01b05d63          	blez	s11,8004d2 <vprintfmt+0x302>
  8004bc:	67a2                	ld	a5,8(sp)
  8004be:	2781                	sext.w	a5,a5
  8004c0:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004c2:	6522                	ld	a0,8(sp)
  8004c4:	85a6                	mv	a1,s1
  8004c6:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c8:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004ca:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004cc:	6602                	ld	a2,0(sp)
  8004ce:	fe0d9ae3          	bnez	s11,8004c2 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004d2:	00064783          	lbu	a5,0(a2)
  8004d6:	0007851b          	sext.w	a0,a5
  8004da:	e8051be3          	bnez	a0,800370 <vprintfmt+0x1a0>
  8004de:	b335                	j	80020a <vprintfmt+0x3a>
        return va_arg(*ap, int);
  8004e0:	000aa403          	lw	s0,0(s5)
  8004e4:	bbf1                	j	8002c0 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  8004e6:	000ae603          	lwu	a2,0(s5)
  8004ea:	46a9                	li	a3,10
  8004ec:	8aae                	mv	s5,a1
  8004ee:	bd89                	j	800340 <vprintfmt+0x170>
  8004f0:	000ae603          	lwu	a2,0(s5)
  8004f4:	46c1                	li	a3,16
  8004f6:	8aae                	mv	s5,a1
  8004f8:	b5a1                	j	800340 <vprintfmt+0x170>
  8004fa:	000ae603          	lwu	a2,0(s5)
  8004fe:	46a1                	li	a3,8
  800500:	8aae                	mv	s5,a1
  800502:	bd3d                	j	800340 <vprintfmt+0x170>
                    putch(ch, putdat);
  800504:	9902                	jalr	s2
  800506:	b559                	j	80038c <vprintfmt+0x1bc>
                putch('-', putdat);
  800508:	85a6                	mv	a1,s1
  80050a:	02d00513          	li	a0,45
  80050e:	e03e                	sd	a5,0(sp)
  800510:	9902                	jalr	s2
                num = -(long long)num;
  800512:	8ace                	mv	s5,s3
  800514:	40800633          	neg	a2,s0
  800518:	46a9                	li	a3,10
  80051a:	6782                	ld	a5,0(sp)
  80051c:	b515                	j	800340 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  80051e:	01b05663          	blez	s11,80052a <vprintfmt+0x35a>
  800522:	02d00693          	li	a3,45
  800526:	f6d798e3          	bne	a5,a3,800496 <vprintfmt+0x2c6>
  80052a:	00000417          	auipc	s0,0x0
  80052e:	41740413          	addi	s0,s0,1047 # 800941 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800532:	02800513          	li	a0,40
  800536:	02800793          	li	a5,40
  80053a:	bd1d                	j	800370 <vprintfmt+0x1a0>

000000000080053c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80053c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80053e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800542:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800544:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800546:	ec06                	sd	ra,24(sp)
  800548:	f83a                	sd	a4,48(sp)
  80054a:	fc3e                	sd	a5,56(sp)
  80054c:	e0c2                	sd	a6,64(sp)
  80054e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800550:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800552:	c7fff0ef          	jal	ra,8001d0 <vprintfmt>
}
  800556:	60e2                	ld	ra,24(sp)
  800558:	6161                	addi	sp,sp,80
  80055a:	8082                	ret

000000000080055c <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  80055c:	c185                	beqz	a1,80057c <strnlen+0x20>
  80055e:	00054783          	lbu	a5,0(a0)
  800562:	cf89                	beqz	a5,80057c <strnlen+0x20>
    size_t cnt = 0;
  800564:	4781                	li	a5,0
  800566:	a021                	j	80056e <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800568:	00074703          	lbu	a4,0(a4)
  80056c:	c711                	beqz	a4,800578 <strnlen+0x1c>
        cnt ++;
  80056e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800570:	00f50733          	add	a4,a0,a5
  800574:	fef59ae3          	bne	a1,a5,800568 <strnlen+0xc>
    }
    return cnt;
}
  800578:	853e                	mv	a0,a5
  80057a:	8082                	ret
    size_t cnt = 0;
  80057c:	4781                	li	a5,0
}
  80057e:	853e                	mv	a0,a5
  800580:	8082                	ret

0000000000800582 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  800582:	1141                	addi	sp,sp,-16
  800584:	e406                	sd	ra,8(sp)
  800586:	e022                	sd	s0,0(sp)
    int pid;
    if ((pid = fork()) == 0) {
  800588:	bc1ff0ef          	jal	ra,800148 <fork>
  80058c:	c51d                	beqz	a0,8005ba <main+0x38>
  80058e:	842a                	mv	s0,a0
        sleep(~0);
        exit(0xdead);
    }
    assert(pid > 0);
  800590:	04a05c63          	blez	a0,8005e8 <main+0x66>

    sleep(100);
  800594:	06400513          	li	a0,100
  800598:	bb9ff0ef          	jal	ra,800150 <sleep>
    assert(kill(pid) == 0);
  80059c:	8522                	mv	a0,s0
  80059e:	bafff0ef          	jal	ra,80014c <kill>
  8005a2:	e505                	bnez	a0,8005ca <main+0x48>
    cprintf("sleepkill pass.\n");
  8005a4:	00000517          	auipc	a0,0x0
  8005a8:	40450513          	addi	a0,a0,1028 # 8009a8 <error_string+0x208>
  8005ac:	af5ff0ef          	jal	ra,8000a0 <cprintf>
    return 0;
}
  8005b0:	60a2                	ld	ra,8(sp)
  8005b2:	6402                	ld	s0,0(sp)
  8005b4:	4501                	li	a0,0
  8005b6:	0141                	addi	sp,sp,16
  8005b8:	8082                	ret
        sleep(~0);
  8005ba:	557d                	li	a0,-1
  8005bc:	b95ff0ef          	jal	ra,800150 <sleep>
        exit(0xdead);
  8005c0:	6539                	lui	a0,0xe
  8005c2:	ead50513          	addi	a0,a0,-339 # dead <_start-0x7f2173>
  8005c6:	b6dff0ef          	jal	ra,800132 <exit>
    assert(kill(pid) == 0);
  8005ca:	00000697          	auipc	a3,0x0
  8005ce:	3ce68693          	addi	a3,a3,974 # 800998 <error_string+0x1f8>
  8005d2:	00000617          	auipc	a2,0x0
  8005d6:	39660613          	addi	a2,a2,918 # 800968 <error_string+0x1c8>
  8005da:	45b9                	li	a1,14
  8005dc:	00000517          	auipc	a0,0x0
  8005e0:	3a450513          	addi	a0,a0,932 # 800980 <error_string+0x1e0>
  8005e4:	a43ff0ef          	jal	ra,800026 <__panic>
    assert(pid > 0);
  8005e8:	00000697          	auipc	a3,0x0
  8005ec:	37868693          	addi	a3,a3,888 # 800960 <error_string+0x1c0>
  8005f0:	00000617          	auipc	a2,0x0
  8005f4:	37860613          	addi	a2,a2,888 # 800968 <error_string+0x1c8>
  8005f8:	45ad                	li	a1,11
  8005fa:	00000517          	auipc	a0,0x0
  8005fe:	38650513          	addi	a0,a0,902 # 800980 <error_string+0x1e0>
  800602:	a25ff0ef          	jal	ra,800026 <__panic>
