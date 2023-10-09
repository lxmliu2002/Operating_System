
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020d2b7          	lui	t0,0xc020d
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
ffffffffc0200028:	c020d137          	lui	sp,0xc020d

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
static void lab1_switch_test(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	000d4517          	auipc	a0,0xd4
ffffffffc020003a:	e1a50513          	addi	a0,a0,-486 # ffffffffc02d3e50 <edata>
ffffffffc020003e:	000df617          	auipc	a2,0xdf
ffffffffc0200042:	52260613          	addi	a2,a2,1314 # ffffffffc02df560 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	488070ef          	jal	ra,ffffffffc02074d6 <memset>
    cons_init();                // init the console
ffffffffc0200052:	52e000ef          	jal	ra,ffffffffc0200580 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00007597          	auipc	a1,0x7
ffffffffc020005a:	4aa58593          	addi	a1,a1,1194 # ffffffffc0207500 <etext>
ffffffffc020005e:	00007517          	auipc	a0,0x7
ffffffffc0200062:	4c250513          	addi	a0,a0,1218 # ffffffffc0207520 <etext+0x20>
ffffffffc0200066:	12c000ef          	jal	ra,ffffffffc0200192 <cprintf>

    print_kerninfo();
ffffffffc020006a:	1b0000ef          	jal	ra,ffffffffc020021a <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	5a6020ef          	jal	ra,ffffffffc0202614 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5e6000ef          	jal	ra,ffffffffc0200658 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5e4000ef          	jal	ra,ffffffffc020065a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	3ce040ef          	jal	ra,ffffffffc0204448 <vmm_init>
    sched_init();
ffffffffc020007e:	231060ef          	jal	ra,ffffffffc0206aae <sched_init>
    proc_init();                // init process table
ffffffffc0200082:	6b6060ef          	jal	ra,ffffffffc0206738 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200086:	56e000ef          	jal	ra,ffffffffc02005f4 <ide_init>
    swap_init();                // init swap
ffffffffc020008a:	2e2030ef          	jal	ra,ffffffffc020336c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008e:	4a8000ef          	jal	ra,ffffffffc0200536 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc0200092:	5ba000ef          	jal	ra,ffffffffc020064c <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
        
    cpu_idle();                 // run idle process
ffffffffc0200096:	7ee060ef          	jal	ra,ffffffffc0206884 <cpu_idle>

ffffffffc020009a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020009a:	715d                	addi	sp,sp,-80
ffffffffc020009c:	e486                	sd	ra,72(sp)
ffffffffc020009e:	e0a2                	sd	s0,64(sp)
ffffffffc02000a0:	fc26                	sd	s1,56(sp)
ffffffffc02000a2:	f84a                	sd	s2,48(sp)
ffffffffc02000a4:	f44e                	sd	s3,40(sp)
ffffffffc02000a6:	f052                	sd	s4,32(sp)
ffffffffc02000a8:	ec56                	sd	s5,24(sp)
ffffffffc02000aa:	e85a                	sd	s6,16(sp)
ffffffffc02000ac:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02000ae:	c901                	beqz	a0,ffffffffc02000be <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02000b0:	85aa                	mv	a1,a0
ffffffffc02000b2:	00007517          	auipc	a0,0x7
ffffffffc02000b6:	47650513          	addi	a0,a0,1142 # ffffffffc0207528 <etext+0x28>
ffffffffc02000ba:	0d8000ef          	jal	ra,ffffffffc0200192 <cprintf>
readline(const char *prompt) {
ffffffffc02000be:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c0:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000c2:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000c4:	4aa9                	li	s5,10
ffffffffc02000c6:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000c8:	000d4b97          	auipc	s7,0xd4
ffffffffc02000cc:	d88b8b93          	addi	s7,s7,-632 # ffffffffc02d3e50 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d0:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d4:	136000ef          	jal	ra,ffffffffc020020a <getchar>
ffffffffc02000d8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000da:	00054b63          	bltz	a0,ffffffffc02000f0 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000de:	00a95b63          	ble	a0,s2,ffffffffc02000f4 <readline+0x5a>
ffffffffc02000e2:	029a5463          	ble	s1,s4,ffffffffc020010a <readline+0x70>
        c = getchar();
ffffffffc02000e6:	124000ef          	jal	ra,ffffffffc020020a <getchar>
ffffffffc02000ea:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000ec:	fe0559e3          	bgez	a0,ffffffffc02000de <readline+0x44>
            return NULL;
ffffffffc02000f0:	4501                	li	a0,0
ffffffffc02000f2:	a099                	j	ffffffffc0200138 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02000f4:	03341463          	bne	s0,s3,ffffffffc020011c <readline+0x82>
ffffffffc02000f8:	e8b9                	bnez	s1,ffffffffc020014e <readline+0xb4>
        c = getchar();
ffffffffc02000fa:	110000ef          	jal	ra,ffffffffc020020a <getchar>
ffffffffc02000fe:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200100:	fe0548e3          	bltz	a0,ffffffffc02000f0 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200104:	fea958e3          	ble	a0,s2,ffffffffc02000f4 <readline+0x5a>
ffffffffc0200108:	4481                	li	s1,0
            cputchar(c);
ffffffffc020010a:	8522                	mv	a0,s0
ffffffffc020010c:	0ba000ef          	jal	ra,ffffffffc02001c6 <cputchar>
            buf[i ++] = c;
ffffffffc0200110:	009b87b3          	add	a5,s7,s1
ffffffffc0200114:	00878023          	sb	s0,0(a5)
ffffffffc0200118:	2485                	addiw	s1,s1,1
ffffffffc020011a:	bf6d                	j	ffffffffc02000d4 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc020011c:	01540463          	beq	s0,s5,ffffffffc0200124 <readline+0x8a>
ffffffffc0200120:	fb641ae3          	bne	s0,s6,ffffffffc02000d4 <readline+0x3a>
            cputchar(c);
ffffffffc0200124:	8522                	mv	a0,s0
ffffffffc0200126:	0a0000ef          	jal	ra,ffffffffc02001c6 <cputchar>
            buf[i] = '\0';
ffffffffc020012a:	000d4517          	auipc	a0,0xd4
ffffffffc020012e:	d2650513          	addi	a0,a0,-730 # ffffffffc02d3e50 <edata>
ffffffffc0200132:	94aa                	add	s1,s1,a0
ffffffffc0200134:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200138:	60a6                	ld	ra,72(sp)
ffffffffc020013a:	6406                	ld	s0,64(sp)
ffffffffc020013c:	74e2                	ld	s1,56(sp)
ffffffffc020013e:	7942                	ld	s2,48(sp)
ffffffffc0200140:	79a2                	ld	s3,40(sp)
ffffffffc0200142:	7a02                	ld	s4,32(sp)
ffffffffc0200144:	6ae2                	ld	s5,24(sp)
ffffffffc0200146:	6b42                	ld	s6,16(sp)
ffffffffc0200148:	6ba2                	ld	s7,8(sp)
ffffffffc020014a:	6161                	addi	sp,sp,80
ffffffffc020014c:	8082                	ret
            cputchar(c);
ffffffffc020014e:	4521                	li	a0,8
ffffffffc0200150:	076000ef          	jal	ra,ffffffffc02001c6 <cputchar>
            i --;
ffffffffc0200154:	34fd                	addiw	s1,s1,-1
ffffffffc0200156:	bfbd                	j	ffffffffc02000d4 <readline+0x3a>

ffffffffc0200158 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200158:	1141                	addi	sp,sp,-16
ffffffffc020015a:	e022                	sd	s0,0(sp)
ffffffffc020015c:	e406                	sd	ra,8(sp)
ffffffffc020015e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200160:	422000ef          	jal	ra,ffffffffc0200582 <cons_putc>
    (*cnt) ++;
ffffffffc0200164:	401c                	lw	a5,0(s0)
}
ffffffffc0200166:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200168:	2785                	addiw	a5,a5,1
ffffffffc020016a:	c01c                	sw	a5,0(s0)
}
ffffffffc020016c:	6402                	ld	s0,0(sp)
ffffffffc020016e:	0141                	addi	sp,sp,16
ffffffffc0200170:	8082                	ret

ffffffffc0200172 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200172:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200174:	86ae                	mv	a3,a1
ffffffffc0200176:	862a                	mv	a2,a0
ffffffffc0200178:	006c                	addi	a1,sp,12
ffffffffc020017a:	00000517          	auipc	a0,0x0
ffffffffc020017e:	fde50513          	addi	a0,a0,-34 # ffffffffc0200158 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200182:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200184:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200186:	727060ef          	jal	ra,ffffffffc02070ac <vprintfmt>
    return cnt;
}
ffffffffc020018a:	60e2                	ld	ra,24(sp)
ffffffffc020018c:	4532                	lw	a0,12(sp)
ffffffffc020018e:	6105                	addi	sp,sp,32
ffffffffc0200190:	8082                	ret

ffffffffc0200192 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200192:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200194:	02810313          	addi	t1,sp,40 # ffffffffc020d028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200198:	f42e                	sd	a1,40(sp)
ffffffffc020019a:	f832                	sd	a2,48(sp)
ffffffffc020019c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020019e:	862a                	mv	a2,a0
ffffffffc02001a0:	004c                	addi	a1,sp,4
ffffffffc02001a2:	00000517          	auipc	a0,0x0
ffffffffc02001a6:	fb650513          	addi	a0,a0,-74 # ffffffffc0200158 <cputch>
ffffffffc02001aa:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02001ac:	ec06                	sd	ra,24(sp)
ffffffffc02001ae:	e0ba                	sd	a4,64(sp)
ffffffffc02001b0:	e4be                	sd	a5,72(sp)
ffffffffc02001b2:	e8c2                	sd	a6,80(sp)
ffffffffc02001b4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001b6:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001b8:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001ba:	6f3060ef          	jal	ra,ffffffffc02070ac <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001be:	60e2                	ld	ra,24(sp)
ffffffffc02001c0:	4512                	lw	a0,4(sp)
ffffffffc02001c2:	6125                	addi	sp,sp,96
ffffffffc02001c4:	8082                	ret

ffffffffc02001c6 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001c6:	3bc0006f          	j	ffffffffc0200582 <cons_putc>

ffffffffc02001ca <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001ca:	1101                	addi	sp,sp,-32
ffffffffc02001cc:	e822                	sd	s0,16(sp)
ffffffffc02001ce:	ec06                	sd	ra,24(sp)
ffffffffc02001d0:	e426                	sd	s1,8(sp)
ffffffffc02001d2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001d4:	00054503          	lbu	a0,0(a0)
ffffffffc02001d8:	c51d                	beqz	a0,ffffffffc0200206 <cputs+0x3c>
ffffffffc02001da:	0405                	addi	s0,s0,1
ffffffffc02001dc:	4485                	li	s1,1
ffffffffc02001de:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001e0:	3a2000ef          	jal	ra,ffffffffc0200582 <cons_putc>
    (*cnt) ++;
ffffffffc02001e4:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc02001e8:	0405                	addi	s0,s0,1
ffffffffc02001ea:	fff44503          	lbu	a0,-1(s0)
ffffffffc02001ee:	f96d                	bnez	a0,ffffffffc02001e0 <cputs+0x16>
ffffffffc02001f0:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001f4:	4529                	li	a0,10
ffffffffc02001f6:	38c000ef          	jal	ra,ffffffffc0200582 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001fa:	8522                	mv	a0,s0
ffffffffc02001fc:	60e2                	ld	ra,24(sp)
ffffffffc02001fe:	6442                	ld	s0,16(sp)
ffffffffc0200200:	64a2                	ld	s1,8(sp)
ffffffffc0200202:	6105                	addi	sp,sp,32
ffffffffc0200204:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200206:	4405                	li	s0,1
ffffffffc0200208:	b7f5                	j	ffffffffc02001f4 <cputs+0x2a>

ffffffffc020020a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020020a:	1141                	addi	sp,sp,-16
ffffffffc020020c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020020e:	3aa000ef          	jal	ra,ffffffffc02005b8 <cons_getc>
ffffffffc0200212:	dd75                	beqz	a0,ffffffffc020020e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200214:	60a2                	ld	ra,8(sp)
ffffffffc0200216:	0141                	addi	sp,sp,16
ffffffffc0200218:	8082                	ret

ffffffffc020021a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020021a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020021c:	00007517          	auipc	a0,0x7
ffffffffc0200220:	34450513          	addi	a0,a0,836 # ffffffffc0207560 <etext+0x60>
void print_kerninfo(void) {
ffffffffc0200224:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200226:	f6dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020022a:	00000597          	auipc	a1,0x0
ffffffffc020022e:	e0c58593          	addi	a1,a1,-500 # ffffffffc0200036 <kern_init>
ffffffffc0200232:	00007517          	auipc	a0,0x7
ffffffffc0200236:	34e50513          	addi	a0,a0,846 # ffffffffc0207580 <etext+0x80>
ffffffffc020023a:	f59ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020023e:	00007597          	auipc	a1,0x7
ffffffffc0200242:	2c258593          	addi	a1,a1,706 # ffffffffc0207500 <etext>
ffffffffc0200246:	00007517          	auipc	a0,0x7
ffffffffc020024a:	35a50513          	addi	a0,a0,858 # ffffffffc02075a0 <etext+0xa0>
ffffffffc020024e:	f45ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200252:	000d4597          	auipc	a1,0xd4
ffffffffc0200256:	bfe58593          	addi	a1,a1,-1026 # ffffffffc02d3e50 <edata>
ffffffffc020025a:	00007517          	auipc	a0,0x7
ffffffffc020025e:	36650513          	addi	a0,a0,870 # ffffffffc02075c0 <etext+0xc0>
ffffffffc0200262:	f31ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200266:	000df597          	auipc	a1,0xdf
ffffffffc020026a:	2fa58593          	addi	a1,a1,762 # ffffffffc02df560 <end>
ffffffffc020026e:	00007517          	auipc	a0,0x7
ffffffffc0200272:	37250513          	addi	a0,a0,882 # ffffffffc02075e0 <etext+0xe0>
ffffffffc0200276:	f1dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020027a:	000df597          	auipc	a1,0xdf
ffffffffc020027e:	6e558593          	addi	a1,a1,1765 # ffffffffc02df95f <end+0x3ff>
ffffffffc0200282:	00000797          	auipc	a5,0x0
ffffffffc0200286:	db478793          	addi	a5,a5,-588 # ffffffffc0200036 <kern_init>
ffffffffc020028a:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020028e:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200292:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200294:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200298:	95be                	add	a1,a1,a5
ffffffffc020029a:	85a9                	srai	a1,a1,0xa
ffffffffc020029c:	00007517          	auipc	a0,0x7
ffffffffc02002a0:	36450513          	addi	a0,a0,868 # ffffffffc0207600 <etext+0x100>
}
ffffffffc02002a4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a6:	eedff06f          	j	ffffffffc0200192 <cprintf>

ffffffffc02002aa <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002aa:	1141                	addi	sp,sp,-16
     * and line number, etc.
     *    (3.5) popup a calling stackframe
     *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
     *                   the calling funciton's ebp = ss:[ebp]
     */
    panic("Not Implemented!");
ffffffffc02002ac:	00007617          	auipc	a2,0x7
ffffffffc02002b0:	28460613          	addi	a2,a2,644 # ffffffffc0207530 <etext+0x30>
ffffffffc02002b4:	05b00593          	li	a1,91
ffffffffc02002b8:	00007517          	auipc	a0,0x7
ffffffffc02002bc:	29050513          	addi	a0,a0,656 # ffffffffc0207548 <etext+0x48>
void print_stackframe(void) {
ffffffffc02002c0:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002c2:	1c6000ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02002c6 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002c6:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002c8:	00007617          	auipc	a2,0x7
ffffffffc02002cc:	44860613          	addi	a2,a2,1096 # ffffffffc0207710 <commands+0xe0>
ffffffffc02002d0:	00007597          	auipc	a1,0x7
ffffffffc02002d4:	46058593          	addi	a1,a1,1120 # ffffffffc0207730 <commands+0x100>
ffffffffc02002d8:	00007517          	auipc	a0,0x7
ffffffffc02002dc:	46050513          	addi	a0,a0,1120 # ffffffffc0207738 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e0:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e2:	eb1ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc02002e6:	00007617          	auipc	a2,0x7
ffffffffc02002ea:	46260613          	addi	a2,a2,1122 # ffffffffc0207748 <commands+0x118>
ffffffffc02002ee:	00007597          	auipc	a1,0x7
ffffffffc02002f2:	48258593          	addi	a1,a1,1154 # ffffffffc0207770 <commands+0x140>
ffffffffc02002f6:	00007517          	auipc	a0,0x7
ffffffffc02002fa:	44250513          	addi	a0,a0,1090 # ffffffffc0207738 <commands+0x108>
ffffffffc02002fe:	e95ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0200302:	00007617          	auipc	a2,0x7
ffffffffc0200306:	47e60613          	addi	a2,a2,1150 # ffffffffc0207780 <commands+0x150>
ffffffffc020030a:	00007597          	auipc	a1,0x7
ffffffffc020030e:	49658593          	addi	a1,a1,1174 # ffffffffc02077a0 <commands+0x170>
ffffffffc0200312:	00007517          	auipc	a0,0x7
ffffffffc0200316:	42650513          	addi	a0,a0,1062 # ffffffffc0207738 <commands+0x108>
ffffffffc020031a:	e79ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    }
    return 0;
}
ffffffffc020031e:	60a2                	ld	ra,8(sp)
ffffffffc0200320:	4501                	li	a0,0
ffffffffc0200322:	0141                	addi	sp,sp,16
ffffffffc0200324:	8082                	ret

ffffffffc0200326 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200326:	1141                	addi	sp,sp,-16
ffffffffc0200328:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020032a:	ef1ff0ef          	jal	ra,ffffffffc020021a <print_kerninfo>
    return 0;
}
ffffffffc020032e:	60a2                	ld	ra,8(sp)
ffffffffc0200330:	4501                	li	a0,0
ffffffffc0200332:	0141                	addi	sp,sp,16
ffffffffc0200334:	8082                	ret

ffffffffc0200336 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200336:	1141                	addi	sp,sp,-16
ffffffffc0200338:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020033a:	f71ff0ef          	jal	ra,ffffffffc02002aa <print_stackframe>
    return 0;
}
ffffffffc020033e:	60a2                	ld	ra,8(sp)
ffffffffc0200340:	4501                	li	a0,0
ffffffffc0200342:	0141                	addi	sp,sp,16
ffffffffc0200344:	8082                	ret

ffffffffc0200346 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200346:	7115                	addi	sp,sp,-224
ffffffffc0200348:	e962                	sd	s8,144(sp)
ffffffffc020034a:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020034c:	00007517          	auipc	a0,0x7
ffffffffc0200350:	32c50513          	addi	a0,a0,812 # ffffffffc0207678 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200354:	ed86                	sd	ra,216(sp)
ffffffffc0200356:	e9a2                	sd	s0,208(sp)
ffffffffc0200358:	e5a6                	sd	s1,200(sp)
ffffffffc020035a:	e1ca                	sd	s2,192(sp)
ffffffffc020035c:	fd4e                	sd	s3,184(sp)
ffffffffc020035e:	f952                	sd	s4,176(sp)
ffffffffc0200360:	f556                	sd	s5,168(sp)
ffffffffc0200362:	f15a                	sd	s6,160(sp)
ffffffffc0200364:	ed5e                	sd	s7,152(sp)
ffffffffc0200366:	e566                	sd	s9,136(sp)
ffffffffc0200368:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020036a:	e29ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020036e:	00007517          	auipc	a0,0x7
ffffffffc0200372:	33250513          	addi	a0,a0,818 # ffffffffc02076a0 <commands+0x70>
ffffffffc0200376:	e1dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    if (tf != NULL) {
ffffffffc020037a:	000c0563          	beqz	s8,ffffffffc0200384 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037e:	8562                	mv	a0,s8
ffffffffc0200380:	4c2000ef          	jal	ra,ffffffffc0200842 <print_trapframe>
ffffffffc0200384:	00007c97          	auipc	s9,0x7
ffffffffc0200388:	2acc8c93          	addi	s9,s9,684 # ffffffffc0207630 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020038c:	00007997          	auipc	s3,0x7
ffffffffc0200390:	33c98993          	addi	s3,s3,828 # ffffffffc02076c8 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200394:	00007917          	auipc	s2,0x7
ffffffffc0200398:	33c90913          	addi	s2,s2,828 # ffffffffc02076d0 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc020039c:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039e:	00007b17          	auipc	s6,0x7
ffffffffc02003a2:	33ab0b13          	addi	s6,s6,826 # ffffffffc02076d8 <commands+0xa8>
    if (argc == 0) {
ffffffffc02003a6:	00007a97          	auipc	s5,0x7
ffffffffc02003aa:	38aa8a93          	addi	s5,s5,906 # ffffffffc0207730 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ae:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003b0:	854e                	mv	a0,s3
ffffffffc02003b2:	ce9ff0ef          	jal	ra,ffffffffc020009a <readline>
ffffffffc02003b6:	842a                	mv	s0,a0
ffffffffc02003b8:	dd65                	beqz	a0,ffffffffc02003b0 <kmonitor+0x6a>
ffffffffc02003ba:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003be:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003c0:	c999                	beqz	a1,ffffffffc02003d6 <kmonitor+0x90>
ffffffffc02003c2:	854a                	mv	a0,s2
ffffffffc02003c4:	0f4070ef          	jal	ra,ffffffffc02074b8 <strchr>
ffffffffc02003c8:	c925                	beqz	a0,ffffffffc0200438 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02003ca:	00144583          	lbu	a1,1(s0)
ffffffffc02003ce:	00040023          	sb	zero,0(s0)
ffffffffc02003d2:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003d4:	f5fd                	bnez	a1,ffffffffc02003c2 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02003d6:	dce9                	beqz	s1,ffffffffc02003b0 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d8:	6582                	ld	a1,0(sp)
ffffffffc02003da:	00007d17          	auipc	s10,0x7
ffffffffc02003de:	256d0d13          	addi	s10,s10,598 # ffffffffc0207630 <commands>
    if (argc == 0) {
ffffffffc02003e2:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e4:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003e6:	0d61                	addi	s10,s10,24
ffffffffc02003e8:	0a6070ef          	jal	ra,ffffffffc020748e <strcmp>
ffffffffc02003ec:	c919                	beqz	a0,ffffffffc0200402 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ee:	2405                	addiw	s0,s0,1
ffffffffc02003f0:	09740463          	beq	s0,s7,ffffffffc0200478 <kmonitor+0x132>
ffffffffc02003f4:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f8:	6582                	ld	a1,0(sp)
ffffffffc02003fa:	0d61                	addi	s10,s10,24
ffffffffc02003fc:	092070ef          	jal	ra,ffffffffc020748e <strcmp>
ffffffffc0200400:	f57d                	bnez	a0,ffffffffc02003ee <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200402:	00141793          	slli	a5,s0,0x1
ffffffffc0200406:	97a2                	add	a5,a5,s0
ffffffffc0200408:	078e                	slli	a5,a5,0x3
ffffffffc020040a:	97e6                	add	a5,a5,s9
ffffffffc020040c:	6b9c                	ld	a5,16(a5)
ffffffffc020040e:	8662                	mv	a2,s8
ffffffffc0200410:	002c                	addi	a1,sp,8
ffffffffc0200412:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200416:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200418:	f8055ce3          	bgez	a0,ffffffffc02003b0 <kmonitor+0x6a>
}
ffffffffc020041c:	60ee                	ld	ra,216(sp)
ffffffffc020041e:	644e                	ld	s0,208(sp)
ffffffffc0200420:	64ae                	ld	s1,200(sp)
ffffffffc0200422:	690e                	ld	s2,192(sp)
ffffffffc0200424:	79ea                	ld	s3,184(sp)
ffffffffc0200426:	7a4a                	ld	s4,176(sp)
ffffffffc0200428:	7aaa                	ld	s5,168(sp)
ffffffffc020042a:	7b0a                	ld	s6,160(sp)
ffffffffc020042c:	6bea                	ld	s7,152(sp)
ffffffffc020042e:	6c4a                	ld	s8,144(sp)
ffffffffc0200430:	6caa                	ld	s9,136(sp)
ffffffffc0200432:	6d0a                	ld	s10,128(sp)
ffffffffc0200434:	612d                	addi	sp,sp,224
ffffffffc0200436:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200438:	00044783          	lbu	a5,0(s0)
ffffffffc020043c:	dfc9                	beqz	a5,ffffffffc02003d6 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020043e:	03448863          	beq	s1,s4,ffffffffc020046e <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200442:	00349793          	slli	a5,s1,0x3
ffffffffc0200446:	0118                	addi	a4,sp,128
ffffffffc0200448:	97ba                	add	a5,a5,a4
ffffffffc020044a:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044e:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200452:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200454:	e591                	bnez	a1,ffffffffc0200460 <kmonitor+0x11a>
ffffffffc0200456:	b749                	j	ffffffffc02003d8 <kmonitor+0x92>
            buf ++;
ffffffffc0200458:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020045a:	00044583          	lbu	a1,0(s0)
ffffffffc020045e:	ddad                	beqz	a1,ffffffffc02003d8 <kmonitor+0x92>
ffffffffc0200460:	854a                	mv	a0,s2
ffffffffc0200462:	056070ef          	jal	ra,ffffffffc02074b8 <strchr>
ffffffffc0200466:	d96d                	beqz	a0,ffffffffc0200458 <kmonitor+0x112>
ffffffffc0200468:	00044583          	lbu	a1,0(s0)
ffffffffc020046c:	bf91                	j	ffffffffc02003c0 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020046e:	45c1                	li	a1,16
ffffffffc0200470:	855a                	mv	a0,s6
ffffffffc0200472:	d21ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0200476:	b7f1                	j	ffffffffc0200442 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200478:	6582                	ld	a1,0(sp)
ffffffffc020047a:	00007517          	auipc	a0,0x7
ffffffffc020047e:	27e50513          	addi	a0,a0,638 # ffffffffc02076f8 <commands+0xc8>
ffffffffc0200482:	d11ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    return 0;
ffffffffc0200486:	b72d                	j	ffffffffc02003b0 <kmonitor+0x6a>

ffffffffc0200488 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200488:	000df317          	auipc	t1,0xdf
ffffffffc020048c:	df830313          	addi	t1,t1,-520 # ffffffffc02df280 <is_panic>
ffffffffc0200490:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200494:	715d                	addi	sp,sp,-80
ffffffffc0200496:	ec06                	sd	ra,24(sp)
ffffffffc0200498:	e822                	sd	s0,16(sp)
ffffffffc020049a:	f436                	sd	a3,40(sp)
ffffffffc020049c:	f83a                	sd	a4,48(sp)
ffffffffc020049e:	fc3e                	sd	a5,56(sp)
ffffffffc02004a0:	e0c2                	sd	a6,64(sp)
ffffffffc02004a2:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02004a4:	02031c63          	bnez	t1,ffffffffc02004dc <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02004a8:	4785                	li	a5,1
ffffffffc02004aa:	8432                	mv	s0,a2
ffffffffc02004ac:	000df717          	auipc	a4,0xdf
ffffffffc02004b0:	dcf73a23          	sd	a5,-556(a4) # ffffffffc02df280 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b4:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02004b6:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b8:	85aa                	mv	a1,a0
ffffffffc02004ba:	00007517          	auipc	a0,0x7
ffffffffc02004be:	2f650513          	addi	a0,a0,758 # ffffffffc02077b0 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02004c2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004c4:	ccfff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004c8:	65a2                	ld	a1,8(sp)
ffffffffc02004ca:	8522                	mv	a0,s0
ffffffffc02004cc:	ca7ff0ef          	jal	ra,ffffffffc0200172 <vcprintf>
    cprintf("\n");
ffffffffc02004d0:	00008517          	auipc	a0,0x8
ffffffffc02004d4:	29850513          	addi	a0,a0,664 # ffffffffc0208768 <default_pmm_manager+0x530>
ffffffffc02004d8:	cbbff0ef          	jal	ra,ffffffffc0200192 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004dc:	4501                	li	a0,0
ffffffffc02004de:	4581                	li	a1,0
ffffffffc02004e0:	4601                	li	a2,0
ffffffffc02004e2:	48a1                	li	a7,8
ffffffffc02004e4:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004e8:	16a000ef          	jal	ra,ffffffffc0200652 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004ec:	4501                	li	a0,0
ffffffffc02004ee:	e59ff0ef          	jal	ra,ffffffffc0200346 <kmonitor>
ffffffffc02004f2:	bfed                	j	ffffffffc02004ec <__panic+0x64>

ffffffffc02004f4 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004f4:	715d                	addi	sp,sp,-80
ffffffffc02004f6:	e822                	sd	s0,16(sp)
ffffffffc02004f8:	fc3e                	sd	a5,56(sp)
ffffffffc02004fa:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004fc:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004fe:	862e                	mv	a2,a1
ffffffffc0200500:	85aa                	mv	a1,a0
ffffffffc0200502:	00007517          	auipc	a0,0x7
ffffffffc0200506:	2ce50513          	addi	a0,a0,718 # ffffffffc02077d0 <commands+0x1a0>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc020050a:	ec06                	sd	ra,24(sp)
ffffffffc020050c:	f436                	sd	a3,40(sp)
ffffffffc020050e:	f83a                	sd	a4,48(sp)
ffffffffc0200510:	e0c2                	sd	a6,64(sp)
ffffffffc0200512:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200514:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200516:	c7dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020051a:	65a2                	ld	a1,8(sp)
ffffffffc020051c:	8522                	mv	a0,s0
ffffffffc020051e:	c55ff0ef          	jal	ra,ffffffffc0200172 <vcprintf>
    cprintf("\n");
ffffffffc0200522:	00008517          	auipc	a0,0x8
ffffffffc0200526:	24650513          	addi	a0,a0,582 # ffffffffc0208768 <default_pmm_manager+0x530>
ffffffffc020052a:	c69ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    va_end(ap);
}
ffffffffc020052e:	60e2                	ld	ra,24(sp)
ffffffffc0200530:	6442                	ld	s0,16(sp)
ffffffffc0200532:	6161                	addi	sp,sp,80
ffffffffc0200534:	8082                	ret

ffffffffc0200536 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    set_csr(sie, MIP_STIP);
ffffffffc0200536:	02000793          	li	a5,32
ffffffffc020053a:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020053e:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200542:	67e1                	lui	a5,0x18
ffffffffc0200544:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xca70>
ffffffffc0200548:	953e                	add	a0,a0,a5
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020054a:	4581                	li	a1,0
ffffffffc020054c:	4601                	li	a2,0
ffffffffc020054e:	4881                	li	a7,0
ffffffffc0200550:	00000073          	ecall
    cprintf("++ setup timer interrupts\n");
ffffffffc0200554:	00007517          	auipc	a0,0x7
ffffffffc0200558:	29c50513          	addi	a0,a0,668 # ffffffffc02077f0 <commands+0x1c0>
    ticks = 0;
ffffffffc020055c:	000df797          	auipc	a5,0xdf
ffffffffc0200560:	d807b223          	sd	zero,-636(a5) # ffffffffc02df2e0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200564:	c2fff06f          	j	ffffffffc0200192 <cprintf>

ffffffffc0200568 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200568:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020056c:	67e1                	lui	a5,0x18
ffffffffc020056e:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xca70>
ffffffffc0200572:	953e                	add	a0,a0,a5
ffffffffc0200574:	4581                	li	a1,0
ffffffffc0200576:	4601                	li	a2,0
ffffffffc0200578:	4881                	li	a7,0
ffffffffc020057a:	00000073          	ecall
ffffffffc020057e:	8082                	ret

ffffffffc0200580 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <cons_putc>:
#include <riscv.h>
#include <assert.h>
#include <atomic.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200582:	100027f3          	csrr	a5,sstatus
ffffffffc0200586:	8b89                	andi	a5,a5,2
ffffffffc0200588:	0ff57513          	andi	a0,a0,255
ffffffffc020058c:	e799                	bnez	a5,ffffffffc020059a <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020058e:	4581                	li	a1,0
ffffffffc0200590:	4601                	li	a2,0
ffffffffc0200592:	4885                	li	a7,1
ffffffffc0200594:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200598:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020059a:	1101                	addi	sp,sp,-32
ffffffffc020059c:	ec06                	sd	ra,24(sp)
ffffffffc020059e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005a0:	0b2000ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc02005a4:	6522                	ld	a0,8(sp)
ffffffffc02005a6:	4581                	li	a1,0
ffffffffc02005a8:	4601                	li	a2,0
ffffffffc02005aa:	4885                	li	a7,1
ffffffffc02005ac:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005b0:	60e2                	ld	ra,24(sp)
ffffffffc02005b2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005b4:	0980006f          	j	ffffffffc020064c <intr_enable>

ffffffffc02005b8 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005b8:	100027f3          	csrr	a5,sstatus
ffffffffc02005bc:	8b89                	andi	a5,a5,2
ffffffffc02005be:	eb89                	bnez	a5,ffffffffc02005d0 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005c0:	4501                	li	a0,0
ffffffffc02005c2:	4581                	li	a1,0
ffffffffc02005c4:	4601                	li	a2,0
ffffffffc02005c6:	4889                	li	a7,2
ffffffffc02005c8:	00000073          	ecall
ffffffffc02005cc:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005ce:	8082                	ret
int cons_getc(void) {
ffffffffc02005d0:	1101                	addi	sp,sp,-32
ffffffffc02005d2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005d4:	07e000ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc02005d8:	4501                	li	a0,0
ffffffffc02005da:	4581                	li	a1,0
ffffffffc02005dc:	4601                	li	a2,0
ffffffffc02005de:	4889                	li	a7,2
ffffffffc02005e0:	00000073          	ecall
ffffffffc02005e4:	2501                	sext.w	a0,a0
ffffffffc02005e6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005e8:	064000ef          	jal	ra,ffffffffc020064c <intr_enable>
}
ffffffffc02005ec:	60e2                	ld	ra,24(sp)
ffffffffc02005ee:	6522                	ld	a0,8(sp)
ffffffffc02005f0:	6105                	addi	sp,sp,32
ffffffffc02005f2:	8082                	ret

ffffffffc02005f4 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005f4:	8082                	ret

ffffffffc02005f6 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005f6:	00253513          	sltiu	a0,a0,2
ffffffffc02005fa:	8082                	ret

ffffffffc02005fc <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02005fc:	03800513          	li	a0,56
ffffffffc0200600:	8082                	ret

ffffffffc0200602 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200602:	000d4797          	auipc	a5,0xd4
ffffffffc0200606:	c4e78793          	addi	a5,a5,-946 # ffffffffc02d4250 <ide>
ffffffffc020060a:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc020060e:	1141                	addi	sp,sp,-16
ffffffffc0200610:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200612:	95be                	add	a1,a1,a5
ffffffffc0200614:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200618:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020061a:	6cf060ef          	jal	ra,ffffffffc02074e8 <memcpy>
    return 0;
}
ffffffffc020061e:	60a2                	ld	ra,8(sp)
ffffffffc0200620:	4501                	li	a0,0
ffffffffc0200622:	0141                	addi	sp,sp,16
ffffffffc0200624:	8082                	ret

ffffffffc0200626 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200626:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200628:	0095979b          	slliw	a5,a1,0x9
ffffffffc020062c:	000d4517          	auipc	a0,0xd4
ffffffffc0200630:	c2450513          	addi	a0,a0,-988 # ffffffffc02d4250 <ide>
                   size_t nsecs) {
ffffffffc0200634:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200636:	00969613          	slli	a2,a3,0x9
ffffffffc020063a:	85ba                	mv	a1,a4
ffffffffc020063c:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020063e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200640:	6a9060ef          	jal	ra,ffffffffc02074e8 <memcpy>
    return 0;
}
ffffffffc0200644:	60a2                	ld	ra,8(sp)
ffffffffc0200646:	4501                	li	a0,0
ffffffffc0200648:	0141                	addi	sp,sp,16
ffffffffc020064a:	8082                	ret

ffffffffc020064c <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020064c:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200650:	8082                	ret

ffffffffc0200652 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200652:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200656:	8082                	ret

ffffffffc0200658 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200658:	8082                	ret

ffffffffc020065a <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020065a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020065e:	00000797          	auipc	a5,0x0
ffffffffc0200662:	66278793          	addi	a5,a5,1634 # ffffffffc0200cc0 <__alltraps>
ffffffffc0200666:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020066a:	000407b7          	lui	a5,0x40
ffffffffc020066e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200672:	8082                	ret

ffffffffc0200674 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200674:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200676:	1141                	addi	sp,sp,-16
ffffffffc0200678:	e022                	sd	s0,0(sp)
ffffffffc020067a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	00007517          	auipc	a0,0x7
ffffffffc0200680:	4bc50513          	addi	a0,a0,1212 # ffffffffc0207b38 <commands+0x508>
void print_regs(struct pushregs* gpr) {
ffffffffc0200684:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200686:	b0dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020068a:	640c                	ld	a1,8(s0)
ffffffffc020068c:	00007517          	auipc	a0,0x7
ffffffffc0200690:	4c450513          	addi	a0,a0,1220 # ffffffffc0207b50 <commands+0x520>
ffffffffc0200694:	affff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200698:	680c                	ld	a1,16(s0)
ffffffffc020069a:	00007517          	auipc	a0,0x7
ffffffffc020069e:	4ce50513          	addi	a0,a0,1230 # ffffffffc0207b68 <commands+0x538>
ffffffffc02006a2:	af1ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006a6:	6c0c                	ld	a1,24(s0)
ffffffffc02006a8:	00007517          	auipc	a0,0x7
ffffffffc02006ac:	4d850513          	addi	a0,a0,1240 # ffffffffc0207b80 <commands+0x550>
ffffffffc02006b0:	ae3ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006b4:	700c                	ld	a1,32(s0)
ffffffffc02006b6:	00007517          	auipc	a0,0x7
ffffffffc02006ba:	4e250513          	addi	a0,a0,1250 # ffffffffc0207b98 <commands+0x568>
ffffffffc02006be:	ad5ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006c2:	740c                	ld	a1,40(s0)
ffffffffc02006c4:	00007517          	auipc	a0,0x7
ffffffffc02006c8:	4ec50513          	addi	a0,a0,1260 # ffffffffc0207bb0 <commands+0x580>
ffffffffc02006cc:	ac7ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d0:	780c                	ld	a1,48(s0)
ffffffffc02006d2:	00007517          	auipc	a0,0x7
ffffffffc02006d6:	4f650513          	addi	a0,a0,1270 # ffffffffc0207bc8 <commands+0x598>
ffffffffc02006da:	ab9ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006de:	7c0c                	ld	a1,56(s0)
ffffffffc02006e0:	00007517          	auipc	a0,0x7
ffffffffc02006e4:	50050513          	addi	a0,a0,1280 # ffffffffc0207be0 <commands+0x5b0>
ffffffffc02006e8:	aabff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006ec:	602c                	ld	a1,64(s0)
ffffffffc02006ee:	00007517          	auipc	a0,0x7
ffffffffc02006f2:	50a50513          	addi	a0,a0,1290 # ffffffffc0207bf8 <commands+0x5c8>
ffffffffc02006f6:	a9dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006fa:	642c                	ld	a1,72(s0)
ffffffffc02006fc:	00007517          	auipc	a0,0x7
ffffffffc0200700:	51450513          	addi	a0,a0,1300 # ffffffffc0207c10 <commands+0x5e0>
ffffffffc0200704:	a8fff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200708:	682c                	ld	a1,80(s0)
ffffffffc020070a:	00007517          	auipc	a0,0x7
ffffffffc020070e:	51e50513          	addi	a0,a0,1310 # ffffffffc0207c28 <commands+0x5f8>
ffffffffc0200712:	a81ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200716:	6c2c                	ld	a1,88(s0)
ffffffffc0200718:	00007517          	auipc	a0,0x7
ffffffffc020071c:	52850513          	addi	a0,a0,1320 # ffffffffc0207c40 <commands+0x610>
ffffffffc0200720:	a73ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200724:	702c                	ld	a1,96(s0)
ffffffffc0200726:	00007517          	auipc	a0,0x7
ffffffffc020072a:	53250513          	addi	a0,a0,1330 # ffffffffc0207c58 <commands+0x628>
ffffffffc020072e:	a65ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200732:	742c                	ld	a1,104(s0)
ffffffffc0200734:	00007517          	auipc	a0,0x7
ffffffffc0200738:	53c50513          	addi	a0,a0,1340 # ffffffffc0207c70 <commands+0x640>
ffffffffc020073c:	a57ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200740:	782c                	ld	a1,112(s0)
ffffffffc0200742:	00007517          	auipc	a0,0x7
ffffffffc0200746:	54650513          	addi	a0,a0,1350 # ffffffffc0207c88 <commands+0x658>
ffffffffc020074a:	a49ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020074e:	7c2c                	ld	a1,120(s0)
ffffffffc0200750:	00007517          	auipc	a0,0x7
ffffffffc0200754:	55050513          	addi	a0,a0,1360 # ffffffffc0207ca0 <commands+0x670>
ffffffffc0200758:	a3bff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020075c:	604c                	ld	a1,128(s0)
ffffffffc020075e:	00007517          	auipc	a0,0x7
ffffffffc0200762:	55a50513          	addi	a0,a0,1370 # ffffffffc0207cb8 <commands+0x688>
ffffffffc0200766:	a2dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020076a:	644c                	ld	a1,136(s0)
ffffffffc020076c:	00007517          	auipc	a0,0x7
ffffffffc0200770:	56450513          	addi	a0,a0,1380 # ffffffffc0207cd0 <commands+0x6a0>
ffffffffc0200774:	a1fff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200778:	684c                	ld	a1,144(s0)
ffffffffc020077a:	00007517          	auipc	a0,0x7
ffffffffc020077e:	56e50513          	addi	a0,a0,1390 # ffffffffc0207ce8 <commands+0x6b8>
ffffffffc0200782:	a11ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200786:	6c4c                	ld	a1,152(s0)
ffffffffc0200788:	00007517          	auipc	a0,0x7
ffffffffc020078c:	57850513          	addi	a0,a0,1400 # ffffffffc0207d00 <commands+0x6d0>
ffffffffc0200790:	a03ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200794:	704c                	ld	a1,160(s0)
ffffffffc0200796:	00007517          	auipc	a0,0x7
ffffffffc020079a:	58250513          	addi	a0,a0,1410 # ffffffffc0207d18 <commands+0x6e8>
ffffffffc020079e:	9f5ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007a2:	744c                	ld	a1,168(s0)
ffffffffc02007a4:	00007517          	auipc	a0,0x7
ffffffffc02007a8:	58c50513          	addi	a0,a0,1420 # ffffffffc0207d30 <commands+0x700>
ffffffffc02007ac:	9e7ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b0:	784c                	ld	a1,176(s0)
ffffffffc02007b2:	00007517          	auipc	a0,0x7
ffffffffc02007b6:	59650513          	addi	a0,a0,1430 # ffffffffc0207d48 <commands+0x718>
ffffffffc02007ba:	9d9ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007be:	7c4c                	ld	a1,184(s0)
ffffffffc02007c0:	00007517          	auipc	a0,0x7
ffffffffc02007c4:	5a050513          	addi	a0,a0,1440 # ffffffffc0207d60 <commands+0x730>
ffffffffc02007c8:	9cbff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007cc:	606c                	ld	a1,192(s0)
ffffffffc02007ce:	00007517          	auipc	a0,0x7
ffffffffc02007d2:	5aa50513          	addi	a0,a0,1450 # ffffffffc0207d78 <commands+0x748>
ffffffffc02007d6:	9bdff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007da:	646c                	ld	a1,200(s0)
ffffffffc02007dc:	00007517          	auipc	a0,0x7
ffffffffc02007e0:	5b450513          	addi	a0,a0,1460 # ffffffffc0207d90 <commands+0x760>
ffffffffc02007e4:	9afff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007e8:	686c                	ld	a1,208(s0)
ffffffffc02007ea:	00007517          	auipc	a0,0x7
ffffffffc02007ee:	5be50513          	addi	a0,a0,1470 # ffffffffc0207da8 <commands+0x778>
ffffffffc02007f2:	9a1ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007f6:	6c6c                	ld	a1,216(s0)
ffffffffc02007f8:	00007517          	auipc	a0,0x7
ffffffffc02007fc:	5c850513          	addi	a0,a0,1480 # ffffffffc0207dc0 <commands+0x790>
ffffffffc0200800:	993ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200804:	706c                	ld	a1,224(s0)
ffffffffc0200806:	00007517          	auipc	a0,0x7
ffffffffc020080a:	5d250513          	addi	a0,a0,1490 # ffffffffc0207dd8 <commands+0x7a8>
ffffffffc020080e:	985ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200812:	746c                	ld	a1,232(s0)
ffffffffc0200814:	00007517          	auipc	a0,0x7
ffffffffc0200818:	5dc50513          	addi	a0,a0,1500 # ffffffffc0207df0 <commands+0x7c0>
ffffffffc020081c:	977ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200820:	786c                	ld	a1,240(s0)
ffffffffc0200822:	00007517          	auipc	a0,0x7
ffffffffc0200826:	5e650513          	addi	a0,a0,1510 # ffffffffc0207e08 <commands+0x7d8>
ffffffffc020082a:	969ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200830:	6402                	ld	s0,0(sp)
ffffffffc0200832:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200834:	00007517          	auipc	a0,0x7
ffffffffc0200838:	5ec50513          	addi	a0,a0,1516 # ffffffffc0207e20 <commands+0x7f0>
}
ffffffffc020083c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083e:	955ff06f          	j	ffffffffc0200192 <cprintf>

ffffffffc0200842 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200842:	1141                	addi	sp,sp,-16
ffffffffc0200844:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200846:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200848:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020084a:	00007517          	auipc	a0,0x7
ffffffffc020084e:	5ee50513          	addi	a0,a0,1518 # ffffffffc0207e38 <commands+0x808>
print_trapframe(struct trapframe *tf) {
ffffffffc0200852:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200854:	93fff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200858:	8522                	mv	a0,s0
ffffffffc020085a:	e1bff0ef          	jal	ra,ffffffffc0200674 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020085e:	10043583          	ld	a1,256(s0)
ffffffffc0200862:	00007517          	auipc	a0,0x7
ffffffffc0200866:	5ee50513          	addi	a0,a0,1518 # ffffffffc0207e50 <commands+0x820>
ffffffffc020086a:	929ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020086e:	10843583          	ld	a1,264(s0)
ffffffffc0200872:	00007517          	auipc	a0,0x7
ffffffffc0200876:	5f650513          	addi	a0,a0,1526 # ffffffffc0207e68 <commands+0x838>
ffffffffc020087a:	919ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020087e:	11043583          	ld	a1,272(s0)
ffffffffc0200882:	00007517          	auipc	a0,0x7
ffffffffc0200886:	5fe50513          	addi	a0,a0,1534 # ffffffffc0207e80 <commands+0x850>
ffffffffc020088a:	909ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200892:	6402                	ld	s0,0(sp)
ffffffffc0200894:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	00007517          	auipc	a0,0x7
ffffffffc020089a:	5fa50513          	addi	a0,a0,1530 # ffffffffc0207e90 <commands+0x860>
}
ffffffffc020089e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02008a0:	8f3ff06f          	j	ffffffffc0200192 <cprintf>

ffffffffc02008a4 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a4:	1101                	addi	sp,sp,-32
ffffffffc02008a6:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008a8:	000df497          	auipc	s1,0xdf
ffffffffc02008ac:	b5048493          	addi	s1,s1,-1200 # ffffffffc02df3f8 <check_mm_struct>
ffffffffc02008b0:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008b2:	e822                	sd	s0,16(sp)
ffffffffc02008b4:	ec06                	sd	ra,24(sp)
ffffffffc02008b6:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b8:	cbbd                	beqz	a5,ffffffffc020092e <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ba:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008be:	11053583          	ld	a1,272(a0)
ffffffffc02008c2:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c6:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008ca:	cba1                	beqz	a5,ffffffffc020091a <pgfault_handler+0x76>
ffffffffc02008cc:	11843703          	ld	a4,280(s0)
ffffffffc02008d0:	47bd                	li	a5,15
ffffffffc02008d2:	05700693          	li	a3,87
ffffffffc02008d6:	00f70463          	beq	a4,a5,ffffffffc02008de <pgfault_handler+0x3a>
ffffffffc02008da:	05200693          	li	a3,82
ffffffffc02008de:	00007517          	auipc	a0,0x7
ffffffffc02008e2:	1da50513          	addi	a0,a0,474 # ffffffffc0207ab8 <commands+0x488>
ffffffffc02008e6:	8adff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008ea:	6088                	ld	a0,0(s1)
ffffffffc02008ec:	c129                	beqz	a0,ffffffffc020092e <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008ee:	000df797          	auipc	a5,0xdf
ffffffffc02008f2:	9c278793          	addi	a5,a5,-1598 # ffffffffc02df2b0 <current>
ffffffffc02008f6:	6398                	ld	a4,0(a5)
ffffffffc02008f8:	000df797          	auipc	a5,0xdf
ffffffffc02008fc:	9c078793          	addi	a5,a5,-1600 # ffffffffc02df2b8 <idleproc>
ffffffffc0200900:	639c                	ld	a5,0(a5)
ffffffffc0200902:	04f71763          	bne	a4,a5,ffffffffc0200950 <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200906:	11043603          	ld	a2,272(s0)
ffffffffc020090a:	11843583          	ld	a1,280(s0)
}
ffffffffc020090e:	6442                	ld	s0,16(sp)
ffffffffc0200910:	60e2                	ld	ra,24(sp)
ffffffffc0200912:	64a2                	ld	s1,8(sp)
ffffffffc0200914:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200916:	0780406f          	j	ffffffffc020498e <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020091a:	11843703          	ld	a4,280(s0)
ffffffffc020091e:	47bd                	li	a5,15
ffffffffc0200920:	05500613          	li	a2,85
ffffffffc0200924:	05700693          	li	a3,87
ffffffffc0200928:	faf719e3          	bne	a4,a5,ffffffffc02008da <pgfault_handler+0x36>
ffffffffc020092c:	bf4d                	j	ffffffffc02008de <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020092e:	000df797          	auipc	a5,0xdf
ffffffffc0200932:	98278793          	addi	a5,a5,-1662 # ffffffffc02df2b0 <current>
ffffffffc0200936:	639c                	ld	a5,0(a5)
ffffffffc0200938:	cf85                	beqz	a5,ffffffffc0200970 <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020093a:	11043603          	ld	a2,272(s0)
ffffffffc020093e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200942:	6442                	ld	s0,16(sp)
ffffffffc0200944:	60e2                	ld	ra,24(sp)
ffffffffc0200946:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200948:	7788                	ld	a0,40(a5)
}
ffffffffc020094a:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020094c:	0420406f          	j	ffffffffc020498e <do_pgfault>
        assert(current == idleproc);
ffffffffc0200950:	00007697          	auipc	a3,0x7
ffffffffc0200954:	18868693          	addi	a3,a3,392 # ffffffffc0207ad8 <commands+0x4a8>
ffffffffc0200958:	00007617          	auipc	a2,0x7
ffffffffc020095c:	19860613          	addi	a2,a2,408 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0200960:	06c00593          	li	a1,108
ffffffffc0200964:	00007517          	auipc	a0,0x7
ffffffffc0200968:	1a450513          	addi	a0,a0,420 # ffffffffc0207b08 <commands+0x4d8>
ffffffffc020096c:	b1dff0ef          	jal	ra,ffffffffc0200488 <__panic>
            print_trapframe(tf);
ffffffffc0200970:	8522                	mv	a0,s0
ffffffffc0200972:	ed1ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200976:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020097a:	11043583          	ld	a1,272(s0)
ffffffffc020097e:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200982:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200986:	e399                	bnez	a5,ffffffffc020098c <pgfault_handler+0xe8>
ffffffffc0200988:	05500613          	li	a2,85
ffffffffc020098c:	11843703          	ld	a4,280(s0)
ffffffffc0200990:	47bd                	li	a5,15
ffffffffc0200992:	02f70663          	beq	a4,a5,ffffffffc02009be <pgfault_handler+0x11a>
ffffffffc0200996:	05200693          	li	a3,82
ffffffffc020099a:	00007517          	auipc	a0,0x7
ffffffffc020099e:	11e50513          	addi	a0,a0,286 # ffffffffc0207ab8 <commands+0x488>
ffffffffc02009a2:	ff0ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009a6:	00007617          	auipc	a2,0x7
ffffffffc02009aa:	17a60613          	addi	a2,a2,378 # ffffffffc0207b20 <commands+0x4f0>
ffffffffc02009ae:	07300593          	li	a1,115
ffffffffc02009b2:	00007517          	auipc	a0,0x7
ffffffffc02009b6:	15650513          	addi	a0,a0,342 # ffffffffc0207b08 <commands+0x4d8>
ffffffffc02009ba:	acfff0ef          	jal	ra,ffffffffc0200488 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009be:	05700693          	li	a3,87
ffffffffc02009c2:	bfe1                	j	ffffffffc020099a <pgfault_handler+0xf6>

ffffffffc02009c4 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009c4:	11853783          	ld	a5,280(a0)
ffffffffc02009c8:	577d                	li	a4,-1
ffffffffc02009ca:	8305                	srli	a4,a4,0x1
ffffffffc02009cc:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02009ce:	472d                	li	a4,11
ffffffffc02009d0:	06f76b63          	bltu	a4,a5,ffffffffc0200a46 <interrupt_handler+0x82>
ffffffffc02009d4:	00007717          	auipc	a4,0x7
ffffffffc02009d8:	e3870713          	addi	a4,a4,-456 # ffffffffc020780c <commands+0x1dc>
ffffffffc02009dc:	078a                	slli	a5,a5,0x2
ffffffffc02009de:	97ba                	add	a5,a5,a4
ffffffffc02009e0:	439c                	lw	a5,0(a5)
ffffffffc02009e2:	97ba                	add	a5,a5,a4
ffffffffc02009e4:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009e6:	00007517          	auipc	a0,0x7
ffffffffc02009ea:	09250513          	addi	a0,a0,146 # ffffffffc0207a78 <commands+0x448>
ffffffffc02009ee:	fa4ff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009f2:	00007517          	auipc	a0,0x7
ffffffffc02009f6:	06650513          	addi	a0,a0,102 # ffffffffc0207a58 <commands+0x428>
ffffffffc02009fa:	f98ff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009fe:	00007517          	auipc	a0,0x7
ffffffffc0200a02:	01a50513          	addi	a0,a0,26 # ffffffffc0207a18 <commands+0x3e8>
ffffffffc0200a06:	f8cff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a0a:	00007517          	auipc	a0,0x7
ffffffffc0200a0e:	02e50513          	addi	a0,a0,46 # ffffffffc0207a38 <commands+0x408>
ffffffffc0200a12:	f80ff06f          	j	ffffffffc0200192 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a16:	00007517          	auipc	a0,0x7
ffffffffc0200a1a:	08250513          	addi	a0,a0,130 # ffffffffc0207a98 <commands+0x468>
ffffffffc0200a1e:	f74ff06f          	j	ffffffffc0200192 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a22:	1141                	addi	sp,sp,-16
ffffffffc0200a24:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a26:	b43ff0ef          	jal	ra,ffffffffc0200568 <clock_set_next_event>
            ++ticks;
ffffffffc0200a2a:	000df797          	auipc	a5,0xdf
ffffffffc0200a2e:	8b678793          	addi	a5,a5,-1866 # ffffffffc02df2e0 <ticks>
ffffffffc0200a32:	639c                	ld	a5,0(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a34:	60a2                	ld	ra,8(sp)
            ++ticks;
ffffffffc0200a36:	0785                	addi	a5,a5,1
ffffffffc0200a38:	000df717          	auipc	a4,0xdf
ffffffffc0200a3c:	8af73423          	sd	a5,-1880(a4) # ffffffffc02df2e0 <ticks>
}
ffffffffc0200a40:	0141                	addi	sp,sp,16
            run_timer_list();
ffffffffc0200a42:	3920606f          	j	ffffffffc0206dd4 <run_timer_list>
            print_trapframe(tf);
ffffffffc0200a46:	dfdff06f          	j	ffffffffc0200842 <print_trapframe>

ffffffffc0200a4a <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a4a:	11853783          	ld	a5,280(a0)
ffffffffc0200a4e:	473d                	li	a4,15
ffffffffc0200a50:	1af76e63          	bltu	a4,a5,ffffffffc0200c0c <exception_handler+0x1c2>
ffffffffc0200a54:	00007717          	auipc	a4,0x7
ffffffffc0200a58:	de870713          	addi	a4,a4,-536 # ffffffffc020783c <commands+0x20c>
ffffffffc0200a5c:	078a                	slli	a5,a5,0x2
ffffffffc0200a5e:	97ba                	add	a5,a5,a4
ffffffffc0200a60:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a62:	1101                	addi	sp,sp,-32
ffffffffc0200a64:	e822                	sd	s0,16(sp)
ffffffffc0200a66:	ec06                	sd	ra,24(sp)
ffffffffc0200a68:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a6a:	97ba                	add	a5,a5,a4
ffffffffc0200a6c:	842a                	mv	s0,a0
ffffffffc0200a6e:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a70:	00007517          	auipc	a0,0x7
ffffffffc0200a74:	f0050513          	addi	a0,a0,-256 # ffffffffc0207970 <commands+0x340>
ffffffffc0200a78:	f1aff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            tf->epc += 4;
ffffffffc0200a7c:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a80:	60e2                	ld	ra,24(sp)
ffffffffc0200a82:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a84:	0791                	addi	a5,a5,4
ffffffffc0200a86:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a8a:	6442                	ld	s0,16(sp)
ffffffffc0200a8c:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a8e:	5180606f          	j	ffffffffc0206fa6 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a92:	00007517          	auipc	a0,0x7
ffffffffc0200a96:	efe50513          	addi	a0,a0,-258 # ffffffffc0207990 <commands+0x360>
}
ffffffffc0200a9a:	6442                	ld	s0,16(sp)
ffffffffc0200a9c:	60e2                	ld	ra,24(sp)
ffffffffc0200a9e:	64a2                	ld	s1,8(sp)
ffffffffc0200aa0:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200aa2:	ef0ff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200aa6:	00007517          	auipc	a0,0x7
ffffffffc0200aaa:	f0a50513          	addi	a0,a0,-246 # ffffffffc02079b0 <commands+0x380>
ffffffffc0200aae:	b7f5                	j	ffffffffc0200a9a <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ab0:	00007517          	auipc	a0,0x7
ffffffffc0200ab4:	f2050513          	addi	a0,a0,-224 # ffffffffc02079d0 <commands+0x3a0>
ffffffffc0200ab8:	b7cd                	j	ffffffffc0200a9a <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200aba:	00007517          	auipc	a0,0x7
ffffffffc0200abe:	f2e50513          	addi	a0,a0,-210 # ffffffffc02079e8 <commands+0x3b8>
ffffffffc0200ac2:	ed0ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ac6:	8522                	mv	a0,s0
ffffffffc0200ac8:	dddff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200acc:	84aa                	mv	s1,a0
ffffffffc0200ace:	14051163          	bnez	a0,ffffffffc0200c10 <exception_handler+0x1c6>
}
ffffffffc0200ad2:	60e2                	ld	ra,24(sp)
ffffffffc0200ad4:	6442                	ld	s0,16(sp)
ffffffffc0200ad6:	64a2                	ld	s1,8(sp)
ffffffffc0200ad8:	6105                	addi	sp,sp,32
ffffffffc0200ada:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200adc:	00007517          	auipc	a0,0x7
ffffffffc0200ae0:	f2450513          	addi	a0,a0,-220 # ffffffffc0207a00 <commands+0x3d0>
ffffffffc0200ae4:	eaeff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae8:	8522                	mv	a0,s0
ffffffffc0200aea:	dbbff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200aee:	84aa                	mv	s1,a0
ffffffffc0200af0:	d16d                	beqz	a0,ffffffffc0200ad2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200af2:	8522                	mv	a0,s0
ffffffffc0200af4:	d4fff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200af8:	86a6                	mv	a3,s1
ffffffffc0200afa:	00007617          	auipc	a2,0x7
ffffffffc0200afe:	e2660613          	addi	a2,a2,-474 # ffffffffc0207920 <commands+0x2f0>
ffffffffc0200b02:	0f700593          	li	a1,247
ffffffffc0200b06:	00007517          	auipc	a0,0x7
ffffffffc0200b0a:	00250513          	addi	a0,a0,2 # ffffffffc0207b08 <commands+0x4d8>
ffffffffc0200b0e:	97bff0ef          	jal	ra,ffffffffc0200488 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b12:	00007517          	auipc	a0,0x7
ffffffffc0200b16:	d6e50513          	addi	a0,a0,-658 # ffffffffc0207880 <commands+0x250>
ffffffffc0200b1a:	b741                	j	ffffffffc0200a9a <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b1c:	00007517          	auipc	a0,0x7
ffffffffc0200b20:	d8450513          	addi	a0,a0,-636 # ffffffffc02078a0 <commands+0x270>
ffffffffc0200b24:	bf9d                	j	ffffffffc0200a9a <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b26:	00007517          	auipc	a0,0x7
ffffffffc0200b2a:	d9a50513          	addi	a0,a0,-614 # ffffffffc02078c0 <commands+0x290>
ffffffffc0200b2e:	b7b5                	j	ffffffffc0200a9a <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b30:	00007517          	auipc	a0,0x7
ffffffffc0200b34:	da850513          	addi	a0,a0,-600 # ffffffffc02078d8 <commands+0x2a8>
ffffffffc0200b38:	e5aff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b3c:	6458                	ld	a4,136(s0)
ffffffffc0200b3e:	47a9                	li	a5,10
ffffffffc0200b40:	f8f719e3          	bne	a4,a5,ffffffffc0200ad2 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b44:	10843783          	ld	a5,264(s0)
ffffffffc0200b48:	0791                	addi	a5,a5,4
ffffffffc0200b4a:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b4e:	458060ef          	jal	ra,ffffffffc0206fa6 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b52:	000de797          	auipc	a5,0xde
ffffffffc0200b56:	75e78793          	addi	a5,a5,1886 # ffffffffc02df2b0 <current>
ffffffffc0200b5a:	639c                	ld	a5,0(a5)
ffffffffc0200b5c:	8522                	mv	a0,s0
}
ffffffffc0200b5e:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b60:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b62:	60e2                	ld	ra,24(sp)
ffffffffc0200b64:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b66:	6589                	lui	a1,0x2
ffffffffc0200b68:	95be                	add	a1,a1,a5
}
ffffffffc0200b6a:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b6c:	2220006f          	j	ffffffffc0200d8e <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b70:	00007517          	auipc	a0,0x7
ffffffffc0200b74:	d7850513          	addi	a0,a0,-648 # ffffffffc02078e8 <commands+0x2b8>
ffffffffc0200b78:	b70d                	j	ffffffffc0200a9a <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b7a:	00007517          	auipc	a0,0x7
ffffffffc0200b7e:	d8e50513          	addi	a0,a0,-626 # ffffffffc0207908 <commands+0x2d8>
ffffffffc0200b82:	e10ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b86:	8522                	mv	a0,s0
ffffffffc0200b88:	d1dff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200b8c:	84aa                	mv	s1,a0
ffffffffc0200b8e:	d131                	beqz	a0,ffffffffc0200ad2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b90:	8522                	mv	a0,s0
ffffffffc0200b92:	cb1ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b96:	86a6                	mv	a3,s1
ffffffffc0200b98:	00007617          	auipc	a2,0x7
ffffffffc0200b9c:	d8860613          	addi	a2,a2,-632 # ffffffffc0207920 <commands+0x2f0>
ffffffffc0200ba0:	0cc00593          	li	a1,204
ffffffffc0200ba4:	00007517          	auipc	a0,0x7
ffffffffc0200ba8:	f6450513          	addi	a0,a0,-156 # ffffffffc0207b08 <commands+0x4d8>
ffffffffc0200bac:	8ddff0ef          	jal	ra,ffffffffc0200488 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bb0:	00007517          	auipc	a0,0x7
ffffffffc0200bb4:	da850513          	addi	a0,a0,-600 # ffffffffc0207958 <commands+0x328>
ffffffffc0200bb8:	ddaff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bbc:	8522                	mv	a0,s0
ffffffffc0200bbe:	ce7ff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200bc2:	84aa                	mv	s1,a0
ffffffffc0200bc4:	f00507e3          	beqz	a0,ffffffffc0200ad2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bc8:	8522                	mv	a0,s0
ffffffffc0200bca:	c79ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bce:	86a6                	mv	a3,s1
ffffffffc0200bd0:	00007617          	auipc	a2,0x7
ffffffffc0200bd4:	d5060613          	addi	a2,a2,-688 # ffffffffc0207920 <commands+0x2f0>
ffffffffc0200bd8:	0d600593          	li	a1,214
ffffffffc0200bdc:	00007517          	auipc	a0,0x7
ffffffffc0200be0:	f2c50513          	addi	a0,a0,-212 # ffffffffc0207b08 <commands+0x4d8>
ffffffffc0200be4:	8a5ff0ef          	jal	ra,ffffffffc0200488 <__panic>
}
ffffffffc0200be8:	6442                	ld	s0,16(sp)
ffffffffc0200bea:	60e2                	ld	ra,24(sp)
ffffffffc0200bec:	64a2                	ld	s1,8(sp)
ffffffffc0200bee:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200bf0:	c53ff06f          	j	ffffffffc0200842 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200bf4:	00007617          	auipc	a2,0x7
ffffffffc0200bf8:	d4c60613          	addi	a2,a2,-692 # ffffffffc0207940 <commands+0x310>
ffffffffc0200bfc:	0d000593          	li	a1,208
ffffffffc0200c00:	00007517          	auipc	a0,0x7
ffffffffc0200c04:	f0850513          	addi	a0,a0,-248 # ffffffffc0207b08 <commands+0x4d8>
ffffffffc0200c08:	881ff0ef          	jal	ra,ffffffffc0200488 <__panic>
            print_trapframe(tf);
ffffffffc0200c0c:	c37ff06f          	j	ffffffffc0200842 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c10:	8522                	mv	a0,s0
ffffffffc0200c12:	c31ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c16:	86a6                	mv	a3,s1
ffffffffc0200c18:	00007617          	auipc	a2,0x7
ffffffffc0200c1c:	d0860613          	addi	a2,a2,-760 # ffffffffc0207920 <commands+0x2f0>
ffffffffc0200c20:	0f000593          	li	a1,240
ffffffffc0200c24:	00007517          	auipc	a0,0x7
ffffffffc0200c28:	ee450513          	addi	a0,a0,-284 # ffffffffc0207b08 <commands+0x4d8>
ffffffffc0200c2c:	85dff0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0200c30 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c30:	1101                	addi	sp,sp,-32
ffffffffc0200c32:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c34:	000de417          	auipc	s0,0xde
ffffffffc0200c38:	67c40413          	addi	s0,s0,1660 # ffffffffc02df2b0 <current>
ffffffffc0200c3c:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c3e:	ec06                	sd	ra,24(sp)
ffffffffc0200c40:	e426                	sd	s1,8(sp)
ffffffffc0200c42:	e04a                	sd	s2,0(sp)
ffffffffc0200c44:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c48:	cf1d                	beqz	a4,ffffffffc0200c86 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c4a:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c4e:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c52:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c54:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c58:	0206c463          	bltz	a3,ffffffffc0200c80 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c5c:	defff0ef          	jal	ra,ffffffffc0200a4a <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c60:	601c                	ld	a5,0(s0)
ffffffffc0200c62:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c66:	e499                	bnez	s1,ffffffffc0200c74 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c68:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c6c:	8b05                	andi	a4,a4,1
ffffffffc0200c6e:	e339                	bnez	a4,ffffffffc0200cb4 <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c70:	6f9c                	ld	a5,24(a5)
ffffffffc0200c72:	eb95                	bnez	a5,ffffffffc0200ca6 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200c74:	60e2                	ld	ra,24(sp)
ffffffffc0200c76:	6442                	ld	s0,16(sp)
ffffffffc0200c78:	64a2                	ld	s1,8(sp)
ffffffffc0200c7a:	6902                	ld	s2,0(sp)
ffffffffc0200c7c:	6105                	addi	sp,sp,32
ffffffffc0200c7e:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c80:	d45ff0ef          	jal	ra,ffffffffc02009c4 <interrupt_handler>
ffffffffc0200c84:	bff1                	j	ffffffffc0200c60 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c86:	0006c963          	bltz	a3,ffffffffc0200c98 <trap+0x68>
}
ffffffffc0200c8a:	6442                	ld	s0,16(sp)
ffffffffc0200c8c:	60e2                	ld	ra,24(sp)
ffffffffc0200c8e:	64a2                	ld	s1,8(sp)
ffffffffc0200c90:	6902                	ld	s2,0(sp)
ffffffffc0200c92:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c94:	db7ff06f          	j	ffffffffc0200a4a <exception_handler>
}
ffffffffc0200c98:	6442                	ld	s0,16(sp)
ffffffffc0200c9a:	60e2                	ld	ra,24(sp)
ffffffffc0200c9c:	64a2                	ld	s1,8(sp)
ffffffffc0200c9e:	6902                	ld	s2,0(sp)
ffffffffc0200ca0:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200ca2:	d23ff06f          	j	ffffffffc02009c4 <interrupt_handler>
}
ffffffffc0200ca6:	6442                	ld	s0,16(sp)
ffffffffc0200ca8:	60e2                	ld	ra,24(sp)
ffffffffc0200caa:	64a2                	ld	s1,8(sp)
ffffffffc0200cac:	6902                	ld	s2,0(sp)
ffffffffc0200cae:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cb0:	70d0506f          	j	ffffffffc0206bbc <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cb4:	555d                	li	a0,-9
ffffffffc0200cb6:	7c3040ef          	jal	ra,ffffffffc0205c78 <do_exit>
ffffffffc0200cba:	601c                	ld	a5,0(s0)
ffffffffc0200cbc:	bf55                	j	ffffffffc0200c70 <trap+0x40>
	...

ffffffffc0200cc0 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cc0:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200cc4:	00011463          	bnez	sp,ffffffffc0200ccc <__alltraps+0xc>
ffffffffc0200cc8:	14002173          	csrr	sp,sscratch
ffffffffc0200ccc:	712d                	addi	sp,sp,-288
ffffffffc0200cce:	e002                	sd	zero,0(sp)
ffffffffc0200cd0:	e406                	sd	ra,8(sp)
ffffffffc0200cd2:	ec0e                	sd	gp,24(sp)
ffffffffc0200cd4:	f012                	sd	tp,32(sp)
ffffffffc0200cd6:	f416                	sd	t0,40(sp)
ffffffffc0200cd8:	f81a                	sd	t1,48(sp)
ffffffffc0200cda:	fc1e                	sd	t2,56(sp)
ffffffffc0200cdc:	e0a2                	sd	s0,64(sp)
ffffffffc0200cde:	e4a6                	sd	s1,72(sp)
ffffffffc0200ce0:	e8aa                	sd	a0,80(sp)
ffffffffc0200ce2:	ecae                	sd	a1,88(sp)
ffffffffc0200ce4:	f0b2                	sd	a2,96(sp)
ffffffffc0200ce6:	f4b6                	sd	a3,104(sp)
ffffffffc0200ce8:	f8ba                	sd	a4,112(sp)
ffffffffc0200cea:	fcbe                	sd	a5,120(sp)
ffffffffc0200cec:	e142                	sd	a6,128(sp)
ffffffffc0200cee:	e546                	sd	a7,136(sp)
ffffffffc0200cf0:	e94a                	sd	s2,144(sp)
ffffffffc0200cf2:	ed4e                	sd	s3,152(sp)
ffffffffc0200cf4:	f152                	sd	s4,160(sp)
ffffffffc0200cf6:	f556                	sd	s5,168(sp)
ffffffffc0200cf8:	f95a                	sd	s6,176(sp)
ffffffffc0200cfa:	fd5e                	sd	s7,184(sp)
ffffffffc0200cfc:	e1e2                	sd	s8,192(sp)
ffffffffc0200cfe:	e5e6                	sd	s9,200(sp)
ffffffffc0200d00:	e9ea                	sd	s10,208(sp)
ffffffffc0200d02:	edee                	sd	s11,216(sp)
ffffffffc0200d04:	f1f2                	sd	t3,224(sp)
ffffffffc0200d06:	f5f6                	sd	t4,232(sp)
ffffffffc0200d08:	f9fa                	sd	t5,240(sp)
ffffffffc0200d0a:	fdfe                	sd	t6,248(sp)
ffffffffc0200d0c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d10:	100024f3          	csrr	s1,sstatus
ffffffffc0200d14:	14102973          	csrr	s2,sepc
ffffffffc0200d18:	143029f3          	csrr	s3,stval
ffffffffc0200d1c:	14202a73          	csrr	s4,scause
ffffffffc0200d20:	e822                	sd	s0,16(sp)
ffffffffc0200d22:	e226                	sd	s1,256(sp)
ffffffffc0200d24:	e64a                	sd	s2,264(sp)
ffffffffc0200d26:	ea4e                	sd	s3,272(sp)
ffffffffc0200d28:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d2a:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d2c:	f05ff0ef          	jal	ra,ffffffffc0200c30 <trap>

ffffffffc0200d30 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d30:	6492                	ld	s1,256(sp)
ffffffffc0200d32:	6932                	ld	s2,264(sp)
ffffffffc0200d34:	1004f413          	andi	s0,s1,256
ffffffffc0200d38:	e401                	bnez	s0,ffffffffc0200d40 <__trapret+0x10>
ffffffffc0200d3a:	1200                	addi	s0,sp,288
ffffffffc0200d3c:	14041073          	csrw	sscratch,s0
ffffffffc0200d40:	10049073          	csrw	sstatus,s1
ffffffffc0200d44:	14191073          	csrw	sepc,s2
ffffffffc0200d48:	60a2                	ld	ra,8(sp)
ffffffffc0200d4a:	61e2                	ld	gp,24(sp)
ffffffffc0200d4c:	7202                	ld	tp,32(sp)
ffffffffc0200d4e:	72a2                	ld	t0,40(sp)
ffffffffc0200d50:	7342                	ld	t1,48(sp)
ffffffffc0200d52:	73e2                	ld	t2,56(sp)
ffffffffc0200d54:	6406                	ld	s0,64(sp)
ffffffffc0200d56:	64a6                	ld	s1,72(sp)
ffffffffc0200d58:	6546                	ld	a0,80(sp)
ffffffffc0200d5a:	65e6                	ld	a1,88(sp)
ffffffffc0200d5c:	7606                	ld	a2,96(sp)
ffffffffc0200d5e:	76a6                	ld	a3,104(sp)
ffffffffc0200d60:	7746                	ld	a4,112(sp)
ffffffffc0200d62:	77e6                	ld	a5,120(sp)
ffffffffc0200d64:	680a                	ld	a6,128(sp)
ffffffffc0200d66:	68aa                	ld	a7,136(sp)
ffffffffc0200d68:	694a                	ld	s2,144(sp)
ffffffffc0200d6a:	69ea                	ld	s3,152(sp)
ffffffffc0200d6c:	7a0a                	ld	s4,160(sp)
ffffffffc0200d6e:	7aaa                	ld	s5,168(sp)
ffffffffc0200d70:	7b4a                	ld	s6,176(sp)
ffffffffc0200d72:	7bea                	ld	s7,184(sp)
ffffffffc0200d74:	6c0e                	ld	s8,192(sp)
ffffffffc0200d76:	6cae                	ld	s9,200(sp)
ffffffffc0200d78:	6d4e                	ld	s10,208(sp)
ffffffffc0200d7a:	6dee                	ld	s11,216(sp)
ffffffffc0200d7c:	7e0e                	ld	t3,224(sp)
ffffffffc0200d7e:	7eae                	ld	t4,232(sp)
ffffffffc0200d80:	7f4e                	ld	t5,240(sp)
ffffffffc0200d82:	7fee                	ld	t6,248(sp)
ffffffffc0200d84:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d86:	10200073          	sret

ffffffffc0200d8a <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d8a:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d8c:	b755                	j	ffffffffc0200d30 <__trapret>

ffffffffc0200d8e <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d8e:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7bf0>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d92:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d96:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d9a:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d9e:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200da2:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200da6:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200daa:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200dae:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200db2:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200db4:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200db6:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200db8:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dba:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200dbc:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dbe:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dc0:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dc2:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200dc4:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200dc6:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200dc8:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dca:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200dcc:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dce:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200dd0:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200dd2:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200dd4:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200dd6:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200dd8:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dda:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200ddc:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dde:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200de0:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200de2:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200de4:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200de6:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200de8:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dea:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200dec:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dee:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200df0:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200df2:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200df4:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200df6:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200df8:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200dfa:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200dfc:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dfe:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e00:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e02:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e04:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e06:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e08:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e0a:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e0c:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e0e:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e10:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e12:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e14:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e16:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e18:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e1a:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e1c:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e1e:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e20:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e22:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e24:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e26:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e28:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e2a:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e2c:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e2e:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e30:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e32:	812e                	mv	sp,a1
ffffffffc0200e34:	bdf5                	j	ffffffffc0200d30 <__trapret>

ffffffffc0200e36 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e36:	000de797          	auipc	a5,0xde
ffffffffc0200e3a:	4b278793          	addi	a5,a5,1202 # ffffffffc02df2e8 <free_area>
ffffffffc0200e3e:	e79c                	sd	a5,8(a5)
ffffffffc0200e40:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e42:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e46:	8082                	ret

ffffffffc0200e48 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e48:	000de517          	auipc	a0,0xde
ffffffffc0200e4c:	4b056503          	lwu	a0,1200(a0) # ffffffffc02df2f8 <free_area+0x10>
ffffffffc0200e50:	8082                	ret

ffffffffc0200e52 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e52:	715d                	addi	sp,sp,-80
ffffffffc0200e54:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e56:	000de917          	auipc	s2,0xde
ffffffffc0200e5a:	49290913          	addi	s2,s2,1170 # ffffffffc02df2e8 <free_area>
ffffffffc0200e5e:	00893783          	ld	a5,8(s2)
ffffffffc0200e62:	e486                	sd	ra,72(sp)
ffffffffc0200e64:	e0a2                	sd	s0,64(sp)
ffffffffc0200e66:	fc26                	sd	s1,56(sp)
ffffffffc0200e68:	f44e                	sd	s3,40(sp)
ffffffffc0200e6a:	f052                	sd	s4,32(sp)
ffffffffc0200e6c:	ec56                	sd	s5,24(sp)
ffffffffc0200e6e:	e85a                	sd	s6,16(sp)
ffffffffc0200e70:	e45e                	sd	s7,8(sp)
ffffffffc0200e72:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e74:	31278463          	beq	a5,s2,ffffffffc020117c <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e78:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200e7c:	8305                	srli	a4,a4,0x1
ffffffffc0200e7e:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e80:	30070263          	beqz	a4,ffffffffc0201184 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200e84:	4401                	li	s0,0
ffffffffc0200e86:	4481                	li	s1,0
ffffffffc0200e88:	a031                	j	ffffffffc0200e94 <default_check+0x42>
ffffffffc0200e8a:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200e8e:	8b09                	andi	a4,a4,2
ffffffffc0200e90:	2e070a63          	beqz	a4,ffffffffc0201184 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200e94:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e98:	679c                	ld	a5,8(a5)
ffffffffc0200e9a:	2485                	addiw	s1,s1,1
ffffffffc0200e9c:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e9e:	ff2796e3          	bne	a5,s2,ffffffffc0200e8a <default_check+0x38>
ffffffffc0200ea2:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200ea4:	05c010ef          	jal	ra,ffffffffc0201f00 <nr_free_pages>
ffffffffc0200ea8:	73351e63          	bne	a0,s3,ffffffffc02015e4 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200eac:	4505                	li	a0,1
ffffffffc0200eae:	785000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc0200eb2:	8a2a                	mv	s4,a0
ffffffffc0200eb4:	46050863          	beqz	a0,ffffffffc0201324 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200eb8:	4505                	li	a0,1
ffffffffc0200eba:	779000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc0200ebe:	89aa                	mv	s3,a0
ffffffffc0200ec0:	74050263          	beqz	a0,ffffffffc0201604 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ec4:	4505                	li	a0,1
ffffffffc0200ec6:	76d000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc0200eca:	8aaa                	mv	s5,a0
ffffffffc0200ecc:	4c050c63          	beqz	a0,ffffffffc02013a4 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ed0:	2d3a0a63          	beq	s4,s3,ffffffffc02011a4 <default_check+0x352>
ffffffffc0200ed4:	2caa0863          	beq	s4,a0,ffffffffc02011a4 <default_check+0x352>
ffffffffc0200ed8:	2ca98663          	beq	s3,a0,ffffffffc02011a4 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200edc:	000a2783          	lw	a5,0(s4)
ffffffffc0200ee0:	2e079263          	bnez	a5,ffffffffc02011c4 <default_check+0x372>
ffffffffc0200ee4:	0009a783          	lw	a5,0(s3)
ffffffffc0200ee8:	2c079e63          	bnez	a5,ffffffffc02011c4 <default_check+0x372>
ffffffffc0200eec:	411c                	lw	a5,0(a0)
ffffffffc0200eee:	2c079b63          	bnez	a5,ffffffffc02011c4 <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200ef2:	000de797          	auipc	a5,0xde
ffffffffc0200ef6:	42678793          	addi	a5,a5,1062 # ffffffffc02df318 <pages>
ffffffffc0200efa:	639c                	ld	a5,0(a5)
ffffffffc0200efc:	0000a717          	auipc	a4,0xa
ffffffffc0200f00:	9bc70713          	addi	a4,a4,-1604 # ffffffffc020a8b8 <nbase>
ffffffffc0200f04:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f06:	000de717          	auipc	a4,0xde
ffffffffc0200f0a:	39270713          	addi	a4,a4,914 # ffffffffc02df298 <npage>
ffffffffc0200f0e:	6314                	ld	a3,0(a4)
ffffffffc0200f10:	40fa0733          	sub	a4,s4,a5
ffffffffc0200f14:	8719                	srai	a4,a4,0x6
ffffffffc0200f16:	9732                	add	a4,a4,a2
ffffffffc0200f18:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f1a:	0732                	slli	a4,a4,0xc
ffffffffc0200f1c:	2cd77463          	bleu	a3,a4,ffffffffc02011e4 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200f20:	40f98733          	sub	a4,s3,a5
ffffffffc0200f24:	8719                	srai	a4,a4,0x6
ffffffffc0200f26:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f28:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f2a:	4ed77d63          	bleu	a3,a4,ffffffffc0201424 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200f2e:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f32:	8799                	srai	a5,a5,0x6
ffffffffc0200f34:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f36:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f38:	34d7f663          	bleu	a3,a5,ffffffffc0201284 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200f3c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f3e:	00093c03          	ld	s8,0(s2)
ffffffffc0200f42:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f46:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200f4a:	000de797          	auipc	a5,0xde
ffffffffc0200f4e:	3b27b323          	sd	s2,934(a5) # ffffffffc02df2f0 <free_area+0x8>
ffffffffc0200f52:	000de797          	auipc	a5,0xde
ffffffffc0200f56:	3927bb23          	sd	s2,918(a5) # ffffffffc02df2e8 <free_area>
    nr_free = 0;
ffffffffc0200f5a:	000de797          	auipc	a5,0xde
ffffffffc0200f5e:	3807af23          	sw	zero,926(a5) # ffffffffc02df2f8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f62:	6d1000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc0200f66:	2e051f63          	bnez	a0,ffffffffc0201264 <default_check+0x412>
    free_page(p0);
ffffffffc0200f6a:	4585                	li	a1,1
ffffffffc0200f6c:	8552                	mv	a0,s4
ffffffffc0200f6e:	74d000ef          	jal	ra,ffffffffc0201eba <free_pages>
    free_page(p1);
ffffffffc0200f72:	4585                	li	a1,1
ffffffffc0200f74:	854e                	mv	a0,s3
ffffffffc0200f76:	745000ef          	jal	ra,ffffffffc0201eba <free_pages>
    free_page(p2);
ffffffffc0200f7a:	4585                	li	a1,1
ffffffffc0200f7c:	8556                	mv	a0,s5
ffffffffc0200f7e:	73d000ef          	jal	ra,ffffffffc0201eba <free_pages>
    assert(nr_free == 3);
ffffffffc0200f82:	01092703          	lw	a4,16(s2)
ffffffffc0200f86:	478d                	li	a5,3
ffffffffc0200f88:	2af71e63          	bne	a4,a5,ffffffffc0201244 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f8c:	4505                	li	a0,1
ffffffffc0200f8e:	6a5000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc0200f92:	89aa                	mv	s3,a0
ffffffffc0200f94:	28050863          	beqz	a0,ffffffffc0201224 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f98:	4505                	li	a0,1
ffffffffc0200f9a:	699000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc0200f9e:	8aaa                	mv	s5,a0
ffffffffc0200fa0:	3e050263          	beqz	a0,ffffffffc0201384 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fa4:	4505                	li	a0,1
ffffffffc0200fa6:	68d000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc0200faa:	8a2a                	mv	s4,a0
ffffffffc0200fac:	3a050c63          	beqz	a0,ffffffffc0201364 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200fb0:	4505                	li	a0,1
ffffffffc0200fb2:	681000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc0200fb6:	38051763          	bnez	a0,ffffffffc0201344 <default_check+0x4f2>
    free_page(p0);
ffffffffc0200fba:	4585                	li	a1,1
ffffffffc0200fbc:	854e                	mv	a0,s3
ffffffffc0200fbe:	6fd000ef          	jal	ra,ffffffffc0201eba <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200fc2:	00893783          	ld	a5,8(s2)
ffffffffc0200fc6:	23278f63          	beq	a5,s2,ffffffffc0201204 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200fca:	4505                	li	a0,1
ffffffffc0200fcc:	667000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc0200fd0:	32a99a63          	bne	s3,a0,ffffffffc0201304 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0200fd4:	4505                	li	a0,1
ffffffffc0200fd6:	65d000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc0200fda:	30051563          	bnez	a0,ffffffffc02012e4 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0200fde:	01092783          	lw	a5,16(s2)
ffffffffc0200fe2:	2e079163          	bnez	a5,ffffffffc02012c4 <default_check+0x472>
    free_page(p);
ffffffffc0200fe6:	854e                	mv	a0,s3
ffffffffc0200fe8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200fea:	000de797          	auipc	a5,0xde
ffffffffc0200fee:	2f87bf23          	sd	s8,766(a5) # ffffffffc02df2e8 <free_area>
ffffffffc0200ff2:	000de797          	auipc	a5,0xde
ffffffffc0200ff6:	2f77bf23          	sd	s7,766(a5) # ffffffffc02df2f0 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200ffa:	000de797          	auipc	a5,0xde
ffffffffc0200ffe:	2f67af23          	sw	s6,766(a5) # ffffffffc02df2f8 <free_area+0x10>
    free_page(p);
ffffffffc0201002:	6b9000ef          	jal	ra,ffffffffc0201eba <free_pages>
    free_page(p1);
ffffffffc0201006:	4585                	li	a1,1
ffffffffc0201008:	8556                	mv	a0,s5
ffffffffc020100a:	6b1000ef          	jal	ra,ffffffffc0201eba <free_pages>
    free_page(p2);
ffffffffc020100e:	4585                	li	a1,1
ffffffffc0201010:	8552                	mv	a0,s4
ffffffffc0201012:	6a9000ef          	jal	ra,ffffffffc0201eba <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201016:	4515                	li	a0,5
ffffffffc0201018:	61b000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc020101c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020101e:	28050363          	beqz	a0,ffffffffc02012a4 <default_check+0x452>
ffffffffc0201022:	651c                	ld	a5,8(a0)
ffffffffc0201024:	8385                	srli	a5,a5,0x1
ffffffffc0201026:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0201028:	54079e63          	bnez	a5,ffffffffc0201584 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc020102c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020102e:	00093b03          	ld	s6,0(s2)
ffffffffc0201032:	00893a83          	ld	s5,8(s2)
ffffffffc0201036:	000de797          	auipc	a5,0xde
ffffffffc020103a:	2b27b923          	sd	s2,690(a5) # ffffffffc02df2e8 <free_area>
ffffffffc020103e:	000de797          	auipc	a5,0xde
ffffffffc0201042:	2b27b923          	sd	s2,690(a5) # ffffffffc02df2f0 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0201046:	5ed000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc020104a:	50051d63          	bnez	a0,ffffffffc0201564 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020104e:	08098a13          	addi	s4,s3,128
ffffffffc0201052:	8552                	mv	a0,s4
ffffffffc0201054:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201056:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc020105a:	000de797          	auipc	a5,0xde
ffffffffc020105e:	2807af23          	sw	zero,670(a5) # ffffffffc02df2f8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201062:	659000ef          	jal	ra,ffffffffc0201eba <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201066:	4511                	li	a0,4
ffffffffc0201068:	5cb000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc020106c:	4c051c63          	bnez	a0,ffffffffc0201544 <default_check+0x6f2>
ffffffffc0201070:	0889b783          	ld	a5,136(s3)
ffffffffc0201074:	8385                	srli	a5,a5,0x1
ffffffffc0201076:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201078:	4a078663          	beqz	a5,ffffffffc0201524 <default_check+0x6d2>
ffffffffc020107c:	0909a703          	lw	a4,144(s3)
ffffffffc0201080:	478d                	li	a5,3
ffffffffc0201082:	4af71163          	bne	a4,a5,ffffffffc0201524 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201086:	450d                	li	a0,3
ffffffffc0201088:	5ab000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc020108c:	8c2a                	mv	s8,a0
ffffffffc020108e:	46050b63          	beqz	a0,ffffffffc0201504 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0201092:	4505                	li	a0,1
ffffffffc0201094:	59f000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc0201098:	44051663          	bnez	a0,ffffffffc02014e4 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc020109c:	438a1463          	bne	s4,s8,ffffffffc02014c4 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02010a0:	4585                	li	a1,1
ffffffffc02010a2:	854e                	mv	a0,s3
ffffffffc02010a4:	617000ef          	jal	ra,ffffffffc0201eba <free_pages>
    free_pages(p1, 3);
ffffffffc02010a8:	458d                	li	a1,3
ffffffffc02010aa:	8552                	mv	a0,s4
ffffffffc02010ac:	60f000ef          	jal	ra,ffffffffc0201eba <free_pages>
ffffffffc02010b0:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02010b4:	04098c13          	addi	s8,s3,64
ffffffffc02010b8:	8385                	srli	a5,a5,0x1
ffffffffc02010ba:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010bc:	3e078463          	beqz	a5,ffffffffc02014a4 <default_check+0x652>
ffffffffc02010c0:	0109a703          	lw	a4,16(s3)
ffffffffc02010c4:	4785                	li	a5,1
ffffffffc02010c6:	3cf71f63          	bne	a4,a5,ffffffffc02014a4 <default_check+0x652>
ffffffffc02010ca:	008a3783          	ld	a5,8(s4)
ffffffffc02010ce:	8385                	srli	a5,a5,0x1
ffffffffc02010d0:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010d2:	3a078963          	beqz	a5,ffffffffc0201484 <default_check+0x632>
ffffffffc02010d6:	010a2703          	lw	a4,16(s4)
ffffffffc02010da:	478d                	li	a5,3
ffffffffc02010dc:	3af71463          	bne	a4,a5,ffffffffc0201484 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010e0:	4505                	li	a0,1
ffffffffc02010e2:	551000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc02010e6:	36a99f63          	bne	s3,a0,ffffffffc0201464 <default_check+0x612>
    free_page(p0);
ffffffffc02010ea:	4585                	li	a1,1
ffffffffc02010ec:	5cf000ef          	jal	ra,ffffffffc0201eba <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02010f0:	4509                	li	a0,2
ffffffffc02010f2:	541000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc02010f6:	34aa1763          	bne	s4,a0,ffffffffc0201444 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc02010fa:	4589                	li	a1,2
ffffffffc02010fc:	5bf000ef          	jal	ra,ffffffffc0201eba <free_pages>
    free_page(p2);
ffffffffc0201100:	4585                	li	a1,1
ffffffffc0201102:	8562                	mv	a0,s8
ffffffffc0201104:	5b7000ef          	jal	ra,ffffffffc0201eba <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201108:	4515                	li	a0,5
ffffffffc020110a:	529000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc020110e:	89aa                	mv	s3,a0
ffffffffc0201110:	48050a63          	beqz	a0,ffffffffc02015a4 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0201114:	4505                	li	a0,1
ffffffffc0201116:	51d000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc020111a:	2e051563          	bnez	a0,ffffffffc0201404 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc020111e:	01092783          	lw	a5,16(s2)
ffffffffc0201122:	2c079163          	bnez	a5,ffffffffc02013e4 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201126:	4595                	li	a1,5
ffffffffc0201128:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020112a:	000de797          	auipc	a5,0xde
ffffffffc020112e:	1d77a723          	sw	s7,462(a5) # ffffffffc02df2f8 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0201132:	000de797          	auipc	a5,0xde
ffffffffc0201136:	1b67bb23          	sd	s6,438(a5) # ffffffffc02df2e8 <free_area>
ffffffffc020113a:	000de797          	auipc	a5,0xde
ffffffffc020113e:	1b57bb23          	sd	s5,438(a5) # ffffffffc02df2f0 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0201142:	579000ef          	jal	ra,ffffffffc0201eba <free_pages>
    return listelm->next;
ffffffffc0201146:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020114a:	01278963          	beq	a5,s2,ffffffffc020115c <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020114e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201152:	679c                	ld	a5,8(a5)
ffffffffc0201154:	34fd                	addiw	s1,s1,-1
ffffffffc0201156:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201158:	ff279be3          	bne	a5,s2,ffffffffc020114e <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc020115c:	26049463          	bnez	s1,ffffffffc02013c4 <default_check+0x572>
    assert(total == 0);
ffffffffc0201160:	46041263          	bnez	s0,ffffffffc02015c4 <default_check+0x772>
}
ffffffffc0201164:	60a6                	ld	ra,72(sp)
ffffffffc0201166:	6406                	ld	s0,64(sp)
ffffffffc0201168:	74e2                	ld	s1,56(sp)
ffffffffc020116a:	7942                	ld	s2,48(sp)
ffffffffc020116c:	79a2                	ld	s3,40(sp)
ffffffffc020116e:	7a02                	ld	s4,32(sp)
ffffffffc0201170:	6ae2                	ld	s5,24(sp)
ffffffffc0201172:	6b42                	ld	s6,16(sp)
ffffffffc0201174:	6ba2                	ld	s7,8(sp)
ffffffffc0201176:	6c02                	ld	s8,0(sp)
ffffffffc0201178:	6161                	addi	sp,sp,80
ffffffffc020117a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020117c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020117e:	4401                	li	s0,0
ffffffffc0201180:	4481                	li	s1,0
ffffffffc0201182:	b30d                	j	ffffffffc0200ea4 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0201184:	00007697          	auipc	a3,0x7
ffffffffc0201188:	d2468693          	addi	a3,a3,-732 # ffffffffc0207ea8 <commands+0x878>
ffffffffc020118c:	00007617          	auipc	a2,0x7
ffffffffc0201190:	96460613          	addi	a2,a2,-1692 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201194:	0ef00593          	li	a1,239
ffffffffc0201198:	00007517          	auipc	a0,0x7
ffffffffc020119c:	d2050513          	addi	a0,a0,-736 # ffffffffc0207eb8 <commands+0x888>
ffffffffc02011a0:	ae8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02011a4:	00007697          	auipc	a3,0x7
ffffffffc02011a8:	dac68693          	addi	a3,a3,-596 # ffffffffc0207f50 <commands+0x920>
ffffffffc02011ac:	00007617          	auipc	a2,0x7
ffffffffc02011b0:	94460613          	addi	a2,a2,-1724 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02011b4:	0bc00593          	li	a1,188
ffffffffc02011b8:	00007517          	auipc	a0,0x7
ffffffffc02011bc:	d0050513          	addi	a0,a0,-768 # ffffffffc0207eb8 <commands+0x888>
ffffffffc02011c0:	ac8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02011c4:	00007697          	auipc	a3,0x7
ffffffffc02011c8:	db468693          	addi	a3,a3,-588 # ffffffffc0207f78 <commands+0x948>
ffffffffc02011cc:	00007617          	auipc	a2,0x7
ffffffffc02011d0:	92460613          	addi	a2,a2,-1756 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02011d4:	0bd00593          	li	a1,189
ffffffffc02011d8:	00007517          	auipc	a0,0x7
ffffffffc02011dc:	ce050513          	addi	a0,a0,-800 # ffffffffc0207eb8 <commands+0x888>
ffffffffc02011e0:	aa8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02011e4:	00007697          	auipc	a3,0x7
ffffffffc02011e8:	dd468693          	addi	a3,a3,-556 # ffffffffc0207fb8 <commands+0x988>
ffffffffc02011ec:	00007617          	auipc	a2,0x7
ffffffffc02011f0:	90460613          	addi	a2,a2,-1788 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02011f4:	0bf00593          	li	a1,191
ffffffffc02011f8:	00007517          	auipc	a0,0x7
ffffffffc02011fc:	cc050513          	addi	a0,a0,-832 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201200:	a88ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201204:	00007697          	auipc	a3,0x7
ffffffffc0201208:	e3c68693          	addi	a3,a3,-452 # ffffffffc0208040 <commands+0xa10>
ffffffffc020120c:	00007617          	auipc	a2,0x7
ffffffffc0201210:	8e460613          	addi	a2,a2,-1820 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201214:	0d800593          	li	a1,216
ffffffffc0201218:	00007517          	auipc	a0,0x7
ffffffffc020121c:	ca050513          	addi	a0,a0,-864 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201220:	a68ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201224:	00007697          	auipc	a3,0x7
ffffffffc0201228:	ccc68693          	addi	a3,a3,-820 # ffffffffc0207ef0 <commands+0x8c0>
ffffffffc020122c:	00007617          	auipc	a2,0x7
ffffffffc0201230:	8c460613          	addi	a2,a2,-1852 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201234:	0d100593          	li	a1,209
ffffffffc0201238:	00007517          	auipc	a0,0x7
ffffffffc020123c:	c8050513          	addi	a0,a0,-896 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201240:	a48ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free == 3);
ffffffffc0201244:	00007697          	auipc	a3,0x7
ffffffffc0201248:	dec68693          	addi	a3,a3,-532 # ffffffffc0208030 <commands+0xa00>
ffffffffc020124c:	00007617          	auipc	a2,0x7
ffffffffc0201250:	8a460613          	addi	a2,a2,-1884 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201254:	0cf00593          	li	a1,207
ffffffffc0201258:	00007517          	auipc	a0,0x7
ffffffffc020125c:	c6050513          	addi	a0,a0,-928 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201260:	a28ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201264:	00007697          	auipc	a3,0x7
ffffffffc0201268:	db468693          	addi	a3,a3,-588 # ffffffffc0208018 <commands+0x9e8>
ffffffffc020126c:	00007617          	auipc	a2,0x7
ffffffffc0201270:	88460613          	addi	a2,a2,-1916 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201274:	0ca00593          	li	a1,202
ffffffffc0201278:	00007517          	auipc	a0,0x7
ffffffffc020127c:	c4050513          	addi	a0,a0,-960 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201280:	a08ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201284:	00007697          	auipc	a3,0x7
ffffffffc0201288:	d7468693          	addi	a3,a3,-652 # ffffffffc0207ff8 <commands+0x9c8>
ffffffffc020128c:	00007617          	auipc	a2,0x7
ffffffffc0201290:	86460613          	addi	a2,a2,-1948 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201294:	0c100593          	li	a1,193
ffffffffc0201298:	00007517          	auipc	a0,0x7
ffffffffc020129c:	c2050513          	addi	a0,a0,-992 # ffffffffc0207eb8 <commands+0x888>
ffffffffc02012a0:	9e8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(p0 != NULL);
ffffffffc02012a4:	00007697          	auipc	a3,0x7
ffffffffc02012a8:	de468693          	addi	a3,a3,-540 # ffffffffc0208088 <commands+0xa58>
ffffffffc02012ac:	00007617          	auipc	a2,0x7
ffffffffc02012b0:	84460613          	addi	a2,a2,-1980 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02012b4:	0f700593          	li	a1,247
ffffffffc02012b8:	00007517          	auipc	a0,0x7
ffffffffc02012bc:	c0050513          	addi	a0,a0,-1024 # ffffffffc0207eb8 <commands+0x888>
ffffffffc02012c0:	9c8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free == 0);
ffffffffc02012c4:	00007697          	auipc	a3,0x7
ffffffffc02012c8:	db468693          	addi	a3,a3,-588 # ffffffffc0208078 <commands+0xa48>
ffffffffc02012cc:	00007617          	auipc	a2,0x7
ffffffffc02012d0:	82460613          	addi	a2,a2,-2012 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02012d4:	0de00593          	li	a1,222
ffffffffc02012d8:	00007517          	auipc	a0,0x7
ffffffffc02012dc:	be050513          	addi	a0,a0,-1056 # ffffffffc0207eb8 <commands+0x888>
ffffffffc02012e0:	9a8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012e4:	00007697          	auipc	a3,0x7
ffffffffc02012e8:	d3468693          	addi	a3,a3,-716 # ffffffffc0208018 <commands+0x9e8>
ffffffffc02012ec:	00007617          	auipc	a2,0x7
ffffffffc02012f0:	80460613          	addi	a2,a2,-2044 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02012f4:	0dc00593          	li	a1,220
ffffffffc02012f8:	00007517          	auipc	a0,0x7
ffffffffc02012fc:	bc050513          	addi	a0,a0,-1088 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201300:	988ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201304:	00007697          	auipc	a3,0x7
ffffffffc0201308:	d5468693          	addi	a3,a3,-684 # ffffffffc0208058 <commands+0xa28>
ffffffffc020130c:	00006617          	auipc	a2,0x6
ffffffffc0201310:	7e460613          	addi	a2,a2,2020 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201314:	0db00593          	li	a1,219
ffffffffc0201318:	00007517          	auipc	a0,0x7
ffffffffc020131c:	ba050513          	addi	a0,a0,-1120 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201320:	968ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201324:	00007697          	auipc	a3,0x7
ffffffffc0201328:	bcc68693          	addi	a3,a3,-1076 # ffffffffc0207ef0 <commands+0x8c0>
ffffffffc020132c:	00006617          	auipc	a2,0x6
ffffffffc0201330:	7c460613          	addi	a2,a2,1988 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201334:	0b800593          	li	a1,184
ffffffffc0201338:	00007517          	auipc	a0,0x7
ffffffffc020133c:	b8050513          	addi	a0,a0,-1152 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201340:	948ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201344:	00007697          	auipc	a3,0x7
ffffffffc0201348:	cd468693          	addi	a3,a3,-812 # ffffffffc0208018 <commands+0x9e8>
ffffffffc020134c:	00006617          	auipc	a2,0x6
ffffffffc0201350:	7a460613          	addi	a2,a2,1956 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201354:	0d500593          	li	a1,213
ffffffffc0201358:	00007517          	auipc	a0,0x7
ffffffffc020135c:	b6050513          	addi	a0,a0,-1184 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201360:	928ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201364:	00007697          	auipc	a3,0x7
ffffffffc0201368:	bcc68693          	addi	a3,a3,-1076 # ffffffffc0207f30 <commands+0x900>
ffffffffc020136c:	00006617          	auipc	a2,0x6
ffffffffc0201370:	78460613          	addi	a2,a2,1924 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201374:	0d300593          	li	a1,211
ffffffffc0201378:	00007517          	auipc	a0,0x7
ffffffffc020137c:	b4050513          	addi	a0,a0,-1216 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201380:	908ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201384:	00007697          	auipc	a3,0x7
ffffffffc0201388:	b8c68693          	addi	a3,a3,-1140 # ffffffffc0207f10 <commands+0x8e0>
ffffffffc020138c:	00006617          	auipc	a2,0x6
ffffffffc0201390:	76460613          	addi	a2,a2,1892 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201394:	0d200593          	li	a1,210
ffffffffc0201398:	00007517          	auipc	a0,0x7
ffffffffc020139c:	b2050513          	addi	a0,a0,-1248 # ffffffffc0207eb8 <commands+0x888>
ffffffffc02013a0:	8e8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013a4:	00007697          	auipc	a3,0x7
ffffffffc02013a8:	b8c68693          	addi	a3,a3,-1140 # ffffffffc0207f30 <commands+0x900>
ffffffffc02013ac:	00006617          	auipc	a2,0x6
ffffffffc02013b0:	74460613          	addi	a2,a2,1860 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02013b4:	0ba00593          	li	a1,186
ffffffffc02013b8:	00007517          	auipc	a0,0x7
ffffffffc02013bc:	b0050513          	addi	a0,a0,-1280 # ffffffffc0207eb8 <commands+0x888>
ffffffffc02013c0:	8c8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(count == 0);
ffffffffc02013c4:	00007697          	auipc	a3,0x7
ffffffffc02013c8:	e1468693          	addi	a3,a3,-492 # ffffffffc02081d8 <commands+0xba8>
ffffffffc02013cc:	00006617          	auipc	a2,0x6
ffffffffc02013d0:	72460613          	addi	a2,a2,1828 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02013d4:	12400593          	li	a1,292
ffffffffc02013d8:	00007517          	auipc	a0,0x7
ffffffffc02013dc:	ae050513          	addi	a0,a0,-1312 # ffffffffc0207eb8 <commands+0x888>
ffffffffc02013e0:	8a8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free == 0);
ffffffffc02013e4:	00007697          	auipc	a3,0x7
ffffffffc02013e8:	c9468693          	addi	a3,a3,-876 # ffffffffc0208078 <commands+0xa48>
ffffffffc02013ec:	00006617          	auipc	a2,0x6
ffffffffc02013f0:	70460613          	addi	a2,a2,1796 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02013f4:	11900593          	li	a1,281
ffffffffc02013f8:	00007517          	auipc	a0,0x7
ffffffffc02013fc:	ac050513          	addi	a0,a0,-1344 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201400:	888ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201404:	00007697          	auipc	a3,0x7
ffffffffc0201408:	c1468693          	addi	a3,a3,-1004 # ffffffffc0208018 <commands+0x9e8>
ffffffffc020140c:	00006617          	auipc	a2,0x6
ffffffffc0201410:	6e460613          	addi	a2,a2,1764 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201414:	11700593          	li	a1,279
ffffffffc0201418:	00007517          	auipc	a0,0x7
ffffffffc020141c:	aa050513          	addi	a0,a0,-1376 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201420:	868ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201424:	00007697          	auipc	a3,0x7
ffffffffc0201428:	bb468693          	addi	a3,a3,-1100 # ffffffffc0207fd8 <commands+0x9a8>
ffffffffc020142c:	00006617          	auipc	a2,0x6
ffffffffc0201430:	6c460613          	addi	a2,a2,1732 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201434:	0c000593          	li	a1,192
ffffffffc0201438:	00007517          	auipc	a0,0x7
ffffffffc020143c:	a8050513          	addi	a0,a0,-1408 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201440:	848ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201444:	00007697          	auipc	a3,0x7
ffffffffc0201448:	d5468693          	addi	a3,a3,-684 # ffffffffc0208198 <commands+0xb68>
ffffffffc020144c:	00006617          	auipc	a2,0x6
ffffffffc0201450:	6a460613          	addi	a2,a2,1700 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201454:	11100593          	li	a1,273
ffffffffc0201458:	00007517          	auipc	a0,0x7
ffffffffc020145c:	a6050513          	addi	a0,a0,-1440 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201460:	828ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201464:	00007697          	auipc	a3,0x7
ffffffffc0201468:	d1468693          	addi	a3,a3,-748 # ffffffffc0208178 <commands+0xb48>
ffffffffc020146c:	00006617          	auipc	a2,0x6
ffffffffc0201470:	68460613          	addi	a2,a2,1668 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201474:	10f00593          	li	a1,271
ffffffffc0201478:	00007517          	auipc	a0,0x7
ffffffffc020147c:	a4050513          	addi	a0,a0,-1472 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201480:	808ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201484:	00007697          	auipc	a3,0x7
ffffffffc0201488:	ccc68693          	addi	a3,a3,-820 # ffffffffc0208150 <commands+0xb20>
ffffffffc020148c:	00006617          	auipc	a2,0x6
ffffffffc0201490:	66460613          	addi	a2,a2,1636 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201494:	10d00593          	li	a1,269
ffffffffc0201498:	00007517          	auipc	a0,0x7
ffffffffc020149c:	a2050513          	addi	a0,a0,-1504 # ffffffffc0207eb8 <commands+0x888>
ffffffffc02014a0:	fe9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02014a4:	00007697          	auipc	a3,0x7
ffffffffc02014a8:	c8468693          	addi	a3,a3,-892 # ffffffffc0208128 <commands+0xaf8>
ffffffffc02014ac:	00006617          	auipc	a2,0x6
ffffffffc02014b0:	64460613          	addi	a2,a2,1604 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02014b4:	10c00593          	li	a1,268
ffffffffc02014b8:	00007517          	auipc	a0,0x7
ffffffffc02014bc:	a0050513          	addi	a0,a0,-1536 # ffffffffc0207eb8 <commands+0x888>
ffffffffc02014c0:	fc9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02014c4:	00007697          	auipc	a3,0x7
ffffffffc02014c8:	c5468693          	addi	a3,a3,-940 # ffffffffc0208118 <commands+0xae8>
ffffffffc02014cc:	00006617          	auipc	a2,0x6
ffffffffc02014d0:	62460613          	addi	a2,a2,1572 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02014d4:	10700593          	li	a1,263
ffffffffc02014d8:	00007517          	auipc	a0,0x7
ffffffffc02014dc:	9e050513          	addi	a0,a0,-1568 # ffffffffc0207eb8 <commands+0x888>
ffffffffc02014e0:	fa9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014e4:	00007697          	auipc	a3,0x7
ffffffffc02014e8:	b3468693          	addi	a3,a3,-1228 # ffffffffc0208018 <commands+0x9e8>
ffffffffc02014ec:	00006617          	auipc	a2,0x6
ffffffffc02014f0:	60460613          	addi	a2,a2,1540 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02014f4:	10600593          	li	a1,262
ffffffffc02014f8:	00007517          	auipc	a0,0x7
ffffffffc02014fc:	9c050513          	addi	a0,a0,-1600 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201500:	f89fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201504:	00007697          	auipc	a3,0x7
ffffffffc0201508:	bf468693          	addi	a3,a3,-1036 # ffffffffc02080f8 <commands+0xac8>
ffffffffc020150c:	00006617          	auipc	a2,0x6
ffffffffc0201510:	5e460613          	addi	a2,a2,1508 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201514:	10500593          	li	a1,261
ffffffffc0201518:	00007517          	auipc	a0,0x7
ffffffffc020151c:	9a050513          	addi	a0,a0,-1632 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201520:	f69fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201524:	00007697          	auipc	a3,0x7
ffffffffc0201528:	ba468693          	addi	a3,a3,-1116 # ffffffffc02080c8 <commands+0xa98>
ffffffffc020152c:	00006617          	auipc	a2,0x6
ffffffffc0201530:	5c460613          	addi	a2,a2,1476 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201534:	10400593          	li	a1,260
ffffffffc0201538:	00007517          	auipc	a0,0x7
ffffffffc020153c:	98050513          	addi	a0,a0,-1664 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201540:	f49fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201544:	00007697          	auipc	a3,0x7
ffffffffc0201548:	b6c68693          	addi	a3,a3,-1172 # ffffffffc02080b0 <commands+0xa80>
ffffffffc020154c:	00006617          	auipc	a2,0x6
ffffffffc0201550:	5a460613          	addi	a2,a2,1444 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201554:	10300593          	li	a1,259
ffffffffc0201558:	00007517          	auipc	a0,0x7
ffffffffc020155c:	96050513          	addi	a0,a0,-1696 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201560:	f29fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201564:	00007697          	auipc	a3,0x7
ffffffffc0201568:	ab468693          	addi	a3,a3,-1356 # ffffffffc0208018 <commands+0x9e8>
ffffffffc020156c:	00006617          	auipc	a2,0x6
ffffffffc0201570:	58460613          	addi	a2,a2,1412 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201574:	0fd00593          	li	a1,253
ffffffffc0201578:	00007517          	auipc	a0,0x7
ffffffffc020157c:	94050513          	addi	a0,a0,-1728 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201580:	f09fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201584:	00007697          	auipc	a3,0x7
ffffffffc0201588:	b1468693          	addi	a3,a3,-1260 # ffffffffc0208098 <commands+0xa68>
ffffffffc020158c:	00006617          	auipc	a2,0x6
ffffffffc0201590:	56460613          	addi	a2,a2,1380 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201594:	0f800593          	li	a1,248
ffffffffc0201598:	00007517          	auipc	a0,0x7
ffffffffc020159c:	92050513          	addi	a0,a0,-1760 # ffffffffc0207eb8 <commands+0x888>
ffffffffc02015a0:	ee9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02015a4:	00007697          	auipc	a3,0x7
ffffffffc02015a8:	c1468693          	addi	a3,a3,-1004 # ffffffffc02081b8 <commands+0xb88>
ffffffffc02015ac:	00006617          	auipc	a2,0x6
ffffffffc02015b0:	54460613          	addi	a2,a2,1348 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02015b4:	11600593          	li	a1,278
ffffffffc02015b8:	00007517          	auipc	a0,0x7
ffffffffc02015bc:	90050513          	addi	a0,a0,-1792 # ffffffffc0207eb8 <commands+0x888>
ffffffffc02015c0:	ec9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(total == 0);
ffffffffc02015c4:	00007697          	auipc	a3,0x7
ffffffffc02015c8:	c2468693          	addi	a3,a3,-988 # ffffffffc02081e8 <commands+0xbb8>
ffffffffc02015cc:	00006617          	auipc	a2,0x6
ffffffffc02015d0:	52460613          	addi	a2,a2,1316 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02015d4:	12500593          	li	a1,293
ffffffffc02015d8:	00007517          	auipc	a0,0x7
ffffffffc02015dc:	8e050513          	addi	a0,a0,-1824 # ffffffffc0207eb8 <commands+0x888>
ffffffffc02015e0:	ea9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(total == nr_free_pages());
ffffffffc02015e4:	00007697          	auipc	a3,0x7
ffffffffc02015e8:	8ec68693          	addi	a3,a3,-1812 # ffffffffc0207ed0 <commands+0x8a0>
ffffffffc02015ec:	00006617          	auipc	a2,0x6
ffffffffc02015f0:	50460613          	addi	a2,a2,1284 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02015f4:	0f200593          	li	a1,242
ffffffffc02015f8:	00007517          	auipc	a0,0x7
ffffffffc02015fc:	8c050513          	addi	a0,a0,-1856 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201600:	e89fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201604:	00007697          	auipc	a3,0x7
ffffffffc0201608:	90c68693          	addi	a3,a3,-1780 # ffffffffc0207f10 <commands+0x8e0>
ffffffffc020160c:	00006617          	auipc	a2,0x6
ffffffffc0201610:	4e460613          	addi	a2,a2,1252 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201614:	0b900593          	li	a1,185
ffffffffc0201618:	00007517          	auipc	a0,0x7
ffffffffc020161c:	8a050513          	addi	a0,a0,-1888 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201620:	e69fe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201624 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201624:	1141                	addi	sp,sp,-16
ffffffffc0201626:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201628:	16058e63          	beqz	a1,ffffffffc02017a4 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc020162c:	00659693          	slli	a3,a1,0x6
ffffffffc0201630:	96aa                	add	a3,a3,a0
ffffffffc0201632:	02d50d63          	beq	a0,a3,ffffffffc020166c <default_free_pages+0x48>
ffffffffc0201636:	651c                	ld	a5,8(a0)
ffffffffc0201638:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020163a:	14079563          	bnez	a5,ffffffffc0201784 <default_free_pages+0x160>
ffffffffc020163e:	651c                	ld	a5,8(a0)
ffffffffc0201640:	8385                	srli	a5,a5,0x1
ffffffffc0201642:	8b85                	andi	a5,a5,1
ffffffffc0201644:	14079063          	bnez	a5,ffffffffc0201784 <default_free_pages+0x160>
ffffffffc0201648:	87aa                	mv	a5,a0
ffffffffc020164a:	a809                	j	ffffffffc020165c <default_free_pages+0x38>
ffffffffc020164c:	6798                	ld	a4,8(a5)
ffffffffc020164e:	8b05                	andi	a4,a4,1
ffffffffc0201650:	12071a63          	bnez	a4,ffffffffc0201784 <default_free_pages+0x160>
ffffffffc0201654:	6798                	ld	a4,8(a5)
ffffffffc0201656:	8b09                	andi	a4,a4,2
ffffffffc0201658:	12071663          	bnez	a4,ffffffffc0201784 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc020165c:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201660:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201664:	04078793          	addi	a5,a5,64
ffffffffc0201668:	fed792e3          	bne	a5,a3,ffffffffc020164c <default_free_pages+0x28>
    base->property = n;
ffffffffc020166c:	2581                	sext.w	a1,a1
ffffffffc020166e:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201670:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201674:	4789                	li	a5,2
ffffffffc0201676:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020167a:	000de697          	auipc	a3,0xde
ffffffffc020167e:	c6e68693          	addi	a3,a3,-914 # ffffffffc02df2e8 <free_area>
ffffffffc0201682:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201684:	669c                	ld	a5,8(a3)
ffffffffc0201686:	9db9                	addw	a1,a1,a4
ffffffffc0201688:	000de717          	auipc	a4,0xde
ffffffffc020168c:	c6b72823          	sw	a1,-912(a4) # ffffffffc02df2f8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201690:	0cd78163          	beq	a5,a3,ffffffffc0201752 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201694:	fe878713          	addi	a4,a5,-24
ffffffffc0201698:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020169a:	4801                	li	a6,0
ffffffffc020169c:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02016a0:	00e56a63          	bltu	a0,a4,ffffffffc02016b4 <default_free_pages+0x90>
    return listelm->next;
ffffffffc02016a4:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02016a6:	04d70f63          	beq	a4,a3,ffffffffc0201704 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016aa:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02016ac:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02016b0:	fee57ae3          	bleu	a4,a0,ffffffffc02016a4 <default_free_pages+0x80>
ffffffffc02016b4:	00080663          	beqz	a6,ffffffffc02016c0 <default_free_pages+0x9c>
ffffffffc02016b8:	000de817          	auipc	a6,0xde
ffffffffc02016bc:	c2b83823          	sd	a1,-976(a6) # ffffffffc02df2e8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02016c0:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02016c2:	e390                	sd	a2,0(a5)
ffffffffc02016c4:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02016c6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016c8:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02016ca:	06d58a63          	beq	a1,a3,ffffffffc020173e <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc02016ce:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02016d2:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02016d6:	02061793          	slli	a5,a2,0x20
ffffffffc02016da:	83e9                	srli	a5,a5,0x1a
ffffffffc02016dc:	97ba                	add	a5,a5,a4
ffffffffc02016de:	04f51b63          	bne	a0,a5,ffffffffc0201734 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc02016e2:	491c                	lw	a5,16(a0)
ffffffffc02016e4:	9e3d                	addw	a2,a2,a5
ffffffffc02016e6:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02016ea:	57f5                	li	a5,-3
ffffffffc02016ec:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016f0:	01853803          	ld	a6,24(a0)
ffffffffc02016f4:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc02016f6:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02016f8:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc02016fc:	659c                	ld	a5,8(a1)
ffffffffc02016fe:	01063023          	sd	a6,0(a2)
ffffffffc0201702:	a815                	j	ffffffffc0201736 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0201704:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201706:	f114                	sd	a3,32(a0)
ffffffffc0201708:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020170a:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020170c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020170e:	00d70563          	beq	a4,a3,ffffffffc0201718 <default_free_pages+0xf4>
ffffffffc0201712:	4805                	li	a6,1
ffffffffc0201714:	87ba                	mv	a5,a4
ffffffffc0201716:	bf59                	j	ffffffffc02016ac <default_free_pages+0x88>
ffffffffc0201718:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020171a:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020171c:	00d78d63          	beq	a5,a3,ffffffffc0201736 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0201720:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201724:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201728:	02061793          	slli	a5,a2,0x20
ffffffffc020172c:	83e9                	srli	a5,a5,0x1a
ffffffffc020172e:	97ba                	add	a5,a5,a4
ffffffffc0201730:	faf509e3          	beq	a0,a5,ffffffffc02016e2 <default_free_pages+0xbe>
ffffffffc0201734:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201736:	fe878713          	addi	a4,a5,-24
ffffffffc020173a:	00d78963          	beq	a5,a3,ffffffffc020174c <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc020173e:	4910                	lw	a2,16(a0)
ffffffffc0201740:	02061693          	slli	a3,a2,0x20
ffffffffc0201744:	82e9                	srli	a3,a3,0x1a
ffffffffc0201746:	96aa                	add	a3,a3,a0
ffffffffc0201748:	00d70e63          	beq	a4,a3,ffffffffc0201764 <default_free_pages+0x140>
}
ffffffffc020174c:	60a2                	ld	ra,8(sp)
ffffffffc020174e:	0141                	addi	sp,sp,16
ffffffffc0201750:	8082                	ret
ffffffffc0201752:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201754:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201758:	e398                	sd	a4,0(a5)
ffffffffc020175a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020175c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020175e:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201760:	0141                	addi	sp,sp,16
ffffffffc0201762:	8082                	ret
            base->property += p->property;
ffffffffc0201764:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201768:	ff078693          	addi	a3,a5,-16
ffffffffc020176c:	9e39                	addw	a2,a2,a4
ffffffffc020176e:	c910                	sw	a2,16(a0)
ffffffffc0201770:	5775                	li	a4,-3
ffffffffc0201772:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201776:	6398                	ld	a4,0(a5)
ffffffffc0201778:	679c                	ld	a5,8(a5)
}
ffffffffc020177a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020177c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020177e:	e398                	sd	a4,0(a5)
ffffffffc0201780:	0141                	addi	sp,sp,16
ffffffffc0201782:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201784:	00007697          	auipc	a3,0x7
ffffffffc0201788:	a7468693          	addi	a3,a3,-1420 # ffffffffc02081f8 <commands+0xbc8>
ffffffffc020178c:	00006617          	auipc	a2,0x6
ffffffffc0201790:	36460613          	addi	a2,a2,868 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201794:	08200593          	li	a1,130
ffffffffc0201798:	00006517          	auipc	a0,0x6
ffffffffc020179c:	72050513          	addi	a0,a0,1824 # ffffffffc0207eb8 <commands+0x888>
ffffffffc02017a0:	ce9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(n > 0);
ffffffffc02017a4:	00007697          	auipc	a3,0x7
ffffffffc02017a8:	a7c68693          	addi	a3,a3,-1412 # ffffffffc0208220 <commands+0xbf0>
ffffffffc02017ac:	00006617          	auipc	a2,0x6
ffffffffc02017b0:	34460613          	addi	a2,a2,836 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02017b4:	07f00593          	li	a1,127
ffffffffc02017b8:	00006517          	auipc	a0,0x6
ffffffffc02017bc:	70050513          	addi	a0,a0,1792 # ffffffffc0207eb8 <commands+0x888>
ffffffffc02017c0:	cc9fe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02017c4 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02017c4:	c959                	beqz	a0,ffffffffc020185a <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02017c6:	000de597          	auipc	a1,0xde
ffffffffc02017ca:	b2258593          	addi	a1,a1,-1246 # ffffffffc02df2e8 <free_area>
ffffffffc02017ce:	0105a803          	lw	a6,16(a1)
ffffffffc02017d2:	862a                	mv	a2,a0
ffffffffc02017d4:	02081793          	slli	a5,a6,0x20
ffffffffc02017d8:	9381                	srli	a5,a5,0x20
ffffffffc02017da:	00a7ee63          	bltu	a5,a0,ffffffffc02017f6 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02017de:	87ae                	mv	a5,a1
ffffffffc02017e0:	a801                	j	ffffffffc02017f0 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02017e2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02017e6:	02071693          	slli	a3,a4,0x20
ffffffffc02017ea:	9281                	srli	a3,a3,0x20
ffffffffc02017ec:	00c6f763          	bleu	a2,a3,ffffffffc02017fa <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02017f0:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02017f2:	feb798e3          	bne	a5,a1,ffffffffc02017e2 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02017f6:	4501                	li	a0,0
}
ffffffffc02017f8:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02017fa:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc02017fe:	dd6d                	beqz	a0,ffffffffc02017f8 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201800:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201804:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0201808:	00060e1b          	sext.w	t3,a2
ffffffffc020180c:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201810:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201814:	02d67863          	bleu	a3,a2,ffffffffc0201844 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0201818:	061a                	slli	a2,a2,0x6
ffffffffc020181a:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc020181c:	41c7073b          	subw	a4,a4,t3
ffffffffc0201820:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201822:	00860693          	addi	a3,a2,8
ffffffffc0201826:	4709                	li	a4,2
ffffffffc0201828:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc020182c:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201830:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0201834:	0105a803          	lw	a6,16(a1)
ffffffffc0201838:	e314                	sd	a3,0(a4)
ffffffffc020183a:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc020183e:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0201840:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0201844:	41c8083b          	subw	a6,a6,t3
ffffffffc0201848:	000de717          	auipc	a4,0xde
ffffffffc020184c:	ab072823          	sw	a6,-1360(a4) # ffffffffc02df2f8 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201850:	5775                	li	a4,-3
ffffffffc0201852:	17c1                	addi	a5,a5,-16
ffffffffc0201854:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201858:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020185a:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020185c:	00007697          	auipc	a3,0x7
ffffffffc0201860:	9c468693          	addi	a3,a3,-1596 # ffffffffc0208220 <commands+0xbf0>
ffffffffc0201864:	00006617          	auipc	a2,0x6
ffffffffc0201868:	28c60613          	addi	a2,a2,652 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020186c:	06100593          	li	a1,97
ffffffffc0201870:	00006517          	auipc	a0,0x6
ffffffffc0201874:	64850513          	addi	a0,a0,1608 # ffffffffc0207eb8 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc0201878:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020187a:	c0ffe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020187e <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020187e:	1141                	addi	sp,sp,-16
ffffffffc0201880:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201882:	c1ed                	beqz	a1,ffffffffc0201964 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0201884:	00659693          	slli	a3,a1,0x6
ffffffffc0201888:	96aa                	add	a3,a3,a0
ffffffffc020188a:	02d50463          	beq	a0,a3,ffffffffc02018b2 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020188e:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0201890:	87aa                	mv	a5,a0
ffffffffc0201892:	8b05                	andi	a4,a4,1
ffffffffc0201894:	e709                	bnez	a4,ffffffffc020189e <default_init_memmap+0x20>
ffffffffc0201896:	a07d                	j	ffffffffc0201944 <default_init_memmap+0xc6>
ffffffffc0201898:	6798                	ld	a4,8(a5)
ffffffffc020189a:	8b05                	andi	a4,a4,1
ffffffffc020189c:	c745                	beqz	a4,ffffffffc0201944 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc020189e:	0007a823          	sw	zero,16(a5)
ffffffffc02018a2:	0007b423          	sd	zero,8(a5)
ffffffffc02018a6:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02018aa:	04078793          	addi	a5,a5,64
ffffffffc02018ae:	fed795e3          	bne	a5,a3,ffffffffc0201898 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc02018b2:	2581                	sext.w	a1,a1
ffffffffc02018b4:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018b6:	4789                	li	a5,2
ffffffffc02018b8:	00850713          	addi	a4,a0,8
ffffffffc02018bc:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02018c0:	000de697          	auipc	a3,0xde
ffffffffc02018c4:	a2868693          	addi	a3,a3,-1496 # ffffffffc02df2e8 <free_area>
ffffffffc02018c8:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02018ca:	669c                	ld	a5,8(a3)
ffffffffc02018cc:	9db9                	addw	a1,a1,a4
ffffffffc02018ce:	000de717          	auipc	a4,0xde
ffffffffc02018d2:	a2b72523          	sw	a1,-1494(a4) # ffffffffc02df2f8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02018d6:	04d78a63          	beq	a5,a3,ffffffffc020192a <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc02018da:	fe878713          	addi	a4,a5,-24
ffffffffc02018de:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02018e0:	4801                	li	a6,0
ffffffffc02018e2:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02018e6:	00e56a63          	bltu	a0,a4,ffffffffc02018fa <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc02018ea:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02018ec:	02d70563          	beq	a4,a3,ffffffffc0201916 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02018f0:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02018f2:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02018f6:	fee57ae3          	bleu	a4,a0,ffffffffc02018ea <default_init_memmap+0x6c>
ffffffffc02018fa:	00080663          	beqz	a6,ffffffffc0201906 <default_init_memmap+0x88>
ffffffffc02018fe:	000de717          	auipc	a4,0xde
ffffffffc0201902:	9eb73523          	sd	a1,-1558(a4) # ffffffffc02df2e8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201906:	6398                	ld	a4,0(a5)
}
ffffffffc0201908:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020190a:	e390                	sd	a2,0(a5)
ffffffffc020190c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020190e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201910:	ed18                	sd	a4,24(a0)
ffffffffc0201912:	0141                	addi	sp,sp,16
ffffffffc0201914:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201916:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201918:	f114                	sd	a3,32(a0)
ffffffffc020191a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020191c:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020191e:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201920:	00d70e63          	beq	a4,a3,ffffffffc020193c <default_init_memmap+0xbe>
ffffffffc0201924:	4805                	li	a6,1
ffffffffc0201926:	87ba                	mv	a5,a4
ffffffffc0201928:	b7e9                	j	ffffffffc02018f2 <default_init_memmap+0x74>
}
ffffffffc020192a:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020192c:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201930:	e398                	sd	a4,0(a5)
ffffffffc0201932:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201934:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201936:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201938:	0141                	addi	sp,sp,16
ffffffffc020193a:	8082                	ret
ffffffffc020193c:	60a2                	ld	ra,8(sp)
ffffffffc020193e:	e290                	sd	a2,0(a3)
ffffffffc0201940:	0141                	addi	sp,sp,16
ffffffffc0201942:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201944:	00007697          	auipc	a3,0x7
ffffffffc0201948:	8e468693          	addi	a3,a3,-1820 # ffffffffc0208228 <commands+0xbf8>
ffffffffc020194c:	00006617          	auipc	a2,0x6
ffffffffc0201950:	1a460613          	addi	a2,a2,420 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201954:	04800593          	li	a1,72
ffffffffc0201958:	00006517          	auipc	a0,0x6
ffffffffc020195c:	56050513          	addi	a0,a0,1376 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201960:	b29fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(n > 0);
ffffffffc0201964:	00007697          	auipc	a3,0x7
ffffffffc0201968:	8bc68693          	addi	a3,a3,-1860 # ffffffffc0208220 <commands+0xbf0>
ffffffffc020196c:	00006617          	auipc	a2,0x6
ffffffffc0201970:	18460613          	addi	a2,a2,388 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201974:	04500593          	li	a1,69
ffffffffc0201978:	00006517          	auipc	a0,0x6
ffffffffc020197c:	54050513          	addi	a0,a0,1344 # ffffffffc0207eb8 <commands+0x888>
ffffffffc0201980:	b09fe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201984 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201984:	c125                	beqz	a0,ffffffffc02019e4 <slob_free+0x60>
		return;

	if (size)
ffffffffc0201986:	e1a5                	bnez	a1,ffffffffc02019e6 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201988:	100027f3          	csrr	a5,sstatus
ffffffffc020198c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020198e:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201990:	e3bd                	bnez	a5,ffffffffc02019f6 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201992:	000d2797          	auipc	a5,0xd2
ffffffffc0201996:	4a678793          	addi	a5,a5,1190 # ffffffffc02d3e38 <slobfree>
ffffffffc020199a:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020199c:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020199e:	00a7fa63          	bleu	a0,a5,ffffffffc02019b2 <slob_free+0x2e>
ffffffffc02019a2:	00e56c63          	bltu	a0,a4,ffffffffc02019ba <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019a6:	00e7fa63          	bleu	a4,a5,ffffffffc02019ba <slob_free+0x36>
    return 0;
ffffffffc02019aa:	87ba                	mv	a5,a4
ffffffffc02019ac:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019ae:	fea7eae3          	bltu	a5,a0,ffffffffc02019a2 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019b2:	fee7ece3          	bltu	a5,a4,ffffffffc02019aa <slob_free+0x26>
ffffffffc02019b6:	fee57ae3          	bleu	a4,a0,ffffffffc02019aa <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc02019ba:	4110                	lw	a2,0(a0)
ffffffffc02019bc:	00461693          	slli	a3,a2,0x4
ffffffffc02019c0:	96aa                	add	a3,a3,a0
ffffffffc02019c2:	08d70b63          	beq	a4,a3,ffffffffc0201a58 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02019c6:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02019c8:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02019ca:	00469713          	slli	a4,a3,0x4
ffffffffc02019ce:	973e                	add	a4,a4,a5
ffffffffc02019d0:	08e50f63          	beq	a0,a4,ffffffffc0201a6e <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02019d4:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc02019d6:	000d2717          	auipc	a4,0xd2
ffffffffc02019da:	46f73123          	sd	a5,1122(a4) # ffffffffc02d3e38 <slobfree>
    if (flag) {
ffffffffc02019de:	c199                	beqz	a1,ffffffffc02019e4 <slob_free+0x60>
        intr_enable();
ffffffffc02019e0:	c6dfe06f          	j	ffffffffc020064c <intr_enable>
ffffffffc02019e4:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc02019e6:	05bd                	addi	a1,a1,15
ffffffffc02019e8:	8191                	srli	a1,a1,0x4
ffffffffc02019ea:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019ec:	100027f3          	csrr	a5,sstatus
ffffffffc02019f0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02019f2:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019f4:	dfd9                	beqz	a5,ffffffffc0201992 <slob_free+0xe>
{
ffffffffc02019f6:	1101                	addi	sp,sp,-32
ffffffffc02019f8:	e42a                	sd	a0,8(sp)
ffffffffc02019fa:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02019fc:	c57fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a00:	000d2797          	auipc	a5,0xd2
ffffffffc0201a04:	43878793          	addi	a5,a5,1080 # ffffffffc02d3e38 <slobfree>
ffffffffc0201a08:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201a0a:	6522                	ld	a0,8(sp)
ffffffffc0201a0c:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a0e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a10:	00a7fa63          	bleu	a0,a5,ffffffffc0201a24 <slob_free+0xa0>
ffffffffc0201a14:	00e56c63          	bltu	a0,a4,ffffffffc0201a2c <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a18:	00e7fa63          	bleu	a4,a5,ffffffffc0201a2c <slob_free+0xa8>
    return 0;
ffffffffc0201a1c:	87ba                	mv	a5,a4
ffffffffc0201a1e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a20:	fea7eae3          	bltu	a5,a0,ffffffffc0201a14 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a24:	fee7ece3          	bltu	a5,a4,ffffffffc0201a1c <slob_free+0x98>
ffffffffc0201a28:	fee57ae3          	bleu	a4,a0,ffffffffc0201a1c <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201a2c:	4110                	lw	a2,0(a0)
ffffffffc0201a2e:	00461693          	slli	a3,a2,0x4
ffffffffc0201a32:	96aa                	add	a3,a3,a0
ffffffffc0201a34:	04d70763          	beq	a4,a3,ffffffffc0201a82 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201a38:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a3a:	4394                	lw	a3,0(a5)
ffffffffc0201a3c:	00469713          	slli	a4,a3,0x4
ffffffffc0201a40:	973e                	add	a4,a4,a5
ffffffffc0201a42:	04e50663          	beq	a0,a4,ffffffffc0201a8e <slob_free+0x10a>
		cur->next = b;
ffffffffc0201a46:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201a48:	000d2717          	auipc	a4,0xd2
ffffffffc0201a4c:	3ef73823          	sd	a5,1008(a4) # ffffffffc02d3e38 <slobfree>
    if (flag) {
ffffffffc0201a50:	e58d                	bnez	a1,ffffffffc0201a7a <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201a52:	60e2                	ld	ra,24(sp)
ffffffffc0201a54:	6105                	addi	sp,sp,32
ffffffffc0201a56:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201a58:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a5a:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a5c:	9e35                	addw	a2,a2,a3
ffffffffc0201a5e:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201a60:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a62:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a64:	00469713          	slli	a4,a3,0x4
ffffffffc0201a68:	973e                	add	a4,a4,a5
ffffffffc0201a6a:	f6e515e3          	bne	a0,a4,ffffffffc02019d4 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201a6e:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201a70:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201a72:	9eb9                	addw	a3,a3,a4
ffffffffc0201a74:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201a76:	e790                	sd	a2,8(a5)
ffffffffc0201a78:	bfb9                	j	ffffffffc02019d6 <slob_free+0x52>
}
ffffffffc0201a7a:	60e2                	ld	ra,24(sp)
ffffffffc0201a7c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201a7e:	bcffe06f          	j	ffffffffc020064c <intr_enable>
		b->units += cur->next->units;
ffffffffc0201a82:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a84:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a86:	9e35                	addw	a2,a2,a3
ffffffffc0201a88:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201a8a:	e518                	sd	a4,8(a0)
ffffffffc0201a8c:	b77d                	j	ffffffffc0201a3a <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0201a8e:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201a90:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201a92:	9eb9                	addw	a3,a3,a4
ffffffffc0201a94:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201a96:	e790                	sd	a2,8(a5)
ffffffffc0201a98:	bf45                	j	ffffffffc0201a48 <slob_free+0xc4>

ffffffffc0201a9a <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201a9a:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201a9c:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201a9e:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201aa2:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201aa4:	38e000ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
  if(!page)
ffffffffc0201aa8:	c139                	beqz	a0,ffffffffc0201aee <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc0201aaa:	000de797          	auipc	a5,0xde
ffffffffc0201aae:	86e78793          	addi	a5,a5,-1938 # ffffffffc02df318 <pages>
ffffffffc0201ab2:	6394                	ld	a3,0(a5)
ffffffffc0201ab4:	00009797          	auipc	a5,0x9
ffffffffc0201ab8:	e0478793          	addi	a5,a5,-508 # ffffffffc020a8b8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201abc:	000dd717          	auipc	a4,0xdd
ffffffffc0201ac0:	7dc70713          	addi	a4,a4,2012 # ffffffffc02df298 <npage>
    return page - pages + nbase;
ffffffffc0201ac4:	40d506b3          	sub	a3,a0,a3
ffffffffc0201ac8:	6388                	ld	a0,0(a5)
ffffffffc0201aca:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201acc:	57fd                	li	a5,-1
ffffffffc0201ace:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0201ad0:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0201ad2:	83b1                	srli	a5,a5,0xc
ffffffffc0201ad4:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ad6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201ad8:	00e7ff63          	bleu	a4,a5,ffffffffc0201af6 <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0201adc:	000de797          	auipc	a5,0xde
ffffffffc0201ae0:	82c78793          	addi	a5,a5,-2004 # ffffffffc02df308 <va_pa_offset>
ffffffffc0201ae4:	6388                	ld	a0,0(a5)
}
ffffffffc0201ae6:	60a2                	ld	ra,8(sp)
ffffffffc0201ae8:	9536                	add	a0,a0,a3
ffffffffc0201aea:	0141                	addi	sp,sp,16
ffffffffc0201aec:	8082                	ret
ffffffffc0201aee:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0201af0:	4501                	li	a0,0
}
ffffffffc0201af2:	0141                	addi	sp,sp,16
ffffffffc0201af4:	8082                	ret
ffffffffc0201af6:	00006617          	auipc	a2,0x6
ffffffffc0201afa:	79260613          	addi	a2,a2,1938 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc0201afe:	06900593          	li	a1,105
ffffffffc0201b02:	00006517          	auipc	a0,0x6
ffffffffc0201b06:	7ae50513          	addi	a0,a0,1966 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc0201b0a:	97ffe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201b0e <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201b0e:	7179                	addi	sp,sp,-48
ffffffffc0201b10:	f406                	sd	ra,40(sp)
ffffffffc0201b12:	f022                	sd	s0,32(sp)
ffffffffc0201b14:	ec26                	sd	s1,24(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201b16:	01050713          	addi	a4,a0,16
ffffffffc0201b1a:	6785                	lui	a5,0x1
ffffffffc0201b1c:	0cf77b63          	bleu	a5,a4,ffffffffc0201bf2 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201b20:	00f50413          	addi	s0,a0,15
ffffffffc0201b24:	8011                	srli	s0,s0,0x4
ffffffffc0201b26:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b28:	10002673          	csrr	a2,sstatus
ffffffffc0201b2c:	8a09                	andi	a2,a2,2
ffffffffc0201b2e:	ea5d                	bnez	a2,ffffffffc0201be4 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0201b30:	000d2497          	auipc	s1,0xd2
ffffffffc0201b34:	30848493          	addi	s1,s1,776 # ffffffffc02d3e38 <slobfree>
ffffffffc0201b38:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b3a:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b3c:	4398                	lw	a4,0(a5)
ffffffffc0201b3e:	0a875763          	ble	s0,a4,ffffffffc0201bec <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc0201b42:	00f68a63          	beq	a3,a5,ffffffffc0201b56 <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b46:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b48:	4118                	lw	a4,0(a0)
ffffffffc0201b4a:	02875763          	ble	s0,a4,ffffffffc0201b78 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc0201b4e:	6094                	ld	a3,0(s1)
ffffffffc0201b50:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc0201b52:	fef69ae3          	bne	a3,a5,ffffffffc0201b46 <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc0201b56:	ea39                	bnez	a2,ffffffffc0201bac <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201b58:	4501                	li	a0,0
ffffffffc0201b5a:	f41ff0ef          	jal	ra,ffffffffc0201a9a <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201b5e:	cd29                	beqz	a0,ffffffffc0201bb8 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201b60:	6585                	lui	a1,0x1
ffffffffc0201b62:	e23ff0ef          	jal	ra,ffffffffc0201984 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b66:	10002673          	csrr	a2,sstatus
ffffffffc0201b6a:	8a09                	andi	a2,a2,2
ffffffffc0201b6c:	ea1d                	bnez	a2,ffffffffc0201ba2 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc0201b6e:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b70:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b72:	4118                	lw	a4,0(a0)
ffffffffc0201b74:	fc874de3          	blt	a4,s0,ffffffffc0201b4e <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc0201b78:	04e40663          	beq	s0,a4,ffffffffc0201bc4 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0201b7c:	00441693          	slli	a3,s0,0x4
ffffffffc0201b80:	96aa                	add	a3,a3,a0
ffffffffc0201b82:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201b84:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc0201b86:	9f01                	subw	a4,a4,s0
ffffffffc0201b88:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201b8a:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201b8c:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0201b8e:	000d2717          	auipc	a4,0xd2
ffffffffc0201b92:	2af73523          	sd	a5,682(a4) # ffffffffc02d3e38 <slobfree>
    if (flag) {
ffffffffc0201b96:	ee15                	bnez	a2,ffffffffc0201bd2 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0201b98:	70a2                	ld	ra,40(sp)
ffffffffc0201b9a:	7402                	ld	s0,32(sp)
ffffffffc0201b9c:	64e2                	ld	s1,24(sp)
ffffffffc0201b9e:	6145                	addi	sp,sp,48
ffffffffc0201ba0:	8082                	ret
        intr_disable();
ffffffffc0201ba2:	ab1fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201ba6:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201ba8:	609c                	ld	a5,0(s1)
ffffffffc0201baa:	b7d9                	j	ffffffffc0201b70 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0201bac:	aa1fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201bb0:	4501                	li	a0,0
ffffffffc0201bb2:	ee9ff0ef          	jal	ra,ffffffffc0201a9a <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201bb6:	f54d                	bnez	a0,ffffffffc0201b60 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc0201bb8:	70a2                	ld	ra,40(sp)
ffffffffc0201bba:	7402                	ld	s0,32(sp)
ffffffffc0201bbc:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0201bbe:	4501                	li	a0,0
}
ffffffffc0201bc0:	6145                	addi	sp,sp,48
ffffffffc0201bc2:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201bc4:	6518                	ld	a4,8(a0)
ffffffffc0201bc6:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc0201bc8:	000d2717          	auipc	a4,0xd2
ffffffffc0201bcc:	26f73823          	sd	a5,624(a4) # ffffffffc02d3e38 <slobfree>
    if (flag) {
ffffffffc0201bd0:	d661                	beqz	a2,ffffffffc0201b98 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0201bd2:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201bd4:	a79fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
}
ffffffffc0201bd8:	70a2                	ld	ra,40(sp)
ffffffffc0201bda:	7402                	ld	s0,32(sp)
ffffffffc0201bdc:	6522                	ld	a0,8(sp)
ffffffffc0201bde:	64e2                	ld	s1,24(sp)
ffffffffc0201be0:	6145                	addi	sp,sp,48
ffffffffc0201be2:	8082                	ret
        intr_disable();
ffffffffc0201be4:	a6ffe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201be8:	4605                	li	a2,1
ffffffffc0201bea:	b799                	j	ffffffffc0201b30 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201bec:	853e                	mv	a0,a5
ffffffffc0201bee:	87b6                	mv	a5,a3
ffffffffc0201bf0:	b761                	j	ffffffffc0201b78 <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201bf2:	00006697          	auipc	a3,0x6
ffffffffc0201bf6:	73668693          	addi	a3,a3,1846 # ffffffffc0208328 <default_pmm_manager+0xf0>
ffffffffc0201bfa:	00006617          	auipc	a2,0x6
ffffffffc0201bfe:	ef660613          	addi	a2,a2,-266 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0201c02:	06400593          	li	a1,100
ffffffffc0201c06:	00006517          	auipc	a0,0x6
ffffffffc0201c0a:	74250513          	addi	a0,a0,1858 # ffffffffc0208348 <default_pmm_manager+0x110>
ffffffffc0201c0e:	87bfe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201c12 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201c12:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201c14:	00006517          	auipc	a0,0x6
ffffffffc0201c18:	74c50513          	addi	a0,a0,1868 # ffffffffc0208360 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc0201c1c:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201c1e:	d74fe0ef          	jal	ra,ffffffffc0200192 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201c22:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c24:	00006517          	auipc	a0,0x6
ffffffffc0201c28:	6e450513          	addi	a0,a0,1764 # ffffffffc0208308 <default_pmm_manager+0xd0>
}
ffffffffc0201c2c:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c2e:	d64fe06f          	j	ffffffffc0200192 <cprintf>

ffffffffc0201c32 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201c32:	4501                	li	a0,0
ffffffffc0201c34:	8082                	ret

ffffffffc0201c36 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201c36:	1101                	addi	sp,sp,-32
ffffffffc0201c38:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c3a:	6905                	lui	s2,0x1
{
ffffffffc0201c3c:	e822                	sd	s0,16(sp)
ffffffffc0201c3e:	ec06                	sd	ra,24(sp)
ffffffffc0201c40:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c42:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8ae1>
{
ffffffffc0201c46:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c48:	04a7fc63          	bleu	a0,a5,ffffffffc0201ca0 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201c4c:	4561                	li	a0,24
ffffffffc0201c4e:	ec1ff0ef          	jal	ra,ffffffffc0201b0e <slob_alloc.isra.1.constprop.3>
ffffffffc0201c52:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201c54:	cd21                	beqz	a0,ffffffffc0201cac <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201c56:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201c5a:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c5c:	00f95763          	ble	a5,s2,ffffffffc0201c6a <kmalloc+0x34>
ffffffffc0201c60:	6705                	lui	a4,0x1
ffffffffc0201c62:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201c64:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c66:	fef74ee3          	blt	a4,a5,ffffffffc0201c62 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201c6a:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201c6c:	e2fff0ef          	jal	ra,ffffffffc0201a9a <__slob_get_free_pages.isra.0>
ffffffffc0201c70:	e488                	sd	a0,8(s1)
ffffffffc0201c72:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201c74:	c935                	beqz	a0,ffffffffc0201ce8 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c76:	100027f3          	csrr	a5,sstatus
ffffffffc0201c7a:	8b89                	andi	a5,a5,2
ffffffffc0201c7c:	e3a1                	bnez	a5,ffffffffc0201cbc <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201c7e:	000dd797          	auipc	a5,0xdd
ffffffffc0201c82:	60a78793          	addi	a5,a5,1546 # ffffffffc02df288 <bigblocks>
ffffffffc0201c86:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201c88:	000dd717          	auipc	a4,0xdd
ffffffffc0201c8c:	60973023          	sd	s1,1536(a4) # ffffffffc02df288 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201c90:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201c92:	8522                	mv	a0,s0
ffffffffc0201c94:	60e2                	ld	ra,24(sp)
ffffffffc0201c96:	6442                	ld	s0,16(sp)
ffffffffc0201c98:	64a2                	ld	s1,8(sp)
ffffffffc0201c9a:	6902                	ld	s2,0(sp)
ffffffffc0201c9c:	6105                	addi	sp,sp,32
ffffffffc0201c9e:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201ca0:	0541                	addi	a0,a0,16
ffffffffc0201ca2:	e6dff0ef          	jal	ra,ffffffffc0201b0e <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201ca6:	01050413          	addi	s0,a0,16
ffffffffc0201caa:	f565                	bnez	a0,ffffffffc0201c92 <kmalloc+0x5c>
ffffffffc0201cac:	4401                	li	s0,0
}
ffffffffc0201cae:	8522                	mv	a0,s0
ffffffffc0201cb0:	60e2                	ld	ra,24(sp)
ffffffffc0201cb2:	6442                	ld	s0,16(sp)
ffffffffc0201cb4:	64a2                	ld	s1,8(sp)
ffffffffc0201cb6:	6902                	ld	s2,0(sp)
ffffffffc0201cb8:	6105                	addi	sp,sp,32
ffffffffc0201cba:	8082                	ret
        intr_disable();
ffffffffc0201cbc:	997fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201cc0:	000dd797          	auipc	a5,0xdd
ffffffffc0201cc4:	5c878793          	addi	a5,a5,1480 # ffffffffc02df288 <bigblocks>
ffffffffc0201cc8:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201cca:	000dd717          	auipc	a4,0xdd
ffffffffc0201cce:	5a973f23          	sd	s1,1470(a4) # ffffffffc02df288 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201cd2:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201cd4:	979fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201cd8:	6480                	ld	s0,8(s1)
}
ffffffffc0201cda:	60e2                	ld	ra,24(sp)
ffffffffc0201cdc:	64a2                	ld	s1,8(sp)
ffffffffc0201cde:	8522                	mv	a0,s0
ffffffffc0201ce0:	6442                	ld	s0,16(sp)
ffffffffc0201ce2:	6902                	ld	s2,0(sp)
ffffffffc0201ce4:	6105                	addi	sp,sp,32
ffffffffc0201ce6:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ce8:	45e1                	li	a1,24
ffffffffc0201cea:	8526                	mv	a0,s1
ffffffffc0201cec:	c99ff0ef          	jal	ra,ffffffffc0201984 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201cf0:	b74d                	j	ffffffffc0201c92 <kmalloc+0x5c>

ffffffffc0201cf2 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201cf2:	c175                	beqz	a0,ffffffffc0201dd6 <kfree+0xe4>
{
ffffffffc0201cf4:	1101                	addi	sp,sp,-32
ffffffffc0201cf6:	e426                	sd	s1,8(sp)
ffffffffc0201cf8:	ec06                	sd	ra,24(sp)
ffffffffc0201cfa:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201cfc:	03451793          	slli	a5,a0,0x34
ffffffffc0201d00:	84aa                	mv	s1,a0
ffffffffc0201d02:	eb8d                	bnez	a5,ffffffffc0201d34 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d04:	100027f3          	csrr	a5,sstatus
ffffffffc0201d08:	8b89                	andi	a5,a5,2
ffffffffc0201d0a:	efc9                	bnez	a5,ffffffffc0201da4 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d0c:	000dd797          	auipc	a5,0xdd
ffffffffc0201d10:	57c78793          	addi	a5,a5,1404 # ffffffffc02df288 <bigblocks>
ffffffffc0201d14:	6394                	ld	a3,0(a5)
ffffffffc0201d16:	ce99                	beqz	a3,ffffffffc0201d34 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201d18:	669c                	ld	a5,8(a3)
ffffffffc0201d1a:	6a80                	ld	s0,16(a3)
ffffffffc0201d1c:	0af50e63          	beq	a0,a5,ffffffffc0201dd8 <kfree+0xe6>
    return 0;
ffffffffc0201d20:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d22:	c801                	beqz	s0,ffffffffc0201d32 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201d24:	6418                	ld	a4,8(s0)
ffffffffc0201d26:	681c                	ld	a5,16(s0)
ffffffffc0201d28:	00970f63          	beq	a4,s1,ffffffffc0201d46 <kfree+0x54>
ffffffffc0201d2c:	86a2                	mv	a3,s0
ffffffffc0201d2e:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d30:	f875                	bnez	s0,ffffffffc0201d24 <kfree+0x32>
    if (flag) {
ffffffffc0201d32:	e659                	bnez	a2,ffffffffc0201dc0 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201d34:	6442                	ld	s0,16(sp)
ffffffffc0201d36:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d38:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201d3c:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d3e:	4581                	li	a1,0
}
ffffffffc0201d40:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d42:	c43ff06f          	j	ffffffffc0201984 <slob_free>
				*last = bb->next;
ffffffffc0201d46:	ea9c                	sd	a5,16(a3)
ffffffffc0201d48:	e641                	bnez	a2,ffffffffc0201dd0 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0201d4a:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201d4e:	4018                	lw	a4,0(s0)
ffffffffc0201d50:	08f4ea63          	bltu	s1,a5,ffffffffc0201de4 <kfree+0xf2>
ffffffffc0201d54:	000dd797          	auipc	a5,0xdd
ffffffffc0201d58:	5b478793          	addi	a5,a5,1460 # ffffffffc02df308 <va_pa_offset>
ffffffffc0201d5c:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201d5e:	000dd797          	auipc	a5,0xdd
ffffffffc0201d62:	53a78793          	addi	a5,a5,1338 # ffffffffc02df298 <npage>
ffffffffc0201d66:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201d68:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201d6a:	80b1                	srli	s1,s1,0xc
ffffffffc0201d6c:	08f4f963          	bleu	a5,s1,ffffffffc0201dfe <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d70:	00009797          	auipc	a5,0x9
ffffffffc0201d74:	b4878793          	addi	a5,a5,-1208 # ffffffffc020a8b8 <nbase>
ffffffffc0201d78:	639c                	ld	a5,0(a5)
ffffffffc0201d7a:	000dd697          	auipc	a3,0xdd
ffffffffc0201d7e:	59e68693          	addi	a3,a3,1438 # ffffffffc02df318 <pages>
ffffffffc0201d82:	6288                	ld	a0,0(a3)
ffffffffc0201d84:	8c9d                	sub	s1,s1,a5
ffffffffc0201d86:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201d88:	4585                	li	a1,1
ffffffffc0201d8a:	9526                	add	a0,a0,s1
ffffffffc0201d8c:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201d90:	12a000ef          	jal	ra,ffffffffc0201eba <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d94:	8522                	mv	a0,s0
}
ffffffffc0201d96:	6442                	ld	s0,16(sp)
ffffffffc0201d98:	60e2                	ld	ra,24(sp)
ffffffffc0201d9a:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d9c:	45e1                	li	a1,24
}
ffffffffc0201d9e:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201da0:	be5ff06f          	j	ffffffffc0201984 <slob_free>
        intr_disable();
ffffffffc0201da4:	8affe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201da8:	000dd797          	auipc	a5,0xdd
ffffffffc0201dac:	4e078793          	addi	a5,a5,1248 # ffffffffc02df288 <bigblocks>
ffffffffc0201db0:	6394                	ld	a3,0(a5)
ffffffffc0201db2:	c699                	beqz	a3,ffffffffc0201dc0 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0201db4:	669c                	ld	a5,8(a3)
ffffffffc0201db6:	6a80                	ld	s0,16(a3)
ffffffffc0201db8:	00f48763          	beq	s1,a5,ffffffffc0201dc6 <kfree+0xd4>
        return 1;
ffffffffc0201dbc:	4605                	li	a2,1
ffffffffc0201dbe:	b795                	j	ffffffffc0201d22 <kfree+0x30>
        intr_enable();
ffffffffc0201dc0:	88dfe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201dc4:	bf85                	j	ffffffffc0201d34 <kfree+0x42>
				*last = bb->next;
ffffffffc0201dc6:	000dd797          	auipc	a5,0xdd
ffffffffc0201dca:	4c87b123          	sd	s0,1218(a5) # ffffffffc02df288 <bigblocks>
ffffffffc0201dce:	8436                	mv	s0,a3
ffffffffc0201dd0:	87dfe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201dd4:	bf9d                	j	ffffffffc0201d4a <kfree+0x58>
ffffffffc0201dd6:	8082                	ret
ffffffffc0201dd8:	000dd797          	auipc	a5,0xdd
ffffffffc0201ddc:	4a87b823          	sd	s0,1200(a5) # ffffffffc02df288 <bigblocks>
ffffffffc0201de0:	8436                	mv	s0,a3
ffffffffc0201de2:	b7a5                	j	ffffffffc0201d4a <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201de4:	86a6                	mv	a3,s1
ffffffffc0201de6:	00006617          	auipc	a2,0x6
ffffffffc0201dea:	4da60613          	addi	a2,a2,1242 # ffffffffc02082c0 <default_pmm_manager+0x88>
ffffffffc0201dee:	06e00593          	li	a1,110
ffffffffc0201df2:	00006517          	auipc	a0,0x6
ffffffffc0201df6:	4be50513          	addi	a0,a0,1214 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc0201dfa:	e8efe0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201dfe:	00006617          	auipc	a2,0x6
ffffffffc0201e02:	4ea60613          	addi	a2,a2,1258 # ffffffffc02082e8 <default_pmm_manager+0xb0>
ffffffffc0201e06:	06200593          	li	a1,98
ffffffffc0201e0a:	00006517          	auipc	a0,0x6
ffffffffc0201e0e:	4a650513          	addi	a0,a0,1190 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc0201e12:	e76fe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201e16 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201e16:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201e18:	00006617          	auipc	a2,0x6
ffffffffc0201e1c:	4d060613          	addi	a2,a2,1232 # ffffffffc02082e8 <default_pmm_manager+0xb0>
ffffffffc0201e20:	06200593          	li	a1,98
ffffffffc0201e24:	00006517          	auipc	a0,0x6
ffffffffc0201e28:	48c50513          	addi	a0,a0,1164 # ffffffffc02082b0 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201e2c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201e2e:	e5afe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201e32 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201e32:	715d                	addi	sp,sp,-80
ffffffffc0201e34:	e0a2                	sd	s0,64(sp)
ffffffffc0201e36:	fc26                	sd	s1,56(sp)
ffffffffc0201e38:	f84a                	sd	s2,48(sp)
ffffffffc0201e3a:	f44e                	sd	s3,40(sp)
ffffffffc0201e3c:	f052                	sd	s4,32(sp)
ffffffffc0201e3e:	ec56                	sd	s5,24(sp)
ffffffffc0201e40:	e486                	sd	ra,72(sp)
ffffffffc0201e42:	842a                	mv	s0,a0
ffffffffc0201e44:	000dd497          	auipc	s1,0xdd
ffffffffc0201e48:	4bc48493          	addi	s1,s1,1212 # ffffffffc02df300 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e4c:	4985                	li	s3,1
ffffffffc0201e4e:	000dda17          	auipc	s4,0xdd
ffffffffc0201e52:	45aa0a13          	addi	s4,s4,1114 # ffffffffc02df2a8 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e56:	0005091b          	sext.w	s2,a0
ffffffffc0201e5a:	000dda97          	auipc	s5,0xdd
ffffffffc0201e5e:	59ea8a93          	addi	s5,s5,1438 # ffffffffc02df3f8 <check_mm_struct>
ffffffffc0201e62:	a00d                	j	ffffffffc0201e84 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e64:	609c                	ld	a5,0(s1)
ffffffffc0201e66:	6f9c                	ld	a5,24(a5)
ffffffffc0201e68:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e6a:	4601                	li	a2,0
ffffffffc0201e6c:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e6e:	ed0d                	bnez	a0,ffffffffc0201ea8 <alloc_pages+0x76>
ffffffffc0201e70:	0289ec63          	bltu	s3,s0,ffffffffc0201ea8 <alloc_pages+0x76>
ffffffffc0201e74:	000a2783          	lw	a5,0(s4)
ffffffffc0201e78:	2781                	sext.w	a5,a5
ffffffffc0201e7a:	c79d                	beqz	a5,ffffffffc0201ea8 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e7c:	000ab503          	ld	a0,0(s5)
ffffffffc0201e80:	48d010ef          	jal	ra,ffffffffc0203b0c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e84:	100027f3          	csrr	a5,sstatus
ffffffffc0201e88:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e8a:	8522                	mv	a0,s0
ffffffffc0201e8c:	dfe1                	beqz	a5,ffffffffc0201e64 <alloc_pages+0x32>
        intr_disable();
ffffffffc0201e8e:	fc4fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201e92:	609c                	ld	a5,0(s1)
ffffffffc0201e94:	8522                	mv	a0,s0
ffffffffc0201e96:	6f9c                	ld	a5,24(a5)
ffffffffc0201e98:	9782                	jalr	a5
ffffffffc0201e9a:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201e9c:	fb0fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201ea0:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201ea2:	4601                	li	a2,0
ffffffffc0201ea4:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201ea6:	d569                	beqz	a0,ffffffffc0201e70 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201ea8:	60a6                	ld	ra,72(sp)
ffffffffc0201eaa:	6406                	ld	s0,64(sp)
ffffffffc0201eac:	74e2                	ld	s1,56(sp)
ffffffffc0201eae:	7942                	ld	s2,48(sp)
ffffffffc0201eb0:	79a2                	ld	s3,40(sp)
ffffffffc0201eb2:	7a02                	ld	s4,32(sp)
ffffffffc0201eb4:	6ae2                	ld	s5,24(sp)
ffffffffc0201eb6:	6161                	addi	sp,sp,80
ffffffffc0201eb8:	8082                	ret

ffffffffc0201eba <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201eba:	100027f3          	csrr	a5,sstatus
ffffffffc0201ebe:	8b89                	andi	a5,a5,2
ffffffffc0201ec0:	eb89                	bnez	a5,ffffffffc0201ed2 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201ec2:	000dd797          	auipc	a5,0xdd
ffffffffc0201ec6:	43e78793          	addi	a5,a5,1086 # ffffffffc02df300 <pmm_manager>
ffffffffc0201eca:	639c                	ld	a5,0(a5)
ffffffffc0201ecc:	0207b303          	ld	t1,32(a5)
ffffffffc0201ed0:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201ed2:	1101                	addi	sp,sp,-32
ffffffffc0201ed4:	ec06                	sd	ra,24(sp)
ffffffffc0201ed6:	e822                	sd	s0,16(sp)
ffffffffc0201ed8:	e426                	sd	s1,8(sp)
ffffffffc0201eda:	842a                	mv	s0,a0
ffffffffc0201edc:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201ede:	f74fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201ee2:	000dd797          	auipc	a5,0xdd
ffffffffc0201ee6:	41e78793          	addi	a5,a5,1054 # ffffffffc02df300 <pmm_manager>
ffffffffc0201eea:	639c                	ld	a5,0(a5)
ffffffffc0201eec:	85a6                	mv	a1,s1
ffffffffc0201eee:	8522                	mv	a0,s0
ffffffffc0201ef0:	739c                	ld	a5,32(a5)
ffffffffc0201ef2:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201ef4:	6442                	ld	s0,16(sp)
ffffffffc0201ef6:	60e2                	ld	ra,24(sp)
ffffffffc0201ef8:	64a2                	ld	s1,8(sp)
ffffffffc0201efa:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201efc:	f50fe06f          	j	ffffffffc020064c <intr_enable>

ffffffffc0201f00 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f00:	100027f3          	csrr	a5,sstatus
ffffffffc0201f04:	8b89                	andi	a5,a5,2
ffffffffc0201f06:	eb89                	bnez	a5,ffffffffc0201f18 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f08:	000dd797          	auipc	a5,0xdd
ffffffffc0201f0c:	3f878793          	addi	a5,a5,1016 # ffffffffc02df300 <pmm_manager>
ffffffffc0201f10:	639c                	ld	a5,0(a5)
ffffffffc0201f12:	0287b303          	ld	t1,40(a5)
ffffffffc0201f16:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201f18:	1141                	addi	sp,sp,-16
ffffffffc0201f1a:	e406                	sd	ra,8(sp)
ffffffffc0201f1c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201f1e:	f34fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f22:	000dd797          	auipc	a5,0xdd
ffffffffc0201f26:	3de78793          	addi	a5,a5,990 # ffffffffc02df300 <pmm_manager>
ffffffffc0201f2a:	639c                	ld	a5,0(a5)
ffffffffc0201f2c:	779c                	ld	a5,40(a5)
ffffffffc0201f2e:	9782                	jalr	a5
ffffffffc0201f30:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f32:	f1afe0ef          	jal	ra,ffffffffc020064c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201f36:	8522                	mv	a0,s0
ffffffffc0201f38:	60a2                	ld	ra,8(sp)
ffffffffc0201f3a:	6402                	ld	s0,0(sp)
ffffffffc0201f3c:	0141                	addi	sp,sp,16
ffffffffc0201f3e:	8082                	ret

ffffffffc0201f40 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f40:	7139                	addi	sp,sp,-64
ffffffffc0201f42:	f426                	sd	s1,40(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f44:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201f48:	1ff4f493          	andi	s1,s1,511
ffffffffc0201f4c:	048e                	slli	s1,s1,0x3
ffffffffc0201f4e:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f50:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f52:	f04a                	sd	s2,32(sp)
ffffffffc0201f54:	ec4e                	sd	s3,24(sp)
ffffffffc0201f56:	e852                	sd	s4,16(sp)
ffffffffc0201f58:	fc06                	sd	ra,56(sp)
ffffffffc0201f5a:	f822                	sd	s0,48(sp)
ffffffffc0201f5c:	e456                	sd	s5,8(sp)
ffffffffc0201f5e:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f60:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f64:	892e                	mv	s2,a1
ffffffffc0201f66:	8a32                	mv	s4,a2
ffffffffc0201f68:	000dd997          	auipc	s3,0xdd
ffffffffc0201f6c:	33098993          	addi	s3,s3,816 # ffffffffc02df298 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f70:	e7bd                	bnez	a5,ffffffffc0201fde <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201f72:	12060c63          	beqz	a2,ffffffffc02020aa <get_pte+0x16a>
ffffffffc0201f76:	4505                	li	a0,1
ffffffffc0201f78:	ebbff0ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc0201f7c:	842a                	mv	s0,a0
ffffffffc0201f7e:	12050663          	beqz	a0,ffffffffc02020aa <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201f82:	000ddb17          	auipc	s6,0xdd
ffffffffc0201f86:	396b0b13          	addi	s6,s6,918 # ffffffffc02df318 <pages>
ffffffffc0201f8a:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201f8e:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f90:	000dd997          	auipc	s3,0xdd
ffffffffc0201f94:	30898993          	addi	s3,s3,776 # ffffffffc02df298 <npage>
    return page - pages + nbase;
ffffffffc0201f98:	40a40533          	sub	a0,s0,a0
ffffffffc0201f9c:	00080ab7          	lui	s5,0x80
ffffffffc0201fa0:	8519                	srai	a0,a0,0x6
ffffffffc0201fa2:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201fa6:	c01c                	sw	a5,0(s0)
ffffffffc0201fa8:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201faa:	9556                	add	a0,a0,s5
ffffffffc0201fac:	83b1                	srli	a5,a5,0xc
ffffffffc0201fae:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fb0:	0532                	slli	a0,a0,0xc
ffffffffc0201fb2:	14e7f363          	bleu	a4,a5,ffffffffc02020f8 <get_pte+0x1b8>
ffffffffc0201fb6:	000dd797          	auipc	a5,0xdd
ffffffffc0201fba:	35278793          	addi	a5,a5,850 # ffffffffc02df308 <va_pa_offset>
ffffffffc0201fbe:	639c                	ld	a5,0(a5)
ffffffffc0201fc0:	6605                	lui	a2,0x1
ffffffffc0201fc2:	4581                	li	a1,0
ffffffffc0201fc4:	953e                	add	a0,a0,a5
ffffffffc0201fc6:	510050ef          	jal	ra,ffffffffc02074d6 <memset>
    return page - pages + nbase;
ffffffffc0201fca:	000b3683          	ld	a3,0(s6)
ffffffffc0201fce:	40d406b3          	sub	a3,s0,a3
ffffffffc0201fd2:	8699                	srai	a3,a3,0x6
ffffffffc0201fd4:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201fd6:	06aa                	slli	a3,a3,0xa
ffffffffc0201fd8:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201fdc:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201fde:	77fd                	lui	a5,0xfffff
ffffffffc0201fe0:	068a                	slli	a3,a3,0x2
ffffffffc0201fe2:	0009b703          	ld	a4,0(s3)
ffffffffc0201fe6:	8efd                	and	a3,a3,a5
ffffffffc0201fe8:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201fec:	0ce7f163          	bleu	a4,a5,ffffffffc02020ae <get_pte+0x16e>
ffffffffc0201ff0:	000dda97          	auipc	s5,0xdd
ffffffffc0201ff4:	318a8a93          	addi	s5,s5,792 # ffffffffc02df308 <va_pa_offset>
ffffffffc0201ff8:	000ab403          	ld	s0,0(s5)
ffffffffc0201ffc:	01595793          	srli	a5,s2,0x15
ffffffffc0202000:	1ff7f793          	andi	a5,a5,511
ffffffffc0202004:	96a2                	add	a3,a3,s0
ffffffffc0202006:	00379413          	slli	s0,a5,0x3
ffffffffc020200a:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc020200c:	6014                	ld	a3,0(s0)
ffffffffc020200e:	0016f793          	andi	a5,a3,1
ffffffffc0202012:	e3ad                	bnez	a5,ffffffffc0202074 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202014:	080a0b63          	beqz	s4,ffffffffc02020aa <get_pte+0x16a>
ffffffffc0202018:	4505                	li	a0,1
ffffffffc020201a:	e19ff0ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc020201e:	84aa                	mv	s1,a0
ffffffffc0202020:	c549                	beqz	a0,ffffffffc02020aa <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0202022:	000ddb17          	auipc	s6,0xdd
ffffffffc0202026:	2f6b0b13          	addi	s6,s6,758 # ffffffffc02df318 <pages>
ffffffffc020202a:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc020202e:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0202030:	00080a37          	lui	s4,0x80
ffffffffc0202034:	40a48533          	sub	a0,s1,a0
ffffffffc0202038:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020203a:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc020203e:	c09c                	sw	a5,0(s1)
ffffffffc0202040:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0202042:	9552                	add	a0,a0,s4
ffffffffc0202044:	83b1                	srli	a5,a5,0xc
ffffffffc0202046:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202048:	0532                	slli	a0,a0,0xc
ffffffffc020204a:	08e7fa63          	bleu	a4,a5,ffffffffc02020de <get_pte+0x19e>
ffffffffc020204e:	000ab783          	ld	a5,0(s5)
ffffffffc0202052:	6605                	lui	a2,0x1
ffffffffc0202054:	4581                	li	a1,0
ffffffffc0202056:	953e                	add	a0,a0,a5
ffffffffc0202058:	47e050ef          	jal	ra,ffffffffc02074d6 <memset>
    return page - pages + nbase;
ffffffffc020205c:	000b3683          	ld	a3,0(s6)
ffffffffc0202060:	40d486b3          	sub	a3,s1,a3
ffffffffc0202064:	8699                	srai	a3,a3,0x6
ffffffffc0202066:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202068:	06aa                	slli	a3,a3,0xa
ffffffffc020206a:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020206e:	e014                	sd	a3,0(s0)
ffffffffc0202070:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202074:	068a                	slli	a3,a3,0x2
ffffffffc0202076:	757d                	lui	a0,0xfffff
ffffffffc0202078:	8ee9                	and	a3,a3,a0
ffffffffc020207a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020207e:	04e7f463          	bleu	a4,a5,ffffffffc02020c6 <get_pte+0x186>
ffffffffc0202082:	000ab503          	ld	a0,0(s5)
ffffffffc0202086:	00c95793          	srli	a5,s2,0xc
ffffffffc020208a:	1ff7f793          	andi	a5,a5,511
ffffffffc020208e:	96aa                	add	a3,a3,a0
ffffffffc0202090:	00379513          	slli	a0,a5,0x3
ffffffffc0202094:	9536                	add	a0,a0,a3
}
ffffffffc0202096:	70e2                	ld	ra,56(sp)
ffffffffc0202098:	7442                	ld	s0,48(sp)
ffffffffc020209a:	74a2                	ld	s1,40(sp)
ffffffffc020209c:	7902                	ld	s2,32(sp)
ffffffffc020209e:	69e2                	ld	s3,24(sp)
ffffffffc02020a0:	6a42                	ld	s4,16(sp)
ffffffffc02020a2:	6aa2                	ld	s5,8(sp)
ffffffffc02020a4:	6b02                	ld	s6,0(sp)
ffffffffc02020a6:	6121                	addi	sp,sp,64
ffffffffc02020a8:	8082                	ret
            return NULL;
ffffffffc02020aa:	4501                	li	a0,0
ffffffffc02020ac:	b7ed                	j	ffffffffc0202096 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02020ae:	00006617          	auipc	a2,0x6
ffffffffc02020b2:	1da60613          	addi	a2,a2,474 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc02020b6:	0fe00593          	li	a1,254
ffffffffc02020ba:	00006517          	auipc	a0,0x6
ffffffffc02020be:	2ee50513          	addi	a0,a0,750 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc02020c2:	bc6fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02020c6:	00006617          	auipc	a2,0x6
ffffffffc02020ca:	1c260613          	addi	a2,a2,450 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc02020ce:	10900593          	li	a1,265
ffffffffc02020d2:	00006517          	auipc	a0,0x6
ffffffffc02020d6:	2d650513          	addi	a0,a0,726 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc02020da:	baefe0ef          	jal	ra,ffffffffc0200488 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020de:	86aa                	mv	a3,a0
ffffffffc02020e0:	00006617          	auipc	a2,0x6
ffffffffc02020e4:	1a860613          	addi	a2,a2,424 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc02020e8:	10600593          	li	a1,262
ffffffffc02020ec:	00006517          	auipc	a0,0x6
ffffffffc02020f0:	2bc50513          	addi	a0,a0,700 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc02020f4:	b94fe0ef          	jal	ra,ffffffffc0200488 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020f8:	86aa                	mv	a3,a0
ffffffffc02020fa:	00006617          	auipc	a2,0x6
ffffffffc02020fe:	18e60613          	addi	a2,a2,398 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc0202102:	0fa00593          	li	a1,250
ffffffffc0202106:	00006517          	auipc	a0,0x6
ffffffffc020210a:	2a250513          	addi	a0,a0,674 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc020210e:	b7afe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0202112 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202112:	1141                	addi	sp,sp,-16
ffffffffc0202114:	e022                	sd	s0,0(sp)
ffffffffc0202116:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202118:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020211a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020211c:	e25ff0ef          	jal	ra,ffffffffc0201f40 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202120:	c011                	beqz	s0,ffffffffc0202124 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202122:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202124:	c129                	beqz	a0,ffffffffc0202166 <get_page+0x54>
ffffffffc0202126:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202128:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020212a:	0017f713          	andi	a4,a5,1
ffffffffc020212e:	e709                	bnez	a4,ffffffffc0202138 <get_page+0x26>
}
ffffffffc0202130:	60a2                	ld	ra,8(sp)
ffffffffc0202132:	6402                	ld	s0,0(sp)
ffffffffc0202134:	0141                	addi	sp,sp,16
ffffffffc0202136:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202138:	000dd717          	auipc	a4,0xdd
ffffffffc020213c:	16070713          	addi	a4,a4,352 # ffffffffc02df298 <npage>
ffffffffc0202140:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202142:	078a                	slli	a5,a5,0x2
ffffffffc0202144:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202146:	02e7f563          	bleu	a4,a5,ffffffffc0202170 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc020214a:	000dd717          	auipc	a4,0xdd
ffffffffc020214e:	1ce70713          	addi	a4,a4,462 # ffffffffc02df318 <pages>
ffffffffc0202152:	6308                	ld	a0,0(a4)
ffffffffc0202154:	60a2                	ld	ra,8(sp)
ffffffffc0202156:	6402                	ld	s0,0(sp)
ffffffffc0202158:	fff80737          	lui	a4,0xfff80
ffffffffc020215c:	97ba                	add	a5,a5,a4
ffffffffc020215e:	079a                	slli	a5,a5,0x6
ffffffffc0202160:	953e                	add	a0,a0,a5
ffffffffc0202162:	0141                	addi	sp,sp,16
ffffffffc0202164:	8082                	ret
ffffffffc0202166:	60a2                	ld	ra,8(sp)
ffffffffc0202168:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc020216a:	4501                	li	a0,0
}
ffffffffc020216c:	0141                	addi	sp,sp,16
ffffffffc020216e:	8082                	ret
ffffffffc0202170:	ca7ff0ef          	jal	ra,ffffffffc0201e16 <pa2page.part.4>

ffffffffc0202174 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202174:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202176:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020217a:	ec86                	sd	ra,88(sp)
ffffffffc020217c:	e8a2                	sd	s0,80(sp)
ffffffffc020217e:	e4a6                	sd	s1,72(sp)
ffffffffc0202180:	e0ca                	sd	s2,64(sp)
ffffffffc0202182:	fc4e                	sd	s3,56(sp)
ffffffffc0202184:	f852                	sd	s4,48(sp)
ffffffffc0202186:	f456                	sd	s5,40(sp)
ffffffffc0202188:	f05a                	sd	s6,32(sp)
ffffffffc020218a:	ec5e                	sd	s7,24(sp)
ffffffffc020218c:	e862                	sd	s8,16(sp)
ffffffffc020218e:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202190:	03479713          	slli	a4,a5,0x34
ffffffffc0202194:	eb71                	bnez	a4,ffffffffc0202268 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc0202196:	002007b7          	lui	a5,0x200
ffffffffc020219a:	842e                	mv	s0,a1
ffffffffc020219c:	0af5e663          	bltu	a1,a5,ffffffffc0202248 <unmap_range+0xd4>
ffffffffc02021a0:	8932                	mv	s2,a2
ffffffffc02021a2:	0ac5f363          	bleu	a2,a1,ffffffffc0202248 <unmap_range+0xd4>
ffffffffc02021a6:	4785                	li	a5,1
ffffffffc02021a8:	07fe                	slli	a5,a5,0x1f
ffffffffc02021aa:	08c7ef63          	bltu	a5,a2,ffffffffc0202248 <unmap_range+0xd4>
ffffffffc02021ae:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02021b0:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02021b2:	000ddc97          	auipc	s9,0xdd
ffffffffc02021b6:	0e6c8c93          	addi	s9,s9,230 # ffffffffc02df298 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02021ba:	000ddc17          	auipc	s8,0xdd
ffffffffc02021be:	15ec0c13          	addi	s8,s8,350 # ffffffffc02df318 <pages>
ffffffffc02021c2:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02021c6:	00200b37          	lui	s6,0x200
ffffffffc02021ca:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02021ce:	4601                	li	a2,0
ffffffffc02021d0:	85a2                	mv	a1,s0
ffffffffc02021d2:	854e                	mv	a0,s3
ffffffffc02021d4:	d6dff0ef          	jal	ra,ffffffffc0201f40 <get_pte>
ffffffffc02021d8:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02021da:	cd21                	beqz	a0,ffffffffc0202232 <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc02021dc:	611c                	ld	a5,0(a0)
ffffffffc02021de:	e38d                	bnez	a5,ffffffffc0202200 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc02021e0:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02021e2:	ff2466e3          	bltu	s0,s2,ffffffffc02021ce <unmap_range+0x5a>
}
ffffffffc02021e6:	60e6                	ld	ra,88(sp)
ffffffffc02021e8:	6446                	ld	s0,80(sp)
ffffffffc02021ea:	64a6                	ld	s1,72(sp)
ffffffffc02021ec:	6906                	ld	s2,64(sp)
ffffffffc02021ee:	79e2                	ld	s3,56(sp)
ffffffffc02021f0:	7a42                	ld	s4,48(sp)
ffffffffc02021f2:	7aa2                	ld	s5,40(sp)
ffffffffc02021f4:	7b02                	ld	s6,32(sp)
ffffffffc02021f6:	6be2                	ld	s7,24(sp)
ffffffffc02021f8:	6c42                	ld	s8,16(sp)
ffffffffc02021fa:	6ca2                	ld	s9,8(sp)
ffffffffc02021fc:	6125                	addi	sp,sp,96
ffffffffc02021fe:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202200:	0017f713          	andi	a4,a5,1
ffffffffc0202204:	df71                	beqz	a4,ffffffffc02021e0 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc0202206:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020220a:	078a                	slli	a5,a5,0x2
ffffffffc020220c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020220e:	06e7fd63          	bleu	a4,a5,ffffffffc0202288 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc0202212:	000c3503          	ld	a0,0(s8)
ffffffffc0202216:	97de                	add	a5,a5,s7
ffffffffc0202218:	079a                	slli	a5,a5,0x6
ffffffffc020221a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020221c:	411c                	lw	a5,0(a0)
ffffffffc020221e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202222:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202224:	cf11                	beqz	a4,ffffffffc0202240 <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202226:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020222a:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020222e:	9452                	add	s0,s0,s4
ffffffffc0202230:	bf4d                	j	ffffffffc02021e2 <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202232:	945a                	add	s0,s0,s6
ffffffffc0202234:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0202238:	d45d                	beqz	s0,ffffffffc02021e6 <unmap_range+0x72>
ffffffffc020223a:	f9246ae3          	bltu	s0,s2,ffffffffc02021ce <unmap_range+0x5a>
ffffffffc020223e:	b765                	j	ffffffffc02021e6 <unmap_range+0x72>
            free_page(page);
ffffffffc0202240:	4585                	li	a1,1
ffffffffc0202242:	c79ff0ef          	jal	ra,ffffffffc0201eba <free_pages>
ffffffffc0202246:	b7c5                	j	ffffffffc0202226 <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0202248:	00006697          	auipc	a3,0x6
ffffffffc020224c:	70868693          	addi	a3,a3,1800 # ffffffffc0208950 <default_pmm_manager+0x718>
ffffffffc0202250:	00006617          	auipc	a2,0x6
ffffffffc0202254:	8a060613          	addi	a2,a2,-1888 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202258:	14100593          	li	a1,321
ffffffffc020225c:	00006517          	auipc	a0,0x6
ffffffffc0202260:	14c50513          	addi	a0,a0,332 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202264:	a24fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202268:	00006697          	auipc	a3,0x6
ffffffffc020226c:	6b868693          	addi	a3,a3,1720 # ffffffffc0208920 <default_pmm_manager+0x6e8>
ffffffffc0202270:	00006617          	auipc	a2,0x6
ffffffffc0202274:	88060613          	addi	a2,a2,-1920 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202278:	14000593          	li	a1,320
ffffffffc020227c:	00006517          	auipc	a0,0x6
ffffffffc0202280:	12c50513          	addi	a0,a0,300 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202284:	a04fe0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0202288:	b8fff0ef          	jal	ra,ffffffffc0201e16 <pa2page.part.4>

ffffffffc020228c <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020228c:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020228e:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202292:	fc86                	sd	ra,120(sp)
ffffffffc0202294:	f8a2                	sd	s0,112(sp)
ffffffffc0202296:	f4a6                	sd	s1,104(sp)
ffffffffc0202298:	f0ca                	sd	s2,96(sp)
ffffffffc020229a:	ecce                	sd	s3,88(sp)
ffffffffc020229c:	e8d2                	sd	s4,80(sp)
ffffffffc020229e:	e4d6                	sd	s5,72(sp)
ffffffffc02022a0:	e0da                	sd	s6,64(sp)
ffffffffc02022a2:	fc5e                	sd	s7,56(sp)
ffffffffc02022a4:	f862                	sd	s8,48(sp)
ffffffffc02022a6:	f466                	sd	s9,40(sp)
ffffffffc02022a8:	f06a                	sd	s10,32(sp)
ffffffffc02022aa:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022ac:	03479713          	slli	a4,a5,0x34
ffffffffc02022b0:	1c071163          	bnez	a4,ffffffffc0202472 <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc02022b4:	002007b7          	lui	a5,0x200
ffffffffc02022b8:	20f5e563          	bltu	a1,a5,ffffffffc02024c2 <exit_range+0x236>
ffffffffc02022bc:	8b32                	mv	s6,a2
ffffffffc02022be:	20c5f263          	bleu	a2,a1,ffffffffc02024c2 <exit_range+0x236>
ffffffffc02022c2:	4785                	li	a5,1
ffffffffc02022c4:	07fe                	slli	a5,a5,0x1f
ffffffffc02022c6:	1ec7ee63          	bltu	a5,a2,ffffffffc02024c2 <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02022ca:	c00009b7          	lui	s3,0xc0000
ffffffffc02022ce:	400007b7          	lui	a5,0x40000
ffffffffc02022d2:	0135f9b3          	and	s3,a1,s3
ffffffffc02022d6:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02022d8:	c0000337          	lui	t1,0xc0000
ffffffffc02022dc:	00698933          	add	s2,s3,t1
ffffffffc02022e0:	01e95913          	srli	s2,s2,0x1e
ffffffffc02022e4:	1ff97913          	andi	s2,s2,511
ffffffffc02022e8:	8e2a                	mv	t3,a0
ffffffffc02022ea:	090e                	slli	s2,s2,0x3
ffffffffc02022ec:	9972                	add	s2,s2,t3
ffffffffc02022ee:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02022f2:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc02022f6:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc02022f8:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02022fc:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc02022fe:	000ddd17          	auipc	s10,0xdd
ffffffffc0202302:	f9ad0d13          	addi	s10,s10,-102 # ffffffffc02df298 <npage>
    return KADDR(page2pa(page));
ffffffffc0202306:	00cddd93          	srli	s11,s11,0xc
ffffffffc020230a:	000dd717          	auipc	a4,0xdd
ffffffffc020230e:	ffe70713          	addi	a4,a4,-2 # ffffffffc02df308 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc0202312:	000dde97          	auipc	t4,0xdd
ffffffffc0202316:	006e8e93          	addi	t4,t4,6 # ffffffffc02df318 <pages>
        if (pde1&PTE_V){
ffffffffc020231a:	e79d                	bnez	a5,ffffffffc0202348 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc020231c:	12098963          	beqz	s3,ffffffffc020244e <exit_range+0x1c2>
ffffffffc0202320:	400007b7          	lui	a5,0x40000
ffffffffc0202324:	84ce                	mv	s1,s3
ffffffffc0202326:	97ce                	add	a5,a5,s3
ffffffffc0202328:	1369f363          	bleu	s6,s3,ffffffffc020244e <exit_range+0x1c2>
ffffffffc020232c:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020232e:	00698933          	add	s2,s3,t1
ffffffffc0202332:	01e95913          	srli	s2,s2,0x1e
ffffffffc0202336:	1ff97913          	andi	s2,s2,511
ffffffffc020233a:	090e                	slli	s2,s2,0x3
ffffffffc020233c:	9972                	add	s2,s2,t3
ffffffffc020233e:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc0202342:	001bf793          	andi	a5,s7,1
ffffffffc0202346:	dbf9                	beqz	a5,ffffffffc020231c <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202348:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020234c:	0b8a                	slli	s7,s7,0x2
ffffffffc020234e:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202352:	14fbfc63          	bleu	a5,s7,ffffffffc02024aa <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202356:	fff80ab7          	lui	s5,0xfff80
ffffffffc020235a:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc020235c:	000806b7          	lui	a3,0x80
ffffffffc0202360:	96d6                	add	a3,a3,s5
ffffffffc0202362:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc0202366:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc020236a:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc020236c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020236e:	12f67263          	bleu	a5,a2,ffffffffc0202492 <exit_range+0x206>
ffffffffc0202372:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc0202376:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202378:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc020237c:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc020237e:	00080837          	lui	a6,0x80
ffffffffc0202382:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc0202384:	00200c37          	lui	s8,0x200
ffffffffc0202388:	a801                	j	ffffffffc0202398 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc020238a:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc020238c:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc020238e:	c0d9                	beqz	s1,ffffffffc0202414 <exit_range+0x188>
ffffffffc0202390:	0934f263          	bleu	s3,s1,ffffffffc0202414 <exit_range+0x188>
ffffffffc0202394:	0d64fc63          	bleu	s6,s1,ffffffffc020246c <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202398:	0154d413          	srli	s0,s1,0x15
ffffffffc020239c:	1ff47413          	andi	s0,s0,511
ffffffffc02023a0:	040e                	slli	s0,s0,0x3
ffffffffc02023a2:	9452                	add	s0,s0,s4
ffffffffc02023a4:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc02023a6:	0017f693          	andi	a3,a5,1
ffffffffc02023aa:	d2e5                	beqz	a3,ffffffffc020238a <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc02023ac:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023b0:	00279513          	slli	a0,a5,0x2
ffffffffc02023b4:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023b6:	0eb57a63          	bleu	a1,a0,ffffffffc02024aa <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02023ba:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc02023bc:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc02023c0:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc02023c4:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02023c6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023c8:	0cb7f563          	bleu	a1,a5,ffffffffc0202492 <exit_range+0x206>
ffffffffc02023cc:	631c                	ld	a5,0(a4)
ffffffffc02023ce:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023d0:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc02023d4:	629c                	ld	a5,0(a3)
ffffffffc02023d6:	8b85                	andi	a5,a5,1
ffffffffc02023d8:	fbd5                	bnez	a5,ffffffffc020238c <exit_range+0x100>
ffffffffc02023da:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023dc:	fed59ce3          	bne	a1,a3,ffffffffc02023d4 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc02023e0:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc02023e4:	4585                	li	a1,1
ffffffffc02023e6:	e072                	sd	t3,0(sp)
ffffffffc02023e8:	953e                	add	a0,a0,a5
ffffffffc02023ea:	ad1ff0ef          	jal	ra,ffffffffc0201eba <free_pages>
                d0start += PTSIZE;
ffffffffc02023ee:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc02023f0:	00043023          	sd	zero,0(s0)
ffffffffc02023f4:	000dde97          	auipc	t4,0xdd
ffffffffc02023f8:	f24e8e93          	addi	t4,t4,-220 # ffffffffc02df318 <pages>
ffffffffc02023fc:	6e02                	ld	t3,0(sp)
ffffffffc02023fe:	c0000337          	lui	t1,0xc0000
ffffffffc0202402:	fff808b7          	lui	a7,0xfff80
ffffffffc0202406:	00080837          	lui	a6,0x80
ffffffffc020240a:	000dd717          	auipc	a4,0xdd
ffffffffc020240e:	efe70713          	addi	a4,a4,-258 # ffffffffc02df308 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202412:	fcbd                	bnez	s1,ffffffffc0202390 <exit_range+0x104>
            if (free_pd0) {
ffffffffc0202414:	f00c84e3          	beqz	s9,ffffffffc020231c <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202418:	000d3783          	ld	a5,0(s10)
ffffffffc020241c:	e072                	sd	t3,0(sp)
ffffffffc020241e:	08fbf663          	bleu	a5,s7,ffffffffc02024aa <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202422:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0202426:	67a2                	ld	a5,8(sp)
ffffffffc0202428:	4585                	li	a1,1
ffffffffc020242a:	953e                	add	a0,a0,a5
ffffffffc020242c:	a8fff0ef          	jal	ra,ffffffffc0201eba <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202430:	00093023          	sd	zero,0(s2)
ffffffffc0202434:	000dd717          	auipc	a4,0xdd
ffffffffc0202438:	ed470713          	addi	a4,a4,-300 # ffffffffc02df308 <va_pa_offset>
ffffffffc020243c:	c0000337          	lui	t1,0xc0000
ffffffffc0202440:	6e02                	ld	t3,0(sp)
ffffffffc0202442:	000dde97          	auipc	t4,0xdd
ffffffffc0202446:	ed6e8e93          	addi	t4,t4,-298 # ffffffffc02df318 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc020244a:	ec099be3          	bnez	s3,ffffffffc0202320 <exit_range+0x94>
}
ffffffffc020244e:	70e6                	ld	ra,120(sp)
ffffffffc0202450:	7446                	ld	s0,112(sp)
ffffffffc0202452:	74a6                	ld	s1,104(sp)
ffffffffc0202454:	7906                	ld	s2,96(sp)
ffffffffc0202456:	69e6                	ld	s3,88(sp)
ffffffffc0202458:	6a46                	ld	s4,80(sp)
ffffffffc020245a:	6aa6                	ld	s5,72(sp)
ffffffffc020245c:	6b06                	ld	s6,64(sp)
ffffffffc020245e:	7be2                	ld	s7,56(sp)
ffffffffc0202460:	7c42                	ld	s8,48(sp)
ffffffffc0202462:	7ca2                	ld	s9,40(sp)
ffffffffc0202464:	7d02                	ld	s10,32(sp)
ffffffffc0202466:	6de2                	ld	s11,24(sp)
ffffffffc0202468:	6109                	addi	sp,sp,128
ffffffffc020246a:	8082                	ret
            if (free_pd0) {
ffffffffc020246c:	ea0c8ae3          	beqz	s9,ffffffffc0202320 <exit_range+0x94>
ffffffffc0202470:	b765                	j	ffffffffc0202418 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202472:	00006697          	auipc	a3,0x6
ffffffffc0202476:	4ae68693          	addi	a3,a3,1198 # ffffffffc0208920 <default_pmm_manager+0x6e8>
ffffffffc020247a:	00005617          	auipc	a2,0x5
ffffffffc020247e:	67660613          	addi	a2,a2,1654 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202482:	15100593          	li	a1,337
ffffffffc0202486:	00006517          	auipc	a0,0x6
ffffffffc020248a:	f2250513          	addi	a0,a0,-222 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc020248e:	ffbfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202492:	00006617          	auipc	a2,0x6
ffffffffc0202496:	df660613          	addi	a2,a2,-522 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc020249a:	06900593          	li	a1,105
ffffffffc020249e:	00006517          	auipc	a0,0x6
ffffffffc02024a2:	e1250513          	addi	a0,a0,-494 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc02024a6:	fe3fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02024aa:	00006617          	auipc	a2,0x6
ffffffffc02024ae:	e3e60613          	addi	a2,a2,-450 # ffffffffc02082e8 <default_pmm_manager+0xb0>
ffffffffc02024b2:	06200593          	li	a1,98
ffffffffc02024b6:	00006517          	auipc	a0,0x6
ffffffffc02024ba:	dfa50513          	addi	a0,a0,-518 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc02024be:	fcbfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02024c2:	00006697          	auipc	a3,0x6
ffffffffc02024c6:	48e68693          	addi	a3,a3,1166 # ffffffffc0208950 <default_pmm_manager+0x718>
ffffffffc02024ca:	00005617          	auipc	a2,0x5
ffffffffc02024ce:	62660613          	addi	a2,a2,1574 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02024d2:	15200593          	li	a1,338
ffffffffc02024d6:	00006517          	auipc	a0,0x6
ffffffffc02024da:	ed250513          	addi	a0,a0,-302 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc02024de:	fabfd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02024e2 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02024e2:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024e4:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02024e6:	e426                	sd	s1,8(sp)
ffffffffc02024e8:	ec06                	sd	ra,24(sp)
ffffffffc02024ea:	e822                	sd	s0,16(sp)
ffffffffc02024ec:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024ee:	a53ff0ef          	jal	ra,ffffffffc0201f40 <get_pte>
    if (ptep != NULL) {
ffffffffc02024f2:	c511                	beqz	a0,ffffffffc02024fe <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02024f4:	611c                	ld	a5,0(a0)
ffffffffc02024f6:	842a                	mv	s0,a0
ffffffffc02024f8:	0017f713          	andi	a4,a5,1
ffffffffc02024fc:	e711                	bnez	a4,ffffffffc0202508 <page_remove+0x26>
}
ffffffffc02024fe:	60e2                	ld	ra,24(sp)
ffffffffc0202500:	6442                	ld	s0,16(sp)
ffffffffc0202502:	64a2                	ld	s1,8(sp)
ffffffffc0202504:	6105                	addi	sp,sp,32
ffffffffc0202506:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202508:	000dd717          	auipc	a4,0xdd
ffffffffc020250c:	d9070713          	addi	a4,a4,-624 # ffffffffc02df298 <npage>
ffffffffc0202510:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202512:	078a                	slli	a5,a5,0x2
ffffffffc0202514:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202516:	02e7fe63          	bleu	a4,a5,ffffffffc0202552 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc020251a:	000dd717          	auipc	a4,0xdd
ffffffffc020251e:	dfe70713          	addi	a4,a4,-514 # ffffffffc02df318 <pages>
ffffffffc0202522:	6308                	ld	a0,0(a4)
ffffffffc0202524:	fff80737          	lui	a4,0xfff80
ffffffffc0202528:	97ba                	add	a5,a5,a4
ffffffffc020252a:	079a                	slli	a5,a5,0x6
ffffffffc020252c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020252e:	411c                	lw	a5,0(a0)
ffffffffc0202530:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202534:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202536:	cb11                	beqz	a4,ffffffffc020254a <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202538:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020253c:	12048073          	sfence.vma	s1
}
ffffffffc0202540:	60e2                	ld	ra,24(sp)
ffffffffc0202542:	6442                	ld	s0,16(sp)
ffffffffc0202544:	64a2                	ld	s1,8(sp)
ffffffffc0202546:	6105                	addi	sp,sp,32
ffffffffc0202548:	8082                	ret
            free_page(page);
ffffffffc020254a:	4585                	li	a1,1
ffffffffc020254c:	96fff0ef          	jal	ra,ffffffffc0201eba <free_pages>
ffffffffc0202550:	b7e5                	j	ffffffffc0202538 <page_remove+0x56>
ffffffffc0202552:	8c5ff0ef          	jal	ra,ffffffffc0201e16 <pa2page.part.4>

ffffffffc0202556 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202556:	7179                	addi	sp,sp,-48
ffffffffc0202558:	e44e                	sd	s3,8(sp)
ffffffffc020255a:	89b2                	mv	s3,a2
ffffffffc020255c:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020255e:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202560:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202562:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202564:	ec26                	sd	s1,24(sp)
ffffffffc0202566:	f406                	sd	ra,40(sp)
ffffffffc0202568:	e84a                	sd	s2,16(sp)
ffffffffc020256a:	e052                	sd	s4,0(sp)
ffffffffc020256c:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020256e:	9d3ff0ef          	jal	ra,ffffffffc0201f40 <get_pte>
    if (ptep == NULL) {
ffffffffc0202572:	cd49                	beqz	a0,ffffffffc020260c <page_insert+0xb6>
    page->ref += 1;
ffffffffc0202574:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0202576:	611c                	ld	a5,0(a0)
ffffffffc0202578:	892a                	mv	s2,a0
ffffffffc020257a:	0016871b          	addiw	a4,a3,1
ffffffffc020257e:	c018                	sw	a4,0(s0)
ffffffffc0202580:	0017f713          	andi	a4,a5,1
ffffffffc0202584:	ef05                	bnez	a4,ffffffffc02025bc <page_insert+0x66>
ffffffffc0202586:	000dd797          	auipc	a5,0xdd
ffffffffc020258a:	d9278793          	addi	a5,a5,-622 # ffffffffc02df318 <pages>
ffffffffc020258e:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0202590:	8c19                	sub	s0,s0,a4
ffffffffc0202592:	000806b7          	lui	a3,0x80
ffffffffc0202596:	8419                	srai	s0,s0,0x6
ffffffffc0202598:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020259a:	042a                	slli	s0,s0,0xa
ffffffffc020259c:	8c45                	or	s0,s0,s1
ffffffffc020259e:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02025a2:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025a6:	12098073          	sfence.vma	s3
    return 0;
ffffffffc02025aa:	4501                	li	a0,0
}
ffffffffc02025ac:	70a2                	ld	ra,40(sp)
ffffffffc02025ae:	7402                	ld	s0,32(sp)
ffffffffc02025b0:	64e2                	ld	s1,24(sp)
ffffffffc02025b2:	6942                	ld	s2,16(sp)
ffffffffc02025b4:	69a2                	ld	s3,8(sp)
ffffffffc02025b6:	6a02                	ld	s4,0(sp)
ffffffffc02025b8:	6145                	addi	sp,sp,48
ffffffffc02025ba:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02025bc:	000dd717          	auipc	a4,0xdd
ffffffffc02025c0:	cdc70713          	addi	a4,a4,-804 # ffffffffc02df298 <npage>
ffffffffc02025c4:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02025c6:	078a                	slli	a5,a5,0x2
ffffffffc02025c8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025ca:	04e7f363          	bleu	a4,a5,ffffffffc0202610 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc02025ce:	000dda17          	auipc	s4,0xdd
ffffffffc02025d2:	d4aa0a13          	addi	s4,s4,-694 # ffffffffc02df318 <pages>
ffffffffc02025d6:	000a3703          	ld	a4,0(s4)
ffffffffc02025da:	fff80537          	lui	a0,0xfff80
ffffffffc02025de:	953e                	add	a0,a0,a5
ffffffffc02025e0:	051a                	slli	a0,a0,0x6
ffffffffc02025e2:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc02025e4:	00a40a63          	beq	s0,a0,ffffffffc02025f8 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc02025e8:	411c                	lw	a5,0(a0)
ffffffffc02025ea:	fff7869b          	addiw	a3,a5,-1
ffffffffc02025ee:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc02025f0:	c691                	beqz	a3,ffffffffc02025fc <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025f2:	12098073          	sfence.vma	s3
ffffffffc02025f6:	bf69                	j	ffffffffc0202590 <page_insert+0x3a>
ffffffffc02025f8:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02025fa:	bf59                	j	ffffffffc0202590 <page_insert+0x3a>
            free_page(page);
ffffffffc02025fc:	4585                	li	a1,1
ffffffffc02025fe:	8bdff0ef          	jal	ra,ffffffffc0201eba <free_pages>
ffffffffc0202602:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202606:	12098073          	sfence.vma	s3
ffffffffc020260a:	b759                	j	ffffffffc0202590 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020260c:	5571                	li	a0,-4
ffffffffc020260e:	bf79                	j	ffffffffc02025ac <page_insert+0x56>
ffffffffc0202610:	807ff0ef          	jal	ra,ffffffffc0201e16 <pa2page.part.4>

ffffffffc0202614 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202614:	00006797          	auipc	a5,0x6
ffffffffc0202618:	c2478793          	addi	a5,a5,-988 # ffffffffc0208238 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020261c:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020261e:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202620:	00006517          	auipc	a0,0x6
ffffffffc0202624:	db050513          	addi	a0,a0,-592 # ffffffffc02083d0 <default_pmm_manager+0x198>
void pmm_init(void) {
ffffffffc0202628:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020262a:	000dd717          	auipc	a4,0xdd
ffffffffc020262e:	ccf73b23          	sd	a5,-810(a4) # ffffffffc02df300 <pmm_manager>
void pmm_init(void) {
ffffffffc0202632:	e0a2                	sd	s0,64(sp)
ffffffffc0202634:	fc26                	sd	s1,56(sp)
ffffffffc0202636:	f84a                	sd	s2,48(sp)
ffffffffc0202638:	f44e                	sd	s3,40(sp)
ffffffffc020263a:	f052                	sd	s4,32(sp)
ffffffffc020263c:	ec56                	sd	s5,24(sp)
ffffffffc020263e:	e85a                	sd	s6,16(sp)
ffffffffc0202640:	e45e                	sd	s7,8(sp)
ffffffffc0202642:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202644:	000dd417          	auipc	s0,0xdd
ffffffffc0202648:	cbc40413          	addi	s0,s0,-836 # ffffffffc02df300 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020264c:	b47fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    pmm_manager->init();
ffffffffc0202650:	601c                	ld	a5,0(s0)
ffffffffc0202652:	000dd497          	auipc	s1,0xdd
ffffffffc0202656:	c4648493          	addi	s1,s1,-954 # ffffffffc02df298 <npage>
ffffffffc020265a:	000dd917          	auipc	s2,0xdd
ffffffffc020265e:	cbe90913          	addi	s2,s2,-834 # ffffffffc02df318 <pages>
ffffffffc0202662:	679c                	ld	a5,8(a5)
ffffffffc0202664:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202666:	57f5                	li	a5,-3
ffffffffc0202668:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020266a:	00006517          	auipc	a0,0x6
ffffffffc020266e:	d7e50513          	addi	a0,a0,-642 # ffffffffc02083e8 <default_pmm_manager+0x1b0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202672:	000dd717          	auipc	a4,0xdd
ffffffffc0202676:	c8f73b23          	sd	a5,-874(a4) # ffffffffc02df308 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020267a:	b19fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020267e:	46c5                	li	a3,17
ffffffffc0202680:	06ee                	slli	a3,a3,0x1b
ffffffffc0202682:	40100613          	li	a2,1025
ffffffffc0202686:	16fd                	addi	a3,a3,-1
ffffffffc0202688:	0656                	slli	a2,a2,0x15
ffffffffc020268a:	07e005b7          	lui	a1,0x7e00
ffffffffc020268e:	00006517          	auipc	a0,0x6
ffffffffc0202692:	d7250513          	addi	a0,a0,-654 # ffffffffc0208400 <default_pmm_manager+0x1c8>
ffffffffc0202696:	afdfd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020269a:	777d                	lui	a4,0xfffff
ffffffffc020269c:	000de797          	auipc	a5,0xde
ffffffffc02026a0:	ec378793          	addi	a5,a5,-317 # ffffffffc02e055f <end+0xfff>
ffffffffc02026a4:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02026a6:	00088737          	lui	a4,0x88
ffffffffc02026aa:	000dd697          	auipc	a3,0xdd
ffffffffc02026ae:	bee6b723          	sd	a4,-1042(a3) # ffffffffc02df298 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026b2:	000dd717          	auipc	a4,0xdd
ffffffffc02026b6:	c6f73323          	sd	a5,-922(a4) # ffffffffc02df318 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02026ba:	4701                	li	a4,0
ffffffffc02026bc:	4685                	li	a3,1
ffffffffc02026be:	fff80837          	lui	a6,0xfff80
ffffffffc02026c2:	a019                	j	ffffffffc02026c8 <pmm_init+0xb4>
ffffffffc02026c4:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02026c8:	00671613          	slli	a2,a4,0x6
ffffffffc02026cc:	97b2                	add	a5,a5,a2
ffffffffc02026ce:	07a1                	addi	a5,a5,8
ffffffffc02026d0:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02026d4:	6090                	ld	a2,0(s1)
ffffffffc02026d6:	0705                	addi	a4,a4,1
ffffffffc02026d8:	010607b3          	add	a5,a2,a6
ffffffffc02026dc:	fef764e3          	bltu	a4,a5,ffffffffc02026c4 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02026e0:	00093503          	ld	a0,0(s2)
ffffffffc02026e4:	fe0007b7          	lui	a5,0xfe000
ffffffffc02026e8:	00661693          	slli	a3,a2,0x6
ffffffffc02026ec:	97aa                	add	a5,a5,a0
ffffffffc02026ee:	96be                	add	a3,a3,a5
ffffffffc02026f0:	c02007b7          	lui	a5,0xc0200
ffffffffc02026f4:	7af6ed63          	bltu	a3,a5,ffffffffc0202eae <pmm_init+0x89a>
ffffffffc02026f8:	000dd997          	auipc	s3,0xdd
ffffffffc02026fc:	c1098993          	addi	s3,s3,-1008 # ffffffffc02df308 <va_pa_offset>
ffffffffc0202700:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202704:	47c5                	li	a5,17
ffffffffc0202706:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202708:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc020270a:	02f6f763          	bleu	a5,a3,ffffffffc0202738 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020270e:	6585                	lui	a1,0x1
ffffffffc0202710:	15fd                	addi	a1,a1,-1
ffffffffc0202712:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0202714:	00c6d713          	srli	a4,a3,0xc
ffffffffc0202718:	48c77a63          	bleu	a2,a4,ffffffffc0202bac <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc020271c:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020271e:	75fd                	lui	a1,0xfffff
ffffffffc0202720:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0202722:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0202724:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202726:	40d786b3          	sub	a3,a5,a3
ffffffffc020272a:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc020272c:	00c6d593          	srli	a1,a3,0xc
ffffffffc0202730:	953a                	add	a0,a0,a4
ffffffffc0202732:	9602                	jalr	a2
ffffffffc0202734:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202738:	00006517          	auipc	a0,0x6
ffffffffc020273c:	cf050513          	addi	a0,a0,-784 # ffffffffc0208428 <default_pmm_manager+0x1f0>
ffffffffc0202740:	a53fd0ef          	jal	ra,ffffffffc0200192 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202744:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202746:	000dd417          	auipc	s0,0xdd
ffffffffc020274a:	b4a40413          	addi	s0,s0,-1206 # ffffffffc02df290 <boot_pgdir>
    pmm_manager->check();
ffffffffc020274e:	7b9c                	ld	a5,48(a5)
ffffffffc0202750:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202752:	00006517          	auipc	a0,0x6
ffffffffc0202756:	cee50513          	addi	a0,a0,-786 # ffffffffc0208440 <default_pmm_manager+0x208>
ffffffffc020275a:	a39fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020275e:	0000b697          	auipc	a3,0xb
ffffffffc0202762:	8a268693          	addi	a3,a3,-1886 # ffffffffc020d000 <boot_page_table_sv39>
ffffffffc0202766:	000dd797          	auipc	a5,0xdd
ffffffffc020276a:	b2d7b523          	sd	a3,-1238(a5) # ffffffffc02df290 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020276e:	c02007b7          	lui	a5,0xc0200
ffffffffc0202772:	10f6eae3          	bltu	a3,a5,ffffffffc0203086 <pmm_init+0xa72>
ffffffffc0202776:	0009b783          	ld	a5,0(s3)
ffffffffc020277a:	8e9d                	sub	a3,a3,a5
ffffffffc020277c:	000dd797          	auipc	a5,0xdd
ffffffffc0202780:	b8d7ba23          	sd	a3,-1132(a5) # ffffffffc02df310 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0202784:	f7cff0ef          	jal	ra,ffffffffc0201f00 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202788:	6098                	ld	a4,0(s1)
ffffffffc020278a:	c80007b7          	lui	a5,0xc8000
ffffffffc020278e:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0202790:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202792:	0ce7eae3          	bltu	a5,a4,ffffffffc0203066 <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202796:	6008                	ld	a0,0(s0)
ffffffffc0202798:	44050463          	beqz	a0,ffffffffc0202be0 <pmm_init+0x5cc>
ffffffffc020279c:	6785                	lui	a5,0x1
ffffffffc020279e:	17fd                	addi	a5,a5,-1
ffffffffc02027a0:	8fe9                	and	a5,a5,a0
ffffffffc02027a2:	2781                	sext.w	a5,a5
ffffffffc02027a4:	42079e63          	bnez	a5,ffffffffc0202be0 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02027a8:	4601                	li	a2,0
ffffffffc02027aa:	4581                	li	a1,0
ffffffffc02027ac:	967ff0ef          	jal	ra,ffffffffc0202112 <get_page>
ffffffffc02027b0:	78051b63          	bnez	a0,ffffffffc0202f46 <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02027b4:	4505                	li	a0,1
ffffffffc02027b6:	e7cff0ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc02027ba:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02027bc:	6008                	ld	a0,0(s0)
ffffffffc02027be:	4681                	li	a3,0
ffffffffc02027c0:	4601                	li	a2,0
ffffffffc02027c2:	85d6                	mv	a1,s5
ffffffffc02027c4:	d93ff0ef          	jal	ra,ffffffffc0202556 <page_insert>
ffffffffc02027c8:	7a051f63          	bnez	a0,ffffffffc0202f86 <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02027cc:	6008                	ld	a0,0(s0)
ffffffffc02027ce:	4601                	li	a2,0
ffffffffc02027d0:	4581                	li	a1,0
ffffffffc02027d2:	f6eff0ef          	jal	ra,ffffffffc0201f40 <get_pte>
ffffffffc02027d6:	78050863          	beqz	a0,ffffffffc0202f66 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc02027da:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027dc:	0017f713          	andi	a4,a5,1
ffffffffc02027e0:	3e070463          	beqz	a4,ffffffffc0202bc8 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02027e4:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02027e6:	078a                	slli	a5,a5,0x2
ffffffffc02027e8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02027ea:	3ce7f163          	bleu	a4,a5,ffffffffc0202bac <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02027ee:	00093683          	ld	a3,0(s2)
ffffffffc02027f2:	fff80637          	lui	a2,0xfff80
ffffffffc02027f6:	97b2                	add	a5,a5,a2
ffffffffc02027f8:	079a                	slli	a5,a5,0x6
ffffffffc02027fa:	97b6                	add	a5,a5,a3
ffffffffc02027fc:	72fa9563          	bne	s5,a5,ffffffffc0202f26 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc0202800:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8ad0>
ffffffffc0202804:	4785                	li	a5,1
ffffffffc0202806:	70fb9063          	bne	s7,a5,ffffffffc0202f06 <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020280a:	6008                	ld	a0,0(s0)
ffffffffc020280c:	76fd                	lui	a3,0xfffff
ffffffffc020280e:	611c                	ld	a5,0(a0)
ffffffffc0202810:	078a                	slli	a5,a5,0x2
ffffffffc0202812:	8ff5                	and	a5,a5,a3
ffffffffc0202814:	00c7d613          	srli	a2,a5,0xc
ffffffffc0202818:	66e67e63          	bleu	a4,a2,ffffffffc0202e94 <pmm_init+0x880>
ffffffffc020281c:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202820:	97e2                	add	a5,a5,s8
ffffffffc0202822:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8ad0>
ffffffffc0202826:	0b0a                	slli	s6,s6,0x2
ffffffffc0202828:	00db7b33          	and	s6,s6,a3
ffffffffc020282c:	00cb5793          	srli	a5,s6,0xc
ffffffffc0202830:	56e7f863          	bleu	a4,a5,ffffffffc0202da0 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202834:	4601                	li	a2,0
ffffffffc0202836:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202838:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020283a:	f06ff0ef          	jal	ra,ffffffffc0201f40 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020283e:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202840:	55651063          	bne	a0,s6,ffffffffc0202d80 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc0202844:	4505                	li	a0,1
ffffffffc0202846:	decff0ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc020284a:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020284c:	6008                	ld	a0,0(s0)
ffffffffc020284e:	46d1                	li	a3,20
ffffffffc0202850:	6605                	lui	a2,0x1
ffffffffc0202852:	85da                	mv	a1,s6
ffffffffc0202854:	d03ff0ef          	jal	ra,ffffffffc0202556 <page_insert>
ffffffffc0202858:	50051463          	bnez	a0,ffffffffc0202d60 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020285c:	6008                	ld	a0,0(s0)
ffffffffc020285e:	4601                	li	a2,0
ffffffffc0202860:	6585                	lui	a1,0x1
ffffffffc0202862:	edeff0ef          	jal	ra,ffffffffc0201f40 <get_pte>
ffffffffc0202866:	4c050d63          	beqz	a0,ffffffffc0202d40 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc020286a:	611c                	ld	a5,0(a0)
ffffffffc020286c:	0107f713          	andi	a4,a5,16
ffffffffc0202870:	4a070863          	beqz	a4,ffffffffc0202d20 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc0202874:	8b91                	andi	a5,a5,4
ffffffffc0202876:	48078563          	beqz	a5,ffffffffc0202d00 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020287a:	6008                	ld	a0,0(s0)
ffffffffc020287c:	611c                	ld	a5,0(a0)
ffffffffc020287e:	8bc1                	andi	a5,a5,16
ffffffffc0202880:	46078063          	beqz	a5,ffffffffc0202ce0 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc0202884:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_matrix_out_size+0x1f43d0>
ffffffffc0202888:	43779c63          	bne	a5,s7,ffffffffc0202cc0 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020288c:	4681                	li	a3,0
ffffffffc020288e:	6605                	lui	a2,0x1
ffffffffc0202890:	85d6                	mv	a1,s5
ffffffffc0202892:	cc5ff0ef          	jal	ra,ffffffffc0202556 <page_insert>
ffffffffc0202896:	40051563          	bnez	a0,ffffffffc0202ca0 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc020289a:	000aa703          	lw	a4,0(s5)
ffffffffc020289e:	4789                	li	a5,2
ffffffffc02028a0:	3ef71063          	bne	a4,a5,ffffffffc0202c80 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc02028a4:	000b2783          	lw	a5,0(s6)
ffffffffc02028a8:	3a079c63          	bnez	a5,ffffffffc0202c60 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02028ac:	6008                	ld	a0,0(s0)
ffffffffc02028ae:	4601                	li	a2,0
ffffffffc02028b0:	6585                	lui	a1,0x1
ffffffffc02028b2:	e8eff0ef          	jal	ra,ffffffffc0201f40 <get_pte>
ffffffffc02028b6:	38050563          	beqz	a0,ffffffffc0202c40 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc02028ba:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02028bc:	00177793          	andi	a5,a4,1
ffffffffc02028c0:	30078463          	beqz	a5,ffffffffc0202bc8 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02028c4:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02028c6:	00271793          	slli	a5,a4,0x2
ffffffffc02028ca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028cc:	2ed7f063          	bleu	a3,a5,ffffffffc0202bac <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02028d0:	00093683          	ld	a3,0(s2)
ffffffffc02028d4:	fff80637          	lui	a2,0xfff80
ffffffffc02028d8:	97b2                	add	a5,a5,a2
ffffffffc02028da:	079a                	slli	a5,a5,0x6
ffffffffc02028dc:	97b6                	add	a5,a5,a3
ffffffffc02028de:	32fa9163          	bne	s5,a5,ffffffffc0202c00 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc02028e2:	8b41                	andi	a4,a4,16
ffffffffc02028e4:	70071163          	bnez	a4,ffffffffc0202fe6 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc02028e8:	6008                	ld	a0,0(s0)
ffffffffc02028ea:	4581                	li	a1,0
ffffffffc02028ec:	bf7ff0ef          	jal	ra,ffffffffc02024e2 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02028f0:	000aa703          	lw	a4,0(s5)
ffffffffc02028f4:	4785                	li	a5,1
ffffffffc02028f6:	6cf71863          	bne	a4,a5,ffffffffc0202fc6 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc02028fa:	000b2783          	lw	a5,0(s6)
ffffffffc02028fe:	6a079463          	bnez	a5,ffffffffc0202fa6 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202902:	6008                	ld	a0,0(s0)
ffffffffc0202904:	6585                	lui	a1,0x1
ffffffffc0202906:	bddff0ef          	jal	ra,ffffffffc02024e2 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020290a:	000aa783          	lw	a5,0(s5)
ffffffffc020290e:	50079363          	bnez	a5,ffffffffc0202e14 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc0202912:	000b2783          	lw	a5,0(s6)
ffffffffc0202916:	4c079f63          	bnez	a5,ffffffffc0202df4 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020291a:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020291e:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202920:	000ab783          	ld	a5,0(s5)
ffffffffc0202924:	078a                	slli	a5,a5,0x2
ffffffffc0202926:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202928:	28c7f263          	bleu	a2,a5,ffffffffc0202bac <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020292c:	fff80737          	lui	a4,0xfff80
ffffffffc0202930:	00093503          	ld	a0,0(s2)
ffffffffc0202934:	97ba                	add	a5,a5,a4
ffffffffc0202936:	079a                	slli	a5,a5,0x6
ffffffffc0202938:	00f50733          	add	a4,a0,a5
ffffffffc020293c:	4314                	lw	a3,0(a4)
ffffffffc020293e:	4705                	li	a4,1
ffffffffc0202940:	48e69a63          	bne	a3,a4,ffffffffc0202dd4 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0202944:	8799                	srai	a5,a5,0x6
ffffffffc0202946:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020294a:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc020294c:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc020294e:	8331                	srli	a4,a4,0xc
ffffffffc0202950:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202952:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202954:	46c77363          	bleu	a2,a4,ffffffffc0202dba <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202958:	0009b683          	ld	a3,0(s3)
ffffffffc020295c:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc020295e:	639c                	ld	a5,0(a5)
ffffffffc0202960:	078a                	slli	a5,a5,0x2
ffffffffc0202962:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202964:	24c7f463          	bleu	a2,a5,ffffffffc0202bac <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202968:	416787b3          	sub	a5,a5,s6
ffffffffc020296c:	079a                	slli	a5,a5,0x6
ffffffffc020296e:	953e                	add	a0,a0,a5
ffffffffc0202970:	4585                	li	a1,1
ffffffffc0202972:	d48ff0ef          	jal	ra,ffffffffc0201eba <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202976:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc020297a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020297c:	078a                	slli	a5,a5,0x2
ffffffffc020297e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202980:	22e7f663          	bleu	a4,a5,ffffffffc0202bac <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202984:	00093503          	ld	a0,0(s2)
ffffffffc0202988:	416787b3          	sub	a5,a5,s6
ffffffffc020298c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020298e:	953e                	add	a0,a0,a5
ffffffffc0202990:	4585                	li	a1,1
ffffffffc0202992:	d28ff0ef          	jal	ra,ffffffffc0201eba <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202996:	601c                	ld	a5,0(s0)
ffffffffc0202998:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc020299c:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02029a0:	d60ff0ef          	jal	ra,ffffffffc0201f00 <nr_free_pages>
ffffffffc02029a4:	68aa1163          	bne	s4,a0,ffffffffc0203026 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02029a8:	00006517          	auipc	a0,0x6
ffffffffc02029ac:	da850513          	addi	a0,a0,-600 # ffffffffc0208750 <default_pmm_manager+0x518>
ffffffffc02029b0:	fe2fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02029b4:	d4cff0ef          	jal	ra,ffffffffc0201f00 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029b8:	6098                	ld	a4,0(s1)
ffffffffc02029ba:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02029be:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029c0:	00c71693          	slli	a3,a4,0xc
ffffffffc02029c4:	18d7f563          	bleu	a3,a5,ffffffffc0202b4e <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029c8:	83b1                	srli	a5,a5,0xc
ffffffffc02029ca:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029cc:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029d0:	1ae7f163          	bleu	a4,a5,ffffffffc0202b72 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02029d4:	7bfd                	lui	s7,0xfffff
ffffffffc02029d6:	6b05                	lui	s6,0x1
ffffffffc02029d8:	a029                	j	ffffffffc02029e2 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029da:	00cad713          	srli	a4,s5,0xc
ffffffffc02029de:	18f77a63          	bleu	a5,a4,ffffffffc0202b72 <pmm_init+0x55e>
ffffffffc02029e2:	0009b583          	ld	a1,0(s3)
ffffffffc02029e6:	4601                	li	a2,0
ffffffffc02029e8:	95d6                	add	a1,a1,s5
ffffffffc02029ea:	d56ff0ef          	jal	ra,ffffffffc0201f40 <get_pte>
ffffffffc02029ee:	16050263          	beqz	a0,ffffffffc0202b52 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02029f2:	611c                	ld	a5,0(a0)
ffffffffc02029f4:	078a                	slli	a5,a5,0x2
ffffffffc02029f6:	0177f7b3          	and	a5,a5,s7
ffffffffc02029fa:	19579963          	bne	a5,s5,ffffffffc0202b8c <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029fe:	609c                	ld	a5,0(s1)
ffffffffc0202a00:	9ada                	add	s5,s5,s6
ffffffffc0202a02:	6008                	ld	a0,0(s0)
ffffffffc0202a04:	00c79713          	slli	a4,a5,0xc
ffffffffc0202a08:	fceae9e3          	bltu	s5,a4,ffffffffc02029da <pmm_init+0x3c6>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202a0c:	611c                	ld	a5,0(a0)
ffffffffc0202a0e:	62079c63          	bnez	a5,ffffffffc0203046 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0202a12:	4505                	li	a0,1
ffffffffc0202a14:	c1eff0ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc0202a18:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202a1a:	6008                	ld	a0,0(s0)
ffffffffc0202a1c:	4699                	li	a3,6
ffffffffc0202a1e:	10000613          	li	a2,256
ffffffffc0202a22:	85d6                	mv	a1,s5
ffffffffc0202a24:	b33ff0ef          	jal	ra,ffffffffc0202556 <page_insert>
ffffffffc0202a28:	1e051c63          	bnez	a0,ffffffffc0202c20 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0202a2c:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0202a30:	4785                	li	a5,1
ffffffffc0202a32:	44f71163          	bne	a4,a5,ffffffffc0202e74 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202a36:	6008                	ld	a0,0(s0)
ffffffffc0202a38:	6b05                	lui	s6,0x1
ffffffffc0202a3a:	4699                	li	a3,6
ffffffffc0202a3c:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x89d0>
ffffffffc0202a40:	85d6                	mv	a1,s5
ffffffffc0202a42:	b15ff0ef          	jal	ra,ffffffffc0202556 <page_insert>
ffffffffc0202a46:	40051763          	bnez	a0,ffffffffc0202e54 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0202a4a:	000aa703          	lw	a4,0(s5)
ffffffffc0202a4e:	4789                	li	a5,2
ffffffffc0202a50:	3ef71263          	bne	a4,a5,ffffffffc0202e34 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202a54:	00006597          	auipc	a1,0x6
ffffffffc0202a58:	e3458593          	addi	a1,a1,-460 # ffffffffc0208888 <default_pmm_manager+0x650>
ffffffffc0202a5c:	10000513          	li	a0,256
ffffffffc0202a60:	21d040ef          	jal	ra,ffffffffc020747c <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202a64:	100b0593          	addi	a1,s6,256
ffffffffc0202a68:	10000513          	li	a0,256
ffffffffc0202a6c:	223040ef          	jal	ra,ffffffffc020748e <strcmp>
ffffffffc0202a70:	44051b63          	bnez	a0,ffffffffc0202ec6 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0202a74:	00093683          	ld	a3,0(s2)
ffffffffc0202a78:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202a7c:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202a7e:	40da86b3          	sub	a3,s5,a3
ffffffffc0202a82:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202a84:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202a86:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202a88:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0202a8c:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a90:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a92:	10f77f63          	bleu	a5,a4,ffffffffc0202bb0 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a96:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a9a:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a9e:	96be                	add	a3,a3,a5
ffffffffc0202aa0:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd1fba0>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202aa4:	195040ef          	jal	ra,ffffffffc0207438 <strlen>
ffffffffc0202aa8:	54051f63          	bnez	a0,ffffffffc0203006 <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202aac:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202ab0:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ab2:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd1faa0>
ffffffffc0202ab6:	068a                	slli	a3,a3,0x2
ffffffffc0202ab8:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202aba:	0ef6f963          	bleu	a5,a3,ffffffffc0202bac <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0202abe:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ac2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202ac4:	0efb7663          	bleu	a5,s6,ffffffffc0202bb0 <pmm_init+0x59c>
ffffffffc0202ac8:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202acc:	4585                	li	a1,1
ffffffffc0202ace:	8556                	mv	a0,s5
ffffffffc0202ad0:	99b6                	add	s3,s3,a3
ffffffffc0202ad2:	be8ff0ef          	jal	ra,ffffffffc0201eba <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ad6:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202ada:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202adc:	078a                	slli	a5,a5,0x2
ffffffffc0202ade:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ae0:	0ce7f663          	bleu	a4,a5,ffffffffc0202bac <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ae4:	00093503          	ld	a0,0(s2)
ffffffffc0202ae8:	fff809b7          	lui	s3,0xfff80
ffffffffc0202aec:	97ce                	add	a5,a5,s3
ffffffffc0202aee:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202af0:	953e                	add	a0,a0,a5
ffffffffc0202af2:	4585                	li	a1,1
ffffffffc0202af4:	bc6ff0ef          	jal	ra,ffffffffc0201eba <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202af8:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0202afc:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202afe:	078a                	slli	a5,a5,0x2
ffffffffc0202b00:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b02:	0ae7f563          	bleu	a4,a5,ffffffffc0202bac <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b06:	00093503          	ld	a0,0(s2)
ffffffffc0202b0a:	97ce                	add	a5,a5,s3
ffffffffc0202b0c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202b0e:	953e                	add	a0,a0,a5
ffffffffc0202b10:	4585                	li	a1,1
ffffffffc0202b12:	ba8ff0ef          	jal	ra,ffffffffc0201eba <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202b16:	601c                	ld	a5,0(s0)
ffffffffc0202b18:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0202b1c:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202b20:	be0ff0ef          	jal	ra,ffffffffc0201f00 <nr_free_pages>
ffffffffc0202b24:	3caa1163          	bne	s4,a0,ffffffffc0202ee6 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202b28:	00006517          	auipc	a0,0x6
ffffffffc0202b2c:	dd850513          	addi	a0,a0,-552 # ffffffffc0208900 <default_pmm_manager+0x6c8>
ffffffffc0202b30:	e62fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc0202b34:	6406                	ld	s0,64(sp)
ffffffffc0202b36:	60a6                	ld	ra,72(sp)
ffffffffc0202b38:	74e2                	ld	s1,56(sp)
ffffffffc0202b3a:	7942                	ld	s2,48(sp)
ffffffffc0202b3c:	79a2                	ld	s3,40(sp)
ffffffffc0202b3e:	7a02                	ld	s4,32(sp)
ffffffffc0202b40:	6ae2                	ld	s5,24(sp)
ffffffffc0202b42:	6b42                	ld	s6,16(sp)
ffffffffc0202b44:	6ba2                	ld	s7,8(sp)
ffffffffc0202b46:	6c02                	ld	s8,0(sp)
ffffffffc0202b48:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0202b4a:	8c8ff06f          	j	ffffffffc0201c12 <kmalloc_init>
ffffffffc0202b4e:	6008                	ld	a0,0(s0)
ffffffffc0202b50:	bd75                	j	ffffffffc0202a0c <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202b52:	00006697          	auipc	a3,0x6
ffffffffc0202b56:	c1e68693          	addi	a3,a3,-994 # ffffffffc0208770 <default_pmm_manager+0x538>
ffffffffc0202b5a:	00005617          	auipc	a2,0x5
ffffffffc0202b5e:	f9660613          	addi	a2,a2,-106 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202b62:	25700593          	li	a1,599
ffffffffc0202b66:	00006517          	auipc	a0,0x6
ffffffffc0202b6a:	84250513          	addi	a0,a0,-1982 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202b6e:	91bfd0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0202b72:	86d6                	mv	a3,s5
ffffffffc0202b74:	00005617          	auipc	a2,0x5
ffffffffc0202b78:	71460613          	addi	a2,a2,1812 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc0202b7c:	25700593          	li	a1,599
ffffffffc0202b80:	00006517          	auipc	a0,0x6
ffffffffc0202b84:	82850513          	addi	a0,a0,-2008 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202b88:	901fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202b8c:	00006697          	auipc	a3,0x6
ffffffffc0202b90:	c2468693          	addi	a3,a3,-988 # ffffffffc02087b0 <default_pmm_manager+0x578>
ffffffffc0202b94:	00005617          	auipc	a2,0x5
ffffffffc0202b98:	f5c60613          	addi	a2,a2,-164 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202b9c:	25800593          	li	a1,600
ffffffffc0202ba0:	00006517          	auipc	a0,0x6
ffffffffc0202ba4:	80850513          	addi	a0,a0,-2040 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202ba8:	8e1fd0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0202bac:	a6aff0ef          	jal	ra,ffffffffc0201e16 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0202bb0:	00005617          	auipc	a2,0x5
ffffffffc0202bb4:	6d860613          	addi	a2,a2,1752 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc0202bb8:	06900593          	li	a1,105
ffffffffc0202bbc:	00005517          	auipc	a0,0x5
ffffffffc0202bc0:	6f450513          	addi	a0,a0,1780 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc0202bc4:	8c5fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202bc8:	00006617          	auipc	a2,0x6
ffffffffc0202bcc:	97860613          	addi	a2,a2,-1672 # ffffffffc0208540 <default_pmm_manager+0x308>
ffffffffc0202bd0:	07400593          	li	a1,116
ffffffffc0202bd4:	00005517          	auipc	a0,0x5
ffffffffc0202bd8:	6dc50513          	addi	a0,a0,1756 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc0202bdc:	8adfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202be0:	00006697          	auipc	a3,0x6
ffffffffc0202be4:	8a068693          	addi	a3,a3,-1888 # ffffffffc0208480 <default_pmm_manager+0x248>
ffffffffc0202be8:	00005617          	auipc	a2,0x5
ffffffffc0202bec:	f0860613          	addi	a2,a2,-248 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202bf0:	21b00593          	li	a1,539
ffffffffc0202bf4:	00005517          	auipc	a0,0x5
ffffffffc0202bf8:	7b450513          	addi	a0,a0,1972 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202bfc:	88dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202c00:	00006697          	auipc	a3,0x6
ffffffffc0202c04:	96868693          	addi	a3,a3,-1688 # ffffffffc0208568 <default_pmm_manager+0x330>
ffffffffc0202c08:	00005617          	auipc	a2,0x5
ffffffffc0202c0c:	ee860613          	addi	a2,a2,-280 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202c10:	23700593          	li	a1,567
ffffffffc0202c14:	00005517          	auipc	a0,0x5
ffffffffc0202c18:	79450513          	addi	a0,a0,1940 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202c1c:	86dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c20:	00006697          	auipc	a3,0x6
ffffffffc0202c24:	bc068693          	addi	a3,a3,-1088 # ffffffffc02087e0 <default_pmm_manager+0x5a8>
ffffffffc0202c28:	00005617          	auipc	a2,0x5
ffffffffc0202c2c:	ec860613          	addi	a2,a2,-312 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202c30:	26000593          	li	a1,608
ffffffffc0202c34:	00005517          	auipc	a0,0x5
ffffffffc0202c38:	77450513          	addi	a0,a0,1908 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202c3c:	84dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202c40:	00006697          	auipc	a3,0x6
ffffffffc0202c44:	9b868693          	addi	a3,a3,-1608 # ffffffffc02085f8 <default_pmm_manager+0x3c0>
ffffffffc0202c48:	00005617          	auipc	a2,0x5
ffffffffc0202c4c:	ea860613          	addi	a2,a2,-344 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202c50:	23600593          	li	a1,566
ffffffffc0202c54:	00005517          	auipc	a0,0x5
ffffffffc0202c58:	75450513          	addi	a0,a0,1876 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202c5c:	82dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202c60:	00006697          	auipc	a3,0x6
ffffffffc0202c64:	a6068693          	addi	a3,a3,-1440 # ffffffffc02086c0 <default_pmm_manager+0x488>
ffffffffc0202c68:	00005617          	auipc	a2,0x5
ffffffffc0202c6c:	e8860613          	addi	a2,a2,-376 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202c70:	23500593          	li	a1,565
ffffffffc0202c74:	00005517          	auipc	a0,0x5
ffffffffc0202c78:	73450513          	addi	a0,a0,1844 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202c7c:	80dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202c80:	00006697          	auipc	a3,0x6
ffffffffc0202c84:	a2868693          	addi	a3,a3,-1496 # ffffffffc02086a8 <default_pmm_manager+0x470>
ffffffffc0202c88:	00005617          	auipc	a2,0x5
ffffffffc0202c8c:	e6860613          	addi	a2,a2,-408 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202c90:	23400593          	li	a1,564
ffffffffc0202c94:	00005517          	auipc	a0,0x5
ffffffffc0202c98:	71450513          	addi	a0,a0,1812 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202c9c:	fecfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202ca0:	00006697          	auipc	a3,0x6
ffffffffc0202ca4:	9d868693          	addi	a3,a3,-1576 # ffffffffc0208678 <default_pmm_manager+0x440>
ffffffffc0202ca8:	00005617          	auipc	a2,0x5
ffffffffc0202cac:	e4860613          	addi	a2,a2,-440 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202cb0:	23300593          	li	a1,563
ffffffffc0202cb4:	00005517          	auipc	a0,0x5
ffffffffc0202cb8:	6f450513          	addi	a0,a0,1780 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202cbc:	fccfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202cc0:	00006697          	auipc	a3,0x6
ffffffffc0202cc4:	9a068693          	addi	a3,a3,-1632 # ffffffffc0208660 <default_pmm_manager+0x428>
ffffffffc0202cc8:	00005617          	auipc	a2,0x5
ffffffffc0202ccc:	e2860613          	addi	a2,a2,-472 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202cd0:	23100593          	li	a1,561
ffffffffc0202cd4:	00005517          	auipc	a0,0x5
ffffffffc0202cd8:	6d450513          	addi	a0,a0,1748 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202cdc:	facfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202ce0:	00006697          	auipc	a3,0x6
ffffffffc0202ce4:	96868693          	addi	a3,a3,-1688 # ffffffffc0208648 <default_pmm_manager+0x410>
ffffffffc0202ce8:	00005617          	auipc	a2,0x5
ffffffffc0202cec:	e0860613          	addi	a2,a2,-504 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202cf0:	23000593          	li	a1,560
ffffffffc0202cf4:	00005517          	auipc	a0,0x5
ffffffffc0202cf8:	6b450513          	addi	a0,a0,1716 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202cfc:	f8cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202d00:	00006697          	auipc	a3,0x6
ffffffffc0202d04:	93868693          	addi	a3,a3,-1736 # ffffffffc0208638 <default_pmm_manager+0x400>
ffffffffc0202d08:	00005617          	auipc	a2,0x5
ffffffffc0202d0c:	de860613          	addi	a2,a2,-536 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202d10:	22f00593          	li	a1,559
ffffffffc0202d14:	00005517          	auipc	a0,0x5
ffffffffc0202d18:	69450513          	addi	a0,a0,1684 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202d1c:	f6cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202d20:	00006697          	auipc	a3,0x6
ffffffffc0202d24:	90868693          	addi	a3,a3,-1784 # ffffffffc0208628 <default_pmm_manager+0x3f0>
ffffffffc0202d28:	00005617          	auipc	a2,0x5
ffffffffc0202d2c:	dc860613          	addi	a2,a2,-568 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202d30:	22e00593          	li	a1,558
ffffffffc0202d34:	00005517          	auipc	a0,0x5
ffffffffc0202d38:	67450513          	addi	a0,a0,1652 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202d3c:	f4cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d40:	00006697          	auipc	a3,0x6
ffffffffc0202d44:	8b868693          	addi	a3,a3,-1864 # ffffffffc02085f8 <default_pmm_manager+0x3c0>
ffffffffc0202d48:	00005617          	auipc	a2,0x5
ffffffffc0202d4c:	da860613          	addi	a2,a2,-600 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202d50:	22d00593          	li	a1,557
ffffffffc0202d54:	00005517          	auipc	a0,0x5
ffffffffc0202d58:	65450513          	addi	a0,a0,1620 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202d5c:	f2cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d60:	00006697          	auipc	a3,0x6
ffffffffc0202d64:	86068693          	addi	a3,a3,-1952 # ffffffffc02085c0 <default_pmm_manager+0x388>
ffffffffc0202d68:	00005617          	auipc	a2,0x5
ffffffffc0202d6c:	d8860613          	addi	a2,a2,-632 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202d70:	22c00593          	li	a1,556
ffffffffc0202d74:	00005517          	auipc	a0,0x5
ffffffffc0202d78:	63450513          	addi	a0,a0,1588 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202d7c:	f0cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202d80:	00006697          	auipc	a3,0x6
ffffffffc0202d84:	81868693          	addi	a3,a3,-2024 # ffffffffc0208598 <default_pmm_manager+0x360>
ffffffffc0202d88:	00005617          	auipc	a2,0x5
ffffffffc0202d8c:	d6860613          	addi	a2,a2,-664 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202d90:	22900593          	li	a1,553
ffffffffc0202d94:	00005517          	auipc	a0,0x5
ffffffffc0202d98:	61450513          	addi	a0,a0,1556 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202d9c:	eecfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202da0:	86da                	mv	a3,s6
ffffffffc0202da2:	00005617          	auipc	a2,0x5
ffffffffc0202da6:	4e660613          	addi	a2,a2,1254 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc0202daa:	22800593          	li	a1,552
ffffffffc0202dae:	00005517          	auipc	a0,0x5
ffffffffc0202db2:	5fa50513          	addi	a0,a0,1530 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202db6:	ed2fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202dba:	86be                	mv	a3,a5
ffffffffc0202dbc:	00005617          	auipc	a2,0x5
ffffffffc0202dc0:	4cc60613          	addi	a2,a2,1228 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc0202dc4:	06900593          	li	a1,105
ffffffffc0202dc8:	00005517          	auipc	a0,0x5
ffffffffc0202dcc:	4e850513          	addi	a0,a0,1256 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc0202dd0:	eb8fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202dd4:	00006697          	auipc	a3,0x6
ffffffffc0202dd8:	93468693          	addi	a3,a3,-1740 # ffffffffc0208708 <default_pmm_manager+0x4d0>
ffffffffc0202ddc:	00005617          	auipc	a2,0x5
ffffffffc0202de0:	d1460613          	addi	a2,a2,-748 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202de4:	24200593          	li	a1,578
ffffffffc0202de8:	00005517          	auipc	a0,0x5
ffffffffc0202dec:	5c050513          	addi	a0,a0,1472 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202df0:	e98fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202df4:	00006697          	auipc	a3,0x6
ffffffffc0202df8:	8cc68693          	addi	a3,a3,-1844 # ffffffffc02086c0 <default_pmm_manager+0x488>
ffffffffc0202dfc:	00005617          	auipc	a2,0x5
ffffffffc0202e00:	cf460613          	addi	a2,a2,-780 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202e04:	24000593          	li	a1,576
ffffffffc0202e08:	00005517          	auipc	a0,0x5
ffffffffc0202e0c:	5a050513          	addi	a0,a0,1440 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202e10:	e78fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202e14:	00006697          	auipc	a3,0x6
ffffffffc0202e18:	8dc68693          	addi	a3,a3,-1828 # ffffffffc02086f0 <default_pmm_manager+0x4b8>
ffffffffc0202e1c:	00005617          	auipc	a2,0x5
ffffffffc0202e20:	cd460613          	addi	a2,a2,-812 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202e24:	23f00593          	li	a1,575
ffffffffc0202e28:	00005517          	auipc	a0,0x5
ffffffffc0202e2c:	58050513          	addi	a0,a0,1408 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202e30:	e58fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202e34:	00006697          	auipc	a3,0x6
ffffffffc0202e38:	a3c68693          	addi	a3,a3,-1476 # ffffffffc0208870 <default_pmm_manager+0x638>
ffffffffc0202e3c:	00005617          	auipc	a2,0x5
ffffffffc0202e40:	cb460613          	addi	a2,a2,-844 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202e44:	26300593          	li	a1,611
ffffffffc0202e48:	00005517          	auipc	a0,0x5
ffffffffc0202e4c:	56050513          	addi	a0,a0,1376 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202e50:	e38fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e54:	00006697          	auipc	a3,0x6
ffffffffc0202e58:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0208830 <default_pmm_manager+0x5f8>
ffffffffc0202e5c:	00005617          	auipc	a2,0x5
ffffffffc0202e60:	c9460613          	addi	a2,a2,-876 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202e64:	26200593          	li	a1,610
ffffffffc0202e68:	00005517          	auipc	a0,0x5
ffffffffc0202e6c:	54050513          	addi	a0,a0,1344 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202e70:	e18fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202e74:	00006697          	auipc	a3,0x6
ffffffffc0202e78:	9a468693          	addi	a3,a3,-1628 # ffffffffc0208818 <default_pmm_manager+0x5e0>
ffffffffc0202e7c:	00005617          	auipc	a2,0x5
ffffffffc0202e80:	c7460613          	addi	a2,a2,-908 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202e84:	26100593          	li	a1,609
ffffffffc0202e88:	00005517          	auipc	a0,0x5
ffffffffc0202e8c:	52050513          	addi	a0,a0,1312 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202e90:	df8fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202e94:	86be                	mv	a3,a5
ffffffffc0202e96:	00005617          	auipc	a2,0x5
ffffffffc0202e9a:	3f260613          	addi	a2,a2,1010 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc0202e9e:	22700593          	li	a1,551
ffffffffc0202ea2:	00005517          	auipc	a0,0x5
ffffffffc0202ea6:	50650513          	addi	a0,a0,1286 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202eaa:	ddefd0ef          	jal	ra,ffffffffc0200488 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202eae:	00005617          	auipc	a2,0x5
ffffffffc0202eb2:	41260613          	addi	a2,a2,1042 # ffffffffc02082c0 <default_pmm_manager+0x88>
ffffffffc0202eb6:	07f00593          	li	a1,127
ffffffffc0202eba:	00005517          	auipc	a0,0x5
ffffffffc0202ebe:	4ee50513          	addi	a0,a0,1262 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202ec2:	dc6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202ec6:	00006697          	auipc	a3,0x6
ffffffffc0202eca:	9da68693          	addi	a3,a3,-1574 # ffffffffc02088a0 <default_pmm_manager+0x668>
ffffffffc0202ece:	00005617          	auipc	a2,0x5
ffffffffc0202ed2:	c2260613          	addi	a2,a2,-990 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202ed6:	26700593          	li	a1,615
ffffffffc0202eda:	00005517          	auipc	a0,0x5
ffffffffc0202ede:	4ce50513          	addi	a0,a0,1230 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202ee2:	da6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202ee6:	00006697          	auipc	a3,0x6
ffffffffc0202eea:	84a68693          	addi	a3,a3,-1974 # ffffffffc0208730 <default_pmm_manager+0x4f8>
ffffffffc0202eee:	00005617          	auipc	a2,0x5
ffffffffc0202ef2:	c0260613          	addi	a2,a2,-1022 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202ef6:	27300593          	li	a1,627
ffffffffc0202efa:	00005517          	auipc	a0,0x5
ffffffffc0202efe:	4ae50513          	addi	a0,a0,1198 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202f02:	d86fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202f06:	00005697          	auipc	a3,0x5
ffffffffc0202f0a:	67a68693          	addi	a3,a3,1658 # ffffffffc0208580 <default_pmm_manager+0x348>
ffffffffc0202f0e:	00005617          	auipc	a2,0x5
ffffffffc0202f12:	be260613          	addi	a2,a2,-1054 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202f16:	22500593          	li	a1,549
ffffffffc0202f1a:	00005517          	auipc	a0,0x5
ffffffffc0202f1e:	48e50513          	addi	a0,a0,1166 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202f22:	d66fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f26:	00005697          	auipc	a3,0x5
ffffffffc0202f2a:	64268693          	addi	a3,a3,1602 # ffffffffc0208568 <default_pmm_manager+0x330>
ffffffffc0202f2e:	00005617          	auipc	a2,0x5
ffffffffc0202f32:	bc260613          	addi	a2,a2,-1086 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202f36:	22400593          	li	a1,548
ffffffffc0202f3a:	00005517          	auipc	a0,0x5
ffffffffc0202f3e:	46e50513          	addi	a0,a0,1134 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202f42:	d46fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202f46:	00005697          	auipc	a3,0x5
ffffffffc0202f4a:	57268693          	addi	a3,a3,1394 # ffffffffc02084b8 <default_pmm_manager+0x280>
ffffffffc0202f4e:	00005617          	auipc	a2,0x5
ffffffffc0202f52:	ba260613          	addi	a2,a2,-1118 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202f56:	21c00593          	li	a1,540
ffffffffc0202f5a:	00005517          	auipc	a0,0x5
ffffffffc0202f5e:	44e50513          	addi	a0,a0,1102 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202f62:	d26fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202f66:	00005697          	auipc	a3,0x5
ffffffffc0202f6a:	5aa68693          	addi	a3,a3,1450 # ffffffffc0208510 <default_pmm_manager+0x2d8>
ffffffffc0202f6e:	00005617          	auipc	a2,0x5
ffffffffc0202f72:	b8260613          	addi	a2,a2,-1150 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202f76:	22300593          	li	a1,547
ffffffffc0202f7a:	00005517          	auipc	a0,0x5
ffffffffc0202f7e:	42e50513          	addi	a0,a0,1070 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202f82:	d06fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202f86:	00005697          	auipc	a3,0x5
ffffffffc0202f8a:	55a68693          	addi	a3,a3,1370 # ffffffffc02084e0 <default_pmm_manager+0x2a8>
ffffffffc0202f8e:	00005617          	auipc	a2,0x5
ffffffffc0202f92:	b6260613          	addi	a2,a2,-1182 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202f96:	22000593          	li	a1,544
ffffffffc0202f9a:	00005517          	auipc	a0,0x5
ffffffffc0202f9e:	40e50513          	addi	a0,a0,1038 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202fa2:	ce6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202fa6:	00005697          	auipc	a3,0x5
ffffffffc0202faa:	71a68693          	addi	a3,a3,1818 # ffffffffc02086c0 <default_pmm_manager+0x488>
ffffffffc0202fae:	00005617          	auipc	a2,0x5
ffffffffc0202fb2:	b4260613          	addi	a2,a2,-1214 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202fb6:	23c00593          	li	a1,572
ffffffffc0202fba:	00005517          	auipc	a0,0x5
ffffffffc0202fbe:	3ee50513          	addi	a0,a0,1006 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202fc2:	cc6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202fc6:	00005697          	auipc	a3,0x5
ffffffffc0202fca:	5ba68693          	addi	a3,a3,1466 # ffffffffc0208580 <default_pmm_manager+0x348>
ffffffffc0202fce:	00005617          	auipc	a2,0x5
ffffffffc0202fd2:	b2260613          	addi	a2,a2,-1246 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202fd6:	23b00593          	li	a1,571
ffffffffc0202fda:	00005517          	auipc	a0,0x5
ffffffffc0202fde:	3ce50513          	addi	a0,a0,974 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0202fe2:	ca6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202fe6:	00005697          	auipc	a3,0x5
ffffffffc0202fea:	6f268693          	addi	a3,a3,1778 # ffffffffc02086d8 <default_pmm_manager+0x4a0>
ffffffffc0202fee:	00005617          	auipc	a2,0x5
ffffffffc0202ff2:	b0260613          	addi	a2,a2,-1278 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0202ff6:	23800593          	li	a1,568
ffffffffc0202ffa:	00005517          	auipc	a0,0x5
ffffffffc0202ffe:	3ae50513          	addi	a0,a0,942 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0203002:	c86fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203006:	00006697          	auipc	a3,0x6
ffffffffc020300a:	8d268693          	addi	a3,a3,-1838 # ffffffffc02088d8 <default_pmm_manager+0x6a0>
ffffffffc020300e:	00005617          	auipc	a2,0x5
ffffffffc0203012:	ae260613          	addi	a2,a2,-1310 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203016:	26a00593          	li	a1,618
ffffffffc020301a:	00005517          	auipc	a0,0x5
ffffffffc020301e:	38e50513          	addi	a0,a0,910 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0203022:	c66fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203026:	00005697          	auipc	a3,0x5
ffffffffc020302a:	70a68693          	addi	a3,a3,1802 # ffffffffc0208730 <default_pmm_manager+0x4f8>
ffffffffc020302e:	00005617          	auipc	a2,0x5
ffffffffc0203032:	ac260613          	addi	a2,a2,-1342 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203036:	24a00593          	li	a1,586
ffffffffc020303a:	00005517          	auipc	a0,0x5
ffffffffc020303e:	36e50513          	addi	a0,a0,878 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0203042:	c46fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203046:	00005697          	auipc	a3,0x5
ffffffffc020304a:	78268693          	addi	a3,a3,1922 # ffffffffc02087c8 <default_pmm_manager+0x590>
ffffffffc020304e:	00005617          	auipc	a2,0x5
ffffffffc0203052:	aa260613          	addi	a2,a2,-1374 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203056:	25c00593          	li	a1,604
ffffffffc020305a:	00005517          	auipc	a0,0x5
ffffffffc020305e:	34e50513          	addi	a0,a0,846 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0203062:	c26fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203066:	00005697          	auipc	a3,0x5
ffffffffc020306a:	3fa68693          	addi	a3,a3,1018 # ffffffffc0208460 <default_pmm_manager+0x228>
ffffffffc020306e:	00005617          	auipc	a2,0x5
ffffffffc0203072:	a8260613          	addi	a2,a2,-1406 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203076:	21a00593          	li	a1,538
ffffffffc020307a:	00005517          	auipc	a0,0x5
ffffffffc020307e:	32e50513          	addi	a0,a0,814 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0203082:	c06fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203086:	00005617          	auipc	a2,0x5
ffffffffc020308a:	23a60613          	addi	a2,a2,570 # ffffffffc02082c0 <default_pmm_manager+0x88>
ffffffffc020308e:	0c100593          	li	a1,193
ffffffffc0203092:	00005517          	auipc	a0,0x5
ffffffffc0203096:	31650513          	addi	a0,a0,790 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc020309a:	beefd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020309e <copy_range>:
               bool share) {
ffffffffc020309e:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030a0:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc02030a4:	f486                	sd	ra,104(sp)
ffffffffc02030a6:	f0a2                	sd	s0,96(sp)
ffffffffc02030a8:	eca6                	sd	s1,88(sp)
ffffffffc02030aa:	e8ca                	sd	s2,80(sp)
ffffffffc02030ac:	e4ce                	sd	s3,72(sp)
ffffffffc02030ae:	e0d2                	sd	s4,64(sp)
ffffffffc02030b0:	fc56                	sd	s5,56(sp)
ffffffffc02030b2:	f85a                	sd	s6,48(sp)
ffffffffc02030b4:	f45e                	sd	s7,40(sp)
ffffffffc02030b6:	f062                	sd	s8,32(sp)
ffffffffc02030b8:	ec66                	sd	s9,24(sp)
ffffffffc02030ba:	e86a                	sd	s10,16(sp)
ffffffffc02030bc:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030be:	03479713          	slli	a4,a5,0x34
ffffffffc02030c2:	1e071863          	bnez	a4,ffffffffc02032b2 <copy_range+0x214>
    assert(USER_ACCESS(start, end));
ffffffffc02030c6:	002007b7          	lui	a5,0x200
ffffffffc02030ca:	8432                	mv	s0,a2
ffffffffc02030cc:	16f66b63          	bltu	a2,a5,ffffffffc0203242 <copy_range+0x1a4>
ffffffffc02030d0:	84b6                	mv	s1,a3
ffffffffc02030d2:	16d67863          	bleu	a3,a2,ffffffffc0203242 <copy_range+0x1a4>
ffffffffc02030d6:	4785                	li	a5,1
ffffffffc02030d8:	07fe                	slli	a5,a5,0x1f
ffffffffc02030da:	16d7e463          	bltu	a5,a3,ffffffffc0203242 <copy_range+0x1a4>
ffffffffc02030de:	5a7d                	li	s4,-1
ffffffffc02030e0:	8aaa                	mv	s5,a0
ffffffffc02030e2:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc02030e4:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc02030e6:	000dcc17          	auipc	s8,0xdc
ffffffffc02030ea:	1b2c0c13          	addi	s8,s8,434 # ffffffffc02df298 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02030ee:	000dcb97          	auipc	s7,0xdc
ffffffffc02030f2:	22ab8b93          	addi	s7,s7,554 # ffffffffc02df318 <pages>
    return page - pages + nbase;
ffffffffc02030f6:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc02030fa:	00ca5a13          	srli	s4,s4,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02030fe:	4601                	li	a2,0
ffffffffc0203100:	85a2                	mv	a1,s0
ffffffffc0203102:	854a                	mv	a0,s2
ffffffffc0203104:	e3dfe0ef          	jal	ra,ffffffffc0201f40 <get_pte>
ffffffffc0203108:	8caa                	mv	s9,a0
        if (ptep == NULL) {
ffffffffc020310a:	c17d                	beqz	a0,ffffffffc02031f0 <copy_range+0x152>
        if (*ptep & PTE_V) {
ffffffffc020310c:	611c                	ld	a5,0(a0)
ffffffffc020310e:	8b85                	andi	a5,a5,1
ffffffffc0203110:	e785                	bnez	a5,ffffffffc0203138 <copy_range+0x9a>
        start += PGSIZE;
ffffffffc0203112:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0203114:	fe9465e3          	bltu	s0,s1,ffffffffc02030fe <copy_range+0x60>
    return 0;
ffffffffc0203118:	4501                	li	a0,0
}
ffffffffc020311a:	70a6                	ld	ra,104(sp)
ffffffffc020311c:	7406                	ld	s0,96(sp)
ffffffffc020311e:	64e6                	ld	s1,88(sp)
ffffffffc0203120:	6946                	ld	s2,80(sp)
ffffffffc0203122:	69a6                	ld	s3,72(sp)
ffffffffc0203124:	6a06                	ld	s4,64(sp)
ffffffffc0203126:	7ae2                	ld	s5,56(sp)
ffffffffc0203128:	7b42                	ld	s6,48(sp)
ffffffffc020312a:	7ba2                	ld	s7,40(sp)
ffffffffc020312c:	7c02                	ld	s8,32(sp)
ffffffffc020312e:	6ce2                	ld	s9,24(sp)
ffffffffc0203130:	6d42                	ld	s10,16(sp)
ffffffffc0203132:	6da2                	ld	s11,8(sp)
ffffffffc0203134:	6165                	addi	sp,sp,112
ffffffffc0203136:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0203138:	4605                	li	a2,1
ffffffffc020313a:	85a2                	mv	a1,s0
ffffffffc020313c:	8556                	mv	a0,s5
ffffffffc020313e:	e03fe0ef          	jal	ra,ffffffffc0201f40 <get_pte>
ffffffffc0203142:	c169                	beqz	a0,ffffffffc0203204 <copy_range+0x166>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0203144:	000cb783          	ld	a5,0(s9)
    if (!(pte & PTE_V)) {
ffffffffc0203148:	0017f713          	andi	a4,a5,1
ffffffffc020314c:	01f7fc93          	andi	s9,a5,31
ffffffffc0203150:	14070563          	beqz	a4,ffffffffc020329a <copy_range+0x1fc>
    if (PPN(pa) >= npage) {
ffffffffc0203154:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203158:	078a                	slli	a5,a5,0x2
ffffffffc020315a:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020315e:	12d77263          	bleu	a3,a4,ffffffffc0203282 <copy_range+0x1e4>
    return &pages[PPN(pa) - nbase];
ffffffffc0203162:	000bb783          	ld	a5,0(s7)
ffffffffc0203166:	fff806b7          	lui	a3,0xfff80
ffffffffc020316a:	9736                	add	a4,a4,a3
ffffffffc020316c:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc020316e:	4505                	li	a0,1
ffffffffc0203170:	00e78db3          	add	s11,a5,a4
ffffffffc0203174:	cbffe0ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc0203178:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc020317a:	0a0d8463          	beqz	s11,ffffffffc0203222 <copy_range+0x184>
            assert(npage != NULL);
ffffffffc020317e:	c175                	beqz	a0,ffffffffc0203262 <copy_range+0x1c4>
    return page - pages + nbase;
ffffffffc0203180:	000bb703          	ld	a4,0(s7)
    return KADDR(page2pa(page));
ffffffffc0203184:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0203188:	40ed86b3          	sub	a3,s11,a4
ffffffffc020318c:	8699                	srai	a3,a3,0x6
ffffffffc020318e:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc0203190:	0146f7b3          	and	a5,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc0203194:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203196:	06c7fa63          	bleu	a2,a5,ffffffffc020320a <copy_range+0x16c>
    return page - pages + nbase;
ffffffffc020319a:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc020319e:	000dc717          	auipc	a4,0xdc
ffffffffc02031a2:	16a70713          	addi	a4,a4,362 # ffffffffc02df308 <va_pa_offset>
ffffffffc02031a6:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02031a8:	8799                	srai	a5,a5,0x6
ffffffffc02031aa:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc02031ac:	0147f733          	and	a4,a5,s4
ffffffffc02031b0:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02031b4:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02031b6:	04c77963          	bleu	a2,a4,ffffffffc0203208 <copy_range+0x16a>
            memcpy(dst, src, PGSIZE);
ffffffffc02031ba:	6605                	lui	a2,0x1
ffffffffc02031bc:	953e                	add	a0,a0,a5
ffffffffc02031be:	32a040ef          	jal	ra,ffffffffc02074e8 <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02031c2:	86e6                	mv	a3,s9
ffffffffc02031c4:	8622                	mv	a2,s0
ffffffffc02031c6:	85ea                	mv	a1,s10
ffffffffc02031c8:	8556                	mv	a0,s5
ffffffffc02031ca:	b8cff0ef          	jal	ra,ffffffffc0202556 <page_insert>
            assert(ret == 0);
ffffffffc02031ce:	d131                	beqz	a0,ffffffffc0203112 <copy_range+0x74>
ffffffffc02031d0:	00005697          	auipc	a3,0x5
ffffffffc02031d4:	1c868693          	addi	a3,a3,456 # ffffffffc0208398 <default_pmm_manager+0x160>
ffffffffc02031d8:	00005617          	auipc	a2,0x5
ffffffffc02031dc:	91860613          	addi	a2,a2,-1768 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02031e0:	1bc00593          	li	a1,444
ffffffffc02031e4:	00005517          	auipc	a0,0x5
ffffffffc02031e8:	1c450513          	addi	a0,a0,452 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc02031ec:	a9cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02031f0:	002007b7          	lui	a5,0x200
ffffffffc02031f4:	943e                	add	s0,s0,a5
ffffffffc02031f6:	ffe007b7          	lui	a5,0xffe00
ffffffffc02031fa:	8c7d                	and	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc02031fc:	dc11                	beqz	s0,ffffffffc0203118 <copy_range+0x7a>
ffffffffc02031fe:	f09460e3          	bltu	s0,s1,ffffffffc02030fe <copy_range+0x60>
ffffffffc0203202:	bf19                	j	ffffffffc0203118 <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc0203204:	5571                	li	a0,-4
ffffffffc0203206:	bf11                	j	ffffffffc020311a <copy_range+0x7c>
ffffffffc0203208:	86be                	mv	a3,a5
ffffffffc020320a:	00005617          	auipc	a2,0x5
ffffffffc020320e:	07e60613          	addi	a2,a2,126 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc0203212:	06900593          	li	a1,105
ffffffffc0203216:	00005517          	auipc	a0,0x5
ffffffffc020321a:	09a50513          	addi	a0,a0,154 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc020321e:	a6afd0ef          	jal	ra,ffffffffc0200488 <__panic>
            assert(page != NULL);
ffffffffc0203222:	00005697          	auipc	a3,0x5
ffffffffc0203226:	15668693          	addi	a3,a3,342 # ffffffffc0208378 <default_pmm_manager+0x140>
ffffffffc020322a:	00005617          	auipc	a2,0x5
ffffffffc020322e:	8c660613          	addi	a2,a2,-1850 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203232:	1a300593          	li	a1,419
ffffffffc0203236:	00005517          	auipc	a0,0x5
ffffffffc020323a:	17250513          	addi	a0,a0,370 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc020323e:	a4afd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203242:	00005697          	auipc	a3,0x5
ffffffffc0203246:	70e68693          	addi	a3,a3,1806 # ffffffffc0208950 <default_pmm_manager+0x718>
ffffffffc020324a:	00005617          	auipc	a2,0x5
ffffffffc020324e:	8a660613          	addi	a2,a2,-1882 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203252:	18f00593          	li	a1,399
ffffffffc0203256:	00005517          	auipc	a0,0x5
ffffffffc020325a:	15250513          	addi	a0,a0,338 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc020325e:	a2afd0ef          	jal	ra,ffffffffc0200488 <__panic>
            assert(npage != NULL);
ffffffffc0203262:	00005697          	auipc	a3,0x5
ffffffffc0203266:	12668693          	addi	a3,a3,294 # ffffffffc0208388 <default_pmm_manager+0x150>
ffffffffc020326a:	00005617          	auipc	a2,0x5
ffffffffc020326e:	88660613          	addi	a2,a2,-1914 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203272:	1a400593          	li	a1,420
ffffffffc0203276:	00005517          	auipc	a0,0x5
ffffffffc020327a:	13250513          	addi	a0,a0,306 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc020327e:	a0afd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203282:	00005617          	auipc	a2,0x5
ffffffffc0203286:	06660613          	addi	a2,a2,102 # ffffffffc02082e8 <default_pmm_manager+0xb0>
ffffffffc020328a:	06200593          	li	a1,98
ffffffffc020328e:	00005517          	auipc	a0,0x5
ffffffffc0203292:	02250513          	addi	a0,a0,34 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc0203296:	9f2fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020329a:	00005617          	auipc	a2,0x5
ffffffffc020329e:	2a660613          	addi	a2,a2,678 # ffffffffc0208540 <default_pmm_manager+0x308>
ffffffffc02032a2:	07400593          	li	a1,116
ffffffffc02032a6:	00005517          	auipc	a0,0x5
ffffffffc02032aa:	00a50513          	addi	a0,a0,10 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc02032ae:	9dafd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02032b2:	00005697          	auipc	a3,0x5
ffffffffc02032b6:	66e68693          	addi	a3,a3,1646 # ffffffffc0208920 <default_pmm_manager+0x6e8>
ffffffffc02032ba:	00005617          	auipc	a2,0x5
ffffffffc02032be:	83660613          	addi	a2,a2,-1994 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02032c2:	18e00593          	li	a1,398
ffffffffc02032c6:	00005517          	auipc	a0,0x5
ffffffffc02032ca:	0e250513          	addi	a0,a0,226 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc02032ce:	9bafd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02032d2 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02032d2:	12058073          	sfence.vma	a1
}
ffffffffc02032d6:	8082                	ret

ffffffffc02032d8 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02032d8:	7179                	addi	sp,sp,-48
ffffffffc02032da:	e84a                	sd	s2,16(sp)
ffffffffc02032dc:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02032de:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02032e0:	f022                	sd	s0,32(sp)
ffffffffc02032e2:	ec26                	sd	s1,24(sp)
ffffffffc02032e4:	e44e                	sd	s3,8(sp)
ffffffffc02032e6:	f406                	sd	ra,40(sp)
ffffffffc02032e8:	84ae                	mv	s1,a1
ffffffffc02032ea:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02032ec:	b47fe0ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc02032f0:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02032f2:	cd1d                	beqz	a0,ffffffffc0203330 <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02032f4:	85aa                	mv	a1,a0
ffffffffc02032f6:	86ce                	mv	a3,s3
ffffffffc02032f8:	8626                	mv	a2,s1
ffffffffc02032fa:	854a                	mv	a0,s2
ffffffffc02032fc:	a5aff0ef          	jal	ra,ffffffffc0202556 <page_insert>
ffffffffc0203300:	e121                	bnez	a0,ffffffffc0203340 <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc0203302:	000dc797          	auipc	a5,0xdc
ffffffffc0203306:	fa678793          	addi	a5,a5,-90 # ffffffffc02df2a8 <swap_init_ok>
ffffffffc020330a:	439c                	lw	a5,0(a5)
ffffffffc020330c:	2781                	sext.w	a5,a5
ffffffffc020330e:	c38d                	beqz	a5,ffffffffc0203330 <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc0203310:	000dc797          	auipc	a5,0xdc
ffffffffc0203314:	0e878793          	addi	a5,a5,232 # ffffffffc02df3f8 <check_mm_struct>
ffffffffc0203318:	6388                	ld	a0,0(a5)
ffffffffc020331a:	c919                	beqz	a0,ffffffffc0203330 <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc020331c:	4681                	li	a3,0
ffffffffc020331e:	8622                	mv	a2,s0
ffffffffc0203320:	85a6                	mv	a1,s1
ffffffffc0203322:	7da000ef          	jal	ra,ffffffffc0203afc <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0203326:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0203328:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc020332a:	4785                	li	a5,1
ffffffffc020332c:	02f71063          	bne	a4,a5,ffffffffc020334c <pgdir_alloc_page+0x74>
}
ffffffffc0203330:	8522                	mv	a0,s0
ffffffffc0203332:	70a2                	ld	ra,40(sp)
ffffffffc0203334:	7402                	ld	s0,32(sp)
ffffffffc0203336:	64e2                	ld	s1,24(sp)
ffffffffc0203338:	6942                	ld	s2,16(sp)
ffffffffc020333a:	69a2                	ld	s3,8(sp)
ffffffffc020333c:	6145                	addi	sp,sp,48
ffffffffc020333e:	8082                	ret
            free_page(page);
ffffffffc0203340:	8522                	mv	a0,s0
ffffffffc0203342:	4585                	li	a1,1
ffffffffc0203344:	b77fe0ef          	jal	ra,ffffffffc0201eba <free_pages>
            return NULL;
ffffffffc0203348:	4401                	li	s0,0
ffffffffc020334a:	b7dd                	j	ffffffffc0203330 <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc020334c:	00005697          	auipc	a3,0x5
ffffffffc0203350:	06c68693          	addi	a3,a3,108 # ffffffffc02083b8 <default_pmm_manager+0x180>
ffffffffc0203354:	00004617          	auipc	a2,0x4
ffffffffc0203358:	79c60613          	addi	a2,a2,1948 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020335c:	1fb00593          	li	a1,507
ffffffffc0203360:	00005517          	auipc	a0,0x5
ffffffffc0203364:	04850513          	addi	a0,a0,72 # ffffffffc02083a8 <default_pmm_manager+0x170>
ffffffffc0203368:	920fd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020336c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020336c:	7135                	addi	sp,sp,-160
ffffffffc020336e:	ed06                	sd	ra,152(sp)
ffffffffc0203370:	e922                	sd	s0,144(sp)
ffffffffc0203372:	e526                	sd	s1,136(sp)
ffffffffc0203374:	e14a                	sd	s2,128(sp)
ffffffffc0203376:	fcce                	sd	s3,120(sp)
ffffffffc0203378:	f8d2                	sd	s4,112(sp)
ffffffffc020337a:	f4d6                	sd	s5,104(sp)
ffffffffc020337c:	f0da                	sd	s6,96(sp)
ffffffffc020337e:	ecde                	sd	s7,88(sp)
ffffffffc0203380:	e8e2                	sd	s8,80(sp)
ffffffffc0203382:	e4e6                	sd	s9,72(sp)
ffffffffc0203384:	e0ea                	sd	s10,64(sp)
ffffffffc0203386:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0203388:	09a020ef          	jal	ra,ffffffffc0205422 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020338c:	000dc797          	auipc	a5,0xdc
ffffffffc0203390:	01c78793          	addi	a5,a5,28 # ffffffffc02df3a8 <max_swap_offset>
ffffffffc0203394:	6394                	ld	a3,0(a5)
ffffffffc0203396:	010007b7          	lui	a5,0x1000
ffffffffc020339a:	17e1                	addi	a5,a5,-8
ffffffffc020339c:	ff968713          	addi	a4,a3,-7
ffffffffc02033a0:	4ae7ee63          	bltu	a5,a4,ffffffffc020385c <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02033a4:	000d1797          	auipc	a5,0xd1
ffffffffc02033a8:	a2478793          	addi	a5,a5,-1500 # ffffffffc02d3dc8 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02033ac:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02033ae:	000dc697          	auipc	a3,0xdc
ffffffffc02033b2:	eef6b923          	sd	a5,-270(a3) # ffffffffc02df2a0 <sm>
     int r = sm->init();
ffffffffc02033b6:	9702                	jalr	a4
ffffffffc02033b8:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc02033ba:	c10d                	beqz	a0,ffffffffc02033dc <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02033bc:	60ea                	ld	ra,152(sp)
ffffffffc02033be:	644a                	ld	s0,144(sp)
ffffffffc02033c0:	8556                	mv	a0,s5
ffffffffc02033c2:	64aa                	ld	s1,136(sp)
ffffffffc02033c4:	690a                	ld	s2,128(sp)
ffffffffc02033c6:	79e6                	ld	s3,120(sp)
ffffffffc02033c8:	7a46                	ld	s4,112(sp)
ffffffffc02033ca:	7aa6                	ld	s5,104(sp)
ffffffffc02033cc:	7b06                	ld	s6,96(sp)
ffffffffc02033ce:	6be6                	ld	s7,88(sp)
ffffffffc02033d0:	6c46                	ld	s8,80(sp)
ffffffffc02033d2:	6ca6                	ld	s9,72(sp)
ffffffffc02033d4:	6d06                	ld	s10,64(sp)
ffffffffc02033d6:	7de2                	ld	s11,56(sp)
ffffffffc02033d8:	610d                	addi	sp,sp,160
ffffffffc02033da:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02033dc:	000dc797          	auipc	a5,0xdc
ffffffffc02033e0:	ec478793          	addi	a5,a5,-316 # ffffffffc02df2a0 <sm>
ffffffffc02033e4:	639c                	ld	a5,0(a5)
ffffffffc02033e6:	00005517          	auipc	a0,0x5
ffffffffc02033ea:	60250513          	addi	a0,a0,1538 # ffffffffc02089e8 <default_pmm_manager+0x7b0>
    return listelm->next;
ffffffffc02033ee:	000dc417          	auipc	s0,0xdc
ffffffffc02033f2:	efa40413          	addi	s0,s0,-262 # ffffffffc02df2e8 <free_area>
ffffffffc02033f6:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02033f8:	4785                	li	a5,1
ffffffffc02033fa:	000dc717          	auipc	a4,0xdc
ffffffffc02033fe:	eaf72723          	sw	a5,-338(a4) # ffffffffc02df2a8 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203402:	d91fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0203406:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203408:	36878e63          	beq	a5,s0,ffffffffc0203784 <swap_init+0x418>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020340c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203410:	8305                	srli	a4,a4,0x1
ffffffffc0203412:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203414:	36070c63          	beqz	a4,ffffffffc020378c <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0203418:	4481                	li	s1,0
ffffffffc020341a:	4901                	li	s2,0
ffffffffc020341c:	a031                	j	ffffffffc0203428 <swap_init+0xbc>
ffffffffc020341e:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0203422:	8b09                	andi	a4,a4,2
ffffffffc0203424:	36070463          	beqz	a4,ffffffffc020378c <swap_init+0x420>
        count ++, total += p->property;
ffffffffc0203428:	ff87a703          	lw	a4,-8(a5)
ffffffffc020342c:	679c                	ld	a5,8(a5)
ffffffffc020342e:	2905                	addiw	s2,s2,1
ffffffffc0203430:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203432:	fe8796e3          	bne	a5,s0,ffffffffc020341e <swap_init+0xb2>
ffffffffc0203436:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0203438:	ac9fe0ef          	jal	ra,ffffffffc0201f00 <nr_free_pages>
ffffffffc020343c:	69351863          	bne	a0,s3,ffffffffc0203acc <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0203440:	8626                	mv	a2,s1
ffffffffc0203442:	85ca                	mv	a1,s2
ffffffffc0203444:	00005517          	auipc	a0,0x5
ffffffffc0203448:	5bc50513          	addi	a0,a0,1468 # ffffffffc0208a00 <default_pmm_manager+0x7c8>
ffffffffc020344c:	d47fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0203450:	457000ef          	jal	ra,ffffffffc02040a6 <mm_create>
ffffffffc0203454:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0203456:	60050b63          	beqz	a0,ffffffffc0203a6c <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020345a:	000dc797          	auipc	a5,0xdc
ffffffffc020345e:	f9e78793          	addi	a5,a5,-98 # ffffffffc02df3f8 <check_mm_struct>
ffffffffc0203462:	639c                	ld	a5,0(a5)
ffffffffc0203464:	62079463          	bnez	a5,ffffffffc0203a8c <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203468:	000dc797          	auipc	a5,0xdc
ffffffffc020346c:	e2878793          	addi	a5,a5,-472 # ffffffffc02df290 <boot_pgdir>
ffffffffc0203470:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0203474:	000dc797          	auipc	a5,0xdc
ffffffffc0203478:	f8a7b223          	sd	a0,-124(a5) # ffffffffc02df3f8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020347c:	000b3783          	ld	a5,0(s6) # 80000 <_binary_obj___user_matrix_out_size+0x743d0>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203480:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0203484:	4e079863          	bnez	a5,ffffffffc0203974 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0203488:	6599                	lui	a1,0x6
ffffffffc020348a:	460d                	li	a2,3
ffffffffc020348c:	6505                	lui	a0,0x1
ffffffffc020348e:	46b000ef          	jal	ra,ffffffffc02040f8 <vma_create>
ffffffffc0203492:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0203494:	50050063          	beqz	a0,ffffffffc0203994 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc0203498:	855e                	mv	a0,s7
ffffffffc020349a:	4cb000ef          	jal	ra,ffffffffc0204164 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020349e:	00005517          	auipc	a0,0x5
ffffffffc02034a2:	5d250513          	addi	a0,a0,1490 # ffffffffc0208a70 <default_pmm_manager+0x838>
ffffffffc02034a6:	cedfc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02034aa:	018bb503          	ld	a0,24(s7)
ffffffffc02034ae:	4605                	li	a2,1
ffffffffc02034b0:	6585                	lui	a1,0x1
ffffffffc02034b2:	a8ffe0ef          	jal	ra,ffffffffc0201f40 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02034b6:	4e050f63          	beqz	a0,ffffffffc02039b4 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034ba:	00005517          	auipc	a0,0x5
ffffffffc02034be:	60650513          	addi	a0,a0,1542 # ffffffffc0208ac0 <default_pmm_manager+0x888>
ffffffffc02034c2:	000dc997          	auipc	s3,0xdc
ffffffffc02034c6:	e5e98993          	addi	s3,s3,-418 # ffffffffc02df320 <check_rp>
ffffffffc02034ca:	cc9fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034ce:	000dca17          	auipc	s4,0xdc
ffffffffc02034d2:	e72a0a13          	addi	s4,s4,-398 # ffffffffc02df340 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034d6:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc02034d8:	4505                	li	a0,1
ffffffffc02034da:	959fe0ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc02034de:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc02034e2:	32050d63          	beqz	a0,ffffffffc020381c <swap_init+0x4b0>
ffffffffc02034e6:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02034e8:	8b89                	andi	a5,a5,2
ffffffffc02034ea:	30079963          	bnez	a5,ffffffffc02037fc <swap_init+0x490>
ffffffffc02034ee:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034f0:	ff4c14e3          	bne	s8,s4,ffffffffc02034d8 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02034f4:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02034f6:	000dcc17          	auipc	s8,0xdc
ffffffffc02034fa:	e2ac0c13          	addi	s8,s8,-470 # ffffffffc02df320 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc02034fe:	ec3e                	sd	a5,24(sp)
ffffffffc0203500:	641c                	ld	a5,8(s0)
ffffffffc0203502:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203504:	481c                	lw	a5,16(s0)
ffffffffc0203506:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0203508:	000dc797          	auipc	a5,0xdc
ffffffffc020350c:	de87b423          	sd	s0,-536(a5) # ffffffffc02df2f0 <free_area+0x8>
ffffffffc0203510:	000dc797          	auipc	a5,0xdc
ffffffffc0203514:	dc87bc23          	sd	s0,-552(a5) # ffffffffc02df2e8 <free_area>
     nr_free = 0;
ffffffffc0203518:	000dc797          	auipc	a5,0xdc
ffffffffc020351c:	de07a023          	sw	zero,-544(a5) # ffffffffc02df2f8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203520:	000c3503          	ld	a0,0(s8)
ffffffffc0203524:	4585                	li	a1,1
ffffffffc0203526:	0c21                	addi	s8,s8,8
ffffffffc0203528:	993fe0ef          	jal	ra,ffffffffc0201eba <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020352c:	ff4c1ae3          	bne	s8,s4,ffffffffc0203520 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203530:	01042c03          	lw	s8,16(s0)
ffffffffc0203534:	4791                	li	a5,4
ffffffffc0203536:	50fc1b63          	bne	s8,a5,ffffffffc0203a4c <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020353a:	00005517          	auipc	a0,0x5
ffffffffc020353e:	60e50513          	addi	a0,a0,1550 # ffffffffc0208b48 <default_pmm_manager+0x910>
ffffffffc0203542:	c51fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203546:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203548:	000dc797          	auipc	a5,0xdc
ffffffffc020354c:	d607a223          	sw	zero,-668(a5) # ffffffffc02df2ac <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203550:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0203552:	000dc797          	auipc	a5,0xdc
ffffffffc0203556:	d5a78793          	addi	a5,a5,-678 # ffffffffc02df2ac <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020355a:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x8ad0>
     assert(pgfault_num==1);
ffffffffc020355e:	4398                	lw	a4,0(a5)
ffffffffc0203560:	4585                	li	a1,1
ffffffffc0203562:	2701                	sext.w	a4,a4
ffffffffc0203564:	38b71863          	bne	a4,a1,ffffffffc02038f4 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0203568:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc020356c:	4394                	lw	a3,0(a5)
ffffffffc020356e:	2681                	sext.w	a3,a3
ffffffffc0203570:	3ae69263          	bne	a3,a4,ffffffffc0203914 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203574:	6689                	lui	a3,0x2
ffffffffc0203576:	462d                	li	a2,11
ffffffffc0203578:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7ad0>
     assert(pgfault_num==2);
ffffffffc020357c:	4398                	lw	a4,0(a5)
ffffffffc020357e:	4589                	li	a1,2
ffffffffc0203580:	2701                	sext.w	a4,a4
ffffffffc0203582:	2eb71963          	bne	a4,a1,ffffffffc0203874 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0203586:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc020358a:	4394                	lw	a3,0(a5)
ffffffffc020358c:	2681                	sext.w	a3,a3
ffffffffc020358e:	30e69363          	bne	a3,a4,ffffffffc0203894 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203592:	668d                	lui	a3,0x3
ffffffffc0203594:	4631                	li	a2,12
ffffffffc0203596:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6ad0>
     assert(pgfault_num==3);
ffffffffc020359a:	4398                	lw	a4,0(a5)
ffffffffc020359c:	458d                	li	a1,3
ffffffffc020359e:	2701                	sext.w	a4,a4
ffffffffc02035a0:	30b71a63          	bne	a4,a1,ffffffffc02038b4 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02035a4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02035a8:	4394                	lw	a3,0(a5)
ffffffffc02035aa:	2681                	sext.w	a3,a3
ffffffffc02035ac:	32e69463          	bne	a3,a4,ffffffffc02038d4 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02035b0:	6691                	lui	a3,0x4
ffffffffc02035b2:	4635                	li	a2,13
ffffffffc02035b4:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5ad0>
     assert(pgfault_num==4);
ffffffffc02035b8:	4398                	lw	a4,0(a5)
ffffffffc02035ba:	2701                	sext.w	a4,a4
ffffffffc02035bc:	37871c63          	bne	a4,s8,ffffffffc0203934 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02035c0:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02035c4:	439c                	lw	a5,0(a5)
ffffffffc02035c6:	2781                	sext.w	a5,a5
ffffffffc02035c8:	38e79663          	bne	a5,a4,ffffffffc0203954 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02035cc:	481c                	lw	a5,16(s0)
ffffffffc02035ce:	40079363          	bnez	a5,ffffffffc02039d4 <swap_init+0x668>
ffffffffc02035d2:	000dc797          	auipc	a5,0xdc
ffffffffc02035d6:	d6e78793          	addi	a5,a5,-658 # ffffffffc02df340 <swap_in_seq_no>
ffffffffc02035da:	000dc717          	auipc	a4,0xdc
ffffffffc02035de:	d8e70713          	addi	a4,a4,-626 # ffffffffc02df368 <swap_out_seq_no>
ffffffffc02035e2:	000dc617          	auipc	a2,0xdc
ffffffffc02035e6:	d8660613          	addi	a2,a2,-634 # ffffffffc02df368 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02035ea:	56fd                	li	a3,-1
ffffffffc02035ec:	c394                	sw	a3,0(a5)
ffffffffc02035ee:	c314                	sw	a3,0(a4)
ffffffffc02035f0:	0791                	addi	a5,a5,4
ffffffffc02035f2:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02035f4:	fef61ce3          	bne	a2,a5,ffffffffc02035ec <swap_init+0x280>
ffffffffc02035f8:	000dc697          	auipc	a3,0xdc
ffffffffc02035fc:	dd068693          	addi	a3,a3,-560 # ffffffffc02df3c8 <check_ptep>
ffffffffc0203600:	000dc817          	auipc	a6,0xdc
ffffffffc0203604:	d2080813          	addi	a6,a6,-736 # ffffffffc02df320 <check_rp>
ffffffffc0203608:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc020360a:	000dcc97          	auipc	s9,0xdc
ffffffffc020360e:	c8ec8c93          	addi	s9,s9,-882 # ffffffffc02df298 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203612:	00007d97          	auipc	s11,0x7
ffffffffc0203616:	2a6d8d93          	addi	s11,s11,678 # ffffffffc020a8b8 <nbase>
ffffffffc020361a:	000dcc17          	auipc	s8,0xdc
ffffffffc020361e:	cfec0c13          	addi	s8,s8,-770 # ffffffffc02df318 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0203622:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203626:	4601                	li	a2,0
ffffffffc0203628:	85ea                	mv	a1,s10
ffffffffc020362a:	855a                	mv	a0,s6
ffffffffc020362c:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc020362e:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203630:	911fe0ef          	jal	ra,ffffffffc0201f40 <get_pte>
ffffffffc0203634:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203636:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203638:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc020363a:	20050163          	beqz	a0,ffffffffc020383c <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020363e:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203640:	0017f613          	andi	a2,a5,1
ffffffffc0203644:	1a060063          	beqz	a2,ffffffffc02037e4 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc0203648:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020364c:	078a                	slli	a5,a5,0x2
ffffffffc020364e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203650:	14c7fe63          	bleu	a2,a5,ffffffffc02037ac <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203654:	000db703          	ld	a4,0(s11)
ffffffffc0203658:	000c3603          	ld	a2,0(s8)
ffffffffc020365c:	00083583          	ld	a1,0(a6)
ffffffffc0203660:	8f99                	sub	a5,a5,a4
ffffffffc0203662:	079a                	slli	a5,a5,0x6
ffffffffc0203664:	e43a                	sd	a4,8(sp)
ffffffffc0203666:	97b2                	add	a5,a5,a2
ffffffffc0203668:	14f59e63          	bne	a1,a5,ffffffffc02037c4 <swap_init+0x458>
ffffffffc020366c:	6785                	lui	a5,0x1
ffffffffc020366e:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203670:	6795                	lui	a5,0x5
ffffffffc0203672:	06a1                	addi	a3,a3,8
ffffffffc0203674:	0821                	addi	a6,a6,8
ffffffffc0203676:	fafd16e3          	bne	s10,a5,ffffffffc0203622 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020367a:	00005517          	auipc	a0,0x5
ffffffffc020367e:	57650513          	addi	a0,a0,1398 # ffffffffc0208bf0 <default_pmm_manager+0x9b8>
ffffffffc0203682:	b11fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    int ret = sm->check_swap();
ffffffffc0203686:	000dc797          	auipc	a5,0xdc
ffffffffc020368a:	c1a78793          	addi	a5,a5,-998 # ffffffffc02df2a0 <sm>
ffffffffc020368e:	639c                	ld	a5,0(a5)
ffffffffc0203690:	7f9c                	ld	a5,56(a5)
ffffffffc0203692:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203694:	40051c63          	bnez	a0,ffffffffc0203aac <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc0203698:	77a2                	ld	a5,40(sp)
ffffffffc020369a:	000dc717          	auipc	a4,0xdc
ffffffffc020369e:	c4f72f23          	sw	a5,-930(a4) # ffffffffc02df2f8 <free_area+0x10>
     free_list = free_list_store;
ffffffffc02036a2:	67e2                	ld	a5,24(sp)
ffffffffc02036a4:	000dc717          	auipc	a4,0xdc
ffffffffc02036a8:	c4f73223          	sd	a5,-956(a4) # ffffffffc02df2e8 <free_area>
ffffffffc02036ac:	7782                	ld	a5,32(sp)
ffffffffc02036ae:	000dc717          	auipc	a4,0xdc
ffffffffc02036b2:	c4f73123          	sd	a5,-958(a4) # ffffffffc02df2f0 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02036b6:	0009b503          	ld	a0,0(s3)
ffffffffc02036ba:	4585                	li	a1,1
ffffffffc02036bc:	09a1                	addi	s3,s3,8
ffffffffc02036be:	ffcfe0ef          	jal	ra,ffffffffc0201eba <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02036c2:	ff499ae3          	bne	s3,s4,ffffffffc02036b6 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02036c6:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc02036ca:	855e                	mv	a0,s7
ffffffffc02036cc:	367000ef          	jal	ra,ffffffffc0204232 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02036d0:	000dc797          	auipc	a5,0xdc
ffffffffc02036d4:	bc078793          	addi	a5,a5,-1088 # ffffffffc02df290 <boot_pgdir>
ffffffffc02036d8:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc02036da:	000dc697          	auipc	a3,0xdc
ffffffffc02036de:	d006bf23          	sd	zero,-738(a3) # ffffffffc02df3f8 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc02036e2:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02036e6:	6394                	ld	a3,0(a5)
ffffffffc02036e8:	068a                	slli	a3,a3,0x2
ffffffffc02036ea:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036ec:	0ce6f063          	bleu	a4,a3,ffffffffc02037ac <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02036f0:	67a2                	ld	a5,8(sp)
ffffffffc02036f2:	000c3503          	ld	a0,0(s8)
ffffffffc02036f6:	8e9d                	sub	a3,a3,a5
ffffffffc02036f8:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02036fa:	8699                	srai	a3,a3,0x6
ffffffffc02036fc:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02036fe:	57fd                	li	a5,-1
ffffffffc0203700:	83b1                	srli	a5,a5,0xc
ffffffffc0203702:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203704:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203706:	2ee7f763          	bleu	a4,a5,ffffffffc02039f4 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc020370a:	000dc797          	auipc	a5,0xdc
ffffffffc020370e:	bfe78793          	addi	a5,a5,-1026 # ffffffffc02df308 <va_pa_offset>
ffffffffc0203712:	639c                	ld	a5,0(a5)
ffffffffc0203714:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203716:	629c                	ld	a5,0(a3)
ffffffffc0203718:	078a                	slli	a5,a5,0x2
ffffffffc020371a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020371c:	08e7f863          	bleu	a4,a5,ffffffffc02037ac <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203720:	69a2                	ld	s3,8(sp)
ffffffffc0203722:	4585                	li	a1,1
ffffffffc0203724:	413787b3          	sub	a5,a5,s3
ffffffffc0203728:	079a                	slli	a5,a5,0x6
ffffffffc020372a:	953e                	add	a0,a0,a5
ffffffffc020372c:	f8efe0ef          	jal	ra,ffffffffc0201eba <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203730:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203734:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203738:	078a                	slli	a5,a5,0x2
ffffffffc020373a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020373c:	06e7f863          	bleu	a4,a5,ffffffffc02037ac <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203740:	000c3503          	ld	a0,0(s8)
ffffffffc0203744:	413787b3          	sub	a5,a5,s3
ffffffffc0203748:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc020374a:	4585                	li	a1,1
ffffffffc020374c:	953e                	add	a0,a0,a5
ffffffffc020374e:	f6cfe0ef          	jal	ra,ffffffffc0201eba <free_pages>
     pgdir[0] = 0;
ffffffffc0203752:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203756:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020375a:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020375c:	00878963          	beq	a5,s0,ffffffffc020376e <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203760:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203764:	679c                	ld	a5,8(a5)
ffffffffc0203766:	397d                	addiw	s2,s2,-1
ffffffffc0203768:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020376a:	fe879be3          	bne	a5,s0,ffffffffc0203760 <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc020376e:	28091f63          	bnez	s2,ffffffffc0203a0c <swap_init+0x6a0>
     assert(total==0);
ffffffffc0203772:	2a049d63          	bnez	s1,ffffffffc0203a2c <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203776:	00005517          	auipc	a0,0x5
ffffffffc020377a:	4ca50513          	addi	a0,a0,1226 # ffffffffc0208c40 <default_pmm_manager+0xa08>
ffffffffc020377e:	a15fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0203782:	b92d                	j	ffffffffc02033bc <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0203784:	4481                	li	s1,0
ffffffffc0203786:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203788:	4981                	li	s3,0
ffffffffc020378a:	b17d                	j	ffffffffc0203438 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc020378c:	00004697          	auipc	a3,0x4
ffffffffc0203790:	71c68693          	addi	a3,a3,1820 # ffffffffc0207ea8 <commands+0x878>
ffffffffc0203794:	00004617          	auipc	a2,0x4
ffffffffc0203798:	35c60613          	addi	a2,a2,860 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020379c:	0bc00593          	li	a1,188
ffffffffc02037a0:	00005517          	auipc	a0,0x5
ffffffffc02037a4:	23850513          	addi	a0,a0,568 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc02037a8:	ce1fc0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02037ac:	00005617          	auipc	a2,0x5
ffffffffc02037b0:	b3c60613          	addi	a2,a2,-1220 # ffffffffc02082e8 <default_pmm_manager+0xb0>
ffffffffc02037b4:	06200593          	li	a1,98
ffffffffc02037b8:	00005517          	auipc	a0,0x5
ffffffffc02037bc:	af850513          	addi	a0,a0,-1288 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc02037c0:	cc9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02037c4:	00005697          	auipc	a3,0x5
ffffffffc02037c8:	40468693          	addi	a3,a3,1028 # ffffffffc0208bc8 <default_pmm_manager+0x990>
ffffffffc02037cc:	00004617          	auipc	a2,0x4
ffffffffc02037d0:	32460613          	addi	a2,a2,804 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02037d4:	0fc00593          	li	a1,252
ffffffffc02037d8:	00005517          	auipc	a0,0x5
ffffffffc02037dc:	20050513          	addi	a0,a0,512 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc02037e0:	ca9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02037e4:	00005617          	auipc	a2,0x5
ffffffffc02037e8:	d5c60613          	addi	a2,a2,-676 # ffffffffc0208540 <default_pmm_manager+0x308>
ffffffffc02037ec:	07400593          	li	a1,116
ffffffffc02037f0:	00005517          	auipc	a0,0x5
ffffffffc02037f4:	ac050513          	addi	a0,a0,-1344 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc02037f8:	c91fc0ef          	jal	ra,ffffffffc0200488 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02037fc:	00005697          	auipc	a3,0x5
ffffffffc0203800:	30468693          	addi	a3,a3,772 # ffffffffc0208b00 <default_pmm_manager+0x8c8>
ffffffffc0203804:	00004617          	auipc	a2,0x4
ffffffffc0203808:	2ec60613          	addi	a2,a2,748 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020380c:	0dd00593          	li	a1,221
ffffffffc0203810:	00005517          	auipc	a0,0x5
ffffffffc0203814:	1c850513          	addi	a0,a0,456 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203818:	c71fc0ef          	jal	ra,ffffffffc0200488 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc020381c:	00005697          	auipc	a3,0x5
ffffffffc0203820:	2cc68693          	addi	a3,a3,716 # ffffffffc0208ae8 <default_pmm_manager+0x8b0>
ffffffffc0203824:	00004617          	auipc	a2,0x4
ffffffffc0203828:	2cc60613          	addi	a2,a2,716 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020382c:	0dc00593          	li	a1,220
ffffffffc0203830:	00005517          	auipc	a0,0x5
ffffffffc0203834:	1a850513          	addi	a0,a0,424 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203838:	c51fc0ef          	jal	ra,ffffffffc0200488 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc020383c:	00005697          	auipc	a3,0x5
ffffffffc0203840:	37468693          	addi	a3,a3,884 # ffffffffc0208bb0 <default_pmm_manager+0x978>
ffffffffc0203844:	00004617          	auipc	a2,0x4
ffffffffc0203848:	2ac60613          	addi	a2,a2,684 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020384c:	0fb00593          	li	a1,251
ffffffffc0203850:	00005517          	auipc	a0,0x5
ffffffffc0203854:	18850513          	addi	a0,a0,392 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203858:	c31fc0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020385c:	00005617          	auipc	a2,0x5
ffffffffc0203860:	15c60613          	addi	a2,a2,348 # ffffffffc02089b8 <default_pmm_manager+0x780>
ffffffffc0203864:	02800593          	li	a1,40
ffffffffc0203868:	00005517          	auipc	a0,0x5
ffffffffc020386c:	17050513          	addi	a0,a0,368 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203870:	c19fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==2);
ffffffffc0203874:	00005697          	auipc	a3,0x5
ffffffffc0203878:	30c68693          	addi	a3,a3,780 # ffffffffc0208b80 <default_pmm_manager+0x948>
ffffffffc020387c:	00004617          	auipc	a2,0x4
ffffffffc0203880:	27460613          	addi	a2,a2,628 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203884:	09700593          	li	a1,151
ffffffffc0203888:	00005517          	auipc	a0,0x5
ffffffffc020388c:	15050513          	addi	a0,a0,336 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203890:	bf9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==2);
ffffffffc0203894:	00005697          	auipc	a3,0x5
ffffffffc0203898:	2ec68693          	addi	a3,a3,748 # ffffffffc0208b80 <default_pmm_manager+0x948>
ffffffffc020389c:	00004617          	auipc	a2,0x4
ffffffffc02038a0:	25460613          	addi	a2,a2,596 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02038a4:	09900593          	li	a1,153
ffffffffc02038a8:	00005517          	auipc	a0,0x5
ffffffffc02038ac:	13050513          	addi	a0,a0,304 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc02038b0:	bd9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==3);
ffffffffc02038b4:	00005697          	auipc	a3,0x5
ffffffffc02038b8:	2dc68693          	addi	a3,a3,732 # ffffffffc0208b90 <default_pmm_manager+0x958>
ffffffffc02038bc:	00004617          	auipc	a2,0x4
ffffffffc02038c0:	23460613          	addi	a2,a2,564 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02038c4:	09b00593          	li	a1,155
ffffffffc02038c8:	00005517          	auipc	a0,0x5
ffffffffc02038cc:	11050513          	addi	a0,a0,272 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc02038d0:	bb9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==3);
ffffffffc02038d4:	00005697          	auipc	a3,0x5
ffffffffc02038d8:	2bc68693          	addi	a3,a3,700 # ffffffffc0208b90 <default_pmm_manager+0x958>
ffffffffc02038dc:	00004617          	auipc	a2,0x4
ffffffffc02038e0:	21460613          	addi	a2,a2,532 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02038e4:	09d00593          	li	a1,157
ffffffffc02038e8:	00005517          	auipc	a0,0x5
ffffffffc02038ec:	0f050513          	addi	a0,a0,240 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc02038f0:	b99fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==1);
ffffffffc02038f4:	00005697          	auipc	a3,0x5
ffffffffc02038f8:	27c68693          	addi	a3,a3,636 # ffffffffc0208b70 <default_pmm_manager+0x938>
ffffffffc02038fc:	00004617          	auipc	a2,0x4
ffffffffc0203900:	1f460613          	addi	a2,a2,500 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203904:	09300593          	li	a1,147
ffffffffc0203908:	00005517          	auipc	a0,0x5
ffffffffc020390c:	0d050513          	addi	a0,a0,208 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203910:	b79fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==1);
ffffffffc0203914:	00005697          	auipc	a3,0x5
ffffffffc0203918:	25c68693          	addi	a3,a3,604 # ffffffffc0208b70 <default_pmm_manager+0x938>
ffffffffc020391c:	00004617          	auipc	a2,0x4
ffffffffc0203920:	1d460613          	addi	a2,a2,468 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203924:	09500593          	li	a1,149
ffffffffc0203928:	00005517          	auipc	a0,0x5
ffffffffc020392c:	0b050513          	addi	a0,a0,176 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203930:	b59fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==4);
ffffffffc0203934:	00005697          	auipc	a3,0x5
ffffffffc0203938:	26c68693          	addi	a3,a3,620 # ffffffffc0208ba0 <default_pmm_manager+0x968>
ffffffffc020393c:	00004617          	auipc	a2,0x4
ffffffffc0203940:	1b460613          	addi	a2,a2,436 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203944:	09f00593          	li	a1,159
ffffffffc0203948:	00005517          	auipc	a0,0x5
ffffffffc020394c:	09050513          	addi	a0,a0,144 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203950:	b39fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==4);
ffffffffc0203954:	00005697          	auipc	a3,0x5
ffffffffc0203958:	24c68693          	addi	a3,a3,588 # ffffffffc0208ba0 <default_pmm_manager+0x968>
ffffffffc020395c:	00004617          	auipc	a2,0x4
ffffffffc0203960:	19460613          	addi	a2,a2,404 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203964:	0a100593          	li	a1,161
ffffffffc0203968:	00005517          	auipc	a0,0x5
ffffffffc020396c:	07050513          	addi	a0,a0,112 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203970:	b19fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203974:	00005697          	auipc	a3,0x5
ffffffffc0203978:	0dc68693          	addi	a3,a3,220 # ffffffffc0208a50 <default_pmm_manager+0x818>
ffffffffc020397c:	00004617          	auipc	a2,0x4
ffffffffc0203980:	17460613          	addi	a2,a2,372 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203984:	0cc00593          	li	a1,204
ffffffffc0203988:	00005517          	auipc	a0,0x5
ffffffffc020398c:	05050513          	addi	a0,a0,80 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203990:	af9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(vma != NULL);
ffffffffc0203994:	00005697          	auipc	a3,0x5
ffffffffc0203998:	0cc68693          	addi	a3,a3,204 # ffffffffc0208a60 <default_pmm_manager+0x828>
ffffffffc020399c:	00004617          	auipc	a2,0x4
ffffffffc02039a0:	15460613          	addi	a2,a2,340 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02039a4:	0cf00593          	li	a1,207
ffffffffc02039a8:	00005517          	auipc	a0,0x5
ffffffffc02039ac:	03050513          	addi	a0,a0,48 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc02039b0:	ad9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02039b4:	00005697          	auipc	a3,0x5
ffffffffc02039b8:	0f468693          	addi	a3,a3,244 # ffffffffc0208aa8 <default_pmm_manager+0x870>
ffffffffc02039bc:	00004617          	auipc	a2,0x4
ffffffffc02039c0:	13460613          	addi	a2,a2,308 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02039c4:	0d700593          	li	a1,215
ffffffffc02039c8:	00005517          	auipc	a0,0x5
ffffffffc02039cc:	01050513          	addi	a0,a0,16 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc02039d0:	ab9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert( nr_free == 0);         
ffffffffc02039d4:	00004697          	auipc	a3,0x4
ffffffffc02039d8:	6a468693          	addi	a3,a3,1700 # ffffffffc0208078 <commands+0xa48>
ffffffffc02039dc:	00004617          	auipc	a2,0x4
ffffffffc02039e0:	11460613          	addi	a2,a2,276 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02039e4:	0f300593          	li	a1,243
ffffffffc02039e8:	00005517          	auipc	a0,0x5
ffffffffc02039ec:	ff050513          	addi	a0,a0,-16 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc02039f0:	a99fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc02039f4:	00005617          	auipc	a2,0x5
ffffffffc02039f8:	89460613          	addi	a2,a2,-1900 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc02039fc:	06900593          	li	a1,105
ffffffffc0203a00:	00005517          	auipc	a0,0x5
ffffffffc0203a04:	8b050513          	addi	a0,a0,-1872 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc0203a08:	a81fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(count==0);
ffffffffc0203a0c:	00005697          	auipc	a3,0x5
ffffffffc0203a10:	21468693          	addi	a3,a3,532 # ffffffffc0208c20 <default_pmm_manager+0x9e8>
ffffffffc0203a14:	00004617          	auipc	a2,0x4
ffffffffc0203a18:	0dc60613          	addi	a2,a2,220 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203a1c:	11d00593          	li	a1,285
ffffffffc0203a20:	00005517          	auipc	a0,0x5
ffffffffc0203a24:	fb850513          	addi	a0,a0,-72 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203a28:	a61fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(total==0);
ffffffffc0203a2c:	00005697          	auipc	a3,0x5
ffffffffc0203a30:	20468693          	addi	a3,a3,516 # ffffffffc0208c30 <default_pmm_manager+0x9f8>
ffffffffc0203a34:	00004617          	auipc	a2,0x4
ffffffffc0203a38:	0bc60613          	addi	a2,a2,188 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203a3c:	11e00593          	li	a1,286
ffffffffc0203a40:	00005517          	auipc	a0,0x5
ffffffffc0203a44:	f9850513          	addi	a0,a0,-104 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203a48:	a41fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203a4c:	00005697          	auipc	a3,0x5
ffffffffc0203a50:	0d468693          	addi	a3,a3,212 # ffffffffc0208b20 <default_pmm_manager+0x8e8>
ffffffffc0203a54:	00004617          	auipc	a2,0x4
ffffffffc0203a58:	09c60613          	addi	a2,a2,156 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203a5c:	0ea00593          	li	a1,234
ffffffffc0203a60:	00005517          	auipc	a0,0x5
ffffffffc0203a64:	f7850513          	addi	a0,a0,-136 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203a68:	a21fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(mm != NULL);
ffffffffc0203a6c:	00005697          	auipc	a3,0x5
ffffffffc0203a70:	fbc68693          	addi	a3,a3,-68 # ffffffffc0208a28 <default_pmm_manager+0x7f0>
ffffffffc0203a74:	00004617          	auipc	a2,0x4
ffffffffc0203a78:	07c60613          	addi	a2,a2,124 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203a7c:	0c400593          	li	a1,196
ffffffffc0203a80:	00005517          	auipc	a0,0x5
ffffffffc0203a84:	f5850513          	addi	a0,a0,-168 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203a88:	a01fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203a8c:	00005697          	auipc	a3,0x5
ffffffffc0203a90:	fac68693          	addi	a3,a3,-84 # ffffffffc0208a38 <default_pmm_manager+0x800>
ffffffffc0203a94:	00004617          	auipc	a2,0x4
ffffffffc0203a98:	05c60613          	addi	a2,a2,92 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203a9c:	0c700593          	li	a1,199
ffffffffc0203aa0:	00005517          	auipc	a0,0x5
ffffffffc0203aa4:	f3850513          	addi	a0,a0,-200 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203aa8:	9e1fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(ret==0);
ffffffffc0203aac:	00005697          	auipc	a3,0x5
ffffffffc0203ab0:	16c68693          	addi	a3,a3,364 # ffffffffc0208c18 <default_pmm_manager+0x9e0>
ffffffffc0203ab4:	00004617          	auipc	a2,0x4
ffffffffc0203ab8:	03c60613          	addi	a2,a2,60 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203abc:	10200593          	li	a1,258
ffffffffc0203ac0:	00005517          	auipc	a0,0x5
ffffffffc0203ac4:	f1850513          	addi	a0,a0,-232 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203ac8:	9c1fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203acc:	00004697          	auipc	a3,0x4
ffffffffc0203ad0:	40468693          	addi	a3,a3,1028 # ffffffffc0207ed0 <commands+0x8a0>
ffffffffc0203ad4:	00004617          	auipc	a2,0x4
ffffffffc0203ad8:	01c60613          	addi	a2,a2,28 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203adc:	0bf00593          	li	a1,191
ffffffffc0203ae0:	00005517          	auipc	a0,0x5
ffffffffc0203ae4:	ef850513          	addi	a0,a0,-264 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203ae8:	9a1fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203aec <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203aec:	000db797          	auipc	a5,0xdb
ffffffffc0203af0:	7b478793          	addi	a5,a5,1972 # ffffffffc02df2a0 <sm>
ffffffffc0203af4:	639c                	ld	a5,0(a5)
ffffffffc0203af6:	0107b303          	ld	t1,16(a5)
ffffffffc0203afa:	8302                	jr	t1

ffffffffc0203afc <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203afc:	000db797          	auipc	a5,0xdb
ffffffffc0203b00:	7a478793          	addi	a5,a5,1956 # ffffffffc02df2a0 <sm>
ffffffffc0203b04:	639c                	ld	a5,0(a5)
ffffffffc0203b06:	0207b303          	ld	t1,32(a5)
ffffffffc0203b0a:	8302                	jr	t1

ffffffffc0203b0c <swap_out>:
{
ffffffffc0203b0c:	711d                	addi	sp,sp,-96
ffffffffc0203b0e:	ec86                	sd	ra,88(sp)
ffffffffc0203b10:	e8a2                	sd	s0,80(sp)
ffffffffc0203b12:	e4a6                	sd	s1,72(sp)
ffffffffc0203b14:	e0ca                	sd	s2,64(sp)
ffffffffc0203b16:	fc4e                	sd	s3,56(sp)
ffffffffc0203b18:	f852                	sd	s4,48(sp)
ffffffffc0203b1a:	f456                	sd	s5,40(sp)
ffffffffc0203b1c:	f05a                	sd	s6,32(sp)
ffffffffc0203b1e:	ec5e                	sd	s7,24(sp)
ffffffffc0203b20:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203b22:	cde9                	beqz	a1,ffffffffc0203bfc <swap_out+0xf0>
ffffffffc0203b24:	8ab2                	mv	s5,a2
ffffffffc0203b26:	892a                	mv	s2,a0
ffffffffc0203b28:	8a2e                	mv	s4,a1
ffffffffc0203b2a:	4401                	li	s0,0
ffffffffc0203b2c:	000db997          	auipc	s3,0xdb
ffffffffc0203b30:	77498993          	addi	s3,s3,1908 # ffffffffc02df2a0 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b34:	00005b17          	auipc	s6,0x5
ffffffffc0203b38:	18cb0b13          	addi	s6,s6,396 # ffffffffc0208cc0 <default_pmm_manager+0xa88>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203b3c:	00005b97          	auipc	s7,0x5
ffffffffc0203b40:	16cb8b93          	addi	s7,s7,364 # ffffffffc0208ca8 <default_pmm_manager+0xa70>
ffffffffc0203b44:	a825                	j	ffffffffc0203b7c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b46:	67a2                	ld	a5,8(sp)
ffffffffc0203b48:	8626                	mv	a2,s1
ffffffffc0203b4a:	85a2                	mv	a1,s0
ffffffffc0203b4c:	7f94                	ld	a3,56(a5)
ffffffffc0203b4e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203b50:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b52:	82b1                	srli	a3,a3,0xc
ffffffffc0203b54:	0685                	addi	a3,a3,1
ffffffffc0203b56:	e3cfc0ef          	jal	ra,ffffffffc0200192 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b5a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203b5c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b5e:	7d1c                	ld	a5,56(a0)
ffffffffc0203b60:	83b1                	srli	a5,a5,0xc
ffffffffc0203b62:	0785                	addi	a5,a5,1
ffffffffc0203b64:	07a2                	slli	a5,a5,0x8
ffffffffc0203b66:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203b6a:	b50fe0ef          	jal	ra,ffffffffc0201eba <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203b6e:	01893503          	ld	a0,24(s2)
ffffffffc0203b72:	85a6                	mv	a1,s1
ffffffffc0203b74:	f5eff0ef          	jal	ra,ffffffffc02032d2 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203b78:	048a0d63          	beq	s4,s0,ffffffffc0203bd2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203b7c:	0009b783          	ld	a5,0(s3)
ffffffffc0203b80:	8656                	mv	a2,s5
ffffffffc0203b82:	002c                	addi	a1,sp,8
ffffffffc0203b84:	7b9c                	ld	a5,48(a5)
ffffffffc0203b86:	854a                	mv	a0,s2
ffffffffc0203b88:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203b8a:	e12d                	bnez	a0,ffffffffc0203bec <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203b8c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b8e:	01893503          	ld	a0,24(s2)
ffffffffc0203b92:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203b94:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b96:	85a6                	mv	a1,s1
ffffffffc0203b98:	ba8fe0ef          	jal	ra,ffffffffc0201f40 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203b9c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b9e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203ba0:	8b85                	andi	a5,a5,1
ffffffffc0203ba2:	cfb9                	beqz	a5,ffffffffc0203c00 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203ba4:	65a2                	ld	a1,8(sp)
ffffffffc0203ba6:	7d9c                	ld	a5,56(a1)
ffffffffc0203ba8:	83b1                	srli	a5,a5,0xc
ffffffffc0203baa:	00178513          	addi	a0,a5,1
ffffffffc0203bae:	0522                	slli	a0,a0,0x8
ffffffffc0203bb0:	143010ef          	jal	ra,ffffffffc02054f2 <swapfs_write>
ffffffffc0203bb4:	d949                	beqz	a0,ffffffffc0203b46 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203bb6:	855e                	mv	a0,s7
ffffffffc0203bb8:	ddafc0ef          	jal	ra,ffffffffc0200192 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203bbc:	0009b783          	ld	a5,0(s3)
ffffffffc0203bc0:	6622                	ld	a2,8(sp)
ffffffffc0203bc2:	4681                	li	a3,0
ffffffffc0203bc4:	739c                	ld	a5,32(a5)
ffffffffc0203bc6:	85a6                	mv	a1,s1
ffffffffc0203bc8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203bca:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203bcc:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203bce:	fa8a17e3          	bne	s4,s0,ffffffffc0203b7c <swap_out+0x70>
}
ffffffffc0203bd2:	8522                	mv	a0,s0
ffffffffc0203bd4:	60e6                	ld	ra,88(sp)
ffffffffc0203bd6:	6446                	ld	s0,80(sp)
ffffffffc0203bd8:	64a6                	ld	s1,72(sp)
ffffffffc0203bda:	6906                	ld	s2,64(sp)
ffffffffc0203bdc:	79e2                	ld	s3,56(sp)
ffffffffc0203bde:	7a42                	ld	s4,48(sp)
ffffffffc0203be0:	7aa2                	ld	s5,40(sp)
ffffffffc0203be2:	7b02                	ld	s6,32(sp)
ffffffffc0203be4:	6be2                	ld	s7,24(sp)
ffffffffc0203be6:	6c42                	ld	s8,16(sp)
ffffffffc0203be8:	6125                	addi	sp,sp,96
ffffffffc0203bea:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203bec:	85a2                	mv	a1,s0
ffffffffc0203bee:	00005517          	auipc	a0,0x5
ffffffffc0203bf2:	07250513          	addi	a0,a0,114 # ffffffffc0208c60 <default_pmm_manager+0xa28>
ffffffffc0203bf6:	d9cfc0ef          	jal	ra,ffffffffc0200192 <cprintf>
                  break;
ffffffffc0203bfa:	bfe1                	j	ffffffffc0203bd2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203bfc:	4401                	li	s0,0
ffffffffc0203bfe:	bfd1                	j	ffffffffc0203bd2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c00:	00005697          	auipc	a3,0x5
ffffffffc0203c04:	09068693          	addi	a3,a3,144 # ffffffffc0208c90 <default_pmm_manager+0xa58>
ffffffffc0203c08:	00004617          	auipc	a2,0x4
ffffffffc0203c0c:	ee860613          	addi	a2,a2,-280 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203c10:	06800593          	li	a1,104
ffffffffc0203c14:	00005517          	auipc	a0,0x5
ffffffffc0203c18:	dc450513          	addi	a0,a0,-572 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203c1c:	86dfc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203c20 <swap_in>:
{
ffffffffc0203c20:	7179                	addi	sp,sp,-48
ffffffffc0203c22:	e84a                	sd	s2,16(sp)
ffffffffc0203c24:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203c26:	4505                	li	a0,1
{
ffffffffc0203c28:	ec26                	sd	s1,24(sp)
ffffffffc0203c2a:	e44e                	sd	s3,8(sp)
ffffffffc0203c2c:	f406                	sd	ra,40(sp)
ffffffffc0203c2e:	f022                	sd	s0,32(sp)
ffffffffc0203c30:	84ae                	mv	s1,a1
ffffffffc0203c32:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203c34:	9fefe0ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203c38:	c129                	beqz	a0,ffffffffc0203c7a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203c3a:	842a                	mv	s0,a0
ffffffffc0203c3c:	01893503          	ld	a0,24(s2)
ffffffffc0203c40:	4601                	li	a2,0
ffffffffc0203c42:	85a6                	mv	a1,s1
ffffffffc0203c44:	afcfe0ef          	jal	ra,ffffffffc0201f40 <get_pte>
ffffffffc0203c48:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203c4a:	6108                	ld	a0,0(a0)
ffffffffc0203c4c:	85a2                	mv	a1,s0
ffffffffc0203c4e:	00d010ef          	jal	ra,ffffffffc020545a <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203c52:	00093583          	ld	a1,0(s2)
ffffffffc0203c56:	8626                	mv	a2,s1
ffffffffc0203c58:	00005517          	auipc	a0,0x5
ffffffffc0203c5c:	d2050513          	addi	a0,a0,-736 # ffffffffc0208978 <default_pmm_manager+0x740>
ffffffffc0203c60:	81a1                	srli	a1,a1,0x8
ffffffffc0203c62:	d30fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc0203c66:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203c68:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203c6c:	7402                	ld	s0,32(sp)
ffffffffc0203c6e:	64e2                	ld	s1,24(sp)
ffffffffc0203c70:	6942                	ld	s2,16(sp)
ffffffffc0203c72:	69a2                	ld	s3,8(sp)
ffffffffc0203c74:	4501                	li	a0,0
ffffffffc0203c76:	6145                	addi	sp,sp,48
ffffffffc0203c78:	8082                	ret
     assert(result!=NULL);
ffffffffc0203c7a:	00005697          	auipc	a3,0x5
ffffffffc0203c7e:	cee68693          	addi	a3,a3,-786 # ffffffffc0208968 <default_pmm_manager+0x730>
ffffffffc0203c82:	00004617          	auipc	a2,0x4
ffffffffc0203c86:	e6e60613          	addi	a2,a2,-402 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203c8a:	07e00593          	li	a1,126
ffffffffc0203c8e:	00005517          	auipc	a0,0x5
ffffffffc0203c92:	d4a50513          	addi	a0,a0,-694 # ffffffffc02089d8 <default_pmm_manager+0x7a0>
ffffffffc0203c96:	ff2fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203c9a <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203c9a:	000db797          	auipc	a5,0xdb
ffffffffc0203c9e:	74e78793          	addi	a5,a5,1870 # ffffffffc02df3e8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203ca2:	f51c                	sd	a5,40(a0)
ffffffffc0203ca4:	e79c                	sd	a5,8(a5)
ffffffffc0203ca6:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203ca8:	4501                	li	a0,0
ffffffffc0203caa:	8082                	ret

ffffffffc0203cac <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203cac:	4501                	li	a0,0
ffffffffc0203cae:	8082                	ret

ffffffffc0203cb0 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203cb0:	4501                	li	a0,0
ffffffffc0203cb2:	8082                	ret

ffffffffc0203cb4 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203cb4:	4501                	li	a0,0
ffffffffc0203cb6:	8082                	ret

ffffffffc0203cb8 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203cb8:	711d                	addi	sp,sp,-96
ffffffffc0203cba:	fc4e                	sd	s3,56(sp)
ffffffffc0203cbc:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203cbe:	00005517          	auipc	a0,0x5
ffffffffc0203cc2:	04250513          	addi	a0,a0,66 # ffffffffc0208d00 <default_pmm_manager+0xac8>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203cc6:	698d                	lui	s3,0x3
ffffffffc0203cc8:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203cca:	e8a2                	sd	s0,80(sp)
ffffffffc0203ccc:	e4a6                	sd	s1,72(sp)
ffffffffc0203cce:	ec86                	sd	ra,88(sp)
ffffffffc0203cd0:	e0ca                	sd	s2,64(sp)
ffffffffc0203cd2:	f456                	sd	s5,40(sp)
ffffffffc0203cd4:	f05a                	sd	s6,32(sp)
ffffffffc0203cd6:	ec5e                	sd	s7,24(sp)
ffffffffc0203cd8:	e862                	sd	s8,16(sp)
ffffffffc0203cda:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203cdc:	000db417          	auipc	s0,0xdb
ffffffffc0203ce0:	5d040413          	addi	s0,s0,1488 # ffffffffc02df2ac <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203ce4:	caefc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203ce8:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6ad0>
    assert(pgfault_num==4);
ffffffffc0203cec:	4004                	lw	s1,0(s0)
ffffffffc0203cee:	4791                	li	a5,4
ffffffffc0203cf0:	2481                	sext.w	s1,s1
ffffffffc0203cf2:	14f49963          	bne	s1,a5,ffffffffc0203e44 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203cf6:	00005517          	auipc	a0,0x5
ffffffffc0203cfa:	04a50513          	addi	a0,a0,74 # ffffffffc0208d40 <default_pmm_manager+0xb08>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203cfe:	6a85                	lui	s5,0x1
ffffffffc0203d00:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d02:	c90fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d06:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8ad0>
    assert(pgfault_num==4);
ffffffffc0203d0a:	00042903          	lw	s2,0(s0)
ffffffffc0203d0e:	2901                	sext.w	s2,s2
ffffffffc0203d10:	2a991a63          	bne	s2,s1,ffffffffc0203fc4 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d14:	00005517          	auipc	a0,0x5
ffffffffc0203d18:	05450513          	addi	a0,a0,84 # ffffffffc0208d68 <default_pmm_manager+0xb30>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d1c:	6b91                	lui	s7,0x4
ffffffffc0203d1e:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d20:	c72fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d24:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5ad0>
    assert(pgfault_num==4);
ffffffffc0203d28:	4004                	lw	s1,0(s0)
ffffffffc0203d2a:	2481                	sext.w	s1,s1
ffffffffc0203d2c:	27249c63          	bne	s1,s2,ffffffffc0203fa4 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d30:	00005517          	auipc	a0,0x5
ffffffffc0203d34:	06050513          	addi	a0,a0,96 # ffffffffc0208d90 <default_pmm_manager+0xb58>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d38:	6909                	lui	s2,0x2
ffffffffc0203d3a:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d3c:	c56fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d40:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x7ad0>
    assert(pgfault_num==4);
ffffffffc0203d44:	401c                	lw	a5,0(s0)
ffffffffc0203d46:	2781                	sext.w	a5,a5
ffffffffc0203d48:	22979e63          	bne	a5,s1,ffffffffc0203f84 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d4c:	00005517          	auipc	a0,0x5
ffffffffc0203d50:	06c50513          	addi	a0,a0,108 # ffffffffc0208db8 <default_pmm_manager+0xb80>
ffffffffc0203d54:	c3efc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d58:	6795                	lui	a5,0x5
ffffffffc0203d5a:	4739                	li	a4,14
ffffffffc0203d5c:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4ad0>
    assert(pgfault_num==5);
ffffffffc0203d60:	4004                	lw	s1,0(s0)
ffffffffc0203d62:	4795                	li	a5,5
ffffffffc0203d64:	2481                	sext.w	s1,s1
ffffffffc0203d66:	1ef49f63          	bne	s1,a5,ffffffffc0203f64 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d6a:	00005517          	auipc	a0,0x5
ffffffffc0203d6e:	02650513          	addi	a0,a0,38 # ffffffffc0208d90 <default_pmm_manager+0xb58>
ffffffffc0203d72:	c20fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d76:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203d7a:	401c                	lw	a5,0(s0)
ffffffffc0203d7c:	2781                	sext.w	a5,a5
ffffffffc0203d7e:	1c979363          	bne	a5,s1,ffffffffc0203f44 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d82:	00005517          	auipc	a0,0x5
ffffffffc0203d86:	fbe50513          	addi	a0,a0,-66 # ffffffffc0208d40 <default_pmm_manager+0xb08>
ffffffffc0203d8a:	c08fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d8e:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203d92:	401c                	lw	a5,0(s0)
ffffffffc0203d94:	4719                	li	a4,6
ffffffffc0203d96:	2781                	sext.w	a5,a5
ffffffffc0203d98:	18e79663          	bne	a5,a4,ffffffffc0203f24 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d9c:	00005517          	auipc	a0,0x5
ffffffffc0203da0:	ff450513          	addi	a0,a0,-12 # ffffffffc0208d90 <default_pmm_manager+0xb58>
ffffffffc0203da4:	beefc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203da8:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203dac:	401c                	lw	a5,0(s0)
ffffffffc0203dae:	471d                	li	a4,7
ffffffffc0203db0:	2781                	sext.w	a5,a5
ffffffffc0203db2:	14e79963          	bne	a5,a4,ffffffffc0203f04 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203db6:	00005517          	auipc	a0,0x5
ffffffffc0203dba:	f4a50513          	addi	a0,a0,-182 # ffffffffc0208d00 <default_pmm_manager+0xac8>
ffffffffc0203dbe:	bd4fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203dc2:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203dc6:	401c                	lw	a5,0(s0)
ffffffffc0203dc8:	4721                	li	a4,8
ffffffffc0203dca:	2781                	sext.w	a5,a5
ffffffffc0203dcc:	10e79c63          	bne	a5,a4,ffffffffc0203ee4 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203dd0:	00005517          	auipc	a0,0x5
ffffffffc0203dd4:	f9850513          	addi	a0,a0,-104 # ffffffffc0208d68 <default_pmm_manager+0xb30>
ffffffffc0203dd8:	bbafc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203ddc:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203de0:	401c                	lw	a5,0(s0)
ffffffffc0203de2:	4725                	li	a4,9
ffffffffc0203de4:	2781                	sext.w	a5,a5
ffffffffc0203de6:	0ce79f63          	bne	a5,a4,ffffffffc0203ec4 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203dea:	00005517          	auipc	a0,0x5
ffffffffc0203dee:	fce50513          	addi	a0,a0,-50 # ffffffffc0208db8 <default_pmm_manager+0xb80>
ffffffffc0203df2:	ba0fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203df6:	6795                	lui	a5,0x5
ffffffffc0203df8:	4739                	li	a4,14
ffffffffc0203dfa:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4ad0>
    assert(pgfault_num==10);
ffffffffc0203dfe:	4004                	lw	s1,0(s0)
ffffffffc0203e00:	47a9                	li	a5,10
ffffffffc0203e02:	2481                	sext.w	s1,s1
ffffffffc0203e04:	0af49063          	bne	s1,a5,ffffffffc0203ea4 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e08:	00005517          	auipc	a0,0x5
ffffffffc0203e0c:	f3850513          	addi	a0,a0,-200 # ffffffffc0208d40 <default_pmm_manager+0xb08>
ffffffffc0203e10:	b82fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e14:	6785                	lui	a5,0x1
ffffffffc0203e16:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8ad0>
ffffffffc0203e1a:	06979563          	bne	a5,s1,ffffffffc0203e84 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203e1e:	401c                	lw	a5,0(s0)
ffffffffc0203e20:	472d                	li	a4,11
ffffffffc0203e22:	2781                	sext.w	a5,a5
ffffffffc0203e24:	04e79063          	bne	a5,a4,ffffffffc0203e64 <_fifo_check_swap+0x1ac>
}
ffffffffc0203e28:	60e6                	ld	ra,88(sp)
ffffffffc0203e2a:	6446                	ld	s0,80(sp)
ffffffffc0203e2c:	64a6                	ld	s1,72(sp)
ffffffffc0203e2e:	6906                	ld	s2,64(sp)
ffffffffc0203e30:	79e2                	ld	s3,56(sp)
ffffffffc0203e32:	7a42                	ld	s4,48(sp)
ffffffffc0203e34:	7aa2                	ld	s5,40(sp)
ffffffffc0203e36:	7b02                	ld	s6,32(sp)
ffffffffc0203e38:	6be2                	ld	s7,24(sp)
ffffffffc0203e3a:	6c42                	ld	s8,16(sp)
ffffffffc0203e3c:	6ca2                	ld	s9,8(sp)
ffffffffc0203e3e:	4501                	li	a0,0
ffffffffc0203e40:	6125                	addi	sp,sp,96
ffffffffc0203e42:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203e44:	00005697          	auipc	a3,0x5
ffffffffc0203e48:	d5c68693          	addi	a3,a3,-676 # ffffffffc0208ba0 <default_pmm_manager+0x968>
ffffffffc0203e4c:	00004617          	auipc	a2,0x4
ffffffffc0203e50:	ca460613          	addi	a2,a2,-860 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203e54:	05100593          	li	a1,81
ffffffffc0203e58:	00005517          	auipc	a0,0x5
ffffffffc0203e5c:	ed050513          	addi	a0,a0,-304 # ffffffffc0208d28 <default_pmm_manager+0xaf0>
ffffffffc0203e60:	e28fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==11);
ffffffffc0203e64:	00005697          	auipc	a3,0x5
ffffffffc0203e68:	00468693          	addi	a3,a3,4 # ffffffffc0208e68 <default_pmm_manager+0xc30>
ffffffffc0203e6c:	00004617          	auipc	a2,0x4
ffffffffc0203e70:	c8460613          	addi	a2,a2,-892 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203e74:	07300593          	li	a1,115
ffffffffc0203e78:	00005517          	auipc	a0,0x5
ffffffffc0203e7c:	eb050513          	addi	a0,a0,-336 # ffffffffc0208d28 <default_pmm_manager+0xaf0>
ffffffffc0203e80:	e08fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e84:	00005697          	auipc	a3,0x5
ffffffffc0203e88:	fbc68693          	addi	a3,a3,-68 # ffffffffc0208e40 <default_pmm_manager+0xc08>
ffffffffc0203e8c:	00004617          	auipc	a2,0x4
ffffffffc0203e90:	c6460613          	addi	a2,a2,-924 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203e94:	07100593          	li	a1,113
ffffffffc0203e98:	00005517          	auipc	a0,0x5
ffffffffc0203e9c:	e9050513          	addi	a0,a0,-368 # ffffffffc0208d28 <default_pmm_manager+0xaf0>
ffffffffc0203ea0:	de8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==10);
ffffffffc0203ea4:	00005697          	auipc	a3,0x5
ffffffffc0203ea8:	f8c68693          	addi	a3,a3,-116 # ffffffffc0208e30 <default_pmm_manager+0xbf8>
ffffffffc0203eac:	00004617          	auipc	a2,0x4
ffffffffc0203eb0:	c4460613          	addi	a2,a2,-956 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203eb4:	06f00593          	li	a1,111
ffffffffc0203eb8:	00005517          	auipc	a0,0x5
ffffffffc0203ebc:	e7050513          	addi	a0,a0,-400 # ffffffffc0208d28 <default_pmm_manager+0xaf0>
ffffffffc0203ec0:	dc8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==9);
ffffffffc0203ec4:	00005697          	auipc	a3,0x5
ffffffffc0203ec8:	f5c68693          	addi	a3,a3,-164 # ffffffffc0208e20 <default_pmm_manager+0xbe8>
ffffffffc0203ecc:	00004617          	auipc	a2,0x4
ffffffffc0203ed0:	c2460613          	addi	a2,a2,-988 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203ed4:	06c00593          	li	a1,108
ffffffffc0203ed8:	00005517          	auipc	a0,0x5
ffffffffc0203edc:	e5050513          	addi	a0,a0,-432 # ffffffffc0208d28 <default_pmm_manager+0xaf0>
ffffffffc0203ee0:	da8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==8);
ffffffffc0203ee4:	00005697          	auipc	a3,0x5
ffffffffc0203ee8:	f2c68693          	addi	a3,a3,-212 # ffffffffc0208e10 <default_pmm_manager+0xbd8>
ffffffffc0203eec:	00004617          	auipc	a2,0x4
ffffffffc0203ef0:	c0460613          	addi	a2,a2,-1020 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203ef4:	06900593          	li	a1,105
ffffffffc0203ef8:	00005517          	auipc	a0,0x5
ffffffffc0203efc:	e3050513          	addi	a0,a0,-464 # ffffffffc0208d28 <default_pmm_manager+0xaf0>
ffffffffc0203f00:	d88fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==7);
ffffffffc0203f04:	00005697          	auipc	a3,0x5
ffffffffc0203f08:	efc68693          	addi	a3,a3,-260 # ffffffffc0208e00 <default_pmm_manager+0xbc8>
ffffffffc0203f0c:	00004617          	auipc	a2,0x4
ffffffffc0203f10:	be460613          	addi	a2,a2,-1052 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203f14:	06600593          	li	a1,102
ffffffffc0203f18:	00005517          	auipc	a0,0x5
ffffffffc0203f1c:	e1050513          	addi	a0,a0,-496 # ffffffffc0208d28 <default_pmm_manager+0xaf0>
ffffffffc0203f20:	d68fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==6);
ffffffffc0203f24:	00005697          	auipc	a3,0x5
ffffffffc0203f28:	ecc68693          	addi	a3,a3,-308 # ffffffffc0208df0 <default_pmm_manager+0xbb8>
ffffffffc0203f2c:	00004617          	auipc	a2,0x4
ffffffffc0203f30:	bc460613          	addi	a2,a2,-1084 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203f34:	06300593          	li	a1,99
ffffffffc0203f38:	00005517          	auipc	a0,0x5
ffffffffc0203f3c:	df050513          	addi	a0,a0,-528 # ffffffffc0208d28 <default_pmm_manager+0xaf0>
ffffffffc0203f40:	d48fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==5);
ffffffffc0203f44:	00005697          	auipc	a3,0x5
ffffffffc0203f48:	e9c68693          	addi	a3,a3,-356 # ffffffffc0208de0 <default_pmm_manager+0xba8>
ffffffffc0203f4c:	00004617          	auipc	a2,0x4
ffffffffc0203f50:	ba460613          	addi	a2,a2,-1116 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203f54:	06000593          	li	a1,96
ffffffffc0203f58:	00005517          	auipc	a0,0x5
ffffffffc0203f5c:	dd050513          	addi	a0,a0,-560 # ffffffffc0208d28 <default_pmm_manager+0xaf0>
ffffffffc0203f60:	d28fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==5);
ffffffffc0203f64:	00005697          	auipc	a3,0x5
ffffffffc0203f68:	e7c68693          	addi	a3,a3,-388 # ffffffffc0208de0 <default_pmm_manager+0xba8>
ffffffffc0203f6c:	00004617          	auipc	a2,0x4
ffffffffc0203f70:	b8460613          	addi	a2,a2,-1148 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203f74:	05d00593          	li	a1,93
ffffffffc0203f78:	00005517          	auipc	a0,0x5
ffffffffc0203f7c:	db050513          	addi	a0,a0,-592 # ffffffffc0208d28 <default_pmm_manager+0xaf0>
ffffffffc0203f80:	d08fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f84:	00005697          	auipc	a3,0x5
ffffffffc0203f88:	c1c68693          	addi	a3,a3,-996 # ffffffffc0208ba0 <default_pmm_manager+0x968>
ffffffffc0203f8c:	00004617          	auipc	a2,0x4
ffffffffc0203f90:	b6460613          	addi	a2,a2,-1180 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203f94:	05a00593          	li	a1,90
ffffffffc0203f98:	00005517          	auipc	a0,0x5
ffffffffc0203f9c:	d9050513          	addi	a0,a0,-624 # ffffffffc0208d28 <default_pmm_manager+0xaf0>
ffffffffc0203fa0:	ce8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==4);
ffffffffc0203fa4:	00005697          	auipc	a3,0x5
ffffffffc0203fa8:	bfc68693          	addi	a3,a3,-1028 # ffffffffc0208ba0 <default_pmm_manager+0x968>
ffffffffc0203fac:	00004617          	auipc	a2,0x4
ffffffffc0203fb0:	b4460613          	addi	a2,a2,-1212 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203fb4:	05700593          	li	a1,87
ffffffffc0203fb8:	00005517          	auipc	a0,0x5
ffffffffc0203fbc:	d7050513          	addi	a0,a0,-656 # ffffffffc0208d28 <default_pmm_manager+0xaf0>
ffffffffc0203fc0:	cc8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==4);
ffffffffc0203fc4:	00005697          	auipc	a3,0x5
ffffffffc0203fc8:	bdc68693          	addi	a3,a3,-1060 # ffffffffc0208ba0 <default_pmm_manager+0x968>
ffffffffc0203fcc:	00004617          	auipc	a2,0x4
ffffffffc0203fd0:	b2460613          	addi	a2,a2,-1244 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0203fd4:	05400593          	li	a1,84
ffffffffc0203fd8:	00005517          	auipc	a0,0x5
ffffffffc0203fdc:	d5050513          	addi	a0,a0,-688 # ffffffffc0208d28 <default_pmm_manager+0xaf0>
ffffffffc0203fe0:	ca8fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203fe4 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203fe4:	751c                	ld	a5,40(a0)
{
ffffffffc0203fe6:	1141                	addi	sp,sp,-16
ffffffffc0203fe8:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203fea:	cf91                	beqz	a5,ffffffffc0204006 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203fec:	ee0d                	bnez	a2,ffffffffc0204026 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203fee:	679c                	ld	a5,8(a5)
}
ffffffffc0203ff0:	60a2                	ld	ra,8(sp)
ffffffffc0203ff2:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0203ff4:	6394                	ld	a3,0(a5)
ffffffffc0203ff6:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203ff8:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203ffc:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203ffe:	e314                	sd	a3,0(a4)
ffffffffc0204000:	e19c                	sd	a5,0(a1)
}
ffffffffc0204002:	0141                	addi	sp,sp,16
ffffffffc0204004:	8082                	ret
         assert(head != NULL);
ffffffffc0204006:	00005697          	auipc	a3,0x5
ffffffffc020400a:	e9268693          	addi	a3,a3,-366 # ffffffffc0208e98 <default_pmm_manager+0xc60>
ffffffffc020400e:	00004617          	auipc	a2,0x4
ffffffffc0204012:	ae260613          	addi	a2,a2,-1310 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0204016:	04100593          	li	a1,65
ffffffffc020401a:	00005517          	auipc	a0,0x5
ffffffffc020401e:	d0e50513          	addi	a0,a0,-754 # ffffffffc0208d28 <default_pmm_manager+0xaf0>
ffffffffc0204022:	c66fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(in_tick==0);
ffffffffc0204026:	00005697          	auipc	a3,0x5
ffffffffc020402a:	e8268693          	addi	a3,a3,-382 # ffffffffc0208ea8 <default_pmm_manager+0xc70>
ffffffffc020402e:	00004617          	auipc	a2,0x4
ffffffffc0204032:	ac260613          	addi	a2,a2,-1342 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0204036:	04200593          	li	a1,66
ffffffffc020403a:	00005517          	auipc	a0,0x5
ffffffffc020403e:	cee50513          	addi	a0,a0,-786 # ffffffffc0208d28 <default_pmm_manager+0xaf0>
ffffffffc0204042:	c46fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204046 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0204046:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020404a:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020404c:	cb09                	beqz	a4,ffffffffc020405e <_fifo_map_swappable+0x18>
ffffffffc020404e:	cb81                	beqz	a5,ffffffffc020405e <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204050:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0204052:	e398                	sd	a4,0(a5)
}
ffffffffc0204054:	4501                	li	a0,0
ffffffffc0204056:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0204058:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020405a:	f614                	sd	a3,40(a2)
ffffffffc020405c:	8082                	ret
{
ffffffffc020405e:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0204060:	00005697          	auipc	a3,0x5
ffffffffc0204064:	e1868693          	addi	a3,a3,-488 # ffffffffc0208e78 <default_pmm_manager+0xc40>
ffffffffc0204068:	00004617          	auipc	a2,0x4
ffffffffc020406c:	a8860613          	addi	a2,a2,-1400 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0204070:	03200593          	li	a1,50
ffffffffc0204074:	00005517          	auipc	a0,0x5
ffffffffc0204078:	cb450513          	addi	a0,a0,-844 # ffffffffc0208d28 <default_pmm_manager+0xaf0>
{
ffffffffc020407c:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc020407e:	c0afc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204082 <check_vma_overlap.isra.2.part.3>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204082:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0204084:	00005697          	auipc	a3,0x5
ffffffffc0204088:	e4c68693          	addi	a3,a3,-436 # ffffffffc0208ed0 <default_pmm_manager+0xc98>
ffffffffc020408c:	00004617          	auipc	a2,0x4
ffffffffc0204090:	a6460613          	addi	a2,a2,-1436 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0204094:	06d00593          	li	a1,109
ffffffffc0204098:	00005517          	auipc	a0,0x5
ffffffffc020409c:	e5850513          	addi	a0,a0,-424 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02040a0:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02040a2:	be6fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02040a6 <mm_create>:
mm_create(void) {
ffffffffc02040a6:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02040a8:	05800513          	li	a0,88
mm_create(void) {
ffffffffc02040ac:	e022                	sd	s0,0(sp)
ffffffffc02040ae:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02040b0:	b87fd0ef          	jal	ra,ffffffffc0201c36 <kmalloc>
ffffffffc02040b4:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02040b6:	c90d                	beqz	a0,ffffffffc02040e8 <mm_create+0x42>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02040b8:	000db797          	auipc	a5,0xdb
ffffffffc02040bc:	1f078793          	addi	a5,a5,496 # ffffffffc02df2a8 <swap_init_ok>
ffffffffc02040c0:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc02040c2:	e408                	sd	a0,8(s0)
ffffffffc02040c4:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02040c6:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02040ca:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02040ce:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02040d2:	2781                	sext.w	a5,a5
ffffffffc02040d4:	ef99                	bnez	a5,ffffffffc02040f2 <mm_create+0x4c>
        else mm->sm_priv = NULL;
ffffffffc02040d6:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc02040da:	02042823          	sw	zero,48(s0)
        sem_init(&(mm->mm_sem), 1);
ffffffffc02040de:	4585                	li	a1,1
ffffffffc02040e0:	03840513          	addi	a0,s0,56
ffffffffc02040e4:	216010ef          	jal	ra,ffffffffc02052fa <sem_init>
}
ffffffffc02040e8:	8522                	mv	a0,s0
ffffffffc02040ea:	60a2                	ld	ra,8(sp)
ffffffffc02040ec:	6402                	ld	s0,0(sp)
ffffffffc02040ee:	0141                	addi	sp,sp,16
ffffffffc02040f0:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02040f2:	9fbff0ef          	jal	ra,ffffffffc0203aec <swap_init_mm>
ffffffffc02040f6:	b7d5                	j	ffffffffc02040da <mm_create+0x34>

ffffffffc02040f8 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02040f8:	1101                	addi	sp,sp,-32
ffffffffc02040fa:	e04a                	sd	s2,0(sp)
ffffffffc02040fc:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02040fe:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204102:	e822                	sd	s0,16(sp)
ffffffffc0204104:	e426                	sd	s1,8(sp)
ffffffffc0204106:	ec06                	sd	ra,24(sp)
ffffffffc0204108:	84ae                	mv	s1,a1
ffffffffc020410a:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020410c:	b2bfd0ef          	jal	ra,ffffffffc0201c36 <kmalloc>
    if (vma != NULL) {
ffffffffc0204110:	c509                	beqz	a0,ffffffffc020411a <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0204112:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204116:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204118:	cd00                	sw	s0,24(a0)
}
ffffffffc020411a:	60e2                	ld	ra,24(sp)
ffffffffc020411c:	6442                	ld	s0,16(sp)
ffffffffc020411e:	64a2                	ld	s1,8(sp)
ffffffffc0204120:	6902                	ld	s2,0(sp)
ffffffffc0204122:	6105                	addi	sp,sp,32
ffffffffc0204124:	8082                	ret

ffffffffc0204126 <find_vma>:
    if (mm != NULL) {
ffffffffc0204126:	c51d                	beqz	a0,ffffffffc0204154 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0204128:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020412a:	c781                	beqz	a5,ffffffffc0204132 <find_vma+0xc>
ffffffffc020412c:	6798                	ld	a4,8(a5)
ffffffffc020412e:	02e5f663          	bleu	a4,a1,ffffffffc020415a <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0204132:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc0204134:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0204136:	00f50f63          	beq	a0,a5,ffffffffc0204154 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc020413a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020413e:	fee5ebe3          	bltu	a1,a4,ffffffffc0204134 <find_vma+0xe>
ffffffffc0204142:	ff07b703          	ld	a4,-16(a5)
ffffffffc0204146:	fee5f7e3          	bleu	a4,a1,ffffffffc0204134 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc020414a:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc020414c:	c781                	beqz	a5,ffffffffc0204154 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc020414e:	e91c                	sd	a5,16(a0)
}
ffffffffc0204150:	853e                	mv	a0,a5
ffffffffc0204152:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0204154:	4781                	li	a5,0
}
ffffffffc0204156:	853e                	mv	a0,a5
ffffffffc0204158:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020415a:	6b98                	ld	a4,16(a5)
ffffffffc020415c:	fce5fbe3          	bleu	a4,a1,ffffffffc0204132 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0204160:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0204162:	b7fd                	j	ffffffffc0204150 <find_vma+0x2a>

ffffffffc0204164 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204164:	6590                	ld	a2,8(a1)
ffffffffc0204166:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x8ac0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020416a:	1141                	addi	sp,sp,-16
ffffffffc020416c:	e406                	sd	ra,8(sp)
ffffffffc020416e:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204170:	01066863          	bltu	a2,a6,ffffffffc0204180 <insert_vma_struct+0x1c>
ffffffffc0204174:	a8b9                	j	ffffffffc02041d2 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0204176:	fe87b683          	ld	a3,-24(a5)
ffffffffc020417a:	04d66763          	bltu	a2,a3,ffffffffc02041c8 <insert_vma_struct+0x64>
ffffffffc020417e:	873e                	mv	a4,a5
ffffffffc0204180:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0204182:	fef51ae3          	bne	a0,a5,ffffffffc0204176 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0204186:	02a70463          	beq	a4,a0,ffffffffc02041ae <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020418a:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020418e:	fe873883          	ld	a7,-24(a4)
ffffffffc0204192:	08d8f063          	bleu	a3,a7,ffffffffc0204212 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0204196:	04d66e63          	bltu	a2,a3,ffffffffc02041f2 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc020419a:	00f50a63          	beq	a0,a5,ffffffffc02041ae <insert_vma_struct+0x4a>
ffffffffc020419e:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041a2:	0506e863          	bltu	a3,a6,ffffffffc02041f2 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02041a6:	ff07b603          	ld	a2,-16(a5)
ffffffffc02041aa:	02c6f263          	bleu	a2,a3,ffffffffc02041ce <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02041ae:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02041b0:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02041b2:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02041b6:	e390                	sd	a2,0(a5)
ffffffffc02041b8:	e710                	sd	a2,8(a4)
}
ffffffffc02041ba:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02041bc:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02041be:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc02041c0:	2685                	addiw	a3,a3,1
ffffffffc02041c2:	d114                	sw	a3,32(a0)
}
ffffffffc02041c4:	0141                	addi	sp,sp,16
ffffffffc02041c6:	8082                	ret
    if (le_prev != list) {
ffffffffc02041c8:	fca711e3          	bne	a4,a0,ffffffffc020418a <insert_vma_struct+0x26>
ffffffffc02041cc:	bfd9                	j	ffffffffc02041a2 <insert_vma_struct+0x3e>
ffffffffc02041ce:	eb5ff0ef          	jal	ra,ffffffffc0204082 <check_vma_overlap.isra.2.part.3>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02041d2:	00005697          	auipc	a3,0x5
ffffffffc02041d6:	e2e68693          	addi	a3,a3,-466 # ffffffffc0209000 <default_pmm_manager+0xdc8>
ffffffffc02041da:	00004617          	auipc	a2,0x4
ffffffffc02041de:	91660613          	addi	a2,a2,-1770 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02041e2:	07400593          	li	a1,116
ffffffffc02041e6:	00005517          	auipc	a0,0x5
ffffffffc02041ea:	d0a50513          	addi	a0,a0,-758 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc02041ee:	a9afc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041f2:	00005697          	auipc	a3,0x5
ffffffffc02041f6:	e4e68693          	addi	a3,a3,-434 # ffffffffc0209040 <default_pmm_manager+0xe08>
ffffffffc02041fa:	00004617          	auipc	a2,0x4
ffffffffc02041fe:	8f660613          	addi	a2,a2,-1802 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0204202:	06c00593          	li	a1,108
ffffffffc0204206:	00005517          	auipc	a0,0x5
ffffffffc020420a:	cea50513          	addi	a0,a0,-790 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc020420e:	a7afc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0204212:	00005697          	auipc	a3,0x5
ffffffffc0204216:	e0e68693          	addi	a3,a3,-498 # ffffffffc0209020 <default_pmm_manager+0xde8>
ffffffffc020421a:	00004617          	auipc	a2,0x4
ffffffffc020421e:	8d660613          	addi	a2,a2,-1834 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0204222:	06b00593          	li	a1,107
ffffffffc0204226:	00005517          	auipc	a0,0x5
ffffffffc020422a:	cca50513          	addi	a0,a0,-822 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc020422e:	a5afc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204232 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0204232:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0204234:	1141                	addi	sp,sp,-16
ffffffffc0204236:	e406                	sd	ra,8(sp)
ffffffffc0204238:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc020423a:	e78d                	bnez	a5,ffffffffc0204264 <mm_destroy+0x32>
ffffffffc020423c:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020423e:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0204240:	00a40c63          	beq	s0,a0,ffffffffc0204258 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204244:	6118                	ld	a4,0(a0)
ffffffffc0204246:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0204248:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020424a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020424c:	e398                	sd	a4,0(a5)
ffffffffc020424e:	aa5fd0ef          	jal	ra,ffffffffc0201cf2 <kfree>
    return listelm->next;
ffffffffc0204252:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0204254:	fea418e3          	bne	s0,a0,ffffffffc0204244 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0204258:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc020425a:	6402                	ld	s0,0(sp)
ffffffffc020425c:	60a2                	ld	ra,8(sp)
ffffffffc020425e:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0204260:	a93fd06f          	j	ffffffffc0201cf2 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0204264:	00005697          	auipc	a3,0x5
ffffffffc0204268:	dfc68693          	addi	a3,a3,-516 # ffffffffc0209060 <default_pmm_manager+0xe28>
ffffffffc020426c:	00004617          	auipc	a2,0x4
ffffffffc0204270:	88460613          	addi	a2,a2,-1916 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0204274:	09400593          	li	a1,148
ffffffffc0204278:	00005517          	auipc	a0,0x5
ffffffffc020427c:	c7850513          	addi	a0,a0,-904 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc0204280:	a08fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204284 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204284:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc0204286:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204288:	17fd                	addi	a5,a5,-1
ffffffffc020428a:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc020428c:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020428e:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc0204292:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204294:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc0204296:	fc06                	sd	ra,56(sp)
ffffffffc0204298:	f04a                	sd	s2,32(sp)
ffffffffc020429a:	ec4e                	sd	s3,24(sp)
ffffffffc020429c:	e852                	sd	s4,16(sp)
ffffffffc020429e:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042a0:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc02042a4:	002007b7          	lui	a5,0x200
ffffffffc02042a8:	01047433          	and	s0,s0,a6
ffffffffc02042ac:	06f4e363          	bltu	s1,a5,ffffffffc0204312 <mm_map+0x8e>
ffffffffc02042b0:	0684f163          	bleu	s0,s1,ffffffffc0204312 <mm_map+0x8e>
ffffffffc02042b4:	4785                	li	a5,1
ffffffffc02042b6:	07fe                	slli	a5,a5,0x1f
ffffffffc02042b8:	0487ed63          	bltu	a5,s0,ffffffffc0204312 <mm_map+0x8e>
ffffffffc02042bc:	89aa                	mv	s3,a0
ffffffffc02042be:	8a3a                	mv	s4,a4
ffffffffc02042c0:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02042c2:	c931                	beqz	a0,ffffffffc0204316 <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc02042c4:	85a6                	mv	a1,s1
ffffffffc02042c6:	e61ff0ef          	jal	ra,ffffffffc0204126 <find_vma>
ffffffffc02042ca:	c501                	beqz	a0,ffffffffc02042d2 <mm_map+0x4e>
ffffffffc02042cc:	651c                	ld	a5,8(a0)
ffffffffc02042ce:	0487e263          	bltu	a5,s0,ffffffffc0204312 <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02042d2:	03000513          	li	a0,48
ffffffffc02042d6:	961fd0ef          	jal	ra,ffffffffc0201c36 <kmalloc>
ffffffffc02042da:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02042dc:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc02042de:	02090163          	beqz	s2,ffffffffc0204300 <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02042e2:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02042e4:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02042e8:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02042ec:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02042f0:	85ca                	mv	a1,s2
ffffffffc02042f2:	e73ff0ef          	jal	ra,ffffffffc0204164 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc02042f6:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc02042f8:	000a0463          	beqz	s4,ffffffffc0204300 <mm_map+0x7c>
        *vma_store = vma;
ffffffffc02042fc:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0204300:	70e2                	ld	ra,56(sp)
ffffffffc0204302:	7442                	ld	s0,48(sp)
ffffffffc0204304:	74a2                	ld	s1,40(sp)
ffffffffc0204306:	7902                	ld	s2,32(sp)
ffffffffc0204308:	69e2                	ld	s3,24(sp)
ffffffffc020430a:	6a42                	ld	s4,16(sp)
ffffffffc020430c:	6aa2                	ld	s5,8(sp)
ffffffffc020430e:	6121                	addi	sp,sp,64
ffffffffc0204310:	8082                	ret
        return -E_INVAL;
ffffffffc0204312:	5575                	li	a0,-3
ffffffffc0204314:	b7f5                	j	ffffffffc0204300 <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc0204316:	00004697          	auipc	a3,0x4
ffffffffc020431a:	71268693          	addi	a3,a3,1810 # ffffffffc0208a28 <default_pmm_manager+0x7f0>
ffffffffc020431e:	00003617          	auipc	a2,0x3
ffffffffc0204322:	7d260613          	addi	a2,a2,2002 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0204326:	0a700593          	li	a1,167
ffffffffc020432a:	00005517          	auipc	a0,0x5
ffffffffc020432e:	bc650513          	addi	a0,a0,-1082 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc0204332:	956fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204336 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0204336:	7139                	addi	sp,sp,-64
ffffffffc0204338:	fc06                	sd	ra,56(sp)
ffffffffc020433a:	f822                	sd	s0,48(sp)
ffffffffc020433c:	f426                	sd	s1,40(sp)
ffffffffc020433e:	f04a                	sd	s2,32(sp)
ffffffffc0204340:	ec4e                	sd	s3,24(sp)
ffffffffc0204342:	e852                	sd	s4,16(sp)
ffffffffc0204344:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0204346:	c535                	beqz	a0,ffffffffc02043b2 <dup_mmap+0x7c>
ffffffffc0204348:	892a                	mv	s2,a0
ffffffffc020434a:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc020434c:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc020434e:	e59d                	bnez	a1,ffffffffc020437c <dup_mmap+0x46>
ffffffffc0204350:	a08d                	j	ffffffffc02043b2 <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0204352:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc0204354:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_matrix_out_size+0x1f43d8>
        insert_vma_struct(to, nvma);
ffffffffc0204358:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc020435a:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc020435e:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc0204362:	e03ff0ef          	jal	ra,ffffffffc0204164 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0204366:	ff043683          	ld	a3,-16(s0)
ffffffffc020436a:	fe843603          	ld	a2,-24(s0)
ffffffffc020436e:	6c8c                	ld	a1,24(s1)
ffffffffc0204370:	01893503          	ld	a0,24(s2)
ffffffffc0204374:	4701                	li	a4,0
ffffffffc0204376:	d29fe0ef          	jal	ra,ffffffffc020309e <copy_range>
ffffffffc020437a:	e105                	bnez	a0,ffffffffc020439a <dup_mmap+0x64>
    return listelm->prev;
ffffffffc020437c:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc020437e:	02848863          	beq	s1,s0,ffffffffc02043ae <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204382:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0204386:	fe843a83          	ld	s5,-24(s0)
ffffffffc020438a:	ff043a03          	ld	s4,-16(s0)
ffffffffc020438e:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204392:	8a5fd0ef          	jal	ra,ffffffffc0201c36 <kmalloc>
ffffffffc0204396:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc0204398:	fd4d                	bnez	a0,ffffffffc0204352 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc020439a:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc020439c:	70e2                	ld	ra,56(sp)
ffffffffc020439e:	7442                	ld	s0,48(sp)
ffffffffc02043a0:	74a2                	ld	s1,40(sp)
ffffffffc02043a2:	7902                	ld	s2,32(sp)
ffffffffc02043a4:	69e2                	ld	s3,24(sp)
ffffffffc02043a6:	6a42                	ld	s4,16(sp)
ffffffffc02043a8:	6aa2                	ld	s5,8(sp)
ffffffffc02043aa:	6121                	addi	sp,sp,64
ffffffffc02043ac:	8082                	ret
    return 0;
ffffffffc02043ae:	4501                	li	a0,0
ffffffffc02043b0:	b7f5                	j	ffffffffc020439c <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc02043b2:	00005697          	auipc	a3,0x5
ffffffffc02043b6:	c0e68693          	addi	a3,a3,-1010 # ffffffffc0208fc0 <default_pmm_manager+0xd88>
ffffffffc02043ba:	00003617          	auipc	a2,0x3
ffffffffc02043be:	73660613          	addi	a2,a2,1846 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02043c2:	0c000593          	li	a1,192
ffffffffc02043c6:	00005517          	auipc	a0,0x5
ffffffffc02043ca:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc02043ce:	8bafc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02043d2 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc02043d2:	1101                	addi	sp,sp,-32
ffffffffc02043d4:	ec06                	sd	ra,24(sp)
ffffffffc02043d6:	e822                	sd	s0,16(sp)
ffffffffc02043d8:	e426                	sd	s1,8(sp)
ffffffffc02043da:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02043dc:	c531                	beqz	a0,ffffffffc0204428 <exit_mmap+0x56>
ffffffffc02043de:	591c                	lw	a5,48(a0)
ffffffffc02043e0:	84aa                	mv	s1,a0
ffffffffc02043e2:	e3b9                	bnez	a5,ffffffffc0204428 <exit_mmap+0x56>
    return listelm->next;
ffffffffc02043e4:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02043e6:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc02043ea:	02850663          	beq	a0,s0,ffffffffc0204416 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02043ee:	ff043603          	ld	a2,-16(s0)
ffffffffc02043f2:	fe843583          	ld	a1,-24(s0)
ffffffffc02043f6:	854a                	mv	a0,s2
ffffffffc02043f8:	d7dfd0ef          	jal	ra,ffffffffc0202174 <unmap_range>
ffffffffc02043fc:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02043fe:	fe8498e3          	bne	s1,s0,ffffffffc02043ee <exit_mmap+0x1c>
ffffffffc0204402:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc0204404:	00848c63          	beq	s1,s0,ffffffffc020441c <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204408:	ff043603          	ld	a2,-16(s0)
ffffffffc020440c:	fe843583          	ld	a1,-24(s0)
ffffffffc0204410:	854a                	mv	a0,s2
ffffffffc0204412:	e7bfd0ef          	jal	ra,ffffffffc020228c <exit_range>
ffffffffc0204416:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204418:	fe8498e3          	bne	s1,s0,ffffffffc0204408 <exit_mmap+0x36>
    }
}
ffffffffc020441c:	60e2                	ld	ra,24(sp)
ffffffffc020441e:	6442                	ld	s0,16(sp)
ffffffffc0204420:	64a2                	ld	s1,8(sp)
ffffffffc0204422:	6902                	ld	s2,0(sp)
ffffffffc0204424:	6105                	addi	sp,sp,32
ffffffffc0204426:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204428:	00005697          	auipc	a3,0x5
ffffffffc020442c:	bb868693          	addi	a3,a3,-1096 # ffffffffc0208fe0 <default_pmm_manager+0xda8>
ffffffffc0204430:	00003617          	auipc	a2,0x3
ffffffffc0204434:	6c060613          	addi	a2,a2,1728 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0204438:	0d600593          	li	a1,214
ffffffffc020443c:	00005517          	auipc	a0,0x5
ffffffffc0204440:	ab450513          	addi	a0,a0,-1356 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc0204444:	844fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204448 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0204448:	7139                	addi	sp,sp,-64
ffffffffc020444a:	f822                	sd	s0,48(sp)
ffffffffc020444c:	f426                	sd	s1,40(sp)
ffffffffc020444e:	fc06                	sd	ra,56(sp)
ffffffffc0204450:	f04a                	sd	s2,32(sp)
ffffffffc0204452:	ec4e                	sd	s3,24(sp)
ffffffffc0204454:	e852                	sd	s4,16(sp)
ffffffffc0204456:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0204458:	c4fff0ef          	jal	ra,ffffffffc02040a6 <mm_create>
    assert(mm != NULL);
ffffffffc020445c:	842a                	mv	s0,a0
ffffffffc020445e:	03200493          	li	s1,50
ffffffffc0204462:	e919                	bnez	a0,ffffffffc0204478 <vmm_init+0x30>
ffffffffc0204464:	a989                	j	ffffffffc02048b6 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0204466:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204468:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020446a:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020446e:	14ed                	addi	s1,s1,-5
ffffffffc0204470:	8522                	mv	a0,s0
ffffffffc0204472:	cf3ff0ef          	jal	ra,ffffffffc0204164 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0204476:	c88d                	beqz	s1,ffffffffc02044a8 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204478:	03000513          	li	a0,48
ffffffffc020447c:	fbafd0ef          	jal	ra,ffffffffc0201c36 <kmalloc>
ffffffffc0204480:	85aa                	mv	a1,a0
ffffffffc0204482:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0204486:	f165                	bnez	a0,ffffffffc0204466 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0204488:	00004697          	auipc	a3,0x4
ffffffffc020448c:	5d868693          	addi	a3,a3,1496 # ffffffffc0208a60 <default_pmm_manager+0x828>
ffffffffc0204490:	00003617          	auipc	a2,0x3
ffffffffc0204494:	66060613          	addi	a2,a2,1632 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0204498:	11300593          	li	a1,275
ffffffffc020449c:	00005517          	auipc	a0,0x5
ffffffffc02044a0:	a5450513          	addi	a0,a0,-1452 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc02044a4:	fe5fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc02044a8:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02044ac:	1f900913          	li	s2,505
ffffffffc02044b0:	a819                	j	ffffffffc02044c6 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02044b2:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02044b4:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02044b6:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02044ba:	0495                	addi	s1,s1,5
ffffffffc02044bc:	8522                	mv	a0,s0
ffffffffc02044be:	ca7ff0ef          	jal	ra,ffffffffc0204164 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02044c2:	03248a63          	beq	s1,s2,ffffffffc02044f6 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044c6:	03000513          	li	a0,48
ffffffffc02044ca:	f6cfd0ef          	jal	ra,ffffffffc0201c36 <kmalloc>
ffffffffc02044ce:	85aa                	mv	a1,a0
ffffffffc02044d0:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02044d4:	fd79                	bnez	a0,ffffffffc02044b2 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02044d6:	00004697          	auipc	a3,0x4
ffffffffc02044da:	58a68693          	addi	a3,a3,1418 # ffffffffc0208a60 <default_pmm_manager+0x828>
ffffffffc02044de:	00003617          	auipc	a2,0x3
ffffffffc02044e2:	61260613          	addi	a2,a2,1554 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02044e6:	11900593          	li	a1,281
ffffffffc02044ea:	00005517          	auipc	a0,0x5
ffffffffc02044ee:	a0650513          	addi	a0,a0,-1530 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc02044f2:	f97fb0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc02044f6:	6418                	ld	a4,8(s0)
ffffffffc02044f8:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02044fa:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02044fe:	2ee40063          	beq	s0,a4,ffffffffc02047de <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204502:	fe873603          	ld	a2,-24(a4)
ffffffffc0204506:	ffe78693          	addi	a3,a5,-2
ffffffffc020450a:	24d61a63          	bne	a2,a3,ffffffffc020475e <vmm_init+0x316>
ffffffffc020450e:	ff073683          	ld	a3,-16(a4)
ffffffffc0204512:	24f69663          	bne	a3,a5,ffffffffc020475e <vmm_init+0x316>
ffffffffc0204516:	0795                	addi	a5,a5,5
ffffffffc0204518:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc020451a:	feb792e3          	bne	a5,a1,ffffffffc02044fe <vmm_init+0xb6>
ffffffffc020451e:	491d                	li	s2,7
ffffffffc0204520:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0204522:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0204526:	85a6                	mv	a1,s1
ffffffffc0204528:	8522                	mv	a0,s0
ffffffffc020452a:	bfdff0ef          	jal	ra,ffffffffc0204126 <find_vma>
ffffffffc020452e:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0204530:	30050763          	beqz	a0,ffffffffc020483e <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0204534:	00148593          	addi	a1,s1,1
ffffffffc0204538:	8522                	mv	a0,s0
ffffffffc020453a:	bedff0ef          	jal	ra,ffffffffc0204126 <find_vma>
ffffffffc020453e:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0204540:	2c050f63          	beqz	a0,ffffffffc020481e <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0204544:	85ca                	mv	a1,s2
ffffffffc0204546:	8522                	mv	a0,s0
ffffffffc0204548:	bdfff0ef          	jal	ra,ffffffffc0204126 <find_vma>
        assert(vma3 == NULL);
ffffffffc020454c:	2a051963          	bnez	a0,ffffffffc02047fe <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0204550:	00348593          	addi	a1,s1,3
ffffffffc0204554:	8522                	mv	a0,s0
ffffffffc0204556:	bd1ff0ef          	jal	ra,ffffffffc0204126 <find_vma>
        assert(vma4 == NULL);
ffffffffc020455a:	32051263          	bnez	a0,ffffffffc020487e <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020455e:	00448593          	addi	a1,s1,4
ffffffffc0204562:	8522                	mv	a0,s0
ffffffffc0204564:	bc3ff0ef          	jal	ra,ffffffffc0204126 <find_vma>
        assert(vma5 == NULL);
ffffffffc0204568:	2e051b63          	bnez	a0,ffffffffc020485e <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020456c:	008a3783          	ld	a5,8(s4)
ffffffffc0204570:	20979763          	bne	a5,s1,ffffffffc020477e <vmm_init+0x336>
ffffffffc0204574:	010a3783          	ld	a5,16(s4)
ffffffffc0204578:	21279363          	bne	a5,s2,ffffffffc020477e <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020457c:	0089b783          	ld	a5,8(s3)
ffffffffc0204580:	20979f63          	bne	a5,s1,ffffffffc020479e <vmm_init+0x356>
ffffffffc0204584:	0109b783          	ld	a5,16(s3)
ffffffffc0204588:	21279b63          	bne	a5,s2,ffffffffc020479e <vmm_init+0x356>
ffffffffc020458c:	0495                	addi	s1,s1,5
ffffffffc020458e:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0204590:	f9549be3          	bne	s1,s5,ffffffffc0204526 <vmm_init+0xde>
ffffffffc0204594:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0204596:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0204598:	85a6                	mv	a1,s1
ffffffffc020459a:	8522                	mv	a0,s0
ffffffffc020459c:	b8bff0ef          	jal	ra,ffffffffc0204126 <find_vma>
ffffffffc02045a0:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc02045a4:	c90d                	beqz	a0,ffffffffc02045d6 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02045a6:	6914                	ld	a3,16(a0)
ffffffffc02045a8:	6510                	ld	a2,8(a0)
ffffffffc02045aa:	00005517          	auipc	a0,0x5
ffffffffc02045ae:	bce50513          	addi	a0,a0,-1074 # ffffffffc0209178 <default_pmm_manager+0xf40>
ffffffffc02045b2:	be1fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02045b6:	00005697          	auipc	a3,0x5
ffffffffc02045ba:	bea68693          	addi	a3,a3,-1046 # ffffffffc02091a0 <default_pmm_manager+0xf68>
ffffffffc02045be:	00003617          	auipc	a2,0x3
ffffffffc02045c2:	53260613          	addi	a2,a2,1330 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02045c6:	13b00593          	li	a1,315
ffffffffc02045ca:	00005517          	auipc	a0,0x5
ffffffffc02045ce:	92650513          	addi	a0,a0,-1754 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc02045d2:	eb7fb0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc02045d6:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02045d8:	fd2490e3          	bne	s1,s2,ffffffffc0204598 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc02045dc:	8522                	mv	a0,s0
ffffffffc02045de:	c55ff0ef          	jal	ra,ffffffffc0204232 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02045e2:	00005517          	auipc	a0,0x5
ffffffffc02045e6:	bd650513          	addi	a0,a0,-1066 # ffffffffc02091b8 <default_pmm_manager+0xf80>
ffffffffc02045ea:	ba9fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02045ee:	913fd0ef          	jal	ra,ffffffffc0201f00 <nr_free_pages>
ffffffffc02045f2:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02045f4:	ab3ff0ef          	jal	ra,ffffffffc02040a6 <mm_create>
ffffffffc02045f8:	000db797          	auipc	a5,0xdb
ffffffffc02045fc:	e0a7b023          	sd	a0,-512(a5) # ffffffffc02df3f8 <check_mm_struct>
ffffffffc0204600:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0204602:	36050663          	beqz	a0,ffffffffc020496e <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204606:	000db797          	auipc	a5,0xdb
ffffffffc020460a:	c8a78793          	addi	a5,a5,-886 # ffffffffc02df290 <boot_pgdir>
ffffffffc020460e:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0204612:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204616:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc020461a:	2c079e63          	bnez	a5,ffffffffc02048f6 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020461e:	03000513          	li	a0,48
ffffffffc0204622:	e14fd0ef          	jal	ra,ffffffffc0201c36 <kmalloc>
ffffffffc0204626:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0204628:	18050b63          	beqz	a0,ffffffffc02047be <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc020462c:	002007b7          	lui	a5,0x200
ffffffffc0204630:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0204632:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0204634:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0204636:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0204638:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc020463a:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc020463e:	b27ff0ef          	jal	ra,ffffffffc0204164 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0204642:	10000593          	li	a1,256
ffffffffc0204646:	8526                	mv	a0,s1
ffffffffc0204648:	adfff0ef          	jal	ra,ffffffffc0204126 <find_vma>
ffffffffc020464c:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc0204650:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0204654:	2ca41163          	bne	s0,a0,ffffffffc0204916 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0204658:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_matrix_out_size+0x1f43d0>
        sum += i;
ffffffffc020465c:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc020465e:	fee79de3          	bne	a5,a4,ffffffffc0204658 <vmm_init+0x210>
        sum += i;
ffffffffc0204662:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0204664:	10000793          	li	a5,256
        sum += i;
ffffffffc0204668:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x877a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc020466c:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0204670:	0007c683          	lbu	a3,0(a5)
ffffffffc0204674:	0785                	addi	a5,a5,1
ffffffffc0204676:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0204678:	fec79ce3          	bne	a5,a2,ffffffffc0204670 <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc020467c:	2c071963          	bnez	a4,ffffffffc020494e <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204680:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204684:	000dba97          	auipc	s5,0xdb
ffffffffc0204688:	c14a8a93          	addi	s5,s5,-1004 # ffffffffc02df298 <npage>
ffffffffc020468c:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204690:	078a                	slli	a5,a5,0x2
ffffffffc0204692:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204694:	20e7f563          	bleu	a4,a5,ffffffffc020489e <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0204698:	00006697          	auipc	a3,0x6
ffffffffc020469c:	22068693          	addi	a3,a3,544 # ffffffffc020a8b8 <nbase>
ffffffffc02046a0:	0006ba03          	ld	s4,0(a3)
ffffffffc02046a4:	414786b3          	sub	a3,a5,s4
ffffffffc02046a8:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02046aa:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02046ac:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc02046ae:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02046b0:	83b1                	srli	a5,a5,0xc
ffffffffc02046b2:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02046b4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02046b6:	28e7f063          	bleu	a4,a5,ffffffffc0204936 <vmm_init+0x4ee>
ffffffffc02046ba:	000db797          	auipc	a5,0xdb
ffffffffc02046be:	c4e78793          	addi	a5,a5,-946 # ffffffffc02df308 <va_pa_offset>
ffffffffc02046c2:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02046c4:	4581                	li	a1,0
ffffffffc02046c6:	854a                	mv	a0,s2
ffffffffc02046c8:	9436                	add	s0,s0,a3
ffffffffc02046ca:	e19fd0ef          	jal	ra,ffffffffc02024e2 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046ce:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02046d0:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046d4:	078a                	slli	a5,a5,0x2
ffffffffc02046d6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046d8:	1ce7f363          	bleu	a4,a5,ffffffffc020489e <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02046dc:	000db417          	auipc	s0,0xdb
ffffffffc02046e0:	c3c40413          	addi	s0,s0,-964 # ffffffffc02df318 <pages>
ffffffffc02046e4:	6008                	ld	a0,0(s0)
ffffffffc02046e6:	414787b3          	sub	a5,a5,s4
ffffffffc02046ea:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02046ec:	953e                	add	a0,a0,a5
ffffffffc02046ee:	4585                	li	a1,1
ffffffffc02046f0:	fcafd0ef          	jal	ra,ffffffffc0201eba <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046f4:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02046f8:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046fc:	078a                	slli	a5,a5,0x2
ffffffffc02046fe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204700:	18e7ff63          	bleu	a4,a5,ffffffffc020489e <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0204704:	6008                	ld	a0,0(s0)
ffffffffc0204706:	414787b3          	sub	a5,a5,s4
ffffffffc020470a:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020470c:	4585                	li	a1,1
ffffffffc020470e:	953e                	add	a0,a0,a5
ffffffffc0204710:	faafd0ef          	jal	ra,ffffffffc0201eba <free_pages>
    pgdir[0] = 0;
ffffffffc0204714:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0204718:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc020471c:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0204720:	8526                	mv	a0,s1
ffffffffc0204722:	b11ff0ef          	jal	ra,ffffffffc0204232 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0204726:	000db797          	auipc	a5,0xdb
ffffffffc020472a:	cc07b923          	sd	zero,-814(a5) # ffffffffc02df3f8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020472e:	fd2fd0ef          	jal	ra,ffffffffc0201f00 <nr_free_pages>
ffffffffc0204732:	1aa99263          	bne	s3,a0,ffffffffc02048d6 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0204736:	00005517          	auipc	a0,0x5
ffffffffc020473a:	b1250513          	addi	a0,a0,-1262 # ffffffffc0209248 <default_pmm_manager+0x1010>
ffffffffc020473e:	a55fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc0204742:	7442                	ld	s0,48(sp)
ffffffffc0204744:	70e2                	ld	ra,56(sp)
ffffffffc0204746:	74a2                	ld	s1,40(sp)
ffffffffc0204748:	7902                	ld	s2,32(sp)
ffffffffc020474a:	69e2                	ld	s3,24(sp)
ffffffffc020474c:	6a42                	ld	s4,16(sp)
ffffffffc020474e:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204750:	00005517          	auipc	a0,0x5
ffffffffc0204754:	b1850513          	addi	a0,a0,-1256 # ffffffffc0209268 <default_pmm_manager+0x1030>
}
ffffffffc0204758:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc020475a:	a39fb06f          	j	ffffffffc0200192 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020475e:	00005697          	auipc	a3,0x5
ffffffffc0204762:	93268693          	addi	a3,a3,-1742 # ffffffffc0209090 <default_pmm_manager+0xe58>
ffffffffc0204766:	00003617          	auipc	a2,0x3
ffffffffc020476a:	38a60613          	addi	a2,a2,906 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020476e:	12200593          	li	a1,290
ffffffffc0204772:	00004517          	auipc	a0,0x4
ffffffffc0204776:	77e50513          	addi	a0,a0,1918 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc020477a:	d0ffb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020477e:	00005697          	auipc	a3,0x5
ffffffffc0204782:	99a68693          	addi	a3,a3,-1638 # ffffffffc0209118 <default_pmm_manager+0xee0>
ffffffffc0204786:	00003617          	auipc	a2,0x3
ffffffffc020478a:	36a60613          	addi	a2,a2,874 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020478e:	13200593          	li	a1,306
ffffffffc0204792:	00004517          	auipc	a0,0x4
ffffffffc0204796:	75e50513          	addi	a0,a0,1886 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc020479a:	ceffb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020479e:	00005697          	auipc	a3,0x5
ffffffffc02047a2:	9aa68693          	addi	a3,a3,-1622 # ffffffffc0209148 <default_pmm_manager+0xf10>
ffffffffc02047a6:	00003617          	auipc	a2,0x3
ffffffffc02047aa:	34a60613          	addi	a2,a2,842 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02047ae:	13300593          	li	a1,307
ffffffffc02047b2:	00004517          	auipc	a0,0x4
ffffffffc02047b6:	73e50513          	addi	a0,a0,1854 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc02047ba:	ccffb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(vma != NULL);
ffffffffc02047be:	00004697          	auipc	a3,0x4
ffffffffc02047c2:	2a268693          	addi	a3,a3,674 # ffffffffc0208a60 <default_pmm_manager+0x828>
ffffffffc02047c6:	00003617          	auipc	a2,0x3
ffffffffc02047ca:	32a60613          	addi	a2,a2,810 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02047ce:	15200593          	li	a1,338
ffffffffc02047d2:	00004517          	auipc	a0,0x4
ffffffffc02047d6:	71e50513          	addi	a0,a0,1822 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc02047da:	caffb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02047de:	00005697          	auipc	a3,0x5
ffffffffc02047e2:	89a68693          	addi	a3,a3,-1894 # ffffffffc0209078 <default_pmm_manager+0xe40>
ffffffffc02047e6:	00003617          	auipc	a2,0x3
ffffffffc02047ea:	30a60613          	addi	a2,a2,778 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02047ee:	12000593          	li	a1,288
ffffffffc02047f2:	00004517          	auipc	a0,0x4
ffffffffc02047f6:	6fe50513          	addi	a0,a0,1790 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc02047fa:	c8ffb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma3 == NULL);
ffffffffc02047fe:	00005697          	auipc	a3,0x5
ffffffffc0204802:	8ea68693          	addi	a3,a3,-1814 # ffffffffc02090e8 <default_pmm_manager+0xeb0>
ffffffffc0204806:	00003617          	auipc	a2,0x3
ffffffffc020480a:	2ea60613          	addi	a2,a2,746 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020480e:	12c00593          	li	a1,300
ffffffffc0204812:	00004517          	auipc	a0,0x4
ffffffffc0204816:	6de50513          	addi	a0,a0,1758 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc020481a:	c6ffb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma2 != NULL);
ffffffffc020481e:	00005697          	auipc	a3,0x5
ffffffffc0204822:	8ba68693          	addi	a3,a3,-1862 # ffffffffc02090d8 <default_pmm_manager+0xea0>
ffffffffc0204826:	00003617          	auipc	a2,0x3
ffffffffc020482a:	2ca60613          	addi	a2,a2,714 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020482e:	12a00593          	li	a1,298
ffffffffc0204832:	00004517          	auipc	a0,0x4
ffffffffc0204836:	6be50513          	addi	a0,a0,1726 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc020483a:	c4ffb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma1 != NULL);
ffffffffc020483e:	00005697          	auipc	a3,0x5
ffffffffc0204842:	88a68693          	addi	a3,a3,-1910 # ffffffffc02090c8 <default_pmm_manager+0xe90>
ffffffffc0204846:	00003617          	auipc	a2,0x3
ffffffffc020484a:	2aa60613          	addi	a2,a2,682 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020484e:	12800593          	li	a1,296
ffffffffc0204852:	00004517          	auipc	a0,0x4
ffffffffc0204856:	69e50513          	addi	a0,a0,1694 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc020485a:	c2ffb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma5 == NULL);
ffffffffc020485e:	00005697          	auipc	a3,0x5
ffffffffc0204862:	8aa68693          	addi	a3,a3,-1878 # ffffffffc0209108 <default_pmm_manager+0xed0>
ffffffffc0204866:	00003617          	auipc	a2,0x3
ffffffffc020486a:	28a60613          	addi	a2,a2,650 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020486e:	13000593          	li	a1,304
ffffffffc0204872:	00004517          	auipc	a0,0x4
ffffffffc0204876:	67e50513          	addi	a0,a0,1662 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc020487a:	c0ffb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma4 == NULL);
ffffffffc020487e:	00005697          	auipc	a3,0x5
ffffffffc0204882:	87a68693          	addi	a3,a3,-1926 # ffffffffc02090f8 <default_pmm_manager+0xec0>
ffffffffc0204886:	00003617          	auipc	a2,0x3
ffffffffc020488a:	26a60613          	addi	a2,a2,618 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020488e:	12e00593          	li	a1,302
ffffffffc0204892:	00004517          	auipc	a0,0x4
ffffffffc0204896:	65e50513          	addi	a0,a0,1630 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc020489a:	beffb0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020489e:	00004617          	auipc	a2,0x4
ffffffffc02048a2:	a4a60613          	addi	a2,a2,-1462 # ffffffffc02082e8 <default_pmm_manager+0xb0>
ffffffffc02048a6:	06200593          	li	a1,98
ffffffffc02048aa:	00004517          	auipc	a0,0x4
ffffffffc02048ae:	a0650513          	addi	a0,a0,-1530 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc02048b2:	bd7fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(mm != NULL);
ffffffffc02048b6:	00004697          	auipc	a3,0x4
ffffffffc02048ba:	17268693          	addi	a3,a3,370 # ffffffffc0208a28 <default_pmm_manager+0x7f0>
ffffffffc02048be:	00003617          	auipc	a2,0x3
ffffffffc02048c2:	23260613          	addi	a2,a2,562 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02048c6:	10c00593          	li	a1,268
ffffffffc02048ca:	00004517          	auipc	a0,0x4
ffffffffc02048ce:	62650513          	addi	a0,a0,1574 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc02048d2:	bb7fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02048d6:	00005697          	auipc	a3,0x5
ffffffffc02048da:	94a68693          	addi	a3,a3,-1718 # ffffffffc0209220 <default_pmm_manager+0xfe8>
ffffffffc02048de:	00003617          	auipc	a2,0x3
ffffffffc02048e2:	21260613          	addi	a2,a2,530 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02048e6:	17000593          	li	a1,368
ffffffffc02048ea:	00004517          	auipc	a0,0x4
ffffffffc02048ee:	60650513          	addi	a0,a0,1542 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc02048f2:	b97fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02048f6:	00004697          	auipc	a3,0x4
ffffffffc02048fa:	15a68693          	addi	a3,a3,346 # ffffffffc0208a50 <default_pmm_manager+0x818>
ffffffffc02048fe:	00003617          	auipc	a2,0x3
ffffffffc0204902:	1f260613          	addi	a2,a2,498 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0204906:	14f00593          	li	a1,335
ffffffffc020490a:	00004517          	auipc	a0,0x4
ffffffffc020490e:	5e650513          	addi	a0,a0,1510 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc0204912:	b77fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204916:	00005697          	auipc	a3,0x5
ffffffffc020491a:	8da68693          	addi	a3,a3,-1830 # ffffffffc02091f0 <default_pmm_manager+0xfb8>
ffffffffc020491e:	00003617          	auipc	a2,0x3
ffffffffc0204922:	1d260613          	addi	a2,a2,466 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0204926:	15700593          	li	a1,343
ffffffffc020492a:	00004517          	auipc	a0,0x4
ffffffffc020492e:	5c650513          	addi	a0,a0,1478 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc0204932:	b57fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204936:	00004617          	auipc	a2,0x4
ffffffffc020493a:	95260613          	addi	a2,a2,-1710 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc020493e:	06900593          	li	a1,105
ffffffffc0204942:	00004517          	auipc	a0,0x4
ffffffffc0204946:	96e50513          	addi	a0,a0,-1682 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc020494a:	b3ffb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(sum == 0);
ffffffffc020494e:	00005697          	auipc	a3,0x5
ffffffffc0204952:	8c268693          	addi	a3,a3,-1854 # ffffffffc0209210 <default_pmm_manager+0xfd8>
ffffffffc0204956:	00003617          	auipc	a2,0x3
ffffffffc020495a:	19a60613          	addi	a2,a2,410 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020495e:	16300593          	li	a1,355
ffffffffc0204962:	00004517          	auipc	a0,0x4
ffffffffc0204966:	58e50513          	addi	a0,a0,1422 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc020496a:	b1ffb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020496e:	00005697          	auipc	a3,0x5
ffffffffc0204972:	86a68693          	addi	a3,a3,-1942 # ffffffffc02091d8 <default_pmm_manager+0xfa0>
ffffffffc0204976:	00003617          	auipc	a2,0x3
ffffffffc020497a:	17a60613          	addi	a2,a2,378 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020497e:	14b00593          	li	a1,331
ffffffffc0204982:	00004517          	auipc	a0,0x4
ffffffffc0204986:	56e50513          	addi	a0,a0,1390 # ffffffffc0208ef0 <default_pmm_manager+0xcb8>
ffffffffc020498a:	afffb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020498e <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020498e:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204990:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204992:	f822                	sd	s0,48(sp)
ffffffffc0204994:	f426                	sd	s1,40(sp)
ffffffffc0204996:	fc06                	sd	ra,56(sp)
ffffffffc0204998:	f04a                	sd	s2,32(sp)
ffffffffc020499a:	ec4e                	sd	s3,24(sp)
ffffffffc020499c:	8432                	mv	s0,a2
ffffffffc020499e:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02049a0:	f86ff0ef          	jal	ra,ffffffffc0204126 <find_vma>

    pgfault_num++;
ffffffffc02049a4:	000db797          	auipc	a5,0xdb
ffffffffc02049a8:	90878793          	addi	a5,a5,-1784 # ffffffffc02df2ac <pgfault_num>
ffffffffc02049ac:	439c                	lw	a5,0(a5)
ffffffffc02049ae:	2785                	addiw	a5,a5,1
ffffffffc02049b0:	000db717          	auipc	a4,0xdb
ffffffffc02049b4:	8ef72e23          	sw	a5,-1796(a4) # ffffffffc02df2ac <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02049b8:	c555                	beqz	a0,ffffffffc0204a64 <do_pgfault+0xd6>
ffffffffc02049ba:	651c                	ld	a5,8(a0)
ffffffffc02049bc:	0af46463          	bltu	s0,a5,ffffffffc0204a64 <do_pgfault+0xd6>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02049c0:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02049c2:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02049c4:	8b89                	andi	a5,a5,2
ffffffffc02049c6:	e3a5                	bnez	a5,ffffffffc0204a26 <do_pgfault+0x98>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049c8:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02049ca:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049cc:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02049ce:	85a2                	mv	a1,s0
ffffffffc02049d0:	4605                	li	a2,1
ffffffffc02049d2:	d6efd0ef          	jal	ra,ffffffffc0201f40 <get_pte>
ffffffffc02049d6:	c945                	beqz	a0,ffffffffc0204a86 <do_pgfault+0xf8>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc02049d8:	610c                	ld	a1,0(a0)
ffffffffc02049da:	c5b5                	beqz	a1,ffffffffc0204a46 <do_pgfault+0xb8>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if(swap_init_ok) {
ffffffffc02049dc:	000db797          	auipc	a5,0xdb
ffffffffc02049e0:	8cc78793          	addi	a5,a5,-1844 # ffffffffc02df2a8 <swap_init_ok>
ffffffffc02049e4:	439c                	lw	a5,0(a5)
ffffffffc02049e6:	2781                	sext.w	a5,a5
ffffffffc02049e8:	c7d9                	beqz	a5,ffffffffc0204a76 <do_pgfault+0xe8>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc02049ea:	0030                	addi	a2,sp,8
ffffffffc02049ec:	85a2                	mv	a1,s0
ffffffffc02049ee:	8526                	mv	a0,s1
            struct Page *page=NULL;
ffffffffc02049f0:	e402                	sd	zero,8(sp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc02049f2:	a2eff0ef          	jal	ra,ffffffffc0203c20 <swap_in>
ffffffffc02049f6:	892a                	mv	s2,a0
ffffffffc02049f8:	e90d                	bnez	a0,ffffffffc0204a2a <do_pgfault+0x9c>
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc02049fa:	65a2                	ld	a1,8(sp)
ffffffffc02049fc:	6c88                	ld	a0,24(s1)
ffffffffc02049fe:	86ce                	mv	a3,s3
ffffffffc0204a00:	8622                	mv	a2,s0
ffffffffc0204a02:	b55fd0ef          	jal	ra,ffffffffc0202556 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0204a06:	6622                	ld	a2,8(sp)
ffffffffc0204a08:	4685                	li	a3,1
ffffffffc0204a0a:	85a2                	mv	a1,s0
ffffffffc0204a0c:	8526                	mv	a0,s1
ffffffffc0204a0e:	8eeff0ef          	jal	ra,ffffffffc0203afc <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0204a12:	67a2                	ld	a5,8(sp)
ffffffffc0204a14:	ff80                	sd	s0,56(a5)
        }
   }
   ret = 0;
failed:
    return ret;
}
ffffffffc0204a16:	70e2                	ld	ra,56(sp)
ffffffffc0204a18:	7442                	ld	s0,48(sp)
ffffffffc0204a1a:	854a                	mv	a0,s2
ffffffffc0204a1c:	74a2                	ld	s1,40(sp)
ffffffffc0204a1e:	7902                	ld	s2,32(sp)
ffffffffc0204a20:	69e2                	ld	s3,24(sp)
ffffffffc0204a22:	6121                	addi	sp,sp,64
ffffffffc0204a24:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204a26:	49dd                	li	s3,23
ffffffffc0204a28:	b745                	j	ffffffffc02049c8 <do_pgfault+0x3a>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc0204a2a:	00004517          	auipc	a0,0x4
ffffffffc0204a2e:	54e50513          	addi	a0,a0,1358 # ffffffffc0208f78 <default_pmm_manager+0xd40>
ffffffffc0204a32:	f60fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc0204a36:	70e2                	ld	ra,56(sp)
ffffffffc0204a38:	7442                	ld	s0,48(sp)
ffffffffc0204a3a:	854a                	mv	a0,s2
ffffffffc0204a3c:	74a2                	ld	s1,40(sp)
ffffffffc0204a3e:	7902                	ld	s2,32(sp)
ffffffffc0204a40:	69e2                	ld	s3,24(sp)
ffffffffc0204a42:	6121                	addi	sp,sp,64
ffffffffc0204a44:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204a46:	6c88                	ld	a0,24(s1)
ffffffffc0204a48:	864e                	mv	a2,s3
ffffffffc0204a4a:	85a2                	mv	a1,s0
ffffffffc0204a4c:	88dfe0ef          	jal	ra,ffffffffc02032d8 <pgdir_alloc_page>
   ret = 0;
ffffffffc0204a50:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204a52:	f171                	bnez	a0,ffffffffc0204a16 <do_pgfault+0x88>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204a54:	00004517          	auipc	a0,0x4
ffffffffc0204a58:	4fc50513          	addi	a0,a0,1276 # ffffffffc0208f50 <default_pmm_manager+0xd18>
ffffffffc0204a5c:	f36fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a60:	5971                	li	s2,-4
            goto failed;
ffffffffc0204a62:	bf55                	j	ffffffffc0204a16 <do_pgfault+0x88>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204a64:	85a2                	mv	a1,s0
ffffffffc0204a66:	00004517          	auipc	a0,0x4
ffffffffc0204a6a:	49a50513          	addi	a0,a0,1178 # ffffffffc0208f00 <default_pmm_manager+0xcc8>
ffffffffc0204a6e:	f24fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    int ret = -E_INVAL;
ffffffffc0204a72:	5975                	li	s2,-3
        goto failed;
ffffffffc0204a74:	b74d                	j	ffffffffc0204a16 <do_pgfault+0x88>
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
ffffffffc0204a76:	00004517          	auipc	a0,0x4
ffffffffc0204a7a:	52250513          	addi	a0,a0,1314 # ffffffffc0208f98 <default_pmm_manager+0xd60>
ffffffffc0204a7e:	f14fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a82:	5971                	li	s2,-4
            goto failed;
ffffffffc0204a84:	bf49                	j	ffffffffc0204a16 <do_pgfault+0x88>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204a86:	00004517          	auipc	a0,0x4
ffffffffc0204a8a:	4aa50513          	addi	a0,a0,1194 # ffffffffc0208f30 <default_pmm_manager+0xcf8>
ffffffffc0204a8e:	f04fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a92:	5971                	li	s2,-4
        goto failed;
ffffffffc0204a94:	b749                	j	ffffffffc0204a16 <do_pgfault+0x88>

ffffffffc0204a96 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204a96:	7179                	addi	sp,sp,-48
ffffffffc0204a98:	f022                	sd	s0,32(sp)
ffffffffc0204a9a:	f406                	sd	ra,40(sp)
ffffffffc0204a9c:	ec26                	sd	s1,24(sp)
ffffffffc0204a9e:	e84a                	sd	s2,16(sp)
ffffffffc0204aa0:	e44e                	sd	s3,8(sp)
ffffffffc0204aa2:	e052                	sd	s4,0(sp)
ffffffffc0204aa4:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204aa6:	c135                	beqz	a0,ffffffffc0204b0a <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204aa8:	002007b7          	lui	a5,0x200
ffffffffc0204aac:	04f5e663          	bltu	a1,a5,ffffffffc0204af8 <user_mem_check+0x62>
ffffffffc0204ab0:	00c584b3          	add	s1,a1,a2
ffffffffc0204ab4:	0495f263          	bleu	s1,a1,ffffffffc0204af8 <user_mem_check+0x62>
ffffffffc0204ab8:	4785                	li	a5,1
ffffffffc0204aba:	07fe                	slli	a5,a5,0x1f
ffffffffc0204abc:	0297ee63          	bltu	a5,s1,ffffffffc0204af8 <user_mem_check+0x62>
ffffffffc0204ac0:	892a                	mv	s2,a0
ffffffffc0204ac2:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204ac4:	6a05                	lui	s4,0x1
ffffffffc0204ac6:	a821                	j	ffffffffc0204ade <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204ac8:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204acc:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204ace:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204ad0:	c685                	beqz	a3,ffffffffc0204af8 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204ad2:	c399                	beqz	a5,ffffffffc0204ad8 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204ad4:	02e46263          	bltu	s0,a4,ffffffffc0204af8 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204ad8:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204ada:	04947663          	bleu	s1,s0,ffffffffc0204b26 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204ade:	85a2                	mv	a1,s0
ffffffffc0204ae0:	854a                	mv	a0,s2
ffffffffc0204ae2:	e44ff0ef          	jal	ra,ffffffffc0204126 <find_vma>
ffffffffc0204ae6:	c909                	beqz	a0,ffffffffc0204af8 <user_mem_check+0x62>
ffffffffc0204ae8:	6518                	ld	a4,8(a0)
ffffffffc0204aea:	00e46763          	bltu	s0,a4,ffffffffc0204af8 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204aee:	4d1c                	lw	a5,24(a0)
ffffffffc0204af0:	fc099ce3          	bnez	s3,ffffffffc0204ac8 <user_mem_check+0x32>
ffffffffc0204af4:	8b85                	andi	a5,a5,1
ffffffffc0204af6:	f3ed                	bnez	a5,ffffffffc0204ad8 <user_mem_check+0x42>
            return 0;
ffffffffc0204af8:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204afa:	70a2                	ld	ra,40(sp)
ffffffffc0204afc:	7402                	ld	s0,32(sp)
ffffffffc0204afe:	64e2                	ld	s1,24(sp)
ffffffffc0204b00:	6942                	ld	s2,16(sp)
ffffffffc0204b02:	69a2                	ld	s3,8(sp)
ffffffffc0204b04:	6a02                	ld	s4,0(sp)
ffffffffc0204b06:	6145                	addi	sp,sp,48
ffffffffc0204b08:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204b0a:	c02007b7          	lui	a5,0xc0200
ffffffffc0204b0e:	4501                	li	a0,0
ffffffffc0204b10:	fef5e5e3          	bltu	a1,a5,ffffffffc0204afa <user_mem_check+0x64>
ffffffffc0204b14:	962e                	add	a2,a2,a1
ffffffffc0204b16:	fec5f2e3          	bleu	a2,a1,ffffffffc0204afa <user_mem_check+0x64>
ffffffffc0204b1a:	c8000537          	lui	a0,0xc8000
ffffffffc0204b1e:	0505                	addi	a0,a0,1
ffffffffc0204b20:	00a63533          	sltu	a0,a2,a0
ffffffffc0204b24:	bfd9                	j	ffffffffc0204afa <user_mem_check+0x64>
        return 1;
ffffffffc0204b26:	4505                	li	a0,1
ffffffffc0204b28:	bfc9                	j	ffffffffc0204afa <user_mem_check+0x64>

ffffffffc0204b2a <phi_test_sema>:

struct proc_struct *philosopher_proc_sema[N];

void phi_test_sema(int i) /* i：哲学家号码从0到N-1 */
{ 
    if(state_sema[i]==HUNGRY&&state_sema[LEFT]!=EATING
ffffffffc0204b2a:	000db697          	auipc	a3,0xdb
ffffffffc0204b2e:	8d668693          	addi	a3,a3,-1834 # ffffffffc02df400 <state_sema>
ffffffffc0204b32:	00251793          	slli	a5,a0,0x2
ffffffffc0204b36:	97b6                	add	a5,a5,a3
ffffffffc0204b38:	4390                	lw	a2,0(a5)
ffffffffc0204b3a:	4705                	li	a4,1
ffffffffc0204b3c:	00e60363          	beq	a2,a4,ffffffffc0204b42 <phi_test_sema+0x18>
            &&state_sema[RIGHT]!=EATING)
    {
        state_sema[i]=EATING;
        up(&s[i]);
    }
}
ffffffffc0204b40:	8082                	ret
    if(state_sema[i]==HUNGRY&&state_sema[LEFT]!=EATING
ffffffffc0204b42:	0045071b          	addiw	a4,a0,4
ffffffffc0204b46:	4595                	li	a1,5
ffffffffc0204b48:	02b7673b          	remw	a4,a4,a1
ffffffffc0204b4c:	4609                	li	a2,2
ffffffffc0204b4e:	070a                	slli	a4,a4,0x2
ffffffffc0204b50:	9736                	add	a4,a4,a3
ffffffffc0204b52:	4318                	lw	a4,0(a4)
ffffffffc0204b54:	fec706e3          	beq	a4,a2,ffffffffc0204b40 <phi_test_sema+0x16>
            &&state_sema[RIGHT]!=EATING)
ffffffffc0204b58:	0015071b          	addiw	a4,a0,1
ffffffffc0204b5c:	02b7673b          	remw	a4,a4,a1
ffffffffc0204b60:	070a                	slli	a4,a4,0x2
ffffffffc0204b62:	96ba                	add	a3,a3,a4
ffffffffc0204b64:	4298                	lw	a4,0(a3)
ffffffffc0204b66:	fcc70de3          	beq	a4,a2,ffffffffc0204b40 <phi_test_sema+0x16>
        up(&s[i]);
ffffffffc0204b6a:	00151713          	slli	a4,a0,0x1
ffffffffc0204b6e:	953a                	add	a0,a0,a4
ffffffffc0204b70:	050e                	slli	a0,a0,0x3
ffffffffc0204b72:	000db717          	auipc	a4,0xdb
ffffffffc0204b76:	96670713          	addi	a4,a4,-1690 # ffffffffc02df4d8 <s>
ffffffffc0204b7a:	953a                	add	a0,a0,a4
        state_sema[i]=EATING;
ffffffffc0204b7c:	c390                	sw	a2,0(a5)
        up(&s[i]);
ffffffffc0204b7e:	7840006f          	j	ffffffffc0205302 <up>

ffffffffc0204b82 <phi_take_forks_sema>:

void phi_take_forks_sema(int i) /* i：哲学家号码从0到N-1 */
{ 
ffffffffc0204b82:	1141                	addi	sp,sp,-16
ffffffffc0204b84:	e022                	sd	s0,0(sp)
ffffffffc0204b86:	842a                	mv	s0,a0
        down(&mutex); /* 进入临界区 */
ffffffffc0204b88:	000db517          	auipc	a0,0xdb
ffffffffc0204b8c:	8b850513          	addi	a0,a0,-1864 # ffffffffc02df440 <mutex>
{ 
ffffffffc0204b90:	e406                	sd	ra,8(sp)
        down(&mutex); /* 进入临界区 */
ffffffffc0204b92:	774000ef          	jal	ra,ffffffffc0205306 <down>
        state_sema[i]=HUNGRY; /* 记录下哲学家i饥饿的事实 */
ffffffffc0204b96:	00241713          	slli	a4,s0,0x2
ffffffffc0204b9a:	000db797          	auipc	a5,0xdb
ffffffffc0204b9e:	86678793          	addi	a5,a5,-1946 # ffffffffc02df400 <state_sema>
ffffffffc0204ba2:	97ba                	add	a5,a5,a4
        phi_test_sema(i); /* 试图得到两只叉子 */
ffffffffc0204ba4:	8522                	mv	a0,s0
        state_sema[i]=HUNGRY; /* 记录下哲学家i饥饿的事实 */
ffffffffc0204ba6:	4705                	li	a4,1
ffffffffc0204ba8:	c398                	sw	a4,0(a5)
        phi_test_sema(i); /* 试图得到两只叉子 */
ffffffffc0204baa:	f81ff0ef          	jal	ra,ffffffffc0204b2a <phi_test_sema>
        up(&mutex); /* 离开临界区 */
ffffffffc0204bae:	000db517          	auipc	a0,0xdb
ffffffffc0204bb2:	89250513          	addi	a0,a0,-1902 # ffffffffc02df440 <mutex>
ffffffffc0204bb6:	74c000ef          	jal	ra,ffffffffc0205302 <up>
        down(&s[i]); /* 如果得不到叉子就阻塞 */
ffffffffc0204bba:	00141793          	slli	a5,s0,0x1
ffffffffc0204bbe:	97a2                	add	a5,a5,s0
}
ffffffffc0204bc0:	6402                	ld	s0,0(sp)
ffffffffc0204bc2:	60a2                	ld	ra,8(sp)
        down(&s[i]); /* 如果得不到叉子就阻塞 */
ffffffffc0204bc4:	078e                	slli	a5,a5,0x3
ffffffffc0204bc6:	000db517          	auipc	a0,0xdb
ffffffffc0204bca:	91250513          	addi	a0,a0,-1774 # ffffffffc02df4d8 <s>
ffffffffc0204bce:	953e                	add	a0,a0,a5
}
ffffffffc0204bd0:	0141                	addi	sp,sp,16
        down(&s[i]); /* 如果得不到叉子就阻塞 */
ffffffffc0204bd2:	7340006f          	j	ffffffffc0205306 <down>

ffffffffc0204bd6 <phi_put_forks_sema>:

void phi_put_forks_sema(int i) /* i：哲学家号码从0到N-1 */
{ 
ffffffffc0204bd6:	1101                	addi	sp,sp,-32
ffffffffc0204bd8:	e822                	sd	s0,16(sp)
ffffffffc0204bda:	842a                	mv	s0,a0
        down(&mutex); /* 进入临界区 */
ffffffffc0204bdc:	000db517          	auipc	a0,0xdb
ffffffffc0204be0:	86450513          	addi	a0,a0,-1948 # ffffffffc02df440 <mutex>
{ 
ffffffffc0204be4:	ec06                	sd	ra,24(sp)
ffffffffc0204be6:	e426                	sd	s1,8(sp)
        down(&mutex); /* 进入临界区 */
ffffffffc0204be8:	71e000ef          	jal	ra,ffffffffc0205306 <down>
        state_sema[i]=THINKING; /* 哲学家进餐结束 */
        phi_test_sema(LEFT); /* 看一下左邻居现在是否能进餐 */
ffffffffc0204bec:	4495                	li	s1,5
ffffffffc0204bee:	0044051b          	addiw	a0,s0,4
ffffffffc0204bf2:	0295653b          	remw	a0,a0,s1
        state_sema[i]=THINKING; /* 哲学家进餐结束 */
ffffffffc0204bf6:	00241713          	slli	a4,s0,0x2
ffffffffc0204bfa:	000db797          	auipc	a5,0xdb
ffffffffc0204bfe:	80678793          	addi	a5,a5,-2042 # ffffffffc02df400 <state_sema>
ffffffffc0204c02:	97ba                	add	a5,a5,a4
ffffffffc0204c04:	0007a023          	sw	zero,0(a5)
        phi_test_sema(LEFT); /* 看一下左邻居现在是否能进餐 */
ffffffffc0204c08:	f23ff0ef          	jal	ra,ffffffffc0204b2a <phi_test_sema>
        phi_test_sema(RIGHT); /* 看一下右邻居现在是否能进餐 */
ffffffffc0204c0c:	0014051b          	addiw	a0,s0,1
ffffffffc0204c10:	0295653b          	remw	a0,a0,s1
ffffffffc0204c14:	f17ff0ef          	jal	ra,ffffffffc0204b2a <phi_test_sema>
        up(&mutex); /* 离开临界区 */
}
ffffffffc0204c18:	6442                	ld	s0,16(sp)
ffffffffc0204c1a:	60e2                	ld	ra,24(sp)
ffffffffc0204c1c:	64a2                	ld	s1,8(sp)
        up(&mutex); /* 离开临界区 */
ffffffffc0204c1e:	000db517          	auipc	a0,0xdb
ffffffffc0204c22:	82250513          	addi	a0,a0,-2014 # ffffffffc02df440 <mutex>
}
ffffffffc0204c26:	6105                	addi	sp,sp,32
        up(&mutex); /* 离开临界区 */
ffffffffc0204c28:	6da0006f          	j	ffffffffc0205302 <up>

ffffffffc0204c2c <philosopher_using_semaphore>:

int philosopher_using_semaphore(void * arg) /* i：哲学家号码，从0到N-1 */
{
ffffffffc0204c2c:	7179                	addi	sp,sp,-48
ffffffffc0204c2e:	ec26                	sd	s1,24(sp)
    int i, iter=0;
    i=(int)arg;
ffffffffc0204c30:	0005049b          	sext.w	s1,a0
    cprintf("I am No.%d philosopher_sema\n",i);
ffffffffc0204c34:	85a6                	mv	a1,s1
ffffffffc0204c36:	00005517          	auipc	a0,0x5
ffffffffc0204c3a:	82250513          	addi	a0,a0,-2014 # ffffffffc0209458 <default_pmm_manager+0x1220>
{
ffffffffc0204c3e:	f022                	sd	s0,32(sp)
ffffffffc0204c40:	e84a                	sd	s2,16(sp)
ffffffffc0204c42:	e44e                	sd	s3,8(sp)
ffffffffc0204c44:	e052                	sd	s4,0(sp)
ffffffffc0204c46:	f406                	sd	ra,40(sp)
    while(iter++<TIMES)
ffffffffc0204c48:	4405                	li	s0,1
    cprintf("I am No.%d philosopher_sema\n",i);
ffffffffc0204c4a:	d48fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    { /* 无限循环 */
        cprintf("Iter %d, No.%d philosopher_sema is thinking\n",iter,i); /* 哲学家正在思考 */
ffffffffc0204c4e:	00005a17          	auipc	s4,0x5
ffffffffc0204c52:	82aa0a13          	addi	s4,s4,-2006 # ffffffffc0209478 <default_pmm_manager+0x1240>
        do_sleep(SLEEP_TIME);
        phi_take_forks_sema(i); 
        /* 需要两只叉子，或者阻塞 */
        cprintf("Iter %d, No.%d philosopher_sema is eating\n",iter,i); /* 进餐 */
ffffffffc0204c56:	00005997          	auipc	s3,0x5
ffffffffc0204c5a:	85298993          	addi	s3,s3,-1966 # ffffffffc02094a8 <default_pmm_manager+0x1270>
    while(iter++<TIMES)
ffffffffc0204c5e:	4915                	li	s2,5
        cprintf("Iter %d, No.%d philosopher_sema is thinking\n",iter,i); /* 哲学家正在思考 */
ffffffffc0204c60:	85a2                	mv	a1,s0
ffffffffc0204c62:	8626                	mv	a2,s1
ffffffffc0204c64:	8552                	mv	a0,s4
ffffffffc0204c66:	d2cfb0ef          	jal	ra,ffffffffc0200192 <cprintf>
        do_sleep(SLEEP_TIME);
ffffffffc0204c6a:	4529                	li	a0,10
ffffffffc0204c6c:	46f010ef          	jal	ra,ffffffffc02068da <do_sleep>
        phi_take_forks_sema(i); 
ffffffffc0204c70:	8526                	mv	a0,s1
ffffffffc0204c72:	f11ff0ef          	jal	ra,ffffffffc0204b82 <phi_take_forks_sema>
        cprintf("Iter %d, No.%d philosopher_sema is eating\n",iter,i); /* 进餐 */
ffffffffc0204c76:	85a2                	mv	a1,s0
ffffffffc0204c78:	8626                	mv	a2,s1
ffffffffc0204c7a:	854e                	mv	a0,s3
ffffffffc0204c7c:	d16fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
        do_sleep(SLEEP_TIME);
ffffffffc0204c80:	4529                	li	a0,10
ffffffffc0204c82:	459010ef          	jal	ra,ffffffffc02068da <do_sleep>
    while(iter++<TIMES)
ffffffffc0204c86:	2405                	addiw	s0,s0,1
        phi_put_forks_sema(i); 
ffffffffc0204c88:	8526                	mv	a0,s1
ffffffffc0204c8a:	f4dff0ef          	jal	ra,ffffffffc0204bd6 <phi_put_forks_sema>
    while(iter++<TIMES)
ffffffffc0204c8e:	fd2419e3          	bne	s0,s2,ffffffffc0204c60 <philosopher_using_semaphore+0x34>
        /* 把两把叉子同时放回桌子 */
    }
    cprintf("No.%d philosopher_sema quit\n",i);
ffffffffc0204c92:	85a6                	mv	a1,s1
ffffffffc0204c94:	00005517          	auipc	a0,0x5
ffffffffc0204c98:	84450513          	addi	a0,a0,-1980 # ffffffffc02094d8 <default_pmm_manager+0x12a0>
ffffffffc0204c9c:	cf6fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    return 0;    
}
ffffffffc0204ca0:	70a2                	ld	ra,40(sp)
ffffffffc0204ca2:	7402                	ld	s0,32(sp)
ffffffffc0204ca4:	64e2                	ld	s1,24(sp)
ffffffffc0204ca6:	6942                	ld	s2,16(sp)
ffffffffc0204ca8:	69a2                	ld	s3,8(sp)
ffffffffc0204caa:	6a02                	ld	s4,0(sp)
ffffffffc0204cac:	4501                	li	a0,0
ffffffffc0204cae:	6145                	addi	sp,sp,48
ffffffffc0204cb0:	8082                	ret

ffffffffc0204cb2 <phi_test_condvar>:

struct proc_struct *philosopher_proc_condvar[N]; // N philosopher
int state_condvar[N];                            // the philosopher's state: EATING, HUNGARY, THINKING  
monitor_t mt, *mtp=&mt;                          // monitor

void phi_test_condvar (int i) { 
ffffffffc0204cb2:	7179                	addi	sp,sp,-48
ffffffffc0204cb4:	ec26                	sd	s1,24(sp)
    if(state_condvar[i]==HUNGRY&&state_condvar[LEFT]!=EATING
ffffffffc0204cb6:	000da717          	auipc	a4,0xda
ffffffffc0204cba:	7e270713          	addi	a4,a4,2018 # ffffffffc02df498 <state_condvar>
ffffffffc0204cbe:	00251493          	slli	s1,a0,0x2
void phi_test_condvar (int i) { 
ffffffffc0204cc2:	e84a                	sd	s2,16(sp)
    if(state_condvar[i]==HUNGRY&&state_condvar[LEFT]!=EATING
ffffffffc0204cc4:	00970933          	add	s2,a4,s1
ffffffffc0204cc8:	00092683          	lw	a3,0(s2)
void phi_test_condvar (int i) { 
ffffffffc0204ccc:	f406                	sd	ra,40(sp)
ffffffffc0204cce:	f022                	sd	s0,32(sp)
ffffffffc0204cd0:	e44e                	sd	s3,8(sp)
    if(state_condvar[i]==HUNGRY&&state_condvar[LEFT]!=EATING
ffffffffc0204cd2:	4785                	li	a5,1
ffffffffc0204cd4:	00f68963          	beq	a3,a5,ffffffffc0204ce6 <phi_test_condvar+0x34>
        cprintf("phi_test_condvar: state_condvar[%d] will eating\n",i);
        state_condvar[i] = EATING ;
        cprintf("phi_test_condvar: signal self_cv[%d] \n",i);
        cond_signal(&mtp->cv[i]) ;
    }
}
ffffffffc0204cd8:	70a2                	ld	ra,40(sp)
ffffffffc0204cda:	7402                	ld	s0,32(sp)
ffffffffc0204cdc:	64e2                	ld	s1,24(sp)
ffffffffc0204cde:	6942                	ld	s2,16(sp)
ffffffffc0204ce0:	69a2                	ld	s3,8(sp)
ffffffffc0204ce2:	6145                	addi	sp,sp,48
ffffffffc0204ce4:	8082                	ret
    if(state_condvar[i]==HUNGRY&&state_condvar[LEFT]!=EATING
ffffffffc0204ce6:	0045079b          	addiw	a5,a0,4
ffffffffc0204cea:	4695                	li	a3,5
ffffffffc0204cec:	02d7e7bb          	remw	a5,a5,a3
ffffffffc0204cf0:	4989                	li	s3,2
ffffffffc0204cf2:	078a                	slli	a5,a5,0x2
ffffffffc0204cf4:	97ba                	add	a5,a5,a4
ffffffffc0204cf6:	439c                	lw	a5,0(a5)
ffffffffc0204cf8:	ff3780e3          	beq	a5,s3,ffffffffc0204cd8 <phi_test_condvar+0x26>
            &&state_condvar[RIGHT]!=EATING) {
ffffffffc0204cfc:	0015079b          	addiw	a5,a0,1
ffffffffc0204d00:	02d7e7bb          	remw	a5,a5,a3
ffffffffc0204d04:	078a                	slli	a5,a5,0x2
ffffffffc0204d06:	973e                	add	a4,a4,a5
ffffffffc0204d08:	431c                	lw	a5,0(a4)
ffffffffc0204d0a:	fd3787e3          	beq	a5,s3,ffffffffc0204cd8 <phi_test_condvar+0x26>
        cprintf("phi_test_condvar: state_condvar[%d] will eating\n",i);
ffffffffc0204d0e:	842a                	mv	s0,a0
ffffffffc0204d10:	85aa                	mv	a1,a0
ffffffffc0204d12:	00004517          	auipc	a0,0x4
ffffffffc0204d16:	64650513          	addi	a0,a0,1606 # ffffffffc0209358 <default_pmm_manager+0x1120>
ffffffffc0204d1a:	c78fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
        cprintf("phi_test_condvar: signal self_cv[%d] \n",i);
ffffffffc0204d1e:	85a2                	mv	a1,s0
ffffffffc0204d20:	00004517          	auipc	a0,0x4
ffffffffc0204d24:	67050513          	addi	a0,a0,1648 # ffffffffc0209390 <default_pmm_manager+0x1158>
        state_condvar[i] = EATING ;
ffffffffc0204d28:	01392023          	sw	s3,0(s2)
        cprintf("phi_test_condvar: signal self_cv[%d] \n",i);
ffffffffc0204d2c:	c66fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
        cond_signal(&mtp->cv[i]) ;
ffffffffc0204d30:	000cf797          	auipc	a5,0xcf
ffffffffc0204d34:	11078793          	addi	a5,a5,272 # ffffffffc02d3e40 <mtp>
ffffffffc0204d38:	639c                	ld	a5,0(a5)
ffffffffc0204d3a:	00848533          	add	a0,s1,s0
}
ffffffffc0204d3e:	7402                	ld	s0,32(sp)
        cond_signal(&mtp->cv[i]) ;
ffffffffc0204d40:	7f9c                	ld	a5,56(a5)
}
ffffffffc0204d42:	70a2                	ld	ra,40(sp)
ffffffffc0204d44:	64e2                	ld	s1,24(sp)
ffffffffc0204d46:	6942                	ld	s2,16(sp)
ffffffffc0204d48:	69a2                	ld	s3,8(sp)
        cond_signal(&mtp->cv[i]) ;
ffffffffc0204d4a:	050e                	slli	a0,a0,0x3
ffffffffc0204d4c:	953e                	add	a0,a0,a5
}
ffffffffc0204d4e:	6145                	addi	sp,sp,48
        cond_signal(&mtp->cv[i]) ;
ffffffffc0204d50:	3940006f          	j	ffffffffc02050e4 <cond_signal>

ffffffffc0204d54 <phi_take_forks_condvar>:


void phi_take_forks_condvar(int i) {
ffffffffc0204d54:	7179                	addi	sp,sp,-48
ffffffffc0204d56:	ec26                	sd	s1,24(sp)
     down(&(mtp->mutex));
ffffffffc0204d58:	000cf497          	auipc	s1,0xcf
ffffffffc0204d5c:	0e848493          	addi	s1,s1,232 # ffffffffc02d3e40 <mtp>
void phi_take_forks_condvar(int i) {
ffffffffc0204d60:	e84a                	sd	s2,16(sp)
ffffffffc0204d62:	892a                	mv	s2,a0
     down(&(mtp->mutex));
ffffffffc0204d64:	6088                	ld	a0,0(s1)
void phi_take_forks_condvar(int i) {
ffffffffc0204d66:	f406                	sd	ra,40(sp)
ffffffffc0204d68:	f022                	sd	s0,32(sp)
ffffffffc0204d6a:	e44e                	sd	s3,8(sp)
//--------into routine in monitor--------------
     // LAB7 EXERCISE: YOUR CODE
     // I am hungry
     // try to get fork
    state_condvar[i] = HUNGRY;
ffffffffc0204d6c:	000da417          	auipc	s0,0xda
ffffffffc0204d70:	72c40413          	addi	s0,s0,1836 # ffffffffc02df498 <state_condvar>
     down(&(mtp->mutex));
ffffffffc0204d74:	592000ef          	jal	ra,ffffffffc0205306 <down>
    state_condvar[i] = HUNGRY;
ffffffffc0204d78:	00291993          	slli	s3,s2,0x2
ffffffffc0204d7c:	4785                	li	a5,1
ffffffffc0204d7e:	944e                	add	s0,s0,s3
    phi_test_condvar(i);
ffffffffc0204d80:	854a                	mv	a0,s2
    state_condvar[i] = HUNGRY;
ffffffffc0204d82:	c01c                	sw	a5,0(s0)
    phi_test_condvar(i);
ffffffffc0204d84:	f2fff0ef          	jal	ra,ffffffffc0204cb2 <phi_test_condvar>
    if(state_condvar[i] == HUNGRY)
ffffffffc0204d88:	4018                	lw	a4,0(s0)
ffffffffc0204d8a:	4785                	li	a5,1
ffffffffc0204d8c:	00f70f63          	beq	a4,a5,ffffffffc0204daa <phi_take_forks_condvar+0x56>
        cond_wait(&mtp->cv[i]);

//--------leave routine in monitor--------------
      if(mtp->next_count>0)
ffffffffc0204d90:	6088                	ld	a0,0(s1)
ffffffffc0204d92:	591c                	lw	a5,48(a0)
ffffffffc0204d94:	00f05363          	blez	a5,ffffffffc0204d9a <phi_take_forks_condvar+0x46>
         up(&(mtp->next));
ffffffffc0204d98:	0561                	addi	a0,a0,24
      else
         up(&(mtp->mutex));
}
ffffffffc0204d9a:	7402                	ld	s0,32(sp)
ffffffffc0204d9c:	70a2                	ld	ra,40(sp)
ffffffffc0204d9e:	64e2                	ld	s1,24(sp)
ffffffffc0204da0:	6942                	ld	s2,16(sp)
ffffffffc0204da2:	69a2                	ld	s3,8(sp)
ffffffffc0204da4:	6145                	addi	sp,sp,48
         up(&(mtp->mutex));
ffffffffc0204da6:	55c0006f          	j	ffffffffc0205302 <up>
        cond_wait(&mtp->cv[i]);
ffffffffc0204daa:	609c                	ld	a5,0(s1)
ffffffffc0204dac:	994e                	add	s2,s2,s3
ffffffffc0204dae:	090e                	slli	s2,s2,0x3
ffffffffc0204db0:	7f88                	ld	a0,56(a5)
ffffffffc0204db2:	954a                	add	a0,a0,s2
ffffffffc0204db4:	3a0000ef          	jal	ra,ffffffffc0205154 <cond_wait>
ffffffffc0204db8:	bfe1                	j	ffffffffc0204d90 <phi_take_forks_condvar+0x3c>

ffffffffc0204dba <phi_put_forks_condvar>:

void phi_put_forks_condvar(int i) {
ffffffffc0204dba:	1101                	addi	sp,sp,-32
ffffffffc0204dbc:	e426                	sd	s1,8(sp)
     down(&(mtp->mutex));
ffffffffc0204dbe:	000cf497          	auipc	s1,0xcf
ffffffffc0204dc2:	08248493          	addi	s1,s1,130 # ffffffffc02d3e40 <mtp>
void phi_put_forks_condvar(int i) {
ffffffffc0204dc6:	e822                	sd	s0,16(sp)
ffffffffc0204dc8:	842a                	mv	s0,a0
     down(&(mtp->mutex));
ffffffffc0204dca:	6088                	ld	a0,0(s1)
void phi_put_forks_condvar(int i) {
ffffffffc0204dcc:	ec06                	sd	ra,24(sp)
ffffffffc0204dce:	e04a                	sd	s2,0(sp)
     down(&(mtp->mutex));
ffffffffc0204dd0:	536000ef          	jal	ra,ffffffffc0205306 <down>
//--------into routine in monitor--------------
     // LAB7 EXERCISE: YOUR CODE
     // I ate over
     // test left and right neighbors
    state_condvar[i] = THINKING;
    phi_test_condvar(LEFT);
ffffffffc0204dd4:	4915                	li	s2,5
ffffffffc0204dd6:	0044051b          	addiw	a0,s0,4
ffffffffc0204dda:	0325653b          	remw	a0,a0,s2
    state_condvar[i] = THINKING;
ffffffffc0204dde:	00241713          	slli	a4,s0,0x2
ffffffffc0204de2:	000da797          	auipc	a5,0xda
ffffffffc0204de6:	6b678793          	addi	a5,a5,1718 # ffffffffc02df498 <state_condvar>
ffffffffc0204dea:	97ba                	add	a5,a5,a4
ffffffffc0204dec:	0007a023          	sw	zero,0(a5)
    phi_test_condvar(LEFT);
ffffffffc0204df0:	ec3ff0ef          	jal	ra,ffffffffc0204cb2 <phi_test_condvar>
    phi_test_condvar(RIGHT);
ffffffffc0204df4:	0014051b          	addiw	a0,s0,1
ffffffffc0204df8:	0325653b          	remw	a0,a0,s2
ffffffffc0204dfc:	eb7ff0ef          	jal	ra,ffffffffc0204cb2 <phi_test_condvar>

//--------leave routine in monitor--------------
     if(mtp->next_count>0)
ffffffffc0204e00:	6088                	ld	a0,0(s1)
ffffffffc0204e02:	591c                	lw	a5,48(a0)
ffffffffc0204e04:	00f05363          	blez	a5,ffffffffc0204e0a <phi_put_forks_condvar+0x50>
        up(&(mtp->next));
ffffffffc0204e08:	0561                	addi	a0,a0,24
     else
        up(&(mtp->mutex));
}
ffffffffc0204e0a:	6442                	ld	s0,16(sp)
ffffffffc0204e0c:	60e2                	ld	ra,24(sp)
ffffffffc0204e0e:	64a2                	ld	s1,8(sp)
ffffffffc0204e10:	6902                	ld	s2,0(sp)
ffffffffc0204e12:	6105                	addi	sp,sp,32
        up(&(mtp->mutex));
ffffffffc0204e14:	4ee0006f          	j	ffffffffc0205302 <up>

ffffffffc0204e18 <philosopher_using_condvar>:

//---------- philosophers using monitor (condition variable) ----------------------
int philosopher_using_condvar(void * arg) { /* arg is the No. of philosopher 0~N-1*/
ffffffffc0204e18:	7179                	addi	sp,sp,-48
ffffffffc0204e1a:	ec26                	sd	s1,24(sp)
  
    int i, iter=0;
    i=(int)arg;
ffffffffc0204e1c:	0005049b          	sext.w	s1,a0
    cprintf("I am No.%d philosopher_condvar\n",i);
ffffffffc0204e20:	85a6                	mv	a1,s1
ffffffffc0204e22:	00004517          	auipc	a0,0x4
ffffffffc0204e26:	59650513          	addi	a0,a0,1430 # ffffffffc02093b8 <default_pmm_manager+0x1180>
int philosopher_using_condvar(void * arg) { /* arg is the No. of philosopher 0~N-1*/
ffffffffc0204e2a:	f022                	sd	s0,32(sp)
ffffffffc0204e2c:	e84a                	sd	s2,16(sp)
ffffffffc0204e2e:	e44e                	sd	s3,8(sp)
ffffffffc0204e30:	e052                	sd	s4,0(sp)
ffffffffc0204e32:	f406                	sd	ra,40(sp)
    while(iter++<TIMES)
ffffffffc0204e34:	4405                	li	s0,1
    cprintf("I am No.%d philosopher_condvar\n",i);
ffffffffc0204e36:	b5cfb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    { /* iterate*/
        cprintf("Iter %d, No.%d philosopher_condvar is thinking\n",iter,i); /* thinking*/
ffffffffc0204e3a:	00004a17          	auipc	s4,0x4
ffffffffc0204e3e:	59ea0a13          	addi	s4,s4,1438 # ffffffffc02093d8 <default_pmm_manager+0x11a0>
        do_sleep(SLEEP_TIME);
        phi_take_forks_condvar(i); 
        /* need two forks, maybe blocked */
        cprintf("Iter %d, No.%d philosopher_condvar is eating\n",iter,i); /* eating*/
ffffffffc0204e42:	00004997          	auipc	s3,0x4
ffffffffc0204e46:	5c698993          	addi	s3,s3,1478 # ffffffffc0209408 <default_pmm_manager+0x11d0>
    while(iter++<TIMES)
ffffffffc0204e4a:	4915                	li	s2,5
        cprintf("Iter %d, No.%d philosopher_condvar is thinking\n",iter,i); /* thinking*/
ffffffffc0204e4c:	85a2                	mv	a1,s0
ffffffffc0204e4e:	8626                	mv	a2,s1
ffffffffc0204e50:	8552                	mv	a0,s4
ffffffffc0204e52:	b40fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
        do_sleep(SLEEP_TIME);
ffffffffc0204e56:	4529                	li	a0,10
ffffffffc0204e58:	283010ef          	jal	ra,ffffffffc02068da <do_sleep>
        phi_take_forks_condvar(i); 
ffffffffc0204e5c:	8526                	mv	a0,s1
ffffffffc0204e5e:	ef7ff0ef          	jal	ra,ffffffffc0204d54 <phi_take_forks_condvar>
        cprintf("Iter %d, No.%d philosopher_condvar is eating\n",iter,i); /* eating*/
ffffffffc0204e62:	85a2                	mv	a1,s0
ffffffffc0204e64:	8626                	mv	a2,s1
ffffffffc0204e66:	854e                	mv	a0,s3
ffffffffc0204e68:	b2afb0ef          	jal	ra,ffffffffc0200192 <cprintf>
        do_sleep(SLEEP_TIME);
ffffffffc0204e6c:	4529                	li	a0,10
ffffffffc0204e6e:	26d010ef          	jal	ra,ffffffffc02068da <do_sleep>
    while(iter++<TIMES)
ffffffffc0204e72:	2405                	addiw	s0,s0,1
        phi_put_forks_condvar(i); 
ffffffffc0204e74:	8526                	mv	a0,s1
ffffffffc0204e76:	f45ff0ef          	jal	ra,ffffffffc0204dba <phi_put_forks_condvar>
    while(iter++<TIMES)
ffffffffc0204e7a:	fd2419e3          	bne	s0,s2,ffffffffc0204e4c <philosopher_using_condvar+0x34>
        /* return two forks back*/
    }
    cprintf("No.%d philosopher_condvar quit\n",i);
ffffffffc0204e7e:	85a6                	mv	a1,s1
ffffffffc0204e80:	00004517          	auipc	a0,0x4
ffffffffc0204e84:	5b850513          	addi	a0,a0,1464 # ffffffffc0209438 <default_pmm_manager+0x1200>
ffffffffc0204e88:	b0afb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    return 0;    
}
ffffffffc0204e8c:	70a2                	ld	ra,40(sp)
ffffffffc0204e8e:	7402                	ld	s0,32(sp)
ffffffffc0204e90:	64e2                	ld	s1,24(sp)
ffffffffc0204e92:	6942                	ld	s2,16(sp)
ffffffffc0204e94:	69a2                	ld	s3,8(sp)
ffffffffc0204e96:	6a02                	ld	s4,0(sp)
ffffffffc0204e98:	4501                	li	a0,0
ffffffffc0204e9a:	6145                	addi	sp,sp,48
ffffffffc0204e9c:	8082                	ret

ffffffffc0204e9e <check_sync>:

void check_sync(void){
ffffffffc0204e9e:	7159                	addi	sp,sp,-112
ffffffffc0204ea0:	f0a2                	sd	s0,96(sp)

    int i, pids[N];

    //check semaphore
    sem_init(&mutex, 1);
ffffffffc0204ea2:	4585                	li	a1,1
ffffffffc0204ea4:	000da517          	auipc	a0,0xda
ffffffffc0204ea8:	59c50513          	addi	a0,a0,1436 # ffffffffc02df440 <mutex>
ffffffffc0204eac:	0020                	addi	s0,sp,8
void check_sync(void){
ffffffffc0204eae:	eca6                	sd	s1,88(sp)
ffffffffc0204eb0:	e8ca                	sd	s2,80(sp)
ffffffffc0204eb2:	e4ce                	sd	s3,72(sp)
ffffffffc0204eb4:	e0d2                	sd	s4,64(sp)
ffffffffc0204eb6:	fc56                	sd	s5,56(sp)
ffffffffc0204eb8:	f85a                	sd	s6,48(sp)
ffffffffc0204eba:	f45e                	sd	s7,40(sp)
ffffffffc0204ebc:	f486                	sd	ra,104(sp)
ffffffffc0204ebe:	f062                	sd	s8,32(sp)
ffffffffc0204ec0:	000daa17          	auipc	s4,0xda
ffffffffc0204ec4:	618a0a13          	addi	s4,s4,1560 # ffffffffc02df4d8 <s>
    sem_init(&mutex, 1);
ffffffffc0204ec8:	432000ef          	jal	ra,ffffffffc02052fa <sem_init>
    for(i=0;i<N;i++){
ffffffffc0204ecc:	000da997          	auipc	s3,0xda
ffffffffc0204ed0:	5e498993          	addi	s3,s3,1508 # ffffffffc02df4b0 <philosopher_proc_sema>
    sem_init(&mutex, 1);
ffffffffc0204ed4:	8922                	mv	s2,s0
ffffffffc0204ed6:	4481                	li	s1,0
        sem_init(&s[i], 0);
        int pid = kernel_thread(philosopher_using_semaphore, (void *)i, 0);
ffffffffc0204ed8:	00000b97          	auipc	s7,0x0
ffffffffc0204edc:	d54b8b93          	addi	s7,s7,-684 # ffffffffc0204c2c <philosopher_using_semaphore>
        if (pid <= 0) {
            panic("create No.%d philosopher_using_semaphore failed.\n");
        }
        pids[i] = pid;
        philosopher_proc_sema[i] = find_proc(pid);
        set_proc_name(philosopher_proc_sema[i], "philosopher_sema_proc");
ffffffffc0204ee0:	00004b17          	auipc	s6,0x4
ffffffffc0204ee4:	3f0b0b13          	addi	s6,s6,1008 # ffffffffc02092d0 <default_pmm_manager+0x1098>
    for(i=0;i<N;i++){
ffffffffc0204ee8:	4a95                	li	s5,5
        sem_init(&s[i], 0);
ffffffffc0204eea:	4581                	li	a1,0
ffffffffc0204eec:	8552                	mv	a0,s4
ffffffffc0204eee:	40c000ef          	jal	ra,ffffffffc02052fa <sem_init>
        int pid = kernel_thread(philosopher_using_semaphore, (void *)i, 0);
ffffffffc0204ef2:	4601                	li	a2,0
ffffffffc0204ef4:	85a6                	mv	a1,s1
ffffffffc0204ef6:	855e                	mv	a0,s7
ffffffffc0204ef8:	531000ef          	jal	ra,ffffffffc0205c28 <kernel_thread>
        if (pid <= 0) {
ffffffffc0204efc:	0ca05963          	blez	a0,ffffffffc0204fce <check_sync+0x130>
        pids[i] = pid;
ffffffffc0204f00:	00a92023          	sw	a0,0(s2)
        philosopher_proc_sema[i] = find_proc(pid);
ffffffffc0204f04:	0db000ef          	jal	ra,ffffffffc02057de <find_proc>
ffffffffc0204f08:	00a9b023          	sd	a0,0(s3)
        set_proc_name(philosopher_proc_sema[i], "philosopher_sema_proc");
ffffffffc0204f0c:	85da                	mv	a1,s6
ffffffffc0204f0e:	0485                	addi	s1,s1,1
ffffffffc0204f10:	0a61                	addi	s4,s4,24
ffffffffc0204f12:	037000ef          	jal	ra,ffffffffc0205748 <set_proc_name>
ffffffffc0204f16:	0911                	addi	s2,s2,4
ffffffffc0204f18:	09a1                	addi	s3,s3,8
    for(i=0;i<N;i++){
ffffffffc0204f1a:	fd5498e3          	bne	s1,s5,ffffffffc0204eea <check_sync+0x4c>
ffffffffc0204f1e:	01440a93          	addi	s5,s0,20
ffffffffc0204f22:	84a2                	mv	s1,s0
    }
    for (i=0;i<N;i++)
        assert(do_wait(pids[i],NULL) == 0);
ffffffffc0204f24:	4088                	lw	a0,0(s1)
ffffffffc0204f26:	4581                	li	a1,0
ffffffffc0204f28:	788010ef          	jal	ra,ffffffffc02066b0 <do_wait>
ffffffffc0204f2c:	0e051963          	bnez	a0,ffffffffc020501e <check_sync+0x180>
ffffffffc0204f30:	0491                	addi	s1,s1,4
    for (i=0;i<N;i++)
ffffffffc0204f32:	ff5499e3          	bne	s1,s5,ffffffffc0204f24 <check_sync+0x86>

    //check condition variable
    monitor_init(&mt, N);
ffffffffc0204f36:	4595                	li	a1,5
ffffffffc0204f38:	000da517          	auipc	a0,0xda
ffffffffc0204f3c:	52050513          	addi	a0,a0,1312 # ffffffffc02df458 <mt>
ffffffffc0204f40:	0fe000ef          	jal	ra,ffffffffc020503e <monitor_init>
    for(i=0;i<N;i++){
ffffffffc0204f44:	000da917          	auipc	s2,0xda
ffffffffc0204f48:	55490913          	addi	s2,s2,1364 # ffffffffc02df498 <state_condvar>
ffffffffc0204f4c:	000daa17          	auipc	s4,0xda
ffffffffc0204f50:	4cca0a13          	addi	s4,s4,1228 # ffffffffc02df418 <philosopher_proc_condvar>
    monitor_init(&mt, N);
ffffffffc0204f54:	89a2                	mv	s3,s0
ffffffffc0204f56:	4481                	li	s1,0
        state_condvar[i]=THINKING;
        int pid = kernel_thread(philosopher_using_condvar, (void *)i, 0);
ffffffffc0204f58:	00000b17          	auipc	s6,0x0
ffffffffc0204f5c:	ec0b0b13          	addi	s6,s6,-320 # ffffffffc0204e18 <philosopher_using_condvar>
        if (pid <= 0) {
            panic("create No.%d philosopher_using_condvar failed.\n");
        }
        pids[i] = pid;
        philosopher_proc_condvar[i] = find_proc(pid);
        set_proc_name(philosopher_proc_condvar[i], "philosopher_condvar_proc");
ffffffffc0204f60:	00004c17          	auipc	s8,0x4
ffffffffc0204f64:	3d8c0c13          	addi	s8,s8,984 # ffffffffc0209338 <default_pmm_manager+0x1100>
    for(i=0;i<N;i++){
ffffffffc0204f68:	4b95                	li	s7,5
        int pid = kernel_thread(philosopher_using_condvar, (void *)i, 0);
ffffffffc0204f6a:	4601                	li	a2,0
ffffffffc0204f6c:	85a6                	mv	a1,s1
ffffffffc0204f6e:	855a                	mv	a0,s6
        state_condvar[i]=THINKING;
ffffffffc0204f70:	00092023          	sw	zero,0(s2)
        int pid = kernel_thread(philosopher_using_condvar, (void *)i, 0);
ffffffffc0204f74:	4b5000ef          	jal	ra,ffffffffc0205c28 <kernel_thread>
        if (pid <= 0) {
ffffffffc0204f78:	08a05763          	blez	a0,ffffffffc0205006 <check_sync+0x168>
        pids[i] = pid;
ffffffffc0204f7c:	00a9a023          	sw	a0,0(s3)
        philosopher_proc_condvar[i] = find_proc(pid);
ffffffffc0204f80:	05f000ef          	jal	ra,ffffffffc02057de <find_proc>
ffffffffc0204f84:	00aa3023          	sd	a0,0(s4)
        set_proc_name(philosopher_proc_condvar[i], "philosopher_condvar_proc");
ffffffffc0204f88:	85e2                	mv	a1,s8
ffffffffc0204f8a:	0485                	addi	s1,s1,1
ffffffffc0204f8c:	0911                	addi	s2,s2,4
ffffffffc0204f8e:	7ba000ef          	jal	ra,ffffffffc0205748 <set_proc_name>
ffffffffc0204f92:	0991                	addi	s3,s3,4
ffffffffc0204f94:	0a21                	addi	s4,s4,8
    for(i=0;i<N;i++){
ffffffffc0204f96:	fd749ae3          	bne	s1,s7,ffffffffc0204f6a <check_sync+0xcc>
    }
    for (i=0;i<N;i++)
        assert(do_wait(pids[i],NULL) == 0);
ffffffffc0204f9a:	4008                	lw	a0,0(s0)
ffffffffc0204f9c:	4581                	li	a1,0
ffffffffc0204f9e:	712010ef          	jal	ra,ffffffffc02066b0 <do_wait>
ffffffffc0204fa2:	e131                	bnez	a0,ffffffffc0204fe6 <check_sync+0x148>
ffffffffc0204fa4:	0411                	addi	s0,s0,4
    for (i=0;i<N;i++)
ffffffffc0204fa6:	ff541ae3          	bne	s0,s5,ffffffffc0204f9a <check_sync+0xfc>
    monitor_free(&mt, N);
}
ffffffffc0204faa:	7406                	ld	s0,96(sp)
ffffffffc0204fac:	70a6                	ld	ra,104(sp)
ffffffffc0204fae:	64e6                	ld	s1,88(sp)
ffffffffc0204fb0:	6946                	ld	s2,80(sp)
ffffffffc0204fb2:	69a6                	ld	s3,72(sp)
ffffffffc0204fb4:	6a06                	ld	s4,64(sp)
ffffffffc0204fb6:	7ae2                	ld	s5,56(sp)
ffffffffc0204fb8:	7b42                	ld	s6,48(sp)
ffffffffc0204fba:	7ba2                	ld	s7,40(sp)
ffffffffc0204fbc:	7c02                	ld	s8,32(sp)
    monitor_free(&mt, N);
ffffffffc0204fbe:	4595                	li	a1,5
ffffffffc0204fc0:	000da517          	auipc	a0,0xda
ffffffffc0204fc4:	49850513          	addi	a0,a0,1176 # ffffffffc02df458 <mt>
}
ffffffffc0204fc8:	6165                	addi	sp,sp,112
    monitor_free(&mt, N);
ffffffffc0204fca:	1140006f          	j	ffffffffc02050de <monitor_free>
            panic("create No.%d philosopher_using_semaphore failed.\n");
ffffffffc0204fce:	00004617          	auipc	a2,0x4
ffffffffc0204fd2:	2b260613          	addi	a2,a2,690 # ffffffffc0209280 <default_pmm_manager+0x1048>
ffffffffc0204fd6:	0f800593          	li	a1,248
ffffffffc0204fda:	00004517          	auipc	a0,0x4
ffffffffc0204fde:	2de50513          	addi	a0,a0,734 # ffffffffc02092b8 <default_pmm_manager+0x1080>
ffffffffc0204fe2:	ca6fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(do_wait(pids[i],NULL) == 0);
ffffffffc0204fe6:	00004697          	auipc	a3,0x4
ffffffffc0204fea:	30268693          	addi	a3,a3,770 # ffffffffc02092e8 <default_pmm_manager+0x10b0>
ffffffffc0204fee:	00003617          	auipc	a2,0x3
ffffffffc0204ff2:	b0260613          	addi	a2,a2,-1278 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0204ff6:	10e00593          	li	a1,270
ffffffffc0204ffa:	00004517          	auipc	a0,0x4
ffffffffc0204ffe:	2be50513          	addi	a0,a0,702 # ffffffffc02092b8 <default_pmm_manager+0x1080>
ffffffffc0205002:	c86fb0ef          	jal	ra,ffffffffc0200488 <__panic>
            panic("create No.%d philosopher_using_condvar failed.\n");
ffffffffc0205006:	00004617          	auipc	a2,0x4
ffffffffc020500a:	30260613          	addi	a2,a2,770 # ffffffffc0209308 <default_pmm_manager+0x10d0>
ffffffffc020500e:	10700593          	li	a1,263
ffffffffc0205012:	00004517          	auipc	a0,0x4
ffffffffc0205016:	2a650513          	addi	a0,a0,678 # ffffffffc02092b8 <default_pmm_manager+0x1080>
ffffffffc020501a:	c6efb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(do_wait(pids[i],NULL) == 0);
ffffffffc020501e:	00004697          	auipc	a3,0x4
ffffffffc0205022:	2ca68693          	addi	a3,a3,714 # ffffffffc02092e8 <default_pmm_manager+0x10b0>
ffffffffc0205026:	00003617          	auipc	a2,0x3
ffffffffc020502a:	aca60613          	addi	a2,a2,-1334 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020502e:	0ff00593          	li	a1,255
ffffffffc0205032:	00004517          	auipc	a0,0x4
ffffffffc0205036:	28650513          	addi	a0,a0,646 # ffffffffc02092b8 <default_pmm_manager+0x1080>
ffffffffc020503a:	c4efb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020503e <monitor_init>:
#include <assert.h>


// Initialize monitor.
void     
monitor_init (monitor_t * mtp, size_t num_cv) {
ffffffffc020503e:	1101                	addi	sp,sp,-32
ffffffffc0205040:	ec06                	sd	ra,24(sp)
ffffffffc0205042:	e822                	sd	s0,16(sp)
ffffffffc0205044:	e426                	sd	s1,8(sp)
ffffffffc0205046:	e04a                	sd	s2,0(sp)
    int i;
    assert(num_cv>0);
ffffffffc0205048:	cda9                	beqz	a1,ffffffffc02050a2 <monitor_init+0x64>
    mtp->next_count = 0;
ffffffffc020504a:	842e                	mv	s0,a1
ffffffffc020504c:	02052823          	sw	zero,48(a0)
    mtp->cv = NULL;
    sem_init(&(mtp->mutex), 1); //unlocked
ffffffffc0205050:	4585                	li	a1,1
    mtp->cv = NULL;
ffffffffc0205052:	02053c23          	sd	zero,56(a0)
    sem_init(&(mtp->mutex), 1); //unlocked
ffffffffc0205056:	84aa                	mv	s1,a0
    sem_init(&(mtp->next), 0);
    mtp->cv =(condvar_t *) kmalloc(sizeof(condvar_t)*num_cv);
ffffffffc0205058:	00241913          	slli	s2,s0,0x2
    sem_init(&(mtp->mutex), 1); //unlocked
ffffffffc020505c:	29e000ef          	jal	ra,ffffffffc02052fa <sem_init>
    sem_init(&(mtp->next), 0);
ffffffffc0205060:	4581                	li	a1,0
ffffffffc0205062:	01848513          	addi	a0,s1,24
    mtp->cv =(condvar_t *) kmalloc(sizeof(condvar_t)*num_cv);
ffffffffc0205066:	9922                	add	s2,s2,s0
    sem_init(&(mtp->next), 0);
ffffffffc0205068:	292000ef          	jal	ra,ffffffffc02052fa <sem_init>
    mtp->cv =(condvar_t *) kmalloc(sizeof(condvar_t)*num_cv);
ffffffffc020506c:	090e                	slli	s2,s2,0x3
ffffffffc020506e:	854a                	mv	a0,s2
ffffffffc0205070:	bc7fc0ef          	jal	ra,ffffffffc0201c36 <kmalloc>
ffffffffc0205074:	fc88                	sd	a0,56(s1)
    assert(mtp->cv!=NULL);
ffffffffc0205076:	4401                	li	s0,0
ffffffffc0205078:	c521                	beqz	a0,ffffffffc02050c0 <monitor_init+0x82>
    for(i=0; i<num_cv; i++){
        mtp->cv[i].count=0;
ffffffffc020507a:	9522                	add	a0,a0,s0
ffffffffc020507c:	00052c23          	sw	zero,24(a0)
        sem_init(&(mtp->cv[i].sem),0);
ffffffffc0205080:	4581                	li	a1,0
ffffffffc0205082:	278000ef          	jal	ra,ffffffffc02052fa <sem_init>
        mtp->cv[i].owner=mtp;
ffffffffc0205086:	7c88                	ld	a0,56(s1)
ffffffffc0205088:	008507b3          	add	a5,a0,s0
ffffffffc020508c:	f384                	sd	s1,32(a5)
ffffffffc020508e:	02840413          	addi	s0,s0,40
    for(i=0; i<num_cv; i++){
ffffffffc0205092:	fe8914e3          	bne	s2,s0,ffffffffc020507a <monitor_init+0x3c>
    }
}
ffffffffc0205096:	60e2                	ld	ra,24(sp)
ffffffffc0205098:	6442                	ld	s0,16(sp)
ffffffffc020509a:	64a2                	ld	s1,8(sp)
ffffffffc020509c:	6902                	ld	s2,0(sp)
ffffffffc020509e:	6105                	addi	sp,sp,32
ffffffffc02050a0:	8082                	ret
    assert(num_cv>0);
ffffffffc02050a2:	00004697          	auipc	a3,0x4
ffffffffc02050a6:	57668693          	addi	a3,a3,1398 # ffffffffc0209618 <default_pmm_manager+0x13e0>
ffffffffc02050aa:	00003617          	auipc	a2,0x3
ffffffffc02050ae:	a4660613          	addi	a2,a2,-1466 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02050b2:	45ad                	li	a1,11
ffffffffc02050b4:	00004517          	auipc	a0,0x4
ffffffffc02050b8:	57450513          	addi	a0,a0,1396 # ffffffffc0209628 <default_pmm_manager+0x13f0>
ffffffffc02050bc:	bccfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(mtp->cv!=NULL);
ffffffffc02050c0:	00004697          	auipc	a3,0x4
ffffffffc02050c4:	58068693          	addi	a3,a3,1408 # ffffffffc0209640 <default_pmm_manager+0x1408>
ffffffffc02050c8:	00003617          	auipc	a2,0x3
ffffffffc02050cc:	a2860613          	addi	a2,a2,-1496 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02050d0:	45c5                	li	a1,17
ffffffffc02050d2:	00004517          	auipc	a0,0x4
ffffffffc02050d6:	55650513          	addi	a0,a0,1366 # ffffffffc0209628 <default_pmm_manager+0x13f0>
ffffffffc02050da:	baefb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02050de <monitor_free>:

// Free monitor.
void
monitor_free (monitor_t * mtp, size_t num_cv) {
    kfree(mtp->cv);
ffffffffc02050de:	7d08                	ld	a0,56(a0)
ffffffffc02050e0:	c13fc06f          	j	ffffffffc0201cf2 <kfree>

ffffffffc02050e4 <cond_signal>:

// Unlock one of threads waiting on the condition variable. 
void 
cond_signal (condvar_t *cvp) {
   //LAB7 EXERCISE: YOUR CODE
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc02050e4:	711c                	ld	a5,32(a0)
ffffffffc02050e6:	4d10                	lw	a2,24(a0)
cond_signal (condvar_t *cvp) {
ffffffffc02050e8:	1141                	addi	sp,sp,-16
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc02050ea:	5b94                	lw	a3,48(a5)
cond_signal (condvar_t *cvp) {
ffffffffc02050ec:	e022                	sd	s0,0(sp)
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc02050ee:	85aa                	mv	a1,a0
cond_signal (condvar_t *cvp) {
ffffffffc02050f0:	842a                	mv	s0,a0
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc02050f2:	00004517          	auipc	a0,0x4
ffffffffc02050f6:	40650513          	addi	a0,a0,1030 # ffffffffc02094f8 <default_pmm_manager+0x12c0>
cond_signal (condvar_t *cvp) {
ffffffffc02050fa:	e406                	sd	ra,8(sp)
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc02050fc:	896fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
   *             wait(mt.next);
   *             mt.next_count--;
   *          }
   *       }
   */
    if(cvp->count > 0) {
ffffffffc0205100:	4c10                	lw	a2,24(s0)
ffffffffc0205102:	00c04e63          	bgtz	a2,ffffffffc020511e <cond_signal+0x3a>
ffffffffc0205106:	701c                	ld	a5,32(s0)
        cvp->owner->next_count ++;
        up(&(cvp->sem));
        down(&(cvp->owner->next));
        cvp->owner->next_count --;
    }
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0205108:	85a2                	mv	a1,s0
}
ffffffffc020510a:	6402                	ld	s0,0(sp)
ffffffffc020510c:	60a2                	ld	ra,8(sp)
ffffffffc020510e:	5b94                	lw	a3,48(a5)
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0205110:	00004517          	auipc	a0,0x4
ffffffffc0205114:	43050513          	addi	a0,a0,1072 # ffffffffc0209540 <default_pmm_manager+0x1308>
}
ffffffffc0205118:	0141                	addi	sp,sp,16
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc020511a:	878fb06f          	j	ffffffffc0200192 <cprintf>
        cvp->owner->next_count ++;
ffffffffc020511e:	7018                	ld	a4,32(s0)
        up(&(cvp->sem));
ffffffffc0205120:	8522                	mv	a0,s0
        cvp->owner->next_count ++;
ffffffffc0205122:	5b1c                	lw	a5,48(a4)
ffffffffc0205124:	2785                	addiw	a5,a5,1
ffffffffc0205126:	db1c                	sw	a5,48(a4)
        up(&(cvp->sem));
ffffffffc0205128:	1da000ef          	jal	ra,ffffffffc0205302 <up>
        down(&(cvp->owner->next));
ffffffffc020512c:	7008                	ld	a0,32(s0)
ffffffffc020512e:	0561                	addi	a0,a0,24
ffffffffc0205130:	1d6000ef          	jal	ra,ffffffffc0205306 <down>
        cvp->owner->next_count --;
ffffffffc0205134:	7018                	ld	a4,32(s0)
ffffffffc0205136:	4c10                	lw	a2,24(s0)
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0205138:	85a2                	mv	a1,s0
        cvp->owner->next_count --;
ffffffffc020513a:	5b1c                	lw	a5,48(a4)
}
ffffffffc020513c:	6402                	ld	s0,0(sp)
ffffffffc020513e:	60a2                	ld	ra,8(sp)
        cvp->owner->next_count --;
ffffffffc0205140:	fff7869b          	addiw	a3,a5,-1
ffffffffc0205144:	db14                	sw	a3,48(a4)
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0205146:	00004517          	auipc	a0,0x4
ffffffffc020514a:	3fa50513          	addi	a0,a0,1018 # ffffffffc0209540 <default_pmm_manager+0x1308>
}
ffffffffc020514e:	0141                	addi	sp,sp,16
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0205150:	842fb06f          	j	ffffffffc0200192 <cprintf>

ffffffffc0205154 <cond_wait>:
// Suspend calling thread on a condition variable waiting for condition Atomically unlocks 
// mutex and suspends calling thread on conditional variable after waking up locks mutex. Notice: mp is mutex semaphore for monitor's procedures
void
cond_wait (condvar_t *cvp) {
    //LAB7 EXERCISE: YOUR CODE
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0205154:	711c                	ld	a5,32(a0)
ffffffffc0205156:	4d10                	lw	a2,24(a0)
cond_wait (condvar_t *cvp) {
ffffffffc0205158:	1141                	addi	sp,sp,-16
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc020515a:	5b94                	lw	a3,48(a5)
cond_wait (condvar_t *cvp) {
ffffffffc020515c:	e022                	sd	s0,0(sp)
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc020515e:	85aa                	mv	a1,a0
cond_wait (condvar_t *cvp) {
ffffffffc0205160:	842a                	mv	s0,a0
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0205162:	00004517          	auipc	a0,0x4
ffffffffc0205166:	42650513          	addi	a0,a0,1062 # ffffffffc0209588 <default_pmm_manager+0x1350>
cond_wait (condvar_t *cvp) {
ffffffffc020516a:	e406                	sd	ra,8(sp)
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc020516c:	826fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *            signal(mt.mutex);
    *         wait(cv.sem);
    *         cv.count --;
    */
    cvp->count ++;
    if(cvp->owner->next_count > 0)
ffffffffc0205170:	7008                	ld	a0,32(s0)
    cvp->count ++;
ffffffffc0205172:	4c1c                	lw	a5,24(s0)
    if(cvp->owner->next_count > 0)
ffffffffc0205174:	5918                	lw	a4,48(a0)
    cvp->count ++;
ffffffffc0205176:	2785                	addiw	a5,a5,1
ffffffffc0205178:	cc1c                	sw	a5,24(s0)
    if(cvp->owner->next_count > 0)
ffffffffc020517a:	02e05763          	blez	a4,ffffffffc02051a8 <cond_wait+0x54>
        up(&(cvp->owner->next));
ffffffffc020517e:	0561                	addi	a0,a0,24
ffffffffc0205180:	182000ef          	jal	ra,ffffffffc0205302 <up>
    else
        up(&(cvp->owner->mutex));
    down(&(cvp->sem));
ffffffffc0205184:	8522                	mv	a0,s0
ffffffffc0205186:	180000ef          	jal	ra,ffffffffc0205306 <down>
    cvp->count --;
ffffffffc020518a:	4c10                	lw	a2,24(s0)
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc020518c:	701c                	ld	a5,32(s0)
ffffffffc020518e:	85a2                	mv	a1,s0
    cvp->count --;
ffffffffc0205190:	367d                	addiw	a2,a2,-1
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0205192:	5b94                	lw	a3,48(a5)
    cvp->count --;
ffffffffc0205194:	cc10                	sw	a2,24(s0)
}
ffffffffc0205196:	6402                	ld	s0,0(sp)
ffffffffc0205198:	60a2                	ld	ra,8(sp)
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc020519a:	00004517          	auipc	a0,0x4
ffffffffc020519e:	43650513          	addi	a0,a0,1078 # ffffffffc02095d0 <default_pmm_manager+0x1398>
}
ffffffffc02051a2:	0141                	addi	sp,sp,16
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02051a4:	feffa06f          	j	ffffffffc0200192 <cprintf>
        up(&(cvp->owner->mutex));
ffffffffc02051a8:	15a000ef          	jal	ra,ffffffffc0205302 <up>
ffffffffc02051ac:	bfe1                	j	ffffffffc0205184 <cond_wait+0x30>

ffffffffc02051ae <__down.constprop.0>:
        }
    }
    local_intr_restore(intr_flag);
}

static __noinline uint32_t __down(semaphore_t *sem, uint32_t wait_state) {
ffffffffc02051ae:	711d                	addi	sp,sp,-96
ffffffffc02051b0:	ec86                	sd	ra,88(sp)
ffffffffc02051b2:	e8a2                	sd	s0,80(sp)
ffffffffc02051b4:	e4a6                	sd	s1,72(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02051b6:	100027f3          	csrr	a5,sstatus
ffffffffc02051ba:	8b89                	andi	a5,a5,2
ffffffffc02051bc:	ebb1                	bnez	a5,ffffffffc0205210 <__down.constprop.0+0x62>
    bool intr_flag;
    local_intr_save(intr_flag);
    if (sem->value > 0) {
ffffffffc02051be:	411c                	lw	a5,0(a0)
ffffffffc02051c0:	00f05a63          	blez	a5,ffffffffc02051d4 <__down.constprop.0+0x26>
        sem->value --;
ffffffffc02051c4:	37fd                	addiw	a5,a5,-1
ffffffffc02051c6:	c11c                	sw	a5,0(a0)
        local_intr_restore(intr_flag);
        return 0;
ffffffffc02051c8:	4501                	li	a0,0

    if (wait->wakeup_flags != wait_state) {
        return wait->wakeup_flags;
    }
    return 0;
}
ffffffffc02051ca:	60e6                	ld	ra,88(sp)
ffffffffc02051cc:	6446                	ld	s0,80(sp)
ffffffffc02051ce:	64a6                	ld	s1,72(sp)
ffffffffc02051d0:	6125                	addi	sp,sp,96
ffffffffc02051d2:	8082                	ret
    wait_current_set(&(sem->wait_queue), wait, wait_state);
ffffffffc02051d4:	00850413          	addi	s0,a0,8
ffffffffc02051d8:	0824                	addi	s1,sp,24
ffffffffc02051da:	10000613          	li	a2,256
ffffffffc02051de:	85a6                	mv	a1,s1
ffffffffc02051e0:	8522                	mv	a0,s0
ffffffffc02051e2:	1ec000ef          	jal	ra,ffffffffc02053ce <wait_current_set>
    schedule();
ffffffffc02051e6:	1d7010ef          	jal	ra,ffffffffc0206bbc <schedule>
ffffffffc02051ea:	100027f3          	csrr	a5,sstatus
ffffffffc02051ee:	8b89                	andi	a5,a5,2
ffffffffc02051f0:	e3b5                	bnez	a5,ffffffffc0205254 <__down.constprop.0+0xa6>
    wait_current_del(&(sem->wait_queue), wait);
ffffffffc02051f2:	8526                	mv	a0,s1
ffffffffc02051f4:	1a0000ef          	jal	ra,ffffffffc0205394 <wait_in_queue>
ffffffffc02051f8:	e929                	bnez	a0,ffffffffc020524a <__down.constprop.0+0x9c>
    if (wait->wakeup_flags != wait_state) {
ffffffffc02051fa:	5502                	lw	a0,32(sp)
ffffffffc02051fc:	10000793          	li	a5,256
ffffffffc0205200:	fcf515e3          	bne	a0,a5,ffffffffc02051ca <__down.constprop.0+0x1c>
}
ffffffffc0205204:	60e6                	ld	ra,88(sp)
ffffffffc0205206:	6446                	ld	s0,80(sp)
ffffffffc0205208:	64a6                	ld	s1,72(sp)
    return 0;
ffffffffc020520a:	4501                	li	a0,0
}
ffffffffc020520c:	6125                	addi	sp,sp,96
ffffffffc020520e:	8082                	ret
ffffffffc0205210:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205212:	c40fb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
    if (sem->value > 0) {
ffffffffc0205216:	6522                	ld	a0,8(sp)
ffffffffc0205218:	411c                	lw	a5,0(a0)
ffffffffc020521a:	00f05c63          	blez	a5,ffffffffc0205232 <__down.constprop.0+0x84>
        sem->value --;
ffffffffc020521e:	37fd                	addiw	a5,a5,-1
ffffffffc0205220:	c11c                	sw	a5,0(a0)
        intr_enable();
ffffffffc0205222:	c2afb0ef          	jal	ra,ffffffffc020064c <intr_enable>
}
ffffffffc0205226:	60e6                	ld	ra,88(sp)
ffffffffc0205228:	6446                	ld	s0,80(sp)
ffffffffc020522a:	64a6                	ld	s1,72(sp)
        return 0;
ffffffffc020522c:	4501                	li	a0,0
}
ffffffffc020522e:	6125                	addi	sp,sp,96
ffffffffc0205230:	8082                	ret
    wait_current_set(&(sem->wait_queue), wait, wait_state);
ffffffffc0205232:	00850413          	addi	s0,a0,8
ffffffffc0205236:	0824                	addi	s1,sp,24
ffffffffc0205238:	10000613          	li	a2,256
ffffffffc020523c:	85a6                	mv	a1,s1
ffffffffc020523e:	8522                	mv	a0,s0
ffffffffc0205240:	18e000ef          	jal	ra,ffffffffc02053ce <wait_current_set>
ffffffffc0205244:	c08fb0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0205248:	bf79                	j	ffffffffc02051e6 <__down.constprop.0+0x38>
    wait_current_del(&(sem->wait_queue), wait);
ffffffffc020524a:	85a6                	mv	a1,s1
ffffffffc020524c:	8522                	mv	a0,s0
ffffffffc020524e:	112000ef          	jal	ra,ffffffffc0205360 <wait_queue_del>
    if (flag) {
ffffffffc0205252:	b765                	j	ffffffffc02051fa <__down.constprop.0+0x4c>
        intr_disable();
ffffffffc0205254:	bfefb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0205258:	8526                	mv	a0,s1
ffffffffc020525a:	13a000ef          	jal	ra,ffffffffc0205394 <wait_in_queue>
ffffffffc020525e:	e501                	bnez	a0,ffffffffc0205266 <__down.constprop.0+0xb8>
        intr_enable();
ffffffffc0205260:	becfb0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0205264:	bf59                	j	ffffffffc02051fa <__down.constprop.0+0x4c>
ffffffffc0205266:	85a6                	mv	a1,s1
ffffffffc0205268:	8522                	mv	a0,s0
ffffffffc020526a:	0f6000ef          	jal	ra,ffffffffc0205360 <wait_queue_del>
    if (flag) {
ffffffffc020526e:	bfcd                	j	ffffffffc0205260 <__down.constprop.0+0xb2>

ffffffffc0205270 <__up.constprop.1>:
static __noinline void __up(semaphore_t *sem, uint32_t wait_state) {
ffffffffc0205270:	1101                	addi	sp,sp,-32
ffffffffc0205272:	e426                	sd	s1,8(sp)
ffffffffc0205274:	ec06                	sd	ra,24(sp)
ffffffffc0205276:	e822                	sd	s0,16(sp)
ffffffffc0205278:	e04a                	sd	s2,0(sp)
ffffffffc020527a:	84aa                	mv	s1,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020527c:	100027f3          	csrr	a5,sstatus
ffffffffc0205280:	8b89                	andi	a5,a5,2
ffffffffc0205282:	4901                	li	s2,0
ffffffffc0205284:	eba1                	bnez	a5,ffffffffc02052d4 <__up.constprop.1+0x64>
        if ((wait = wait_queue_first(&(sem->wait_queue))) == NULL) {
ffffffffc0205286:	00848413          	addi	s0,s1,8
ffffffffc020528a:	8522                	mv	a0,s0
ffffffffc020528c:	0f8000ef          	jal	ra,ffffffffc0205384 <wait_queue_first>
ffffffffc0205290:	cd15                	beqz	a0,ffffffffc02052cc <__up.constprop.1+0x5c>
            assert(wait->proc->wait_state == wait_state);
ffffffffc0205292:	6118                	ld	a4,0(a0)
ffffffffc0205294:	10000793          	li	a5,256
ffffffffc0205298:	0ec72703          	lw	a4,236(a4)
ffffffffc020529c:	04f71063          	bne	a4,a5,ffffffffc02052dc <__up.constprop.1+0x6c>
            wakeup_wait(&(sem->wait_queue), wait, wait_state, 1);
ffffffffc02052a0:	85aa                	mv	a1,a0
ffffffffc02052a2:	4685                	li	a3,1
ffffffffc02052a4:	10000613          	li	a2,256
ffffffffc02052a8:	8522                	mv	a0,s0
ffffffffc02052aa:	0f8000ef          	jal	ra,ffffffffc02053a2 <wakeup_wait>
    if (flag) {
ffffffffc02052ae:	00091863          	bnez	s2,ffffffffc02052be <__up.constprop.1+0x4e>
}
ffffffffc02052b2:	60e2                	ld	ra,24(sp)
ffffffffc02052b4:	6442                	ld	s0,16(sp)
ffffffffc02052b6:	64a2                	ld	s1,8(sp)
ffffffffc02052b8:	6902                	ld	s2,0(sp)
ffffffffc02052ba:	6105                	addi	sp,sp,32
ffffffffc02052bc:	8082                	ret
ffffffffc02052be:	6442                	ld	s0,16(sp)
ffffffffc02052c0:	60e2                	ld	ra,24(sp)
ffffffffc02052c2:	64a2                	ld	s1,8(sp)
ffffffffc02052c4:	6902                	ld	s2,0(sp)
ffffffffc02052c6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02052c8:	b84fb06f          	j	ffffffffc020064c <intr_enable>
            sem->value ++;
ffffffffc02052cc:	409c                	lw	a5,0(s1)
ffffffffc02052ce:	2785                	addiw	a5,a5,1
ffffffffc02052d0:	c09c                	sw	a5,0(s1)
ffffffffc02052d2:	bff1                	j	ffffffffc02052ae <__up.constprop.1+0x3e>
        intr_disable();
ffffffffc02052d4:	b7efb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc02052d8:	4905                	li	s2,1
ffffffffc02052da:	b775                	j	ffffffffc0205286 <__up.constprop.1+0x16>
            assert(wait->proc->wait_state == wait_state);
ffffffffc02052dc:	00004697          	auipc	a3,0x4
ffffffffc02052e0:	37468693          	addi	a3,a3,884 # ffffffffc0209650 <default_pmm_manager+0x1418>
ffffffffc02052e4:	00003617          	auipc	a2,0x3
ffffffffc02052e8:	80c60613          	addi	a2,a2,-2036 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02052ec:	45e5                	li	a1,25
ffffffffc02052ee:	00004517          	auipc	a0,0x4
ffffffffc02052f2:	38a50513          	addi	a0,a0,906 # ffffffffc0209678 <default_pmm_manager+0x1440>
ffffffffc02052f6:	992fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02052fa <sem_init>:
    sem->value = value;
ffffffffc02052fa:	c10c                	sw	a1,0(a0)
    wait_queue_init(&(sem->wait_queue));
ffffffffc02052fc:	0521                	addi	a0,a0,8
ffffffffc02052fe:	05c0006f          	j	ffffffffc020535a <wait_queue_init>

ffffffffc0205302 <up>:

void
up(semaphore_t *sem) {
    __up(sem, WT_KSEM);
ffffffffc0205302:	f6fff06f          	j	ffffffffc0205270 <__up.constprop.1>

ffffffffc0205306 <down>:
}

void
down(semaphore_t *sem) {
ffffffffc0205306:	1141                	addi	sp,sp,-16
ffffffffc0205308:	e406                	sd	ra,8(sp)
    uint32_t flags = __down(sem, WT_KSEM);
ffffffffc020530a:	ea5ff0ef          	jal	ra,ffffffffc02051ae <__down.constprop.0>
ffffffffc020530e:	2501                	sext.w	a0,a0
    assert(flags == 0);
ffffffffc0205310:	e501                	bnez	a0,ffffffffc0205318 <down+0x12>
}
ffffffffc0205312:	60a2                	ld	ra,8(sp)
ffffffffc0205314:	0141                	addi	sp,sp,16
ffffffffc0205316:	8082                	ret
    assert(flags == 0);
ffffffffc0205318:	00004697          	auipc	a3,0x4
ffffffffc020531c:	37068693          	addi	a3,a3,880 # ffffffffc0209688 <default_pmm_manager+0x1450>
ffffffffc0205320:	00002617          	auipc	a2,0x2
ffffffffc0205324:	7d060613          	addi	a2,a2,2000 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0205328:	04000593          	li	a1,64
ffffffffc020532c:	00004517          	auipc	a0,0x4
ffffffffc0205330:	34c50513          	addi	a0,a0,844 # ffffffffc0209678 <default_pmm_manager+0x1440>
ffffffffc0205334:	954fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205338 <wait_queue_del.part.1>:
    wait->wait_queue = queue;
    list_add_before(&(queue->wait_head), &(wait->wait_link));
}

void
wait_queue_del(wait_queue_t *queue, wait_t *wait) {
ffffffffc0205338:	1141                	addi	sp,sp,-16
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc020533a:	00004697          	auipc	a3,0x4
ffffffffc020533e:	36e68693          	addi	a3,a3,878 # ffffffffc02096a8 <default_pmm_manager+0x1470>
ffffffffc0205342:	00002617          	auipc	a2,0x2
ffffffffc0205346:	7ae60613          	addi	a2,a2,1966 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020534a:	45f1                	li	a1,28
ffffffffc020534c:	00004517          	auipc	a0,0x4
ffffffffc0205350:	39c50513          	addi	a0,a0,924 # ffffffffc02096e8 <default_pmm_manager+0x14b0>
wait_queue_del(wait_queue_t *queue, wait_t *wait) {
ffffffffc0205354:	e406                	sd	ra,8(sp)
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc0205356:	932fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020535a <wait_queue_init>:
    elm->prev = elm->next = elm;
ffffffffc020535a:	e508                	sd	a0,8(a0)
ffffffffc020535c:	e108                	sd	a0,0(a0)
}
ffffffffc020535e:	8082                	ret

ffffffffc0205360 <wait_queue_del>:
    return list->next == list;
ffffffffc0205360:	7198                	ld	a4,32(a1)
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc0205362:	01858793          	addi	a5,a1,24
ffffffffc0205366:	00e78b63          	beq	a5,a4,ffffffffc020537c <wait_queue_del+0x1c>
ffffffffc020536a:	6994                	ld	a3,16(a1)
ffffffffc020536c:	00a69863          	bne	a3,a0,ffffffffc020537c <wait_queue_del+0x1c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205370:	6d94                	ld	a3,24(a1)
    prev->next = next;
ffffffffc0205372:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0205374:	e314                	sd	a3,0(a4)
    elm->prev = elm->next = elm;
ffffffffc0205376:	f19c                	sd	a5,32(a1)
ffffffffc0205378:	ed9c                	sd	a5,24(a1)
ffffffffc020537a:	8082                	ret
wait_queue_del(wait_queue_t *queue, wait_t *wait) {
ffffffffc020537c:	1141                	addi	sp,sp,-16
ffffffffc020537e:	e406                	sd	ra,8(sp)
ffffffffc0205380:	fb9ff0ef          	jal	ra,ffffffffc0205338 <wait_queue_del.part.1>

ffffffffc0205384 <wait_queue_first>:
    return listelm->next;
ffffffffc0205384:	651c                	ld	a5,8(a0)
}

wait_t *
wait_queue_first(wait_queue_t *queue) {
    list_entry_t *le = list_next(&(queue->wait_head));
    if (le != &(queue->wait_head)) {
ffffffffc0205386:	00f50563          	beq	a0,a5,ffffffffc0205390 <wait_queue_first+0xc>
        return le2wait(le, wait_link);
ffffffffc020538a:	fe878513          	addi	a0,a5,-24
ffffffffc020538e:	8082                	ret
    }
    return NULL;
ffffffffc0205390:	4501                	li	a0,0
}
ffffffffc0205392:	8082                	ret

ffffffffc0205394 <wait_in_queue>:
    return list_empty(&(queue->wait_head));
}

bool
wait_in_queue(wait_t *wait) {
    return !list_empty(&(wait->wait_link));
ffffffffc0205394:	711c                	ld	a5,32(a0)
ffffffffc0205396:	0561                	addi	a0,a0,24
ffffffffc0205398:	40a78533          	sub	a0,a5,a0
}
ffffffffc020539c:	00a03533          	snez	a0,a0
ffffffffc02053a0:	8082                	ret

ffffffffc02053a2 <wakeup_wait>:

void
wakeup_wait(wait_queue_t *queue, wait_t *wait, uint32_t wakeup_flags, bool del) {
    if (del) {
ffffffffc02053a2:	ce91                	beqz	a3,ffffffffc02053be <wakeup_wait+0x1c>
    return list->next == list;
ffffffffc02053a4:	7198                	ld	a4,32(a1)
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc02053a6:	01858793          	addi	a5,a1,24
ffffffffc02053aa:	00e78e63          	beq	a5,a4,ffffffffc02053c6 <wakeup_wait+0x24>
ffffffffc02053ae:	6994                	ld	a3,16(a1)
ffffffffc02053b0:	00d51b63          	bne	a0,a3,ffffffffc02053c6 <wakeup_wait+0x24>
    __list_del(listelm->prev, listelm->next);
ffffffffc02053b4:	6d94                	ld	a3,24(a1)
    prev->next = next;
ffffffffc02053b6:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02053b8:	e314                	sd	a3,0(a4)
    elm->prev = elm->next = elm;
ffffffffc02053ba:	f19c                	sd	a5,32(a1)
ffffffffc02053bc:	ed9c                	sd	a5,24(a1)
        wait_queue_del(queue, wait);
    }
    wait->wakeup_flags = wakeup_flags;
    wakeup_proc(wait->proc);
ffffffffc02053be:	6188                	ld	a0,0(a1)
    wait->wakeup_flags = wakeup_flags;
ffffffffc02053c0:	c590                	sw	a2,8(a1)
    wakeup_proc(wait->proc);
ffffffffc02053c2:	7400106f          	j	ffffffffc0206b02 <wakeup_proc>
wakeup_wait(wait_queue_t *queue, wait_t *wait, uint32_t wakeup_flags, bool del) {
ffffffffc02053c6:	1141                	addi	sp,sp,-16
ffffffffc02053c8:	e406                	sd	ra,8(sp)
ffffffffc02053ca:	f6fff0ef          	jal	ra,ffffffffc0205338 <wait_queue_del.part.1>

ffffffffc02053ce <wait_current_set>:
    }
}

void
wait_current_set(wait_queue_t *queue, wait_t *wait, uint32_t wait_state) {
    assert(current != NULL);
ffffffffc02053ce:	000da797          	auipc	a5,0xda
ffffffffc02053d2:	ee278793          	addi	a5,a5,-286 # ffffffffc02df2b0 <current>
ffffffffc02053d6:	639c                	ld	a5,0(a5)
ffffffffc02053d8:	c39d                	beqz	a5,ffffffffc02053fe <wait_current_set+0x30>
    list_init(&(wait->wait_link));
ffffffffc02053da:	01858713          	addi	a4,a1,24
    wait->wakeup_flags = WT_INTERRUPTED;
ffffffffc02053de:	800006b7          	lui	a3,0x80000
ffffffffc02053e2:	ed98                	sd	a4,24(a1)
    wait->proc = proc;
ffffffffc02053e4:	e19c                	sd	a5,0(a1)
    wait->wakeup_flags = WT_INTERRUPTED;
ffffffffc02053e6:	c594                	sw	a3,8(a1)
    wait_init(wait, current);
    current->state = PROC_SLEEPING;
ffffffffc02053e8:	4685                	li	a3,1
ffffffffc02053ea:	c394                	sw	a3,0(a5)
    current->wait_state = wait_state;
ffffffffc02053ec:	0ec7a623          	sw	a2,236(a5)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02053f0:	611c                	ld	a5,0(a0)
    wait->wait_queue = queue;
ffffffffc02053f2:	e988                	sd	a0,16(a1)
    prev->next = next->prev = elm;
ffffffffc02053f4:	e118                	sd	a4,0(a0)
ffffffffc02053f6:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02053f8:	f188                	sd	a0,32(a1)
    elm->prev = prev;
ffffffffc02053fa:	ed9c                	sd	a5,24(a1)
ffffffffc02053fc:	8082                	ret
wait_current_set(wait_queue_t *queue, wait_t *wait, uint32_t wait_state) {
ffffffffc02053fe:	1141                	addi	sp,sp,-16
    assert(current != NULL);
ffffffffc0205400:	00004697          	auipc	a3,0x4
ffffffffc0205404:	29868693          	addi	a3,a3,664 # ffffffffc0209698 <default_pmm_manager+0x1460>
ffffffffc0205408:	00002617          	auipc	a2,0x2
ffffffffc020540c:	6e860613          	addi	a2,a2,1768 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0205410:	07400593          	li	a1,116
ffffffffc0205414:	00004517          	auipc	a0,0x4
ffffffffc0205418:	2d450513          	addi	a0,a0,724 # ffffffffc02096e8 <default_pmm_manager+0x14b0>
wait_current_set(wait_queue_t *queue, wait_t *wait, uint32_t wait_state) {
ffffffffc020541c:	e406                	sd	ra,8(sp)
    assert(current != NULL);
ffffffffc020541e:	86afb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205422 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0205422:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0205424:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0205426:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0205428:	9cefb0ef          	jal	ra,ffffffffc02005f6 <ide_device_valid>
ffffffffc020542c:	cd01                	beqz	a0,ffffffffc0205444 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc020542e:	4505                	li	a0,1
ffffffffc0205430:	9ccfb0ef          	jal	ra,ffffffffc02005fc <ide_device_size>
}
ffffffffc0205434:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0205436:	810d                	srli	a0,a0,0x3
ffffffffc0205438:	000da797          	auipc	a5,0xda
ffffffffc020543c:	f6a7b823          	sd	a0,-144(a5) # ffffffffc02df3a8 <max_swap_offset>
}
ffffffffc0205440:	0141                	addi	sp,sp,16
ffffffffc0205442:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0205444:	00004617          	auipc	a2,0x4
ffffffffc0205448:	2bc60613          	addi	a2,a2,700 # ffffffffc0209700 <default_pmm_manager+0x14c8>
ffffffffc020544c:	45b5                	li	a1,13
ffffffffc020544e:	00004517          	auipc	a0,0x4
ffffffffc0205452:	2d250513          	addi	a0,a0,722 # ffffffffc0209720 <default_pmm_manager+0x14e8>
ffffffffc0205456:	832fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020545a <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc020545a:	1141                	addi	sp,sp,-16
ffffffffc020545c:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020545e:	00855793          	srli	a5,a0,0x8
ffffffffc0205462:	cfb9                	beqz	a5,ffffffffc02054c0 <swapfs_read+0x66>
ffffffffc0205464:	000da717          	auipc	a4,0xda
ffffffffc0205468:	f4470713          	addi	a4,a4,-188 # ffffffffc02df3a8 <max_swap_offset>
ffffffffc020546c:	6318                	ld	a4,0(a4)
ffffffffc020546e:	04e7f963          	bleu	a4,a5,ffffffffc02054c0 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0205472:	000da717          	auipc	a4,0xda
ffffffffc0205476:	ea670713          	addi	a4,a4,-346 # ffffffffc02df318 <pages>
ffffffffc020547a:	6310                	ld	a2,0(a4)
ffffffffc020547c:	00005717          	auipc	a4,0x5
ffffffffc0205480:	43c70713          	addi	a4,a4,1084 # ffffffffc020a8b8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0205484:	000da697          	auipc	a3,0xda
ffffffffc0205488:	e1468693          	addi	a3,a3,-492 # ffffffffc02df298 <npage>
    return page - pages + nbase;
ffffffffc020548c:	40c58633          	sub	a2,a1,a2
ffffffffc0205490:	630c                	ld	a1,0(a4)
ffffffffc0205492:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0205494:	577d                	li	a4,-1
ffffffffc0205496:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0205498:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc020549a:	8331                	srli	a4,a4,0xc
ffffffffc020549c:	8f71                	and	a4,a4,a2
ffffffffc020549e:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc02054a2:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc02054a4:	02d77a63          	bleu	a3,a4,ffffffffc02054d8 <swapfs_read+0x7e>
ffffffffc02054a8:	000da797          	auipc	a5,0xda
ffffffffc02054ac:	e6078793          	addi	a5,a5,-416 # ffffffffc02df308 <va_pa_offset>
ffffffffc02054b0:	639c                	ld	a5,0(a5)
}
ffffffffc02054b2:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02054b4:	46a1                	li	a3,8
ffffffffc02054b6:	963e                	add	a2,a2,a5
ffffffffc02054b8:	4505                	li	a0,1
}
ffffffffc02054ba:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02054bc:	946fb06f          	j	ffffffffc0200602 <ide_read_secs>
ffffffffc02054c0:	86aa                	mv	a3,a0
ffffffffc02054c2:	00004617          	auipc	a2,0x4
ffffffffc02054c6:	27660613          	addi	a2,a2,630 # ffffffffc0209738 <default_pmm_manager+0x1500>
ffffffffc02054ca:	45d1                	li	a1,20
ffffffffc02054cc:	00004517          	auipc	a0,0x4
ffffffffc02054d0:	25450513          	addi	a0,a0,596 # ffffffffc0209720 <default_pmm_manager+0x14e8>
ffffffffc02054d4:	fb5fa0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc02054d8:	86b2                	mv	a3,a2
ffffffffc02054da:	06900593          	li	a1,105
ffffffffc02054de:	00003617          	auipc	a2,0x3
ffffffffc02054e2:	daa60613          	addi	a2,a2,-598 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc02054e6:	00003517          	auipc	a0,0x3
ffffffffc02054ea:	dca50513          	addi	a0,a0,-566 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc02054ee:	f9bfa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02054f2 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc02054f2:	1141                	addi	sp,sp,-16
ffffffffc02054f4:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02054f6:	00855793          	srli	a5,a0,0x8
ffffffffc02054fa:	cfb9                	beqz	a5,ffffffffc0205558 <swapfs_write+0x66>
ffffffffc02054fc:	000da717          	auipc	a4,0xda
ffffffffc0205500:	eac70713          	addi	a4,a4,-340 # ffffffffc02df3a8 <max_swap_offset>
ffffffffc0205504:	6318                	ld	a4,0(a4)
ffffffffc0205506:	04e7f963          	bleu	a4,a5,ffffffffc0205558 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc020550a:	000da717          	auipc	a4,0xda
ffffffffc020550e:	e0e70713          	addi	a4,a4,-498 # ffffffffc02df318 <pages>
ffffffffc0205512:	6310                	ld	a2,0(a4)
ffffffffc0205514:	00005717          	auipc	a4,0x5
ffffffffc0205518:	3a470713          	addi	a4,a4,932 # ffffffffc020a8b8 <nbase>
    return KADDR(page2pa(page));
ffffffffc020551c:	000da697          	auipc	a3,0xda
ffffffffc0205520:	d7c68693          	addi	a3,a3,-644 # ffffffffc02df298 <npage>
    return page - pages + nbase;
ffffffffc0205524:	40c58633          	sub	a2,a1,a2
ffffffffc0205528:	630c                	ld	a1,0(a4)
ffffffffc020552a:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc020552c:	577d                	li	a4,-1
ffffffffc020552e:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0205530:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0205532:	8331                	srli	a4,a4,0xc
ffffffffc0205534:	8f71                	and	a4,a4,a2
ffffffffc0205536:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc020553a:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc020553c:	02d77a63          	bleu	a3,a4,ffffffffc0205570 <swapfs_write+0x7e>
ffffffffc0205540:	000da797          	auipc	a5,0xda
ffffffffc0205544:	dc878793          	addi	a5,a5,-568 # ffffffffc02df308 <va_pa_offset>
ffffffffc0205548:	639c                	ld	a5,0(a5)
}
ffffffffc020554a:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020554c:	46a1                	li	a3,8
ffffffffc020554e:	963e                	add	a2,a2,a5
ffffffffc0205550:	4505                	li	a0,1
}
ffffffffc0205552:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0205554:	8d2fb06f          	j	ffffffffc0200626 <ide_write_secs>
ffffffffc0205558:	86aa                	mv	a3,a0
ffffffffc020555a:	00004617          	auipc	a2,0x4
ffffffffc020555e:	1de60613          	addi	a2,a2,478 # ffffffffc0209738 <default_pmm_manager+0x1500>
ffffffffc0205562:	45e5                	li	a1,25
ffffffffc0205564:	00004517          	auipc	a0,0x4
ffffffffc0205568:	1bc50513          	addi	a0,a0,444 # ffffffffc0209720 <default_pmm_manager+0x14e8>
ffffffffc020556c:	f1dfa0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0205570:	86b2                	mv	a3,a2
ffffffffc0205572:	06900593          	li	a1,105
ffffffffc0205576:	00003617          	auipc	a2,0x3
ffffffffc020557a:	d1260613          	addi	a2,a2,-750 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc020557e:	00003517          	auipc	a0,0x3
ffffffffc0205582:	d3250513          	addi	a0,a0,-718 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc0205586:	f03fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020558a <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc020558a:	8526                	mv	a0,s1
	jalr s0
ffffffffc020558c:	9402                	jalr	s0

	jal do_exit
ffffffffc020558e:	6ea000ef          	jal	ra,ffffffffc0205c78 <do_exit>

ffffffffc0205592 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0205592:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0205594:	14800513          	li	a0,328
alloc_proc(void) {
ffffffffc0205598:	e022                	sd	s0,0(sp)
ffffffffc020559a:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc020559c:	e9afc0ef          	jal	ra,ffffffffc0201c36 <kmalloc>
ffffffffc02055a0:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc02055a2:	cd3d                	beqz	a0,ffffffffc0205620 <alloc_proc+0x8e>
     *     int time_slice;                             // time slice for occupying the CPU
     *     skew_heap_entry_t lab6_run_pool;            // FOR LAB6 ONLY: the entry in the run pool
     *     uint32_t lab6_stride;                       // FOR LAB6 ONLY: the current stride of the process
     *     uint32_t lab6_priority;                     // FOR LAB6 ONLY: the priority of process, set by lab6_set_priority(uint32_t)
     */
        proc->state = PROC_UNINIT;
ffffffffc02055a4:	57fd                	li	a5,-1
ffffffffc02055a6:	1782                	slli	a5,a5,0x20
ffffffffc02055a8:	e11c                	sd	a5,0(a0)
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc02055aa:	07000613          	li	a2,112
ffffffffc02055ae:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc02055b0:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc02055b4:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc02055b8:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc02055bc:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc02055c0:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc02055c4:	03050513          	addi	a0,a0,48
ffffffffc02055c8:	70f010ef          	jal	ra,ffffffffc02074d6 <memset>
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
ffffffffc02055cc:	000da797          	auipc	a5,0xda
ffffffffc02055d0:	d4478793          	addi	a5,a5,-700 # ffffffffc02df310 <boot_cr3>
ffffffffc02055d4:	639c                	ld	a5,0(a5)
        proc->tf = NULL;
ffffffffc02055d6:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc02055da:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3;
ffffffffc02055de:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc02055e0:	463d                	li	a2,15
ffffffffc02055e2:	4581                	li	a1,0
ffffffffc02055e4:	0b440513          	addi	a0,s0,180
ffffffffc02055e8:	6ef010ef          	jal	ra,ffffffffc02074d6 <memset>
        proc->wait_state = 0;
        proc->cptr = NULL;
        proc->optr = NULL;
        proc->yptr = NULL;
        proc->rq = NULL;
        list_init(&(proc->run_link));
ffffffffc02055ec:	11040793          	addi	a5,s0,272
        proc->wait_state = 0;
ffffffffc02055f0:	0e042623          	sw	zero,236(s0)
        proc->cptr = NULL;
ffffffffc02055f4:	0e043823          	sd	zero,240(s0)
        proc->optr = NULL;
ffffffffc02055f8:	10043023          	sd	zero,256(s0)
        proc->yptr = NULL;
ffffffffc02055fc:	0e043c23          	sd	zero,248(s0)
        proc->rq = NULL;
ffffffffc0205600:	10043423          	sd	zero,264(s0)
    elm->prev = elm->next = elm;
ffffffffc0205604:	10f43c23          	sd	a5,280(s0)
ffffffffc0205608:	10f43823          	sd	a5,272(s0)
        proc->time_slice = 0;
ffffffffc020560c:	12042023          	sw	zero,288(s0)
     compare_f comp) __attribute__((always_inline));

static inline void
skew_heap_init(skew_heap_entry_t *a)
{
     a->left = a->right = a->parent = NULL;
ffffffffc0205610:	12043423          	sd	zero,296(s0)
ffffffffc0205614:	12043823          	sd	zero,304(s0)
ffffffffc0205618:	12043c23          	sd	zero,312(s0)
        skew_heap_init(&(proc->lab6_run_pool));
        proc->lab6_stride = 0;
ffffffffc020561c:	14043023          	sd	zero,320(s0)
        proc->lab6_priority = 0;
    }
    return proc;
}
ffffffffc0205620:	8522                	mv	a0,s0
ffffffffc0205622:	60a2                	ld	ra,8(sp)
ffffffffc0205624:	6402                	ld	s0,0(sp)
ffffffffc0205626:	0141                	addi	sp,sp,16
ffffffffc0205628:	8082                	ret

ffffffffc020562a <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc020562a:	000da797          	auipc	a5,0xda
ffffffffc020562e:	c8678793          	addi	a5,a5,-890 # ffffffffc02df2b0 <current>
ffffffffc0205632:	639c                	ld	a5,0(a5)
ffffffffc0205634:	73c8                	ld	a0,160(a5)
ffffffffc0205636:	f54fb06f          	j	ffffffffc0200d8a <forkrets>

ffffffffc020563a <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc020563a:	000da797          	auipc	a5,0xda
ffffffffc020563e:	c7678793          	addi	a5,a5,-906 # ffffffffc02df2b0 <current>
ffffffffc0205642:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0205644:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0205646:	00004617          	auipc	a2,0x4
ffffffffc020564a:	4f260613          	addi	a2,a2,1266 # ffffffffc0209b38 <default_pmm_manager+0x1900>
ffffffffc020564e:	43cc                	lw	a1,4(a5)
ffffffffc0205650:	00004517          	auipc	a0,0x4
ffffffffc0205654:	4f050513          	addi	a0,a0,1264 # ffffffffc0209b40 <default_pmm_manager+0x1908>
user_main(void *arg) {
ffffffffc0205658:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc020565a:	b39fa0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc020565e:	00004797          	auipc	a5,0x4
ffffffffc0205662:	4da78793          	addi	a5,a5,1242 # ffffffffc0209b38 <default_pmm_manager+0x1900>
ffffffffc0205666:	3fe06717          	auipc	a4,0x3fe06
ffffffffc020566a:	5ca70713          	addi	a4,a4,1482 # bc30 <_binary_obj___user_matrix_out_size>
ffffffffc020566e:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0205670:	853e                	mv	a0,a5
ffffffffc0205672:	00065717          	auipc	a4,0x65
ffffffffc0205676:	2d670713          	addi	a4,a4,726 # ffffffffc026a948 <_binary_obj___user_matrix_out_start>
ffffffffc020567a:	f03a                	sd	a4,32(sp)
ffffffffc020567c:	f43e                	sd	a5,40(sp)
ffffffffc020567e:	e802                	sd	zero,16(sp)
ffffffffc0205680:	5b9010ef          	jal	ra,ffffffffc0207438 <strlen>
ffffffffc0205684:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0205686:	4511                	li	a0,4
ffffffffc0205688:	75a2                	ld	a1,40(sp)
ffffffffc020568a:	6662                	ld	a2,24(sp)
ffffffffc020568c:	7682                	ld	a3,32(sp)
ffffffffc020568e:	6722                	ld	a4,8(sp)
ffffffffc0205690:	48a9                	li	a7,10
ffffffffc0205692:	9002                	ebreak
ffffffffc0205694:	e82a                	sd	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0205696:	65c2                	ld	a1,16(sp)
ffffffffc0205698:	00004517          	auipc	a0,0x4
ffffffffc020569c:	4d050513          	addi	a0,a0,1232 # ffffffffc0209b68 <default_pmm_manager+0x1930>
ffffffffc02056a0:	af3fa0ef          	jal	ra,ffffffffc0200192 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc02056a4:	00004617          	auipc	a2,0x4
ffffffffc02056a8:	4d460613          	addi	a2,a2,1236 # ffffffffc0209b78 <default_pmm_manager+0x1940>
ffffffffc02056ac:	35e00593          	li	a1,862
ffffffffc02056b0:	00004517          	auipc	a0,0x4
ffffffffc02056b4:	4e850513          	addi	a0,a0,1256 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc02056b8:	dd1fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02056bc <setup_pgdir.isra.2>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc02056bc:	1101                	addi	sp,sp,-32
ffffffffc02056be:	e426                	sd	s1,8(sp)
ffffffffc02056c0:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc02056c2:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc02056c4:	ec06                	sd	ra,24(sp)
ffffffffc02056c6:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc02056c8:	f6afc0ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
ffffffffc02056cc:	c125                	beqz	a0,ffffffffc020572c <setup_pgdir.isra.2+0x70>
    return page - pages + nbase;
ffffffffc02056ce:	000da797          	auipc	a5,0xda
ffffffffc02056d2:	c4a78793          	addi	a5,a5,-950 # ffffffffc02df318 <pages>
ffffffffc02056d6:	6394                	ld	a3,0(a5)
ffffffffc02056d8:	00005797          	auipc	a5,0x5
ffffffffc02056dc:	1e078793          	addi	a5,a5,480 # ffffffffc020a8b8 <nbase>
ffffffffc02056e0:	6380                	ld	s0,0(a5)
ffffffffc02056e2:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc02056e6:	000da717          	auipc	a4,0xda
ffffffffc02056ea:	bb270713          	addi	a4,a4,-1102 # ffffffffc02df298 <npage>
    return page - pages + nbase;
ffffffffc02056ee:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02056f0:	57fd                	li	a5,-1
ffffffffc02056f2:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc02056f4:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc02056f6:	83b1                	srli	a5,a5,0xc
ffffffffc02056f8:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02056fa:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02056fc:	02e7fa63          	bleu	a4,a5,ffffffffc0205730 <setup_pgdir.isra.2+0x74>
ffffffffc0205700:	000da797          	auipc	a5,0xda
ffffffffc0205704:	c0878793          	addi	a5,a5,-1016 # ffffffffc02df308 <va_pa_offset>
ffffffffc0205708:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc020570a:	000da797          	auipc	a5,0xda
ffffffffc020570e:	b8678793          	addi	a5,a5,-1146 # ffffffffc02df290 <boot_pgdir>
ffffffffc0205712:	638c                	ld	a1,0(a5)
ffffffffc0205714:	9436                	add	s0,s0,a3
ffffffffc0205716:	6605                	lui	a2,0x1
ffffffffc0205718:	8522                	mv	a0,s0
ffffffffc020571a:	5cf010ef          	jal	ra,ffffffffc02074e8 <memcpy>
    return 0;
ffffffffc020571e:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0205720:	e080                	sd	s0,0(s1)
}
ffffffffc0205722:	60e2                	ld	ra,24(sp)
ffffffffc0205724:	6442                	ld	s0,16(sp)
ffffffffc0205726:	64a2                	ld	s1,8(sp)
ffffffffc0205728:	6105                	addi	sp,sp,32
ffffffffc020572a:	8082                	ret
        return -E_NO_MEM;
ffffffffc020572c:	5571                	li	a0,-4
ffffffffc020572e:	bfd5                	j	ffffffffc0205722 <setup_pgdir.isra.2+0x66>
ffffffffc0205730:	00003617          	auipc	a2,0x3
ffffffffc0205734:	b5860613          	addi	a2,a2,-1192 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc0205738:	06900593          	li	a1,105
ffffffffc020573c:	00003517          	auipc	a0,0x3
ffffffffc0205740:	b7450513          	addi	a0,a0,-1164 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc0205744:	d45fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205748 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0205748:	1101                	addi	sp,sp,-32
ffffffffc020574a:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020574c:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0205750:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205752:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0205754:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205756:	8522                	mv	a0,s0
ffffffffc0205758:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020575a:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020575c:	57b010ef          	jal	ra,ffffffffc02074d6 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205760:	8522                	mv	a0,s0
}
ffffffffc0205762:	6442                	ld	s0,16(sp)
ffffffffc0205764:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205766:	85a6                	mv	a1,s1
}
ffffffffc0205768:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020576a:	463d                	li	a2,15
}
ffffffffc020576c:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020576e:	57b0106f          	j	ffffffffc02074e8 <memcpy>

ffffffffc0205772 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0205772:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc0205774:	000da797          	auipc	a5,0xda
ffffffffc0205778:	b3c78793          	addi	a5,a5,-1220 # ffffffffc02df2b0 <current>
proc_run(struct proc_struct *proc) {
ffffffffc020577c:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc020577e:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc0205780:	ec06                	sd	ra,24(sp)
ffffffffc0205782:	e822                	sd	s0,16(sp)
ffffffffc0205784:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0205786:	02a48b63          	beq	s1,a0,ffffffffc02057bc <proc_run+0x4a>
ffffffffc020578a:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020578c:	100027f3          	csrr	a5,sstatus
ffffffffc0205790:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205792:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205794:	e3a9                	bnez	a5,ffffffffc02057d6 <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0205796:	745c                	ld	a5,168(s0)
            current = proc;
ffffffffc0205798:	000da717          	auipc	a4,0xda
ffffffffc020579c:	b0873c23          	sd	s0,-1256(a4) # ffffffffc02df2b0 <current>
ffffffffc02057a0:	577d                	li	a4,-1
ffffffffc02057a2:	177e                	slli	a4,a4,0x3f
ffffffffc02057a4:	83b1                	srli	a5,a5,0xc
ffffffffc02057a6:	8fd9                	or	a5,a5,a4
ffffffffc02057a8:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc02057ac:	03040593          	addi	a1,s0,48
ffffffffc02057b0:	03048513          	addi	a0,s1,48
ffffffffc02057b4:	1ae010ef          	jal	ra,ffffffffc0206962 <switch_to>
    if (flag) {
ffffffffc02057b8:	00091863          	bnez	s2,ffffffffc02057c8 <proc_run+0x56>
}
ffffffffc02057bc:	60e2                	ld	ra,24(sp)
ffffffffc02057be:	6442                	ld	s0,16(sp)
ffffffffc02057c0:	64a2                	ld	s1,8(sp)
ffffffffc02057c2:	6902                	ld	s2,0(sp)
ffffffffc02057c4:	6105                	addi	sp,sp,32
ffffffffc02057c6:	8082                	ret
ffffffffc02057c8:	6442                	ld	s0,16(sp)
ffffffffc02057ca:	60e2                	ld	ra,24(sp)
ffffffffc02057cc:	64a2                	ld	s1,8(sp)
ffffffffc02057ce:	6902                	ld	s2,0(sp)
ffffffffc02057d0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02057d2:	e7bfa06f          	j	ffffffffc020064c <intr_enable>
        intr_disable();
ffffffffc02057d6:	e7dfa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc02057da:	4905                	li	s2,1
ffffffffc02057dc:	bf6d                	j	ffffffffc0205796 <proc_run+0x24>

ffffffffc02057de <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc02057de:	0005071b          	sext.w	a4,a0
ffffffffc02057e2:	6789                	lui	a5,0x2
ffffffffc02057e4:	fff7069b          	addiw	a3,a4,-1
ffffffffc02057e8:	17f9                	addi	a5,a5,-2
ffffffffc02057ea:	04d7e063          	bltu	a5,a3,ffffffffc020582a <find_proc+0x4c>
find_proc(int pid) {
ffffffffc02057ee:	1141                	addi	sp,sp,-16
ffffffffc02057f0:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02057f2:	45a9                	li	a1,10
ffffffffc02057f4:	842a                	mv	s0,a0
ffffffffc02057f6:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc02057f8:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02057fa:	02f010ef          	jal	ra,ffffffffc0207028 <hash32>
ffffffffc02057fe:	02051693          	slli	a3,a0,0x20
ffffffffc0205802:	82f1                	srli	a3,a3,0x1c
ffffffffc0205804:	000d6517          	auipc	a0,0xd6
ffffffffc0205808:	a4c50513          	addi	a0,a0,-1460 # ffffffffc02db250 <hash_list>
ffffffffc020580c:	96aa                	add	a3,a3,a0
ffffffffc020580e:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205810:	a029                	j	ffffffffc020581a <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0205812:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7ba4>
ffffffffc0205816:	00870c63          	beq	a4,s0,ffffffffc020582e <find_proc+0x50>
    return listelm->next;
ffffffffc020581a:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc020581c:	fef69be3          	bne	a3,a5,ffffffffc0205812 <find_proc+0x34>
}
ffffffffc0205820:	60a2                	ld	ra,8(sp)
ffffffffc0205822:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0205824:	4501                	li	a0,0
}
ffffffffc0205826:	0141                	addi	sp,sp,16
ffffffffc0205828:	8082                	ret
    return NULL;
ffffffffc020582a:	4501                	li	a0,0
}
ffffffffc020582c:	8082                	ret
ffffffffc020582e:	60a2                	ld	ra,8(sp)
ffffffffc0205830:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205832:	f2878513          	addi	a0,a5,-216
}
ffffffffc0205836:	0141                	addi	sp,sp,16
ffffffffc0205838:	8082                	ret

ffffffffc020583a <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc020583a:	7159                	addi	sp,sp,-112
ffffffffc020583c:	e8ca                	sd	s2,80(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc020583e:	000da917          	auipc	s2,0xda
ffffffffc0205842:	a8a90913          	addi	s2,s2,-1398 # ffffffffc02df2c8 <nr_process>
ffffffffc0205846:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc020584a:	f486                	sd	ra,104(sp)
ffffffffc020584c:	f0a2                	sd	s0,96(sp)
ffffffffc020584e:	eca6                	sd	s1,88(sp)
ffffffffc0205850:	e4ce                	sd	s3,72(sp)
ffffffffc0205852:	e0d2                	sd	s4,64(sp)
ffffffffc0205854:	fc56                	sd	s5,56(sp)
ffffffffc0205856:	f85a                	sd	s6,48(sp)
ffffffffc0205858:	f45e                	sd	s7,40(sp)
ffffffffc020585a:	f062                	sd	s8,32(sp)
ffffffffc020585c:	ec66                	sd	s9,24(sp)
ffffffffc020585e:	e86a                	sd	s10,16(sp)
ffffffffc0205860:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0205862:	6785                	lui	a5,0x1
ffffffffc0205864:	32f75f63          	ble	a5,a4,ffffffffc0205ba2 <do_fork+0x368>
ffffffffc0205868:	8a2a                	mv	s4,a0
ffffffffc020586a:	89ae                	mv	s3,a1
ffffffffc020586c:	84b2                	mv	s1,a2
    if((proc = alloc_proc()) == NULL) {
ffffffffc020586e:	d25ff0ef          	jal	ra,ffffffffc0205592 <alloc_proc>
ffffffffc0205872:	842a                	mv	s0,a0
ffffffffc0205874:	2a050763          	beqz	a0,ffffffffc0205b22 <do_fork+0x2e8>
    proc->parent = current;
ffffffffc0205878:	000dab97          	auipc	s7,0xda
ffffffffc020587c:	a38b8b93          	addi	s7,s7,-1480 # ffffffffc02df2b0 <current>
ffffffffc0205880:	000bb783          	ld	a5,0(s7)
    assert(current->wait_state == 0);
ffffffffc0205884:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x89e4>
    proc->parent = current;
ffffffffc0205888:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc020588a:	32071a63          	bnez	a4,ffffffffc0205bbe <do_fork+0x384>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020588e:	4509                	li	a0,2
ffffffffc0205890:	da2fc0ef          	jal	ra,ffffffffc0201e32 <alloc_pages>
    if (page != NULL) {
ffffffffc0205894:	28050463          	beqz	a0,ffffffffc0205b1c <do_fork+0x2e2>
    return page - pages + nbase;
ffffffffc0205898:	000dac97          	auipc	s9,0xda
ffffffffc020589c:	a80c8c93          	addi	s9,s9,-1408 # ffffffffc02df318 <pages>
ffffffffc02058a0:	000cb683          	ld	a3,0(s9)
ffffffffc02058a4:	00005797          	auipc	a5,0x5
ffffffffc02058a8:	01478793          	addi	a5,a5,20 # ffffffffc020a8b8 <nbase>
ffffffffc02058ac:	0007ba83          	ld	s5,0(a5)
ffffffffc02058b0:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc02058b4:	000dad17          	auipc	s10,0xda
ffffffffc02058b8:	9e4d0d13          	addi	s10,s10,-1564 # ffffffffc02df298 <npage>
    return page - pages + nbase;
ffffffffc02058bc:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02058be:	57fd                	li	a5,-1
ffffffffc02058c0:	000d3703          	ld	a4,0(s10)
    return page - pages + nbase;
ffffffffc02058c4:	96d6                	add	a3,a3,s5
    return KADDR(page2pa(page));
ffffffffc02058c6:	83b1                	srli	a5,a5,0xc
ffffffffc02058c8:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02058ca:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02058cc:	2ce7fd63          	bleu	a4,a5,ffffffffc0205ba6 <do_fork+0x36c>
ffffffffc02058d0:	000dac17          	auipc	s8,0xda
ffffffffc02058d4:	a38c0c13          	addi	s8,s8,-1480 # ffffffffc02df308 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc02058d8:	000bb703          	ld	a4,0(s7)
ffffffffc02058dc:	000c3783          	ld	a5,0(s8)
ffffffffc02058e0:	02873b03          	ld	s6,40(a4)
ffffffffc02058e4:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02058e6:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc02058e8:	020b0863          	beqz	s6,ffffffffc0205918 <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc02058ec:	100a7a13          	andi	s4,s4,256
ffffffffc02058f0:	1e0a0463          	beqz	s4,ffffffffc0205ad8 <do_fork+0x29e>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc02058f4:	030b2703          	lw	a4,48(s6)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02058f8:	018b3783          	ld	a5,24(s6)
ffffffffc02058fc:	c02006b7          	lui	a3,0xc0200
ffffffffc0205900:	2705                	addiw	a4,a4,1
ffffffffc0205902:	02eb2823          	sw	a4,48(s6)
    proc->mm = mm;
ffffffffc0205906:	03643423          	sd	s6,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020590a:	2cd7ea63          	bltu	a5,a3,ffffffffc0205bde <do_fork+0x3a4>
ffffffffc020590e:	000c3703          	ld	a4,0(s8)
ffffffffc0205912:	6814                	ld	a3,16(s0)
ffffffffc0205914:	8f99                	sub	a5,a5,a4
ffffffffc0205916:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205918:	6789                	lui	a5,0x2
ffffffffc020591a:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7bf0>
ffffffffc020591e:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0205920:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205922:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0205924:	87b6                	mv	a5,a3
ffffffffc0205926:	12048893          	addi	a7,s1,288
ffffffffc020592a:	00063803          	ld	a6,0(a2)
ffffffffc020592e:	6608                	ld	a0,8(a2)
ffffffffc0205930:	6a0c                	ld	a1,16(a2)
ffffffffc0205932:	6e18                	ld	a4,24(a2)
ffffffffc0205934:	0107b023          	sd	a6,0(a5)
ffffffffc0205938:	e788                	sd	a0,8(a5)
ffffffffc020593a:	eb8c                	sd	a1,16(a5)
ffffffffc020593c:	ef98                	sd	a4,24(a5)
ffffffffc020593e:	02060613          	addi	a2,a2,32
ffffffffc0205942:	02078793          	addi	a5,a5,32
ffffffffc0205946:	ff1612e3          	bne	a2,a7,ffffffffc020592a <do_fork+0xf0>
    proc->tf->gpr.a0 = 0;
ffffffffc020594a:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020594e:	12098e63          	beqz	s3,ffffffffc0205a8a <do_fork+0x250>
ffffffffc0205952:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205956:	00000797          	auipc	a5,0x0
ffffffffc020595a:	cd478793          	addi	a5,a5,-812 # ffffffffc020562a <forkret>
ffffffffc020595e:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205960:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205962:	100027f3          	csrr	a5,sstatus
ffffffffc0205966:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205968:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020596a:	12079f63          	bnez	a5,ffffffffc0205aa8 <do_fork+0x26e>
    if (++ last_pid >= MAX_PID) {
ffffffffc020596e:	000ce797          	auipc	a5,0xce
ffffffffc0205972:	4da78793          	addi	a5,a5,1242 # ffffffffc02d3e48 <last_pid.1832>
ffffffffc0205976:	439c                	lw	a5,0(a5)
ffffffffc0205978:	6709                	lui	a4,0x2
ffffffffc020597a:	0017851b          	addiw	a0,a5,1
ffffffffc020597e:	000ce697          	auipc	a3,0xce
ffffffffc0205982:	4ca6a523          	sw	a0,1226(a3) # ffffffffc02d3e48 <last_pid.1832>
ffffffffc0205986:	14e55263          	ble	a4,a0,ffffffffc0205aca <do_fork+0x290>
    if (last_pid >= next_safe) {
ffffffffc020598a:	000ce797          	auipc	a5,0xce
ffffffffc020598e:	4c278793          	addi	a5,a5,1218 # ffffffffc02d3e4c <next_safe.1831>
ffffffffc0205992:	439c                	lw	a5,0(a5)
ffffffffc0205994:	000da497          	auipc	s1,0xda
ffffffffc0205998:	bbc48493          	addi	s1,s1,-1092 # ffffffffc02df550 <proc_list>
ffffffffc020599c:	06f54063          	blt	a0,a5,ffffffffc02059fc <do_fork+0x1c2>
        next_safe = MAX_PID;
ffffffffc02059a0:	6789                	lui	a5,0x2
ffffffffc02059a2:	000ce717          	auipc	a4,0xce
ffffffffc02059a6:	4af72523          	sw	a5,1194(a4) # ffffffffc02d3e4c <next_safe.1831>
ffffffffc02059aa:	4581                	li	a1,0
ffffffffc02059ac:	87aa                	mv	a5,a0
ffffffffc02059ae:	000da497          	auipc	s1,0xda
ffffffffc02059b2:	ba248493          	addi	s1,s1,-1118 # ffffffffc02df550 <proc_list>
    repeat:
ffffffffc02059b6:	6889                	lui	a7,0x2
ffffffffc02059b8:	882e                	mv	a6,a1
ffffffffc02059ba:	6609                	lui	a2,0x2
        le = list;
ffffffffc02059bc:	000da697          	auipc	a3,0xda
ffffffffc02059c0:	b9468693          	addi	a3,a3,-1132 # ffffffffc02df550 <proc_list>
ffffffffc02059c4:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc02059c6:	00968f63          	beq	a3,s1,ffffffffc02059e4 <do_fork+0x1aa>
            if (proc->pid == last_pid) {
ffffffffc02059ca:	f3c6a703          	lw	a4,-196(a3)
ffffffffc02059ce:	0af70963          	beq	a4,a5,ffffffffc0205a80 <do_fork+0x246>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc02059d2:	fee7d9e3          	ble	a4,a5,ffffffffc02059c4 <do_fork+0x18a>
ffffffffc02059d6:	fec757e3          	ble	a2,a4,ffffffffc02059c4 <do_fork+0x18a>
ffffffffc02059da:	6694                	ld	a3,8(a3)
ffffffffc02059dc:	863a                	mv	a2,a4
ffffffffc02059de:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc02059e0:	fe9695e3          	bne	a3,s1,ffffffffc02059ca <do_fork+0x190>
ffffffffc02059e4:	c591                	beqz	a1,ffffffffc02059f0 <do_fork+0x1b6>
ffffffffc02059e6:	000ce717          	auipc	a4,0xce
ffffffffc02059ea:	46f72123          	sw	a5,1122(a4) # ffffffffc02d3e48 <last_pid.1832>
ffffffffc02059ee:	853e                	mv	a0,a5
ffffffffc02059f0:	00080663          	beqz	a6,ffffffffc02059fc <do_fork+0x1c2>
ffffffffc02059f4:	000ce797          	auipc	a5,0xce
ffffffffc02059f8:	44c7ac23          	sw	a2,1112(a5) # ffffffffc02d3e4c <next_safe.1831>
        proc->pid = get_pid();
ffffffffc02059fc:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02059fe:	45a9                	li	a1,10
ffffffffc0205a00:	2501                	sext.w	a0,a0
ffffffffc0205a02:	626010ef          	jal	ra,ffffffffc0207028 <hash32>
ffffffffc0205a06:	1502                	slli	a0,a0,0x20
ffffffffc0205a08:	000d6797          	auipc	a5,0xd6
ffffffffc0205a0c:	84878793          	addi	a5,a5,-1976 # ffffffffc02db250 <hash_list>
ffffffffc0205a10:	8171                	srli	a0,a0,0x1c
ffffffffc0205a12:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0205a14:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205a16:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205a18:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc0205a1c:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0205a1e:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc0205a20:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205a22:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0205a24:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc0205a28:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc0205a2a:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0205a2c:	e21c                	sd	a5,0(a2)
ffffffffc0205a2e:	000da597          	auipc	a1,0xda
ffffffffc0205a32:	b2f5b523          	sd	a5,-1238(a1) # ffffffffc02df558 <proc_list+0x8>
    elm->next = next;
ffffffffc0205a36:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0205a38:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc0205a3a:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205a3e:	10e43023          	sd	a4,256(s0)
ffffffffc0205a42:	c311                	beqz	a4,ffffffffc0205a46 <do_fork+0x20c>
        proc->optr->yptr = proc;
ffffffffc0205a44:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc0205a46:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc0205a4a:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc0205a4c:	2785                	addiw	a5,a5,1
ffffffffc0205a4e:	000da717          	auipc	a4,0xda
ffffffffc0205a52:	86f72d23          	sw	a5,-1926(a4) # ffffffffc02df2c8 <nr_process>
    if (flag) {
ffffffffc0205a56:	0c099863          	bnez	s3,ffffffffc0205b26 <do_fork+0x2ec>
    wakeup_proc(proc);
ffffffffc0205a5a:	8522                	mv	a0,s0
ffffffffc0205a5c:	0a6010ef          	jal	ra,ffffffffc0206b02 <wakeup_proc>
    ret = proc->pid;
ffffffffc0205a60:	4048                	lw	a0,4(s0)
}
ffffffffc0205a62:	70a6                	ld	ra,104(sp)
ffffffffc0205a64:	7406                	ld	s0,96(sp)
ffffffffc0205a66:	64e6                	ld	s1,88(sp)
ffffffffc0205a68:	6946                	ld	s2,80(sp)
ffffffffc0205a6a:	69a6                	ld	s3,72(sp)
ffffffffc0205a6c:	6a06                	ld	s4,64(sp)
ffffffffc0205a6e:	7ae2                	ld	s5,56(sp)
ffffffffc0205a70:	7b42                	ld	s6,48(sp)
ffffffffc0205a72:	7ba2                	ld	s7,40(sp)
ffffffffc0205a74:	7c02                	ld	s8,32(sp)
ffffffffc0205a76:	6ce2                	ld	s9,24(sp)
ffffffffc0205a78:	6d42                	ld	s10,16(sp)
ffffffffc0205a7a:	6da2                	ld	s11,8(sp)
ffffffffc0205a7c:	6165                	addi	sp,sp,112
ffffffffc0205a7e:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc0205a80:	2785                	addiw	a5,a5,1
ffffffffc0205a82:	0ac7d563          	ble	a2,a5,ffffffffc0205b2c <do_fork+0x2f2>
ffffffffc0205a86:	4585                	li	a1,1
ffffffffc0205a88:	bf35                	j	ffffffffc02059c4 <do_fork+0x18a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205a8a:	89b6                	mv	s3,a3
ffffffffc0205a8c:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205a90:	00000797          	auipc	a5,0x0
ffffffffc0205a94:	b9a78793          	addi	a5,a5,-1126 # ffffffffc020562a <forkret>
ffffffffc0205a98:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205a9a:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205a9c:	100027f3          	csrr	a5,sstatus
ffffffffc0205aa0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205aa2:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205aa4:	ec0785e3          	beqz	a5,ffffffffc020596e <do_fork+0x134>
        intr_disable();
ffffffffc0205aa8:	babfa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205aac:	000ce797          	auipc	a5,0xce
ffffffffc0205ab0:	39c78793          	addi	a5,a5,924 # ffffffffc02d3e48 <last_pid.1832>
ffffffffc0205ab4:	439c                	lw	a5,0(a5)
ffffffffc0205ab6:	6709                	lui	a4,0x2
        return 1;
ffffffffc0205ab8:	4985                	li	s3,1
ffffffffc0205aba:	0017851b          	addiw	a0,a5,1
ffffffffc0205abe:	000ce697          	auipc	a3,0xce
ffffffffc0205ac2:	38a6a523          	sw	a0,906(a3) # ffffffffc02d3e48 <last_pid.1832>
ffffffffc0205ac6:	ece542e3          	blt	a0,a4,ffffffffc020598a <do_fork+0x150>
        last_pid = 1;
ffffffffc0205aca:	4785                	li	a5,1
ffffffffc0205acc:	000ce717          	auipc	a4,0xce
ffffffffc0205ad0:	36f72e23          	sw	a5,892(a4) # ffffffffc02d3e48 <last_pid.1832>
ffffffffc0205ad4:	4505                	li	a0,1
ffffffffc0205ad6:	b5e9                	j	ffffffffc02059a0 <do_fork+0x166>
    if ((mm = mm_create()) == NULL) {
ffffffffc0205ad8:	dcefe0ef          	jal	ra,ffffffffc02040a6 <mm_create>
ffffffffc0205adc:	8a2a                	mv	s4,a0
ffffffffc0205ade:	c901                	beqz	a0,ffffffffc0205aee <do_fork+0x2b4>
    if (setup_pgdir(mm) != 0) {
ffffffffc0205ae0:	0561                	addi	a0,a0,24
ffffffffc0205ae2:	bdbff0ef          	jal	ra,ffffffffc02056bc <setup_pgdir.isra.2>
ffffffffc0205ae6:	c921                	beqz	a0,ffffffffc0205b36 <do_fork+0x2fc>
    mm_destroy(mm);
ffffffffc0205ae8:	8552                	mv	a0,s4
ffffffffc0205aea:	f48fe0ef          	jal	ra,ffffffffc0204232 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205aee:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0205af0:	c02007b7          	lui	a5,0xc0200
ffffffffc0205af4:	10f6e263          	bltu	a3,a5,ffffffffc0205bf8 <do_fork+0x3be>
ffffffffc0205af8:	000c3783          	ld	a5,0(s8)
    if (PPN(pa) >= npage) {
ffffffffc0205afc:	000d3703          	ld	a4,0(s10)
    return pa2page(PADDR(kva));
ffffffffc0205b00:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205b04:	83b1                	srli	a5,a5,0xc
ffffffffc0205b06:	10e7f563          	bleu	a4,a5,ffffffffc0205c10 <do_fork+0x3d6>
    return &pages[PPN(pa) - nbase];
ffffffffc0205b0a:	000cb503          	ld	a0,0(s9)
ffffffffc0205b0e:	415787b3          	sub	a5,a5,s5
ffffffffc0205b12:	079a                	slli	a5,a5,0x6
ffffffffc0205b14:	4589                	li	a1,2
ffffffffc0205b16:	953e                	add	a0,a0,a5
ffffffffc0205b18:	ba2fc0ef          	jal	ra,ffffffffc0201eba <free_pages>
    kfree(proc);
ffffffffc0205b1c:	8522                	mv	a0,s0
ffffffffc0205b1e:	9d4fc0ef          	jal	ra,ffffffffc0201cf2 <kfree>
    ret = -E_NO_MEM;
ffffffffc0205b22:	5571                	li	a0,-4
    return ret;
ffffffffc0205b24:	bf3d                	j	ffffffffc0205a62 <do_fork+0x228>
        intr_enable();
ffffffffc0205b26:	b27fa0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0205b2a:	bf05                	j	ffffffffc0205a5a <do_fork+0x220>
                    if (last_pid >= MAX_PID) {
ffffffffc0205b2c:	0117c363          	blt	a5,a7,ffffffffc0205b32 <do_fork+0x2f8>
                        last_pid = 1;
ffffffffc0205b30:	4785                	li	a5,1
                    goto repeat;
ffffffffc0205b32:	4585                	li	a1,1
ffffffffc0205b34:	b551                	j	ffffffffc02059b8 <do_fork+0x17e>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        down(&(mm->mm_sem));
ffffffffc0205b36:	038b0d93          	addi	s11,s6,56
ffffffffc0205b3a:	856e                	mv	a0,s11
ffffffffc0205b3c:	fcaff0ef          	jal	ra,ffffffffc0205306 <down>
        if (current != NULL) {
ffffffffc0205b40:	000bb783          	ld	a5,0(s7)
ffffffffc0205b44:	c781                	beqz	a5,ffffffffc0205b4c <do_fork+0x312>
            mm->locked_by = current->pid;
ffffffffc0205b46:	43dc                	lw	a5,4(a5)
ffffffffc0205b48:	04fb2823          	sw	a5,80(s6)
        ret = dup_mmap(mm, oldmm);
ffffffffc0205b4c:	85da                	mv	a1,s6
ffffffffc0205b4e:	8552                	mv	a0,s4
ffffffffc0205b50:	fe6fe0ef          	jal	ra,ffffffffc0204336 <dup_mmap>
ffffffffc0205b54:	8baa                	mv	s7,a0
}

static inline void
unlock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        up(&(mm->mm_sem));
ffffffffc0205b56:	856e                	mv	a0,s11
ffffffffc0205b58:	faaff0ef          	jal	ra,ffffffffc0205302 <up>
        mm->locked_by = 0;
ffffffffc0205b5c:	040b2823          	sw	zero,80(s6)
    if (ret != 0) {
ffffffffc0205b60:	8b52                	mv	s6,s4
ffffffffc0205b62:	d80b89e3          	beqz	s7,ffffffffc02058f4 <do_fork+0xba>
    exit_mmap(mm);
ffffffffc0205b66:	8552                	mv	a0,s4
ffffffffc0205b68:	86bfe0ef          	jal	ra,ffffffffc02043d2 <exit_mmap>
    return pa2page(PADDR(kva));
ffffffffc0205b6c:	018a3683          	ld	a3,24(s4)
ffffffffc0205b70:	c02007b7          	lui	a5,0xc0200
ffffffffc0205b74:	08f6e263          	bltu	a3,a5,ffffffffc0205bf8 <do_fork+0x3be>
ffffffffc0205b78:	000c3703          	ld	a4,0(s8)
    if (PPN(pa) >= npage) {
ffffffffc0205b7c:	000d3783          	ld	a5,0(s10)
    return pa2page(PADDR(kva));
ffffffffc0205b80:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0205b82:	82b1                	srli	a3,a3,0xc
ffffffffc0205b84:	08f6f663          	bleu	a5,a3,ffffffffc0205c10 <do_fork+0x3d6>
    return &pages[PPN(pa) - nbase];
ffffffffc0205b88:	000cb503          	ld	a0,0(s9)
ffffffffc0205b8c:	415686b3          	sub	a3,a3,s5
ffffffffc0205b90:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0205b92:	9536                	add	a0,a0,a3
ffffffffc0205b94:	4585                	li	a1,1
ffffffffc0205b96:	b24fc0ef          	jal	ra,ffffffffc0201eba <free_pages>
    mm_destroy(mm);
ffffffffc0205b9a:	8552                	mv	a0,s4
ffffffffc0205b9c:	e96fe0ef          	jal	ra,ffffffffc0204232 <mm_destroy>
ffffffffc0205ba0:	b7b9                	j	ffffffffc0205aee <do_fork+0x2b4>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205ba2:	556d                	li	a0,-5
ffffffffc0205ba4:	bd7d                	j	ffffffffc0205a62 <do_fork+0x228>
    return KADDR(page2pa(page));
ffffffffc0205ba6:	00002617          	auipc	a2,0x2
ffffffffc0205baa:	6e260613          	addi	a2,a2,1762 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc0205bae:	06900593          	li	a1,105
ffffffffc0205bb2:	00002517          	auipc	a0,0x2
ffffffffc0205bb6:	6fe50513          	addi	a0,a0,1790 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc0205bba:	8cffa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(current->wait_state == 0);
ffffffffc0205bbe:	00004697          	auipc	a3,0x4
ffffffffc0205bc2:	d6268693          	addi	a3,a3,-670 # ffffffffc0209920 <default_pmm_manager+0x16e8>
ffffffffc0205bc6:	00002617          	auipc	a2,0x2
ffffffffc0205bca:	f2a60613          	addi	a2,a2,-214 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0205bce:	1c000593          	li	a1,448
ffffffffc0205bd2:	00004517          	auipc	a0,0x4
ffffffffc0205bd6:	fc650513          	addi	a0,a0,-58 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc0205bda:	8affa0ef          	jal	ra,ffffffffc0200488 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205bde:	86be                	mv	a3,a5
ffffffffc0205be0:	00002617          	auipc	a2,0x2
ffffffffc0205be4:	6e060613          	addi	a2,a2,1760 # ffffffffc02082c0 <default_pmm_manager+0x88>
ffffffffc0205be8:	17400593          	li	a1,372
ffffffffc0205bec:	00004517          	auipc	a0,0x4
ffffffffc0205bf0:	fac50513          	addi	a0,a0,-84 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc0205bf4:	895fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205bf8:	00002617          	auipc	a2,0x2
ffffffffc0205bfc:	6c860613          	addi	a2,a2,1736 # ffffffffc02082c0 <default_pmm_manager+0x88>
ffffffffc0205c00:	06e00593          	li	a1,110
ffffffffc0205c04:	00002517          	auipc	a0,0x2
ffffffffc0205c08:	6ac50513          	addi	a0,a0,1708 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc0205c0c:	87dfa0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205c10:	00002617          	auipc	a2,0x2
ffffffffc0205c14:	6d860613          	addi	a2,a2,1752 # ffffffffc02082e8 <default_pmm_manager+0xb0>
ffffffffc0205c18:	06200593          	li	a1,98
ffffffffc0205c1c:	00002517          	auipc	a0,0x2
ffffffffc0205c20:	69450513          	addi	a0,a0,1684 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc0205c24:	865fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205c28 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205c28:	7129                	addi	sp,sp,-320
ffffffffc0205c2a:	fa22                	sd	s0,304(sp)
ffffffffc0205c2c:	f626                	sd	s1,296(sp)
ffffffffc0205c2e:	f24a                	sd	s2,288(sp)
ffffffffc0205c30:	84ae                	mv	s1,a1
ffffffffc0205c32:	892a                	mv	s2,a0
ffffffffc0205c34:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205c36:	4581                	li	a1,0
ffffffffc0205c38:	12000613          	li	a2,288
ffffffffc0205c3c:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205c3e:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205c40:	097010ef          	jal	ra,ffffffffc02074d6 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205c44:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205c46:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205c48:	100027f3          	csrr	a5,sstatus
ffffffffc0205c4c:	edd7f793          	andi	a5,a5,-291
ffffffffc0205c50:	1207e793          	ori	a5,a5,288
ffffffffc0205c54:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205c56:	860a                	mv	a2,sp
ffffffffc0205c58:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205c5c:	00000797          	auipc	a5,0x0
ffffffffc0205c60:	92e78793          	addi	a5,a5,-1746 # ffffffffc020558a <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205c64:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205c66:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205c68:	bd3ff0ef          	jal	ra,ffffffffc020583a <do_fork>
}
ffffffffc0205c6c:	70f2                	ld	ra,312(sp)
ffffffffc0205c6e:	7452                	ld	s0,304(sp)
ffffffffc0205c70:	74b2                	ld	s1,296(sp)
ffffffffc0205c72:	7912                	ld	s2,288(sp)
ffffffffc0205c74:	6131                	addi	sp,sp,320
ffffffffc0205c76:	8082                	ret

ffffffffc0205c78 <do_exit>:
do_exit(int error_code) {
ffffffffc0205c78:	7179                	addi	sp,sp,-48
ffffffffc0205c7a:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc0205c7c:	000d9717          	auipc	a4,0xd9
ffffffffc0205c80:	63c70713          	addi	a4,a4,1596 # ffffffffc02df2b8 <idleproc>
ffffffffc0205c84:	000d9917          	auipc	s2,0xd9
ffffffffc0205c88:	62c90913          	addi	s2,s2,1580 # ffffffffc02df2b0 <current>
ffffffffc0205c8c:	00093783          	ld	a5,0(s2)
ffffffffc0205c90:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc0205c92:	f406                	sd	ra,40(sp)
ffffffffc0205c94:	f022                	sd	s0,32(sp)
ffffffffc0205c96:	ec26                	sd	s1,24(sp)
ffffffffc0205c98:	e44e                	sd	s3,8(sp)
ffffffffc0205c9a:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc0205c9c:	0ce78d63          	beq	a5,a4,ffffffffc0205d76 <do_exit+0xfe>
    if (current == initproc) {
ffffffffc0205ca0:	000d9417          	auipc	s0,0xd9
ffffffffc0205ca4:	62040413          	addi	s0,s0,1568 # ffffffffc02df2c0 <initproc>
ffffffffc0205ca8:	6018                	ld	a4,0(s0)
ffffffffc0205caa:	12e78c63          	beq	a5,a4,ffffffffc0205de2 <do_exit+0x16a>
    struct mm_struct *mm = current->mm;
ffffffffc0205cae:	7784                	ld	s1,40(a5)
ffffffffc0205cb0:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc0205cb2:	c48d                	beqz	s1,ffffffffc0205cdc <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc0205cb4:	000d9797          	auipc	a5,0xd9
ffffffffc0205cb8:	65c78793          	addi	a5,a5,1628 # ffffffffc02df310 <boot_cr3>
ffffffffc0205cbc:	639c                	ld	a5,0(a5)
ffffffffc0205cbe:	577d                	li	a4,-1
ffffffffc0205cc0:	177e                	slli	a4,a4,0x3f
ffffffffc0205cc2:	83b1                	srli	a5,a5,0xc
ffffffffc0205cc4:	8fd9                	or	a5,a5,a4
ffffffffc0205cc6:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205cca:	589c                	lw	a5,48(s1)
ffffffffc0205ccc:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205cd0:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205cd2:	cf55                	beqz	a4,ffffffffc0205d8e <do_exit+0x116>
        current->mm = NULL;
ffffffffc0205cd4:	00093783          	ld	a5,0(s2)
ffffffffc0205cd8:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0205cdc:	00093783          	ld	a5,0(s2)
ffffffffc0205ce0:	470d                	li	a4,3
ffffffffc0205ce2:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205ce4:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205ce8:	100027f3          	csrr	a5,sstatus
ffffffffc0205cec:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205cee:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205cf0:	10079563          	bnez	a5,ffffffffc0205dfa <do_exit+0x182>
        proc = current->parent;
ffffffffc0205cf4:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205cf8:	800007b7          	lui	a5,0x80000
ffffffffc0205cfc:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0205cfe:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205d00:	0ec52703          	lw	a4,236(a0)
ffffffffc0205d04:	0ef70f63          	beq	a4,a5,ffffffffc0205e02 <do_exit+0x18a>
ffffffffc0205d08:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205d0c:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205d10:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205d12:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc0205d14:	7afc                	ld	a5,240(a3)
ffffffffc0205d16:	cb95                	beqz	a5,ffffffffc0205d4a <do_exit+0xd2>
            current->cptr = proc->optr;
ffffffffc0205d18:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_matrix_out_size+0xffffffff7fff44d0>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205d1c:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc0205d1e:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205d20:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0205d22:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205d26:	10e7b023          	sd	a4,256(a5)
ffffffffc0205d2a:	c311                	beqz	a4,ffffffffc0205d2e <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc0205d2c:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205d2e:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0205d30:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0205d32:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205d34:	fe9710e3          	bne	a4,s1,ffffffffc0205d14 <do_exit+0x9c>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205d38:	0ec52783          	lw	a5,236(a0)
ffffffffc0205d3c:	fd379ce3          	bne	a5,s3,ffffffffc0205d14 <do_exit+0x9c>
                    wakeup_proc(initproc);
ffffffffc0205d40:	5c3000ef          	jal	ra,ffffffffc0206b02 <wakeup_proc>
ffffffffc0205d44:	00093683          	ld	a3,0(s2)
ffffffffc0205d48:	b7f1                	j	ffffffffc0205d14 <do_exit+0x9c>
    if (flag) {
ffffffffc0205d4a:	020a1363          	bnez	s4,ffffffffc0205d70 <do_exit+0xf8>
    schedule();
ffffffffc0205d4e:	66f000ef          	jal	ra,ffffffffc0206bbc <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205d52:	00093783          	ld	a5,0(s2)
ffffffffc0205d56:	00004617          	auipc	a2,0x4
ffffffffc0205d5a:	baa60613          	addi	a2,a2,-1110 # ffffffffc0209900 <default_pmm_manager+0x16c8>
ffffffffc0205d5e:	21300593          	li	a1,531
ffffffffc0205d62:	43d4                	lw	a3,4(a5)
ffffffffc0205d64:	00004517          	auipc	a0,0x4
ffffffffc0205d68:	e3450513          	addi	a0,a0,-460 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc0205d6c:	f1cfa0ef          	jal	ra,ffffffffc0200488 <__panic>
        intr_enable();
ffffffffc0205d70:	8ddfa0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0205d74:	bfe9                	j	ffffffffc0205d4e <do_exit+0xd6>
        panic("idleproc exit.\n");
ffffffffc0205d76:	00004617          	auipc	a2,0x4
ffffffffc0205d7a:	b6a60613          	addi	a2,a2,-1174 # ffffffffc02098e0 <default_pmm_manager+0x16a8>
ffffffffc0205d7e:	1e700593          	li	a1,487
ffffffffc0205d82:	00004517          	auipc	a0,0x4
ffffffffc0205d86:	e1650513          	addi	a0,a0,-490 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc0205d8a:	efefa0ef          	jal	ra,ffffffffc0200488 <__panic>
            exit_mmap(mm);
ffffffffc0205d8e:	8526                	mv	a0,s1
ffffffffc0205d90:	e42fe0ef          	jal	ra,ffffffffc02043d2 <exit_mmap>
    return pa2page(PADDR(kva));
ffffffffc0205d94:	6c94                	ld	a3,24(s1)
ffffffffc0205d96:	c02007b7          	lui	a5,0xc0200
ffffffffc0205d9a:	06f6e763          	bltu	a3,a5,ffffffffc0205e08 <do_exit+0x190>
ffffffffc0205d9e:	000d9797          	auipc	a5,0xd9
ffffffffc0205da2:	56a78793          	addi	a5,a5,1386 # ffffffffc02df308 <va_pa_offset>
ffffffffc0205da6:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0205da8:	000d9797          	auipc	a5,0xd9
ffffffffc0205dac:	4f078793          	addi	a5,a5,1264 # ffffffffc02df298 <npage>
ffffffffc0205db0:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0205db2:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0205db4:	82b1                	srli	a3,a3,0xc
ffffffffc0205db6:	06f6f563          	bleu	a5,a3,ffffffffc0205e20 <do_exit+0x1a8>
    return &pages[PPN(pa) - nbase];
ffffffffc0205dba:	00005797          	auipc	a5,0x5
ffffffffc0205dbe:	afe78793          	addi	a5,a5,-1282 # ffffffffc020a8b8 <nbase>
ffffffffc0205dc2:	639c                	ld	a5,0(a5)
ffffffffc0205dc4:	000d9717          	auipc	a4,0xd9
ffffffffc0205dc8:	55470713          	addi	a4,a4,1364 # ffffffffc02df318 <pages>
ffffffffc0205dcc:	6308                	ld	a0,0(a4)
ffffffffc0205dce:	8e9d                	sub	a3,a3,a5
ffffffffc0205dd0:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0205dd2:	9536                	add	a0,a0,a3
ffffffffc0205dd4:	4585                	li	a1,1
ffffffffc0205dd6:	8e4fc0ef          	jal	ra,ffffffffc0201eba <free_pages>
            mm_destroy(mm);
ffffffffc0205dda:	8526                	mv	a0,s1
ffffffffc0205ddc:	c56fe0ef          	jal	ra,ffffffffc0204232 <mm_destroy>
ffffffffc0205de0:	bdd5                	j	ffffffffc0205cd4 <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc0205de2:	00004617          	auipc	a2,0x4
ffffffffc0205de6:	b0e60613          	addi	a2,a2,-1266 # ffffffffc02098f0 <default_pmm_manager+0x16b8>
ffffffffc0205dea:	1ea00593          	li	a1,490
ffffffffc0205dee:	00004517          	auipc	a0,0x4
ffffffffc0205df2:	daa50513          	addi	a0,a0,-598 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc0205df6:	e92fa0ef          	jal	ra,ffffffffc0200488 <__panic>
        intr_disable();
ffffffffc0205dfa:	859fa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0205dfe:	4a05                	li	s4,1
ffffffffc0205e00:	bdd5                	j	ffffffffc0205cf4 <do_exit+0x7c>
            wakeup_proc(proc);
ffffffffc0205e02:	501000ef          	jal	ra,ffffffffc0206b02 <wakeup_proc>
ffffffffc0205e06:	b709                	j	ffffffffc0205d08 <do_exit+0x90>
    return pa2page(PADDR(kva));
ffffffffc0205e08:	00002617          	auipc	a2,0x2
ffffffffc0205e0c:	4b860613          	addi	a2,a2,1208 # ffffffffc02082c0 <default_pmm_manager+0x88>
ffffffffc0205e10:	06e00593          	li	a1,110
ffffffffc0205e14:	00002517          	auipc	a0,0x2
ffffffffc0205e18:	49c50513          	addi	a0,a0,1180 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc0205e1c:	e6cfa0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205e20:	00002617          	auipc	a2,0x2
ffffffffc0205e24:	4c860613          	addi	a2,a2,1224 # ffffffffc02082e8 <default_pmm_manager+0xb0>
ffffffffc0205e28:	06200593          	li	a1,98
ffffffffc0205e2c:	00002517          	auipc	a0,0x2
ffffffffc0205e30:	48450513          	addi	a0,a0,1156 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc0205e34:	e54fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205e38 <do_wait.part.5>:
do_wait(int pid, int *code_store) {
ffffffffc0205e38:	7139                	addi	sp,sp,-64
ffffffffc0205e3a:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc0205e3c:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc0205e40:	f426                	sd	s1,40(sp)
ffffffffc0205e42:	f04a                	sd	s2,32(sp)
ffffffffc0205e44:	ec4e                	sd	s3,24(sp)
ffffffffc0205e46:	e456                	sd	s5,8(sp)
ffffffffc0205e48:	e05a                	sd	s6,0(sp)
ffffffffc0205e4a:	fc06                	sd	ra,56(sp)
ffffffffc0205e4c:	f822                	sd	s0,48(sp)
ffffffffc0205e4e:	89aa                	mv	s3,a0
ffffffffc0205e50:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc0205e52:	000d9917          	auipc	s2,0xd9
ffffffffc0205e56:	45e90913          	addi	s2,s2,1118 # ffffffffc02df2b0 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205e5a:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc0205e5c:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc0205e5e:	2a05                	addiw	s4,s4,1
    if (pid != 0) {
ffffffffc0205e60:	02098f63          	beqz	s3,ffffffffc0205e9e <do_wait.part.5+0x66>
        proc = find_proc(pid);
ffffffffc0205e64:	854e                	mv	a0,s3
ffffffffc0205e66:	979ff0ef          	jal	ra,ffffffffc02057de <find_proc>
ffffffffc0205e6a:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc0205e6c:	12050063          	beqz	a0,ffffffffc0205f8c <do_wait.part.5+0x154>
ffffffffc0205e70:	00093703          	ld	a4,0(s2)
ffffffffc0205e74:	711c                	ld	a5,32(a0)
ffffffffc0205e76:	10e79b63          	bne	a5,a4,ffffffffc0205f8c <do_wait.part.5+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205e7a:	411c                	lw	a5,0(a0)
ffffffffc0205e7c:	02978c63          	beq	a5,s1,ffffffffc0205eb4 <do_wait.part.5+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc0205e80:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc0205e84:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc0205e88:	535000ef          	jal	ra,ffffffffc0206bbc <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205e8c:	00093783          	ld	a5,0(s2)
ffffffffc0205e90:	0b07a783          	lw	a5,176(a5)
ffffffffc0205e94:	8b85                	andi	a5,a5,1
ffffffffc0205e96:	d7e9                	beqz	a5,ffffffffc0205e60 <do_wait.part.5+0x28>
            do_exit(-E_KILLED);
ffffffffc0205e98:	555d                	li	a0,-9
ffffffffc0205e9a:	ddfff0ef          	jal	ra,ffffffffc0205c78 <do_exit>
        proc = current->cptr;
ffffffffc0205e9e:	00093703          	ld	a4,0(s2)
ffffffffc0205ea2:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205ea4:	e409                	bnez	s0,ffffffffc0205eae <do_wait.part.5+0x76>
ffffffffc0205ea6:	a0dd                	j	ffffffffc0205f8c <do_wait.part.5+0x154>
ffffffffc0205ea8:	10043403          	ld	s0,256(s0)
ffffffffc0205eac:	d871                	beqz	s0,ffffffffc0205e80 <do_wait.part.5+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205eae:	401c                	lw	a5,0(s0)
ffffffffc0205eb0:	fe979ce3          	bne	a5,s1,ffffffffc0205ea8 <do_wait.part.5+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205eb4:	000d9797          	auipc	a5,0xd9
ffffffffc0205eb8:	40478793          	addi	a5,a5,1028 # ffffffffc02df2b8 <idleproc>
ffffffffc0205ebc:	639c                	ld	a5,0(a5)
ffffffffc0205ebe:	0c878d63          	beq	a5,s0,ffffffffc0205f98 <do_wait.part.5+0x160>
ffffffffc0205ec2:	000d9797          	auipc	a5,0xd9
ffffffffc0205ec6:	3fe78793          	addi	a5,a5,1022 # ffffffffc02df2c0 <initproc>
ffffffffc0205eca:	639c                	ld	a5,0(a5)
ffffffffc0205ecc:	0cf40663          	beq	s0,a5,ffffffffc0205f98 <do_wait.part.5+0x160>
    if (code_store != NULL) {
ffffffffc0205ed0:	000b0663          	beqz	s6,ffffffffc0205edc <do_wait.part.5+0xa4>
        *code_store = proc->exit_code;
ffffffffc0205ed4:	0e842783          	lw	a5,232(s0)
ffffffffc0205ed8:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205edc:	100027f3          	csrr	a5,sstatus
ffffffffc0205ee0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205ee2:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205ee4:	e7d5                	bnez	a5,ffffffffc0205f90 <do_wait.part.5+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205ee6:	6c70                	ld	a2,216(s0)
ffffffffc0205ee8:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc0205eea:	10043703          	ld	a4,256(s0)
ffffffffc0205eee:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0205ef0:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205ef2:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205ef4:	6470                	ld	a2,200(s0)
ffffffffc0205ef6:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0205ef8:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205efa:	e290                	sd	a2,0(a3)
ffffffffc0205efc:	c319                	beqz	a4,ffffffffc0205f02 <do_wait.part.5+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc0205efe:	ff7c                	sd	a5,248(a4)
ffffffffc0205f00:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc0205f02:	c3d1                	beqz	a5,ffffffffc0205f86 <do_wait.part.5+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc0205f04:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc0205f08:	000d9797          	auipc	a5,0xd9
ffffffffc0205f0c:	3c078793          	addi	a5,a5,960 # ffffffffc02df2c8 <nr_process>
ffffffffc0205f10:	439c                	lw	a5,0(a5)
ffffffffc0205f12:	37fd                	addiw	a5,a5,-1
ffffffffc0205f14:	000d9717          	auipc	a4,0xd9
ffffffffc0205f18:	3af72a23          	sw	a5,948(a4) # ffffffffc02df2c8 <nr_process>
    if (flag) {
ffffffffc0205f1c:	e1b5                	bnez	a1,ffffffffc0205f80 <do_wait.part.5+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205f1e:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0205f20:	c02007b7          	lui	a5,0xc0200
ffffffffc0205f24:	0af6e263          	bltu	a3,a5,ffffffffc0205fc8 <do_wait.part.5+0x190>
ffffffffc0205f28:	000d9797          	auipc	a5,0xd9
ffffffffc0205f2c:	3e078793          	addi	a5,a5,992 # ffffffffc02df308 <va_pa_offset>
ffffffffc0205f30:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0205f32:	000d9797          	auipc	a5,0xd9
ffffffffc0205f36:	36678793          	addi	a5,a5,870 # ffffffffc02df298 <npage>
ffffffffc0205f3a:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0205f3c:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0205f3e:	82b1                	srli	a3,a3,0xc
ffffffffc0205f40:	06f6f863          	bleu	a5,a3,ffffffffc0205fb0 <do_wait.part.5+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc0205f44:	00005797          	auipc	a5,0x5
ffffffffc0205f48:	97478793          	addi	a5,a5,-1676 # ffffffffc020a8b8 <nbase>
ffffffffc0205f4c:	639c                	ld	a5,0(a5)
ffffffffc0205f4e:	000d9717          	auipc	a4,0xd9
ffffffffc0205f52:	3ca70713          	addi	a4,a4,970 # ffffffffc02df318 <pages>
ffffffffc0205f56:	6308                	ld	a0,0(a4)
ffffffffc0205f58:	8e9d                	sub	a3,a3,a5
ffffffffc0205f5a:	069a                	slli	a3,a3,0x6
ffffffffc0205f5c:	9536                	add	a0,a0,a3
ffffffffc0205f5e:	4589                	li	a1,2
ffffffffc0205f60:	f5bfb0ef          	jal	ra,ffffffffc0201eba <free_pages>
    kfree(proc);
ffffffffc0205f64:	8522                	mv	a0,s0
ffffffffc0205f66:	d8dfb0ef          	jal	ra,ffffffffc0201cf2 <kfree>
    return 0;
ffffffffc0205f6a:	4501                	li	a0,0
}
ffffffffc0205f6c:	70e2                	ld	ra,56(sp)
ffffffffc0205f6e:	7442                	ld	s0,48(sp)
ffffffffc0205f70:	74a2                	ld	s1,40(sp)
ffffffffc0205f72:	7902                	ld	s2,32(sp)
ffffffffc0205f74:	69e2                	ld	s3,24(sp)
ffffffffc0205f76:	6a42                	ld	s4,16(sp)
ffffffffc0205f78:	6aa2                	ld	s5,8(sp)
ffffffffc0205f7a:	6b02                	ld	s6,0(sp)
ffffffffc0205f7c:	6121                	addi	sp,sp,64
ffffffffc0205f7e:	8082                	ret
        intr_enable();
ffffffffc0205f80:	eccfa0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0205f84:	bf69                	j	ffffffffc0205f1e <do_wait.part.5+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc0205f86:	701c                	ld	a5,32(s0)
ffffffffc0205f88:	fbf8                	sd	a4,240(a5)
ffffffffc0205f8a:	bfbd                	j	ffffffffc0205f08 <do_wait.part.5+0xd0>
    return -E_BAD_PROC;
ffffffffc0205f8c:	5579                	li	a0,-2
ffffffffc0205f8e:	bff9                	j	ffffffffc0205f6c <do_wait.part.5+0x134>
        intr_disable();
ffffffffc0205f90:	ec2fa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0205f94:	4585                	li	a1,1
ffffffffc0205f96:	bf81                	j	ffffffffc0205ee6 <do_wait.part.5+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc0205f98:	00004617          	auipc	a2,0x4
ffffffffc0205f9c:	9a860613          	addi	a2,a2,-1624 # ffffffffc0209940 <default_pmm_manager+0x1708>
ffffffffc0205fa0:	30d00593          	li	a1,781
ffffffffc0205fa4:	00004517          	auipc	a0,0x4
ffffffffc0205fa8:	bf450513          	addi	a0,a0,-1036 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc0205fac:	cdcfa0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205fb0:	00002617          	auipc	a2,0x2
ffffffffc0205fb4:	33860613          	addi	a2,a2,824 # ffffffffc02082e8 <default_pmm_manager+0xb0>
ffffffffc0205fb8:	06200593          	li	a1,98
ffffffffc0205fbc:	00002517          	auipc	a0,0x2
ffffffffc0205fc0:	2f450513          	addi	a0,a0,756 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc0205fc4:	cc4fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205fc8:	00002617          	auipc	a2,0x2
ffffffffc0205fcc:	2f860613          	addi	a2,a2,760 # ffffffffc02082c0 <default_pmm_manager+0x88>
ffffffffc0205fd0:	06e00593          	li	a1,110
ffffffffc0205fd4:	00002517          	auipc	a0,0x2
ffffffffc0205fd8:	2dc50513          	addi	a0,a0,732 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc0205fdc:	cacfa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205fe0 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0205fe0:	1141                	addi	sp,sp,-16
ffffffffc0205fe2:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205fe4:	f1dfb0ef          	jal	ra,ffffffffc0201f00 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0205fe8:	c4bfb0ef          	jal	ra,ffffffffc0201c32 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0205fec:	4601                	li	a2,0
ffffffffc0205fee:	4581                	li	a1,0
ffffffffc0205ff0:	fffff517          	auipc	a0,0xfffff
ffffffffc0205ff4:	64a50513          	addi	a0,a0,1610 # ffffffffc020563a <user_main>
ffffffffc0205ff8:	c31ff0ef          	jal	ra,ffffffffc0205c28 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205ffc:	08a05c63          	blez	a0,ffffffffc0206094 <init_main+0xb4>
        panic("create user_main failed.\n");
    }
    extern void check_sync(void);
    check_sync();                // check philosopher sync problem
ffffffffc0206000:	e9ffe0ef          	jal	ra,ffffffffc0204e9e <check_sync>

    while (do_wait(0, NULL) == 0) {
ffffffffc0206004:	a019                	j	ffffffffc020600a <init_main+0x2a>
        schedule();
ffffffffc0206006:	3b7000ef          	jal	ra,ffffffffc0206bbc <schedule>
    if (code_store != NULL) {
ffffffffc020600a:	4581                	li	a1,0
ffffffffc020600c:	4501                	li	a0,0
ffffffffc020600e:	e2bff0ef          	jal	ra,ffffffffc0205e38 <do_wait.part.5>
    while (do_wait(0, NULL) == 0) {
ffffffffc0206012:	d975                	beqz	a0,ffffffffc0206006 <init_main+0x26>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0206014:	00004517          	auipc	a0,0x4
ffffffffc0206018:	96c50513          	addi	a0,a0,-1684 # ffffffffc0209980 <default_pmm_manager+0x1748>
ffffffffc020601c:	976fa0ef          	jal	ra,ffffffffc0200192 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0206020:	000d9797          	auipc	a5,0xd9
ffffffffc0206024:	2a078793          	addi	a5,a5,672 # ffffffffc02df2c0 <initproc>
ffffffffc0206028:	639c                	ld	a5,0(a5)
ffffffffc020602a:	7bf8                	ld	a4,240(a5)
ffffffffc020602c:	e721                	bnez	a4,ffffffffc0206074 <init_main+0x94>
ffffffffc020602e:	7ff8                	ld	a4,248(a5)
ffffffffc0206030:	e331                	bnez	a4,ffffffffc0206074 <init_main+0x94>
ffffffffc0206032:	1007b703          	ld	a4,256(a5)
ffffffffc0206036:	ef1d                	bnez	a4,ffffffffc0206074 <init_main+0x94>
    assert(nr_process == 2);
ffffffffc0206038:	000d9717          	auipc	a4,0xd9
ffffffffc020603c:	29070713          	addi	a4,a4,656 # ffffffffc02df2c8 <nr_process>
ffffffffc0206040:	4314                	lw	a3,0(a4)
ffffffffc0206042:	4709                	li	a4,2
ffffffffc0206044:	0ae69463          	bne	a3,a4,ffffffffc02060ec <init_main+0x10c>
    return listelm->next;
ffffffffc0206048:	000d9697          	auipc	a3,0xd9
ffffffffc020604c:	50868693          	addi	a3,a3,1288 # ffffffffc02df550 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0206050:	6698                	ld	a4,8(a3)
ffffffffc0206052:	0c878793          	addi	a5,a5,200
ffffffffc0206056:	06f71b63          	bne	a4,a5,ffffffffc02060cc <init_main+0xec>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020605a:	629c                	ld	a5,0(a3)
ffffffffc020605c:	04f71863          	bne	a4,a5,ffffffffc02060ac <init_main+0xcc>

    cprintf("init check memory pass.\n");
ffffffffc0206060:	00004517          	auipc	a0,0x4
ffffffffc0206064:	a0850513          	addi	a0,a0,-1528 # ffffffffc0209a68 <default_pmm_manager+0x1830>
ffffffffc0206068:	92afa0ef          	jal	ra,ffffffffc0200192 <cprintf>
    return 0;
}
ffffffffc020606c:	60a2                	ld	ra,8(sp)
ffffffffc020606e:	4501                	li	a0,0
ffffffffc0206070:	0141                	addi	sp,sp,16
ffffffffc0206072:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0206074:	00004697          	auipc	a3,0x4
ffffffffc0206078:	93468693          	addi	a3,a3,-1740 # ffffffffc02099a8 <default_pmm_manager+0x1770>
ffffffffc020607c:	00002617          	auipc	a2,0x2
ffffffffc0206080:	a7460613          	addi	a2,a2,-1420 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0206084:	37300593          	li	a1,883
ffffffffc0206088:	00004517          	auipc	a0,0x4
ffffffffc020608c:	b1050513          	addi	a0,a0,-1264 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc0206090:	bf8fa0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("create user_main failed.\n");
ffffffffc0206094:	00004617          	auipc	a2,0x4
ffffffffc0206098:	8cc60613          	addi	a2,a2,-1844 # ffffffffc0209960 <default_pmm_manager+0x1728>
ffffffffc020609c:	36900593          	li	a1,873
ffffffffc02060a0:	00004517          	auipc	a0,0x4
ffffffffc02060a4:	af850513          	addi	a0,a0,-1288 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc02060a8:	be0fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02060ac:	00004697          	auipc	a3,0x4
ffffffffc02060b0:	98c68693          	addi	a3,a3,-1652 # ffffffffc0209a38 <default_pmm_manager+0x1800>
ffffffffc02060b4:	00002617          	auipc	a2,0x2
ffffffffc02060b8:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02060bc:	37600593          	li	a1,886
ffffffffc02060c0:	00004517          	auipc	a0,0x4
ffffffffc02060c4:	ad850513          	addi	a0,a0,-1320 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc02060c8:	bc0fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02060cc:	00004697          	auipc	a3,0x4
ffffffffc02060d0:	93c68693          	addi	a3,a3,-1732 # ffffffffc0209a08 <default_pmm_manager+0x17d0>
ffffffffc02060d4:	00002617          	auipc	a2,0x2
ffffffffc02060d8:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02060dc:	37500593          	li	a1,885
ffffffffc02060e0:	00004517          	auipc	a0,0x4
ffffffffc02060e4:	ab850513          	addi	a0,a0,-1352 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc02060e8:	ba0fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_process == 2);
ffffffffc02060ec:	00004697          	auipc	a3,0x4
ffffffffc02060f0:	90c68693          	addi	a3,a3,-1780 # ffffffffc02099f8 <default_pmm_manager+0x17c0>
ffffffffc02060f4:	00002617          	auipc	a2,0x2
ffffffffc02060f8:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc02060fc:	37400593          	li	a1,884
ffffffffc0206100:	00004517          	auipc	a0,0x4
ffffffffc0206104:	a9850513          	addi	a0,a0,-1384 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc0206108:	b80fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020610c <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020610c:	7135                	addi	sp,sp,-160
ffffffffc020610e:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0206110:	000d9a17          	auipc	s4,0xd9
ffffffffc0206114:	1a0a0a13          	addi	s4,s4,416 # ffffffffc02df2b0 <current>
ffffffffc0206118:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020611c:	e526                	sd	s1,136(sp)
ffffffffc020611e:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0206120:	7784                	ld	s1,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0206122:	fcce                	sd	s3,120(sp)
ffffffffc0206124:	f0da                	sd	s6,96(sp)
ffffffffc0206126:	89aa                	mv	s3,a0
ffffffffc0206128:	842e                	mv	s0,a1
ffffffffc020612a:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020612c:	4681                	li	a3,0
ffffffffc020612e:	862e                	mv	a2,a1
ffffffffc0206130:	85aa                	mv	a1,a0
ffffffffc0206132:	8526                	mv	a0,s1
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0206134:	ed06                	sd	ra,152(sp)
ffffffffc0206136:	e14a                	sd	s2,128(sp)
ffffffffc0206138:	f4d6                	sd	s5,104(sp)
ffffffffc020613a:	ecde                	sd	s7,88(sp)
ffffffffc020613c:	e8e2                	sd	s8,80(sp)
ffffffffc020613e:	e4e6                	sd	s9,72(sp)
ffffffffc0206140:	e0ea                	sd	s10,64(sp)
ffffffffc0206142:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0206144:	953fe0ef          	jal	ra,ffffffffc0204a96 <user_mem_check>
ffffffffc0206148:	46050763          	beqz	a0,ffffffffc02065b6 <do_execve+0x4aa>
    memset(local_name, 0, sizeof(local_name));
ffffffffc020614c:	4641                	li	a2,16
ffffffffc020614e:	4581                	li	a1,0
ffffffffc0206150:	1008                	addi	a0,sp,32
ffffffffc0206152:	384010ef          	jal	ra,ffffffffc02074d6 <memset>
    memcpy(local_name, name, len);
ffffffffc0206156:	47bd                	li	a5,15
ffffffffc0206158:	8622                	mv	a2,s0
ffffffffc020615a:	1887e963          	bltu	a5,s0,ffffffffc02062ec <do_execve+0x1e0>
ffffffffc020615e:	85ce                	mv	a1,s3
ffffffffc0206160:	1008                	addi	a0,sp,32
ffffffffc0206162:	386010ef          	jal	ra,ffffffffc02074e8 <memcpy>
    if (mm != NULL) {
ffffffffc0206166:	18048a63          	beqz	s1,ffffffffc02062fa <do_execve+0x1ee>
        cputs("mm != NULL");
ffffffffc020616a:	00003517          	auipc	a0,0x3
ffffffffc020616e:	8be50513          	addi	a0,a0,-1858 # ffffffffc0208a28 <default_pmm_manager+0x7f0>
ffffffffc0206172:	858fa0ef          	jal	ra,ffffffffc02001ca <cputs>
        lcr3(boot_cr3);
ffffffffc0206176:	000d9797          	auipc	a5,0xd9
ffffffffc020617a:	19a78793          	addi	a5,a5,410 # ffffffffc02df310 <boot_cr3>
ffffffffc020617e:	639c                	ld	a5,0(a5)
ffffffffc0206180:	577d                	li	a4,-1
ffffffffc0206182:	177e                	slli	a4,a4,0x3f
ffffffffc0206184:	83b1                	srli	a5,a5,0xc
ffffffffc0206186:	8fd9                	or	a5,a5,a4
ffffffffc0206188:	18079073          	csrw	satp,a5
ffffffffc020618c:	589c                	lw	a5,48(s1)
ffffffffc020618e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0206192:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc0206194:	2c070163          	beqz	a4,ffffffffc0206456 <do_execve+0x34a>
        current->mm = NULL;
ffffffffc0206198:	000a3783          	ld	a5,0(s4)
ffffffffc020619c:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc02061a0:	f07fd0ef          	jal	ra,ffffffffc02040a6 <mm_create>
ffffffffc02061a4:	84aa                	mv	s1,a0
ffffffffc02061a6:	18050263          	beqz	a0,ffffffffc020632a <do_execve+0x21e>
    if (setup_pgdir(mm) != 0) {
ffffffffc02061aa:	0561                	addi	a0,a0,24
ffffffffc02061ac:	d10ff0ef          	jal	ra,ffffffffc02056bc <setup_pgdir.isra.2>
ffffffffc02061b0:	16051663          	bnez	a0,ffffffffc020631c <do_execve+0x210>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02061b4:	000b2703          	lw	a4,0(s6)
ffffffffc02061b8:	464c47b7          	lui	a5,0x464c4
ffffffffc02061bc:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_matrix_out_size+0x464b894f>
ffffffffc02061c0:	24f71363          	bne	a4,a5,ffffffffc0206406 <do_execve+0x2fa>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02061c4:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02061c8:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02061cc:	00371793          	slli	a5,a4,0x3
ffffffffc02061d0:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02061d2:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02061d4:	078e                	slli	a5,a5,0x3
ffffffffc02061d6:	97a2                	add	a5,a5,s0
ffffffffc02061d8:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc02061da:	02f47b63          	bleu	a5,s0,ffffffffc0206210 <do_execve+0x104>
    return KADDR(page2pa(page));
ffffffffc02061de:	5bfd                	li	s7,-1
ffffffffc02061e0:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc02061e4:	000d9d97          	auipc	s11,0xd9
ffffffffc02061e8:	134d8d93          	addi	s11,s11,308 # ffffffffc02df318 <pages>
ffffffffc02061ec:	00004d17          	auipc	s10,0x4
ffffffffc02061f0:	6ccd0d13          	addi	s10,s10,1740 # ffffffffc020a8b8 <nbase>
    return KADDR(page2pa(page));
ffffffffc02061f4:	e43e                	sd	a5,8(sp)
ffffffffc02061f6:	000d9c97          	auipc	s9,0xd9
ffffffffc02061fa:	0a2c8c93          	addi	s9,s9,162 # ffffffffc02df298 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc02061fe:	4018                	lw	a4,0(s0)
ffffffffc0206200:	4785                	li	a5,1
ffffffffc0206202:	12f70663          	beq	a4,a5,ffffffffc020632e <do_execve+0x222>
    for (; ph < ph_end; ph ++) {
ffffffffc0206206:	67e2                	ld	a5,24(sp)
ffffffffc0206208:	03840413          	addi	s0,s0,56
ffffffffc020620c:	fef469e3          	bltu	s0,a5,ffffffffc02061fe <do_execve+0xf2>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0206210:	4701                	li	a4,0
ffffffffc0206212:	46ad                	li	a3,11
ffffffffc0206214:	00100637          	lui	a2,0x100
ffffffffc0206218:	7ff005b7          	lui	a1,0x7ff00
ffffffffc020621c:	8526                	mv	a0,s1
ffffffffc020621e:	866fe0ef          	jal	ra,ffffffffc0204284 <mm_map>
ffffffffc0206222:	89aa                	mv	s3,a0
ffffffffc0206224:	1c051d63          	bnez	a0,ffffffffc02063fe <do_execve+0x2f2>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0206228:	6c88                	ld	a0,24(s1)
ffffffffc020622a:	467d                	li	a2,31
ffffffffc020622c:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0206230:	8a8fd0ef          	jal	ra,ffffffffc02032d8 <pgdir_alloc_page>
ffffffffc0206234:	44050563          	beqz	a0,ffffffffc020667e <do_execve+0x572>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0206238:	6c88                	ld	a0,24(s1)
ffffffffc020623a:	467d                	li	a2,31
ffffffffc020623c:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0206240:	898fd0ef          	jal	ra,ffffffffc02032d8 <pgdir_alloc_page>
ffffffffc0206244:	40050d63          	beqz	a0,ffffffffc020665e <do_execve+0x552>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0206248:	6c88                	ld	a0,24(s1)
ffffffffc020624a:	467d                	li	a2,31
ffffffffc020624c:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0206250:	888fd0ef          	jal	ra,ffffffffc02032d8 <pgdir_alloc_page>
ffffffffc0206254:	3e050563          	beqz	a0,ffffffffc020663e <do_execve+0x532>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0206258:	6c88                	ld	a0,24(s1)
ffffffffc020625a:	467d                	li	a2,31
ffffffffc020625c:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0206260:	878fd0ef          	jal	ra,ffffffffc02032d8 <pgdir_alloc_page>
ffffffffc0206264:	3a050d63          	beqz	a0,ffffffffc020661e <do_execve+0x512>
    mm->mm_count += 1;
ffffffffc0206268:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc020626a:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc020626e:	6c94                	ld	a3,24(s1)
ffffffffc0206270:	2785                	addiw	a5,a5,1
ffffffffc0206272:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0206274:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0206276:	c02007b7          	lui	a5,0xc0200
ffffffffc020627a:	38f6e663          	bltu	a3,a5,ffffffffc0206606 <do_execve+0x4fa>
ffffffffc020627e:	000d9797          	auipc	a5,0xd9
ffffffffc0206282:	08a78793          	addi	a5,a5,138 # ffffffffc02df308 <va_pa_offset>
ffffffffc0206286:	639c                	ld	a5,0(a5)
ffffffffc0206288:	577d                	li	a4,-1
ffffffffc020628a:	177e                	slli	a4,a4,0x3f
ffffffffc020628c:	8e9d                	sub	a3,a3,a5
ffffffffc020628e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0206292:	f654                	sd	a3,168(a2)
ffffffffc0206294:	8fd9                	or	a5,a5,a4
ffffffffc0206296:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc020629a:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc020629c:	4581                	li	a1,0
ffffffffc020629e:	12000613          	li	a2,288
ffffffffc02062a2:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc02062a4:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02062a8:	22e010ef          	jal	ra,ffffffffc02074d6 <memset>
    tf->epc = elf->e_entry;
ffffffffc02062ac:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp = USTACKTOP;
ffffffffc02062b0:	4785                	li	a5,1
    set_proc_name(current, local_name);
ffffffffc02062b2:	000a3503          	ld	a0,0(s4)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc02062b6:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp = USTACKTOP;
ffffffffc02062ba:	07fe                	slli	a5,a5,0x1f
ffffffffc02062bc:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc02062be:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc02062c2:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc02062c6:	100c                	addi	a1,sp,32
ffffffffc02062c8:	c80ff0ef          	jal	ra,ffffffffc0205748 <set_proc_name>
}
ffffffffc02062cc:	60ea                	ld	ra,152(sp)
ffffffffc02062ce:	644a                	ld	s0,144(sp)
ffffffffc02062d0:	854e                	mv	a0,s3
ffffffffc02062d2:	64aa                	ld	s1,136(sp)
ffffffffc02062d4:	690a                	ld	s2,128(sp)
ffffffffc02062d6:	79e6                	ld	s3,120(sp)
ffffffffc02062d8:	7a46                	ld	s4,112(sp)
ffffffffc02062da:	7aa6                	ld	s5,104(sp)
ffffffffc02062dc:	7b06                	ld	s6,96(sp)
ffffffffc02062de:	6be6                	ld	s7,88(sp)
ffffffffc02062e0:	6c46                	ld	s8,80(sp)
ffffffffc02062e2:	6ca6                	ld	s9,72(sp)
ffffffffc02062e4:	6d06                	ld	s10,64(sp)
ffffffffc02062e6:	7de2                	ld	s11,56(sp)
ffffffffc02062e8:	610d                	addi	sp,sp,160
ffffffffc02062ea:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc02062ec:	463d                	li	a2,15
ffffffffc02062ee:	85ce                	mv	a1,s3
ffffffffc02062f0:	1008                	addi	a0,sp,32
ffffffffc02062f2:	1f6010ef          	jal	ra,ffffffffc02074e8 <memcpy>
    if (mm != NULL) {
ffffffffc02062f6:	e6049ae3          	bnez	s1,ffffffffc020616a <do_execve+0x5e>
    if (current->mm != NULL) {
ffffffffc02062fa:	000a3783          	ld	a5,0(s4)
ffffffffc02062fe:	779c                	ld	a5,40(a5)
ffffffffc0206300:	ea0780e3          	beqz	a5,ffffffffc02061a0 <do_execve+0x94>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0206304:	00003617          	auipc	a2,0x3
ffffffffc0206308:	45460613          	addi	a2,a2,1108 # ffffffffc0209758 <default_pmm_manager+0x1520>
ffffffffc020630c:	21d00593          	li	a1,541
ffffffffc0206310:	00004517          	auipc	a0,0x4
ffffffffc0206314:	88850513          	addi	a0,a0,-1912 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc0206318:	970fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    mm_destroy(mm);
ffffffffc020631c:	8526                	mv	a0,s1
ffffffffc020631e:	f15fd0ef          	jal	ra,ffffffffc0204232 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0206322:	59f1                	li	s3,-4
    do_exit(ret);
ffffffffc0206324:	854e                	mv	a0,s3
ffffffffc0206326:	953ff0ef          	jal	ra,ffffffffc0205c78 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc020632a:	59f1                	li	s3,-4
ffffffffc020632c:	bfe5                	j	ffffffffc0206324 <do_execve+0x218>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc020632e:	7410                	ld	a2,40(s0)
ffffffffc0206330:	701c                	ld	a5,32(s0)
ffffffffc0206332:	28f66463          	bltu	a2,a5,ffffffffc02065ba <do_execve+0x4ae>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0206336:	405c                	lw	a5,4(s0)
ffffffffc0206338:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc020633c:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0206340:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0206342:	16071463          	bnez	a4,ffffffffc02064aa <do_execve+0x39e>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0206346:	4745                	li	a4,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0206348:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc020634a:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc020634c:	c789                	beqz	a5,ffffffffc0206356 <do_execve+0x24a>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc020634e:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0206350:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0206354:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0206356:	0026f793          	andi	a5,a3,2
ffffffffc020635a:	14079e63          	bnez	a5,ffffffffc02064b6 <do_execve+0x3aa>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc020635e:	0046f793          	andi	a5,a3,4
ffffffffc0206362:	c789                	beqz	a5,ffffffffc020636c <do_execve+0x260>
ffffffffc0206364:	6782                	ld	a5,0(sp)
ffffffffc0206366:	0087e793          	ori	a5,a5,8
ffffffffc020636a:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc020636c:	680c                	ld	a1,16(s0)
ffffffffc020636e:	4701                	li	a4,0
ffffffffc0206370:	8526                	mv	a0,s1
ffffffffc0206372:	f13fd0ef          	jal	ra,ffffffffc0204284 <mm_map>
ffffffffc0206376:	89aa                	mv	s3,a0
ffffffffc0206378:	e159                	bnez	a0,ffffffffc02063fe <do_execve+0x2f2>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc020637a:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc020637e:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0206382:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0206386:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0206388:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc020638a:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc020638c:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0206390:	053bef63          	bltu	s7,s3,ffffffffc02063ee <do_execve+0x2e2>
ffffffffc0206394:	ac39                	j	ffffffffc02065b2 <do_execve+0x4a6>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0206396:	6785                	lui	a5,0x1
ffffffffc0206398:	418b8533          	sub	a0,s7,s8
ffffffffc020639c:	9c3e                	add	s8,s8,a5
ffffffffc020639e:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc02063a2:	0189f463          	bleu	s8,s3,ffffffffc02063aa <do_execve+0x29e>
                size -= la - end;
ffffffffc02063a6:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc02063aa:	000db683          	ld	a3,0(s11)
ffffffffc02063ae:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc02063b2:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc02063b4:	40d906b3          	sub	a3,s2,a3
ffffffffc02063b8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02063ba:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc02063be:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc02063c0:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc02063c4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02063c6:	1ec5fc63          	bleu	a2,a1,ffffffffc02065be <do_execve+0x4b2>
ffffffffc02063ca:	000d9797          	auipc	a5,0xd9
ffffffffc02063ce:	f3e78793          	addi	a5,a5,-194 # ffffffffc02df308 <va_pa_offset>
ffffffffc02063d2:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc02063d6:	85d6                	mv	a1,s5
ffffffffc02063d8:	8642                	mv	a2,a6
ffffffffc02063da:	96c6                	add	a3,a3,a7
ffffffffc02063dc:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc02063de:	9bc2                	add	s7,s7,a6
ffffffffc02063e0:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc02063e2:	106010ef          	jal	ra,ffffffffc02074e8 <memcpy>
            start += size, from += size;
ffffffffc02063e6:	6842                	ld	a6,16(sp)
ffffffffc02063e8:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc02063ea:	0d3bf963          	bleu	s3,s7,ffffffffc02064bc <do_execve+0x3b0>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc02063ee:	6c88                	ld	a0,24(s1)
ffffffffc02063f0:	6602                	ld	a2,0(sp)
ffffffffc02063f2:	85e2                	mv	a1,s8
ffffffffc02063f4:	ee5fc0ef          	jal	ra,ffffffffc02032d8 <pgdir_alloc_page>
ffffffffc02063f8:	892a                	mv	s2,a0
ffffffffc02063fa:	fd51                	bnez	a0,ffffffffc0206396 <do_execve+0x28a>
        ret = -E_NO_MEM;
ffffffffc02063fc:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc02063fe:	8526                	mv	a0,s1
ffffffffc0206400:	fd3fd0ef          	jal	ra,ffffffffc02043d2 <exit_mmap>
ffffffffc0206404:	a011                	j	ffffffffc0206408 <do_execve+0x2fc>
        ret = -E_INVAL_ELF;
ffffffffc0206406:	59e1                	li	s3,-8
    return pa2page(PADDR(kva));
ffffffffc0206408:	6c94                	ld	a3,24(s1)
ffffffffc020640a:	c02007b7          	lui	a5,0xc0200
ffffffffc020640e:	1cf6e463          	bltu	a3,a5,ffffffffc02065d6 <do_execve+0x4ca>
ffffffffc0206412:	000d9797          	auipc	a5,0xd9
ffffffffc0206416:	ef678793          	addi	a5,a5,-266 # ffffffffc02df308 <va_pa_offset>
ffffffffc020641a:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020641c:	000d9797          	auipc	a5,0xd9
ffffffffc0206420:	e7c78793          	addi	a5,a5,-388 # ffffffffc02df298 <npage>
ffffffffc0206424:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0206426:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0206428:	82b1                	srli	a3,a3,0xc
ffffffffc020642a:	1cf6f263          	bleu	a5,a3,ffffffffc02065ee <do_execve+0x4e2>
    return &pages[PPN(pa) - nbase];
ffffffffc020642e:	00004797          	auipc	a5,0x4
ffffffffc0206432:	48a78793          	addi	a5,a5,1162 # ffffffffc020a8b8 <nbase>
ffffffffc0206436:	639c                	ld	a5,0(a5)
ffffffffc0206438:	000d9717          	auipc	a4,0xd9
ffffffffc020643c:	ee070713          	addi	a4,a4,-288 # ffffffffc02df318 <pages>
ffffffffc0206440:	6308                	ld	a0,0(a4)
ffffffffc0206442:	8e9d                	sub	a3,a3,a5
ffffffffc0206444:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0206446:	9536                	add	a0,a0,a3
ffffffffc0206448:	4585                	li	a1,1
ffffffffc020644a:	a71fb0ef          	jal	ra,ffffffffc0201eba <free_pages>
    mm_destroy(mm);
ffffffffc020644e:	8526                	mv	a0,s1
ffffffffc0206450:	de3fd0ef          	jal	ra,ffffffffc0204232 <mm_destroy>
    return ret;
ffffffffc0206454:	bdc1                	j	ffffffffc0206324 <do_execve+0x218>
            exit_mmap(mm);
ffffffffc0206456:	8526                	mv	a0,s1
ffffffffc0206458:	f7bfd0ef          	jal	ra,ffffffffc02043d2 <exit_mmap>
    return pa2page(PADDR(kva));
ffffffffc020645c:	6c94                	ld	a3,24(s1)
ffffffffc020645e:	c02007b7          	lui	a5,0xc0200
ffffffffc0206462:	16f6ea63          	bltu	a3,a5,ffffffffc02065d6 <do_execve+0x4ca>
ffffffffc0206466:	000d9797          	auipc	a5,0xd9
ffffffffc020646a:	ea278793          	addi	a5,a5,-350 # ffffffffc02df308 <va_pa_offset>
ffffffffc020646e:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0206470:	000d9797          	auipc	a5,0xd9
ffffffffc0206474:	e2878793          	addi	a5,a5,-472 # ffffffffc02df298 <npage>
ffffffffc0206478:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc020647a:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc020647c:	82b1                	srli	a3,a3,0xc
ffffffffc020647e:	16f6f863          	bleu	a5,a3,ffffffffc02065ee <do_execve+0x4e2>
    return &pages[PPN(pa) - nbase];
ffffffffc0206482:	00004797          	auipc	a5,0x4
ffffffffc0206486:	43678793          	addi	a5,a5,1078 # ffffffffc020a8b8 <nbase>
ffffffffc020648a:	639c                	ld	a5,0(a5)
ffffffffc020648c:	000d9717          	auipc	a4,0xd9
ffffffffc0206490:	e8c70713          	addi	a4,a4,-372 # ffffffffc02df318 <pages>
ffffffffc0206494:	6308                	ld	a0,0(a4)
ffffffffc0206496:	8e9d                	sub	a3,a3,a5
ffffffffc0206498:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc020649a:	9536                	add	a0,a0,a3
ffffffffc020649c:	4585                	li	a1,1
ffffffffc020649e:	a1dfb0ef          	jal	ra,ffffffffc0201eba <free_pages>
            mm_destroy(mm);
ffffffffc02064a2:	8526                	mv	a0,s1
ffffffffc02064a4:	d8ffd0ef          	jal	ra,ffffffffc0204232 <mm_destroy>
ffffffffc02064a8:	b9c5                	j	ffffffffc0206198 <do_execve+0x8c>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02064aa:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc02064ae:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02064b0:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc02064b2:	e8079ee3          	bnez	a5,ffffffffc020634e <do_execve+0x242>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc02064b6:	47dd                	li	a5,23
ffffffffc02064b8:	e03e                	sd	a5,0(sp)
ffffffffc02064ba:	b555                	j	ffffffffc020635e <do_execve+0x252>
ffffffffc02064bc:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc02064c0:	7414                	ld	a3,40(s0)
ffffffffc02064c2:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc02064c4:	098bf163          	bleu	s8,s7,ffffffffc0206546 <do_execve+0x43a>
            if (start == end) {
ffffffffc02064c8:	d3798fe3          	beq	s3,s7,ffffffffc0206206 <do_execve+0xfa>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc02064cc:	6505                	lui	a0,0x1
ffffffffc02064ce:	955e                	add	a0,a0,s7
ffffffffc02064d0:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc02064d4:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc02064d8:	0d89fa63          	bleu	s8,s3,ffffffffc02065ac <do_execve+0x4a0>
    return page - pages + nbase;
ffffffffc02064dc:	000db683          	ld	a3,0(s11)
ffffffffc02064e0:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc02064e4:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc02064e6:	40d906b3          	sub	a3,s2,a3
ffffffffc02064ea:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02064ec:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc02064f0:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc02064f2:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc02064f6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02064f8:	0cc5f363          	bleu	a2,a1,ffffffffc02065be <do_execve+0x4b2>
ffffffffc02064fc:	000d9617          	auipc	a2,0xd9
ffffffffc0206500:	e0c60613          	addi	a2,a2,-500 # ffffffffc02df308 <va_pa_offset>
ffffffffc0206504:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0206508:	4581                	li	a1,0
ffffffffc020650a:	8656                	mv	a2,s5
ffffffffc020650c:	96c2                	add	a3,a3,a6
ffffffffc020650e:	9536                	add	a0,a0,a3
ffffffffc0206510:	7c7000ef          	jal	ra,ffffffffc02074d6 <memset>
            start += size;
ffffffffc0206514:	015b8733          	add	a4,s7,s5
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0206518:	0389f463          	bleu	s8,s3,ffffffffc0206540 <do_execve+0x434>
ffffffffc020651c:	cee985e3          	beq	s3,a4,ffffffffc0206206 <do_execve+0xfa>
ffffffffc0206520:	00003697          	auipc	a3,0x3
ffffffffc0206524:	26068693          	addi	a3,a3,608 # ffffffffc0209780 <default_pmm_manager+0x1548>
ffffffffc0206528:	00001617          	auipc	a2,0x1
ffffffffc020652c:	5c860613          	addi	a2,a2,1480 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0206530:	27200593          	li	a1,626
ffffffffc0206534:	00003517          	auipc	a0,0x3
ffffffffc0206538:	66450513          	addi	a0,a0,1636 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc020653c:	f4df90ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0206540:	ff8710e3          	bne	a4,s8,ffffffffc0206520 <do_execve+0x414>
ffffffffc0206544:	8be2                	mv	s7,s8
ffffffffc0206546:	000d9a97          	auipc	s5,0xd9
ffffffffc020654a:	dc2a8a93          	addi	s5,s5,-574 # ffffffffc02df308 <va_pa_offset>
        while (start < end) {
ffffffffc020654e:	053be763          	bltu	s7,s3,ffffffffc020659c <do_execve+0x490>
ffffffffc0206552:	b955                	j	ffffffffc0206206 <do_execve+0xfa>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0206554:	6785                	lui	a5,0x1
ffffffffc0206556:	418b8533          	sub	a0,s7,s8
ffffffffc020655a:	9c3e                	add	s8,s8,a5
ffffffffc020655c:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc0206560:	0189f463          	bleu	s8,s3,ffffffffc0206568 <do_execve+0x45c>
                size -= la - end;
ffffffffc0206564:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0206568:	000db683          	ld	a3,0(s11)
ffffffffc020656c:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0206570:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0206572:	40d906b3          	sub	a3,s2,a3
ffffffffc0206576:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0206578:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc020657c:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc020657e:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0206582:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0206584:	02b87d63          	bleu	a1,a6,ffffffffc02065be <do_execve+0x4b2>
ffffffffc0206588:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc020658c:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc020658e:	4581                	li	a1,0
ffffffffc0206590:	96c2                	add	a3,a3,a6
ffffffffc0206592:	9536                	add	a0,a0,a3
ffffffffc0206594:	743000ef          	jal	ra,ffffffffc02074d6 <memset>
        while (start < end) {
ffffffffc0206598:	c73bf7e3          	bleu	s3,s7,ffffffffc0206206 <do_execve+0xfa>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc020659c:	6c88                	ld	a0,24(s1)
ffffffffc020659e:	6602                	ld	a2,0(sp)
ffffffffc02065a0:	85e2                	mv	a1,s8
ffffffffc02065a2:	d37fc0ef          	jal	ra,ffffffffc02032d8 <pgdir_alloc_page>
ffffffffc02065a6:	892a                	mv	s2,a0
ffffffffc02065a8:	f555                	bnez	a0,ffffffffc0206554 <do_execve+0x448>
ffffffffc02065aa:	bd89                	j	ffffffffc02063fc <do_execve+0x2f0>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc02065ac:	417c0ab3          	sub	s5,s8,s7
ffffffffc02065b0:	b735                	j	ffffffffc02064dc <do_execve+0x3d0>
        while (start < end) {
ffffffffc02065b2:	89de                	mv	s3,s7
ffffffffc02065b4:	b731                	j	ffffffffc02064c0 <do_execve+0x3b4>
        return -E_INVAL;
ffffffffc02065b6:	59f5                	li	s3,-3
ffffffffc02065b8:	bb11                	j	ffffffffc02062cc <do_execve+0x1c0>
            ret = -E_INVAL_ELF;
ffffffffc02065ba:	59e1                	li	s3,-8
ffffffffc02065bc:	b589                	j	ffffffffc02063fe <do_execve+0x2f2>
ffffffffc02065be:	00002617          	auipc	a2,0x2
ffffffffc02065c2:	cca60613          	addi	a2,a2,-822 # ffffffffc0208288 <default_pmm_manager+0x50>
ffffffffc02065c6:	06900593          	li	a1,105
ffffffffc02065ca:	00002517          	auipc	a0,0x2
ffffffffc02065ce:	ce650513          	addi	a0,a0,-794 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc02065d2:	eb7f90ef          	jal	ra,ffffffffc0200488 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02065d6:	00002617          	auipc	a2,0x2
ffffffffc02065da:	cea60613          	addi	a2,a2,-790 # ffffffffc02082c0 <default_pmm_manager+0x88>
ffffffffc02065de:	06e00593          	li	a1,110
ffffffffc02065e2:	00002517          	auipc	a0,0x2
ffffffffc02065e6:	cce50513          	addi	a0,a0,-818 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc02065ea:	e9ff90ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02065ee:	00002617          	auipc	a2,0x2
ffffffffc02065f2:	cfa60613          	addi	a2,a2,-774 # ffffffffc02082e8 <default_pmm_manager+0xb0>
ffffffffc02065f6:	06200593          	li	a1,98
ffffffffc02065fa:	00002517          	auipc	a0,0x2
ffffffffc02065fe:	cb650513          	addi	a0,a0,-842 # ffffffffc02082b0 <default_pmm_manager+0x78>
ffffffffc0206602:	e87f90ef          	jal	ra,ffffffffc0200488 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0206606:	00002617          	auipc	a2,0x2
ffffffffc020660a:	cba60613          	addi	a2,a2,-838 # ffffffffc02082c0 <default_pmm_manager+0x88>
ffffffffc020660e:	28d00593          	li	a1,653
ffffffffc0206612:	00003517          	auipc	a0,0x3
ffffffffc0206616:	58650513          	addi	a0,a0,1414 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc020661a:	e6ff90ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc020661e:	00003697          	auipc	a3,0x3
ffffffffc0206622:	27a68693          	addi	a3,a3,634 # ffffffffc0209898 <default_pmm_manager+0x1660>
ffffffffc0206626:	00001617          	auipc	a2,0x1
ffffffffc020662a:	4ca60613          	addi	a2,a2,1226 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020662e:	28800593          	li	a1,648
ffffffffc0206632:	00003517          	auipc	a0,0x3
ffffffffc0206636:	56650513          	addi	a0,a0,1382 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc020663a:	e4ff90ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc020663e:	00003697          	auipc	a3,0x3
ffffffffc0206642:	21268693          	addi	a3,a3,530 # ffffffffc0209850 <default_pmm_manager+0x1618>
ffffffffc0206646:	00001617          	auipc	a2,0x1
ffffffffc020664a:	4aa60613          	addi	a2,a2,1194 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020664e:	28700593          	li	a1,647
ffffffffc0206652:	00003517          	auipc	a0,0x3
ffffffffc0206656:	54650513          	addi	a0,a0,1350 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc020665a:	e2ff90ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc020665e:	00003697          	auipc	a3,0x3
ffffffffc0206662:	1aa68693          	addi	a3,a3,426 # ffffffffc0209808 <default_pmm_manager+0x15d0>
ffffffffc0206666:	00001617          	auipc	a2,0x1
ffffffffc020666a:	48a60613          	addi	a2,a2,1162 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020666e:	28600593          	li	a1,646
ffffffffc0206672:	00003517          	auipc	a0,0x3
ffffffffc0206676:	52650513          	addi	a0,a0,1318 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc020667a:	e0ff90ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc020667e:	00003697          	auipc	a3,0x3
ffffffffc0206682:	14268693          	addi	a3,a3,322 # ffffffffc02097c0 <default_pmm_manager+0x1588>
ffffffffc0206686:	00001617          	auipc	a2,0x1
ffffffffc020668a:	46a60613          	addi	a2,a2,1130 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020668e:	28500593          	li	a1,645
ffffffffc0206692:	00003517          	auipc	a0,0x3
ffffffffc0206696:	50650513          	addi	a0,a0,1286 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc020669a:	deff90ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020669e <do_yield>:
    current->need_resched = 1;
ffffffffc020669e:	000d9797          	auipc	a5,0xd9
ffffffffc02066a2:	c1278793          	addi	a5,a5,-1006 # ffffffffc02df2b0 <current>
ffffffffc02066a6:	639c                	ld	a5,0(a5)
ffffffffc02066a8:	4705                	li	a4,1
}
ffffffffc02066aa:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc02066ac:	ef98                	sd	a4,24(a5)
}
ffffffffc02066ae:	8082                	ret

ffffffffc02066b0 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc02066b0:	1101                	addi	sp,sp,-32
ffffffffc02066b2:	e822                	sd	s0,16(sp)
ffffffffc02066b4:	e426                	sd	s1,8(sp)
ffffffffc02066b6:	ec06                	sd	ra,24(sp)
ffffffffc02066b8:	842e                	mv	s0,a1
ffffffffc02066ba:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc02066bc:	cd81                	beqz	a1,ffffffffc02066d4 <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc02066be:	000d9797          	auipc	a5,0xd9
ffffffffc02066c2:	bf278793          	addi	a5,a5,-1038 # ffffffffc02df2b0 <current>
ffffffffc02066c6:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc02066c8:	4685                	li	a3,1
ffffffffc02066ca:	4611                	li	a2,4
ffffffffc02066cc:	7788                	ld	a0,40(a5)
ffffffffc02066ce:	bc8fe0ef          	jal	ra,ffffffffc0204a96 <user_mem_check>
ffffffffc02066d2:	c909                	beqz	a0,ffffffffc02066e4 <do_wait+0x34>
ffffffffc02066d4:	85a2                	mv	a1,s0
}
ffffffffc02066d6:	6442                	ld	s0,16(sp)
ffffffffc02066d8:	60e2                	ld	ra,24(sp)
ffffffffc02066da:	8526                	mv	a0,s1
ffffffffc02066dc:	64a2                	ld	s1,8(sp)
ffffffffc02066de:	6105                	addi	sp,sp,32
ffffffffc02066e0:	f58ff06f          	j	ffffffffc0205e38 <do_wait.part.5>
ffffffffc02066e4:	60e2                	ld	ra,24(sp)
ffffffffc02066e6:	6442                	ld	s0,16(sp)
ffffffffc02066e8:	64a2                	ld	s1,8(sp)
ffffffffc02066ea:	5575                	li	a0,-3
ffffffffc02066ec:	6105                	addi	sp,sp,32
ffffffffc02066ee:	8082                	ret

ffffffffc02066f0 <do_kill>:
do_kill(int pid) {
ffffffffc02066f0:	1141                	addi	sp,sp,-16
ffffffffc02066f2:	e406                	sd	ra,8(sp)
ffffffffc02066f4:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc02066f6:	8e8ff0ef          	jal	ra,ffffffffc02057de <find_proc>
ffffffffc02066fa:	cd0d                	beqz	a0,ffffffffc0206734 <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc02066fc:	0b052703          	lw	a4,176(a0)
ffffffffc0206700:	00177693          	andi	a3,a4,1
ffffffffc0206704:	e695                	bnez	a3,ffffffffc0206730 <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0206706:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc020670a:	00176713          	ori	a4,a4,1
ffffffffc020670e:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0206712:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0206714:	0006c763          	bltz	a3,ffffffffc0206722 <do_kill+0x32>
}
ffffffffc0206718:	8522                	mv	a0,s0
ffffffffc020671a:	60a2                	ld	ra,8(sp)
ffffffffc020671c:	6402                	ld	s0,0(sp)
ffffffffc020671e:	0141                	addi	sp,sp,16
ffffffffc0206720:	8082                	ret
                wakeup_proc(proc);
ffffffffc0206722:	3e0000ef          	jal	ra,ffffffffc0206b02 <wakeup_proc>
}
ffffffffc0206726:	8522                	mv	a0,s0
ffffffffc0206728:	60a2                	ld	ra,8(sp)
ffffffffc020672a:	6402                	ld	s0,0(sp)
ffffffffc020672c:	0141                	addi	sp,sp,16
ffffffffc020672e:	8082                	ret
        return -E_KILLED;
ffffffffc0206730:	545d                	li	s0,-9
ffffffffc0206732:	b7dd                	j	ffffffffc0206718 <do_kill+0x28>
    return -E_INVAL;
ffffffffc0206734:	5475                	li	s0,-3
ffffffffc0206736:	b7cd                	j	ffffffffc0206718 <do_kill+0x28>

ffffffffc0206738 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0206738:	000d9797          	auipc	a5,0xd9
ffffffffc020673c:	e1878793          	addi	a5,a5,-488 # ffffffffc02df550 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0206740:	1101                	addi	sp,sp,-32
ffffffffc0206742:	000d9717          	auipc	a4,0xd9
ffffffffc0206746:	e0f73b23          	sd	a5,-490(a4) # ffffffffc02df558 <proc_list+0x8>
ffffffffc020674a:	000d9717          	auipc	a4,0xd9
ffffffffc020674e:	e0f73323          	sd	a5,-506(a4) # ffffffffc02df550 <proc_list>
ffffffffc0206752:	ec06                	sd	ra,24(sp)
ffffffffc0206754:	e822                	sd	s0,16(sp)
ffffffffc0206756:	e426                	sd	s1,8(sp)
ffffffffc0206758:	000d5797          	auipc	a5,0xd5
ffffffffc020675c:	af878793          	addi	a5,a5,-1288 # ffffffffc02db250 <hash_list>
ffffffffc0206760:	000d9717          	auipc	a4,0xd9
ffffffffc0206764:	af070713          	addi	a4,a4,-1296 # ffffffffc02df250 <__rq>
ffffffffc0206768:	e79c                	sd	a5,8(a5)
ffffffffc020676a:	e39c                	sd	a5,0(a5)
ffffffffc020676c:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc020676e:	fee79de3          	bne	a5,a4,ffffffffc0206768 <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0206772:	e21fe0ef          	jal	ra,ffffffffc0205592 <alloc_proc>
ffffffffc0206776:	000d9717          	auipc	a4,0xd9
ffffffffc020677a:	b4a73123          	sd	a0,-1214(a4) # ffffffffc02df2b8 <idleproc>
ffffffffc020677e:	000d9497          	auipc	s1,0xd9
ffffffffc0206782:	b3a48493          	addi	s1,s1,-1222 # ffffffffc02df2b8 <idleproc>
ffffffffc0206786:	c559                	beqz	a0,ffffffffc0206814 <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0206788:	4709                	li	a4,2
ffffffffc020678a:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc020678c:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc020678e:	00005717          	auipc	a4,0x5
ffffffffc0206792:	87270713          	addi	a4,a4,-1934 # ffffffffc020b000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0206796:	00003597          	auipc	a1,0x3
ffffffffc020679a:	32258593          	addi	a1,a1,802 # ffffffffc0209ab8 <default_pmm_manager+0x1880>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc020679e:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc02067a0:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc02067a2:	fa7fe0ef          	jal	ra,ffffffffc0205748 <set_proc_name>
    nr_process ++;
ffffffffc02067a6:	000d9797          	auipc	a5,0xd9
ffffffffc02067aa:	b2278793          	addi	a5,a5,-1246 # ffffffffc02df2c8 <nr_process>
ffffffffc02067ae:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc02067b0:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02067b2:	4601                	li	a2,0
    nr_process ++;
ffffffffc02067b4:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02067b6:	4581                	li	a1,0
ffffffffc02067b8:	00000517          	auipc	a0,0x0
ffffffffc02067bc:	82850513          	addi	a0,a0,-2008 # ffffffffc0205fe0 <init_main>
    nr_process ++;
ffffffffc02067c0:	000d9697          	auipc	a3,0xd9
ffffffffc02067c4:	b0f6a423          	sw	a5,-1272(a3) # ffffffffc02df2c8 <nr_process>
    current = idleproc;
ffffffffc02067c8:	000d9797          	auipc	a5,0xd9
ffffffffc02067cc:	aee7b423          	sd	a4,-1304(a5) # ffffffffc02df2b0 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02067d0:	c58ff0ef          	jal	ra,ffffffffc0205c28 <kernel_thread>
    if (pid <= 0) {
ffffffffc02067d4:	08a05c63          	blez	a0,ffffffffc020686c <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc02067d8:	806ff0ef          	jal	ra,ffffffffc02057de <find_proc>
    set_proc_name(initproc, "init");
ffffffffc02067dc:	00003597          	auipc	a1,0x3
ffffffffc02067e0:	30458593          	addi	a1,a1,772 # ffffffffc0209ae0 <default_pmm_manager+0x18a8>
    initproc = find_proc(pid);
ffffffffc02067e4:	000d9797          	auipc	a5,0xd9
ffffffffc02067e8:	aca7be23          	sd	a0,-1316(a5) # ffffffffc02df2c0 <initproc>
    set_proc_name(initproc, "init");
ffffffffc02067ec:	f5dfe0ef          	jal	ra,ffffffffc0205748 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02067f0:	609c                	ld	a5,0(s1)
ffffffffc02067f2:	cfa9                	beqz	a5,ffffffffc020684c <proc_init+0x114>
ffffffffc02067f4:	43dc                	lw	a5,4(a5)
ffffffffc02067f6:	ebb9                	bnez	a5,ffffffffc020684c <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02067f8:	000d9797          	auipc	a5,0xd9
ffffffffc02067fc:	ac878793          	addi	a5,a5,-1336 # ffffffffc02df2c0 <initproc>
ffffffffc0206800:	639c                	ld	a5,0(a5)
ffffffffc0206802:	c78d                	beqz	a5,ffffffffc020682c <proc_init+0xf4>
ffffffffc0206804:	43dc                	lw	a5,4(a5)
ffffffffc0206806:	02879363          	bne	a5,s0,ffffffffc020682c <proc_init+0xf4>
}
ffffffffc020680a:	60e2                	ld	ra,24(sp)
ffffffffc020680c:	6442                	ld	s0,16(sp)
ffffffffc020680e:	64a2                	ld	s1,8(sp)
ffffffffc0206810:	6105                	addi	sp,sp,32
ffffffffc0206812:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0206814:	00003617          	auipc	a2,0x3
ffffffffc0206818:	28c60613          	addi	a2,a2,652 # ffffffffc0209aa0 <default_pmm_manager+0x1868>
ffffffffc020681c:	38800593          	li	a1,904
ffffffffc0206820:	00003517          	auipc	a0,0x3
ffffffffc0206824:	37850513          	addi	a0,a0,888 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc0206828:	c61f90ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020682c:	00003697          	auipc	a3,0x3
ffffffffc0206830:	2e468693          	addi	a3,a3,740 # ffffffffc0209b10 <default_pmm_manager+0x18d8>
ffffffffc0206834:	00001617          	auipc	a2,0x1
ffffffffc0206838:	2bc60613          	addi	a2,a2,700 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020683c:	39d00593          	li	a1,925
ffffffffc0206840:	00003517          	auipc	a0,0x3
ffffffffc0206844:	35850513          	addi	a0,a0,856 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc0206848:	c41f90ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020684c:	00003697          	auipc	a3,0x3
ffffffffc0206850:	29c68693          	addi	a3,a3,668 # ffffffffc0209ae8 <default_pmm_manager+0x18b0>
ffffffffc0206854:	00001617          	auipc	a2,0x1
ffffffffc0206858:	29c60613          	addi	a2,a2,668 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc020685c:	39c00593          	li	a1,924
ffffffffc0206860:	00003517          	auipc	a0,0x3
ffffffffc0206864:	33850513          	addi	a0,a0,824 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc0206868:	c21f90ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("create init_main failed.\n");
ffffffffc020686c:	00003617          	auipc	a2,0x3
ffffffffc0206870:	25460613          	addi	a2,a2,596 # ffffffffc0209ac0 <default_pmm_manager+0x1888>
ffffffffc0206874:	39600593          	li	a1,918
ffffffffc0206878:	00003517          	auipc	a0,0x3
ffffffffc020687c:	32050513          	addi	a0,a0,800 # ffffffffc0209b98 <default_pmm_manager+0x1960>
ffffffffc0206880:	c09f90ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0206884 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0206884:	1141                	addi	sp,sp,-16
ffffffffc0206886:	e022                	sd	s0,0(sp)
ffffffffc0206888:	e406                	sd	ra,8(sp)
ffffffffc020688a:	000d9417          	auipc	s0,0xd9
ffffffffc020688e:	a2640413          	addi	s0,s0,-1498 # ffffffffc02df2b0 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0206892:	6018                	ld	a4,0(s0)
ffffffffc0206894:	6f1c                	ld	a5,24(a4)
ffffffffc0206896:	dffd                	beqz	a5,ffffffffc0206894 <cpu_idle+0x10>
            schedule();
ffffffffc0206898:	324000ef          	jal	ra,ffffffffc0206bbc <schedule>
ffffffffc020689c:	bfdd                	j	ffffffffc0206892 <cpu_idle+0xe>

ffffffffc020689e <lab6_set_priority>:
    }
}
//FOR LAB6, set the process's priority (bigger value will get more CPU time)
void
lab6_set_priority(uint32_t priority)
{
ffffffffc020689e:	1141                	addi	sp,sp,-16
ffffffffc02068a0:	e022                	sd	s0,0(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc02068a2:	85aa                	mv	a1,a0
{
ffffffffc02068a4:	842a                	mv	s0,a0
    cprintf("set priority to %d\n", priority);
ffffffffc02068a6:	00003517          	auipc	a0,0x3
ffffffffc02068aa:	1e250513          	addi	a0,a0,482 # ffffffffc0209a88 <default_pmm_manager+0x1850>
{
ffffffffc02068ae:	e406                	sd	ra,8(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc02068b0:	8e3f90ef          	jal	ra,ffffffffc0200192 <cprintf>
    if (priority == 0)
        current->lab6_priority = 1;
ffffffffc02068b4:	000d9797          	auipc	a5,0xd9
ffffffffc02068b8:	9fc78793          	addi	a5,a5,-1540 # ffffffffc02df2b0 <current>
ffffffffc02068bc:	639c                	ld	a5,0(a5)
    if (priority == 0)
ffffffffc02068be:	e801                	bnez	s0,ffffffffc02068ce <lab6_set_priority+0x30>
    else current->lab6_priority = priority;
}
ffffffffc02068c0:	60a2                	ld	ra,8(sp)
ffffffffc02068c2:	6402                	ld	s0,0(sp)
        current->lab6_priority = 1;
ffffffffc02068c4:	4705                	li	a4,1
ffffffffc02068c6:	14e7a223          	sw	a4,324(a5)
}
ffffffffc02068ca:	0141                	addi	sp,sp,16
ffffffffc02068cc:	8082                	ret
    else current->lab6_priority = priority;
ffffffffc02068ce:	1487a223          	sw	s0,324(a5)
}
ffffffffc02068d2:	60a2                	ld	ra,8(sp)
ffffffffc02068d4:	6402                	ld	s0,0(sp)
ffffffffc02068d6:	0141                	addi	sp,sp,16
ffffffffc02068d8:	8082                	ret

ffffffffc02068da <do_sleep>:
// do_sleep - set current process state to sleep and add timer with "time"
//          - then call scheduler. if process run again, delete timer first.
int
do_sleep(unsigned int time) {
    if (time == 0) {
ffffffffc02068da:	c921                	beqz	a0,ffffffffc020692a <do_sleep+0x50>
do_sleep(unsigned int time) {
ffffffffc02068dc:	7179                	addi	sp,sp,-48
ffffffffc02068de:	f022                	sd	s0,32(sp)
ffffffffc02068e0:	f406                	sd	ra,40(sp)
ffffffffc02068e2:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02068e4:	100027f3          	csrr	a5,sstatus
ffffffffc02068e8:	8b89                	andi	a5,a5,2
ffffffffc02068ea:	e3b1                	bnez	a5,ffffffffc020692e <do_sleep+0x54>
        return 0;
    }
    bool intr_flag;
    local_intr_save(intr_flag);
    timer_t __timer, *timer = timer_init(&__timer, current, time);
ffffffffc02068ec:	000d9797          	auipc	a5,0xd9
ffffffffc02068f0:	9c478793          	addi	a5,a5,-1596 # ffffffffc02df2b0 <current>
ffffffffc02068f4:	639c                	ld	a5,0(a5)
ffffffffc02068f6:	0818                	addi	a4,sp,16
to_struct((le), timer_t, member)

// init a timer
static inline timer_t *
timer_init(timer_t *timer, struct proc_struct *proc, int expires) {
    timer->expires = expires;
ffffffffc02068f8:	c02a                	sw	a0,0(sp)
ffffffffc02068fa:	ec3a                	sd	a4,24(sp)
ffffffffc02068fc:	e83a                	sd	a4,16(sp)
    timer->proc = proc;
ffffffffc02068fe:	e43e                	sd	a5,8(sp)
    current->state = PROC_SLEEPING;
ffffffffc0206900:	4705                	li	a4,1
ffffffffc0206902:	c398                	sw	a4,0(a5)
    current->wait_state = WT_TIMER;
ffffffffc0206904:	80000737          	lui	a4,0x80000
ffffffffc0206908:	840a                	mv	s0,sp
ffffffffc020690a:	2709                	addiw	a4,a4,2
ffffffffc020690c:	0ee7a623          	sw	a4,236(a5)
    add_timer(timer);
ffffffffc0206910:	8522                	mv	a0,s0
ffffffffc0206912:	374000ef          	jal	ra,ffffffffc0206c86 <add_timer>
    local_intr_restore(intr_flag);

    schedule();
ffffffffc0206916:	2a6000ef          	jal	ra,ffffffffc0206bbc <schedule>

    del_timer(timer);
ffffffffc020691a:	8522                	mv	a0,s0
ffffffffc020691c:	432000ef          	jal	ra,ffffffffc0206d4e <del_timer>
    return 0;
}
ffffffffc0206920:	70a2                	ld	ra,40(sp)
ffffffffc0206922:	7402                	ld	s0,32(sp)
ffffffffc0206924:	4501                	li	a0,0
ffffffffc0206926:	6145                	addi	sp,sp,48
ffffffffc0206928:	8082                	ret
ffffffffc020692a:	4501                	li	a0,0
ffffffffc020692c:	8082                	ret
        intr_disable();
ffffffffc020692e:	d25f90ef          	jal	ra,ffffffffc0200652 <intr_disable>
    timer_t __timer, *timer = timer_init(&__timer, current, time);
ffffffffc0206932:	000d9797          	auipc	a5,0xd9
ffffffffc0206936:	97e78793          	addi	a5,a5,-1666 # ffffffffc02df2b0 <current>
ffffffffc020693a:	639c                	ld	a5,0(a5)
ffffffffc020693c:	0818                	addi	a4,sp,16
    timer->expires = expires;
ffffffffc020693e:	c022                	sw	s0,0(sp)
    timer->proc = proc;
ffffffffc0206940:	e43e                	sd	a5,8(sp)
ffffffffc0206942:	ec3a                	sd	a4,24(sp)
ffffffffc0206944:	e83a                	sd	a4,16(sp)
    current->state = PROC_SLEEPING;
ffffffffc0206946:	4705                	li	a4,1
ffffffffc0206948:	c398                	sw	a4,0(a5)
    current->wait_state = WT_TIMER;
ffffffffc020694a:	80000737          	lui	a4,0x80000
ffffffffc020694e:	2709                	addiw	a4,a4,2
ffffffffc0206950:	840a                	mv	s0,sp
    add_timer(timer);
ffffffffc0206952:	8522                	mv	a0,s0
    current->wait_state = WT_TIMER;
ffffffffc0206954:	0ee7a623          	sw	a4,236(a5)
    add_timer(timer);
ffffffffc0206958:	32e000ef          	jal	ra,ffffffffc0206c86 <add_timer>
        intr_enable();
ffffffffc020695c:	cf1f90ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0206960:	bf5d                	j	ffffffffc0206916 <do_sleep+0x3c>

ffffffffc0206962 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0206962:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0206966:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc020696a:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc020696c:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc020696e:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0206972:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0206976:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc020697a:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc020697e:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0206982:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0206986:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc020698a:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc020698e:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0206992:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0206996:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc020699a:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc020699e:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02069a0:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02069a2:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc02069a6:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02069aa:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02069ae:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc02069b2:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc02069b6:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc02069ba:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc02069be:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc02069c2:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc02069c6:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc02069ca:	8082                	ret

ffffffffc02069cc <RR_init>:
ffffffffc02069cc:	e508                	sd	a0,8(a0)
ffffffffc02069ce:	e108                	sd	a0,0(a0)
#include <default_sched.h>

static void
RR_init(struct run_queue *rq) {
    list_init(&(rq->run_list));
    rq->proc_num = 0;
ffffffffc02069d0:	00052823          	sw	zero,16(a0)
}
ffffffffc02069d4:	8082                	ret

ffffffffc02069d6 <RR_pick_next>:
    return listelm->next;
ffffffffc02069d6:	651c                	ld	a5,8(a0)
}

static struct proc_struct *
RR_pick_next(struct run_queue *rq) {
    list_entry_t *le = list_next(&(rq->run_list));
    if (le != &(rq->run_list)) {
ffffffffc02069d8:	00f50563          	beq	a0,a5,ffffffffc02069e2 <RR_pick_next+0xc>
        return le2proc(le, run_link);
ffffffffc02069dc:	ef078513          	addi	a0,a5,-272
ffffffffc02069e0:	8082                	ret
    }
    return NULL;
ffffffffc02069e2:	4501                	li	a0,0
}
ffffffffc02069e4:	8082                	ret

ffffffffc02069e6 <RR_proc_tick>:

static void
RR_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    if (proc->time_slice > 0) {
ffffffffc02069e6:	1205a783          	lw	a5,288(a1)
ffffffffc02069ea:	00f05563          	blez	a5,ffffffffc02069f4 <RR_proc_tick+0xe>
        proc->time_slice --;
ffffffffc02069ee:	37fd                	addiw	a5,a5,-1
ffffffffc02069f0:	12f5a023          	sw	a5,288(a1)
    }
    if (proc->time_slice == 0) {
ffffffffc02069f4:	e399                	bnez	a5,ffffffffc02069fa <RR_proc_tick+0x14>
        proc->need_resched = 1;
ffffffffc02069f6:	4785                	li	a5,1
ffffffffc02069f8:	ed9c                	sd	a5,24(a1)
    }
}
ffffffffc02069fa:	8082                	ret

ffffffffc02069fc <RR_dequeue>:
    return list->next == list;
ffffffffc02069fc:	1185b703          	ld	a4,280(a1)
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
ffffffffc0206a00:	11058793          	addi	a5,a1,272
ffffffffc0206a04:	02e78263          	beq	a5,a4,ffffffffc0206a28 <RR_dequeue+0x2c>
ffffffffc0206a08:	1085b683          	ld	a3,264(a1)
ffffffffc0206a0c:	00a69e63          	bne	a3,a0,ffffffffc0206a28 <RR_dequeue+0x2c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0206a10:	1105b503          	ld	a0,272(a1)
    rq->proc_num --;
ffffffffc0206a14:	4a90                	lw	a2,16(a3)
    prev->next = next;
ffffffffc0206a16:	e518                	sd	a4,8(a0)
    next->prev = prev;
ffffffffc0206a18:	e308                	sd	a0,0(a4)
    elm->prev = elm->next = elm;
ffffffffc0206a1a:	10f5bc23          	sd	a5,280(a1)
ffffffffc0206a1e:	10f5b823          	sd	a5,272(a1)
ffffffffc0206a22:	367d                	addiw	a2,a2,-1
ffffffffc0206a24:	ca90                	sw	a2,16(a3)
ffffffffc0206a26:	8082                	ret
RR_dequeue(struct run_queue *rq, struct proc_struct *proc) {
ffffffffc0206a28:	1141                	addi	sp,sp,-16
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
ffffffffc0206a2a:	00003697          	auipc	a3,0x3
ffffffffc0206a2e:	18668693          	addi	a3,a3,390 # ffffffffc0209bb0 <default_pmm_manager+0x1978>
ffffffffc0206a32:	00001617          	auipc	a2,0x1
ffffffffc0206a36:	0be60613          	addi	a2,a2,190 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0206a3a:	45e9                	li	a1,26
ffffffffc0206a3c:	00003517          	auipc	a0,0x3
ffffffffc0206a40:	1ac50513          	addi	a0,a0,428 # ffffffffc0209be8 <default_pmm_manager+0x19b0>
RR_dequeue(struct run_queue *rq, struct proc_struct *proc) {
ffffffffc0206a44:	e406                	sd	ra,8(sp)
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
ffffffffc0206a46:	a43f90ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0206a4a <RR_enqueue>:
    assert(list_empty(&(proc->run_link)));
ffffffffc0206a4a:	1185b703          	ld	a4,280(a1)
ffffffffc0206a4e:	11058793          	addi	a5,a1,272
ffffffffc0206a52:	02e79d63          	bne	a5,a4,ffffffffc0206a8c <RR_enqueue+0x42>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0206a56:	6118                	ld	a4,0(a0)
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc0206a58:	1205a683          	lw	a3,288(a1)
    prev->next = next->prev = elm;
ffffffffc0206a5c:	e11c                	sd	a5,0(a0)
ffffffffc0206a5e:	e71c                	sd	a5,8(a4)
    elm->next = next;
ffffffffc0206a60:	10a5bc23          	sd	a0,280(a1)
    elm->prev = prev;
ffffffffc0206a64:	10e5b823          	sd	a4,272(a1)
ffffffffc0206a68:	495c                	lw	a5,20(a0)
ffffffffc0206a6a:	ea89                	bnez	a3,ffffffffc0206a7c <RR_enqueue+0x32>
        proc->time_slice = rq->max_time_slice;
ffffffffc0206a6c:	12f5a023          	sw	a5,288(a1)
    rq->proc_num ++;
ffffffffc0206a70:	491c                	lw	a5,16(a0)
    proc->rq = rq;
ffffffffc0206a72:	10a5b423          	sd	a0,264(a1)
    rq->proc_num ++;
ffffffffc0206a76:	2785                	addiw	a5,a5,1
ffffffffc0206a78:	c91c                	sw	a5,16(a0)
ffffffffc0206a7a:	8082                	ret
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc0206a7c:	fed7c8e3          	blt	a5,a3,ffffffffc0206a6c <RR_enqueue+0x22>
    rq->proc_num ++;
ffffffffc0206a80:	491c                	lw	a5,16(a0)
    proc->rq = rq;
ffffffffc0206a82:	10a5b423          	sd	a0,264(a1)
    rq->proc_num ++;
ffffffffc0206a86:	2785                	addiw	a5,a5,1
ffffffffc0206a88:	c91c                	sw	a5,16(a0)
ffffffffc0206a8a:	8082                	ret
RR_enqueue(struct run_queue *rq, struct proc_struct *proc) {
ffffffffc0206a8c:	1141                	addi	sp,sp,-16
    assert(list_empty(&(proc->run_link)));
ffffffffc0206a8e:	00003697          	auipc	a3,0x3
ffffffffc0206a92:	17a68693          	addi	a3,a3,378 # ffffffffc0209c08 <default_pmm_manager+0x19d0>
ffffffffc0206a96:	00001617          	auipc	a2,0x1
ffffffffc0206a9a:	05a60613          	addi	a2,a2,90 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0206a9e:	45bd                	li	a1,15
ffffffffc0206aa0:	00003517          	auipc	a0,0x3
ffffffffc0206aa4:	14850513          	addi	a0,a0,328 # ffffffffc0209be8 <default_pmm_manager+0x19b0>
RR_enqueue(struct run_queue *rq, struct proc_struct *proc) {
ffffffffc0206aa8:	e406                	sd	ra,8(sp)
    assert(list_empty(&(proc->run_link)));
ffffffffc0206aaa:	9dff90ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0206aae <sched_init>:
}

static struct run_queue __rq;

void
sched_init(void) {
ffffffffc0206aae:	1141                	addi	sp,sp,-16
    list_init(&timer_list);

    sched_class = &default_sched_class;
ffffffffc0206ab0:	000cd697          	auipc	a3,0xcd
ffffffffc0206ab4:	35868693          	addi	a3,a3,856 # ffffffffc02d3e08 <default_sched_class>
sched_init(void) {
ffffffffc0206ab8:	e022                	sd	s0,0(sp)
ffffffffc0206aba:	e406                	sd	ra,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0206abc:	000d8797          	auipc	a5,0xd8
ffffffffc0206ac0:	7b478793          	addi	a5,a5,1972 # ffffffffc02df270 <timer_list>

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);
ffffffffc0206ac4:	6690                	ld	a2,8(a3)
    rq = &__rq;
ffffffffc0206ac6:	000d8717          	auipc	a4,0xd8
ffffffffc0206aca:	78a70713          	addi	a4,a4,1930 # ffffffffc02df250 <__rq>
ffffffffc0206ace:	e79c                	sd	a5,8(a5)
ffffffffc0206ad0:	e39c                	sd	a5,0(a5)
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc0206ad2:	4795                	li	a5,5
    sched_class = &default_sched_class;
ffffffffc0206ad4:	000d9417          	auipc	s0,0xd9
ffffffffc0206ad8:	80440413          	addi	s0,s0,-2044 # ffffffffc02df2d8 <sched_class>
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc0206adc:	cb5c                	sw	a5,20(a4)
    sched_class->init(rq);
ffffffffc0206ade:	853a                	mv	a0,a4
    sched_class = &default_sched_class;
ffffffffc0206ae0:	e014                	sd	a3,0(s0)
    rq = &__rq;
ffffffffc0206ae2:	000d8797          	auipc	a5,0xd8
ffffffffc0206ae6:	7ee7b723          	sd	a4,2030(a5) # ffffffffc02df2d0 <rq>
    sched_class->init(rq);
ffffffffc0206aea:	9602                	jalr	a2

    cprintf("sched class: %s\n", sched_class->name);
ffffffffc0206aec:	601c                	ld	a5,0(s0)
}
ffffffffc0206aee:	6402                	ld	s0,0(sp)
ffffffffc0206af0:	60a2                	ld	ra,8(sp)
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc0206af2:	638c                	ld	a1,0(a5)
ffffffffc0206af4:	00003517          	auipc	a0,0x3
ffffffffc0206af8:	1fc50513          	addi	a0,a0,508 # ffffffffc0209cf0 <default_pmm_manager+0x1ab8>
}
ffffffffc0206afc:	0141                	addi	sp,sp,16
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc0206afe:	e94f906f          	j	ffffffffc0200192 <cprintf>

ffffffffc0206b02 <wakeup_proc>:

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206b02:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0206b04:	1101                	addi	sp,sp,-32
ffffffffc0206b06:	ec06                	sd	ra,24(sp)
ffffffffc0206b08:	e822                	sd	s0,16(sp)
ffffffffc0206b0a:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206b0c:	478d                	li	a5,3
ffffffffc0206b0e:	08f70763          	beq	a4,a5,ffffffffc0206b9c <wakeup_proc+0x9a>
ffffffffc0206b12:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206b14:	100027f3          	csrr	a5,sstatus
ffffffffc0206b18:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0206b1a:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206b1c:	ebbd                	bnez	a5,ffffffffc0206b92 <wakeup_proc+0x90>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0206b1e:	4789                	li	a5,2
ffffffffc0206b20:	04f70c63          	beq	a4,a5,ffffffffc0206b78 <wakeup_proc+0x76>
            proc->state = PROC_RUNNABLE;
            proc->wait_state = 0;
            if (proc != current) {
ffffffffc0206b24:	000d8717          	auipc	a4,0xd8
ffffffffc0206b28:	78c70713          	addi	a4,a4,1932 # ffffffffc02df2b0 <current>
ffffffffc0206b2c:	6318                	ld	a4,0(a4)
            proc->wait_state = 0;
ffffffffc0206b2e:	0e042623          	sw	zero,236(s0)
            proc->state = PROC_RUNNABLE;
ffffffffc0206b32:	c01c                	sw	a5,0(s0)
            if (proc != current) {
ffffffffc0206b34:	02870663          	beq	a4,s0,ffffffffc0206b60 <wakeup_proc+0x5e>
    if (proc != idleproc) {
ffffffffc0206b38:	000d8797          	auipc	a5,0xd8
ffffffffc0206b3c:	78078793          	addi	a5,a5,1920 # ffffffffc02df2b8 <idleproc>
ffffffffc0206b40:	639c                	ld	a5,0(a5)
ffffffffc0206b42:	00f40f63          	beq	s0,a5,ffffffffc0206b60 <wakeup_proc+0x5e>
        sched_class->enqueue(rq, proc);
ffffffffc0206b46:	000d8797          	auipc	a5,0xd8
ffffffffc0206b4a:	79278793          	addi	a5,a5,1938 # ffffffffc02df2d8 <sched_class>
ffffffffc0206b4e:	639c                	ld	a5,0(a5)
ffffffffc0206b50:	000d8717          	auipc	a4,0xd8
ffffffffc0206b54:	78070713          	addi	a4,a4,1920 # ffffffffc02df2d0 <rq>
ffffffffc0206b58:	6308                	ld	a0,0(a4)
ffffffffc0206b5a:	6b9c                	ld	a5,16(a5)
ffffffffc0206b5c:	85a2                	mv	a1,s0
ffffffffc0206b5e:	9782                	jalr	a5
    if (flag) {
ffffffffc0206b60:	e491                	bnez	s1,ffffffffc0206b6c <wakeup_proc+0x6a>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206b62:	60e2                	ld	ra,24(sp)
ffffffffc0206b64:	6442                	ld	s0,16(sp)
ffffffffc0206b66:	64a2                	ld	s1,8(sp)
ffffffffc0206b68:	6105                	addi	sp,sp,32
ffffffffc0206b6a:	8082                	ret
ffffffffc0206b6c:	6442                	ld	s0,16(sp)
ffffffffc0206b6e:	60e2                	ld	ra,24(sp)
ffffffffc0206b70:	64a2                	ld	s1,8(sp)
ffffffffc0206b72:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0206b74:	ad9f906f          	j	ffffffffc020064c <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0206b78:	00003617          	auipc	a2,0x3
ffffffffc0206b7c:	1c860613          	addi	a2,a2,456 # ffffffffc0209d40 <default_pmm_manager+0x1b08>
ffffffffc0206b80:	04800593          	li	a1,72
ffffffffc0206b84:	00003517          	auipc	a0,0x3
ffffffffc0206b88:	1a450513          	addi	a0,a0,420 # ffffffffc0209d28 <default_pmm_manager+0x1af0>
ffffffffc0206b8c:	969f90ef          	jal	ra,ffffffffc02004f4 <__warn>
ffffffffc0206b90:	bfc1                	j	ffffffffc0206b60 <wakeup_proc+0x5e>
        intr_disable();
ffffffffc0206b92:	ac1f90ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0206b96:	4018                	lw	a4,0(s0)
ffffffffc0206b98:	4485                	li	s1,1
ffffffffc0206b9a:	b751                	j	ffffffffc0206b1e <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206b9c:	00003697          	auipc	a3,0x3
ffffffffc0206ba0:	16c68693          	addi	a3,a3,364 # ffffffffc0209d08 <default_pmm_manager+0x1ad0>
ffffffffc0206ba4:	00001617          	auipc	a2,0x1
ffffffffc0206ba8:	f4c60613          	addi	a2,a2,-180 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0206bac:	03c00593          	li	a1,60
ffffffffc0206bb0:	00003517          	auipc	a0,0x3
ffffffffc0206bb4:	17850513          	addi	a0,a0,376 # ffffffffc0209d28 <default_pmm_manager+0x1af0>
ffffffffc0206bb8:	8d1f90ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0206bbc <schedule>:

void
schedule(void) {
ffffffffc0206bbc:	7179                	addi	sp,sp,-48
ffffffffc0206bbe:	f406                	sd	ra,40(sp)
ffffffffc0206bc0:	f022                	sd	s0,32(sp)
ffffffffc0206bc2:	ec26                	sd	s1,24(sp)
ffffffffc0206bc4:	e84a                	sd	s2,16(sp)
ffffffffc0206bc6:	e44e                	sd	s3,8(sp)
ffffffffc0206bc8:	e052                	sd	s4,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206bca:	100027f3          	csrr	a5,sstatus
ffffffffc0206bce:	8b89                	andi	a5,a5,2
ffffffffc0206bd0:	4a01                	li	s4,0
ffffffffc0206bd2:	e7d5                	bnez	a5,ffffffffc0206c7e <schedule+0xc2>
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0206bd4:	000d8497          	auipc	s1,0xd8
ffffffffc0206bd8:	6dc48493          	addi	s1,s1,1756 # ffffffffc02df2b0 <current>
ffffffffc0206bdc:	608c                	ld	a1,0(s1)
ffffffffc0206bde:	000d8997          	auipc	s3,0xd8
ffffffffc0206be2:	6fa98993          	addi	s3,s3,1786 # ffffffffc02df2d8 <sched_class>
ffffffffc0206be6:	000d8917          	auipc	s2,0xd8
ffffffffc0206bea:	6ea90913          	addi	s2,s2,1770 # ffffffffc02df2d0 <rq>
        if (current->state == PROC_RUNNABLE) {
ffffffffc0206bee:	4194                	lw	a3,0(a1)
        current->need_resched = 0;
ffffffffc0206bf0:	0005bc23          	sd	zero,24(a1)
        if (current->state == PROC_RUNNABLE) {
ffffffffc0206bf4:	4709                	li	a4,2
ffffffffc0206bf6:	0009b783          	ld	a5,0(s3)
ffffffffc0206bfa:	00093503          	ld	a0,0(s2)
ffffffffc0206bfe:	04e68063          	beq	a3,a4,ffffffffc0206c3e <schedule+0x82>
    return sched_class->pick_next(rq);
ffffffffc0206c02:	739c                	ld	a5,32(a5)
ffffffffc0206c04:	9782                	jalr	a5
ffffffffc0206c06:	842a                	mv	s0,a0
            sched_class_enqueue(current);
        }
        if ((next = sched_class_pick_next()) != NULL) {
ffffffffc0206c08:	cd21                	beqz	a0,ffffffffc0206c60 <schedule+0xa4>
    sched_class->dequeue(rq, proc);
ffffffffc0206c0a:	0009b783          	ld	a5,0(s3)
ffffffffc0206c0e:	00093503          	ld	a0,0(s2)
ffffffffc0206c12:	85a2                	mv	a1,s0
ffffffffc0206c14:	6f9c                	ld	a5,24(a5)
ffffffffc0206c16:	9782                	jalr	a5
            sched_class_dequeue(next);
        }
        if (next == NULL) {
            next = idleproc;
        }
        next->runs ++;
ffffffffc0206c18:	441c                	lw	a5,8(s0)
        if (next != current) {
ffffffffc0206c1a:	6098                	ld	a4,0(s1)
        next->runs ++;
ffffffffc0206c1c:	2785                	addiw	a5,a5,1
ffffffffc0206c1e:	c41c                	sw	a5,8(s0)
        if (next != current) {
ffffffffc0206c20:	00870563          	beq	a4,s0,ffffffffc0206c2a <schedule+0x6e>
            proc_run(next);
ffffffffc0206c24:	8522                	mv	a0,s0
ffffffffc0206c26:	b4dfe0ef          	jal	ra,ffffffffc0205772 <proc_run>
    if (flag) {
ffffffffc0206c2a:	040a1163          	bnez	s4,ffffffffc0206c6c <schedule+0xb0>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206c2e:	70a2                	ld	ra,40(sp)
ffffffffc0206c30:	7402                	ld	s0,32(sp)
ffffffffc0206c32:	64e2                	ld	s1,24(sp)
ffffffffc0206c34:	6942                	ld	s2,16(sp)
ffffffffc0206c36:	69a2                	ld	s3,8(sp)
ffffffffc0206c38:	6a02                	ld	s4,0(sp)
ffffffffc0206c3a:	6145                	addi	sp,sp,48
ffffffffc0206c3c:	8082                	ret
    if (proc != idleproc) {
ffffffffc0206c3e:	000d8717          	auipc	a4,0xd8
ffffffffc0206c42:	67a70713          	addi	a4,a4,1658 # ffffffffc02df2b8 <idleproc>
ffffffffc0206c46:	6318                	ld	a4,0(a4)
ffffffffc0206c48:	fae58de3          	beq	a1,a4,ffffffffc0206c02 <schedule+0x46>
        sched_class->enqueue(rq, proc);
ffffffffc0206c4c:	6b9c                	ld	a5,16(a5)
ffffffffc0206c4e:	9782                	jalr	a5
ffffffffc0206c50:	0009b783          	ld	a5,0(s3)
ffffffffc0206c54:	00093503          	ld	a0,0(s2)
    return sched_class->pick_next(rq);
ffffffffc0206c58:	739c                	ld	a5,32(a5)
ffffffffc0206c5a:	9782                	jalr	a5
ffffffffc0206c5c:	842a                	mv	s0,a0
        if ((next = sched_class_pick_next()) != NULL) {
ffffffffc0206c5e:	f555                	bnez	a0,ffffffffc0206c0a <schedule+0x4e>
            next = idleproc;
ffffffffc0206c60:	000d8797          	auipc	a5,0xd8
ffffffffc0206c64:	65878793          	addi	a5,a5,1624 # ffffffffc02df2b8 <idleproc>
ffffffffc0206c68:	6380                	ld	s0,0(a5)
ffffffffc0206c6a:	b77d                	j	ffffffffc0206c18 <schedule+0x5c>
}
ffffffffc0206c6c:	7402                	ld	s0,32(sp)
ffffffffc0206c6e:	70a2                	ld	ra,40(sp)
ffffffffc0206c70:	64e2                	ld	s1,24(sp)
ffffffffc0206c72:	6942                	ld	s2,16(sp)
ffffffffc0206c74:	69a2                	ld	s3,8(sp)
ffffffffc0206c76:	6a02                	ld	s4,0(sp)
ffffffffc0206c78:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0206c7a:	9d3f906f          	j	ffffffffc020064c <intr_enable>
        intr_disable();
ffffffffc0206c7e:	9d5f90ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0206c82:	4a05                	li	s4,1
ffffffffc0206c84:	bf81                	j	ffffffffc0206bd4 <schedule+0x18>

ffffffffc0206c86 <add_timer>:

// add timer to timer_list
void
add_timer(timer_t *timer) {
ffffffffc0206c86:	1101                	addi	sp,sp,-32
ffffffffc0206c88:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206c8a:	100027f3          	csrr	a5,sstatus
ffffffffc0206c8e:	8b89                	andi	a5,a5,2
ffffffffc0206c90:	4801                	li	a6,0
ffffffffc0206c92:	eba5                	bnez	a5,ffffffffc0206d02 <add_timer+0x7c>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        assert(timer->expires > 0 && timer->proc != NULL);
ffffffffc0206c94:	411c                	lw	a5,0(a0)
ffffffffc0206c96:	cfa5                	beqz	a5,ffffffffc0206d0e <add_timer+0x88>
ffffffffc0206c98:	6518                	ld	a4,8(a0)
ffffffffc0206c9a:	cb35                	beqz	a4,ffffffffc0206d0e <add_timer+0x88>
        assert(list_empty(&(timer->timer_link)));
ffffffffc0206c9c:	6d18                	ld	a4,24(a0)
ffffffffc0206c9e:	01050593          	addi	a1,a0,16
ffffffffc0206ca2:	08e59663          	bne	a1,a4,ffffffffc0206d2e <add_timer+0xa8>
    return listelm->next;
ffffffffc0206ca6:	000d8617          	auipc	a2,0xd8
ffffffffc0206caa:	5ca60613          	addi	a2,a2,1482 # ffffffffc02df270 <timer_list>
ffffffffc0206cae:	6618                	ld	a4,8(a2)
        list_entry_t *le = list_next(&timer_list);
        while (le != &timer_list) {
ffffffffc0206cb0:	00c71863          	bne	a4,a2,ffffffffc0206cc0 <add_timer+0x3a>
ffffffffc0206cb4:	a80d                	j	ffffffffc0206ce6 <add_timer+0x60>
ffffffffc0206cb6:	6718                	ld	a4,8(a4)
            timer_t *next = le2timer(le, timer_link);
            if (timer->expires < next->expires) {
                next->expires -= timer->expires;
                break;
            }
            timer->expires -= next->expires;
ffffffffc0206cb8:	9f95                	subw	a5,a5,a3
ffffffffc0206cba:	c11c                	sw	a5,0(a0)
        while (le != &timer_list) {
ffffffffc0206cbc:	02c70563          	beq	a4,a2,ffffffffc0206ce6 <add_timer+0x60>
            if (timer->expires < next->expires) {
ffffffffc0206cc0:	ff072683          	lw	a3,-16(a4)
ffffffffc0206cc4:	fed7f9e3          	bleu	a3,a5,ffffffffc0206cb6 <add_timer+0x30>
                next->expires -= timer->expires;
ffffffffc0206cc8:	40f687bb          	subw	a5,a3,a5
ffffffffc0206ccc:	fef72823          	sw	a5,-16(a4)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0206cd0:	631c                	ld	a5,0(a4)
    prev->next = next->prev = elm;
ffffffffc0206cd2:	e30c                	sd	a1,0(a4)
ffffffffc0206cd4:	e78c                	sd	a1,8(a5)
    elm->next = next;
ffffffffc0206cd6:	ed18                	sd	a4,24(a0)
    elm->prev = prev;
ffffffffc0206cd8:	e91c                	sd	a5,16(a0)
    if (flag) {
ffffffffc0206cda:	02080163          	beqz	a6,ffffffffc0206cfc <add_timer+0x76>
            le = list_next(le);
        }
        list_add_before(le, &(timer->timer_link));
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206cde:	60e2                	ld	ra,24(sp)
ffffffffc0206ce0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0206ce2:	96bf906f          	j	ffffffffc020064c <intr_enable>
    return 0;
ffffffffc0206ce6:	000d8717          	auipc	a4,0xd8
ffffffffc0206cea:	58a70713          	addi	a4,a4,1418 # ffffffffc02df270 <timer_list>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0206cee:	631c                	ld	a5,0(a4)
    prev->next = next->prev = elm;
ffffffffc0206cf0:	e30c                	sd	a1,0(a4)
ffffffffc0206cf2:	e78c                	sd	a1,8(a5)
    elm->next = next;
ffffffffc0206cf4:	ed18                	sd	a4,24(a0)
    elm->prev = prev;
ffffffffc0206cf6:	e91c                	sd	a5,16(a0)
    if (flag) {
ffffffffc0206cf8:	fe0813e3          	bnez	a6,ffffffffc0206cde <add_timer+0x58>
ffffffffc0206cfc:	60e2                	ld	ra,24(sp)
ffffffffc0206cfe:	6105                	addi	sp,sp,32
ffffffffc0206d00:	8082                	ret
ffffffffc0206d02:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0206d04:	94ff90ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0206d08:	4805                	li	a6,1
ffffffffc0206d0a:	6522                	ld	a0,8(sp)
ffffffffc0206d0c:	b761                	j	ffffffffc0206c94 <add_timer+0xe>
        assert(timer->expires > 0 && timer->proc != NULL);
ffffffffc0206d0e:	00003697          	auipc	a3,0x3
ffffffffc0206d12:	f2a68693          	addi	a3,a3,-214 # ffffffffc0209c38 <default_pmm_manager+0x1a00>
ffffffffc0206d16:	00001617          	auipc	a2,0x1
ffffffffc0206d1a:	dda60613          	addi	a2,a2,-550 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0206d1e:	06c00593          	li	a1,108
ffffffffc0206d22:	00003517          	auipc	a0,0x3
ffffffffc0206d26:	00650513          	addi	a0,a0,6 # ffffffffc0209d28 <default_pmm_manager+0x1af0>
ffffffffc0206d2a:	f5ef90ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(list_empty(&(timer->timer_link)));
ffffffffc0206d2e:	00003697          	auipc	a3,0x3
ffffffffc0206d32:	f3a68693          	addi	a3,a3,-198 # ffffffffc0209c68 <default_pmm_manager+0x1a30>
ffffffffc0206d36:	00001617          	auipc	a2,0x1
ffffffffc0206d3a:	dba60613          	addi	a2,a2,-582 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0206d3e:	06d00593          	li	a1,109
ffffffffc0206d42:	00003517          	auipc	a0,0x3
ffffffffc0206d46:	fe650513          	addi	a0,a0,-26 # ffffffffc0209d28 <default_pmm_manager+0x1af0>
ffffffffc0206d4a:	f3ef90ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0206d4e <del_timer>:

// del timer from timer_list
void
del_timer(timer_t *timer) {
ffffffffc0206d4e:	1101                	addi	sp,sp,-32
ffffffffc0206d50:	ec06                	sd	ra,24(sp)
ffffffffc0206d52:	e822                	sd	s0,16(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206d54:	100027f3          	csrr	a5,sstatus
ffffffffc0206d58:	8b89                	andi	a5,a5,2
ffffffffc0206d5a:	01050413          	addi	s0,a0,16
ffffffffc0206d5e:	e7a9                	bnez	a5,ffffffffc0206da8 <del_timer+0x5a>
    return list->next == list;
ffffffffc0206d60:	6d1c                	ld	a5,24(a0)
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (!list_empty(&(timer->timer_link))) {
ffffffffc0206d62:	02f40f63          	beq	s0,a5,ffffffffc0206da0 <del_timer+0x52>
            if (timer->expires != 0) {
ffffffffc0206d66:	4114                	lw	a3,0(a0)
ffffffffc0206d68:	6918                	ld	a4,16(a0)
ffffffffc0206d6a:	c69d                	beqz	a3,ffffffffc0206d98 <del_timer+0x4a>
                list_entry_t *le = list_next(&(timer->timer_link));
                if (le != &timer_list) {
ffffffffc0206d6c:	000d8617          	auipc	a2,0xd8
ffffffffc0206d70:	50460613          	addi	a2,a2,1284 # ffffffffc02df270 <timer_list>
    return 0;
ffffffffc0206d74:	4581                	li	a1,0
ffffffffc0206d76:	02c78163          	beq	a5,a2,ffffffffc0206d98 <del_timer+0x4a>
                    timer_t *next = le2timer(le, timer_link);
                    next->expires += timer->expires;
ffffffffc0206d7a:	ff07a603          	lw	a2,-16(a5)
ffffffffc0206d7e:	9eb1                	addw	a3,a3,a2
ffffffffc0206d80:	fed7a823          	sw	a3,-16(a5)
    prev->next = next;
ffffffffc0206d84:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0206d86:	e398                	sd	a4,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0206d88:	ed00                	sd	s0,24(a0)
ffffffffc0206d8a:	e900                	sd	s0,16(a0)
    if (flag) {
ffffffffc0206d8c:	c991                	beqz	a1,ffffffffc0206da0 <del_timer+0x52>
            }
            list_del_init(&(timer->timer_link));
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206d8e:	6442                	ld	s0,16(sp)
ffffffffc0206d90:	60e2                	ld	ra,24(sp)
ffffffffc0206d92:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0206d94:	8b9f906f          	j	ffffffffc020064c <intr_enable>
    prev->next = next;
ffffffffc0206d98:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0206d9a:	e398                	sd	a4,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0206d9c:	ed00                	sd	s0,24(a0)
ffffffffc0206d9e:	e900                	sd	s0,16(a0)
ffffffffc0206da0:	60e2                	ld	ra,24(sp)
ffffffffc0206da2:	6442                	ld	s0,16(sp)
ffffffffc0206da4:	6105                	addi	sp,sp,32
ffffffffc0206da6:	8082                	ret
ffffffffc0206da8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0206daa:	8a9f90ef          	jal	ra,ffffffffc0200652 <intr_disable>
    return list->next == list;
ffffffffc0206dae:	6522                	ld	a0,8(sp)
ffffffffc0206db0:	6d1c                	ld	a5,24(a0)
        if (!list_empty(&(timer->timer_link))) {
ffffffffc0206db2:	fc878ee3          	beq	a5,s0,ffffffffc0206d8e <del_timer+0x40>
            if (timer->expires != 0) {
ffffffffc0206db6:	4114                	lw	a3,0(a0)
ffffffffc0206db8:	6918                	ld	a4,16(a0)
ffffffffc0206dba:	ca81                	beqz	a3,ffffffffc0206dca <del_timer+0x7c>
                if (le != &timer_list) {
ffffffffc0206dbc:	000d8617          	auipc	a2,0xd8
ffffffffc0206dc0:	4b460613          	addi	a2,a2,1204 # ffffffffc02df270 <timer_list>
        return 1;
ffffffffc0206dc4:	4585                	li	a1,1
ffffffffc0206dc6:	fac79ae3          	bne	a5,a2,ffffffffc0206d7a <del_timer+0x2c>
    prev->next = next;
ffffffffc0206dca:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0206dcc:	e398                	sd	a4,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0206dce:	ed00                	sd	s0,24(a0)
ffffffffc0206dd0:	e900                	sd	s0,16(a0)
    if (flag) {
ffffffffc0206dd2:	bf75                	j	ffffffffc0206d8e <del_timer+0x40>

ffffffffc0206dd4 <run_timer_list>:

// call scheduler to update tick related info, and check the timer is expired? If expired, then wakup proc
void
run_timer_list(void) {
ffffffffc0206dd4:	7139                	addi	sp,sp,-64
ffffffffc0206dd6:	fc06                	sd	ra,56(sp)
ffffffffc0206dd8:	f822                	sd	s0,48(sp)
ffffffffc0206dda:	f426                	sd	s1,40(sp)
ffffffffc0206ddc:	f04a                	sd	s2,32(sp)
ffffffffc0206dde:	ec4e                	sd	s3,24(sp)
ffffffffc0206de0:	e852                	sd	s4,16(sp)
ffffffffc0206de2:	e456                	sd	s5,8(sp)
ffffffffc0206de4:	e05a                	sd	s6,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206de6:	100027f3          	csrr	a5,sstatus
ffffffffc0206dea:	8b89                	andi	a5,a5,2
ffffffffc0206dec:	4b01                	li	s6,0
ffffffffc0206dee:	e3fd                	bnez	a5,ffffffffc0206ed4 <run_timer_list+0x100>
    return listelm->next;
ffffffffc0206df0:	000d8997          	auipc	s3,0xd8
ffffffffc0206df4:	48098993          	addi	s3,s3,1152 # ffffffffc02df270 <timer_list>
ffffffffc0206df8:	0089b403          	ld	s0,8(s3)
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        list_entry_t *le = list_next(&timer_list);
        if (le != &timer_list) {
ffffffffc0206dfc:	07340a63          	beq	s0,s3,ffffffffc0206e70 <run_timer_list+0x9c>
            timer_t *timer = le2timer(le, timer_link);
            assert(timer->expires != 0);
ffffffffc0206e00:	ff042783          	lw	a5,-16(s0)
            timer_t *timer = le2timer(le, timer_link);
ffffffffc0206e04:	ff040913          	addi	s2,s0,-16
            assert(timer->expires != 0);
ffffffffc0206e08:	0e078a63          	beqz	a5,ffffffffc0206efc <run_timer_list+0x128>
            timer->expires --;
ffffffffc0206e0c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0206e10:	fee42823          	sw	a4,-16(s0)
            while (timer->expires == 0) {
ffffffffc0206e14:	ef31                	bnez	a4,ffffffffc0206e70 <run_timer_list+0x9c>
                struct proc_struct *proc = timer->proc;
                if (proc->wait_state != 0) {
                    assert(proc->wait_state & WT_INTERRUPTED);
                }
                else {
                    warn("process %d's wait_state == 0.\n", proc->pid);
ffffffffc0206e16:	00003a97          	auipc	s5,0x3
ffffffffc0206e1a:	ebaa8a93          	addi	s5,s5,-326 # ffffffffc0209cd0 <default_pmm_manager+0x1a98>
ffffffffc0206e1e:	00003a17          	auipc	s4,0x3
ffffffffc0206e22:	f0aa0a13          	addi	s4,s4,-246 # ffffffffc0209d28 <default_pmm_manager+0x1af0>
ffffffffc0206e26:	a005                	j	ffffffffc0206e46 <run_timer_list+0x72>
                    assert(proc->wait_state & WT_INTERRUPTED);
ffffffffc0206e28:	0a07da63          	bgez	a5,ffffffffc0206edc <run_timer_list+0x108>
                }
                wakeup_proc(proc);
ffffffffc0206e2c:	8526                	mv	a0,s1
ffffffffc0206e2e:	cd5ff0ef          	jal	ra,ffffffffc0206b02 <wakeup_proc>
                del_timer(timer);
ffffffffc0206e32:	854a                	mv	a0,s2
ffffffffc0206e34:	f1bff0ef          	jal	ra,ffffffffc0206d4e <del_timer>
                if (le == &timer_list) {
ffffffffc0206e38:	03340c63          	beq	s0,s3,ffffffffc0206e70 <run_timer_list+0x9c>
            while (timer->expires == 0) {
ffffffffc0206e3c:	ff042783          	lw	a5,-16(s0)
                    break;
                }
                timer = le2timer(le, timer_link);
ffffffffc0206e40:	ff040913          	addi	s2,s0,-16
            while (timer->expires == 0) {
ffffffffc0206e44:	e795                	bnez	a5,ffffffffc0206e70 <run_timer_list+0x9c>
                struct proc_struct *proc = timer->proc;
ffffffffc0206e46:	00893483          	ld	s1,8(s2)
ffffffffc0206e4a:	6400                	ld	s0,8(s0)
                if (proc->wait_state != 0) {
ffffffffc0206e4c:	0ec4a783          	lw	a5,236(s1)
ffffffffc0206e50:	ffe1                	bnez	a5,ffffffffc0206e28 <run_timer_list+0x54>
                    warn("process %d's wait_state == 0.\n", proc->pid);
ffffffffc0206e52:	40d4                	lw	a3,4(s1)
ffffffffc0206e54:	8656                	mv	a2,s5
ffffffffc0206e56:	0a300593          	li	a1,163
ffffffffc0206e5a:	8552                	mv	a0,s4
ffffffffc0206e5c:	e98f90ef          	jal	ra,ffffffffc02004f4 <__warn>
                wakeup_proc(proc);
ffffffffc0206e60:	8526                	mv	a0,s1
ffffffffc0206e62:	ca1ff0ef          	jal	ra,ffffffffc0206b02 <wakeup_proc>
                del_timer(timer);
ffffffffc0206e66:	854a                	mv	a0,s2
ffffffffc0206e68:	ee7ff0ef          	jal	ra,ffffffffc0206d4e <del_timer>
                if (le == &timer_list) {
ffffffffc0206e6c:	fd3418e3          	bne	s0,s3,ffffffffc0206e3c <run_timer_list+0x68>
            }
        }
        sched_class_proc_tick(current);
ffffffffc0206e70:	000d8797          	auipc	a5,0xd8
ffffffffc0206e74:	44078793          	addi	a5,a5,1088 # ffffffffc02df2b0 <current>
ffffffffc0206e78:	638c                	ld	a1,0(a5)
    if (proc != idleproc) {
ffffffffc0206e7a:	000d8797          	auipc	a5,0xd8
ffffffffc0206e7e:	43e78793          	addi	a5,a5,1086 # ffffffffc02df2b8 <idleproc>
ffffffffc0206e82:	639c                	ld	a5,0(a5)
ffffffffc0206e84:	04f58563          	beq	a1,a5,ffffffffc0206ece <run_timer_list+0xfa>
        sched_class->proc_tick(rq, proc);
ffffffffc0206e88:	000d8797          	auipc	a5,0xd8
ffffffffc0206e8c:	45078793          	addi	a5,a5,1104 # ffffffffc02df2d8 <sched_class>
ffffffffc0206e90:	639c                	ld	a5,0(a5)
ffffffffc0206e92:	000d8717          	auipc	a4,0xd8
ffffffffc0206e96:	43e70713          	addi	a4,a4,1086 # ffffffffc02df2d0 <rq>
ffffffffc0206e9a:	6308                	ld	a0,0(a4)
ffffffffc0206e9c:	779c                	ld	a5,40(a5)
ffffffffc0206e9e:	9782                	jalr	a5
    if (flag) {
ffffffffc0206ea0:	000b1c63          	bnez	s6,ffffffffc0206eb8 <run_timer_list+0xe4>
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206ea4:	70e2                	ld	ra,56(sp)
ffffffffc0206ea6:	7442                	ld	s0,48(sp)
ffffffffc0206ea8:	74a2                	ld	s1,40(sp)
ffffffffc0206eaa:	7902                	ld	s2,32(sp)
ffffffffc0206eac:	69e2                	ld	s3,24(sp)
ffffffffc0206eae:	6a42                	ld	s4,16(sp)
ffffffffc0206eb0:	6aa2                	ld	s5,8(sp)
ffffffffc0206eb2:	6b02                	ld	s6,0(sp)
ffffffffc0206eb4:	6121                	addi	sp,sp,64
ffffffffc0206eb6:	8082                	ret
ffffffffc0206eb8:	7442                	ld	s0,48(sp)
ffffffffc0206eba:	70e2                	ld	ra,56(sp)
ffffffffc0206ebc:	74a2                	ld	s1,40(sp)
ffffffffc0206ebe:	7902                	ld	s2,32(sp)
ffffffffc0206ec0:	69e2                	ld	s3,24(sp)
ffffffffc0206ec2:	6a42                	ld	s4,16(sp)
ffffffffc0206ec4:	6aa2                	ld	s5,8(sp)
ffffffffc0206ec6:	6b02                	ld	s6,0(sp)
ffffffffc0206ec8:	6121                	addi	sp,sp,64
        intr_enable();
ffffffffc0206eca:	f82f906f          	j	ffffffffc020064c <intr_enable>
        proc->need_resched = 1;
ffffffffc0206ece:	4785                	li	a5,1
ffffffffc0206ed0:	ed9c                	sd	a5,24(a1)
ffffffffc0206ed2:	b7f9                	j	ffffffffc0206ea0 <run_timer_list+0xcc>
        intr_disable();
ffffffffc0206ed4:	f7ef90ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0206ed8:	4b05                	li	s6,1
ffffffffc0206eda:	bf19                	j	ffffffffc0206df0 <run_timer_list+0x1c>
                    assert(proc->wait_state & WT_INTERRUPTED);
ffffffffc0206edc:	00003697          	auipc	a3,0x3
ffffffffc0206ee0:	dcc68693          	addi	a3,a3,-564 # ffffffffc0209ca8 <default_pmm_manager+0x1a70>
ffffffffc0206ee4:	00001617          	auipc	a2,0x1
ffffffffc0206ee8:	c0c60613          	addi	a2,a2,-1012 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0206eec:	0a000593          	li	a1,160
ffffffffc0206ef0:	00003517          	auipc	a0,0x3
ffffffffc0206ef4:	e3850513          	addi	a0,a0,-456 # ffffffffc0209d28 <default_pmm_manager+0x1af0>
ffffffffc0206ef8:	d90f90ef          	jal	ra,ffffffffc0200488 <__panic>
            assert(timer->expires != 0);
ffffffffc0206efc:	00003697          	auipc	a3,0x3
ffffffffc0206f00:	d9468693          	addi	a3,a3,-620 # ffffffffc0209c90 <default_pmm_manager+0x1a58>
ffffffffc0206f04:	00001617          	auipc	a2,0x1
ffffffffc0206f08:	bec60613          	addi	a2,a2,-1044 # ffffffffc0207af0 <commands+0x4c0>
ffffffffc0206f0c:	09a00593          	li	a1,154
ffffffffc0206f10:	00003517          	auipc	a0,0x3
ffffffffc0206f14:	e1850513          	addi	a0,a0,-488 # ffffffffc0209d28 <default_pmm_manager+0x1af0>
ffffffffc0206f18:	d70f90ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0206f1c <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0206f1c:	000d8797          	auipc	a5,0xd8
ffffffffc0206f20:	39478793          	addi	a5,a5,916 # ffffffffc02df2b0 <current>
ffffffffc0206f24:	639c                	ld	a5,0(a5)
}
ffffffffc0206f26:	43c8                	lw	a0,4(a5)
ffffffffc0206f28:	8082                	ret

ffffffffc0206f2a <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206f2a:	4501                	li	a0,0
ffffffffc0206f2c:	8082                	ret

ffffffffc0206f2e <sys_gettime>:
static int sys_gettime(uint64_t arg[]){
    return (int)ticks*10;
ffffffffc0206f2e:	000d8797          	auipc	a5,0xd8
ffffffffc0206f32:	3b278793          	addi	a5,a5,946 # ffffffffc02df2e0 <ticks>
ffffffffc0206f36:	639c                	ld	a5,0(a5)
ffffffffc0206f38:	0027951b          	slliw	a0,a5,0x2
ffffffffc0206f3c:	9d3d                	addw	a0,a0,a5
}
ffffffffc0206f3e:	0015151b          	slliw	a0,a0,0x1
ffffffffc0206f42:	8082                	ret

ffffffffc0206f44 <sys_lab6_set_priority>:
static int sys_lab6_set_priority(uint64_t arg[]){
    uint64_t priority = (uint64_t)arg[0];
    lab6_set_priority(priority);
ffffffffc0206f44:	4108                	lw	a0,0(a0)
static int sys_lab6_set_priority(uint64_t arg[]){
ffffffffc0206f46:	1141                	addi	sp,sp,-16
ffffffffc0206f48:	e406                	sd	ra,8(sp)
    lab6_set_priority(priority);
ffffffffc0206f4a:	955ff0ef          	jal	ra,ffffffffc020689e <lab6_set_priority>
    return 0;
}
ffffffffc0206f4e:	60a2                	ld	ra,8(sp)
ffffffffc0206f50:	4501                	li	a0,0
ffffffffc0206f52:	0141                	addi	sp,sp,16
ffffffffc0206f54:	8082                	ret

ffffffffc0206f56 <sys_putc>:
    cputchar(c);
ffffffffc0206f56:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206f58:	1141                	addi	sp,sp,-16
ffffffffc0206f5a:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0206f5c:	a6af90ef          	jal	ra,ffffffffc02001c6 <cputchar>
}
ffffffffc0206f60:	60a2                	ld	ra,8(sp)
ffffffffc0206f62:	4501                	li	a0,0
ffffffffc0206f64:	0141                	addi	sp,sp,16
ffffffffc0206f66:	8082                	ret

ffffffffc0206f68 <sys_kill>:
    return do_kill(pid);
ffffffffc0206f68:	4108                	lw	a0,0(a0)
ffffffffc0206f6a:	f86ff06f          	j	ffffffffc02066f0 <do_kill>

ffffffffc0206f6e <sys_sleep>:
static int
sys_sleep(uint64_t arg[]) {
    unsigned int time = (unsigned int)arg[0];
    return do_sleep(time);
ffffffffc0206f6e:	4108                	lw	a0,0(a0)
ffffffffc0206f70:	96bff06f          	j	ffffffffc02068da <do_sleep>

ffffffffc0206f74 <sys_yield>:
    return do_yield();
ffffffffc0206f74:	f2aff06f          	j	ffffffffc020669e <do_yield>

ffffffffc0206f78 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0206f78:	6d14                	ld	a3,24(a0)
ffffffffc0206f7a:	6910                	ld	a2,16(a0)
ffffffffc0206f7c:	650c                	ld	a1,8(a0)
ffffffffc0206f7e:	6108                	ld	a0,0(a0)
ffffffffc0206f80:	98cff06f          	j	ffffffffc020610c <do_execve>

ffffffffc0206f84 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0206f84:	650c                	ld	a1,8(a0)
ffffffffc0206f86:	4108                	lw	a0,0(a0)
ffffffffc0206f88:	f28ff06f          	j	ffffffffc02066b0 <do_wait>

ffffffffc0206f8c <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0206f8c:	000d8797          	auipc	a5,0xd8
ffffffffc0206f90:	32478793          	addi	a5,a5,804 # ffffffffc02df2b0 <current>
ffffffffc0206f94:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc0206f96:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0206f98:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0206f9a:	6a0c                	ld	a1,16(a2)
ffffffffc0206f9c:	89ffe06f          	j	ffffffffc020583a <do_fork>

ffffffffc0206fa0 <sys_exit>:
    return do_exit(error_code);
ffffffffc0206fa0:	4108                	lw	a0,0(a0)
ffffffffc0206fa2:	cd7fe06f          	j	ffffffffc0205c78 <do_exit>

ffffffffc0206fa6 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0206fa6:	715d                	addi	sp,sp,-80
ffffffffc0206fa8:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206faa:	000d8497          	auipc	s1,0xd8
ffffffffc0206fae:	30648493          	addi	s1,s1,774 # ffffffffc02df2b0 <current>
ffffffffc0206fb2:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0206fb4:	e0a2                	sd	s0,64(sp)
ffffffffc0206fb6:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206fb8:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0206fba:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206fbc:	0ff00793          	li	a5,255
    int num = tf->gpr.a0;
ffffffffc0206fc0:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206fc4:	0327ee63          	bltu	a5,s2,ffffffffc0207000 <syscall+0x5a>
        if (syscalls[num] != NULL) {
ffffffffc0206fc8:	00391713          	slli	a4,s2,0x3
ffffffffc0206fcc:	00003797          	auipc	a5,0x3
ffffffffc0206fd0:	ddc78793          	addi	a5,a5,-548 # ffffffffc0209da8 <syscalls>
ffffffffc0206fd4:	97ba                	add	a5,a5,a4
ffffffffc0206fd6:	639c                	ld	a5,0(a5)
ffffffffc0206fd8:	c785                	beqz	a5,ffffffffc0207000 <syscall+0x5a>
            arg[0] = tf->gpr.a1;
ffffffffc0206fda:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0206fdc:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0206fde:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0206fe0:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0206fe2:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0206fe4:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0206fe6:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0206fe8:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0206fea:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0206fec:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206fee:	0028                	addi	a0,sp,8
ffffffffc0206ff0:	9782                	jalr	a5
ffffffffc0206ff2:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0206ff4:	60a6                	ld	ra,72(sp)
ffffffffc0206ff6:	6406                	ld	s0,64(sp)
ffffffffc0206ff8:	74e2                	ld	s1,56(sp)
ffffffffc0206ffa:	7942                	ld	s2,48(sp)
ffffffffc0206ffc:	6161                	addi	sp,sp,80
ffffffffc0206ffe:	8082                	ret
    print_trapframe(tf);
ffffffffc0207000:	8522                	mv	a0,s0
ffffffffc0207002:	841f90ef          	jal	ra,ffffffffc0200842 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0207006:	609c                	ld	a5,0(s1)
ffffffffc0207008:	86ca                	mv	a3,s2
ffffffffc020700a:	00003617          	auipc	a2,0x3
ffffffffc020700e:	d5660613          	addi	a2,a2,-682 # ffffffffc0209d60 <default_pmm_manager+0x1b28>
ffffffffc0207012:	43d8                	lw	a4,4(a5)
ffffffffc0207014:	07400593          	li	a1,116
ffffffffc0207018:	0b478793          	addi	a5,a5,180
ffffffffc020701c:	00003517          	auipc	a0,0x3
ffffffffc0207020:	d7450513          	addi	a0,a0,-652 # ffffffffc0209d90 <default_pmm_manager+0x1b58>
ffffffffc0207024:	c64f90ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0207028 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0207028:	9e3707b7          	lui	a5,0x9e370
ffffffffc020702c:	2785                	addiw	a5,a5,1
ffffffffc020702e:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0207032:	02000793          	li	a5,32
ffffffffc0207036:	40b785bb          	subw	a1,a5,a1
}
ffffffffc020703a:	00b5553b          	srlw	a0,a0,a1
ffffffffc020703e:	8082                	ret

ffffffffc0207040 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0207040:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0207044:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0207046:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020704a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020704c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0207050:	f022                	sd	s0,32(sp)
ffffffffc0207052:	ec26                	sd	s1,24(sp)
ffffffffc0207054:	e84a                	sd	s2,16(sp)
ffffffffc0207056:	f406                	sd	ra,40(sp)
ffffffffc0207058:	e44e                	sd	s3,8(sp)
ffffffffc020705a:	84aa                	mv	s1,a0
ffffffffc020705c:	892e                	mv	s2,a1
ffffffffc020705e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0207062:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0207064:	03067e63          	bleu	a6,a2,ffffffffc02070a0 <printnum+0x60>
ffffffffc0207068:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020706a:	00805763          	blez	s0,ffffffffc0207078 <printnum+0x38>
ffffffffc020706e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0207070:	85ca                	mv	a1,s2
ffffffffc0207072:	854e                	mv	a0,s3
ffffffffc0207074:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0207076:	fc65                	bnez	s0,ffffffffc020706e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0207078:	1a02                	slli	s4,s4,0x20
ffffffffc020707a:	020a5a13          	srli	s4,s4,0x20
ffffffffc020707e:	00003797          	auipc	a5,0x3
ffffffffc0207082:	74a78793          	addi	a5,a5,1866 # ffffffffc020a7c8 <error_string+0xc8>
ffffffffc0207086:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0207088:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020708a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020708e:	70a2                	ld	ra,40(sp)
ffffffffc0207090:	69a2                	ld	s3,8(sp)
ffffffffc0207092:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0207094:	85ca                	mv	a1,s2
ffffffffc0207096:	8326                	mv	t1,s1
}
ffffffffc0207098:	6942                	ld	s2,16(sp)
ffffffffc020709a:	64e2                	ld	s1,24(sp)
ffffffffc020709c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020709e:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02070a0:	03065633          	divu	a2,a2,a6
ffffffffc02070a4:	8722                	mv	a4,s0
ffffffffc02070a6:	f9bff0ef          	jal	ra,ffffffffc0207040 <printnum>
ffffffffc02070aa:	b7f9                	j	ffffffffc0207078 <printnum+0x38>

ffffffffc02070ac <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02070ac:	7119                	addi	sp,sp,-128
ffffffffc02070ae:	f4a6                	sd	s1,104(sp)
ffffffffc02070b0:	f0ca                	sd	s2,96(sp)
ffffffffc02070b2:	e8d2                	sd	s4,80(sp)
ffffffffc02070b4:	e4d6                	sd	s5,72(sp)
ffffffffc02070b6:	e0da                	sd	s6,64(sp)
ffffffffc02070b8:	fc5e                	sd	s7,56(sp)
ffffffffc02070ba:	f862                	sd	s8,48(sp)
ffffffffc02070bc:	f06a                	sd	s10,32(sp)
ffffffffc02070be:	fc86                	sd	ra,120(sp)
ffffffffc02070c0:	f8a2                	sd	s0,112(sp)
ffffffffc02070c2:	ecce                	sd	s3,88(sp)
ffffffffc02070c4:	f466                	sd	s9,40(sp)
ffffffffc02070c6:	ec6e                	sd	s11,24(sp)
ffffffffc02070c8:	892a                	mv	s2,a0
ffffffffc02070ca:	84ae                	mv	s1,a1
ffffffffc02070cc:	8d32                	mv	s10,a2
ffffffffc02070ce:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02070d0:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02070d2:	00003a17          	auipc	s4,0x3
ffffffffc02070d6:	4d6a0a13          	addi	s4,s4,1238 # ffffffffc020a5a8 <syscalls+0x800>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02070da:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02070de:	00003c17          	auipc	s8,0x3
ffffffffc02070e2:	622c0c13          	addi	s8,s8,1570 # ffffffffc020a700 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02070e6:	000d4503          	lbu	a0,0(s10)
ffffffffc02070ea:	02500793          	li	a5,37
ffffffffc02070ee:	001d0413          	addi	s0,s10,1
ffffffffc02070f2:	00f50e63          	beq	a0,a5,ffffffffc020710e <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02070f6:	c521                	beqz	a0,ffffffffc020713e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02070f8:	02500993          	li	s3,37
ffffffffc02070fc:	a011                	j	ffffffffc0207100 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02070fe:	c121                	beqz	a0,ffffffffc020713e <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0207100:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0207102:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0207104:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0207106:	fff44503          	lbu	a0,-1(s0)
ffffffffc020710a:	ff351ae3          	bne	a0,s3,ffffffffc02070fe <vprintfmt+0x52>
ffffffffc020710e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0207112:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0207116:	4981                	li	s3,0
ffffffffc0207118:	4801                	li	a6,0
        width = precision = -1;
ffffffffc020711a:	5cfd                	li	s9,-1
ffffffffc020711c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020711e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0207122:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0207124:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0207128:	0ff6f693          	andi	a3,a3,255
ffffffffc020712c:	00140d13          	addi	s10,s0,1
ffffffffc0207130:	20d5e563          	bltu	a1,a3,ffffffffc020733a <vprintfmt+0x28e>
ffffffffc0207134:	068a                	slli	a3,a3,0x2
ffffffffc0207136:	96d2                	add	a3,a3,s4
ffffffffc0207138:	4294                	lw	a3,0(a3)
ffffffffc020713a:	96d2                	add	a3,a3,s4
ffffffffc020713c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020713e:	70e6                	ld	ra,120(sp)
ffffffffc0207140:	7446                	ld	s0,112(sp)
ffffffffc0207142:	74a6                	ld	s1,104(sp)
ffffffffc0207144:	7906                	ld	s2,96(sp)
ffffffffc0207146:	69e6                	ld	s3,88(sp)
ffffffffc0207148:	6a46                	ld	s4,80(sp)
ffffffffc020714a:	6aa6                	ld	s5,72(sp)
ffffffffc020714c:	6b06                	ld	s6,64(sp)
ffffffffc020714e:	7be2                	ld	s7,56(sp)
ffffffffc0207150:	7c42                	ld	s8,48(sp)
ffffffffc0207152:	7ca2                	ld	s9,40(sp)
ffffffffc0207154:	7d02                	ld	s10,32(sp)
ffffffffc0207156:	6de2                	ld	s11,24(sp)
ffffffffc0207158:	6109                	addi	sp,sp,128
ffffffffc020715a:	8082                	ret
    if (lflag >= 2) {
ffffffffc020715c:	4705                	li	a4,1
ffffffffc020715e:	008a8593          	addi	a1,s5,8
ffffffffc0207162:	01074463          	blt	a4,a6,ffffffffc020716a <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0207166:	26080363          	beqz	a6,ffffffffc02073cc <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc020716a:	000ab603          	ld	a2,0(s5)
ffffffffc020716e:	46c1                	li	a3,16
ffffffffc0207170:	8aae                	mv	s5,a1
ffffffffc0207172:	a06d                	j	ffffffffc020721c <vprintfmt+0x170>
            goto reswitch;
ffffffffc0207174:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0207178:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020717a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020717c:	b765                	j	ffffffffc0207124 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc020717e:	000aa503          	lw	a0,0(s5)
ffffffffc0207182:	85a6                	mv	a1,s1
ffffffffc0207184:	0aa1                	addi	s5,s5,8
ffffffffc0207186:	9902                	jalr	s2
            break;
ffffffffc0207188:	bfb9                	j	ffffffffc02070e6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020718a:	4705                	li	a4,1
ffffffffc020718c:	008a8993          	addi	s3,s5,8
ffffffffc0207190:	01074463          	blt	a4,a6,ffffffffc0207198 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0207194:	22080463          	beqz	a6,ffffffffc02073bc <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0207198:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc020719c:	24044463          	bltz	s0,ffffffffc02073e4 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02071a0:	8622                	mv	a2,s0
ffffffffc02071a2:	8ace                	mv	s5,s3
ffffffffc02071a4:	46a9                	li	a3,10
ffffffffc02071a6:	a89d                	j	ffffffffc020721c <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02071a8:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02071ac:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02071ae:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02071b0:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02071b4:	8fb5                	xor	a5,a5,a3
ffffffffc02071b6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02071ba:	1ad74363          	blt	a4,a3,ffffffffc0207360 <vprintfmt+0x2b4>
ffffffffc02071be:	00369793          	slli	a5,a3,0x3
ffffffffc02071c2:	97e2                	add	a5,a5,s8
ffffffffc02071c4:	639c                	ld	a5,0(a5)
ffffffffc02071c6:	18078d63          	beqz	a5,ffffffffc0207360 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02071ca:	86be                	mv	a3,a5
ffffffffc02071cc:	00000617          	auipc	a2,0x0
ffffffffc02071d0:	35c60613          	addi	a2,a2,860 # ffffffffc0207528 <etext+0x28>
ffffffffc02071d4:	85a6                	mv	a1,s1
ffffffffc02071d6:	854a                	mv	a0,s2
ffffffffc02071d8:	240000ef          	jal	ra,ffffffffc0207418 <printfmt>
ffffffffc02071dc:	b729                	j	ffffffffc02070e6 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02071de:	00144603          	lbu	a2,1(s0)
ffffffffc02071e2:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02071e4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02071e6:	bf3d                	j	ffffffffc0207124 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02071e8:	4705                	li	a4,1
ffffffffc02071ea:	008a8593          	addi	a1,s5,8
ffffffffc02071ee:	01074463          	blt	a4,a6,ffffffffc02071f6 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02071f2:	1e080263          	beqz	a6,ffffffffc02073d6 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02071f6:	000ab603          	ld	a2,0(s5)
ffffffffc02071fa:	46a1                	li	a3,8
ffffffffc02071fc:	8aae                	mv	s5,a1
ffffffffc02071fe:	a839                	j	ffffffffc020721c <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0207200:	03000513          	li	a0,48
ffffffffc0207204:	85a6                	mv	a1,s1
ffffffffc0207206:	e03e                	sd	a5,0(sp)
ffffffffc0207208:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020720a:	85a6                	mv	a1,s1
ffffffffc020720c:	07800513          	li	a0,120
ffffffffc0207210:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0207212:	0aa1                	addi	s5,s5,8
ffffffffc0207214:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0207218:	6782                	ld	a5,0(sp)
ffffffffc020721a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020721c:	876e                	mv	a4,s11
ffffffffc020721e:	85a6                	mv	a1,s1
ffffffffc0207220:	854a                	mv	a0,s2
ffffffffc0207222:	e1fff0ef          	jal	ra,ffffffffc0207040 <printnum>
            break;
ffffffffc0207226:	b5c1                	j	ffffffffc02070e6 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0207228:	000ab603          	ld	a2,0(s5)
ffffffffc020722c:	0aa1                	addi	s5,s5,8
ffffffffc020722e:	1c060663          	beqz	a2,ffffffffc02073fa <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0207232:	00160413          	addi	s0,a2,1
ffffffffc0207236:	17b05c63          	blez	s11,ffffffffc02073ae <vprintfmt+0x302>
ffffffffc020723a:	02d00593          	li	a1,45
ffffffffc020723e:	14b79263          	bne	a5,a1,ffffffffc0207382 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0207242:	00064783          	lbu	a5,0(a2)
ffffffffc0207246:	0007851b          	sext.w	a0,a5
ffffffffc020724a:	c905                	beqz	a0,ffffffffc020727a <vprintfmt+0x1ce>
ffffffffc020724c:	000cc563          	bltz	s9,ffffffffc0207256 <vprintfmt+0x1aa>
ffffffffc0207250:	3cfd                	addiw	s9,s9,-1
ffffffffc0207252:	036c8263          	beq	s9,s6,ffffffffc0207276 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0207256:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0207258:	18098463          	beqz	s3,ffffffffc02073e0 <vprintfmt+0x334>
ffffffffc020725c:	3781                	addiw	a5,a5,-32
ffffffffc020725e:	18fbf163          	bleu	a5,s7,ffffffffc02073e0 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0207262:	03f00513          	li	a0,63
ffffffffc0207266:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0207268:	0405                	addi	s0,s0,1
ffffffffc020726a:	fff44783          	lbu	a5,-1(s0)
ffffffffc020726e:	3dfd                	addiw	s11,s11,-1
ffffffffc0207270:	0007851b          	sext.w	a0,a5
ffffffffc0207274:	fd61                	bnez	a0,ffffffffc020724c <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0207276:	e7b058e3          	blez	s11,ffffffffc02070e6 <vprintfmt+0x3a>
ffffffffc020727a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020727c:	85a6                	mv	a1,s1
ffffffffc020727e:	02000513          	li	a0,32
ffffffffc0207282:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0207284:	e60d81e3          	beqz	s11,ffffffffc02070e6 <vprintfmt+0x3a>
ffffffffc0207288:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020728a:	85a6                	mv	a1,s1
ffffffffc020728c:	02000513          	li	a0,32
ffffffffc0207290:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0207292:	fe0d94e3          	bnez	s11,ffffffffc020727a <vprintfmt+0x1ce>
ffffffffc0207296:	bd81                	j	ffffffffc02070e6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0207298:	4705                	li	a4,1
ffffffffc020729a:	008a8593          	addi	a1,s5,8
ffffffffc020729e:	01074463          	blt	a4,a6,ffffffffc02072a6 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02072a2:	12080063          	beqz	a6,ffffffffc02073c2 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02072a6:	000ab603          	ld	a2,0(s5)
ffffffffc02072aa:	46a9                	li	a3,10
ffffffffc02072ac:	8aae                	mv	s5,a1
ffffffffc02072ae:	b7bd                	j	ffffffffc020721c <vprintfmt+0x170>
ffffffffc02072b0:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02072b4:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02072b8:	846a                	mv	s0,s10
ffffffffc02072ba:	b5ad                	j	ffffffffc0207124 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02072bc:	85a6                	mv	a1,s1
ffffffffc02072be:	02500513          	li	a0,37
ffffffffc02072c2:	9902                	jalr	s2
            break;
ffffffffc02072c4:	b50d                	j	ffffffffc02070e6 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02072c6:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02072ca:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02072ce:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02072d0:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02072d2:	e40dd9e3          	bgez	s11,ffffffffc0207124 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02072d6:	8de6                	mv	s11,s9
ffffffffc02072d8:	5cfd                	li	s9,-1
ffffffffc02072da:	b5a9                	j	ffffffffc0207124 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02072dc:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02072e0:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02072e4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02072e6:	bd3d                	j	ffffffffc0207124 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02072e8:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02072ec:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02072f0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02072f2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02072f6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02072fa:	fcd56ce3          	bltu	a0,a3,ffffffffc02072d2 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02072fe:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0207300:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0207304:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0207308:	0196873b          	addw	a4,a3,s9
ffffffffc020730c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0207310:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0207314:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0207318:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020731c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0207320:	fcd57fe3          	bleu	a3,a0,ffffffffc02072fe <vprintfmt+0x252>
ffffffffc0207324:	b77d                	j	ffffffffc02072d2 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0207326:	fffdc693          	not	a3,s11
ffffffffc020732a:	96fd                	srai	a3,a3,0x3f
ffffffffc020732c:	00ddfdb3          	and	s11,s11,a3
ffffffffc0207330:	00144603          	lbu	a2,1(s0)
ffffffffc0207334:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0207336:	846a                	mv	s0,s10
ffffffffc0207338:	b3f5                	j	ffffffffc0207124 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020733a:	85a6                	mv	a1,s1
ffffffffc020733c:	02500513          	li	a0,37
ffffffffc0207340:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0207342:	fff44703          	lbu	a4,-1(s0)
ffffffffc0207346:	02500793          	li	a5,37
ffffffffc020734a:	8d22                	mv	s10,s0
ffffffffc020734c:	d8f70de3          	beq	a4,a5,ffffffffc02070e6 <vprintfmt+0x3a>
ffffffffc0207350:	02500713          	li	a4,37
ffffffffc0207354:	1d7d                	addi	s10,s10,-1
ffffffffc0207356:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020735a:	fee79de3          	bne	a5,a4,ffffffffc0207354 <vprintfmt+0x2a8>
ffffffffc020735e:	b361                	j	ffffffffc02070e6 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0207360:	00003617          	auipc	a2,0x3
ffffffffc0207364:	54860613          	addi	a2,a2,1352 # ffffffffc020a8a8 <error_string+0x1a8>
ffffffffc0207368:	85a6                	mv	a1,s1
ffffffffc020736a:	854a                	mv	a0,s2
ffffffffc020736c:	0ac000ef          	jal	ra,ffffffffc0207418 <printfmt>
ffffffffc0207370:	bb9d                	j	ffffffffc02070e6 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0207372:	00003617          	auipc	a2,0x3
ffffffffc0207376:	52e60613          	addi	a2,a2,1326 # ffffffffc020a8a0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc020737a:	00003417          	auipc	s0,0x3
ffffffffc020737e:	52740413          	addi	s0,s0,1319 # ffffffffc020a8a1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0207382:	8532                	mv	a0,a2
ffffffffc0207384:	85e6                	mv	a1,s9
ffffffffc0207386:	e032                	sd	a2,0(sp)
ffffffffc0207388:	e43e                	sd	a5,8(sp)
ffffffffc020738a:	0cc000ef          	jal	ra,ffffffffc0207456 <strnlen>
ffffffffc020738e:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0207392:	6602                	ld	a2,0(sp)
ffffffffc0207394:	01b05d63          	blez	s11,ffffffffc02073ae <vprintfmt+0x302>
ffffffffc0207398:	67a2                	ld	a5,8(sp)
ffffffffc020739a:	2781                	sext.w	a5,a5
ffffffffc020739c:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020739e:	6522                	ld	a0,8(sp)
ffffffffc02073a0:	85a6                	mv	a1,s1
ffffffffc02073a2:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02073a4:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02073a6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02073a8:	6602                	ld	a2,0(sp)
ffffffffc02073aa:	fe0d9ae3          	bnez	s11,ffffffffc020739e <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02073ae:	00064783          	lbu	a5,0(a2)
ffffffffc02073b2:	0007851b          	sext.w	a0,a5
ffffffffc02073b6:	e8051be3          	bnez	a0,ffffffffc020724c <vprintfmt+0x1a0>
ffffffffc02073ba:	b335                	j	ffffffffc02070e6 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02073bc:	000aa403          	lw	s0,0(s5)
ffffffffc02073c0:	bbf1                	j	ffffffffc020719c <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02073c2:	000ae603          	lwu	a2,0(s5)
ffffffffc02073c6:	46a9                	li	a3,10
ffffffffc02073c8:	8aae                	mv	s5,a1
ffffffffc02073ca:	bd89                	j	ffffffffc020721c <vprintfmt+0x170>
ffffffffc02073cc:	000ae603          	lwu	a2,0(s5)
ffffffffc02073d0:	46c1                	li	a3,16
ffffffffc02073d2:	8aae                	mv	s5,a1
ffffffffc02073d4:	b5a1                	j	ffffffffc020721c <vprintfmt+0x170>
ffffffffc02073d6:	000ae603          	lwu	a2,0(s5)
ffffffffc02073da:	46a1                	li	a3,8
ffffffffc02073dc:	8aae                	mv	s5,a1
ffffffffc02073de:	bd3d                	j	ffffffffc020721c <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02073e0:	9902                	jalr	s2
ffffffffc02073e2:	b559                	j	ffffffffc0207268 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02073e4:	85a6                	mv	a1,s1
ffffffffc02073e6:	02d00513          	li	a0,45
ffffffffc02073ea:	e03e                	sd	a5,0(sp)
ffffffffc02073ec:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02073ee:	8ace                	mv	s5,s3
ffffffffc02073f0:	40800633          	neg	a2,s0
ffffffffc02073f4:	46a9                	li	a3,10
ffffffffc02073f6:	6782                	ld	a5,0(sp)
ffffffffc02073f8:	b515                	j	ffffffffc020721c <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02073fa:	01b05663          	blez	s11,ffffffffc0207406 <vprintfmt+0x35a>
ffffffffc02073fe:	02d00693          	li	a3,45
ffffffffc0207402:	f6d798e3          	bne	a5,a3,ffffffffc0207372 <vprintfmt+0x2c6>
ffffffffc0207406:	00003417          	auipc	s0,0x3
ffffffffc020740a:	49b40413          	addi	s0,s0,1179 # ffffffffc020a8a1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020740e:	02800513          	li	a0,40
ffffffffc0207412:	02800793          	li	a5,40
ffffffffc0207416:	bd1d                	j	ffffffffc020724c <vprintfmt+0x1a0>

ffffffffc0207418 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0207418:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020741a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020741e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0207420:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0207422:	ec06                	sd	ra,24(sp)
ffffffffc0207424:	f83a                	sd	a4,48(sp)
ffffffffc0207426:	fc3e                	sd	a5,56(sp)
ffffffffc0207428:	e0c2                	sd	a6,64(sp)
ffffffffc020742a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020742c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020742e:	c7fff0ef          	jal	ra,ffffffffc02070ac <vprintfmt>
}
ffffffffc0207432:	60e2                	ld	ra,24(sp)
ffffffffc0207434:	6161                	addi	sp,sp,80
ffffffffc0207436:	8082                	ret

ffffffffc0207438 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0207438:	00054783          	lbu	a5,0(a0)
ffffffffc020743c:	cb91                	beqz	a5,ffffffffc0207450 <strlen+0x18>
    size_t cnt = 0;
ffffffffc020743e:	4781                	li	a5,0
        cnt ++;
ffffffffc0207440:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0207442:	00f50733          	add	a4,a0,a5
ffffffffc0207446:	00074703          	lbu	a4,0(a4)
ffffffffc020744a:	fb7d                	bnez	a4,ffffffffc0207440 <strlen+0x8>
    }
    return cnt;
}
ffffffffc020744c:	853e                	mv	a0,a5
ffffffffc020744e:	8082                	ret
    size_t cnt = 0;
ffffffffc0207450:	4781                	li	a5,0
}
ffffffffc0207452:	853e                	mv	a0,a5
ffffffffc0207454:	8082                	ret

ffffffffc0207456 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0207456:	c185                	beqz	a1,ffffffffc0207476 <strnlen+0x20>
ffffffffc0207458:	00054783          	lbu	a5,0(a0)
ffffffffc020745c:	cf89                	beqz	a5,ffffffffc0207476 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc020745e:	4781                	li	a5,0
ffffffffc0207460:	a021                	j	ffffffffc0207468 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0207462:	00074703          	lbu	a4,0(a4)
ffffffffc0207466:	c711                	beqz	a4,ffffffffc0207472 <strnlen+0x1c>
        cnt ++;
ffffffffc0207468:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020746a:	00f50733          	add	a4,a0,a5
ffffffffc020746e:	fef59ae3          	bne	a1,a5,ffffffffc0207462 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0207472:	853e                	mv	a0,a5
ffffffffc0207474:	8082                	ret
    size_t cnt = 0;
ffffffffc0207476:	4781                	li	a5,0
}
ffffffffc0207478:	853e                	mv	a0,a5
ffffffffc020747a:	8082                	ret

ffffffffc020747c <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020747c:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020747e:	0585                	addi	a1,a1,1
ffffffffc0207480:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0207484:	0785                	addi	a5,a5,1
ffffffffc0207486:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020748a:	fb75                	bnez	a4,ffffffffc020747e <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020748c:	8082                	ret

ffffffffc020748e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020748e:	00054783          	lbu	a5,0(a0)
ffffffffc0207492:	0005c703          	lbu	a4,0(a1)
ffffffffc0207496:	cb91                	beqz	a5,ffffffffc02074aa <strcmp+0x1c>
ffffffffc0207498:	00e79c63          	bne	a5,a4,ffffffffc02074b0 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020749c:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020749e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02074a2:	0585                	addi	a1,a1,1
ffffffffc02074a4:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02074a8:	fbe5                	bnez	a5,ffffffffc0207498 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02074aa:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02074ac:	9d19                	subw	a0,a0,a4
ffffffffc02074ae:	8082                	ret
ffffffffc02074b0:	0007851b          	sext.w	a0,a5
ffffffffc02074b4:	9d19                	subw	a0,a0,a4
ffffffffc02074b6:	8082                	ret

ffffffffc02074b8 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02074b8:	00054783          	lbu	a5,0(a0)
ffffffffc02074bc:	cb91                	beqz	a5,ffffffffc02074d0 <strchr+0x18>
        if (*s == c) {
ffffffffc02074be:	00b79563          	bne	a5,a1,ffffffffc02074c8 <strchr+0x10>
ffffffffc02074c2:	a809                	j	ffffffffc02074d4 <strchr+0x1c>
ffffffffc02074c4:	00b78763          	beq	a5,a1,ffffffffc02074d2 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02074c8:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02074ca:	00054783          	lbu	a5,0(a0)
ffffffffc02074ce:	fbfd                	bnez	a5,ffffffffc02074c4 <strchr+0xc>
    }
    return NULL;
ffffffffc02074d0:	4501                	li	a0,0
}
ffffffffc02074d2:	8082                	ret
ffffffffc02074d4:	8082                	ret

ffffffffc02074d6 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02074d6:	ca01                	beqz	a2,ffffffffc02074e6 <memset+0x10>
ffffffffc02074d8:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02074da:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02074dc:	0785                	addi	a5,a5,1
ffffffffc02074de:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02074e2:	fec79de3          	bne	a5,a2,ffffffffc02074dc <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02074e6:	8082                	ret

ffffffffc02074e8 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02074e8:	ca19                	beqz	a2,ffffffffc02074fe <memcpy+0x16>
ffffffffc02074ea:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02074ec:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02074ee:	0585                	addi	a1,a1,1
ffffffffc02074f0:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02074f4:	0785                	addi	a5,a5,1
ffffffffc02074f6:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02074fa:	fec59ae3          	bne	a1,a2,ffffffffc02074ee <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02074fe:	8082                	ret
