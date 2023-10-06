
obj/__user_badarg.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  800020:	134000ef          	jal	ra,800154 <umain>
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
  800038:	63c50513          	addi	a0,a0,1596 # 800670 <main+0xf2>
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
  800094:	138000ef          	jal	ra,8001cc <vprintfmt>
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
  8000c8:	104000ef          	jal	ra,8001cc <vprintfmt>
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
  80013e:	55650513          	addi	a0,a0,1366 # 800690 <main+0x112>
  800142:	f5fff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  800146:	a001                	j	800146 <exit+0x14>

0000000000800148 <fork>:
}

int
fork(void) {
    return sys_fork();
  800148:	fcdff06f          	j	800114 <sys_fork>

000000000080014c <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  80014c:	fcfff06f          	j	80011a <sys_wait>

0000000000800150 <yield>:
}

void
yield(void) {
    sys_yield();
  800150:	fd5ff06f          	j	800124 <sys_yield>

0000000000800154 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800154:	1141                	addi	sp,sp,-16
  800156:	e406                	sd	ra,8(sp)
    int ret = main();
  800158:	426000ef          	jal	ra,80057e <main>
    exit(ret);
  80015c:	fd7ff0ef          	jal	ra,800132 <exit>

0000000000800160 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800160:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800164:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800166:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80016a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80016c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800170:	f022                	sd	s0,32(sp)
  800172:	ec26                	sd	s1,24(sp)
  800174:	e84a                	sd	s2,16(sp)
  800176:	f406                	sd	ra,40(sp)
  800178:	e44e                	sd	s3,8(sp)
  80017a:	84aa                	mv	s1,a0
  80017c:	892e                	mv	s2,a1
  80017e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800182:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800184:	03067e63          	bleu	a6,a2,8001c0 <printnum+0x60>
  800188:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80018a:	00805763          	blez	s0,800198 <printnum+0x38>
  80018e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800190:	85ca                	mv	a1,s2
  800192:	854e                	mv	a0,s3
  800194:	9482                	jalr	s1
        while (-- width > 0)
  800196:	fc65                	bnez	s0,80018e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800198:	1a02                	slli	s4,s4,0x20
  80019a:	020a5a13          	srli	s4,s4,0x20
  80019e:	00000797          	auipc	a5,0x0
  8001a2:	72a78793          	addi	a5,a5,1834 # 8008c8 <error_string+0xc8>
  8001a6:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001a8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001aa:	000a4503          	lbu	a0,0(s4)
}
  8001ae:	70a2                	ld	ra,40(sp)
  8001b0:	69a2                	ld	s3,8(sp)
  8001b2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b4:	85ca                	mv	a1,s2
  8001b6:	8326                	mv	t1,s1
}
  8001b8:	6942                	ld	s2,16(sp)
  8001ba:	64e2                	ld	s1,24(sp)
  8001bc:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001be:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001c0:	03065633          	divu	a2,a2,a6
  8001c4:	8722                	mv	a4,s0
  8001c6:	f9bff0ef          	jal	ra,800160 <printnum>
  8001ca:	b7f9                	j	800198 <printnum+0x38>

