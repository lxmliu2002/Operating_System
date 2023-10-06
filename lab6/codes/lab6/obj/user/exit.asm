
obj/__user_exit.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  800020:	13c000ef          	jal	ra,80015c <umain>
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
  800038:	66c50513          	addi	a0,a0,1644 # 8006a0 <main+0x11a>
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
  80006e:	0bc000ef          	jal	ra,80012a <sys_putc>
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
  800094:	140000ef          	jal	ra,8001d4 <vprintfmt>
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
  8000c8:	10c000ef          	jal	ra,8001d4 <vprintfmt>
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

0000000000800124 <sys_yield>:
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  800124:	4529                	li	a0,10
  800126:	fafff06f          	j	8000d4 <syscall>

000000000080012a <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  80012a:	85aa                	mv	a1,a0
  80012c:	4579                	li	a0,30
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
  80013e:	58650513          	addi	a0,a0,1414 # 8006c0 <main+0x13a>
  800142:	f5fff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  800146:	a001                	j	800146 <exit+0x14>

0000000000800148 <fork>:
}

int
fork(void) {
    return sys_fork();
  800148:	fcdff06f          	j	800114 <sys_fork>

000000000080014c <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  80014c:	4581                	li	a1,0
  80014e:	4501                	li	a0,0
  800150:	fcbff06f          	j	80011a <sys_wait>

0000000000800154 <waitpid>:
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  800154:	fc7ff06f          	j	80011a <sys_wait>

0000000000800158 <yield>:
}

void
yield(void) {
    sys_yield();
  800158:	fcdff06f          	j	800124 <sys_yield>

000000000080015c <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80015c:	1141                	addi	sp,sp,-16
  80015e:	e406                	sd	ra,8(sp)
    int ret = main();
  800160:	426000ef          	jal	ra,800586 <main>
    exit(ret);
  800164:	fcfff0ef          	jal	ra,800132 <exit>

0000000000800168 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800168:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80016c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80016e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800172:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800174:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800178:	f022                	sd	s0,32(sp)
  80017a:	ec26                	sd	s1,24(sp)
  80017c:	e84a                	sd	s2,16(sp)
  80017e:	f406                	sd	ra,40(sp)
  800180:	e44e                	sd	s3,8(sp)
  800182:	84aa                	mv	s1,a0
  800184:	892e                	mv	s2,a1
  800186:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80018a:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  80018c:	03067e63          	bleu	a6,a2,8001c8 <printnum+0x60>
  800190:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800192:	00805763          	blez	s0,8001a0 <printnum+0x38>
  800196:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800198:	85ca                	mv	a1,s2
  80019a:	854e                	mv	a0,s3
  80019c:	9482                	jalr	s1
        while (-- width > 0)
  80019e:	fc65                	bnez	s0,800196 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001a0:	1a02                	slli	s4,s4,0x20
  8001a2:	020a5a13          	srli	s4,s4,0x20
  8001a6:	00000797          	auipc	a5,0x0
  8001aa:	75278793          	addi	a5,a5,1874 # 8008f8 <error_string+0xc8>
  8001ae:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001b0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b2:	000a4503          	lbu	a0,0(s4)
}
  8001b6:	70a2                	ld	ra,40(sp)
  8001b8:	69a2                	ld	s3,8(sp)
  8001ba:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001bc:	85ca                	mv	a1,s2
  8001be:	8326                	mv	t1,s1
}
  8001c0:	6942                	ld	s2,16(sp)
  8001c2:	64e2                	ld	s1,24(sp)
  8001c4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001c6:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001c8:	03065633          	divu	a2,a2,a6
  8001cc:	8722                	mv	a4,s0
  8001ce:	f9bff0ef          	jal	ra,800168 <printnum>
  8001d2:	b7f9                	j	8001a0 <printnum+0x38>

