
obj/__user_priority.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  800020:	15c000ef          	jal	ra,80017c <umain>
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
  800038:	73c50513          	addi	a0,a0,1852 # 800770 <main+0x1b8>
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
  800058:	73c50513          	addi	a0,a0,1852 # 800790 <main+0x1d8>
  80005c:	044000ef          	jal	ra,8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800060:	5559                	li	a0,-10
  800062:	0e8000ef          	jal	ra,80014a <exit>

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
  800094:	160000ef          	jal	ra,8001f4 <vprintfmt>
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
  8000c8:	12c000ef          	jal	ra,8001f4 <vprintfmt>
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

0000000000800124 <sys_kill>:
    return syscall(SYS_yield);
}

int
sys_kill(int64_t pid) {
    return syscall(SYS_kill, pid);
  800124:	85aa                	mv	a1,a0
  800126:	4531                	li	a0,12
  800128:	fadff06f          	j	8000d4 <syscall>

000000000080012c <sys_getpid>:
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  80012c:	4549                	li	a0,18
  80012e:	fa7ff06f          	j	8000d4 <syscall>

0000000000800132 <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  800132:	85aa                	mv	a1,a0
  800134:	4579                	li	a0,30
  800136:	f9fff06f          	j	8000d4 <syscall>

000000000080013a <sys_gettime>:
    return syscall(SYS_pgdir);
}

int
sys_gettime(void) {
    return syscall(SYS_gettime);
  80013a:	4545                	li	a0,17
  80013c:	f99ff06f          	j	8000d4 <syscall>

0000000000800140 <sys_lab6_set_priority>:
}

void
sys_lab6_set_priority(uint64_t priority)
{
    syscall(SYS_lab6_set_priority, priority);
  800140:	85aa                	mv	a1,a0
  800142:	0ff00513          	li	a0,255
  800146:	f8fff06f          	j	8000d4 <syscall>

000000000080014a <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80014a:	1141                	addi	sp,sp,-16
  80014c:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80014e:	fbfff0ef          	jal	ra,80010c <sys_exit>
    cprintf("BUG: exit failed.\n");
  800152:	00000517          	auipc	a0,0x0
  800156:	64650513          	addi	a0,a0,1606 # 800798 <main+0x1e0>
  80015a:	f47ff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  80015e:	a001                	j	80015e <exit+0x14>

0000000000800160 <fork>:
}

int
fork(void) {
    return sys_fork();
  800160:	fb5ff06f          	j	800114 <sys_fork>

0000000000800164 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  800164:	fb7ff06f          	j	80011a <sys_wait>

0000000000800168 <kill>:
    sys_yield();
}

int
kill(int pid) {
    return sys_kill(pid);
  800168:	fbdff06f          	j	800124 <sys_kill>

000000000080016c <getpid>:
}

int
getpid(void) {
    return sys_getpid();
  80016c:	fc1ff06f          	j	80012c <sys_getpid>

0000000000800170 <gettime_msec>:
    sys_pgdir();
}

unsigned int
gettime_msec(void) {
    return (unsigned int)sys_gettime();
  800170:	fcbff06f          	j	80013a <sys_gettime>

0000000000800174 <lab6_setpriority>:
}

