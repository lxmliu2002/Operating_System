
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02042b7          	lui	t0,0xc0204
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0204137          	lui	sp,0xc0204

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00005517          	auipc	a0,0x5
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0205010 <edata>
ffffffffc020003e:	00005617          	auipc	a2,0x5
ffffffffc0200042:	52260613          	addi	a2,a2,1314 # ffffffffc0205560 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	2ec010ef          	jal	ra,ffffffffc020133a <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00001517          	auipc	a0,0x1
ffffffffc020005a:	2fa50513          	addi	a0,a0,762 # ffffffffc0201350 <etext+0x4>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	3a9000ef          	jal	ra,ffffffffc0200c12 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	583000ef          	jal	ra,ffffffffc0200e2c <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0204028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	54f000ef          	jal	ra,ffffffffc0200e2c <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200140:	00001517          	auipc	a0,0x1
ffffffffc0200144:	26050513          	addi	a0,a0,608 # ffffffffc02013a0 <etext+0x54>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00001517          	auipc	a0,0x1
ffffffffc020015a:	26a50513          	addi	a0,a0,618 # ffffffffc02013c0 <etext+0x74>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00001597          	auipc	a1,0x1
ffffffffc0200166:	1ea58593          	addi	a1,a1,490 # ffffffffc020134c <etext>
ffffffffc020016a:	00001517          	auipc	a0,0x1
ffffffffc020016e:	27650513          	addi	a0,a0,630 # ffffffffc02013e0 <etext+0x94>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00005597          	auipc	a1,0x5
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0205010 <edata>
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	28250513          	addi	a0,a0,642 # ffffffffc0201400 <etext+0xb4>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00005597          	auipc	a1,0x5
ffffffffc020018e:	3d658593          	addi	a1,a1,982 # ffffffffc0205560 <end>
ffffffffc0200192:	00001517          	auipc	a0,0x1
ffffffffc0200196:	28e50513          	addi	a0,a0,654 # ffffffffc0201420 <etext+0xd4>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00005597          	auipc	a1,0x5
ffffffffc02001a2:	7c158593          	addi	a1,a1,1985 # ffffffffc020595f <end+0x3ff>
ffffffffc02001a6:	00000797          	auipc	a5,0x0
ffffffffc02001aa:	e9078793          	addi	a5,a5,-368 # ffffffffc0200036 <kern_init>
ffffffffc02001ae:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001bc:	95be                	add	a1,a1,a5
ffffffffc02001be:	85a9                	srai	a1,a1,0xa
ffffffffc02001c0:	00001517          	auipc	a0,0x1
ffffffffc02001c4:	28050513          	addi	a0,a0,640 # ffffffffc0201440 <etext+0xf4>
}
ffffffffc02001c8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ca:	eedff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ce <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ce:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d0:	00001617          	auipc	a2,0x1
ffffffffc02001d4:	1a060613          	addi	a2,a2,416 # ffffffffc0201370 <etext+0x24>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00001517          	auipc	a0,0x1
ffffffffc02001e0:	1ac50513          	addi	a0,a0,428 # ffffffffc0201388 <etext+0x3c>
void print_stackframe(void) {
ffffffffc02001e4:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e6:	1c6000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001ea <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ea:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ec:	00001617          	auipc	a2,0x1
ffffffffc02001f0:	36460613          	addi	a2,a2,868 # ffffffffc0201550 <commands+0xe0>
ffffffffc02001f4:	00001597          	auipc	a1,0x1
ffffffffc02001f8:	37c58593          	addi	a1,a1,892 # ffffffffc0201570 <commands+0x100>
ffffffffc02001fc:	00001517          	auipc	a0,0x1
ffffffffc0200200:	37c50513          	addi	a0,a0,892 # ffffffffc0201578 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00001617          	auipc	a2,0x1
ffffffffc020020e:	37e60613          	addi	a2,a2,894 # ffffffffc0201588 <commands+0x118>
ffffffffc0200212:	00001597          	auipc	a1,0x1
ffffffffc0200216:	39e58593          	addi	a1,a1,926 # ffffffffc02015b0 <commands+0x140>
ffffffffc020021a:	00001517          	auipc	a0,0x1
ffffffffc020021e:	35e50513          	addi	a0,a0,862 # ffffffffc0201578 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00001617          	auipc	a2,0x1
ffffffffc020022a:	39a60613          	addi	a2,a2,922 # ffffffffc02015c0 <commands+0x150>
ffffffffc020022e:	00001597          	auipc	a1,0x1
ffffffffc0200232:	3b258593          	addi	a1,a1,946 # ffffffffc02015e0 <commands+0x170>
ffffffffc0200236:	00001517          	auipc	a0,0x1
ffffffffc020023a:	34250513          	addi	a0,a0,834 # ffffffffc0201578 <commands+0x108>
ffffffffc020023e:	e79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc0200242:	60a2                	ld	ra,8(sp)
ffffffffc0200244:	4501                	li	a0,0
ffffffffc0200246:	0141                	addi	sp,sp,16
ffffffffc0200248:	8082                	ret

ffffffffc020024a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
ffffffffc020024c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024e:	ef1ff0ef          	jal	ra,ffffffffc020013e <print_kerninfo>
    return 0;
}
ffffffffc0200252:	60a2                	ld	ra,8(sp)
ffffffffc0200254:	4501                	li	a0,0
ffffffffc0200256:	0141                	addi	sp,sp,16
ffffffffc0200258:	8082                	ret

ffffffffc020025a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	1141                	addi	sp,sp,-16
ffffffffc020025c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025e:	f71ff0ef          	jal	ra,ffffffffc02001ce <print_stackframe>
    return 0;
}
ffffffffc0200262:	60a2                	ld	ra,8(sp)
ffffffffc0200264:	4501                	li	a0,0
ffffffffc0200266:	0141                	addi	sp,sp,16
ffffffffc0200268:	8082                	ret

ffffffffc020026a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026a:	7115                	addi	sp,sp,-224
ffffffffc020026c:	e962                	sd	s8,144(sp)
ffffffffc020026e:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200270:	00001517          	auipc	a0,0x1
ffffffffc0200274:	24850513          	addi	a0,a0,584 # ffffffffc02014b8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200278:	ed86                	sd	ra,216(sp)
ffffffffc020027a:	e9a2                	sd	s0,208(sp)
ffffffffc020027c:	e5a6                	sd	s1,200(sp)
ffffffffc020027e:	e1ca                	sd	s2,192(sp)
ffffffffc0200280:	fd4e                	sd	s3,184(sp)
ffffffffc0200282:	f952                	sd	s4,176(sp)
ffffffffc0200284:	f556                	sd	s5,168(sp)
ffffffffc0200286:	f15a                	sd	s6,160(sp)
ffffffffc0200288:	ed5e                	sd	s7,152(sp)
ffffffffc020028a:	e566                	sd	s9,136(sp)
ffffffffc020028c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	e29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200292:	00001517          	auipc	a0,0x1
ffffffffc0200296:	24e50513          	addi	a0,a0,590 # ffffffffc02014e0 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00001c97          	auipc	s9,0x1
ffffffffc02002ac:	1c8c8c93          	addi	s9,s9,456 # ffffffffc0201470 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00001997          	auipc	s3,0x1
ffffffffc02002b4:	25898993          	addi	s3,s3,600 # ffffffffc0201508 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00001917          	auipc	s2,0x1
ffffffffc02002bc:	25890913          	addi	s2,s2,600 # ffffffffc0201510 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00001b17          	auipc	s6,0x1
ffffffffc02002c6:	256b0b13          	addi	s6,s6,598 # ffffffffc0201518 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00001a97          	auipc	s5,0x1
ffffffffc02002ce:	2a6a8a93          	addi	s5,s5,678 # ffffffffc0201570 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	6e3000ef          	jal	ra,ffffffffc02011b8 <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	034010ef          	jal	ra,ffffffffc020131c <strchr>
ffffffffc02002ec:	c925                	beqz	a0,ffffffffc020035c <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002ee:	00144583          	lbu	a1,1(s0)
ffffffffc02002f2:	00040023          	sb	zero,0(s0)
ffffffffc02002f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f8:	f5fd                	bnez	a1,ffffffffc02002e6 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002fa:	dce9                	beqz	s1,ffffffffc02002d4 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002fc:	6582                	ld	a1,0(sp)
ffffffffc02002fe:	00001d17          	auipc	s10,0x1
ffffffffc0200302:	172d0d13          	addi	s10,s10,370 # ffffffffc0201470 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	7e7000ef          	jal	ra,ffffffffc02012f2 <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	7d3000ef          	jal	ra,ffffffffc02012f2 <strcmp>
ffffffffc0200324:	f57d                	bnez	a0,ffffffffc0200312 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200326:	00141793          	slli	a5,s0,0x1
ffffffffc020032a:	97a2                	add	a5,a5,s0
ffffffffc020032c:	078e                	slli	a5,a5,0x3
ffffffffc020032e:	97e6                	add	a5,a5,s9
ffffffffc0200330:	6b9c                	ld	a5,16(a5)
ffffffffc0200332:	8662                	mv	a2,s8
ffffffffc0200334:	002c                	addi	a1,sp,8
ffffffffc0200336:	fff4851b          	addiw	a0,s1,-1
ffffffffc020033a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020033c:	f8055ce3          	bgez	a0,ffffffffc02002d4 <kmonitor+0x6a>
}
ffffffffc0200340:	60ee                	ld	ra,216(sp)
ffffffffc0200342:	644e                	ld	s0,208(sp)
ffffffffc0200344:	64ae                	ld	s1,200(sp)
ffffffffc0200346:	690e                	ld	s2,192(sp)
ffffffffc0200348:	79ea                	ld	s3,184(sp)
ffffffffc020034a:	7a4a                	ld	s4,176(sp)
ffffffffc020034c:	7aaa                	ld	s5,168(sp)
ffffffffc020034e:	7b0a                	ld	s6,160(sp)
ffffffffc0200350:	6bea                	ld	s7,152(sp)
ffffffffc0200352:	6c4a                	ld	s8,144(sp)
ffffffffc0200354:	6caa                	ld	s9,136(sp)
ffffffffc0200356:	6d0a                	ld	s10,128(sp)
ffffffffc0200358:	612d                	addi	sp,sp,224
ffffffffc020035a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020035c:	00044783          	lbu	a5,0(s0)
ffffffffc0200360:	dfc9                	beqz	a5,ffffffffc02002fa <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200362:	03448863          	beq	s1,s4,ffffffffc0200392 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200366:	00349793          	slli	a5,s1,0x3
ffffffffc020036a:	0118                	addi	a4,sp,128
ffffffffc020036c:	97ba                	add	a5,a5,a4
ffffffffc020036e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200372:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200376:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	e591                	bnez	a1,ffffffffc0200384 <kmonitor+0x11a>
ffffffffc020037a:	b749                	j	ffffffffc02002fc <kmonitor+0x92>
            buf ++;
