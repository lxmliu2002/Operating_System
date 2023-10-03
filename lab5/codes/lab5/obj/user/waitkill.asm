
obj/__user_waitkill.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	14c000ef          	jal	ra,80016c <umain>
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
  800038:	6a450513          	addi	a0,a0,1700 # 8006d8 <main+0xb4>
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
  800058:	9dc50513          	addi	a0,a0,-1572 # 800a30 <error_string+0x1c8>
  80005c:	044000ef          	jal	ra,8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800060:	5559                	li	a0,-10
  800062:	0e0000ef          	jal	ra,800142 <exit>

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
  80006e:	0cc000ef          	jal	ra,80013a <sys_putc>
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
  800094:	150000ef          	jal	ra,8001e4 <vprintfmt>
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
  8000c8:	11c000ef          	jal	ra,8001e4 <vprintfmt>
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

0000000000800134 <sys_getpid>:
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  800134:	4549                	li	a0,18
  800136:	f9fff06f          	j	8000d4 <syscall>

000000000080013a <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  80013a:	85aa                	mv	a1,a0
  80013c:	4579                	li	a0,30
  80013e:	f97ff06f          	j	8000d4 <syscall>

0000000000800142 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800142:	1141                	addi	sp,sp,-16
  800144:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800146:	fc9ff0ef          	jal	ra,80010e <sys_exit>
    cprintf("BUG: exit failed.\n");
  80014a:	00000517          	auipc	a0,0x0
  80014e:	5ae50513          	addi	a0,a0,1454 # 8006f8 <main+0xd4>
  800152:	f4fff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  800156:	a001                	j	800156 <exit+0x14>

0000000000800158 <fork>:
}

int
fork(void) {
    return sys_fork();
  800158:	fbfff06f          	j	800116 <sys_fork>

000000000080015c <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  80015c:	fc1ff06f          	j	80011c <sys_wait>

0000000000800160 <yield>:
}

void
yield(void) {
    sys_yield();
  800160:	fc7ff06f          	j	800126 <sys_yield>

0000000000800164 <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  800164:	fc9ff06f          	j	80012c <sys_kill>

0000000000800168 <getpid>:
}

int
getpid(void) {
    return sys_getpid();
  800168:	fcdff06f          	j	800134 <sys_getpid>

000000000080016c <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80016c:	1141                	addi	sp,sp,-16
  80016e:	e406                	sd	ra,8(sp)
    int ret = main();
  800170:	4b4000ef          	jal	ra,800624 <main>
    exit(ret);
  800174:	fcfff0ef          	jal	ra,800142 <exit>

0000000000800178 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800178:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80017c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80017e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800182:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800184:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800188:	f022                	sd	s0,32(sp)
  80018a:	ec26                	sd	s1,24(sp)
  80018c:	e84a                	sd	s2,16(sp)
  80018e:	f406                	sd	ra,40(sp)
  800190:	e44e                	sd	s3,8(sp)
  800192:	84aa                	mv	s1,a0
  800194:	892e                	mv	s2,a1
  800196:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80019a:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  80019c:	03067e63          	bleu	a6,a2,8001d8 <printnum+0x60>
  8001a0:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8001a2:	00805763          	blez	s0,8001b0 <printnum+0x38>
  8001a6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001a8:	85ca                	mv	a1,s2
  8001aa:	854e                	mv	a0,s3
  8001ac:	9482                	jalr	s1
        while (-- width > 0)
  8001ae:	fc65                	bnez	s0,8001a6 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001b0:	1a02                	slli	s4,s4,0x20
  8001b2:	020a5a13          	srli	s4,s4,0x20
  8001b6:	00000797          	auipc	a5,0x0
  8001ba:	77a78793          	addi	a5,a5,1914 # 800930 <error_string+0xc8>
  8001be:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001c0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001c2:	000a4503          	lbu	a0,0(s4)
}
  8001c6:	70a2                	ld	ra,40(sp)
  8001c8:	69a2                	ld	s3,8(sp)
  8001ca:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001cc:	85ca                	mv	a1,s2
  8001ce:	8326                	mv	t1,s1
}
  8001d0:	6942                	ld	s2,16(sp)
  8001d2:	64e2                	ld	s1,24(sp)
  8001d4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001d6:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001d8:	03065633          	divu	a2,a2,a6
  8001dc:	8722                	mv	a4,s0
  8001de:	f9bff0ef          	jal	ra,800178 <printnum>
  8001e2:	b7f9                	j	8001b0 <printnum+0x38>