void
lab6_setpriority(uint32_t priority)
{
    sys_lab6_set_priority(priority);
  800174:	1502                	slli	a0,a0,0x20
  800176:	9101                	srli	a0,a0,0x20
  800178:	fc9ff06f          	j	800140 <sys_lab6_set_priority>

000000000080017c <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80017c:	1141                	addi	sp,sp,-16
  80017e:	e406                	sd	ra,8(sp)
    int ret = main();
  800180:	438000ef          	jal	ra,8005b8 <main>
    exit(ret);
  800184:	fc7ff0ef          	jal	ra,80014a <exit>

0000000000800188 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800188:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80018c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80018e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800192:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800194:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800198:	f022                	sd	s0,32(sp)
  80019a:	ec26                	sd	s1,24(sp)
  80019c:	e84a                	sd	s2,16(sp)
  80019e:	f406                	sd	ra,40(sp)
  8001a0:	e44e                	sd	s3,8(sp)
  8001a2:	84aa                	mv	s1,a0
  8001a4:	892e                	mv	s2,a1
  8001a6:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  8001aa:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  8001ac:	03067e63          	bleu	a6,a2,8001e8 <printnum+0x60>
  8001b0:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8001b2:	00805763          	blez	s0,8001c0 <printnum+0x38>
  8001b6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001b8:	85ca                	mv	a1,s2
  8001ba:	854e                	mv	a0,s3
  8001bc:	9482                	jalr	s1
        while (-- width > 0)
  8001be:	fc65                	bnez	s0,8001b6 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001c0:	1a02                	slli	s4,s4,0x20
  8001c2:	020a5a13          	srli	s4,s4,0x20
  8001c6:	00001797          	auipc	a5,0x1
  8001ca:	80a78793          	addi	a5,a5,-2038 # 8009d0 <error_string+0xc8>
  8001ce:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001d0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001d2:	000a4503          	lbu	a0,0(s4)
}
  8001d6:	70a2                	ld	ra,40(sp)
  8001d8:	69a2                	ld	s3,8(sp)
  8001da:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001dc:	85ca                	mv	a1,s2
  8001de:	8326                	mv	t1,s1
}
  8001e0:	6942                	ld	s2,16(sp)
  8001e2:	64e2                	ld	s1,24(sp)
  8001e4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001e6:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001e8:	03065633          	divu	a2,a2,a6
  8001ec:	8722                	mv	a4,s0
  8001ee:	f9bff0ef          	jal	ra,800188 <printnum>
  8001f2:	b7f9                	j	8001c0 <printnum+0x38>