00000000008001cc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001cc:	7119                	addi	sp,sp,-128
  8001ce:	f4a6                	sd	s1,104(sp)
  8001d0:	f0ca                	sd	s2,96(sp)
  8001d2:	e8d2                	sd	s4,80(sp)
  8001d4:	e4d6                	sd	s5,72(sp)
  8001d6:	e0da                	sd	s6,64(sp)
  8001d8:	fc5e                	sd	s7,56(sp)
  8001da:	f862                	sd	s8,48(sp)
  8001dc:	f06a                	sd	s10,32(sp)
  8001de:	fc86                	sd	ra,120(sp)
  8001e0:	f8a2                	sd	s0,112(sp)
  8001e2:	ecce                	sd	s3,88(sp)
  8001e4:	f466                	sd	s9,40(sp)
  8001e6:	ec6e                	sd	s11,24(sp)
  8001e8:	892a                	mv	s2,a0
  8001ea:	84ae                	mv	s1,a1
  8001ec:	8d32                	mv	s10,a2
  8001ee:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001f0:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001f2:	00000a17          	auipc	s4,0x0
  8001f6:	4b2a0a13          	addi	s4,s4,1202 # 8006a4 <main+0x126>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  8001fa:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001fe:	00000c17          	auipc	s8,0x0
  800202:	602c0c13          	addi	s8,s8,1538 # 800800 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800206:	000d4503          	lbu	a0,0(s10)
  80020a:	02500793          	li	a5,37
  80020e:	001d0413          	addi	s0,s10,1
  800212:	00f50e63          	beq	a0,a5,80022e <vprintfmt+0x62>
            if (ch == '\0') {
  800216:	c521                	beqz	a0,80025e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800218:	02500993          	li	s3,37
  80021c:	a011                	j	800220 <vprintfmt+0x54>
            if (ch == '\0') {
  80021e:	c121                	beqz	a0,80025e <vprintfmt+0x92>
            putch(ch, putdat);
  800220:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800222:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800224:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800226:	fff44503          	lbu	a0,-1(s0)
  80022a:	ff351ae3          	bne	a0,s3,80021e <vprintfmt+0x52>
  80022e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800232:	02000793          	li	a5,32
        lflag = altflag = 0;
  800236:	4981                	li	s3,0
  800238:	4801                	li	a6,0
        width = precision = -1;
  80023a:	5cfd                	li	s9,-1
  80023c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  80023e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800242:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800244:	fdd6069b          	addiw	a3,a2,-35
  800248:	0ff6f693          	andi	a3,a3,255
  80024c:	00140d13          	addi	s10,s0,1
  800250:	20d5e563          	bltu	a1,a3,80045a <vprintfmt+0x28e>
  800254:	068a                	slli	a3,a3,0x2
  800256:	96d2                	add	a3,a3,s4
  800258:	4294                	lw	a3,0(a3)
  80025a:	96d2                	add	a3,a3,s4
  80025c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80025e:	70e6                	ld	ra,120(sp)
  800260:	7446                	ld	s0,112(sp)
  800262:	74a6                	ld	s1,104(sp)
  800264:	7906                	ld	s2,96(sp)
  800266:	69e6                	ld	s3,88(sp)
  800268:	6a46                	ld	s4,80(sp)
  80026a:	6aa6                	ld	s5,72(sp)
  80026c:	6b06                	ld	s6,64(sp)
  80026e:	7be2                	ld	s7,56(sp)
  800270:	7c42                	ld	s8,48(sp)
  800272:	7ca2                	ld	s9,40(sp)
  800274:	7d02                	ld	s10,32(sp)
  800276:	6de2                	ld	s11,24(sp)
  800278:	6109                	addi	sp,sp,128
  80027a:	8082                	ret
    if (lflag >= 2) {
  80027c:	4705                	li	a4,1
  80027e:	008a8593          	addi	a1,s5,8
  800282:	01074463          	blt	a4,a6,80028a <vprintfmt+0xbe>
    else if (lflag) {
  800286:	26080363          	beqz	a6,8004ec <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  80028a:	000ab603          	ld	a2,0(s5)
  80028e:	46c1                	li	a3,16
  800290:	8aae                	mv	s5,a1
  800292:	a06d                	j	80033c <vprintfmt+0x170>
            goto reswitch;
  800294:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800298:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  80029a:	846a                	mv	s0,s10
            goto reswitch;
  80029c:	b765                	j	800244 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  80029e:	000aa503          	lw	a0,0(s5)
  8002a2:	85a6                	mv	a1,s1
  8002a4:	0aa1                	addi	s5,s5,8
  8002a6:	9902                	jalr	s2
            break;
  8002a8:	bfb9                	j	800206 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002aa:	4705                	li	a4,1
  8002ac:	008a8993          	addi	s3,s5,8
  8002b0:	01074463          	blt	a4,a6,8002b8 <vprintfmt+0xec>
    else if (lflag) {
  8002b4:	22080463          	beqz	a6,8004dc <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002b8:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002bc:	24044463          	bltz	s0,800504 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002c0:	8622                	mv	a2,s0
  8002c2:	8ace                	mv	s5,s3
  8002c4:	46a9                	li	a3,10
  8002c6:	a89d                	j	80033c <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002c8:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002cc:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002ce:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002d0:	41f7d69b          	sraiw	a3,a5,0x1f
  8002d4:	8fb5                	xor	a5,a5,a3
  8002d6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002da:	1ad74363          	blt	a4,a3,800480 <vprintfmt+0x2b4>
  8002de:	00369793          	slli	a5,a3,0x3
  8002e2:	97e2                	add	a5,a5,s8
  8002e4:	639c                	ld	a5,0(a5)
  8002e6:	18078d63          	beqz	a5,800480 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  8002ea:	86be                	mv	a3,a5
  8002ec:	00000617          	auipc	a2,0x0
  8002f0:	6cc60613          	addi	a2,a2,1740 # 8009b8 <error_string+0x1b8>
  8002f4:	85a6                	mv	a1,s1
  8002f6:	854a                	mv	a0,s2
  8002f8:	240000ef          	jal	ra,800538 <printfmt>
  8002fc:	b729                	j	800206 <vprintfmt+0x3a>
            lflag ++;
  8002fe:	00144603          	lbu	a2,1(s0)
  800302:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800304:	846a                	mv	s0,s10
            goto reswitch;
  800306:	bf3d                	j	800244 <vprintfmt+0x78>
    if (lflag >= 2) {
  800308:	4705                	li	a4,1
  80030a:	008a8593          	addi	a1,s5,8
  80030e:	01074463          	blt	a4,a6,800316 <vprintfmt+0x14a>
    else if (lflag) {
  800312:	1e080263          	beqz	a6,8004f6 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  800316:	000ab603          	ld	a2,0(s5)
  80031a:	46a1                	li	a3,8
  80031c:	8aae                	mv	s5,a1
  80031e:	a839                	j	80033c <vprintfmt+0x170>
            putch('0', putdat);
  800320:	03000513          	li	a0,48
  800324:	85a6                	mv	a1,s1
  800326:	e03e                	sd	a5,0(sp)
  800328:	9902                	jalr	s2
            putch('x', putdat);
  80032a:	85a6                	mv	a1,s1
  80032c:	07800513          	li	a0,120
  800330:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800332:	0aa1                	addi	s5,s5,8
  800334:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800338:	6782                	ld	a5,0(sp)
  80033a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  80033c:	876e                	mv	a4,s11
  80033e:	85a6                	mv	a1,s1
  800340:	854a                	mv	a0,s2
  800342:	e1fff0ef          	jal	ra,800160 <printnum>
            break;
  800346:	b5c1                	j	800206 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800348:	000ab603          	ld	a2,0(s5)
  80034c:	0aa1                	addi	s5,s5,8
  80034e:	1c060663          	beqz	a2,80051a <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  800352:	00160413          	addi	s0,a2,1
  800356:	17b05c63          	blez	s11,8004ce <vprintfmt+0x302>
  80035a:	02d00593          	li	a1,45
  80035e:	14b79263          	bne	a5,a1,8004a2 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800362:	00064783          	lbu	a5,0(a2)
  800366:	0007851b          	sext.w	a0,a5
  80036a:	c905                	beqz	a0,80039a <vprintfmt+0x1ce>
  80036c:	000cc563          	bltz	s9,800376 <vprintfmt+0x1aa>
  800370:	3cfd                	addiw	s9,s9,-1
  800372:	036c8263          	beq	s9,s6,800396 <vprintfmt+0x1ca>
                    putch('?', putdat);
  800376:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800378:	18098463          	beqz	s3,800500 <vprintfmt+0x334>
  80037c:	3781                	addiw	a5,a5,-32
  80037e:	18fbf163          	bleu	a5,s7,800500 <vprintfmt+0x334>
                    putch('?', putdat);
  800382:	03f00513          	li	a0,63
  800386:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800388:	0405                	addi	s0,s0,1
  80038a:	fff44783          	lbu	a5,-1(s0)
  80038e:	3dfd                	addiw	s11,s11,-1
  800390:	0007851b          	sext.w	a0,a5
  800394:	fd61                	bnez	a0,80036c <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  800396:	e7b058e3          	blez	s11,800206 <vprintfmt+0x3a>
  80039a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80039c:	85a6                	mv	a1,s1
  80039e:	02000513          	li	a0,32
  8003a2:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003a4:	e60d81e3          	beqz	s11,800206 <vprintfmt+0x3a>
  8003a8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003aa:	85a6                	mv	a1,s1
  8003ac:	02000513          	li	a0,32
  8003b0:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003b2:	fe0d94e3          	bnez	s11,80039a <vprintfmt+0x1ce>
  8003b6:	bd81                	j	800206 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003b8:	4705                	li	a4,1
  8003ba:	008a8593          	addi	a1,s5,8
  8003be:	01074463          	blt	a4,a6,8003c6 <vprintfmt+0x1fa>
    else if (lflag) {
  8003c2:	12080063          	beqz	a6,8004e2 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003c6:	000ab603          	ld	a2,0(s5)
  8003ca:	46a9                	li	a3,10
  8003cc:	8aae                	mv	s5,a1
  8003ce:	b7bd                	j	80033c <vprintfmt+0x170>
  8003d0:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003d4:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  8003d8:	846a                	mv	s0,s10
  8003da:	b5ad                	j	800244 <vprintfmt+0x78>
            putch(ch, putdat);
  8003dc:	85a6                	mv	a1,s1
  8003de:	02500513          	li	a0,37
  8003e2:	9902                	jalr	s2
            break;
  8003e4:	b50d                	j	800206 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  8003e6:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8003ea:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8003ee:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8003f0:	846a                	mv	s0,s10
            if (width < 0)
  8003f2:	e40dd9e3          	bgez	s11,800244 <vprintfmt+0x78>
                width = precision, precision = -1;
  8003f6:	8de6                	mv	s11,s9
  8003f8:	5cfd                	li	s9,-1
  8003fa:	b5a9                	j	800244 <vprintfmt+0x78>
            goto reswitch;
  8003fc:	00144603          	lbu	a2,1(s0)
            padc = '0';
  800400:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  800404:	846a                	mv	s0,s10
            goto reswitch;
  800406:	bd3d                	j	800244 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800408:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  80040c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800410:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800412:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800416:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80041a:	fcd56ce3          	bltu	a0,a3,8003f2 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  80041e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800420:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800424:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800428:	0196873b          	addw	a4,a3,s9
  80042c:	0017171b          	slliw	a4,a4,0x1
  800430:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800434:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800438:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80043c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800440:	fcd57fe3          	bleu	a3,a0,80041e <vprintfmt+0x252>
  800444:	b77d                	j	8003f2 <vprintfmt+0x226>
            if (width < 0)
  800446:	fffdc693          	not	a3,s11
  80044a:	96fd                	srai	a3,a3,0x3f
  80044c:	00ddfdb3          	and	s11,s11,a3
  800450:	00144603          	lbu	a2,1(s0)
  800454:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800456:	846a                	mv	s0,s10
  800458:	b3f5                	j	800244 <vprintfmt+0x78>
            putch('%', putdat);
  80045a:	85a6                	mv	a1,s1
  80045c:	02500513          	li	a0,37
  800460:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800462:	fff44703          	lbu	a4,-1(s0)
  800466:	02500793          	li	a5,37
  80046a:	8d22                	mv	s10,s0
  80046c:	d8f70de3          	beq	a4,a5,800206 <vprintfmt+0x3a>
  800470:	02500713          	li	a4,37
  800474:	1d7d                	addi	s10,s10,-1
  800476:	fffd4783          	lbu	a5,-1(s10)
  80047a:	fee79de3          	bne	a5,a4,800474 <vprintfmt+0x2a8>
  80047e:	b361                	j	800206 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800480:	00000617          	auipc	a2,0x0
  800484:	52860613          	addi	a2,a2,1320 # 8009a8 <error_string+0x1a8>
  800488:	85a6                	mv	a1,s1
  80048a:	854a                	mv	a0,s2
  80048c:	0ac000ef          	jal	ra,800538 <printfmt>
  800490:	bb9d                	j	800206 <vprintfmt+0x3a>
                p = "(null)";
  800492:	00000617          	auipc	a2,0x0
  800496:	50e60613          	addi	a2,a2,1294 # 8009a0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  80049a:	00000417          	auipc	s0,0x0
  80049e:	50740413          	addi	s0,s0,1287 # 8009a1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a2:	8532                	mv	a0,a2
  8004a4:	85e6                	mv	a1,s9
  8004a6:	e032                	sd	a2,0(sp)
  8004a8:	e43e                	sd	a5,8(sp)
  8004aa:	0ae000ef          	jal	ra,800558 <strnlen>
  8004ae:	40ad8dbb          	subw	s11,s11,a0
  8004b2:	6602                	ld	a2,0(sp)
  8004b4:	01b05d63          	blez	s11,8004ce <vprintfmt+0x302>
  8004b8:	67a2                	ld	a5,8(sp)
  8004ba:	2781                	sext.w	a5,a5
  8004bc:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004be:	6522                	ld	a0,8(sp)
  8004c0:	85a6                	mv	a1,s1
  8004c2:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c4:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004c6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c8:	6602                	ld	a2,0(sp)
  8004ca:	fe0d9ae3          	bnez	s11,8004be <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ce:	00064783          	lbu	a5,0(a2)
  8004d2:	0007851b          	sext.w	a0,a5
  8004d6:	e8051be3          	bnez	a0,80036c <vprintfmt+0x1a0>
  8004da:	b335                	j	800206 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  8004dc:	000aa403          	lw	s0,0(s5)
  8004e0:	bbf1                	j	8002bc <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  8004e2:	000ae603          	lwu	a2,0(s5)
  8004e6:	46a9                	li	a3,10
  8004e8:	8aae                	mv	s5,a1
  8004ea:	bd89                	j	80033c <vprintfmt+0x170>
  8004ec:	000ae603          	lwu	a2,0(s5)
  8004f0:	46c1                	li	a3,16
  8004f2:	8aae                	mv	s5,a1
  8004f4:	b5a1                	j	80033c <vprintfmt+0x170>
  8004f6:	000ae603          	lwu	a2,0(s5)
  8004fa:	46a1                	li	a3,8
  8004fc:	8aae                	mv	s5,a1
  8004fe:	bd3d                	j	80033c <vprintfmt+0x170>
                    putch(ch, putdat);
  800500:	9902                	jalr	s2
  800502:	b559                	j	800388 <vprintfmt+0x1bc>
                putch('-', putdat);
  800504:	85a6                	mv	a1,s1
  800506:	02d00513          	li	a0,45
  80050a:	e03e                	sd	a5,0(sp)
  80050c:	9902                	jalr	s2
                num = -(long long)num;
  80050e:	8ace                	mv	s5,s3
  800510:	40800633          	neg	a2,s0
  800514:	46a9                	li	a3,10
  800516:	6782                	ld	a5,0(sp)
  800518:	b515                	j	80033c <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  80051a:	01b05663          	blez	s11,800526 <vprintfmt+0x35a>
  80051e:	02d00693          	li	a3,45
  800522:	f6d798e3          	bne	a5,a3,800492 <vprintfmt+0x2c6>
  800526:	00000417          	auipc	s0,0x0
  80052a:	47b40413          	addi	s0,s0,1147 # 8009a1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80052e:	02800513          	li	a0,40
  800532:	02800793          	li	a5,40
  800536:	bd1d                	j	80036c <vprintfmt+0x1a0>

0000000000800538 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800538:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80053a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80053e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800540:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800542:	ec06                	sd	ra,24(sp)
  800544:	f83a                	sd	a4,48(sp)
  800546:	fc3e                	sd	a5,56(sp)
  800548:	e0c2                	sd	a6,64(sp)
  80054a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80054c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80054e:	c7fff0ef          	jal	ra,8001cc <vprintfmt>
}
  800552:	60e2                	ld	ra,24(sp)
  800554:	6161                	addi	sp,sp,80
  800556:	8082                	ret

0000000000800558 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800558:	c185                	beqz	a1,800578 <strnlen+0x20>
  80055a:	00054783          	lbu	a5,0(a0)
  80055e:	cf89                	beqz	a5,800578 <strnlen+0x20>
    size_t cnt = 0;
  800560:	4781                	li	a5,0
  800562:	a021                	j	80056a <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800564:	00074703          	lbu	a4,0(a4)
  800568:	c711                	beqz	a4,800574 <strnlen+0x1c>
        cnt ++;
  80056a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80056c:	00f50733          	add	a4,a0,a5
  800570:	fef59ae3          	bne	a1,a5,800564 <strnlen+0xc>
    }
    return cnt;
}
  800574:	853e                	mv	a0,a5
  800576:	8082                	ret
    size_t cnt = 0;
  800578:	4781                	li	a5,0
}
  80057a:	853e                	mv	a0,a5
  80057c:	8082                	ret

000000000080057e <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  80057e:	1101                	addi	sp,sp,-32
  800580:	ec06                	sd	ra,24(sp)
  800582:	e822                	sd	s0,16(sp)
    int pid, exit_code;
    if ((pid = fork()) == 0) {
  800584:	bc5ff0ef          	jal	ra,800148 <fork>
  800588:	c169                	beqz	a0,80064a <main+0xcc>
  80058a:	842a                	mv	s0,a0
        for (i = 0; i < 10; i ++) {
            yield();
        }
        exit(0xbeaf);
    }
    assert(pid > 0);
  80058c:	0aa05063          	blez	a0,80062c <main+0xae>
    assert(waitpid(-1, NULL) != 0);
  800590:	4581                	li	a1,0
  800592:	557d                	li	a0,-1
  800594:	bb9ff0ef          	jal	ra,80014c <waitpid>
  800598:	c93d                	beqz	a0,80060e <main+0x90>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  80059a:	458d                	li	a1,3
  80059c:	05fa                	slli	a1,a1,0x1e
  80059e:	8522                	mv	a0,s0
  8005a0:	badff0ef          	jal	ra,80014c <waitpid>
  8005a4:	c531                	beqz	a0,8005f0 <main+0x72>
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  8005a6:	006c                	addi	a1,sp,12
  8005a8:	8522                	mv	a0,s0
  8005aa:	ba3ff0ef          	jal	ra,80014c <waitpid>
  8005ae:	e115                	bnez	a0,8005d2 <main+0x54>
  8005b0:	4732                	lw	a4,12(sp)
  8005b2:	67b1                	lui	a5,0xc
  8005b4:	eaf78793          	addi	a5,a5,-337 # beaf <_start-0x7f4171>
  8005b8:	00f71d63          	bne	a4,a5,8005d2 <main+0x54>
    cprintf("badarg pass.\n");
  8005bc:	00000517          	auipc	a0,0x0
  8005c0:	4bc50513          	addi	a0,a0,1212 # 800a78 <error_string+0x278>
  8005c4:	addff0ef          	jal	ra,8000a0 <cprintf>
    return 0;
}
  8005c8:	60e2                	ld	ra,24(sp)
  8005ca:	6442                	ld	s0,16(sp)
  8005cc:	4501                	li	a0,0
  8005ce:	6105                	addi	sp,sp,32
  8005d0:	8082                	ret
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  8005d2:	00000697          	auipc	a3,0x0
  8005d6:	46e68693          	addi	a3,a3,1134 # 800a40 <error_string+0x240>
  8005da:	00000617          	auipc	a2,0x0
  8005de:	3fe60613          	addi	a2,a2,1022 # 8009d8 <error_string+0x1d8>
  8005e2:	45c9                	li	a1,18
  8005e4:	00000517          	auipc	a0,0x0
  8005e8:	40c50513          	addi	a0,a0,1036 # 8009f0 <error_string+0x1f0>
  8005ec:	a3bff0ef          	jal	ra,800026 <__panic>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  8005f0:	00000697          	auipc	a3,0x0
  8005f4:	42868693          	addi	a3,a3,1064 # 800a18 <error_string+0x218>
  8005f8:	00000617          	auipc	a2,0x0
  8005fc:	3e060613          	addi	a2,a2,992 # 8009d8 <error_string+0x1d8>
  800600:	45c5                	li	a1,17
  800602:	00000517          	auipc	a0,0x0
  800606:	3ee50513          	addi	a0,a0,1006 # 8009f0 <error_string+0x1f0>
  80060a:	a1dff0ef          	jal	ra,800026 <__panic>
    assert(waitpid(-1, NULL) != 0);
  80060e:	00000697          	auipc	a3,0x0
  800612:	3f268693          	addi	a3,a3,1010 # 800a00 <error_string+0x200>
  800616:	00000617          	auipc	a2,0x0
  80061a:	3c260613          	addi	a2,a2,962 # 8009d8 <error_string+0x1d8>
  80061e:	45c1                	li	a1,16
  800620:	00000517          	auipc	a0,0x0
  800624:	3d050513          	addi	a0,a0,976 # 8009f0 <error_string+0x1f0>
  800628:	9ffff0ef          	jal	ra,800026 <__panic>
    assert(pid > 0);
  80062c:	00000697          	auipc	a3,0x0
  800630:	3a468693          	addi	a3,a3,932 # 8009d0 <error_string+0x1d0>
  800634:	00000617          	auipc	a2,0x0
  800638:	3a460613          	addi	a2,a2,932 # 8009d8 <error_string+0x1d8>
  80063c:	45bd                	li	a1,15
  80063e:	00000517          	auipc	a0,0x0
  800642:	3b250513          	addi	a0,a0,946 # 8009f0 <error_string+0x1f0>
  800646:	9e1ff0ef          	jal	ra,800026 <__panic>
        cprintf("fork ok.\n");
  80064a:	00000517          	auipc	a0,0x0
  80064e:	37650513          	addi	a0,a0,886 # 8009c0 <error_string+0x1c0>
  800652:	a4fff0ef          	jal	ra,8000a0 <cprintf>
  800656:	4429                	li	s0,10
            yield();
  800658:	347d                	addiw	s0,s0,-1
  80065a:	af7ff0ef          	jal	ra,800150 <yield>
        for (i = 0; i < 10; i ++) {
  80065e:	fc6d                	bnez	s0,800658 <main+0xda>
        exit(0xbeaf);
  800660:	6531                	lui	a0,0xc
  800662:	eaf50513          	addi	a0,a0,-337 # beaf <_start-0x7f4171>
  800666:	acdff0ef          	jal	ra,800132 <exit>
