
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	00450513          	addi	a0,a0,4 # 80204010 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	01460613          	addi	a2,a2,20 # 80204028 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	249000ef          	jal	ra,80200a6c <memset>

    cons_init();  // init the console
    80200028:	152000ef          	jal	ra,8020017a <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	a5458593          	addi	a1,a1,-1452 # 80200a80 <etext+0x2>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	a6c50513          	addi	a0,a0,-1428 # 80200aa0 <etext+0x22>
    8020003c:	036000ef          	jal	ra,80200072 <cprintf>

    print_kerninfo();
    80200040:	066000ef          	jal	ra,802000a6 <print_kerninfo>

    // grade_backtrace();
    
    idt_init();  // init interrupt descriptor table
    80200044:	146000ef          	jal	ra,8020018a <idt_init>
    
    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200048:	0ee000ef          	jal	ra,80200136 <clock_init>
    
    intr_enable();  // enable irq interrupt
    8020004c:	138000ef          	jal	ra,80200184 <intr_enable>
    asm("mret");
    80200050:	30200073          	mret
    asm("ebreak");
    80200054:	9002                	ebreak
    while (1)
        ;
    80200056:	a001                	j	80200056 <kern_init+0x4a>

0000000080200058 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200058:	1141                	addi	sp,sp,-16
    8020005a:	e022                	sd	s0,0(sp)
    8020005c:	e406                	sd	ra,8(sp)
    8020005e:	842e                	mv	s0,a1
    cons_putc(c);
    80200060:	11c000ef          	jal	ra,8020017c <cons_putc>
    (*cnt)++;
    80200064:	401c                	lw	a5,0(s0)
}
    80200066:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200068:	2785                	addiw	a5,a5,1
    8020006a:	c01c                	sw	a5,0(s0)
}
    8020006c:	6402                	ld	s0,0(sp)
    8020006e:	0141                	addi	sp,sp,16
    80200070:	8082                	ret

0000000080200072 <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    80200072:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    80200074:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200078:	f42e                	sd	a1,40(sp)
    8020007a:	f832                	sd	a2,48(sp)
    8020007c:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020007e:	862a                	mv	a2,a0
    80200080:	004c                	addi	a1,sp,4
    80200082:	00000517          	auipc	a0,0x0
    80200086:	fd650513          	addi	a0,a0,-42 # 80200058 <cputch>
    8020008a:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    8020008c:	ec06                	sd	ra,24(sp)
    8020008e:	e0ba                	sd	a4,64(sp)
    80200090:	e4be                	sd	a5,72(sp)
    80200092:	e8c2                	sd	a6,80(sp)
    80200094:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200096:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200098:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020009a:	5cc000ef          	jal	ra,80200666 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    8020009e:	60e2                	ld	ra,24(sp)
    802000a0:	4512                	lw	a0,4(sp)
    802000a2:	6125                	addi	sp,sp,96
    802000a4:	8082                	ret

00000000802000a6 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a6:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a8:	00001517          	auipc	a0,0x1
    802000ac:	a0050513          	addi	a0,a0,-1536 # 80200aa8 <etext+0x2a>
void print_kerninfo(void) {
    802000b0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000b2:	fc1ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b6:	00000597          	auipc	a1,0x0
    802000ba:	f5658593          	addi	a1,a1,-170 # 8020000c <kern_init>
    802000be:	00001517          	auipc	a0,0x1
    802000c2:	a0a50513          	addi	a0,a0,-1526 # 80200ac8 <etext+0x4a>
    802000c6:	fadff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000ca:	00001597          	auipc	a1,0x1
    802000ce:	9b458593          	addi	a1,a1,-1612 # 80200a7e <etext>
    802000d2:	00001517          	auipc	a0,0x1
    802000d6:	a1650513          	addi	a0,a0,-1514 # 80200ae8 <etext+0x6a>
    802000da:	f99ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000de:	00004597          	auipc	a1,0x4
    802000e2:	f3258593          	addi	a1,a1,-206 # 80204010 <edata>
    802000e6:	00001517          	auipc	a0,0x1
    802000ea:	a2250513          	addi	a0,a0,-1502 # 80200b08 <etext+0x8a>
    802000ee:	f85ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000f2:	00004597          	auipc	a1,0x4
    802000f6:	f3658593          	addi	a1,a1,-202 # 80204028 <end>
    802000fa:	00001517          	auipc	a0,0x1
    802000fe:	a2e50513          	addi	a0,a0,-1490 # 80200b28 <etext+0xaa>
    80200102:	f71ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200106:	00004597          	auipc	a1,0x4
    8020010a:	32158593          	addi	a1,a1,801 # 80204427 <end+0x3ff>
    8020010e:	00000797          	auipc	a5,0x0
    80200112:	efe78793          	addi	a5,a5,-258 # 8020000c <kern_init>
    80200116:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	43f7d593          	srai	a1,a5,0x3f
}
    8020011e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200120:	3ff5f593          	andi	a1,a1,1023
    80200124:	95be                	add	a1,a1,a5
    80200126:	85a9                	srai	a1,a1,0xa
    80200128:	00001517          	auipc	a0,0x1
    8020012c:	a2050513          	addi	a0,a0,-1504 # 80200b48 <etext+0xca>
}
    80200130:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200132:	f41ff06f          	j	80200072 <cprintf>

0000000080200136 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200136:	1141                	addi	sp,sp,-16
    80200138:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    8020013a:	02000793          	li	a5,32
    8020013e:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200142:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200146:	67e1                	lui	a5,0x18
    80200148:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    8020014c:	953e                	add	a0,a0,a5
    8020014e:	0c1000ef          	jal	ra,80200a0e <sbi_set_timer>
}
    80200152:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200154:	00004797          	auipc	a5,0x4
    80200158:	ec07b623          	sd	zero,-308(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    8020015c:	00001517          	auipc	a0,0x1
    80200160:	a1c50513          	addi	a0,a0,-1508 # 80200b78 <etext+0xfa>
}
    80200164:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200166:	f0dff06f          	j	80200072 <cprintf>

000000008020016a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020016a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020016e:	67e1                	lui	a5,0x18
    80200170:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200174:	953e                	add	a0,a0,a5
    80200176:	0990006f          	j	80200a0e <sbi_set_timer>

000000008020017a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    8020017a:	8082                	ret

000000008020017c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8020017c:	0ff57513          	andi	a0,a0,255
    80200180:	0730006f          	j	802009f2 <sbi_console_putchar>

0000000080200184 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200184:	100167f3          	csrrsi	a5,sstatus,2
    80200188:	8082                	ret

