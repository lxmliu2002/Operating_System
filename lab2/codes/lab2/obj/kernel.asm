
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
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
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

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
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	ff250513          	addi	a0,a0,-14 # ffffffffc0206028 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	54260613          	addi	a2,a2,1346 # ffffffffc0206580 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	589010ef          	jal	ra,ffffffffc0201dd6 <memset>
    cons_init();  // init the console
ffffffffc0200052:	406000ef          	jal	ra,ffffffffc0200458 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	d9250513          	addi	a0,a0,-622 # ffffffffc0201de8 <etext>
ffffffffc020005e:	098000ef          	jal	ra,ffffffffc02000f6 <cputs>

    print_kerninfo();
ffffffffc0200062:	0e4000ef          	jal	ra,ffffffffc0200146 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	40c000ef          	jal	ra,ffffffffc0200472 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	336010ef          	jal	ra,ffffffffc02013a0 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	404000ef          	jal	ra,ffffffffc0200472 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	3a2000ef          	jal	ra,ffffffffc0200414 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3f0000ef          	jal	ra,ffffffffc0200466 <intr_enable>

    slub_init();
ffffffffc020007a:	606010ef          	jal	ra,ffffffffc0201680 <slub_init>
    slub_check();
ffffffffc020007e:	6e6010ef          	jal	ra,ffffffffc0201764 <slub_check>
    /* do nothing */
    while (1)
        ;
ffffffffc0200082:	a001                	j	ffffffffc0200082 <kern_init+0x4c>

ffffffffc0200084 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200084:	1141                	addi	sp,sp,-16
ffffffffc0200086:	e022                	sd	s0,0(sp)
ffffffffc0200088:	e406                	sd	ra,8(sp)
ffffffffc020008a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020008c:	3ce000ef          	jal	ra,ffffffffc020045a <cons_putc>
    (*cnt) ++;
ffffffffc0200090:	401c                	lw	a5,0(s0)
}
ffffffffc0200092:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200094:	2785                	addiw	a5,a5,1
ffffffffc0200096:	c01c                	sw	a5,0(s0)
}
ffffffffc0200098:	6402                	ld	s0,0(sp)
ffffffffc020009a:	0141                	addi	sp,sp,16
ffffffffc020009c:	8082                	ret

ffffffffc020009e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	86ae                	mv	a3,a1
ffffffffc02000a2:	862a                	mv	a2,a0
ffffffffc02000a4:	006c                	addi	a1,sp,12
ffffffffc02000a6:	00000517          	auipc	a0,0x0
ffffffffc02000aa:	fde50513          	addi	a0,a0,-34 # ffffffffc0200084 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ae:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000b0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	017010ef          	jal	ra,ffffffffc02018c8 <vprintfmt>
    return cnt;
}
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
ffffffffc02000b8:	4532                	lw	a0,12(sp)
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000be:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c4:	f42e                	sd	a1,40(sp)
ffffffffc02000c6:	f832                	sd	a2,48(sp)
ffffffffc02000c8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	862a                	mv	a2,a0
ffffffffc02000cc:	004c                	addi	a1,sp,4
ffffffffc02000ce:	00000517          	auipc	a0,0x0
ffffffffc02000d2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200084 <cputch>
ffffffffc02000d6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d8:	ec06                	sd	ra,24(sp)
ffffffffc02000da:	e0ba                	sd	a4,64(sp)
ffffffffc02000dc:	e4be                	sd	a5,72(sp)
ffffffffc02000de:	e8c2                	sd	a6,80(sp)
ffffffffc02000e0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e6:	7e2010ef          	jal	ra,ffffffffc02018c8 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000ea:	60e2                	ld	ra,24(sp)
ffffffffc02000ec:	4512                	lw	a0,4(sp)
ffffffffc02000ee:	6125                	addi	sp,sp,96
ffffffffc02000f0:	8082                	ret

ffffffffc02000f2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f2:	3680006f          	j	ffffffffc020045a <cons_putc>

ffffffffc02000f6 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000f6:	1101                	addi	sp,sp,-32
ffffffffc02000f8:	e822                	sd	s0,16(sp)
ffffffffc02000fa:	ec06                	sd	ra,24(sp)
ffffffffc02000fc:	e426                	sd	s1,8(sp)
ffffffffc02000fe:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200100:	00054503          	lbu	a0,0(a0)
ffffffffc0200104:	c51d                	beqz	a0,ffffffffc0200132 <cputs+0x3c>
ffffffffc0200106:	0405                	addi	s0,s0,1
ffffffffc0200108:	4485                	li	s1,1
ffffffffc020010a:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020010c:	34e000ef          	jal	ra,ffffffffc020045a <cons_putc>
    (*cnt) ++;
ffffffffc0200110:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc0200114:	0405                	addi	s0,s0,1
ffffffffc0200116:	fff44503          	lbu	a0,-1(s0)
ffffffffc020011a:	f96d                	bnez	a0,ffffffffc020010c <cputs+0x16>
ffffffffc020011c:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200120:	4529                	li	a0,10
ffffffffc0200122:	338000ef          	jal	ra,ffffffffc020045a <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200126:	8522                	mv	a0,s0
ffffffffc0200128:	60e2                	ld	ra,24(sp)
ffffffffc020012a:	6442                	ld	s0,16(sp)
ffffffffc020012c:	64a2                	ld	s1,8(sp)
ffffffffc020012e:	6105                	addi	sp,sp,32
ffffffffc0200130:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200132:	4405                	li	s0,1
ffffffffc0200134:	b7f5                	j	ffffffffc0200120 <cputs+0x2a>

ffffffffc0200136 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200136:	1141                	addi	sp,sp,-16
ffffffffc0200138:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020013a:	328000ef          	jal	ra,ffffffffc0200462 <cons_getc>
ffffffffc020013e:	dd75                	beqz	a0,ffffffffc020013a <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200140:	60a2                	ld	ra,8(sp)
ffffffffc0200142:	0141                	addi	sp,sp,16
ffffffffc0200144:	8082                	ret

ffffffffc0200146 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200146:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200148:	00002517          	auipc	a0,0x2
ffffffffc020014c:	cf050513          	addi	a0,a0,-784 # ffffffffc0201e38 <etext+0x50>
void print_kerninfo(void) {
ffffffffc0200150:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200152:	f6dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc0200156:	00000597          	auipc	a1,0x0
ffffffffc020015a:	ee058593          	addi	a1,a1,-288 # ffffffffc0200036 <kern_init>
ffffffffc020015e:	00002517          	auipc	a0,0x2
ffffffffc0200162:	cfa50513          	addi	a0,a0,-774 # ffffffffc0201e58 <etext+0x70>
ffffffffc0200166:	f59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020016a:	00002597          	auipc	a1,0x2
ffffffffc020016e:	c7e58593          	addi	a1,a1,-898 # ffffffffc0201de8 <etext>
ffffffffc0200172:	00002517          	auipc	a0,0x2
ffffffffc0200176:	d0650513          	addi	a0,a0,-762 # ffffffffc0201e78 <etext+0x90>
ffffffffc020017a:	f45ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc020017e:	00006597          	auipc	a1,0x6
ffffffffc0200182:	eaa58593          	addi	a1,a1,-342 # ffffffffc0206028 <edata>
ffffffffc0200186:	00002517          	auipc	a0,0x2
ffffffffc020018a:	d1250513          	addi	a0,a0,-750 # ffffffffc0201e98 <etext+0xb0>
ffffffffc020018e:	f31ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200192:	00006597          	auipc	a1,0x6
ffffffffc0200196:	3ee58593          	addi	a1,a1,1006 # ffffffffc0206580 <end>
ffffffffc020019a:	00002517          	auipc	a0,0x2
ffffffffc020019e:	d1e50513          	addi	a0,a0,-738 # ffffffffc0201eb8 <etext+0xd0>
ffffffffc02001a2:	f1dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001a6:	00006597          	auipc	a1,0x6
ffffffffc02001aa:	7d958593          	addi	a1,a1,2009 # ffffffffc020697f <end+0x3ff>
ffffffffc02001ae:	00000797          	auipc	a5,0x0
ffffffffc02001b2:	e8878793          	addi	a5,a5,-376 # ffffffffc0200036 <kern_init>
ffffffffc02001b6:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ba:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001be:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c0:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001c4:	95be                	add	a1,a1,a5
ffffffffc02001c6:	85a9                	srai	a1,a1,0xa
ffffffffc02001c8:	00002517          	auipc	a0,0x2
ffffffffc02001cc:	d1050513          	addi	a0,a0,-752 # ffffffffc0201ed8 <etext+0xf0>
}
ffffffffc02001d0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d2:	eedff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02001d6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001d6:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d8:	00002617          	auipc	a2,0x2
ffffffffc02001dc:	c3060613          	addi	a2,a2,-976 # ffffffffc0201e08 <etext+0x20>
ffffffffc02001e0:	04e00593          	li	a1,78
ffffffffc02001e4:	00002517          	auipc	a0,0x2
ffffffffc02001e8:	c3c50513          	addi	a0,a0,-964 # ffffffffc0201e20 <etext+0x38>
void print_stackframe(void) {
ffffffffc02001ec:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001ee:	1c6000ef          	jal	ra,ffffffffc02003b4 <__panic>

ffffffffc02001f2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001f2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001f4:	00002617          	auipc	a2,0x2
ffffffffc02001f8:	df460613          	addi	a2,a2,-524 # ffffffffc0201fe8 <commands+0xe0>
ffffffffc02001fc:	00002597          	auipc	a1,0x2
ffffffffc0200200:	e0c58593          	addi	a1,a1,-500 # ffffffffc0202008 <commands+0x100>
ffffffffc0200204:	00002517          	auipc	a0,0x2
ffffffffc0200208:	e0c50513          	addi	a0,a0,-500 # ffffffffc0202010 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020020c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020020e:	eb1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200212:	00002617          	auipc	a2,0x2
ffffffffc0200216:	e0e60613          	addi	a2,a2,-498 # ffffffffc0202020 <commands+0x118>
ffffffffc020021a:	00002597          	auipc	a1,0x2
ffffffffc020021e:	e2e58593          	addi	a1,a1,-466 # ffffffffc0202048 <commands+0x140>
ffffffffc0200222:	00002517          	auipc	a0,0x2
ffffffffc0200226:	dee50513          	addi	a0,a0,-530 # ffffffffc0202010 <commands+0x108>
ffffffffc020022a:	e95ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020022e:	00002617          	auipc	a2,0x2
ffffffffc0200232:	e2a60613          	addi	a2,a2,-470 # ffffffffc0202058 <commands+0x150>
ffffffffc0200236:	00002597          	auipc	a1,0x2
ffffffffc020023a:	e4258593          	addi	a1,a1,-446 # ffffffffc0202078 <commands+0x170>
ffffffffc020023e:	00002517          	auipc	a0,0x2
ffffffffc0200242:	dd250513          	addi	a0,a0,-558 # ffffffffc0202010 <commands+0x108>
ffffffffc0200246:	e79ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    }
    return 0;
}
ffffffffc020024a:	60a2                	ld	ra,8(sp)
ffffffffc020024c:	4501                	li	a0,0
ffffffffc020024e:	0141                	addi	sp,sp,16
ffffffffc0200250:	8082                	ret

ffffffffc0200252 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200252:	1141                	addi	sp,sp,-16
ffffffffc0200254:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200256:	ef1ff0ef          	jal	ra,ffffffffc0200146 <print_kerninfo>
    return 0;
}
ffffffffc020025a:	60a2                	ld	ra,8(sp)
ffffffffc020025c:	4501                	li	a0,0
ffffffffc020025e:	0141                	addi	sp,sp,16
ffffffffc0200260:	8082                	ret

ffffffffc0200262 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200262:	1141                	addi	sp,sp,-16
ffffffffc0200264:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200266:	f71ff0ef          	jal	ra,ffffffffc02001d6 <print_stackframe>
    return 0;
}
ffffffffc020026a:	60a2                	ld	ra,8(sp)
ffffffffc020026c:	4501                	li	a0,0
ffffffffc020026e:	0141                	addi	sp,sp,16
ffffffffc0200270:	8082                	ret

ffffffffc0200272 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	7115                	addi	sp,sp,-224
ffffffffc0200274:	e962                	sd	s8,144(sp)
ffffffffc0200276:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200278:	00002517          	auipc	a0,0x2
ffffffffc020027c:	cd850513          	addi	a0,a0,-808 # ffffffffc0201f50 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200280:	ed86                	sd	ra,216(sp)
ffffffffc0200282:	e9a2                	sd	s0,208(sp)
ffffffffc0200284:	e5a6                	sd	s1,200(sp)
ffffffffc0200286:	e1ca                	sd	s2,192(sp)
ffffffffc0200288:	fd4e                	sd	s3,184(sp)
ffffffffc020028a:	f952                	sd	s4,176(sp)
ffffffffc020028c:	f556                	sd	s5,168(sp)
ffffffffc020028e:	f15a                	sd	s6,160(sp)
ffffffffc0200290:	ed5e                	sd	s7,152(sp)
ffffffffc0200292:	e566                	sd	s9,136(sp)
ffffffffc0200294:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200296:	e29ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020029a:	00002517          	auipc	a0,0x2
ffffffffc020029e:	cde50513          	addi	a0,a0,-802 # ffffffffc0201f78 <commands+0x70>
ffffffffc02002a2:	e1dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc02002a6:	000c0563          	beqz	s8,ffffffffc02002b0 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002aa:	8562                	mv	a0,s8
ffffffffc02002ac:	3a6000ef          	jal	ra,ffffffffc0200652 <print_trapframe>
ffffffffc02002b0:	00002c97          	auipc	s9,0x2
ffffffffc02002b4:	c58c8c93          	addi	s9,s9,-936 # ffffffffc0201f08 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b8:	00002997          	auipc	s3,0x2
ffffffffc02002bc:	ce898993          	addi	s3,s3,-792 # ffffffffc0201fa0 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002c0:	00002917          	auipc	s2,0x2
ffffffffc02002c4:	ce890913          	addi	s2,s2,-792 # ffffffffc0201fa8 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c8:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002ca:	00002b17          	auipc	s6,0x2
ffffffffc02002ce:	ce6b0b13          	addi	s6,s6,-794 # ffffffffc0201fb0 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002d2:	00002a97          	auipc	s5,0x2
ffffffffc02002d6:	d36a8a93          	addi	s5,s5,-714 # ffffffffc0202008 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002da:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002dc:	854e                	mv	a0,s3
ffffffffc02002de:	177010ef          	jal	ra,ffffffffc0201c54 <readline>
ffffffffc02002e2:	842a                	mv	s0,a0
ffffffffc02002e4:	dd65                	beqz	a0,ffffffffc02002dc <kmonitor+0x6a>
ffffffffc02002e6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002ea:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002ec:	c999                	beqz	a1,ffffffffc0200302 <kmonitor+0x90>
ffffffffc02002ee:	854a                	mv	a0,s2
ffffffffc02002f0:	2c9010ef          	jal	ra,ffffffffc0201db8 <strchr>
ffffffffc02002f4:	c925                	beqz	a0,ffffffffc0200364 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002f6:	00144583          	lbu	a1,1(s0)
ffffffffc02002fa:	00040023          	sb	zero,0(s0)
ffffffffc02002fe:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200300:	f5fd                	bnez	a1,ffffffffc02002ee <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc0200302:	dce9                	beqz	s1,ffffffffc02002dc <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200304:	6582                	ld	a1,0(sp)
ffffffffc0200306:	00002d17          	auipc	s10,0x2
ffffffffc020030a:	c02d0d13          	addi	s10,s10,-1022 # ffffffffc0201f08 <commands>
    if (argc == 0) {
ffffffffc020030e:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200310:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200312:	0d61                	addi	s10,s10,24
ffffffffc0200314:	27b010ef          	jal	ra,ffffffffc0201d8e <strcmp>
ffffffffc0200318:	c919                	beqz	a0,ffffffffc020032e <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020031a:	2405                	addiw	s0,s0,1
ffffffffc020031c:	09740463          	beq	s0,s7,ffffffffc02003a4 <kmonitor+0x132>
ffffffffc0200320:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200324:	6582                	ld	a1,0(sp)
ffffffffc0200326:	0d61                	addi	s10,s10,24
ffffffffc0200328:	267010ef          	jal	ra,ffffffffc0201d8e <strcmp>
ffffffffc020032c:	f57d                	bnez	a0,ffffffffc020031a <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020032e:	00141793          	slli	a5,s0,0x1
ffffffffc0200332:	97a2                	add	a5,a5,s0
ffffffffc0200334:	078e                	slli	a5,a5,0x3
ffffffffc0200336:	97e6                	add	a5,a5,s9
ffffffffc0200338:	6b9c                	ld	a5,16(a5)
ffffffffc020033a:	8662                	mv	a2,s8
ffffffffc020033c:	002c                	addi	a1,sp,8
ffffffffc020033e:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200342:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200344:	f8055ce3          	bgez	a0,ffffffffc02002dc <kmonitor+0x6a>
}
ffffffffc0200348:	60ee                	ld	ra,216(sp)
ffffffffc020034a:	644e                	ld	s0,208(sp)
ffffffffc020034c:	64ae                	ld	s1,200(sp)
ffffffffc020034e:	690e                	ld	s2,192(sp)
ffffffffc0200350:	79ea                	ld	s3,184(sp)
ffffffffc0200352:	7a4a                	ld	s4,176(sp)
ffffffffc0200354:	7aaa                	ld	s5,168(sp)
ffffffffc0200356:	7b0a                	ld	s6,160(sp)
ffffffffc0200358:	6bea                	ld	s7,152(sp)
ffffffffc020035a:	6c4a                	ld	s8,144(sp)
ffffffffc020035c:	6caa                	ld	s9,136(sp)
ffffffffc020035e:	6d0a                	ld	s10,128(sp)
ffffffffc0200360:	612d                	addi	sp,sp,224
ffffffffc0200362:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200364:	00044783          	lbu	a5,0(s0)
ffffffffc0200368:	dfc9                	beqz	a5,ffffffffc0200302 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020036a:	03448863          	beq	s1,s4,ffffffffc020039a <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020036e:	00349793          	slli	a5,s1,0x3
ffffffffc0200372:	0118                	addi	a4,sp,128
ffffffffc0200374:	97ba                	add	a5,a5,a4
ffffffffc0200376:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020037e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	e591                	bnez	a1,ffffffffc020038c <kmonitor+0x11a>
ffffffffc0200382:	b749                	j	ffffffffc0200304 <kmonitor+0x92>
            buf ++;
ffffffffc0200384:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200386:	00044583          	lbu	a1,0(s0)
ffffffffc020038a:	ddad                	beqz	a1,ffffffffc0200304 <kmonitor+0x92>
ffffffffc020038c:	854a                	mv	a0,s2
ffffffffc020038e:	22b010ef          	jal	ra,ffffffffc0201db8 <strchr>
ffffffffc0200392:	d96d                	beqz	a0,ffffffffc0200384 <kmonitor+0x112>
ffffffffc0200394:	00044583          	lbu	a1,0(s0)
ffffffffc0200398:	bf91                	j	ffffffffc02002ec <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039a:	45c1                	li	a1,16
ffffffffc020039c:	855a                	mv	a0,s6
ffffffffc020039e:	d21ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02003a2:	b7f1                	j	ffffffffc020036e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003a4:	6582                	ld	a1,0(sp)
ffffffffc02003a6:	00002517          	auipc	a0,0x2
ffffffffc02003aa:	c2a50513          	addi	a0,a0,-982 # ffffffffc0201fd0 <commands+0xc8>
ffffffffc02003ae:	d11ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    return 0;
ffffffffc02003b2:	b72d                	j	ffffffffc02002dc <kmonitor+0x6a>

ffffffffc02003b4 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003b4:	00006317          	auipc	t1,0x6
ffffffffc02003b8:	07430313          	addi	t1,t1,116 # ffffffffc0206428 <is_panic>
ffffffffc02003bc:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003c0:	715d                	addi	sp,sp,-80
ffffffffc02003c2:	ec06                	sd	ra,24(sp)
ffffffffc02003c4:	e822                	sd	s0,16(sp)
ffffffffc02003c6:	f436                	sd	a3,40(sp)
ffffffffc02003c8:	f83a                	sd	a4,48(sp)
ffffffffc02003ca:	fc3e                	sd	a5,56(sp)
ffffffffc02003cc:	e0c2                	sd	a6,64(sp)
ffffffffc02003ce:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003d0:	02031c63          	bnez	t1,ffffffffc0200408 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003d4:	4785                	li	a5,1
ffffffffc02003d6:	8432                	mv	s0,a2
ffffffffc02003d8:	00006717          	auipc	a4,0x6
ffffffffc02003dc:	04f72823          	sw	a5,80(a4) # ffffffffc0206428 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e0:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003e2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	85aa                	mv	a1,a0
ffffffffc02003e6:	00002517          	auipc	a0,0x2
ffffffffc02003ea:	ca250513          	addi	a0,a0,-862 # ffffffffc0202088 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003ee:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003f0:	ccfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003f4:	65a2                	ld	a1,8(sp)
ffffffffc02003f6:	8522                	mv	a0,s0
ffffffffc02003f8:	ca7ff0ef          	jal	ra,ffffffffc020009e <vcprintf>
    cprintf("\n");
