
obj/__user_matrix.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  800020:	14e000ef          	jal	ra,80016e <umain>
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
  800038:	7ac50513          	addi	a0,a0,1964 # 8007e0 <main+0xcc>
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
  800058:	aec50513          	addi	a0,a0,-1300 # 800b40 <error_string+0x1d0>
  80005c:	044000ef          	jal	ra,8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800060:	5559                	li	a0,-10
  800062:	0de000ef          	jal	ra,800140 <exit>

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
  80006e:	0ca000ef          	jal	ra,800138 <sys_putc>
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
  800094:	152000ef          	jal	ra,8001e6 <vprintfmt>
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
  8000c8:	11e000ef          	jal	ra,8001e6 <vprintfmt>
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

0000000000800132 <sys_getpid>:
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  800132:	4549                	li	a0,18
  800134:	fa1ff06f          	j	8000d4 <syscall>

0000000000800138 <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  800138:	85aa                	mv	a1,a0
  80013a:	4579                	li	a0,30
  80013c:	f99ff06f          	j	8000d4 <syscall>

0000000000800140 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800140:	1141                	addi	sp,sp,-16
  800142:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800144:	fc9ff0ef          	jal	ra,80010c <sys_exit>
    cprintf("BUG: exit failed.\n");
  800148:	00000517          	auipc	a0,0x0
  80014c:	6b850513          	addi	a0,a0,1720 # 800800 <main+0xec>
  800150:	f51ff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  800154:	a001                	j	800154 <exit+0x14>

0000000000800156 <fork>:
}

int
fork(void) {
    return sys_fork();
  800156:	fbfff06f          	j	800114 <sys_fork>

000000000080015a <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  80015a:	4581                	li	a1,0
  80015c:	4501                	li	a0,0
  80015e:	fbdff06f          	j	80011a <sys_wait>

0000000000800162 <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  800162:	fc3ff06f          	j	800124 <sys_yield>

0000000000800166 <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  800166:	fc5ff06f          	j	80012a <sys_kill>

000000000080016a <getpid>:
}

int
getpid(void) {
    return sys_getpid();
  80016a:	fc9ff06f          	j	800132 <sys_getpid>

000000000080016e <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80016e:	1141                	addi	sp,sp,-16
  800170:	e406                	sd	ra,8(sp)
    int ret = main();
  800172:	5a2000ef          	jal	ra,800714 <main>
    exit(ret);
  800176:	fcbff0ef          	jal	ra,800140 <exit>

000000000080017a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80017a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80017e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800180:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800184:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800186:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80018a:	f022                	sd	s0,32(sp)
  80018c:	ec26                	sd	s1,24(sp)
  80018e:	e84a                	sd	s2,16(sp)
  800190:	f406                	sd	ra,40(sp)
  800192:	e44e                	sd	s3,8(sp)
  800194:	84aa                	mv	s1,a0
  800196:	892e                	mv	s2,a1
  800198:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80019c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  80019e:	03067e63          	bleu	a6,a2,8001da <printnum+0x60>
  8001a2:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8001a4:	00805763          	blez	s0,8001b2 <printnum+0x38>
  8001a8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001aa:	85ca                	mv	a1,s2
  8001ac:	854e                	mv	a0,s3
  8001ae:	9482                	jalr	s1
        while (-- width > 0)
  8001b0:	fc65                	bnez	s0,8001a8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001b2:	1a02                	slli	s4,s4,0x20
  8001b4:	020a5a13          	srli	s4,s4,0x20
  8001b8:	00001797          	auipc	a5,0x1
  8001bc:	88078793          	addi	a5,a5,-1920 # 800a38 <error_string+0xc8>
  8001c0:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001c2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001c4:	000a4503          	lbu	a0,0(s4)
}
  8001c8:	70a2                	ld	ra,40(sp)
  8001ca:	69a2                	ld	s3,8(sp)
  8001cc:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ce:	85ca                	mv	a1,s2
  8001d0:	8326                	mv	t1,s1
}
  8001d2:	6942                	ld	s2,16(sp)
  8001d4:	64e2                	ld	s1,24(sp)
  8001d6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001d8:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001da:	03065633          	divu	a2,a2,a6
  8001de:	8722                	mv	a4,s0
  8001e0:	f9bff0ef          	jal	ra,80017a <printnum>
  8001e4:	b7f9                	j	8001b2 <printnum+0x38>