000000008020018a <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    8020018a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    8020018e:	00000797          	auipc	a5,0x0
    80200192:	3b678793          	addi	a5,a5,950 # 80200544 <__alltraps>
    80200196:	10579073          	csrw	stvec,a5
}
    8020019a:	8082                	ret

000000008020019c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    8020019e:	1141                	addi	sp,sp,-16
    802001a0:	e022                	sd	s0,0(sp)
    802001a2:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a4:	00001517          	auipc	a0,0x1
    802001a8:	b6450513          	addi	a0,a0,-1180 # 80200d08 <etext+0x28a>
void print_regs(struct pushregs *gpr) {
    802001ac:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001ae:	ec5ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001b2:	640c                	ld	a1,8(s0)
    802001b4:	00001517          	auipc	a0,0x1
    802001b8:	b6c50513          	addi	a0,a0,-1172 # 80200d20 <etext+0x2a2>
    802001bc:	eb7ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001c0:	680c                	ld	a1,16(s0)
    802001c2:	00001517          	auipc	a0,0x1
    802001c6:	b7650513          	addi	a0,a0,-1162 # 80200d38 <etext+0x2ba>
    802001ca:	ea9ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001ce:	6c0c                	ld	a1,24(s0)
    802001d0:	00001517          	auipc	a0,0x1
    802001d4:	b8050513          	addi	a0,a0,-1152 # 80200d50 <etext+0x2d2>
    802001d8:	e9bff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001dc:	700c                	ld	a1,32(s0)
    802001de:	00001517          	auipc	a0,0x1
    802001e2:	b8a50513          	addi	a0,a0,-1142 # 80200d68 <etext+0x2ea>
    802001e6:	e8dff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001ea:	740c                	ld	a1,40(s0)
    802001ec:	00001517          	auipc	a0,0x1
    802001f0:	b9450513          	addi	a0,a0,-1132 # 80200d80 <etext+0x302>
    802001f4:	e7fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f8:	780c                	ld	a1,48(s0)
    802001fa:	00001517          	auipc	a0,0x1
    802001fe:	b9e50513          	addi	a0,a0,-1122 # 80200d98 <etext+0x31a>
    80200202:	e71ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200206:	7c0c                	ld	a1,56(s0)
    80200208:	00001517          	auipc	a0,0x1
    8020020c:	ba850513          	addi	a0,a0,-1112 # 80200db0 <etext+0x332>
    80200210:	e63ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200214:	602c                	ld	a1,64(s0)
    80200216:	00001517          	auipc	a0,0x1
    8020021a:	bb250513          	addi	a0,a0,-1102 # 80200dc8 <etext+0x34a>
    8020021e:	e55ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200222:	642c                	ld	a1,72(s0)
    80200224:	00001517          	auipc	a0,0x1
    80200228:	bbc50513          	addi	a0,a0,-1092 # 80200de0 <etext+0x362>
    8020022c:	e47ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200230:	682c                	ld	a1,80(s0)
    80200232:	00001517          	auipc	a0,0x1
    80200236:	bc650513          	addi	a0,a0,-1082 # 80200df8 <etext+0x37a>
    8020023a:	e39ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    8020023e:	6c2c                	ld	a1,88(s0)
    80200240:	00001517          	auipc	a0,0x1
    80200244:	bd050513          	addi	a0,a0,-1072 # 80200e10 <etext+0x392>
    80200248:	e2bff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    8020024c:	702c                	ld	a1,96(s0)
    8020024e:	00001517          	auipc	a0,0x1
    80200252:	bda50513          	addi	a0,a0,-1062 # 80200e28 <etext+0x3aa>
    80200256:	e1dff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    8020025a:	742c                	ld	a1,104(s0)
    8020025c:	00001517          	auipc	a0,0x1
    80200260:	be450513          	addi	a0,a0,-1052 # 80200e40 <etext+0x3c2>
    80200264:	e0fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200268:	782c                	ld	a1,112(s0)
    8020026a:	00001517          	auipc	a0,0x1
    8020026e:	bee50513          	addi	a0,a0,-1042 # 80200e58 <etext+0x3da>
    80200272:	e01ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200276:	7c2c                	ld	a1,120(s0)
    80200278:	00001517          	auipc	a0,0x1
    8020027c:	bf850513          	addi	a0,a0,-1032 # 80200e70 <etext+0x3f2>
    80200280:	df3ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200284:	604c                	ld	a1,128(s0)
    80200286:	00001517          	auipc	a0,0x1
    8020028a:	c0250513          	addi	a0,a0,-1022 # 80200e88 <etext+0x40a>
    8020028e:	de5ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200292:	644c                	ld	a1,136(s0)
    80200294:	00001517          	auipc	a0,0x1
    80200298:	c0c50513          	addi	a0,a0,-1012 # 80200ea0 <etext+0x422>
    8020029c:	dd7ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    802002a0:	684c                	ld	a1,144(s0)
    802002a2:	00001517          	auipc	a0,0x1
    802002a6:	c1650513          	addi	a0,a0,-1002 # 80200eb8 <etext+0x43a>
    802002aa:	dc9ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002ae:	6c4c                	ld	a1,152(s0)
    802002b0:	00001517          	auipc	a0,0x1
    802002b4:	c2050513          	addi	a0,a0,-992 # 80200ed0 <etext+0x452>
    802002b8:	dbbff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002bc:	704c                	ld	a1,160(s0)
    802002be:	00001517          	auipc	a0,0x1
    802002c2:	c2a50513          	addi	a0,a0,-982 # 80200ee8 <etext+0x46a>
    802002c6:	dadff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002ca:	744c                	ld	a1,168(s0)
    802002cc:	00001517          	auipc	a0,0x1
    802002d0:	c3450513          	addi	a0,a0,-972 # 80200f00 <etext+0x482>
    802002d4:	d9fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d8:	784c                	ld	a1,176(s0)
    802002da:	00001517          	auipc	a0,0x1
    802002de:	c3e50513          	addi	a0,a0,-962 # 80200f18 <etext+0x49a>
    802002e2:	d91ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e6:	7c4c                	ld	a1,184(s0)
    802002e8:	00001517          	auipc	a0,0x1
    802002ec:	c4850513          	addi	a0,a0,-952 # 80200f30 <etext+0x4b2>
    802002f0:	d83ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002f4:	606c                	ld	a1,192(s0)
    802002f6:	00001517          	auipc	a0,0x1
    802002fa:	c5250513          	addi	a0,a0,-942 # 80200f48 <etext+0x4ca>
    802002fe:	d75ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    80200302:	646c                	ld	a1,200(s0)
    80200304:	00001517          	auipc	a0,0x1
    80200308:	c5c50513          	addi	a0,a0,-932 # 80200f60 <etext+0x4e2>
    8020030c:	d67ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200310:	686c                	ld	a1,208(s0)
    80200312:	00001517          	auipc	a0,0x1
    80200316:	c6650513          	addi	a0,a0,-922 # 80200f78 <etext+0x4fa>
    8020031a:	d59ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020031e:	6c6c                	ld	a1,216(s0)
    80200320:	00001517          	auipc	a0,0x1
    80200324:	c7050513          	addi	a0,a0,-912 # 80200f90 <etext+0x512>
    80200328:	d4bff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    8020032c:	706c                	ld	a1,224(s0)
    8020032e:	00001517          	auipc	a0,0x1
    80200332:	c7a50513          	addi	a0,a0,-902 # 80200fa8 <etext+0x52a>
    80200336:	d3dff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    8020033a:	746c                	ld	a1,232(s0)
    8020033c:	00001517          	auipc	a0,0x1
    80200340:	c8450513          	addi	a0,a0,-892 # 80200fc0 <etext+0x542>
    80200344:	d2fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200348:	786c                	ld	a1,240(s0)
    8020034a:	00001517          	auipc	a0,0x1
    8020034e:	c8e50513          	addi	a0,a0,-882 # 80200fd8 <etext+0x55a>
    80200352:	d21ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200356:	7c6c                	ld	a1,248(s0)
}
    80200358:	6402                	ld	s0,0(sp)
    8020035a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035c:	00001517          	auipc	a0,0x1
    80200360:	c9450513          	addi	a0,a0,-876 # 80200ff0 <etext+0x572>
}
    80200364:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200366:	d0dff06f          	j	80200072 <cprintf>

