
obj/__user_sleep.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  800020:	144000ef          	jal	ra,800164 <umain>
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
  800038:	60450513          	addi	a0,a0,1540 # 800638 <main+0x74>
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
  800058:	60450513          	addi	a0,a0,1540 # 800658 <main+0x94>
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
  80006e:	0b6000ef          	jal	ra,800124 <sys_putc>
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
  800094:	148000ef          	jal	ra,8001dc <vprintfmt>
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
  8000c8:	114000ef          	jal	ra,8001dc <vprintfmt>
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

0000000000800124 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  800124:	85aa                	mv	a1,a0
  800126:	4579                	li	a0,30
  800128:	fadff06f          	j	8000d4 <syscall>

000000000080012c <sys_gettime>:
    return syscall(SYS_pgdir);
}

int
sys_gettime(void) {
    return syscall(SYS_gettime);
  80012c:	4545                	li	a0,17
  80012e:	fa7ff06f          	j	8000d4 <syscall>

0000000000800132 <sys_sleep>:
    syscall(SYS_lab6_set_priority, priority);
}

int
sys_sleep(uint64_t time) {
    return syscall(SYS_sleep, time);
  800132:	85aa                	mv	a1,a0
  800134:	452d                	li	a0,11
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
  800146:	51e50513          	addi	a0,a0,1310 # 800660 <main+0x9c>
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

0000000000800158 <gettime_msec>:
    sys_pgdir();
}

unsigned int
gettime_msec(void) {
    return (unsigned int)sys_gettime();
  800158:	fd5ff06f          	j	80012c <sys_gettime>

000000000080015c <sleep>:
    sys_lab6_set_priority(priority);
}

int
sleep(unsigned int time) {
    return sys_sleep(time);
  80015c:	1502                	slli	a0,a0,0x20
  80015e:	9101                	srli	a0,a0,0x20
  800160:	fd3ff06f          	j	800132 <sys_sleep>

0000000000800164 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800164:	1141                	addi	sp,sp,-16
  800166:	e406                	sd	ra,8(sp)
    int ret = main();
  800168:	45c000ef          	jal	ra,8005c4 <main>
    exit(ret);
  80016c:	fcfff0ef          	jal	ra,80013a <exit>

0000000000800170 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800170:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800174:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800176:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80017a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80017c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800180:	f022                	sd	s0,32(sp)
  800182:	ec26                	sd	s1,24(sp)
  800184:	e84a                	sd	s2,16(sp)
  800186:	f406                	sd	ra,40(sp)
  800188:	e44e                	sd	s3,8(sp)
  80018a:	84aa                	mv	s1,a0
  80018c:	892e                	mv	s2,a1
  80018e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800192:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800194:	03067e63          	bleu	a6,a2,8001d0 <printnum+0x60>
  800198:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80019a:	00805763          	blez	s0,8001a8 <printnum+0x38>
  80019e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  8001a0:	85ca                	mv	a1,s2
  8001a2:	854e                	mv	a0,s3
  8001a4:	9482                	jalr	s1
        while (-- width > 0)
  8001a6:	fc65                	bnez	s0,80019e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001a8:	1a02                	slli	s4,s4,0x20
  8001aa:	020a5a13          	srli	s4,s4,0x20
  8001ae:	00000797          	auipc	a5,0x0
  8001b2:	6ea78793          	addi	a5,a5,1770 # 800898 <error_string+0xc8>
  8001b6:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001b8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ba:	000a4503          	lbu	a0,0(s4)
}
  8001be:	70a2                	ld	ra,40(sp)
  8001c0:	69a2                	ld	s3,8(sp)
  8001c2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001c4:	85ca                	mv	a1,s2
  8001c6:	8326                	mv	t1,s1
}
  8001c8:	6942                	ld	s2,16(sp)
  8001ca:	64e2                	ld	s1,24(sp)
  8001cc:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001ce:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001d0:	03065633          	divu	a2,a2,a6
  8001d4:	8722                	mv	a4,s0
  8001d6:	f9bff0ef          	jal	ra,800170 <printnum>
  8001da:	b7f9                	j	8001a8 <printnum+0x38>