ffffffffc020037c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037e:	00044583          	lbu	a1,0(s0)
ffffffffc0200382:	ddad                	beqz	a1,ffffffffc02002fc <kmonitor+0x92>
ffffffffc0200384:	854a                	mv	a0,s2
ffffffffc0200386:	797000ef          	jal	ra,ffffffffc020131c <strchr>
ffffffffc020038a:	d96d                	beqz	a0,ffffffffc020037c <kmonitor+0x112>
ffffffffc020038c:	00044583          	lbu	a1,0(s0)
ffffffffc0200390:	bf91                	j	ffffffffc02002e4 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020039a:	b7f1                	j	ffffffffc0200366 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	19a50513          	addi	a0,a0,410 # ffffffffc0201538 <commands+0xc8>
ffffffffc02003a6:	d11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc02003aa:	b72d                	j	ffffffffc02002d4 <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00005317          	auipc	t1,0x5
ffffffffc02003b0:	06430313          	addi	t1,t1,100 # ffffffffc0205410 <is_panic>
ffffffffc02003b4:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	02031c63          	bnez	t1,ffffffffc0200400 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	8432                	mv	s0,a2
ffffffffc02003d0:	00005717          	auipc	a4,0x5
ffffffffc02003d4:	04f72023          	sw	a5,64(a4) # ffffffffc0205410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003da:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	85aa                	mv	a1,a0
ffffffffc02003de:	00001517          	auipc	a0,0x1
ffffffffc02003e2:	21250513          	addi	a0,a0,530 # ffffffffc02015f0 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00001517          	auipc	a0,0x1
ffffffffc02003f8:	07450513          	addi	a0,a0,116 # ffffffffc0201468 <etext+0x11c>
ffffffffc02003fc:	cbbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200400:	064000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200404:	4501                	li	a0,0
ffffffffc0200406:	e65ff0ef          	jal	ra,ffffffffc020026a <kmonitor>
ffffffffc020040a:	bfed                	j	ffffffffc0200404 <__panic+0x58>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	66f000ef          	jal	ra,ffffffffc0201292 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00005797          	auipc	a5,0x5
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0205430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	1de50513          	addi	a0,a0,478 # ffffffffc0201610 <commands+0x1a0>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	6470006f          	j	ffffffffc0201292 <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	6210006f          	j	ffffffffc0201276 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	6550006f          	j	ffffffffc02012ae <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	30678793          	addi	a5,a5,774 # ffffffffc0200774 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00001517          	auipc	a0,0x1
ffffffffc0200488:	2a450513          	addi	a0,a0,676 # ffffffffc0201728 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00001517          	auipc	a0,0x1
ffffffffc0200498:	2ac50513          	addi	a0,a0,684 # ffffffffc0201740 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00001517          	auipc	a0,0x1
ffffffffc02004a6:	2b650513          	addi	a0,a0,694 # ffffffffc0201758 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00001517          	auipc	a0,0x1
ffffffffc02004b4:	2c050513          	addi	a0,a0,704 # ffffffffc0201770 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00001517          	auipc	a0,0x1
ffffffffc02004c2:	2ca50513          	addi	a0,a0,714 # ffffffffc0201788 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00001517          	auipc	a0,0x1
ffffffffc02004d0:	2d450513          	addi	a0,a0,724 # ffffffffc02017a0 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00001517          	auipc	a0,0x1
ffffffffc02004de:	2de50513          	addi	a0,a0,734 # ffffffffc02017b8 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00001517          	auipc	a0,0x1
ffffffffc02004ec:	2e850513          	addi	a0,a0,744 # ffffffffc02017d0 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00001517          	auipc	a0,0x1
ffffffffc02004fa:	2f250513          	addi	a0,a0,754 # ffffffffc02017e8 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00001517          	auipc	a0,0x1
ffffffffc0200508:	2fc50513          	addi	a0,a0,764 # ffffffffc0201800 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00001517          	auipc	a0,0x1
ffffffffc0200516:	30650513          	addi	a0,a0,774 # ffffffffc0201818 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00001517          	auipc	a0,0x1
ffffffffc0200524:	31050513          	addi	a0,a0,784 # ffffffffc0201830 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00001517          	auipc	a0,0x1
ffffffffc0200532:	31a50513          	addi	a0,a0,794 # ffffffffc0201848 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00001517          	auipc	a0,0x1
ffffffffc0200540:	32450513          	addi	a0,a0,804 # ffffffffc0201860 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00001517          	auipc	a0,0x1
ffffffffc020054e:	32e50513          	addi	a0,a0,814 # ffffffffc0201878 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00001517          	auipc	a0,0x1
ffffffffc020055c:	33850513          	addi	a0,a0,824 # ffffffffc0201890 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00001517          	auipc	a0,0x1
ffffffffc020056a:	34250513          	addi	a0,a0,834 # ffffffffc02018a8 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00001517          	auipc	a0,0x1
ffffffffc0200578:	34c50513          	addi	a0,a0,844 # ffffffffc02018c0 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00001517          	auipc	a0,0x1
ffffffffc0200586:	35650513          	addi	a0,a0,854 # ffffffffc02018d8 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00001517          	auipc	a0,0x1
ffffffffc0200594:	36050513          	addi	a0,a0,864 # ffffffffc02018f0 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00001517          	auipc	a0,0x1
ffffffffc02005a2:	36a50513          	addi	a0,a0,874 # ffffffffc0201908 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00001517          	auipc	a0,0x1
ffffffffc02005b0:	37450513          	addi	a0,a0,884 # ffffffffc0201920 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00001517          	auipc	a0,0x1
ffffffffc02005be:	37e50513          	addi	a0,a0,894 # ffffffffc0201938 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00001517          	auipc	a0,0x1
ffffffffc02005cc:	38850513          	addi	a0,a0,904 # ffffffffc0201950 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00001517          	auipc	a0,0x1
ffffffffc02005da:	39250513          	addi	a0,a0,914 # ffffffffc0201968 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00001517          	auipc	a0,0x1
ffffffffc02005e8:	39c50513          	addi	a0,a0,924 # ffffffffc0201980 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00001517          	auipc	a0,0x1
ffffffffc02005f6:	3a650513          	addi	a0,a0,934 # ffffffffc0201998 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00001517          	auipc	a0,0x1
ffffffffc0200604:	3b050513          	addi	a0,a0,944 # ffffffffc02019b0 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00001517          	auipc	a0,0x1
ffffffffc0200612:	3ba50513          	addi	a0,a0,954 # ffffffffc02019c8 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00001517          	auipc	a0,0x1
ffffffffc0200620:	3c450513          	addi	a0,a0,964 # ffffffffc02019e0 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00001517          	auipc	a0,0x1
ffffffffc020062e:	3ce50513          	addi	a0,a0,974 # ffffffffc02019f8 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00001517          	auipc	a0,0x1
ffffffffc0200640:	3d450513          	addi	a0,a0,980 # ffffffffc0201a10 <commands+0x5a0>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00001517          	auipc	a0,0x1
ffffffffc0200656:	3d650513          	addi	a0,a0,982 # ffffffffc0201a28 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00001517          	auipc	a0,0x1
ffffffffc020066e:	3d650513          	addi	a0,a0,982 # ffffffffc0201a40 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00001517          	auipc	a0,0x1
ffffffffc020067e:	3de50513          	addi	a0,a0,990 # ffffffffc0201a58 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00001517          	auipc	a0,0x1
ffffffffc020068e:	3e650513          	addi	a0,a0,998 # ffffffffc0201a70 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00001517          	auipc	a0,0x1
ffffffffc02006a2:	3ea50513          	addi	a0,a0,1002 # ffffffffc0201a88 <commands+0x618>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76563          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x96>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	f7070713          	addi	a4,a4,-144 # ffffffffc020162c <commands+0x1bc>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	ff250513          	addi	a0,a0,-14 # ffffffffc02016c0 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	fc650513          	addi	a0,a0,-58 # ffffffffc02016a0 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	f7a50513          	addi	a0,a0,-134 # ffffffffc0201660 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	fee50513          	addi	a0,a0,-18 # ffffffffc02016e0 <commands+0x270>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200706:	00005797          	auipc	a5,0x5
ffffffffc020070a:	d2a78793          	addi	a5,a5,-726 # ffffffffc0205430 <ticks>
ffffffffc020070e:	639c                	ld	a5,0(a5)
ffffffffc0200710:	06400713          	li	a4,100
ffffffffc0200714:	0785                	addi	a5,a5,1
ffffffffc0200716:	02e7f733          	remu	a4,a5,a4
ffffffffc020071a:	00005697          	auipc	a3,0x5
ffffffffc020071e:	d0f6bb23          	sd	a5,-746(a3) # ffffffffc0205430 <ticks>
ffffffffc0200722:	c315                	beqz	a4,ffffffffc0200746 <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200724:	60a2                	ld	ra,8(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	fde50513          	addi	a0,a0,-34 # ffffffffc0201708 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	f4a50513          	addi	a0,a0,-182 # ffffffffc0201680 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	fac50513          	addi	a0,a0,-84 # ffffffffc02016f8 <commands+0x288>
}
ffffffffc0200754:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200756:	961ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020075a <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075a:	11853783          	ld	a5,280(a0)
ffffffffc020075e:	0007c863          	bltz	a5,ffffffffc020076e <trap+0x14>
    switch (tf->cause) {
ffffffffc0200762:	472d                	li	a4,11
ffffffffc0200764:	00f76363          	bltu	a4,a5,ffffffffc020076a <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200768:	8082                	ret
            print_trapframe(tf);
ffffffffc020076a:	ee1ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc020076e:	f3fff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc0200774 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200774:	14011073          	csrw	sscratch,sp
ffffffffc0200778:	712d                	addi	sp,sp,-288
ffffffffc020077a:	e002                	sd	zero,0(sp)
ffffffffc020077c:	e406                	sd	ra,8(sp)
ffffffffc020077e:	ec0e                	sd	gp,24(sp)
ffffffffc0200780:	f012                	sd	tp,32(sp)
ffffffffc0200782:	f416                	sd	t0,40(sp)
ffffffffc0200784:	f81a                	sd	t1,48(sp)
ffffffffc0200786:	fc1e                	sd	t2,56(sp)
ffffffffc0200788:	e0a2                	sd	s0,64(sp)
ffffffffc020078a:	e4a6                	sd	s1,72(sp)
ffffffffc020078c:	e8aa                	sd	a0,80(sp)
ffffffffc020078e:	ecae                	sd	a1,88(sp)
ffffffffc0200790:	f0b2                	sd	a2,96(sp)
ffffffffc0200792:	f4b6                	sd	a3,104(sp)
ffffffffc0200794:	f8ba                	sd	a4,112(sp)
ffffffffc0200796:	fcbe                	sd	a5,120(sp)
ffffffffc0200798:	e142                	sd	a6,128(sp)
ffffffffc020079a:	e546                	sd	a7,136(sp)
ffffffffc020079c:	e94a                	sd	s2,144(sp)
ffffffffc020079e:	ed4e                	sd	s3,152(sp)
ffffffffc02007a0:	f152                	sd	s4,160(sp)
ffffffffc02007a2:	f556                	sd	s5,168(sp)
ffffffffc02007a4:	f95a                	sd	s6,176(sp)
ffffffffc02007a6:	fd5e                	sd	s7,184(sp)
ffffffffc02007a8:	e1e2                	sd	s8,192(sp)
ffffffffc02007aa:	e5e6                	sd	s9,200(sp)
ffffffffc02007ac:	e9ea                	sd	s10,208(sp)
ffffffffc02007ae:	edee                	sd	s11,216(sp)
ffffffffc02007b0:	f1f2                	sd	t3,224(sp)
ffffffffc02007b2:	f5f6                	sd	t4,232(sp)
ffffffffc02007b4:	f9fa                	sd	t5,240(sp)
ffffffffc02007b6:	fdfe                	sd	t6,248(sp)
ffffffffc02007b8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007bc:	100024f3          	csrr	s1,sstatus
ffffffffc02007c0:	14102973          	csrr	s2,sepc
ffffffffc02007c4:	143029f3          	csrr	s3,stval
ffffffffc02007c8:	14202a73          	csrr	s4,scause
ffffffffc02007cc:	e822                	sd	s0,16(sp)
ffffffffc02007ce:	e226                	sd	s1,256(sp)
ffffffffc02007d0:	e64a                	sd	s2,264(sp)
ffffffffc02007d2:	ea4e                	sd	s3,272(sp)
ffffffffc02007d4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d8:	f83ff0ef          	jal	ra,ffffffffc020075a <trap>

ffffffffc02007dc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007dc:	6492                	ld	s1,256(sp)
ffffffffc02007de:	6932                	ld	s2,264(sp)
ffffffffc02007e0:	10049073          	csrw	sstatus,s1
ffffffffc02007e4:	14191073          	csrw	sepc,s2
ffffffffc02007e8:	60a2                	ld	ra,8(sp)
ffffffffc02007ea:	61e2                	ld	gp,24(sp)
ffffffffc02007ec:	7202                	ld	tp,32(sp)
ffffffffc02007ee:	72a2                	ld	t0,40(sp)
ffffffffc02007f0:	7342                	ld	t1,48(sp)
ffffffffc02007f2:	73e2                	ld	t2,56(sp)
ffffffffc02007f4:	6406                	ld	s0,64(sp)
ffffffffc02007f6:	64a6                	ld	s1,72(sp)
ffffffffc02007f8:	6546                	ld	a0,80(sp)
ffffffffc02007fa:	65e6                	ld	a1,88(sp)
ffffffffc02007fc:	7606                	ld	a2,96(sp)
ffffffffc02007fe:	76a6                	ld	a3,104(sp)
ffffffffc0200800:	7746                	ld	a4,112(sp)
ffffffffc0200802:	77e6                	ld	a5,120(sp)
ffffffffc0200804:	680a                	ld	a6,128(sp)
ffffffffc0200806:	68aa                	ld	a7,136(sp)
ffffffffc0200808:	694a                	ld	s2,144(sp)
ffffffffc020080a:	69ea                	ld	s3,152(sp)
ffffffffc020080c:	7a0a                	ld	s4,160(sp)
ffffffffc020080e:	7aaa                	ld	s5,168(sp)
ffffffffc0200810:	7b4a                	ld	s6,176(sp)
ffffffffc0200812:	7bea                	ld	s7,184(sp)
ffffffffc0200814:	6c0e                	ld	s8,192(sp)
ffffffffc0200816:	6cae                	ld	s9,200(sp)
ffffffffc0200818:	6d4e                	ld	s10,208(sp)
ffffffffc020081a:	6dee                	ld	s11,216(sp)
ffffffffc020081c:	7e0e                	ld	t3,224(sp)
ffffffffc020081e:	7eae                	ld	t4,232(sp)
ffffffffc0200820:	7f4e                	ld	t5,240(sp)
ffffffffc0200822:	7fee                	ld	t6,248(sp)
ffffffffc0200824:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200826:	10200073          	sret

ffffffffc020082a <buddy_system_init>:
#define nr_free(i) free_area[(i)].nr_free
#define IS_POWER_OF_2(x) (!((x)&((x)-1)))

static void
buddy_system_init(void) {
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc020082a:	00005797          	auipc	a5,0x5
ffffffffc020082e:	c0e78793          	addi	a5,a5,-1010 # ffffffffc0205438 <free_area>
ffffffffc0200832:	00005717          	auipc	a4,0x5
ffffffffc0200836:	d0e70713          	addi	a4,a4,-754 # ffffffffc0205540 <satp_physical>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020083a:	e79c                	sd	a5,8(a5)
ffffffffc020083c:	e39c                	sd	a5,0(a5)
        list_init(&(free_area[i].free_list));
        free_area[i].nr_free = 0;
ffffffffc020083e:	0007a823          	sw	zero,16(a5)
ffffffffc0200842:	07e1                	addi	a5,a5,24
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200844:	fee79be3          	bne	a5,a4,ffffffffc020083a <buddy_system_init+0x10>
    }
    
}
ffffffffc0200848:	8082                	ret