00000000008001e4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001e4:	7119                	addi	sp,sp,-128
  8001e6:	f4a6                	sd	s1,104(sp)
  8001e8:	f0ca                	sd	s2,96(sp)
  8001ea:	e8d2                	sd	s4,80(sp)
  8001ec:	e4d6                	sd	s5,72(sp)
  8001ee:	e0da                	sd	s6,64(sp)
  8001f0:	fc5e                	sd	s7,56(sp)
  8001f2:	f862                	sd	s8,48(sp)
  8001f4:	f06a                	sd	s10,32(sp)
  8001f6:	fc86                	sd	ra,120(sp)
  8001f8:	f8a2                	sd	s0,112(sp)
  8001fa:	ecce                	sd	s3,88(sp)
  8001fc:	f466                	sd	s9,40(sp)
  8001fe:	ec6e                	sd	s11,24(sp)
  800200:	892a                	mv	s2,a0
  800202:	84ae                	mv	s1,a1
  800204:	8d32                	mv	s10,a2
  800206:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800208:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  80020a:	00000a17          	auipc	s4,0x0
  80020e:	502a0a13          	addi	s4,s4,1282 # 80070c <main+0xe8>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800212:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800216:	00000c17          	auipc	s8,0x0
  80021a:	652c0c13          	addi	s8,s8,1618 # 800868 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021e:	000d4503          	lbu	a0,0(s10)
  800222:	02500793          	li	a5,37
  800226:	001d0413          	addi	s0,s10,1
  80022a:	00f50e63          	beq	a0,a5,800246 <vprintfmt+0x62>
            if (ch == '\0') {
  80022e:	c521                	beqz	a0,800276 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800230:	02500993          	li	s3,37
  800234:	a011                	j	800238 <vprintfmt+0x54>
            if (ch == '\0') {
  800236:	c121                	beqz	a0,800276 <vprintfmt+0x92>
            putch(ch, putdat);
  800238:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80023a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80023c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80023e:	fff44503          	lbu	a0,-1(s0)
  800242:	ff351ae3          	bne	a0,s3,800236 <vprintfmt+0x52>
  800246:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80024a:	02000793          	li	a5,32
        lflag = altflag = 0;
  80024e:	4981                	li	s3,0
  800250:	4801                	li	a6,0
        width = precision = -1;
  800252:	5cfd                	li	s9,-1
  800254:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800256:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  80025a:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  80025c:	fdd6069b          	addiw	a3,a2,-35
  800260:	0ff6f693          	andi	a3,a3,255
  800264:	00140d13          	addi	s10,s0,1
  800268:	20d5e563          	bltu	a1,a3,800472 <vprintfmt+0x28e>
  80026c:	068a                	slli	a3,a3,0x2
  80026e:	96d2                	add	a3,a3,s4
  800270:	4294                	lw	a3,0(a3)
  800272:	96d2                	add	a3,a3,s4
  800274:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800276:	70e6                	ld	ra,120(sp)
  800278:	7446                	ld	s0,112(sp)
  80027a:	74a6                	ld	s1,104(sp)
  80027c:	7906                	ld	s2,96(sp)
  80027e:	69e6                	ld	s3,88(sp)
  800280:	6a46                	ld	s4,80(sp)
  800282:	6aa6                	ld	s5,72(sp)
  800284:	6b06                	ld	s6,64(sp)
  800286:	7be2                	ld	s7,56(sp)
  800288:	7c42                	ld	s8,48(sp)
  80028a:	7ca2                	ld	s9,40(sp)
  80028c:	7d02                	ld	s10,32(sp)
  80028e:	6de2                	ld	s11,24(sp)
  800290:	6109                	addi	sp,sp,128
  800292:	8082                	ret
    if (lflag >= 2) {
  800294:	4705                	li	a4,1
  800296:	008a8593          	addi	a1,s5,8
  80029a:	01074463          	blt	a4,a6,8002a2 <vprintfmt+0xbe>
    else if (lflag) {
  80029e:	26080363          	beqz	a6,800504 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  8002a2:	000ab603          	ld	a2,0(s5)
  8002a6:	46c1                	li	a3,16
  8002a8:	8aae                	mv	s5,a1
  8002aa:	a06d                	j	800354 <vprintfmt+0x170>
            goto reswitch;
  8002ac:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002b0:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002b2:	846a                	mv	s0,s10
            goto reswitch;
  8002b4:	b765                	j	80025c <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  8002b6:	000aa503          	lw	a0,0(s5)
  8002ba:	85a6                	mv	a1,s1
  8002bc:	0aa1                	addi	s5,s5,8
  8002be:	9902                	jalr	s2
            break;
  8002c0:	bfb9                	j	80021e <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002c2:	4705                	li	a4,1
  8002c4:	008a8993          	addi	s3,s5,8
  8002c8:	01074463          	blt	a4,a6,8002d0 <vprintfmt+0xec>
    else if (lflag) {
  8002cc:	22080463          	beqz	a6,8004f4 <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002d0:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002d4:	24044463          	bltz	s0,80051c <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002d8:	8622                	mv	a2,s0
  8002da:	8ace                	mv	s5,s3
  8002dc:	46a9                	li	a3,10
  8002de:	a89d                	j	800354 <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002e0:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002e4:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002e6:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002e8:	41f7d69b          	sraiw	a3,a5,0x1f
  8002ec:	8fb5                	xor	a5,a5,a3
  8002ee:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002f2:	1ad74363          	blt	a4,a3,800498 <vprintfmt+0x2b4>
  8002f6:	00369793          	slli	a5,a3,0x3
  8002fa:	97e2                	add	a5,a5,s8
  8002fc:	639c                	ld	a5,0(a5)
  8002fe:	18078d63          	beqz	a5,800498 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  800302:	86be                	mv	a3,a5
  800304:	00000617          	auipc	a2,0x0
  800308:	71c60613          	addi	a2,a2,1820 # 800a20 <error_string+0x1b8>
  80030c:	85a6                	mv	a1,s1
  80030e:	854a                	mv	a0,s2
  800310:	240000ef          	jal	ra,800550 <printfmt>
  800314:	b729                	j	80021e <vprintfmt+0x3a>
            lflag ++;
  800316:	00144603          	lbu	a2,1(s0)
  80031a:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  80031c:	846a                	mv	s0,s10
            goto reswitch;
  80031e:	bf3d                	j	80025c <vprintfmt+0x78>
    if (lflag >= 2) {
  800320:	4705                	li	a4,1
  800322:	008a8593          	addi	a1,s5,8
  800326:	01074463          	blt	a4,a6,80032e <vprintfmt+0x14a>
    else if (lflag) {
  80032a:	1e080263          	beqz	a6,80050e <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  80032e:	000ab603          	ld	a2,0(s5)
  800332:	46a1                	li	a3,8
  800334:	8aae                	mv	s5,a1
  800336:	a839                	j	800354 <vprintfmt+0x170>
            putch('0', putdat);
  800338:	03000513          	li	a0,48
  80033c:	85a6                	mv	a1,s1
  80033e:	e03e                	sd	a5,0(sp)
  800340:	9902                	jalr	s2
            putch('x', putdat);
  800342:	85a6                	mv	a1,s1
  800344:	07800513          	li	a0,120
  800348:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80034a:	0aa1                	addi	s5,s5,8
  80034c:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800350:	6782                	ld	a5,0(sp)
  800352:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800354:	876e                	mv	a4,s11
  800356:	85a6                	mv	a1,s1
  800358:	854a                	mv	a0,s2
  80035a:	e1fff0ef          	jal	ra,800178 <printnum>
            break;
  80035e:	b5c1                	j	80021e <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800360:	000ab603          	ld	a2,0(s5)
  800364:	0aa1                	addi	s5,s5,8
  800366:	1c060663          	beqz	a2,800532 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  80036a:	00160413          	addi	s0,a2,1
  80036e:	17b05c63          	blez	s11,8004e6 <vprintfmt+0x302>
  800372:	02d00593          	li	a1,45
  800376:	14b79263          	bne	a5,a1,8004ba <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80037a:	00064783          	lbu	a5,0(a2)
  80037e:	0007851b          	sext.w	a0,a5
  800382:	c905                	beqz	a0,8003b2 <vprintfmt+0x1ce>
  800384:	000cc563          	bltz	s9,80038e <vprintfmt+0x1aa>
  800388:	3cfd                	addiw	s9,s9,-1
  80038a:	036c8263          	beq	s9,s6,8003ae <vprintfmt+0x1ca>
                    putch('?', putdat);
  80038e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800390:	18098463          	beqz	s3,800518 <vprintfmt+0x334>
  800394:	3781                	addiw	a5,a5,-32
  800396:	18fbf163          	bleu	a5,s7,800518 <vprintfmt+0x334>
                    putch('?', putdat);
  80039a:	03f00513          	li	a0,63
  80039e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a0:	0405                	addi	s0,s0,1
  8003a2:	fff44783          	lbu	a5,-1(s0)
  8003a6:	3dfd                	addiw	s11,s11,-1
  8003a8:	0007851b          	sext.w	a0,a5
  8003ac:	fd61                	bnez	a0,800384 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  8003ae:	e7b058e3          	blez	s11,80021e <vprintfmt+0x3a>
  8003b2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003b4:	85a6                	mv	a1,s1
  8003b6:	02000513          	li	a0,32
  8003ba:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003bc:	e60d81e3          	beqz	s11,80021e <vprintfmt+0x3a>
  8003c0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003c2:	85a6                	mv	a1,s1
  8003c4:	02000513          	li	a0,32
  8003c8:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ca:	fe0d94e3          	bnez	s11,8003b2 <vprintfmt+0x1ce>
  8003ce:	bd81                	j	80021e <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003d0:	4705                	li	a4,1
  8003d2:	008a8593          	addi	a1,s5,8
  8003d6:	01074463          	blt	a4,a6,8003de <vprintfmt+0x1fa>
    else if (lflag) {
  8003da:	12080063          	beqz	a6,8004fa <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003de:	000ab603          	ld	a2,0(s5)
  8003e2:	46a9                	li	a3,10
  8003e4:	8aae                	mv	s5,a1
  8003e6:	b7bd                	j	800354 <vprintfmt+0x170>
  8003e8:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003ec:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  8003f0:	846a                	mv	s0,s10
  8003f2:	b5ad                	j	80025c <vprintfmt+0x78>
            putch(ch, putdat);
  8003f4:	85a6                	mv	a1,s1
  8003f6:	02500513          	li	a0,37
  8003fa:	9902                	jalr	s2
            break;
  8003fc:	b50d                	j	80021e <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  8003fe:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  800402:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800406:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800408:	846a                	mv	s0,s10
            if (width < 0)
  80040a:	e40dd9e3          	bgez	s11,80025c <vprintfmt+0x78>
                width = precision, precision = -1;
  80040e:	8de6                	mv	s11,s9
  800410:	5cfd                	li	s9,-1
  800412:	b5a9                	j	80025c <vprintfmt+0x78>
            goto reswitch;
  800414:	00144603          	lbu	a2,1(s0)
            padc = '0';
  800418:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  80041c:	846a                	mv	s0,s10
            goto reswitch;
  80041e:	bd3d                	j	80025c <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800420:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800424:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800428:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80042a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  80042e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800432:	fcd56ce3          	bltu	a0,a3,80040a <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  800436:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800438:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  80043c:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800440:	0196873b          	addw	a4,a3,s9
  800444:	0017171b          	slliw	a4,a4,0x1
  800448:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  80044c:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800450:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800454:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800458:	fcd57fe3          	bleu	a3,a0,800436 <vprintfmt+0x252>
  80045c:	b77d                	j	80040a <vprintfmt+0x226>
            if (width < 0)
  80045e:	fffdc693          	not	a3,s11
  800462:	96fd                	srai	a3,a3,0x3f
  800464:	00ddfdb3          	and	s11,s11,a3
  800468:	00144603          	lbu	a2,1(s0)
  80046c:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  80046e:	846a                	mv	s0,s10
  800470:	b3f5                	j	80025c <vprintfmt+0x78>
            putch('%', putdat);
  800472:	85a6                	mv	a1,s1
  800474:	02500513          	li	a0,37
  800478:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80047a:	fff44703          	lbu	a4,-1(s0)
  80047e:	02500793          	li	a5,37
  800482:	8d22                	mv	s10,s0
  800484:	d8f70de3          	beq	a4,a5,80021e <vprintfmt+0x3a>
  800488:	02500713          	li	a4,37
  80048c:	1d7d                	addi	s10,s10,-1
  80048e:	fffd4783          	lbu	a5,-1(s10)
  800492:	fee79de3          	bne	a5,a4,80048c <vprintfmt+0x2a8>
  800496:	b361                	j	80021e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800498:	00000617          	auipc	a2,0x0
  80049c:	57860613          	addi	a2,a2,1400 # 800a10 <error_string+0x1a8>
  8004a0:	85a6                	mv	a1,s1
  8004a2:	854a                	mv	a0,s2
  8004a4:	0ac000ef          	jal	ra,800550 <printfmt>
  8004a8:	bb9d                	j	80021e <vprintfmt+0x3a>
                p = "(null)";
  8004aa:	00000617          	auipc	a2,0x0
  8004ae:	55e60613          	addi	a2,a2,1374 # 800a08 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004b2:	00000417          	auipc	s0,0x0
  8004b6:	55740413          	addi	s0,s0,1367 # 800a09 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ba:	8532                	mv	a0,a2
  8004bc:	85e6                	mv	a1,s9
  8004be:	e032                	sd	a2,0(sp)
  8004c0:	e43e                	sd	a5,8(sp)
  8004c2:	0ae000ef          	jal	ra,800570 <strnlen>
  8004c6:	40ad8dbb          	subw	s11,s11,a0
  8004ca:	6602                	ld	a2,0(sp)
  8004cc:	01b05d63          	blez	s11,8004e6 <vprintfmt+0x302>
  8004d0:	67a2                	ld	a5,8(sp)
  8004d2:	2781                	sext.w	a5,a5
  8004d4:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004d6:	6522                	ld	a0,8(sp)
  8004d8:	85a6                	mv	a1,s1
  8004da:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004dc:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004de:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e0:	6602                	ld	a2,0(sp)
  8004e2:	fe0d9ae3          	bnez	s11,8004d6 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e6:	00064783          	lbu	a5,0(a2)
  8004ea:	0007851b          	sext.w	a0,a5
  8004ee:	e8051be3          	bnez	a0,800384 <vprintfmt+0x1a0>
  8004f2:	b335                	j	80021e <vprintfmt+0x3a>
        return va_arg(*ap, int);
  8004f4:	000aa403          	lw	s0,0(s5)
  8004f8:	bbf1                	j	8002d4 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  8004fa:	000ae603          	lwu	a2,0(s5)
  8004fe:	46a9                	li	a3,10
  800500:	8aae                	mv	s5,a1
  800502:	bd89                	j	800354 <vprintfmt+0x170>
  800504:	000ae603          	lwu	a2,0(s5)
  800508:	46c1                	li	a3,16
  80050a:	8aae                	mv	s5,a1
  80050c:	b5a1                	j	800354 <vprintfmt+0x170>
  80050e:	000ae603          	lwu	a2,0(s5)
  800512:	46a1                	li	a3,8
  800514:	8aae                	mv	s5,a1
  800516:	bd3d                	j	800354 <vprintfmt+0x170>
                    putch(ch, putdat);
  800518:	9902                	jalr	s2
  80051a:	b559                	j	8003a0 <vprintfmt+0x1bc>
                putch('-', putdat);
  80051c:	85a6                	mv	a1,s1
  80051e:	02d00513          	li	a0,45
  800522:	e03e                	sd	a5,0(sp)
  800524:	9902                	jalr	s2
                num = -(long long)num;
  800526:	8ace                	mv	s5,s3
  800528:	40800633          	neg	a2,s0
  80052c:	46a9                	li	a3,10
  80052e:	6782                	ld	a5,0(sp)
  800530:	b515                	j	800354 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  800532:	01b05663          	blez	s11,80053e <vprintfmt+0x35a>
  800536:	02d00693          	li	a3,45
  80053a:	f6d798e3          	bne	a5,a3,8004aa <vprintfmt+0x2c6>
  80053e:	00000417          	auipc	s0,0x0
  800542:	4cb40413          	addi	s0,s0,1227 # 800a09 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800546:	02800513          	li	a0,40
  80054a:	02800793          	li	a5,40
  80054e:	bd1d                	j	800384 <vprintfmt+0x1a0>

0000000000800550 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800550:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800552:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800556:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800558:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80055a:	ec06                	sd	ra,24(sp)
  80055c:	f83a                	sd	a4,48(sp)
  80055e:	fc3e                	sd	a5,56(sp)
  800560:	e0c2                	sd	a6,64(sp)
  800562:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800564:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800566:	c7fff0ef          	jal	ra,8001e4 <vprintfmt>
}
  80056a:	60e2                	ld	ra,24(sp)
  80056c:	6161                	addi	sp,sp,80
  80056e:	8082                	ret

0000000000800570 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800570:	c185                	beqz	a1,800590 <strnlen+0x20>
  800572:	00054783          	lbu	a5,0(a0)
  800576:	cf89                	beqz	a5,800590 <strnlen+0x20>
    size_t cnt = 0;
  800578:	4781                	li	a5,0
  80057a:	a021                	j	800582 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  80057c:	00074703          	lbu	a4,0(a4)
  800580:	c711                	beqz	a4,80058c <strnlen+0x1c>
        cnt ++;
  800582:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800584:	00f50733          	add	a4,a0,a5
  800588:	fef59ae3          	bne	a1,a5,80057c <strnlen+0xc>
    }
    return cnt;
}
  80058c:	853e                	mv	a0,a5
  80058e:	8082                	ret
    size_t cnt = 0;
  800590:	4781                	li	a5,0
}
  800592:	853e                	mv	a0,a5
  800594:	8082                	ret

0000000000800596 <do_yield>:
#include <ulib.h>
#include <stdio.h>

void
do_yield(void) {
  800596:	1141                	addi	sp,sp,-16
  800598:	e406                	sd	ra,8(sp)
    yield();
  80059a:	bc7ff0ef          	jal	ra,800160 <yield>
    yield();
  80059e:	bc3ff0ef          	jal	ra,800160 <yield>
    yield();
  8005a2:	bbfff0ef          	jal	ra,800160 <yield>
    yield();
  8005a6:	bbbff0ef          	jal	ra,800160 <yield>
    yield();
  8005aa:	bb7ff0ef          	jal	ra,800160 <yield>
    yield();
}
  8005ae:	60a2                	ld	ra,8(sp)
  8005b0:	0141                	addi	sp,sp,16
    yield();
  8005b2:	bafff06f          	j	800160 <yield>

00000000008005b6 <loop>:

int parent, pid1, pid2;

void
loop(void) {
  8005b6:	1141                	addi	sp,sp,-16
    cprintf("child 1.\n");
  8005b8:	00000517          	auipc	a0,0x0
  8005bc:	47050513          	addi	a0,a0,1136 # 800a28 <error_string+0x1c0>
loop(void) {
  8005c0:	e406                	sd	ra,8(sp)
    cprintf("child 1.\n");
  8005c2:	adfff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  8005c6:	a001                	j	8005c6 <loop+0x10>

00000000008005c8 <work>:
}

void
work(void) {
  8005c8:	1141                	addi	sp,sp,-16
    cprintf("child 2.\n");
  8005ca:	00000517          	auipc	a0,0x0
  8005ce:	4de50513          	addi	a0,a0,1246 # 800aa8 <error_string+0x240>
work(void) {
  8005d2:	e406                	sd	ra,8(sp)
    cprintf("child 2.\n");
  8005d4:	acdff0ef          	jal	ra,8000a0 <cprintf>
    do_yield();
  8005d8:	fbfff0ef          	jal	ra,800596 <do_yield>
    if (kill(parent) == 0) {
  8005dc:	00001797          	auipc	a5,0x1
  8005e0:	a2478793          	addi	a5,a5,-1500 # 801000 <parent>
  8005e4:	4388                	lw	a0,0(a5)
  8005e6:	b7fff0ef          	jal	ra,800164 <kill>
  8005ea:	e10d                	bnez	a0,80060c <work+0x44>
        cprintf("kill parent ok.\n");
  8005ec:	00000517          	auipc	a0,0x0
  8005f0:	4cc50513          	addi	a0,a0,1228 # 800ab8 <error_string+0x250>
  8005f4:	aadff0ef          	jal	ra,8000a0 <cprintf>
        do_yield();
  8005f8:	f9fff0ef          	jal	ra,800596 <do_yield>
        if (kill(pid1) == 0) {
  8005fc:	00001797          	auipc	a5,0x1
  800600:	a0c78793          	addi	a5,a5,-1524 # 801008 <pid1>
  800604:	4388                	lw	a0,0(a5)
  800606:	b5fff0ef          	jal	ra,800164 <kill>
  80060a:	c501                	beqz	a0,800612 <work+0x4a>
            cprintf("kill child1 ok.\n");
            exit(0);
        }
    }
    exit(-1);
  80060c:	557d                	li	a0,-1
  80060e:	b35ff0ef          	jal	ra,800142 <exit>
            cprintf("kill child1 ok.\n");
  800612:	00000517          	auipc	a0,0x0
  800616:	4be50513          	addi	a0,a0,1214 # 800ad0 <error_string+0x268>
  80061a:	a87ff0ef          	jal	ra,8000a0 <cprintf>
            exit(0);
  80061e:	4501                	li	a0,0
  800620:	b23ff0ef          	jal	ra,800142 <exit>

0000000000800624 <main>:
}

int
main(void) {
  800624:	1141                	addi	sp,sp,-16
  800626:	e406                	sd	ra,8(sp)
  800628:	e022                	sd	s0,0(sp)
    parent = getpid();
  80062a:	b3fff0ef          	jal	ra,800168 <getpid>
  80062e:	00001797          	auipc	a5,0x1
  800632:	9ca7a923          	sw	a0,-1582(a5) # 801000 <parent>
    if ((pid1 = fork()) == 0) {
  800636:	b23ff0ef          	jal	ra,800158 <fork>
  80063a:	00001797          	auipc	a5,0x1
  80063e:	9ca7a723          	sw	a0,-1586(a5) # 801008 <pid1>
  800642:	c53d                	beqz	a0,8006b0 <main+0x8c>
        loop();
    }

    assert(pid1 > 0);
  800644:	04a05663          	blez	a0,800690 <main+0x6c>

    if ((pid2 = fork()) == 0) {
  800648:	b11ff0ef          	jal	ra,800158 <fork>
  80064c:	00001797          	auipc	a5,0x1
  800650:	9aa7ac23          	sw	a0,-1608(a5) # 801004 <pid2>
  800654:	cd3d                	beqz	a0,8006d2 <main+0xae>
  800656:	00001417          	auipc	s0,0x1
  80065a:	9b240413          	addi	s0,s0,-1614 # 801008 <pid1>
        work();
    }
    if (pid2 > 0) {
  80065e:	04a05b63          	blez	a0,8006b4 <main+0x90>
        cprintf("wait child 1.\n");
  800662:	00000517          	auipc	a0,0x0
  800666:	40e50513          	addi	a0,a0,1038 # 800a70 <error_string+0x208>
  80066a:	a37ff0ef          	jal	ra,8000a0 <cprintf>
        waitpid(pid1, NULL);
  80066e:	4008                	lw	a0,0(s0)
  800670:	4581                	li	a1,0
  800672:	aebff0ef          	jal	ra,80015c <waitpid>
        panic("waitpid %d returns\n", pid1);
  800676:	4014                	lw	a3,0(s0)
  800678:	00000617          	auipc	a2,0x0
  80067c:	40860613          	addi	a2,a2,1032 # 800a80 <error_string+0x218>
  800680:	03400593          	li	a1,52
  800684:	00000517          	auipc	a0,0x0
  800688:	3dc50513          	addi	a0,a0,988 # 800a60 <error_string+0x1f8>
  80068c:	99bff0ef          	jal	ra,800026 <__panic>
    assert(pid1 > 0);
  800690:	00000697          	auipc	a3,0x0
  800694:	3a868693          	addi	a3,a3,936 # 800a38 <error_string+0x1d0>
  800698:	00000617          	auipc	a2,0x0
  80069c:	3b060613          	addi	a2,a2,944 # 800a48 <error_string+0x1e0>
  8006a0:	02c00593          	li	a1,44
  8006a4:	00000517          	auipc	a0,0x0
  8006a8:	3bc50513          	addi	a0,a0,956 # 800a60 <error_string+0x1f8>
  8006ac:	97bff0ef          	jal	ra,800026 <__panic>
        loop();
  8006b0:	f07ff0ef          	jal	ra,8005b6 <loop>
    }
    else {
        kill(pid1);
  8006b4:	4008                	lw	a0,0(s0)
  8006b6:	aafff0ef          	jal	ra,800164 <kill>
    }
    panic("FAIL: T.T\n");
  8006ba:	00000617          	auipc	a2,0x0
  8006be:	3de60613          	addi	a2,a2,990 # 800a98 <error_string+0x230>
  8006c2:	03900593          	li	a1,57
  8006c6:	00000517          	auipc	a0,0x0
  8006ca:	39a50513          	addi	a0,a0,922 # 800a60 <error_string+0x1f8>
  8006ce:	959ff0ef          	jal	ra,800026 <__panic>
        work();
  8006d2:	ef7ff0ef          	jal	ra,8005c8 <work>