00000000008001d4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001d4:	7119                	addi	sp,sp,-128
  8001d6:	f4a6                	sd	s1,104(sp)
  8001d8:	f0ca                	sd	s2,96(sp)
  8001da:	e8d2                	sd	s4,80(sp)
  8001dc:	e4d6                	sd	s5,72(sp)
  8001de:	e0da                	sd	s6,64(sp)
  8001e0:	fc5e                	sd	s7,56(sp)
  8001e2:	f862                	sd	s8,48(sp)
  8001e4:	f06a                	sd	s10,32(sp)
  8001e6:	fc86                	sd	ra,120(sp)
  8001e8:	f8a2                	sd	s0,112(sp)
  8001ea:	ecce                	sd	s3,88(sp)
  8001ec:	f466                	sd	s9,40(sp)
  8001ee:	ec6e                	sd	s11,24(sp)
  8001f0:	892a                	mv	s2,a0
  8001f2:	84ae                	mv	s1,a1
  8001f4:	8d32                	mv	s10,a2
  8001f6:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001f8:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001fa:	00000a17          	auipc	s4,0x0
  8001fe:	4daa0a13          	addi	s4,s4,1242 # 8006d4 <main+0x14e>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800202:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800206:	00000c17          	auipc	s8,0x0
  80020a:	62ac0c13          	addi	s8,s8,1578 # 800830 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80020e:	000d4503          	lbu	a0,0(s10)
  800212:	02500793          	li	a5,37
  800216:	001d0413          	addi	s0,s10,1
  80021a:	00f50e63          	beq	a0,a5,800236 <vprintfmt+0x62>
            if (ch == '\0') {
  80021e:	c521                	beqz	a0,800266 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800220:	02500993          	li	s3,37
  800224:	a011                	j	800228 <vprintfmt+0x54>
            if (ch == '\0') {
  800226:	c121                	beqz	a0,800266 <vprintfmt+0x92>
            putch(ch, putdat);
  800228:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80022a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80022c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80022e:	fff44503          	lbu	a0,-1(s0)
  800232:	ff351ae3          	bne	a0,s3,800226 <vprintfmt+0x52>
  800236:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80023a:	02000793          	li	a5,32
        lflag = altflag = 0;
  80023e:	4981                	li	s3,0
  800240:	4801                	li	a6,0
        width = precision = -1;
  800242:	5cfd                	li	s9,-1
  800244:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800246:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  80024a:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  80024c:	fdd6069b          	addiw	a3,a2,-35
  800250:	0ff6f693          	andi	a3,a3,255
  800254:	00140d13          	addi	s10,s0,1
  800258:	20d5e563          	bltu	a1,a3,800462 <vprintfmt+0x28e>
  80025c:	068a                	slli	a3,a3,0x2
  80025e:	96d2                	add	a3,a3,s4
  800260:	4294                	lw	a3,0(a3)
  800262:	96d2                	add	a3,a3,s4
  800264:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800266:	70e6                	ld	ra,120(sp)
  800268:	7446                	ld	s0,112(sp)
  80026a:	74a6                	ld	s1,104(sp)
  80026c:	7906                	ld	s2,96(sp)
  80026e:	69e6                	ld	s3,88(sp)
  800270:	6a46                	ld	s4,80(sp)
  800272:	6aa6                	ld	s5,72(sp)
  800274:	6b06                	ld	s6,64(sp)
  800276:	7be2                	ld	s7,56(sp)
  800278:	7c42                	ld	s8,48(sp)
  80027a:	7ca2                	ld	s9,40(sp)
  80027c:	7d02                	ld	s10,32(sp)
  80027e:	6de2                	ld	s11,24(sp)
  800280:	6109                	addi	sp,sp,128
  800282:	8082                	ret
    if (lflag >= 2) {
  800284:	4705                	li	a4,1
  800286:	008a8593          	addi	a1,s5,8
  80028a:	01074463          	blt	a4,a6,800292 <vprintfmt+0xbe>
    else if (lflag) {
  80028e:	26080363          	beqz	a6,8004f4 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  800292:	000ab603          	ld	a2,0(s5)
  800296:	46c1                	li	a3,16
  800298:	8aae                	mv	s5,a1
  80029a:	a06d                	j	800344 <vprintfmt+0x170>
            goto reswitch;
  80029c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002a0:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002a2:	846a                	mv	s0,s10
            goto reswitch;
  8002a4:	b765                	j	80024c <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  8002a6:	000aa503          	lw	a0,0(s5)
  8002aa:	85a6                	mv	a1,s1
  8002ac:	0aa1                	addi	s5,s5,8
  8002ae:	9902                	jalr	s2
            break;
  8002b0:	bfb9                	j	80020e <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002b2:	4705                	li	a4,1
  8002b4:	008a8993          	addi	s3,s5,8
  8002b8:	01074463          	blt	a4,a6,8002c0 <vprintfmt+0xec>
    else if (lflag) {
  8002bc:	22080463          	beqz	a6,8004e4 <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002c0:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002c4:	24044463          	bltz	s0,80050c <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002c8:	8622                	mv	a2,s0
  8002ca:	8ace                	mv	s5,s3
  8002cc:	46a9                	li	a3,10
  8002ce:	a89d                	j	800344 <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002d0:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002d4:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002d6:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002d8:	41f7d69b          	sraiw	a3,a5,0x1f
  8002dc:	8fb5                	xor	a5,a5,a3
  8002de:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002e2:	1ad74363          	blt	a4,a3,800488 <vprintfmt+0x2b4>
  8002e6:	00369793          	slli	a5,a3,0x3
  8002ea:	97e2                	add	a5,a5,s8
  8002ec:	639c                	ld	a5,0(a5)
  8002ee:	18078d63          	beqz	a5,800488 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  8002f2:	86be                	mv	a3,a5
  8002f4:	00000617          	auipc	a2,0x0
  8002f8:	6f460613          	addi	a2,a2,1780 # 8009e8 <error_string+0x1b8>
  8002fc:	85a6                	mv	a1,s1
  8002fe:	854a                	mv	a0,s2
  800300:	240000ef          	jal	ra,800540 <printfmt>
  800304:	b729                	j	80020e <vprintfmt+0x3a>
            lflag ++;
  800306:	00144603          	lbu	a2,1(s0)
  80030a:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  80030c:	846a                	mv	s0,s10
            goto reswitch;
  80030e:	bf3d                	j	80024c <vprintfmt+0x78>
    if (lflag >= 2) {
  800310:	4705                	li	a4,1
  800312:	008a8593          	addi	a1,s5,8
  800316:	01074463          	blt	a4,a6,80031e <vprintfmt+0x14a>
    else if (lflag) {
  80031a:	1e080263          	beqz	a6,8004fe <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  80031e:	000ab603          	ld	a2,0(s5)
  800322:	46a1                	li	a3,8
  800324:	8aae                	mv	s5,a1
  800326:	a839                	j	800344 <vprintfmt+0x170>
            putch('0', putdat);
  800328:	03000513          	li	a0,48
  80032c:	85a6                	mv	a1,s1
  80032e:	e03e                	sd	a5,0(sp)
  800330:	9902                	jalr	s2
            putch('x', putdat);
  800332:	85a6                	mv	a1,s1
  800334:	07800513          	li	a0,120
  800338:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80033a:	0aa1                	addi	s5,s5,8
  80033c:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800340:	6782                	ld	a5,0(sp)
  800342:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800344:	876e                	mv	a4,s11
  800346:	85a6                	mv	a1,s1
  800348:	854a                	mv	a0,s2
  80034a:	e1fff0ef          	jal	ra,800168 <printnum>
            break;
  80034e:	b5c1                	j	80020e <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800350:	000ab603          	ld	a2,0(s5)
  800354:	0aa1                	addi	s5,s5,8
  800356:	1c060663          	beqz	a2,800522 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  80035a:	00160413          	addi	s0,a2,1
  80035e:	17b05c63          	blez	s11,8004d6 <vprintfmt+0x302>
  800362:	02d00593          	li	a1,45
  800366:	14b79263          	bne	a5,a1,8004aa <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80036a:	00064783          	lbu	a5,0(a2)
  80036e:	0007851b          	sext.w	a0,a5
  800372:	c905                	beqz	a0,8003a2 <vprintfmt+0x1ce>
  800374:	000cc563          	bltz	s9,80037e <vprintfmt+0x1aa>
  800378:	3cfd                	addiw	s9,s9,-1
  80037a:	036c8263          	beq	s9,s6,80039e <vprintfmt+0x1ca>
                    putch('?', putdat);
  80037e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800380:	18098463          	beqz	s3,800508 <vprintfmt+0x334>
  800384:	3781                	addiw	a5,a5,-32
  800386:	18fbf163          	bleu	a5,s7,800508 <vprintfmt+0x334>
                    putch('?', putdat);
  80038a:	03f00513          	li	a0,63
  80038e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800390:	0405                	addi	s0,s0,1
  800392:	fff44783          	lbu	a5,-1(s0)
  800396:	3dfd                	addiw	s11,s11,-1
  800398:	0007851b          	sext.w	a0,a5
  80039c:	fd61                	bnez	a0,800374 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  80039e:	e7b058e3          	blez	s11,80020e <vprintfmt+0x3a>
  8003a2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003a4:	85a6                	mv	a1,s1
  8003a6:	02000513          	li	a0,32
  8003aa:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ac:	e60d81e3          	beqz	s11,80020e <vprintfmt+0x3a>
  8003b0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003b2:	85a6                	mv	a1,s1
  8003b4:	02000513          	li	a0,32
  8003b8:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ba:	fe0d94e3          	bnez	s11,8003a2 <vprintfmt+0x1ce>
  8003be:	bd81                	j	80020e <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003c0:	4705                	li	a4,1
  8003c2:	008a8593          	addi	a1,s5,8
  8003c6:	01074463          	blt	a4,a6,8003ce <vprintfmt+0x1fa>
    else if (lflag) {
  8003ca:	12080063          	beqz	a6,8004ea <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003ce:	000ab603          	ld	a2,0(s5)
  8003d2:	46a9                	li	a3,10
  8003d4:	8aae                	mv	s5,a1
  8003d6:	b7bd                	j	800344 <vprintfmt+0x170>
  8003d8:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003dc:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  8003e0:	846a                	mv	s0,s10
  8003e2:	b5ad                	j	80024c <vprintfmt+0x78>
            putch(ch, putdat);
  8003e4:	85a6                	mv	a1,s1
  8003e6:	02500513          	li	a0,37
  8003ea:	9902                	jalr	s2
            break;
  8003ec:	b50d                	j	80020e <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  8003ee:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8003f2:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8003f6:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8003f8:	846a                	mv	s0,s10
            if (width < 0)
  8003fa:	e40dd9e3          	bgez	s11,80024c <vprintfmt+0x78>
                width = precision, precision = -1;
  8003fe:	8de6                	mv	s11,s9
  800400:	5cfd                	li	s9,-1
  800402:	b5a9                	j	80024c <vprintfmt+0x78>
            goto reswitch;
  800404:	00144603          	lbu	a2,1(s0)
            padc = '0';
  800408:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  80040c:	846a                	mv	s0,s10
            goto reswitch;
  80040e:	bd3d                	j	80024c <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800410:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800414:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800418:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80041a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  80041e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800422:	fcd56ce3          	bltu	a0,a3,8003fa <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  800426:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800428:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  80042c:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800430:	0196873b          	addw	a4,a3,s9
  800434:	0017171b          	slliw	a4,a4,0x1
  800438:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  80043c:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800440:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800444:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800448:	fcd57fe3          	bleu	a3,a0,800426 <vprintfmt+0x252>
  80044c:	b77d                	j	8003fa <vprintfmt+0x226>
            if (width < 0)
  80044e:	fffdc693          	not	a3,s11
  800452:	96fd                	srai	a3,a3,0x3f
  800454:	00ddfdb3          	and	s11,s11,a3
  800458:	00144603          	lbu	a2,1(s0)
  80045c:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  80045e:	846a                	mv	s0,s10
  800460:	b3f5                	j	80024c <vprintfmt+0x78>
            putch('%', putdat);
  800462:	85a6                	mv	a1,s1
  800464:	02500513          	li	a0,37
  800468:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80046a:	fff44703          	lbu	a4,-1(s0)
  80046e:	02500793          	li	a5,37
  800472:	8d22                	mv	s10,s0
  800474:	d8f70de3          	beq	a4,a5,80020e <vprintfmt+0x3a>
  800478:	02500713          	li	a4,37
  80047c:	1d7d                	addi	s10,s10,-1
  80047e:	fffd4783          	lbu	a5,-1(s10)
  800482:	fee79de3          	bne	a5,a4,80047c <vprintfmt+0x2a8>
  800486:	b361                	j	80020e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800488:	00000617          	auipc	a2,0x0
  80048c:	55060613          	addi	a2,a2,1360 # 8009d8 <error_string+0x1a8>
  800490:	85a6                	mv	a1,s1
  800492:	854a                	mv	a0,s2
  800494:	0ac000ef          	jal	ra,800540 <printfmt>
  800498:	bb9d                	j	80020e <vprintfmt+0x3a>
                p = "(null)";
  80049a:	00000617          	auipc	a2,0x0
  80049e:	53660613          	addi	a2,a2,1334 # 8009d0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004a2:	00000417          	auipc	s0,0x0
  8004a6:	52f40413          	addi	s0,s0,1327 # 8009d1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004aa:	8532                	mv	a0,a2
  8004ac:	85e6                	mv	a1,s9
  8004ae:	e032                	sd	a2,0(sp)
  8004b0:	e43e                	sd	a5,8(sp)
  8004b2:	0ae000ef          	jal	ra,800560 <strnlen>
  8004b6:	40ad8dbb          	subw	s11,s11,a0
  8004ba:	6602                	ld	a2,0(sp)
  8004bc:	01b05d63          	blez	s11,8004d6 <vprintfmt+0x302>
  8004c0:	67a2                	ld	a5,8(sp)
  8004c2:	2781                	sext.w	a5,a5
  8004c4:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004c6:	6522                	ld	a0,8(sp)
  8004c8:	85a6                	mv	a1,s1
  8004ca:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004cc:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004ce:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d0:	6602                	ld	a2,0(sp)
  8004d2:	fe0d9ae3          	bnez	s11,8004c6 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004d6:	00064783          	lbu	a5,0(a2)
  8004da:	0007851b          	sext.w	a0,a5
  8004de:	e8051be3          	bnez	a0,800374 <vprintfmt+0x1a0>
  8004e2:	b335                	j	80020e <vprintfmt+0x3a>
        return va_arg(*ap, int);
  8004e4:	000aa403          	lw	s0,0(s5)
  8004e8:	bbf1                	j	8002c4 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  8004ea:	000ae603          	lwu	a2,0(s5)
  8004ee:	46a9                	li	a3,10
  8004f0:	8aae                	mv	s5,a1
  8004f2:	bd89                	j	800344 <vprintfmt+0x170>
  8004f4:	000ae603          	lwu	a2,0(s5)
  8004f8:	46c1                	li	a3,16
  8004fa:	8aae                	mv	s5,a1
  8004fc:	b5a1                	j	800344 <vprintfmt+0x170>
  8004fe:	000ae603          	lwu	a2,0(s5)
  800502:	46a1                	li	a3,8
  800504:	8aae                	mv	s5,a1
  800506:	bd3d                	j	800344 <vprintfmt+0x170>
                    putch(ch, putdat);
  800508:	9902                	jalr	s2
  80050a:	b559                	j	800390 <vprintfmt+0x1bc>
                putch('-', putdat);
  80050c:	85a6                	mv	a1,s1
  80050e:	02d00513          	li	a0,45
  800512:	e03e                	sd	a5,0(sp)
  800514:	9902                	jalr	s2
                num = -(long long)num;
  800516:	8ace                	mv	s5,s3
  800518:	40800633          	neg	a2,s0
  80051c:	46a9                	li	a3,10
  80051e:	6782                	ld	a5,0(sp)
  800520:	b515                	j	800344 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  800522:	01b05663          	blez	s11,80052e <vprintfmt+0x35a>
  800526:	02d00693          	li	a3,45
  80052a:	f6d798e3          	bne	a5,a3,80049a <vprintfmt+0x2c6>
  80052e:	00000417          	auipc	s0,0x0
  800532:	4a340413          	addi	s0,s0,1187 # 8009d1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800536:	02800513          	li	a0,40
  80053a:	02800793          	li	a5,40
  80053e:	bd1d                	j	800374 <vprintfmt+0x1a0>

0000000000800540 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800540:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800542:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800546:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800548:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80054a:	ec06                	sd	ra,24(sp)
  80054c:	f83a                	sd	a4,48(sp)
  80054e:	fc3e                	sd	a5,56(sp)
  800550:	e0c2                	sd	a6,64(sp)
  800552:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800554:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800556:	c7fff0ef          	jal	ra,8001d4 <vprintfmt>
}
  80055a:	60e2                	ld	ra,24(sp)
  80055c:	6161                	addi	sp,sp,80
  80055e:	8082                	ret

0000000000800560 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800560:	c185                	beqz	a1,800580 <strnlen+0x20>
  800562:	00054783          	lbu	a5,0(a0)
  800566:	cf89                	beqz	a5,800580 <strnlen+0x20>
    size_t cnt = 0;
  800568:	4781                	li	a5,0
  80056a:	a021                	j	800572 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  80056c:	00074703          	lbu	a4,0(a4)
  800570:	c711                	beqz	a4,80057c <strnlen+0x1c>
        cnt ++;
  800572:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800574:	00f50733          	add	a4,a0,a5
  800578:	fef59ae3          	bne	a1,a5,80056c <strnlen+0xc>
    }
    return cnt;
}
  80057c:	853e                	mv	a0,a5
  80057e:	8082                	ret
    size_t cnt = 0;
  800580:	4781                	li	a5,0
}
  800582:	853e                	mv	a0,a5
  800584:	8082                	ret

0000000000800586 <main>:
#include <ulib.h>

int magic = -0x10384;

int
main(void) {
  800586:	1101                	addi	sp,sp,-32
    int pid, code;
    cprintf("I am the parent. Forking the child...\n");
  800588:	00000517          	auipc	a0,0x0
  80058c:	46850513          	addi	a0,a0,1128 # 8009f0 <error_string+0x1c0>
main(void) {
  800590:	ec06                	sd	ra,24(sp)
  800592:	e822                	sd	s0,16(sp)
    cprintf("I am the parent. Forking the child...\n");
  800594:	b0dff0ef          	jal	ra,8000a0 <cprintf>
    if ((pid = fork()) == 0) {
  800598:	bb1ff0ef          	jal	ra,800148 <fork>
  80059c:	c569                	beqz	a0,800666 <main+0xe0>
  80059e:	842a                	mv	s0,a0
        yield();
        yield();
        exit(magic);
    }
    else {
        cprintf("I am parent, fork a child pid %d\n",pid);
  8005a0:	85aa                	mv	a1,a0
  8005a2:	00000517          	auipc	a0,0x0
  8005a6:	48e50513          	addi	a0,a0,1166 # 800a30 <error_string+0x200>
  8005aa:	af7ff0ef          	jal	ra,8000a0 <cprintf>
    }
    assert(pid > 0);
  8005ae:	08805d63          	blez	s0,800648 <main+0xc2>
    cprintf("I am the parent, waiting now..\n");
  8005b2:	00000517          	auipc	a0,0x0
  8005b6:	4d650513          	addi	a0,a0,1238 # 800a88 <error_string+0x258>
  8005ba:	ae7ff0ef          	jal	ra,8000a0 <cprintf>

    assert(waitpid(pid, &code) == 0 && code == magic);
  8005be:	006c                	addi	a1,sp,12
  8005c0:	8522                	mv	a0,s0
  8005c2:	b93ff0ef          	jal	ra,800154 <waitpid>
  8005c6:	e139                	bnez	a0,80060c <main+0x86>
  8005c8:	00001797          	auipc	a5,0x1
  8005cc:	a3878793          	addi	a5,a5,-1480 # 801000 <magic>
  8005d0:	4732                	lw	a4,12(sp)
  8005d2:	439c                	lw	a5,0(a5)
  8005d4:	02f71c63          	bne	a4,a5,80060c <main+0x86>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  8005d8:	006c                	addi	a1,sp,12
  8005da:	8522                	mv	a0,s0
  8005dc:	b79ff0ef          	jal	ra,800154 <waitpid>
  8005e0:	c529                	beqz	a0,80062a <main+0xa4>
  8005e2:	b6bff0ef          	jal	ra,80014c <wait>
  8005e6:	c131                	beqz	a0,80062a <main+0xa4>
    cprintf("waitpid %d ok.\n", pid);
  8005e8:	85a2                	mv	a1,s0
  8005ea:	00000517          	auipc	a0,0x0
  8005ee:	51650513          	addi	a0,a0,1302 # 800b00 <error_string+0x2d0>
  8005f2:	aafff0ef          	jal	ra,8000a0 <cprintf>

    cprintf("exit pass.\n");
  8005f6:	00000517          	auipc	a0,0x0
  8005fa:	51a50513          	addi	a0,a0,1306 # 800b10 <error_string+0x2e0>
  8005fe:	aa3ff0ef          	jal	ra,8000a0 <cprintf>
    return 0;
}
  800602:	60e2                	ld	ra,24(sp)
  800604:	6442                	ld	s0,16(sp)
  800606:	4501                	li	a0,0
  800608:	6105                	addi	sp,sp,32
  80060a:	8082                	ret
    assert(waitpid(pid, &code) == 0 && code == magic);
  80060c:	00000697          	auipc	a3,0x0
  800610:	49c68693          	addi	a3,a3,1180 # 800aa8 <error_string+0x278>
  800614:	00000617          	auipc	a2,0x0
  800618:	44c60613          	addi	a2,a2,1100 # 800a60 <error_string+0x230>
  80061c:	45ed                	li	a1,27
  80061e:	00000517          	auipc	a0,0x0
  800622:	45a50513          	addi	a0,a0,1114 # 800a78 <error_string+0x248>
  800626:	a01ff0ef          	jal	ra,800026 <__panic>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  80062a:	00000697          	auipc	a3,0x0
  80062e:	4ae68693          	addi	a3,a3,1198 # 800ad8 <error_string+0x2a8>
  800632:	00000617          	auipc	a2,0x0
  800636:	42e60613          	addi	a2,a2,1070 # 800a60 <error_string+0x230>
  80063a:	45f1                	li	a1,28
  80063c:	00000517          	auipc	a0,0x0
  800640:	43c50513          	addi	a0,a0,1084 # 800a78 <error_string+0x248>
  800644:	9e3ff0ef          	jal	ra,800026 <__panic>
    assert(pid > 0);
  800648:	00000697          	auipc	a3,0x0
  80064c:	41068693          	addi	a3,a3,1040 # 800a58 <error_string+0x228>
  800650:	00000617          	auipc	a2,0x0
  800654:	41060613          	addi	a2,a2,1040 # 800a60 <error_string+0x230>
  800658:	45e1                	li	a1,24
  80065a:	00000517          	auipc	a0,0x0
  80065e:	41e50513          	addi	a0,a0,1054 # 800a78 <error_string+0x248>
  800662:	9c5ff0ef          	jal	ra,800026 <__panic>
        cprintf("I am the child.\n");
  800666:	00000517          	auipc	a0,0x0
  80066a:	3b250513          	addi	a0,a0,946 # 800a18 <error_string+0x1e8>
  80066e:	a33ff0ef          	jal	ra,8000a0 <cprintf>
        yield();
  800672:	ae7ff0ef          	jal	ra,800158 <yield>
        yield();
  800676:	ae3ff0ef          	jal	ra,800158 <yield>
        yield();
  80067a:	adfff0ef          	jal	ra,800158 <yield>
        yield();
  80067e:	adbff0ef          	jal	ra,800158 <yield>
        yield();
  800682:	ad7ff0ef          	jal	ra,800158 <yield>
        yield();
  800686:	ad3ff0ef          	jal	ra,800158 <yield>
        yield();
  80068a:	acfff0ef          	jal	ra,800158 <yield>
        exit(magic);
  80068e:	00001797          	auipc	a5,0x1
  800692:	97278793          	addi	a5,a5,-1678 # 801000 <magic>
  800696:	4388                	lw	a0,0(a5)
  800698:	a9bff0ef          	jal	ra,800132 <exit>