000000008020036a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020036a:	1141                	addi	sp,sp,-16
    8020036c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    8020036e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200370:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200372:	00001517          	auipc	a0,0x1
    80200376:	c9650513          	addi	a0,a0,-874 # 80201008 <etext+0x58a>
void print_trapframe(struct trapframe *tf) {
    8020037a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    8020037c:	cf7ff0ef          	jal	ra,80200072 <cprintf>
    print_regs(&tf->gpr);
    80200380:	8522                	mv	a0,s0
    80200382:	e1bff0ef          	jal	ra,8020019c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200386:	10043583          	ld	a1,256(s0)
    8020038a:	00001517          	auipc	a0,0x1
    8020038e:	c9650513          	addi	a0,a0,-874 # 80201020 <etext+0x5a2>
    80200392:	ce1ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200396:	10843583          	ld	a1,264(s0)
    8020039a:	00001517          	auipc	a0,0x1
    8020039e:	c9e50513          	addi	a0,a0,-866 # 80201038 <etext+0x5ba>
    802003a2:	cd1ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a6:	11043583          	ld	a1,272(s0)
    802003aa:	00001517          	auipc	a0,0x1
    802003ae:	ca650513          	addi	a0,a0,-858 # 80201050 <etext+0x5d2>
    802003b2:	cc1ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b6:	11843583          	ld	a1,280(s0)
}
    802003ba:	6402                	ld	s0,0(sp)
    802003bc:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003be:	00001517          	auipc	a0,0x1
    802003c2:	caa50513          	addi	a0,a0,-854 # 80201068 <etext+0x5ea>
}
    802003c6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c8:	cabff06f          	j	80200072 <cprintf>

00000000802003cc <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003cc:	11853783          	ld	a5,280(a0)
    802003d0:	577d                	li	a4,-1
    802003d2:	8305                	srli	a4,a4,0x1
    802003d4:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003d6:	472d                	li	a4,11
    802003d8:	08f76963          	bltu	a4,a5,8020046a <interrupt_handler+0x9e>
    802003dc:	00000717          	auipc	a4,0x0
    802003e0:	7b870713          	addi	a4,a4,1976 # 80200b94 <etext+0x116>
    802003e4:	078a                	slli	a5,a5,0x2
    802003e6:	97ba                	add	a5,a5,a4
    802003e8:	439c                	lw	a5,0(a5)
    802003ea:	97ba                	add	a5,a5,a4
    802003ec:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003ee:	00001517          	auipc	a0,0x1
    802003f2:	8ca50513          	addi	a0,a0,-1846 # 80200cb8 <etext+0x23a>
    802003f6:	c7dff06f          	j	80200072 <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003fa:	00001517          	auipc	a0,0x1
    802003fe:	89e50513          	addi	a0,a0,-1890 # 80200c98 <etext+0x21a>
    80200402:	c71ff06f          	j	80200072 <cprintf>
            cprintf("User software interrupt\n");
    80200406:	00001517          	auipc	a0,0x1
    8020040a:	85250513          	addi	a0,a0,-1966 # 80200c58 <etext+0x1da>
    8020040e:	c65ff06f          	j	80200072 <cprintf>
            cprintf("Supervisor software interrupt\n");
    80200412:	00001517          	auipc	a0,0x1
    80200416:	86650513          	addi	a0,a0,-1946 # 80200c78 <etext+0x1fa>
    8020041a:	c59ff06f          	j	80200072 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    8020041e:	00001517          	auipc	a0,0x1
    80200422:	8ca50513          	addi	a0,a0,-1846 # 80200ce8 <etext+0x26a>
    80200426:	c4dff06f          	j	80200072 <cprintf>
void interrupt_handler(struct trapframe *tf) {
    8020042a:	1141                	addi	sp,sp,-16
    8020042c:	e022                	sd	s0,0(sp)
    8020042e:	e406                	sd	ra,8(sp)
            clock_set_next_event();
    80200430:	d3bff0ef          	jal	ra,8020016a <clock_set_next_event>
            ticks++;
    80200434:	00004717          	auipc	a4,0x4
    80200438:	bec70713          	addi	a4,a4,-1044 # 80204020 <ticks>
    8020043c:	631c                	ld	a5,0(a4)
            if(ticks == 100)
    8020043e:	06400693          	li	a3,100
    80200442:	00004417          	auipc	s0,0x4
    80200446:	bce40413          	addi	s0,s0,-1074 # 80204010 <edata>
            ticks++;
    8020044a:	0785                	addi	a5,a5,1
    8020044c:	00004617          	auipc	a2,0x4
    80200450:	bcf63a23          	sd	a5,-1068(a2) # 80204020 <ticks>
            if(ticks == 100)
    80200454:	631c                	ld	a5,0(a4)
    80200456:	00d78c63          	beq	a5,a3,8020046e <interrupt_handler+0xa2>
            if(num == 10)
    8020045a:	6018                	ld	a4,0(s0)
    8020045c:	47a9                	li	a5,10
    8020045e:	02f70b63          	beq	a4,a5,80200494 <interrupt_handler+0xc8>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200462:	60a2                	ld	ra,8(sp)
    80200464:	6402                	ld	s0,0(sp)
    80200466:	0141                	addi	sp,sp,16
    80200468:	8082                	ret
            print_trapframe(tf);
    8020046a:	f01ff06f          	j	8020036a <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020046e:	06400593          	li	a1,100
    80200472:	00001517          	auipc	a0,0x1
    80200476:	86650513          	addi	a0,a0,-1946 # 80200cd8 <etext+0x25a>
    8020047a:	bf9ff0ef          	jal	ra,80200072 <cprintf>
                ticks = 0;
    8020047e:	00004797          	auipc	a5,0x4
    80200482:	ba07b123          	sd	zero,-1118(a5) # 80204020 <ticks>
                num++;
    80200486:	601c                	ld	a5,0(s0)
    80200488:	0785                	addi	a5,a5,1
    8020048a:	00004717          	auipc	a4,0x4
    8020048e:	b8f73323          	sd	a5,-1146(a4) # 80204010 <edata>
    80200492:	b7e1                	j	8020045a <interrupt_handler+0x8e>
}
    80200494:	6402                	ld	s0,0(sp)
    80200496:	60a2                	ld	ra,8(sp)
    80200498:	0141                	addi	sp,sp,16
                sbi_shutdown();
    8020049a:	5900006f          	j	80200a2a <sbi_shutdown>

