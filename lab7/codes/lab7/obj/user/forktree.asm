
obj/__user_forktree.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  800020:	0d0000ef          	jal	ra,8000f0 <umain>
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
  80002e:	098000ef          	jal	ra,8000c6 <sys_putc>
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
  800068:	11a000ef          	jal	ra,800182 <vprintfmt>
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
  800094:	4522                	lw	a0,8(sp)
  800096:	55a2                	lw	a1,40(sp)
  800098:	5642                	lw	a2,48(sp)
  80009a:	56e2                	lw	a3,56(sp)
  80009c:	4706                	lw	a4,64(sp)
  80009e:	47a6                	lw	a5,72(sp)
  8000a0:	00000073          	ecall
  8000a4:	ce2a                	sw	a0,28(sp)
          "m" (a[3]),
          "m" (a[4])
        : "memory"
      );
    return ret;
}
  8000a6:	4572                	lw	a0,28(sp)
  8000a8:	6149                	addi	sp,sp,144
  8000aa:	8082                	ret

00000000008000ac <sys_exit>:

int
sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
  8000ac:	85aa                	mv	a1,a0
  8000ae:	4505                	li	a0,1
  8000b0:	fc5ff06f          	j	800074 <syscall>

00000000008000b4 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  8000b4:	4509                	li	a0,2
  8000b6:	fbfff06f          	j	800074 <syscall>

00000000008000ba <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  8000ba:	4529                	li	a0,10
  8000bc:	fb9ff06f          	j	800074 <syscall>

00000000008000c0 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000c0:	4549                	li	a0,18
  8000c2:	fb3ff06f          	j	800074 <syscall>

00000000008000c6 <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000c6:	85aa                	mv	a1,a0
  8000c8:	4579                	li	a0,30
  8000ca:	fabff06f          	j	800074 <syscall>

00000000008000ce <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000ce:	1141                	addi	sp,sp,-16
  8000d0:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000d2:	fdbff0ef          	jal	ra,8000ac <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000d6:	00000517          	auipc	a0,0x0
  8000da:	56a50513          	addi	a0,a0,1386 # 800640 <main+0x1a>
  8000de:	f63ff0ef          	jal	ra,800040 <cprintf>
    while (1);
  8000e2:	a001                	j	8000e2 <exit+0x14>

00000000008000e4 <fork>:
}

int
fork(void) {
    return sys_fork();
  8000e4:	fd1ff06f          	j	8000b4 <sys_fork>

00000000008000e8 <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  8000e8:	fd3ff06f          	j	8000ba <sys_yield>

00000000008000ec <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000ec:	fd5ff06f          	j	8000c0 <sys_getpid>

00000000008000f0 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000f0:	1141                	addi	sp,sp,-16
  8000f2:	e406                	sd	ra,8(sp)
    int ret = main();
  8000f4:	532000ef          	jal	ra,800626 <main>
    exit(ret);
  8000f8:	fd7ff0ef          	jal	ra,8000ce <exit>

00000000008000fc <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000fc:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800100:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800102:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800106:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800108:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80010c:	f022                	sd	s0,32(sp)
  80010e:	ec26                	sd	s1,24(sp)
  800110:	e84a                	sd	s2,16(sp)
  800112:	f406                	sd	ra,40(sp)
  800114:	e44e                	sd	s3,8(sp)
  800116:	84aa                	mv	s1,a0
  800118:	892e                	mv	s2,a1
  80011a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80011e:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800120:	03067e63          	bleu	a6,a2,80015c <printnum+0x60>
  800124:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800126:	00805763          	blez	s0,800134 <printnum+0x38>
  80012a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80012c:	85ca                	mv	a1,s2
  80012e:	854e                	mv	a0,s3
  800130:	9482                	jalr	s1
        while (-- width > 0)
  800132:	fc65                	bnez	s0,80012a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800134:	1a02                	slli	s4,s4,0x20
  800136:	020a5a13          	srli	s4,s4,0x20
  80013a:	00000797          	auipc	a5,0x0
  80013e:	73e78793          	addi	a5,a5,1854 # 800878 <error_string+0xc8>
  800142:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800144:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800146:	000a4503          	lbu	a0,0(s4)
}
  80014a:	70a2                	ld	ra,40(sp)
  80014c:	69a2                	ld	s3,8(sp)
  80014e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800150:	85ca                	mv	a1,s2
  800152:	8326                	mv	t1,s1
}
  800154:	6942                	ld	s2,16(sp)
  800156:	64e2                	ld	s1,24(sp)
  800158:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80015a:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  80015c:	03065633          	divu	a2,a2,a6
  800160:	8722                	mv	a4,s0
  800162:	f9bff0ef          	jal	ra,8000fc <printnum>
  800166:	b7f9                	j	800134 <printnum+0x38>

