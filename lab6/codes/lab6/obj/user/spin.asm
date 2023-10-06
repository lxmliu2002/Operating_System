
obj/__user_spin.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  800020:	140000ef          	jal	ra,800160 <umain>
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
  800038:	62450513          	addi	a0,a0,1572 # 800658 <main+0xce>
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
  800058:	62450513          	addi	a0,a0,1572 # 800678 <main+0xee>
  80005c:	044000ef          	jal	ra,8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800060:	5559                	li	a0,-10
  800062:	0d8000ef          	jal	ra,80013a <exit>

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
  80006e:	0c4000ef          	jal	ra,800132 <sys_putc>
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
  800094:	144000ef          	jal	ra,8001d8 <vprintfmt>
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
  8000c8:	110000ef          	jal	ra,8001d8 <vprintfmt>
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

000000000080012a <sys_kill>:
}

int
sys_kill(int64_t pid) {
    return syscall(SYS_kill, pid);
  80012a:	85aa                	mv	a1,a0
  80012c:	4531                	li	a0,12
  80012e:	fa7ff06f          	j	8000d4 <syscall>

0000000000800132 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  800132:	85aa                	mv	a1,a0
  800134:	4579                	li	a0,30
  800136:	f9fff06f          	j	8000d4 <syscall>

000000000080013a <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80013a:	1141                	addi	sp,sp,-16
  80013c:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80013e:	fcfff0ef          	jal	ra,80010c <sys_exit>
    cprintf("BUG: exit failed.\n");
  800142:	00000517          	auipc	a0,0x0
  800146:	53e50513          	addi	a0,a0,1342 # 800680 <main+0xf6>
  80014a:	f57ff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  80014e:	a001                	j	80014e <exit+0x14>

0000000000800150 <fork>:
}

int
fork(void) {
    return sys_fork();
  800150:	fc5ff06f          	j	800114 <sys_fork>

0000000000800154 <waitpid>:
    return sys_wait(0, NULL);
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

000000000080015c <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  80015c:	fcfff06f          	j	80012a <sys_kill>

0000000000800160 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800160:	1141                	addi	sp,sp,-16
  800162:	e406                	sd	ra,8(sp)
    int ret = main();
  800164:	426000ef          	jal	ra,80058a <main>
    exit(ret);
  800168:	fd3ff0ef          	jal	ra,80013a <exit>

000000000080016c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80016c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800170:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800172:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800176:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800178:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80017c:	f022                	sd	s0,32(sp)
  80017e:	ec26                	sd	s1,24(sp)
  800180:	e84a                	sd	s2,16(sp)
  800182:	f406                	sd	ra,40(sp)
  800184:	e44e                	sd	s3,8(sp)
  800186:	84aa                	mv	s1,a0
  800188:	892e                	mv	s2,a1
  80018a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80018e:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800190:	03067e63          	bleu	a6,a2,8001cc <printnum+0x60>
  800194:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800196:	00805763          	blez	s0,8001a4 <printnum+0x38>
  80019a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80019c:	85ca                	mv	a1,s2
  80019e:	854e                	mv	a0,s3
  8001a0:	9482                	jalr	s1
        while (-- width > 0)
  8001a2:	fc65                	bnez	s0,80019a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001a4:	1a02                	slli	s4,s4,0x20
  8001a6:	020a5a13          	srli	s4,s4,0x20
  8001aa:	00000797          	auipc	a5,0x0
  8001ae:	70e78793          	addi	a5,a5,1806 # 8008b8 <error_string+0xc8>
  8001b2:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001b4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b6:	000a4503          	lbu	a0,0(s4)
}
  8001ba:	70a2                	ld	ra,40(sp)
  8001bc:	69a2                	ld	s3,8(sp)
  8001be:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001c0:	85ca                	mv	a1,s2
  8001c2:	8326                	mv	t1,s1
}
  8001c4:	6942                	ld	s2,16(sp)
  8001c6:	64e2                	ld	s1,24(sp)
  8001c8:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001ca:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001cc:	03065633          	divu	a2,a2,a6
  8001d0:	8722                	mv	a4,s0
  8001d2:	f9bff0ef          	jal	ra,80016c <printnum>
  8001d6:	b7f9                	j	8001a4 <printnum+0x38>

