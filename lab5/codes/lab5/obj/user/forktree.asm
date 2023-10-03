
obj/__user_forktree.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0d2000ef          	jal	ra,8000f2 <umain>
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
  80002e:	09a000ef          	jal	ra,8000c8 <sys_putc>
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
  800068:	11c000ef          	jal	ra,800184 <vprintfmt>
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
  800094:	6522                	ld	a0,8(sp)
  800096:	75a2                	ld	a1,40(sp)
  800098:	7642                	ld	a2,48(sp)
  80009a:	76e2                	ld	a3,56(sp)
  80009c:	6706                	ld	a4,64(sp)
  80009e:	67a6                	ld	a5,72(sp)
  8000a0:	00000073          	ecall
  8000a4:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  8000a8:	4572                	lw	a0,28(sp)
  8000aa:	6149                	addi	sp,sp,144
  8000ac:	8082                	ret

00000000008000ae <sys_exit>:

int
sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
  8000ae:	85aa                	mv	a1,a0
  8000b0:	4505                	li	a0,1
  8000b2:	fc3ff06f          	j	800074 <syscall>

00000000008000b6 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  8000b6:	4509                	li	a0,2
  8000b8:	fbdff06f          	j	800074 <syscall>

00000000008000bc <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  8000bc:	4529                	li	a0,10
  8000be:	fb7ff06f          	j	800074 <syscall>

00000000008000c2 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000c2:	4549                	li	a0,18
  8000c4:	fb1ff06f          	j	800074 <syscall>

00000000008000c8 <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000c8:	85aa                	mv	a1,a0
  8000ca:	4579                	li	a0,30
  8000cc:	fa9ff06f          	j	800074 <syscall>

00000000008000d0 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000d0:	1141                	addi	sp,sp,-16
  8000d2:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000d4:	fdbff0ef          	jal	ra,8000ae <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000d8:	00000517          	auipc	a0,0x0
  8000dc:	56850513          	addi	a0,a0,1384 # 800640 <main+0x18>
  8000e0:	f61ff0ef          	jal	ra,800040 <cprintf>
    while (1);
  8000e4:	a001                	j	8000e4 <exit+0x14>

00000000008000e6 <fork>:
}

int
fork(void) {
    return sys_fork();
  8000e6:	fd1ff06f          	j	8000b6 <sys_fork>

00000000008000ea <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  8000ea:	fd3ff06f          	j	8000bc <sys_yield>

00000000008000ee <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000ee:	fd5ff06f          	j	8000c2 <sys_getpid>

00000000008000f2 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000f2:	1141                	addi	sp,sp,-16
  8000f4:	e406                	sd	ra,8(sp)
    int ret = main();
  8000f6:	532000ef          	jal	ra,800628 <main>
    exit(ret);
  8000fa:	fd7ff0ef          	jal	ra,8000d0 <exit>

00000000008000fe <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000fe:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800102:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800104:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800108:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80010a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80010e:	f022                	sd	s0,32(sp)
  800110:	ec26                	sd	s1,24(sp)
  800112:	e84a                	sd	s2,16(sp)
  800114:	f406                	sd	ra,40(sp)
  800116:	e44e                	sd	s3,8(sp)
  800118:	84aa                	mv	s1,a0
  80011a:	892e                	mv	s2,a1
  80011c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800120:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800122:	03067e63          	bleu	a6,a2,80015e <printnum+0x60>
  800126:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800128:	00805763          	blez	s0,800136 <printnum+0x38>
  80012c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80012e:	85ca                	mv	a1,s2
  800130:	854e                	mv	a0,s3
  800132:	9482                	jalr	s1
        while (-- width > 0)
  800134:	fc65                	bnez	s0,80012c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800136:	1a02                	slli	s4,s4,0x20
  800138:	020a5a13          	srli	s4,s4,0x20
  80013c:	00000797          	auipc	a5,0x0
  800140:	73c78793          	addi	a5,a5,1852 # 800878 <error_string+0xc8>
  800144:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800146:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800148:	000a4503          	lbu	a0,0(s4)
}
  80014c:	70a2                	ld	ra,40(sp)
  80014e:	69a2                	ld	s3,8(sp)
  800150:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800152:	85ca                	mv	a1,s2
  800154:	8326                	mv	t1,s1
}
  800156:	6942                	ld	s2,16(sp)
  800158:	64e2                	ld	s1,24(sp)
  80015a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80015c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  80015e:	03065633          	divu	a2,a2,a6
  800162:	8722                	mv	a4,s0
  800164:	f9bff0ef          	jal	ra,8000fe <printnum>
  800168:	b7f9                	j	800136 <printnum+0x38>