000000008020049e <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020049e:	11853783          	ld	a5,280(a0)
    802004a2:	472d                	li	a4,11
    802004a4:	02f76863          	bltu	a4,a5,802004d4 <exception_handler+0x36>
    802004a8:	4705                	li	a4,1
    802004aa:	00f71733          	sll	a4,a4,a5
    802004ae:	6785                	lui	a5,0x1
    802004b0:	17cd                	addi	a5,a5,-13
    802004b2:	8ff9                	and	a5,a5,a4
    802004b4:	ef99                	bnez	a5,802004d2 <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    802004b6:	1141                	addi	sp,sp,-16
    802004b8:	e022                	sd	s0,0(sp)
    802004ba:	e406                	sd	ra,8(sp)
    802004bc:	00877793          	andi	a5,a4,8
    802004c0:	842a                	mv	s0,a0
    802004c2:	e3b1                	bnez	a5,80200506 <exception_handler+0x68>
    802004c4:	8b11                	andi	a4,a4,4
    802004c6:	eb09                	bnez	a4,802004d8 <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004c8:	6402                	ld	s0,0(sp)
    802004ca:	60a2                	ld	ra,8(sp)
    802004cc:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004ce:	e9dff06f          	j	8020036a <print_trapframe>
    802004d2:	8082                	ret
    802004d4:	e97ff06f          	j	8020036a <print_trapframe>
            cprintf("Exception type:Illegal instruction\n");
    802004d8:	00000517          	auipc	a0,0x0
    802004dc:	6f050513          	addi	a0,a0,1776 # 80200bc8 <etext+0x14a>
    802004e0:	b93ff0ef          	jal	ra,80200072 <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
    802004e4:	10843583          	ld	a1,264(s0)
    802004e8:	00000517          	auipc	a0,0x0
    802004ec:	70850513          	addi	a0,a0,1800 # 80200bf0 <etext+0x172>
    802004f0:	b83ff0ef          	jal	ra,80200072 <cprintf>
            tf->epc += 4; 
    802004f4:	10843783          	ld	a5,264(s0)
}
    802004f8:	60a2                	ld	ra,8(sp)
            tf->epc += 4; 
    802004fa:	0791                	addi	a5,a5,4
    802004fc:	10f43423          	sd	a5,264(s0)
}
    80200500:	6402                	ld	s0,0(sp)
    80200502:	0141                	addi	sp,sp,16
    80200504:	8082                	ret
            cprintf("Exception type: breakpoint\n");
    80200506:	00000517          	auipc	a0,0x0
    8020050a:	71250513          	addi	a0,a0,1810 # 80200c18 <etext+0x19a>
    8020050e:	b65ff0ef          	jal	ra,80200072 <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
    80200512:	10843583          	ld	a1,264(s0)
    80200516:	00000517          	auipc	a0,0x0
    8020051a:	72250513          	addi	a0,a0,1826 # 80200c38 <etext+0x1ba>
    8020051e:	b55ff0ef          	jal	ra,80200072 <cprintf>
            tf->epc += 4;
    80200522:	10843783          	ld	a5,264(s0)
}
    80200526:	60a2                	ld	ra,8(sp)
            tf->epc += 4;
    80200528:	0791                	addi	a5,a5,4
    8020052a:	10f43423          	sd	a5,264(s0)
}
    8020052e:	6402                	ld	s0,0(sp)
    80200530:	0141                	addi	sp,sp,16
    80200532:	8082                	ret

0000000080200534 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200534:	11853783          	ld	a5,280(a0)
    80200538:	0007c463          	bltz	a5,80200540 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    8020053c:	f63ff06f          	j	8020049e <exception_handler>
        interrupt_handler(tf);
    80200540:	e8dff06f          	j	802003cc <interrupt_handler>

0000000080200544 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200544:	14011073          	csrw	sscratch,sp
    80200548:	712d                	addi	sp,sp,-288
    8020054a:	e002                	sd	zero,0(sp)
    8020054c:	e406                	sd	ra,8(sp)
    8020054e:	ec0e                	sd	gp,24(sp)
    80200550:	f012                	sd	tp,32(sp)
    80200552:	f416                	sd	t0,40(sp)
    80200554:	f81a                	sd	t1,48(sp)
    80200556:	fc1e                	sd	t2,56(sp)
    80200558:	e0a2                	sd	s0,64(sp)
    8020055a:	e4a6                	sd	s1,72(sp)
    8020055c:	e8aa                	sd	a0,80(sp)
    8020055e:	ecae                	sd	a1,88(sp)
    80200560:	f0b2                	sd	a2,96(sp)
    80200562:	f4b6                	sd	a3,104(sp)
    80200564:	f8ba                	sd	a4,112(sp)
    80200566:	fcbe                	sd	a5,120(sp)
    80200568:	e142                	sd	a6,128(sp)
    8020056a:	e546                	sd	a7,136(sp)
    8020056c:	e94a                	sd	s2,144(sp)
    8020056e:	ed4e                	sd	s3,152(sp)
    80200570:	f152                	sd	s4,160(sp)
    80200572:	f556                	sd	s5,168(sp)
    80200574:	f95a                	sd	s6,176(sp)
    80200576:	fd5e                	sd	s7,184(sp)
    80200578:	e1e2                	sd	s8,192(sp)
    8020057a:	e5e6                	sd	s9,200(sp)
    8020057c:	e9ea                	sd	s10,208(sp)
    8020057e:	edee                	sd	s11,216(sp)
    80200580:	f1f2                	sd	t3,224(sp)
    80200582:	f5f6                	sd	t4,232(sp)
    80200584:	f9fa                	sd	t5,240(sp)
    80200586:	fdfe                	sd	t6,248(sp)
    80200588:	14001473          	csrrw	s0,sscratch,zero
    8020058c:	100024f3          	csrr	s1,sstatus
    80200590:	14102973          	csrr	s2,sepc
    80200594:	143029f3          	csrr	s3,stval
    80200598:	14202a73          	csrr	s4,scause
    8020059c:	e822                	sd	s0,16(sp)
    8020059e:	e226                	sd	s1,256(sp)
    802005a0:	e64a                	sd	s2,264(sp)
    802005a2:	ea4e                	sd	s3,272(sp)
    802005a4:	ee52                	sd	s4,280(sp)

    move  a0, sp
    802005a6:	850a                	mv	a0,sp
    jal trap
    802005a8:	f8dff0ef          	jal	ra,80200534 <trap>