00000000008001dc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001dc:	7119                	addi	sp,sp,-128
  8001de:	f4a6                	sd	s1,104(sp)
  8001e0:	f0ca                	sd	s2,96(sp)
  8001e2:	e8d2                	sd	s4,80(sp)
  8001e4:	e4d6                	sd	s5,72(sp)
  8001e6:	e0da                	sd	s6,64(sp)
  8001e8:	fc5e                	sd	s7,56(sp)
  8001ea:	f862                	sd	s8,48(sp)
  8001ec:	f06a                	sd	s10,32(sp)
  8001ee:	fc86                	sd	ra,120(sp)
  8001f0:	f8a2                	sd	s0,112(sp)
  8001f2:	ecce                	sd	s3,88(sp)
  8001f4:	f466                	sd	s9,40(sp)
  8001f6:	ec6e                	sd	s11,24(sp)
  8001f8:	892a                	mv	s2,a0
  8001fa:	84ae                	mv	s1,a1
  8001fc:	8d32                	mv	s10,a2
  8001fe:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800200:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800202:	00000a17          	auipc	s4,0x0
  800206:	472a0a13          	addi	s4,s4,1138 # 800674 <main+0xb0>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  80020a:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80020e:	00000c17          	auipc	s8,0x0
  800212:	5c2c0c13          	addi	s8,s8,1474 # 8007d0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800216:	000d4503          	lbu	a0,0(s10)
  80021a:	02500793          	li	a5,37
  80021e:	001d0413          	addi	s0,s10,1
  800222:	00f50e63          	beq	a0,a5,80023e <vprintfmt+0x62>
            if (ch == '\0') {
  800226:	c521                	beqz	a0,80026e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800228:	02500993          	li	s3,37
  80022c:	a011                	j	800230 <vprintfmt+0x54>
            if (ch == '\0') {
  80022e:	c121                	beqz	a0,80026e <vprintfmt+0x92>
            putch(ch, putdat);
  800230:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800232:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800234:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800236:	fff44503          	lbu	a0,-1(s0)
  80023a:	ff351ae3          	bne	a0,s3,80022e <vprintfmt+0x52>
  80023e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800242:	02000793          	li	a5,32
        lflag = altflag = 0;
  800246:	4981                	li	s3,0
  800248:	4801                	li	a6,0
        width = precision = -1;
  80024a:	5cfd                	li	s9,-1
  80024c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  80024e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800252:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800254:	fdd6069b          	addiw	a3,a2,-35
  800258:	0ff6f693          	andi	a3,a3,255
  80025c:	00140d13          	addi	s10,s0,1
  800260:	20d5e563          	bltu	a1,a3,80046a <vprintfmt+0x28e>
  800264:	068a                	slli	a3,a3,0x2
  800266:	96d2                	add	a3,a3,s4
  800268:	4294                	lw	a3,0(a3)
  80026a:	96d2                	add	a3,a3,s4
  80026c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80026e:	70e6                	ld	ra,120(sp)
  800270:	7446                	ld	s0,112(sp)
  800272:	74a6                	ld	s1,104(sp)
  800274:	7906                	ld	s2,96(sp)
  800276:	69e6                	ld	s3,88(sp)
  800278:	6a46                	ld	s4,80(sp)
  80027a:	6aa6                	ld	s5,72(sp)
  80027c:	6b06                	ld	s6,64(sp)
  80027e:	7be2                	ld	s7,56(sp)
  800280:	7c42                	ld	s8,48(sp)
  800282:	7ca2                	ld	s9,40(sp)
  800284:	7d02                	ld	s10,32(sp)
  800286:	6de2                	ld	s11,24(sp)
  800288:	6109                	addi	sp,sp,128
  80028a:	8082                	ret
    if (lflag >= 2) {
  80028c:	4705                	li	a4,1
  80028e:	008a8593          	addi	a1,s5,8
  800292:	01074463          	blt	a4,a6,80029a <vprintfmt+0xbe>
    else if (lflag) {
  800296:	26080363          	beqz	a6,8004fc <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
  80029a:	000ab603          	ld	a2,0(s5)
  80029e:	46c1                	li	a3,16
  8002a0:	8aae                	mv	s5,a1
  8002a2:	a06d                	j	80034c <vprintfmt+0x170>
            goto reswitch;
  8002a4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8002a8:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8002aa:	846a                	mv	s0,s10
            goto reswitch;
  8002ac:	b765                	j	800254 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
  8002ae:	000aa503          	lw	a0,0(s5)
  8002b2:	85a6                	mv	a1,s1
  8002b4:	0aa1                	addi	s5,s5,8
  8002b6:	9902                	jalr	s2
            break;
  8002b8:	bfb9                	j	800216 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002ba:	4705                	li	a4,1
  8002bc:	008a8993          	addi	s3,s5,8
  8002c0:	01074463          	blt	a4,a6,8002c8 <vprintfmt+0xec>
    else if (lflag) {
  8002c4:	22080463          	beqz	a6,8004ec <vprintfmt+0x310>
        return va_arg(*ap, long);
  8002c8:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002cc:	24044463          	bltz	s0,800514 <vprintfmt+0x338>
            num = getint(&ap, lflag);
  8002d0:	8622                	mv	a2,s0
  8002d2:	8ace                	mv	s5,s3
  8002d4:	46a9                	li	a3,10
  8002d6:	a89d                	j	80034c <vprintfmt+0x170>
            err = va_arg(ap, int);
  8002d8:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002dc:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002de:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002e0:	41f7d69b          	sraiw	a3,a5,0x1f
  8002e4:	8fb5                	xor	a5,a5,a3
  8002e6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002ea:	1ad74363          	blt	a4,a3,800490 <vprintfmt+0x2b4>
  8002ee:	00369793          	slli	a5,a3,0x3
  8002f2:	97e2                	add	a5,a5,s8
  8002f4:	639c                	ld	a5,0(a5)
  8002f6:	18078d63          	beqz	a5,800490 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
  8002fa:	86be                	mv	a3,a5
  8002fc:	00000617          	auipc	a2,0x0
  800300:	68c60613          	addi	a2,a2,1676 # 800988 <error_string+0x1b8>
  800304:	85a6                	mv	a1,s1
  800306:	854a                	mv	a0,s2
  800308:	240000ef          	jal	ra,800548 <printfmt>
  80030c:	b729                	j	800216 <vprintfmt+0x3a>
            lflag ++;
  80030e:	00144603          	lbu	a2,1(s0)
  800312:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800314:	846a                	mv	s0,s10
            goto reswitch;
  800316:	bf3d                	j	800254 <vprintfmt+0x78>
    if (lflag >= 2) {
  800318:	4705                	li	a4,1
  80031a:	008a8593          	addi	a1,s5,8
  80031e:	01074463          	blt	a4,a6,800326 <vprintfmt+0x14a>
    else if (lflag) {
  800322:	1e080263          	beqz	a6,800506 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
  800326:	000ab603          	ld	a2,0(s5)
  80032a:	46a1                	li	a3,8
  80032c:	8aae                	mv	s5,a1
  80032e:	a839                	j	80034c <vprintfmt+0x170>
            putch('0', putdat);
  800330:	03000513          	li	a0,48
  800334:	85a6                	mv	a1,s1
  800336:	e03e                	sd	a5,0(sp)
  800338:	9902                	jalr	s2
            putch('x', putdat);
  80033a:	85a6                	mv	a1,s1
  80033c:	07800513          	li	a0,120
  800340:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800342:	0aa1                	addi	s5,s5,8
  800344:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800348:	6782                	ld	a5,0(sp)
  80034a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  80034c:	876e                	mv	a4,s11
  80034e:	85a6                	mv	a1,s1
  800350:	854a                	mv	a0,s2
  800352:	e1fff0ef          	jal	ra,800170 <printnum>
            break;
  800356:	b5c1                	j	800216 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800358:	000ab603          	ld	a2,0(s5)
  80035c:	0aa1                	addi	s5,s5,8
  80035e:	1c060663          	beqz	a2,80052a <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
  800362:	00160413          	addi	s0,a2,1
  800366:	17b05c63          	blez	s11,8004de <vprintfmt+0x302>
  80036a:	02d00593          	li	a1,45
  80036e:	14b79263          	bne	a5,a1,8004b2 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800372:	00064783          	lbu	a5,0(a2)
  800376:	0007851b          	sext.w	a0,a5
  80037a:	c905                	beqz	a0,8003aa <vprintfmt+0x1ce>
  80037c:	000cc563          	bltz	s9,800386 <vprintfmt+0x1aa>
  800380:	3cfd                	addiw	s9,s9,-1
  800382:	036c8263          	beq	s9,s6,8003a6 <vprintfmt+0x1ca>
                    putch('?', putdat);
  800386:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800388:	18098463          	beqz	s3,800510 <vprintfmt+0x334>
  80038c:	3781                	addiw	a5,a5,-32
  80038e:	18fbf163          	bleu	a5,s7,800510 <vprintfmt+0x334>
                    putch('?', putdat);
  800392:	03f00513          	li	a0,63
  800396:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800398:	0405                	addi	s0,s0,1
  80039a:	fff44783          	lbu	a5,-1(s0)
  80039e:	3dfd                	addiw	s11,s11,-1
  8003a0:	0007851b          	sext.w	a0,a5
  8003a4:	fd61                	bnez	a0,80037c <vprintfmt+0x1a0>
            for (; width > 0; width --) {
  8003a6:	e7b058e3          	blez	s11,800216 <vprintfmt+0x3a>
  8003aa:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003ac:	85a6                	mv	a1,s1
  8003ae:	02000513          	li	a0,32
  8003b2:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003b4:	e60d81e3          	beqz	s11,800216 <vprintfmt+0x3a>
  8003b8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003ba:	85a6                	mv	a1,s1
  8003bc:	02000513          	li	a0,32
  8003c0:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003c2:	fe0d94e3          	bnez	s11,8003aa <vprintfmt+0x1ce>
  8003c6:	bd81                	j	800216 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003c8:	4705                	li	a4,1
  8003ca:	008a8593          	addi	a1,s5,8
  8003ce:	01074463          	blt	a4,a6,8003d6 <vprintfmt+0x1fa>
    else if (lflag) {
  8003d2:	12080063          	beqz	a6,8004f2 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
  8003d6:	000ab603          	ld	a2,0(s5)
  8003da:	46a9                	li	a3,10
  8003dc:	8aae                	mv	s5,a1
  8003de:	b7bd                	j	80034c <vprintfmt+0x170>
  8003e0:	00144603          	lbu	a2,1(s0)
            padc = '-';
  8003e4:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
  8003e8:	846a                	mv	s0,s10
  8003ea:	b5ad                	j	800254 <vprintfmt+0x78>
            putch(ch, putdat);
  8003ec:	85a6                	mv	a1,s1
  8003ee:	02500513          	li	a0,37
  8003f2:	9902                	jalr	s2
            break;
  8003f4:	b50d                	j	800216 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
  8003f6:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  8003fa:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8003fe:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800400:	846a                	mv	s0,s10
            if (width < 0)
  800402:	e40dd9e3          	bgez	s11,800254 <vprintfmt+0x78>
                width = precision, precision = -1;
  800406:	8de6                	mv	s11,s9
  800408:	5cfd                	li	s9,-1
  80040a:	b5a9                	j	800254 <vprintfmt+0x78>
            goto reswitch;
  80040c:	00144603          	lbu	a2,1(s0)
            padc = '0';
  800410:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
  800414:	846a                	mv	s0,s10
            goto reswitch;
  800416:	bd3d                	j	800254 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
  800418:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  80041c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800420:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800422:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800426:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80042a:	fcd56ce3          	bltu	a0,a3,800402 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
  80042e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800430:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800434:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800438:	0196873b          	addw	a4,a3,s9
  80043c:	0017171b          	slliw	a4,a4,0x1
  800440:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800444:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800448:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80044c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800450:	fcd57fe3          	bleu	a3,a0,80042e <vprintfmt+0x252>
  800454:	b77d                	j	800402 <vprintfmt+0x226>
            if (width < 0)
  800456:	fffdc693          	not	a3,s11
  80045a:	96fd                	srai	a3,a3,0x3f
  80045c:	00ddfdb3          	and	s11,s11,a3
  800460:	00144603          	lbu	a2,1(s0)
  800464:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800466:	846a                	mv	s0,s10
  800468:	b3f5                	j	800254 <vprintfmt+0x78>
            putch('%', putdat);
  80046a:	85a6                	mv	a1,s1
  80046c:	02500513          	li	a0,37
  800470:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800472:	fff44703          	lbu	a4,-1(s0)
  800476:	02500793          	li	a5,37
  80047a:	8d22                	mv	s10,s0
  80047c:	d8f70de3          	beq	a4,a5,800216 <vprintfmt+0x3a>
  800480:	02500713          	li	a4,37
  800484:	1d7d                	addi	s10,s10,-1
  800486:	fffd4783          	lbu	a5,-1(s10)
  80048a:	fee79de3          	bne	a5,a4,800484 <vprintfmt+0x2a8>
  80048e:	b361                	j	800216 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800490:	00000617          	auipc	a2,0x0
  800494:	4e860613          	addi	a2,a2,1256 # 800978 <error_string+0x1a8>
  800498:	85a6                	mv	a1,s1
  80049a:	854a                	mv	a0,s2
  80049c:	0ac000ef          	jal	ra,800548 <printfmt>
  8004a0:	bb9d                	j	800216 <vprintfmt+0x3a>
                p = "(null)";
  8004a2:	00000617          	auipc	a2,0x0
  8004a6:	4ce60613          	addi	a2,a2,1230 # 800970 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  8004aa:	00000417          	auipc	s0,0x0
  8004ae:	4c740413          	addi	s0,s0,1223 # 800971 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b2:	8532                	mv	a0,a2
  8004b4:	85e6                	mv	a1,s9
  8004b6:	e032                	sd	a2,0(sp)
  8004b8:	e43e                	sd	a5,8(sp)
  8004ba:	0ae000ef          	jal	ra,800568 <strnlen>
  8004be:	40ad8dbb          	subw	s11,s11,a0
  8004c2:	6602                	ld	a2,0(sp)
  8004c4:	01b05d63          	blez	s11,8004de <vprintfmt+0x302>
  8004c8:	67a2                	ld	a5,8(sp)
  8004ca:	2781                	sext.w	a5,a5
  8004cc:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004ce:	6522                	ld	a0,8(sp)
  8004d0:	85a6                	mv	a1,s1
  8004d2:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d4:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004d6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d8:	6602                	ld	a2,0(sp)
  8004da:	fe0d9ae3          	bnez	s11,8004ce <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004de:	00064783          	lbu	a5,0(a2)
  8004e2:	0007851b          	sext.w	a0,a5
  8004e6:	e8051be3          	bnez	a0,80037c <vprintfmt+0x1a0>
  8004ea:	b335                	j	800216 <vprintfmt+0x3a>
        return va_arg(*ap, int);
  8004ec:	000aa403          	lw	s0,0(s5)
  8004f0:	bbf1                	j	8002cc <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
  8004f2:	000ae603          	lwu	a2,0(s5)
  8004f6:	46a9                	li	a3,10
  8004f8:	8aae                	mv	s5,a1
  8004fa:	bd89                	j	80034c <vprintfmt+0x170>
  8004fc:	000ae603          	lwu	a2,0(s5)
  800500:	46c1                	li	a3,16
  800502:	8aae                	mv	s5,a1
  800504:	b5a1                	j	80034c <vprintfmt+0x170>
  800506:	000ae603          	lwu	a2,0(s5)
  80050a:	46a1                	li	a3,8
  80050c:	8aae                	mv	s5,a1
  80050e:	bd3d                	j	80034c <vprintfmt+0x170>
                    putch(ch, putdat);
  800510:	9902                	jalr	s2
  800512:	b559                	j	800398 <vprintfmt+0x1bc>
                putch('-', putdat);
  800514:	85a6                	mv	a1,s1
  800516:	02d00513          	li	a0,45
  80051a:	e03e                	sd	a5,0(sp)
  80051c:	9902                	jalr	s2
                num = -(long long)num;
  80051e:	8ace                	mv	s5,s3
  800520:	40800633          	neg	a2,s0
  800524:	46a9                	li	a3,10
  800526:	6782                	ld	a5,0(sp)
  800528:	b515                	j	80034c <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
  80052a:	01b05663          	blez	s11,800536 <vprintfmt+0x35a>
  80052e:	02d00693          	li	a3,45
  800532:	f6d798e3          	bne	a5,a3,8004a2 <vprintfmt+0x2c6>
  800536:	00000417          	auipc	s0,0x0
  80053a:	43b40413          	addi	s0,s0,1083 # 800971 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80053e:	02800513          	li	a0,40
  800542:	02800793          	li	a5,40
  800546:	bd1d                	j	80037c <vprintfmt+0x1a0>

0000000000800548 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800548:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80054a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80054e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800550:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800552:	ec06                	sd	ra,24(sp)
  800554:	f83a                	sd	a4,48(sp)
  800556:	fc3e                	sd	a5,56(sp)
  800558:	e0c2                	sd	a6,64(sp)
  80055a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80055c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80055e:	c7fff0ef          	jal	ra,8001dc <vprintfmt>
}
  800562:	60e2                	ld	ra,24(sp)
  800564:	6161                	addi	sp,sp,80
  800566:	8082                	ret

0000000000800568 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800568:	c185                	beqz	a1,800588 <strnlen+0x20>
  80056a:	00054783          	lbu	a5,0(a0)
  80056e:	cf89                	beqz	a5,800588 <strnlen+0x20>
    size_t cnt = 0;
  800570:	4781                	li	a5,0
  800572:	a021                	j	80057a <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800574:	00074703          	lbu	a4,0(a4)
  800578:	c711                	beqz	a4,800584 <strnlen+0x1c>
        cnt ++;
  80057a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80057c:	00f50733          	add	a4,a0,a5
  800580:	fef59ae3          	bne	a1,a5,800574 <strnlen+0xc>
    }
    return cnt;
}
  800584:	853e                	mv	a0,a5
  800586:	8082                	ret
    size_t cnt = 0;
  800588:	4781                	li	a5,0
}
  80058a:	853e                	mv	a0,a5
  80058c:	8082                	ret

000000000080058e <sleepy>:
#include <stdio.h>
#include <ulib.h>

void
sleepy(int pid) {
  80058e:	1101                	addi	sp,sp,-32
  800590:	e822                	sd	s0,16(sp)
  800592:	e426                	sd	s1,8(sp)
  800594:	e04a                	sd	s2,0(sp)
  800596:	ec06                	sd	ra,24(sp)
    int i, time = 100;
    for (i = 0; i < 10; i ++) {
  800598:	4401                	li	s0,0
        sleep(time);
        cprintf("sleep %d x %d slices.\n", i + 1, time);
  80059a:	00000917          	auipc	s2,0x0
  80059e:	47e90913          	addi	s2,s2,1150 # 800a18 <error_string+0x248>
    for (i = 0; i < 10; i ++) {
  8005a2:	44a9                	li	s1,10
        sleep(time);
  8005a4:	06400513          	li	a0,100
  8005a8:	bb5ff0ef          	jal	ra,80015c <sleep>
        cprintf("sleep %d x %d slices.\n", i + 1, time);
  8005ac:	2405                	addiw	s0,s0,1
  8005ae:	06400613          	li	a2,100
  8005b2:	85a2                	mv	a1,s0
  8005b4:	854a                	mv	a0,s2
  8005b6:	aebff0ef          	jal	ra,8000a0 <cprintf>
    for (i = 0; i < 10; i ++) {
  8005ba:	fe9415e3          	bne	s0,s1,8005a4 <sleepy+0x16>
    }
    exit(0);
  8005be:	4501                	li	a0,0
  8005c0:	b7bff0ef          	jal	ra,80013a <exit>

00000000008005c4 <main>:
}

int
main(void) {
  8005c4:	1101                	addi	sp,sp,-32
  8005c6:	e822                	sd	s0,16(sp)
  8005c8:	ec06                	sd	ra,24(sp)
    unsigned int time = gettime_msec();
  8005ca:	b8fff0ef          	jal	ra,800158 <gettime_msec>
  8005ce:	0005041b          	sext.w	s0,a0
    int pid1, exit_code;

    if ((pid1 = fork()) == 0) {
  8005d2:	b7fff0ef          	jal	ra,800150 <fork>
  8005d6:	cd21                	beqz	a0,80062e <main+0x6a>
        sleepy(pid1);
    }
    
    assert(waitpid(pid1, &exit_code) == 0 && exit_code == 0);
  8005d8:	006c                	addi	a1,sp,12
  8005da:	b7bff0ef          	jal	ra,800154 <waitpid>
  8005de:	47b2                	lw	a5,12(sp)
  8005e0:	8d5d                	or	a0,a0,a5
  8005e2:	2501                	sext.w	a0,a0
  8005e4:	e515                	bnez	a0,800610 <main+0x4c>
    cprintf("use %04d msecs.\n", gettime_msec() - time);
  8005e6:	b73ff0ef          	jal	ra,800158 <gettime_msec>
  8005ea:	408505bb          	subw	a1,a0,s0
  8005ee:	00000517          	auipc	a0,0x0
  8005f2:	40250513          	addi	a0,a0,1026 # 8009f0 <error_string+0x220>
  8005f6:	aabff0ef          	jal	ra,8000a0 <cprintf>
    cprintf("sleep pass.\n");
  8005fa:	00000517          	auipc	a0,0x0
  8005fe:	40e50513          	addi	a0,a0,1038 # 800a08 <error_string+0x238>
  800602:	a9fff0ef          	jal	ra,8000a0 <cprintf>
    return 0;
}
  800606:	60e2                	ld	ra,24(sp)
  800608:	6442                	ld	s0,16(sp)
  80060a:	4501                	li	a0,0
  80060c:	6105                	addi	sp,sp,32
  80060e:	8082                	ret
    assert(waitpid(pid1, &exit_code) == 0 && exit_code == 0);
  800610:	00000697          	auipc	a3,0x0
  800614:	38068693          	addi	a3,a3,896 # 800990 <error_string+0x1c0>
  800618:	00000617          	auipc	a2,0x0
  80061c:	3b060613          	addi	a2,a2,944 # 8009c8 <error_string+0x1f8>
  800620:	45dd                	li	a1,23
  800622:	00000517          	auipc	a0,0x0
  800626:	3be50513          	addi	a0,a0,958 # 8009e0 <error_string+0x210>
  80062a:	9fdff0ef          	jal	ra,800026 <__panic>
        sleepy(pid1);
  80062e:	f61ff0ef          	jal	ra,80058e <sleepy>