00000000008001f4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001f4:	7119                	addi	sp,sp,-128
  8001f6:	f4a6                	sd	s1,104(sp)
  8001f8:	f0ca                	sd	s2,96(sp)
  8001fa:	e8d2                	sd	s4,80(sp)
  8001fc:	e4d6                	sd	s5,72(sp)
  8001fe:	e0da                	sd	s6,64(sp)
  800200:	fc5e                	sd	s7,56(sp)
  800202:	f862                	sd	s8,48(sp)
  800204:	f06a                	sd	s10,32(sp)
  800206:	fc86                	sd	ra,120(sp)
  800208:	f8a2                	sd	s0,112(sp)
  80020a:	ecce                	sd	s3,88(sp)
  80020c:	f466                	sd	s9,40(sp)
  80020e:	ec6e                	sd	s11,24(sp)
  800210:	892a                	mv	s2,a0
  800212:	84ae                	mv	s1,a1
  800214:	8d32                	mv	s10,a2
  800216:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800218:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  80021a:	00000a17          	auipc	s4,0x0
  80021e:	592a0a13          	addi	s4,s4,1426 # 8007ac <main+0x1f4>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800222:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800226:	00000c17          	auipc	s8,0x0
  80022a:	6e2c0c13          	addi	s8,s8,1762 # 800908 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80022e:	000d4503          	lbu	a0,0(s10)
  800232:	02500793          	li	a5,37
  800236:	001d0413          	addi	s0,s10,1
  80023a:	00f50e63          	beq	a0,a5,800256 <vprintfmt+0x62>
            if (ch == '\0') {
  80023e:	c521                	beqz	a0,800286 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800240:	02500993          	li	s3,37
  800244:	a011                	j	800248 <vprintfmt+0x54>
            if (ch == '\0') {
  800246:	c121                	beqz	a0,800286 <vprintfmt+0x92>
            putch(ch, putdat);
  800248:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80024a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80024c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80024e:	fff44503          	lbu	a0,-1(s0)
  800252:	ff351ae3          	bne	a0,s3,800246 <vprintfmt+0x52>
  800256:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80025a:	02000793          	li	a5,32
        lflag = altflag = 0;
  80025e:	4981                	li	s3,0
  800260:	4801                	li	a6,0
        width = precision = -1;
  800262:	5cfd                	li	s9,-1
  800264:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800266:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  80026a:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  80026c:	fdd6069b          	addiw	a3,a2,-35
  800270:	0ff6f693          	andi	a3,a3,255
  800274:	00140d13          	addi	s10,s0,1
  800278:	20d5e563          	bltu	a1,a3,800482 <vprintfmt+0x28e>
  80027c:	068a                	slli	a3,a3,0x2
  80027e:	96d2                	add	a3,a3,s4
  800280:	4294                	lw	a3,0(a3)
  800282:	96d2                	add	a3,a3,s4
  800284:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800286:	70e6                	ld	ra,120(sp)
  800288:	7446                	ld	s0,112(sp)
  80028a:	74a6                	ld	s1,104(sp)
  80028c:	7906                	ld	s2,96(sp)
  80028e:	69e6                	ld	s3,88(sp)
  800290:	6a46                	ld	s4,80(sp)
  800292:	6aa6                	ld	s5,72(sp)
  800294:	6b06                	ld	s6,64(sp)
  800296:	7be2                	ld	s7,56(sp)
  800298:	7c42                	ld	s8,48(sp)
  80029a:	7ca2                	ld	s9,40(sp)
  80029c:	7d02                	ld	s10,32(sp)
  80029e:	6de2                	ld	s11,24(sp)
  8002a0:	6109                	addi	sp,sp,128
  8002a2:	8082                	ret
    if (lflag >= 2) {
  8002a4:	4705                	li	a4,1
  8002a6:	008a8593          	addi	a1,s5,8
  8002aa:	01074463          	blt	a4,a6,8002b2 <vprintfmt+0xbe>
    else if (lflag) {
  8002ae:	26080363          	beqz	a6,800514 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  8002b2:	000ab603          	ld	a2,0(s5)
  8002b6:	46c1                	li	a3,16
  8002b8:	8aae                	mv	s5,a1
  8002ba:	a06d                	j	800364 <vprintfmt+0x170>
            goto reswitch;
  8002bc:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002c0:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002c2:	846a                	mv	s0,s10
            goto reswitch;
  8002c4:	b765                	j	80026c <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  8002c6:	000aa503          	lw	a0,0(s5)
  8002ca:	85a6                	mv	a1,s1
  8002cc:	0aa1                	addi	s5,s5,8
  8002ce:	9902                	jalr	s2
            break;
  8002d0:	bfb9                	j	80022e <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002d2:	4705                	li	a4,1
  8002d4:	008a8993          	addi	s3,s5,8
  8002d8:	01074463          	blt	a4,a6,8002e0 <vprintfmt+0xec>
    else if (lflag) {
  8002dc:	22080463          	beqz	a6,800504 <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002e0:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002e4:	24044463          	bltz	s0,80052c <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002e8:	8622                	mv	a2,s0
  8002ea:	8ace                	mv	s5,s3
  8002ec:	46a9                	li	a3,10
  8002ee:	a89d                	j	800364 <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002f0:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002f4:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002f6:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002f8:	41f7d69b          	sraiw	a3,a5,0x1f
  8002fc:	8fb5                	xor	a5,a5,a3
  8002fe:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800302:	1ad74363          	blt	a4,a3,8004a8 <vprintfmt+0x2b4>
  800306:	00369793          	slli	a5,a3,0x3
  80030a:	97e2                	add	a5,a5,s8
  80030c:	639c                	ld	a5,0(a5)
  80030e:	18078d63          	beqz	a5,8004a8 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  800312:	86be                	mv	a3,a5
  800314:	00000617          	auipc	a2,0x0
  800318:	7ac60613          	addi	a2,a2,1964 # 800ac0 <error_string+0x1b8>
  80031c:	85a6                	mv	a1,s1
  80031e:	854a                	mv	a0,s2
  800320:	240000ef          	jal	ra,800560 <printfmt>
  800324:	b729                	j	80022e <vprintfmt+0x3a>
            lflag ++;
  800326:	00144603          	lbu	a2,1(s0)
  80032a:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  80032c:	846a                	mv	s0,s10
            goto reswitch;
  80032e:	bf3d                	j	80026c <vprintfmt+0x78>
    if (lflag >= 2) {
  800330:	4705                	li	a4,1
  800332:	008a8593          	addi	a1,s5,8
  800336:	01074463          	blt	a4,a6,80033e <vprintfmt+0x14a>
    else if (lflag) {
  80033a:	1e080263          	beqz	a6,80051e <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  80033e:	000ab603          	ld	a2,0(s5)
  800342:	46a1                	li	a3,8
  800344:	8aae                	mv	s5,a1
  800346:	a839                	j	800364 <vprintfmt+0x170>
            putch('0', putdat);
  800348:	03000513          	li	a0,48
  80034c:	85a6                	mv	a1,s1
  80034e:	e03e                	sd	a5,0(sp)
  800350:	9902                	jalr	s2
            putch('x', putdat);
  800352:	85a6                	mv	a1,s1
  800354:	07800513          	li	a0,120
  800358:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80035a:	0aa1                	addi	s5,s5,8
  80035c:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800360:	6782                	ld	a5,0(sp)
  800362:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800364:	876e                	mv	a4,s11
  800366:	85a6                	mv	a1,s1
  800368:	854a                	mv	a0,s2
  80036a:	e1fff0ef          	jal	ra,800188 <printnum>
            break;
  80036e:	b5c1                	j	80022e <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800370:	000ab603          	ld	a2,0(s5)
  800374:	0aa1                	addi	s5,s5,8
  800376:	1c060663          	beqz	a2,800542 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  80037a:	00160413          	addi	s0,a2,1
  80037e:	17b05c63          	blez	s11,8004f6 <vprintfmt+0x302>
  800382:	02d00593          	li	a1,45
  800386:	14b79263          	bne	a5,a1,8004ca <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80038a:	00064783          	lbu	a5,0(a2)
  80038e:	0007851b          	sext.w	a0,a5
  800392:	c905                	beqz	a0,8003c2 <vprintfmt+0x1ce>
  800394:	000cc563          	bltz	s9,80039e <vprintfmt+0x1aa>
  800398:	3cfd                	addiw	s9,s9,-1
  80039a:	036c8263          	beq	s9,s6,8003be <vprintfmt+0x1ca>
                    putch('?', putdat);
  80039e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003a0:	18098463          	beqz	s3,800528 <vprintfmt+0x334>
  8003a4:	3781                	addiw	a5,a5,-32
  8003a6:	18fbf163          	bleu	a5,s7,800528 <vprintfmt+0x334>
                    putch('?', putdat);
  8003aa:	03f00513          	li	a0,63
  8003ae:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003b0:	0405                	addi	s0,s0,1
  8003b2:	fff44783          	lbu	a5,-1(s0)
  8003b6:	3dfd                	addiw	s11,s11,-1
  8003b8:	0007851b          	sext.w	a0,a5
  8003bc:	fd61                	bnez	a0,800394 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  8003be:	e7b058e3          	blez	s11,80022e <vprintfmt+0x3a>
  8003c2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003c4:	85a6                	mv	a1,s1
  8003c6:	02000513          	li	a0,32
  8003ca:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003cc:	e60d81e3          	beqz	s11,80022e <vprintfmt+0x3a>
  8003d0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003d2:	85a6                	mv	a1,s1
  8003d4:	02000513          	li	a0,32
  8003d8:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003da:	fe0d94e3          	bnez	s11,8003c2 <vprintfmt+0x1ce>
  8003de:	bd81                	j	80022e <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003e0:	4705                	li	a4,1
  8003e2:	008a8593          	addi	a1,s5,8
  8003e6:	01074463          	blt	a4,a6,8003ee <vprintfmt+0x1fa>
    else if (lflag) {
  8003ea:	12080063          	beqz	a6,80050a <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003ee:	000ab603          	ld	a2,0(s5)
  8003f2:	46a9                	li	a3,10
  8003f4:	8aae                	mv	s5,a1
  8003f6:	b7bd                	j	800364 <vprintfmt+0x170>
  8003f8:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003fc:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  800400:	846a                	mv	s0,s10
  800402:	b5ad                	j	80026c <vprintfmt+0x78>
            putch(ch, putdat);
  800404:	85a6                	mv	a1,s1
  800406:	02500513          	li	a0,37
  80040a:	9902                	jalr	s2
            break;
  80040c:	b50d                	j	80022e <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  80040e:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  800412:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800416:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800418:	846a                	mv	s0,s10
            if (width < 0)
  80041a:	e40dd9e3          	bgez	s11,80026c <vprintfmt+0x78>
                width = precision, precision = -1;
  80041e:	8de6                	mv	s11,s9
  800420:	5cfd                	li	s9,-1
  800422:	b5a9                	j	80026c <vprintfmt+0x78>
            goto reswitch;
  800424:	00144603          	lbu	a2,1(s0)
            padc = '0';
  800428:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  80042c:	846a                	mv	s0,s10
            goto reswitch;
  80042e:	bd3d                	j	80026c <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800430:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800434:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800438:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80043a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  80043e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800442:	fcd56ce3          	bltu	a0,a3,80041a <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  800446:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800448:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  80044c:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800450:	0196873b          	addw	a4,a3,s9
  800454:	0017171b          	slliw	a4,a4,0x1
  800458:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  80045c:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800460:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800464:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800468:	fcd57fe3          	bleu	a3,a0,800446 <vprintfmt+0x252>
  80046c:	b77d                	j	80041a <vprintfmt+0x226>
            if (width < 0)
  80046e:	fffdc693          	not	a3,s11
  800472:	96fd                	srai	a3,a3,0x3f
  800474:	00ddfdb3          	and	s11,s11,a3
  800478:	00144603          	lbu	a2,1(s0)
  80047c:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  80047e:	846a                	mv	s0,s10
  800480:	b3f5                	j	80026c <vprintfmt+0x78>
            putch('%', putdat);
  800482:	85a6                	mv	a1,s1
  800484:	02500513          	li	a0,37
  800488:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80048a:	fff44703          	lbu	a4,-1(s0)
  80048e:	02500793          	li	a5,37
  800492:	8d22                	mv	s10,s0
  800494:	d8f70de3          	beq	a4,a5,80022e <vprintfmt+0x3a>
  800498:	02500713          	li	a4,37
  80049c:	1d7d                	addi	s10,s10,-1
  80049e:	fffd4783          	lbu	a5,-1(s10)
  8004a2:	fee79de3          	bne	a5,a4,80049c <vprintfmt+0x2a8>
  8004a6:	b361                	j	80022e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  8004a8:	00000617          	auipc	a2,0x0
  8004ac:	60860613          	addi	a2,a2,1544 # 800ab0 <error_string+0x1a8>
  8004b0:	85a6                	mv	a1,s1
  8004b2:	854a                	mv	a0,s2
  8004b4:	0ac000ef          	jal	ra,800560 <printfmt>
  8004b8:	bb9d                	j	80022e <vprintfmt+0x3a>
                p = "(null)";
  8004ba:	00000617          	auipc	a2,0x0
  8004be:	5ee60613          	addi	a2,a2,1518 # 800aa8 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004c2:	00000417          	auipc	s0,0x0
  8004c6:	5e740413          	addi	s0,s0,1511 # 800aa9 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ca:	8532                	mv	a0,a2
  8004cc:	85e6                	mv	a1,s9
  8004ce:	e032                	sd	a2,0(sp)
  8004d0:	e43e                	sd	a5,8(sp)
  8004d2:	0ae000ef          	jal	ra,800580 <strnlen>
  8004d6:	40ad8dbb          	subw	s11,s11,a0
  8004da:	6602                	ld	a2,0(sp)
  8004dc:	01b05d63          	blez	s11,8004f6 <vprintfmt+0x302>
  8004e0:	67a2                	ld	a5,8(sp)
  8004e2:	2781                	sext.w	a5,a5
  8004e4:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004e6:	6522                	ld	a0,8(sp)
  8004e8:	85a6                	mv	a1,s1
  8004ea:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ec:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004ee:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004f0:	6602                	ld	a2,0(sp)
  8004f2:	fe0d9ae3          	bnez	s11,8004e6 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004f6:	00064783          	lbu	a5,0(a2)
  8004fa:	0007851b          	sext.w	a0,a5
  8004fe:	e8051be3          	bnez	a0,800394 <vprintfmt+0x1a0>
  800502:	b335                	j	80022e <vprintfmt+0x3a>
        return va_arg(*ap, int);
  800504:	000aa403          	lw	s0,0(s5)
  800508:	bbf1                	j	8002e4 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  80050a:	000ae603          	lwu	a2,0(s5)
  80050e:	46a9                	li	a3,10
  800510:	8aae                	mv	s5,a1
  800512:	bd89                	j	800364 <vprintfmt+0x170>
  800514:	000ae603          	lwu	a2,0(s5)
  800518:	46c1                	li	a3,16
  80051a:	8aae                	mv	s5,a1
  80051c:	b5a1                	j	800364 <vprintfmt+0x170>
  80051e:	000ae603          	lwu	a2,0(s5)
  800522:	46a1                	li	a3,8
  800524:	8aae                	mv	s5,a1
  800526:	bd3d                	j	800364 <vprintfmt+0x170>
                    putch(ch, putdat);
  800528:	9902                	jalr	s2
  80052a:	b559                	j	8003b0 <vprintfmt+0x1bc>
                putch('-', putdat);
  80052c:	85a6                	mv	a1,s1
  80052e:	02d00513          	li	a0,45
  800532:	e03e                	sd	a5,0(sp)
  800534:	9902                	jalr	s2
                num = -(long long)num;
  800536:	8ace                	mv	s5,s3
  800538:	40800633          	neg	a2,s0
  80053c:	46a9                	li	a3,10
  80053e:	6782                	ld	a5,0(sp)
  800540:	b515                	j	800364 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  800542:	01b05663          	blez	s11,80054e <vprintfmt+0x35a>
  800546:	02d00693          	li	a3,45
  80054a:	f6d798e3          	bne	a5,a3,8004ba <vprintfmt+0x2c6>
  80054e:	00000417          	auipc	s0,0x0
  800552:	55b40413          	addi	s0,s0,1371 # 800aa9 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800556:	02800513          	li	a0,40
  80055a:	02800793          	li	a5,40
  80055e:	bd1d                	j	800394 <vprintfmt+0x1a0>

0000000000800560 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800560:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800562:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800566:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800568:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80056a:	ec06                	sd	ra,24(sp)
  80056c:	f83a                	sd	a4,48(sp)
  80056e:	fc3e                	sd	a5,56(sp)
  800570:	e0c2                	sd	a6,64(sp)
  800572:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800574:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800576:	c7fff0ef          	jal	ra,8001f4 <vprintfmt>
}
  80057a:	60e2                	ld	ra,24(sp)
  80057c:	6161                	addi	sp,sp,80
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

00000000008005a6 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
  8005a6:	ca01                	beqz	a2,8005b6 <memset+0x10>
  8005a8:	962a                	add	a2,a2,a0
    char *p = s;
  8005aa:	87aa                	mv	a5,a0
        *p ++ = c;
  8005ac:	0785                	addi	a5,a5,1
  8005ae:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
  8005b2:	fec79de3          	bne	a5,a2,8005ac <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  8005b6:	8082                	ret

00000000008005b8 <main>:
          j = !j;
     }
}

int
main(void) {
  8005b8:	711d                	addi	sp,sp,-96
     int i,time;
     memset(pids, 0, sizeof(pids));
  8005ba:	4651                	li	a2,20
  8005bc:	4581                	li	a1,0
  8005be:	00001517          	auipc	a0,0x1
  8005c2:	a7250513          	addi	a0,a0,-1422 # 801030 <pids>
main(void) {
  8005c6:	ec86                	sd	ra,88(sp)
  8005c8:	e8a2                	sd	s0,80(sp)
  8005ca:	e4a6                	sd	s1,72(sp)
  8005cc:	e0ca                	sd	s2,64(sp)
  8005ce:	fc4e                	sd	s3,56(sp)
  8005d0:	f852                	sd	s4,48(sp)
  8005d2:	f456                	sd	s5,40(sp)
  8005d4:	f05a                	sd	s6,32(sp)
  8005d6:	ec5e                	sd	s7,24(sp)
     memset(pids, 0, sizeof(pids));
  8005d8:	fcfff0ef          	jal	ra,8005a6 <memset>
     lab6_setpriority(TOTAL + 1);
  8005dc:	4519                	li	a0,6
  8005de:	00001a97          	auipc	s5,0x1
  8005e2:	a22a8a93          	addi	s5,s5,-1502 # 801000 <acc>
  8005e6:	00001917          	auipc	s2,0x1
  8005ea:	a4a90913          	addi	s2,s2,-1462 # 801030 <pids>
  8005ee:	b87ff0ef          	jal	ra,800174 <lab6_setpriority>

     for (i = 0; i < TOTAL; i ++) {
  8005f2:	89d6                	mv	s3,s5
     lab6_setpriority(TOTAL + 1);
  8005f4:	84ca                	mv	s1,s2
     for (i = 0; i < TOTAL; i ++) {
  8005f6:	4401                	li	s0,0
  8005f8:	4a15                	li	s4,5
          acc[i]=0;
  8005fa:	0009a023          	sw	zero,0(s3)
          if ((pids[i] = fork()) == 0) {
  8005fe:	b63ff0ef          	jal	ra,800160 <fork>
  800602:	c088                	sw	a0,0(s1)
  800604:	c969                	beqz	a0,8006d6 <main+0x11e>
                        }
                    }
               }
               
          }
          if (pids[i] < 0) {
  800606:	12054c63          	bltz	a0,80073e <main+0x186>
     for (i = 0; i < TOTAL; i ++) {
  80060a:	2405                	addiw	s0,s0,1
  80060c:	0991                	addi	s3,s3,4
  80060e:	0491                	addi	s1,s1,4
  800610:	ff4415e3          	bne	s0,s4,8005fa <main+0x42>
               goto failed;
          }
     }

     cprintf("main: fork ok,now need to wait pids.\n");
  800614:	00001497          	auipc	s1,0x1
  800618:	a0448493          	addi	s1,s1,-1532 # 801018 <status>
  80061c:	00000517          	auipc	a0,0x0
  800620:	4cc50513          	addi	a0,a0,1228 # 800ae8 <error_string+0x1e0>
  800624:	a7dff0ef          	jal	ra,8000a0 <cprintf>

     for (i = 0; i < TOTAL; i ++) {
  800628:	00001997          	auipc	s3,0x1
  80062c:	a0498993          	addi	s3,s3,-1532 # 80102c <status+0x14>
     cprintf("main: fork ok,now need to wait pids.\n");
  800630:	8a26                	mv	s4,s1
  800632:	8426                	mv	s0,s1
         status[i]=0;
         waitpid(pids[i],&status[i]);
         cprintf("main: pid %d, acc %d, time %d\n",pids[i],status[i],gettime_msec()); 
  800634:	00000b97          	auipc	s7,0x0
  800638:	4dcb8b93          	addi	s7,s7,1244 # 800b10 <error_string+0x208>
         waitpid(pids[i],&status[i]);
  80063c:	00092503          	lw	a0,0(s2)
  800640:	85a2                	mv	a1,s0
         status[i]=0;
  800642:	00042023          	sw	zero,0(s0)
         waitpid(pids[i],&status[i]);
  800646:	b1fff0ef          	jal	ra,800164 <waitpid>
         cprintf("main: pid %d, acc %d, time %d\n",pids[i],status[i],gettime_msec()); 
  80064a:	00092a83          	lw	s5,0(s2)
  80064e:	00042b03          	lw	s6,0(s0)
  800652:	b1fff0ef          	jal	ra,800170 <gettime_msec>
  800656:	0005069b          	sext.w	a3,a0
  80065a:	865a                	mv	a2,s6
  80065c:	85d6                	mv	a1,s5
  80065e:	855e                	mv	a0,s7
  800660:	0411                	addi	s0,s0,4
  800662:	a3fff0ef          	jal	ra,8000a0 <cprintf>
  800666:	0911                	addi	s2,s2,4
     for (i = 0; i < TOTAL; i ++) {
  800668:	fd341ae3          	bne	s0,s3,80063c <main+0x84>
     }
     cprintf("main: wait pids over\n");
  80066c:	00000517          	auipc	a0,0x0
  800670:	4c450513          	addi	a0,a0,1220 # 800b30 <error_string+0x228>
  800674:	a2dff0ef          	jal	ra,8000a0 <cprintf>
     cprintf("stride sched correct result:");
  800678:	00000517          	auipc	a0,0x0
  80067c:	4d050513          	addi	a0,a0,1232 # 800b48 <error_string+0x240>
  800680:	a21ff0ef          	jal	ra,8000a0 <cprintf>
     for (i = 0; i < TOTAL; i ++)
     {
         cprintf(" %d", (status[i] * 2 / status[0] + 1) / 2);
  800684:	00000417          	auipc	s0,0x0
  800688:	4e440413          	addi	s0,s0,1252 # 800b68 <error_string+0x260>
  80068c:	408c                	lw	a1,0(s1)
  80068e:	000a2783          	lw	a5,0(s4)
  800692:	0491                	addi	s1,s1,4
  800694:	0015959b          	slliw	a1,a1,0x1
  800698:	02f5c5bb          	divw	a1,a1,a5
  80069c:	8522                	mv	a0,s0
  80069e:	2585                	addiw	a1,a1,1
  8006a0:	01f5d79b          	srliw	a5,a1,0x1f
  8006a4:	9dbd                	addw	a1,a1,a5
  8006a6:	4015d59b          	sraiw	a1,a1,0x1
  8006aa:	9f7ff0ef          	jal	ra,8000a0 <cprintf>
     for (i = 0; i < TOTAL; i ++)
  8006ae:	fd349fe3          	bne	s1,s3,80068c <main+0xd4>
     }
     cprintf("\n");
  8006b2:	00000517          	auipc	a0,0x0
  8006b6:	0de50513          	addi	a0,a0,222 # 800790 <main+0x1d8>
  8006ba:	9e7ff0ef          	jal	ra,8000a0 <cprintf>
          if (pids[i] > 0) {
               kill(pids[i]);
          }
     }
     panic("FAIL: T.T\n");
}
  8006be:	60e6                	ld	ra,88(sp)
  8006c0:	6446                	ld	s0,80(sp)
  8006c2:	64a6                	ld	s1,72(sp)
  8006c4:	6906                	ld	s2,64(sp)
  8006c6:	79e2                	ld	s3,56(sp)
  8006c8:	7a42                	ld	s4,48(sp)
  8006ca:	7aa2                	ld	s5,40(sp)
  8006cc:	7b02                	ld	s6,32(sp)
  8006ce:	6be2                	ld	s7,24(sp)
  8006d0:	4501                	li	a0,0
  8006d2:	6125                	addi	sp,sp,96
  8006d4:	8082                	ret
               lab6_setpriority(i + 1);
  8006d6:	0014051b          	addiw	a0,s0,1
               acc[i] = 0;
  8006da:	040a                	slli	s0,s0,0x2
  8006dc:	9456                	add	s0,s0,s5
                    if(acc[i]%4000==0) {
  8006de:	6485                	lui	s1,0x1
               lab6_setpriority(i + 1);
  8006e0:	a95ff0ef          	jal	ra,800174 <lab6_setpriority>
                    if(acc[i]%4000==0) {
  8006e4:	fa04849b          	addiw	s1,s1,-96
               acc[i] = 0;
  8006e8:	00042023          	sw	zero,0(s0)
                        if((time=gettime_msec())>MAX_TIME) {
  8006ec:	7d000993          	li	s3,2000
  8006f0:	4014                	lw	a3,0(s0)
  8006f2:	2685                	addiw	a3,a3,1
     for (i = 0; i != 200; ++ i)
  8006f4:	0c800713          	li	a4,200
          j = !j;
  8006f8:	47b2                	lw	a5,12(sp)
  8006fa:	377d                	addiw	a4,a4,-1
  8006fc:	2781                	sext.w	a5,a5
  8006fe:	0017b793          	seqz	a5,a5
  800702:	c63e                	sw	a5,12(sp)
     for (i = 0; i != 200; ++ i)
  800704:	fb75                	bnez	a4,8006f8 <main+0x140>
                    if(acc[i]%4000==0) {
  800706:	0296f7bb          	remuw	a5,a3,s1
  80070a:	0016871b          	addiw	a4,a3,1
  80070e:	c399                	beqz	a5,800714 <main+0x15c>
  800710:	86ba                	mv	a3,a4
  800712:	b7cd                	j	8006f4 <main+0x13c>
  800714:	c014                	sw	a3,0(s0)
                        if((time=gettime_msec())>MAX_TIME) {
  800716:	a5bff0ef          	jal	ra,800170 <gettime_msec>
  80071a:	0005091b          	sext.w	s2,a0
  80071e:	fd29d9e3          	ble	s2,s3,8006f0 <main+0x138>
                            cprintf("child pid %d, acc %d, time %d\n",getpid(),acc[i],time);
  800722:	a4bff0ef          	jal	ra,80016c <getpid>
  800726:	4010                	lw	a2,0(s0)
  800728:	85aa                	mv	a1,a0
  80072a:	86ca                	mv	a3,s2
  80072c:	00000517          	auipc	a0,0x0
  800730:	39c50513          	addi	a0,a0,924 # 800ac8 <error_string+0x1c0>
  800734:	96dff0ef          	jal	ra,8000a0 <cprintf>
                            exit(acc[i]);
  800738:	4008                	lw	a0,0(s0)
  80073a:	a11ff0ef          	jal	ra,80014a <exit>
  80073e:	00001417          	auipc	s0,0x1
  800742:	90640413          	addi	s0,s0,-1786 # 801044 <pids+0x14>
          if (pids[i] > 0) {
  800746:	00092503          	lw	a0,0(s2)
  80074a:	00a05463          	blez	a0,800752 <main+0x19a>
               kill(pids[i]);
  80074e:	a1bff0ef          	jal	ra,800168 <kill>
  800752:	0911                	addi	s2,s2,4
     for (i = 0; i < TOTAL; i ++) {
  800754:	ff2419e3          	bne	s0,s2,800746 <main+0x18e>
     panic("FAIL: T.T\n");
  800758:	00000617          	auipc	a2,0x0
  80075c:	41860613          	addi	a2,a2,1048 # 800b70 <error_string+0x268>
  800760:	04b00593          	li	a1,75
  800764:	00000517          	auipc	a0,0x0
  800768:	41c50513          	addi	a0,a0,1052 # 800b80 <error_string+0x278>
  80076c:	8bbff0ef          	jal	ra,800026 <__panic>