0000000000800168 <sprintputch>:
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
    b->cnt ++;
  800168:	499c                	lw	a5,16(a1)
    if (b->buf < b->ebuf) {
  80016a:	6198                	ld	a4,0(a1)
  80016c:	6594                	ld	a3,8(a1)
    b->cnt ++;
  80016e:	2785                	addiw	a5,a5,1
  800170:	c99c                	sw	a5,16(a1)
    if (b->buf < b->ebuf) {
  800172:	00d77763          	bleu	a3,a4,800180 <sprintputch+0x18>
        *b->buf ++ = ch;
  800176:	00170793          	addi	a5,a4,1
  80017a:	e19c                	sd	a5,0(a1)
  80017c:	00a70023          	sb	a0,0(a4)
    }
}
  800180:	8082                	ret

0000000000800182 <vprintfmt>:
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800182:	7119                	addi	sp,sp,-128
  800184:	f4a6                	sd	s1,104(sp)
  800186:	f0ca                	sd	s2,96(sp)
  800188:	e8d2                	sd	s4,80(sp)
  80018a:	e4d6                	sd	s5,72(sp)
  80018c:	e0da                	sd	s6,64(sp)
  80018e:	fc5e                	sd	s7,56(sp)
  800190:	f862                	sd	s8,48(sp)
  800192:	f06a                	sd	s10,32(sp)
  800194:	fc86                	sd	ra,120(sp)
  800196:	f8a2                	sd	s0,112(sp)
  800198:	ecce                	sd	s3,88(sp)
  80019a:	f466                	sd	s9,40(sp)
  80019c:	ec6e                	sd	s11,24(sp)
  80019e:	892a                	mv	s2,a0
  8001a0:	84ae                	mv	s1,a1
  8001a2:	8d32                	mv	s10,a2
  8001a4:	8ab6                	mv	s5,a3
        width = precision = -1;
  8001a6:	5b7d                	li	s6,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001a8:	00000a17          	auipc	s4,0x0
  8001ac:	4aca0a13          	addi	s4,s4,1196 # 800654 <main+0x2e>
                if (altflag && (ch < ' ' || ch > '~')) {
  8001b0:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001b4:	00000c17          	auipc	s8,0x0
  8001b8:	5fcc0c13          	addi	s8,s8,1532 # 8007b0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001bc:	000d4503          	lbu	a0,0(s10)
  8001c0:	02500793          	li	a5,37
  8001c4:	001d0413          	addi	s0,s10,1
  8001c8:	00f50e63          	beq	a0,a5,8001e4 <vprintfmt+0x62>
            if (ch == '\0') {
  8001cc:	c521                	beqz	a0,800214 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ce:	02500993          	li	s3,37
  8001d2:	a011                	j	8001d6 <vprintfmt+0x54>
            if (ch == '\0') {
  8001d4:	c121                	beqz	a0,800214 <vprintfmt+0x92>
            putch(ch, putdat);
  8001d6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001d8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001da:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001dc:	fff44503          	lbu	a0,-1(s0)
  8001e0:	ff351ae3          	bne	a0,s3,8001d4 <vprintfmt+0x52>
  8001e4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001e8:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001ec:	4981                	li	s3,0
  8001ee:	4801                	li	a6,0
        width = precision = -1;
  8001f0:	5cfd                	li	s9,-1
  8001f2:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001f4:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  8001f8:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001fa:	fdd6069b          	addiw	a3,a2,-35
  8001fe:	0ff6f693          	andi	a3,a3,255
  800202:	00140d13          	addi	s10,s0,1
  800206:	20d5e563          	bltu	a1,a3,800410 <vprintfmt+0x28e>
  80020a:	068a                	slli	a3,a3,0x2
  80020c:	96d2                	add	a3,a3,s4
  80020e:	4294                	lw	a3,0(a3)
  800210:	96d2                	add	a3,a3,s4
  800212:	8682                	jr	a3
}
  800214:	70e6                	ld	ra,120(sp)
  800216:	7446                	ld	s0,112(sp)
  800218:	74a6                	ld	s1,104(sp)
  80021a:	7906                	ld	s2,96(sp)
  80021c:	69e6                	ld	s3,88(sp)
  80021e:	6a46                	ld	s4,80(sp)
  800220:	6aa6                	ld	s5,72(sp)
  800222:	6b06                	ld	s6,64(sp)
  800224:	7be2                	ld	s7,56(sp)
  800226:	7c42                	ld	s8,48(sp)
  800228:	7ca2                	ld	s9,40(sp)
  80022a:	7d02                	ld	s10,32(sp)
  80022c:	6de2                	ld	s11,24(sp)
  80022e:	6109                	addi	sp,sp,128
  800230:	8082                	ret
    if (lflag >= 2) {
  800232:	4705                	li	a4,1
  800234:	008a8593          	addi	a1,s5,8
  800238:	01074463          	blt	a4,a6,800240 <vprintfmt+0xbe>
    else if (lflag) {
  80023c:	26080363          	beqz	a6,8004a2 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  800240:	000ab603          	ld	a2,0(s5)
  800244:	46c1                	li	a3,16
  800246:	8aae                	mv	s5,a1
  800248:	a06d                	j	8002f2 <vprintfmt+0x170>
            goto reswitch;
  80024a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  80024e:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800250:	846a                	mv	s0,s10
            goto reswitch;
  800252:	b765                	j	8001fa <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  800254:	000aa503          	lw	a0,0(s5)
  800258:	85a6                	mv	a1,s1
  80025a:	0aa1                	addi	s5,s5,8
  80025c:	9902                	jalr	s2
            break;
  80025e:	bfb9                	j	8001bc <vprintfmt+0x3a>
    if (lflag >= 2) {
  800260:	4705                	li	a4,1
  800262:	008a8993          	addi	s3,s5,8
  800266:	01074463          	blt	a4,a6,80026e <vprintfmt+0xec>
    else if (lflag) {
  80026a:	22080463          	beqz	a6,800492 <vprintfmt+0x310>
        return va_arg(*ap, long);
  80026e:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  800272:	24044463          	bltz	s0,8004ba <vprintfmt+0x338>
            num = getint(&ap, lflag);
  800276:	8622                	mv	a2,s0
  800278:	8ace                	mv	s5,s3
  80027a:	46a9                	li	a3,10
  80027c:	a89d                	j	8002f2 <vprintfmt+0x170>
            err = va_arg(ap, int);
  80027e:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800282:	4761                	li	a4,24
            err = va_arg(ap, int);
  800284:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  800286:	41f7d69b          	sraiw	a3,a5,0x1f
  80028a:	8fb5                	xor	a5,a5,a3
  80028c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800290:	1ad74363          	blt	a4,a3,800436 <vprintfmt+0x2b4>
  800294:	00369793          	slli	a5,a3,0x3
  800298:	97e2                	add	a5,a5,s8
  80029a:	639c                	ld	a5,0(a5)
  80029c:	18078d63          	beqz	a5,800436 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  8002a0:	86be                	mv	a3,a5
  8002a2:	00000617          	auipc	a2,0x0
  8002a6:	6c660613          	addi	a2,a2,1734 # 800968 <error_string+0x1b8>
  8002aa:	85a6                	mv	a1,s1
  8002ac:	854a                	mv	a0,s2
  8002ae:	240000ef          	jal	ra,8004ee <printfmt>
  8002b2:	b729                	j	8001bc <vprintfmt+0x3a>
            lflag ++;
  8002b4:	00144603          	lbu	a2,1(s0)
  8002b8:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002ba:	846a                	mv	s0,s10
            goto reswitch;
  8002bc:	bf3d                	j	8001fa <vprintfmt+0x78>
    if (lflag >= 2) {
  8002be:	4705                	li	a4,1
  8002c0:	008a8593          	addi	a1,s5,8
  8002c4:	01074463          	blt	a4,a6,8002cc <vprintfmt+0x14a>
    else if (lflag) {
  8002c8:	1e080263          	beqz	a6,8004ac <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  8002cc:	000ab603          	ld	a2,0(s5)
  8002d0:	46a1                	li	a3,8
  8002d2:	8aae                	mv	s5,a1
  8002d4:	a839                	j	8002f2 <vprintfmt+0x170>
            putch('0', putdat);
  8002d6:	03000513          	li	a0,48
  8002da:	85a6                	mv	a1,s1
  8002dc:	e03e                	sd	a5,0(sp)
  8002de:	9902                	jalr	s2
            putch('x', putdat);
  8002e0:	85a6                	mv	a1,s1
  8002e2:	07800513          	li	a0,120
  8002e6:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002e8:	0aa1                	addi	s5,s5,8
  8002ea:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  8002ee:	6782                	ld	a5,0(sp)
  8002f0:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  8002f2:	876e                	mv	a4,s11
  8002f4:	85a6                	mv	a1,s1
  8002f6:	854a                	mv	a0,s2
  8002f8:	e05ff0ef          	jal	ra,8000fc <printnum>
            break;
  8002fc:	b5c1                	j	8001bc <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  8002fe:	000ab603          	ld	a2,0(s5)
  800302:	0aa1                	addi	s5,s5,8
  800304:	1c060663          	beqz	a2,8004d0 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  800308:	00160413          	addi	s0,a2,1
  80030c:	17b05c63          	blez	s11,800484 <vprintfmt+0x302>
  800310:	02d00593          	li	a1,45
  800314:	14b79263          	bne	a5,a1,800458 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800318:	00064783          	lbu	a5,0(a2)
  80031c:	0007851b          	sext.w	a0,a5
  800320:	c905                	beqz	a0,800350 <vprintfmt+0x1ce>
  800322:	000cc563          	bltz	s9,80032c <vprintfmt+0x1aa>
  800326:	3cfd                	addiw	s9,s9,-1
  800328:	036c8263          	beq	s9,s6,80034c <vprintfmt+0x1ca>
                    putch('?', putdat);
  80032c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80032e:	18098463          	beqz	s3,8004b6 <vprintfmt+0x334>
  800332:	3781                	addiw	a5,a5,-32
  800334:	18fbf163          	bleu	a5,s7,8004b6 <vprintfmt+0x334>
                    putch('?', putdat);
  800338:	03f00513          	li	a0,63
  80033c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80033e:	0405                	addi	s0,s0,1
  800340:	fff44783          	lbu	a5,-1(s0)
  800344:	3dfd                	addiw	s11,s11,-1
  800346:	0007851b          	sext.w	a0,a5
  80034a:	fd61                	bnez	a0,800322 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  80034c:	e7b058e3          	blez	s11,8001bc <vprintfmt+0x3a>
  800350:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800352:	85a6                	mv	a1,s1
  800354:	02000513          	li	a0,32
  800358:	9902                	jalr	s2
            for (; width > 0; width --) {
  80035a:	e60d81e3          	beqz	s11,8001bc <vprintfmt+0x3a>
  80035e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800360:	85a6                	mv	a1,s1
  800362:	02000513          	li	a0,32
  800366:	9902                	jalr	s2
            for (; width > 0; width --) {
  800368:	fe0d94e3          	bnez	s11,800350 <vprintfmt+0x1ce>
  80036c:	bd81                	j	8001bc <vprintfmt+0x3a>
    if (lflag >= 2) {
  80036e:	4705                	li	a4,1
  800370:	008a8593          	addi	a1,s5,8
  800374:	01074463          	blt	a4,a6,80037c <vprintfmt+0x1fa>
    else if (lflag) {
  800378:	12080063          	beqz	a6,800498 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  80037c:	000ab603          	ld	a2,0(s5)
  800380:	46a9                	li	a3,10
  800382:	8aae                	mv	s5,a1
  800384:	b7bd                	j	8002f2 <vprintfmt+0x170>
  800386:	00144603          	lbu	a2,1(s0)
            padc = '-';
  80038a:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  80038e:	846a                	mv	s0,s10
  800390:	b5ad                	j	8001fa <vprintfmt+0x78>
            putch(ch, putdat);
  800392:	85a6                	mv	a1,s1
  800394:	02500513          	li	a0,37
  800398:	9902                	jalr	s2
            break;
  80039a:	b50d                	j	8001bc <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  80039c:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8003a0:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8003a4:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8003a6:	846a                	mv	s0,s10
            if (width < 0)
  8003a8:	e40dd9e3          	bgez	s11,8001fa <vprintfmt+0x78>
                width = precision, precision = -1;
  8003ac:	8de6                	mv	s11,s9
  8003ae:	5cfd                	li	s9,-1
  8003b0:	b5a9                	j	8001fa <vprintfmt+0x78>
            goto reswitch;
  8003b2:	00144603          	lbu	a2,1(s0)
            padc = '0';
  8003b6:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  8003ba:	846a                	mv	s0,s10
            goto reswitch;
  8003bc:	bd3d                	j	8001fa <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  8003be:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8003c2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8003c6:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8003c8:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8003cc:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003d0:	fcd56ce3          	bltu	a0,a3,8003a8 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  8003d4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8003d6:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8003da:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  8003de:	0196873b          	addw	a4,a3,s9
  8003e2:	0017171b          	slliw	a4,a4,0x1
  8003e6:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8003ea:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8003ee:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8003f2:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003f6:	fcd57fe3          	bleu	a3,a0,8003d4 <vprintfmt+0x252>
  8003fa:	b77d                	j	8003a8 <vprintfmt+0x226>
            if (width < 0)
  8003fc:	fffdc693          	not	a3,s11
  800400:	96fd                	srai	a3,a3,0x3f
  800402:	00ddfdb3          	and	s11,s11,a3
  800406:	00144603          	lbu	a2,1(s0)
  80040a:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  80040c:	846a                	mv	s0,s10
  80040e:	b3f5                	j	8001fa <vprintfmt+0x78>
            putch('%', putdat);
  800410:	85a6                	mv	a1,s1
  800412:	02500513          	li	a0,37
  800416:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800418:	fff44703          	lbu	a4,-1(s0)
  80041c:	02500793          	li	a5,37
  800420:	8d22                	mv	s10,s0
  800422:	d8f70de3          	beq	a4,a5,8001bc <vprintfmt+0x3a>
  800426:	02500713          	li	a4,37
  80042a:	1d7d                	addi	s10,s10,-1
  80042c:	fffd4783          	lbu	a5,-1(s10)
  800430:	fee79de3          	bne	a5,a4,80042a <vprintfmt+0x2a8>
  800434:	b361                	j	8001bc <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800436:	00000617          	auipc	a2,0x0
  80043a:	52260613          	addi	a2,a2,1314 # 800958 <error_string+0x1a8>
  80043e:	85a6                	mv	a1,s1
  800440:	854a                	mv	a0,s2
  800442:	0ac000ef          	jal	ra,8004ee <printfmt>
  800446:	bb9d                	j	8001bc <vprintfmt+0x3a>
                p = "(null)";
  800448:	00000617          	auipc	a2,0x0
  80044c:	50860613          	addi	a2,a2,1288 # 800950 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800450:	00000417          	auipc	s0,0x0
  800454:	50140413          	addi	s0,s0,1281 # 800951 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800458:	8532                	mv	a0,a2
  80045a:	85e6                	mv	a1,s9
  80045c:	e032                	sd	a2,0(sp)
  80045e:	e43e                	sd	a5,8(sp)
  800460:	120000ef          	jal	ra,800580 <strnlen>
  800464:	40ad8dbb          	subw	s11,s11,a0
  800468:	6602                	ld	a2,0(sp)
  80046a:	01b05d63          	blez	s11,800484 <vprintfmt+0x302>
  80046e:	67a2                	ld	a5,8(sp)
  800470:	2781                	sext.w	a5,a5
  800472:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  800474:	6522                	ld	a0,8(sp)
  800476:	85a6                	mv	a1,s1
  800478:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  80047a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  80047c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80047e:	6602                	ld	a2,0(sp)
  800480:	fe0d9ae3          	bnez	s11,800474 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800484:	00064783          	lbu	a5,0(a2)
  800488:	0007851b          	sext.w	a0,a5
  80048c:	e8051be3          	bnez	a0,800322 <vprintfmt+0x1a0>
  800490:	b335                	j	8001bc <vprintfmt+0x3a>
        return va_arg(*ap, int);
  800492:	000aa403          	lw	s0,0(s5)
  800496:	bbf1                	j	800272 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  800498:	000ae603          	lwu	a2,0(s5)
  80049c:	46a9                	li	a3,10
  80049e:	8aae                	mv	s5,a1
  8004a0:	bd89                	j	8002f2 <vprintfmt+0x170>
  8004a2:	000ae603          	lwu	a2,0(s5)
  8004a6:	46c1                	li	a3,16
  8004a8:	8aae                	mv	s5,a1
  8004aa:	b5a1                	j	8002f2 <vprintfmt+0x170>
  8004ac:	000ae603          	lwu	a2,0(s5)
  8004b0:	46a1                	li	a3,8
  8004b2:	8aae                	mv	s5,a1
  8004b4:	bd3d                	j	8002f2 <vprintfmt+0x170>
                    putch(ch, putdat);
  8004b6:	9902                	jalr	s2
  8004b8:	b559                	j	80033e <vprintfmt+0x1bc>
                putch('-', putdat);
  8004ba:	85a6                	mv	a1,s1
  8004bc:	02d00513          	li	a0,45
  8004c0:	e03e                	sd	a5,0(sp)
  8004c2:	9902                	jalr	s2
                num = -(long long)num;
  8004c4:	8ace                	mv	s5,s3
  8004c6:	40800633          	neg	a2,s0
  8004ca:	46a9                	li	a3,10
  8004cc:	6782                	ld	a5,0(sp)
  8004ce:	b515                	j	8002f2 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  8004d0:	01b05663          	blez	s11,8004dc <vprintfmt+0x35a>
  8004d4:	02d00693          	li	a3,45
  8004d8:	f6d798e3          	bne	a5,a3,800448 <vprintfmt+0x2c6>
  8004dc:	00000417          	auipc	s0,0x0
  8004e0:	47540413          	addi	s0,s0,1141 # 800951 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e4:	02800513          	li	a0,40
  8004e8:	02800793          	li	a5,40
  8004ec:	bd1d                	j	800322 <vprintfmt+0x1a0>

00000000008004ee <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ee:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004f0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004f4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004f6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004f8:	ec06                	sd	ra,24(sp)
  8004fa:	f83a                	sd	a4,48(sp)
  8004fc:	fc3e                	sd	a5,56(sp)
  8004fe:	e0c2                	sd	a6,64(sp)
  800500:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800502:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800504:	c7fff0ef          	jal	ra,800182 <vprintfmt>
}
  800508:	60e2                	ld	ra,24(sp)
  80050a:	6161                	addi	sp,sp,80
  80050c:	8082                	ret

000000000080050e <vsnprintf>:
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
    struct sprintbuf b = {str, str + size - 1, 0};
  80050e:	15fd                	addi	a1,a1,-1
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  800510:	7179                	addi	sp,sp,-48
    struct sprintbuf b = {str, str + size - 1, 0};
  800512:	95aa                	add	a1,a1,a0
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  800514:	f406                	sd	ra,40(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
  800516:	e42a                	sd	a0,8(sp)
  800518:	e82e                	sd	a1,16(sp)
  80051a:	cc02                	sw	zero,24(sp)
    if (str == NULL || b.buf > b.ebuf) {
  80051c:	c10d                	beqz	a0,80053e <vsnprintf+0x30>
  80051e:	02a5e063          	bltu	a1,a0,80053e <vsnprintf+0x30>
        return -E_INVAL;
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800522:	00000517          	auipc	a0,0x0
  800526:	c4650513          	addi	a0,a0,-954 # 800168 <sprintputch>
  80052a:	002c                	addi	a1,sp,8
  80052c:	c57ff0ef          	jal	ra,800182 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800530:	67a2                	ld	a5,8(sp)
  800532:	00078023          	sb	zero,0(a5)
    return b.cnt;
  800536:	4562                	lw	a0,24(sp)
}
  800538:	70a2                	ld	ra,40(sp)
  80053a:	6145                	addi	sp,sp,48
  80053c:	8082                	ret
        return -E_INVAL;
  80053e:	5575                	li	a0,-3
  800540:	bfe5                	j	800538 <vsnprintf+0x2a>

0000000000800542 <snprintf>:
snprintf(char *str, size_t size, const char *fmt, ...) {
  800542:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800544:	02810313          	addi	t1,sp,40
snprintf(char *str, size_t size, const char *fmt, ...) {
  800548:	f436                	sd	a3,40(sp)
    cnt = vsnprintf(str, size, fmt, ap);
  80054a:	869a                	mv	a3,t1
snprintf(char *str, size_t size, const char *fmt, ...) {
  80054c:	ec06                	sd	ra,24(sp)
  80054e:	f83a                	sd	a4,48(sp)
  800550:	fc3e                	sd	a5,56(sp)
  800552:	e0c2                	sd	a6,64(sp)
  800554:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800556:	e41a                	sd	t1,8(sp)
    cnt = vsnprintf(str, size, fmt, ap);
  800558:	fb7ff0ef          	jal	ra,80050e <vsnprintf>
}
  80055c:	60e2                	ld	ra,24(sp)
  80055e:	6161                	addi	sp,sp,80
  800560:	8082                	ret

0000000000800562 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  800562:	00054783          	lbu	a5,0(a0)
  800566:	cb91                	beqz	a5,80057a <strlen+0x18>
    size_t cnt = 0;
  800568:	4781                	li	a5,0
        cnt ++;
  80056a:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
  80056c:	00f50733          	add	a4,a0,a5
  800570:	00074703          	lbu	a4,0(a4)
  800574:	fb7d                	bnez	a4,80056a <strlen+0x8>
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

0000000000800580 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800580:	c185                	beqz	a1,8005a0 <strnlen+0x20>
  800582:	00054783          	lbu	a5,0(a0)
  800586:	cf89                	beqz	a5,8005a0 <strnlen+0x20>
    size_t cnt = 0;
  800588:	4781                	li	a5,0
  80058a:	a021                	j	800592 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  80058c:	00074703          	lbu	a4,0(a4)
  800590:	c711                	beqz	a4,80059c <strnlen+0x1c>
        cnt ++;
  800592:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800594:	00f50733          	add	a4,a0,a5
  800598:	fef59ae3          	bne	a1,a5,80058c <strnlen+0xc>
    }
    return cnt;
}
  80059c:	853e                	mv	a0,a5
  80059e:	8082                	ret
    size_t cnt = 0;
  8005a0:	4781                	li	a5,0
}
  8005a2:	853e                	mv	a0,a5
  8005a4:	8082                	ret

00000000008005a6 <forktree>:
        exit(0);
    }
}

void
forktree(const char *cur) {
  8005a6:	1141                	addi	sp,sp,-16
  8005a8:	e406                	sd	ra,8(sp)
  8005aa:	e022                	sd	s0,0(sp)
  8005ac:	842a                	mv	s0,a0
    cprintf("%04x: I am '%s'\n", getpid(), cur);
  8005ae:	b3fff0ef          	jal	ra,8000ec <getpid>
  8005b2:	8622                	mv	a2,s0
  8005b4:	85aa                	mv	a1,a0
  8005b6:	00000517          	auipc	a0,0x0
  8005ba:	3c250513          	addi	a0,a0,962 # 800978 <error_string+0x1c8>
  8005be:	a83ff0ef          	jal	ra,800040 <cprintf>

    forkchild(cur, '0');
  8005c2:	8522                	mv	a0,s0
  8005c4:	03000593          	li	a1,48
  8005c8:	014000ef          	jal	ra,8005dc <forkchild>
    forkchild(cur, '1');
  8005cc:	8522                	mv	a0,s0
}
  8005ce:	6402                	ld	s0,0(sp)
  8005d0:	60a2                	ld	ra,8(sp)
    forkchild(cur, '1');
  8005d2:	03100593          	li	a1,49
}
  8005d6:	0141                	addi	sp,sp,16
    forkchild(cur, '1');
  8005d8:	0040006f          	j	8005dc <forkchild>

00000000008005dc <forkchild>:
forkchild(const char *cur, char branch) {
  8005dc:	7179                	addi	sp,sp,-48
  8005de:	f022                	sd	s0,32(sp)
  8005e0:	ec26                	sd	s1,24(sp)
  8005e2:	f406                	sd	ra,40(sp)
  8005e4:	842a                	mv	s0,a0
  8005e6:	84ae                	mv	s1,a1
    if (strlen(cur) >= DEPTH)
  8005e8:	f7bff0ef          	jal	ra,800562 <strlen>
  8005ec:	478d                	li	a5,3
  8005ee:	00a7f763          	bleu	a0,a5,8005fc <forkchild+0x20>
}
  8005f2:	70a2                	ld	ra,40(sp)
  8005f4:	7402                	ld	s0,32(sp)
  8005f6:	64e2                	ld	s1,24(sp)
  8005f8:	6145                	addi	sp,sp,48
  8005fa:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  8005fc:	8726                	mv	a4,s1
  8005fe:	86a2                	mv	a3,s0
  800600:	00000617          	auipc	a2,0x0
  800604:	37060613          	addi	a2,a2,880 # 800970 <error_string+0x1c0>
  800608:	4595                	li	a1,5
  80060a:	0028                	addi	a0,sp,8
  80060c:	f37ff0ef          	jal	ra,800542 <snprintf>
    if (fork() == 0) {
  800610:	ad5ff0ef          	jal	ra,8000e4 <fork>
  800614:	fd79                	bnez	a0,8005f2 <forkchild+0x16>
        forktree(nxt);
  800616:	0028                	addi	a0,sp,8
  800618:	f8fff0ef          	jal	ra,8005a6 <forktree>
        yield();
  80061c:	acdff0ef          	jal	ra,8000e8 <yield>
        exit(0);
  800620:	4501                	li	a0,0
  800622:	aadff0ef          	jal	ra,8000ce <exit>

0000000000800626 <main>:

int
main(void) {
  800626:	1141                	addi	sp,sp,-16
    forktree("");
  800628:	00000517          	auipc	a0,0x0
  80062c:	36050513          	addi	a0,a0,864 # 800988 <error_string+0x1d8>
main(void) {
  800630:	e406                	sd	ra,8(sp)
    forktree("");
  800632:	f75ff0ef          	jal	ra,8005a6 <forktree>
    return 0;
}
  800636:	60a2                	ld	ra,8(sp)
  800638:	4501                	li	a0,0
  80063a:	0141                	addi	sp,sp,16
  80063c:	8082                	ret