ffffffffc02003fc:	00002517          	auipc	a0,0x2
ffffffffc0200400:	b0450513          	addi	a0,a0,-1276 # ffffffffc0201f00 <etext+0x118>
ffffffffc0200404:	cbbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200408:	064000ef          	jal	ra,ffffffffc020046c <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020040c:	4501                	li	a0,0
ffffffffc020040e:	e65ff0ef          	jal	ra,ffffffffc0200272 <kmonitor>
ffffffffc0200412:	bfed                	j	ffffffffc020040c <__panic+0x58>

ffffffffc0200414 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200414:	1141                	addi	sp,sp,-16
ffffffffc0200416:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200418:	02000793          	li	a5,32
ffffffffc020041c:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200420:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200424:	67e1                	lui	a5,0x18
ffffffffc0200426:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020042a:	953e                	add	a0,a0,a5
ffffffffc020042c:	103010ef          	jal	ra,ffffffffc0201d2e <sbi_set_timer>
}
ffffffffc0200430:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200432:	00006797          	auipc	a5,0x6
ffffffffc0200436:	0007bf23          	sd	zero,30(a5) # ffffffffc0206450 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020043a:	00002517          	auipc	a0,0x2
ffffffffc020043e:	c6e50513          	addi	a0,a0,-914 # ffffffffc02020a8 <commands+0x1a0>
}
ffffffffc0200442:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200444:	c7bff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200448 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200448:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020044c:	67e1                	lui	a5,0x18
ffffffffc020044e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200452:	953e                	add	a0,a0,a5
ffffffffc0200454:	0db0106f          	j	ffffffffc0201d2e <sbi_set_timer>

ffffffffc0200458 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200458:	8082                	ret

ffffffffc020045a <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020045a:	0ff57513          	andi	a0,a0,255
ffffffffc020045e:	0b50106f          	j	ffffffffc0201d12 <sbi_console_putchar>

ffffffffc0200462 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200462:	0e90106f          	j	ffffffffc0201d4a <sbi_console_getchar>

ffffffffc0200466 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200466:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020046a:	8082                	ret

ffffffffc020046c <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020046c:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200470:	8082                	ret

ffffffffc0200472 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200472:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200476:	00000797          	auipc	a5,0x0
ffffffffc020047a:	30678793          	addi	a5,a5,774 # ffffffffc020077c <__alltraps>
ffffffffc020047e:	10579073          	csrw	stvec,a5
}
ffffffffc0200482:	8082                	ret