000000000080016a <sprintputch>:
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
    b->cnt ++;
  80016a:	499c                	lw	a5,16(a1)
    if (b->buf < b->ebuf) {
  80016c:	6198                	ld	a4,0(a1)
  80016e:	6594                	ld	a3,8(a1)
    b->cnt ++;
  800170:	2785                	addiw	a5,a5,1
  800172:	c99c                	sw	a5,16(a1)
    if (b->buf < b->ebuf) {
  800174:	00d77763          	bleu	a3,a4,800182 <sprintputch+0x18>
        *b->buf ++ = ch;
  800178:	00170793          	addi	a5,a4,1
  80017c:	e19c                	sd	a5,0(a1)
  80017e:	00a70023          	sb	a0,0(a4)
    }
}
  800182:	8082                	ret

0000000000800184 <vprintfmt>:
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800184:	7119                	addi	sp,sp,-128
  800186:	f4a6                	sd	s1,104(sp)
  800188:	f0ca                	sd	s2,96(sp)
  80018a:	e8d2                	sd	s4,80(sp)
  80018c:	e4d6                	sd	s5,72(sp)
  80018e:	e0da                	sd	s6,64(sp)
  800190:	fc5e                	sd	s7,56(sp)
  800192:	f862                	sd	s8,48(sp)
  800194:	f06a                	sd	s10,32(sp)
  800196:	fc86                	sd	ra,120(sp)
  800198:	f8a2                	sd	s0,112(sp)
  80019a:	ecce                	sd	s3,88(sp)
  80019c:	f466                	sd	s9,40(sp)
  80019e:	ec6e                	sd	s11,24(sp)
  8001a0:	892a                	mv	s2,a0
  8001a2:	84ae                	mv	s1,a1
  8001a4:	8d32                	mv	s10,a2
  8001a6:	8ab6                	mv	s5,a3
        width = precision = -1;
  8001a8:	5b7d                	li	s6,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001aa:	00000a17          	auipc	s4,0x0
  8001ae:	4aaa0a13          	addi	s4,s4,1194 # 800654 <main+0x2c>
                if (altflag && (ch < ' ' || ch > '~')) {
  8001b2:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001b6:	00000c17          	auipc	s8,0x0
  8001ba:	5fac0c13          	addi	s8,s8,1530 # 8007b0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001be:	000d4503          	lbu	a0,0(s10)
  8001c2:	02500793          	li	a5,37
  8001c6:	001d0413          	addi	s0,s10,1
  8001ca:	00f50e63          	beq	a0,a5,8001e6 <vprintfmt+0x62>
            if (ch == '\0') {
  8001ce:	c521                	beqz	a0,800216 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001d0:	02500993          	li	s3,37
  8001d4:	a011                	j	8001d8 <vprintfmt+0x54>
            if (ch == '\0') {
  8001d6:	c121                	beqz	a0,800216 <vprintfmt+0x92>
            putch(ch, putdat);
  8001d8:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001da:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001dc:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001de:	fff44503          	lbu	a0,-1(s0)
  8001e2:	ff351ae3          	bne	a0,s3,8001d6 <vprintfmt+0x52>
  8001e6:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001ea:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001ee:	4981                	li	s3,0
  8001f0:	4801                	li	a6,0
        width = precision = -1;
  8001f2:	5cfd                	li	s9,-1
  8001f4:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001f6:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  8001fa:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001fc:	fdd6069b          	addiw	a3,a2,-35
  800200:	0ff6f693          	andi	a3,a3,255
  800204:	00140d13          	addi	s10,s0,1
  800208:	20d5e563          	bltu	a1,a3,800412 <vprintfmt+0x28e>
  80020c:	068a                	slli	a3,a3,0x2
  80020e:	96d2                	add	a3,a3,s4
  800210:	4294                	lw	a3,0(a3)
  800212:	96d2                	add	a3,a3,s4
  800214:	8682                	jr	a3
}
  800216:	70e6                	ld	ra,120(sp)
  800218:	7446                	ld	s0,112(sp)
  80021a:	74a6                	ld	s1,104(sp)
  80021c:	7906                	ld	s2,96(sp)
  80021e:	69e6                	ld	s3,88(sp)
  800220:	6a46                	ld	s4,80(sp)
  800222:	6aa6                	ld	s5,72(sp)
  800224:	6b06                	ld	s6,64(sp)
  800226:	7be2                	ld	s7,56(sp)
  800228:	7c42                	ld	s8,48(sp)
  80022a:	7ca2                	ld	s9,40(sp)
  80022c:	7d02                	ld	s10,32(sp)
  80022e:	6de2                	ld	s11,24(sp)
  800230:	6109                	addi	sp,sp,128
  800232:	8082                	ret
    if (lflag >= 2) {
  800234:	4705                	li	a4,1
  800236:	008a8593          	addi	a1,s5,8
  80023a:	01074463          	blt	a4,a6,800242 <vprintfmt+0xbe>
    else if (lflag) {
  80023e:	26080363          	beqz	a6,8004a4 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  800242:	000ab603          	ld	a2,0(s5)
  800246:	46c1                	li	a3,16
  800248:	8aae                	mv	s5,a1
  80024a:	a06d                	j	8002f4 <vprintfmt+0x170>
            goto reswitch;
  80024c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800250:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800252:	846a                	mv	s0,s10
            goto reswitch;
  800254:	b765                	j	8001fc <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  800256:	000aa503          	lw	a0,0(s5)
  80025a:	85a6                	mv	a1,s1
  80025c:	0aa1                	addi	s5,s5,8
  80025e:	9902                	jalr	s2
            break;
  800260:	bfb9                	j	8001be <vprintfmt+0x3a>
    if (lflag >= 2) {
  800262:	4705                	li	a4,1
  800264:	008a8993          	addi	s3,s5,8
  800268:	01074463          	blt	a4,a6,800270 <vprintfmt+0xec>
    else if (lflag) {
  80026c:	22080463          	beqz	a6,800494 <vprintfmt+0x310>
        return va_arg(*ap, long);
  800270:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  800274:	24044463          	bltz	s0,8004bc <vprintfmt+0x338>
            num = getint(&ap, lflag);
  800278:	8622                	mv	a2,s0
  80027a:	8ace                	mv	s5,s3
  80027c:	46a9                	li	a3,10
  80027e:	a89d                	j	8002f4 <vprintfmt+0x170>
            err = va_arg(ap, int);
  800280:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800284:	4761                	li	a4,24
            err = va_arg(ap, int);
  800286:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  800288:	41f7d69b          	sraiw	a3,a5,0x1f
  80028c:	8fb5                	xor	a5,a5,a3
  80028e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800292:	1ad74363          	blt	a4,a3,800438 <vprintfmt+0x2b4>
  800296:	00369793          	slli	a5,a3,0x3
  80029a:	97e2                	add	a5,a5,s8
  80029c:	639c                	ld	a5,0(a5)
  80029e:	18078d63          	beqz	a5,800438 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  8002a2:	86be                	mv	a3,a5
  8002a4:	00000617          	auipc	a2,0x0
  8002a8:	6c460613          	addi	a2,a2,1732 # 800968 <error_string+0x1b8>
  8002ac:	85a6                	mv	a1,s1
  8002ae:	854a                	mv	a0,s2
  8002b0:	240000ef          	jal	ra,8004f0 <printfmt>
  8002b4:	b729                	j	8001be <vprintfmt+0x3a>
            lflag ++;
  8002b6:	00144603          	lbu	a2,1(s0)
  8002ba:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002bc:	846a                	mv	s0,s10
            goto reswitch;
  8002be:	bf3d                	j	8001fc <vprintfmt+0x78>
    if (lflag >= 2) {
  8002c0:	4705                	li	a4,1
  8002c2:	008a8593          	addi	a1,s5,8
  8002c6:	01074463          	blt	a4,a6,8002ce <vprintfmt+0x14a>
    else if (lflag) {
  8002ca:	1e080263          	beqz	a6,8004ae <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  8002ce:	000ab603          	ld	a2,0(s5)
  8002d2:	46a1                	li	a3,8
  8002d4:	8aae                	mv	s5,a1
  8002d6:	a839                	j	8002f4 <vprintfmt+0x170>
            putch('0', putdat);
  8002d8:	03000513          	li	a0,48
  8002dc:	85a6                	mv	a1,s1
  8002de:	e03e                	sd	a5,0(sp)
  8002e0:	9902                	jalr	s2
            putch('x', putdat);
  8002e2:	85a6                	mv	a1,s1
  8002e4:	07800513          	li	a0,120
  8002e8:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002ea:	0aa1                	addi	s5,s5,8
  8002ec:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  8002f0:	6782                	ld	a5,0(sp)
  8002f2:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  8002f4:	876e                	mv	a4,s11
  8002f6:	85a6                	mv	a1,s1
  8002f8:	854a                	mv	a0,s2
  8002fa:	e05ff0ef          	jal	ra,8000fe <printnum>
            break;
  8002fe:	b5c1                	j	8001be <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800300:	000ab603          	ld	a2,0(s5)
  800304:	0aa1                	addi	s5,s5,8
  800306:	1c060663          	beqz	a2,8004d2 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  80030a:	00160413          	addi	s0,a2,1
  80030e:	17b05c63          	blez	s11,800486 <vprintfmt+0x302>
  800312:	02d00593          	li	a1,45
  800316:	14b79263          	bne	a5,a1,80045a <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80031a:	00064783          	lbu	a5,0(a2)
  80031e:	0007851b          	sext.w	a0,a5
  800322:	c905                	beqz	a0,800352 <vprintfmt+0x1ce>
  800324:	000cc563          	bltz	s9,80032e <vprintfmt+0x1aa>
  800328:	3cfd                	addiw	s9,s9,-1
  80032a:	036c8263          	beq	s9,s6,80034e <vprintfmt+0x1ca>
                    putch('?', putdat);
  80032e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800330:	18098463          	beqz	s3,8004b8 <vprintfmt+0x334>
  800334:	3781                	addiw	a5,a5,-32
  800336:	18fbf163          	bleu	a5,s7,8004b8 <vprintfmt+0x334>
                    putch('?', putdat);
  80033a:	03f00513          	li	a0,63
  80033e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800340:	0405                	addi	s0,s0,1
  800342:	fff44783          	lbu	a5,-1(s0)
  800346:	3dfd                	addiw	s11,s11,-1
  800348:	0007851b          	sext.w	a0,a5
  80034c:	fd61                	bnez	a0,800324 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  80034e:	e7b058e3          	blez	s11,8001be <vprintfmt+0x3a>
  800352:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800354:	85a6                	mv	a1,s1
  800356:	02000513          	li	a0,32
  80035a:	9902                	jalr	s2
            for (; width > 0; width --) {
  80035c:	e60d81e3          	beqz	s11,8001be <vprintfmt+0x3a>
  800360:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800362:	85a6                	mv	a1,s1
  800364:	02000513          	li	a0,32
  800368:	9902                	jalr	s2
            for (; width > 0; width --) {
  80036a:	fe0d94e3          	bnez	s11,800352 <vprintfmt+0x1ce>
  80036e:	bd81                	j	8001be <vprintfmt+0x3a>
    if (lflag >= 2) {
  800370:	4705                	li	a4,1
  800372:	008a8593          	addi	a1,s5,8
  800376:	01074463          	blt	a4,a6,80037e <vprintfmt+0x1fa>
    else if (lflag) {
  80037a:	12080063          	beqz	a6,80049a <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  80037e:	000ab603          	ld	a2,0(s5)
  800382:	46a9                	li	a3,10
  800384:	8aae                	mv	s5,a1
  800386:	b7bd                	j	8002f4 <vprintfmt+0x170>
  800388:	00144603          	lbu	a2,1(s0)
            padc = '-';
  80038c:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  800390:	846a                	mv	s0,s10
  800392:	b5ad                	j	8001fc <vprintfmt+0x78>
            putch(ch, putdat);
  800394:	85a6                	mv	a1,s1
  800396:	02500513          	li	a0,37
  80039a:	9902                	jalr	s2
            break;
  80039c:	b50d                	j	8001be <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  80039e:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8003a2:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8003a6:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8003a8:	846a                	mv	s0,s10
            if (width < 0)
  8003aa:	e40dd9e3          	bgez	s11,8001fc <vprintfmt+0x78>
                width = precision, precision = -1;
  8003ae:	8de6                	mv	s11,s9
  8003b0:	5cfd                	li	s9,-1
  8003b2:	b5a9                	j	8001fc <vprintfmt+0x78>
            goto reswitch;
  8003b4:	00144603          	lbu	a2,1(s0)
            padc = '0';
  8003b8:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  8003bc:	846a                	mv	s0,s10
            goto reswitch;
  8003be:	bd3d                	j	8001fc <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  8003c0:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8003c4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8003c8:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8003ca:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8003ce:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003d2:	fcd56ce3          	bltu	a0,a3,8003aa <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  8003d6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8003d8:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8003dc:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  8003e0:	0196873b          	addw	a4,a3,s9
  8003e4:	0017171b          	slliw	a4,a4,0x1
  8003e8:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8003ec:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8003f0:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8003f4:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003f8:	fcd57fe3          	bleu	a3,a0,8003d6 <vprintfmt+0x252>
  8003fc:	b77d                	j	8003aa <vprintfmt+0x226>
            if (width < 0)
  8003fe:	fffdc693          	not	a3,s11
  800402:	96fd                	srai	a3,a3,0x3f
  800404:	00ddfdb3          	and	s11,s11,a3
  800408:	00144603          	lbu	a2,1(s0)
  80040c:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  80040e:	846a                	mv	s0,s10
  800410:	b3f5                	j	8001fc <vprintfmt+0x78>
            putch('%', putdat);
  800412:	85a6                	mv	a1,s1
  800414:	02500513          	li	a0,37
  800418:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80041a:	fff44703          	lbu	a4,-1(s0)
  80041e:	02500793          	li	a5,37
  800422:	8d22                	mv	s10,s0
  800424:	d8f70de3          	beq	a4,a5,8001be <vprintfmt+0x3a>
  800428:	02500713          	li	a4,37
  80042c:	1d7d                	addi	s10,s10,-1
  80042e:	fffd4783          	lbu	a5,-1(s10)
  800432:	fee79de3          	bne	a5,a4,80042c <vprintfmt+0x2a8>
  800436:	b361                	j	8001be <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800438:	00000617          	auipc	a2,0x0
  80043c:	52060613          	addi	a2,a2,1312 # 800958 <error_string+0x1a8>
  800440:	85a6                	mv	a1,s1
  800442:	854a                	mv	a0,s2
  800444:	0ac000ef          	jal	ra,8004f0 <printfmt>
  800448:	bb9d                	j	8001be <vprintfmt+0x3a>
                p = "(null)";
  80044a:	00000617          	auipc	a2,0x0
  80044e:	50660613          	addi	a2,a2,1286 # 800950 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800452:	00000417          	auipc	s0,0x0
  800456:	4ff40413          	addi	s0,s0,1279 # 800951 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80045a:	8532                	mv	a0,a2
  80045c:	85e6                	mv	a1,s9
  80045e:	e032                	sd	a2,0(sp)
  800460:	e43e                	sd	a5,8(sp)
  800462:	120000ef          	jal	ra,800582 <strnlen>
  800466:	40ad8dbb          	subw	s11,s11,a0
  80046a:	6602                	ld	a2,0(sp)
  80046c:	01b05d63          	blez	s11,800486 <vprintfmt+0x302>
  800470:	67a2                	ld	a5,8(sp)
  800472:	2781                	sext.w	a5,a5
  800474:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  800476:	6522                	ld	a0,8(sp)
  800478:	85a6                	mv	a1,s1
  80047a:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  80047c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  80047e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800480:	6602                	ld	a2,0(sp)
  800482:	fe0d9ae3          	bnez	s11,800476 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800486:	00064783          	lbu	a5,0(a2)
  80048a:	0007851b          	sext.w	a0,a5
  80048e:	e8051be3          	bnez	a0,800324 <vprintfmt+0x1a0>
  800492:	b335                	j	8001be <vprintfmt+0x3a>
        return va_arg(*ap, int);
  800494:	000aa403          	lw	s0,0(s5)
  800498:	bbf1                	j	800274 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  80049a:	000ae603          	lwu	a2,0(s5)
  80049e:	46a9                	li	a3,10
  8004a0:	8aae                	mv	s5,a1
  8004a2:	bd89                	j	8002f4 <vprintfmt+0x170>
  8004a4:	000ae603          	lwu	a2,0(s5)
  8004a8:	46c1                	li	a3,16
  8004aa:	8aae                	mv	s5,a1
  8004ac:	b5a1                	j	8002f4 <vprintfmt+0x170>
  8004ae:	000ae603          	lwu	a2,0(s5)
  8004b2:	46a1                	li	a3,8
  8004b4:	8aae                	mv	s5,a1
  8004b6:	bd3d                	j	8002f4 <vprintfmt+0x170>
                    putch(ch, putdat);
  8004b8:	9902                	jalr	s2
  8004ba:	b559                	j	800340 <vprintfmt+0x1bc>
                putch('-', putdat);
  8004bc:	85a6                	mv	a1,s1
  8004be:	02d00513          	li	a0,45
  8004c2:	e03e                	sd	a5,0(sp)
  8004c4:	9902                	jalr	s2
                num = -(long long)num;
  8004c6:	8ace                	mv	s5,s3
  8004c8:	40800633          	neg	a2,s0
  8004cc:	46a9                	li	a3,10
  8004ce:	6782                	ld	a5,0(sp)
  8004d0:	b515                	j	8002f4 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  8004d2:	01b05663          	blez	s11,8004de <vprintfmt+0x35a>
  8004d6:	02d00693          	li	a3,45
  8004da:	f6d798e3          	bne	a5,a3,80044a <vprintfmt+0x2c6>
  8004de:	00000417          	auipc	s0,0x0
  8004e2:	47340413          	addi	s0,s0,1139 # 800951 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e6:	02800513          	li	a0,40
  8004ea:	02800793          	li	a5,40
  8004ee:	bd1d                	j	800324 <vprintfmt+0x1a0>

00000000008004f0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004f0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004f2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004f6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004f8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004fa:	ec06                	sd	ra,24(sp)
  8004fc:	f83a                	sd	a4,48(sp)
  8004fe:	fc3e                	sd	a5,56(sp)
  800500:	e0c2                	sd	a6,64(sp)
  800502:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800504:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800506:	c7fff0ef          	jal	ra,800184 <vprintfmt>
}
  80050a:	60e2                	ld	ra,24(sp)
  80050c:	6161                	addi	sp,sp,80
  80050e:	8082                	ret

0000000000800510 <vsnprintf>:
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
    struct sprintbuf b = {str, str + size - 1, 0};
  800510:	15fd                	addi	a1,a1,-1
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  800512:	7179                	addi	sp,sp,-48
    struct sprintbuf b = {str, str + size - 1, 0};
  800514:	95aa                	add	a1,a1,a0
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  800516:	f406                	sd	ra,40(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
  800518:	e42a                	sd	a0,8(sp)
  80051a:	e82e                	sd	a1,16(sp)
  80051c:	cc02                	sw	zero,24(sp)
    if (str == NULL || b.buf > b.ebuf) {
  80051e:	c10d                	beqz	a0,800540 <vsnprintf+0x30>
  800520:	02a5e063          	bltu	a1,a0,800540 <vsnprintf+0x30>
        return -E_INVAL;
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800524:	00000517          	auipc	a0,0x0
  800528:	c4650513          	addi	a0,a0,-954 # 80016a <sprintputch>
  80052c:	002c                	addi	a1,sp,8
  80052e:	c57ff0ef          	jal	ra,800184 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800532:	67a2                	ld	a5,8(sp)
  800534:	00078023          	sb	zero,0(a5)
    return b.cnt;
  800538:	4562                	lw	a0,24(sp)
}
  80053a:	70a2                	ld	ra,40(sp)
  80053c:	6145                	addi	sp,sp,48
  80053e:	8082                	ret
        return -E_INVAL;
  800540:	5575                	li	a0,-3
  800542:	bfe5                	j	80053a <vsnprintf+0x2a>

0000000000800544 <snprintf>:
snprintf(char *str, size_t size, const char *fmt, ...) {
  800544:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800546:	02810313          	addi	t1,sp,40
snprintf(char *str, size_t size, const char *fmt, ...) {
  80054a:	f436                	sd	a3,40(sp)
    cnt = vsnprintf(str, size, fmt, ap);
  80054c:	869a                	mv	a3,t1
snprintf(char *str, size_t size, const char *fmt, ...) {
  80054e:	ec06                	sd	ra,24(sp)
  800550:	f83a                	sd	a4,48(sp)
  800552:	fc3e                	sd	a5,56(sp)
  800554:	e0c2                	sd	a6,64(sp)
  800556:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800558:	e41a                	sd	t1,8(sp)
    cnt = vsnprintf(str, size, fmt, ap);
  80055a:	fb7ff0ef          	jal	ra,800510 <vsnprintf>
}
  80055e:	60e2                	ld	ra,24(sp)
  800560:	6161                	addi	sp,sp,80
  800562:	8082                	ret

0000000000800564 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  800564:	00054783          	lbu	a5,0(a0)
  800568:	cb91                	beqz	a5,80057c <strlen+0x18>
    size_t cnt = 0;
  80056a:	4781                	li	a5,0
        cnt ++;
  80056c:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
  80056e:	00f50733          	add	a4,a0,a5
  800572:	00074703          	lbu	a4,0(a4)
  800576:	fb7d                	bnez	a4,80056c <strlen+0x8>
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

0000000000800582 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800582:	c185                	beqz	a1,8005a2 <strnlen+0x20>
  800584:	00054783          	lbu	a5,0(a0)
  800588:	cf89                	beqz	a5,8005a2 <strnlen+0x20>
    size_t cnt = 0;
  80058a:	4781                	li	a5,0
  80058c:	a021                	j	800594 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  80058e:	00074703          	lbu	a4,0(a4)
  800592:	c711                	beqz	a4,80059e <strnlen+0x1c>
        cnt ++;
  800594:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800596:	00f50733          	add	a4,a0,a5
  80059a:	fef59ae3          	bne	a1,a5,80058e <strnlen+0xc>
    }
    return cnt;
}
  80059e:	853e                	mv	a0,a5
  8005a0:	8082                	ret
    size_t cnt = 0;
  8005a2:	4781                	li	a5,0
}
  8005a4:	853e                	mv	a0,a5
  8005a6:	8082                	ret

00000000008005a8 <forktree>:
        exit(0);
    }
}

void
forktree(const char *cur) {
  8005a8:	1141                	addi	sp,sp,-16
  8005aa:	e406                	sd	ra,8(sp)
  8005ac:	e022                	sd	s0,0(sp)
  8005ae:	842a                	mv	s0,a0
    cprintf("%04x: I am '%s'\n", getpid(), cur);
  8005b0:	b3fff0ef          	jal	ra,8000ee <getpid>
  8005b4:	8622                	mv	a2,s0
  8005b6:	85aa                	mv	a1,a0
  8005b8:	00000517          	auipc	a0,0x0
  8005bc:	3c050513          	addi	a0,a0,960 # 800978 <error_string+0x1c8>
  8005c0:	a81ff0ef          	jal	ra,800040 <cprintf>

    forkchild(cur, '0');
  8005c4:	8522                	mv	a0,s0
  8005c6:	03000593          	li	a1,48
  8005ca:	014000ef          	jal	ra,8005de <forkchild>
    forkchild(cur, '1');
  8005ce:	8522                	mv	a0,s0
}
  8005d0:	6402                	ld	s0,0(sp)
  8005d2:	60a2                	ld	ra,8(sp)
    forkchild(cur, '1');
  8005d4:	03100593          	li	a1,49
}
  8005d8:	0141                	addi	sp,sp,16
    forkchild(cur, '1');
  8005da:	0040006f          	j	8005de <forkchild>

00000000008005de <forkchild>:
forkchild(const char *cur, char branch) {
  8005de:	7179                	addi	sp,sp,-48
  8005e0:	f022                	sd	s0,32(sp)
  8005e2:	ec26                	sd	s1,24(sp)
  8005e4:	f406                	sd	ra,40(sp)
  8005e6:	842a                	mv	s0,a0
  8005e8:	84ae                	mv	s1,a1
    if (strlen(cur) >= DEPTH)
  8005ea:	f7bff0ef          	jal	ra,800564 <strlen>
  8005ee:	478d                	li	a5,3
  8005f0:	00a7f763          	bleu	a0,a5,8005fe <forkchild+0x20>
}
  8005f4:	70a2                	ld	ra,40(sp)
  8005f6:	7402                	ld	s0,32(sp)
  8005f8:	64e2                	ld	s1,24(sp)
  8005fa:	6145                	addi	sp,sp,48
  8005fc:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  8005fe:	8726                	mv	a4,s1
  800600:	86a2                	mv	a3,s0
  800602:	00000617          	auipc	a2,0x0
  800606:	36e60613          	addi	a2,a2,878 # 800970 <error_string+0x1c0>
  80060a:	4595                	li	a1,5
  80060c:	0028                	addi	a0,sp,8
  80060e:	f37ff0ef          	jal	ra,800544 <snprintf>
    if (fork() == 0) {
  800612:	ad5ff0ef          	jal	ra,8000e6 <fork>
  800616:	fd79                	bnez	a0,8005f4 <forkchild+0x16>
        forktree(nxt);
  800618:	0028                	addi	a0,sp,8
  80061a:	f8fff0ef          	jal	ra,8005a8 <forktree>
        yield();
  80061e:	acdff0ef          	jal	ra,8000ea <yield>
        exit(0);
  800622:	4501                	li	a0,0
  800624:	aadff0ef          	jal	ra,8000d0 <exit>

0000000000800628 <main>:

int
main(void) {
  800628:	1141                	addi	sp,sp,-16
    forktree("");
  80062a:	00000517          	auipc	a0,0x0
  80062e:	35e50513          	addi	a0,a0,862 # 800988 <error_string+0x1d8>
main(void) {
  800632:	e406                	sd	ra,8(sp)
    forktree("");
  800634:	f75ff0ef          	jal	ra,8005a8 <forktree>
    return 0;
}
  800638:	60a2                	ld	ra,8(sp)
  80063a:	4501                	li	a0,0
  80063c:	0141                	addi	sp,sp,16
  80063e:	8082                	ret