00000000802005ac <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    802005ac:	6492                	ld	s1,256(sp)
    802005ae:	6932                	ld	s2,264(sp)
    802005b0:	10049073          	csrw	sstatus,s1
    802005b4:	14191073          	csrw	sepc,s2
    802005b8:	60a2                	ld	ra,8(sp)
    802005ba:	61e2                	ld	gp,24(sp)
    802005bc:	7202                	ld	tp,32(sp)
    802005be:	72a2                	ld	t0,40(sp)
    802005c0:	7342                	ld	t1,48(sp)
    802005c2:	73e2                	ld	t2,56(sp)
    802005c4:	6406                	ld	s0,64(sp)
    802005c6:	64a6                	ld	s1,72(sp)
    802005c8:	6546                	ld	a0,80(sp)
    802005ca:	65e6                	ld	a1,88(sp)
    802005cc:	7606                	ld	a2,96(sp)
    802005ce:	76a6                	ld	a3,104(sp)
    802005d0:	7746                	ld	a4,112(sp)
    802005d2:	77e6                	ld	a5,120(sp)
    802005d4:	680a                	ld	a6,128(sp)
    802005d6:	68aa                	ld	a7,136(sp)
    802005d8:	694a                	ld	s2,144(sp)
    802005da:	69ea                	ld	s3,152(sp)
    802005dc:	7a0a                	ld	s4,160(sp)
    802005de:	7aaa                	ld	s5,168(sp)
    802005e0:	7b4a                	ld	s6,176(sp)
    802005e2:	7bea                	ld	s7,184(sp)
    802005e4:	6c0e                	ld	s8,192(sp)
    802005e6:	6cae                	ld	s9,200(sp)
    802005e8:	6d4e                	ld	s10,208(sp)
    802005ea:	6dee                	ld	s11,216(sp)
    802005ec:	7e0e                	ld	t3,224(sp)
    802005ee:	7eae                	ld	t4,232(sp)
    802005f0:	7f4e                	ld	t5,240(sp)
    802005f2:	7fee                	ld	t6,248(sp)
    802005f4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005f6:	10200073          	sret

00000000802005fa <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005fa:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005fe:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80200600:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200604:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    80200606:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    8020060a:	f022                	sd	s0,32(sp)
    8020060c:	ec26                	sd	s1,24(sp)
    8020060e:	e84a                	sd	s2,16(sp)
    80200610:	f406                	sd	ra,40(sp)
    80200612:	e44e                	sd	s3,8(sp)
    80200614:	84aa                	mv	s1,a0
    80200616:	892e                	mv	s2,a1
    80200618:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    8020061c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    8020061e:	03067e63          	bleu	a6,a2,8020065a <printnum+0x60>
    80200622:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200624:	00805763          	blez	s0,80200632 <printnum+0x38>
    80200628:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    8020062a:	85ca                	mv	a1,s2
    8020062c:	854e                	mv	a0,s3
    8020062e:	9482                	jalr	s1
        while (-- width > 0)
    80200630:	fc65                	bnez	s0,80200628 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200632:	1a02                	slli	s4,s4,0x20
    80200634:	020a5a13          	srli	s4,s4,0x20
    80200638:	00001797          	auipc	a5,0x1
    8020063c:	bd878793          	addi	a5,a5,-1064 # 80201210 <error_string+0x38>
    80200640:	9a3e                	add	s4,s4,a5
}
    80200642:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200644:	000a4503          	lbu	a0,0(s4)
}
    80200648:	70a2                	ld	ra,40(sp)
    8020064a:	69a2                	ld	s3,8(sp)
    8020064c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020064e:	85ca                	mv	a1,s2
    80200650:	8326                	mv	t1,s1
}
    80200652:	6942                	ld	s2,16(sp)
    80200654:	64e2                	ld	s1,24(sp)
    80200656:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200658:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    8020065a:	03065633          	divu	a2,a2,a6
    8020065e:	8722                	mv	a4,s0
    80200660:	f9bff0ef          	jal	ra,802005fa <printnum>
    80200664:	b7f9                	j	80200632 <printnum+0x38>

