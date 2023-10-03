
obj/__user_spin.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	142000ef          	jal	ra,800162 <umain>
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
  800038:	62450513          	addi	a0,a0,1572 # 800658 <main+0xcc>
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
  800058:	62450513          	addi	a0,a0,1572 # 800678 <main+0xec>
  80005c:	044000ef          	jal	ra,8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800060:	5559                	li	a0,-10
  800062:	0da000ef          	jal	ra,80013c <exit>

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
  80006e:	0c6000ef          	jal	ra,800134 <sys_putc>
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
  800094:	146000ef          	jal	ra,8001da <vprintfmt>
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
  8000c8:	112000ef          	jal	ra,8001da <vprintfmt>
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

000000000080012c <sys_kill>:
}

int
sys_kill(int64_t pid) {
    return syscall(SYS_kill, pid);
  80012c:	85aa                	mv	a1,a0
  80012e:	4531                	li	a0,12
  800130:	fa5ff06f          	j	8000d4 <syscall>

0000000000800134 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  800134:	85aa                	mv	a1,a0
  800136:	4579                	li	a0,30
  800138:	f9dff06f          	j	8000d4 <syscall>

000000000080013c <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80013c:	1141                	addi	sp,sp,-16
  80013e:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800140:	fcfff0ef          	jal	ra,80010e <sys_exit>
    cprintf("BUG: exit failed.\n");
  800144:	00000517          	auipc	a0,0x0
  800148:	53c50513          	addi	a0,a0,1340 # 800680 <main+0xf4>
  80014c:	f55ff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  800150:	a001                	j	800150 <exit+0x14>

0000000000800152 <fork>:
}

int
fork(void) {
    return sys_fork();
  800152:	fc5ff06f          	j	800116 <sys_fork>

0000000000800156 <waitpid>:
    return sys_wait(0, NULL);
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

000000000080015e <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  80015e:	fcfff06f          	j	80012c <sys_kill>

0000000000800162 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800162:	1141                	addi	sp,sp,-16
  800164:	e406                	sd	ra,8(sp)
    int ret = main();
  800166:	426000ef          	jal	ra,80058c <main>
    exit(ret);
  80016a:	fd3ff0ef          	jal	ra,80013c <exit>

000000000080016e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80016e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800172:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800174:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800178:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80017a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80017e:	f022                	sd	s0,32(sp)
  800180:	ec26                	sd	s1,24(sp)
  800182:	e84a                	sd	s2,16(sp)
  800184:	f406                	sd	ra,40(sp)
  800186:	e44e                	sd	s3,8(sp)
  800188:	84aa                	mv	s1,a0
  80018a:	892e                	mv	s2,a1
  80018c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800190:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800192:	03067e63          	bleu	a6,a2,8001ce <printnum+0x60>
  800196:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800198:	00805763          	blez	s0,8001a6 <printnum+0x38>
  80019c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80019e:	85ca                	mv	a1,s2
  8001a0:	854e                	mv	a0,s3
  8001a2:	9482                	jalr	s1
        while (-- width > 0)
  8001a4:	fc65                	bnez	s0,80019c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001a6:	1a02                	slli	s4,s4,0x20
  8001a8:	020a5a13          	srli	s4,s4,0x20
  8001ac:	00000797          	auipc	a5,0x0
  8001b0:	70c78793          	addi	a5,a5,1804 # 8008b8 <error_string+0xc8>
  8001b4:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001b6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b8:	000a4503          	lbu	a0,0(s4)
}
  8001bc:	70a2                	ld	ra,40(sp)
  8001be:	69a2                	ld	s3,8(sp)
  8001c0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001c2:	85ca                	mv	a1,s2
  8001c4:	8326                	mv	t1,s1
}
  8001c6:	6942                	ld	s2,16(sp)
  8001c8:	64e2                	ld	s1,24(sp)
  8001ca:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001cc:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001ce:	03065633          	divu	a2,a2,a6
  8001d2:	8722                	mv	a4,s0
  8001d4:	f9bff0ef          	jal	ra,80016e <printnum>
  8001d8:	b7f9                	j	8001a6 <printnum+0x38>

