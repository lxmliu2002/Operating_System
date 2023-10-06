
obj/__user_faultreadkernel.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  800020:	112000ef          	jal	ra,800132 <umain>
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
  800038:	55c50513          	addi	a0,a0,1372 # 800590 <main+0x34>
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
  800058:	55c50513          	addi	a0,a0,1372 # 8005b0 <main+0x54>
  80005c:	044000ef          	jal	ra,8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800060:	5559                	li	a0,-10
  800062:	0ba000ef          	jal	ra,80011c <exit>

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
  80006e:	0a6000ef          	jal	ra,800114 <sys_putc>
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
  800094:	116000ef          	jal	ra,8001aa <vprintfmt>
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
  8000c8:	0e2000ef          	jal	ra,8001aa <vprintfmt>
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

0000000000800114 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  800114:	85aa                	mv	a1,a0
  800116:	4579                	li	a0,30
  800118:	fbdff06f          	j	8000d4 <syscall>

000000000080011c <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80011c:	1141                	addi	sp,sp,-16
  80011e:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800120:	fedff0ef          	jal	ra,80010c <sys_exit>
    cprintf("BUG: exit failed.\n");
  800124:	00000517          	auipc	a0,0x0
  800128:	49450513          	addi	a0,a0,1172 # 8005b8 <main+0x5c>
  80012c:	f75ff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  800130:	a001                	j	800130 <exit+0x14>

0000000000800132 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800132:	1141                	addi	sp,sp,-16
  800134:	e406                	sd	ra,8(sp)
    int ret = main();
  800136:	426000ef          	jal	ra,80055c <main>
    exit(ret);
  80013a:	fe3ff0ef          	jal	ra,80011c <exit>

000000000080013e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80013e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800142:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800144:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800148:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80014a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80014e:	f022                	sd	s0,32(sp)
  800150:	ec26                	sd	s1,24(sp)
  800152:	e84a                	sd	s2,16(sp)
  800154:	f406                	sd	ra,40(sp)
  800156:	e44e                	sd	s3,8(sp)
  800158:	84aa                	mv	s1,a0
  80015a:	892e                	mv	s2,a1
  80015c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800160:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800162:	03067e63          	bleu	a6,a2,80019e <printnum+0x60>
  800166:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800168:	00805763          	blez	s0,800176 <printnum+0x38>
  80016c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80016e:	85ca                	mv	a1,s2
  800170:	854e                	mv	a0,s3
  800172:	9482                	jalr	s1
        while (-- width > 0)
  800174:	fc65                	bnez	s0,80016c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800176:	1a02                	slli	s4,s4,0x20
  800178:	020a5a13          	srli	s4,s4,0x20
  80017c:	00000797          	auipc	a5,0x0
  800180:	67478793          	addi	a5,a5,1652 # 8007f0 <error_string+0xc8>
  800184:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800186:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800188:	000a4503          	lbu	a0,0(s4)
}
  80018c:	70a2                	ld	ra,40(sp)
  80018e:	69a2                	ld	s3,8(sp)
  800190:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800192:	85ca                	mv	a1,s2
  800194:	8326                	mv	t1,s1
}
  800196:	6942                	ld	s2,16(sp)
  800198:	64e2                	ld	s1,24(sp)
  80019a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80019c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  80019e:	03065633          	divu	a2,a2,a6
  8001a2:	8722                	mv	a4,s0
  8001a4:	f9bff0ef          	jal	ra,80013e <printnum>
  8001a8:	b7f9                	j	800176 <printnum+0x38>