00000000008001e6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001e6:	7119                	addi	sp,sp,-128
  8001e8:	f4a6                	sd	s1,104(sp)
  8001ea:	f0ca                	sd	s2,96(sp)
  8001ec:	e8d2                	sd	s4,80(sp)
  8001ee:	e4d6                	sd	s5,72(sp)
  8001f0:	e0da                	sd	s6,64(sp)
  8001f2:	fc5e                	sd	s7,56(sp)
  8001f4:	f862                	sd	s8,48(sp)
  8001f6:	f06a                	sd	s10,32(sp)
  8001f8:	fc86                	sd	ra,120(sp)
  8001fa:	f8a2                	sd	s0,112(sp)
  8001fc:	ecce                	sd	s3,88(sp)
  8001fe:	f466                	sd	s9,40(sp)
  800200:	ec6e                	sd	s11,24(sp)
  800202:	892a                	mv	s2,a0
  800204:	84ae                	mv	s1,a1
  800206:	8d32                	mv	s10,a2
  800208:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  80020a:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  80020c:	00000a17          	auipc	s4,0x0
  800210:	608a0a13          	addi	s4,s4,1544 # 800814 <main+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800214:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800218:	00000c17          	auipc	s8,0x0
  80021c:	758c0c13          	addi	s8,s8,1880 # 800970 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800220:	000d4503          	lbu	a0,0(s10)
  800224:	02500793          	li	a5,37
  800228:	001d0413          	addi	s0,s10,1
  80022c:	00f50e63          	beq	a0,a5,800248 <vprintfmt+0x62>
            if (ch == '\0') {
  800230:	c521                	beqz	a0,800278 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800232:	02500993          	li	s3,37
  800236:	a011                	j	80023a <vprintfmt+0x54>
            if (ch == '\0') {
  800238:	c121                	beqz	a0,800278 <vprintfmt+0x92>
            putch(ch, putdat);
  80023a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80023c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80023e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800240:	fff44503          	lbu	a0,-1(s0)
  800244:	ff351ae3          	bne	a0,s3,800238 <vprintfmt+0x52>
  800248:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80024c:	02000793          	li	a5,32
        lflag = altflag = 0;
  800250:	4981                	li	s3,0
  800252:	4801                	li	a6,0
        width = precision = -1;
  800254:	5cfd                	li	s9,-1
  800256:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800258:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  80025c:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  80025e:	fdd6069b          	addiw	a3,a2,-35
  800262:	0ff6f693          	andi	a3,a3,255
  800266:	00140d13          	addi	s10,s0,1
  80026a:	20d5e563          	bltu	a1,a3,800474 <vprintfmt+0x28e>
  80026e:	068a                	slli	a3,a3,0x2
  800270:	96d2                	add	a3,a3,s4
  800272:	4294                	lw	a3,0(a3)
  800274:	96d2                	add	a3,a3,s4
  800276:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800278:	70e6                	ld	ra,120(sp)
  80027a:	7446                	ld	s0,112(sp)
  80027c:	74a6                	ld	s1,104(sp)
  80027e:	7906                	ld	s2,96(sp)
  800280:	69e6                	ld	s3,88(sp)
  800282:	6a46                	ld	s4,80(sp)
  800284:	6aa6                	ld	s5,72(sp)
  800286:	6b06                	ld	s6,64(sp)
  800288:	7be2                	ld	s7,56(sp)
  80028a:	7c42                	ld	s8,48(sp)
  80028c:	7ca2                	ld	s9,40(sp)
  80028e:	7d02                	ld	s10,32(sp)
  800290:	6de2                	ld	s11,24(sp)
  800292:	6109                	addi	sp,sp,128
  800294:	8082                	ret
    if (lflag >= 2) {
  800296:	4705                	li	a4,1
  800298:	008a8593          	addi	a1,s5,8
  80029c:	01074463          	blt	a4,a6,8002a4 <vprintfmt+0xbe>
    else if (lflag) {
  8002a0:	26080363          	beqz	a6,800506 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  8002a4:	000ab603          	ld	a2,0(s5)
  8002a8:	46c1                	li	a3,16
  8002aa:	8aae                	mv	s5,a1
  8002ac:	a06d                	j	800356 <vprintfmt+0x170>
            goto reswitch;
  8002ae:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002b2:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002b4:	846a                	mv	s0,s10
            goto reswitch;
  8002b6:	b765                	j	80025e <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  8002b8:	000aa503          	lw	a0,0(s5)
  8002bc:	85a6                	mv	a1,s1
  8002be:	0aa1                	addi	s5,s5,8
  8002c0:	9902                	jalr	s2
            break;
  8002c2:	bfb9                	j	800220 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002c4:	4705                	li	a4,1
  8002c6:	008a8993          	addi	s3,s5,8
  8002ca:	01074463          	blt	a4,a6,8002d2 <vprintfmt+0xec>
    else if (lflag) {
  8002ce:	22080463          	beqz	a6,8004f6 <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002d2:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002d6:	24044463          	bltz	s0,80051e <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002da:	8622                	mv	a2,s0
  8002dc:	8ace                	mv	s5,s3
  8002de:	46a9                	li	a3,10
  8002e0:	a89d                	j	800356 <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002e2:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002e6:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002e8:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002ea:	41f7d69b          	sraiw	a3,a5,0x1f
  8002ee:	8fb5                	xor	a5,a5,a3
  8002f0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002f4:	1ad74363          	blt	a4,a3,80049a <vprintfmt+0x2b4>
  8002f8:	00369793          	slli	a5,a3,0x3
  8002fc:	97e2                	add	a5,a5,s8
  8002fe:	639c                	ld	a5,0(a5)
  800300:	18078d63          	beqz	a5,80049a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  800304:	86be                	mv	a3,a5
  800306:	00001617          	auipc	a2,0x1
  80030a:	82260613          	addi	a2,a2,-2014 # 800b28 <error_string+0x1b8>
  80030e:	85a6                	mv	a1,s1
  800310:	854a                	mv	a0,s2
  800312:	240000ef          	jal	ra,800552 <printfmt>
  800316:	b729                	j	800220 <vprintfmt+0x3a>
            lflag ++;
  800318:	00144603          	lbu	a2,1(s0)
  80031c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  80031e:	846a                	mv	s0,s10
            goto reswitch;
  800320:	bf3d                	j	80025e <vprintfmt+0x78>
    if (lflag >= 2) {
  800322:	4705                	li	a4,1
  800324:	008a8593          	addi	a1,s5,8
  800328:	01074463          	blt	a4,a6,800330 <vprintfmt+0x14a>
    else if (lflag) {
  80032c:	1e080263          	beqz	a6,800510 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  800330:	000ab603          	ld	a2,0(s5)
  800334:	46a1                	li	a3,8
  800336:	8aae                	mv	s5,a1
  800338:	a839                	j	800356 <vprintfmt+0x170>
            putch('0', putdat);
  80033a:	03000513          	li	a0,48
  80033e:	85a6                	mv	a1,s1
  800340:	e03e                	sd	a5,0(sp)
  800342:	9902                	jalr	s2
            putch('x', putdat);
  800344:	85a6                	mv	a1,s1
  800346:	07800513          	li	a0,120
  80034a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80034c:	0aa1                	addi	s5,s5,8
  80034e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800352:	6782                	ld	a5,0(sp)
  800354:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800356:	876e                	mv	a4,s11
  800358:	85a6                	mv	a1,s1
  80035a:	854a                	mv	a0,s2
  80035c:	e1fff0ef          	jal	ra,80017a <printnum>
            break;
  800360:	b5c1                	j	800220 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800362:	000ab603          	ld	a2,0(s5)
  800366:	0aa1                	addi	s5,s5,8
  800368:	1c060663          	beqz	a2,800534 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  80036c:	00160413          	addi	s0,a2,1
  800370:	17b05c63          	blez	s11,8004e8 <vprintfmt+0x302>
  800374:	02d00593          	li	a1,45
  800378:	14b79263          	bne	a5,a1,8004bc <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80037c:	00064783          	lbu	a5,0(a2)
  800380:	0007851b          	sext.w	a0,a5
  800384:	c905                	beqz	a0,8003b4 <vprintfmt+0x1ce>
  800386:	000cc563          	bltz	s9,800390 <vprintfmt+0x1aa>
  80038a:	3cfd                	addiw	s9,s9,-1
  80038c:	036c8263          	beq	s9,s6,8003b0 <vprintfmt+0x1ca>
                    putch('?', putdat);
  800390:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800392:	18098463          	beqz	s3,80051a <vprintfmt+0x334>
  800396:	3781                	addiw	a5,a5,-32
  800398:	18fbf163          	bleu	a5,s7,80051a <vprintfmt+0x334>
                    putch('?', putdat);
  80039c:	03f00513          	li	a0,63
  8003a0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a2:	0405                	addi	s0,s0,1
  8003a4:	fff44783          	lbu	a5,-1(s0)
  8003a8:	3dfd                	addiw	s11,s11,-1
  8003aa:	0007851b          	sext.w	a0,a5
  8003ae:	fd61                	bnez	a0,800386 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  8003b0:	e7b058e3          	blez	s11,800220 <vprintfmt+0x3a>
  8003b4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003b6:	85a6                	mv	a1,s1
  8003b8:	02000513          	li	a0,32
  8003bc:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003be:	e60d81e3          	beqz	s11,800220 <vprintfmt+0x3a>
  8003c2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003c4:	85a6                	mv	a1,s1
  8003c6:	02000513          	li	a0,32
  8003ca:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003cc:	fe0d94e3          	bnez	s11,8003b4 <vprintfmt+0x1ce>
  8003d0:	bd81                	j	800220 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003d2:	4705                	li	a4,1
  8003d4:	008a8593          	addi	a1,s5,8
  8003d8:	01074463          	blt	a4,a6,8003e0 <vprintfmt+0x1fa>
    else if (lflag) {
  8003dc:	12080063          	beqz	a6,8004fc <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003e0:	000ab603          	ld	a2,0(s5)
  8003e4:	46a9                	li	a3,10
  8003e6:	8aae                	mv	s5,a1
  8003e8:	b7bd                	j	800356 <vprintfmt+0x170>
  8003ea:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003ee:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  8003f2:	846a                	mv	s0,s10
  8003f4:	b5ad                	j	80025e <vprintfmt+0x78>
            putch(ch, putdat);
  8003f6:	85a6                	mv	a1,s1
  8003f8:	02500513          	li	a0,37
  8003fc:	9902                	jalr	s2
            break;
  8003fe:	b50d                	j	800220 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  800400:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  800404:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800408:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  80040a:	846a                	mv	s0,s10
            if (width < 0)
  80040c:	e40dd9e3          	bgez	s11,80025e <vprintfmt+0x78>
                width = precision, precision = -1;
  800410:	8de6                	mv	s11,s9
  800412:	5cfd                	li	s9,-1
  800414:	b5a9                	j	80025e <vprintfmt+0x78>
            goto reswitch;
  800416:	00144603          	lbu	a2,1(s0)
            padc = '0';
  80041a:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  80041e:	846a                	mv	s0,s10
            goto reswitch;
  800420:	bd3d                	j	80025e <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800422:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800426:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80042a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80042c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800430:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800434:	fcd56ce3          	bltu	a0,a3,80040c <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  800438:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80043a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  80043e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800442:	0196873b          	addw	a4,a3,s9
  800446:	0017171b          	slliw	a4,a4,0x1
  80044a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  80044e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800452:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800456:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80045a:	fcd57fe3          	bleu	a3,a0,800438 <vprintfmt+0x252>
  80045e:	b77d                	j	80040c <vprintfmt+0x226>
            if (width < 0)
  800460:	fffdc693          	not	a3,s11
  800464:	96fd                	srai	a3,a3,0x3f
  800466:	00ddfdb3          	and	s11,s11,a3
  80046a:	00144603          	lbu	a2,1(s0)
  80046e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800470:	846a                	mv	s0,s10
  800472:	b3f5                	j	80025e <vprintfmt+0x78>
            putch('%', putdat);
  800474:	85a6                	mv	a1,s1
  800476:	02500513          	li	a0,37
  80047a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80047c:	fff44703          	lbu	a4,-1(s0)
  800480:	02500793          	li	a5,37
  800484:	8d22                	mv	s10,s0
  800486:	d8f70de3          	beq	a4,a5,800220 <vprintfmt+0x3a>
  80048a:	02500713          	li	a4,37
  80048e:	1d7d                	addi	s10,s10,-1
  800490:	fffd4783          	lbu	a5,-1(s10)
  800494:	fee79de3          	bne	a5,a4,80048e <vprintfmt+0x2a8>
  800498:	b361                	j	800220 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80049a:	00000617          	auipc	a2,0x0
  80049e:	67e60613          	addi	a2,a2,1662 # 800b18 <error_string+0x1a8>
  8004a2:	85a6                	mv	a1,s1
  8004a4:	854a                	mv	a0,s2
  8004a6:	0ac000ef          	jal	ra,800552 <printfmt>
  8004aa:	bb9d                	j	800220 <vprintfmt+0x3a>
                p = "(null)";
  8004ac:	00000617          	auipc	a2,0x0
  8004b0:	66460613          	addi	a2,a2,1636 # 800b10 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004b4:	00000417          	auipc	s0,0x0
  8004b8:	65d40413          	addi	s0,s0,1629 # 800b11 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004bc:	8532                	mv	a0,a2
  8004be:	85e6                	mv	a1,s9
  8004c0:	e032                	sd	a2,0(sp)
  8004c2:	e43e                	sd	a5,8(sp)
  8004c4:	0f2000ef          	jal	ra,8005b6 <strnlen>
  8004c8:	40ad8dbb          	subw	s11,s11,a0
  8004cc:	6602                	ld	a2,0(sp)
  8004ce:	01b05d63          	blez	s11,8004e8 <vprintfmt+0x302>
  8004d2:	67a2                	ld	a5,8(sp)
  8004d4:	2781                	sext.w	a5,a5
  8004d6:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004d8:	6522                	ld	a0,8(sp)
  8004da:	85a6                	mv	a1,s1
  8004dc:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004de:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004e0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e2:	6602                	ld	a2,0(sp)
  8004e4:	fe0d9ae3          	bnez	s11,8004d8 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e8:	00064783          	lbu	a5,0(a2)
  8004ec:	0007851b          	sext.w	a0,a5
  8004f0:	e8051be3          	bnez	a0,800386 <vprintfmt+0x1a0>
  8004f4:	b335                	j	800220 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  8004f6:	000aa403          	lw	s0,0(s5)
  8004fa:	bbf1                	j	8002d6 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  8004fc:	000ae603          	lwu	a2,0(s5)
  800500:	46a9                	li	a3,10
  800502:	8aae                	mv	s5,a1
  800504:	bd89                	j	800356 <vprintfmt+0x170>
  800506:	000ae603          	lwu	a2,0(s5)
  80050a:	46c1                	li	a3,16
  80050c:	8aae                	mv	s5,a1
  80050e:	b5a1                	j	800356 <vprintfmt+0x170>
  800510:	000ae603          	lwu	a2,0(s5)
  800514:	46a1                	li	a3,8
  800516:	8aae                	mv	s5,a1
  800518:	bd3d                	j	800356 <vprintfmt+0x170>
                    putch(ch, putdat);
  80051a:	9902                	jalr	s2
  80051c:	b559                	j	8003a2 <vprintfmt+0x1bc>
                putch('-', putdat);
  80051e:	85a6                	mv	a1,s1
  800520:	02d00513          	li	a0,45
  800524:	e03e                	sd	a5,0(sp)
  800526:	9902                	jalr	s2
                num = -(long long)num;
  800528:	8ace                	mv	s5,s3
  80052a:	40800633          	neg	a2,s0
  80052e:	46a9                	li	a3,10
  800530:	6782                	ld	a5,0(sp)
  800532:	b515                	j	800356 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  800534:	01b05663          	blez	s11,800540 <vprintfmt+0x35a>
  800538:	02d00693          	li	a3,45
  80053c:	f6d798e3          	bne	a5,a3,8004ac <vprintfmt+0x2c6>
  800540:	00000417          	auipc	s0,0x0
  800544:	5d140413          	addi	s0,s0,1489 # 800b11 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800548:	02800513          	li	a0,40
  80054c:	02800793          	li	a5,40
  800550:	bd1d                	j	800386 <vprintfmt+0x1a0>

0000000000800552 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800552:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800554:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800558:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80055a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80055c:	ec06                	sd	ra,24(sp)
  80055e:	f83a                	sd	a4,48(sp)
  800560:	fc3e                	sd	a5,56(sp)
  800562:	e0c2                	sd	a6,64(sp)
  800564:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800566:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800568:	c7fff0ef          	jal	ra,8001e6 <vprintfmt>
}
  80056c:	60e2                	ld	ra,24(sp)
  80056e:	6161                	addi	sp,sp,80
  800570:	8082                	ret

0000000000800572 <rand>:
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  800572:	00001697          	auipc	a3,0x1
  800576:	a8e68693          	addi	a3,a3,-1394 # 801000 <next>
  80057a:	00000717          	auipc	a4,0x0
  80057e:	5b670713          	addi	a4,a4,1462 # 800b30 <error_string+0x1c0>
  800582:	629c                	ld	a5,0(a3)
  800584:	6318                	ld	a4,0(a4)
  800586:	02e787b3          	mul	a5,a5,a4
  80058a:	577d                	li	a4,-1
  80058c:	8341                	srli	a4,a4,0x10
  80058e:	07ad                	addi	a5,a5,11
  800590:	8ff9                	and	a5,a5,a4
    unsigned long long result = (next >> 12);
    return (int)do_div(result, RAND_MAX + 1);
  800592:	80000737          	lui	a4,0x80000
    unsigned long long result = (next >> 12);
  800596:	00c7d513          	srli	a0,a5,0xc
    return (int)do_div(result, RAND_MAX + 1);
  80059a:	fff74713          	not	a4,a4
  80059e:	02e57533          	remu	a0,a0,a4
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  8005a2:	e29c                	sd	a5,0(a3)
}
  8005a4:	2505                	addiw	a0,a0,1
  8005a6:	8082                	ret

00000000008005a8 <srand>:
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
    next = seed;
  8005a8:	1502                	slli	a0,a0,0x20
  8005aa:	9101                	srli	a0,a0,0x20
  8005ac:	00001797          	auipc	a5,0x1
  8005b0:	a4a7ba23          	sd	a0,-1452(a5) # 801000 <next>
}
  8005b4:	8082                	ret

00000000008005b6 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  8005b6:	c185                	beqz	a1,8005d6 <strnlen+0x20>
  8005b8:	00054783          	lbu	a5,0(a0)
  8005bc:	cf89                	beqz	a5,8005d6 <strnlen+0x20>
    size_t cnt = 0;
  8005be:	4781                	li	a5,0
  8005c0:	a021                	j	8005c8 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  8005c2:	00074703          	lbu	a4,0(a4) # ffffffff80000000 <matc+0xffffffff7f7fecd8>
  8005c6:	c711                	beqz	a4,8005d2 <strnlen+0x1c>
        cnt ++;
  8005c8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8005ca:	00f50733          	add	a4,a0,a5
  8005ce:	fef59ae3          	bne	a1,a5,8005c2 <strnlen+0xc>
    }
    return cnt;
}
  8005d2:	853e                	mv	a0,a5
  8005d4:	8082                	ret
    size_t cnt = 0;
  8005d6:	4781                	li	a5,0
}
  8005d8:	853e                	mv	a0,a5
  8005da:	8082                	ret

00000000008005dc <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
  8005dc:	ca01                	beqz	a2,8005ec <memset+0x10>
  8005de:	962a                	add	a2,a2,a0
    char *p = s;
  8005e0:	87aa                	mv	a5,a0
        *p ++ = c;
  8005e2:	0785                	addi	a5,a5,1
  8005e4:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
  8005e8:	fec79de3          	bne	a5,a2,8005e2 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  8005ec:	8082                	ret

00000000008005ee <work>:
static int mata[MATSIZE][MATSIZE];
static int matb[MATSIZE][MATSIZE];
static int matc[MATSIZE][MATSIZE];

void
work(unsigned int times) {
  8005ee:	7179                	addi	sp,sp,-48
  8005f0:	e84a                	sd	s2,16(sp)
  8005f2:	00001597          	auipc	a1,0x1
  8005f6:	9ee58593          	addi	a1,a1,-1554 # 800fe0 <error_string+0x670>
  8005fa:	00001917          	auipc	s2,0x1
  8005fe:	b9e90913          	addi	s2,s2,-1122 # 801198 <matb>
  800602:	f022                	sd	s0,32(sp)
  800604:	ec26                	sd	s1,24(sp)
  800606:	e44e                	sd	s3,8(sp)
  800608:	f406                	sd	ra,40(sp)
  80060a:	84aa                	mv	s1,a0
  80060c:	00001617          	auipc	a2,0x1
  800610:	bb460613          	addi	a2,a2,-1100 # 8011c0 <matb+0x28>
  800614:	00001417          	auipc	s0,0x1
  800618:	d3c40413          	addi	s0,s0,-708 # 801350 <matc+0x28>
  80061c:	00001997          	auipc	s3,0x1
  800620:	9ec98993          	addi	s3,s3,-1556 # 801008 <mata>
  800624:	412585b3          	sub	a1,a1,s2
    int i, j, k, size = MATSIZE;
    for (i = 0; i < size; i ++) {
        for (j = 0; j < size; j ++) {
            mata[i][j] = matb[i][j] = 1;
  800628:	4685                	li	a3,1
  80062a:	fd860793          	addi	a5,a2,-40
  80062e:	00c58733          	add	a4,a1,a2
  800632:	c394                	sw	a3,0(a5)
  800634:	c314                	sw	a3,0(a4)
  800636:	0791                	addi	a5,a5,4
  800638:	0711                	addi	a4,a4,4
        for (j = 0; j < size; j ++) {
  80063a:	fec79ce3          	bne	a5,a2,800632 <work+0x44>
  80063e:	02878613          	addi	a2,a5,40
    for (i = 0; i < size; i ++) {
  800642:	fe8614e3          	bne	a2,s0,80062a <work+0x3c>
        }
    }

    yield();
  800646:	b1dff0ef          	jal	ra,800162 <yield>

    cprintf("pid %d is running (%d times)!.\n", getpid(), times);
  80064a:	b21ff0ef          	jal	ra,80016a <getpid>
  80064e:	8626                	mv	a2,s1
  800650:	85aa                	mv	a1,a0
  800652:	00000517          	auipc	a0,0x0
  800656:	53650513          	addi	a0,a0,1334 # 800b88 <error_string+0x218>
  80065a:	a47ff0ef          	jal	ra,8000a0 <cprintf>

    while (times -- > 0) {
  80065e:	53fd                	li	t2,-1
  800660:	34fd                	addiw	s1,s1,-1
  800662:	00001297          	auipc	t0,0x1
  800666:	b3628293          	addi	t0,t0,-1226 # 801198 <matb>
  80066a:	00001f97          	auipc	t6,0x1
  80066e:	cbef8f93          	addi	t6,t6,-834 # 801328 <matc>
  800672:	00001f17          	auipc	t5,0x1
  800676:	e46f0f13          	addi	t5,t5,-442 # 8014b8 <matc+0x190>
                    matc[i][j] += mata[i][k] * matb[k][j];
                }
            }
        }
        for (i = 0; i < size; i ++) {
            for (j = 0; j < size; j ++) {
  80067a:	02800e13          	li	t3,40
    while (times -- > 0) {
  80067e:	06748f63          	beq	s1,t2,8006fc <work+0x10e>
  800682:	00001897          	auipc	a7,0x1
  800686:	ca688893          	addi	a7,a7,-858 # 801328 <matc>
  80068a:	8ec6                	mv	t4,a7
  80068c:	834e                	mv	t1,s3
  80068e:	857e                	mv	a0,t6
work(unsigned int times) {
  800690:	8876                	mv	a6,t4
                for (k = 0; k < size; k ++) {
  800692:	e7050793          	addi	a5,a0,-400
work(unsigned int times) {
  800696:	869a                	mv	a3,t1
  800698:	4601                	li	a2,0
                    matc[i][j] += mata[i][k] * matb[k][j];
  80069a:	4298                	lw	a4,0(a3)
  80069c:	438c                	lw	a1,0(a5)
  80069e:	02878793          	addi	a5,a5,40
  8006a2:	0691                	addi	a3,a3,4
  8006a4:	02b7073b          	mulw	a4,a4,a1
  8006a8:	9e39                	addw	a2,a2,a4
                for (k = 0; k < size; k ++) {
  8006aa:	fea798e3          	bne	a5,a0,80069a <work+0xac>
  8006ae:	00c82023          	sw	a2,0(a6)
  8006b2:	00478513          	addi	a0,a5,4
  8006b6:	0811                	addi	a6,a6,4
            for (j = 0; j < size; j ++) {
  8006b8:	fc851de3          	bne	a0,s0,800692 <work+0xa4>
  8006bc:	02830313          	addi	t1,t1,40
  8006c0:	028e8e93          	addi	t4,t4,40
        for (i = 0; i < size; i ++) {
  8006c4:	fc5315e3          	bne	t1,t0,80068e <work+0xa0>
  8006c8:	854e                	mv	a0,s3
  8006ca:	85ca                	mv	a1,s2
    while (times -- > 0) {
  8006cc:	4781                	li	a5,0
                mata[i][j] = matb[i][j] = matc[i][j];
  8006ce:	00f88733          	add	a4,a7,a5
  8006d2:	4318                	lw	a4,0(a4)
  8006d4:	00f58633          	add	a2,a1,a5
  8006d8:	00f506b3          	add	a3,a0,a5
  8006dc:	c218                	sw	a4,0(a2)
  8006de:	c298                	sw	a4,0(a3)
  8006e0:	0791                	addi	a5,a5,4
            for (j = 0; j < size; j ++) {
  8006e2:	ffc796e3          	bne	a5,t3,8006ce <work+0xe0>
  8006e6:	02888893          	addi	a7,a7,40
  8006ea:	02858593          	addi	a1,a1,40
  8006ee:	02850513          	addi	a0,a0,40
        for (i = 0; i < size; i ++) {
  8006f2:	fde89de3          	bne	a7,t5,8006cc <work+0xde>
    while (times -- > 0) {
  8006f6:	34fd                	addiw	s1,s1,-1
  8006f8:	f87495e3          	bne	s1,t2,800682 <work+0x94>
            }
        }
    }
    cprintf("pid %d done!.\n", getpid());
  8006fc:	a6fff0ef          	jal	ra,80016a <getpid>
  800700:	85aa                	mv	a1,a0
  800702:	00000517          	auipc	a0,0x0
  800706:	4a650513          	addi	a0,a0,1190 # 800ba8 <error_string+0x238>
  80070a:	997ff0ef          	jal	ra,8000a0 <cprintf>
    exit(0);
  80070e:	4501                	li	a0,0
  800710:	a31ff0ef          	jal	ra,800140 <exit>

0000000000800714 <main>:
}

const int total = 21;

int
main(void) {
  800714:	7175                	addi	sp,sp,-144
  800716:	f4ce                	sd	s3,104(sp)
    int pids[total];
    memset(pids, 0, sizeof(pids));
  800718:	05400613          	li	a2,84
  80071c:	4581                	li	a1,0
  80071e:	0028                	addi	a0,sp,8
  800720:	00810993          	addi	s3,sp,8
main(void) {
  800724:	e122                	sd	s0,128(sp)
  800726:	fca6                	sd	s1,120(sp)
  800728:	f8ca                	sd	s2,112(sp)
  80072a:	e506                	sd	ra,136(sp)
    memset(pids, 0, sizeof(pids));
  80072c:	84ce                	mv	s1,s3
  80072e:	eafff0ef          	jal	ra,8005dc <memset>

    int i;
    for (i = 0; i < total; i ++) {
  800732:	4401                	li	s0,0
  800734:	4955                	li	s2,21
        if ((pids[i] = fork()) == 0) {
  800736:	a21ff0ef          	jal	ra,800156 <fork>
  80073a:	c088                	sw	a0,0(s1)
  80073c:	cd2d                	beqz	a0,8007b6 <main+0xa2>
            srand(i * i);
            int times = (((unsigned int)rand()) % total);
            times = (times * times + 10) * 100;
            work(times);
        }
        if (pids[i] < 0) {
  80073e:	04054663          	bltz	a0,80078a <main+0x76>
    for (i = 0; i < total; i ++) {
  800742:	2405                	addiw	s0,s0,1
  800744:	0491                	addi	s1,s1,4
  800746:	ff2418e3          	bne	s0,s2,800736 <main+0x22>
            goto failed;
        }
    }

    cprintf("fork ok.\n");
  80074a:	00000517          	auipc	a0,0x0
  80074e:	3ee50513          	addi	a0,a0,1006 # 800b38 <error_string+0x1c8>
  800752:	94fff0ef          	jal	ra,8000a0 <cprintf>
  800756:	4455                	li	s0,21

    for (i = 0; i < total; i ++) {
        if (wait() != 0) {
  800758:	a03ff0ef          	jal	ra,80015a <wait>
  80075c:	e10d                	bnez	a0,80077e <main+0x6a>
  80075e:	347d                	addiw	s0,s0,-1
    for (i = 0; i < total; i ++) {
  800760:	fc65                	bnez	s0,800758 <main+0x44>
            cprintf("wait failed.\n");
            goto failed;
        }
    }

    cprintf("matrix pass.\n");
  800762:	00000517          	auipc	a0,0x0
  800766:	3f650513          	addi	a0,a0,1014 # 800b58 <error_string+0x1e8>
  80076a:	937ff0ef          	jal	ra,8000a0 <cprintf>
        if (pids[i] > 0) {
            kill(pids[i]);
        }
    }
    panic("FAIL: T.T\n");
}
  80076e:	60aa                	ld	ra,136(sp)
  800770:	640a                	ld	s0,128(sp)
  800772:	74e6                	ld	s1,120(sp)
  800774:	7946                	ld	s2,112(sp)
  800776:	79a6                	ld	s3,104(sp)
  800778:	4501                	li	a0,0
  80077a:	6149                	addi	sp,sp,144
  80077c:	8082                	ret
            cprintf("wait failed.\n");
  80077e:	00000517          	auipc	a0,0x0
  800782:	3ca50513          	addi	a0,a0,970 # 800b48 <error_string+0x1d8>
  800786:	91bff0ef          	jal	ra,8000a0 <cprintf>
            goto failed;
  80078a:	08e0                	addi	s0,sp,92
        if (pids[i] > 0) {
  80078c:	0009a503          	lw	a0,0(s3)
  800790:	00a05463          	blez	a0,800798 <main+0x84>
            kill(pids[i]);
  800794:	9d3ff0ef          	jal	ra,800166 <kill>
  800798:	0991                	addi	s3,s3,4
    for (i = 0; i < total; i ++) {
  80079a:	ff3419e3          	bne	s0,s3,80078c <main+0x78>
    panic("FAIL: T.T\n");
  80079e:	00000617          	auipc	a2,0x0
  8007a2:	3ca60613          	addi	a2,a2,970 # 800b68 <error_string+0x1f8>
  8007a6:	05200593          	li	a1,82
  8007aa:	00000517          	auipc	a0,0x0
  8007ae:	3ce50513          	addi	a0,a0,974 # 800b78 <error_string+0x208>
  8007b2:	875ff0ef          	jal	ra,800026 <__panic>
            srand(i * i);
  8007b6:	0284053b          	mulw	a0,s0,s0
  8007ba:	defff0ef          	jal	ra,8005a8 <srand>
            int times = (((unsigned int)rand()) % total);
  8007be:	db5ff0ef          	jal	ra,800572 <rand>
  8007c2:	47d5                	li	a5,21
  8007c4:	02f5753b          	remuw	a0,a0,a5
            times = (times * times + 10) * 100;
  8007c8:	02a5053b          	mulw	a0,a0,a0
  8007cc:	00a5079b          	addiw	a5,a0,10
            work(times);
  8007d0:	06400513          	li	a0,100
  8007d4:	02f50533          	mul	a0,a0,a5
  8007d8:	e17ff0ef          	jal	ra,8005ee <work>