00000000008001da <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001da:	7119                	addi	sp,sp,-128
  8001dc:	f4a6                	sd	s1,104(sp)
  8001de:	f0ca                	sd	s2,96(sp)
  8001e0:	e8d2                	sd	s4,80(sp)
  8001e2:	e4d6                	sd	s5,72(sp)
  8001e4:	e0da                	sd	s6,64(sp)
  8001e6:	fc5e                	sd	s7,56(sp)
  8001e8:	f862                	sd	s8,48(sp)
  8001ea:	f06a                	sd	s10,32(sp)
  8001ec:	fc86                	sd	ra,120(sp)
  8001ee:	f8a2                	sd	s0,112(sp)
  8001f0:	ecce                	sd	s3,88(sp)
  8001f2:	f466                	sd	s9,40(sp)
  8001f4:	ec6e                	sd	s11,24(sp)
  8001f6:	892a                	mv	s2,a0
  8001f8:	84ae                	mv	s1,a1
  8001fa:	8d32                	mv	s10,a2
  8001fc:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001fe:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800200:	00000a17          	auipc	s4,0x0
  800204:	494a0a13          	addi	s4,s4,1172 # 800694 <main+0x108>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800208:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80020c:	00000c17          	auipc	s8,0x0
  800210:	5e4c0c13          	addi	s8,s8,1508 # 8007f0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800214:	000d4503          	lbu	a0,0(s10)
  800218:	02500793          	li	a5,37
  80021c:	001d0413          	addi	s0,s10,1
  800220:	00f50e63          	beq	a0,a5,80023c <vprintfmt+0x62>
            if (ch == '\0') {
  800224:	c521                	beqz	a0,80026c <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800226:	02500993          	li	s3,37
  80022a:	a011                	j	80022e <vprintfmt+0x54>
            if (ch == '\0') {
  80022c:	c121                	beqz	a0,80026c <vprintfmt+0x92>
            putch(ch, putdat);
  80022e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800230:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800232:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800234:	fff44503          	lbu	a0,-1(s0)
  800238:	ff351ae3          	bne	a0,s3,80022c <vprintfmt+0x52>
  80023c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800240:	02000793          	li	a5,32
        lflag = altflag = 0;
  800244:	4981                	li	s3,0
  800246:	4801                	li	a6,0
        width = precision = -1;
  800248:	5cfd                	li	s9,-1
  80024a:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  80024c:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800250:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800252:	fdd6069b          	addiw	a3,a2,-35
  800256:	0ff6f693          	andi	a3,a3,255
  80025a:	00140d13          	addi	s10,s0,1
  80025e:	20d5e563          	bltu	a1,a3,800468 <vprintfmt+0x28e>
  800262:	068a                	slli	a3,a3,0x2
  800264:	96d2                	add	a3,a3,s4
  800266:	4294                	lw	a3,0(a3)
  800268:	96d2                	add	a3,a3,s4
  80026a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80026c:	70e6                	ld	ra,120(sp)
  80026e:	7446                	ld	s0,112(sp)
  800270:	74a6                	ld	s1,104(sp)
  800272:	7906                	ld	s2,96(sp)
  800274:	69e6                	ld	s3,88(sp)
  800276:	6a46                	ld	s4,80(sp)
  800278:	6aa6                	ld	s5,72(sp)
  80027a:	6b06                	ld	s6,64(sp)
  80027c:	7be2                	ld	s7,56(sp)
  80027e:	7c42                	ld	s8,48(sp)
  800280:	7ca2                	ld	s9,40(sp)
  800282:	7d02                	ld	s10,32(sp)
  800284:	6de2                	ld	s11,24(sp)
  800286:	6109                	addi	sp,sp,128
  800288:	8082                	ret
    if (lflag >= 2) {
  80028a:	4705                	li	a4,1
  80028c:	008a8593          	addi	a1,s5,8
  800290:	01074463          	blt	a4,a6,800298 <vprintfmt+0xbe>
    else if (lflag) {
  800294:	26080363          	beqz	a6,8004fa <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  800298:	000ab603          	ld	a2,0(s5)
  80029c:	46c1                	li	a3,16
  80029e:	8aae                	mv	s5,a1
  8002a0:	a06d                	j	80034a <vprintfmt+0x170>
            goto reswitch;
  8002a2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002a6:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002a8:	846a                	mv	s0,s10
            goto reswitch;
  8002aa:	b765                	j	800252 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  8002ac:	000aa503          	lw	a0,0(s5)
  8002b0:	85a6                	mv	a1,s1
  8002b2:	0aa1                	addi	s5,s5,8
  8002b4:	9902                	jalr	s2
            break;
  8002b6:	bfb9                	j	800214 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002b8:	4705                	li	a4,1
  8002ba:	008a8993          	addi	s3,s5,8
  8002be:	01074463          	blt	a4,a6,8002c6 <vprintfmt+0xec>
    else if (lflag) {
  8002c2:	22080463          	beqz	a6,8004ea <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002c6:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002ca:	24044463          	bltz	s0,800512 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002ce:	8622                	mv	a2,s0
  8002d0:	8ace                	mv	s5,s3
  8002d2:	46a9                	li	a3,10
  8002d4:	a89d                	j	80034a <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002d6:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002da:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002dc:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002de:	41f7d69b          	sraiw	a3,a5,0x1f
  8002e2:	8fb5                	xor	a5,a5,a3
  8002e4:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002e8:	1ad74363          	blt	a4,a3,80048e <vprintfmt+0x2b4>
  8002ec:	00369793          	slli	a5,a3,0x3
  8002f0:	97e2                	add	a5,a5,s8
  8002f2:	639c                	ld	a5,0(a5)
  8002f4:	18078d63          	beqz	a5,80048e <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  8002f8:	86be                	mv	a3,a5
  8002fa:	00000617          	auipc	a2,0x0
  8002fe:	6ae60613          	addi	a2,a2,1710 # 8009a8 <error_string+0x1b8>
  800302:	85a6                	mv	a1,s1
  800304:	854a                	mv	a0,s2
  800306:	240000ef          	jal	ra,800546 <printfmt>
  80030a:	b729                	j	800214 <vprintfmt+0x3a>
            lflag ++;
  80030c:	00144603          	lbu	a2,1(s0)
  800310:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800312:	846a                	mv	s0,s10
            goto reswitch;
  800314:	bf3d                	j	800252 <vprintfmt+0x78>
    if (lflag >= 2) {
  800316:	4705                	li	a4,1
  800318:	008a8593          	addi	a1,s5,8
  80031c:	01074463          	blt	a4,a6,800324 <vprintfmt+0x14a>
    else if (lflag) {
  800320:	1e080263          	beqz	a6,800504 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  800324:	000ab603          	ld	a2,0(s5)
  800328:	46a1                	li	a3,8
  80032a:	8aae                	mv	s5,a1
  80032c:	a839                	j	80034a <vprintfmt+0x170>
            putch('0', putdat);
  80032e:	03000513          	li	a0,48
  800332:	85a6                	mv	a1,s1
  800334:	e03e                	sd	a5,0(sp)
  800336:	9902                	jalr	s2
            putch('x', putdat);
  800338:	85a6                	mv	a1,s1
  80033a:	07800513          	li	a0,120
  80033e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800340:	0aa1                	addi	s5,s5,8
  800342:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800346:	6782                	ld	a5,0(sp)
  800348:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  80034a:	876e                	mv	a4,s11
  80034c:	85a6                	mv	a1,s1
  80034e:	854a                	mv	a0,s2
  800350:	e1fff0ef          	jal	ra,80016e <printnum>
            break;
  800354:	b5c1                	j	800214 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800356:	000ab603          	ld	a2,0(s5)
  80035a:	0aa1                	addi	s5,s5,8
  80035c:	1c060663          	beqz	a2,800528 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  800360:	00160413          	addi	s0,a2,1
  800364:	17b05c63          	blez	s11,8004dc <vprintfmt+0x302>
  800368:	02d00593          	li	a1,45
  80036c:	14b79263          	bne	a5,a1,8004b0 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800370:	00064783          	lbu	a5,0(a2)
  800374:	0007851b          	sext.w	a0,a5
  800378:	c905                	beqz	a0,8003a8 <vprintfmt+0x1ce>
  80037a:	000cc563          	bltz	s9,800384 <vprintfmt+0x1aa>
  80037e:	3cfd                	addiw	s9,s9,-1
  800380:	036c8263          	beq	s9,s6,8003a4 <vprintfmt+0x1ca>
                    putch('?', putdat);
  800384:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800386:	18098463          	beqz	s3,80050e <vprintfmt+0x334>
  80038a:	3781                	addiw	a5,a5,-32
  80038c:	18fbf163          	bleu	a5,s7,80050e <vprintfmt+0x334>
                    putch('?', putdat);
  800390:	03f00513          	li	a0,63
  800394:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800396:	0405                	addi	s0,s0,1
  800398:	fff44783          	lbu	a5,-1(s0)
  80039c:	3dfd                	addiw	s11,s11,-1
  80039e:	0007851b          	sext.w	a0,a5
  8003a2:	fd61                	bnez	a0,80037a <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  8003a4:	e7b058e3          	blez	s11,800214 <vprintfmt+0x3a>
  8003a8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003aa:	85a6                	mv	a1,s1
  8003ac:	02000513          	li	a0,32
  8003b0:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003b2:	e60d81e3          	beqz	s11,800214 <vprintfmt+0x3a>
  8003b6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003b8:	85a6                	mv	a1,s1
  8003ba:	02000513          	li	a0,32
  8003be:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003c0:	fe0d94e3          	bnez	s11,8003a8 <vprintfmt+0x1ce>
  8003c4:	bd81                	j	800214 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003c6:	4705                	li	a4,1
  8003c8:	008a8593          	addi	a1,s5,8
  8003cc:	01074463          	blt	a4,a6,8003d4 <vprintfmt+0x1fa>
    else if (lflag) {
  8003d0:	12080063          	beqz	a6,8004f0 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003d4:	000ab603          	ld	a2,0(s5)
  8003d8:	46a9                	li	a3,10
  8003da:	8aae                	mv	s5,a1
  8003dc:	b7bd                	j	80034a <vprintfmt+0x170>
  8003de:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003e2:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  8003e6:	846a                	mv	s0,s10
  8003e8:	b5ad                	j	800252 <vprintfmt+0x78>
            putch(ch, putdat);
  8003ea:	85a6                	mv	a1,s1
  8003ec:	02500513          	li	a0,37
  8003f0:	9902                	jalr	s2
            break;
  8003f2:	b50d                	j	800214 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  8003f4:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8003f8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8003fc:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8003fe:	846a                	mv	s0,s10
            if (width < 0)
  800400:	e40dd9e3          	bgez	s11,800252 <vprintfmt+0x78>
                width = precision, precision = -1;
  800404:	8de6                	mv	s11,s9
  800406:	5cfd                	li	s9,-1
  800408:	b5a9                	j	800252 <vprintfmt+0x78>
            goto reswitch;
  80040a:	00144603          	lbu	a2,1(s0)
            padc = '0';
  80040e:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  800412:	846a                	mv	s0,s10
            goto reswitch;
  800414:	bd3d                	j	800252 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800416:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  80041a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80041e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800420:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800424:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800428:	fcd56ce3          	bltu	a0,a3,800400 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  80042c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80042e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800432:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800436:	0196873b          	addw	a4,a3,s9
  80043a:	0017171b          	slliw	a4,a4,0x1
  80043e:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800442:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800446:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80044a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80044e:	fcd57fe3          	bleu	a3,a0,80042c <vprintfmt+0x252>
  800452:	b77d                	j	800400 <vprintfmt+0x226>
            if (width < 0)
  800454:	fffdc693          	not	a3,s11
  800458:	96fd                	srai	a3,a3,0x3f
  80045a:	00ddfdb3          	and	s11,s11,a3
  80045e:	00144603          	lbu	a2,1(s0)
  800462:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800464:	846a                	mv	s0,s10
  800466:	b3f5                	j	800252 <vprintfmt+0x78>
            putch('%', putdat);
  800468:	85a6                	mv	a1,s1
  80046a:	02500513          	li	a0,37
  80046e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800470:	fff44703          	lbu	a4,-1(s0)
  800474:	02500793          	li	a5,37
  800478:	8d22                	mv	s10,s0
  80047a:	d8f70de3          	beq	a4,a5,800214 <vprintfmt+0x3a>
  80047e:	02500713          	li	a4,37
  800482:	1d7d                	addi	s10,s10,-1
  800484:	fffd4783          	lbu	a5,-1(s10)
  800488:	fee79de3          	bne	a5,a4,800482 <vprintfmt+0x2a8>
  80048c:	b361                	j	800214 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80048e:	00000617          	auipc	a2,0x0
  800492:	50a60613          	addi	a2,a2,1290 # 800998 <error_string+0x1a8>
  800496:	85a6                	mv	a1,s1
  800498:	854a                	mv	a0,s2
  80049a:	0ac000ef          	jal	ra,800546 <printfmt>
  80049e:	bb9d                	j	800214 <vprintfmt+0x3a>
                p = "(null)";
  8004a0:	00000617          	auipc	a2,0x0
  8004a4:	4f060613          	addi	a2,a2,1264 # 800990 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004a8:	00000417          	auipc	s0,0x0
  8004ac:	4e940413          	addi	s0,s0,1257 # 800991 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b0:	8532                	mv	a0,a2
  8004b2:	85e6                	mv	a1,s9
  8004b4:	e032                	sd	a2,0(sp)
  8004b6:	e43e                	sd	a5,8(sp)
  8004b8:	0ae000ef          	jal	ra,800566 <strnlen>
  8004bc:	40ad8dbb          	subw	s11,s11,a0
  8004c0:	6602                	ld	a2,0(sp)
  8004c2:	01b05d63          	blez	s11,8004dc <vprintfmt+0x302>
  8004c6:	67a2                	ld	a5,8(sp)
  8004c8:	2781                	sext.w	a5,a5
  8004ca:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004cc:	6522                	ld	a0,8(sp)
  8004ce:	85a6                	mv	a1,s1
  8004d0:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004d4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d6:	6602                	ld	a2,0(sp)
  8004d8:	fe0d9ae3          	bnez	s11,8004cc <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004dc:	00064783          	lbu	a5,0(a2)
  8004e0:	0007851b          	sext.w	a0,a5
  8004e4:	e8051be3          	bnez	a0,80037a <vprintfmt+0x1a0>
  8004e8:	b335                	j	800214 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  8004ea:	000aa403          	lw	s0,0(s5)
  8004ee:	bbf1                	j	8002ca <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  8004f0:	000ae603          	lwu	a2,0(s5)
  8004f4:	46a9                	li	a3,10
  8004f6:	8aae                	mv	s5,a1
  8004f8:	bd89                	j	80034a <vprintfmt+0x170>
  8004fa:	000ae603          	lwu	a2,0(s5)
  8004fe:	46c1                	li	a3,16
  800500:	8aae                	mv	s5,a1
  800502:	b5a1                	j	80034a <vprintfmt+0x170>
  800504:	000ae603          	lwu	a2,0(s5)
  800508:	46a1                	li	a3,8
  80050a:	8aae                	mv	s5,a1
  80050c:	bd3d                	j	80034a <vprintfmt+0x170>
                    putch(ch, putdat);
  80050e:	9902                	jalr	s2
  800510:	b559                	j	800396 <vprintfmt+0x1bc>
                putch('-', putdat);
  800512:	85a6                	mv	a1,s1
  800514:	02d00513          	li	a0,45
  800518:	e03e                	sd	a5,0(sp)
  80051a:	9902                	jalr	s2
                num = -(long long)num;
  80051c:	8ace                	mv	s5,s3
  80051e:	40800633          	neg	a2,s0
  800522:	46a9                	li	a3,10
  800524:	6782                	ld	a5,0(sp)
  800526:	b515                	j	80034a <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  800528:	01b05663          	blez	s11,800534 <vprintfmt+0x35a>
  80052c:	02d00693          	li	a3,45
  800530:	f6d798e3          	bne	a5,a3,8004a0 <vprintfmt+0x2c6>
  800534:	00000417          	auipc	s0,0x0
  800538:	45d40413          	addi	s0,s0,1117 # 800991 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80053c:	02800513          	li	a0,40
  800540:	02800793          	li	a5,40
  800544:	bd1d                	j	80037a <vprintfmt+0x1a0>

0000000000800546 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800546:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800548:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80054c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80054e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800550:	ec06                	sd	ra,24(sp)
  800552:	f83a                	sd	a4,48(sp)
  800554:	fc3e                	sd	a5,56(sp)
  800556:	e0c2                	sd	a6,64(sp)
  800558:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80055a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80055c:	c7fff0ef          	jal	ra,8001da <vprintfmt>
}
  800560:	60e2                	ld	ra,24(sp)
  800562:	6161                	addi	sp,sp,80
  800564:	8082                	ret

0000000000800566 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800566:	c185                	beqz	a1,800586 <strnlen+0x20>
  800568:	00054783          	lbu	a5,0(a0)
  80056c:	cf89                	beqz	a5,800586 <strnlen+0x20>
    size_t cnt = 0;
  80056e:	4781                	li	a5,0
  800570:	a021                	j	800578 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800572:	00074703          	lbu	a4,0(a4)
  800576:	c711                	beqz	a4,800582 <strnlen+0x1c>
        cnt ++;
  800578:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80057a:	00f50733          	add	a4,a0,a5
  80057e:	fef59ae3          	bne	a1,a5,800572 <strnlen+0xc>
    }
    return cnt;
}
  800582:	853e                	mv	a0,a5
  800584:	8082                	ret
    size_t cnt = 0;
  800586:	4781                	li	a5,0
}
  800588:	853e                	mv	a0,a5
  80058a:	8082                	ret

000000000080058c <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  80058c:	1141                	addi	sp,sp,-16
    int pid, ret;
    cprintf("I am the parent. Forking the child...\n");
  80058e:	00000517          	auipc	a0,0x0
  800592:	42250513          	addi	a0,a0,1058 # 8009b0 <error_string+0x1c0>
main(void) {
  800596:	e406                	sd	ra,8(sp)
  800598:	e022                	sd	s0,0(sp)
    cprintf("I am the parent. Forking the child...\n");
  80059a:	b07ff0ef          	jal	ra,8000a0 <cprintf>
    if ((pid = fork()) == 0) {
  80059e:	bb5ff0ef          	jal	ra,800152 <fork>
  8005a2:	e901                	bnez	a0,8005b2 <main+0x26>
        cprintf("I am the child. spinning ...\n");
  8005a4:	00000517          	auipc	a0,0x0
  8005a8:	43450513          	addi	a0,a0,1076 # 8009d8 <error_string+0x1e8>
  8005ac:	af5ff0ef          	jal	ra,8000a0 <cprintf>
        while (1);
  8005b0:	a001                	j	8005b0 <main+0x24>
    }
    cprintf("I am the parent. Running the child...\n");
  8005b2:	842a                	mv	s0,a0
  8005b4:	00000517          	auipc	a0,0x0
  8005b8:	44450513          	addi	a0,a0,1092 # 8009f8 <error_string+0x208>
  8005bc:	ae5ff0ef          	jal	ra,8000a0 <cprintf>

    yield();
  8005c0:	b9bff0ef          	jal	ra,80015a <yield>
    yield();
  8005c4:	b97ff0ef          	jal	ra,80015a <yield>
    yield();
  8005c8:	b93ff0ef          	jal	ra,80015a <yield>

    cprintf("I am the parent.  Killing the child...\n");
  8005cc:	00000517          	auipc	a0,0x0
  8005d0:	45450513          	addi	a0,a0,1108 # 800a20 <error_string+0x230>
  8005d4:	acdff0ef          	jal	ra,8000a0 <cprintf>

    assert((ret = kill(pid)) == 0);
  8005d8:	8522                	mv	a0,s0
  8005da:	b85ff0ef          	jal	ra,80015e <kill>
  8005de:	ed31                	bnez	a0,80063a <main+0xae>
    cprintf("kill returns %d\n", ret);
  8005e0:	4581                	li	a1,0
  8005e2:	00000517          	auipc	a0,0x0
  8005e6:	4a650513          	addi	a0,a0,1190 # 800a88 <error_string+0x298>
  8005ea:	ab7ff0ef          	jal	ra,8000a0 <cprintf>

    assert((ret = waitpid(pid, NULL)) == 0);
  8005ee:	4581                	li	a1,0
  8005f0:	8522                	mv	a0,s0
  8005f2:	b65ff0ef          	jal	ra,800156 <waitpid>
  8005f6:	e11d                	bnez	a0,80061c <main+0x90>
    cprintf("wait returns %d\n", ret);
  8005f8:	4581                	li	a1,0
  8005fa:	00000517          	auipc	a0,0x0
  8005fe:	4c650513          	addi	a0,a0,1222 # 800ac0 <error_string+0x2d0>
  800602:	a9fff0ef          	jal	ra,8000a0 <cprintf>

    cprintf("spin may pass.\n");
  800606:	00000517          	auipc	a0,0x0
  80060a:	4d250513          	addi	a0,a0,1234 # 800ad8 <error_string+0x2e8>
  80060e:	a93ff0ef          	jal	ra,8000a0 <cprintf>
    return 0;
}
  800612:	60a2                	ld	ra,8(sp)
  800614:	6402                	ld	s0,0(sp)
  800616:	4501                	li	a0,0
  800618:	0141                	addi	sp,sp,16
  80061a:	8082                	ret
    assert((ret = waitpid(pid, NULL)) == 0);
  80061c:	00000697          	auipc	a3,0x0
  800620:	48468693          	addi	a3,a3,1156 # 800aa0 <error_string+0x2b0>
  800624:	00000617          	auipc	a2,0x0
  800628:	43c60613          	addi	a2,a2,1084 # 800a60 <error_string+0x270>
  80062c:	45dd                	li	a1,23
  80062e:	00000517          	auipc	a0,0x0
  800632:	44a50513          	addi	a0,a0,1098 # 800a78 <error_string+0x288>
  800636:	9f1ff0ef          	jal	ra,800026 <__panic>
    assert((ret = kill(pid)) == 0);
  80063a:	00000697          	auipc	a3,0x0
  80063e:	40e68693          	addi	a3,a3,1038 # 800a48 <error_string+0x258>
  800642:	00000617          	auipc	a2,0x0
  800646:	41e60613          	addi	a2,a2,1054 # 800a60 <error_string+0x270>
  80064a:	45d1                	li	a1,20
  80064c:	00000517          	auipc	a0,0x0
  800650:	42c50513          	addi	a0,a0,1068 # 800a78 <error_string+0x288>
  800654:	9d3ff0ef          	jal	ra,800026 <__panic>