00000000008001aa <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001aa:	7119                	addi	sp,sp,-128
  8001ac:	f4a6                	sd	s1,104(sp)
  8001ae:	f0ca                	sd	s2,96(sp)
  8001b0:	e8d2                	sd	s4,80(sp)
  8001b2:	e4d6                	sd	s5,72(sp)
  8001b4:	e0da                	sd	s6,64(sp)
  8001b6:	fc5e                	sd	s7,56(sp)
  8001b8:	f862                	sd	s8,48(sp)
  8001ba:	f06a                	sd	s10,32(sp)
  8001bc:	fc86                	sd	ra,120(sp)
  8001be:	f8a2                	sd	s0,112(sp)
  8001c0:	ecce                	sd	s3,88(sp)
  8001c2:	f466                	sd	s9,40(sp)
  8001c4:	ec6e                	sd	s11,24(sp)
  8001c6:	892a                	mv	s2,a0
  8001c8:	84ae                	mv	s1,a1
  8001ca:	8d32                	mv	s10,a2
  8001cc:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001ce:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001d0:	00000a17          	auipc	s4,0x0
  8001d4:	3fca0a13          	addi	s4,s4,1020 # 8005cc <main+0x70>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  8001d8:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001dc:	00000c17          	auipc	s8,0x0
  8001e0:	54cc0c13          	addi	s8,s8,1356 # 800728 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001e4:	000d4503          	lbu	a0,0(s10)
  8001e8:	02500793          	li	a5,37
  8001ec:	001d0413          	addi	s0,s10,1
  8001f0:	00f50e63          	beq	a0,a5,80020c <vprintfmt+0x62>
            if (ch == '\0') {
  8001f4:	c521                	beqz	a0,80023c <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f6:	02500993          	li	s3,37
  8001fa:	a011                	j	8001fe <vprintfmt+0x54>
            if (ch == '\0') {
  8001fc:	c121                	beqz	a0,80023c <vprintfmt+0x92>
            putch(ch, putdat);
  8001fe:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800200:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800202:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800204:	fff44503          	lbu	a0,-1(s0)
  800208:	ff351ae3          	bne	a0,s3,8001fc <vprintfmt+0x52>
  80020c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800210:	02000793          	li	a5,32
        lflag = altflag = 0;
  800214:	4981                	li	s3,0
  800216:	4801                	li	a6,0
        width = precision = -1;
  800218:	5cfd                	li	s9,-1
  80021a:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  80021c:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800220:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800222:	fdd6069b          	addiw	a3,a2,-35
  800226:	0ff6f693          	andi	a3,a3,255
  80022a:	00140d13          	addi	s10,s0,1
  80022e:	20d5e563          	bltu	a1,a3,800438 <vprintfmt+0x28e>
  800232:	068a                	slli	a3,a3,0x2
  800234:	96d2                	add	a3,a3,s4
  800236:	4294                	lw	a3,0(a3)
  800238:	96d2                	add	a3,a3,s4
  80023a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80023c:	70e6                	ld	ra,120(sp)
  80023e:	7446                	ld	s0,112(sp)
  800240:	74a6                	ld	s1,104(sp)
  800242:	7906                	ld	s2,96(sp)
  800244:	69e6                	ld	s3,88(sp)
  800246:	6a46                	ld	s4,80(sp)
  800248:	6aa6                	ld	s5,72(sp)
  80024a:	6b06                	ld	s6,64(sp)
  80024c:	7be2                	ld	s7,56(sp)
  80024e:	7c42                	ld	s8,48(sp)
  800250:	7ca2                	ld	s9,40(sp)
  800252:	7d02                	ld	s10,32(sp)
  800254:	6de2                	ld	s11,24(sp)
  800256:	6109                	addi	sp,sp,128
  800258:	8082                	ret
    if (lflag >= 2) {
  80025a:	4705                	li	a4,1
  80025c:	008a8593          	addi	a1,s5,8
  800260:	01074463          	blt	a4,a6,800268 <vprintfmt+0xbe>
    else if (lflag) {
  800264:	26080363          	beqz	a6,8004ca <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  800268:	000ab603          	ld	a2,0(s5)
  80026c:	46c1                	li	a3,16
  80026e:	8aae                	mv	s5,a1
  800270:	a06d                	j	80031a <vprintfmt+0x170>
            goto reswitch;
  800272:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800276:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800278:	846a                	mv	s0,s10
            goto reswitch;
  80027a:	b765                	j	800222 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  80027c:	000aa503          	lw	a0,0(s5)
  800280:	85a6                	mv	a1,s1
  800282:	0aa1                	addi	s5,s5,8
  800284:	9902                	jalr	s2
            break;
  800286:	bfb9                	j	8001e4 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800288:	4705                	li	a4,1
  80028a:	008a8993          	addi	s3,s5,8
  80028e:	01074463          	blt	a4,a6,800296 <vprintfmt+0xec>
    else if (lflag) {
  800292:	22080463          	beqz	a6,8004ba <vprintfmt+0x310>
        return va_arg(*ap, long);
  800296:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  80029a:	24044463          	bltz	s0,8004e2 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  80029e:	8622                	mv	a2,s0
  8002a0:	8ace                	mv	s5,s3
  8002a2:	46a9                	li	a3,10
  8002a4:	a89d                	j	80031a <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002a6:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002aa:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002ac:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002ae:	41f7d69b          	sraiw	a3,a5,0x1f
  8002b2:	8fb5                	xor	a5,a5,a3
  8002b4:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002b8:	1ad74363          	blt	a4,a3,80045e <vprintfmt+0x2b4>
  8002bc:	00369793          	slli	a5,a3,0x3
  8002c0:	97e2                	add	a5,a5,s8
  8002c2:	639c                	ld	a5,0(a5)
  8002c4:	18078d63          	beqz	a5,80045e <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  8002c8:	86be                	mv	a3,a5
  8002ca:	00000617          	auipc	a2,0x0
  8002ce:	61660613          	addi	a2,a2,1558 # 8008e0 <error_string+0x1b8>
  8002d2:	85a6                	mv	a1,s1
  8002d4:	854a                	mv	a0,s2
  8002d6:	240000ef          	jal	ra,800516 <printfmt>
  8002da:	b729                	j	8001e4 <vprintfmt+0x3a>
            lflag ++;
  8002dc:	00144603          	lbu	a2,1(s0)
  8002e0:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002e2:	846a                	mv	s0,s10
            goto reswitch;
  8002e4:	bf3d                	j	800222 <vprintfmt+0x78>
    if (lflag >= 2) {
  8002e6:	4705                	li	a4,1
  8002e8:	008a8593          	addi	a1,s5,8
  8002ec:	01074463          	blt	a4,a6,8002f4 <vprintfmt+0x14a>
    else if (lflag) {
  8002f0:	1e080263          	beqz	a6,8004d4 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  8002f4:	000ab603          	ld	a2,0(s5)
  8002f8:	46a1                	li	a3,8
  8002fa:	8aae                	mv	s5,a1
  8002fc:	a839                	j	80031a <vprintfmt+0x170>
            putch('0', putdat);
  8002fe:	03000513          	li	a0,48
  800302:	85a6                	mv	a1,s1
  800304:	e03e                	sd	a5,0(sp)
  800306:	9902                	jalr	s2
            putch('x', putdat);
  800308:	85a6                	mv	a1,s1
  80030a:	07800513          	li	a0,120
  80030e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800310:	0aa1                	addi	s5,s5,8
  800312:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800316:	6782                	ld	a5,0(sp)
  800318:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  80031a:	876e                	mv	a4,s11
  80031c:	85a6                	mv	a1,s1
  80031e:	854a                	mv	a0,s2
  800320:	e1fff0ef          	jal	ra,80013e <printnum>
            break;
  800324:	b5c1                	j	8001e4 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800326:	000ab603          	ld	a2,0(s5)
  80032a:	0aa1                	addi	s5,s5,8
  80032c:	1c060663          	beqz	a2,8004f8 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  800330:	00160413          	addi	s0,a2,1
  800334:	17b05c63          	blez	s11,8004ac <vprintfmt+0x302>
  800338:	02d00593          	li	a1,45
  80033c:	14b79263          	bne	a5,a1,800480 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800340:	00064783          	lbu	a5,0(a2)
  800344:	0007851b          	sext.w	a0,a5
  800348:	c905                	beqz	a0,800378 <vprintfmt+0x1ce>
  80034a:	000cc563          	bltz	s9,800354 <vprintfmt+0x1aa>
  80034e:	3cfd                	addiw	s9,s9,-1
  800350:	036c8263          	beq	s9,s6,800374 <vprintfmt+0x1ca>
                    putch('?', putdat);
  800354:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800356:	18098463          	beqz	s3,8004de <vprintfmt+0x334>
  80035a:	3781                	addiw	a5,a5,-32
  80035c:	18fbf163          	bleu	a5,s7,8004de <vprintfmt+0x334>
                    putch('?', putdat);
  800360:	03f00513          	li	a0,63
  800364:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800366:	0405                	addi	s0,s0,1
  800368:	fff44783          	lbu	a5,-1(s0)
  80036c:	3dfd                	addiw	s11,s11,-1
  80036e:	0007851b          	sext.w	a0,a5
  800372:	fd61                	bnez	a0,80034a <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  800374:	e7b058e3          	blez	s11,8001e4 <vprintfmt+0x3a>
  800378:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80037a:	85a6                	mv	a1,s1
  80037c:	02000513          	li	a0,32
  800380:	9902                	jalr	s2
            for (; width > 0; width --) {
  800382:	e60d81e3          	beqz	s11,8001e4 <vprintfmt+0x3a>
  800386:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800388:	85a6                	mv	a1,s1
  80038a:	02000513          	li	a0,32
  80038e:	9902                	jalr	s2
            for (; width > 0; width --) {
  800390:	fe0d94e3          	bnez	s11,800378 <vprintfmt+0x1ce>
  800394:	bd81                	j	8001e4 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800396:	4705                	li	a4,1
  800398:	008a8593          	addi	a1,s5,8
  80039c:	01074463          	blt	a4,a6,8003a4 <vprintfmt+0x1fa>
    else if (lflag) {
  8003a0:	12080063          	beqz	a6,8004c0 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003a4:	000ab603          	ld	a2,0(s5)
  8003a8:	46a9                	li	a3,10
  8003aa:	8aae                	mv	s5,a1
  8003ac:	b7bd                	j	80031a <vprintfmt+0x170>
  8003ae:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003b2:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  8003b6:	846a                	mv	s0,s10
  8003b8:	b5ad                	j	800222 <vprintfmt+0x78>
            putch(ch, putdat);
  8003ba:	85a6                	mv	a1,s1
  8003bc:	02500513          	li	a0,37
  8003c0:	9902                	jalr	s2
            break;
  8003c2:	b50d                	j	8001e4 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  8003c4:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8003c8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8003cc:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8003ce:	846a                	mv	s0,s10
            if (width < 0)
  8003d0:	e40dd9e3          	bgez	s11,800222 <vprintfmt+0x78>
                width = precision, precision = -1;
  8003d4:	8de6                	mv	s11,s9
  8003d6:	5cfd                	li	s9,-1
  8003d8:	b5a9                	j	800222 <vprintfmt+0x78>
            goto reswitch;
  8003da:	00144603          	lbu	a2,1(s0)
            padc = '0';
  8003de:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  8003e2:	846a                	mv	s0,s10
            goto reswitch;
  8003e4:	bd3d                	j	800222 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  8003e6:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8003ea:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8003ee:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8003f0:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8003f4:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8003f8:	fcd56ce3          	bltu	a0,a3,8003d0 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  8003fc:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8003fe:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800402:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800406:	0196873b          	addw	a4,a3,s9
  80040a:	0017171b          	slliw	a4,a4,0x1
  80040e:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800412:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800416:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80041a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80041e:	fcd57fe3          	bleu	a3,a0,8003fc <vprintfmt+0x252>
  800422:	b77d                	j	8003d0 <vprintfmt+0x226>
            if (width < 0)
  800424:	fffdc693          	not	a3,s11
  800428:	96fd                	srai	a3,a3,0x3f
  80042a:	00ddfdb3          	and	s11,s11,a3
  80042e:	00144603          	lbu	a2,1(s0)
  800432:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800434:	846a                	mv	s0,s10
  800436:	b3f5                	j	800222 <vprintfmt+0x78>
            putch('%', putdat);
  800438:	85a6                	mv	a1,s1
  80043a:	02500513          	li	a0,37
  80043e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800440:	fff44703          	lbu	a4,-1(s0)
  800444:	02500793          	li	a5,37
  800448:	8d22                	mv	s10,s0
  80044a:	d8f70de3          	beq	a4,a5,8001e4 <vprintfmt+0x3a>
  80044e:	02500713          	li	a4,37
  800452:	1d7d                	addi	s10,s10,-1
  800454:	fffd4783          	lbu	a5,-1(s10)
  800458:	fee79de3          	bne	a5,a4,800452 <vprintfmt+0x2a8>
  80045c:	b361                	j	8001e4 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80045e:	00000617          	auipc	a2,0x0
  800462:	47260613          	addi	a2,a2,1138 # 8008d0 <error_string+0x1a8>
  800466:	85a6                	mv	a1,s1
  800468:	854a                	mv	a0,s2
  80046a:	0ac000ef          	jal	ra,800516 <printfmt>
  80046e:	bb9d                	j	8001e4 <vprintfmt+0x3a>
                p = "(null)";
  800470:	00000617          	auipc	a2,0x0
  800474:	45860613          	addi	a2,a2,1112 # 8008c8 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800478:	00000417          	auipc	s0,0x0
  80047c:	45140413          	addi	s0,s0,1105 # 8008c9 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800480:	8532                	mv	a0,a2
  800482:	85e6                	mv	a1,s9
  800484:	e032                	sd	a2,0(sp)
  800486:	e43e                	sd	a5,8(sp)
  800488:	0ae000ef          	jal	ra,800536 <strnlen>
  80048c:	40ad8dbb          	subw	s11,s11,a0
  800490:	6602                	ld	a2,0(sp)
  800492:	01b05d63          	blez	s11,8004ac <vprintfmt+0x302>
  800496:	67a2                	ld	a5,8(sp)
  800498:	2781                	sext.w	a5,a5
  80049a:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  80049c:	6522                	ld	a0,8(sp)
  80049e:	85a6                	mv	a1,s1
  8004a0:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004a4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a6:	6602                	ld	a2,0(sp)
  8004a8:	fe0d9ae3          	bnez	s11,80049c <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ac:	00064783          	lbu	a5,0(a2)
  8004b0:	0007851b          	sext.w	a0,a5
  8004b4:	e8051be3          	bnez	a0,80034a <vprintfmt+0x1a0>
  8004b8:	b335                	j	8001e4 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  8004ba:	000aa403          	lw	s0,0(s5)
  8004be:	bbf1                	j	80029a <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  8004c0:	000ae603          	lwu	a2,0(s5)
  8004c4:	46a9                	li	a3,10
  8004c6:	8aae                	mv	s5,a1
  8004c8:	bd89                	j	80031a <vprintfmt+0x170>
  8004ca:	000ae603          	lwu	a2,0(s5)
  8004ce:	46c1                	li	a3,16
  8004d0:	8aae                	mv	s5,a1
  8004d2:	b5a1                	j	80031a <vprintfmt+0x170>
  8004d4:	000ae603          	lwu	a2,0(s5)
  8004d8:	46a1                	li	a3,8
  8004da:	8aae                	mv	s5,a1
  8004dc:	bd3d                	j	80031a <vprintfmt+0x170>
                    putch(ch, putdat);
  8004de:	9902                	jalr	s2
  8004e0:	b559                	j	800366 <vprintfmt+0x1bc>
                putch('-', putdat);
  8004e2:	85a6                	mv	a1,s1
  8004e4:	02d00513          	li	a0,45
  8004e8:	e03e                	sd	a5,0(sp)
  8004ea:	9902                	jalr	s2
                num = -(long long)num;
  8004ec:	8ace                	mv	s5,s3
  8004ee:	40800633          	neg	a2,s0
  8004f2:	46a9                	li	a3,10
  8004f4:	6782                	ld	a5,0(sp)
  8004f6:	b515                	j	80031a <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  8004f8:	01b05663          	blez	s11,800504 <vprintfmt+0x35a>
  8004fc:	02d00693          	li	a3,45
  800500:	f6d798e3          	bne	a5,a3,800470 <vprintfmt+0x2c6>
  800504:	00000417          	auipc	s0,0x0
  800508:	3c540413          	addi	s0,s0,965 # 8008c9 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80050c:	02800513          	li	a0,40
  800510:	02800793          	li	a5,40
  800514:	bd1d                	j	80034a <vprintfmt+0x1a0>

0000000000800516 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800516:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800518:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80051c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80051e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800520:	ec06                	sd	ra,24(sp)
  800522:	f83a                	sd	a4,48(sp)
  800524:	fc3e                	sd	a5,56(sp)
  800526:	e0c2                	sd	a6,64(sp)
  800528:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80052a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80052c:	c7fff0ef          	jal	ra,8001aa <vprintfmt>
}
  800530:	60e2                	ld	ra,24(sp)
  800532:	6161                	addi	sp,sp,80
  800534:	8082                	ret

0000000000800536 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800536:	c185                	beqz	a1,800556 <strnlen+0x20>
  800538:	00054783          	lbu	a5,0(a0)
  80053c:	cf89                	beqz	a5,800556 <strnlen+0x20>
    size_t cnt = 0;
  80053e:	4781                	li	a5,0
  800540:	a021                	j	800548 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800542:	00074703          	lbu	a4,0(a4)
  800546:	c711                	beqz	a4,800552 <strnlen+0x1c>
        cnt ++;
  800548:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80054a:	00f50733          	add	a4,a0,a5
  80054e:	fef59ae3          	bne	a1,a5,800542 <strnlen+0xc>
    }
    return cnt;
}
  800552:	853e                	mv	a0,a5
  800554:	8082                	ret
    size_t cnt = 0;
  800556:	4781                	li	a5,0
}
  800558:	853e                	mv	a0,a5
  80055a:	8082                	ret

000000000080055c <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
    cprintf("I read %08x from 0xfac00000!\n", *(unsigned *)0xfac00000);
  80055c:	3eb00793          	li	a5,1003
  800560:	07da                	slli	a5,a5,0x16
  800562:	438c                	lw	a1,0(a5)
main(void) {
  800564:	1141                	addi	sp,sp,-16
    cprintf("I read %08x from 0xfac00000!\n", *(unsigned *)0xfac00000);
  800566:	00000517          	auipc	a0,0x0
  80056a:	38250513          	addi	a0,a0,898 # 8008e8 <error_string+0x1c0>
main(void) {
  80056e:	e406                	sd	ra,8(sp)
    cprintf("I read %08x from 0xfac00000!\n", *(unsigned *)0xfac00000);
  800570:	b31ff0ef          	jal	ra,8000a0 <cprintf>
    panic("FAIL: T.T\n");
  800574:	00000617          	auipc	a2,0x0
  800578:	39460613          	addi	a2,a2,916 # 800908 <error_string+0x1e0>
  80057c:	459d                	li	a1,7
  80057e:	00000517          	auipc	a0,0x0
  800582:	39a50513          	addi	a0,a0,922 # 800918 <error_string+0x1f0>
  800586:	aa1ff0ef          	jal	ra,800026 <__panic>