00000000008001d8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001d8:	7119                	addi	sp,sp,-128
  8001da:	f4a6                	sd	s1,104(sp)
  8001dc:	f0ca                	sd	s2,96(sp)
  8001de:	e8d2                	sd	s4,80(sp)
  8001e0:	e4d6                	sd	s5,72(sp)
  8001e2:	e0da                	sd	s6,64(sp)
  8001e4:	fc5e                	sd	s7,56(sp)
  8001e6:	f862                	sd	s8,48(sp)
  8001e8:	f06a                	sd	s10,32(sp)
  8001ea:	fc86                	sd	ra,120(sp)
  8001ec:	f8a2                	sd	s0,112(sp)
  8001ee:	ecce                	sd	s3,88(sp)
  8001f0:	f466                	sd	s9,40(sp)
  8001f2:	ec6e                	sd	s11,24(sp)
  8001f4:	892a                	mv	s2,a0
  8001f6:	84ae                	mv	s1,a1
  8001f8:	8d32                	mv	s10,a2
  8001fa:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001fc:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001fe:	00000a17          	auipc	s4,0x0
  800202:	496a0a13          	addi	s4,s4,1174 # 800694 <main+0x10a>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800206:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80020a:	00000c17          	auipc	s8,0x0
  80020e:	5e6c0c13          	addi	s8,s8,1510 # 8007f0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800212:	000d4503          	lbu	a0,0(s10)
  800216:	02500793          	li	a5,37
  80021a:	001d0413          	addi	s0,s10,1
  80021e:	00f50e63          	beq	a0,a5,80023a <vprintfmt+0x62>
            if (ch == '\0') {
  800222:	c521                	beqz	a0,80026a <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800224:	02500993          	li	s3,37
  800228:	a011                	j	80022c <vprintfmt+0x54>
            if (ch == '\0') {
  80022a:	c121                	beqz	a0,80026a <vprintfmt+0x92>
            putch(ch, putdat);
  80022c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80022e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800230:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800232:	fff44503          	lbu	a0,-1(s0)
  800236:	ff351ae3          	bne	a0,s3,80022a <vprintfmt+0x52>
  80023a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80023e:	02000793          	li	a5,32
        lflag = altflag = 0;
  800242:	4981                	li	s3,0
  800244:	4801                	li	a6,0
        width = precision = -1;
  800246:	5cfd                	li	s9,-1
  800248:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  80024a:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  80024e:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800250:	fdd6069b          	addiw	a3,a2,-35
  800254:	0ff6f693          	andi	a3,a3,255
  800258:	00140d13          	addi	s10,s0,1
  80025c:	20d5e563          	bltu	a1,a3,800466 <vprintfmt+0x28e>
  800260:	068a                	slli	a3,a3,0x2
  800262:	96d2                	add	a3,a3,s4
  800264:	4294                	lw	a3,0(a3)
  800266:	96d2                	add	a3,a3,s4
  800268:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80026a:	70e6                	ld	ra,120(sp)
  80026c:	7446                	ld	s0,112(sp)
  80026e:	74a6                	ld	s1,104(sp)
  800270:	7906                	ld	s2,96(sp)
  800272:	69e6                	ld	s3,88(sp)
  800274:	6a46                	ld	s4,80(sp)
  800276:	6aa6                	ld	s5,72(sp)
  800278:	6b06                	ld	s6,64(sp)
  80027a:	7be2                	ld	s7,56(sp)
  80027c:	7c42                	ld	s8,48(sp)
  80027e:	7ca2                	ld	s9,40(sp)
  800280:	7d02                	ld	s10,32(sp)
  800282:	6de2                	ld	s11,24(sp)
  800284:	6109                	addi	sp,sp,128
  800286:	8082                	ret
    if (lflag >= 2) {
  800288:	4705                	li	a4,1
  80028a:	008a8593          	addi	a1,s5,8
  80028e:	01074463          	blt	a4,a6,800296 <vprintfmt+0xbe>
    else if (lflag) {
  800292:	26080363          	beqz	a6,8004f8 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  800296:	000ab603          	ld	a2,0(s5)
  80029a:	46c1                	li	a3,16
  80029c:	8aae                	mv	s5,a1
  80029e:	a06d                	j	800348 <vprintfmt+0x170>
            goto reswitch;
  8002a0:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002a4:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002a6:	846a                	mv	s0,s10
            goto reswitch;
  8002a8:	b765                	j	800250 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  8002aa:	000aa503          	lw	a0,0(s5)
  8002ae:	85a6                	mv	a1,s1
  8002b0:	0aa1                	addi	s5,s5,8
  8002b2:	9902                	jalr	s2
            break;
  8002b4:	bfb9                	j	800212 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002b6:	4705                	li	a4,1
  8002b8:	008a8993          	addi	s3,s5,8
  8002bc:	01074463          	blt	a4,a6,8002c4 <vprintfmt+0xec>
    else if (lflag) {
  8002c0:	22080463          	beqz	a6,8004e8 <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002c4:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002c8:	24044463          	bltz	s0,800510 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002cc:	8622                	mv	a2,s0
  8002ce:	8ace                	mv	s5,s3
  8002d0:	46a9                	li	a3,10
  8002d2:	a89d                	j	800348 <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002d4:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002d8:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002da:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002dc:	41f7d69b          	sraiw	a3,a5,0x1f
  8002e0:	8fb5                	xor	a5,a5,a3
  8002e2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002e6:	1ad74363          	blt	a4,a3,80048c <vprintfmt+0x2b4>
  8002ea:	00369793          	slli	a5,a3,0x3
  8002ee:	97e2                	add	a5,a5,s8
  8002f0:	639c                	ld	a5,0(a5)
  8002f2:	18078d63          	beqz	a5,80048c <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  8002f6:	86be                	mv	a3,a5
  8002f8:	00000617          	auipc	a2,0x0
  8002fc:	6b060613          	addi	a2,a2,1712 # 8009a8 <error_string+0x1b8>
  800300:	85a6                	mv	a1,s1
  800302:	854a                	mv	a0,s2
  800304:	240000ef          	jal	ra,800544 <printfmt>
  800308:	b729                	j	800212 <vprintfmt+0x3a>
            lflag ++;
  80030a:	00144603          	lbu	a2,1(s0)
  80030e:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800310:	846a                	mv	s0,s10
            goto reswitch;
  800312:	bf3d                	j	800250 <vprintfmt+0x78>
    if (lflag >= 2) {
  800314:	4705                	li	a4,1
  800316:	008a8593          	addi	a1,s5,8
  80031a:	01074463          	blt	a4,a6,800322 <vprintfmt+0x14a>
    else if (lflag) {
  80031e:	1e080263          	beqz	a6,800502 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  800322:	000ab603          	ld	a2,0(s5)
  800326:	46a1                	li	a3,8
  800328:	8aae                	mv	s5,a1
  80032a:	a839                	j	800348 <vprintfmt+0x170>
            putch('0', putdat);
  80032c:	03000513          	li	a0,48
  800330:	85a6                	mv	a1,s1
  800332:	e03e                	sd	a5,0(sp)
  800334:	9902                	jalr	s2
            putch('x', putdat);
  800336:	85a6                	mv	a1,s1
  800338:	07800513          	li	a0,120
  80033c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80033e:	0aa1                	addi	s5,s5,8
  800340:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800344:	6782                	ld	a5,0(sp)
  800346:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800348:	876e                	mv	a4,s11
  80034a:	85a6                	mv	a1,s1
  80034c:	854a                	mv	a0,s2
  80034e:	e1fff0ef          	jal	ra,80016c <printnum>
            break;
  800352:	b5c1                	j	800212 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800354:	000ab603          	ld	a2,0(s5)
  800358:	0aa1                	addi	s5,s5,8
  80035a:	1c060663          	beqz	a2,800526 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  80035e:	00160413          	addi	s0,a2,1
  800362:	17b05c63          	blez	s11,8004da <vprintfmt+0x302>
  800366:	02d00593          	li	a1,45
  80036a:	14b79263          	bne	a5,a1,8004ae <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80036e:	00064783          	lbu	a5,0(a2)
  800372:	0007851b          	sext.w	a0,a5
  800376:	c905                	beqz	a0,8003a6 <vprintfmt+0x1ce>
  800378:	000cc563          	bltz	s9,800382 <vprintfmt+0x1aa>
  80037c:	3cfd                	addiw	s9,s9,-1
  80037e:	036c8263          	beq	s9,s6,8003a2 <vprintfmt+0x1ca>
                    putch('?', putdat);
  800382:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800384:	18098463          	beqz	s3,80050c <vprintfmt+0x334>
  800388:	3781                	addiw	a5,a5,-32
  80038a:	18fbf163          	bleu	a5,s7,80050c <vprintfmt+0x334>
                    putch('?', putdat);
  80038e:	03f00513          	li	a0,63
  800392:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800394:	0405                	addi	s0,s0,1
  800396:	fff44783          	lbu	a5,-1(s0)
  80039a:	3dfd                	addiw	s11,s11,-1
  80039c:	0007851b          	sext.w	a0,a5
  8003a0:	fd61                	bnez	a0,800378 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  8003a2:	e7b058e3          	blez	s11,800212 <vprintfmt+0x3a>
  8003a6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003a8:	85a6                	mv	a1,s1
  8003aa:	02000513          	li	a0,32
  8003ae:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003b0:	e60d81e3          	beqz	s11,800212 <vprintfmt+0x3a>
  8003b4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003b6:	85a6                	mv	a1,s1
  8003b8:	02000513          	li	a0,32
  8003bc:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003be:	fe0d94e3          	bnez	s11,8003a6 <vprintfmt+0x1ce>
  8003c2:	bd81                	j	800212 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003c4:	4705                	li	a4,1
  8003c6:	008a8593          	addi	a1,s5,8
  8003ca:	01074463          	blt	a4,a6,8003d2 <vprintfmt+0x1fa>
    else if (lflag) {
  8003ce:	12080063          	beqz	a6,8004ee <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003d2:	000ab603          	ld	a2,0(s5)
  8003d6:	46a9                	li	a3,10
  8003d8:	8aae                	mv	s5,a1
  8003da:	b7bd                	j	800348 <vprintfmt+0x170>
  8003dc:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003e0:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  8003e4:	846a                	mv	s0,s10
  8003e6:	b5ad                	j	800250 <vprintfmt+0x78>
            putch(ch, putdat);
  8003e8:	85a6                	mv	a1,s1
  8003ea:	02500513          	li	a0,37
  8003ee:	9902                	jalr	s2
            break;
  8003f0:	b50d                	j	800212 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  8003f2:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8003f6:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8003fa:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  8003fc:	846a                	mv	s0,s10
            if (width < 0)
  8003fe:	e40dd9e3          	bgez	s11,800250 <vprintfmt+0x78>
                width = precision, precision = -1;
  800402:	8de6                	mv	s11,s9
  800404:	5cfd                	li	s9,-1
  800406:	b5a9                	j	800250 <vprintfmt+0x78>
            goto reswitch;
  800408:	00144603          	lbu	a2,1(s0)
            padc = '0';
  80040c:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  800410:	846a                	mv	s0,s10
            goto reswitch;
  800412:	bd3d                	j	800250 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800414:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800418:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80041c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80041e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800422:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800426:	fcd56ce3          	bltu	a0,a3,8003fe <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  80042a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80042c:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800430:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800434:	0196873b          	addw	a4,a3,s9
  800438:	0017171b          	slliw	a4,a4,0x1
  80043c:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800440:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800444:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800448:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80044c:	fcd57fe3          	bleu	a3,a0,80042a <vprintfmt+0x252>
  800450:	b77d                	j	8003fe <vprintfmt+0x226>
            if (width < 0)
  800452:	fffdc693          	not	a3,s11
  800456:	96fd                	srai	a3,a3,0x3f
  800458:	00ddfdb3          	and	s11,s11,a3
  80045c:	00144603          	lbu	a2,1(s0)
  800460:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800462:	846a                	mv	s0,s10
  800464:	b3f5                	j	800250 <vprintfmt+0x78>
            putch('%', putdat);
  800466:	85a6                	mv	a1,s1
  800468:	02500513          	li	a0,37
  80046c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80046e:	fff44703          	lbu	a4,-1(s0)
  800472:	02500793          	li	a5,37
  800476:	8d22                	mv	s10,s0
  800478:	d8f70de3          	beq	a4,a5,800212 <vprintfmt+0x3a>
  80047c:	02500713          	li	a4,37
  800480:	1d7d                	addi	s10,s10,-1
  800482:	fffd4783          	lbu	a5,-1(s10)
  800486:	fee79de3          	bne	a5,a4,800480 <vprintfmt+0x2a8>
  80048a:	b361                	j	800212 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80048c:	00000617          	auipc	a2,0x0
  800490:	50c60613          	addi	a2,a2,1292 # 800998 <error_string+0x1a8>
  800494:	85a6                	mv	a1,s1
  800496:	854a                	mv	a0,s2
  800498:	0ac000ef          	jal	ra,800544 <printfmt>
  80049c:	bb9d                	j	800212 <vprintfmt+0x3a>
                p = "(null)";
  80049e:	00000617          	auipc	a2,0x0
  8004a2:	4f260613          	addi	a2,a2,1266 # 800990 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004a6:	00000417          	auipc	s0,0x0
  8004aa:	4eb40413          	addi	s0,s0,1259 # 800991 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ae:	8532                	mv	a0,a2
  8004b0:	85e6                	mv	a1,s9
  8004b2:	e032                	sd	a2,0(sp)
  8004b4:	e43e                	sd	a5,8(sp)
  8004b6:	0ae000ef          	jal	ra,800564 <strnlen>
  8004ba:	40ad8dbb          	subw	s11,s11,a0
  8004be:	6602                	ld	a2,0(sp)
  8004c0:	01b05d63          	blez	s11,8004da <vprintfmt+0x302>
  8004c4:	67a2                	ld	a5,8(sp)
  8004c6:	2781                	sext.w	a5,a5
  8004c8:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004ca:	6522                	ld	a0,8(sp)
  8004cc:	85a6                	mv	a1,s1
  8004ce:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d0:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004d2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d4:	6602                	ld	a2,0(sp)
  8004d6:	fe0d9ae3          	bnez	s11,8004ca <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004da:	00064783          	lbu	a5,0(a2)
  8004de:	0007851b          	sext.w	a0,a5
  8004e2:	e8051be3          	bnez	a0,800378 <vprintfmt+0x1a0>
  8004e6:	b335                	j	800212 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  8004e8:	000aa403          	lw	s0,0(s5)
  8004ec:	bbf1                	j	8002c8 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  8004ee:	000ae603          	lwu	a2,0(s5)
  8004f2:	46a9                	li	a3,10
  8004f4:	8aae                	mv	s5,a1
  8004f6:	bd89                	j	800348 <vprintfmt+0x170>
  8004f8:	000ae603          	lwu	a2,0(s5)
  8004fc:	46c1                	li	a3,16
  8004fe:	8aae                	mv	s5,a1
  800500:	b5a1                	j	800348 <vprintfmt+0x170>
  800502:	000ae603          	lwu	a2,0(s5)
  800506:	46a1                	li	a3,8
  800508:	8aae                	mv	s5,a1
  80050a:	bd3d                	j	800348 <vprintfmt+0x170>
                    putch(ch, putdat);
  80050c:	9902                	jalr	s2
  80050e:	b559                	j	800394 <vprintfmt+0x1bc>
                putch('-', putdat);
  800510:	85a6                	mv	a1,s1
  800512:	02d00513          	li	a0,45
  800516:	e03e                	sd	a5,0(sp)
  800518:	9902                	jalr	s2
                num = -(long long)num;
  80051a:	8ace                	mv	s5,s3
  80051c:	40800633          	neg	a2,s0
  800520:	46a9                	li	a3,10
  800522:	6782                	ld	a5,0(sp)
  800524:	b515                	j	800348 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  800526:	01b05663          	blez	s11,800532 <vprintfmt+0x35a>
  80052a:	02d00693          	li	a3,45
  80052e:	f6d798e3          	bne	a5,a3,80049e <vprintfmt+0x2c6>
  800532:	00000417          	auipc	s0,0x0
  800536:	45f40413          	addi	s0,s0,1119 # 800991 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80053a:	02800513          	li	a0,40
  80053e:	02800793          	li	a5,40
  800542:	bd1d                	j	800378 <vprintfmt+0x1a0>

0000000000800544 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800544:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800546:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80054a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80054c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80054e:	ec06                	sd	ra,24(sp)
  800550:	f83a                	sd	a4,48(sp)
  800552:	fc3e                	sd	a5,56(sp)
  800554:	e0c2                	sd	a6,64(sp)
  800556:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800558:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80055a:	c7fff0ef          	jal	ra,8001d8 <vprintfmt>
}
  80055e:	60e2                	ld	ra,24(sp)
  800560:	6161                	addi	sp,sp,80
  800562:	8082                	ret

0000000000800564 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800564:	c185                	beqz	a1,800584 <strnlen+0x20>
  800566:	00054783          	lbu	a5,0(a0)
  80056a:	cf89                	beqz	a5,800584 <strnlen+0x20>
    size_t cnt = 0;
  80056c:	4781                	li	a5,0
  80056e:	a021                	j	800576 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800570:	00074703          	lbu	a4,0(a4)
  800574:	c711                	beqz	a4,800580 <strnlen+0x1c>
        cnt ++;
  800576:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800578:	00f50733          	add	a4,a0,a5
  80057c:	fef59ae3          	bne	a1,a5,800570 <strnlen+0xc>
    }
    return cnt;
}
  800580:	853e                	mv	a0,a5
  800582:	8082                	ret
    size_t cnt = 0;
  800584:	4781                	li	a5,0
}
  800586:	853e                	mv	a0,a5
  800588:	8082                	ret

000000000080058a <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  80058a:	1141                	addi	sp,sp,-16
    int pid, ret;
    cprintf("I am the parent. Forking the child...\n");
  80058c:	00000517          	auipc	a0,0x0
  800590:	42450513          	addi	a0,a0,1060 # 8009b0 <error_string+0x1c0>
main(void) {
  800594:	e406                	sd	ra,8(sp)
  800596:	e022                	sd	s0,0(sp)
    cprintf("I am the parent. Forking the child...\n");
  800598:	b09ff0ef          	jal	ra,8000a0 <cprintf>
    if ((pid = fork()) == 0) {
  80059c:	bb5ff0ef          	jal	ra,800150 <fork>
  8005a0:	e901                	bnez	a0,8005b0 <main+0x26>
        cprintf("I am the child. spinning ...\n");
  8005a2:	00000517          	auipc	a0,0x0
  8005a6:	43650513          	addi	a0,a0,1078 # 8009d8 <error_string+0x1e8>
  8005aa:	af7ff0ef          	jal	ra,8000a0 <cprintf>
        while (1);
  8005ae:	a001                	j	8005ae <main+0x24>
    }
    cprintf("I am the parent. Running the child...\n");
  8005b0:	842a                	mv	s0,a0
  8005b2:	00000517          	auipc	a0,0x0
  8005b6:	44650513          	addi	a0,a0,1094 # 8009f8 <error_string+0x208>
  8005ba:	ae7ff0ef          	jal	ra,8000a0 <cprintf>

    yield();
  8005be:	b9bff0ef          	jal	ra,800158 <yield>
    yield();
  8005c2:	b97ff0ef          	jal	ra,800158 <yield>
    yield();
  8005c6:	b93ff0ef          	jal	ra,800158 <yield>

    cprintf("I am the parent.  Killing the child...\n");
  8005ca:	00000517          	auipc	a0,0x0
  8005ce:	45650513          	addi	a0,a0,1110 # 800a20 <error_string+0x230>
  8005d2:	acfff0ef          	jal	ra,8000a0 <cprintf>

    assert((ret = kill(pid)) == 0);
  8005d6:	8522                	mv	a0,s0
  8005d8:	b85ff0ef          	jal	ra,80015c <kill>
  8005dc:	ed31                	bnez	a0,800638 <main+0xae>
    cprintf("kill returns %d\n", ret);
  8005de:	4581                	li	a1,0
  8005e0:	00000517          	auipc	a0,0x0
  8005e4:	4a850513          	addi	a0,a0,1192 # 800a88 <error_string+0x298>
  8005e8:	ab9ff0ef          	jal	ra,8000a0 <cprintf>

    assert((ret = waitpid(pid, NULL)) == 0);
  8005ec:	4581                	li	a1,0
  8005ee:	8522                	mv	a0,s0
  8005f0:	b65ff0ef          	jal	ra,800154 <waitpid>
  8005f4:	e11d                	bnez	a0,80061a <main+0x90>
    cprintf("wait returns %d\n", ret);
  8005f6:	4581                	li	a1,0
  8005f8:	00000517          	auipc	a0,0x0
  8005fc:	4c850513          	addi	a0,a0,1224 # 800ac0 <error_string+0x2d0>
  800600:	aa1ff0ef          	jal	ra,8000a0 <cprintf>

    cprintf("spin may pass.\n");
  800604:	00000517          	auipc	a0,0x0
  800608:	4d450513          	addi	a0,a0,1236 # 800ad8 <error_string+0x2e8>
  80060c:	a95ff0ef          	jal	ra,8000a0 <cprintf>
    return 0;
}
  800610:	60a2                	ld	ra,8(sp)
  800612:	6402                	ld	s0,0(sp)
  800614:	4501                	li	a0,0
  800616:	0141                	addi	sp,sp,16
  800618:	8082                	ret
    assert((ret = waitpid(pid, NULL)) == 0);
  80061a:	00000697          	auipc	a3,0x0
  80061e:	48668693          	addi	a3,a3,1158 # 800aa0 <error_string+0x2b0>
  800622:	00000617          	auipc	a2,0x0
  800626:	43e60613          	addi	a2,a2,1086 # 800a60 <error_string+0x270>
  80062a:	45dd                	li	a1,23
  80062c:	00000517          	auipc	a0,0x0
  800630:	44c50513          	addi	a0,a0,1100 # 800a78 <error_string+0x288>
  800634:	9f3ff0ef          	jal	ra,800026 <__panic>
    assert((ret = kill(pid)) == 0);
  800638:	00000697          	auipc	a3,0x0
  80063c:	41068693          	addi	a3,a3,1040 # 800a48 <error_string+0x258>
  800640:	00000617          	auipc	a2,0x0
  800644:	42060613          	addi	a2,a2,1056 # 800a60 <error_string+0x270>
  800648:	45d1                	li	a1,20
  80064a:	00000517          	auipc	a0,0x0
  80064e:	42e50513          	addi	a0,a0,1070 # 800a78 <error_string+0x288>
  800652:	9d5ff0ef          	jal	ra,800026 <__panic>