ffffffffc020084a <add_page>:
    return page;
}


static void add_page(uint32_t order, struct Page* base) {
    if (list_empty(&(free_list(order)))) {
ffffffffc020084a:	1502                	slli	a0,a0,0x20
ffffffffc020084c:	9101                	srli	a0,a0,0x20
ffffffffc020084e:	00151713          	slli	a4,a0,0x1
ffffffffc0200852:	972a                	add	a4,a4,a0
ffffffffc0200854:	00005797          	auipc	a5,0x5
ffffffffc0200858:	be478793          	addi	a5,a5,-1052 # ffffffffc0205438 <free_area>
ffffffffc020085c:	070e                	slli	a4,a4,0x3
ffffffffc020085e:	973e                	add	a4,a4,a5
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc0200860:	671c                	ld	a5,8(a4)
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &(free_list(order))) {
                list_add(le, &(base->page_link));
ffffffffc0200862:	01858613          	addi	a2,a1,24
    if (list_empty(&(free_list(order)))) {
ffffffffc0200866:	04f70063          	beq	a4,a5,ffffffffc02008a6 <add_page+0x5c>
            struct Page* page = le2page(le, page_link);
ffffffffc020086a:	fe878693          	addi	a3,a5,-24
        while ((le = list_next(le)) != &(free_list(order))) {
ffffffffc020086e:	00f70c63          	beq	a4,a5,ffffffffc0200886 <add_page+0x3c>
            if (base < page) {
ffffffffc0200872:	02d5e263          	bltu	a1,a3,ffffffffc0200896 <add_page+0x4c>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200876:	6794                	ld	a3,8(a5)
            } else if (list_next(le) == &(free_list(order))) {
ffffffffc0200878:	00d70863          	beq	a4,a3,ffffffffc0200888 <add_page+0x3e>
static void add_page(uint32_t order, struct Page* base) {
ffffffffc020087c:	87b6                	mv	a5,a3
            struct Page* page = le2page(le, page_link);
ffffffffc020087e:	fe878693          	addi	a3,a5,-24
        while ((le = list_next(le)) != &(free_list(order))) {
ffffffffc0200882:	fef718e3          	bne	a4,a5,ffffffffc0200872 <add_page+0x28>
            }
        }
    }
}
ffffffffc0200886:	8082                	ret
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200888:	e310                	sd	a2,0(a4)
ffffffffc020088a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020088c:	f198                	sd	a4,32(a1)
    elm->prev = prev;
ffffffffc020088e:	6794                	ld	a3,8(a5)
ffffffffc0200890:	ed9c                	sd	a5,24(a1)
static void add_page(uint32_t order, struct Page* base) {
ffffffffc0200892:	87b6                	mv	a5,a3
ffffffffc0200894:	b7ed                	j	ffffffffc020087e <add_page+0x34>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200896:	6398                	ld	a4,0(a5)
                list_add_before(le, &(base->page_link));
ffffffffc0200898:	01858693          	addi	a3,a1,24
    prev->next = next->prev = elm;
ffffffffc020089c:	e394                	sd	a3,0(a5)
ffffffffc020089e:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc02008a0:	f19c                	sd	a5,32(a1)
    elm->prev = prev;
ffffffffc02008a2:	ed98                	sd	a4,24(a1)
ffffffffc02008a4:	8082                	ret
        list_add(&(free_list(order)), &(base->page_link));
ffffffffc02008a6:	01858793          	addi	a5,a1,24
    prev->next = next->prev = elm;
ffffffffc02008aa:	e31c                	sd	a5,0(a4)
ffffffffc02008ac:	e71c                	sd	a5,8(a4)
    elm->next = next;
ffffffffc02008ae:	f198                	sd	a4,32(a1)
    elm->prev = prev;
ffffffffc02008b0:	ed98                	sd	a4,24(a1)
ffffffffc02008b2:	8082                	ret

ffffffffc02008b4 <buddy_system_nr_free_pages>:
}

static size_t
buddy_system_nr_free_pages(void) {
    size_t num = 0;
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc02008b4:	00005697          	auipc	a3,0x5
ffffffffc02008b8:	b9468693          	addi	a3,a3,-1132 # ffffffffc0205448 <free_area+0x10>
ffffffffc02008bc:	4701                	li	a4,0
    size_t num = 0;
ffffffffc02008be:	4501                	li	a0,0
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc02008c0:	462d                	li	a2,11
        num += nr_free(i) << i;
ffffffffc02008c2:	429c                	lw	a5,0(a3)
ffffffffc02008c4:	06e1                	addi	a3,a3,24
ffffffffc02008c6:	00e797bb          	sllw	a5,a5,a4
ffffffffc02008ca:	1782                	slli	a5,a5,0x20
ffffffffc02008cc:	9381                	srli	a5,a5,0x20
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc02008ce:	2705                	addiw	a4,a4,1
        num += nr_free(i) << i;
ffffffffc02008d0:	953e                	add	a0,a0,a5
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc02008d2:	fec718e3          	bne	a4,a2,ffffffffc02008c2 <buddy_system_nr_free_pages+0xe>
    }
    return num;
}
ffffffffc02008d6:	8082                	ret

ffffffffc02008d8 <buddy_system_check>:
    free_page(p);
    free_page(p1);
    free_page(p2);
}
static void
buddy_system_check(void) {}
ffffffffc02008d8:	8082                	ret

ffffffffc02008da <buddy_system_free_pages>:
buddy_system_free_pages(struct Page *base, size_t n) {
ffffffffc02008da:	7139                	addi	sp,sp,-64
ffffffffc02008dc:	fc06                	sd	ra,56(sp)
ffffffffc02008de:	f822                	sd	s0,48(sp)
ffffffffc02008e0:	f426                	sd	s1,40(sp)
ffffffffc02008e2:	f04a                	sd	s2,32(sp)
ffffffffc02008e4:	ec4e                	sd	s3,24(sp)
ffffffffc02008e6:	e852                	sd	s4,16(sp)
ffffffffc02008e8:	e456                	sd	s5,8(sp)
    assert(n > 0);
ffffffffc02008ea:	1a058463          	beqz	a1,ffffffffc0200a92 <buddy_system_free_pages+0x1b8>
    assert(IS_POWER_OF_2(n));
ffffffffc02008ee:	fff58793          	addi	a5,a1,-1
ffffffffc02008f2:	8fed                	and	a5,a5,a1
ffffffffc02008f4:	16079f63          	bnez	a5,ffffffffc0200a72 <buddy_system_free_pages+0x198>
    for (; p != base + n; p ++) {
ffffffffc02008f8:	00259693          	slli	a3,a1,0x2
ffffffffc02008fc:	96ae                	add	a3,a3,a1
ffffffffc02008fe:	068e                	slli	a3,a3,0x3
ffffffffc0200900:	96aa                	add	a3,a3,a0
ffffffffc0200902:	892a                	mv	s2,a0
ffffffffc0200904:	02d50d63          	beq	a0,a3,ffffffffc020093e <buddy_system_free_pages+0x64>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200908:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020090a:	8b85                	andi	a5,a5,1
ffffffffc020090c:	14079363          	bnez	a5,ffffffffc0200a52 <buddy_system_free_pages+0x178>
ffffffffc0200910:	651c                	ld	a5,8(a0)
ffffffffc0200912:	8385                	srli	a5,a5,0x1
ffffffffc0200914:	8b85                	andi	a5,a5,1
ffffffffc0200916:	12079e63          	bnez	a5,ffffffffc0200a52 <buddy_system_free_pages+0x178>
ffffffffc020091a:	87aa                	mv	a5,a0
ffffffffc020091c:	a809                	j	ffffffffc020092e <buddy_system_free_pages+0x54>
ffffffffc020091e:	6798                	ld	a4,8(a5)
ffffffffc0200920:	8b05                	andi	a4,a4,1
ffffffffc0200922:	12071863          	bnez	a4,ffffffffc0200a52 <buddy_system_free_pages+0x178>
ffffffffc0200926:	6798                	ld	a4,8(a5)
ffffffffc0200928:	8b09                	andi	a4,a4,2
ffffffffc020092a:	12071463          	bnez	a4,ffffffffc0200a52 <buddy_system_free_pages+0x178>
        p->flags = 0;
ffffffffc020092e:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200932:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200936:	02878793          	addi	a5,a5,40
ffffffffc020093a:	fed792e3          	bne	a5,a3,ffffffffc020091e <buddy_system_free_pages+0x44>
    base->property = n;
ffffffffc020093e:	00b92823          	sw	a1,16(s2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200942:	4789                	li	a5,2
ffffffffc0200944:	00890713          	addi	a4,s2,8
ffffffffc0200948:	40f7302f          	amoor.d	zero,a5,(a4)
    while (temp != 1) {
ffffffffc020094c:	4705                	li	a4,1
    uint32_t order = 0;
ffffffffc020094e:	4481                	li	s1,0
    while (temp != 1) {
ffffffffc0200950:	4785                	li	a5,1
ffffffffc0200952:	0ee58b63          	beq	a1,a4,ffffffffc0200a48 <buddy_system_free_pages+0x16e>
        temp >>= 1;
ffffffffc0200956:	8185                	srli	a1,a1,0x1
        order++;
ffffffffc0200958:	2485                	addiw	s1,s1,1
    while (temp != 1) {
ffffffffc020095a:	fef59ee3          	bne	a1,a5,ffffffffc0200956 <buddy_system_free_pages+0x7c>
    add_page(order,base);
ffffffffc020095e:	85ca                	mv	a1,s2
ffffffffc0200960:	8526                	mv	a0,s1
ffffffffc0200962:	ee9ff0ef          	jal	ra,ffffffffc020084a <add_page>
    if (order == MAX_ORDER - 1) {
ffffffffc0200966:	47a9                	li	a5,10
ffffffffc0200968:	06f48763          	beq	s1,a5,ffffffffc02009d6 <buddy_system_free_pages+0xfc>
ffffffffc020096c:	00005a97          	auipc	s5,0x5
ffffffffc0200970:	acca8a93          	addi	s5,s5,-1332 # ffffffffc0205438 <free_area>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200974:	59f5                	li	s3,-3
ffffffffc0200976:	4a29                	li	s4,10
    if (le != &(free_list(order))) {
ffffffffc0200978:	02049793          	slli	a5,s1,0x20
ffffffffc020097c:	9381                	srli	a5,a5,0x20
ffffffffc020097e:	00179413          	slli	s0,a5,0x1
ffffffffc0200982:	943e                	add	s0,s0,a5
    return listelm->prev;
ffffffffc0200984:	01893703          	ld	a4,24(s2)
ffffffffc0200988:	040e                	slli	s0,s0,0x3
ffffffffc020098a:	9456                	add	s0,s0,s5
ffffffffc020098c:	2485                	addiw	s1,s1,1
ffffffffc020098e:	02870063          	beq	a4,s0,ffffffffc02009ae <buddy_system_free_pages+0xd4>
        if (p + p->property == base) {
ffffffffc0200992:	ff872603          	lw	a2,-8(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc0200996:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc020099a:	02061693          	slli	a3,a2,0x20
ffffffffc020099e:	9281                	srli	a3,a3,0x20
ffffffffc02009a0:	00269793          	slli	a5,a3,0x2
ffffffffc02009a4:	97b6                	add	a5,a5,a3
ffffffffc02009a6:	078e                	slli	a5,a5,0x3
ffffffffc02009a8:	97ae                	add	a5,a5,a1
ffffffffc02009aa:	06f90963          	beq	s2,a5,ffffffffc0200a1c <buddy_system_free_pages+0x142>
    return listelm->next;
ffffffffc02009ae:	02093703          	ld	a4,32(s2)
    if (le != &(free_list(order))) {
ffffffffc02009b2:	02e40063          	beq	s0,a4,ffffffffc02009d2 <buddy_system_free_pages+0xf8>
        if (base + base->property == p) {
ffffffffc02009b6:	01092583          	lw	a1,16(s2)
        struct Page *p = le2page(le, page_link);
ffffffffc02009ba:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc02009be:	02059613          	slli	a2,a1,0x20
ffffffffc02009c2:	9201                	srli	a2,a2,0x20
ffffffffc02009c4:	00261793          	slli	a5,a2,0x2
ffffffffc02009c8:	97b2                	add	a5,a5,a2
ffffffffc02009ca:	078e                	slli	a5,a5,0x3
ffffffffc02009cc:	97ca                	add	a5,a5,s2
ffffffffc02009ce:	00f68d63          	beq	a3,a5,ffffffffc02009e8 <buddy_system_free_pages+0x10e>
    if (order == MAX_ORDER - 1) {
ffffffffc02009d2:	fb4493e3          	bne	s1,s4,ffffffffc0200978 <buddy_system_free_pages+0x9e>
}
ffffffffc02009d6:	70e2                	ld	ra,56(sp)
ffffffffc02009d8:	7442                	ld	s0,48(sp)
ffffffffc02009da:	74a2                	ld	s1,40(sp)
ffffffffc02009dc:	7902                	ld	s2,32(sp)
ffffffffc02009de:	69e2                	ld	s3,24(sp)
ffffffffc02009e0:	6a42                	ld	s4,16(sp)
ffffffffc02009e2:	6aa2                	ld	s5,8(sp)
ffffffffc02009e4:	6121                	addi	sp,sp,64
ffffffffc02009e6:	8082                	ret
            base->property += p->property;
ffffffffc02009e8:	ff872783          	lw	a5,-8(a4)
ffffffffc02009ec:	9dbd                	addw	a1,a1,a5
ffffffffc02009ee:	00b92823          	sw	a1,16(s2)
ffffffffc02009f2:	ff070793          	addi	a5,a4,-16
ffffffffc02009f6:	6137b02f          	amoand.d	zero,s3,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02009fa:	671c                	ld	a5,8(a4)
ffffffffc02009fc:	6314                	ld	a3,0(a4)
            add_page(order+1,base);
ffffffffc02009fe:	85ca                	mv	a1,s2
ffffffffc0200a00:	8526                	mv	a0,s1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200a02:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200a04:	e394                	sd	a3,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200a06:	01893703          	ld	a4,24(s2)
ffffffffc0200a0a:	02093783          	ld	a5,32(s2)
    prev->next = next;
ffffffffc0200a0e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200a10:	e398                	sd	a4,0(a5)
ffffffffc0200a12:	e39ff0ef          	jal	ra,ffffffffc020084a <add_page>
    if (order == MAX_ORDER - 1) {
ffffffffc0200a16:	f74491e3          	bne	s1,s4,ffffffffc0200978 <buddy_system_free_pages+0x9e>
ffffffffc0200a1a:	bf75                	j	ffffffffc02009d6 <buddy_system_free_pages+0xfc>
            p->property += base->property;
ffffffffc0200a1c:	01092783          	lw	a5,16(s2)
ffffffffc0200a20:	9e3d                	addw	a2,a2,a5
ffffffffc0200a22:	fec72c23          	sw	a2,-8(a4)
ffffffffc0200a26:	00890793          	addi	a5,s2,8
ffffffffc0200a2a:	6137b02f          	amoand.d	zero,s3,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200a2e:	02093783          	ld	a5,32(s2)
                add_page(order+1,base);
ffffffffc0200a32:	8526                	mv	a0,s1
            base = p;
ffffffffc0200a34:	892e                	mv	s2,a1
    prev->next = next;
ffffffffc0200a36:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200a38:	e398                	sd	a4,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200a3a:	6314                	ld	a3,0(a4)
ffffffffc0200a3c:	671c                	ld	a5,8(a4)
    prev->next = next;
ffffffffc0200a3e:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200a40:	e394                	sd	a3,0(a5)
                add_page(order+1,base);
ffffffffc0200a42:	e09ff0ef          	jal	ra,ffffffffc020084a <add_page>
ffffffffc0200a46:	b7a5                	j	ffffffffc02009ae <buddy_system_free_pages+0xd4>
    add_page(order,base);
ffffffffc0200a48:	85ca                	mv	a1,s2
ffffffffc0200a4a:	4501                	li	a0,0
ffffffffc0200a4c:	dffff0ef          	jal	ra,ffffffffc020084a <add_page>
    if (order == MAX_ORDER - 1) {
ffffffffc0200a50:	bf31                	j	ffffffffc020096c <buddy_system_free_pages+0x92>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200a52:	00001697          	auipc	a3,0x1
ffffffffc0200a56:	08e68693          	addi	a3,a3,142 # ffffffffc0201ae0 <commands+0x670>
ffffffffc0200a5a:	00001617          	auipc	a2,0x1
ffffffffc0200a5e:	04e60613          	addi	a2,a2,78 # ffffffffc0201aa8 <commands+0x638>
ffffffffc0200a62:	0a000593          	li	a1,160
ffffffffc0200a66:	00001517          	auipc	a0,0x1
ffffffffc0200a6a:	05a50513          	addi	a0,a0,90 # ffffffffc0201ac0 <commands+0x650>
ffffffffc0200a6e:	93fff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(IS_POWER_OF_2(n));
ffffffffc0200a72:	00001697          	auipc	a3,0x1
ffffffffc0200a76:	09668693          	addi	a3,a3,150 # ffffffffc0201b08 <commands+0x698>
ffffffffc0200a7a:	00001617          	auipc	a2,0x1
ffffffffc0200a7e:	02e60613          	addi	a2,a2,46 # ffffffffc0201aa8 <commands+0x638>
ffffffffc0200a82:	09d00593          	li	a1,157
ffffffffc0200a86:	00001517          	auipc	a0,0x1
ffffffffc0200a8a:	03a50513          	addi	a0,a0,58 # ffffffffc0201ac0 <commands+0x650>
ffffffffc0200a8e:	91fff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200a92:	00001697          	auipc	a3,0x1
ffffffffc0200a96:	00e68693          	addi	a3,a3,14 # ffffffffc0201aa0 <commands+0x630>
ffffffffc0200a9a:	00001617          	auipc	a2,0x1
ffffffffc0200a9e:	00e60613          	addi	a2,a2,14 # ffffffffc0201aa8 <commands+0x638>
ffffffffc0200aa2:	09c00593          	li	a1,156
ffffffffc0200aa6:	00001517          	auipc	a0,0x1
ffffffffc0200aaa:	01a50513          	addi	a0,a0,26 # ffffffffc0201ac0 <commands+0x650>
ffffffffc0200aae:	8ffff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200ab2 <buddy_system_alloc_pages>:
    assert(n > 0);
ffffffffc0200ab2:	c119                	beqz	a0,ffffffffc0200ab8 <buddy_system_alloc_pages+0x6>
}
ffffffffc0200ab4:	4501                	li	a0,0
ffffffffc0200ab6:	8082                	ret
buddy_system_alloc_pages(size_t n) {
ffffffffc0200ab8:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200aba:	00001697          	auipc	a3,0x1
ffffffffc0200abe:	fe668693          	addi	a3,a3,-26 # ffffffffc0201aa0 <commands+0x630>
ffffffffc0200ac2:	00001617          	auipc	a2,0x1
ffffffffc0200ac6:	fe660613          	addi	a2,a2,-26 # ffffffffc0201aa8 <commands+0x638>
ffffffffc0200aca:	04c00593          	li	a1,76
ffffffffc0200ace:	00001517          	auipc	a0,0x1
ffffffffc0200ad2:	ff250513          	addi	a0,a0,-14 # ffffffffc0201ac0 <commands+0x650>
buddy_system_alloc_pages(size_t n) {
ffffffffc0200ad6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200ad8:	8d5ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200adc <buddy_system_init_memmap>:
buddy_system_init_memmap(struct Page *base, size_t n) {
ffffffffc0200adc:	7139                	addi	sp,sp,-64
ffffffffc0200ade:	f04a                	sd	s2,32(sp)
ffffffffc0200ae0:	e05a                	sd	s6,0(sp)
ffffffffc0200ae2:	892e                	mv	s2,a1
ffffffffc0200ae4:	8b2a                	mv	s6,a0
    cprintf("12\n");
ffffffffc0200ae6:	00001517          	auipc	a0,0x1
ffffffffc0200aea:	03a50513          	addi	a0,a0,58 # ffffffffc0201b20 <commands+0x6b0>
buddy_system_init_memmap(struct Page *base, size_t n) {
ffffffffc0200aee:	fc06                	sd	ra,56(sp)
ffffffffc0200af0:	f822                	sd	s0,48(sp)
ffffffffc0200af2:	f426                	sd	s1,40(sp)
ffffffffc0200af4:	ec4e                	sd	s3,24(sp)
ffffffffc0200af6:	e852                	sd	s4,16(sp)
ffffffffc0200af8:	e456                	sd	s5,8(sp)
    cprintf("12\n");
ffffffffc0200afa:	dbcff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert(n > 0);
ffffffffc0200afe:	0e090b63          	beqz	s2,ffffffffc0200bf4 <buddy_system_init_memmap+0x118>
    for (; p != base + n; p ++) {
ffffffffc0200b02:	00291693          	slli	a3,s2,0x2
ffffffffc0200b06:	96ca                	add	a3,a3,s2
ffffffffc0200b08:	068e                	slli	a3,a3,0x3
ffffffffc0200b0a:	96da                	add	a3,a3,s6
ffffffffc0200b0c:	02db0563          	beq	s6,a3,ffffffffc0200b36 <buddy_system_init_memmap+0x5a>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b10:	008b3703          	ld	a4,8(s6)
        assert(PageReserved(p));
ffffffffc0200b14:	87da                	mv	a5,s6
ffffffffc0200b16:	8b05                	andi	a4,a4,1
ffffffffc0200b18:	e709                	bnez	a4,ffffffffc0200b22 <buddy_system_init_memmap+0x46>
ffffffffc0200b1a:	a875                	j	ffffffffc0200bd6 <buddy_system_init_memmap+0xfa>
ffffffffc0200b1c:	6798                	ld	a4,8(a5)
ffffffffc0200b1e:	8b05                	andi	a4,a4,1
ffffffffc0200b20:	cb5d                	beqz	a4,ffffffffc0200bd6 <buddy_system_init_memmap+0xfa>
        p->flags = p->property = 0;
ffffffffc0200b22:	0007a823          	sw	zero,16(a5)
ffffffffc0200b26:	0007b423          	sd	zero,8(a5)
ffffffffc0200b2a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200b2e:	02878793          	addi	a5,a5,40
ffffffffc0200b32:	fed795e3          	bne	a5,a3,ffffffffc0200b1c <buddy_system_init_memmap+0x40>
    uint32_t order = MAX_ORDER - 1;
ffffffffc0200b36:	4429                	li	s0,10
    uint32_t order_size = 1 << order;
ffffffffc0200b38:	40000493          	li	s1,1024
ffffffffc0200b3c:	00005a97          	auipc	s5,0x5
ffffffffc0200b40:	8fca8a93          	addi	s5,s5,-1796 # ffffffffc0205438 <free_area>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200b44:	4a09                	li	s4,2
        cprintf("curr_size: %u\n",curr_size);
ffffffffc0200b46:	00001997          	auipc	s3,0x1
ffffffffc0200b4a:	ff298993          	addi	s3,s3,-14 # ffffffffc0201b38 <commands+0x6c8>
        p->property = order_size;
ffffffffc0200b4e:	009b2823          	sw	s1,16(s6)
ffffffffc0200b52:	008b0793          	addi	a5,s6,8
ffffffffc0200b56:	4147b02f          	amoor.d	zero,s4,(a5)
        nr_free(order) += 1;
ffffffffc0200b5a:	02041793          	slli	a5,s0,0x20
ffffffffc0200b5e:	9381                	srli	a5,a5,0x20
ffffffffc0200b60:	00179713          	slli	a4,a5,0x1
ffffffffc0200b64:	973e                	add	a4,a4,a5
ffffffffc0200b66:	070e                	slli	a4,a4,0x3
ffffffffc0200b68:	9756                	add	a4,a4,s5
ffffffffc0200b6a:	4b14                	lw	a3,16(a4)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200b6c:	6310                	ld	a2,0(a4)
        list_add_before(&(free_list(order)), &(p->page_link));
ffffffffc0200b6e:	018b0793          	addi	a5,s6,24
        nr_free(order) += 1;
ffffffffc0200b72:	2685                	addiw	a3,a3,1
    prev->next = next->prev = elm;
ffffffffc0200b74:	e31c                	sd	a5,0(a4)
ffffffffc0200b76:	cb14                	sw	a3,16(a4)
ffffffffc0200b78:	e61c                	sd	a5,8(a2)
        curr_size -= order_size;
ffffffffc0200b7a:	02049793          	slli	a5,s1,0x20
ffffffffc0200b7e:	9381                	srli	a5,a5,0x20
    elm->next = next;
ffffffffc0200b80:	02eb3023          	sd	a4,32(s6)
    elm->prev = prev;
ffffffffc0200b84:	00cb3c23          	sd	a2,24(s6)
ffffffffc0200b88:	40f90933          	sub	s2,s2,a5
        while(order > 0 && curr_size < order_size) {
ffffffffc0200b8c:	c819                	beqz	s0,ffffffffc0200ba2 <buddy_system_init_memmap+0xc6>
ffffffffc0200b8e:	00f97a63          	bleu	a5,s2,ffffffffc0200ba2 <buddy_system_init_memmap+0xc6>
            order_size >>= 1;
ffffffffc0200b92:	0014d79b          	srliw	a5,s1,0x1
ffffffffc0200b96:	0007849b          	sext.w	s1,a5
            order -= 1;
ffffffffc0200b9a:	347d                	addiw	s0,s0,-1
ffffffffc0200b9c:	1782                	slli	a5,a5,0x20
ffffffffc0200b9e:	9381                	srli	a5,a5,0x20
        while(order > 0 && curr_size < order_size) {
ffffffffc0200ba0:	f47d                	bnez	s0,ffffffffc0200b8e <buddy_system_init_memmap+0xb2>
        p += order_size;
ffffffffc0200ba2:	00279713          	slli	a4,a5,0x2
ffffffffc0200ba6:	97ba                	add	a5,a5,a4
ffffffffc0200ba8:	078e                	slli	a5,a5,0x3
        cprintf("curr_size: %u\n",curr_size);
ffffffffc0200baa:	85ca                	mv	a1,s2
ffffffffc0200bac:	854e                	mv	a0,s3
        p += order_size;
ffffffffc0200bae:	9b3e                	add	s6,s6,a5
        cprintf("curr_size: %u\n",curr_size);
ffffffffc0200bb0:	d06ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    while (curr_size != 0) {
ffffffffc0200bb4:	f8091de3          	bnez	s2,ffffffffc0200b4e <buddy_system_init_memmap+0x72>
}
ffffffffc0200bb8:	7442                	ld	s0,48(sp)
ffffffffc0200bba:	70e2                	ld	ra,56(sp)
ffffffffc0200bbc:	74a2                	ld	s1,40(sp)
ffffffffc0200bbe:	7902                	ld	s2,32(sp)
ffffffffc0200bc0:	69e2                	ld	s3,24(sp)
ffffffffc0200bc2:	6a42                	ld	s4,16(sp)
ffffffffc0200bc4:	6aa2                	ld	s5,8(sp)
ffffffffc0200bc6:	6b02                	ld	s6,0(sp)
    cprintf("112\n");
ffffffffc0200bc8:	00001517          	auipc	a0,0x1
ffffffffc0200bcc:	f8050513          	addi	a0,a0,-128 # ffffffffc0201b48 <commands+0x6d8>
}
ffffffffc0200bd0:	6121                	addi	sp,sp,64
    cprintf("112\n");
ffffffffc0200bd2:	ce4ff06f          	j	ffffffffc02000b6 <cprintf>
        assert(PageReserved(p));
ffffffffc0200bd6:	00001697          	auipc	a3,0x1
ffffffffc0200bda:	f5268693          	addi	a3,a3,-174 # ffffffffc0201b28 <commands+0x6b8>
ffffffffc0200bde:	00001617          	auipc	a2,0x1
ffffffffc0200be2:	eca60613          	addi	a2,a2,-310 # ffffffffc0201aa8 <commands+0x638>
ffffffffc0200be6:	45fd                	li	a1,31
ffffffffc0200be8:	00001517          	auipc	a0,0x1
ffffffffc0200bec:	ed850513          	addi	a0,a0,-296 # ffffffffc0201ac0 <commands+0x650>
ffffffffc0200bf0:	fbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200bf4:	00001697          	auipc	a3,0x1
ffffffffc0200bf8:	eac68693          	addi	a3,a3,-340 # ffffffffc0201aa0 <commands+0x630>
ffffffffc0200bfc:	00001617          	auipc	a2,0x1
ffffffffc0200c00:	eac60613          	addi	a2,a2,-340 # ffffffffc0201aa8 <commands+0x638>
ffffffffc0200c04:	45f1                	li	a1,28
ffffffffc0200c06:	00001517          	auipc	a0,0x1
ffffffffc0200c0a:	eba50513          	addi	a0,a0,-326 # ffffffffc0201ac0 <commands+0x650>
ffffffffc0200c0e:	f9eff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200c12 <pmm_init>:
static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    // pmm_manager = &best_fit_pmm_manager;
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200c12:	00001797          	auipc	a5,0x1
ffffffffc0200c16:	f3e78793          	addi	a5,a5,-194 # ffffffffc0201b50 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200c1a:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200c1c:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200c1e:	00001517          	auipc	a0,0x1
ffffffffc0200c22:	f8250513          	addi	a0,a0,-126 # ffffffffc0201ba0 <buddy_system_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc0200c26:	ec06                	sd	ra,24(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200c28:	00005717          	auipc	a4,0x5
ffffffffc0200c2c:	92f73023          	sd	a5,-1760(a4) # ffffffffc0205548 <pmm_manager>
void pmm_init(void) {
ffffffffc0200c30:	e822                	sd	s0,16(sp)
ffffffffc0200c32:	e426                	sd	s1,8(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200c34:	00005417          	auipc	s0,0x5
ffffffffc0200c38:	91440413          	addi	s0,s0,-1772 # ffffffffc0205548 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200c3c:	c7aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0200c40:	601c                	ld	a5,0(s0)
ffffffffc0200c42:	679c                	ld	a5,8(a5)
ffffffffc0200c44:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200c46:	57f5                	li	a5,-3
ffffffffc0200c48:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200c4a:	00001517          	auipc	a0,0x1
ffffffffc0200c4e:	f6e50513          	addi	a0,a0,-146 # ffffffffc0201bb8 <buddy_system_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200c52:	00005717          	auipc	a4,0x5
ffffffffc0200c56:	8ef73f23          	sd	a5,-1794(a4) # ffffffffc0205550 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0200c5a:	c5cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200c5e:	46c5                	li	a3,17
ffffffffc0200c60:	06ee                	slli	a3,a3,0x1b
ffffffffc0200c62:	40100613          	li	a2,1025
ffffffffc0200c66:	16fd                	addi	a3,a3,-1
ffffffffc0200c68:	0656                	slli	a2,a2,0x15
ffffffffc0200c6a:	07e005b7          	lui	a1,0x7e00
ffffffffc0200c6e:	00001517          	auipc	a0,0x1
ffffffffc0200c72:	f6250513          	addi	a0,a0,-158 # ffffffffc0201bd0 <buddy_system_pmm_manager+0x80>
ffffffffc0200c76:	c40ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200c7a:	777d                	lui	a4,0xfffff
ffffffffc0200c7c:	00006797          	auipc	a5,0x6
ffffffffc0200c80:	8e378793          	addi	a5,a5,-1821 # ffffffffc020655f <end+0xfff>
ffffffffc0200c84:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200c86:	00088737          	lui	a4,0x88
ffffffffc0200c8a:	00004697          	auipc	a3,0x4
ffffffffc0200c8e:	78e6b723          	sd	a4,1934(a3) # ffffffffc0205418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200c92:	4601                	li	a2,0
ffffffffc0200c94:	00005717          	auipc	a4,0x5
ffffffffc0200c98:	8cf73223          	sd	a5,-1852(a4) # ffffffffc0205558 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200c9c:	4681                	li	a3,0
ffffffffc0200c9e:	00004897          	auipc	a7,0x4
ffffffffc0200ca2:	77a88893          	addi	a7,a7,1914 # ffffffffc0205418 <npage>
ffffffffc0200ca6:	00005597          	auipc	a1,0x5
ffffffffc0200caa:	8b258593          	addi	a1,a1,-1870 # ffffffffc0205558 <pages>
ffffffffc0200cae:	4805                	li	a6,1
ffffffffc0200cb0:	fff80537          	lui	a0,0xfff80
ffffffffc0200cb4:	a011                	j	ffffffffc0200cb8 <pmm_init+0xa6>
ffffffffc0200cb6:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0200cb8:	97b2                	add	a5,a5,a2
ffffffffc0200cba:	07a1                	addi	a5,a5,8
ffffffffc0200cbc:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200cc0:	0008b703          	ld	a4,0(a7)
ffffffffc0200cc4:	0685                	addi	a3,a3,1
ffffffffc0200cc6:	02860613          	addi	a2,a2,40
ffffffffc0200cca:	00a707b3          	add	a5,a4,a0
ffffffffc0200cce:	fef6e4e3          	bltu	a3,a5,ffffffffc0200cb6 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200cd2:	6190                	ld	a2,0(a1)
ffffffffc0200cd4:	00271793          	slli	a5,a4,0x2
ffffffffc0200cd8:	97ba                	add	a5,a5,a4
ffffffffc0200cda:	fec006b7          	lui	a3,0xfec00
ffffffffc0200cde:	078e                	slli	a5,a5,0x3
ffffffffc0200ce0:	96b2                	add	a3,a3,a2
ffffffffc0200ce2:	96be                	add	a3,a3,a5
ffffffffc0200ce4:	c02007b7          	lui	a5,0xc0200
ffffffffc0200ce8:	08f6e863          	bltu	a3,a5,ffffffffc0200d78 <pmm_init+0x166>
ffffffffc0200cec:	00005497          	auipc	s1,0x5
ffffffffc0200cf0:	86448493          	addi	s1,s1,-1948 # ffffffffc0205550 <va_pa_offset>
ffffffffc0200cf4:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0200cf6:	45c5                	li	a1,17
ffffffffc0200cf8:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200cfa:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc0200cfc:	04b6e963          	bltu	a3,a1,ffffffffc0200d4e <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200d00:	601c                	ld	a5,0(s0)
ffffffffc0200d02:	7b9c                	ld	a5,48(a5)
ffffffffc0200d04:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200d06:	00001517          	auipc	a0,0x1
ffffffffc0200d0a:	f6250513          	addi	a0,a0,-158 # ffffffffc0201c68 <buddy_system_pmm_manager+0x118>
ffffffffc0200d0e:	ba8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200d12:	00003697          	auipc	a3,0x3
ffffffffc0200d16:	2ee68693          	addi	a3,a3,750 # ffffffffc0204000 <boot_page_table_sv39>
ffffffffc0200d1a:	00004797          	auipc	a5,0x4
ffffffffc0200d1e:	70d7b323          	sd	a3,1798(a5) # ffffffffc0205420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200d22:	c02007b7          	lui	a5,0xc0200
ffffffffc0200d26:	06f6e563          	bltu	a3,a5,ffffffffc0200d90 <pmm_init+0x17e>
ffffffffc0200d2a:	609c                	ld	a5,0(s1)
}
ffffffffc0200d2c:	6442                	ld	s0,16(sp)
ffffffffc0200d2e:	60e2                	ld	ra,24(sp)
ffffffffc0200d30:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200d32:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc0200d34:	8e9d                	sub	a3,a3,a5
ffffffffc0200d36:	00005797          	auipc	a5,0x5
ffffffffc0200d3a:	80d7b523          	sd	a3,-2038(a5) # ffffffffc0205540 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200d3e:	00001517          	auipc	a0,0x1
ffffffffc0200d42:	f4a50513          	addi	a0,a0,-182 # ffffffffc0201c88 <buddy_system_pmm_manager+0x138>
ffffffffc0200d46:	8636                	mv	a2,a3
}
ffffffffc0200d48:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200d4a:	b6cff06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200d4e:	6785                	lui	a5,0x1
ffffffffc0200d50:	17fd                	addi	a5,a5,-1
ffffffffc0200d52:	96be                	add	a3,a3,a5
ffffffffc0200d54:	77fd                	lui	a5,0xfffff
ffffffffc0200d56:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200d58:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200d5c:	04e7f663          	bleu	a4,a5,ffffffffc0200da8 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0200d60:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200d62:	97aa                	add	a5,a5,a0
ffffffffc0200d64:	00279513          	slli	a0,a5,0x2
ffffffffc0200d68:	953e                	add	a0,a0,a5
ffffffffc0200d6a:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200d6c:	8d95                	sub	a1,a1,a3
ffffffffc0200d6e:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200d70:	81b1                	srli	a1,a1,0xc
ffffffffc0200d72:	9532                	add	a0,a0,a2
ffffffffc0200d74:	9782                	jalr	a5
ffffffffc0200d76:	b769                	j	ffffffffc0200d00 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200d78:	00001617          	auipc	a2,0x1
ffffffffc0200d7c:	e8860613          	addi	a2,a2,-376 # ffffffffc0201c00 <buddy_system_pmm_manager+0xb0>
ffffffffc0200d80:	07100593          	li	a1,113
ffffffffc0200d84:	00001517          	auipc	a0,0x1
ffffffffc0200d88:	ea450513          	addi	a0,a0,-348 # ffffffffc0201c28 <buddy_system_pmm_manager+0xd8>
ffffffffc0200d8c:	e20ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200d90:	00001617          	auipc	a2,0x1
ffffffffc0200d94:	e7060613          	addi	a2,a2,-400 # ffffffffc0201c00 <buddy_system_pmm_manager+0xb0>
ffffffffc0200d98:	08c00593          	li	a1,140
ffffffffc0200d9c:	00001517          	auipc	a0,0x1
ffffffffc0200da0:	e8c50513          	addi	a0,a0,-372 # ffffffffc0201c28 <buddy_system_pmm_manager+0xd8>
ffffffffc0200da4:	e08ff0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200da8:	00001617          	auipc	a2,0x1
ffffffffc0200dac:	e9060613          	addi	a2,a2,-368 # ffffffffc0201c38 <buddy_system_pmm_manager+0xe8>
ffffffffc0200db0:	06b00593          	li	a1,107
ffffffffc0200db4:	00001517          	auipc	a0,0x1
ffffffffc0200db8:	ea450513          	addi	a0,a0,-348 # ffffffffc0201c58 <buddy_system_pmm_manager+0x108>
ffffffffc0200dbc:	df0ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200dc0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0200dc0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200dc4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0200dc6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200dca:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0200dcc:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200dd0:	f022                	sd	s0,32(sp)
ffffffffc0200dd2:	ec26                	sd	s1,24(sp)
ffffffffc0200dd4:	e84a                	sd	s2,16(sp)
ffffffffc0200dd6:	f406                	sd	ra,40(sp)
ffffffffc0200dd8:	e44e                	sd	s3,8(sp)
ffffffffc0200dda:	84aa                	mv	s1,a0
ffffffffc0200ddc:	892e                	mv	s2,a1
ffffffffc0200dde:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0200de2:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0200de4:	03067e63          	bleu	a6,a2,ffffffffc0200e20 <printnum+0x60>
ffffffffc0200de8:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0200dea:	00805763          	blez	s0,ffffffffc0200df8 <printnum+0x38>
ffffffffc0200dee:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0200df0:	85ca                	mv	a1,s2
ffffffffc0200df2:	854e                	mv	a0,s3
ffffffffc0200df4:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0200df6:	fc65                	bnez	s0,ffffffffc0200dee <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200df8:	1a02                	slli	s4,s4,0x20
ffffffffc0200dfa:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200dfe:	00001797          	auipc	a5,0x1
ffffffffc0200e02:	05a78793          	addi	a5,a5,90 # ffffffffc0201e58 <error_string+0x38>
ffffffffc0200e06:	9a3e                	add	s4,s4,a5
}
ffffffffc0200e08:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200e0a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0200e0e:	70a2                	ld	ra,40(sp)
ffffffffc0200e10:	69a2                	ld	s3,8(sp)
ffffffffc0200e12:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200e14:	85ca                	mv	a1,s2
ffffffffc0200e16:	8326                	mv	t1,s1
}
ffffffffc0200e18:	6942                	ld	s2,16(sp)
ffffffffc0200e1a:	64e2                	ld	s1,24(sp)
ffffffffc0200e1c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200e1e:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0200e20:	03065633          	divu	a2,a2,a6
ffffffffc0200e24:	8722                	mv	a4,s0
ffffffffc0200e26:	f9bff0ef          	jal	ra,ffffffffc0200dc0 <printnum>
ffffffffc0200e2a:	b7f9                	j	ffffffffc0200df8 <printnum+0x38>

ffffffffc0200e2c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0200e2c:	7119                	addi	sp,sp,-128
ffffffffc0200e2e:	f4a6                	sd	s1,104(sp)
ffffffffc0200e30:	f0ca                	sd	s2,96(sp)
ffffffffc0200e32:	e8d2                	sd	s4,80(sp)
ffffffffc0200e34:	e4d6                	sd	s5,72(sp)
ffffffffc0200e36:	e0da                	sd	s6,64(sp)
ffffffffc0200e38:	fc5e                	sd	s7,56(sp)
ffffffffc0200e3a:	f862                	sd	s8,48(sp)
ffffffffc0200e3c:	f06a                	sd	s10,32(sp)
ffffffffc0200e3e:	fc86                	sd	ra,120(sp)
ffffffffc0200e40:	f8a2                	sd	s0,112(sp)
ffffffffc0200e42:	ecce                	sd	s3,88(sp)
ffffffffc0200e44:	f466                	sd	s9,40(sp)
ffffffffc0200e46:	ec6e                	sd	s11,24(sp)
ffffffffc0200e48:	892a                	mv	s2,a0
ffffffffc0200e4a:	84ae                	mv	s1,a1
ffffffffc0200e4c:	8d32                	mv	s10,a2
ffffffffc0200e4e:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0200e50:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200e52:	00001a17          	auipc	s4,0x1
ffffffffc0200e56:	e76a0a13          	addi	s4,s4,-394 # ffffffffc0201cc8 <buddy_system_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0200e5a:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0200e5e:	00001c17          	auipc	s8,0x1
ffffffffc0200e62:	fc2c0c13          	addi	s8,s8,-62 # ffffffffc0201e20 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200e66:	000d4503          	lbu	a0,0(s10)
ffffffffc0200e6a:	02500793          	li	a5,37
ffffffffc0200e6e:	001d0413          	addi	s0,s10,1
ffffffffc0200e72:	00f50e63          	beq	a0,a5,ffffffffc0200e8e <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0200e76:	c521                	beqz	a0,ffffffffc0200ebe <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200e78:	02500993          	li	s3,37
ffffffffc0200e7c:	a011                	j	ffffffffc0200e80 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0200e7e:	c121                	beqz	a0,ffffffffc0200ebe <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0200e80:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200e82:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0200e84:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200e86:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200e8a:	ff351ae3          	bne	a0,s3,ffffffffc0200e7e <vprintfmt+0x52>
ffffffffc0200e8e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0200e92:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0200e96:	4981                	li	s3,0
ffffffffc0200e98:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0200e9a:	5cfd                	li	s9,-1
ffffffffc0200e9c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200e9e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0200ea2:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200ea4:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0200ea8:	0ff6f693          	andi	a3,a3,255
ffffffffc0200eac:	00140d13          	addi	s10,s0,1
ffffffffc0200eb0:	20d5e563          	bltu	a1,a3,ffffffffc02010ba <vprintfmt+0x28e>
ffffffffc0200eb4:	068a                	slli	a3,a3,0x2
ffffffffc0200eb6:	96d2                	add	a3,a3,s4
ffffffffc0200eb8:	4294                	lw	a3,0(a3)
ffffffffc0200eba:	96d2                	add	a3,a3,s4
ffffffffc0200ebc:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0200ebe:	70e6                	ld	ra,120(sp)
ffffffffc0200ec0:	7446                	ld	s0,112(sp)
ffffffffc0200ec2:	74a6                	ld	s1,104(sp)
ffffffffc0200ec4:	7906                	ld	s2,96(sp)
ffffffffc0200ec6:	69e6                	ld	s3,88(sp)
ffffffffc0200ec8:	6a46                	ld	s4,80(sp)
ffffffffc0200eca:	6aa6                	ld	s5,72(sp)
ffffffffc0200ecc:	6b06                	ld	s6,64(sp)
ffffffffc0200ece:	7be2                	ld	s7,56(sp)
ffffffffc0200ed0:	7c42                	ld	s8,48(sp)
ffffffffc0200ed2:	7ca2                	ld	s9,40(sp)
ffffffffc0200ed4:	7d02                	ld	s10,32(sp)
ffffffffc0200ed6:	6de2                	ld	s11,24(sp)
ffffffffc0200ed8:	6109                	addi	sp,sp,128
ffffffffc0200eda:	8082                	ret
    if (lflag >= 2) {
ffffffffc0200edc:	4705                	li	a4,1
ffffffffc0200ede:	008a8593          	addi	a1,s5,8
ffffffffc0200ee2:	01074463          	blt	a4,a6,ffffffffc0200eea <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0200ee6:	26080363          	beqz	a6,ffffffffc020114c <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0200eea:	000ab603          	ld	a2,0(s5)
ffffffffc0200eee:	46c1                	li	a3,16
ffffffffc0200ef0:	8aae                	mv	s5,a1
ffffffffc0200ef2:	a06d                	j	ffffffffc0200f9c <vprintfmt+0x170>
            goto reswitch;
ffffffffc0200ef4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0200ef8:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200efa:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0200efc:	b765                	j	ffffffffc0200ea4 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0200efe:	000aa503          	lw	a0,0(s5)
ffffffffc0200f02:	85a6                	mv	a1,s1
ffffffffc0200f04:	0aa1                	addi	s5,s5,8
ffffffffc0200f06:	9902                	jalr	s2
            break;
ffffffffc0200f08:	bfb9                	j	ffffffffc0200e66 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0200f0a:	4705                	li	a4,1
ffffffffc0200f0c:	008a8993          	addi	s3,s5,8
ffffffffc0200f10:	01074463          	blt	a4,a6,ffffffffc0200f18 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0200f14:	22080463          	beqz	a6,ffffffffc020113c <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0200f18:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0200f1c:	24044463          	bltz	s0,ffffffffc0201164 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0200f20:	8622                	mv	a2,s0
ffffffffc0200f22:	8ace                	mv	s5,s3
ffffffffc0200f24:	46a9                	li	a3,10
ffffffffc0200f26:	a89d                	j	ffffffffc0200f9c <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0200f28:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0200f2c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0200f2e:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0200f30:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0200f34:	8fb5                	xor	a5,a5,a3
ffffffffc0200f36:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0200f3a:	1ad74363          	blt	a4,a3,ffffffffc02010e0 <vprintfmt+0x2b4>
ffffffffc0200f3e:	00369793          	slli	a5,a3,0x3
ffffffffc0200f42:	97e2                	add	a5,a5,s8
ffffffffc0200f44:	639c                	ld	a5,0(a5)
ffffffffc0200f46:	18078d63          	beqz	a5,ffffffffc02010e0 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0200f4a:	86be                	mv	a3,a5
ffffffffc0200f4c:	00001617          	auipc	a2,0x1
ffffffffc0200f50:	fbc60613          	addi	a2,a2,-68 # ffffffffc0201f08 <error_string+0xe8>
ffffffffc0200f54:	85a6                	mv	a1,s1
ffffffffc0200f56:	854a                	mv	a0,s2
ffffffffc0200f58:	240000ef          	jal	ra,ffffffffc0201198 <printfmt>
ffffffffc0200f5c:	b729                	j	ffffffffc0200e66 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0200f5e:	00144603          	lbu	a2,1(s0)
ffffffffc0200f62:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f64:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0200f66:	bf3d                	j	ffffffffc0200ea4 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0200f68:	4705                	li	a4,1
ffffffffc0200f6a:	008a8593          	addi	a1,s5,8
ffffffffc0200f6e:	01074463          	blt	a4,a6,ffffffffc0200f76 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0200f72:	1e080263          	beqz	a6,ffffffffc0201156 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0200f76:	000ab603          	ld	a2,0(s5)
ffffffffc0200f7a:	46a1                	li	a3,8
ffffffffc0200f7c:	8aae                	mv	s5,a1
ffffffffc0200f7e:	a839                	j	ffffffffc0200f9c <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0200f80:	03000513          	li	a0,48
ffffffffc0200f84:	85a6                	mv	a1,s1
ffffffffc0200f86:	e03e                	sd	a5,0(sp)
ffffffffc0200f88:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0200f8a:	85a6                	mv	a1,s1
ffffffffc0200f8c:	07800513          	li	a0,120
ffffffffc0200f90:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0200f92:	0aa1                	addi	s5,s5,8
ffffffffc0200f94:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0200f98:	6782                	ld	a5,0(sp)
ffffffffc0200f9a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0200f9c:	876e                	mv	a4,s11
ffffffffc0200f9e:	85a6                	mv	a1,s1
ffffffffc0200fa0:	854a                	mv	a0,s2
ffffffffc0200fa2:	e1fff0ef          	jal	ra,ffffffffc0200dc0 <printnum>
            break;
ffffffffc0200fa6:	b5c1                	j	ffffffffc0200e66 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0200fa8:	000ab603          	ld	a2,0(s5)
ffffffffc0200fac:	0aa1                	addi	s5,s5,8
ffffffffc0200fae:	1c060663          	beqz	a2,ffffffffc020117a <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0200fb2:	00160413          	addi	s0,a2,1
ffffffffc0200fb6:	17b05c63          	blez	s11,ffffffffc020112e <vprintfmt+0x302>
ffffffffc0200fba:	02d00593          	li	a1,45
ffffffffc0200fbe:	14b79263          	bne	a5,a1,ffffffffc0201102 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0200fc2:	00064783          	lbu	a5,0(a2)
ffffffffc0200fc6:	0007851b          	sext.w	a0,a5
ffffffffc0200fca:	c905                	beqz	a0,ffffffffc0200ffa <vprintfmt+0x1ce>
ffffffffc0200fcc:	000cc563          	bltz	s9,ffffffffc0200fd6 <vprintfmt+0x1aa>
ffffffffc0200fd0:	3cfd                	addiw	s9,s9,-1
ffffffffc0200fd2:	036c8263          	beq	s9,s6,ffffffffc0200ff6 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0200fd6:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0200fd8:	18098463          	beqz	s3,ffffffffc0201160 <vprintfmt+0x334>
ffffffffc0200fdc:	3781                	addiw	a5,a5,-32
ffffffffc0200fde:	18fbf163          	bleu	a5,s7,ffffffffc0201160 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0200fe2:	03f00513          	li	a0,63
ffffffffc0200fe6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0200fe8:	0405                	addi	s0,s0,1
ffffffffc0200fea:	fff44783          	lbu	a5,-1(s0)
ffffffffc0200fee:	3dfd                	addiw	s11,s11,-1
ffffffffc0200ff0:	0007851b          	sext.w	a0,a5
ffffffffc0200ff4:	fd61                	bnez	a0,ffffffffc0200fcc <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0200ff6:	e7b058e3          	blez	s11,ffffffffc0200e66 <vprintfmt+0x3a>
ffffffffc0200ffa:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0200ffc:	85a6                	mv	a1,s1
ffffffffc0200ffe:	02000513          	li	a0,32
ffffffffc0201002:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201004:	e60d81e3          	beqz	s11,ffffffffc0200e66 <vprintfmt+0x3a>
ffffffffc0201008:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020100a:	85a6                	mv	a1,s1
ffffffffc020100c:	02000513          	li	a0,32
ffffffffc0201010:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201012:	fe0d94e3          	bnez	s11,ffffffffc0200ffa <vprintfmt+0x1ce>
ffffffffc0201016:	bd81                	j	ffffffffc0200e66 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201018:	4705                	li	a4,1
ffffffffc020101a:	008a8593          	addi	a1,s5,8
ffffffffc020101e:	01074463          	blt	a4,a6,ffffffffc0201026 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0201022:	12080063          	beqz	a6,ffffffffc0201142 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0201026:	000ab603          	ld	a2,0(s5)
ffffffffc020102a:	46a9                	li	a3,10
ffffffffc020102c:	8aae                	mv	s5,a1
ffffffffc020102e:	b7bd                	j	ffffffffc0200f9c <vprintfmt+0x170>
ffffffffc0201030:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0201034:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201038:	846a                	mv	s0,s10
ffffffffc020103a:	b5ad                	j	ffffffffc0200ea4 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc020103c:	85a6                	mv	a1,s1
ffffffffc020103e:	02500513          	li	a0,37
ffffffffc0201042:	9902                	jalr	s2
            break;
ffffffffc0201044:	b50d                	j	ffffffffc0200e66 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0201046:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020104a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020104e:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201050:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0201052:	e40dd9e3          	bgez	s11,ffffffffc0200ea4 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201056:	8de6                	mv	s11,s9
ffffffffc0201058:	5cfd                	li	s9,-1
ffffffffc020105a:	b5a9                	j	ffffffffc0200ea4 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020105c:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0201060:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201064:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201066:	bd3d                	j	ffffffffc0200ea4 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0201068:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020106c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201070:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201072:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201076:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020107a:	fcd56ce3          	bltu	a0,a3,ffffffffc0201052 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020107e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201080:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201084:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201088:	0196873b          	addw	a4,a3,s9
ffffffffc020108c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201090:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201094:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201098:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020109c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02010a0:	fcd57fe3          	bleu	a3,a0,ffffffffc020107e <vprintfmt+0x252>
ffffffffc02010a4:	b77d                	j	ffffffffc0201052 <vprintfmt+0x226>
            if (width < 0)
ffffffffc02010a6:	fffdc693          	not	a3,s11
ffffffffc02010aa:	96fd                	srai	a3,a3,0x3f
ffffffffc02010ac:	00ddfdb3          	and	s11,s11,a3
ffffffffc02010b0:	00144603          	lbu	a2,1(s0)
ffffffffc02010b4:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010b6:	846a                	mv	s0,s10
ffffffffc02010b8:	b3f5                	j	ffffffffc0200ea4 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02010ba:	85a6                	mv	a1,s1
ffffffffc02010bc:	02500513          	li	a0,37
ffffffffc02010c0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02010c2:	fff44703          	lbu	a4,-1(s0)
ffffffffc02010c6:	02500793          	li	a5,37
ffffffffc02010ca:	8d22                	mv	s10,s0
ffffffffc02010cc:	d8f70de3          	beq	a4,a5,ffffffffc0200e66 <vprintfmt+0x3a>
ffffffffc02010d0:	02500713          	li	a4,37
ffffffffc02010d4:	1d7d                	addi	s10,s10,-1
ffffffffc02010d6:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02010da:	fee79de3          	bne	a5,a4,ffffffffc02010d4 <vprintfmt+0x2a8>
ffffffffc02010de:	b361                	j	ffffffffc0200e66 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02010e0:	00001617          	auipc	a2,0x1
ffffffffc02010e4:	e1860613          	addi	a2,a2,-488 # ffffffffc0201ef8 <error_string+0xd8>
ffffffffc02010e8:	85a6                	mv	a1,s1
ffffffffc02010ea:	854a                	mv	a0,s2
ffffffffc02010ec:	0ac000ef          	jal	ra,ffffffffc0201198 <printfmt>
ffffffffc02010f0:	bb9d                	j	ffffffffc0200e66 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02010f2:	00001617          	auipc	a2,0x1
ffffffffc02010f6:	dfe60613          	addi	a2,a2,-514 # ffffffffc0201ef0 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02010fa:	00001417          	auipc	s0,0x1
ffffffffc02010fe:	df740413          	addi	s0,s0,-521 # ffffffffc0201ef1 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201102:	8532                	mv	a0,a2
ffffffffc0201104:	85e6                	mv	a1,s9
ffffffffc0201106:	e032                	sd	a2,0(sp)
ffffffffc0201108:	e43e                	sd	a5,8(sp)
ffffffffc020110a:	1c2000ef          	jal	ra,ffffffffc02012cc <strnlen>
ffffffffc020110e:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201112:	6602                	ld	a2,0(sp)
ffffffffc0201114:	01b05d63          	blez	s11,ffffffffc020112e <vprintfmt+0x302>
ffffffffc0201118:	67a2                	ld	a5,8(sp)
ffffffffc020111a:	2781                	sext.w	a5,a5
ffffffffc020111c:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020111e:	6522                	ld	a0,8(sp)
ffffffffc0201120:	85a6                	mv	a1,s1
ffffffffc0201122:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201124:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201126:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201128:	6602                	ld	a2,0(sp)
ffffffffc020112a:	fe0d9ae3          	bnez	s11,ffffffffc020111e <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020112e:	00064783          	lbu	a5,0(a2)
ffffffffc0201132:	0007851b          	sext.w	a0,a5
ffffffffc0201136:	e8051be3          	bnez	a0,ffffffffc0200fcc <vprintfmt+0x1a0>
ffffffffc020113a:	b335                	j	ffffffffc0200e66 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc020113c:	000aa403          	lw	s0,0(s5)
ffffffffc0201140:	bbf1                	j	ffffffffc0200f1c <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0201142:	000ae603          	lwu	a2,0(s5)
ffffffffc0201146:	46a9                	li	a3,10
ffffffffc0201148:	8aae                	mv	s5,a1
ffffffffc020114a:	bd89                	j	ffffffffc0200f9c <vprintfmt+0x170>
ffffffffc020114c:	000ae603          	lwu	a2,0(s5)
ffffffffc0201150:	46c1                	li	a3,16
ffffffffc0201152:	8aae                	mv	s5,a1
ffffffffc0201154:	b5a1                	j	ffffffffc0200f9c <vprintfmt+0x170>
ffffffffc0201156:	000ae603          	lwu	a2,0(s5)
ffffffffc020115a:	46a1                	li	a3,8
ffffffffc020115c:	8aae                	mv	s5,a1
ffffffffc020115e:	bd3d                	j	ffffffffc0200f9c <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0201160:	9902                	jalr	s2
ffffffffc0201162:	b559                	j	ffffffffc0200fe8 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0201164:	85a6                	mv	a1,s1
ffffffffc0201166:	02d00513          	li	a0,45
ffffffffc020116a:	e03e                	sd	a5,0(sp)
ffffffffc020116c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020116e:	8ace                	mv	s5,s3
ffffffffc0201170:	40800633          	neg	a2,s0
ffffffffc0201174:	46a9                	li	a3,10
ffffffffc0201176:	6782                	ld	a5,0(sp)
ffffffffc0201178:	b515                	j	ffffffffc0200f9c <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc020117a:	01b05663          	blez	s11,ffffffffc0201186 <vprintfmt+0x35a>
ffffffffc020117e:	02d00693          	li	a3,45
ffffffffc0201182:	f6d798e3          	bne	a5,a3,ffffffffc02010f2 <vprintfmt+0x2c6>
ffffffffc0201186:	00001417          	auipc	s0,0x1
ffffffffc020118a:	d6b40413          	addi	s0,s0,-661 # ffffffffc0201ef1 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020118e:	02800513          	li	a0,40
ffffffffc0201192:	02800793          	li	a5,40
ffffffffc0201196:	bd1d                	j	ffffffffc0200fcc <vprintfmt+0x1a0>

ffffffffc0201198 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201198:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020119a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020119e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02011a0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02011a2:	ec06                	sd	ra,24(sp)
ffffffffc02011a4:	f83a                	sd	a4,48(sp)
ffffffffc02011a6:	fc3e                	sd	a5,56(sp)
ffffffffc02011a8:	e0c2                	sd	a6,64(sp)
ffffffffc02011aa:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02011ac:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02011ae:	c7fff0ef          	jal	ra,ffffffffc0200e2c <vprintfmt>
}
ffffffffc02011b2:	60e2                	ld	ra,24(sp)
ffffffffc02011b4:	6161                	addi	sp,sp,80
ffffffffc02011b6:	8082                	ret

ffffffffc02011b8 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02011b8:	715d                	addi	sp,sp,-80
ffffffffc02011ba:	e486                	sd	ra,72(sp)
ffffffffc02011bc:	e0a2                	sd	s0,64(sp)
ffffffffc02011be:	fc26                	sd	s1,56(sp)
ffffffffc02011c0:	f84a                	sd	s2,48(sp)
ffffffffc02011c2:	f44e                	sd	s3,40(sp)
ffffffffc02011c4:	f052                	sd	s4,32(sp)
ffffffffc02011c6:	ec56                	sd	s5,24(sp)
ffffffffc02011c8:	e85a                	sd	s6,16(sp)
ffffffffc02011ca:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02011cc:	c901                	beqz	a0,ffffffffc02011dc <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02011ce:	85aa                	mv	a1,a0
ffffffffc02011d0:	00001517          	auipc	a0,0x1
ffffffffc02011d4:	d3850513          	addi	a0,a0,-712 # ffffffffc0201f08 <error_string+0xe8>
ffffffffc02011d8:	edffe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc02011dc:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02011de:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02011e0:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02011e2:	4aa9                	li	s5,10
ffffffffc02011e4:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02011e6:	00004b97          	auipc	s7,0x4
ffffffffc02011ea:	e2ab8b93          	addi	s7,s7,-470 # ffffffffc0205010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02011ee:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02011f2:	f3dfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02011f6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02011f8:	00054b63          	bltz	a0,ffffffffc020120e <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02011fc:	00a95b63          	ble	a0,s2,ffffffffc0201212 <readline+0x5a>
ffffffffc0201200:	029a5463          	ble	s1,s4,ffffffffc0201228 <readline+0x70>
        c = getchar();
ffffffffc0201204:	f2bfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201208:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020120a:	fe0559e3          	bgez	a0,ffffffffc02011fc <readline+0x44>
            return NULL;
ffffffffc020120e:	4501                	li	a0,0
ffffffffc0201210:	a099                	j	ffffffffc0201256 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201212:	03341463          	bne	s0,s3,ffffffffc020123a <readline+0x82>
ffffffffc0201216:	e8b9                	bnez	s1,ffffffffc020126c <readline+0xb4>
        c = getchar();
ffffffffc0201218:	f17fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc020121c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020121e:	fe0548e3          	bltz	a0,ffffffffc020120e <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201222:	fea958e3          	ble	a0,s2,ffffffffc0201212 <readline+0x5a>
ffffffffc0201226:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201228:	8522                	mv	a0,s0
ffffffffc020122a:	ec1fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc020122e:	009b87b3          	add	a5,s7,s1
ffffffffc0201232:	00878023          	sb	s0,0(a5)
ffffffffc0201236:	2485                	addiw	s1,s1,1
ffffffffc0201238:	bf6d                	j	ffffffffc02011f2 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc020123a:	01540463          	beq	s0,s5,ffffffffc0201242 <readline+0x8a>
ffffffffc020123e:	fb641ae3          	bne	s0,s6,ffffffffc02011f2 <readline+0x3a>
            cputchar(c);
ffffffffc0201242:	8522                	mv	a0,s0
ffffffffc0201244:	ea7fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201248:	00004517          	auipc	a0,0x4
ffffffffc020124c:	dc850513          	addi	a0,a0,-568 # ffffffffc0205010 <edata>
ffffffffc0201250:	94aa                	add	s1,s1,a0
ffffffffc0201252:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201256:	60a6                	ld	ra,72(sp)
ffffffffc0201258:	6406                	ld	s0,64(sp)
ffffffffc020125a:	74e2                	ld	s1,56(sp)
ffffffffc020125c:	7942                	ld	s2,48(sp)
ffffffffc020125e:	79a2                	ld	s3,40(sp)
ffffffffc0201260:	7a02                	ld	s4,32(sp)
ffffffffc0201262:	6ae2                	ld	s5,24(sp)
ffffffffc0201264:	6b42                	ld	s6,16(sp)
ffffffffc0201266:	6ba2                	ld	s7,8(sp)
ffffffffc0201268:	6161                	addi	sp,sp,80
ffffffffc020126a:	8082                	ret
            cputchar(c);
ffffffffc020126c:	4521                	li	a0,8
ffffffffc020126e:	e7dfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201272:	34fd                	addiw	s1,s1,-1
ffffffffc0201274:	bfbd                	j	ffffffffc02011f2 <readline+0x3a>

ffffffffc0201276 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201276:	00004797          	auipc	a5,0x4
ffffffffc020127a:	d9278793          	addi	a5,a5,-622 # ffffffffc0205008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc020127e:	6398                	ld	a4,0(a5)
ffffffffc0201280:	4781                	li	a5,0
ffffffffc0201282:	88ba                	mv	a7,a4
ffffffffc0201284:	852a                	mv	a0,a0
ffffffffc0201286:	85be                	mv	a1,a5
ffffffffc0201288:	863e                	mv	a2,a5
ffffffffc020128a:	00000073          	ecall
ffffffffc020128e:	87aa                	mv	a5,a0
}
ffffffffc0201290:	8082                	ret

ffffffffc0201292 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201292:	00004797          	auipc	a5,0x4
ffffffffc0201296:	19678793          	addi	a5,a5,406 # ffffffffc0205428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc020129a:	6398                	ld	a4,0(a5)
ffffffffc020129c:	4781                	li	a5,0
ffffffffc020129e:	88ba                	mv	a7,a4
ffffffffc02012a0:	852a                	mv	a0,a0
ffffffffc02012a2:	85be                	mv	a1,a5
ffffffffc02012a4:	863e                	mv	a2,a5
ffffffffc02012a6:	00000073          	ecall
ffffffffc02012aa:	87aa                	mv	a5,a0
}
ffffffffc02012ac:	8082                	ret

ffffffffc02012ae <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc02012ae:	00004797          	auipc	a5,0x4
ffffffffc02012b2:	d5278793          	addi	a5,a5,-686 # ffffffffc0205000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc02012b6:	639c                	ld	a5,0(a5)
ffffffffc02012b8:	4501                	li	a0,0
ffffffffc02012ba:	88be                	mv	a7,a5
ffffffffc02012bc:	852a                	mv	a0,a0
ffffffffc02012be:	85aa                	mv	a1,a0
ffffffffc02012c0:	862a                	mv	a2,a0
ffffffffc02012c2:	00000073          	ecall
ffffffffc02012c6:	852a                	mv	a0,a0
ffffffffc02012c8:	2501                	sext.w	a0,a0
ffffffffc02012ca:	8082                	ret

ffffffffc02012cc <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02012cc:	c185                	beqz	a1,ffffffffc02012ec <strnlen+0x20>
ffffffffc02012ce:	00054783          	lbu	a5,0(a0)
ffffffffc02012d2:	cf89                	beqz	a5,ffffffffc02012ec <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02012d4:	4781                	li	a5,0
ffffffffc02012d6:	a021                	j	ffffffffc02012de <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02012d8:	00074703          	lbu	a4,0(a4)
ffffffffc02012dc:	c711                	beqz	a4,ffffffffc02012e8 <strnlen+0x1c>
        cnt ++;
ffffffffc02012de:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02012e0:	00f50733          	add	a4,a0,a5
ffffffffc02012e4:	fef59ae3          	bne	a1,a5,ffffffffc02012d8 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02012e8:	853e                	mv	a0,a5
ffffffffc02012ea:	8082                	ret
    size_t cnt = 0;
ffffffffc02012ec:	4781                	li	a5,0
}
ffffffffc02012ee:	853e                	mv	a0,a5
ffffffffc02012f0:	8082                	ret

ffffffffc02012f2 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02012f2:	00054783          	lbu	a5,0(a0)
ffffffffc02012f6:	0005c703          	lbu	a4,0(a1)
ffffffffc02012fa:	cb91                	beqz	a5,ffffffffc020130e <strcmp+0x1c>
ffffffffc02012fc:	00e79c63          	bne	a5,a4,ffffffffc0201314 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201300:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201302:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201306:	0585                	addi	a1,a1,1
ffffffffc0201308:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020130c:	fbe5                	bnez	a5,ffffffffc02012fc <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020130e:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201310:	9d19                	subw	a0,a0,a4
ffffffffc0201312:	8082                	ret
ffffffffc0201314:	0007851b          	sext.w	a0,a5
ffffffffc0201318:	9d19                	subw	a0,a0,a4
ffffffffc020131a:	8082                	ret

ffffffffc020131c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020131c:	00054783          	lbu	a5,0(a0)
ffffffffc0201320:	cb91                	beqz	a5,ffffffffc0201334 <strchr+0x18>
        if (*s == c) {
ffffffffc0201322:	00b79563          	bne	a5,a1,ffffffffc020132c <strchr+0x10>
ffffffffc0201326:	a809                	j	ffffffffc0201338 <strchr+0x1c>
ffffffffc0201328:	00b78763          	beq	a5,a1,ffffffffc0201336 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc020132c:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020132e:	00054783          	lbu	a5,0(a0)
ffffffffc0201332:	fbfd                	bnez	a5,ffffffffc0201328 <strchr+0xc>
    }
    return NULL;
ffffffffc0201334:	4501                	li	a0,0
}
ffffffffc0201336:	8082                	ret
ffffffffc0201338:	8082                	ret

ffffffffc020133a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020133a:	ca01                	beqz	a2,ffffffffc020134a <memset+0x10>
ffffffffc020133c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020133e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201340:	0785                	addi	a5,a5,1
ffffffffc0201342:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201346:	fec79de3          	bne	a5,a2,ffffffffc0201340 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020134a:	8082                	ret