ffffffffc0200484 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	1141                	addi	sp,sp,-16
ffffffffc0200488:	e022                	sd	s0,0(sp)
ffffffffc020048a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048c:	00002517          	auipc	a0,0x2
ffffffffc0200490:	d3450513          	addi	a0,a0,-716 # ffffffffc02021c0 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200494:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200496:	c29ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020049a:	640c                	ld	a1,8(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	d3c50513          	addi	a0,a0,-708 # ffffffffc02021d8 <commands+0x2d0>
ffffffffc02004a4:	c1bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a8:	680c                	ld	a1,16(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	d4650513          	addi	a0,a0,-698 # ffffffffc02021f0 <commands+0x2e8>
ffffffffc02004b2:	c0dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004b6:	6c0c                	ld	a1,24(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	d5050513          	addi	a0,a0,-688 # ffffffffc0202208 <commands+0x300>
ffffffffc02004c0:	bffff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004c4:	700c                	ld	a1,32(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	d5a50513          	addi	a0,a0,-678 # ffffffffc0202220 <commands+0x318>
ffffffffc02004ce:	bf1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004d2:	740c                	ld	a1,40(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	d6450513          	addi	a0,a0,-668 # ffffffffc0202238 <commands+0x330>
ffffffffc02004dc:	be3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004e0:	780c                	ld	a1,48(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	d6e50513          	addi	a0,a0,-658 # ffffffffc0202250 <commands+0x348>
ffffffffc02004ea:	bd5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004ee:	7c0c                	ld	a1,56(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	d7850513          	addi	a0,a0,-648 # ffffffffc0202268 <commands+0x360>
ffffffffc02004f8:	bc7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004fc:	602c                	ld	a1,64(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	d8250513          	addi	a0,a0,-638 # ffffffffc0202280 <commands+0x378>
ffffffffc0200506:	bb9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc020050a:	642c                	ld	a1,72(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	d8c50513          	addi	a0,a0,-628 # ffffffffc0202298 <commands+0x390>
ffffffffc0200514:	babff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200518:	682c                	ld	a1,80(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	d9650513          	addi	a0,a0,-618 # ffffffffc02022b0 <commands+0x3a8>
ffffffffc0200522:	b9dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200526:	6c2c                	ld	a1,88(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	da050513          	addi	a0,a0,-608 # ffffffffc02022c8 <commands+0x3c0>
ffffffffc0200530:	b8fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200534:	702c                	ld	a1,96(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	daa50513          	addi	a0,a0,-598 # ffffffffc02022e0 <commands+0x3d8>
ffffffffc020053e:	b81ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200542:	742c                	ld	a1,104(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	db450513          	addi	a0,a0,-588 # ffffffffc02022f8 <commands+0x3f0>
ffffffffc020054c:	b73ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200550:	782c                	ld	a1,112(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	dbe50513          	addi	a0,a0,-578 # ffffffffc0202310 <commands+0x408>
ffffffffc020055a:	b65ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020055e:	7c2c                	ld	a1,120(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	dc850513          	addi	a0,a0,-568 # ffffffffc0202328 <commands+0x420>
ffffffffc0200568:	b57ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020056c:	604c                	ld	a1,128(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	dd250513          	addi	a0,a0,-558 # ffffffffc0202340 <commands+0x438>
ffffffffc0200576:	b49ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020057a:	644c                	ld	a1,136(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	ddc50513          	addi	a0,a0,-548 # ffffffffc0202358 <commands+0x450>
ffffffffc0200584:	b3bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200588:	684c                	ld	a1,144(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	de650513          	addi	a0,a0,-538 # ffffffffc0202370 <commands+0x468>
ffffffffc0200592:	b2dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200596:	6c4c                	ld	a1,152(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	df050513          	addi	a0,a0,-528 # ffffffffc0202388 <commands+0x480>
ffffffffc02005a0:	b1fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02005a4:	704c                	ld	a1,160(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	dfa50513          	addi	a0,a0,-518 # ffffffffc02023a0 <commands+0x498>
ffffffffc02005ae:	b11ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005b2:	744c                	ld	a1,168(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	e0450513          	addi	a0,a0,-508 # ffffffffc02023b8 <commands+0x4b0>
ffffffffc02005bc:	b03ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005c0:	784c                	ld	a1,176(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	e0e50513          	addi	a0,a0,-498 # ffffffffc02023d0 <commands+0x4c8>
ffffffffc02005ca:	af5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005ce:	7c4c                	ld	a1,184(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	e1850513          	addi	a0,a0,-488 # ffffffffc02023e8 <commands+0x4e0>
ffffffffc02005d8:	ae7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005dc:	606c                	ld	a1,192(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	e2250513          	addi	a0,a0,-478 # ffffffffc0202400 <commands+0x4f8>
ffffffffc02005e6:	ad9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005ea:	646c                	ld	a1,200(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	e2c50513          	addi	a0,a0,-468 # ffffffffc0202418 <commands+0x510>
ffffffffc02005f4:	acbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f8:	686c                	ld	a1,208(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	e3650513          	addi	a0,a0,-458 # ffffffffc0202430 <commands+0x528>
ffffffffc0200602:	abdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200606:	6c6c                	ld	a1,216(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	e4050513          	addi	a0,a0,-448 # ffffffffc0202448 <commands+0x540>
ffffffffc0200610:	aafff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200614:	706c                	ld	a1,224(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	e4a50513          	addi	a0,a0,-438 # ffffffffc0202460 <commands+0x558>
ffffffffc020061e:	aa1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200622:	746c                	ld	a1,232(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	e5450513          	addi	a0,a0,-428 # ffffffffc0202478 <commands+0x570>
ffffffffc020062c:	a93ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200630:	786c                	ld	a1,240(s0)
ffffffffc0200632:	00002517          	auipc	a0,0x2
ffffffffc0200636:	e5e50513          	addi	a0,a0,-418 # ffffffffc0202490 <commands+0x588>
ffffffffc020063a:	a85ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200640:	6402                	ld	s0,0(sp)
ffffffffc0200642:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200644:	00002517          	auipc	a0,0x2
ffffffffc0200648:	e6450513          	addi	a0,a0,-412 # ffffffffc02024a8 <commands+0x5a0>
}
ffffffffc020064c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020064e:	a71ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200652 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	1141                	addi	sp,sp,-16
ffffffffc0200654:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200656:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200658:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020065a:	00002517          	auipc	a0,0x2
ffffffffc020065e:	e6650513          	addi	a0,a0,-410 # ffffffffc02024c0 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200662:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200664:	a5bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200668:	8522                	mv	a0,s0
ffffffffc020066a:	e1bff0ef          	jal	ra,ffffffffc0200484 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020066e:	10043583          	ld	a1,256(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	e6650513          	addi	a0,a0,-410 # ffffffffc02024d8 <commands+0x5d0>
ffffffffc020067a:	a45ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020067e:	10843583          	ld	a1,264(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	e6e50513          	addi	a0,a0,-402 # ffffffffc02024f0 <commands+0x5e8>
ffffffffc020068a:	a35ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020068e:	11043583          	ld	a1,272(s0)
ffffffffc0200692:	00002517          	auipc	a0,0x2
ffffffffc0200696:	e7650513          	addi	a0,a0,-394 # ffffffffc0202508 <commands+0x600>
ffffffffc020069a:	a25ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	11843583          	ld	a1,280(s0)
}
ffffffffc02006a2:	6402                	ld	s0,0(sp)
ffffffffc02006a4:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a6:	00002517          	auipc	a0,0x2
ffffffffc02006aa:	e7a50513          	addi	a0,a0,-390 # ffffffffc0202520 <commands+0x618>
}
ffffffffc02006ae:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006b0:	a0fff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02006b4 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006b4:	11853783          	ld	a5,280(a0)
ffffffffc02006b8:	577d                	li	a4,-1
ffffffffc02006ba:	8305                	srli	a4,a4,0x1
ffffffffc02006bc:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006be:	472d                	li	a4,11
ffffffffc02006c0:	08f76563          	bltu	a4,a5,ffffffffc020074a <interrupt_handler+0x96>
ffffffffc02006c4:	00002717          	auipc	a4,0x2
ffffffffc02006c8:	a0070713          	addi	a4,a4,-1536 # ffffffffc02020c4 <commands+0x1bc>
ffffffffc02006cc:	078a                	slli	a5,a5,0x2
ffffffffc02006ce:	97ba                	add	a5,a5,a4
ffffffffc02006d0:	439c                	lw	a5,0(a5)
ffffffffc02006d2:	97ba                	add	a5,a5,a4
ffffffffc02006d4:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	a8250513          	addi	a0,a0,-1406 # ffffffffc0202158 <commands+0x250>
ffffffffc02006de:	9e1ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006e2:	00002517          	auipc	a0,0x2
ffffffffc02006e6:	a5650513          	addi	a0,a0,-1450 # ffffffffc0202138 <commands+0x230>
ffffffffc02006ea:	9d5ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006ee:	00002517          	auipc	a0,0x2
ffffffffc02006f2:	a0a50513          	addi	a0,a0,-1526 # ffffffffc02020f8 <commands+0x1f0>
ffffffffc02006f6:	9c9ff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006fa:	00002517          	auipc	a0,0x2
ffffffffc02006fe:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0202178 <commands+0x270>
ffffffffc0200702:	9bdff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200706:	1141                	addi	sp,sp,-16
ffffffffc0200708:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc020070a:	d3fff0ef          	jal	ra,ffffffffc0200448 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc020070e:	00006797          	auipc	a5,0x6
ffffffffc0200712:	d4278793          	addi	a5,a5,-702 # ffffffffc0206450 <ticks>
ffffffffc0200716:	639c                	ld	a5,0(a5)
ffffffffc0200718:	06400713          	li	a4,100
ffffffffc020071c:	0785                	addi	a5,a5,1
ffffffffc020071e:	02e7f733          	remu	a4,a5,a4
ffffffffc0200722:	00006697          	auipc	a3,0x6
ffffffffc0200726:	d2f6b723          	sd	a5,-722(a3) # ffffffffc0206450 <ticks>
ffffffffc020072a:	c315                	beqz	a4,ffffffffc020074e <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020072c:	60a2                	ld	ra,8(sp)
ffffffffc020072e:	0141                	addi	sp,sp,16
ffffffffc0200730:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200732:	00002517          	auipc	a0,0x2
ffffffffc0200736:	a6e50513          	addi	a0,a0,-1426 # ffffffffc02021a0 <commands+0x298>
ffffffffc020073a:	985ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020073e:	00002517          	auipc	a0,0x2
ffffffffc0200742:	9da50513          	addi	a0,a0,-1574 # ffffffffc0202118 <commands+0x210>
ffffffffc0200746:	979ff06f          	j	ffffffffc02000be <cprintf>
            print_trapframe(tf);
ffffffffc020074a:	f09ff06f          	j	ffffffffc0200652 <print_trapframe>
}
ffffffffc020074e:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200750:	06400593          	li	a1,100
ffffffffc0200754:	00002517          	auipc	a0,0x2
ffffffffc0200758:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0202190 <commands+0x288>
}
ffffffffc020075c:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020075e:	961ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200762 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200762:	11853783          	ld	a5,280(a0)
ffffffffc0200766:	0007c863          	bltz	a5,ffffffffc0200776 <trap+0x14>
    switch (tf->cause) {
ffffffffc020076a:	472d                	li	a4,11
ffffffffc020076c:	00f76363          	bltu	a4,a5,ffffffffc0200772 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200770:	8082                	ret
            print_trapframe(tf);
ffffffffc0200772:	ee1ff06f          	j	ffffffffc0200652 <print_trapframe>
        interrupt_handler(tf);
ffffffffc0200776:	f3fff06f          	j	ffffffffc02006b4 <interrupt_handler>
	...

ffffffffc020077c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020077c:	14011073          	csrw	sscratch,sp
ffffffffc0200780:	712d                	addi	sp,sp,-288
ffffffffc0200782:	e002                	sd	zero,0(sp)
ffffffffc0200784:	e406                	sd	ra,8(sp)
ffffffffc0200786:	ec0e                	sd	gp,24(sp)
ffffffffc0200788:	f012                	sd	tp,32(sp)
ffffffffc020078a:	f416                	sd	t0,40(sp)
ffffffffc020078c:	f81a                	sd	t1,48(sp)
ffffffffc020078e:	fc1e                	sd	t2,56(sp)
ffffffffc0200790:	e0a2                	sd	s0,64(sp)
ffffffffc0200792:	e4a6                	sd	s1,72(sp)
ffffffffc0200794:	e8aa                	sd	a0,80(sp)
ffffffffc0200796:	ecae                	sd	a1,88(sp)
ffffffffc0200798:	f0b2                	sd	a2,96(sp)
ffffffffc020079a:	f4b6                	sd	a3,104(sp)
ffffffffc020079c:	f8ba                	sd	a4,112(sp)
ffffffffc020079e:	fcbe                	sd	a5,120(sp)
ffffffffc02007a0:	e142                	sd	a6,128(sp)
ffffffffc02007a2:	e546                	sd	a7,136(sp)
ffffffffc02007a4:	e94a                	sd	s2,144(sp)
ffffffffc02007a6:	ed4e                	sd	s3,152(sp)
ffffffffc02007a8:	f152                	sd	s4,160(sp)
ffffffffc02007aa:	f556                	sd	s5,168(sp)
ffffffffc02007ac:	f95a                	sd	s6,176(sp)
ffffffffc02007ae:	fd5e                	sd	s7,184(sp)
ffffffffc02007b0:	e1e2                	sd	s8,192(sp)
ffffffffc02007b2:	e5e6                	sd	s9,200(sp)
ffffffffc02007b4:	e9ea                	sd	s10,208(sp)
ffffffffc02007b6:	edee                	sd	s11,216(sp)
ffffffffc02007b8:	f1f2                	sd	t3,224(sp)
ffffffffc02007ba:	f5f6                	sd	t4,232(sp)
ffffffffc02007bc:	f9fa                	sd	t5,240(sp)
ffffffffc02007be:	fdfe                	sd	t6,248(sp)
ffffffffc02007c0:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007c4:	100024f3          	csrr	s1,sstatus
ffffffffc02007c8:	14102973          	csrr	s2,sepc
ffffffffc02007cc:	143029f3          	csrr	s3,stval
ffffffffc02007d0:	14202a73          	csrr	s4,scause
ffffffffc02007d4:	e822                	sd	s0,16(sp)
ffffffffc02007d6:	e226                	sd	s1,256(sp)
ffffffffc02007d8:	e64a                	sd	s2,264(sp)
ffffffffc02007da:	ea4e                	sd	s3,272(sp)
ffffffffc02007dc:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007de:	850a                	mv	a0,sp
    jal trap
ffffffffc02007e0:	f83ff0ef          	jal	ra,ffffffffc0200762 <trap>

ffffffffc02007e4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007e4:	6492                	ld	s1,256(sp)
ffffffffc02007e6:	6932                	ld	s2,264(sp)
ffffffffc02007e8:	10049073          	csrw	sstatus,s1
ffffffffc02007ec:	14191073          	csrw	sepc,s2
ffffffffc02007f0:	60a2                	ld	ra,8(sp)
ffffffffc02007f2:	61e2                	ld	gp,24(sp)
ffffffffc02007f4:	7202                	ld	tp,32(sp)
ffffffffc02007f6:	72a2                	ld	t0,40(sp)
ffffffffc02007f8:	7342                	ld	t1,48(sp)
ffffffffc02007fa:	73e2                	ld	t2,56(sp)
ffffffffc02007fc:	6406                	ld	s0,64(sp)
ffffffffc02007fe:	64a6                	ld	s1,72(sp)
ffffffffc0200800:	6546                	ld	a0,80(sp)
ffffffffc0200802:	65e6                	ld	a1,88(sp)
ffffffffc0200804:	7606                	ld	a2,96(sp)
ffffffffc0200806:	76a6                	ld	a3,104(sp)
ffffffffc0200808:	7746                	ld	a4,112(sp)
ffffffffc020080a:	77e6                	ld	a5,120(sp)
ffffffffc020080c:	680a                	ld	a6,128(sp)
ffffffffc020080e:	68aa                	ld	a7,136(sp)
ffffffffc0200810:	694a                	ld	s2,144(sp)
ffffffffc0200812:	69ea                	ld	s3,152(sp)
ffffffffc0200814:	7a0a                	ld	s4,160(sp)
ffffffffc0200816:	7aaa                	ld	s5,168(sp)
ffffffffc0200818:	7b4a                	ld	s6,176(sp)
ffffffffc020081a:	7bea                	ld	s7,184(sp)
ffffffffc020081c:	6c0e                	ld	s8,192(sp)
ffffffffc020081e:	6cae                	ld	s9,200(sp)
ffffffffc0200820:	6d4e                	ld	s10,208(sp)
ffffffffc0200822:	6dee                	ld	s11,216(sp)
ffffffffc0200824:	7e0e                	ld	t3,224(sp)
ffffffffc0200826:	7eae                	ld	t4,232(sp)
ffffffffc0200828:	7f4e                	ld	t5,240(sp)
ffffffffc020082a:	7fee                	ld	t6,248(sp)
ffffffffc020082c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc020082e:	10200073          	sret

ffffffffc0200832 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200832:	00006797          	auipc	a5,0x6
ffffffffc0200836:	c2678793          	addi	a5,a5,-986 # ffffffffc0206458 <free_area>
ffffffffc020083a:	e79c                	sd	a5,8(a5)
ffffffffc020083c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020083e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200842:	8082                	ret

ffffffffc0200844 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200844:	00006517          	auipc	a0,0x6
ffffffffc0200848:	c2456503          	lwu	a0,-988(a0) # ffffffffc0206468 <free_area+0x10>
ffffffffc020084c:	8082                	ret

ffffffffc020084e <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc020084e:	c15d                	beqz	a0,ffffffffc02008f4 <best_fit_alloc_pages+0xa6>
    if (n > nr_free) {
ffffffffc0200850:	00006617          	auipc	a2,0x6
ffffffffc0200854:	c0860613          	addi	a2,a2,-1016 # ffffffffc0206458 <free_area>
ffffffffc0200858:	01062803          	lw	a6,16(a2)
ffffffffc020085c:	86aa                	mv	a3,a0
ffffffffc020085e:	02081793          	slli	a5,a6,0x20
ffffffffc0200862:	9381                	srli	a5,a5,0x20
ffffffffc0200864:	08a7e663          	bltu	a5,a0,ffffffffc02008f0 <best_fit_alloc_pages+0xa2>
    size_t min_size = nr_free + 1;
ffffffffc0200868:	0018059b          	addiw	a1,a6,1
ffffffffc020086c:	1582                	slli	a1,a1,0x20
ffffffffc020086e:	9181                	srli	a1,a1,0x20
    list_entry_t *le = &free_list;
ffffffffc0200870:	87b2                	mv	a5,a2
    struct Page *page = NULL;
ffffffffc0200872:	4501                	li	a0,0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200874:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200876:	00c78e63          	beq	a5,a2,ffffffffc0200892 <best_fit_alloc_pages+0x44>
        if (p->property >= n && p->property < min_size) {
ffffffffc020087a:	ff87e703          	lwu	a4,-8(a5)
ffffffffc020087e:	fed76be3          	bltu	a4,a3,ffffffffc0200874 <best_fit_alloc_pages+0x26>
ffffffffc0200882:	feb779e3          	bleu	a1,a4,ffffffffc0200874 <best_fit_alloc_pages+0x26>
        struct Page *p = le2page(le, page_link);
ffffffffc0200886:	fe878513          	addi	a0,a5,-24
ffffffffc020088a:	679c                	ld	a5,8(a5)
ffffffffc020088c:	85ba                	mv	a1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020088e:	fec796e3          	bne	a5,a2,ffffffffc020087a <best_fit_alloc_pages+0x2c>
    if (page != NULL) {
ffffffffc0200892:	c125                	beqz	a0,ffffffffc02008f2 <best_fit_alloc_pages+0xa4>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200894:	7118                	ld	a4,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200896:	6d10                	ld	a2,24(a0)
        if (page->property > n) {
ffffffffc0200898:	490c                	lw	a1,16(a0)
ffffffffc020089a:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020089e:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc02008a0:	e310                	sd	a2,0(a4)
ffffffffc02008a2:	02059713          	slli	a4,a1,0x20
ffffffffc02008a6:	9301                	srli	a4,a4,0x20
ffffffffc02008a8:	02e6f863          	bleu	a4,a3,ffffffffc02008d8 <best_fit_alloc_pages+0x8a>
            struct Page *p = page + n;
ffffffffc02008ac:	00269713          	slli	a4,a3,0x2
ffffffffc02008b0:	9736                	add	a4,a4,a3
ffffffffc02008b2:	070e                	slli	a4,a4,0x3
ffffffffc02008b4:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02008b6:	411585bb          	subw	a1,a1,a7
ffffffffc02008ba:	cb0c                	sw	a1,16(a4)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02008bc:	4689                	li	a3,2
ffffffffc02008be:	00870593          	addi	a1,a4,8
ffffffffc02008c2:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02008c6:	6614                	ld	a3,8(a2)
            list_add(prev, &(p->page_link));
ffffffffc02008c8:	01870593          	addi	a1,a4,24
    prev->next = next->prev = elm;
ffffffffc02008cc:	0107a803          	lw	a6,16(a5)
ffffffffc02008d0:	e28c                	sd	a1,0(a3)
ffffffffc02008d2:	e60c                	sd	a1,8(a2)
    elm->next = next;
ffffffffc02008d4:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02008d6:	ef10                	sd	a2,24(a4)
        nr_free -= n;
ffffffffc02008d8:	4118083b          	subw	a6,a6,a7
ffffffffc02008dc:	00006797          	auipc	a5,0x6
ffffffffc02008e0:	b907a623          	sw	a6,-1140(a5) # ffffffffc0206468 <free_area+0x10>
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02008e4:	57f5                	li	a5,-3
ffffffffc02008e6:	00850713          	addi	a4,a0,8
ffffffffc02008ea:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc02008ee:	8082                	ret
        return NULL;
ffffffffc02008f0:	4501                	li	a0,0
}
ffffffffc02008f2:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02008f4:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02008f6:	00002697          	auipc	a3,0x2
ffffffffc02008fa:	c4268693          	addi	a3,a3,-958 # ffffffffc0202538 <commands+0x630>
ffffffffc02008fe:	00002617          	auipc	a2,0x2
ffffffffc0200902:	c4260613          	addi	a2,a2,-958 # ffffffffc0202540 <commands+0x638>
ffffffffc0200906:	07000593          	li	a1,112
ffffffffc020090a:	00002517          	auipc	a0,0x2
ffffffffc020090e:	c4e50513          	addi	a0,a0,-946 # ffffffffc0202558 <commands+0x650>
best_fit_alloc_pages(size_t n) {
ffffffffc0200912:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200914:	aa1ff0ef          	jal	ra,ffffffffc02003b4 <__panic>

ffffffffc0200918 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200918:	715d                	addi	sp,sp,-80
ffffffffc020091a:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc020091c:	00006917          	auipc	s2,0x6
ffffffffc0200920:	b3c90913          	addi	s2,s2,-1220 # ffffffffc0206458 <free_area>
ffffffffc0200924:	00893783          	ld	a5,8(s2)
ffffffffc0200928:	e486                	sd	ra,72(sp)
ffffffffc020092a:	e0a2                	sd	s0,64(sp)
ffffffffc020092c:	fc26                	sd	s1,56(sp)
ffffffffc020092e:	f44e                	sd	s3,40(sp)
ffffffffc0200930:	f052                	sd	s4,32(sp)
ffffffffc0200932:	ec56                	sd	s5,24(sp)
ffffffffc0200934:	e85a                	sd	s6,16(sp)
ffffffffc0200936:	e45e                	sd	s7,8(sp)
ffffffffc0200938:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020093a:	2d278363          	beq	a5,s2,ffffffffc0200c00 <best_fit_check+0x2e8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020093e:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200942:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200944:	8b05                	andi	a4,a4,1
ffffffffc0200946:	2c070163          	beqz	a4,ffffffffc0200c08 <best_fit_check+0x2f0>
    int count = 0, total = 0;
ffffffffc020094a:	4401                	li	s0,0
ffffffffc020094c:	4481                	li	s1,0
ffffffffc020094e:	a031                	j	ffffffffc020095a <best_fit_check+0x42>
ffffffffc0200950:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200954:	8b09                	andi	a4,a4,2
ffffffffc0200956:	2a070963          	beqz	a4,ffffffffc0200c08 <best_fit_check+0x2f0>
        count ++, total += p->property;
ffffffffc020095a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020095e:	679c                	ld	a5,8(a5)
ffffffffc0200960:	2485                	addiw	s1,s1,1
ffffffffc0200962:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200964:	ff2796e3          	bne	a5,s2,ffffffffc0200950 <best_fit_check+0x38>
ffffffffc0200968:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc020096a:	1f7000ef          	jal	ra,ffffffffc0201360 <nr_free_pages>
ffffffffc020096e:	37351d63          	bne	a0,s3,ffffffffc0200ce8 <best_fit_check+0x3d0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200972:	4505                	li	a0,1
ffffffffc0200974:	163000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200978:	8a2a                	mv	s4,a0
ffffffffc020097a:	3a050763          	beqz	a0,ffffffffc0200d28 <best_fit_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020097e:	4505                	li	a0,1
ffffffffc0200980:	157000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200984:	89aa                	mv	s3,a0
ffffffffc0200986:	38050163          	beqz	a0,ffffffffc0200d08 <best_fit_check+0x3f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020098a:	4505                	li	a0,1
ffffffffc020098c:	14b000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200990:	8aaa                	mv	s5,a0
ffffffffc0200992:	30050b63          	beqz	a0,ffffffffc0200ca8 <best_fit_check+0x390>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200996:	293a0963          	beq	s4,s3,ffffffffc0200c28 <best_fit_check+0x310>
ffffffffc020099a:	28aa0763          	beq	s4,a0,ffffffffc0200c28 <best_fit_check+0x310>
ffffffffc020099e:	28a98563          	beq	s3,a0,ffffffffc0200c28 <best_fit_check+0x310>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02009a2:	000a2783          	lw	a5,0(s4)
ffffffffc02009a6:	2a079163          	bnez	a5,ffffffffc0200c48 <best_fit_check+0x330>
ffffffffc02009aa:	0009a783          	lw	a5,0(s3)
ffffffffc02009ae:	28079d63          	bnez	a5,ffffffffc0200c48 <best_fit_check+0x330>
ffffffffc02009b2:	411c                	lw	a5,0(a0)
ffffffffc02009b4:	28079a63          	bnez	a5,ffffffffc0200c48 <best_fit_check+0x330>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009b8:	00006797          	auipc	a5,0x6
ffffffffc02009bc:	bc078793          	addi	a5,a5,-1088 # ffffffffc0206578 <pages>
ffffffffc02009c0:	639c                	ld	a5,0(a5)
ffffffffc02009c2:	00002717          	auipc	a4,0x2
ffffffffc02009c6:	bae70713          	addi	a4,a4,-1106 # ffffffffc0202570 <commands+0x668>
ffffffffc02009ca:	630c                	ld	a1,0(a4)
ffffffffc02009cc:	40fa0733          	sub	a4,s4,a5
ffffffffc02009d0:	870d                	srai	a4,a4,0x3
ffffffffc02009d2:	02b70733          	mul	a4,a4,a1
ffffffffc02009d6:	00002697          	auipc	a3,0x2
ffffffffc02009da:	2da68693          	addi	a3,a3,730 # ffffffffc0202cb0 <nbase>
ffffffffc02009de:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02009e0:	00006697          	auipc	a3,0x6
ffffffffc02009e4:	a5068693          	addi	a3,a3,-1456 # ffffffffc0206430 <npage>
ffffffffc02009e8:	6294                	ld	a3,0(a3)
ffffffffc02009ea:	06b2                	slli	a3,a3,0xc
ffffffffc02009ec:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02009ee:	0732                	slli	a4,a4,0xc
ffffffffc02009f0:	26d77c63          	bleu	a3,a4,ffffffffc0200c68 <best_fit_check+0x350>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009f4:	40f98733          	sub	a4,s3,a5
ffffffffc02009f8:	870d                	srai	a4,a4,0x3
ffffffffc02009fa:	02b70733          	mul	a4,a4,a1
ffffffffc02009fe:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a00:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200a02:	42d77363          	bleu	a3,a4,ffffffffc0200e28 <best_fit_check+0x510>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a06:	40f507b3          	sub	a5,a0,a5
ffffffffc0200a0a:	878d                	srai	a5,a5,0x3
ffffffffc0200a0c:	02b787b3          	mul	a5,a5,a1
ffffffffc0200a10:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a12:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200a14:	3ed7fa63          	bleu	a3,a5,ffffffffc0200e08 <best_fit_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc0200a18:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200a1a:	00093c03          	ld	s8,0(s2)
ffffffffc0200a1e:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200a22:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200a26:	00006797          	auipc	a5,0x6
ffffffffc0200a2a:	a327bd23          	sd	s2,-1478(a5) # ffffffffc0206460 <free_area+0x8>
ffffffffc0200a2e:	00006797          	auipc	a5,0x6
ffffffffc0200a32:	a327b523          	sd	s2,-1494(a5) # ffffffffc0206458 <free_area>
    nr_free = 0;
ffffffffc0200a36:	00006797          	auipc	a5,0x6
ffffffffc0200a3a:	a207a923          	sw	zero,-1486(a5) # ffffffffc0206468 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200a3e:	099000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200a42:	3a051363          	bnez	a0,ffffffffc0200de8 <best_fit_check+0x4d0>
    free_page(p0);
ffffffffc0200a46:	4585                	li	a1,1
ffffffffc0200a48:	8552                	mv	a0,s4
ffffffffc0200a4a:	0d1000ef          	jal	ra,ffffffffc020131a <free_pages>
    free_page(p1);
ffffffffc0200a4e:	4585                	li	a1,1
ffffffffc0200a50:	854e                	mv	a0,s3
ffffffffc0200a52:	0c9000ef          	jal	ra,ffffffffc020131a <free_pages>
    free_page(p2);
ffffffffc0200a56:	4585                	li	a1,1
ffffffffc0200a58:	8556                	mv	a0,s5
ffffffffc0200a5a:	0c1000ef          	jal	ra,ffffffffc020131a <free_pages>
    assert(nr_free == 3);
ffffffffc0200a5e:	01092703          	lw	a4,16(s2)
ffffffffc0200a62:	478d                	li	a5,3
ffffffffc0200a64:	36f71263          	bne	a4,a5,ffffffffc0200dc8 <best_fit_check+0x4b0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a68:	4505                	li	a0,1
ffffffffc0200a6a:	06d000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200a6e:	89aa                	mv	s3,a0
ffffffffc0200a70:	32050c63          	beqz	a0,ffffffffc0200da8 <best_fit_check+0x490>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a74:	4505                	li	a0,1
ffffffffc0200a76:	061000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200a7a:	8aaa                	mv	s5,a0
ffffffffc0200a7c:	30050663          	beqz	a0,ffffffffc0200d88 <best_fit_check+0x470>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a80:	4505                	li	a0,1
ffffffffc0200a82:	055000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200a86:	8a2a                	mv	s4,a0
ffffffffc0200a88:	2e050063          	beqz	a0,ffffffffc0200d68 <best_fit_check+0x450>
    assert(alloc_page() == NULL);
ffffffffc0200a8c:	4505                	li	a0,1
ffffffffc0200a8e:	049000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200a92:	2a051b63          	bnez	a0,ffffffffc0200d48 <best_fit_check+0x430>
    free_page(p0);
ffffffffc0200a96:	4585                	li	a1,1
ffffffffc0200a98:	854e                	mv	a0,s3
ffffffffc0200a9a:	081000ef          	jal	ra,ffffffffc020131a <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200a9e:	00893783          	ld	a5,8(s2)
ffffffffc0200aa2:	1f278363          	beq	a5,s2,ffffffffc0200c88 <best_fit_check+0x370>
    assert((p = alloc_page()) == p0);
ffffffffc0200aa6:	4505                	li	a0,1
ffffffffc0200aa8:	02f000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200aac:	54a99e63          	bne	s3,a0,ffffffffc0201008 <best_fit_check+0x6f0>
    assert(alloc_page() == NULL);
ffffffffc0200ab0:	4505                	li	a0,1
ffffffffc0200ab2:	025000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200ab6:	52051963          	bnez	a0,ffffffffc0200fe8 <best_fit_check+0x6d0>
    assert(nr_free == 0);
ffffffffc0200aba:	01092783          	lw	a5,16(s2)
ffffffffc0200abe:	50079563          	bnez	a5,ffffffffc0200fc8 <best_fit_check+0x6b0>
    free_page(p);
ffffffffc0200ac2:	854e                	mv	a0,s3
ffffffffc0200ac4:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200ac6:	00006797          	auipc	a5,0x6
ffffffffc0200aca:	9987b923          	sd	s8,-1646(a5) # ffffffffc0206458 <free_area>
ffffffffc0200ace:	00006797          	auipc	a5,0x6
ffffffffc0200ad2:	9977b923          	sd	s7,-1646(a5) # ffffffffc0206460 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200ad6:	00006797          	auipc	a5,0x6
ffffffffc0200ada:	9967a923          	sw	s6,-1646(a5) # ffffffffc0206468 <free_area+0x10>
    free_page(p);
ffffffffc0200ade:	03d000ef          	jal	ra,ffffffffc020131a <free_pages>
    free_page(p1);
ffffffffc0200ae2:	4585                	li	a1,1
ffffffffc0200ae4:	8556                	mv	a0,s5
ffffffffc0200ae6:	035000ef          	jal	ra,ffffffffc020131a <free_pages>
    free_page(p2);
ffffffffc0200aea:	4585                	li	a1,1
ffffffffc0200aec:	8552                	mv	a0,s4
ffffffffc0200aee:	02d000ef          	jal	ra,ffffffffc020131a <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200af2:	4515                	li	a0,5
ffffffffc0200af4:	7e2000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200af8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200afa:	4a050763          	beqz	a0,ffffffffc0200fa8 <best_fit_check+0x690>
ffffffffc0200afe:	651c                	ld	a5,8(a0)
ffffffffc0200b00:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200b02:	8b85                	andi	a5,a5,1
ffffffffc0200b04:	48079263          	bnez	a5,ffffffffc0200f88 <best_fit_check+0x670>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200b08:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200b0a:	00093b03          	ld	s6,0(s2)
ffffffffc0200b0e:	00893a83          	ld	s5,8(s2)
ffffffffc0200b12:	00006797          	auipc	a5,0x6
ffffffffc0200b16:	9527b323          	sd	s2,-1722(a5) # ffffffffc0206458 <free_area>
ffffffffc0200b1a:	00006797          	auipc	a5,0x6
ffffffffc0200b1e:	9527b323          	sd	s2,-1722(a5) # ffffffffc0206460 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200b22:	7b4000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200b26:	44051163          	bnez	a0,ffffffffc0200f68 <best_fit_check+0x650>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200b2a:	4589                	li	a1,2
ffffffffc0200b2c:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200b30:	01092b83          	lw	s7,16(s2)
    free_pages(p0 + 4, 1);
ffffffffc0200b34:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200b38:	00006797          	auipc	a5,0x6
ffffffffc0200b3c:	9207a823          	sw	zero,-1744(a5) # ffffffffc0206468 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200b40:	7da000ef          	jal	ra,ffffffffc020131a <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200b44:	8562                	mv	a0,s8
ffffffffc0200b46:	4585                	li	a1,1
ffffffffc0200b48:	7d2000ef          	jal	ra,ffffffffc020131a <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200b4c:	4511                	li	a0,4
ffffffffc0200b4e:	788000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200b52:	3e051b63          	bnez	a0,ffffffffc0200f48 <best_fit_check+0x630>
ffffffffc0200b56:	0309b783          	ld	a5,48(s3)
ffffffffc0200b5a:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200b5c:	8b85                	andi	a5,a5,1
ffffffffc0200b5e:	3c078563          	beqz	a5,ffffffffc0200f28 <best_fit_check+0x610>
ffffffffc0200b62:	0389a703          	lw	a4,56(s3)
ffffffffc0200b66:	4789                	li	a5,2
ffffffffc0200b68:	3cf71063          	bne	a4,a5,ffffffffc0200f28 <best_fit_check+0x610>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200b6c:	4505                	li	a0,1
ffffffffc0200b6e:	768000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200b72:	8a2a                	mv	s4,a0
ffffffffc0200b74:	38050a63          	beqz	a0,ffffffffc0200f08 <best_fit_check+0x5f0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200b78:	4509                	li	a0,2
ffffffffc0200b7a:	75c000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200b7e:	36050563          	beqz	a0,ffffffffc0200ee8 <best_fit_check+0x5d0>
    assert(p0 + 4 == p1);
ffffffffc0200b82:	354c1363          	bne	s8,s4,ffffffffc0200ec8 <best_fit_check+0x5b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200b86:	854e                	mv	a0,s3
ffffffffc0200b88:	4595                	li	a1,5
ffffffffc0200b8a:	790000ef          	jal	ra,ffffffffc020131a <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200b8e:	4515                	li	a0,5
ffffffffc0200b90:	746000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200b94:	89aa                	mv	s3,a0
ffffffffc0200b96:	30050963          	beqz	a0,ffffffffc0200ea8 <best_fit_check+0x590>
    assert(alloc_page() == NULL);
ffffffffc0200b9a:	4505                	li	a0,1
ffffffffc0200b9c:	73a000ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc0200ba0:	2e051463          	bnez	a0,ffffffffc0200e88 <best_fit_check+0x570>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200ba4:	01092783          	lw	a5,16(s2)
ffffffffc0200ba8:	2c079063          	bnez	a5,ffffffffc0200e68 <best_fit_check+0x550>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200bac:	4595                	li	a1,5
ffffffffc0200bae:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200bb0:	00006797          	auipc	a5,0x6
ffffffffc0200bb4:	8b77ac23          	sw	s7,-1864(a5) # ffffffffc0206468 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200bb8:	00006797          	auipc	a5,0x6
ffffffffc0200bbc:	8b67b023          	sd	s6,-1888(a5) # ffffffffc0206458 <free_area>
ffffffffc0200bc0:	00006797          	auipc	a5,0x6
ffffffffc0200bc4:	8b57b023          	sd	s5,-1888(a5) # ffffffffc0206460 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200bc8:	752000ef          	jal	ra,ffffffffc020131a <free_pages>
    return listelm->next;
ffffffffc0200bcc:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bd0:	01278963          	beq	a5,s2,ffffffffc0200be2 <best_fit_check+0x2ca>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200bd4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200bd8:	679c                	ld	a5,8(a5)
ffffffffc0200bda:	34fd                	addiw	s1,s1,-1
ffffffffc0200bdc:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bde:	ff279be3          	bne	a5,s2,ffffffffc0200bd4 <best_fit_check+0x2bc>
    }
    assert(count == 0);
ffffffffc0200be2:	26049363          	bnez	s1,ffffffffc0200e48 <best_fit_check+0x530>
    assert(total == 0);
ffffffffc0200be6:	e06d                	bnez	s0,ffffffffc0200cc8 <best_fit_check+0x3b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200be8:	60a6                	ld	ra,72(sp)
ffffffffc0200bea:	6406                	ld	s0,64(sp)
ffffffffc0200bec:	74e2                	ld	s1,56(sp)
ffffffffc0200bee:	7942                	ld	s2,48(sp)
ffffffffc0200bf0:	79a2                	ld	s3,40(sp)
ffffffffc0200bf2:	7a02                	ld	s4,32(sp)
ffffffffc0200bf4:	6ae2                	ld	s5,24(sp)
ffffffffc0200bf6:	6b42                	ld	s6,16(sp)
ffffffffc0200bf8:	6ba2                	ld	s7,8(sp)
ffffffffc0200bfa:	6c02                	ld	s8,0(sp)
ffffffffc0200bfc:	6161                	addi	sp,sp,80
ffffffffc0200bfe:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c00:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200c02:	4401                	li	s0,0
ffffffffc0200c04:	4481                	li	s1,0
ffffffffc0200c06:	b395                	j	ffffffffc020096a <best_fit_check+0x52>
        assert(PageProperty(p));
ffffffffc0200c08:	00002697          	auipc	a3,0x2
ffffffffc0200c0c:	97068693          	addi	a3,a3,-1680 # ffffffffc0202578 <commands+0x670>
ffffffffc0200c10:	00002617          	auipc	a2,0x2
ffffffffc0200c14:	93060613          	addi	a2,a2,-1744 # ffffffffc0202540 <commands+0x638>
ffffffffc0200c18:	11000593          	li	a1,272
ffffffffc0200c1c:	00002517          	auipc	a0,0x2
ffffffffc0200c20:	93c50513          	addi	a0,a0,-1732 # ffffffffc0202558 <commands+0x650>
ffffffffc0200c24:	f90ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c28:	00002697          	auipc	a3,0x2
ffffffffc0200c2c:	9e068693          	addi	a3,a3,-1568 # ffffffffc0202608 <commands+0x700>
ffffffffc0200c30:	00002617          	auipc	a2,0x2
ffffffffc0200c34:	91060613          	addi	a2,a2,-1776 # ffffffffc0202540 <commands+0x638>
ffffffffc0200c38:	0dc00593          	li	a1,220
ffffffffc0200c3c:	00002517          	auipc	a0,0x2
ffffffffc0200c40:	91c50513          	addi	a0,a0,-1764 # ffffffffc0202558 <commands+0x650>
ffffffffc0200c44:	f70ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c48:	00002697          	auipc	a3,0x2
ffffffffc0200c4c:	9e868693          	addi	a3,a3,-1560 # ffffffffc0202630 <commands+0x728>
ffffffffc0200c50:	00002617          	auipc	a2,0x2
ffffffffc0200c54:	8f060613          	addi	a2,a2,-1808 # ffffffffc0202540 <commands+0x638>
ffffffffc0200c58:	0dd00593          	li	a1,221
ffffffffc0200c5c:	00002517          	auipc	a0,0x2
ffffffffc0200c60:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0202558 <commands+0x650>
ffffffffc0200c64:	f50ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c68:	00002697          	auipc	a3,0x2
ffffffffc0200c6c:	a0868693          	addi	a3,a3,-1528 # ffffffffc0202670 <commands+0x768>
ffffffffc0200c70:	00002617          	auipc	a2,0x2
ffffffffc0200c74:	8d060613          	addi	a2,a2,-1840 # ffffffffc0202540 <commands+0x638>
ffffffffc0200c78:	0df00593          	li	a1,223
ffffffffc0200c7c:	00002517          	auipc	a0,0x2
ffffffffc0200c80:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0202558 <commands+0x650>
ffffffffc0200c84:	f30ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c88:	00002697          	auipc	a3,0x2
ffffffffc0200c8c:	a7068693          	addi	a3,a3,-1424 # ffffffffc02026f8 <commands+0x7f0>
ffffffffc0200c90:	00002617          	auipc	a2,0x2
ffffffffc0200c94:	8b060613          	addi	a2,a2,-1872 # ffffffffc0202540 <commands+0x638>
ffffffffc0200c98:	0f800593          	li	a1,248
ffffffffc0200c9c:	00002517          	auipc	a0,0x2
ffffffffc0200ca0:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0202558 <commands+0x650>
ffffffffc0200ca4:	f10ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ca8:	00002697          	auipc	a3,0x2
ffffffffc0200cac:	94068693          	addi	a3,a3,-1728 # ffffffffc02025e8 <commands+0x6e0>
ffffffffc0200cb0:	00002617          	auipc	a2,0x2
ffffffffc0200cb4:	89060613          	addi	a2,a2,-1904 # ffffffffc0202540 <commands+0x638>
ffffffffc0200cb8:	0da00593          	li	a1,218
ffffffffc0200cbc:	00002517          	auipc	a0,0x2
ffffffffc0200cc0:	89c50513          	addi	a0,a0,-1892 # ffffffffc0202558 <commands+0x650>
ffffffffc0200cc4:	ef0ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(total == 0);
ffffffffc0200cc8:	00002697          	auipc	a3,0x2
ffffffffc0200ccc:	b6068693          	addi	a3,a3,-1184 # ffffffffc0202828 <commands+0x920>
ffffffffc0200cd0:	00002617          	auipc	a2,0x2
ffffffffc0200cd4:	87060613          	addi	a2,a2,-1936 # ffffffffc0202540 <commands+0x638>
ffffffffc0200cd8:	15200593          	li	a1,338
ffffffffc0200cdc:	00002517          	auipc	a0,0x2
ffffffffc0200ce0:	87c50513          	addi	a0,a0,-1924 # ffffffffc0202558 <commands+0x650>
ffffffffc0200ce4:	ed0ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(total == nr_free_pages());
ffffffffc0200ce8:	00002697          	auipc	a3,0x2
ffffffffc0200cec:	8a068693          	addi	a3,a3,-1888 # ffffffffc0202588 <commands+0x680>
ffffffffc0200cf0:	00002617          	auipc	a2,0x2
ffffffffc0200cf4:	85060613          	addi	a2,a2,-1968 # ffffffffc0202540 <commands+0x638>
ffffffffc0200cf8:	11300593          	li	a1,275
ffffffffc0200cfc:	00002517          	auipc	a0,0x2
ffffffffc0200d00:	85c50513          	addi	a0,a0,-1956 # ffffffffc0202558 <commands+0x650>
ffffffffc0200d04:	eb0ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d08:	00002697          	auipc	a3,0x2
ffffffffc0200d0c:	8c068693          	addi	a3,a3,-1856 # ffffffffc02025c8 <commands+0x6c0>
ffffffffc0200d10:	00002617          	auipc	a2,0x2
ffffffffc0200d14:	83060613          	addi	a2,a2,-2000 # ffffffffc0202540 <commands+0x638>
ffffffffc0200d18:	0d900593          	li	a1,217
ffffffffc0200d1c:	00002517          	auipc	a0,0x2
ffffffffc0200d20:	83c50513          	addi	a0,a0,-1988 # ffffffffc0202558 <commands+0x650>
ffffffffc0200d24:	e90ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d28:	00002697          	auipc	a3,0x2
ffffffffc0200d2c:	88068693          	addi	a3,a3,-1920 # ffffffffc02025a8 <commands+0x6a0>
ffffffffc0200d30:	00002617          	auipc	a2,0x2
ffffffffc0200d34:	81060613          	addi	a2,a2,-2032 # ffffffffc0202540 <commands+0x638>
ffffffffc0200d38:	0d800593          	li	a1,216
ffffffffc0200d3c:	00002517          	auipc	a0,0x2
ffffffffc0200d40:	81c50513          	addi	a0,a0,-2020 # ffffffffc0202558 <commands+0x650>
ffffffffc0200d44:	e70ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d48:	00002697          	auipc	a3,0x2
ffffffffc0200d4c:	98868693          	addi	a3,a3,-1656 # ffffffffc02026d0 <commands+0x7c8>
ffffffffc0200d50:	00001617          	auipc	a2,0x1
ffffffffc0200d54:	7f060613          	addi	a2,a2,2032 # ffffffffc0202540 <commands+0x638>
ffffffffc0200d58:	0f500593          	li	a1,245
ffffffffc0200d5c:	00001517          	auipc	a0,0x1
ffffffffc0200d60:	7fc50513          	addi	a0,a0,2044 # ffffffffc0202558 <commands+0x650>
ffffffffc0200d64:	e50ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d68:	00002697          	auipc	a3,0x2
ffffffffc0200d6c:	88068693          	addi	a3,a3,-1920 # ffffffffc02025e8 <commands+0x6e0>
ffffffffc0200d70:	00001617          	auipc	a2,0x1
ffffffffc0200d74:	7d060613          	addi	a2,a2,2000 # ffffffffc0202540 <commands+0x638>
ffffffffc0200d78:	0f300593          	li	a1,243
ffffffffc0200d7c:	00001517          	auipc	a0,0x1
ffffffffc0200d80:	7dc50513          	addi	a0,a0,2012 # ffffffffc0202558 <commands+0x650>
ffffffffc0200d84:	e30ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d88:	00002697          	auipc	a3,0x2
ffffffffc0200d8c:	84068693          	addi	a3,a3,-1984 # ffffffffc02025c8 <commands+0x6c0>
ffffffffc0200d90:	00001617          	auipc	a2,0x1
ffffffffc0200d94:	7b060613          	addi	a2,a2,1968 # ffffffffc0202540 <commands+0x638>
ffffffffc0200d98:	0f200593          	li	a1,242
ffffffffc0200d9c:	00001517          	auipc	a0,0x1
ffffffffc0200da0:	7bc50513          	addi	a0,a0,1980 # ffffffffc0202558 <commands+0x650>
ffffffffc0200da4:	e10ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200da8:	00002697          	auipc	a3,0x2
ffffffffc0200dac:	80068693          	addi	a3,a3,-2048 # ffffffffc02025a8 <commands+0x6a0>
ffffffffc0200db0:	00001617          	auipc	a2,0x1
ffffffffc0200db4:	79060613          	addi	a2,a2,1936 # ffffffffc0202540 <commands+0x638>
ffffffffc0200db8:	0f100593          	li	a1,241
ffffffffc0200dbc:	00001517          	auipc	a0,0x1
ffffffffc0200dc0:	79c50513          	addi	a0,a0,1948 # ffffffffc0202558 <commands+0x650>
ffffffffc0200dc4:	df0ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(nr_free == 3);
ffffffffc0200dc8:	00002697          	auipc	a3,0x2
ffffffffc0200dcc:	92068693          	addi	a3,a3,-1760 # ffffffffc02026e8 <commands+0x7e0>
ffffffffc0200dd0:	00001617          	auipc	a2,0x1
ffffffffc0200dd4:	77060613          	addi	a2,a2,1904 # ffffffffc0202540 <commands+0x638>
ffffffffc0200dd8:	0ef00593          	li	a1,239
ffffffffc0200ddc:	00001517          	auipc	a0,0x1
ffffffffc0200de0:	77c50513          	addi	a0,a0,1916 # ffffffffc0202558 <commands+0x650>
ffffffffc0200de4:	dd0ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200de8:	00002697          	auipc	a3,0x2
ffffffffc0200dec:	8e868693          	addi	a3,a3,-1816 # ffffffffc02026d0 <commands+0x7c8>
ffffffffc0200df0:	00001617          	auipc	a2,0x1
ffffffffc0200df4:	75060613          	addi	a2,a2,1872 # ffffffffc0202540 <commands+0x638>
ffffffffc0200df8:	0ea00593          	li	a1,234
ffffffffc0200dfc:	00001517          	auipc	a0,0x1
ffffffffc0200e00:	75c50513          	addi	a0,a0,1884 # ffffffffc0202558 <commands+0x650>
ffffffffc0200e04:	db0ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200e08:	00002697          	auipc	a3,0x2
ffffffffc0200e0c:	8a868693          	addi	a3,a3,-1880 # ffffffffc02026b0 <commands+0x7a8>
ffffffffc0200e10:	00001617          	auipc	a2,0x1
ffffffffc0200e14:	73060613          	addi	a2,a2,1840 # ffffffffc0202540 <commands+0x638>
ffffffffc0200e18:	0e100593          	li	a1,225
ffffffffc0200e1c:	00001517          	auipc	a0,0x1
ffffffffc0200e20:	73c50513          	addi	a0,a0,1852 # ffffffffc0202558 <commands+0x650>
ffffffffc0200e24:	d90ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e28:	00002697          	auipc	a3,0x2
ffffffffc0200e2c:	86868693          	addi	a3,a3,-1944 # ffffffffc0202690 <commands+0x788>
ffffffffc0200e30:	00001617          	auipc	a2,0x1
ffffffffc0200e34:	71060613          	addi	a2,a2,1808 # ffffffffc0202540 <commands+0x638>
ffffffffc0200e38:	0e000593          	li	a1,224
ffffffffc0200e3c:	00001517          	auipc	a0,0x1
ffffffffc0200e40:	71c50513          	addi	a0,a0,1820 # ffffffffc0202558 <commands+0x650>
ffffffffc0200e44:	d70ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(count == 0);
ffffffffc0200e48:	00002697          	auipc	a3,0x2
ffffffffc0200e4c:	9d068693          	addi	a3,a3,-1584 # ffffffffc0202818 <commands+0x910>
ffffffffc0200e50:	00001617          	auipc	a2,0x1
ffffffffc0200e54:	6f060613          	addi	a2,a2,1776 # ffffffffc0202540 <commands+0x638>
ffffffffc0200e58:	15100593          	li	a1,337
ffffffffc0200e5c:	00001517          	auipc	a0,0x1
ffffffffc0200e60:	6fc50513          	addi	a0,a0,1788 # ffffffffc0202558 <commands+0x650>
ffffffffc0200e64:	d50ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(nr_free == 0);
ffffffffc0200e68:	00002697          	auipc	a3,0x2
ffffffffc0200e6c:	8c868693          	addi	a3,a3,-1848 # ffffffffc0202730 <commands+0x828>
ffffffffc0200e70:	00001617          	auipc	a2,0x1
ffffffffc0200e74:	6d060613          	addi	a2,a2,1744 # ffffffffc0202540 <commands+0x638>
ffffffffc0200e78:	14600593          	li	a1,326
ffffffffc0200e7c:	00001517          	auipc	a0,0x1
ffffffffc0200e80:	6dc50513          	addi	a0,a0,1756 # ffffffffc0202558 <commands+0x650>
ffffffffc0200e84:	d30ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e88:	00002697          	auipc	a3,0x2
ffffffffc0200e8c:	84868693          	addi	a3,a3,-1976 # ffffffffc02026d0 <commands+0x7c8>
ffffffffc0200e90:	00001617          	auipc	a2,0x1
ffffffffc0200e94:	6b060613          	addi	a2,a2,1712 # ffffffffc0202540 <commands+0x638>
ffffffffc0200e98:	14000593          	li	a1,320
ffffffffc0200e9c:	00001517          	auipc	a0,0x1
ffffffffc0200ea0:	6bc50513          	addi	a0,a0,1724 # ffffffffc0202558 <commands+0x650>
ffffffffc0200ea4:	d10ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200ea8:	00002697          	auipc	a3,0x2
ffffffffc0200eac:	95068693          	addi	a3,a3,-1712 # ffffffffc02027f8 <commands+0x8f0>
ffffffffc0200eb0:	00001617          	auipc	a2,0x1
ffffffffc0200eb4:	69060613          	addi	a2,a2,1680 # ffffffffc0202540 <commands+0x638>
ffffffffc0200eb8:	13f00593          	li	a1,319
ffffffffc0200ebc:	00001517          	auipc	a0,0x1
ffffffffc0200ec0:	69c50513          	addi	a0,a0,1692 # ffffffffc0202558 <commands+0x650>
ffffffffc0200ec4:	cf0ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200ec8:	00002697          	auipc	a3,0x2
ffffffffc0200ecc:	92068693          	addi	a3,a3,-1760 # ffffffffc02027e8 <commands+0x8e0>
ffffffffc0200ed0:	00001617          	auipc	a2,0x1
ffffffffc0200ed4:	67060613          	addi	a2,a2,1648 # ffffffffc0202540 <commands+0x638>
ffffffffc0200ed8:	13700593          	li	a1,311
ffffffffc0200edc:	00001517          	auipc	a0,0x1
ffffffffc0200ee0:	67c50513          	addi	a0,a0,1660 # ffffffffc0202558 <commands+0x650>
ffffffffc0200ee4:	cd0ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200ee8:	00002697          	auipc	a3,0x2
ffffffffc0200eec:	8e868693          	addi	a3,a3,-1816 # ffffffffc02027d0 <commands+0x8c8>
ffffffffc0200ef0:	00001617          	auipc	a2,0x1
ffffffffc0200ef4:	65060613          	addi	a2,a2,1616 # ffffffffc0202540 <commands+0x638>
ffffffffc0200ef8:	13600593          	li	a1,310
ffffffffc0200efc:	00001517          	auipc	a0,0x1
ffffffffc0200f00:	65c50513          	addi	a0,a0,1628 # ffffffffc0202558 <commands+0x650>
ffffffffc0200f04:	cb0ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200f08:	00002697          	auipc	a3,0x2
ffffffffc0200f0c:	8a868693          	addi	a3,a3,-1880 # ffffffffc02027b0 <commands+0x8a8>
ffffffffc0200f10:	00001617          	auipc	a2,0x1
ffffffffc0200f14:	63060613          	addi	a2,a2,1584 # ffffffffc0202540 <commands+0x638>
ffffffffc0200f18:	13500593          	li	a1,309
ffffffffc0200f1c:	00001517          	auipc	a0,0x1
ffffffffc0200f20:	63c50513          	addi	a0,a0,1596 # ffffffffc0202558 <commands+0x650>
ffffffffc0200f24:	c90ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200f28:	00002697          	auipc	a3,0x2
ffffffffc0200f2c:	85868693          	addi	a3,a3,-1960 # ffffffffc0202780 <commands+0x878>
ffffffffc0200f30:	00001617          	auipc	a2,0x1
ffffffffc0200f34:	61060613          	addi	a2,a2,1552 # ffffffffc0202540 <commands+0x638>
ffffffffc0200f38:	13300593          	li	a1,307
ffffffffc0200f3c:	00001517          	auipc	a0,0x1
ffffffffc0200f40:	61c50513          	addi	a0,a0,1564 # ffffffffc0202558 <commands+0x650>
ffffffffc0200f44:	c70ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200f48:	00002697          	auipc	a3,0x2
ffffffffc0200f4c:	82068693          	addi	a3,a3,-2016 # ffffffffc0202768 <commands+0x860>
ffffffffc0200f50:	00001617          	auipc	a2,0x1
ffffffffc0200f54:	5f060613          	addi	a2,a2,1520 # ffffffffc0202540 <commands+0x638>
ffffffffc0200f58:	13200593          	li	a1,306
ffffffffc0200f5c:	00001517          	auipc	a0,0x1
ffffffffc0200f60:	5fc50513          	addi	a0,a0,1532 # ffffffffc0202558 <commands+0x650>
ffffffffc0200f64:	c50ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f68:	00001697          	auipc	a3,0x1
ffffffffc0200f6c:	76868693          	addi	a3,a3,1896 # ffffffffc02026d0 <commands+0x7c8>
ffffffffc0200f70:	00001617          	auipc	a2,0x1
ffffffffc0200f74:	5d060613          	addi	a2,a2,1488 # ffffffffc0202540 <commands+0x638>
ffffffffc0200f78:	12600593          	li	a1,294
ffffffffc0200f7c:	00001517          	auipc	a0,0x1
ffffffffc0200f80:	5dc50513          	addi	a0,a0,1500 # ffffffffc0202558 <commands+0x650>
ffffffffc0200f84:	c30ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f88:	00001697          	auipc	a3,0x1
ffffffffc0200f8c:	7c868693          	addi	a3,a3,1992 # ffffffffc0202750 <commands+0x848>
ffffffffc0200f90:	00001617          	auipc	a2,0x1
ffffffffc0200f94:	5b060613          	addi	a2,a2,1456 # ffffffffc0202540 <commands+0x638>
ffffffffc0200f98:	11d00593          	li	a1,285
ffffffffc0200f9c:	00001517          	auipc	a0,0x1
ffffffffc0200fa0:	5bc50513          	addi	a0,a0,1468 # ffffffffc0202558 <commands+0x650>
ffffffffc0200fa4:	c10ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(p0 != NULL);
ffffffffc0200fa8:	00001697          	auipc	a3,0x1
ffffffffc0200fac:	79868693          	addi	a3,a3,1944 # ffffffffc0202740 <commands+0x838>
ffffffffc0200fb0:	00001617          	auipc	a2,0x1
ffffffffc0200fb4:	59060613          	addi	a2,a2,1424 # ffffffffc0202540 <commands+0x638>
ffffffffc0200fb8:	11c00593          	li	a1,284
ffffffffc0200fbc:	00001517          	auipc	a0,0x1
ffffffffc0200fc0:	59c50513          	addi	a0,a0,1436 # ffffffffc0202558 <commands+0x650>
ffffffffc0200fc4:	bf0ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(nr_free == 0);
ffffffffc0200fc8:	00001697          	auipc	a3,0x1
ffffffffc0200fcc:	76868693          	addi	a3,a3,1896 # ffffffffc0202730 <commands+0x828>
ffffffffc0200fd0:	00001617          	auipc	a2,0x1
ffffffffc0200fd4:	57060613          	addi	a2,a2,1392 # ffffffffc0202540 <commands+0x638>
ffffffffc0200fd8:	0fe00593          	li	a1,254
ffffffffc0200fdc:	00001517          	auipc	a0,0x1
ffffffffc0200fe0:	57c50513          	addi	a0,a0,1404 # ffffffffc0202558 <commands+0x650>
ffffffffc0200fe4:	bd0ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fe8:	00001697          	auipc	a3,0x1
ffffffffc0200fec:	6e868693          	addi	a3,a3,1768 # ffffffffc02026d0 <commands+0x7c8>
ffffffffc0200ff0:	00001617          	auipc	a2,0x1
ffffffffc0200ff4:	55060613          	addi	a2,a2,1360 # ffffffffc0202540 <commands+0x638>
ffffffffc0200ff8:	0fc00593          	li	a1,252
ffffffffc0200ffc:	00001517          	auipc	a0,0x1
ffffffffc0201000:	55c50513          	addi	a0,a0,1372 # ffffffffc0202558 <commands+0x650>
ffffffffc0201004:	bb0ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201008:	00001697          	auipc	a3,0x1
ffffffffc020100c:	70868693          	addi	a3,a3,1800 # ffffffffc0202710 <commands+0x808>
ffffffffc0201010:	00001617          	auipc	a2,0x1
ffffffffc0201014:	53060613          	addi	a2,a2,1328 # ffffffffc0202540 <commands+0x638>
ffffffffc0201018:	0fb00593          	li	a1,251
ffffffffc020101c:	00001517          	auipc	a0,0x1
ffffffffc0201020:	53c50513          	addi	a0,a0,1340 # ffffffffc0202558 <commands+0x650>
ffffffffc0201024:	b90ff0ef          	jal	ra,ffffffffc02003b4 <__panic>

ffffffffc0201028 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0201028:	1141                	addi	sp,sp,-16
ffffffffc020102a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020102c:	18058063          	beqz	a1,ffffffffc02011ac <best_fit_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc0201030:	00259693          	slli	a3,a1,0x2
ffffffffc0201034:	96ae                	add	a3,a3,a1
ffffffffc0201036:	068e                	slli	a3,a3,0x3
ffffffffc0201038:	96aa                	add	a3,a3,a0
ffffffffc020103a:	02d50d63          	beq	a0,a3,ffffffffc0201074 <best_fit_free_pages+0x4c>
ffffffffc020103e:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201040:	8b85                	andi	a5,a5,1
ffffffffc0201042:	14079563          	bnez	a5,ffffffffc020118c <best_fit_free_pages+0x164>
ffffffffc0201046:	651c                	ld	a5,8(a0)
ffffffffc0201048:	8385                	srli	a5,a5,0x1
ffffffffc020104a:	8b85                	andi	a5,a5,1
ffffffffc020104c:	14079063          	bnez	a5,ffffffffc020118c <best_fit_free_pages+0x164>
ffffffffc0201050:	87aa                	mv	a5,a0
ffffffffc0201052:	a809                	j	ffffffffc0201064 <best_fit_free_pages+0x3c>
ffffffffc0201054:	6798                	ld	a4,8(a5)
ffffffffc0201056:	8b05                	andi	a4,a4,1
ffffffffc0201058:	12071a63          	bnez	a4,ffffffffc020118c <best_fit_free_pages+0x164>
ffffffffc020105c:	6798                	ld	a4,8(a5)
ffffffffc020105e:	8b09                	andi	a4,a4,2
ffffffffc0201060:	12071663          	bnez	a4,ffffffffc020118c <best_fit_free_pages+0x164>
        p->flags = 0;
ffffffffc0201064:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201068:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020106c:	02878793          	addi	a5,a5,40
ffffffffc0201070:	fed792e3          	bne	a5,a3,ffffffffc0201054 <best_fit_free_pages+0x2c>
    base->property = n;
ffffffffc0201074:	2581                	sext.w	a1,a1
ffffffffc0201076:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201078:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020107c:	4789                	li	a5,2
ffffffffc020107e:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201082:	00005697          	auipc	a3,0x5
ffffffffc0201086:	3d668693          	addi	a3,a3,982 # ffffffffc0206458 <free_area>
ffffffffc020108a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020108c:	669c                	ld	a5,8(a3)
ffffffffc020108e:	9db9                	addw	a1,a1,a4
ffffffffc0201090:	00005717          	auipc	a4,0x5
ffffffffc0201094:	3cb72c23          	sw	a1,984(a4) # ffffffffc0206468 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201098:	08d78f63          	beq	a5,a3,ffffffffc0201136 <best_fit_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc020109c:	fe878713          	addi	a4,a5,-24
ffffffffc02010a0:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02010a2:	4801                	li	a6,0
ffffffffc02010a4:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02010a8:	00e56a63          	bltu	a0,a4,ffffffffc02010bc <best_fit_free_pages+0x94>
    return listelm->next;
ffffffffc02010ac:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02010ae:	02d70563          	beq	a4,a3,ffffffffc02010d8 <best_fit_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010b2:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02010b4:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02010b8:	fee57ae3          	bleu	a4,a0,ffffffffc02010ac <best_fit_free_pages+0x84>
ffffffffc02010bc:	00080663          	beqz	a6,ffffffffc02010c8 <best_fit_free_pages+0xa0>
ffffffffc02010c0:	00005817          	auipc	a6,0x5
ffffffffc02010c4:	38b83c23          	sd	a1,920(a6) # ffffffffc0206458 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02010c8:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc02010ca:	e390                	sd	a2,0(a5)
ffffffffc02010cc:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02010ce:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010d0:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02010d2:	02d59163          	bne	a1,a3,ffffffffc02010f4 <best_fit_free_pages+0xcc>
ffffffffc02010d6:	a091                	j	ffffffffc020111a <best_fit_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02010d8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02010da:	f114                	sd	a3,32(a0)
ffffffffc02010dc:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02010de:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02010e0:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010e2:	00d70563          	beq	a4,a3,ffffffffc02010ec <best_fit_free_pages+0xc4>
ffffffffc02010e6:	4805                	li	a6,1
ffffffffc02010e8:	87ba                	mv	a5,a4
ffffffffc02010ea:	b7e9                	j	ffffffffc02010b4 <best_fit_free_pages+0x8c>
ffffffffc02010ec:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02010ee:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02010f0:	02d78163          	beq	a5,a3,ffffffffc0201112 <best_fit_free_pages+0xea>
        if (p + p->property == base)
ffffffffc02010f4:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc02010f8:	fe858613          	addi	a2,a1,-24
        if (p + p->property == base)
ffffffffc02010fc:	02081713          	slli	a4,a6,0x20
ffffffffc0201100:	9301                	srli	a4,a4,0x20
ffffffffc0201102:	00271793          	slli	a5,a4,0x2
ffffffffc0201106:	97ba                	add	a5,a5,a4
ffffffffc0201108:	078e                	slli	a5,a5,0x3
ffffffffc020110a:	97b2                	add	a5,a5,a2
ffffffffc020110c:	02f50e63          	beq	a0,a5,ffffffffc0201148 <best_fit_free_pages+0x120>
ffffffffc0201110:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201112:	fe878713          	addi	a4,a5,-24
ffffffffc0201116:	00d78d63          	beq	a5,a3,ffffffffc0201130 <best_fit_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc020111a:	490c                	lw	a1,16(a0)
ffffffffc020111c:	02059613          	slli	a2,a1,0x20
ffffffffc0201120:	9201                	srli	a2,a2,0x20
ffffffffc0201122:	00261693          	slli	a3,a2,0x2
ffffffffc0201126:	96b2                	add	a3,a3,a2
ffffffffc0201128:	068e                	slli	a3,a3,0x3
ffffffffc020112a:	96aa                	add	a3,a3,a0
ffffffffc020112c:	04d70063          	beq	a4,a3,ffffffffc020116c <best_fit_free_pages+0x144>
}
ffffffffc0201130:	60a2                	ld	ra,8(sp)
ffffffffc0201132:	0141                	addi	sp,sp,16
ffffffffc0201134:	8082                	ret
ffffffffc0201136:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201138:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020113c:	e398                	sd	a4,0(a5)
ffffffffc020113e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201140:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201142:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201144:	0141                	addi	sp,sp,16
ffffffffc0201146:	8082                	ret
            p->property += base->property;
ffffffffc0201148:	491c                	lw	a5,16(a0)
ffffffffc020114a:	0107883b          	addw	a6,a5,a6
ffffffffc020114e:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201152:	57f5                	li	a5,-3
ffffffffc0201154:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201158:	01853803          	ld	a6,24(a0)
ffffffffc020115c:	7118                	ld	a4,32(a0)
            base = p;
ffffffffc020115e:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0201160:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201164:	659c                	ld	a5,8(a1)
ffffffffc0201166:	01073023          	sd	a6,0(a4)
ffffffffc020116a:	b765                	j	ffffffffc0201112 <best_fit_free_pages+0xea>
            base->property += p->property;
ffffffffc020116c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201170:	ff078693          	addi	a3,a5,-16
ffffffffc0201174:	9db9                	addw	a1,a1,a4
ffffffffc0201176:	c90c                	sw	a1,16(a0)
ffffffffc0201178:	5775                	li	a4,-3
ffffffffc020117a:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020117e:	6398                	ld	a4,0(a5)
ffffffffc0201180:	679c                	ld	a5,8(a5)
}
ffffffffc0201182:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201184:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201186:	e398                	sd	a4,0(a5)
ffffffffc0201188:	0141                	addi	sp,sp,16
ffffffffc020118a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020118c:	00001697          	auipc	a3,0x1
ffffffffc0201190:	6ac68693          	addi	a3,a3,1708 # ffffffffc0202838 <commands+0x930>
ffffffffc0201194:	00001617          	auipc	a2,0x1
ffffffffc0201198:	3ac60613          	addi	a2,a2,940 # ffffffffc0202540 <commands+0x638>
ffffffffc020119c:	09700593          	li	a1,151
ffffffffc02011a0:	00001517          	auipc	a0,0x1
ffffffffc02011a4:	3b850513          	addi	a0,a0,952 # ffffffffc0202558 <commands+0x650>
ffffffffc02011a8:	a0cff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(n > 0);
ffffffffc02011ac:	00001697          	auipc	a3,0x1
ffffffffc02011b0:	38c68693          	addi	a3,a3,908 # ffffffffc0202538 <commands+0x630>
ffffffffc02011b4:	00001617          	auipc	a2,0x1
ffffffffc02011b8:	38c60613          	addi	a2,a2,908 # ffffffffc0202540 <commands+0x638>
ffffffffc02011bc:	09400593          	li	a1,148
ffffffffc02011c0:	00001517          	auipc	a0,0x1
ffffffffc02011c4:	39850513          	addi	a0,a0,920 # ffffffffc0202558 <commands+0x650>
ffffffffc02011c8:	9ecff0ef          	jal	ra,ffffffffc02003b4 <__panic>

ffffffffc02011cc <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc02011cc:	1141                	addi	sp,sp,-16
ffffffffc02011ce:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011d0:	c1fd                	beqz	a1,ffffffffc02012b6 <best_fit_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc02011d2:	00259693          	slli	a3,a1,0x2
ffffffffc02011d6:	96ae                	add	a3,a3,a1
ffffffffc02011d8:	068e                	slli	a3,a3,0x3
ffffffffc02011da:	96aa                	add	a3,a3,a0
ffffffffc02011dc:	02d50463          	beq	a0,a3,ffffffffc0201204 <best_fit_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02011e0:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02011e2:	87aa                	mv	a5,a0
ffffffffc02011e4:	8b05                	andi	a4,a4,1
ffffffffc02011e6:	e709                	bnez	a4,ffffffffc02011f0 <best_fit_init_memmap+0x24>
ffffffffc02011e8:	a07d                	j	ffffffffc0201296 <best_fit_init_memmap+0xca>
ffffffffc02011ea:	6798                	ld	a4,8(a5)
ffffffffc02011ec:	8b05                	andi	a4,a4,1
ffffffffc02011ee:	c745                	beqz	a4,ffffffffc0201296 <best_fit_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc02011f0:	0007a823          	sw	zero,16(a5)
ffffffffc02011f4:	0007b423          	sd	zero,8(a5)
ffffffffc02011f8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02011fc:	02878793          	addi	a5,a5,40
ffffffffc0201200:	fed795e3          	bne	a5,a3,ffffffffc02011ea <best_fit_init_memmap+0x1e>
    base->property = n;
ffffffffc0201204:	2581                	sext.w	a1,a1
ffffffffc0201206:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201208:	4789                	li	a5,2
ffffffffc020120a:	00850713          	addi	a4,a0,8
ffffffffc020120e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201212:	00005697          	auipc	a3,0x5
ffffffffc0201216:	24668693          	addi	a3,a3,582 # ffffffffc0206458 <free_area>
ffffffffc020121a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020121c:	669c                	ld	a5,8(a3)
ffffffffc020121e:	9db9                	addw	a1,a1,a4
ffffffffc0201220:	00005717          	auipc	a4,0x5
ffffffffc0201224:	24b72423          	sw	a1,584(a4) # ffffffffc0206468 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201228:	04d78a63          	beq	a5,a3,ffffffffc020127c <best_fit_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc020122c:	fe878713          	addi	a4,a5,-24
ffffffffc0201230:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201232:	4801                	li	a6,0
ffffffffc0201234:	01850613          	addi	a2,a0,24
            if(base < page) 
ffffffffc0201238:	00e56a63          	bltu	a0,a4,ffffffffc020124c <best_fit_init_memmap+0x80>
    return listelm->next;
ffffffffc020123c:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc020123e:	02d70563          	beq	a4,a3,ffffffffc0201268 <best_fit_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201242:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201244:	fe878713          	addi	a4,a5,-24
            if(base < page) 
ffffffffc0201248:	fee57ae3          	bleu	a4,a0,ffffffffc020123c <best_fit_init_memmap+0x70>
ffffffffc020124c:	00080663          	beqz	a6,ffffffffc0201258 <best_fit_init_memmap+0x8c>
ffffffffc0201250:	00005717          	auipc	a4,0x5
ffffffffc0201254:	20b73423          	sd	a1,520(a4) # ffffffffc0206458 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201258:	6398                	ld	a4,0(a5)
}
ffffffffc020125a:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020125c:	e390                	sd	a2,0(a5)
ffffffffc020125e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201260:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201262:	ed18                	sd	a4,24(a0)
ffffffffc0201264:	0141                	addi	sp,sp,16
ffffffffc0201266:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201268:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020126a:	f114                	sd	a3,32(a0)
ffffffffc020126c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020126e:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201270:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201272:	00d70e63          	beq	a4,a3,ffffffffc020128e <best_fit_init_memmap+0xc2>
ffffffffc0201276:	4805                	li	a6,1
ffffffffc0201278:	87ba                	mv	a5,a4
ffffffffc020127a:	b7e9                	j	ffffffffc0201244 <best_fit_init_memmap+0x78>
}
ffffffffc020127c:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020127e:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201282:	e398                	sd	a4,0(a5)
ffffffffc0201284:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201286:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201288:	ed1c                	sd	a5,24(a0)
}
ffffffffc020128a:	0141                	addi	sp,sp,16
ffffffffc020128c:	8082                	ret
ffffffffc020128e:	60a2                	ld	ra,8(sp)
ffffffffc0201290:	e290                	sd	a2,0(a3)
ffffffffc0201292:	0141                	addi	sp,sp,16
ffffffffc0201294:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201296:	00001697          	auipc	a3,0x1
ffffffffc020129a:	5ca68693          	addi	a3,a3,1482 # ffffffffc0202860 <commands+0x958>
ffffffffc020129e:	00001617          	auipc	a2,0x1
ffffffffc02012a2:	2a260613          	addi	a2,a2,674 # ffffffffc0202540 <commands+0x638>
ffffffffc02012a6:	04c00593          	li	a1,76
ffffffffc02012aa:	00001517          	auipc	a0,0x1
ffffffffc02012ae:	2ae50513          	addi	a0,a0,686 # ffffffffc0202558 <commands+0x650>
ffffffffc02012b2:	902ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(n > 0);
ffffffffc02012b6:	00001697          	auipc	a3,0x1
ffffffffc02012ba:	28268693          	addi	a3,a3,642 # ffffffffc0202538 <commands+0x630>
ffffffffc02012be:	00001617          	auipc	a2,0x1
ffffffffc02012c2:	28260613          	addi	a2,a2,642 # ffffffffc0202540 <commands+0x638>
ffffffffc02012c6:	04800593          	li	a1,72
ffffffffc02012ca:	00001517          	auipc	a0,0x1
ffffffffc02012ce:	28e50513          	addi	a0,a0,654 # ffffffffc0202558 <commands+0x650>
ffffffffc02012d2:	8e2ff0ef          	jal	ra,ffffffffc02003b4 <__panic>

ffffffffc02012d6 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012d6:	100027f3          	csrr	a5,sstatus
ffffffffc02012da:	8b89                	andi	a5,a5,2
ffffffffc02012dc:	eb89                	bnez	a5,ffffffffc02012ee <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02012de:	00005797          	auipc	a5,0x5
ffffffffc02012e2:	28a78793          	addi	a5,a5,650 # ffffffffc0206568 <pmm_manager>
ffffffffc02012e6:	639c                	ld	a5,0(a5)
ffffffffc02012e8:	0187b303          	ld	t1,24(a5)
ffffffffc02012ec:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc02012ee:	1141                	addi	sp,sp,-16
ffffffffc02012f0:	e406                	sd	ra,8(sp)
ffffffffc02012f2:	e022                	sd	s0,0(sp)
ffffffffc02012f4:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02012f6:	976ff0ef          	jal	ra,ffffffffc020046c <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02012fa:	00005797          	auipc	a5,0x5
ffffffffc02012fe:	26e78793          	addi	a5,a5,622 # ffffffffc0206568 <pmm_manager>
ffffffffc0201302:	639c                	ld	a5,0(a5)
ffffffffc0201304:	8522                	mv	a0,s0
ffffffffc0201306:	6f9c                	ld	a5,24(a5)
ffffffffc0201308:	9782                	jalr	a5
ffffffffc020130a:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020130c:	95aff0ef          	jal	ra,ffffffffc0200466 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201310:	8522                	mv	a0,s0
ffffffffc0201312:	60a2                	ld	ra,8(sp)
ffffffffc0201314:	6402                	ld	s0,0(sp)
ffffffffc0201316:	0141                	addi	sp,sp,16
ffffffffc0201318:	8082                	ret

ffffffffc020131a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020131a:	100027f3          	csrr	a5,sstatus
ffffffffc020131e:	8b89                	andi	a5,a5,2
ffffffffc0201320:	eb89                	bnez	a5,ffffffffc0201332 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201322:	00005797          	auipc	a5,0x5
ffffffffc0201326:	24678793          	addi	a5,a5,582 # ffffffffc0206568 <pmm_manager>
ffffffffc020132a:	639c                	ld	a5,0(a5)
ffffffffc020132c:	0207b303          	ld	t1,32(a5)
ffffffffc0201330:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201332:	1101                	addi	sp,sp,-32
ffffffffc0201334:	ec06                	sd	ra,24(sp)
ffffffffc0201336:	e822                	sd	s0,16(sp)
ffffffffc0201338:	e426                	sd	s1,8(sp)
ffffffffc020133a:	842a                	mv	s0,a0
ffffffffc020133c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020133e:	92eff0ef          	jal	ra,ffffffffc020046c <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201342:	00005797          	auipc	a5,0x5
ffffffffc0201346:	22678793          	addi	a5,a5,550 # ffffffffc0206568 <pmm_manager>
ffffffffc020134a:	639c                	ld	a5,0(a5)
ffffffffc020134c:	85a6                	mv	a1,s1
ffffffffc020134e:	8522                	mv	a0,s0
ffffffffc0201350:	739c                	ld	a5,32(a5)
ffffffffc0201352:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201354:	6442                	ld	s0,16(sp)
ffffffffc0201356:	60e2                	ld	ra,24(sp)
ffffffffc0201358:	64a2                	ld	s1,8(sp)
ffffffffc020135a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020135c:	90aff06f          	j	ffffffffc0200466 <intr_enable>

ffffffffc0201360 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201360:	100027f3          	csrr	a5,sstatus
ffffffffc0201364:	8b89                	andi	a5,a5,2
ffffffffc0201366:	eb89                	bnez	a5,ffffffffc0201378 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201368:	00005797          	auipc	a5,0x5
ffffffffc020136c:	20078793          	addi	a5,a5,512 # ffffffffc0206568 <pmm_manager>
ffffffffc0201370:	639c                	ld	a5,0(a5)
ffffffffc0201372:	0287b303          	ld	t1,40(a5)
ffffffffc0201376:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201378:	1141                	addi	sp,sp,-16
ffffffffc020137a:	e406                	sd	ra,8(sp)
ffffffffc020137c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020137e:	8eeff0ef          	jal	ra,ffffffffc020046c <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201382:	00005797          	auipc	a5,0x5
ffffffffc0201386:	1e678793          	addi	a5,a5,486 # ffffffffc0206568 <pmm_manager>
ffffffffc020138a:	639c                	ld	a5,0(a5)
ffffffffc020138c:	779c                	ld	a5,40(a5)
ffffffffc020138e:	9782                	jalr	a5
ffffffffc0201390:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201392:	8d4ff0ef          	jal	ra,ffffffffc0200466 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201396:	8522                	mv	a0,s0
ffffffffc0201398:	60a2                	ld	ra,8(sp)
ffffffffc020139a:	6402                	ld	s0,0(sp)
ffffffffc020139c:	0141                	addi	sp,sp,16
ffffffffc020139e:	8082                	ret

ffffffffc02013a0 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013a0:	00001797          	auipc	a5,0x1
ffffffffc02013a4:	4d078793          	addi	a5,a5,1232 # ffffffffc0202870 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013a8:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02013aa:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013ac:	00001517          	auipc	a0,0x1
ffffffffc02013b0:	51450513          	addi	a0,a0,1300 # ffffffffc02028c0 <best_fit_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc02013b4:	ec06                	sd	ra,24(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013b6:	00005717          	auipc	a4,0x5
ffffffffc02013ba:	1af73923          	sd	a5,434(a4) # ffffffffc0206568 <pmm_manager>
void pmm_init(void) {
ffffffffc02013be:	e822                	sd	s0,16(sp)
ffffffffc02013c0:	e426                	sd	s1,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02013c2:	00005417          	auipc	s0,0x5
ffffffffc02013c6:	1a640413          	addi	s0,s0,422 # ffffffffc0206568 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013ca:	cf5fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc02013ce:	601c                	ld	a5,0(s0)
ffffffffc02013d0:	679c                	ld	a5,8(a5)
ffffffffc02013d2:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013d4:	57f5                	li	a5,-3
ffffffffc02013d6:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02013d8:	00001517          	auipc	a0,0x1
ffffffffc02013dc:	50050513          	addi	a0,a0,1280 # ffffffffc02028d8 <best_fit_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013e0:	00005717          	auipc	a4,0x5
ffffffffc02013e4:	18f73823          	sd	a5,400(a4) # ffffffffc0206570 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02013e8:	cd7fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02013ec:	46c5                	li	a3,17
ffffffffc02013ee:	06ee                	slli	a3,a3,0x1b
ffffffffc02013f0:	40100613          	li	a2,1025
ffffffffc02013f4:	16fd                	addi	a3,a3,-1
ffffffffc02013f6:	0656                	slli	a2,a2,0x15
ffffffffc02013f8:	07e005b7          	lui	a1,0x7e00
ffffffffc02013fc:	00001517          	auipc	a0,0x1
ffffffffc0201400:	4f450513          	addi	a0,a0,1268 # ffffffffc02028f0 <best_fit_pmm_manager+0x80>
ffffffffc0201404:	cbbfe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201408:	777d                	lui	a4,0xfffff
ffffffffc020140a:	00006797          	auipc	a5,0x6
ffffffffc020140e:	17578793          	addi	a5,a5,373 # ffffffffc020757f <end+0xfff>
ffffffffc0201412:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201414:	00088737          	lui	a4,0x88
ffffffffc0201418:	00005697          	auipc	a3,0x5
ffffffffc020141c:	00e6bc23          	sd	a4,24(a3) # ffffffffc0206430 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201420:	4601                	li	a2,0
ffffffffc0201422:	00005717          	auipc	a4,0x5
ffffffffc0201426:	14f73b23          	sd	a5,342(a4) # ffffffffc0206578 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020142a:	4681                	li	a3,0
ffffffffc020142c:	00005897          	auipc	a7,0x5
ffffffffc0201430:	00488893          	addi	a7,a7,4 # ffffffffc0206430 <npage>
ffffffffc0201434:	00005597          	auipc	a1,0x5
ffffffffc0201438:	14458593          	addi	a1,a1,324 # ffffffffc0206578 <pages>
ffffffffc020143c:	4805                	li	a6,1
ffffffffc020143e:	fff80537          	lui	a0,0xfff80
ffffffffc0201442:	a011                	j	ffffffffc0201446 <pmm_init+0xa6>
ffffffffc0201444:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0201446:	97b2                	add	a5,a5,a2
ffffffffc0201448:	07a1                	addi	a5,a5,8
ffffffffc020144a:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020144e:	0008b703          	ld	a4,0(a7)
ffffffffc0201452:	0685                	addi	a3,a3,1
ffffffffc0201454:	02860613          	addi	a2,a2,40
ffffffffc0201458:	00a707b3          	add	a5,a4,a0
ffffffffc020145c:	fef6e4e3          	bltu	a3,a5,ffffffffc0201444 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201460:	6190                	ld	a2,0(a1)
ffffffffc0201462:	00271793          	slli	a5,a4,0x2
ffffffffc0201466:	97ba                	add	a5,a5,a4
ffffffffc0201468:	fec006b7          	lui	a3,0xfec00
ffffffffc020146c:	078e                	slli	a5,a5,0x3
ffffffffc020146e:	96b2                	add	a3,a3,a2
ffffffffc0201470:	96be                	add	a3,a3,a5
ffffffffc0201472:	c02007b7          	lui	a5,0xc0200
ffffffffc0201476:	08f6e863          	bltu	a3,a5,ffffffffc0201506 <pmm_init+0x166>
ffffffffc020147a:	00005497          	auipc	s1,0x5
ffffffffc020147e:	0f648493          	addi	s1,s1,246 # ffffffffc0206570 <va_pa_offset>
ffffffffc0201482:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0201484:	45c5                	li	a1,17
ffffffffc0201486:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201488:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc020148a:	04b6e963          	bltu	a3,a1,ffffffffc02014dc <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020148e:	601c                	ld	a5,0(s0)
ffffffffc0201490:	7b9c                	ld	a5,48(a5)
ffffffffc0201492:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201494:	00001517          	auipc	a0,0x1
ffffffffc0201498:	4f450513          	addi	a0,a0,1268 # ffffffffc0202988 <best_fit_pmm_manager+0x118>
ffffffffc020149c:	c23fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02014a0:	00004697          	auipc	a3,0x4
ffffffffc02014a4:	b6068693          	addi	a3,a3,-1184 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02014a8:	00005797          	auipc	a5,0x5
ffffffffc02014ac:	f8d7b823          	sd	a3,-112(a5) # ffffffffc0206438 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02014b0:	c02007b7          	lui	a5,0xc0200
ffffffffc02014b4:	06f6e563          	bltu	a3,a5,ffffffffc020151e <pmm_init+0x17e>
ffffffffc02014b8:	609c                	ld	a5,0(s1)
}
ffffffffc02014ba:	6442                	ld	s0,16(sp)
ffffffffc02014bc:	60e2                	ld	ra,24(sp)
ffffffffc02014be:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014c0:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02014c2:	8e9d                	sub	a3,a3,a5
ffffffffc02014c4:	00005797          	auipc	a5,0x5
ffffffffc02014c8:	08d7be23          	sd	a3,156(a5) # ffffffffc0206560 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014cc:	00001517          	auipc	a0,0x1
ffffffffc02014d0:	4dc50513          	addi	a0,a0,1244 # ffffffffc02029a8 <best_fit_pmm_manager+0x138>
ffffffffc02014d4:	8636                	mv	a2,a3
}
ffffffffc02014d6:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014d8:	be7fe06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02014dc:	6785                	lui	a5,0x1
ffffffffc02014de:	17fd                	addi	a5,a5,-1
ffffffffc02014e0:	96be                	add	a3,a3,a5
ffffffffc02014e2:	77fd                	lui	a5,0xfffff
ffffffffc02014e4:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02014e6:	00c6d793          	srli	a5,a3,0xc
ffffffffc02014ea:	04e7f663          	bleu	a4,a5,ffffffffc0201536 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc02014ee:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02014f0:	97aa                	add	a5,a5,a0
ffffffffc02014f2:	00279513          	slli	a0,a5,0x2
ffffffffc02014f6:	953e                	add	a0,a0,a5
ffffffffc02014f8:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02014fa:	8d95                	sub	a1,a1,a3
ffffffffc02014fc:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02014fe:	81b1                	srli	a1,a1,0xc
ffffffffc0201500:	9532                	add	a0,a0,a2
ffffffffc0201502:	9782                	jalr	a5
ffffffffc0201504:	b769                	j	ffffffffc020148e <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201506:	00001617          	auipc	a2,0x1
ffffffffc020150a:	41a60613          	addi	a2,a2,1050 # ffffffffc0202920 <best_fit_pmm_manager+0xb0>
ffffffffc020150e:	07100593          	li	a1,113
ffffffffc0201512:	00001517          	auipc	a0,0x1
ffffffffc0201516:	43650513          	addi	a0,a0,1078 # ffffffffc0202948 <best_fit_pmm_manager+0xd8>
ffffffffc020151a:	e9bfe0ef          	jal	ra,ffffffffc02003b4 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020151e:	00001617          	auipc	a2,0x1
ffffffffc0201522:	40260613          	addi	a2,a2,1026 # ffffffffc0202920 <best_fit_pmm_manager+0xb0>
ffffffffc0201526:	08d00593          	li	a1,141
ffffffffc020152a:	00001517          	auipc	a0,0x1
ffffffffc020152e:	41e50513          	addi	a0,a0,1054 # ffffffffc0202948 <best_fit_pmm_manager+0xd8>
ffffffffc0201532:	e83fe0ef          	jal	ra,ffffffffc02003b4 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201536:	00001617          	auipc	a2,0x1
ffffffffc020153a:	42260613          	addi	a2,a2,1058 # ffffffffc0202958 <best_fit_pmm_manager+0xe8>
ffffffffc020153e:	06b00593          	li	a1,107
ffffffffc0201542:	00001517          	auipc	a0,0x1
ffffffffc0201546:	43650513          	addi	a0,a0,1078 # ffffffffc0202978 <best_fit_pmm_manager+0x108>
ffffffffc020154a:	e6bfe0ef          	jal	ra,ffffffffc02003b4 <__panic>

ffffffffc020154e <slob_free>:
}

static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	if (!block)
ffffffffc020154e:	c929                	beqz	a0,ffffffffc02015a0 <slob_free+0x52>
		return;
	if (size)
ffffffffc0201550:	e9a9                	bnez	a1,ffffffffc02015a2 <slob_free+0x54>
ffffffffc0201552:	4114                	lw	a3,0(a0)
		b->units = SLOB_UNITS(size);

	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201554:	00005797          	auipc	a5,0x5
ffffffffc0201558:	abc78793          	addi	a5,a5,-1348 # ffffffffc0206010 <slobfree>
ffffffffc020155c:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020155e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201560:	00a7fa63          	bleu	a0,a5,ffffffffc0201574 <slob_free+0x26>
ffffffffc0201564:	00e56c63          	bltu	a0,a4,ffffffffc020157c <slob_free+0x2e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201568:	00e7fa63          	bleu	a4,a5,ffffffffc020157c <slob_free+0x2e>
{
ffffffffc020156c:	87ba                	mv	a5,a4
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020156e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201570:	fea7eae3          	bltu	a5,a0,ffffffffc0201564 <slob_free+0x16>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201574:	fee7ece3          	bltu	a5,a4,ffffffffc020156c <slob_free+0x1e>
ffffffffc0201578:	fee57ae3          	bleu	a4,a0,ffffffffc020156c <slob_free+0x1e>
			break;

	if (b + b->units == cur->next) {
ffffffffc020157c:	00469613          	slli	a2,a3,0x4
ffffffffc0201580:	962a                	add	a2,a2,a0
ffffffffc0201582:	02c70f63          	beq	a4,a2,ffffffffc02015c0 <slob_free+0x72>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;
ffffffffc0201586:	e518                	sd	a4,8(a0)

	if (cur + cur->units == b) {
ffffffffc0201588:	4394                	lw	a3,0(a5)
ffffffffc020158a:	00469713          	slli	a4,a3,0x4
ffffffffc020158e:	973e                	add	a4,a4,a5
ffffffffc0201590:	00e50e63          	beq	a0,a4,ffffffffc02015ac <slob_free+0x5e>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201594:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc0201596:	00005717          	auipc	a4,0x5
ffffffffc020159a:	a6f73d23          	sd	a5,-1414(a4) # ffffffffc0206010 <slobfree>
ffffffffc020159e:	8082                	ret
}
ffffffffc02015a0:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc02015a2:	00f58693          	addi	a3,a1,15
ffffffffc02015a6:	8691                	srai	a3,a3,0x4
ffffffffc02015a8:	c114                	sw	a3,0(a0)
ffffffffc02015aa:	b76d                	j	ffffffffc0201554 <slob_free+0x6>
		cur->units += b->units;
ffffffffc02015ac:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc02015ae:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc02015b0:	9eb9                	addw	a3,a3,a4
ffffffffc02015b2:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc02015b4:	e790                	sd	a2,8(a5)
	slobfree = cur;
ffffffffc02015b6:	00005717          	auipc	a4,0x5
ffffffffc02015ba:	a4f73d23          	sd	a5,-1446(a4) # ffffffffc0206010 <slobfree>
ffffffffc02015be:	8082                	ret
		b->units += cur->next->units;
ffffffffc02015c0:	4310                	lw	a2,0(a4)
		b->next = cur->next->next;
ffffffffc02015c2:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc02015c4:	9eb1                	addw	a3,a3,a2
ffffffffc02015c6:	c114                	sw	a3,0(a0)
		b->next = cur->next->next;
ffffffffc02015c8:	e518                	sd	a4,8(a0)
ffffffffc02015ca:	bf7d                	j	ffffffffc0201588 <slob_free+0x3a>

ffffffffc02015cc <slob_alloc>:
{
ffffffffc02015cc:	1101                	addi	sp,sp,-32
ffffffffc02015ce:	ec06                	sd	ra,24(sp)
ffffffffc02015d0:	e822                	sd	s0,16(sp)
ffffffffc02015d2:	e426                	sd	s1,8(sp)
    assert(size < PGSIZE);
ffffffffc02015d4:	6785                	lui	a5,0x1
ffffffffc02015d6:	08f57563          	bleu	a5,a0,ffffffffc0201660 <slob_alloc+0x94>
	prev = slobfree;
ffffffffc02015da:	00005497          	auipc	s1,0x5
ffffffffc02015de:	a3648493          	addi	s1,s1,-1482 # ffffffffc0206010 <slobfree>
ffffffffc02015e2:	6094                	ld	a3,0(s1)
	int  units = SLOB_UNITS(size);
ffffffffc02015e4:	00f50413          	addi	s0,a0,15
ffffffffc02015e8:	8011                	srli	s0,s0,0x4
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02015ea:	669c                	ld	a5,8(a3)
	int  units = SLOB_UNITS(size);
ffffffffc02015ec:	2401                	sext.w	s0,s0
		if (cur->units >= units) {
ffffffffc02015ee:	4398                	lw	a4,0(a5)
ffffffffc02015f0:	04875f63          	ble	s0,a4,ffffffffc020164e <slob_alloc+0x82>
		if (cur == slobfree) {
ffffffffc02015f4:	00f68a63          	beq	a3,a5,ffffffffc0201608 <slob_alloc+0x3c>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02015f8:	6788                	ld	a0,8(a5)
		if (cur->units >= units) {
ffffffffc02015fa:	4118                	lw	a4,0(a0)
ffffffffc02015fc:	02875263          	ble	s0,a4,ffffffffc0201620 <slob_alloc+0x54>
ffffffffc0201600:	6094                	ld	a3,0(s1)
ffffffffc0201602:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc0201604:	fef69ae3          	bne	a3,a5,ffffffffc02015f8 <slob_alloc+0x2c>
			cur = (slob_t *)alloc_pages(1);
ffffffffc0201608:	4505                	li	a0,1
ffffffffc020160a:	ccdff0ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
			if (!cur)
ffffffffc020160e:	c139                	beqz	a0,ffffffffc0201654 <slob_alloc+0x88>
			slob_free(cur, PGSIZE);
ffffffffc0201610:	6585                	lui	a1,0x1
ffffffffc0201612:	f3dff0ef          	jal	ra,ffffffffc020154e <slob_free>
			cur = slobfree;
ffffffffc0201616:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201618:	6788                	ld	a0,8(a5)
		if (cur->units >= units) {
ffffffffc020161a:	4118                	lw	a4,0(a0)
ffffffffc020161c:	fe8742e3          	blt	a4,s0,ffffffffc0201600 <slob_alloc+0x34>
			if (cur->units == units)
ffffffffc0201620:	02e40463          	beq	s0,a4,ffffffffc0201648 <slob_alloc+0x7c>
				prev->next = cur + units;
ffffffffc0201624:	00441693          	slli	a3,s0,0x4
ffffffffc0201628:	96aa                	add	a3,a3,a0
ffffffffc020162a:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc020162c:	6510                	ld	a2,8(a0)
				prev->next->units = cur->units - units;
ffffffffc020162e:	9f01                	subw	a4,a4,s0
ffffffffc0201630:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201632:	e690                	sd	a2,8(a3)
				cur->units = units;
ffffffffc0201634:	c100                	sw	s0,0(a0)
}
ffffffffc0201636:	60e2                	ld	ra,24(sp)
ffffffffc0201638:	6442                	ld	s0,16(sp)
			slobfree = prev;
ffffffffc020163a:	00005717          	auipc	a4,0x5
ffffffffc020163e:	9cf73b23          	sd	a5,-1578(a4) # ffffffffc0206010 <slobfree>
}
ffffffffc0201642:	64a2                	ld	s1,8(sp)
ffffffffc0201644:	6105                	addi	sp,sp,32
ffffffffc0201646:	8082                	ret
				prev->next = cur->next;
ffffffffc0201648:	6518                	ld	a4,8(a0)
ffffffffc020164a:	e798                	sd	a4,8(a5)
ffffffffc020164c:	b7ed                	j	ffffffffc0201636 <slob_alloc+0x6a>
		if (cur->units >= units) {
ffffffffc020164e:	853e                	mv	a0,a5
ffffffffc0201650:	87b6                	mv	a5,a3
ffffffffc0201652:	b7f9                	j	ffffffffc0201620 <slob_alloc+0x54>
}
ffffffffc0201654:	60e2                	ld	ra,24(sp)
ffffffffc0201656:	6442                	ld	s0,16(sp)
ffffffffc0201658:	64a2                	ld	s1,8(sp)
				return 0;
ffffffffc020165a:	4501                	li	a0,0
}
ffffffffc020165c:	6105                	addi	sp,sp,32
ffffffffc020165e:	8082                	ret
    assert(size < PGSIZE);
ffffffffc0201660:	00001697          	auipc	a3,0x1
ffffffffc0201664:	38868693          	addi	a3,a3,904 # ffffffffc02029e8 <best_fit_pmm_manager+0x178>
ffffffffc0201668:	00001617          	auipc	a2,0x1
ffffffffc020166c:	ed860613          	addi	a2,a2,-296 # ffffffffc0202540 <commands+0x638>
ffffffffc0201670:	02100593          	li	a1,33
ffffffffc0201674:	00001517          	auipc	a0,0x1
ffffffffc0201678:	38450513          	addi	a0,a0,900 # ffffffffc02029f8 <best_fit_pmm_manager+0x188>
ffffffffc020167c:	d39fe0ef          	jal	ra,ffffffffc02003b4 <__panic>

ffffffffc0201680 <slub_init>:

void 
slub_init(void) {
    cprintf("slub_init() succeeded!\n");
ffffffffc0201680:	00001517          	auipc	a0,0x1
ffffffffc0201684:	3d050513          	addi	a0,a0,976 # ffffffffc0202a50 <best_fit_pmm_manager+0x1e0>
ffffffffc0201688:	a37fe06f          	j	ffffffffc02000be <cprintf>

ffffffffc020168c <slub_alloc>:
}

void *slub_alloc(size_t size)
{
ffffffffc020168c:	1101                	addi	sp,sp,-32
	slob_t *m;
	bigblock_t *bb;

	if (size < PGSIZE - SLOB_UNIT) {
ffffffffc020168e:	6785                	lui	a5,0x1
{
ffffffffc0201690:	e822                	sd	s0,16(sp)
ffffffffc0201692:	ec06                	sd	ra,24(sp)
ffffffffc0201694:	e426                	sd	s1,8(sp)
	if (size < PGSIZE - SLOB_UNIT) {
ffffffffc0201696:	17bd                	addi	a5,a5,-17
{
ffffffffc0201698:	842a                	mv	s0,a0
	if (size < PGSIZE - SLOB_UNIT) {
ffffffffc020169a:	04a7f163          	bleu	a0,a5,ffffffffc02016dc <slub_alloc+0x50>
		m = slob_alloc(size + SLOB_UNIT);
		return m ? (void *)(m + 1) : 0;
	}

	bb = slob_alloc(sizeof(bigblock_t));
ffffffffc020169e:	4561                	li	a0,24
ffffffffc02016a0:	f2dff0ef          	jal	ra,ffffffffc02015cc <slob_alloc>
ffffffffc02016a4:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02016a6:	c129                	beqz	a0,ffffffffc02016e8 <slub_alloc+0x5c>
		return 0;

	bb->order = ((size-1) >> PGSHIFT) + 1;
ffffffffc02016a8:	fff40513          	addi	a0,s0,-1
ffffffffc02016ac:	8131                	srli	a0,a0,0xc
ffffffffc02016ae:	2505                	addiw	a0,a0,1
ffffffffc02016b0:	c088                	sw	a0,0(s1)
	bb->pages = (void *)alloc_pages(bb->order);
ffffffffc02016b2:	c25ff0ef          	jal	ra,ffffffffc02012d6 <alloc_pages>
ffffffffc02016b6:	e488                	sd	a0,8(s1)
ffffffffc02016b8:	842a                	mv	s0,a0

	if (bb->pages) {
ffffffffc02016ba:	cd15                	beqz	a0,ffffffffc02016f6 <slub_alloc+0x6a>
		bb->next = bigblocks;
ffffffffc02016bc:	00005797          	auipc	a5,0x5
ffffffffc02016c0:	d8478793          	addi	a5,a5,-636 # ffffffffc0206440 <bigblocks>
ffffffffc02016c4:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc02016c6:	00005717          	auipc	a4,0x5
ffffffffc02016ca:	d6973d23          	sd	s1,-646(a4) # ffffffffc0206440 <bigblocks>
		bb->next = bigblocks;
ffffffffc02016ce:	e89c                	sd	a5,16(s1)
		return bb->pages;
	}

	slob_free(bb, sizeof(bigblock_t));
	return 0;
}
ffffffffc02016d0:	8522                	mv	a0,s0
ffffffffc02016d2:	60e2                	ld	ra,24(sp)
ffffffffc02016d4:	6442                	ld	s0,16(sp)
ffffffffc02016d6:	64a2                	ld	s1,8(sp)
ffffffffc02016d8:	6105                	addi	sp,sp,32
ffffffffc02016da:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT);
ffffffffc02016dc:	0541                	addi	a0,a0,16
ffffffffc02016de:	eefff0ef          	jal	ra,ffffffffc02015cc <slob_alloc>
		return m ? (void *)(m + 1) : 0;
ffffffffc02016e2:	01050413          	addi	s0,a0,16
ffffffffc02016e6:	f56d                	bnez	a0,ffffffffc02016d0 <slub_alloc+0x44>
ffffffffc02016e8:	4401                	li	s0,0
}
ffffffffc02016ea:	8522                	mv	a0,s0
ffffffffc02016ec:	60e2                	ld	ra,24(sp)
ffffffffc02016ee:	6442                	ld	s0,16(sp)
ffffffffc02016f0:	64a2                	ld	s1,8(sp)
ffffffffc02016f2:	6105                	addi	sp,sp,32
ffffffffc02016f4:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc02016f6:	45e1                	li	a1,24
ffffffffc02016f8:	8526                	mv	a0,s1
ffffffffc02016fa:	e55ff0ef          	jal	ra,ffffffffc020154e <slob_free>
	return 0;
ffffffffc02016fe:	bfc9                	j	ffffffffc02016d0 <slub_alloc+0x44>

ffffffffc0201700 <slub_free>:

void slub_free(void *block)
{
	bigblock_t *bb, **last = &bigblocks;

	if (!block)
ffffffffc0201700:	cd29                	beqz	a0,ffffffffc020175a <slub_free+0x5a>
		return;

	if (!((unsigned long)block & (PGSIZE-1))) {
ffffffffc0201702:	03451793          	slli	a5,a0,0x34
ffffffffc0201706:	ebb9                	bnez	a5,ffffffffc020175c <slub_free+0x5c>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201708:	00005717          	auipc	a4,0x5
ffffffffc020170c:	d3870713          	addi	a4,a4,-712 # ffffffffc0206440 <bigblocks>
ffffffffc0201710:	631c                	ld	a5,0(a4)
ffffffffc0201712:	c7a9                	beqz	a5,ffffffffc020175c <slub_free+0x5c>
			if (bb->pages == block) {
ffffffffc0201714:	6794                	ld	a3,8(a5)
{
ffffffffc0201716:	1141                	addi	sp,sp,-16
ffffffffc0201718:	e406                	sd	ra,8(sp)
ffffffffc020171a:	e022                	sd	s0,0(sp)
			if (bb->pages == block) {
ffffffffc020171c:	00d51963          	bne	a0,a3,ffffffffc020172e <slub_free+0x2e>
ffffffffc0201720:	843e                	mv	s0,a5
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201722:	87ba                	mv	a5,a4
ffffffffc0201724:	a839                	j	ffffffffc0201742 <slub_free+0x42>
			if (bb->pages == block) {
ffffffffc0201726:	6418                	ld	a4,8(s0)
ffffffffc0201728:	00a70c63          	beq	a4,a0,ffffffffc0201740 <slub_free+0x40>
ffffffffc020172c:	87a2                	mv	a5,s0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020172e:	6b80                	ld	s0,16(a5)
ffffffffc0201730:	f87d                	bnez	s0,ffffffffc0201726 <slub_free+0x26>
		}
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201732:	6402                	ld	s0,0(sp)
ffffffffc0201734:	60a2                	ld	ra,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201736:	4581                	li	a1,0
ffffffffc0201738:	1541                	addi	a0,a0,-16
}
ffffffffc020173a:	0141                	addi	sp,sp,16
	slob_free((slob_t *)block - 1, 0);
ffffffffc020173c:	e13ff06f          	j	ffffffffc020154e <slob_free>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201740:	07c1                	addi	a5,a5,16
				*last = bb->next;
ffffffffc0201742:	6818                	ld	a4,16(s0)
				free_pages((struct Page *)block, bb->order);
ffffffffc0201744:	400c                	lw	a1,0(s0)
				*last = bb->next;
ffffffffc0201746:	e398                	sd	a4,0(a5)
				free_pages((struct Page *)block, bb->order);
ffffffffc0201748:	bd3ff0ef          	jal	ra,ffffffffc020131a <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc020174c:	8522                	mv	a0,s0
}
ffffffffc020174e:	6402                	ld	s0,0(sp)
ffffffffc0201750:	60a2                	ld	ra,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201752:	45e1                	li	a1,24
}
ffffffffc0201754:	0141                	addi	sp,sp,16
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201756:	df9ff06f          	j	ffffffffc020154e <slob_free>
ffffffffc020175a:	8082                	ret
ffffffffc020175c:	4581                	li	a1,0
ffffffffc020175e:	1541                	addi	a0,a0,-16
ffffffffc0201760:	defff06f          	j	ffffffffc020154e <slob_free>

ffffffffc0201764 <slub_check>:
        len ++;
    return len;
}

void slub_check()
{
ffffffffc0201764:	1101                	addi	sp,sp,-32
    cprintf("slub check begin\n");
ffffffffc0201766:	00001517          	auipc	a0,0x1
ffffffffc020176a:	2aa50513          	addi	a0,a0,682 # ffffffffc0202a10 <best_fit_pmm_manager+0x1a0>
{
ffffffffc020176e:	e822                	sd	s0,16(sp)
ffffffffc0201770:	ec06                	sd	ra,24(sp)
ffffffffc0201772:	e426                	sd	s1,8(sp)
ffffffffc0201774:	e04a                	sd	s2,0(sp)
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201776:	00005417          	auipc	s0,0x5
ffffffffc020177a:	89a40413          	addi	s0,s0,-1894 # ffffffffc0206010 <slobfree>
    cprintf("slub check begin\n");
ffffffffc020177e:	941fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201782:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc0201784:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201786:	671c                	ld	a5,8(a4)
ffffffffc0201788:	00f70663          	beq	a4,a5,ffffffffc0201794 <slub_check+0x30>
ffffffffc020178c:	679c                	ld	a5,8(a5)
        len ++;
ffffffffc020178e:	2585                	addiw	a1,a1,1
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201790:	fef71ee3          	bne	a4,a5,ffffffffc020178c <slub_check+0x28>
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc0201794:	00001517          	auipc	a0,0x1
ffffffffc0201798:	29450513          	addi	a0,a0,660 # ffffffffc0202a28 <best_fit_pmm_manager+0x1b8>
ffffffffc020179c:	923fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    void* p1 = slub_alloc(4096);
ffffffffc02017a0:	6505                	lui	a0,0x1
ffffffffc02017a2:	eebff0ef          	jal	ra,ffffffffc020168c <slub_alloc>
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02017a6:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc02017a8:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02017aa:	671c                	ld	a5,8(a4)
ffffffffc02017ac:	00f70663          	beq	a4,a5,ffffffffc02017b8 <slub_check+0x54>
ffffffffc02017b0:	679c                	ld	a5,8(a5)
        len ++;
ffffffffc02017b2:	2585                	addiw	a1,a1,1
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02017b4:	fef71ee3          	bne	a4,a5,ffffffffc02017b0 <slub_check+0x4c>
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc02017b8:	00001517          	auipc	a0,0x1
ffffffffc02017bc:	27050513          	addi	a0,a0,624 # ffffffffc0202a28 <best_fit_pmm_manager+0x1b8>
ffffffffc02017c0:	8fffe0ef          	jal	ra,ffffffffc02000be <cprintf>
		m = slob_alloc(size + SLOB_UNIT);
ffffffffc02017c4:	4549                	li	a0,18
ffffffffc02017c6:	e07ff0ef          	jal	ra,ffffffffc02015cc <slob_alloc>
		return m ? (void *)(m + 1) : 0;
ffffffffc02017ca:	4901                	li	s2,0
ffffffffc02017cc:	c119                	beqz	a0,ffffffffc02017d2 <slub_check+0x6e>
ffffffffc02017ce:	01050913          	addi	s2,a0,16
		m = slob_alloc(size + SLOB_UNIT);
ffffffffc02017d2:	4549                	li	a0,18
ffffffffc02017d4:	df9ff0ef          	jal	ra,ffffffffc02015cc <slob_alloc>
		return m ? (void *)(m + 1) : 0;
ffffffffc02017d8:	4481                	li	s1,0
ffffffffc02017da:	c119                	beqz	a0,ffffffffc02017e0 <slub_check+0x7c>
ffffffffc02017dc:	01050493          	addi	s1,a0,16
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02017e0:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc02017e2:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02017e4:	671c                	ld	a5,8(a4)
ffffffffc02017e6:	00f70663          	beq	a4,a5,ffffffffc02017f2 <slub_check+0x8e>
ffffffffc02017ea:	679c                	ld	a5,8(a5)
        len ++;
ffffffffc02017ec:	2585                	addiw	a1,a1,1
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02017ee:	fef71ee3          	bne	a4,a5,ffffffffc02017ea <slub_check+0x86>
    void* p2 = slub_alloc(2);
    void* p3 = slub_alloc(2);
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc02017f2:	00001517          	auipc	a0,0x1
ffffffffc02017f6:	23650513          	addi	a0,a0,566 # ffffffffc0202a28 <best_fit_pmm_manager+0x1b8>
ffffffffc02017fa:	8c5fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    slub_free(p2);
ffffffffc02017fe:	854a                	mv	a0,s2
ffffffffc0201800:	f01ff0ef          	jal	ra,ffffffffc0201700 <slub_free>
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201804:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc0201806:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201808:	671c                	ld	a5,8(a4)
ffffffffc020180a:	00f70663          	beq	a4,a5,ffffffffc0201816 <slub_check+0xb2>
ffffffffc020180e:	679c                	ld	a5,8(a5)
        len ++;
ffffffffc0201810:	2585                	addiw	a1,a1,1
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201812:	fef71ee3          	bne	a4,a5,ffffffffc020180e <slub_check+0xaa>
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc0201816:	00001517          	auipc	a0,0x1
ffffffffc020181a:	21250513          	addi	a0,a0,530 # ffffffffc0202a28 <best_fit_pmm_manager+0x1b8>
ffffffffc020181e:	8a1fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    slub_free(p3);
ffffffffc0201822:	8526                	mv	a0,s1
ffffffffc0201824:	eddff0ef          	jal	ra,ffffffffc0201700 <slub_free>
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201828:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc020182a:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020182c:	671c                	ld	a5,8(a4)
ffffffffc020182e:	00e78663          	beq	a5,a4,ffffffffc020183a <slub_check+0xd6>
ffffffffc0201832:	679c                	ld	a5,8(a5)
        len ++;
ffffffffc0201834:	2585                	addiw	a1,a1,1
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201836:	fef71ee3          	bne	a4,a5,ffffffffc0201832 <slub_check+0xce>
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc020183a:	00001517          	auipc	a0,0x1
ffffffffc020183e:	1ee50513          	addi	a0,a0,494 # ffffffffc0202a28 <best_fit_pmm_manager+0x1b8>
ffffffffc0201842:	87dfe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("slub check end\n");
ffffffffc0201846:	6442                	ld	s0,16(sp)
ffffffffc0201848:	60e2                	ld	ra,24(sp)
ffffffffc020184a:	64a2                	ld	s1,8(sp)
ffffffffc020184c:	6902                	ld	s2,0(sp)
    cprintf("slub check end\n");
ffffffffc020184e:	00001517          	auipc	a0,0x1
ffffffffc0201852:	1f250513          	addi	a0,a0,498 # ffffffffc0202a40 <best_fit_pmm_manager+0x1d0>
ffffffffc0201856:	6105                	addi	sp,sp,32
    cprintf("slub check end\n");
ffffffffc0201858:	867fe06f          	j	ffffffffc02000be <cprintf>

ffffffffc020185c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020185c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201860:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201862:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201866:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201868:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020186c:	f022                	sd	s0,32(sp)
ffffffffc020186e:	ec26                	sd	s1,24(sp)
ffffffffc0201870:	e84a                	sd	s2,16(sp)
ffffffffc0201872:	f406                	sd	ra,40(sp)
ffffffffc0201874:	e44e                	sd	s3,8(sp)
ffffffffc0201876:	84aa                	mv	s1,a0
ffffffffc0201878:	892e                	mv	s2,a1
ffffffffc020187a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020187e:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0201880:	03067e63          	bleu	a6,a2,ffffffffc02018bc <printnum+0x60>
ffffffffc0201884:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201886:	00805763          	blez	s0,ffffffffc0201894 <printnum+0x38>
ffffffffc020188a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020188c:	85ca                	mv	a1,s2
ffffffffc020188e:	854e                	mv	a0,s3
ffffffffc0201890:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201892:	fc65                	bnez	s0,ffffffffc020188a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201894:	1a02                	slli	s4,s4,0x20
ffffffffc0201896:	020a5a13          	srli	s4,s4,0x20
ffffffffc020189a:	00001797          	auipc	a5,0x1
ffffffffc020189e:	35e78793          	addi	a5,a5,862 # ffffffffc0202bf8 <error_string+0x38>
ffffffffc02018a2:	9a3e                	add	s4,s4,a5
}
ffffffffc02018a4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02018a6:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02018aa:	70a2                	ld	ra,40(sp)
ffffffffc02018ac:	69a2                	ld	s3,8(sp)
ffffffffc02018ae:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02018b0:	85ca                	mv	a1,s2
ffffffffc02018b2:	8326                	mv	t1,s1
}
ffffffffc02018b4:	6942                	ld	s2,16(sp)
ffffffffc02018b6:	64e2                	ld	s1,24(sp)
ffffffffc02018b8:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02018ba:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02018bc:	03065633          	divu	a2,a2,a6
ffffffffc02018c0:	8722                	mv	a4,s0
ffffffffc02018c2:	f9bff0ef          	jal	ra,ffffffffc020185c <printnum>
ffffffffc02018c6:	b7f9                	j	ffffffffc0201894 <printnum+0x38>

ffffffffc02018c8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02018c8:	7119                	addi	sp,sp,-128
ffffffffc02018ca:	f4a6                	sd	s1,104(sp)
ffffffffc02018cc:	f0ca                	sd	s2,96(sp)
ffffffffc02018ce:	e8d2                	sd	s4,80(sp)
ffffffffc02018d0:	e4d6                	sd	s5,72(sp)
ffffffffc02018d2:	e0da                	sd	s6,64(sp)
ffffffffc02018d4:	fc5e                	sd	s7,56(sp)
ffffffffc02018d6:	f862                	sd	s8,48(sp)
ffffffffc02018d8:	f06a                	sd	s10,32(sp)
ffffffffc02018da:	fc86                	sd	ra,120(sp)
ffffffffc02018dc:	f8a2                	sd	s0,112(sp)
ffffffffc02018de:	ecce                	sd	s3,88(sp)
ffffffffc02018e0:	f466                	sd	s9,40(sp)
ffffffffc02018e2:	ec6e                	sd	s11,24(sp)
ffffffffc02018e4:	892a                	mv	s2,a0
ffffffffc02018e6:	84ae                	mv	s1,a1
ffffffffc02018e8:	8d32                	mv	s10,a2
ffffffffc02018ea:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02018ec:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018ee:	00001a17          	auipc	s4,0x1
ffffffffc02018f2:	17aa0a13          	addi	s4,s4,378 # ffffffffc0202a68 <best_fit_pmm_manager+0x1f8>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018f6:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02018fa:	00001c17          	auipc	s8,0x1
ffffffffc02018fe:	2c6c0c13          	addi	s8,s8,710 # ffffffffc0202bc0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201902:	000d4503          	lbu	a0,0(s10)
ffffffffc0201906:	02500793          	li	a5,37
ffffffffc020190a:	001d0413          	addi	s0,s10,1
ffffffffc020190e:	00f50e63          	beq	a0,a5,ffffffffc020192a <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201912:	c521                	beqz	a0,ffffffffc020195a <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201914:	02500993          	li	s3,37
ffffffffc0201918:	a011                	j	ffffffffc020191c <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020191a:	c121                	beqz	a0,ffffffffc020195a <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020191c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020191e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201920:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201922:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201926:	ff351ae3          	bne	a0,s3,ffffffffc020191a <vprintfmt+0x52>
ffffffffc020192a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020192e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201932:	4981                	li	s3,0
ffffffffc0201934:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0201936:	5cfd                	li	s9,-1
ffffffffc0201938:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020193a:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc020193e:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201940:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201944:	0ff6f693          	andi	a3,a3,255
ffffffffc0201948:	00140d13          	addi	s10,s0,1
ffffffffc020194c:	20d5e563          	bltu	a1,a3,ffffffffc0201b56 <vprintfmt+0x28e>
ffffffffc0201950:	068a                	slli	a3,a3,0x2
ffffffffc0201952:	96d2                	add	a3,a3,s4
ffffffffc0201954:	4294                	lw	a3,0(a3)
ffffffffc0201956:	96d2                	add	a3,a3,s4
ffffffffc0201958:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020195a:	70e6                	ld	ra,120(sp)
ffffffffc020195c:	7446                	ld	s0,112(sp)
ffffffffc020195e:	74a6                	ld	s1,104(sp)
ffffffffc0201960:	7906                	ld	s2,96(sp)
ffffffffc0201962:	69e6                	ld	s3,88(sp)
ffffffffc0201964:	6a46                	ld	s4,80(sp)
ffffffffc0201966:	6aa6                	ld	s5,72(sp)
ffffffffc0201968:	6b06                	ld	s6,64(sp)
ffffffffc020196a:	7be2                	ld	s7,56(sp)
ffffffffc020196c:	7c42                	ld	s8,48(sp)
ffffffffc020196e:	7ca2                	ld	s9,40(sp)
ffffffffc0201970:	7d02                	ld	s10,32(sp)
ffffffffc0201972:	6de2                	ld	s11,24(sp)
ffffffffc0201974:	6109                	addi	sp,sp,128
ffffffffc0201976:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201978:	4705                	li	a4,1
ffffffffc020197a:	008a8593          	addi	a1,s5,8
ffffffffc020197e:	01074463          	blt	a4,a6,ffffffffc0201986 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0201982:	26080363          	beqz	a6,ffffffffc0201be8 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0201986:	000ab603          	ld	a2,0(s5)
ffffffffc020198a:	46c1                	li	a3,16
ffffffffc020198c:	8aae                	mv	s5,a1
ffffffffc020198e:	a06d                	j	ffffffffc0201a38 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201990:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201994:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201996:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201998:	b765                	j	ffffffffc0201940 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc020199a:	000aa503          	lw	a0,0(s5)
ffffffffc020199e:	85a6                	mv	a1,s1
ffffffffc02019a0:	0aa1                	addi	s5,s5,8
ffffffffc02019a2:	9902                	jalr	s2
            break;
ffffffffc02019a4:	bfb9                	j	ffffffffc0201902 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02019a6:	4705                	li	a4,1
ffffffffc02019a8:	008a8993          	addi	s3,s5,8
ffffffffc02019ac:	01074463          	blt	a4,a6,ffffffffc02019b4 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02019b0:	22080463          	beqz	a6,ffffffffc0201bd8 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02019b4:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02019b8:	24044463          	bltz	s0,ffffffffc0201c00 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02019bc:	8622                	mv	a2,s0
ffffffffc02019be:	8ace                	mv	s5,s3
ffffffffc02019c0:	46a9                	li	a3,10
ffffffffc02019c2:	a89d                	j	ffffffffc0201a38 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02019c4:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02019c8:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02019ca:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02019cc:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02019d0:	8fb5                	xor	a5,a5,a3
ffffffffc02019d2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02019d6:	1ad74363          	blt	a4,a3,ffffffffc0201b7c <vprintfmt+0x2b4>
ffffffffc02019da:	00369793          	slli	a5,a3,0x3
ffffffffc02019de:	97e2                	add	a5,a5,s8
ffffffffc02019e0:	639c                	ld	a5,0(a5)
ffffffffc02019e2:	18078d63          	beqz	a5,ffffffffc0201b7c <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02019e6:	86be                	mv	a3,a5
ffffffffc02019e8:	00001617          	auipc	a2,0x1
ffffffffc02019ec:	2c060613          	addi	a2,a2,704 # ffffffffc0202ca8 <error_string+0xe8>
ffffffffc02019f0:	85a6                	mv	a1,s1
ffffffffc02019f2:	854a                	mv	a0,s2
ffffffffc02019f4:	240000ef          	jal	ra,ffffffffc0201c34 <printfmt>
ffffffffc02019f8:	b729                	j	ffffffffc0201902 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02019fa:	00144603          	lbu	a2,1(s0)
ffffffffc02019fe:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a00:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201a02:	bf3d                	j	ffffffffc0201940 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201a04:	4705                	li	a4,1
ffffffffc0201a06:	008a8593          	addi	a1,s5,8
ffffffffc0201a0a:	01074463          	blt	a4,a6,ffffffffc0201a12 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201a0e:	1e080263          	beqz	a6,ffffffffc0201bf2 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0201a12:	000ab603          	ld	a2,0(s5)
ffffffffc0201a16:	46a1                	li	a3,8
ffffffffc0201a18:	8aae                	mv	s5,a1
ffffffffc0201a1a:	a839                	j	ffffffffc0201a38 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201a1c:	03000513          	li	a0,48
ffffffffc0201a20:	85a6                	mv	a1,s1
ffffffffc0201a22:	e03e                	sd	a5,0(sp)
ffffffffc0201a24:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201a26:	85a6                	mv	a1,s1
ffffffffc0201a28:	07800513          	li	a0,120
ffffffffc0201a2c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201a2e:	0aa1                	addi	s5,s5,8
ffffffffc0201a30:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201a34:	6782                	ld	a5,0(sp)
ffffffffc0201a36:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201a38:	876e                	mv	a4,s11
ffffffffc0201a3a:	85a6                	mv	a1,s1
ffffffffc0201a3c:	854a                	mv	a0,s2
ffffffffc0201a3e:	e1fff0ef          	jal	ra,ffffffffc020185c <printnum>
            break;
ffffffffc0201a42:	b5c1                	j	ffffffffc0201902 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201a44:	000ab603          	ld	a2,0(s5)
ffffffffc0201a48:	0aa1                	addi	s5,s5,8
ffffffffc0201a4a:	1c060663          	beqz	a2,ffffffffc0201c16 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201a4e:	00160413          	addi	s0,a2,1
ffffffffc0201a52:	17b05c63          	blez	s11,ffffffffc0201bca <vprintfmt+0x302>
ffffffffc0201a56:	02d00593          	li	a1,45
ffffffffc0201a5a:	14b79263          	bne	a5,a1,ffffffffc0201b9e <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a5e:	00064783          	lbu	a5,0(a2)
ffffffffc0201a62:	0007851b          	sext.w	a0,a5
ffffffffc0201a66:	c905                	beqz	a0,ffffffffc0201a96 <vprintfmt+0x1ce>
ffffffffc0201a68:	000cc563          	bltz	s9,ffffffffc0201a72 <vprintfmt+0x1aa>
ffffffffc0201a6c:	3cfd                	addiw	s9,s9,-1
ffffffffc0201a6e:	036c8263          	beq	s9,s6,ffffffffc0201a92 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201a72:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201a74:	18098463          	beqz	s3,ffffffffc0201bfc <vprintfmt+0x334>
ffffffffc0201a78:	3781                	addiw	a5,a5,-32
ffffffffc0201a7a:	18fbf163          	bleu	a5,s7,ffffffffc0201bfc <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0201a7e:	03f00513          	li	a0,63
ffffffffc0201a82:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a84:	0405                	addi	s0,s0,1
ffffffffc0201a86:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201a8a:	3dfd                	addiw	s11,s11,-1
ffffffffc0201a8c:	0007851b          	sext.w	a0,a5
ffffffffc0201a90:	fd61                	bnez	a0,ffffffffc0201a68 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201a92:	e7b058e3          	blez	s11,ffffffffc0201902 <vprintfmt+0x3a>
ffffffffc0201a96:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201a98:	85a6                	mv	a1,s1
ffffffffc0201a9a:	02000513          	li	a0,32
ffffffffc0201a9e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201aa0:	e60d81e3          	beqz	s11,ffffffffc0201902 <vprintfmt+0x3a>
ffffffffc0201aa4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201aa6:	85a6                	mv	a1,s1
ffffffffc0201aa8:	02000513          	li	a0,32
ffffffffc0201aac:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201aae:	fe0d94e3          	bnez	s11,ffffffffc0201a96 <vprintfmt+0x1ce>
ffffffffc0201ab2:	bd81                	j	ffffffffc0201902 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201ab4:	4705                	li	a4,1
ffffffffc0201ab6:	008a8593          	addi	a1,s5,8
ffffffffc0201aba:	01074463          	blt	a4,a6,ffffffffc0201ac2 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0201abe:	12080063          	beqz	a6,ffffffffc0201bde <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0201ac2:	000ab603          	ld	a2,0(s5)
ffffffffc0201ac6:	46a9                	li	a3,10
ffffffffc0201ac8:	8aae                	mv	s5,a1
ffffffffc0201aca:	b7bd                	j	ffffffffc0201a38 <vprintfmt+0x170>
ffffffffc0201acc:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0201ad0:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201ad4:	846a                	mv	s0,s10
ffffffffc0201ad6:	b5ad                	j	ffffffffc0201940 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0201ad8:	85a6                	mv	a1,s1
ffffffffc0201ada:	02500513          	li	a0,37
ffffffffc0201ade:	9902                	jalr	s2
            break;
ffffffffc0201ae0:	b50d                	j	ffffffffc0201902 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0201ae2:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201ae6:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201aea:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201aec:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0201aee:	e40dd9e3          	bgez	s11,ffffffffc0201940 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201af2:	8de6                	mv	s11,s9
ffffffffc0201af4:	5cfd                	li	s9,-1
ffffffffc0201af6:	b5a9                	j	ffffffffc0201940 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201af8:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0201afc:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b00:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201b02:	bd3d                	j	ffffffffc0201940 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0201b04:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201b08:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b0c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201b0e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201b12:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201b16:	fcd56ce3          	bltu	a0,a3,ffffffffc0201aee <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201b1a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201b1c:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201b20:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201b24:	0196873b          	addw	a4,a3,s9
ffffffffc0201b28:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201b2c:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201b30:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201b34:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201b38:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201b3c:	fcd57fe3          	bleu	a3,a0,ffffffffc0201b1a <vprintfmt+0x252>
ffffffffc0201b40:	b77d                	j	ffffffffc0201aee <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201b42:	fffdc693          	not	a3,s11
ffffffffc0201b46:	96fd                	srai	a3,a3,0x3f
ffffffffc0201b48:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201b4c:	00144603          	lbu	a2,1(s0)
ffffffffc0201b50:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b52:	846a                	mv	s0,s10
ffffffffc0201b54:	b3f5                	j	ffffffffc0201940 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201b56:	85a6                	mv	a1,s1
ffffffffc0201b58:	02500513          	li	a0,37
ffffffffc0201b5c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201b5e:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201b62:	02500793          	li	a5,37
ffffffffc0201b66:	8d22                	mv	s10,s0
ffffffffc0201b68:	d8f70de3          	beq	a4,a5,ffffffffc0201902 <vprintfmt+0x3a>
ffffffffc0201b6c:	02500713          	li	a4,37
ffffffffc0201b70:	1d7d                	addi	s10,s10,-1
ffffffffc0201b72:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201b76:	fee79de3          	bne	a5,a4,ffffffffc0201b70 <vprintfmt+0x2a8>
ffffffffc0201b7a:	b361                	j	ffffffffc0201902 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201b7c:	00001617          	auipc	a2,0x1
ffffffffc0201b80:	11c60613          	addi	a2,a2,284 # ffffffffc0202c98 <error_string+0xd8>
ffffffffc0201b84:	85a6                	mv	a1,s1
ffffffffc0201b86:	854a                	mv	a0,s2
ffffffffc0201b88:	0ac000ef          	jal	ra,ffffffffc0201c34 <printfmt>
ffffffffc0201b8c:	bb9d                	j	ffffffffc0201902 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201b8e:	00001617          	auipc	a2,0x1
ffffffffc0201b92:	10260613          	addi	a2,a2,258 # ffffffffc0202c90 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201b96:	00001417          	auipc	s0,0x1
ffffffffc0201b9a:	0fb40413          	addi	s0,s0,251 # ffffffffc0202c91 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201b9e:	8532                	mv	a0,a2
ffffffffc0201ba0:	85e6                	mv	a1,s9
ffffffffc0201ba2:	e032                	sd	a2,0(sp)
ffffffffc0201ba4:	e43e                	sd	a5,8(sp)
ffffffffc0201ba6:	1c2000ef          	jal	ra,ffffffffc0201d68 <strnlen>
ffffffffc0201baa:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201bae:	6602                	ld	a2,0(sp)
ffffffffc0201bb0:	01b05d63          	blez	s11,ffffffffc0201bca <vprintfmt+0x302>
ffffffffc0201bb4:	67a2                	ld	a5,8(sp)
ffffffffc0201bb6:	2781                	sext.w	a5,a5
ffffffffc0201bb8:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201bba:	6522                	ld	a0,8(sp)
ffffffffc0201bbc:	85a6                	mv	a1,s1
ffffffffc0201bbe:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201bc0:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201bc2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201bc4:	6602                	ld	a2,0(sp)
ffffffffc0201bc6:	fe0d9ae3          	bnez	s11,ffffffffc0201bba <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201bca:	00064783          	lbu	a5,0(a2)
ffffffffc0201bce:	0007851b          	sext.w	a0,a5
ffffffffc0201bd2:	e8051be3          	bnez	a0,ffffffffc0201a68 <vprintfmt+0x1a0>
ffffffffc0201bd6:	b335                	j	ffffffffc0201902 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0201bd8:	000aa403          	lw	s0,0(s5)
ffffffffc0201bdc:	bbf1                	j	ffffffffc02019b8 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0201bde:	000ae603          	lwu	a2,0(s5)
ffffffffc0201be2:	46a9                	li	a3,10
ffffffffc0201be4:	8aae                	mv	s5,a1
ffffffffc0201be6:	bd89                	j	ffffffffc0201a38 <vprintfmt+0x170>
ffffffffc0201be8:	000ae603          	lwu	a2,0(s5)
ffffffffc0201bec:	46c1                	li	a3,16
ffffffffc0201bee:	8aae                	mv	s5,a1
ffffffffc0201bf0:	b5a1                	j	ffffffffc0201a38 <vprintfmt+0x170>
ffffffffc0201bf2:	000ae603          	lwu	a2,0(s5)
ffffffffc0201bf6:	46a1                	li	a3,8
ffffffffc0201bf8:	8aae                	mv	s5,a1
ffffffffc0201bfa:	bd3d                	j	ffffffffc0201a38 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0201bfc:	9902                	jalr	s2
ffffffffc0201bfe:	b559                	j	ffffffffc0201a84 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0201c00:	85a6                	mv	a1,s1
ffffffffc0201c02:	02d00513          	li	a0,45
ffffffffc0201c06:	e03e                	sd	a5,0(sp)
ffffffffc0201c08:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201c0a:	8ace                	mv	s5,s3
ffffffffc0201c0c:	40800633          	neg	a2,s0
ffffffffc0201c10:	46a9                	li	a3,10
ffffffffc0201c12:	6782                	ld	a5,0(sp)
ffffffffc0201c14:	b515                	j	ffffffffc0201a38 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201c16:	01b05663          	blez	s11,ffffffffc0201c22 <vprintfmt+0x35a>
ffffffffc0201c1a:	02d00693          	li	a3,45
ffffffffc0201c1e:	f6d798e3          	bne	a5,a3,ffffffffc0201b8e <vprintfmt+0x2c6>
ffffffffc0201c22:	00001417          	auipc	s0,0x1
ffffffffc0201c26:	06f40413          	addi	s0,s0,111 # ffffffffc0202c91 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201c2a:	02800513          	li	a0,40
ffffffffc0201c2e:	02800793          	li	a5,40
ffffffffc0201c32:	bd1d                	j	ffffffffc0201a68 <vprintfmt+0x1a0>

ffffffffc0201c34 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201c34:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201c36:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201c3a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201c3c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201c3e:	ec06                	sd	ra,24(sp)
ffffffffc0201c40:	f83a                	sd	a4,48(sp)
ffffffffc0201c42:	fc3e                	sd	a5,56(sp)
ffffffffc0201c44:	e0c2                	sd	a6,64(sp)
ffffffffc0201c46:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201c48:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201c4a:	c7fff0ef          	jal	ra,ffffffffc02018c8 <vprintfmt>
}
ffffffffc0201c4e:	60e2                	ld	ra,24(sp)
ffffffffc0201c50:	6161                	addi	sp,sp,80
ffffffffc0201c52:	8082                	ret

ffffffffc0201c54 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201c54:	715d                	addi	sp,sp,-80
ffffffffc0201c56:	e486                	sd	ra,72(sp)
ffffffffc0201c58:	e0a2                	sd	s0,64(sp)
ffffffffc0201c5a:	fc26                	sd	s1,56(sp)
ffffffffc0201c5c:	f84a                	sd	s2,48(sp)
ffffffffc0201c5e:	f44e                	sd	s3,40(sp)
ffffffffc0201c60:	f052                	sd	s4,32(sp)
ffffffffc0201c62:	ec56                	sd	s5,24(sp)
ffffffffc0201c64:	e85a                	sd	s6,16(sp)
ffffffffc0201c66:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201c68:	c901                	beqz	a0,ffffffffc0201c78 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201c6a:	85aa                	mv	a1,a0
ffffffffc0201c6c:	00001517          	auipc	a0,0x1
ffffffffc0201c70:	03c50513          	addi	a0,a0,60 # ffffffffc0202ca8 <error_string+0xe8>
ffffffffc0201c74:	c4afe0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc0201c78:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201c7a:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201c7c:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201c7e:	4aa9                	li	s5,10
ffffffffc0201c80:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201c82:	00004b97          	auipc	s7,0x4
ffffffffc0201c86:	3a6b8b93          	addi	s7,s7,934 # ffffffffc0206028 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201c8a:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201c8e:	ca8fe0ef          	jal	ra,ffffffffc0200136 <getchar>
ffffffffc0201c92:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201c94:	00054b63          	bltz	a0,ffffffffc0201caa <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201c98:	00a95b63          	ble	a0,s2,ffffffffc0201cae <readline+0x5a>
ffffffffc0201c9c:	029a5463          	ble	s1,s4,ffffffffc0201cc4 <readline+0x70>
        c = getchar();
ffffffffc0201ca0:	c96fe0ef          	jal	ra,ffffffffc0200136 <getchar>
ffffffffc0201ca4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201ca6:	fe0559e3          	bgez	a0,ffffffffc0201c98 <readline+0x44>
            return NULL;
ffffffffc0201caa:	4501                	li	a0,0
ffffffffc0201cac:	a099                	j	ffffffffc0201cf2 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201cae:	03341463          	bne	s0,s3,ffffffffc0201cd6 <readline+0x82>
ffffffffc0201cb2:	e8b9                	bnez	s1,ffffffffc0201d08 <readline+0xb4>
        c = getchar();
ffffffffc0201cb4:	c82fe0ef          	jal	ra,ffffffffc0200136 <getchar>
ffffffffc0201cb8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201cba:	fe0548e3          	bltz	a0,ffffffffc0201caa <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201cbe:	fea958e3          	ble	a0,s2,ffffffffc0201cae <readline+0x5a>
ffffffffc0201cc2:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201cc4:	8522                	mv	a0,s0
ffffffffc0201cc6:	c2cfe0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc0201cca:	009b87b3          	add	a5,s7,s1
ffffffffc0201cce:	00878023          	sb	s0,0(a5)
ffffffffc0201cd2:	2485                	addiw	s1,s1,1
ffffffffc0201cd4:	bf6d                	j	ffffffffc0201c8e <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201cd6:	01540463          	beq	s0,s5,ffffffffc0201cde <readline+0x8a>
ffffffffc0201cda:	fb641ae3          	bne	s0,s6,ffffffffc0201c8e <readline+0x3a>
            cputchar(c);
ffffffffc0201cde:	8522                	mv	a0,s0
ffffffffc0201ce0:	c12fe0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc0201ce4:	00004517          	auipc	a0,0x4
ffffffffc0201ce8:	34450513          	addi	a0,a0,836 # ffffffffc0206028 <edata>
ffffffffc0201cec:	94aa                	add	s1,s1,a0
ffffffffc0201cee:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201cf2:	60a6                	ld	ra,72(sp)
ffffffffc0201cf4:	6406                	ld	s0,64(sp)
ffffffffc0201cf6:	74e2                	ld	s1,56(sp)
ffffffffc0201cf8:	7942                	ld	s2,48(sp)
ffffffffc0201cfa:	79a2                	ld	s3,40(sp)
ffffffffc0201cfc:	7a02                	ld	s4,32(sp)
ffffffffc0201cfe:	6ae2                	ld	s5,24(sp)
ffffffffc0201d00:	6b42                	ld	s6,16(sp)
ffffffffc0201d02:	6ba2                	ld	s7,8(sp)
ffffffffc0201d04:	6161                	addi	sp,sp,80
ffffffffc0201d06:	8082                	ret
            cputchar(c);
ffffffffc0201d08:	4521                	li	a0,8
ffffffffc0201d0a:	be8fe0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc0201d0e:	34fd                	addiw	s1,s1,-1
ffffffffc0201d10:	bfbd                	j	ffffffffc0201c8e <readline+0x3a>

ffffffffc0201d12 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201d12:	00004797          	auipc	a5,0x4
ffffffffc0201d16:	30e78793          	addi	a5,a5,782 # ffffffffc0206020 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201d1a:	6398                	ld	a4,0(a5)
ffffffffc0201d1c:	4781                	li	a5,0
ffffffffc0201d1e:	88ba                	mv	a7,a4
ffffffffc0201d20:	852a                	mv	a0,a0
ffffffffc0201d22:	85be                	mv	a1,a5
ffffffffc0201d24:	863e                	mv	a2,a5
ffffffffc0201d26:	00000073          	ecall
ffffffffc0201d2a:	87aa                	mv	a5,a0
}
ffffffffc0201d2c:	8082                	ret

ffffffffc0201d2e <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201d2e:	00004797          	auipc	a5,0x4
ffffffffc0201d32:	71a78793          	addi	a5,a5,1818 # ffffffffc0206448 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201d36:	6398                	ld	a4,0(a5)
ffffffffc0201d38:	4781                	li	a5,0
ffffffffc0201d3a:	88ba                	mv	a7,a4
ffffffffc0201d3c:	852a                	mv	a0,a0
ffffffffc0201d3e:	85be                	mv	a1,a5
ffffffffc0201d40:	863e                	mv	a2,a5
ffffffffc0201d42:	00000073          	ecall
ffffffffc0201d46:	87aa                	mv	a5,a0
}
ffffffffc0201d48:	8082                	ret

ffffffffc0201d4a <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201d4a:	00004797          	auipc	a5,0x4
ffffffffc0201d4e:	2ce78793          	addi	a5,a5,718 # ffffffffc0206018 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201d52:	639c                	ld	a5,0(a5)
ffffffffc0201d54:	4501                	li	a0,0
ffffffffc0201d56:	88be                	mv	a7,a5
ffffffffc0201d58:	852a                	mv	a0,a0
ffffffffc0201d5a:	85aa                	mv	a1,a0
ffffffffc0201d5c:	862a                	mv	a2,a0
ffffffffc0201d5e:	00000073          	ecall
ffffffffc0201d62:	852a                	mv	a0,a0
ffffffffc0201d64:	2501                	sext.w	a0,a0
ffffffffc0201d66:	8082                	ret

ffffffffc0201d68 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201d68:	c185                	beqz	a1,ffffffffc0201d88 <strnlen+0x20>
ffffffffc0201d6a:	00054783          	lbu	a5,0(a0)
ffffffffc0201d6e:	cf89                	beqz	a5,ffffffffc0201d88 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201d70:	4781                	li	a5,0
ffffffffc0201d72:	a021                	j	ffffffffc0201d7a <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201d74:	00074703          	lbu	a4,0(a4)
ffffffffc0201d78:	c711                	beqz	a4,ffffffffc0201d84 <strnlen+0x1c>
        cnt ++;
ffffffffc0201d7a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201d7c:	00f50733          	add	a4,a0,a5
ffffffffc0201d80:	fef59ae3          	bne	a1,a5,ffffffffc0201d74 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201d84:	853e                	mv	a0,a5
ffffffffc0201d86:	8082                	ret
    size_t cnt = 0;
ffffffffc0201d88:	4781                	li	a5,0
}
ffffffffc0201d8a:	853e                	mv	a0,a5
ffffffffc0201d8c:	8082                	ret

ffffffffc0201d8e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201d8e:	00054783          	lbu	a5,0(a0)
ffffffffc0201d92:	0005c703          	lbu	a4,0(a1) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0201d96:	cb91                	beqz	a5,ffffffffc0201daa <strcmp+0x1c>
ffffffffc0201d98:	00e79c63          	bne	a5,a4,ffffffffc0201db0 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201d9c:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201d9e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201da2:	0585                	addi	a1,a1,1
ffffffffc0201da4:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201da8:	fbe5                	bnez	a5,ffffffffc0201d98 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201daa:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201dac:	9d19                	subw	a0,a0,a4
ffffffffc0201dae:	8082                	ret
ffffffffc0201db0:	0007851b          	sext.w	a0,a5
ffffffffc0201db4:	9d19                	subw	a0,a0,a4
ffffffffc0201db6:	8082                	ret

ffffffffc0201db8 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201db8:	00054783          	lbu	a5,0(a0)
ffffffffc0201dbc:	cb91                	beqz	a5,ffffffffc0201dd0 <strchr+0x18>
        if (*s == c) {
ffffffffc0201dbe:	00b79563          	bne	a5,a1,ffffffffc0201dc8 <strchr+0x10>
ffffffffc0201dc2:	a809                	j	ffffffffc0201dd4 <strchr+0x1c>
ffffffffc0201dc4:	00b78763          	beq	a5,a1,ffffffffc0201dd2 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201dc8:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201dca:	00054783          	lbu	a5,0(a0)
ffffffffc0201dce:	fbfd                	bnez	a5,ffffffffc0201dc4 <strchr+0xc>
    }
    return NULL;
ffffffffc0201dd0:	4501                	li	a0,0
}
ffffffffc0201dd2:	8082                	ret
ffffffffc0201dd4:	8082                	ret

ffffffffc0201dd6 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201dd6:	ca01                	beqz	a2,ffffffffc0201de6 <memset+0x10>
ffffffffc0201dd8:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201dda:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201ddc:	0785                	addi	a5,a5,1
ffffffffc0201dde:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201de2:	fec79de3          	bne	a5,a2,ffffffffc0201ddc <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201de6:	8082                	ret