0000000080200666 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    80200666:	7119                	addi	sp,sp,-128
    80200668:	f4a6                	sd	s1,104(sp)
    8020066a:	f0ca                	sd	s2,96(sp)
    8020066c:	e8d2                	sd	s4,80(sp)
    8020066e:	e4d6                	sd	s5,72(sp)
    80200670:	e0da                	sd	s6,64(sp)
    80200672:	fc5e                	sd	s7,56(sp)
    80200674:	f862                	sd	s8,48(sp)
    80200676:	f06a                	sd	s10,32(sp)
    80200678:	fc86                	sd	ra,120(sp)
    8020067a:	f8a2                	sd	s0,112(sp)
    8020067c:	ecce                	sd	s3,88(sp)
    8020067e:	f466                	sd	s9,40(sp)
    80200680:	ec6e                	sd	s11,24(sp)
    80200682:	892a                	mv	s2,a0
    80200684:	84ae                	mv	s1,a1
    80200686:	8d32                	mv	s10,a2
    80200688:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020068a:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    8020068c:	00001a17          	auipc	s4,0x1
    80200690:	9f0a0a13          	addi	s4,s4,-1552 # 8020107c <etext+0x5fe>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    80200694:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200698:	00001c17          	auipc	s8,0x1
    8020069c:	b40c0c13          	addi	s8,s8,-1216 # 802011d8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006a0:	000d4503          	lbu	a0,0(s10)
    802006a4:	02500793          	li	a5,37
    802006a8:	001d0413          	addi	s0,s10,1
    802006ac:	00f50e63          	beq	a0,a5,802006c8 <vprintfmt+0x62>
            if (ch == '\0') {
    802006b0:	c521                	beqz	a0,802006f8 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006b2:	02500993          	li	s3,37
    802006b6:	a011                	j	802006ba <vprintfmt+0x54>
            if (ch == '\0') {
    802006b8:	c121                	beqz	a0,802006f8 <vprintfmt+0x92>
            putch(ch, putdat);
    802006ba:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006bc:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802006be:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006c0:	fff44503          	lbu	a0,-1(s0)
    802006c4:	ff351ae3          	bne	a0,s3,802006b8 <vprintfmt+0x52>
    802006c8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802006cc:	02000793          	li	a5,32
        lflag = altflag = 0;
    802006d0:	4981                	li	s3,0
    802006d2:	4801                	li	a6,0
        width = precision = -1;
    802006d4:	5cfd                	li	s9,-1
    802006d6:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    802006d8:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    802006dc:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    802006de:	fdd6069b          	addiw	a3,a2,-35
    802006e2:	0ff6f693          	andi	a3,a3,255
    802006e6:	00140d13          	addi	s10,s0,1
    802006ea:	20d5e563          	bltu	a1,a3,802008f4 <vprintfmt+0x28e>
    802006ee:	068a                	slli	a3,a3,0x2
    802006f0:	96d2                	add	a3,a3,s4
    802006f2:	4294                	lw	a3,0(a3)
    802006f4:	96d2                	add	a3,a3,s4
    802006f6:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802006f8:	70e6                	ld	ra,120(sp)
    802006fa:	7446                	ld	s0,112(sp)
    802006fc:	74a6                	ld	s1,104(sp)
    802006fe:	7906                	ld	s2,96(sp)
    80200700:	69e6                	ld	s3,88(sp)
    80200702:	6a46                	ld	s4,80(sp)
    80200704:	6aa6                	ld	s5,72(sp)
    80200706:	6b06                	ld	s6,64(sp)
    80200708:	7be2                	ld	s7,56(sp)
    8020070a:	7c42                	ld	s8,48(sp)
    8020070c:	7ca2                	ld	s9,40(sp)
    8020070e:	7d02                	ld	s10,32(sp)
    80200710:	6de2                	ld	s11,24(sp)
    80200712:	6109                	addi	sp,sp,128
    80200714:	8082                	ret
    if (lflag >= 2) {
    80200716:	4705                	li	a4,1
    80200718:	008a8593          	addi	a1,s5,8
    8020071c:	01074463          	blt	a4,a6,80200724 <vprintfmt+0xbe>
    else if (lflag) {
    80200720:	26080363          	beqz	a6,80200986 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
    80200724:	000ab603          	ld	a2,0(s5)
    80200728:	46c1                	li	a3,16
    8020072a:	8aae                	mv	s5,a1
    8020072c:	a06d                	j	802007d6 <vprintfmt+0x170>
            goto reswitch;
    8020072e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200732:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200734:	846a                	mv	s0,s10
            goto reswitch;
    80200736:	b765                	j	802006de <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
    80200738:	000aa503          	lw	a0,0(s5)
    8020073c:	85a6                	mv	a1,s1
    8020073e:	0aa1                	addi	s5,s5,8
    80200740:	9902                	jalr	s2
            break;
    80200742:	bfb9                	j	802006a0 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200744:	4705                	li	a4,1
    80200746:	008a8993          	addi	s3,s5,8
    8020074a:	01074463          	blt	a4,a6,80200752 <vprintfmt+0xec>
    else if (lflag) {
    8020074e:	22080463          	beqz	a6,80200976 <vprintfmt+0x310>
        return va_arg(*ap, long);
    80200752:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    80200756:	24044463          	bltz	s0,8020099e <vprintfmt+0x338>
            num = getint(&ap, lflag);
    8020075a:	8622                	mv	a2,s0
    8020075c:	8ace                	mv	s5,s3
    8020075e:	46a9                	li	a3,10
    80200760:	a89d                	j	802007d6 <vprintfmt+0x170>
            err = va_arg(ap, int);
    80200762:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200766:	4719                	li	a4,6
            err = va_arg(ap, int);
    80200768:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    8020076a:	41f7d69b          	sraiw	a3,a5,0x1f
    8020076e:	8fb5                	xor	a5,a5,a3
    80200770:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200774:	1ad74363          	blt	a4,a3,8020091a <vprintfmt+0x2b4>
    80200778:	00369793          	slli	a5,a3,0x3
    8020077c:	97e2                	add	a5,a5,s8
    8020077e:	639c                	ld	a5,0(a5)
    80200780:	18078d63          	beqz	a5,8020091a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
    80200784:	86be                	mv	a3,a5
    80200786:	00001617          	auipc	a2,0x1
    8020078a:	b3a60613          	addi	a2,a2,-1222 # 802012c0 <error_string+0xe8>
    8020078e:	85a6                	mv	a1,s1
    80200790:	854a                	mv	a0,s2
    80200792:	240000ef          	jal	ra,802009d2 <printfmt>
    80200796:	b729                	j	802006a0 <vprintfmt+0x3a>
            lflag ++;
    80200798:	00144603          	lbu	a2,1(s0)
    8020079c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    8020079e:	846a                	mv	s0,s10
            goto reswitch;
    802007a0:	bf3d                	j	802006de <vprintfmt+0x78>
    if (lflag >= 2) {
    802007a2:	4705                	li	a4,1
    802007a4:	008a8593          	addi	a1,s5,8
    802007a8:	01074463          	blt	a4,a6,802007b0 <vprintfmt+0x14a>
    else if (lflag) {
    802007ac:	1e080263          	beqz	a6,80200990 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
    802007b0:	000ab603          	ld	a2,0(s5)
    802007b4:	46a1                	li	a3,8
    802007b6:	8aae                	mv	s5,a1
    802007b8:	a839                	j	802007d6 <vprintfmt+0x170>
            putch('0', putdat);
    802007ba:	03000513          	li	a0,48
    802007be:	85a6                	mv	a1,s1
    802007c0:	e03e                	sd	a5,0(sp)
    802007c2:	9902                	jalr	s2
            putch('x', putdat);
    802007c4:	85a6                	mv	a1,s1
    802007c6:	07800513          	li	a0,120
    802007ca:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802007cc:	0aa1                	addi	s5,s5,8
    802007ce:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    802007d2:	6782                	ld	a5,0(sp)
    802007d4:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    802007d6:	876e                	mv	a4,s11
    802007d8:	85a6                	mv	a1,s1
    802007da:	854a                	mv	a0,s2
    802007dc:	e1fff0ef          	jal	ra,802005fa <printnum>
            break;
    802007e0:	b5c1                	j	802006a0 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007e2:	000ab603          	ld	a2,0(s5)
    802007e6:	0aa1                	addi	s5,s5,8
    802007e8:	1c060663          	beqz	a2,802009b4 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
    802007ec:	00160413          	addi	s0,a2,1
    802007f0:	17b05c63          	blez	s11,80200968 <vprintfmt+0x302>
    802007f4:	02d00593          	li	a1,45
    802007f8:	14b79263          	bne	a5,a1,8020093c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007fc:	00064783          	lbu	a5,0(a2)
    80200800:	0007851b          	sext.w	a0,a5
    80200804:	c905                	beqz	a0,80200834 <vprintfmt+0x1ce>
    80200806:	000cc563          	bltz	s9,80200810 <vprintfmt+0x1aa>
    8020080a:	3cfd                	addiw	s9,s9,-1
    8020080c:	036c8263          	beq	s9,s6,80200830 <vprintfmt+0x1ca>
                    putch('?', putdat);
    80200810:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200812:	18098463          	beqz	s3,8020099a <vprintfmt+0x334>
    80200816:	3781                	addiw	a5,a5,-32
    80200818:	18fbf163          	bleu	a5,s7,8020099a <vprintfmt+0x334>
                    putch('?', putdat);
    8020081c:	03f00513          	li	a0,63
    80200820:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200822:	0405                	addi	s0,s0,1
    80200824:	fff44783          	lbu	a5,-1(s0)
    80200828:	3dfd                	addiw	s11,s11,-1
    8020082a:	0007851b          	sext.w	a0,a5
    8020082e:	fd61                	bnez	a0,80200806 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
    80200830:	e7b058e3          	blez	s11,802006a0 <vprintfmt+0x3a>
    80200834:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200836:	85a6                	mv	a1,s1
    80200838:	02000513          	li	a0,32
    8020083c:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020083e:	e60d81e3          	beqz	s11,802006a0 <vprintfmt+0x3a>
    80200842:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200844:	85a6                	mv	a1,s1
    80200846:	02000513          	li	a0,32
    8020084a:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020084c:	fe0d94e3          	bnez	s11,80200834 <vprintfmt+0x1ce>
    80200850:	bd81                	j	802006a0 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200852:	4705                	li	a4,1
    80200854:	008a8593          	addi	a1,s5,8
    80200858:	01074463          	blt	a4,a6,80200860 <vprintfmt+0x1fa>
    else if (lflag) {
    8020085c:	12080063          	beqz	a6,8020097c <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
    80200860:	000ab603          	ld	a2,0(s5)
    80200864:	46a9                	li	a3,10
    80200866:	8aae                	mv	s5,a1
    80200868:	b7bd                	j	802007d6 <vprintfmt+0x170>
    8020086a:	00144603          	lbu	a2,1(s0)
            padc = '-';
    8020086e:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
    80200872:	846a                	mv	s0,s10
    80200874:	b5ad                	j	802006de <vprintfmt+0x78>
            putch(ch, putdat);
    80200876:	85a6                	mv	a1,s1
    80200878:	02500513          	li	a0,37
    8020087c:	9902                	jalr	s2
            break;
    8020087e:	b50d                	j	802006a0 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
    80200880:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    80200884:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200888:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    8020088a:	846a                	mv	s0,s10
            if (width < 0)
    8020088c:	e40dd9e3          	bgez	s11,802006de <vprintfmt+0x78>
                width = precision, precision = -1;
    80200890:	8de6                	mv	s11,s9
    80200892:	5cfd                	li	s9,-1
    80200894:	b5a9                	j	802006de <vprintfmt+0x78>
            goto reswitch;
    80200896:	00144603          	lbu	a2,1(s0)
            padc = '0';
    8020089a:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
    8020089e:	846a                	mv	s0,s10
            goto reswitch;
    802008a0:	bd3d                	j	802006de <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
    802008a2:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    802008a6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802008aa:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802008ac:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802008b0:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008b4:	fcd56ce3          	bltu	a0,a3,8020088c <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
    802008b8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    802008ba:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    802008be:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    802008c2:	0196873b          	addw	a4,a3,s9
    802008c6:	0017171b          	slliw	a4,a4,0x1
    802008ca:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    802008ce:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    802008d2:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    802008d6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    802008da:	fcd57fe3          	bleu	a3,a0,802008b8 <vprintfmt+0x252>
    802008de:	b77d                	j	8020088c <vprintfmt+0x226>
            if (width < 0)
    802008e0:	fffdc693          	not	a3,s11
    802008e4:	96fd                	srai	a3,a3,0x3f
    802008e6:	00ddfdb3          	and	s11,s11,a3
    802008ea:	00144603          	lbu	a2,1(s0)
    802008ee:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    802008f0:	846a                	mv	s0,s10
    802008f2:	b3f5                	j	802006de <vprintfmt+0x78>
            putch('%', putdat);
    802008f4:	85a6                	mv	a1,s1
    802008f6:	02500513          	li	a0,37
    802008fa:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802008fc:	fff44703          	lbu	a4,-1(s0)
    80200900:	02500793          	li	a5,37
    80200904:	8d22                	mv	s10,s0
    80200906:	d8f70de3          	beq	a4,a5,802006a0 <vprintfmt+0x3a>
    8020090a:	02500713          	li	a4,37
    8020090e:	1d7d                	addi	s10,s10,-1
    80200910:	fffd4783          	lbu	a5,-1(s10)
    80200914:	fee79de3          	bne	a5,a4,8020090e <vprintfmt+0x2a8>
    80200918:	b361                	j	802006a0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    8020091a:	00001617          	auipc	a2,0x1
    8020091e:	99660613          	addi	a2,a2,-1642 # 802012b0 <error_string+0xd8>
    80200922:	85a6                	mv	a1,s1
    80200924:	854a                	mv	a0,s2
    80200926:	0ac000ef          	jal	ra,802009d2 <printfmt>
    8020092a:	bb9d                	j	802006a0 <vprintfmt+0x3a>
                p = "(null)";
    8020092c:	00001617          	auipc	a2,0x1
    80200930:	97c60613          	addi	a2,a2,-1668 # 802012a8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    80200934:	00001417          	auipc	s0,0x1
    80200938:	97540413          	addi	s0,s0,-1675 # 802012a9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020093c:	8532                	mv	a0,a2
    8020093e:	85e6                	mv	a1,s9
    80200940:	e032                	sd	a2,0(sp)
    80200942:	e43e                	sd	a5,8(sp)
    80200944:	102000ef          	jal	ra,80200a46 <strnlen>
    80200948:	40ad8dbb          	subw	s11,s11,a0
    8020094c:	6602                	ld	a2,0(sp)
    8020094e:	01b05d63          	blez	s11,80200968 <vprintfmt+0x302>
    80200952:	67a2                	ld	a5,8(sp)
    80200954:	2781                	sext.w	a5,a5
    80200956:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    80200958:	6522                	ld	a0,8(sp)
    8020095a:	85a6                	mv	a1,s1
    8020095c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020095e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200960:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200962:	6602                	ld	a2,0(sp)
    80200964:	fe0d9ae3          	bnez	s11,80200958 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200968:	00064783          	lbu	a5,0(a2)
    8020096c:	0007851b          	sext.w	a0,a5
    80200970:	e8051be3          	bnez	a0,80200806 <vprintfmt+0x1a0>
    80200974:	b335                	j	802006a0 <vprintfmt+0x3a>
        return va_arg(*ap, int);
    80200976:	000aa403          	lw	s0,0(s5)
    8020097a:	bbf1                	j	80200756 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
    8020097c:	000ae603          	lwu	a2,0(s5)
    80200980:	46a9                	li	a3,10
    80200982:	8aae                	mv	s5,a1
    80200984:	bd89                	j	802007d6 <vprintfmt+0x170>
    80200986:	000ae603          	lwu	a2,0(s5)
    8020098a:	46c1                	li	a3,16
    8020098c:	8aae                	mv	s5,a1
    8020098e:	b5a1                	j	802007d6 <vprintfmt+0x170>
    80200990:	000ae603          	lwu	a2,0(s5)
    80200994:	46a1                	li	a3,8
    80200996:	8aae                	mv	s5,a1
    80200998:	bd3d                	j	802007d6 <vprintfmt+0x170>
                    putch(ch, putdat);
    8020099a:	9902                	jalr	s2
    8020099c:	b559                	j	80200822 <vprintfmt+0x1bc>
                putch('-', putdat);
    8020099e:	85a6                	mv	a1,s1
    802009a0:	02d00513          	li	a0,45
    802009a4:	e03e                	sd	a5,0(sp)
    802009a6:	9902                	jalr	s2
                num = -(long long)num;
    802009a8:	8ace                	mv	s5,s3
    802009aa:	40800633          	neg	a2,s0
    802009ae:	46a9                	li	a3,10
    802009b0:	6782                	ld	a5,0(sp)
    802009b2:	b515                	j	802007d6 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
    802009b4:	01b05663          	blez	s11,802009c0 <vprintfmt+0x35a>
    802009b8:	02d00693          	li	a3,45
    802009bc:	f6d798e3          	bne	a5,a3,8020092c <vprintfmt+0x2c6>
    802009c0:	00001417          	auipc	s0,0x1
    802009c4:	8e940413          	addi	s0,s0,-1815 # 802012a9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009c8:	02800513          	li	a0,40
    802009cc:	02800793          	li	a5,40
    802009d0:	bd1d                	j	80200806 <vprintfmt+0x1a0>

00000000802009d2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009d2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    802009d4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009d8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009da:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009dc:	ec06                	sd	ra,24(sp)
    802009de:	f83a                	sd	a4,48(sp)
    802009e0:	fc3e                	sd	a5,56(sp)
    802009e2:	e0c2                	sd	a6,64(sp)
    802009e4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802009e6:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009e8:	c7fff0ef          	jal	ra,80200666 <vprintfmt>
}
    802009ec:	60e2                	ld	ra,24(sp)
    802009ee:	6161                	addi	sp,sp,80
    802009f0:	8082                	ret

00000000802009f2 <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    802009f2:	00003797          	auipc	a5,0x3
    802009f6:	60e78793          	addi	a5,a5,1550 # 80204000 <bootstacktop>
    __asm__ volatile (
    802009fa:	6398                	ld	a4,0(a5)
    802009fc:	4781                	li	a5,0
    802009fe:	88ba                	mv	a7,a4
    80200a00:	852a                	mv	a0,a0
    80200a02:	85be                	mv	a1,a5
    80200a04:	863e                	mv	a2,a5
    80200a06:	00000073          	ecall
    80200a0a:	87aa                	mv	a5,a0
}
    80200a0c:	8082                	ret

0000000080200a0e <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    80200a0e:	00003797          	auipc	a5,0x3
    80200a12:	60a78793          	addi	a5,a5,1546 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    80200a16:	6398                	ld	a4,0(a5)
    80200a18:	4781                	li	a5,0
    80200a1a:	88ba                	mv	a7,a4
    80200a1c:	852a                	mv	a0,a0
    80200a1e:	85be                	mv	a1,a5
    80200a20:	863e                	mv	a2,a5
    80200a22:	00000073          	ecall
    80200a26:	87aa                	mv	a5,a0
}
    80200a28:	8082                	ret

0000000080200a2a <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a2a:	00003797          	auipc	a5,0x3
    80200a2e:	5de78793          	addi	a5,a5,1502 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    80200a32:	6398                	ld	a4,0(a5)
    80200a34:	4781                	li	a5,0
    80200a36:	88ba                	mv	a7,a4
    80200a38:	853e                	mv	a0,a5
    80200a3a:	85be                	mv	a1,a5
    80200a3c:	863e                	mv	a2,a5
    80200a3e:	00000073          	ecall
    80200a42:	87aa                	mv	a5,a0
    80200a44:	8082                	ret

0000000080200a46 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    80200a46:	c185                	beqz	a1,80200a66 <strnlen+0x20>
    80200a48:	00054783          	lbu	a5,0(a0)
    80200a4c:	cf89                	beqz	a5,80200a66 <strnlen+0x20>
    size_t cnt = 0;
    80200a4e:	4781                	li	a5,0
    80200a50:	a021                	j	80200a58 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    80200a52:	00074703          	lbu	a4,0(a4)
    80200a56:	c711                	beqz	a4,80200a62 <strnlen+0x1c>
        cnt ++;
    80200a58:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200a5a:	00f50733          	add	a4,a0,a5
    80200a5e:	fef59ae3          	bne	a1,a5,80200a52 <strnlen+0xc>
    }
    return cnt;
}
    80200a62:	853e                	mv	a0,a5
    80200a64:	8082                	ret
    size_t cnt = 0;
    80200a66:	4781                	li	a5,0
}
    80200a68:	853e                	mv	a0,a5
    80200a6a:	8082                	ret

0000000080200a6c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a6c:	ca01                	beqz	a2,80200a7c <memset+0x10>
    80200a6e:	962a                	add	a2,a2,a0
    char *p = s;
    80200a70:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a72:	0785                	addi	a5,a5,1
    80200a74:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a78:	fec79de3          	bne	a5,a2,80200a72 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a7c:	8082                	ret
